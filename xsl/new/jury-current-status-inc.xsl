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
                                    <td class="court-room-name">
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
                                    <td class="defendant-and-case-number">
                                        <xsl:choose>
                                            <xsl:when test="CASETITLE">
                                                <span class="case-title">
                                                    <xsl:value-of select="CASETITLE"/> / 
                                                </span>
                                                
                                                <span class="case-number">
                                                    <xsl:value-of select="CASENO"/>
                                                </span>
                                            </xsl:when>
                                            <xsl:otherwise>
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
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if test="REPORTRESTRICTIONS = 'TRUE'">
                                            <xsl:text>*</xsl:text>
                                        </xsl:if>
                                    </td>
										<td class="judge">
										<span><xsl:value-of select="NAME"/></span>
                                        </td>
                                        <td class="hearing-progress">
										<span><xsl:value-of select="STATUS"/></span>
                                        </td>
                                    <td class="not-before-time">
                                        <xsl:value-of select="NOTBEFORE"/>
                                    </td>
                                    
                                </tr>
                            </xsl:for-each>

    </xsl:template>
</xsl:stylesheet>