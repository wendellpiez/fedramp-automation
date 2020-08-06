<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="https://fedramp.gov/ns/oscal"
    >
    
    <sch:ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
    <sch:ns prefix="f"   uri="https://fedramp.gov/ns/oscal"/>
    
    <sch:let name="strict"  value="/*/f:transformation/@validation => tokenize() = 'strict'"/>
    <sch:let name="current" value="/*/f:transformation/@validation => tokenize() = 'current'"/>
    
    <sch:pattern>
        <sch:rule context="f:transformation[$strict]">
                <!--<sch:let name="" value="f:title | f:short-title | f:description |
                f:date-of-origin | f:date-last-modified |
                f:parameter | f:dependency | f:result-format"/>-->
            <sch:assert test="exists(f:title)">XSLT needs a title</sch:assert>
            <sch:assert test="exists(f:short-title)">XSLT needs a short-title</sch:assert>
            <sch:assert test="exists(f:description)">XSLT needs a description</sch:assert>
            <sch:assert test="exists(f:date-of-origin)">XSLT needs a date-of-origin</sch:assert>
            <sch:assert test="exists(f:date-last-modified)">date-last-modified</sch:assert>
            <sch:assert test="exists(f:result-format)">XSLT needs a result-format</sch:assert>
            
        </sch:rule>
        <sch:rule context="f:transformation[$strict]/f:title"/>
        <sch:rule context="f:transformation[$strict]/f:short-title"/>
        <sch:rule context="f:transformation[$strict]/f:description"/>
        <sch:rule context="f:transformation[$strict]/f:date-of-origin">
            <sch:assert test=". castable as xs:date">Value <sch:value-of select="."/> is not a date</sch:assert>
        </sch:rule>
        <sch:rule context="f:transformation[$strict]/f:date-last-modified">
            <sch:assert test=". castable as xs:date">Value <sch:value-of select="."/> is not a date</sch:assert>
            <sch:assert test="xs:date(.) >= ../f:date-of-origin!xs:date(.)">Can't be last modified before the creation date</sch:assert>
            <sch:assert test="not($current) or (xs:date(.) >= current-date())">Date is out of date?</sch:assert>
        </sch:rule>
        <sch:rule context="f:transformation[$strict]/f:parameter">
            <sch:let name="this" value="/*/xsl:param[@name=current()/@name]"/>
            <sch:assert test="exists($this) or exists(@module)">Parameter description points to no top-level parameter (in this XSLT)</sch:assert>
            <sch:report test="count($this) gt 1">Parameter description is bound to two points?</sch:report>
            <sch:assert test="($this/@as = @as)">Datatype for parameter '<sch:value-of select="$this/@name"/>' is declared as '<sch:value-of select="$this/@as"/>' not '<sch:value-of select="@as"/>'</sch:assert>
        </sch:rule>
        <sch:rule context="f:transformation[$strict]/f:dependency">
            <sch:let name="href-a-uri" value="@href castable as xs:anyURI"/>
            <sch:assert test="$href-a-uri">Dependency @href '<value-of select="@href"/>' does not appear to be a URI.</sch:assert>
            
        </sch:rule>
        <sch:rule context="f:transformation[$strict]/f:result-format"/>
        <sch:rule context="f:transformation[$strict]/*">
            <sch:report test="true()"><sch:name/> is not prescribed.</sch:report>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>