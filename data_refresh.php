<?php
/*#############################################################################
##                            ~~ Data_Refresh.php ~~                         ##
##                         Author: Warren Ayling (2016)                      ##
#############################################################################*/
define("CDU_VERSION", "1.0.1");

define("INI_FILE", "cdu.ini");
define("INI_USE_DB", "fetch");
define("MAC_CMD", "macAddressCmd");
define("DEFAULT_MAC", "defaultMacAddress");
define("DEFAULT_PAGE", "defaultPage");

define("XSLT_DEFAULT", "xsl/old/");
define("XSLT_OLD", "xsl/old/");
define("XSLT_NEW", "xsl/new/");

define("HTTP_MAC", "macAddr");
define("LAST_UPDATED", "lastUpdatedLocation");
define("HTTP_CURRENT_PAGE_INDEX", "currentPageIndex");

define("LAST_RUN_FILE", "timestampMonitorFile");

$iniValues = parse_ini_file(INI_FILE, FALSE, INI_SCANNER_RAW);
$proxyUrl = $iniValues[INI_USE_DB];
$macAddressCmd = $iniValues[MAC_CMD];
$defaultHTMLpage = $iniValues[DEFAULT_PAGE];
$lastUpdatedLocation = $iniValues[LAST_UPDATED];

$lastRunFile = $iniValues[LAST_RUN_FILE];

$macAddress = '';
$errorReason = null;

// touch the last update file - this is used by monitor
touch($lastRunFile);

// extract the MAC Address from the HTTP parameters if it exists
if (isset($_GET[HTTP_MAC])) {
	$macAddress = $_GET[HTTP_MAC];
} else {
	// MAC Address is not given, try extracting it from command line
	if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
		// do nothing - the system cmd is customised for UNIX
	} else {
		// MAC Address is not given, try extracting it from command line
		$returnVal = 0;
		$resultsArray = null;
		$cmdResults = exec($macAddressCmd, $resultsArray, $returnVal);
		$macAddress = implode($resultsArray);
	}
}

$currentPageIndex = NULL;
// extract the Current Page Index Address from the HTTP parameters if it exists
if (isset($_GET[HTTP_CURRENT_PAGE_INDEX])) {
	$currentPageIndex = $_GET[HTTP_CURRENT_PAGE_INDEX];
}

// if MAC address is still not known, use the default MAC address
if (strlen($macAddress) == 0) {
	$macAddress = $iniValues[DEFAULT_MAC];
}

// by default, show the default holding page (assume error until proven success)
$showDefaultPage = true;
$httpUrl = null;

if (isset($macAddress) && strlen($macAddress) > 0) {
	//print("MAC Address: $macAddress\n");
	
	// as this is simply refreshing the data, inform the proxy by enforcing the "data_refresh" parameter
	if (isset($currentPageIndex)) {
		$httpUrl = $proxyUrl . "?macAddr=" . urlencode($macAddress) . "&data_refresh=1&currentPageIndex=" . urlencode($currentPageIndex);
	} else {
		$httpUrl = $proxyUrl . "?macAddr=" . urlencode($macAddress);
	}
	
	//print("<br/>Proxy URL: <a target=\"_blanks\" href=\"$httpUrl\">$httpUrl</a><br/>\n");
	
	// fetch the XML from localproxy
	$xmlStr = file_get_contents($httpUrl);
	//print($xmlStr);
	if ($xmlStr === FALSE) {
		$errorReason = "REMOTE_FETCH_FAILED";
	}
	
	// now, extract the name of the page and the XSL stylesheet to apply
	if (strpos($xmlStr, '/COURT') > 0) {
		// to the XML document, append a new element /CLIENT/VERSION
		//  Note - it is quicker and easier to use string substitution
		$xmlStr = str_replace("</COURT>", "\t<CLIENT><VERSION>" . CDU_VERSION . "</VERSION></CLIENT>\n</COURT>", $xmlStr);

		$xmlObj = new SimpleXMLElement($xmlStr);
		if (isset($xmlObj)) {
			// NOTE - xpath returns an array
			$pageTypeXML = $xmlObj->xpath('/COURT/PAGE/TYPE');			
			$pageType = NULL;
			if (count($pageTypeXML) == 1) {
				$pageType = $pageTypeXML[0];
			}
			
			$xsltXML = $xmlObj->xpath('/COURT/CDU/XSL');
			$xslt = NULL;
			if (count($xsltXML) == 1) {
				$xslt = $xsltXML[0];
			}
			
			// need to get the last updated date/time - and write to local file, so it
			//  can be polled locally
			$lastUpdated = $xmlObj->xpath('/COURT/PAGE/LAST-UPDATED');
			file_put_contents($lastUpdatedLocation, "Last Updated: " . $lastUpdated[0]);
			
			//print("Page Type: $pageType<br/>\n");
			//print("XSLt: $xslt<br/>\n");
			
			$xslTransformBase = NULL;
			$xslTransform = NULL;
			
			// Page Type and XSL must both be defined for this to be valid XML
			if ((isset($pageType) && (strlen($pageType) > 0)) &&
				(isset($xslt) && (strlen($xslt) > 0))) {
				// using the XSLT, form the base location for stylesheet
				if (strcmp($xslt, 'new') == 0) {
					$xslTransformBase = XSLT_NEW;
				} elseif (strcmp($xslt, 'old') == 0) {
					$xslTransformBase = XSLT_OLD;
				} else {
					$xslTransformBase = XSLT_DEFAULT;
				}
				
				// from the page type, determine the major name for the stylesheet
				switch ($pageType) {
					case "Daily List":
						$xslTransform = 'daily-list-xhibit-inc.xsl';
						break;
					
					// court detail has no table refresh stylesheet
					
					case "All Case Status":
						$xslTransform = 'all-cases-xhibit-inc.xsl';
						break;
					
					case "Summary by Name":
						$xslTransform = 'by-name-xhibit-inc.xsl';
						break;
					
					case "Court List":
						$xslTransform = 'court-room-list-xhibit-inc.xsl';
						break;
					
					case "All Court Status":
						$xslTransform = 'all-court-status-inc.xsl';
						break;
					
					case "Jury Current Status":
						$xslTransform = 'jury-current-status-inc.xsl';
						break;
					
					default:
						$xslTransform = null;
						$errorReason = "UNEXPECTED_PAGE_TYPE";
						break;
				}

				if (is_null($errorReason)) {
					writeInfoToSysLog("SUCCESS: using stylesheet - $xslTransform");
				
					// the full XSLt to apply is:
					$myXSLt = $xslTransformBase . $xslTransform;
					//print("My XSLt location: <a target=\"_blank\" href=\"$myXSLt\">$myXSLt</a><br/>");
					
					// now transform the XML to HTML
					$xslt = new XSLTProcessor();
					$xslObj = new SimpleXMLElement(file_get_contents($myXSLt));
					if (isset($xslObj)) {
						$xslt->importStylesheet($xslObj);
						$transformedOutput = $xslt->transformToXml($xmlObj);
						
						if (FALSE !== $transformedOutput) {
							echo $transformedOutput;
						
							$showDefaultPage = false;
						} else {
							$errorReason = "FAILED_XSLT";
						}
					} else {
						$errorReason = "INVALID_XSL";
					}
				}
			} // end if (pageType & xsl)
			
		} else { // end if isset($xmlObj)
			$errorReason = "INVALID_XML";
		}
	} else { // end if strpos (?xml)
		if (is_null($errorReason)) {
			$errorReason = "INVALID_SERVER_RESPONSE";
		}
		
		//print($xmlStr);
	}
} else {
	$errorReason = "NO_MAC_ADDRESS";
}

if (!function_exists('http_response_code')) {
	function http_response_code($code = NULL) {

		if ($code !== NULL) {
			switch ($code) {
				case 100: $text = 'Continue'; break;
				case 101: $text = 'Switching Protocols'; break;
				case 200: $text = 'OK'; break;
				case 201: $text = 'Created'; break;
				case 202: $text = 'Accepted'; break;
				case 203: $text = 'Non-Authoritative Information'; break;
				case 204: $text = 'No Content'; break;
				case 205: $text = 'Reset Content'; break;
				case 206: $text = 'Partial Content'; break;
				case 300: $text = 'Multiple Choices'; break;
				case 301: $text = 'Moved Permanently'; break;
				case 302: $text = 'Moved Temporarily'; break;
				case 303: $text = 'See Other'; break;
				case 304: $text = 'Not Modified'; break;
				case 305: $text = 'Use Proxy'; break;
				case 400: $text = 'Bad Request'; break;
				case 401: $text = 'Unauthorized'; break;
				case 402: $text = 'Payment Required'; break;
				case 403: $text = 'Forbidden'; break;
				case 404: $text = 'Not Found'; break;
				case 405: $text = 'Method Not Allowed'; break;
				case 406: $text = 'Not Acceptable'; break;
				case 407: $text = 'Proxy Authentication Required'; break;
				case 408: $text = 'Request Time-out'; break;
				case 409: $text = 'Conflict'; break;
				case 410: $text = 'Gone'; break;
				case 411: $text = 'Length Required'; break;
				case 412: $text = 'Precondition Failed'; break;
				case 413: $text = 'Request Entity Too Large'; break;
				case 414: $text = 'Request-URI Too Large'; break;
				case 415: $text = 'Unsupported Media Type'; break;
				case 500: $text = 'Internal Server Error'; break;
				case 501: $text = 'Not Implemented'; break;
				case 502: $text = 'Bad Gateway'; break;
				case 503: $text = 'Service Unavailable'; break;
				case 504: $text = 'Gateway Time-out'; break;
				case 505: $text = 'HTTP Version not supported'; break;
				default:
					exit('Unknown http status code "' . htmlentities($code) . '"');
				break;
			}

			$protocol = (isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'HTTP/1.0');

			header($protocol . ' ' . $code . ' ' . $text);

			$GLOBALS['http_response_code'] = $code;

		} else {

			$code = (isset($GLOBALS['http_response_code']) ? $GLOBALS['http_response_code'] : 200);

		}

		return $code;

	}
}

/* helpers for writing to syslog*/
function openSyslog() {
	// open syslog, include the process ID and use LOCAL5 syslog facility (channel)
	if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
		openlog("data_refresh.php", LOG_PID | LOG_NDELAY, LOG_USER);
	} else {
		openlog("data_refresh.php", LOG_PID | LOG_NDELAY, LOG_LOCAL5);
	}
}

function writeErrorToSysLog($message) {
	openSyslog();
	syslog(LOG_ERR, $message);
	closelog();
}
function writeWarningToSysLog($message) {
	openSyslog();
	syslog(LOG_WARNING, $message);
	closelog();
}
function writeInfoToSysLog($message) {
	openSyslog();
	syslog(LOG_INFO, $message);
	closelog();
}

// if having got this far, check to see if the show default page flag
//  is set, and if so, show the default page
if ($showDefaultPage) {
	// log the error to syslog
	if (is_null($httpUrl)) {
		$url = "?macAddr=" . urlencode($macAddress);
		if ($currentPageIndex) {
			$url = $url . "&pageIndex=" . $currentPageIndex;
		}
	} else {
		$url = $httpUrl;
	}
	//print($url);
	writeErrorToSysLog("$errorReason - $url");

	// with data refresh, we don't want to return a branded No Information to Display
	// we simply want to set HTTP error code to prevent any unexpected update to content.
	switch ($errorReason) {	
		case "UNEXPECTED_PAGE_TYPE":
			http_response_code(204);
			break;
			
		case "INVALID_SERVER_RESPONSE":
		case "INVALID_XML":
			http_response_code(500);
			break;
			
		case "REMOTE_FETCH_FAILED":
		case "FAILED_XSLT":
		case "INVALID_XSL":
		case "NO_MAC_ADDRESS":
		case "UNEXPECTED_PAGE_TYPE":
		default:
			http_response_code(503);
	}
	
	//print ("Error Reason: $errorReason");
}
?>
