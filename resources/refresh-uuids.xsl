<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
    xmlns="http://csrc.nist.gov/ns/oscal/1.0"
    version="3.0">
    
<!-- 
        Run this stylesheet to replace 'uuid' with an actual uuid.
      Wherever there is an id or uuid, a fresh uuid is added. -->
    
    <!--to get assembly names from composed metaschema:
    //define-assembly/(root-name,use-name,@name)[1] => distinct-values() => string-join(' ')-->
    
    <xsl:strip-space elements="metadata responsible-party back-matter revision annotation location party rlink address biblio resource citation role set-parameter system-security-plan import-profile system-characteristics system-information information-type confidentiality-impact integrity-impact availability-impact security-impact-level status leveraged-authorization authorization-boundary diagram network-architecture data-flow system-implementation user authorized-privilege component responsible-role protocol system-inventory inventory-item implemented-component control-implementation implemented-requirement statement by-component"/>
    
    <xsl:preserve-space elements="*"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:mode name="add-new-uuids" on-no-match="shallow-copy"/>
    <xsl:mode name="rewire"        on-no-match="shallow-copy"/>
    
    <xsl:variable name="with-new-uuids">
        <xsl:apply-templates select="/" mode="add-new-uuids"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:comment expand-text="true"> Modified by conversion XSLT { current-dateTime() } - UUIDs refreshed </xsl:comment>
        
        <!--<xsl:apply-templates select="/" mode="add-new-uuids"/>-->
        <xsl:apply-templates mode="rewire" select="$with-new-uuids"/>
    </xsl:template>
    
    <!-- Fresh uuid -->
    <xsl:template match="@uuid" mode="add-new-uuids" xmlns:uuid="java:java.util.UUID">
        <xsl:copy-of select="."/>
        <xsl:attribute name="new-uuid" select="uuid:randomUUID()"/>
    </xsl:template>
    
    <xsl:template match="@uuid" mode="rewire"/>
        
    <xsl:template match="@new-uuid" mode="rewire">
        <xsl:attribute name="uuid" select="string(.)"/>
    </xsl:template>

    <xsl:template match="party-uuid | member-of-organization" mode="rewire">
        <xsl:copy>
            <xsl:sequence select="key('party-link',.)/@new-uuid/string(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[exists(key('html-uuid-link',@href))]" mode="rewire">
        <xsl:message expand-text="true">Matched { name(..) }/@href </xsl:message>
        <xsl:variable  name="t"    select="key('html-uuid-link',@href)"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @href"/>
            <xsl:attribute name="href" select="'#' || $t/@new-uuid"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="location-uuid" mode="rewire">
        <xsl:copy>
            <xsl:sequence select="key('location-link',.)/@new-uuid/string(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@component-uuid" mode="rewire">
        <xsl:attribute name="component-uuid">
            <xsl:sequence select="key('component-link',.)/@new-uuid/string(.)"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="risk-metric/@system" mode="rewire">
        <xsl:variable name="target" select="key('component-link',.)"/>
        <xsl:attribute name="system" select="$target/@new-uuid"/>
    </xsl:template>
    
    <xsl:template match="@uuid-ref" mode="rewire">
        <xsl:message>matched { name()} { @uuid }</xsl:message>
        <xsl:variable name="target" select="key('anything-by-uuid',.)"/>
        <xsl:attribute name="uuid-ref" select="$target/@new-uuid"/>
    </xsl:template>
    
    
    <xsl:key name="location-link"  match="location"         use="@uuid"/>
    <xsl:key name="party-link"     match="party"            use="@uuid"/>
    <xsl:key name="component-link" match="component"        use="@uuid"/>
    <xsl:key name="html-uuid-link" match="*[exists(@uuid)]" use="'#' || @uuid"/>
    <xsl:key name="anything-by-uuid" match="*[exists(@uuid)]"   use="@uuid"/>
    
</xsl:stylesheet>