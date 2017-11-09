<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:oap="https://openarabicpe.github.io/ns"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs xd"
    version="2.0">
    
    <!-- this stylesheet converts TEI XML tabular data to CSV -->
    <xsl:output method="text" encoding="UTF-8"/>
    
    <!-- the new line variable is provided by Tei2Md-parameters -->
    <xsl:param name="p_separator" select="','"/>
    <xsl:param name="p_separator-escape" select="';'"/>
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="descendant::tei:table" mode="m_tei-to-csv"/>
    </xsl:template>
    <xsl:template match="tei:table" mode="m_tei-to-csv">
        <xsl:result-document href="{substring-before( base-uri(),'.TEIP5.xml')}-{@xml:id}.csv">
        <xsl:apply-templates mode="m_tei-to-csv"/>
        </xsl:result-document>
    </xsl:template>
    <!-- supress output for all elements not specifically dealt with -->
    <xsl:template match="node()" mode="m_tei-to-csv"/>
    <!-- rows -->
    <xsl:template match="tei:row" mode="m_tei-to-csv">
        <xsl:apply-templates mode="m_tei-to-csv"/><xsl:value-of select="$v_new-line"/>
    </xsl:template>
    <!-- header row -->
    <xsl:template match="tei:row[@role='label']/tei:cell" mode="m_tei-to-csv">
        <xsl:value-of select="lower-case(.)"/><xsl:value-of select="$p_separator"/>
    </xsl:template>
    <!-- cells -->
    <xsl:template match="tei:cell" mode="m_tei-to-csv">
        <xsl:apply-templates mode="m_tei-to-csv"/><xsl:value-of select="$p_separator"/>
    </xsl:template>
    
    <!-- take care of mark-up in cells -->
    <xsl:template match="tei:title | tei:placeName" mode="m_tei-to-csv">
        <xsl:apply-templates mode="m_tei-to-csv"/>
    </xsl:template>
    
    <!-- generic text template -->
    <xsl:template match="text()" mode="m_tei-to-csv">
        <xsl:value-of select="replace(normalize-space(.),$p_separator,$p_separator-escape)"/>
    </xsl:template>
    <xsl:template match="tei:date" mode="m_tei-to-csv">
        <!-- needs support for other attributes than @when -->
        <xsl:choose>
            <xsl:when test="@notBefore">
                <xsl:value-of select="@notBefore"/>
            </xsl:when>
            <xsl:when test="@notAfter">
                <xsl:value-of select="@notAfter"/>
            </xsl:when>
            <xsl:when test="@when">
                <xsl:value-of select="@when"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:ref[@type='SenteCitationID']" mode="m_tei-to-csv">
        <xsl:value-of select="@target"/>
    </xsl:template>
    
    
</xsl:stylesheet>