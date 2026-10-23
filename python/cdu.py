# -*- coding: utf-8 -*-
"""Model Court HTML-shell/AJAX CDU contract, on Python 3.4 CGI."""
import io
import os
import string
import subprocess
import urllib.parse
import uuid
import xml.etree.ElementTree as ET
from xml.parsers import expat
from http_support import Request, Response, atomic_write, command, fetch, log, read_ini

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VERSION = '1.0.0'
FULL = {'Daily List': 'daily-list', 'Court Detail': 'court-room-detail',
        'All Case Status': 'all-case-status', 'Summary by Name': 'summary-by-name',
        'Court List': 'court-room-list', 'All Court Status': 'all-court-status',
        'Jury Current Status': 'jury-current-status', 'No Info': 'no-info'}


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
    settings = settings if settings is not None else read_ini(os.environ.get('XHIBIT_CDU_CONFIG', os.path.join(root, 'cdu.ini')))
    content_type = settings.get('defaultContentType', 'text/html; charset=UTF-8')
    route = request.route or 'index.php'
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
        try:
            data = fetcher(url, timeout=float(settings['timeout']))
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
        return Response(transformer(data, 'new/' + name + '.xsl', settings, root), content_type=content_type)
    except DisplayError as exc:
        log(exc.reason + ' - ' + url, 'index.php')
        # Uncaught SimpleXMLElement errors produce an empty HTTP 500 in PHP.
        if exc.reason in ('INVALID_XML', 'INVALID_XSL'):
            return Response(status=500, content_type=content_type)
        return Response(holding_page(mac, exc.reason, root), content_type=content_type)


def main():
    try:
        handle(Request.from_cgi()).emit()
    except Exception as exc:
        log('CDU_FAILURE ' + type(exc).__name__)
        Response(status=500).emit()


if __name__ == '__main__':
    main()
