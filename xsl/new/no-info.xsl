<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="/">
		<html>
			<head>
				<script>
					var thisUrl = '<xsl:text>xhibit_content.php?macAddr=</xsl:text><xsl:value-of select="/COURT/CDU/MAC-ADDR"/><xsl:text>&amp;currentPageIndex=</xsl:text><xsl:value-of select="/COURT/PAGE/CURRENT-PAGE-INDEX"/>';
					var XML_REFRESH = <xsl:value-of select="/COURT/CDU/REFRESH"/>;
					var NOTIFICATION = '<xsl:value-of select="/COURT/CDU/NOTICE"/>';
					var POWERSAVING = '<xsl:value-of select="/COURT/CDU/POWER-SAVING"/>';
					var PAGELANGUAGE = '<xsl:value-of select="/COURT/PAGE/LANGUAGE"/>';
					var NOINFO = "false";
				</script>	
			</head>
			<body>
                <!-- LOGO AND SITE TITLE -->
                <div id="heading" class="headerContainer">
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                        <span class="headerLogo">
							<img src="images/MoJLogo.png" alt="MoJ Logo" style="width: 100%;"></img>
						</span>
                    </xsl:if>
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                        <span class="headerLogo">
							<img src="images/MoJLogoWelsh.png" alt="MoJ Logo" style="width: 100%;"></img>
						</span>
                    </xsl:if>
                    <span class="headerText">
						<xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
							<xsl:value-of select="/COURT/CDU/SITE-TITLE"/>
						</xsl:if>
						<xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
							<xsl:value-of select="/COURT/CDU/SITE-TITLE-WELSH"/>
						</xsl:if>
                    </span>
                </div>

				<!-- TITLE, LAST UPDATED AND DEBUG INFORMATION -->
                <div id="pageTitle" class="title">
					<span>
							<xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
								<xsl:value-of select="/COURT/CDU/LOCATION"/>
							</xsl:if>
							<xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
								<xsl:if test="COURT/CDU/LOCATION = 'Reception'">
									<xsl:text>Derbynfa</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Jury Lounge'">
									<xsl:text>Lofa’r Rheithgor</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Robing Room'">
									<xsl:text>Ystafell Ymwisgo</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Canteen'">
									<xsl:text>Cantîn</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Waiting Area'">
									<xsl:text>Ardal aros</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Lobby'">
									<xsl:text>Cyntedd</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Witness Services'">
									<xsl:text>Gwasanaethau i Dystion</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Magistrates Court'">
									<xsl:text>Llys ynadon</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Press Room'">
									<xsl:text>Ystafell y Wasg</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 1'">
									<xsl:text>Llys 1</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 2'">
									<xsl:text>Llys 2</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 3'">
									<xsl:text>Llys 3</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 4'">
									<xsl:text>Llys 4</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 5'">
									<xsl:text>Llys 5</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 6'">
									<xsl:text>Llys 6</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 7'">
									<xsl:text>Llys 7</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 8'">
									<xsl:text>Llys 8</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 9'">
									<xsl:text>Llys 9</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 10'">
									<xsl:text>Llys 10</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 11'">
									<xsl:text>Llys 11</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 12'">
									<xsl:text>Llys 12</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 13'">
									<xsl:text>Llys 13</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 14'">
									<xsl:text>Llys 14</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 15'">
									<xsl:text>Llys 15</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 16'">
									<xsl:text>Llys 16</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 17'">
									<xsl:text>Llys 17</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 18'">
									<xsl:text>Llys 18</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 19'">
									<xsl:text>Llys 19</xsl:text>
								</xsl:if>
								<xsl:if test="COURT/CDU/LOCATION = 'Court 20'">
									<xsl:text>Llys 20</xsl:text>
								</xsl:if>
							</xsl:if>
					</span>
					
					<div class="lastUpdated">
						<span id="lastUpdated">
							<xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
								Last Updated:
							</xsl:if>
							<xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
								Diweddarwyd Ddiwethaf:
							</xsl:if>
							<xsl:value-of select="/COURT/PAGE/LAST-UPDATED" />
						</span>
						<span>
							<xsl:text> | </xsl:text>
						</span> 
                        <span>
							<xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
								Version: 
							</xsl:if>
							<xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
								Fersiwn:
							</xsl:if>
							<xsl:text>CDU_</xsl:text>
							<xsl:value-of select="/COURT/CLIENT/VERSION" />
							<xsl:text> / </xsl:text>
							<xsl:text>PXY_</xsl:text>
							<xsl:value-of select="/COURT/CDU/VERSION" />
						</span>
						<span>
							<xsl:text> | </xsl:text>
						</span>
						<span>
							<xsl:value-of select="/COURT/CDU/TITLE"/>
						</span> 
					</div>
                </div>

				<!-- BODY -->
				<div id="bodyArea" class="body-area">
					<div class="noInformationContainer">
						<span class="noInformationToDisplayText">No Information To Display</span>
					</div>
				</div>
				
				<script>
					timeBetweenFrame = XML_REFRESH*2000;
					setTimeout(function(){nextPage(thisUrl)},timeBetweenFrame);
				</script>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>