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
      <f:date-last-modified>2020-08-11</f:date-last-modified>
      
      <f:parameter name="html-page-title" as="xs:string">String for HTML page title (browser header bar)</f:parameter>
      <f:parameter name="css-link"        as="xs:string?">Literal value for link to out of line CSS (superseded inline CSS)</f:parameter>
      <f:parameter name="trace"           as="xs:string" default="'no'">Emit trace messages to STDOUT at runtime ('yes','true' or 'on')</f:parameter>
      
      <f:dependency href="modules/oscal_general_html.xsl" role="import">Templates for OSCAL. Imports other modules to inherit handling for catalog contents, metadata and fallback logic.</f:dependency>
      <f:dependency href="ssp-oscal-schema.xsd" role="validate-source">When source provided is not a valid OSCAL SSP (Milestone 3), inputs will fall through unpredictably.</f:dependency>
      
      <f:result-format>HTML 5 + CSS</f:result-format>
   </f:transformation>
   
   <xsl:output indent="yes" method="html" html-version="5"/>
   
   <xsl:param name="html-page-title" as="xs:string" select="''"/>
   
   <xsl:param name="css-link"        as="xs:string?" static="yes"/>
   
   <xsl:param name="trace" as="xs:string">no</xsl:param>
   
<!-- The imported XSLT handles catalog contents, with metadata and fallback logic. -->
   <xsl:import href="modules/oscal_general_html.xsl"/>
   
   <xsl:key name="location-by-uuid" match="location" use="@uuid"/>
   <xsl:key name="party-by-uuid"    match="party"    use="@uuid"/>
   
   <xsl:template match="/" expand-text="true">
      <xsl:call-template name="warn-if-tracing">
         <xsl:with-param name="warning">[START] Trace is on.</xsl:with-param>
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
      <xsl:call-template name="warn-if-tracing">
         <xsl:with-param name="warning">[END] Root template concluded.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
<!-- Control which sections to include here. -->
   <xsl:variable as="element()*" name="section-specs">
      <f:generate section="1"/>
      <f:generate section="2"/>
      <f:generate section="3"/>
      <f:generate section="4"/>
      <f:generate section="5"/>
      <f:generate section="6"/>
      <f:generate section="7"/>
      <f:generate section="8"/>
      <f:generate section="9"/>
      <f:generate section="10"/>
      
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
   
   
   <xsl:template name="emit-value">
      <xsl:param name="this" as="node()?"/>
      <xsl:param name="echo"/>
      <xsl:apply-templates select="$this" mode="value"/>
      <xsl:if test="empty($this)" expand-text="true">
         <span class="ERROR">No value found for { $echo }</span>
         <xsl:call-template name="warn-if-tracing">
            <xsl:with-param name="warning">NO VALUE FOUND for { $echo }</xsl:with-param>
         </xsl:call-template>
      </xsl:if>
   </xsl:template>
   
   <xsl:variable name="fedramp-value-registry"
      select="document('fedramp_values.xml')"/>
   
   
   <!-- Mode 'value' produces spans marked 'val'
     containing the presentation value - generally element content, but
     sometimes mapped (as with eAuth values mapping to security impact levels) -->
   <xsl:template match="*" mode="value">
      <span class="val">
         <xsl:apply-templates/>
      </span>
   </xsl:template>
   
   <xsl:template mode="value" match="prop[@ns='https://fedramp.gov/ns/oscal'][@name='security-eauth-level']">
      <xsl:call-template name="lookup-value">
         <xsl:with-param name="who" select="."/>
         <xsl:with-param name="where" select="$fedramp-value-registry/*/eauth-levels"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="value" match="system-characteristics/security-sensitivity-level">
      <xsl:call-template name="lookup-value">
         <xsl:with-param name="who" select="."/>
         <xsl:with-param name="where" select="$fedramp-value-registry/*/security-sensitivity-level"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="value" match="confidentiality-impact/selected |
      integrity-impact/selected |
      availability-impact/selected |
      security-impact-level/*">
      <xsl:call-template name="lookup-value">
         <xsl:with-param name="who" select="."/>
         <xsl:with-param name="where" select="$fedramp-value-registry/*/security-impact-level"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="value" match="party" expand-text="true">
      <span class="val">      <xsl:apply-templates select="party-name"/>
      <xsl:for-each select="prop[@ns='https://fedramp.gov/ns/oscal'][@name='title']">, { . }</xsl:for-each>
      <xsl:for-each select="member-of-organization/key('party-by-uuid',.)/party-name">({ . })</xsl:for-each>
      </span>
   </xsl:template>
   
   <xsl:template match="party-name">
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template name="lookup-value" expand-text="true">
      <xsl:param name="who"   required="true"/>
      <xsl:param name="where" required="true"/>
      <span class="val">
         <xsl:value-of select="$where/value[@id=$who]/@label"/>
      </span>
      <xsl:if test="empty($where/value[@id=$who])">
         <xsl:variable name="path">
            <xsl:apply-templates select="$who" mode="path"/>
         </xsl:variable>
         <span class="ERROR">Lookup failed for value '{ $who }' on path { $path }</span>
      <xsl:call-template name="warn-if-tracing">
         <xsl:with-param name="warning">Lookup failed for value '{ $who }' on path '{ $path }'</xsl:with-param>         
      </xsl:call-template>
      </xsl:if>
   </xsl:template>
   
   <xsl:template match="*" mode="path">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text expand-text="true">/{ name() }</xsl:text>
         <xsl:variable name="kin" select="../*[name()=name(current())] except ."/>
         <xsl:if test="exists($kin)">
            <xsl:text expand-text="true">[{ count(. | (preceding-sibling::* intersect $kin)) }]</xsl:text>
            
         </xsl:if>
      </xsl:for-each>
   </xsl:template>
   
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
   
   <xsl:template name="css-link">
      <link rel="stylesheet" href="{$css-link}"/>
   </xsl:template>
   
   <xsl:template name="css-inline" expand-text="true">
      <xsl:variable name="properties" expand-text="true" as="map(*)" select="map {
         'header.face':  '&quot;Montserrat&quot;, Arial, Helvetica, sans-serif',
         'header.color': '#757575',
         'body.face':    '&quot;Muli&quot;, Arial, Helvetica, sans-serif',
         'body-color':   '#454545',
         'light.blue':   '#ccecfc',
         'white':        '#ffffff',
         'cyan':         '#1294c2',
         'red':          '#cc1d1d',
         'vivid.blue':   '#1a4480',
         'deep.blue':    '#162e51',
         'bg.color':     '#f2f2f2'
         }"/>
      <style type="text/css" xml:space="preserve">
@import url(http://fonts.googleapis.com/css?family=Montserrat:400,700);
@import url(http://fonts.googleapis.com/css?family=Muli:400,700);

html, body {{ background-color: {$properties?white};
              color: { $properties?body-color };
              font-family: {$properties?body.face} }}
         
details {{ padding: 0.5em }}

h1, h2, h3, h4, h5, h6,
.h1, .h2, .h3, .h4, .h5, .h6
  {{ color: {$properties?heading.color};
     font-family: {$properties?header.face} }}

h1, .h1 {{ text-transform: uppercase }}

section h1 {{ color: {$properties?red} }}

table.uniform {{ border-collapse: collapse }}

table.uniform td,
table.uniform th {{ border: thin solid {$properties?body.color};
  padding: 0.2em; min-width: 15vw }}
table.poc td {{ min-width: 30vw }}

table.uniform caption {{ text-align: left; color: {$properties?red};
  font-style: italic; font-weight: normal; padding-bottom: 0.5em }}

.lbl {{ font-family: sans-serif; font-weight: bold; font-size: 80% }}
.lbl2 {{ font-family: sans-serif; font-size: 80% }}

.tag {{ font-family: monospace; font-weight: bold }}

div {{ padding: 0.2em; margin-top: 0.5em }}

th, td {{ vertical-align: text-top }}

th {{ font-size: 85%;
      color: {$properties?white};
      background-color: {$properties?vivid.blue} }}

td.rh {{ font-weight: bold; font-size: 87%; background-color: {$properties?light.blue} }}

p:first-child {{ margin-top: 0em }}
p:last-child  {{ margin-bottom: 0em }}

td p {{ margin: 0.5em 0em 0em 0em }}
td p:first-child {{ margin-top: 0em }}
      
.instruction {{ border: thin solid {$properties?vivid.blue};
  background-color: {$properties?light.blue}; color: {$properties?vivid.blue}; font-size: 90%; margin-top: 1em }}

.val {{ font-weight: bold; font-family: monospace; text-decoration: underline }}

span.choice {{ font-weight: 600; color: {$properties?header.color} }}

.ERROR {{ background-color: yellow; color: darkorange }}

      </style>
   </xsl:template>
   
</xsl:stylesheet>
