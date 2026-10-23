# -*- coding: utf-8 -*-
"""Model Court HTML-shell/AJAX CDU contract, on Python 3.4 CGI."""
import configparser
import io
import os
import re
import string
import subprocess
import sys
import urllib.parse
import uuid
import xml.etree.ElementTree as ET
from xml.parsers import expat
from http_support import Request, Response, atomic_write, command, fetch, log

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VERSION = '1.0.0'
FULL = {'Daily List': 'daily-list', 'Court Detail': 'court-room-detail',
        'All Case Status': 'all-case-status', 'Summary by Name': 'summary-by-name',
        'Court List': 'court-room-list', 'All Court Status': 'all-court-status',
        'Jury Current Status': 'jury-current-status', 'No Info': 'no-info'}
# The verified stylesheets copy /COURT/CDU/NOTICE into a single-quoted JavaScript
# string inside <script>, which HTML output does not escape. Escape only what would
# end or alter that string; notices without these characters keep identical bytes.
SCRIPT_ESCAPES = {'\\': '\\\\', "'": "\\'", '\n': '\\n', '\r': '\\r',
                  '\u2028': '\\u2028', '\u2029': '\\u2029', '<': '\\x3c'}
START_TAG = re.compile(b'<[^>"\']*(?:(?:"[^"]*"|\'[^\']*\')[^>"\']*)*>')
# Server-set CGI variables only. Client headers (HTTP_*, CONTENT_TYPE) and request
# data never reach the MAC command shell, sudo or xsltproc; mod_php exec() did not
# pass them either.
SUBPROCESS_ENVIRONMENT = ('PATH', 'LANG', 'LC_ALL', 'LC_CTYPE', 'TZ', 'LD_LIBRARY_PATH',
                          'XHIBIT_CDU_CONFIG')


class DisplayError(Exception):
    def __init__(self, reason):
        self.reason = reason


def parse_xml(data):
    # Deliberate security-only difference: never expand DTDs/external entities.
    def reject(*unused):
        raise DisplayError('INVALID_XML')
    guard = expat.ParserCreate()
    guard.StartDoctypeDeclHandler = reject
    guard.EntityDeclHandler = reject
    guard.ExternalEntityRefHandler = reject
    try:
        guard.Parse(data, True)
        return ET.fromstring(data)
    except (expat.ExpatError, ET.ParseError, ValueError):
        raise DisplayError('INVALID_XML')


def node_text(root, path):
    nodes = root.findall(path)
    return (nodes[0].text or '') if len(nodes) == 1 else ''


def script_safe_notice(data):
    """Rewrite only /COURT/CDU/NOTICE content that would break the stylesheets' script."""
    parser = expat.ParserCreate()
    path, notices = [], []

    def start(name, attributes):
        path.append(name)
        if path == ['COURT', 'CDU', 'NOTICE']:
            notices.append([parser.CurrentByteIndex, None, []])

    def end(name):
        if path == ['COURT', 'CDU', 'NOTICE']:
            notices[-1][1] = parser.CurrentByteIndex
        path.pop()

    def text(value):
        if path[:3] == ['COURT', 'CDU', 'NOTICE']:
            notices[-1][2].append(value)

    parser.StartElementHandler = start
    parser.EndElementHandler = end
    parser.CharacterDataHandler = text
    parser.Parse(data, True)
    for begin, finish, parts in reversed(notices):
        value = ''.join(parts)  # the string value xsl:value-of copies
        escaped = ''.join(SCRIPT_ESCAPES.get(char, char) for char in value)
        tag = START_TAG.match(data, begin)
        if escaped == value or tag is None or data[finish:finish + 2] != b'</':
            continue
        escaped = escaped.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        data = data[:tag.end()] + escaped.encode('ascii', 'xmlcharrefreplace') + data[finish:]
    return data


def transform(data, stylesheet, settings, root=ROOT):
    path = os.path.join(root, 'xsl', stylesheet)
    expected = os.path.realpath(os.path.join(root, 'xsl')) + os.sep
    if not os.path.realpath(path).startswith(expected) or not os.path.isfile(path):
        raise DisplayError('INVALID_XSL')
    try:
        ET.parse(path)
    except (IOError, ET.ParseError):
        raise DisplayError('INVALID_XSL')
    try:
        return command([settings.get('xsltproc', '/usr/bin/xsltproc'), '--nonet', '--novalid',
                        '--nowrite', '--nomkdir', path, '-'], data,
                       timeout=float(settings.get('transformTimeout', 60)))
    except (OSError, RuntimeError, subprocess.TimeoutExpired):
        raise DisplayError('FAILED_XSLT')


def mac_address(query, settings, runner=command):
    if 'macAddr' in query:
        value = query['macAddr']
    else:
        value = ''
        if os.name != 'nt' and settings.get('macAddressCmd'):
            try:
                # Existing trusted root-owned UNIX pipeline; no HTTP interpolation.
                data = runner(['/bin/sh', '-c', settings['macAddressCmd']],
                              timeout=float(settings.get('macCommandTimeout', 60)), check=False)
                value = ''.join(line.rstrip() for line in data.decode('utf-8', 'replace').splitlines())
            except (OSError, RuntimeError, subprocess.TimeoutExpired):
                pass
    return value or '00:00:00:00:00:00'


def ini_value(value):
    # As parse_ini_file: a quoted value ends at its quote, and an unquoted ' ;' starts
    # a comment. A ';' without leading whitespace stays, e.g. text/html; charset=UTF-8.
    value = value.strip()
    if value[:1] in ('"', "'"):
        end = value.find(value[0], 1)
        if end > 0 and value[end + 1:].lstrip()[:1] in ('', ';'):
            return value[1:end]
        return value
    return re.split(r'(?:^|\s);', value, 1)[0].rstrip()


def read_settings(path):
    # The PHP-era cdu.ini: like parse_ini_file, a repeated key or section is not an error
    # and the later value wins.
    parser = configparser.RawConfigParser(strict=False)
    parser.optionxform = str
    with io.open(path, encoding='utf-8-sig') as stream:
        source = stream.read()
    parser.read_string('[XHIBIT_DEFAULT]\n' + source)
    values = {}
    for section in parser.sections():
        for key, value in parser.items(section):
            values[key] = ini_value(value)
    return values


def touch(path):
    try:
        with open(path, 'ab'):
            pass
        os.utime(path, None)
    except OSError:
        pass


def holding_page(mac, reason, root):
    with io.open(os.path.join(root, 'python', 'templates', 'no-information.html'), encoding='utf-8') as stream:
        template = stream.read()
    # PHP heredoc excludes the newline before its closing marker.
    if template.endswith('\n'):
        template = template[:-1]
    style = 'badInformationContainer' if reason in ('INVALID_XML', 'INVALID_SERVER_RESPONSE') else 'noInformationToDisplayContainer'
    return string.Template(template).substitute(informationBlockStyle=style)


def screenshot(settings, runner=command):
    filename = uuid.uuid4().hex + '-www-data'
    try:
        data = runner([settings.get('sudo', '/usr/bin/sudo'), '-n', '-u', 'xhibit',
                       settings.get('captureHelper', '/usr/local/libexec/xhibit-capture'), filename],
                      timeout=float(settings.get('screenshotTimeout', 60)))
        if data:
            return Response(data, content_type='image/png', headers=[('Content-Length', str(len(data)))])
    except (OSError, RuntimeError, subprocess.TimeoutExpired):
        pass
    return Response(content_type=settings.get('defaultContentType', 'text/html; charset=UTF-8'))


def handle(request, settings=None, fetcher=fetch, transformer=transform, root=ROOT):
    route = request.route or 'index.php'
    if settings is None:
        try:
            settings = read_settings(os.environ.get('XHIBIT_CDU_CONFIG', os.path.join(root, 'cdu.ini')))
        except (OSError, ValueError, configparser.Error) as exc:
            # The verified index.php is static and screenshot.php needed no configuration;
            # every setting they use has a default.
            if route not in ('index.php', 'screenshot.php'):
                raise
            log('CDU_CONFIG_FAILURE ' + type(exc).__name__)
            settings = {}
    content_type = settings.get('defaultContentType', 'text/html; charset=UTF-8')
    if route == 'screenshot.php':
        return screenshot(settings)
    if route == 'index.php':
        with open(os.path.join(root, 'python', 'templates', 'index.html'), 'rb') as stream:
            return Response(stream.read(), content_type=content_type)
    if route != 'xhibit_content.php':
        return Response(status=404, content_type=content_type)
    touch(settings['timestampMonitorFile'])
    mac = mac_address(request.query, settings)
    url = settings['fetch'] + '?macAddr=' + urllib.parse.quote_plus(mac)
    if 'currentPageIndex' in request.query:
        url += '&currentPageIndex=' + urllib.parse.quote_plus(request.query['currentPageIndex'])
    try:
        timeout = float(settings['timeout'])
    except (KeyError, TypeError, ValueError):
        # Same holding page and no fetch, as before, but log the configuration fault
        # instead of an upstream INVALID_SERVER_RESPONSE.
        log('INVALID_CONFIG timeout - ' + url, 'index.php')
        return Response(holding_page(mac, 'INVALID_SERVER_RESPONSE', root), content_type=content_type)
    try:
        try:
            data = fetcher(url, timeout=timeout)
        except Exception:
            # PHP str_replace coerces FALSE to "" BEFORE its strict FALSE check.
            data = b''
        data = data.replace(b'&', b'&amp;')
        if data.find(b'/COURT') <= 0:
            raise DisplayError('INVALID_SERVER_RESPONSE')
        data = data.replace(b'</COURT>', ('\t<CLIENT><VERSION>' + VERSION + '</VERSION></CLIENT>\n</COURT>').encode('ascii'))
        document = parse_xml(data)
        updated = document.findall('PAGE/LAST-UPDATED') if document.tag == 'COURT' else []
        try:
            atomic_write(settings['lastUpdatedLocation'], 'Last Updated: ' + ((updated[0].text or '') if updated else ''))
        except OSError:
            pass
        page_type = node_text(document, 'PAGE/TYPE') if document.tag == 'COURT' else ''
        version = node_text(document, 'CDU/XSL') if document.tag == 'COURT' else ''
        if not page_type or not version:
            raise DisplayError('NO_MAC_ADDRESS')
        name = FULL.get(page_type)
        if name is None:
            raise DisplayError('UNEXPECTED_PAGE_TYPE')
        # The original validates XSL but always uses xsl/new/, even for "old".
        log('SUCCESS: using stylesheet - ' + name + '.xsl', 'index.php', 6)
        return Response(transformer(script_safe_notice(data), 'new/' + name + '.xsl', settings, root),
                        content_type=content_type)
    except DisplayError as exc:
        log(exc.reason + ' - ' + url, 'index.php')
        # Uncaught SimpleXMLElement errors produce an empty HTTP 500 in PHP.
        if exc.reason in ('INVALID_XML', 'INVALID_XSL'):
            return Response(status=500, content_type=content_type)
        return Response(holding_page(mac, exc.reason, root), content_type=content_type)


def discard_body(stream=None):
    # No CDU route uses a request body: drain it in bounded chunks instead of
    # buffering it in memory, so a large POST cannot exhaust the CDU.
    stream = stream or sys.stdin.buffer
    remaining = max(0, int(os.environ.get('CONTENT_LENGTH') or '0'))
    while remaining > 0:
        chunk = stream.read(min(remaining, 65536))
        if not chunk:
            break
        remaining -= len(chunk)


def main():
    try:
        request = Request(os.environ)
        discard_body()
        for key in list(os.environ):
            if key not in SUBPROCESS_ENVIRONMENT:
                del os.environ[key]
        handle(request).emit()
    except Exception as exc:
        log('CDU_FAILURE ' + type(exc).__name__)
        Response(status=500).emit()


if __name__ == '__main__':
    main()
