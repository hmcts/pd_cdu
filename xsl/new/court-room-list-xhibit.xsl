<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html>
            <head>
				<!-- Attaching Javascript -->
				<xsl:if test="/COURT/PAGE/CURRENT-PAGE-INDEX">
					<meta http-equiv="refresh">
						<xsl:attribute name="content">
							<xsl:value-of select="/COURT/CDU/REFRESH"/>
							<xsl:text>; index.php?macAddr=</xsl:text>
							<xsl:value-of select="/COURT/CDU/MAC-ADDR"/>
							<xsl:text>&amp;currentPageIndex=</xsl:text>
							<xsl:value-of select="/COURT/PAGE/CURRENT-PAGE-INDEX"/>
						</xsl:attribute>
					</meta>
				</xsl:if>
				<script>
					var nextPageDelayValue = <xsl:value-of select="/COURT/CDU/REFRESH" />
					var nextPageDelay = nextPageDelayValue/10;
				</script>
                <script type="text/javascript" src="display_documentNEW.js"></script>
                <!-- Attaching Stylesheets -->
                <link rel="stylesheet" type="text/css">
                <xsl:attribute name="href">
                    <xsl:text>css/new/general.css</xsl:text>
                </xsl:attribute>
                </link>
                <link rel="stylesheet" type="text/css">
                <xsl:attribute name="href">
                    <xsl:text>css/new/table.css</xsl:text>
                </xsl:attribute>
				</link>
            </head>
            <body>
			<!-- If visible, blacks out screen and shows power saving message -->
			<div id="brightnessWindow">
				<div id="powerSavingMessage">
					<xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                        <span>- Power Saving Mode Enabled -</span>
                    </xsl:if>
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                        <span>- Power Arbed Modd Galluogwyd -</span>
                    </xsl:if>
				</div>
			</div>
			<xsl:if test="COURT/CDU/POWER-SAVING = 'ENABLED'">
				<script>
					document.getElementById("brightnessWindow").style.visibility = "visible";
				</script>
			</xsl:if>
                <form name="displayform">
                    <input type="hidden" name="listTitleText" value="List"/>
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                        <input type="hidden" name="ofTitleText" value="of" />
                    </xsl:if>
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                        <input type="hidden" name="ofTitleText" value="o" />
                    </xsl:if>
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                        <input type="hidden" name="pageTitleText" value="Page" />
                    </xsl:if>
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                        <input type="hidden" name="pageTitleText" value="Dudalen" />
                    </xsl:if>
                    <input type="hidden" name="macAddress" value="Page">
                    <xsl:attribute name="value">
                        <xsl:value-of select="/COURT/CDU/MAC-ADDR"/>
                    </xsl:attribute>
                    </input>
                    <input type="hidden" name="currentPageIndex">
                    <xsl:attribute name="value">
                        <xsl:value-of select="/COURT/PAGE/CURRENT-PAGE-INDEX"/>
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
                <!-- Div Containing Time Display Within Notification Bar -->
                <div class="timeDisplay">
                    <span class="timeText"  id="time"></span>
                </div>
                <!-- Div Containing Page Number Within Notifivation Bar -->
                <div class="pageNumberDisplay"><span id="pageInfo" class="pageNumberText">1 of 1</span></div>
                <!-- Contains Data for Page x of y display -->
                <form name="displayform">
                    <input type="hidden" name="listTitleText" value="List" />
                    <input type="hidden" name="ofTitleText" value="of" />
                    <input type="hidden" name="pageTitleText" value="Page" />
                </form>
                <!-- Layout Determination for Page -->
                <div id="heading" class="headerContainer">
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                        <span class="headerLogo"><img src="images/MoJLogo.png" alt="MoJ Logo" style="width: 100%;"></img></span>
                    </xsl:if>
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                        <span class="headerLogo"><img src="images/MoJLogoWelsh.png" alt="MoJ Logo" style="width: 100%;"></img></span>
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
                <div id="pageTitle" class="title">
				<span>
                    <xsl:value-of select="/COURT/CDU/TITLE"/>
                    (
                    <xsl:value-of select="/COURT/CDU/LOCATION"/>
                        <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                            ) List
                        </xsl:if>
                        <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                            ) Rhestr Llys
                        </xsl:if>
					</span>
					<div class="lastUpdated bigtext-exempt"><span id="lastUpdated">
                        <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                            Last Updated: 
                        </xsl:if>
                        <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                            Diweddarwyd Ddiwethaf:
                        </xsl:if>

                    <xsl:value-of select="/COURT/PAGE/LAST-UPDATED" /></span> | 
                        
                        <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                            Version: 
                        </xsl:if>
                        <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                            Fersiwn:
                        </xsl:if>

                    <xsl:value-of select="/COURT/CLIENT/VERSION" /> / <xsl:value-of select="/COURT/CDU/VERSION" />
                </div>
                </div>
                <div id="bodyArea" class="body-area">
                    <table id="resultTable" class="results" border="0" cellpadding="3" cellspacing="0">
                        <thead id="tableHeader">
                           <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                            <tr class="column-headers">
                                <td width="15%">Case No.</td>
                                <td width="45%">Name</td>
                                <td width="15%">Type</td>
                                <td width="10%">Not Before</td>
                                <td width="15%">Status</td>
                            </tr>
                            </xsl:if>
                            <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                            <tr class="column-headers">
                                <td width="15%">Achos numer</td>
                                <td width="45%">Enw</td>
                                <td width="15%">Math</td>
                                <td width="10%">Ddim Cyn</td>
                                <td width="15%">Statws</td>
                            </tr>
                            </xsl:if>
                        </thead>
                        <tbody id="resultsBody">
                            <xsl:for-each select="/COURT/TABLE/COURTCASE">
                                <xsl:variable name="myRowClass" >
                                    <xsl:choose>
                                        <xsl:when test="position() mod 2 = 0">
                                            <xsl:text>oddRow</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>evenRow</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <tr class="{$myRowClass}">
                                    <td class="case-number">
                                        <xsl:value-of select="CASENO"/>
                                    </td>
                                    <td>
                                        <xsl:for-each select="DEFENDANTS/DEFENDANT">
                                            <div align= 'left' style="word-wrap:break-word;overflow:auto">
                                                <xsl:value-of select="."/>
                                            </div>
                                        </xsl:for-each>
                                    </td>
                                    <td class="hearing-description">
                                        <xsl:value-of select="HEARINGDESCRIPTION"/>
                                    </td>
                                    <td class="not-before-time">
                                        <xsl:value-of select="NOTBEFORE"/>
                                    </td>
                                    <td class="hearing-progress">
                                        <xsl:value-of select="HEARINGPROGRESS"/>
										<xsl:if test="MOVEDROOM">
											<div class="moved-highlight"><xsl:value-of select="MOVEDROOM"/></div>
										</xsl:if>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
                <!-- This div stores cached data for the page. -->
                <div style="visibility: hidden" id="hiddenContainer"></div>
				
				<script type="text/javascript" src="jquery.min.js"></script>
				<script type="text/javascript" src="bigtext.js"></script>
				
				<script>
					$('#pageTitle').bigtext({
						maxfontsize: 50 // default is 528 (in px)
					});
				</script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>