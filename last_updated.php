<?php
/*#############################################################################
##                            ~~ Last_Updated.php ~~                         ##
##                         Author: Warren Ayling (2016)                      ##
#############################################################################*/
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

$iniValues = parse_ini_file(INI_FILE, FALSE, INI_SCANNER_RAW);
$proxyUrl = $iniValues[INI_USE_DB];
$macAddressCmd = $iniValues[MAC_CMD];
$defaultHTMLpage = $iniValues[DEFAULT_PAGE];
$lastUpdatedLocation = $iniValues[LAST_UPDATED];

$lastUpdatedStr = file_get_contents($lastUpdatedLocation);
print($lastUpdatedStr);
?>
