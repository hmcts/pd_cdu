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
                                    <td class="defendant-name">
                                        <xsl:value-of select="DEFENDANT"/>
                                    </td>
                                    <td class="court-room-name">
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
                                    </td>
                                    <td class="not-before-time">
                                        <xsl:value-of select="NOTBEFORE"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>