<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="specs/fedramp-xslt-validate.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="https://fedramp.gov/ns/oscal"
                xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
                exclude-result-prefixes="#all">
   <xsl:template match="system-security-plan">
      <main>
         <xsl:apply-templates select="." mode="add-class"/>
         <xsl:apply-templates select="metadata/title"/>
         <xsl:apply-templates/>
      </main>
   </xsl:template>

   <xsl:template match="import-profile">
      <p>
         <xsl:apply-templates mode="add-class"       select="."/>
         <xsl:apply-templates mode="decorate-inline" select="."/>
         <xsl:apply-templates select="@href"/>
      </p>
   </xsl:template>

   <xsl:template match="import-profile/@href" expand-text="true">
      <a href="{.}" class="import">{ . }</a>
   </xsl:template>
   
   <xsl:template match="*" mode="decorate-inline">
      <xsl:param name="label">
         <xsl:apply-templates select="." mode="get-label"/>
      </xsl:param>
      <span class="lbl">
         <xsl:sequence select="$label"/>
      </span>
      <xsl:text> </xsl:text>
   </xsl:template>
   
   <xsl:template match="*" mode="get-label" expand-text="true">[label not defined for { name() }]</xsl:template>
   
   <xsl:template match="import-profile" mode="get-label">Profile import</xsl:template>
   
   <xsl:template match="system-characteristics | system-implementation | control-implementation">
      <section>
         <xsl:apply-templates select="." mode="add-class"/>
         <xsl:copy-of select="@id"/>
         <details>
            <summary>
               <xsl:apply-templates select="." mode="section-header"/>
            </summary>
            <xsl:apply-templates/>
         </details>
      </section>
   </xsl:template>

   <xsl:template match="system-id">
      <p>
         <xsl:apply-templates select="." mode="add-class"/>
         <xsl:apply-templates mode="decorate-inline" select="."/>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template mode="get-label" match="system-id">System ID</xsl:template>
   
   <xsl:template match="system-name">
      <p>
         <xsl:apply-templates select="." mode="add-class"/>
         <xsl:apply-templates mode="decorate-inline" select="."/>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template mode="get-label" match="system-name">System name</xsl:template>
   
   <xsl:template match="description[empty(*)]">
      <xsl:call-template name="warn-if-tracing">
         <xsl:with-param name="warning">Empty 'description' element...</xsl:with-param>
      </xsl:call-template>
   </xsl:template>  
   
   <xsl:template match="system-information">
      <div>
         <xsl:apply-templates select="." mode="add-class"/>
         <h4>System Information</h4>
         <xsl:apply-templates/>
      </div>
   </xsl:template>

   <xsl:template match="security-sensitivity-level">
      <p>
         <xsl:apply-templates select="." mode="add-class"/>
         <xsl:apply-templates mode="decorate-inline" select="."/>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template mode="get-label" match="security-sensitivity-level">Security sensitivity level</xsl:template>
   
   <!--<xsl:template match="system-information">
      <div class="system-information">
         <xsl:apply-templates/>
      </div>
   </xsl:template>-->
   
   <xsl:template match="information-type">
      <div>
         <xsl:apply-templates select="." mode="add-class"/>
         <p>
            <xsl:apply-templates mode="decorate-inline" select="."/>
            <xsl:text expand-text="true">: { @name }</xsl:text>
         </p>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template mode="get-label" match="information-type" expand-text="true">Information type</xsl:template>
   
   <xsl:template match="confidentiality-impact | integrity-impact | availability-impact">
      <div>
         <xsl:apply-templates select="." mode="add-class"/>
         <p class="impact-header">
            <xsl:apply-templates mode="decorate-inline" select="."/>
         </p>
         <xsl:apply-templates/>
      </div>
   </xsl:template>

   <xsl:template mode="get-label" match="confidentiality-impact">Impact level | Confidentiality</xsl:template>
   
   <xsl:template mode="get-label" match="integrity-impact">Impact level | Integrity</xsl:template>
   
   <xsl:template mode="get-label" match="availability-impact">Impact level | Integrity</xsl:template>
   
   <xsl:template match="security-impact-level">
      <div>
         <xsl:apply-templates select="." mode="add-class"/>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="security-objective-confidentiality | security-objective-integrity | security-objective-availability">
      <p>
         <xsl:apply-templates select="." mode="add-class"/>
         <xsl:apply-templates mode="decorate-inline" select="."/>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template mode="get-label" match="security-objective-confidentiality">Security objective | Confidentiality</xsl:template>
   
   <xsl:template mode="get-label" match="security-objective-integrity">Security objective | Confidentiality</xsl:template>
   
   <xsl:template mode="get-label" match="security-objective-availability">Security objective | Availability</xsl:template>
   
   <xsl:template match="authorization-boundary">
      <div>
         <xsl:apply-templates select="." mode="add-class"/>
         <h4>Authorization boundary</h4>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="status">
      <div>
         <xsl:apply-templates select="." mode="add-class"/>
         <p>
            <xsl:apply-templates select="." mode="decorate-inline"/>
            <xsl:for-each select="@state">
               <xsl:text>: </xsl:text>
               <xsl:value-of select="."/>
            </xsl:for-each>
         </p>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="component">
      <div>
         <xsl:apply-templates select="." mode="add-class"/>
         <details>
            <summary>
               <h4>Component: <xsl:value-of select="self::component/@name"/></h4>
            </summary>
            <xsl:apply-templates/>
         </details>
      </div>
   </xsl:template>
   
   <xsl:template match="system-inventory">
      <div>
         <xsl:apply-templates select="." mode="add-class"/>
         <details>
            <summary>
               <span class="h4">System inventory</span>
            </summary>
            <xsl:apply-templates/>
         </details>
      </div>
   </xsl:template>

   <xsl:template match="base | selected | date-authorized">
      <p>
         <xsl:apply-templates select="." mode="add-class"/>
         <xsl:apply-templates select="." mode="decorate-inline"/>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template mode="decorate-inline" match="base | selected" expand-text="true">
      <span class="lbl2">{ local-name() }</span>
   </xsl:template>

   
   <xsl:template mode="decorate-inline" match="date-authorized">
      <span class="lbl2">date authorized:</span>
   </xsl:template>
   
   <xsl:template match="user">
      <div class="block user">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="user/title">
      <p class="line user-title lbl">
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template match="responsible-role">
      <div class="responsibility">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template mode="section-header" match="system-characteristics">
      <span class="h2">System Characteristics</span>
   </xsl:template>
   
   <xsl:template mode="section-header" match="system-implementation">
      <span class="h2">System Implementation</span>
   </xsl:template>
   
   <xsl:template mode="section-header" match="control-implementation">
      <span class="h2">Control Implementation</span>
   </xsl:template>
</xsl:stylesheet>