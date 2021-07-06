<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- identity transformation -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:table">
        <tei:listBibl>
            <xsl:apply-templates select="tei:row"/>
        </tei:listBibl>
    </xsl:template>
    <xsl:template match="tei:row[@role = 'label']"/>
    <xsl:template match="tei:row[@role = 'data'][tei:cell[7] = 'Jaraid']" priority="10"/>
    <xsl:template match="tei:row[@role = 'data']">
        <tei:biblStruct type="periodical">
            <tei:monogr>
                <xsl:apply-templates select="tei:cell[4]"/>
                <xsl:apply-templates select="tei:cell[5]"/>
            </tei:monogr>
            <tei:note type="events">
                <tei:listEvent>
                    <xsl:apply-templates select="tei:cell[2]"/>
                </tei:listEvent>
            </tei:note>
        </tei:biblStruct>
    </xsl:template>
    
    <!-- events -->
    <xsl:template match="tei:cell[2]">
        <tei:event>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test=". = ('CS', 'CP', '1', 'Gap')">
                        <xsl:text>lifeCycle</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>censorship</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="subtype" select="."/>
            <!-- question whether suspension where enforced -->
            <xsl:if test="parent::tei:row/tei:cell[3] = 'yes'">
                <xsl:attribute name="cert" select="'high'"/>
            </xsl:if>
            <xsl:attribute name="source">
                <xsl:apply-templates select="parent::tei:row/descendant::tei:ref[@type = 'SenteCitationID']" mode="m_tss-to-zotero"/>
            </xsl:attribute>
            <!-- dating attributes -->
            <xsl:apply-templates select="preceding-sibling::tei:cell[1]/tei:date/@*"/>
            <tei:label>
                <xsl:value-of select="."/>
            </tei:label>
            <!-- description -->
            <tei:desc>
                <!-- dates -->
                <xsl:apply-templates select="parent::tei:row/tei:cell[1 or 9 or 10]/tei:date" mode="m_typing"/>
            </tei:desc>
            <!-- comments  -->
                <xsl:apply-templates select="parent::tei:row/tei:cell[6]"/>
            <!-- sources -->
            <tei:listBibl>
<!--                <xsl:apply-templates select="parent::tei:row/tei:cell[7]/tei:ref" mode="m_sources"/>-->
                <xsl:apply-templates select="parent::tei:row/tei:cell[7]" mode="m_sources"/>
                <xsl:apply-templates select="parent::tei:row/descendant::tei:ref[@type = 'noteAnchor']" mode="m_sources"/>
            </tei:listBibl>
        </tei:event>
    </xsl:template>
    <xsl:template match="tei:date" mode="m_typing">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="parent::tei:cell = ancestor::tei:row[1]/tei:cell[1]">
                        <xsl:text>documented</xsl:text>
                    </xsl:when>
                    <xsl:when test="parent::tei:cell = ancestor::tei:row[1]/tei:cell[9]">
                        <xsl:text>onset</xsl:text>
                    </xsl:when>
                    <xsl:when test="parent::tei:cell = ancestor::tei:row[1]/tei:cell[10]">
                        <xsl:text>terminus</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <!-- sources -->
    <xsl:template match="tei:cell[7]" mode="m_sources">
       <xsl:apply-templates select="tei:ref" mode="m_sources"/>
    </xsl:template>
    <xsl:template match="tei:ref[tei:bibl]" mode="m_sources">
        <xsl:apply-templates select="tei:bibl"/>
    </xsl:template>
    <xsl:template match="tei:ref[@type = 'noteAnchor']" mode="m_sources" priority="3">
        <xsl:if test="@target = ('#fnText2', '#fnText2')">
            <tei:bibl>
            <xsl:apply-templates/>
        </tei:bibl>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:ref[@target]" mode="m_sources" priority="2">
        <tei:bibl>
            <xsl:attribute name="ana">
                <xsl:apply-templates select="." mode="m_tss-to-zotero"/>
            </xsl:attribute>
            <xsl:apply-templates mode="m_sources"/>
        </tei:bibl>
    </xsl:template>
    <xsl:template match="tei:bibl" mode="m_sources">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:cell[6]">
        <tei:note type="comments"><xsl:apply-templates/></tei:note>
    </xsl:template>
    <xsl:template match="tei:ref" mode="m_tss-to-zotero">
        <xsl:analyze-string select="@target" regex="([^\s]+)(@([^\s]+))|([^\s]+)">
            <xsl:matching-substring>
                <xsl:choose><xsl:when test="matches(., '([^\s]+)(@([^\s]+))')">
                    <xsl:value-of select="concat('@', regex-group(1), ', ', regex-group(3))"/></xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('@', regex-group(4))"/>
                </xsl:otherwise></xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <!-- locations -->
    <xsl:template match="tei:cell[5]">
        <tei:imprint>
            <tei:pubPlace>
                <xsl:apply-templates/>
            </tei:pubPlace>
        </tei:imprint>
    </xsl:template>
    <!-- titles -->
    <xsl:template match="tei:cell[4]">
        <xsl:choose>
            <xsl:when test="tei:title">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <tei:title level="j">
                    <xsl:apply-templates/>
                </tei:title>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>