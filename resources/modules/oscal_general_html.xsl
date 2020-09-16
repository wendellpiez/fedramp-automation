<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="https://fedramp.gov/ns/oscal"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
    exclude-result-prefixes="#all">


   <xsl:variable name="fedramp-system" as="xs:string">https://fedramp.gov</xsl:variable>
   
   <xsl:variable name="fedramp-ns" as="xs:string">https://fedramp.gov/ns/oscal</xsl:variable>
   
   <xsl:variable name="use-date-format" as="xs:string">
      <xsl:choose>
         <xsl:when test="$set-date-format='YYYY-MM-DD'">[Y]-[M01]-[D01]</xsl:when>
         <xsl:when test="$set-date-format='D-Mon-YYYY'">[D]-[MNn,3-3]-[Y]</xsl:when>      <xsl:when test="$set-date-format='Month D, YYYY'">[MNn] [D], [Y]</xsl:when>
         <xsl:when test="$set-date-format='D Month YYYY'">[D] [MNn] [Y]</xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$set-date-format"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   
   <!-- import fallback logic first -->
   <xsl:import href="oscal_catalog_html.xsl"/>
   
   <xsl:template match="prop">
      <p>
         <xsl:apply-templates select="." mode="add-class"/>
         <xsl:apply-templates select="." mode="decorate-inline"/>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:variable name="front-matter" as="element()*">
      <!-- ToC, tables of figures and tables etc. here. -->
   </xsl:variable>
   
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
            <xsl:call-template name="js-inline"/>
            <xsl:if test="$paginating">
               <!--<link href="paged-js/interface-0.1.css" rel="stylesheet" type="text/css"/>-->
               <script src="https://unpkg.com/pagedjs/dist/paged.polyfill.js"></script>
            </xsl:if>
         </head>
         <body>
            <!-- We produce the contents by processing a set of proxy elements through a filter. Each proxy
            indicates a handle for expansion using logic bound to the proxy by template
            match. -->
            <xsl:apply-templates select="$front-matter"  mode="boilerplate"/>
            <xsl:apply-templates select="$main-contents" mode="boilerplate"/>
         </body>
      </html>
      <xsl:call-template name="warn-if-tracing">
         <xsl:with-param name="warning">[END] Root template concluded.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
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
   
   <xsl:template name="emit-value-td">
      <!-- $these will be a collection of nodes for display, representing a value setting
           set on an inventory item or on a component referenced by an inventory item. -->
      <xsl:param name="these" as="node()*"/>
      <td>
         <xsl:apply-templates select="$these" mode="inscribe-into-td"/>
         <xsl:call-template name="warn-unless-accepted">
            <xsl:with-param name="these" select="$these"/>
         </xsl:call-template>
      </td>
   </xsl:template>
   
   <xsl:template match="*" mode="inscribe-into-td">
      <xsl:param name="validate" as="element()*" tunnel="true"/>
      <p>
         <xsl:call-template name="emit-value">
            <xsl:with-param name="these" select="."/>
         </xsl:call-template>
         <xsl:apply-templates mode="check-value" select="$validate">
            <xsl:with-param name="who" select="."/>
         </xsl:apply-templates>
         <!-- emitting nbsp to ensure contents -->
         <xsl:text>&#xA0;</xsl:text>
      </p>
   </xsl:template>
   
   <xsl:template match="annotation" mode="inscribe-into-td">
      <xsl:param name="validate" as="element()*" tunnel="true"/>
      <p>
         <xsl:call-template name="emit-value">
            <xsl:with-param name="these" select="."/>
            <!-- emit 'missing' warnings when the info item $this includes nothing inside a component. -->
         </xsl:call-template>
         <xsl:apply-templates mode="check-value" select="$validate">
            <xsl:with-param name="who" select="."/>
         </xsl:apply-templates>
         <!-- emitting nbsp to ensure contents -->
         <xsl:text>&#xA0;</xsl:text>
      </p>
      <!-- if the value is given on an annotation, we want the remarks also -->
      <xsl:apply-templates mode="value" select="remarks[matches(string(),'\S')]"/>      
   </xsl:template>
    
   <!-- Addressing formatting requirements of POA&M  -->
   <xsl:template match="task" mode="inscribe-into-td">
      <xsl:param name="date-format" tunnel="yes" as="xs:string" select="$use-date-format"/>
      <xsl:variable name="dates" select="(start,end)[. castable as xs:dateTime]"/>
      <p>
         <xsl:number format="(1) "/>
         <xsl:value-of select="string-join($dates ! xs:dateTime(.) ! format-dateTime(.,$date-format),' to ')"/>
         <xsl:for-each select="title">
            <xsl:text> </xsl:text>
            <em class="inline-title">
               <xsl:apply-templates/>
            </em>
         </xsl:for-each>
         <!-- emitting nbsp to ensure contents -->
         <xsl:text>&#xA0;</xsl:text>
      </p>
      <xsl:apply-templates select="description" mode="inscribe-into-td"/>      
   </xsl:template>
   
   <!-- Also addressing formatting requirements of POA&M  -->
   <xsl:template match="remediation-tracking/tracking-entry" mode="inscribe-into-td">
      <xsl:param name="date-format" tunnel="yes" as="xs:string" select="$use-date-format"/>
      <p>
         <xsl:number format="(1) "/>
         <xsl:value-of select="date-time-stamp ! xs:dateTime(.) ! format-dateTime(.,$date-format)"/>
         <xsl:for-each select="title">
            <xsl:text> </xsl:text>
            <em class="inline-title">
               <xsl:apply-templates/>
            </em>
         </xsl:for-each>
         <!-- emitting nbsp to ensure contents -->
         <xsl:text>&#xA0;</xsl:text>
      </p>
      <xsl:apply-templates select="description" mode="inscribe-into-td"/>      
   </xsl:template>
   
   <xsl:template match="observation" mode="inscribe-into-td">
      <xsl:param name="validate" as="element()*" tunnel="true"/>
      <div class="observation">
         <xsl:apply-templates select="title,description" mode="#current"/>
      </div>
   </xsl:template>
   
   <xsl:template priority="2" match="observation/relevant-evidence[(@href castable as xs:anyURI) and not(starts-with(@href,'#'))]" mode="inscribe-into-td">
      <xsl:param name="validate" as="element()*" tunnel="true"/>
      <div class="evidence">
         <a href="{@href}">
           <xsl:apply-templates mode="#current"/>
         </a>
      </div>
   </xsl:template>
   
   <xsl:template match="observation/relevant-evidence" mode="inscribe-into-td">
      <xsl:param name="validate" as="element()*" tunnel="true"/>
      <div class="evidence">
         <xsl:apply-templates mode="#current"/>
      </div>
   </xsl:template>
   
   <xsl:template match="title" mode="inscribe-into-td">
      <h5>
         <xsl:apply-templates/>
      </h5>
   </xsl:template>
   
   <xsl:template match="description" mode="inscribe-into-td">
      <!-- switching out of mode -->
      <xsl:apply-templates/>
   </xsl:template>
   
   
   <xsl:template name="emit-value">
      <xsl:param name="these" as="node()*"/>
      <!-- setting $warn-if-missing requires at least one node in $accepting -->
      <!--<xsl:param name="warn-if-missing" tunnel="true" select="false()"/>
      <xsl:param name="accepting"       tunnel="true" select="$these"/>-->
      <xsl:for-each select="$these">
         <xsl:if test="not(position() eq 1)">; </xsl:if>
         <xsl:apply-templates select="." mode="value"/>
      </xsl:for-each>
      <xsl:call-template name="warn-unless-accepted">
         <xsl:with-param name="these" select="$these"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template name="warn-unless-accepted">
      <xsl:param name="these" as="node()*"/>
      <xsl:param name="echo" tunnel="true"/>
      <xsl:param name="warn-if-missing" tunnel="true" select="false()"/>
      <xsl:param name="accepting"       tunnel="true" select="$these"/>
      <xsl:if test="empty($accepting) and $warn-if-missing" expand-text="true">
         <!-- if tracing is on, we transcribe the echo into the page as "Missing"; otherwise just "Missing" -->
         <span class="ERROR">Missing{ if ($tracing) then (': ' || $echo) else '' }</span>
         <xsl:call-template name="warn-if-tracing">
            <xsl:with-param name="warning">NO VALUE FOUND for { $echo }</xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      
   </xsl:template>
   
   <!-- Mode 'value' produces spans marked 'val'
     containing the presentation value - generally element content, but
     sometimes mapped (as with eAuth values mapping to security impact levels) -->
   <xsl:template match="*" mode="value">
      <span class="val">
         <xsl:apply-templates/>
      </span>
   </xsl:template>
   
   <xsl:template match="@*" mode="value">
      <span class="val">
         <xsl:value-of select="."/>
      </span>
   </xsl:template>
   
   <xsl:template match="annotation" mode="value">
      <span class="val">
         <xsl:value-of select="@value"/>
      </span>
   </xsl:template>
   
   <xsl:template match="remarks" mode="value">
      <details class="value-details"><summary>Remarks</summary>
         <xsl:apply-templates/>
      </details>
   </xsl:template>
   
   <xsl:template match="last-modified | collected | expires | task/start | task/end" mode="value">
      <!-- The format can be provided higher in the template call stack. -->
      <xsl:param name="date-format" tunnel="yes" as="xs:string" select="$use-date-format"/>
      <span class="val">
         <xsl:variable name="date-value" select="substring-before(.,'T')"/>
         <xsl:value-of select="$date-value[. castable as xs:date] => xs:date() => format-date($date-format)"/>
         <xsl:if test="not($date-value castable as xs:date)">
            <xsl:value-of select="."/>
         </xsl:if>
      </span>
   </xsl:template>
   
   <xsl:template mode="value" match="prop[@ns=$fedramp-ns][@name='security-eauth-level']">
      <xsl:call-template name="lookup-value">
         <xsl:with-param name="who" select="."/>
         <xsl:with-param name="where" select="$fedramp-value-registry/*/f:value-set[@name='eauth-level']"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="value" match="risk-metric[@system=$fedramp-system]" expand-text="true">
      <xsl:for-each select="@name">
        <span class="lbl">{ substring(.,1,1) ! upper-case(.) }{ substring(.,2) }</span>
         <xsl:text>: </xsl:text>
      </xsl:for-each>
      <span class="val">{ substring(.,1,1) ! upper-case(.) }{ substring(.,2) }</span>
   </xsl:template>
   
   <xsl:template mode="value" match="system-characteristics/security-sensitivity-level">
      <xsl:call-template name="lookup-value">
         <xsl:with-param name="who" select="."/>
         <xsl:with-param name="where" select="$fedramp-value-registry/*/f:value-set[@name='security-sensitivity-level']"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="value" match="confidentiality-impact/selected |
      integrity-impact/selected |
      availability-impact/selected |
      security-impact-level/*">
      <xsl:call-template name="lookup-value">
         <xsl:with-param name="who" select="."/>
         <xsl:with-param name="where" select="$fedramp-value-registry/*/f:value-set[@name='security-impact-level']"/>
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
      <span class="val">{ $where/f:allowed-values/f:enum[@value=$who] }</span>
      <xsl:if test="empty($where//f:allowed-values/f:enum[@value=$who])">
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
   
   <xsl:template name="js-inline">
      <script type="text/javascript">
         function flashClass(whose,flag) {
         var flashers = document.getElementsByClassName(whose);
         /* for (i=0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> flashers.length; i++) { flashers[i].classList.toggle(flag) } */
         for (flasher in flashers) { flasher =<xsl:text disable-output-escaping="yes">></xsl:text> flasher.classList.toggle(flag) }
         }
      </script>
      <!--<script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript">
         function flashClass(whose,flag) {
           var flashers = [ document.getElementsByClassName(whose) ];
           return flashers.map( function(flasher) { flasher.classList.toggle(flag) } )
         }
      </script>-->
   </xsl:template>
   
   
<!-- 'check-value' mode provides validation with errors or warnings emitted into results. -->
   <xsl:template mode="check-value" match="f:allow-only">
      <xsl:param required="yes" name="who" as="node()"/>
      <xsl:variable name="checking" select="($who/self::annotation/@value, $who)[1]" as="xs:string"/>
      <xsl:variable name="okay-values" select="tokenize(@values,',?\s+'), $fedramp-value-registry/*/f:value-set[@name=current()/@lookup]/f:allowed-values/f:enum/@value/string()"/>
      <xsl:if test="not(string($checking) = $okay-values)" expand-text="true">
         <xsl:text> </xsl:text>
         <details class="validation-error"><summary>ERROR:</summary> value '{ $checking } ' is not permitted here: should be (one of) { $okay-values => string-join(', ') }</details>      </xsl:if>
   </xsl:template>
   
   
</xsl:stylesheet>
