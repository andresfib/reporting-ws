<!-- Common macros and functions that could be reused in any template based on IUCLID6 data -->

<#--It initializes the following variables:
	* _dossierHeader (:DossierHashModel) //The header document of a proper or 'raw' dossier, can be empty
	* _subject (:DocumentHashModel) //The dossier subject document or, if not in a dossier context, the root document, never empty
-->
<#macro initializeMainVariables>
	<#if (dossier.header)?has_content>
		<#global "_dossierHeader"=dossier.header + {"Name": dossier.header.name}/>
		<#global "_subject"=dossier.subject.root />
	<#elseif rootDocument.documentType=="DOSSIER">
		<#global "_dossierHeader"=rootDocument + {"Name": rootDocument.name}/>
		<#global "_subject"=iuclid.getDocumentForKey(rootDocument.subjectKey) />
	<#elseif isProject((entity.root)!)>
        <#local "_header"=getProjectDossierHeader(entity)/>
		<#global "_dossierHeader"=_header + { "subjectKey":entity.root.RelatedEntity, "subjectType": entity.root.documentType, "submissionTypeVersion": "", "submittingLegalEntityKey": "", "submissionRemarks":_header.Remarks }/>
		<#global "_subject"=iuclid.getDocumentForKey(entity.root.RelatedEntity) />
	<#else>
		<#global "_subject"=rootDocument />
	</#if>
</#macro>

<#function isProject doc="">
	<#if doc?has_content && doc.documentType=="CUSTOM_ENTITY" && doc.documentSubType=="IuclidWebProject">
		<#return true/>
	</#if>
	<#return false/>
</#function>

<#function getProjectDossierHeader project>
	<#list entity.sections("CUSTOM_SECTION.IuclidWebCreateDossier") as settings>
		<#return iuclid.getDocumentForKey(settings.Header)/>
	</#list>
</#function>

<#macro documentReference documentKey>
<#compress>
	<#if documentKey?has_content>
		<#local document = iuclid.getDocumentForKey(documentKey) />
		<#if document?has_content>
			<#escape x as x?html>
			${document.name}
			</#escape>
		<#else>
			${documentKey}
		</#if>
	</#if>
</#compress>
</#macro>

<#macro documentReferenceMultiple documentReferenceMultipleValue>
<#compress>
	<#if documentReferenceMultipleValue?has_content>
		<#list documentReferenceMultipleValue as item>
			<@documentReference item/>
			<#if item_has_next>; </#if>
		</#list>
	</#if>
</#compress>
</#macro>

<#macro text textValue="">
<#compress>
	<#if textValue?has_content>
		<#escape x as x?html>
		${textValue}
		</#escape>
  	</#if>
</#compress>
</#macro>


<#macro number numberValue>
<#compress>
	<#if numberValue?has_content>
		${numberValue?string["0.###"]}
  	</#if>
</#compress>
</#macro>


<#macro richText richTextValue>
<#compress>
	<#if richTextValue?has_content>
		${iuclid.convertHtmlToDocBook(richTextValue)}
  	</#if>
</#compress>
</#macro>

<#macro picklist picklistValue locale="en" printOtherPhrase=false>
<#compress>
	<#escape x as x?html>
		<#local localizedPhrase = iuclid.localizedPhraseDefinitionFor(picklistValue.code, locale) />
		<#if localizedPhrase?has_content>
			<#if !localizedPhrase.open || !(localizedPhrase.text?matches("other:")) || printOtherPhrase>
				${localizedPhrase.text} <#t>
			</#if>
			<#if localizedPhrase.open && picklistValue.otherText?has_content>
				${picklistValue.otherText}<#t>
			</#if>
			<#if localizedPhrase.description?has_content>
				[${localizedPhrase.description}]
			</#if>
		</#if>
		<#if picklistValue.remarks?has_content>
			- ${picklistValue.remarks}
		</#if>
		<#lt>
	</#escape>
</#compress>
</#macro>


<#macro picklistMultiple picklistMultipleValue>
<#compress>
	<#if picklistMultipleValue?has_content>
		<#list picklistMultipleValue as item>
			<@picklist item/>
			<#if item_has_next>; </#if>
		</#list>
	</#if>
</#compress>
</#macro>


<#macro range rangeValue locale="en">
<#compress>
	<#if rangeValue?has_content>
		<#escape x as x?html>
			<#if rangeValue.lower.value?has_content>
				${rangeValue.lower.qualifier!}<@number rangeValue.lower.value/>
			</#if>
			<#if rangeValue.lower.value?has_content && rangeValue.upper.value?has_content>-</#if>
			<#if rangeValue.upper.value?has_content>
				${rangeValue.upper.qualifier!}<@number rangeValue.upper.value/>
			</#if>
		</#escape>
		<#if rangeValue.unit?has_content>
			<@picklist rangeValue.unit locale/>
		</#if>
  	</#if>
</#compress>
</#macro>


<#macro quantity quantityValue locale="en">
<#compress>
	<#if quantityValue?has_content>
		<@number quantityValue.value!/>
		<#if quantityValue.value?has_content && quantityValue.unit?has_content>
			<@picklist quantityValue.unit locale/>
		</#if>
  	</#if>
</#compress>
</#macro>

<#macro inventoryECNumber inventoryBlock>
<#compress>
	<#if inventoryBlock?has_content>
		<#list inventoryBlock as item>
			<#if item.inventoryCode == 'EC'>
				<@com.text item.numberInInventory/>
				<#break>
			</#if>
		</#list>
	</#if>
</#compress>
</#macro>

<#macro inventoryECCasNumber inventoryBlock>
	<#compress>
		<#if inventoryBlock?has_content>
			<#list inventoryBlock as item>
				<#if item.inventoryCode == 'EC'>
					<@iuclid.inventory entry=item var="inventoryEntry" />
					<#if inventoryEntry??>
						<@com.text inventoryEntry.casNumber/>
					</#if>
					<#break>
				</#if>
			</#list>
		</#if>
	</#compress>
</#macro>

<#function picklistValueMatchesPhrases picklistValue phrases locale="en">
	<#if !(picklistValue?has_content)>
		<#return false />
	</#if>
    <#if picklistValue.code?has_content>
        <#local picklistPhrase = iuclid.localizedPhraseDefinitionFor(picklistValue.code, locale) />
    <#else>
        <#return false />
    </#if>
    <#list phrases as phrase>
        <#if picklistPhrase.text?matches(phrase)>
            <#return true />
        </#if>
    </#list>
    <#return false />
</#function>

<#function picklistMultipleValueMatchesPhrases picklistMultipleValue phrases locale="en">
	<#if !(picklistMultipleValue?has_content)>
		<#return false />
	</#if>
	<#list picklistMultipleValue as item>
		<#if picklistValueMatchesPhrases(item, phrases, locale)>
			<#return true />
		</#if>
	</#list>
	<#return false />
</#function>

<#function isPicklistEmptyOrOther picklistValue>
	<#if !(picklistValue?has_content)>
		<#return true />
	</#if>
	<#if picklistValueMatchesPhrases(picklistValue, ["other:"])>
		<#return true />
	</#if>
	<#return false />
</#function>

<#macro emptyLine>
	<para>&#x200B;</para>
</#macro>


<#function addDocumentToSequenceAsUnique document sequence>
	<#if !(document?has_content)>
		<#return sequence>
	</#if>
	<#list sequence as doc>
		<#if document.documentKey == doc.documentKey>
			<#return sequence>
		</#if>
	</#list>
	<#return sequence + [document]>
</#function>

<#function getReportSubject rootDocument>
	<#if rootDocument.documentType == 'DOSSIER'>
		<#local dossierSubject = iuclid.getDocumentForKey(rootDocument.subjectKey) />
		<#return dossierSubject>
	</#if>
	<#return rootDocument>
</#function>

<#function getDossierHeader rootDocument>
	<#if rootDocument.documentType == 'DOSSIER'>
		<#return rootDocument>
	</#if>
	<#-- else, return nothing -->
</#function>

<#macro metadataBlock left_header_text="" central_header_text="" right_header_text="" left_footer_text="" central_footer_text="" right_footer_text="">
<#escape x as x?html>
<meta:params xmlns:meta="http://echa.europa.eu/schemas/reporting/metadata">
	<meta:param meta:name="left.header.text">${left_header_text}</meta:param>
	<meta:param meta:name="central.header.text">${central_header_text}</meta:param>
	<meta:param meta:name="right.header.text">${right_header_text}</meta:param>
	<meta:param meta:name="left.footer.text">${getLeftFooterText(left_footer_text)}</meta:param>
	<meta:param meta:name="central.footer.text">${central_footer_text}</meta:param>
	<meta:param meta:name="right.footer.text">${right_footer_text}</meta:param>
</meta:params>
</#escape>
</#macro>

<#function getLeftFooterText left_footer_text>
	<#if left_footer_text?has_content>
		<#return left_footer_text>
	</#if>
	<#local default_left_footer_text_date = .now?string[" dd/MM/yyyy "] />
	<#local default_left_footer_text_version = " Generated by IUCLID 6 " + iuclid6Version />
	<#return default_left_footer_text_version + default_left_footer_text_date>
</#function>

<#function countIf sequence predicate>
	<#local counter = 0 />
	<#list sequence as item>
		<#if predicate(item)>
			<#local counter = counter + 1 />
		</#if>
	</#list>
	<#return counter>
</#function>

<#function relatedCategories substanceKey>
    <#local params={"key": [substanceKey]}>
    <#return iuclid.query("iuclid6.SubstanceRelatedCategories", params, 0, 100)>
</#function>

<#function inboundReferences key>
    <#local params={"key": [key]}>
    <#return iuclid.query("web.ReferencingQuery", params, 0, 100)>
</#function>
