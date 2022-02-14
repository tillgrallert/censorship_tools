<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs xd"
    version="3.0">
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:event/tei:listBibl[not(node())]">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="parent::tei:event/@source[. != '']">
                    <xsl:apply-templates select="parent::tei:event/@source" mode="m_source-to-bibl"/>
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <!--<xsl:template match="tei:ref[@target]">
        <xsl:for-each select="tokenize(@target, ' ')">
            <xsl:element name="bibl">
                <xsl:attribute name="type" select="'SenteCitationID'"/>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>-->
    <xsl:template match="tei:bibl[@ana]">
        <xsl:for-each select="tokenize(@ana, ';')">
            <xsl:element name="bibl">
                <xsl:attribute name="type" select="'pandoc'"/>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="@source" mode="m_source-to-bibl">
        <xsl:for-each select="tokenize(., ';')">
            <xsl:element name="bibl">
                <xsl:attribute name="type" select="'pandoc'"/>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="node()[@type = 'SenteCitationID']">
        <xsl:variable name="v_citation-sente" select="normalize-space(.)"/>
        <xsl:variable name="v_citation-pandoc">
            <xsl:for-each select="tokenize($v_citation-sente, '; ')">
                <xsl:choose>
                    <xsl:when test="matches($v_citation-sente, '^(.+)@(.)')">
                        <xsl:value-of select="replace($v_citation-sente, '^(.+)@(.+)$', '@$1, $2')"/>
                    </xsl:when>
                    <xsl:when test="matches($v_citation-sente, '^[^@].+$')">
                        <xsl:value-of select="concat('@', $v_citation-sente)"/>
                    </xsl:when>
                    <xsl:when test="matches($v_citation-sente, '^@.+$')">
                        <xsl:value-of select="$v_citation-sente"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:element name="bibl">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="type" select="'pandoc'"/>
            <xsl:value-of select="$v_citation-pandoc"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>