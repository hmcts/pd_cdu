<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
	<html>
	<head>
		<meta http-equiv="refresh">
			<xsl:attribute name="content">
				<xsl:value-of select="/COURT/CDU/REFRESH"/>
				<xsl:text>; index.php?macAddr=</xsl:text>
				<xsl:value-of select="/COURT/CDU/MAC-ADDR"/>
				<xsl:text>&amp;currentPageIndex=</xsl:text>
				<xsl:value-of select="/COURT/PAGE/CURRENT-PAGE-INDEX"/>
			</xsl:attribute>
		</meta>
		<link href="css/new/general.css" rel="stylesheet" type="text/css"/>
		<script src="display_documentNEW.js"></script>
		<style>
			* {overflow: hidden;}
		</style>
	</head>
	<body>	
		<form name="displayform">
			<input type="hidden" name="listTitleText" value="List"/>
			<input type="hidden" name="ofTitleText" value="of"/>
			<input type="hidden" name="pageTitleText" value="Page"/>
			<input type="hidden" name="macAddress" value="Page">
			<xsl:attribute name="value">
				<xsl:value-of select="/COURT/CDU/MAC-ADDR"/>
			</xsl:attribute>
			</input>
		</form>
		
		<!-- Div Containing Notification Bar -->
		<div class="notificationBar" id="notificationBar">
			<marquee>
				<div id="notificationContents">
					<xsl:value-of select="/COURT/CDU/NOTICE" />
				</div>
			</marquee>
		</div>
		
			<div id="heading" class="headerContainer">
                <span class="headerLogo"><img src="images/MoJLogo.png" alt="MoJ Logo" style="width: 100%;"></img></span>
                <span class="headerText">
                    <xsl:value-of select="/COURT/CDU/SITE-TITLE"/>
                </span>
            </div>
		<div class="title">
			<xsl:value-of select="COURT/CDU/TITLE"/>
			(
			<xsl:value-of select="/COURT/CDU/LOCATION"/>
			) Detail
			<div class="lastUpdated"><span id="lastUpdated">Last Updated: <xsl:value-of select="/COURT/PAGE/LAST-UPDATED" /></span> | Version: <xsl:value-of select="/COURT/CLIENT/VERSION" /> / <xsl:value-of select="/COURT/CDU/VERSION" />
		</div>

		<div class="noInformationContainer">
			<span class="noInformationToDisplayText">No Information To Display</span>
		</div>
		
		<div class="notificationBar" id="notificationBar">
		
		<div class="timeDisplay">
			<span class="timeText" id="time"></span>
		</div>
		
		<div class="pageNumberDisplay"><span id="pageInfo" class="pageNumberText">Page 1 of 1</span></div>

		</div>
		
	</body>
	</html>
    </xsl:template>
</xsl:stylesheet>