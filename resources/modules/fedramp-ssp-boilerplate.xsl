<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="specs/fedramp-xslt-validate.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="https://fedramp.gov/ns/oscal"
                xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
                exclude-result-prefixes="#all"  default-mode="boilerplate">
   
<!-- TBD: XSLT metadata
   
   This XSLT is intended for use as imported by oscal_ssp-basic_html.xsl
   and/or other SSP transformations. Not for standalone use. -->
   
   <!--<xsl:import href="oscal_fallback_html.xsl"/>-->
   

   
<!-- Mode 'boilerplate' matches element proxies (visits) in f: signaling boilerplate build sites. -->
   
   <xsl:mode name="boilerplate" on-no-match="shallow-copy"/>
   
   <!-- Don't want em. -->
   <xsl:template mode="boilerplate" match="comment() | processing-instruction()"/>
   
   <!-- Matching nothing better gets us a signal to that effect. -->
   <xsl:template mode="boilerplate" match="f:generate" expand-text="true">
     <xsl:variable name="warning">
         <xsl:text>GENERATION LOGIC TBD </xsl:text>
         <xsl:apply-templates select="." mode="boilerplate-label"/>
         <xsl:if test="normalize-space(.)">: {.}</xsl:if>
      </xsl:variable>
      <xsl:call-template name="warn-if-tracing">
         <xsl:with-param name="warning" select="$warning"/>
      </xsl:call-template>
      <span class="ERROR">
         <xsl:sequence select="$warning"/>
      </span>
   </xsl:template>
   
   <xsl:template match="f:generate[@section]" mode="boilerplate-label" expand-text="true">(section { @section })</xsl:template>
   
   <xsl:template match="f:generate[@table]" mode="boilerplate-label" expand-text="true">(table { @table })</xsl:template>
   
   <xsl:template match="f:generate[@item]" mode="boilerplate-label" expand-text="true">(item { @item })</xsl:template>
   
   <xsl:template match="f:generate" mode="boilerplate-label" expand-text="true">({ @*/name() => string-join(' ') })</xsl:template>
   
   <xsl:variable name="ssp" select="/"/>
   
<!-- All the boilerplate follows. HTML contents appear in outputs.
     f: namespaced contents provide for dynamic includes of (further) generated contents. -->
   
   <xsl:template mode="boilerplate" match="f:generate[@section='1']"
      expand-text="true">
         <section id="sec.1">
            <h1 class="head"><span class="n">1.</span> Information System Name/Title</h1>
            <p>This System Security Plan provides an overview of the security requirements for 
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this" select="$ssp/*/system-characteristics/system-name"/>
                  <xsl:with-param name="echo">system name</xsl:with-param>
               </xsl:call-template>
             and describes the controls in place or planned for implementation to provide a level of security appropriate for the information to be transmitted, processed or stored by the system.  Information security is vital to our critical infrastructure and its effective performance and protection is a key component of our national security program. Proper management of information technology systems is essential to ensure the confidentiality, integrity and availability of the data transmitted, processed or stored by the <f:generate item="system-short-name"/> system.</p>
            <p>The security safeguards implemented for the <f:generate item="system-short-name"/> system meet the policy and control requirements set forth in this System Security Plan. All systems are subject to monitoring consistent with applicable laws, regulations, agency policies, procedures and practices.</p>
            <f:generate table="1-1">Table 1-1. Information System Name and Title</f:generate>
         </section>
   </xsl:template>
   
   <xsl:template match="f:generate[@table = '1-1']">
      <table id="table.1-1" class="uniform">
         <caption><span class="lbl">Table 1-1.</span> Information System Name and Title</caption>
         <thead>
            <tr>
               <th>Unique Identifier</th>
               <th>Information System Name</th>
               <th>Information System</th>
            </tr>
         </thead>
         <tbody>
            <tr>
               <xsl:call-template name="emit-value-td">
                  <xsl:with-param name="these"
                     select="$ssp/*/system-characteristics/system-id[@identifier-type = 'https://fedramp.gov']"/>
                  <xsl:with-param name="echo">FedRAMP identifier</xsl:with-param>
               </xsl:call-template>
               <xsl:call-template name="emit-value-td">
                  <xsl:with-param name="these" select="$ssp/*/system-characteristics/system-name"/>
                  <xsl:with-param name="echo">system name (full)</xsl:with-param>
               </xsl:call-template>

               <td>
                  <f:generate item="system-short-name"/>
               </td>
            </tr>
         </tbody>
      </table>
   </xsl:template>
   
   <xsl:template match="f:generate[@item='system-short-name']">
      <xsl:call-template name="emit-value">
         <xsl:with-param name="this" select="$ssp/*/system-characteristics/system-name-short"/>
         <xsl:with-param name="echo">system name (abbreviated)</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@section='2']">
      <section id="sec.2">
         <h1 class="head"><span class="n">2.</span> Information System Categorization</h1>
         <p>The overall information system sensitivity categorization is recorded in <a href="#table.2-1">Table 2-1 Security Categorization</a> that follows.  Directions for attaching the FIPS 199 document may be found in the following section: <a href="#attach10">ATTACHMENT 10 - FIPS 199</a>. 
         </p>
         <f:generate table="2-1">Table 2-1. Security Categorization</f:generate>
         <f:generate section="2.1"/>
         <f:generate section="2.2"/>
         <f:generate section="2.3"/>
      </section>
   </xsl:template>
   
   <xsl:template match="f:generate[@table='2-1']">
         <table id="table.2-1" class="uniform">
            <caption><span class="lbl">Table 2-1.</span> Security Categorization</caption>
            <tbody>
            <tr>
               <th>System Sensitivity Level:</th>
               
                  <xsl:call-template name="emit-value-td">
                     <xsl:with-param name="these"
                        select="$ssp/*/system-characteristics/security-sensitivity-level"/>
                     <xsl:with-param name="echo">system sensitivity level</xsl:with-param>
                  </xsl:call-template>
               
            </tr>
            </tbody>
         </table>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@section='2.1']">
      <section id="sec.2.1">
         <h2 class="head"><span class="n">2.1</span> Information Types</h2>
         <p>This section describes how the information types used by the information system are
            categorized for confidentiality, integrity and availability sensitivity levels.</p>
         <p>The following tables identify the information types that are input, stored, processed
            and/or output from the <f:generate item="system-short-name"/> system. The selection of
            the information types is based on guidance provided by <a>Office of Management and
            Budget (OMB) Federal Enterprise Architecture Program Management Office Business
            Reference Model 2.0</a> and <a>FIPS Pub 199, Standards for Security Categorization of
            Federal Information and Information Systems</a> which is based on <a>NIST Special
            Publication (SP) 800-60, Guide for Mapping Types of Information and Information
            Systems to Security Categories</a>. </p>
         <p>The tables also identify the security impact levels for confidentiality, integrity and
            availability for each of the information types expressed as low, moderate, or high. The
            security impact levels are based on the potential impact definitions for each of the
            security objectives (i.e., confidentiality, integrity and availability) discussed in
               <a>NIST SP 800-60</a> and <a>FIPS Pub 199</a>.</p>
         <p>The potential impact is low if —</p>
         <ul>
            <li>
               <p>The loss of confidentiality, integrity, or availability could be expected to have
                  a limited adverse effect on organizational operations, organizational assets, or
                  individuals.</p>
            </li>
            <li>
               <p>A limited adverse effect means that, for example, the loss of confidentiality,
                  integrity, or availability might: (i) cause a degradation in mission capability to
                  an extent and duration that the organization is able to perform its primary
                  functions, but the effectiveness of the functions is noticeably reduced; (ii)
                  result in minor damage to organizational assets; (iii) result in minor financial
                  loss; or (iv) result in minor harm to individuals.</p>
            </li>
         </ul>
         <p>The potential impact is moderate if —</p>
         <ul>
            <li>
               <p>The loss of confidentiality, integrity, or availability could be expected to have
                  a serious adverse effect on organizational operations, organizational assets, or
                  individuals.</p>
            </li>
            <li>
               <p>A serious adverse effect means that, for example, the loss of confidentiality,
                  integrity, or availability might: (i) cause a significant degradation in mission
                  capability to an extent and duration that the organization is able to perform its
                  primary functions, but the effectiveness of the functions is significantly
                  reduced; (ii) result in significant damage to organizational assets; (iii) result
                  in significant financial loss; or (iv) result in significant harm to individuals
                  that does not involve loss of life or serious life threatening injuries.</p>
            </li>
         </ul>
         <p>The potential impact is high if —</p>

         <ul>
            <li>
               <p>The loss of confidentiality, integrity, or availability could be expected to have
                  a severe or catastrophic adverse effect on organizational operations,
                  organizational assets, or individuals.</p>
            </li>
            <li>
               <p>A severe or catastrophic adverse effect means that, for example, the loss of
                  confidentiality, integrity, or availability might: (i) cause a severe degradation
                  in or loss of mission capability to an extent and duration that the organization
                  is not able to perform one or more of its primary functions; (ii) result in major
                  damage to organizational assets; (iii) result in major financial loss; or (iv)
                  result in severe or catastrophic harm to individuals involving loss of life or
                  serious life threatening injuries.</p>
            </li>
         </ul>
         <div class="instruction">
            <p>Record your information types in the tables that follow. Record the sensitivity level
               for Confidentiality, Integrity and Availability as High, Moderate, or Low. Add more
               rows as needed to add more information types. Use <a>NIST SP 800-60 Guide for Mapping
                  Types of Information and Systems to Security Categories, Volumes I &amp; II,
                  Revision 1</a> for guidance. </p>
            <p>Delete this instruction from your final version of this document.</p>
         </div>
         <f:generate table="2-2">Table 2-2. Sensitivity Categorization of Information
            Types</f:generate>

      </section>
   </xsl:template>
   
   <xsl:template match="f:generate[@table='2-2']">
      <table id="table.2-2" class="uniform">
         <caption><span class="lbl">Table 2-2.</span> Sensitivity Categorization of Information Types</caption>
         <colgroup>
            <col width="35%"/>
            <col width="20%"/>
            <col width="15%"/>
            <col width="15%"/>
            <col width="15%"/>
         </colgroup>
         <thead>
            <tr>
               <th>
                  <p>Information Type </p>
                  <p>(Use only information types from <a>NIST SP 800-60</a>, Volumes I and II as
                     amended)</p>
               </th>
               <th>NIST 800-60 identifier for Associated Information Type</th>
               <th>Confidentiality</th>
               <th>Integrity</th>
               <th>Availability</th>
            </tr>
         </thead>
         <tbody>
            <xsl:for-each select="$ssp/*/system-characteristics/system-information/information-type">
               <tr>
                  
                     <xsl:call-template name="emit-value-td">
                        <xsl:with-param name="these" select="title"/>
                        <xsl:with-param name="echo">information type (name)</xsl:with-param>
                     </xsl:call-template>
                  
                  
                     <xsl:call-template name="emit-value-td">
                        <xsl:with-param name="these"
                           select="information-type-id[@system = 'https://doi.org/10.6028/NIST.SP.800-60v2r1']"/>
                        <xsl:with-param name="echo">NIST 800-600 information type
                           identifier</xsl:with-param>
                     </xsl:call-template>
                  
                  
                     <xsl:call-template name="emit-value-td">
                        <xsl:with-param name="these" select="confidentiality-impact/selected"/>
                        <xsl:with-param name="echo">confidentiality impact level</xsl:with-param>
                     </xsl:call-template>
                  
                  
                     <xsl:call-template name="emit-value-td">
                        <xsl:with-param name="these" select="integrity-impact/selected"/>
                        <xsl:with-param name="echo">integrity impact level</xsl:with-param>
                     </xsl:call-template>
                  
                  
                     <xsl:call-template name="emit-value-td">
                        <xsl:with-param name="these" select="availability-impact/selected"/>
                        <xsl:with-param name="echo">availability impact level</xsl:with-param>
                     </xsl:call-template>
                  
               </tr>
            </xsl:for-each>
         </tbody>
      </table>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@section='2.2']">
      <section id="sec.2.2">
         <h2 class="head"><span class="n">2.2</span> Security Objectives Categorization (FIPS 199)</h2>
         <p>Based on the information provided in <a href="#table.2-2">Table 2-2 Sensitivity Categorization of Information Types</a>, for the <f:generate item="system-short-name"/> system, default to the high-water mark for the Information Types as identified in <a href="#table.2-3">Table 2-3 Security Impact Level</a> below.</p>
         <f:generate table="2-3">Table 2-3. Security Impact Level</f:generate>
         <p>Through review and analysis, it has been determined that the baseline security categorization for the <f:generate item="system-short-name"/> system is listed in the <a href="#table.2-4">Table 24 Baseline Security Configuration</a> that follows.</p>
         <f:generate table="2-4">Table 2-4. Baseline Security Configuration</f:generate>
         <p>Using this categorization, in conjunction with the risk assessment and any unique security requirements, we have established the security controls for this system, as detailed in this SSP.</p>
      </section>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@table = '2-3']">
      <table id="table.2-3" class="uniform">
         <caption><span class="lbl">Table 2-3.</span> Security Impact Level</caption>
         <thead> 
         <tr>
            <th>Security Objective</th>
            <th>Low, Moderate or High</th>
         </tr>
         </thead>
         <tbody>
         <tr>
            <td>Confidentiality</td>
            
               <xsl:call-template name="emit-value-td">
                  <xsl:with-param name="these"
                     select="$ssp/*/system-characteristics/security-impact-level/security-objective-confidentiality"/>
                  <xsl:with-param name="echo">confidentiality objective</xsl:with-param>
               </xsl:call-template>

            
         </tr>
         <tr>
            <td>Integrity</td>
            
               <xsl:call-template name="emit-value-td">
                  <xsl:with-param name="these"
                     select="$ssp/*/system-characteristics/security-impact-level/security-objective-integrity"/>
                  <xsl:with-param name="echo">integrity objective</xsl:with-param>
               </xsl:call-template>
            
         </tr>
            <tr>
               <td>Availability</td>
               
                  <xsl:call-template name="emit-value-td">
                     <xsl:with-param name="these"
                        select="$ssp/*/system-characteristics/security-impact-level/security-objective-availability"/>
                     <xsl:with-param name="echo">availability objective</xsl:with-param>
                  </xsl:call-template>
               
            </tr>
         </tbody>
      </table>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@table='2-4']">
      <table id="table.2-4" class="uniform">
         <caption><span class="lbl">Table 2-4.</span> Baseline Security Configuration</caption>
         <tbody>
            <tr>
               <th>Enter Information System Abbreviation Security Categorization</th>
               
                  <xsl:call-template name="emit-value-td">
                     <xsl:with-param name="these"
                        select="$ssp/*/system-characteristics/security-sensitivity-level"/>
                     <xsl:with-param name="echo">security sensitivity level</xsl:with-param>
                  </xsl:call-template>
               
            </tr>
         </tbody>
      </table>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@section='2.3']">
      <section id="sec.2.3">
         <h2 class="head"><span class="n">2.3.</span> Digital Identity Determination</h2>
         <p>The digital identity information may be found in <a href="#attach3">ATTACHMENT 3 – Digital Identity Worksheet</a></p>
         <p>Note: NIST SP 800-63-3, Digital Identity Guidelines, does not recognize the four Levels of Assurance model previously used by federal agencies and described in OMB M-04-04, instead requiring agencies to individually select levels corresponding to each function being performed.</p>
         <p>The digital identity level is <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="$ssp/*/system-characteristics/prop[@ns='https://fedramp.gov/ns/oscal'][@name='security-eauth-level']"/>
            <xsl:with-param name="echo">security sensitivity level</xsl:with-param>
         </xsl:call-template>.</p>
         <p>Additional digital identity information can be found in <a>Section 15 Attachments Digital Identity Level Selection</a>.</p>
      </section>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@section='3']">
      <section id="sec.3">
         <h1 class="head"><span class="n">3</span> System Owner</h1>
         <p>The following individual is identified as the system owner or functional proponent/advocate for this system.</p>
          <!-- While there should be only a single system-owner, it is not invalid for it to be linked to multiple parties. -->
            <xsl:for-each select="$ssp/*/metadata/responsible-party[@role-id='system-owner']/key('party-by-uuid',party-uuid)">
             <xsl:call-template name="address-table">
                <xsl:with-param name="id">table.2-4</xsl:with-param>
                <xsl:with-param name="table-header">Information System Owner Information</xsl:with-param>
                <xsl:with-param name="caption">
                   <caption><span class="lbl">Table 3-1.</span> Information System Owner</caption>
                </xsl:with-param>
                  <xsl:with-param name="addressee" select="."/>
               </xsl:call-template>
            </xsl:for-each>
      </section>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@section='4']">
      <xsl:variable name="authorizing-party" select="$ssp/*/metadata/responsible-party[@role-id='authorizing-official']/key('party-by-uuid',party-uuid)"/>
      <section id="sec.4">
         <h1 class="head"><span class="n">4</span> Authorizing Official</h1>
         <div class="instruction">
            <p>The Authorizing Official is determined by the path that the CSP is using to obtain an authorization.</p>
            <ul>
               <li>JAB P-ATO: FedRAMP, JAB, as comprised of member representatives from the General Services Administration (GSA), Department of Defense (DoD) and Department of Homeland Security (DHS)</li>
               <li>Agency Authority to Operate (ATO): Agency Authorizing Official name, title and contact information</li>
            </ul>
            <p>Delete this and all other instructions from your final version of this document.</p>
         </div>
         <p>The Authorizing Official (AO) or Designated Approving Authority (DAA) for this information system is
            <xsl:call-template name="emit-value-td">
               <xsl:with-param name="these" select="$authorizing-party[1]"/>
               <xsl:with-param name="echo">authorizing official</xsl:with-param>
            </xsl:call-template>.</p>
      </section>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@section='5']">
      <section id="sec.5">
         <h1 class="head"><span class="n">5</span> Other Designated Contacts</h1>
         <div class="instruction">
            <p>AOs should use the following section to identify points of contact that understand the technical implementations of the identified cloud system.  AOs should edit, add, or modify the contacts in this section as they see fit.</p>
            <p>Delete this and all other instructions from your final version of this document.</p>
         </div>
         <p>The following individual(s) identified below possess in-depth knowledge of this system and/or its functions and operation.</p>
         
            <!-- While there should be only a single system-owner, it is not invalid for it to be linked to multiple parties. -->
            <xsl:for-each select="$ssp/*/metadata/responsible-party[@role-id='system-poc-management']/key('party-by-uuid',party-uuid)">
               <div id="table.5-1">
                  
               <xsl:call-template name="address-table">
                  <xsl:with-param name="id">table.5-1</xsl:with-param>
                  <xsl:with-param name="caption">
                     <caption><span class="lbl">Table 5-1.</span> Information System Management Point of Contact</caption></xsl:with-param>
                  <xsl:with-param name="table-header">Information System Management Point of Contact</xsl:with-param>
                  <xsl:with-param name="addressee" select="."/>
               </xsl:call-template>
               </div>
            </xsl:for-each>
         
            <xsl:for-each select="$ssp/*/metadata/responsible-party[@role-id='system-poc-technical']/key('party-by-uuid',party-uuid)">
               <xsl:call-template name="address-table">
                  <xsl:with-param name="id">table.5-2</xsl:with-param>
                  <xsl:with-param name="table-header">Information System Technical Point of
                     Contact</xsl:with-param>
                  <xsl:with-param name="addressee" select="."/>
                  <xsl:with-param name="caption">
                     <caption><span class="lbl">Table 5-2.</span> Information System Technical Point
                        of Contact</caption>
                  </xsl:with-param>
               </xsl:call-template>
            </xsl:for-each>
               <div class="instruction">
                  <p>Add more tables as needed.</p>
                  <p>Delete this and all other instructions from your final version of this document.</p>
               </div>
            <xsl:for-each select="$ssp/*/metadata/responsible-party[@role-id='system-poc-other']/key('party-by-uuid',party-uuid)">
               <xsl:call-template name="address-table">
                  <xsl:with-param name="table-header">Point of Contact</xsl:with-param>
                  <xsl:with-param name="addressee" select="."/>
               </xsl:call-template>
            </xsl:for-each>
         
      </section>
   </xsl:template>
   
   <xsl:template name="address-table">
      <xsl:param name="table-header"/>
      <xsl:param name="addressee" as="element(party)" required="true"/>
      <xsl:param name="caption"/>
      <xsl:param name="id"/>
      <xsl:variable name="organization" select="key('party-by-uuid',member-of-organization)"/>
      <xsl:variable name="location"     select="key('location-by-uuid',location-uuid)"/>
      <table class="uniform poc">
         <xsl:if test="matches($id,'\S')">
            <xsl:attribute name="id" select="$id"/>
         </xsl:if>
         <xsl:copy-of select="$caption"/>
         <thead>
         <tr>
            <th colspan="2">
               <xsl:sequence select="$table-header"/>
            </th>
         </tr>
         </thead>
         <tbody>
            <tr>
               <td class="rh">Name</td>
               <td>
                  <xsl:apply-templates mode="value" select="party-name"/>
                  <xsl:for-each select="short-name" expand-text="true"> ({ . })</xsl:for-each>
               </td>
            </tr>
            <tr>
               <td class="rh">Title</td>
               <td>
                  <xsl:apply-templates mode="value"
                     select="prop[@ns = 'https://fedramp.gov/ns/oscal'][@name = 'title']"/>
               </td>
            </tr>
            <tr>
               <td class="rh">Company / Organization</td>
               <td>
                  <xsl:apply-templates mode="value" select="$organization/party-name"/>
               </td>
            </tr>
            <tr>
               <td class="rh">Address</td>
               <td>
                  <xsl:for-each select="address | $location/address">
                     <p class="val">
                        <xsl:value-of select="*" separator=" "/>
                     </p>
                  </xsl:for-each>
               </td>
            </tr>
            <tr>
               <td class="rh">Phone Number</td>
               <td>
                  <xsl:for-each select="phone | $location/phone">
                     <p class="val">
                        <xsl:apply-templates/>
                     </p>
                  </xsl:for-each>
               </td>
            </tr>
            <tr>
               <td class="rh">Email Address</td>
               <td>
                  <xsl:apply-templates mode="value" select="email"/>
               </td>
            </tr>
         </tbody>
      </table>
   </xsl:template>
   
   <!--expand, collapse or drop-->
   <xsl:param name="show-instructions" as="xs:string">expand</xsl:param>
   
   <xsl:template priority="5" mode="boilerplate" xpath-default-namespace="http://www.w3.org/1999/xhtml" match="div[contains-token(@class,'instruction')][$show-instructions='drop']">
      <xsl:message expand-text="true">matched { $show-instructions }</xsl:message>
   </xsl:template>
   
   <xsl:template mode="boilerplate" xpath-default-namespace="http://www.w3.org/1999/xhtml" match="div[contains-token(@class,'instruction')]">
      <details class="{@class}">
         <xsl:if test="$show-instructions='expand'">
           <xsl:attribute name="open">true</xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="@*"/>
        <summary>Instruction</summary>
        <xsl:apply-templates mode="#current"/>
     </details>
   </xsl:template>
    
   <xsl:template mode="boilerplate" match="f:generate[@attachment='13']">
      <section id="attachment.13" class="integrated-inventory">
         <h1><span class="n">Attachment 13.</span> Integrated Inventory</h1>
         <table class="iinv">
            <xsl:call-template name="inventory-table-head"/>
            <xsl:apply-templates mode="integrated-inventory" select="$ssp/*/system-implementation/system-inventory/inventory-item"/>
         </table>
      </section>
   </xsl:template>
   
   <xsl:template name="inventory-table-head">
      <thead>
         <tr>
            <th colspan="5" class="all">All Inventories</th>
            <th colspan="9" class="os">OS/Infrastructure Inventory</th>
            <th colspan="4" class="swdb">Software and Database Inventories</th>
            <th colspan="5" class="any">Any Inventory</th>
            <th colspan="2" class="added">Additional</th>
         </tr>
         <tr class="guided">
            <th>UNIQUE ASSET IDENTIFIER</th>
            <th>IPv4 or IPv6 Address</th>
            <th>Virtual</th>
            <th>Public</th>
            <th>DNS Name or URL</th>
            <th>NetBIOS Name</th>
            <th>MAC Address</th>
            <th>Authenticated Scan</th>
            <th>Baseline Configuration Name</th>
            <th>OS Name and Version</th>
            <th>Location</th>
            <th>Asset Type</th>
            <th>Hardware Make/Model</th>
            <th>In Latest Scan</th>
            <th>Software / Database Name &amp; Version</th>
            <th>Software / Database Vendor</th>
            <th>Patch Level</th>
            <th>Function</th>
            <th>Comments</th>
            <th>Serial # / Asset Tag #</th>
            <th>VLAN / Network ID</th>
            <th>System Administrator / Owner</th>
            <th>Application Administrator / Owner</th>
            <th>Scan Type</th>
            <th>FIPS 140-2 Validation</th>
         </tr>
      
         <tr class="guidance">
            <th>
               <!--<p>UNIQUE ASSET IDENTIFIER</p>-->
               <div class="guidance">Unique Identifier associated with the asset. This Identifier
                  should be used consistently across all documents, 3PAOs artifacts, and any
                  vulnerability scanning tools. For OS/Infrastructure and Web Application Software,
                  this is typically an IP address or URL/DNS name. For a database, it is typically
                  an IP address, URL, or database name. A CSP's own naming scheme is also acceptable
                  as long as it has unique identifiers.</div>
            </th>
            
            <th>
               <!--<p>IPv4 or IPv6 Address</p>-->
               <div class="guidance">If available, state the IPv4 or IPv6 address of the inventory
                  item. This can be left blank if one does not exist, or if it is a dynamic field.
                  If the IP address is used as the Unique Asset Identifier, then this field will
                  duplicate the contents of the Unique Asset Identifier column. If a device has
                  multiple IP addresses, then include one row in this inventory for each IP
                  address.</div>
            </th>
            <th>
               <!--<p> Virtual</p>-->
               <div class="guidance">Is this asset virtual? </div>
            </th>
            <th>
               <!--<p>Public</p>-->
               <div class="guidance">Is this asset a public facing device? That is, is it outside
                  the boundary? If so, it is an entry point.</div>
            </th>
            <th>
               <!--<p>DNS Name or URL</p>-->
               <div class="guidance">If available, state the DNS name or URL of the inventory item.
                  This can be left blank if one does not exist, or it is a dynamic field. </div>
            </th>
            <th>
               <!--<p>NetBIOS Name</p>-->
               <div class="guidance">If available, state the NetBIOS name of the inventory item.
                  This can be left blank if one does not exist, or it is a dynamic field. </div>
            </th>
            <th>
               <!--<p>MAC Address</p>-->
               <div class="guidance">If available, state the MAC Address of the inventory item. This
                  can be left blank if one does not exist, or it is a dynamic field. </div>
            </th>
            <th>
               <!--<p>Authenticated Scan</p>-->
               <div class="guidance">Is the asset is planned for an authenticated scan? </div>
            </th>
            <th>
               <!--<p>Baseline Configuration Name</p>-->
               <div class="guidance">If available, provide the name of the configuration template
                  used within the CSP configuration management.</div>
            </th>
            <th>
               <!--<p>OS Name and Version</p>-->
               <div class="guidance">Operating System Name and Version running on the asset.</div>
            </th>
            <th>
               <!--<p>Location</p>-->
               <div class="guidance">Physical location of hardware. Could include Data Center ID,
                  Cage#, Rack# or other meaningful location identifiers. </div>
            </th>
            <th>
               <!--<p>Asset Type</p>-->
               <div class="guidance">
                  <p>Simple description of the asset's function (e.g., Router, Storage Array, DNS
                     Server, etc.)</p>
                  <p>Do not use vendor or product names which should go in Columns N (for hardware)
                     or Columns P-Q for software or database.</p>
               </div>
            </th>
            <th>
               <!--<p>Hardware Make/Model</p>-->
               <div class="guidance">Name of the hardware product and model.</div>
            </th>
            <th>
               <!--<p>In Latest Scan</p>-->
               <div class="guidance">Should the asset appear in the network scans and can it be
                  probed by the scans creating the current POA&amp;M?</div>
            </th>
            <th>
               <!--<p>Software / Database Name &amp; Version</p>-->
               <div class="guidance">Name of Software or Database product and version number.</div>
            </th>
            <th>
               <!--<p>Software / Database Vendor</p>-->
               <div class="guidance">
                  <p>Name of Software or Database vendor.</p>
                  <p>If open source (i.e., there is no “vendor”), enter “Open Source” as the vendor
                     name.</p>
               </div>
            </th>
            <th>
               <!--<p>Patch Level</p>-->
               <div class="guidance">If applicable.</div>
            </th>
            <th>
               <!--<p>Function</p>-->
               <div class="guidance">For Software or Database, the function provided by the Software
                  or Database for the system. </div>
            </th>
            <th>
               <!--<p>Comments</p>-->
               <div class="guidance">Any additional information that could be useful to the
                  reviewer.</div>
            </th>
            <th>
               <!--<p>Serial # / Asset Tag #</p>-->
               <div class="guidance">Product serial number or internal asset tag #. </div>
            </th>
            <th>
               <!--<p>VLAN / Network ID</p>-->
               <div class="guidance">Virtual LAN or Network ID.</div>
            </th>
            <th>
               <!--<p>System Administrator/ Owner</p>-->
               <div class="guidance">Name of the system administrator or owner.</div>
            </th>
            <th>
               <!--<p>Application Administrator/ Owner</p>-->
               <div class="guidance">Name of the application administrator or owner.</div>
            </th>
            
         </tr>
      </thead>
   </xsl:template>
   
   <xsl:template mode="integrated-inventory" match="inventory-item | component">
      <xsl:param name="this-item" select="."/>
      <!-- $item-component will be false() for the item, true() for its
           components.-->
      <!-- $integrated-item will be this component and the item calling
              (including) it, or only the item when the context is not a component. -->
      <xsl:variable name="integrated-item" select=". | $this-item"/>
      <xsl:variable name="components" select="key('component-by-uuid',implemented-component/@component-uuid)"/>
      
      <tr class="inventory { if (exists(self::component)) then 'component' else 'line-item' }">
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="$this-item/@asset-id"/>
            <xsl:with-param name="echo">unique asset identifier</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='ipv4-address'] | prop[@name='ipv6-address']"/>
            <xsl:with-param name="echo">ip address (v4 or v6)</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='virtual']"/>
            <xsl:with-param name="echo">virtual</xsl:with-param>
            <xsl:with-param name="validate" as="element()*">
               <f:allow-only values="yes no"/>
            </xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='public']"/>
            <xsl:with-param name="echo">public</xsl:with-param>
            <xsl:with-param name="validate" as="element()*">
               <f:allow-only values="yes no"/>
            </xsl:with-param>
         </xsl:call-template>
         <!--<xsl:call-template name="emit-value-td">
            <xsl:with-param name="this" select="prop[@name='fqdn']"/>
            <xsl:with-param name="echo">fqdn</xsl:with-param>
         </xsl:call-template>-->
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='uri']"/>
            <xsl:with-param name="echo">DNS name / uri</xsl:with-param>            
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='netbios-name']"/>
            <xsl:with-param name="echo">netbios-name</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='mac-address']"/>
            <xsl:with-param name="echo">mac-address</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="annotation[@name='allows-authenticated-scan']"/>
            <xsl:with-param name="echo">allows-authenticated-scan</xsl:with-param>
            
            <xsl:with-param name="warn-if-missing" tunnel="yes" select="true()"/>
            <xsl:with-param name="accepting"       tunnel="yes" select="($integrated-item | $components)/annotation[@name='allows-authenticated-scan']"/>
            
            <xsl:with-param name="validate" as="element()*">
               <f:allow-only values="yes no"/>
            </xsl:with-param>
         </xsl:call-template>
         <!--<xsl:call-template name="emit-value-td">
            <xsl:with-param name="this"
               select="prop[@ns='https://fedramp.gov/ns/oscal'][@name='scan-type']"/>
            <xsl:with-param name="echo">scan-type</xsl:with-param>
            <xsl:with-param name="validate" as="element()*">
               <f:allow-only values="infrastructure web database"/>
            </xsl:with-param>
         </xsl:call-template>-->
         <!--<xsl:call-template name="emit-value-td">
            <xsl:with-param name="this"
               select="prop[@ns='https://fedramp.gov/ns/oscal'][@name='validation']"/>
            <xsl:with-param name="echo">validation</xsl:with-param>
         </xsl:call-template>
         
         -->
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="annotation[@name='baseline-configuration-name']"/>
            <xsl:with-param name="echo">baseline-configuration-name</xsl:with-param>            
         </xsl:call-template>
         
         <xsl:variable name="os-and-version" as="element()*" expand-text="true">
            <xsl:if test="prop[@name='asset-type']='os'">
               <xsl:for-each select="prop[@name='software-name']">
                  <prop name="os-version">{ . }{ ../prop[@name='version'] ! (', version ' || .) }</prop>
               </xsl:for-each>
            </xsl:if>
         </xsl:variable>
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="$os-and-version"/>
            <xsl:with-param name="echo">OS name and version</xsl:with-param>
            <xsl:with-param name="warn-if-missing" tunnel="yes"  select="prop[@name='asset-type']='os'"/>
            <xsl:with-param name="acceptable" tunnel="yes" select="prop[@name='software-name']"/>
         </xsl:call-template>
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="annotation[@name='physical-location']"/>
            <xsl:with-param name="echo">physical-location</xsl:with-param>
         </xsl:call-template>
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='asset-type']"/>
            <xsl:with-param name="echo">asset-type</xsl:with-param>
            <xsl:with-param name="validate" as="element()*">
               <f:allow-only values="os database web-server dns-server email-server directory-server pbx firewall router switch storage-array"/>
            </xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='model']"/>
            <xsl:with-param name="echo">model</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="annotation[@name='is-scanned']"/>
            <xsl:with-param name="echo">"is scanned" status</xsl:with-param>
            <xsl:with-param name="validate" as="element()*">
               <f:allow-only values="yes no"/>
            </xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='software-name'] | prop[@name='version']"/>
            <xsl:with-param name="echo">software name and version</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these"
               select="prop[@ns='https://fedramp.gov/ns/oscal'][@name='vendor-name']"/>
            <xsl:with-param name="echo">vendor name</xsl:with-param>
         </xsl:call-template>
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='patch-level']"/>
            <xsl:with-param name="echo">patch-level</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="annotation[@name='function']"/>
            <xsl:with-param name="echo">function</xsl:with-param>
         </xsl:call-template>
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="remarks"/>
            <xsl:with-param name="echo">comments</xsl:with-param>
         </xsl:call-template>
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='serial-number'] | prop[@name='asset-tag']"/>
            <xsl:with-param name="echo">serial-number, asset tag</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='vlan-id'] | prop[@name='network-id']"/>
            <xsl:with-param name="echo">vlan or network ID</xsl:with-param>
         </xsl:call-template>
         
         <xsl:variable name="system-owner" as="element()*" expand-text="true">
            <xsl:apply-templates mode="inline-contact" select="responsible-party[@role-id='asset-owner']/key('party-by-uuid',party-uuid)"/>
         </xsl:variable>
         
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="()"/>
            <xsl:with-param name="echo">system admin/owner</xsl:with-param>
            <xsl:with-param name="warn-if-missing" tunnel="yes"  select="true()"/>
         </xsl:call-template>
         
         <xsl:variable name="system-admin" as="element()*" expand-text="true">
            <xsl:apply-templates mode="inline-contact" select="responsible-party[@role-id='asset-administrator']/key('party-by-uuid',party-uuid)"/>
         </xsl:variable>
         
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="()"/>
            <xsl:with-param name="echo">application admin/owner</xsl:with-param>
            <xsl:with-param name="warn-if-missing" tunnel="yes"  select="true()"/>
         </xsl:call-template>
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='scan-type']"/>
            <xsl:with-param name="echo">scan type</xsl:with-param>
         </xsl:call-template>
         
         <xsl:call-template name="emit-value-td">
            <xsl:with-param name="these" select="prop[@name='validation'][@ns='https://fedramp.gov/ns/oscal']"/>
            <xsl:with-param name="echo">FIPS 140-2 validation</xsl:with-param>
         </xsl:call-template>
      </tr>
<!-- when the context is an inventory-item, there may be components - we want them too. -->
      <xsl:apply-templates select="$components" mode="#current">
         <xsl:with-param name="this-item" select="."/>
      </xsl:apply-templates>
   </xsl:template>
</xsl:stylesheet>