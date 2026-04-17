<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
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
                                            <div align= 'left' style="word-wrap:break-word;overflow:auto" class="defendant-name-restricted-size-250">
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
    </xsl:template>
</xsl:stylesheet>