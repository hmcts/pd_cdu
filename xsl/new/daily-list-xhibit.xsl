<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- Code used to process the removal of a word from within a string -->
	<xsl:template name="string-replace-all">
		<xsl:param name="source" />
		<xsl:param name="replace" />
		<xsl:param name="with" />
		<xsl:choose>
			<xsl:when test="contains($source, $replace)">
				<xsl:value-of select="substring-before($source,$replace)" />
				<xsl:value-of select="$with" />
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="source" select="substring-after($source,$replace)" />
					<xsl:with-param name="replace" select="$replace" />
					<xsl:with-param name="with" select="$with" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$source" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Main body of the page -->
    <xsl:template match="/">
        <html>
            <head>
                <!-- Attaching Javascript -->
                <xsl:if test="/COURT/PAGE/CURRENT-PAGE-INDEX">
                    <meta http-equiv="refresh">
                        <xsl:attribute name="content">
                            <xsl:value-of select="/COURT/CDU/REFRESH"/>
                            <xsl:text>, index.php?macAddr=</xsl:text>
                            <xsl:value-of select="/COURT/CDU/MAC-ADDR"/>
                            <xsl:text>&amp;currentPageIndex=</xsl:text>
                            <xsl:value-of select="/COURT/PAGE/CURRENT-PAGE-INDEX"/>
                        </xsl:attribute>
                    </meta>
                </xsl:if>
				
				<!-- Setting page rotation speed to value in XML -->
				<meta http-equiv="refresh" content="7200; index.php"></meta>
				<script>
					var nextPageDelay = <xsl:value-of select="/COURT/CDU/REFRESH" />
				</script>
				
                <!-- Attaching Javascript -->
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
					
				<!-- Div Containing Notification Bar -->				
				<div class="notificationBar" id="notificationBar">
					<marquee>
						<div id="notificationContents">
							<xsl:value-of select="/COURT/CDU/NOTICE" />
						</div>
					</marquee>
				</div>
                <div class="reportingRestrictions">
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                        * Reporting Restrictions Apply; Please see court manager for more details 
                    </xsl:if>
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                        * Cyfyngiadau adrodd yn berthnasol; Siaradwch âr rheolwr llys am fwy o fanylion
                    </xsl:if>
                </div>
				
                <!-- Div Containing Time Display Within Notification Bar -->
                <div class="timeDisplay">
                    <span class="timeText"  id="time"></span>
                </div>
				
                <!-- Div Containing Page Number Within Notifivation Bar -->
                <div class="pageNumberDisplay">
					<span id="pageInfo" class="pageNumberText">1 of 1</span>
				</div>
				
                <!-- Contains Data for Page x of y display -->
                <form name="displayform">
                    <input type="hidden" name="listTitleText" value="List" />
						<xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
							<input type="hidden" name="ofTitleText" value="of" />
						</xsl:if>
						<xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
							<input type="hidden" name="ofTitleText" value="o" />
						</xsl:if>                    <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
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
                </form>
                <!-- Layout Determination for Page -->
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
				
                <div id="pageTitle" class="title">
					<span>
						<xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
							Daily List (
						</xsl:if>
						<xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
							Rhestr Ddyddiol (
						</xsl:if>
						<xsl:value-of select="/COURT/CDU/LOCATION"/>
						)
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
                                <td class="noWrap">Court</td>
                                <td>Judge</td>
                                <td>Name/Case No.</td>
                                <td>Type</td>
                                <td>Not Before</td>
                            </tr>
                            </xsl:if>
                            <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                            <tr class="column-headers">
                                <td class="noWrap">Llys</td>
                                <td>Barnwr</td>
                                <td>Enw/Rhif yr achos</td>
                                <td>Math o wrandawiad</td>
                                <td>Ddim Cyn</td>
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
                                    <td class="noWrap">
                                        <div style="word-wrap:break-word;overflow:auto" class="court_room_name_restricted_size">
											<!-- <xsl:value-of select="ROOM" /> -->
											  <xsl:variable name="COURTROOM">
												<xsl:call-template name="string-replace-all">
												  <xsl:with-param name="source" select="ROOM" /> <!-- Original Content -->
												  <xsl:with-param name="replace" select="'Room'" /> <!-- Word/Phrase to Change -->
												  <xsl:with-param name="with" select="''" /> <!-- Replace with this -->
												</xsl:call-template>
											  </xsl:variable>
											  
											  <xsl:value-of select="$COURTROOM" /> <!-- Generated Content -->
											  <xsl:if test="MOVEDROOM">
												<div class="moved-highlight"><xsl:value-of select="MOVEDROOM"/></div>
											  </xsl:if>
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            <xsl:value-of select="NAME"/>
                                        </div>
                                    </td>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="CASETITLE">
                                                <span>
                                                    <xsl:value-of select="CASETITLE"/>
                                                </span>
                                                / 
                                                <span>
                                                    <xsl:value-of select="CASENO"/>
                                                </span>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <span>
                                                    <xsl:for-each select="DEFENDANTS/DEFENDANT">
                                                        <div style="word-wrap:break-word;overflow:auto">
                                                            <xsl:value-of select="."/>
                                                        </div>
                                                    </xsl:for-each>
                                                </span>
                                                / 
                                                <span>
                                                    <xsl:value-of select="CASENO"/>
                                                </span>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if test="REPORTRESTRICTIONS = 'TRUE'">
                                            <xsl:text>*</xsl:text>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:value-of select="TYPE"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="NOTBEFORE"/>
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