<?xml version="1.0" encoding="UTF-8"?>
 
<#-- Import common macros and functions -->
<#import "common_module_traversal_utils.ftl" as utils>
<#import "macros_common_general.ftl" as com>
<#import "front_page_list_reports.ftl" as fp>
<#import "new_ext_lit_ref_report_docbook_utils.ftl" as additionalUtils>

<#-- Initialize common variables -->
<@com.initializeMainVariables/>

<#assign locale = "en" />
<#assign sysDateTime = .now>

<#-- Root entity -->
<#assign rootEntity = entity.root>

<#-- Define the main macro and the arguments to be used to get output using the traversal approach -->
<#assign mainMacroName = "addLiteratureReferencesForDocument"/>
<#assign mainMacroArgs = ['sectionDoc', 'sectionNode', 'entityDocument', 'level']/>

<#-- Make global the macroCall as well as each macro used in it -->
<#global mainMacroCall="<@" + mainMacroName + " " + mainMacroArgs?join(" ") + "/>"/>
<#global addLiteratureReferencesForDocument=addLiteratureReferencesForDocument/>

<#-- Initialize hash to store literature references information (input to table) -->
<#assign litRefsHash = {}/>

<book version="5.0" xmlns="http://docbook.org/ns/docbook" xmlns:xi="http://www.w3.org/2001/XInclude">
	<#-- Get front page -->
	<@fp.getFrontPage _subject _dossierHeader "List of Literature References"/>

	<#-- Chapters -->
	<chapter label="1">
		<title role="HEAD-1">List of Literature References</title>

		<#-- Do the traverse -->
		<@utils.traversal rootEntity 8/>
		
		<#-- Print output -->
		<@tableOutput litRefsHash/>

	</chapter>
</book>

<#----------------------------------------------->
<#-- Macro and function definitions start here -->
<#----------------------------------------------->
<#macro addLiteratureReferencesForDocument sectionDoc sectionNode entityDocument level>

	<#if level==0>

		<#-- get the list of references: it's a list of lists, where the first element is the literature
		reference and the second the data protection claimed, which can be a picklist value, "N/A", or empty
		-->
  		<#assign listOfReferences = getReferencedLitRefEntitiesFromDoc(sectionDoc) >
    	<#if listOfReferences?has_content>
      		<#list listOfReferences as literatureReferenceDpList>
				<#local literatureReference=literatureReferenceDpList[0]/>
				<#local dataPr=literatureReferenceDpList[1]/>

				<#if literatureReference?has_content>

					<#-- Get the section name: Section + Endpoint -->
					<#local sectionName = "" />
					<#if sectionNode?has_content>
						<#if sectionNode.number?has_content>
							<#local sectionName = sectionNode.number + " ">
						</#if>
						<#local sectionName = sectionName + sectionNode.title>
					</#if>

					<#-- Endpoint: add to section name -->
					<#if sectionDoc.hasElement("AdministrativeData.Endpoint") && sectionDoc.AdministrativeData.Endpoint?has_content>
						<#local endpoint><@com.picklist picklistValue=sectionDoc.AdministrativeData.Endpoint printDescription=false printRemarks=false/></#local>
						<#local sectionName = sectionName + " (" + endpoint + ")" />
					</#if>

					<#-- Add to hash -->
					<#assign litRefsHash = addStudyToHash(litRefsHash, literatureReference, sectionDoc, sectionName, dataPr, entityDocument)/>
        		</#if>
      		</#list>
    	</#if>
    </#if>
</#macro>

<#-- This function retrieves all the literature references from a document -->
<#function getReferencedLitRefEntitiesFromDoc docElementNode>
	<#local listOfLiteratureReferences = [] />

	<#if docElementNode?node_type == "document_reference">
		<#local listOfLiteratureReferences = checkAndAddLiteraturReferenceWithDP(docElementNode, docElementNode, listOfLiteratureReferences) />
		<#return listOfLiteratureReferences />
	</#if>

	<#if docElementNode?node_type == "document_references">
		<#list docElementNode as item>
			<#local listOfLiteratureReferences = checkAndAddLiteraturReferenceWithDP(item, docElementNode, listOfLiteratureReferences) />
		</#list>
		<#return listOfLiteratureReferences />
	</#if>

	<#if docElementNode?children?has_content>
		<#list docElementNode?children as child>
			<#local listOfLiteratureReferences = listOfLiteratureReferences + getReferencedLitRefEntitiesFromDoc(child)  />
		</#list>
	</#if>
	<#return listOfLiteratureReferences/>
</#function>


<#-- This function is a new version of the one above, in order to include both the lit reference and data protection claim -->
<#function checkAndAddLiteraturReferenceWithDP docKey docNode listOfReferencedEntities>
	<#local doc = iuclid.getDocumentForKey(docKey) />
	<#if doc?has_content && doc.documentType == "LITERATURE">
		<#list listOfReferencedEntities as docDpList>
			<#local document=docDpList[0]/>
			<#if document.documentKey == doc.documentKey>
				<#return listOfReferencedEntities>
			</#if>
		</#list>

		<#-- get DP -->
		<#local dataProt=""/>
		<#local docKeyParents=docNode?ancestors/>
		<#if docKeyParents?has_content>
			<#local docKeyParent = docKeyParents[0]/>
			<#if docKeyParent.hasElement("DataProtectionClaimed")>
				<#local dataProt=docKeyParent.DataProtectionClaimed/>
			<#else>
				<#local dataProt="N/A"/>
			</#if>
		</#if>

		<#-- add -->
		<#local newLitEntry = [doc, dataProt]/>
		<#return listOfReferencedEntities + [newLitEntry]>
	</#if>
	<#return listOfReferencedEntities>
</#function>

<#-- This function appends a reference and a study into a pre-defined hashMap -->
<#function addStudyToHash hash reference document section datapr entity>

	<#local uuid = reference.documentKey.uuid/>
	<#local author><@com.text reference.GeneralInfo.Author/></#local>
	<#local hashKey = author + "-" + uuid/>

	<#-- if reference exists, add new document to its hash entry; else create a new entry-->
	<#if hash?keys?seq_contains(hashKey)>

		<#local hashEntry = hash[hashKey]/>
		<#local sects = hashEntry['sections']/>

		<#if sects?keys?seq_contains(section)>
			<#local docs = sects[section]['docs']/>
			<#local dps = sects[section]['dps']/>
			<#local ents = sects[section]['ents']/>

			<#local docs = docs + [document]/>
			<#local dps = dps + [datapr]/>
			<#local ents = ents + [entity]/>

			<#local sect = {section:{'docs':docs, 'dps': dps, 'ents': ents}}/>
		<#else>
			<#local sect = {section:{'docs': [document], 'dps' : [datapr], 'ents': [entity]}}/>
		</#if>

		<#local sects = sects + sect>

	<#else>

		<#local sects= {section: {'docs': [document], 'dps': [datapr], 'ents':[entity]}}/>

	</#if>

	<#local hashEntry = { hashKey : {'reference': reference, 'sections': sects}}/>
	<#local hash = hash + hashEntry/>

	<#return hash/>

</#function>

<#-- Table format for the literature references -->
<#macro tableOutput hash>
	<#-- final table output -->
	<para role="small">
	<table border="1">
        <title>Table of Literature References</title>
          
          <#if pppRelevant??>
	          <col width="8%" />
	          <col width="4%" />
	          <col width="26%" />
	          <col width="8%"/>
	          <col width="12%" />
	          <col width="12%" />
	          <col width="8%" />
	          <col width="11%" />
	          <col width="11%" />		
          <#else>
      		  <col width="9%" />
	          <col width="5%" />
	          <col width="30%" />
	          <col width="9%"/>
	          <col width="14%" />
	          <col width="14%" />
	          <col width="8%" />
	          <col width="11%" />
          </#if>
          	
          <tbody>
			<tr valign='middle' align='center'>		
              <th colspan="1"><?dbfo bgcolor="#d6eaf8" ?><emphasis role="bold">Author(s)</emphasis></th>
              <th colspan="1"><?dbfo bgcolor="#d6eaf8" ?><emphasis role="bold">Year</emphasis></th>
	          <th colspan="1"><?dbfo bgcolor="#d6eaf8" ?><emphasis role="bold">Title<?linebreak?>
	          																   Reference type<?linebreak?>
              																   Report and/or Study No.<?linebreak?>
              																   Source or Testing facility, if different from Sponsor
              											</emphasis>
              </th>
	          <th colspan="1"><?dbfo bgcolor="#d6eaf8" ?><emphasis role="bold">Study sponsor</emphasis></th>
              <th colspan="1"><?dbfo bgcolor="#d6eaf8" ?><emphasis role="bold">IUCLID section (endpoint)</emphasis></th>
              <th colspan="1"><?dbfo bgcolor="#d6eaf8" ?><emphasis role="bold">IUCLID document name</emphasis></th>
	          <th colspan="1"><?dbfo bgcolor="#d6eaf8" ?><emphasis role="bold">GLP</emphasis></th>              	       			
              <th colspan="1"><?dbfo bgcolor="#d6eaf8" ?><emphasis role="bold">Data protection claimed</emphasis></th>	
              <#if pppRelevant??>
              	<th colspan="1"><?dbfo bgcolor="#d6eaf8" ?><emphasis role="bold">Previously used</emphasis></th>
              </#if>
            </tr>

			
		<#if hash?has_content>
				<#--  <#list hash?keys?sort as key>-->
				<#list hash?keys as key>
					<#local value = hash[key]/>
					<#local literatureReference=value['reference']>
							
					<#-- variables to extract field labels -->
					<@iuclid.label for=literatureReference.GeneralInfo.Name var="title"/>
					<@iuclid.label for=literatureReference.GeneralInfo.ReportNo var="reportNo"/>
					<@iuclid.label for=literatureReference.GeneralInfo.CompanyOwnerStudyNo var="studyNo"/>
					<@iuclid.label for=literatureReference.GeneralInfo.Source var="source"/>
					<@iuclid.label for=literatureReference.GeneralInfo.CompanyOwner var="owner"/>
					<@iuclid.label for=literatureReference.GeneralInfo.TestLab var="testingFacility"/>
					<@iuclid.label for=literatureReference.GeneralInfo.LiteratureType var="refType"/>

					<#-- get refSpan and GLP across docs in all sections -->
					<#local useRefSpan=true/>
					<#local refSpan=0/> 
					<#list value['sections'] as section, sectionHash>
						<#local refSpan = refSpan + sectionHash['docs']?size/> 
					</#list>
					 
					<#-- iterate over sections -->
					<#list value['sections'] as sectionName, sectionHash>
						
						<#local docs = sectionHash['docs']/>
						<#local dps = sectionHash['dps']/>
						<#local ents = sectionHash['ents']/> 
						 
						<#local sectSpan=docs?size/>
						<#local useSectSpan=true/>
					
						<#list docs as sectionDoc>
					 
							<#local dataProtection = dps[sectionDoc?index]/>
							<#local entityDoc = ents[sectionDoc?index]/> 

						 	<tr>      

							 	<#if useRefSpan>
							 	
									<#local refUrl=utils.getDocumentUrl(literatureReference) />

								    <#-- Author -->									
								    <td rowspan="${refSpan}">
								    	<#if literatureReference.GeneralInfo.Author?has_content>
						      				<@com.text literatureReference.GeneralInfo.Author />	
						      			<#else>
						          			<emphasis>No author provided</emphasis>
						      			</#if>
								    </td>
								  
								    <#-- Year -->				
								    <td rowspan="${refSpan}"> 
								      <#if literatureReference.GeneralInfo.ReferenceYear?has_content>
								      	<@com.number literatureReference.GeneralInfo.ReferenceYear />		
								      <#else>
								          <emphasis>No year provided</emphasis>
								      </#if>
								    </td>
								    
								    <#-- Title, report no, source, type -->
								    <#local sourceVal = literatureReference.GeneralInfo.Source />
								    <#local ownerVal = literatureReference.GeneralInfo.CompanyOwner />
								    <#local testingFacilityVal =literatureReference.GeneralInfo.TestLab/>
						    
								    <td rowspan="${refSpan}">   
								    	<ulink url="${refUrl}">
								      		<#if literatureReference.GeneralInfo.Name?has_content>
						          				<@com.text literatureReference.GeneralInfo.Name/> 	
					        				<#else>
						        				<emphasis><@com.text title/> not provided</emphasis>
						      				</#if>
								      	</ulink> 
								      	
								      	<#-- Reference type -->
								      	<para>		    
								      		<#if literatureReference.GeneralInfo.LiteratureType?has_content>
									      		<#local litType><@com.picklist literatureReference.GeneralInfo.LiteratureType /></#local>
									      		${litType?cap_first}
									      	<#else>
									      		<emphasis>Reference type not provided</emphasis>
									      	</#if>	
								      	</para>
								      				
								      	<#-- Report and Study No -->		    
								    	<para>
										    <#if literatureReference.GeneralInfo.ReportNo?has_content || literatureReference.GeneralInfo.CompanyOwnerStudyNo?has_content>
										      	<#if literatureReference.GeneralInfo.ReportNo?has_content>
										      		Report No.: <@com.text literatureReference.GeneralInfo.ReportNo/>
										      	</#if>
										      	
										      	<#if literatureReference.GeneralInfo.CompanyOwnerStudyNo?has_content>
										      		<#if literatureReference.GeneralInfo.ReportNo?has_content>;</#if>
								          			Study No.: <@com.text literatureReference.GeneralInfo.CompanyOwnerStudyNo/>
								          		</#if>
								          	<#else>
										        <emphasis>Report and Study No. not provided</emphasis>
										    </#if>
										</para>
										
						      			<#-- Source and test facility -->
									  	<para>
										  	<#if sourceVal?has_content || testingFacilityVal?has_content>
										  		<#if sourceVal?has_content && sourceVal!=ownerVal && sourceVal!=testingFacilityVal>
										        	<@com.text sourceVal/>	
										        </#if>
										        <#if testingFacilityVal?has_content && testingFacilityVal!=ownerVal>
										        	<#if sourceVal?has_content && sourceVal!=ownerVal && sourceVal!=testingFacilityVal>;</#if>
										        	<@com.text testingFacilityVal/>	
										        </#if>
									      	<#else>
									      		<emphasis>Source and/or Testing facility not provided</emphasis>  
										  	</#if>
									  	</para>
							  				  
								    </td>	

						 			<#-- Study sponsor -->				
								    <td rowspan="${refSpan}"> 
								     	<#if ownerVal?has_content>
								          <@com.text ownerVal/> 	
								        <#else>
								          <emphasis>Study sponsor not provided</emphasis>
								      	</#if>
								    </td>
	
								    <#local useRefSpan=false/>
							    </#if>
							    
							    <#-- IUCLID Section name and number-->  
								<#if useSectSpan>
								    <td rowspan="${sectSpan}">
								      <@com.text sectionName />
								    </td>
								    
								    <#local useSectSpan=false/>
								</#if> 
							    
							    <#-- IUCLID document name -->
							    <#local docUrl=utils.getDocumentUrl(sectionDoc) />
							    <td> 
							        <ulink url="${docUrl}">
							          <@com.text sectionDoc.name />
							        </ulink> 
							    </td>
							    
							    <#-- GLP -->
							    <td>
								    <#if sectionDoc.hasElement("MaterialsAndMethods.GLPComplianceStatement") && sectionDoc.MaterialsAndMethods.GLPComplianceStatement?has_content>
								      <@com.picklist sectionDoc.MaterialsAndMethods.GLPComplianceStatement />
								    <#else>
								    	GLP information not provided
								    </#if> 
							    </td>
						    
								 
								<#-- Data protection claimed -->
						    	<td> 
							    	<#if dataProtection?has_content && !(dataProtection?is_string) >
							    		<@com.picklist dataProtection/>
									<#elseif dataProtection?has_content>
										${dataProtection}
									<#else>
										no
							    	</#if> 
							    </td>
							    
					    		<#-- Previously used (Change Log) --> 
					    		<#if pppRelevant??>
								    <td>    
									    <#local changeLogStatus=getChangeLogStatus(sectionDoc, entityDoc)/>
										${changeLogStatus}  
									</td>
								</#if>

							</tr>
						</#list>
					</#list>
				</#list>
			</#if>
		</tbody>
		
	</table>
	</para>
</#macro>

<#-- This function checks if the document exists in the change log and retrieves the status -->
<#function getChangeLogStatus study entity>
	<#local changeLogFlag="no"/>

	<#local changeLogEntryList=[]/>

	<#local changeLogs = iuclid.getSectionDocumentsForParentKey(entity.documentKey, "FLEXIBLE_RECORD", "ChangeLog") />
	<#list changeLogs as changeLog>
		<#list changeLog.ChangeLog.ChangeLogEntries as changeLogEntry>
			<#local changeLogDoc=iuclid.getDocumentForKey(changeLogEntry.LinkToDocument)/>

			<#if changeLogDoc?has_content>
				<#if study.documentKey.uuid==changeLogDoc.documentKey.uuid>
					<#local changeLogStatus><@com.picklist changeLogEntry.Status/></#local>
					<#if changeLogStatus?has_content>
						<#if !(changeLogStatus?starts_with("new"))>
							<#local changeLogFlag="yes"/>
						</#if>
						<#-- <#local changeLogStatusList = changeLogStatusList + [changeLogStatus]/> -->
						<#local changeLogEntryList = changeLogEntryList + [changeLogEntry]/>
					</#if>
				</#if>
			</#if>
		</#list>
	</#list>

	<#local changeLogStatusMessage>${changeLogFlag}
		<#if changeLogEntryList?has_content>
			<#list changeLogEntryList as clEntry>
				(<@com.picklist clEntry.Status/>)<#if clEntry.Remark?has_content> - <@com.text clEntry.Remark/></#if>
				<#if clEntry?has_next>|</#if>
			</#list>
		</#if>
	</#local>

	<#return changeLogStatusMessage>
</#function>