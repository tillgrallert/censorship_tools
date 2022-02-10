<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs xd"
    version="3.0">
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:import href="../../../../BachBibliothek/GitHub/OpenArabicPE/authority-files/xslt/functions.xsl"/>
    
    <xsl:template match="/">
        <!-- head -->
        <xsl:value-of select="$v_beginning-of-line"/>
        <xsl:value-of select="$v_end-of-line"/>
        <xsl:apply-templates select="descendant::tei:standOff/descendant::tei:event" mode="m_event-to-csv"/>
    </xsl:template>
    
    <xsl:template match="tei:event" mode="m_event-to-csv">
        <!-- variables -->
        <xsl:variable name="v_title" select="ancestor::tei:biblStruct[1]/tei:monogr/tei:title[@level = 'j'][1]"/>
        <!-- output -->
        <xsl:value-of select="$v_beginning-of-line"/>
        <!-- type and subtype -->
        <xsl:value-of select="@type"/><xsl:value-of select="$v_seperator"/>
        <xsl:value-of select="@subtype"/><xsl:value-of select="$v_seperator"/>
        <!-- status of the action -->
        <xsl:value-of select="@cert"/><xsl:value-of select="$v_seperator"/>
        <!-- date of event -->
            <xsl:if test="not(tei:desc/tei:date)">
                <xsl:message>
                    <xsl:text>No date found</xsl:text>
                </xsl:message>
            </xsl:if>
        <xsl:apply-templates select="tei:desc/tei:date[@type='documented'][1]" mode="m_event-to-csv"/><xsl:value-of select="$v_seperator"/>
        <xsl:apply-templates select="tei:desc/tei:date[@type='onset'][1]" mode="m_event-to-csv"/><xsl:value-of select="$v_seperator"/>
        <xsl:apply-templates select="tei:desc/tei:date[@type='terminus'][1]" mode="m_event-to-csv"/><xsl:value-of select="$v_seperator"/>
        <!-- identify periodical -->
        <xsl:value-of select="oape:query-bibliography($v_title, $v_bibliography, '', $p_local-authority, 'id', '')"/><xsl:value-of select="$v_seperator"/>
        <xsl:value-of select="oape:query-bibliography($v_title, $v_bibliography, '', $p_local-authority, 'name', 'ar-Latn-x-ijmes')"/>
        <xsl:value-of select="$v_end-of-line"/>
    </xsl:template>
    
    <xsl:template match="tei:date" mode="m_event-to-csv">
        <xsl:choose>
            <xsl:when test="@notBefore">
                <xsl:value-of select="@notBefore"/>
            </xsl:when>
            <xsl:when test="@notAfter">
                <xsl:value-of select="@notAfter"/>
            </xsl:when>
            <xsl:when test="string-length(@when)=4">
                <xsl:value-of select="concat(@when,'-01-01')"/>
            </xsl:when>
            <xsl:when test="@when">
                <xsl:value-of select="@when"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>No machine-actionable date found</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>