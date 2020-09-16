<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="specs/fedramp-xslt-validate.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:f="https://fedramp.gov/ns/oscal" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
  exclude-result-prefixes="#all">

  <f:transformation validation="strict current">
    <f:title>FedRAMP System Security Plan 'template' page display (HTML5) transformation</f:title>
    <f:short-title>FedRAMP SSP HTML XSLT ('template' view)</f:short-title>
    <f:description>From OSCAL SSP provided with its baselines, produces a self-contained page
      display with look/feel emulating the published FedRAMP SSP template.</f:description>
    <f:date-of-origin>2020-08-05</f:date-of-origin>
    <f:date-last-modified>2020-09-16</f:date-last-modified>

    <f:parameter name="html-page-title" as="xs:string">String for HTML page title (browser header
      bar)</f:parameter>
    <f:parameter name="css-link" as="xs:string?">Literal value for link to out of line CSS
      (superseding inline CSS)</f:parameter>
    <f:parameter name="trace" as="xs:string" default="'no'">Emit trace messages to STDOUT at runtime
      ('yes','true' or 'on')</f:parameter>
    <f:parameter name="paginate" as="xs:string" default="'no'">Paginate using paged.js library for
      PDF production ('yes','true' or 'on')</f:parameter>
    <f:parameter name="set-date-format" as="xs:string" default="'Month D, YYYY'">Default date
      format: set this to 'YYYY-MM-DD' for '2020-04-01';'D-Mon-YYYY' for '1-Apr-2020','Month D,
      YYYY' for 'April 1, 2020';'D Month YYYY' for '1 April 2020'; or an XPath date-format picture
      string (see the <a
        href="https://www.w3.org/TR/xpath-functions-31/#rules-for-datetime-formatting">XPath 3.1
        rules at
      https://www.w3.org/TR/xpath-functions-31/#rules-for-datetime-formatting</a>)</f:parameter>

    <f:dependency href="fedramp_values.xml" role="value-lookups">Tables of values for dynamic
      inclusion and/or validation.</f:dependency>
    <f:dependency href="modules/oscal_general_html.xsl" role="import">Templates for OSCAL. Imports
      other modules to inherit handling for catalog contents, metadata and fallback
      logic.</f:dependency>
    <f:dependency href="ssp-oscal-schema.xsd" role="validate-source">When source provided is not a
      valid OSCAL SSP (Milestone 3), inputs will fall through unpredictably.</f:dependency>

    <f:result-format>HTML5 + CSS</f:result-format>
  </f:transformation>

  <xsl:output indent="yes" method="html" html-version="5"/>

  <xsl:param name="html-page-title" as="xs:string" select="''"/>

  <xsl:param name="css-link" as="xs:string?" static="yes"/>

  <xsl:param name="trace" as="xs:string">no</xsl:param>

  <xsl:param name="paginate" as="xs:string">no</xsl:param>

  <xsl:param name="set-date-format" as="xs:string">Month D, YYYY</xsl:param>
  <!--<xsl:param name="set-date-format" as="xs:string">[D]-[MNn,3-3]-[Y]</xsl:param>-->

  <xsl:variable name="paginating" select="$paginate = ('yes', 'true', 'on')"/>

  <xsl:variable name="fedramp-value-registry" select="document('fedramp_values.xml')"/>

  <!-- The included XSLT provides generic processing including catalog contents,
     with metadata and fallback logic. -->
  <xsl:include href="modules/oscal_general_html.xsl"/>

  <!-- Additionally, SSP boilerplate is imported. Note that boilerplate is then passed
     through 'boilerplate' mode (in the same XSLT) for expansion/adjustment. -->
  <xsl:import href="modules/fedramp-ssp-boilerplate.xsl"/>


  <xsl:key name="component-by-uuid" match="component" use="@uuid"/>
  <xsl:key name="location-by-uuid" match="location" use="@uuid"/>
  <xsl:key name="party-by-uuid" match="party" use="@uuid"/>

  <!-- Control which sections to include here. -->
  <xsl:variable name="main-contents" as="element()*">
    <main>
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
      <f:generate attachment="13">Integrated Inventory</f:generate>

    </main>
  </xsl:variable>

  <xsl:template name="css-inline" expand-text="true">
    <xsl:variable name="properties" expand-text="true" as="map(*)"
      select="
        map {
          'header.face': '&quot;Montserrat&quot;, Arial, Helvetica, sans-serif',
          'header.color': '#757575',
          'body.face': '&quot;Muli&quot;, Arial, Helvetica, sans-serif',
          'body.color': '#454545',
          'light.blue': '#ccecfc',
          'white': '#ffffff',
          'cyan': '#1294c2',
          'red': '#cc1d1d',
          'vivid.blue': '#1a4480',
          'deep.blue': '#162e51',
          'bg.color': '#f2f2f2',
          'att13.pale': '#daeef3',
          'att13.steel': '#b8cce4',
          'att13.aqua': '#92cddc',
          'att13.olive': '#c4d79b'
        }"/>
    <style type="text/css" xml:space="preserve">
         <xsl:text xml:space="preserve" disable-output-escaping="true">
@import url(http://fonts.googleapis.com/css?family=Montserrat:400,700);
@import url(http://fonts.googleapis.com/css?family=Muli:400,700);

html, body {{ background-color: {$properties?white};
              color: { $properties?body.color };
              font-family: {$properties?body.face} }}
         
details {{ padding: 0.5em }}
summary:focus {{ outline: none }} /* overriding a default */

h1, h2, h3, h4, h5, h6,
.h1, .h2, .h3, .h4, .h5, .h6
  {{ color: {$properties?header.color};
     font-family: {$properties?header.face} }}

h1, .h1 {{ text-transform: uppercase }}

section h1 {{ color: {$properties?red} }}

th, td {{ padding: 0.2em }}

table {{ border-collapse: collapse }}

table.uniform td,
table.uniform th {{ border: thin solid {$properties?body.color}; min-width: 15vw }}
table.poc td {{ min-width: 30vw }}

table.iinv th, table.iinv td {{ border: thin solid black }}

table.iinv th       {{ background-color: {$properties?att13.pale};  font-weight: bold }}
table.iinv th.all   {{ background-color: {$properties?att13.steel}; font-weight: normal }}
table.iinv th.os    {{ background-color: {$properties?att13.aqua};  font-weight: normal }}
table.iinv th.swdb  {{ background-color: {$properties?att13.olive}; font-weight: normal }}
table.iinv th.any   {{ background-color: {$properties?att13.steel}; font-weight: normal }}
table.iinv th.added {{ background-color: black; color: white; font-weight: normal }}

table.uniform caption {{ text-align: left; color: {$properties?red};
  font-style: italic; font-weight: normal; padding-bottom: 0.5em }}

.lbl {{ font-family: sans-serif; font-weight: bold; font-size: 80% }}
.lbl2 {{ font-family: sans-serif; font-size: 80% }}

.tag {{ font-family: monospace; font-weight: bold }}

div {{ padding: 0.2em; margin-top: 0.5em }}

th, td {{ vertical-align: text-top }}

table.uniform th,
table.poc     th {{ font-size: 85%;
      color: {$properties?white};
      background-color: {$properties?vivid.blue} }}

td.rh {{ font-weight: bold; font-size: 87%; background-color: {$properties?light.blue} }}

p:first-child {{ margin-top: 0em }}
p:last-child  {{ margin-bottom: 0em }}

td p {{ margin: 0.5em 0em 0em 0em }}
td p:first-child {{ margin-top: 0em }}

tr.guidance {{ display: none;
  font-size: 65%; font-weight: normal; text-align: left }}

tr.guided:hover + tr.guidance {{ display: table-row }}


table.iinv tr.line-item td {{ border-top: thick double black }}

tr.inventory.component {{ background-color: {$properties?light.blue} }}

tr.inventory.component.hiding {{ display: none }}

/* pops up component lines when their line-item lines are hovered
tr.inventory.component {{ display: none }}
tr.inventory.line-item:focus-within {{ display: table-row; background-color: {$properties?light.blue} }}
tr.inventory.line-item:focus-within ~ tr.inventory.component {{ display: table-row; background-color: {$properties?light.blue} }}
tr.inventory.line-item:focus-within ~ tr.inventory.line-item ~ tr.inventory.component {{ display: none }}
 */

tr.line-item td:hover p.component-notice {{ text-decoration: underline }}

<!-- tr.guided:hover + tr.guidance th {{ max-height: unset }} ; transition: height 2s ease-->

table.iinv tr.guidance th {{ font-weight: normal }}

div.guidance:before {{ font-weight: bold; content: "GUIDANCE: " }}

td.tbd,
table.iinv tr.component td.tbd {{ background-color: pink }}

.value-details {{ font-size: 80%; font-family: monospace }}
.value-details summary {{ font-family: {$properties?body.face}}}

td details[open] {{ position: absolute; z-index: 1; min-width: 20em; max-width: 40em;
  padding: 0.2em; background-color: lemonchiffon; border: thin solid gold }}

.instruction {{ border: thin solid {$properties?vivid.blue};
  background-color: {$properties?light.blue};
  color: {$properties?vivid.blue};
  font-size: 90%; margin-top: 1em }}

.val, .rem {{ font-family: monospace; text-decoration: underline; font-size: 120% }}
.val {{ font-weight: bold }}

span.choice {{ font-weight: 600; color: {$properties?header.color} }}

.ERROR {{ background-color: yellow; color: darkorange }}

.validation-error {{ color: red; font-style: italic; font-size: 80% }}

main > span, section > span {{ display: block }}
</xsl:text>
         <xsl:if test="$paginating" expand-text="true">
   
@media print{{
      
   h1, h2 {{
     string-set: sectionTitle content(text);
   }}
   
   
   @page {{
     margin: 1in 1in;
     @top-right {{
        content: ' { $html-page-title }' string(sectionTitle)
      }}
   }}

}}
</xsl:if>
      </style>
  </xsl:template>

</xsl:stylesheet>
