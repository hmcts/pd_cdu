<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <!--<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"&gt;</xsl:text>-->
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
                    <span>- Power Saving Mode Enabled -</span>
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
                    <xsl:value-of select="COURT/CDU/TITLE"/>
                    (
                    <xsl:value-of select="/COURT/CDU/LOCATION"/>
                        <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                            ) Detail
                        </xsl:if>
                        <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                            ) Manylion Llys
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
                <div id="resultsBody" class="non-scrolling-results">
                    <div id="bodyArea" class="body-area">                        
                        <div class="inter-table-padding">
                            <table id="initialResultTable" class="non-scrolling-results">
                                <thead id="tableHeader">
                                   <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                                    <tr class="column-headers">
                                        <td width="20%">Case No.</td>
                                        <td width="50%">Name</td>
                                        <td width="30%">Hearing Type</td>
                                    </tr>
                                    </xsl:if>
                                    <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                                    <tr class="column-headers">
                                        <td width="20%">Numver achos</td>
                                        <td width="50%">Enw</td>
                                        <td width="30%">Math o wrandawiad</td>
                                    </tr>
                                    </xsl:if>
                                </thead>
                                <tbody>
                                    <tr class="oddRow">
                                        <td class="case-number">
                                            <xsl:value-of select="/COURT/ROOM/DETAIL/CASENO"/>
                                        </td>
                                        <td class="defendant-names">
                                            <div class="defendant-place-holder">
                                                <div class="defendant-scrolling-area" id="defendantScroller">
                                                    <div class="defendant-display-area" id="defendantDisplayArea">
                                                        <xsl:for-each select="/COURT/ROOM/DETAIL/DEFENDANTS/DEFENDANT">
                                                            <div class="defendant-name-restricted-size">
                                                                <xsl:value-of select="."/>
                                                            </div>
                                                        </xsl:for-each>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="hearing-description">
                                            <xsl:value-of select="/COURT/ROOM/DETAIL/TYPE"/>
                                        </td>
                                    </tr>
                                    <tr>
                                       <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                                        <td colspan="3" class="column-body">Judge: <xsl:value-of select="/COURT/ROOM/DETAIL/JUDGE"/></td>
                                        </xsl:if>
                                        <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                                        <td colspan="3" class="column-body">Barnwr: <xsl:value-of select="/COURT/ROOM/DETAIL/JUDGE"/></td>
                                        </xsl:if>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <xsl:if test="/COURT/ROOM/DETAIL/PROGRESS">
                            <div class="inter-table-padding">
                                <table class="non-scrolling-results">
                                    <tbody>
                                        <tr>
                                           <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                                            <td class="column-header">Case progress as of <xsl:value-of select="/COURT/ROOM/DETAIL/PROGRESS/TIME"/></td>
                                            </xsl:if>
                                            <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                                            <td class="column-header">Cynnydd achos fel y <xsl:value-of select="/COURT/ROOM/DETAIL/PROGRESS/TIME"/></td>
                                            </xsl:if>
                                            </tr>
                                            <tr>
                                            <td class="column-body"><xsl:value-of select="/COURT/ROOM/DETAIL/PROGRESS/MESSAGE"/></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </xsl:if>
                        <div class="inter-table-padding">
                            <table id="resultTable" class="results">
                                <thead>
                                    <tr class="column-headers">
                                           <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                                            <td width="100%">Notices</td>
                                            </xsl:if>
                                            <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                                            <td width="100%">Hysbysiadau</td>
                                            </xsl:if>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="/COURT/ROOM/DETAIL/NOTICES/NOTICE">
                                        <tr>
                                            <td class="oddRow">
                                                <xsl:value-of select="."/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                        
                    </div>
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