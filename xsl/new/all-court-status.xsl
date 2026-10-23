<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- FUNCTION - REMOVE PHRASE FROM STRING-->
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

				<!-- REPORTING RESTRICTIONS -->		
                <div class="reportingRestrictions">
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                        * Reporting Restrictions Apply; Please see court manager for more details 
                    </xsl:if>
                    <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                        * Cyfyngiadau adrodd yn berthnasol; Siaradwch âr rheolwr llys am fwy o fanylion
                    </xsl:if>
                </div>
				
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
							All Court Status
						</xsl:if>
						<xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
							Statws Pob Llys
						</xsl:if>
						<xsl:text> </xsl:text>
						<xsl:text>(</xsl:text>
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
						<xsl:text>)</xsl:text>
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
                    <table id="resultTable" class="results" border="0" cellpadding="3" cellspacing="0">
                        <thead id="tableHeader">
                           <xsl:if test="COURT/PAGE/LANGUAGE = 'English'">
                            <tr class="column-headers">
                                <td class="noWrap" width="10%">Court</td>
                                <td width="30%">Name/Case No.</td>
                                <td width="60%">Status</td>
                            </tr>
                            </xsl:if>
                            <xsl:if test="COURT/PAGE/LANGUAGE = 'Welsh'">
                            <tr class="column-headers">
                                <td class="noWrap" width="10%">Llys</td>
                                <td width="30%">Enw / Rhif yr Achos</td>
                                <td width="60%">Statws</td>
                            </tr>
                            </xsl:if>
                        </thead>
                        <tbody id="resultsBody">
                            <xsl:for-each select="/COURT/TABLE/COURTCASE">
                                <xsl:variable name="myRowClass">
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
									
									<xsl:choose>
									  <xsl:when test="NOINFORMATION">
										<td>
											<span>No Information to Display</span>
										</td>
										<td>
										</td>
									  </xsl:when>
									  <xsl:otherwise>
										<td class="defendant-and-case-number">
									
										   <span class="defendant-names">
                                                    <xsl:for-each select="DEFENDANTS/DEFENDANT">
                                                        <div align= 'left' style="word-wrap:break-word;overflow:auto" class="defendant-name-restricted-size-250">
                                                            <xsl:value-of select="."/>
                                                        </div>
                                                    </xsl:for-each>
													/
                                                </span>
												
                                                <span class="case-number">
                                                    <xsl:value-of select="CASENO"/>
                                                </span>
                                        <xsl:if test="REPORTRESTRICTIONS = 'TRUE'">
                                            <xsl:text>*</xsl:text>
                                        </xsl:if>
                                    </td>
									<td class="live-status">
										<div class="liveStatusRestrictedWidth">
											<xsl:value-of select="STATUS"/>
										</div>
									</td>
									  </xsl:otherwise>
									</xsl:choose>
									
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>

				<script type="text/javascript" src="onscreen-clock.js"></script>

			</body>
        </html>
    </xsl:template>
</xsl:stylesheet>