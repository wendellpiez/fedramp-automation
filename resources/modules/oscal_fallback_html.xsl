<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
   exclude-result-prefixes="#all">
   
   <xsl:param    name="trace"   as="xs:string">no</xsl:param>
   <xsl:variable name="tracing" as="xs:boolean" select="$trace=('yes','true','on')"/>
   
   <xsl:template match="p | table | pre | ul | ol | li | h1 | h2 | h3 | h4 | h5 | h6 | code |      
                        a | img | strong | em | b | i | sup | sub">
      <xsl:apply-templates select="." mode="html-ns"/>
   </xsl:template>
   
   <xsl:template match="insert" mode="html-ns">
      <xsl:apply-templates select="." mode="#default"/>
   </xsl:template>
   
   <xsl:template match="*" mode="html-ns">
      <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>
   
   <!-- Matching anything without a better match in an importing XSLT  -->
   <xsl:template match="*">
      <xsl:if test="$tracing">
         <xsl:message expand-text="true">FALLING BACK TO HANDLE { name() }</xsl:message>
      </xsl:if>
      <p class="UNKNOWN {name()}">
         <span class="tag">
            <xsl:value-of select="name()"/>: </span>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template name="warn-if-tracing">
      <xsl:param name="warning"/>
      <xsl:if test="$tracing">
         <xsl:message expand-text="true">{ $warning }</xsl:message>
      </xsl:if>
      
   </xsl:template>
</xsl:stylesheet>