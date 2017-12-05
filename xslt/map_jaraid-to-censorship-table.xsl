<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <xsl:template match="/">
        <tei:table>
            <!-- data on date of first publication and permits -->
<!--        <xsl:apply-templates select="descendant::tei:table/tei:row/tei:cell/tei:biblStruct"/>-->
            <!-- data on final publication dates -->
            <xsl:apply-templates select="descendant::tei:table/tei:row/tei:cell[@n='3']/tei:date" mode="m_row"/>  
        </tei:table>
    </xsl:template>
    
    <xsl:template match="tei:biblStruct">
        <tei:row role="data">
            <!-- date -->
            <tei:cell>
                <xsl:apply-templates select="tei:monogr/tei:imprint/tei:date[@type='start']"/>
            </tei:cell>
            <!-- action -->
            <tei:cell>P</tei:cell>
            <tei:cell/>
            <!-- title -->
            <tei:cell>
                <xsl:copy-of select="tei:monogr/tei:title[@level='j']"/>
            </tei:cell>
            <!-- location -->
            <tei:cell><xsl:copy-of select="tei:monogr/tei:imprint/tei:pubPlace[1]/tei:placeName"/></tei:cell>
            <!-- source -->
            <tei:cell/>
            <tei:cell>
                <xsl:text>Jaraid</xsl:text>
            </tei:cell>
            <tei:cell/>
            <tei:cell/>
        </tei:row>
    </xsl:template>
    
    <xsl:template match="tei:date" mode="m_row">
        <xsl:variable name="v_biblstruct" select="ancestor::tei:row/tei:cell/tei:biblStruct"/>
        <tei:row role="data">
            <!-- date -->
            <tei:cell>
                <xsl:apply-templates select="."/>
            </tei:cell>
            <!-- action -->
            <tei:cell>CP</tei:cell>
            <tei:cell/>
            <!-- title -->
            <tei:cell>
                <xsl:copy-of select="$v_biblstruct/tei:monogr/tei:title[@level='j']"/>
            </tei:cell>
            <!-- location -->
            <tei:cell><xsl:copy-of select="$v_biblstruct/tei:monogr/tei:imprint/tei:pubPlace[1]/tei:placeName"/></tei:cell>
            <!-- source -->
            <tei:cell/>
            <tei:cell>
                <xsl:text>Jaraid</xsl:text>
            </tei:cell>
            <tei:cell/>
            <tei:cell/>
        </tei:row>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="tei:date">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="@when">
                    <xsl:value-of select="@when"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>