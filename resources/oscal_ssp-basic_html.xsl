<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="specs/fedramp-xslt-validate.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="https://fedramp.gov/ns/oscal"
                xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
                exclude-result-prefixes="#all">

   <f:transformation validation="strict current">
      <f:title             >FedRAMP System Security Plan page display (HTML5) transformation</f:title>
      <f:short-title       >FedRAMP SSP HTML XSLT (basic page)</f:short-title>
      <f:description       >From OSCAL SSP provided with its baselines, produces a self-contained page display.</f:description>
      <f:date-of-origin    >2020-08-05</f:date-of-origin>
      <f:date-last-modified>2020-08-07</f:date-last-modified>
      
      <f:parameter name="html-page-title" as="xs:string">String for HTML page title (browser header bar)</f:parameter>
      <f:parameter name="css-link"        as="xs:string?">Literal value for link to out of line CSS (superseded inline CSS)</f:parameter>
      <f:parameter name="trace"           as="xs:string" default="'no'">Emit trace messages to STDOUT at runtime ('yes','true' or 'on')</f:parameter>
      
      <f:dependency href="modules/oscal_general_html.xsl" role="import">Templates for OSCAL. Imports other modules to inherit handling for catalog contents, metadata and fallback logic.</f:dependency>
      <f:dependency href="css/oscal-ssp_html.css" role="inject">If $css-link is not provided, this CSS is injected as literal CSS in the HTML for a standalone result file.</f:dependency>
      <f:dependency href="ssp-oscal-schema.xsd" role="validate-source">When source provided is not a valid OSCAL SSP (Milestone 3), inputs will fall through unpredictably.</f:dependency>
      
      <f:result-format>HTML 5 + CSS</f:result-format>
   </f:transformation>
   
   <xsl:output indent="yes" method="html" html-version="5"/>
   
   <xsl:param name="html-page-title" as="xs:string" select="''"/>
   
   <xsl:param name="css-link"        as="xs:string?" static="yes"/>
   
   <xsl:param name="trace" as="xs:string">no</xsl:param>
   
<!-- The imported XSLT handles catalog contents, with metadata and fallback logic. -->
   <xsl:import href="modules/oscal_general_html.xsl"/>
   
   <xsl:template match="/" expand-text="true">
      <xsl:call-template name="warn-if-tracing">
         <xsl:with-param name="warning">Trace is on.</xsl:with-param>
      </xsl:call-template>
      <html>
         <head>
            <meta itemprop="nominal_source_uri"   content="{ document-uri(.) }"/>
            <meta itemprop="production_xslt"      content="{ document-uri(document('')) }"/>
            <meta itemprop="production_timestamp" content="{ current-dateTime() }"/>
            <!-- Use the page title given if available, or the first element title -->
            <title>{ if (matches($html-page-title,'\S')) then $html-page-title else /descendant::title[1]/normalize-space(.) }</title>
            
            <xsl:call-template name="css-link"   use-when="matches($css-link,'\w')"/>
            <xsl:call-template name="css-inline" use-when="not(matches($css-link,'\w'))"/>
         </head>
         <body>
<!-- We produce the contents by processing a set of proxy elements through a filter. Each proxy
            indicates a handle for expansion using logic bound to the proxy by template
            match. -->
            <xsl:apply-templates select="$section-specs" mode="boilerplate"/>
         </body>
      </html>
   </xsl:template>
   
<!-- Control which sections to include here. -->
   <xsl:variable as="element()*" name="section-specs">
      <f:generate section="1"/>
      <f:generate section="2"/>
      <f:generate section="3"/>
   </xsl:variable>
   
   <xsl:template mode="boilerplate" match="f:generate" expand-text="true">
      <!-- Any actual boilerplate is delivered by a matching template
           in the imported XSLT. If no boilerplate is written, an error-marking
           div is given, and a trace message emitted. -->
      <xsl:variable name="copy">
         <xsl:apply-imports/>
      </xsl:variable>
      <!-- But pasting in the boilerplate is not enough: we
           must process it to expand out any further generation. -->
      <xsl:apply-templates select="$copy" mode="boilerplate"/>
   </xsl:template>
   
   <!-- Actual boilerplate is imported. Note that boilerplate is then passed
     through 'boilerplate' mode (in the same XSLT) for expansion/adjustment. -->
   <xsl:import href="modules/fedramp-ssp-boilerplate.xsl"/>
   
   <!--
   
   responsible-party/@role-id
   responsible-role/@role-id
   inventory-item/@asset-id
   implemented-component/@component-id
   by-component/@component-id
   implemented-requirement/@control-id
   statement/@statement-id
   set-param/@param-id
   
   -->
   
   <!--role-id asset-id component-id control-id statement-id param-id-->
   
   <xsl:template mode="css-value" match="*" as="xs:string*">
      <xsl:sequence select="@name!string(.), tokenize(@class,' '), local-name()"/>
   </xsl:template>
   
   <xsl:template mode="add-class" match="*">
      <xsl:attribute name="class">
         <xsl:value-of separator=" ">
            <xsl:apply-templates select="." mode="css-value"/>
         </xsl:value-of>
      </xsl:attribute>
   </xsl:template>

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

   <xsl:template name="css-link">
      <link rel="stylesheet" href="{$css-link}"/>
   </xsl:template>
   
   <xsl:template name="css-inline" expand-text="true">
      <xsl:variable name="properties" as="map(*)">
         <xsl:map>
            <xsl:map-entry key="'header.face'">'Montserrat', Arial, Helvetica, sans-serif</xsl:map-entry>
            <xsl:map-entry key="'body.face'">'Muli', Arial, Helvetica, sans-serif</xsl:map-entry>
            <xsl:map-entry key="'light.blue'">#ccecfc</xsl:map-entry>
            <xsl:map-entry key="'white'">#ffffff</xsl:map-entry>
            <xsl:map-entry key="'cyan'">#1294c2</xsl:map-entry>
            <xsl:map-entry key="'red'">#cc1d1d</xsl:map-entry>
            <xsl:map-entry key="'vivid.blue'">#1a4480</xsl:map-entry>
            <xsl:map-entry key="'deep.blue'">#162e51</xsl:map-entry>
            <xsl:map-entry key="'bg.color'">#f2f2f2</xsl:map-entry>
            <xsl:map-entry key="'heading.color'">#757575</xsl:map-entry>
            <xsl:map-entry key="'body-color'">#454545</xsl:map-entry>
         </xsl:map>
      </xsl:variable>
      
      <style type="text/css" xml:space="preserve">
@import url(http://fonts.googleapis.com/css?family=Montserrat:400,700);
@import url(http://fonts.googleapis.com/css?family=Muli:400,700);
         
details {{ padding: 1em }}

html, body {{ background-color: {$properties?white};
              color: { $properties?body-color };
              font-family: {$properties?body.face} }}

h1, h2, h3, h4, h5, h6,
.h1, .h2, .h3, .h4, .h5, .h6 {{ color: {$properties?heading.color};
              font-family: {$properties?header.face} }}
h1, .h1 {{ text-transform: uppercase }}

section h1 {{ color: {$properties?red} }}

h4.tablecaption {{ color: {$properties?red};
  font-style: italic; font-weight: normal }}

.lbl {{ font-family: sans-serif; font-weight: bold; font-size: 80% }}
.lbl2 {{ font-family: sans-serif; font-size: 80% }}

.tag {{ font-family: monospace; font-weight: bold }}

div {{ padding: 0.2em; margin-top: 0.5em }}

th {{ color: {$properties?white};
      background-color: {$properties?vivid.blue} }}
      
div.instruction {{ border: thin solid {$properties?vivid.blue};
  color: {$properties?vivid.blue} }}

p:first-child {{ margin-top: 0em }}
p:last-child  {{ margin-bottom: 0em }}

span.choice {{ font-weight: 600; color: {$properties?heading.color} }}
      </style>
   </xsl:template>
   
   <xsl:variable name="gt">
      <xsl:text disable-output-escaping="true">></xsl:text>
   </xsl:variable>
</xsl:stylesheet>
