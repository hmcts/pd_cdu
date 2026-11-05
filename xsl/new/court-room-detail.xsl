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
                <!-- ENGLISH / WELSH PAGE X OF Y TRANSLATIONS -->
                <form name="displayform">
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
						<xsl:text> </xsl:text>
						<xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
							Detail
						</xsl:if>
						<xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
							Manylion Llys
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
											<td width="20%">Rhif achos</td>
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
											<td colspan="3" class="column-body">
												Judge: <xsl:value-of select="/COURT/ROOM/DETAIL/JUDGE"/>
											</td>
                                        </xsl:if>
                                        <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
											<td colspan="3" class="column-body">
												Barnwr: <xsl:value-of select="/COURT/ROOM/DETAIL/JUDGE"/>
											</td>
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
												<td class="column-header">
													Case progress as of <xsl:value-of select="/COURT/ROOM/DETAIL/PROGRESS/TIME"/>
												</td>
                                            </xsl:if>
                                            <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
												<td class="column-header">
													Cynnydd achos fel y <xsl:value-of select="/COURT/ROOM/DETAIL/PROGRESS/TIME"/>
												</td>
                                            </xsl:if>
                                        </tr>
                                        <tr>
                                            <td class="column-body">
												<xsl:value-of select="/COURT/ROOM/DETAIL/PROGRESS/MESSAGE"/>
											</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </xsl:if>
                        <div class="inter-table-padding">
                            <table id="resultTable" class="non-scrolling-results" >
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

            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>