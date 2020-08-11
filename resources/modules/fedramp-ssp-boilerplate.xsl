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
         <tr>
            <th>Unique Identifier</th>
            <th>Information System Name</th>
            <th>Information System</th>
         </tr>
         <tr>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this"
                     select="$ssp/*/system-characteristics/system-id[@identifier-type = 'https://fedramp.gov']"/>
                  <xsl:with-param name="echo">FedRAMP identifier</xsl:with-param>
               </xsl:call-template>
            </td>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this" select="$ssp/*/system-characteristics/system-name"/>
                  <xsl:with-param name="echo">system name (full)</xsl:with-param>
               </xsl:call-template>
            </td>
            <td>
               <f:generate item="system-short-name"/>
            </td>
         </tr>
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
            <tr>
               <th>System Sensitivity Level:</th>
               <td>
                  <xsl:call-template name="emit-value">
                     <xsl:with-param name="this" select="$ssp/*/system-characteristics/security-sensitivity-level"/>
                     <xsl:with-param name="echo">system sensitivity level</xsl:with-param>
                  </xsl:call-template>
               </td>
               
            </tr>
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
         <cols>
            <col width="35%"/>
            <col width="20%"/>
            <col width="15%"/>
            <col width="15%"/>
            <col width="15%"/>
         </cols>
         <tr>
            <th>
               <p>Information Type </p>
               <p>(Use only information types from <a>NIST SP 800-60</a>, Volumes I and II as amended)</p>
            </th>
            <th>NIST 800-60 identifier for Associated Information Type</th>
            <th>Confidentiality</th>
            <th>Integrity</th>
            <th>Availability</th>
         </tr>
         <xsl:for-each select="$ssp/*/system-characteristics/system-information/information-type">
            <tr>
               <td>
                  <xsl:call-template name="emit-value">
                     <xsl:with-param name="this" select="title"/>
                     <xsl:with-param name="echo">information type (name)</xsl:with-param>
                  </xsl:call-template>
               </td>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this" select="information-type-id [@system='https://doi.org/10.6028/NIST.SP.800-60v2r1']"/>
                  <xsl:with-param name="echo">NIST 800-600 information type identifier</xsl:with-param>
               </xsl:call-template>
            </td>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this" select="confidentiality-impact/selected"/>
                  <xsl:with-param name="echo">confidentiality impact level</xsl:with-param>
               </xsl:call-template>
            </td>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this" select="integrity-impact/selected"/>
                  <xsl:with-param name="echo">integrity impact level</xsl:with-param>
               </xsl:call-template>
            </td>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this" select="availability-impact/selected"/>
                  <xsl:with-param name="echo">availability impact level</xsl:with-param>
               </xsl:call-template>
            </td>
            </tr>
            
         </xsl:for-each>
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
         <tr>
            <th>Security Objective</th>
            <th>Low, Moderate or High</th>
         </tr>
         <tr>
            <td>Confidentiality</td>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this"
                     select="$ssp/*/system-characteristics/security-impact-level/security-objective-confidentiality"/>
                  <xsl:with-param name="echo">confidentiality objective</xsl:with-param>
               </xsl:call-template>

            </td>
         </tr>
         <tr>
            <td>Integrity</td>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this"
                     select="$ssp/*/system-characteristics/security-impact-level/security-objective-integrity"/>
                  <xsl:with-param name="echo">integrity objective</xsl:with-param>
               </xsl:call-template>
            </td>
         </tr>
         <tr>
            <td>Availability</td>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this"
                     select="$ssp/*/system-characteristics/security-impact-level/security-objective-availability"/>
                  <xsl:with-param name="echo">availability objective</xsl:with-param>
               </xsl:call-template>
            </td>
         </tr>
      </table>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@table='2-4']">
      <table id="table.2-4" class="uniform">
         <caption><span class="lbl">Table 2-4.</span> Baseline Security Configuration</caption>
         <tr>
            <th>Enter Information System Abbreviation Security Categorization</th>
            <td>
               <xsl:call-template name="emit-value">
                  <xsl:with-param name="this"
                     select="$ssp/*/system-characteristics/security-sensitivity-level"/>
                  <xsl:with-param name="echo">security sensitivity level</xsl:with-param>
               </xsl:call-template>
            </td>
         </tr>
      </table>
   </xsl:template>
   
   <xsl:template mode="boilerplate" match="f:generate[@section='2.3']">
      <section id="sec.2.3">
         <h2 class="head"><span class="n">2.3.</span> Digital Identity Determination</h2>
         <p>The digital identity information may be found in <a href="#attach3">ATTACHMENT 3 – Digital Identity Worksheet</a></p>
         <p>Note: NIST SP 800-63-3, Digital Identity Guidelines, does not recognize the four Levels of Assurance model previously used by federal agencies and described in OMB M-04-04, instead requiring agencies to individually select levels corresponding to each function being performed.</p>
         <p>The digital identity level is <xsl:call-template name="emit-value">
            <xsl:with-param name="this" select="$ssp/*/system-characteristics/prop[@ns='https://fedramp.gov/ns/oscal'][@name='security-eauth-level']"/>
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
            <xsl:call-template name="emit-value">
               <xsl:with-param name="this" select="$authorizing-party[1]"/>
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
         <tr>
            <th colspan="2">
               <xsl:sequence select="$table-header"/>
            </th>
         </tr>
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
      
</xsl:stylesheet>