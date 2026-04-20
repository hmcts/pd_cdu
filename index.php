<?php
/*#############################################################################
##                               ~~ Index.php ~~                             ##
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

define("INI_TIMEOUT", "timeout");

define("HTTP_TESTFILE", "testFile");


$iniValues = parse_ini_file(INI_FILE, FALSE, INI_SCANNER_RAW);
$proxyUrl = $iniValues[INI_USE_DB];
$macAddressCmd = $iniValues[MAC_CMD];
$defaultHTMLpage = $iniValues[DEFAULT_PAGE];
$lastUpdatedLocation = $iniValues[LAST_UPDATED];
$httpTimeout = $iniValues[INI_TIMEOUT];

$lastRunFile = $iniValues[LAST_RUN_FILE];

$errorReason = null;

$macAddress = '';

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
$xmlStr = null;
$httpUrl = null;

if (isset($macAddress) && strlen($macAddress) > 0) {
	//print("MAC Address: $macAddress\n");
	if (isset($currentPageIndex)) {
		$httpUrl = $proxyUrl . "?macAddr=" . urlencode($macAddress) . "&currentPageIndex=" . urlencode($currentPageIndex);
	} else {
		$httpUrl = $proxyUrl . "?macAddr=" . urlencode($macAddress);
	}
	
	//print("<br/>Proxy URL: <a target=\"_blanks\" href=\"$httpUrl\">$httpUrl</a><br/>\n");
	
	// fetch the XML from localproxy - the default timeout is 60 seconds; defaulting to .
	$ctx = stream_context_create(array('http' => array('timeout' => $httpTimeout, 'method' => "GET")));
	if (isset($_GET[HTTP_TESTFILE])) {
		$testFile = basename($_GET[HTTP_TESTFILE]);  // sanitize input
		$testFilePath = __DIR__ . "/testData/" . $testFile;

		if (file_exists($testFilePath)) {
			writeInfoToSysLog("Using test XML file: $testFile");
			$xmlStr = file_get_contents($testFilePath);
		} else {
			writeErrorToSysLog("Requested test file not found: $testFile");
			$errorReason = "INVALID_TEST_FILE";
			$xmlStr = false;
		}
	} else {
		// Default: fetch from the configured proxy
		$ctx = stream_context_create(array('http' => array('timeout' => $httpTimeout, 'method' => "GET")));
		$xmlStr = file_get_contents($httpUrl, false, $ctx);
	}

	//$xmlStr = file_get_contents($httpUrl);
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
			
			//print("Page Type: $pageType<br/>\n");
			//print("XSLt: $xslt<br/>\n");
			// need to get the last updated date/time - and write to local file, so it
			//  can be polled locally
			$lastUpdated = $xmlObj->xpath('/COURT/PAGE/LAST-UPDATED');
			file_put_contents($lastUpdatedLocation, "Last Updated: " . $lastUpdated[0]);			
			
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
						$xslTransform = 'daily-list-xhibit.xsl';
						break;
					
					case "Court Detail":
						$xslTransform = 'court-room-detail-xhibit.xsl';
						break;
					
					case "All Case Status":
						$xslTransform = 'all-cases-xhibit.xsl';
						break;
					
					case "Summary by Name":
						$xslTransform = 'by-name-xhibit.xsl';
						break;
					
					case "Court List":
						$xslTransform = 'court-room-list-xhibit.xsl';
						break;
					
					case "All Court Status":
						$xslTransform = 'all-court-status.xsl';
						break;
					
					case "Jury Current Status":
						$xslTransform = 'jury-current-status.xsl';
						break;
					
					case "No Info":
						$xslTransform = 'no-info.xsl';
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

/* helpers for writing to syslog*/
function openSyslog() {
	// open syslog, include the process ID and use LOCAL5 syslog facility (channel)
	if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
		openlog("index.php", LOG_PID | LOG_NDELAY, LOG_USER);
	} else {
		openlog("index.php", LOG_PID | LOG_NDELAY, LOG_LOCAL5);
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

	switch ($errorReason) {
		case "INVALID_SERVER_RESPONSE":
		case "INVALID_XML":
			$informationBlockStyle = "badInformationContainer";
			break;
		case "REMOTE_FETCH_FAILED":
		case "FAILED_XSLT":
		case "INVALID_XSL":
		case "NO_MAC_ADDRESS":
		case "UNEXPECTED_PAGE_TYPE":
		default:
			$informationBlockStyle = "noInformationToDisplayContainer";
	}
	//print("Error Reason: $errorReason\n");
	//print("Container style: $informationBlockStyle\n");
	
	$urlEncodedMacAddress = urlencode($macAddress);
	
	// determine the cause of the error
	print <<<NO_INFO
<!DOCTYPE html>
<html>
	<head>
	    <meta content="15; index.php?macAddr=$urlEncodedMacAddress" http-equiv="refresh">
	    <link href="css/new/general.css" rel="stylesheet" type="text/css">
		<script src="display_documentNEW.js"></script>
		
		<!-- Hides the scrollbar for the page that is is picking up from seemingly nowhere -->
		<style>
				* {overflow: hidden;}
		</style>
		
	</head>
	<body>
		
		<div id="heading" class="headerContainer">
	        <span class="headerLogo"><img src="images/MoJLogo.png" alt="MoJ Logo" style="width: 100%;"></img></span>
	        <span class="headerText"></span>
	    </div>

		<div class="$informationBlockStyle">
			<span class="noInformationToDisplayText">No Information To Display</span>
		</div>
		
		<div class="notificationBar" id="notificationBar">
			<div class="pageNumberDisplay"><span id="pageInfo" class="pageNumberText">Page 1 of 1</span></div>
		</div>
		
	</body>
</html>
NO_INFO;
}
?>
