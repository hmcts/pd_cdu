<?php
/*#############################################################################
##                              ~~ Refresh.php ~~                            ##
##                         Author: Warren Ayling (2016)                      ##
#############################################################################*/
define("INI_FILE", "cdu.ini");
define("REFRESH_FETCH", "refresh");
define("HTTP_MAC", "macAddr");
define("MAC_CMD", "macAddressCmd");
define("DEFAULT_MAC", "defaultMacAddress");

$iniValues = parse_ini_file(INI_FILE, FALSE, INI_SCANNER_RAW);
$refreshUrl = $iniValues[REFRESH_FETCH];
$macAddressCmd = $iniValues[MAC_CMD];

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

// if MAC address is still not known, use the default MAC address
if (strlen($macAddress) == 0) {
	$macAddress = $iniValues[DEFAULT_MAC];
}

$showDefaultPage = true;
if (isset($macAddress) && strlen($macAddress) > 0) {
	//print("MAC Address: $macAddress\n");
	$httpUrl = $refreshUrl . "?macAddr=" . urlencode($macAddress);
	
	//print("<br/>Proxy URL: <a target=\"_blanks\" href=\"$httpUrl\">$httpUrl</a><br/>\n");
	
	// fetch the XML from localproxy
	$xmlStr = file_get_contents($httpUrl);
	//print($xmlStr);
	
	// now apply XSLt to generate JSON
	if (strpos($xmlStr, '?xml') > 0) {
		$xmlObj = new SimpleXMLElement($xmlStr);
		if (isset($xmlObj)) {			
			// the full XSLt to apply is:
			$myXSLt = 'xsl/new/xml2json.xsl';
			//print("My XSLt location: <a target=\"_blank\" href=\"$myXSLt\">$myXSLt</a><br/>");
			
			// now transform the XML to HTML
			$xslt = new XSLTProcessor();
			$xslt->importStylesheet(new SimpleXMLElement(file_get_contents($myXSLt)));
			echo $xslt->transformToXml($xmlObj);
			
			$showDefaultPage = false;
		} // end isset
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
	// simply return empty contents
	$html = '';
	print ($html);
	
//	writeErrorToSysLog("FAILED: getting refresh data.");
	
	//print("Show default page<br/>\n");
} else {
//	writeInfoToSysLog("SUCCESS: getting refresh data.");
}
?>