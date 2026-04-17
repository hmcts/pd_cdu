<?php
/*#############################################################################
##                             ~~ Screenshot.php ~~                          ##
##                         Author: Warren Ayling (2016)                      ##
#############################################################################*/


// makes a system call to a local script to capture the screenshot, then returns the data as an image stream.
define("SCREENSAVER_SCRIPT", "sudo -u xhibit /home/xhibit/bin/screencapture.sh -f ");

// the filename to use for the capture is the current timestanp
$captureFilename = date("Ymd-His") . "-www-data";
// the screen capture script saves file in /tmp with ".png" extension
$targetFilename = "/tmp/${captureFilename}.png";

$systemCmd = SCREENSAVER_SCRIPT . $captureFilename;
//print ($systemCmd);
system($systemCmd);

if (file_exists($targetFilename)) {
	// send the right headers
	header("Content-Type: image/png");
	header("Content-Length: " . filesize($targetFilename));

	// dump the picture and stop the script
	readfile($targetFilename);
	
	// TODO - should delete the file after streamed back
	unlink($targetFilename);
}
?>
