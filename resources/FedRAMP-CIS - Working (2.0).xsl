<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://www.w3.org/2005/xpath-functions"
    version="3.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
    exclude-result-prefixes="#all">
    <xsl:output indent="yes"
        method="html"
        omit-xml-declaration="yes" />

    <xsl:variable name="fedramp-values">fedramp_values.xml</xsl:variable>
    <xsl:variable name="baseline-level" select="/*/system-characteristics/security-sensitivity-level"/>
    <xsl:variable name="baseline-file" select="document($fedramp-values)/*/baselines/file[@id=$baseline-level]/@href"/>
    <xsl:variable name="csp-name" select="/*/metadata/party[@id='party-csp']/org/org-name" />
    <xsl:variable name="csp-short-name" select="/*/metadata/party[@id='party-csp']/org/short-name" />
    <xsl:variable name="sensitivty-level" select="document($fedramp-values)/*/security-sensitivity-level/row[@id=$baseline-level]/@label" />
    <xsl:variable name="system-name" select="/*/system-characteristics/system-name" />

    <xsl:template match="/">
        <html>
            <head>
                <xsl:if test="boolean($csp-short-name)">
                    <title><xsl:value-of select="$csp-short-name"/> FedRAMP CIS</title>
                </xsl:if>
                <xsl:if test="not(boolean($csp-short-name))">
                    <title><xsl:value-of select="$csp-name"/> FedRAMP CIS</title>
                </xsl:if>
                <link rel="stylesheet" type="text/css" media="all" href="default.css"/>
            </head>
            <body>
                <header>
                    <div style='width:100%; color: red;'><xsl:value-of select="$csp-name"/></div>
                    <div style='width:100%; font-size: 0.7em; color: red;'>
                            (<xsl:value-of select="/*/system-characteristics/system-id[@identifier-type='https://fedramp.gov']"/>) 
                        <xsl:value-of select="/*/system-characteristics/system-name"/>
                        [ <xsl:value-of select="$sensitivty-level"/> ]
                        <!--[ <xsl:apply-templates select="/*/system-characteristics/security-sensitivity-level" /> ]-->
                    </div>
                </header>
                <h2>FedRAMP <xsl:value-of select="$sensitivty-level"/> Control Implementation Summary (CIS)</h2>
                
                <xsl:call-template name="build-compliance-table"/>
                

<!--
                <xsl:call-template name="summary"/>
                <xsl:value-of select="document($baseline-file)//control[@id='ac-1']/prop[@name='label']" />
-->
                <br/><br/><br/><br/><br/><br/>
                <footer id='footer-area' class='site-footer' style=' position: fixed; left: 0; bottom: 0; width: 100%; background-color: black;'>
                    
                    <div style='text-align: center; align: center; margin: 0 auto; font-size: 20px;'>
                        <xsl:apply-templates select="/*/metadata/prop[@name='marking'][@ns='fedramp']" />
                    </div>
                </footer>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="metadata/title">
        <h2>
          <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="security-sensitivity-level">
        -<xsl:value-of select="document($fedramp-values)/*/security-sensitivity-level/row[@id=current()]/@label"/>-
    </xsl:template>

    <xsl:template name="build-compliance-table">

        <div>
            <xsl:text>MISSING: </xsl:text><xsl:value-of select="count(document($baseline-file)//control[not(@id = $controls/@control-id)])" />
            <xsl:text>&#160;&#160;</xsl:text>
            <xsl:text>PROVIDED: </xsl:text><xsl:value-of select="count(document($baseline-file)//control[@id = $controls/@control-id])" />
        </div>
        
        <div style="margin: 0 auto;">
            <table class="review" style="text-align:center;">
            <tr class="thead">
                <th class="thead" rowspan="2">Control ID</th>
                <th class="thead" colspan="{ count(document($fedramp-values)/*/implementation-status/row) }">Implementation Status</th>
                <th class="thead" colspan="{ count(document($fedramp-values)/*/control-origination/row) }">Control Origination</th>
            </tr>
            <tr>
                <xsl:for-each select="document($fedramp-values)/*/implementation-status/row/@label-short">
                    <th class="thead" style="font-size:0.7em">  <!--class="subhead"-->
                       <xsl:value-of select="."/>
                    </th>
                </xsl:for-each>
                <xsl:for-each select="document($fedramp-values)/*/control-origination/row/@label-short">
                    <th class="thead" style="font-size:0.7em">
                        <xsl:value-of select="."/>
                    </th>
                </xsl:for-each>
            </tr>
            
            <xsl:variable name="control-implementation" select="/*/control-implementation"/>
            <xsl:for-each select="document($baseline-file)//control/prop[@name='label']">
                <xsl:variable name="control-id" select="./../@id"/>
                <tr>
                    <td><xsl:value-of select="."/></td>
                    <xsl:for-each select="document($fedramp-values)/*/implementation-status/row">
                        <td>
                            <xsl:if test="./@id=$control-implementation/implemented-requirement[@control-id=$control-id]/prop[@name='implementation-status']" >
                                <xsl:if test="./@id='planned'" >
                                    <span>
                                        <xsl:attribute name="title">
                                            <xsl:value-of select="$control-implementation/implemented-requirement[@control-id=$control-id]/prop[@name='planned-completion-date']" />
                                            <xsl:text>
</xsl:text>
                                            <xsl:value-of select="$control-implementation/implemented-requirement[@control-id=$control-id]/annotation[@name='planned']/remarks" />
                                        </xsl:attribute>
                                        <xsl:text>X</xsl:text>
                                    </span>
                                </xsl:if>
                                <xsl:if test="not(./@id='planned')" >
                                    <xsl:text>X</xsl:text>
                                </xsl:if>
                            </xsl:if>
                        </td>
                    </xsl:for-each>
                    <xsl:for-each select="document($fedramp-values)/*/control-origination/row">
                        <td>
                            <xsl:if test="./@id=$control-implementation/implemented-requirement[@control-id=$control-id]/prop[@name='control-origination']" >
                                <xsl:text>X</xsl:text>
                            </xsl:if>
                        </td>
                    </xsl:for-each>
                </tr>
            </xsl:for-each>
            
            <!--<xsl:apply-templates select="document($baseline-file)//control/prop[@name='label'][not(@ns)]" mode="list-control"/>-->

        </table>
        </div>
    </xsl:template>
    
    <xsl:variable name="controls" select="/*/control-implementation/implemented-requirement"/>
    


</xsl:stylesheet>