<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="specs/fedramp-xslt-validate.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:f="https://fedramp.gov/ns/oscal" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
  exclude-result-prefixes="#all">

  <f:transformation validation="strict current">
    <f:title>FedRAMP PLAN OF ACTION AND MILESTONES (POA&amp;M) display (HTML5)
      transformation</f:title>
    <f:short-title>FedRAMP POA&amp;M HTML XSLT (basic page)</f:short-title>
    <f:description>From an OSCAL POA&amp;M provided with its SSP, produces a POA&amp;M
      table.</f:description>
    <f:date-of-origin>2020-08-24</f:date-of-origin>
    <f:date-last-modified>2020-08-26</f:date-last-modified>

    <f:parameter name="html-page-title" as="xs:string">String for HTML page title (browser header
      bar)</f:parameter>
    <f:parameter name="css-link" as="xs:string?">Literal value for link to out of line CSS
      (superseding inline CSS)</f:parameter>
    <f:parameter name="trace" as="xs:string" default="'no'">Emit trace messages to STDOUT at runtime
      ('yes','true' or 'on')</f:parameter>
    <f:parameter name="paginate" as="xs:string" default="'no'">Paginate using paged.js library for
      PDF production ('yes','true' or 'on')</f:parameter>

    <f:dependency href="modules/oscal_general_html.xsl" role="import">Templates for OSCAL. Imports
      other modules to inherit handling for catalog contents, metadata and fallback
      logic.</f:dependency>
    <f:dependency href="poam-oscal-schema.xsd" role="validate-source">When source provided is not a
      valid OSCAL POA&amp;M (Milestone 3), the table may not populate.</f:dependency>

    <f:result-format>HTML5 + CSS</f:result-format>
  </f:transformation>

  <xsl:output indent="yes" method="html" html-version="5"/>

  <xsl:param name="html-page-title" as="xs:string" select="''"/>

  <!-- 'both' for both tables; 'open' for the table of open items;
       'closed' for the table of closed items; 'single' for a single table
       for all items. -->
  
  <xsl:param name="tables" as="xs:string">both</xsl:param>
  
  <xsl:param name="css-link" as="xs:string?" static="yes"/>
  
  <xsl:param name="trace" as="xs:string">no</xsl:param>

  <xsl:param name="paginate" as="xs:string">no</xsl:param>

  <xsl:variable name="paginating" select="$paginate = ('yes', 'true', 'on')"/>

  <xsl:variable name="fedramp-value-registry" select="document('fedramp_values.xml')"/>

  <!-- The included XSLT provides generic processing including catalog contents,
     with metadata and fallback logic. -->
  <xsl:include href="modules/oscal_general_html.xsl"/>

  
  <xsl:mode name="boilerplate" on-no-match="shallow-copy"/>

  <xsl:variable name="poam" select="/" as="document-node()"/>
  
  <xsl:variable name="ssp"
    select="/*/import-ssp/key('linked-resource', @href)/rlink[@media-type = 'application/xml']
      ! document(@href, $poam)"/>

  <xsl:key name="linked-resource" match="resource" use="'#' || @uuid"/>
  <xsl:key name="component-by-uuid" match="component" use="@uuid"/>
  <xsl:key name="location-by-uuid" match="location" use="@uuid"/>
  <xsl:key name="party-by-uuid" match="party" use="@uuid"/>

  <!-- Control which sections to include here. -->
  <xsl:variable name="main-contents" as="element()*">
    <main>
      <h1>FedRAMP Plan of Action and Milestones (POA&amp;M)</h1>
      <xsl:call-template name="make-poam-head"/>
      <xsl:call-template name="include-tables"/>
    </main>
  </xsl:variable>
  
  <xsl:template name="make-poam-head">
    <table class="poam">
      <tr>
        <th>CSP</th>
        <th>System Name</th>
        <th>Impact Level</th>
        <th>POA&amp;M Date</th>
      </tr>
      <tr>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="()"/>
          <xsl:with-param name="echo">CSP</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="$ssp/*/system-characteristics/system-name-short"/>
          <xsl:with-param name="echo">System name</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="()"/>
          <xsl:with-param name="echo">Impact level</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="$poam/*/metadata/last-modified"/>
          <xsl:with-param name="echo">POA&amp;M date</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
      </tr>
    </table>
  </xsl:template>

  <xsl:template name="include-tables">
    <xsl:choose>
      <xsl:when test="$tables = 'single'">
        <xsl:call-template name="make-poam-table">
          <xsl:with-param name="head">All items</xsl:with-param>
          <xsl:with-param name="items" select="$poam/*/poam-items/poam-item"/>
          <xsl:with-param name="combined" select="true()" tunnel="true"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($tables='closed')">
          <xsl:call-template name="make-poam-table">
            <xsl:with-param name="head">Open items</xsl:with-param>
            <xsl:with-param name="items"
              select="$poam/*/poam-items/poam-item[not(risk/risk-status/normalize-space()='closed')]"
            />
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($tables = 'open')">
          <xsl:call-template name="make-poam-table">
            <xsl:with-param name="head">Closed items</xsl:with-param>
            <xsl:with-param name="items"
              select="$poam/*/poam-items/poam-item[risk/risk-status/normalize-space() = 'closed']"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="make-poam-table">
    <xsl:param name="items" as="element(poam-item)*"/>
    <xsl:param name="head"/>
    <xsl:param name="combined" select="false()" tunnel="true"/>
    <h2>
      <xsl:sequence select="$head"/>
    </h2>
    <table class="poam{ ' combined'[$combined] }">
      <xsl:call-template name="make-poam-table-head"/>
      <xsl:call-template name="make-poam-table-body">
        <xsl:with-param name="items" select="$items"/>
      </xsl:call-template>
    </table>
  </xsl:template>
  
  <xsl:template name="make-poam-table-head">
    <xsl:param name="combined" select="false()" tunnel="true"/>
    <thead>
      <tr class="guided">
        <th>POAM ID</th>
        <xsl:if test="$combined">
          <th>Status</th>
        </xsl:if>
        <th>Controls</th>
        <th>Weakness Name</th>
        <th>Weakness Description</th>
        <th>Weakness Detector Source</th>
        <th>Weakness Source Identifier</th>
        <th>Asset Identifier</th>
        <th>Point of Contact</th>
        <th>Resources Required</th>
        <th>Overall Remediation Plan</th>
        <th>Original Detection Date</th>
        <th>Scheduled Completion Date</th>
        <th>Planned Milestones</th>
        <th>Milestone Changes</th>
        <th>Status Date</th>
        <th>Vendor Dependency</th>
        <th>Last Vendor Check-in Date</th>
        <th>Vendor Dependent Product Name</th>
        <th>Original Risk Rating</th>
        <th>Adjusted Risk Rating</th>
        <th>Risk Adjustment</th>
        <th>False Positive</th>
        <th>Operational Requirement</th>
        <th>Deviation Rationale</th>
        <th>Supporting Documents</th>
        <th>Comments</th>
        <th>Auto-Approve</th>
      </tr>
      <tr class="guidance">
        <td>
          <p>Unique identifier for each POAM Item</p>
        </td>
        <xsl:if test="$combined">
          <td>Item status (open or closed)</td>
        </xsl:if>
        <td>
          <p>Applicable 800-53 Control(s)</p>
        </td>
        <td>
          <p>Name of the weakness as provided by the scanner or otherwise summarizing the
            weakness</p>
        </td>
        <td>
          <p>Description of the weakness and other information</p>
        </td>
        <td>
          <p>The scanner name or other source that detected the vulnerability</p>
        </td>
        <td>
          <p>Vulnerability identifier (Plugin ID) as provided by scanner</p>
          <p>(plugin ID/None)</p>
        </td>
        <td>
          <p>Identifier Specified in the Inventory</p>
          <p>This is a unique string associated with the asset, it could just be IP, or any
            arbitrary naming scheme</p>
          <p>This Field should include the complete identifier (no short hand), along with the port
            and protocol when provided by the scanner.</p>
          <p>Each Asset should be separated by a new line (Alt+Enter)</p>
        </td>
        <td>
          <p>Person Responsible for implementing this task</p>
        </td>
        <td>
          <p>Specify resources needed beyond current resources to mitigate task.</p>
        </td>
        <td>
          <p>General overview of the remediation plan</p>
        </td>
        <td>
          <p>Date the weakness was first identified</p>
          <p>(aka Discovery Date)</p>
        </td>
        <td>
          <p>Permanent Column</p>
          <p>Date of intended completion</p>
        </td>
        <td>
          <p>Permanent Column</p>
          <p>List of proposed Milestones, separated with a blank line (Alt+Enter)</p>
          <p>Any alterations should be made in "Milestone Changes" </p>
          <p>Milestone Number should be unique to each milestone</p>
        </td>
        <td>
          <p>Any alterations, status updates, or additions to the milestones.</p>
          <p></p>
          <p>(Milestone Number) [Type of update] [milestone date] : How and why the date changed,
            or the milestone was altered</p>
          <p>Create a new Milestone Number for new Milestones</p>
        </td>
        <td>
          <p>Date POA&amp;M item was last changed or closed</p>
        </td>
        <td>
          <p>Whether or not this item is vendor dependent.</p>
        </td>
        <td>
          <p>Date of last vendor check-in, if applicable</p>
        </td>
        <td>
          <p>Name of the product that is dependent upon the vendor.</p>
        </td>
        <td>
          <p>Provide the Original Risk Rating from the scanner</p>
        </td>
        <td>
          <p>Provide the Adjusted Risk Rating as approved by the CIO</p>
        </td>
        <td>
          <p>Whether there was a Risk Adjustment</p>
        </td>
        <td>
          <p>Whether this weakness should be considered a False Positive</p>
        </td>
        <td>
          <p>Whether this weakness should be considered an Operational Requirement</p>
        </td>
        <td>
          <p>Information about the Deviation</p>
        </td>
        <td>
          <p>List any supporting documents that are associated with this item</p>
          <p>(e.g. Deviation Request, Evidence of Remediation, Evidence of Vendor Dependency,
            etc)</p>
        </td>
        <td>
          <p>This column is for additional information, not specified in another column</p>
        </td>
        <td>
          <p>Whether the deviation request was auto-approved or manually approved</p>
        </td>

      </tr>
    </thead>
  </xsl:template>


  <xsl:template name="make-poam-table-body">
    <xsl:param name="items" as="element(poam-item)*"/>
    <tbody>
      <xsl:apply-templates select="$items" mode="poam-table-row"/>
    </tbody>
  </xsl:template>
  
  <xsl:template mode="poam-table-row" match="poam-item">
    <xsl:param name="combined" select="false()" tunnel="true"/>
    <tr class="poam-item { if (risk/risk-status/normalize-space() = 'closed') then 'closed' else 'open'}">
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these" select="prop[@name='POAM-ID'][@ns='https://fedramp.gov/ns/oscal']"/>
        <xsl:with-param name="echo">POAM item ID</xsl:with-param>
      </xsl:call-template><xsl:if test="$combined">
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="risk/risk-status"/>
          <xsl:with-param name="echo">item (risk) status</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <td>controls</td>
      <td>weakness name</td>
      <td>weakness description</td>
      <td>weakness detector source</td>
      <td>weakness source identifier</td>
      <td>asset identifier</td>
      <td>point of contact</td>
      <td>resources required</td>
      <td>overall remediation plan</td>
      <td>original detection date</td>
      <td>scheduled completion date</td>
      <td>planned milestones</td>
      <td>milestone changes</td>
      <td>status date</td>
      <td>vendor dependency</td>
      <td>last vendor check-in date</td>
      <td>vendor dependent product name</td>
      <td>original risk rating</td>
      <td>adjusted risk rating</td>
      <td>risk adjustment</td>
      <td>false positive</td>
      <td>operational requirement</td>
      <td>deviation rationale</td>
      <td>supporting documents</td>
      <td>comments</td>
      <td>auto-approve</td>
    </tr>
  </xsl:template>
  
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
    <style type="text/css">
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

table.uniform caption {{ text-align: left; color: {$properties?red};
  font-style: italic; font-weight: normal; padding-bottom: 0.5em }}


table.poam th,
table.poam td {{ border: thin solid black }}

table.poam.combined tr.closed td {{ background-color: {$properties?light.blue} }}

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

td.tbd {{ background-color: pink }}

.value-details {{ font-size: 80%; font-family: monospace }}
.value-details summary {{ font-family: {$properties?body.face}}}


tr.guidance {{ display: none;
  font-size: 65%; font-weight: normal; text-align: left }}

tr.guided:hover + tr.guidance {{ display: table-row }}

td details[open] {{ position: absolute; z-index: 1; min-width: 20em; max-width: 40em;
  padding: 0.2em; background-color: lemonchiffon; border: thin solid gold }}

.instruction {{ border: thin solid {$properties?vivid.blue};
  background-color: {$properties?light.blue};
  color: {$properties?vivid.blue};
  font-size: 90%; margin-top: 1em }}

.val, .rem {{ font-family: monospace; text-decoration: underline }}
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
