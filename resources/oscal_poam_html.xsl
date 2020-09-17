<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="specs/fedramp-xslt-validate.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:f="https://fedramp.gov/ns/oscal" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
  exclude-result-prefixes="#all">

  <f:transformation validation="strict current" xml:space="preserve">

    <f:title>FedRAMP PLAN OF ACTION AND MILESTONES (POA&amp;M) display (HTML5)
      transformation</f:title>
    <f:short-title>FedRAMP POA&amp;M HTML XSLT (basic page)</f:short-title>
    <f:description>From an OSCAL POA&amp;M provided with its SSP, produces a POA&amp;M table.</f:description>
    <f:date-of-origin>2020-08-24</f:date-of-origin>
    <f:date-last-modified>2020-09-17</f:date-last-modified>

    <f:parameter name="html-page-title" as="xs:string">String for HTML page title (browser header bar)</f:parameter>
    <f:parameter name="css-link" as="xs:string?">Literal value for link to out of line CSS (superseding inline CSS)</f:parameter>
    <f:parameter name="trace" as="xs:string" default="'no'">Emit trace messages to STDOUT at runtime ('yes','true' or 'on')</f:parameter>
    <f:parameter name="paginate" as="xs:string" default="'no'">Paginate using paged.js library for PDF production ('yes','true' or 'on')</f:parameter>
    <f:parameter name="set-date-format" as="xs:string" default="'no'">Default date format: set this to 'YYYY-MM-DD' for '2020-04-01';'D-Mon-YYYY' for '1-Apr-2020','Month D, YYYY' for 'April 1, 2020';'D Month YYYY' for '1 April 2020'; or an XPath date-format picture string (see the <a href="https://www.w3.org/TR/xpath-functions-31/#rules-for-datetime-formatting"> XPath 3.1 rules at https://www.w3.org/TR/xpath-functions-31/#rules-for-datetime-formatting</a>)</f:parameter>
    
    <f:dependency href="modules/oscal_general_html.xsl" role="import">Templates for OSCAL. Imports other modules to inherit handling for catalog contents, metadata and fallback logic.</f:dependency>
    <f:dependency href="poam-oscal-schema.xsd" role="validate-source">When source provided is not a valid OSCAL POA&amp;M (Milestone 3), the table may not populate.</f:dependency>

    <f:result-format>HTML5 + CSS</f:result-format>
  </f:transformation>

  <xsl:output indent="yes" method="html" html-version="5"/>

  <xsl:param name="html-page-title" as="xs:string" select="''"/>

  <!-- 'both' for both tables; 'open' for the table of open items;
       'closed' for the table of closed items; 'combined' for a single table
       for all items. -->
  
  <xsl:param name="tables" as="xs:string">both</xsl:param>
  
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

  
  <xsl:mode name="boilerplate" on-no-match="shallow-copy"/>

  
  <xsl:variable name="poam" select="/" as="document-node()"/>
  
  <xsl:variable name="ssp-path" select="resolve-uri(/*/import-ssp/key('linked-resource', @href)/rlink[@media-type = 'application/xml'],document-uri())"/>
  
<!-- Falls back to the POAM source if no SSP is retrieved -->
  <xsl:variable name="ssp"
    select="if (doc-available($ssp-path)) then doc($ssp-path) else $poam"/>

  <xsl:variable as="xs:string" name="uuid-regex">^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-4[0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$</xsl:variable>
  
  <xsl:key name="linked-resource"        match="resource"       use="'#' || @uuid"/>
  
  <xsl:key name="inventory-item-by-uuid" match="inventory-item" use="@uuid"/>
  <xsl:key name="component-by-uuid"      match="component"      use="@uuid"/>
  <xsl:key name="location-by-uuid"       match="location"       use="@uuid"/>
  <xsl:key name="party-by-uuid"          match="party"          use="@uuid"/>

  <!-- Control which sections to include here. -->
  <xsl:variable name="main-contents" as="element()*">
    <main>
      <h1>FedRAMP Plan of Action and Milestones (POA&amp;M)</h1>
        <xsl:call-template name="make-page-head"/>
        <xsl:call-template name="include-tables"/>
    </main>
  </xsl:variable>
  
  <xsl:template name="make-page-head">
    
    <!-- emulating original POA&M spreadsheet <table class="poam">
      <tr>
        <th>CSP</th>
        <th>System Name</th>
        <th>Impact Level</th>
        <th>POA&amp;M Date</th>
      </tr>
      <tr>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="$poam/*/metadata/responsible-party[@role-id='cloud-service-provider']/key('party-by-uuid',party-uuid)/party-name"/>
          <xsl:with-param name="echo" tunnel="true">CSP</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="emit-value-td">
          <!-\- XXX Acquired from back-matter resource via SSP import -\->
          <xsl:with-param name="these" select="
            ($ssp/*/system-characteristics/system-name-short,
            $poam/*/back-matter/resource[
              prop[@name='conformity'][@ns=$fedramp-ns]='no-oscal-ssp' ]/title)[1]"/>
          <xsl:with-param name="echo" tunnel="true">System name</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="(
            $ssp/*/system-characteristics/security-sensitivity-level,
            $poam/*/back-matter/resource[prop[@name='conformity'][@ns=$fedramp-ns]='no-oscal-ssp']
            
            /prop[@name='security-sensitivity-level'][@ns=$fedramp-ns])[1]"/>
          <xsl:with-param name="echo" tunnel="true">Impact level</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="$poam/*/metadata/last-modified"/>
          <xsl:with-param name="echo" tunnel="true">POA&amp;M date</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
      </tr>
    </table>-->
    
    <!-- emulating DR worksheet header (except for date field) -->
    <table class="poam" id="poam-head">
      <tr>
        <th class="centered">CSP Name</th>
        <th class="centered">System Name</th>
        <th class="centered">Impact Level</th>
        <th class="centered">POA&amp;M Date</th>
        <!-- <th>DR Submission Date</th>-->
      </tr>
      <tr>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="$poam/*/metadata/responsible-party[@role-id='cloud-service-provider']/key('party-by-uuid',party-uuid)/party-name"/>
          <xsl:with-param name="echo" tunnel="true">CSP</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="emit-value-td">
          <!-- XXX Acquired from back-matter resource via SSP import -->
          <xsl:with-param name="these" select="
            ($ssp/*/system-characteristics/system-name-short,
            $poam/*/back-matter/resource[
            prop[@name='conformity'][@ns=$fedramp-ns]='no-oscal-ssp' ]/title)[1]"/>
          <xsl:with-param name="echo" tunnel="true">System name</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="(
            $ssp/*/system-characteristics/security-sensitivity-level,
            $poam/*/back-matter/resource[prop[@name='conformity'][@ns=$fedramp-ns]='no-oscal-ssp']
            
            /prop[@name='security-sensitivity-level'][@ns=$fedramp-ns])[1]"/>
          <xsl:with-param name="echo" tunnel="true">Impact level</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="$poam/*/metadata/last-modified"/>
          <xsl:with-param name="echo" tunnel="true">POA&amp;M date</xsl:with-param>
          <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
        </xsl:call-template>
      </tr>
      <tr>
        <th colspan="4">CSP Primary POC</th>
      </tr>
      <tr>
        <th class="centered">Name</th>
        <th class="centered">Title</th>
        <th class="centered">Phone</th>
        <th class="centered">Email</th>
      </tr>
      <tr>
        <td class="tbd">POC name (need example)</td>
        <td class="tbd">POC title</td>
        <td class="tbd">POC phone</td>
        <td class="tbd">POC email</td>
      </tr>
    </table>
  </xsl:template>
  
  <xsl:function name="f:report-item-count" as="xs:string?">
    <xsl:param name="items" as="element(poam-item)*"/>
    <xsl:text expand-text="true">{ count($items) } { if (count($items) ne 1) then 'items' else 'item' }</xsl:text>
  </xsl:function>
  
  <xsl:template name="include-tables" expand-text="true">
    <xsl:choose>
      <xsl:when test="$tables = 'combined'">
        <xsl:variable name="all-items" select="$poam/*/poam-items/poam-item"/>
        <h2>All items ({ f:report-item-count($all-items) })</h2>
        <xsl:call-template name="make-poam-table">
          <xsl:with-param name="table-id">poam-all-items</xsl:with-param>
          <xsl:with-param name="items" select="$all-items"/>
          <xsl:with-param name="combined" select="true()" tunnel="true"/>
        </xsl:call-template>
        <xsl:call-template name="make-dr-table">
          <xsl:with-param name="table-id">dr-report-all-items</xsl:with-param>
          <xsl:with-param name="items" select="$all-items"/>
          <xsl:with-param name="combined" select="true()" tunnel="true"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($tables='closed')">
          <!-- An item is open if it has a risk with status not 'closed' -->
          <xsl:variable name="open-items" select="$poam/*/poam-items/poam-item[risk/risk-status/normalize-space()!='closed']"/>
          <h2>Open items ({ f:report-item-count($open-items) })</h2>
          <xsl:call-template name="make-poam-table">
            <xsl:with-param name="items" select="$open-items"/>
            <xsl:with-param name="table-id">poam-open-items</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="make-dr-table">
            <xsl:with-param name="items" select="$open-items"/>
            <xsl:with-param name="table-id">dr-report-open-items</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($tables = 'open')">
          <!-- An item is closed if it has no risk with status not marked 'closed' -->
          <xsl:variable name="closed-items" select="$poam/*/poam-items/poam-item[not(risk/risk-status/normalize-space() != 'closed')]"/>
          <h2>Closed items ({ f:report-item-count($closed-items) })</h2>
          <xsl:call-template name="make-poam-table">
            <xsl:with-param name="items" select="$closed-items"/>
            <xsl:with-param name="table-id">poam-closed-items</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="make-dr-table">
            <xsl:with-param name="items" select="$closed-items"/>
            <xsl:with-param name="table-id">dr-report-closed-items</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="make-poam-table">
    <xsl:param name="items" as="element(poam-item)*"/>
    <xsl:param name="table-id" required="true"/>
    <xsl:param name="combined" select="false()" tunnel="true"/>
    <xsl:if test="exists($items)">
      <table class="poam{ ' combined'[$combined] }" id="{$table-id}">
        <xsl:call-template name="make-poam-table-head"/>
        <xsl:call-template name="make-poam-table-body">
          <xsl:with-param name="items" select="$items"/>
        </xsl:call-template>
      </table>
    </xsl:if>
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
          <!--<p>Each Asset should be separated by a new line (Alt+Enter)</p>-->
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
          <!--<p>Permanent Column</p>-->
          <p>Date of intended completion</p>
        </td>
        <td>
          <!--<p>Permanent Column</p>-->
          <p>List of proposed Milestones<!--, separated with a blank line (Alt+Enter)--></p>
          <p>Any alterations should be made in "Milestone Changes" </p>
          <p>Milestone Number should be unique to each milestone</p>
        </td>
        <td>
          <p>Any alterations, status updates, or additions to the milestones.</p>
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
      <xsl:apply-templates select="$items/risk" mode="poam-table-row"/>
    </tbody>
  </xsl:template>

  <xsl:template mode="poam-table-row" match="poam-item/risk">
    <xsl:param name="combined" select="false()" tunnel="true"/>
    <xsl:variable name="parent-if-first" select=".[empty(preceding-sibling::risk)]/parent::*"/>
    <tr class="risk-item { if (risk-status/normalize-space() = 'closed') then 'closed' else 'open'}">
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these" select="$parent-if-first/prop[@name='POAM-ID'][@ns=$fedramp-ns]"/>
        <xsl:with-param name="echo" tunnel="true">POAM item ID</xsl:with-param>
      </xsl:call-template>
      <xsl:if test="$combined">
        <xsl:call-template name="emit-value-td">
          <xsl:with-param name="these" select="risk-status"/>
          <xsl:with-param name="echo" tunnel="true">item (risk) status</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these"
          select="$parent-if-first/prop[@ns=$fedramp-ns][@name='impacted=control-id']"/>
        <xsl:with-param name="echo" tunnel="true">controls</xsl:with-param>
        <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these"
          select="title"/>
        <xsl:with-param name="echo" tunnel="true">weakness name</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these"
          select="description"/>
        <xsl:with-param name="echo" tunnel="true">weakness description</xsl:with-param>
      </xsl:call-template>

      <xsl:variable name="detector" select="$parent-if-first/observation/origin/
        (key('component-by-uuid',@uuid-ref) | key('component-by-uuid',@uuid-ref,$ssp))"/>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these"
          select="$detector/title"/>
        <xsl:with-param name="echo" tunnel="true">weakness detector source</xsl:with-param>
        <xsl:with-param name="warn-if-missing" tunnel="true" select="exists($parent-if-first)"/>
      </xsl:call-template>
      
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these"
          select="risk-metric[@name='vulnerability-id']"/>
        <xsl:with-param name="echo" tunnel="true">weakness source identifier</xsl:with-param>
      </xsl:call-template>
      
      <!-- inventory-item or component targets of subject-reference by 'uuid-ref'
           these hold all kinds of stuff. -->
      
      <xsl:variable name="inventory-components" select="$parent-if-first/observation/subject-reference[@type='inventory-item']/key('inventory-item-by-uuid',@uuid-ref),
        $parent-if-first/observation/subject-reference[@type='component']/key('component-by-uuid',@uuid-ref),
        $parent-if-first/observation/subject-reference[@type='inventory-item']/key('inventory-item-by-uuid',@uuid-ref,$ssp),
        $parent-if-first/observation/subject-reference[@type='component']/key('component-by-uuid',@uuid-ref,$ssp)"/>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these"
          select="$inventory-components/title"/>
        <xsl:with-param name="echo" tunnel="true">asset identifier</xsl:with-param>
        <xsl:with-param name="warn-if-missing" tunnel="true" select="exists($parent-if-first)"/>
      </xsl:call-template>
      
      <td class="tbd">point of contact (example needed)</td>
      
<!-- Each risk has one or more remediations; the one with @type='planned' is of interest.
     The Guide (p 20) also has validation logic regarding assignment of recommendation-origin/@type
      and @uuid-ref together; not implemented here. -->
      
      <!-- Valid data may have more than one remediation marked 'planned'; is that a warning condition? -->
      <xsl:variable name="planned-remediation" select="remediation[@type='planned']"/>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these"
          select="$planned-remediation/required/description"/>
        <xsl:with-param name="echo" expand-text="true" tunnel="true">resources required</xsl:with-param>
        <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
      </xsl:call-template>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these"
          select="$planned-remediation/(title, description)"/>
        <xsl:with-param name="echo" expand-text="true" tunnel="true">overall remediation plan</xsl:with-param>
        <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
      </xsl:call-template>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these"
          select="$parent-if-first/collected"/>
        <xsl:with-param name="echo" expand-text="true" tunnel="true">original detection date</xsl:with-param>
        <xsl:with-param name="date-format" tunnel="yes" as="xs:string" select="$use-date-format"/>
        <xsl:with-param name="warn-if-missing" tunnel="true" select="exists($parent-if-first)"/>
      </xsl:call-template>
      
      <xsl:variable name="latest-scheduled-end"
        select="max($planned-remediation/schedule/task/end[. castable as xs:dateTime] ! xs:dateTime(.) )"/>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these" select="$planned-remediation/schedule/task/end[xs:dateTime(.) = $latest-scheduled-end][1]"/>
        <xsl:with-param name="echo" expand-text="true" tunnel="true">scheduled completion date</xsl:with-param>
        <!-- showing local override of global $use-date-format
        <xsl:with-param name="date-format" tunnel="yes" as="xs:string">[D]/[M]/[Y]</xsl:with-param>  -->
        <xsl:with-param name="warn-if-missing" tunnel="true" select="true()"/>
      </xsl:call-template>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these" select="$planned-remediation/schedule/task"/>
        <xsl:with-param name="echo" expand-text="true" tunnel="true">planned milestones</xsl:with-param>
      </xsl:call-template>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these" select="remediation-tracking/tracking-entry"/>
        <xsl:with-param name="echo" expand-text="true" tunnel="true">milestone changes</xsl:with-param>
      </xsl:call-template>
          
      <td class="tbd">status date (???)</td>
      <td class="tbd">vendor dependency (example needed)</td>
      <td class="tbd">last vendor check-in date (ditto)</td>
      <td class="tbd">vendor dependent product name (ditto)</td>
      
      <xsl:variable name="initial-risks" select="risk-metric[@system=$fedramp-system][@class='initial']"/>
      <xsl:variable name="residual-risks" select="risk-metric[@system=$fedramp-system][@class='residual']"/>
        
      <!-- not using emit-value-td here b/c sorting -->
      <td>        
        <xsl:apply-templates select="$initial-risks" mode="inscribe-into-td">
          <xsl:sort select="@name"/>
          <xsl:with-param name="echo" expand-text="true" tunnel="true">original risk rating</xsl:with-param>
        </xsl:apply-templates>
      </td>
      <td>
        <xsl:apply-templates select="$residual-risks" mode="inscribe-into-td">
          <xsl:sort select="@name"/>
          <xsl:with-param name="echo" expand-text="true" tunnel="true">adjusted risk rating</xsl:with-param>
        </xsl:apply-templates>
      </td>

<!-- Risk Adjustment is 'Yes' if there are residual risks given a different value from corresponding initial risks -->
      <td>
        <xsl:choose>
          <xsl:when test="some $r in $residual-risks satisfies not($r = $initial-risks[@name=$r/@name])">Yes</xsl:when>
          <xsl:otherwise>No</xsl:otherwise>
        </xsl:choose>
      </td>
      
      <td>
        <xsl:choose>
          <xsl:when test="risk-metric/@name='false-positive'">Yes</xsl:when>
          <xsl:otherwise>No</xsl:otherwise>
        </xsl:choose>
      </td>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these" select="risk-metric[@name='operational-requirement'][@system=$fedramp-system]"/>
        <xsl:with-param name="echo" expand-text="true" tunnel="true">operational requirement</xsl:with-param>
      </xsl:call-template>
      
      <xsl:variable name="deviations" select="$parent-if-first/observation[prop[@name='conformity'][@ns=$fedramp-ns]=('operational-requirement','risk-adjustment')]"/>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these" select="$deviations"/>
        <xsl:with-param name="echo" expand-text="true" tunnel="true">deviation rationale</xsl:with-param>
      </xsl:call-template>
      
      <xsl:call-template name="emit-value-td">
        <xsl:with-param name="these" select="$deviations/relevant-evidence"/>
        <xsl:with-param name="echo" expand-text="true" tunnel="true">supporting documents</xsl:with-param>
      </xsl:call-template>
      
      <td class="tbd">comments</td>
      <td class="tbd">auto-approve</td>
    </tr>
  </xsl:template>
  
  
  <xsl:template name="make-dr-table">
    <!-- open, closed, combined or both  -->
    <xsl:param name="items" as="element(poam-item)*"/>
    <xsl:param name="table-id" required="true"/>
    <xsl:param name="combined" select="false()" tunnel="true"/>
    <xsl:if test="exists($items)">
      <h3>Deviation Requests</h3>
      <table class="poam dr" id="deviation-request-report">
        <xsl:call-template name="make-dr-table-head"/>
        <xsl:call-template name="make-dr-table-body"/>
      </table>
    </xsl:if>
      
  </xsl:template>
  
  <xsl:template name="make-dr-table-head">
    <thead>
      <tr class="guided">
        <td>&#xA0;</td>
        <th class="centered" colspan="10">Vulnerability Information<!-- (Include only one POA&amp;M item per row.)--></th>
        <th class="centered" colspan="4">Deviation Request Summary</th>
        <th class="centered" colspan="2">Additional Information: False Positive<!--<br class="br"/>(Complete this section only if you are submitting a false positive DR.)--></th>
        <th class="centered" colspan="3">Additional Information: Operational Requirement
          <!--<br class="br"/>(Complete this section if you are submitting an operational requirement or a risk reduced operational requirement DR.)"--></th>
        <th class="centered" colspan="17">Additional Information: Risk Reduction
        <!--<br class="br"/>(Complete this section if you are submitting a risk reduction or a risk reduced operational requirement DR.)
        <br class="br"/>Complete all fields below. Include references to the System Security Plan as applicable
        <br class="br"/>To complete the fields in this section, use the CVSS Environmental Score Metrics definitions found here:
        <a href="https://nvd.nist.gov/vuln-metrics">https://nvd.nist.gov/vuln-metrics</a>--></th>
        <th class="centered">Additional Information</th>
        <th class="centered">JAB/PMO Use Only</th>														
        
      </tr>
      <tr class="guided centered">
        
      </tr>
      
      <tr class="guidance">

      </tr>
    </thead>
  </xsl:template>
  
  <xsl:template name="make-dr-table-body">
      <tbody>
        <xsl:apply-templates select="()" mode="dr-table-row"/>
      </tbody>
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
table.poam td {{ border: thin solid black; text-align: left; vertical-align: bottom }}

table.poam th.centered,
table.poam td.centered {{ text-align: center }}

table.poam th > *:first-child {{ margin-top: 0em }}
table.poam td > *:first-child {{ margin-top: 0em }}
table.poam th > *:last-child  {{ margin-bottom: 0em }}
table.poam td > *:last-child  {{ margin-bottom: 0em }}

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

.rem {{ font-family: monospace; text-decoration: underline }}

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
