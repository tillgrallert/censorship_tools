<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
     xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xs xd html"
    version="3.0">
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- group biblStructs -->
    <xsl:template match="node()[tei:biblStruct]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="tei:biblStruct[not(tei:monogr/tei:title/@ref = 'NA')]" group-by="tei:monogr/tei:title[@ref]/@ref">
                <xsl:copy select="current-group()[1]">
                    <xsl:apply-templates select="current-group()/@*"/>
                    <xsl:apply-templates select="current-group()[1]/tei:monogr"/>
                    <xsl:element name="note">
                        <xsl:attribute name="type" select="'events'"/>
                        <xsl:element name="listEvent">
                            <xsl:copy-of select="current-group()/descendant::tei:event"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:copy>
            </xsl:for-each-group>
            <xsl:apply-templates select="tei:biblStruct[tei:monogr/tei:title/@ref = 'NA']"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>