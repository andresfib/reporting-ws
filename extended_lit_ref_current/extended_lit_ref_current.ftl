sep=,
<#compress> 
<#-- Literature reference report for substances and mixtures with CSV output -->
<#-- Import common macros and functions -->
<#import "../../application/docbook+xmlas/macros_common.ftl" as com>
<#-- Include utilities for the list of relevant endpoint records containing literature references -->
<#include "literature_reference_utilities_csv.ftl" />
<#assign substance = com.getReportSubject(rootDocument) />
<#assign mixture = com.getReportSubject(rootDocument) />
<#-- Print the headears for each column -->
Type,Section number,Section name,Document name,Document UUID,<#if substance.documentType=="SUBSTANCE">CAS number (from reference substance in substance 1.1),</#if>Robust study summary,Adequacy of study,Study period,Data waiving,Data waiving justification,Type of information,Reliability,Data access,Guideline (materials and methods),GLP compliant,Test material information name (and CAS number of test material),Species / test organism,Strain / cell type,Route of application / dose method,Exposure duration,Metabolic activation,Metabolic activation system,Study outcome (dose descriptor),Study outcome (value/result),Reference type,Title,Author,Bibliographic source,Year,Testing Laboratory,Report number,Company owner,Company study number,Report date,Remarks,Confidentiality claim on endpoint,Regulatory programme(s)<#if rootDocument.documentType=="MIXTURE">,BPR Annex II/III requirements</#if>
<#compress>					
	<#if substance.documentType=="SUBSTANCE">
	
		<#-- Substance derived Literature References -->					
		<#list substanceLiteratureReferenceList as dataSourceIdentifier>
		<#assign documentList = iuclid.getSectionDocumentsForParentKey(substance.documentKey, dataSourceIdentifier.docType, dataSourceIdentifier.docSubType) />			
			<#list documentList as document>
				<#if document?has_content>
				<#list document.DataSource.Reference as referenceItem>
					<#if referenceItem?has_content>				
					<@tableRowForLiteratureReference document referenceItem dataSourceIdentifier "Substance" document.name document.documentKey.uuid document.documentKey.snapshotUuid substance.documentKey.uuid/><#if referenceItem_has_next>; </#if>
					</#if>								
				</#list>
				</#if>
			</#list>
		</#list>
	</#if>
		
	<#if mixture.documentType=="MIXTURE">
	
		<#-- Biocidal Product derived Literature References -->							
		<#list mixtureLiteratureReferenceList as dataSourceIdentifier>
		<#assign documentList = iuclid.getSectionDocumentsForParentKey(mixture.documentKey, dataSourceIdentifier.docType, dataSourceIdentifier.docSubType) />
			<#list documentList as document>
				<#if document?has_content>
					<#list document.DataSource.Reference as referenceItem>
						<#if referenceItem?has_content>
							<@tableRowForLiteratureReference document referenceItem dataSourceIdentifier "Biocidal product" document.name document.documentKey.uuid document.documentKey.snapshotUuid mixture.documentKey.uuid/><#if referenceItem_has_next>; </#if>											
						</#if>
					</#list>
				</#if>
			</#list>							
		</#list>
	
		<#-- Literature References in the active substances linked to a mixture -->
		<#assign activeSubstanceList = getActiveSubstanceList(mixture) />
	
		<#list activeSubstanceList as substance>
			<#if substance?has_content>
				<#list substanceOfMixtureReferenceList as dataSourceIdentifier>
					<#if dataSourceIdentifier?has_content>
					<#assign documentList = iuclid.getSectionDocumentsForParentKey(substance.documentKey, dataSourceIdentifier.docType, dataSourceIdentifier.docSubType) />
						<#list documentList as document>
							<#if document?has_content>
								<#list document.DataSource.Reference as referenceItem>
									<#if referenceItem?has_content>											
										<@tableRowForLiteratureReference document referenceItem dataSourceIdentifier "Active Substance" document.name document.documentKey.uuid document.documentKey.snapshotUuid substance.documentKey.uuid/><#if referenceItem_has_next>; </#if>						
									</#if>									
								</#list>
							</#if>
						</#list>
					</#if>
				</#list>
			</#if>
		</#list>	
					
		<#-- Literature References in other substances linked to a mixture -->
		<#assign otherSubstanceList = getOtherSubstanceList(mixture) />
		
		<#list otherSubstanceList as substance>	
			<#if substance?has_content>
				<#list substanceOfMixtureReferenceList as dataSourceIdentifier>
					<#if dataSourceIdentifier?has_content>
						<#assign documentList = iuclid.getSectionDocumentsForParentKey(substance.documentKey, dataSourceIdentifier.docType, dataSourceIdentifier.docSubType) />
						<#list documentList as document>
							<#if document?has_content>
								<#list document.DataSource.Reference as referenceItem>
									<#if referenceItem?has_content>											
										<@tableRowForLiteratureReference document referenceItem dataSourceIdentifier "Other Substance" document.name document.documentKey.uuid document.documentKey.snapshotUuid substance.documentKey.uuid/><#if referenceItem_has_next>; </#if>						
									</#if>									
								</#list>
							</#if>
						</#list>
					</#if>
				</#list>
			</#if>
		</#list>
		
	</#if>
</#compress>
<#-- Macros and functions -->
<#-- table for Literature References for both substances and mixtures -->					
<#compress>
<#macro tableRowForLiteratureReference document referenceItem dataSourceIdentifier type="" documentName="" documentUUID="" dossierUUID="" rootUUID="">
<#compress>
<#if referenceItem?has_content && dataSourceIdentifier?has_content>
<#assign dataSource = iuclid.getDocumentForKey(referenceItem)/>
<#assign adequacy><@com.picklist document.AdministrativeData.PurposeFlag /></#assign>
<#assign studyPeriod><@com.text document.AdministrativeData.StudyPeriod /></#assign>
<#assign dataWaivingJustification><@com.picklistMultiple document.AdministrativeData.DataWaivingJustification /></#assign>
<#assign typeOfInformation><@com.picklist document.AdministrativeData.StudyResultType /></#assign>
<#assign literatureType><@com.picklist dataSource.GeneralInfo.LiteratureType /></#assign>
<#assign reliability><@com.picklist document.AdministrativeData.Reliability /></#assign>
<#assign dataAccess><@com.picklist document.DataSource.DataAccess /></#assign>
<#assign confidentialityFlagPath = "document." + "AdministrativeData.DataProtection" + ".confidentiality" />
<#assign confidentialityFlag = confidentialityFlagPath?eval />
<#assign regulatoryPath = "document." + "AdministrativeData.DataProtection" + ".legislations" />
<#assign regulation = regulatoryPath?eval />
<#assign regulatoryProgrammes><@com.picklistMultiple regulation /></#assign>
<#assign robust = document.AdministrativeData.RobustStudy />
			
<#if dataSource?has_content>
<#compress>
<@com.text type />,<@com.text dataSourceIdentifier.sectionNr />,<@compress single_line=true>${dataSourceIdentifier.sectionName?replace(",","")}</@compress>,<@compress single_line=true>${documentName?replace(",","")}</@compress>,<@compress single_line=true><#assign docUrl=iuclid.webUrl.documentView(document.documentKey) /><#if docUrl?has_content>"=HYPERLINK(""${docUrl}"", ""<@com.text documentUUID />"")"<#else>${documentUUID?replace(",","")}</#if></@compress>,<#if substance.documentType=="SUBSTANCE"><@compress single_line=true><@CASNumber substance/></@compress>,</#if><#if robust>yes<#else>no</#if>,${adequacy?replace(",","")},${studyPeriod?replace(",","")},<@com.picklist document.AdministrativeData.DataWaiving />,<@compress single_line=true>${dataWaivingJustification?replace(",","")}</@compress>,${typeOfInformation?replace(",","")},${reliability?replace(",","")},${dataAccess?replace(",","")},<@compress single_line=true><@guidelines document /></@compress>,<@glpCompliance document />,<@compress single_line=true><@testMaterialInformation document /></@compress>,<@speciesInfo document />,<@strainInfo document />,<@routeOfAdministrationOrDose document />,<@exposureDuration document />,<@metabolicActivation document />,<@metabolicActivationSystem document />,<@doserDescriptorInformation document />,<@valueOfResult document />,<#if literatureType?has_content>${literatureType?replace(",","")}<#else/>No reference type provided</#if>,<#if dataSource.GeneralInfo.Name?has_content>${dataSource.GeneralInfo.Name?replace(",","")}<#else/>No title provided</#if>,<@compress single_line=true><#if dataSource.GeneralInfo.Author?has_content>${dataSource.GeneralInfo.Author?replace(",","")}<#else/>No author provided</#if></@compress>,<@compress single_line=true><#if dataSource.GeneralInfo.Source?has_content>${dataSource.GeneralInfo.Source?replace(",","")}<#else/>No bibliographic source provided</#if></@compress>,<#if dataSource.GeneralInfo.ReferenceYear?has_content>${dataSource.GeneralInfo.ReferenceYear?replace(",","")}<#else/>No year provided</#if>,<#if dataSource.GeneralInfo.TestLab?has_content>${dataSource.GeneralInfo.TestLab?replace(",","")}<#else/>No testing laboratory provided</#if>,<#if dataSource.GeneralInfo.ReportNo?has_content>${dataSource.GeneralInfo.ReportNo?replace(",","")}<#else/>No report number provided</#if>,<#if dataSource.GeneralInfo.CompanyOwner?has_content>${dataSource.GeneralInfo.CompanyOwner?replace(",","")}<#else/>No company owner provided</#if>,<#if dataSource.GeneralInfo.CompanyOwnerStudyNo?has_content>${dataSource.GeneralInfo.CompanyOwnerStudyNo?replace(",","")}<#else/>No company study number provided</#if>,<#if dataSource.GeneralInfo.ReportDate?has_content>${dataSource.GeneralInfo.ReportDate?replace(",","")}<#else/>No report date provided</#if>,<#if dataSource.GeneralInfo.Remarks?has_content>${dataSource.GeneralInfo.Remarks?replace(",","")}<#else/>no remarks in the literature reference</#if>,<#if confidentialityFlag?has_content>endpoint is flagged confidential<#else/>endpoint is not flagged confidential</#if>,<#if regulation?has_content><@compress single_line=true>${regulatoryProgrammes?replace(",","")}</@compress></#if><#if rootDocument.documentType=="MIXTURE">,<@com.text dataSourceIdentifier.AnnexIIIrequirements /></#if>
</#compress>	
</#if>

</#if>
</#compress>
</#macro>
</#compress>

<#macro speciesInfo document>
<@compress single_line=true>
<#if document?has_content>	

	<#local docDefId = document.documentType +"."+ document.documentSubType />
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion" || docDefId=="ENDPOINT_STUDY_RECORD.EyeIrritation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther" || docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo" || docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction" || docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.BasicToxicokinetics">

		<#local species><@com.picklist document.MaterialsAndMethods.TestAnimals.Species /></#local>
		${species?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
	
	<#local speciesEcoTox><@com.picklist document.MaterialsAndMethods.TestOrganisms.TestOrganismsSpecies /></#local>
		${speciesEcoTox?replace(",","")}
		<#else>
	</#if>	
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" >
	<#if document.MaterialsAndMethods.TestOrganisms.TestOrganisms?has_content>
		<#list document.MaterialsAndMethods.TestOrganisms.TestOrganisms as testorganisms>			
			<#if testorganisms.Species?has_content>
			<#local speciesTestOrganisms><@com.picklist testorganisms.Species /></#local>
				${speciesTestOrganisms?replace(",","")}<#if testorganisms_has_next>; </#if>
				<#else>
			</#if>
		</#list>
	</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms">
	<#local speciesSoilMicroorganism><@com.picklist document.MaterialsAndMethods.TestOrganisms.TestOrganismsInoculum /></#local>
		${speciesSoilMicroorganism?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinSensitisation">
	<#local speciesSkinSensitisation><@com.picklist document.MaterialsAndMethods.InVivoTestSystem.TestAnimals.Species /></#local>
		${speciesSkinSensitisation?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local speciesAndStrainGeneticVitro = document.MaterialsAndMethods.Method.SpeciesStrain/>
		<#if speciesAndStrainGeneticVitro?has_content>
			<#list speciesAndStrainGeneticVitro as speciesAndStrain>			
			
				<#local speciesAndStrainVitro><@com.picklist speciesAndStrain.SpeciesStrain /></#local>
				<#if speciesAndStrainVitro?has_content>
				species / strain: ${speciesAndStrainVitro?replace(",","")}<#if speciesAndStrain_has_next>; </#if>
					<#else>
				</#if>
			</#list>
		</#if>
	</#if>

</#if>
</@compress>
</#macro>

<#macro strainInfo document>
<@compress single_line=true>
<#if document?has_content>
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion" || docDefId=="ENDPOINT_STUDY_RECORD.EyeIrritation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther" || docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo" || docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction" || docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.BasicToxicokinetics">

		<#local strain><@com.picklist document.MaterialsAndMethods.TestAnimals.Strain /></#local>
		${strain?replace(",","")}
		<#else>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinSensitisation">
	<#local strainSkinSensitisation><@com.picklist document.MaterialsAndMethods.InVivoTestSystem.TestAnimals.Strain /></#local>
		${strainSkinSensitisation?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local speciesAndStrainGeneticVitro = document.MaterialsAndMethods.Method.SpeciesStrain/>
		<#if speciesAndStrainGeneticVitro?has_content>
			<#list speciesAndStrainGeneticVitro as speciesAndStrain>			
			
				<#local speciesAndStrainVitro><@com.picklist speciesAndStrain.SpeciesStrain /></#local>
				<#if speciesAndStrainVitro?has_content>
				species / strain: ${speciesAndStrainVitro?replace(",","")}<#if speciesAndStrain_has_next>; </#if>
					<#else>
				</#if>
			</#list>
		</#if>
	</#if>
	
</#if>
</@compress>
</#macro>

<#macro valueOfResult document>
<@compress single_line=true>
<#if document?has_content>

	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms">
		
		<#local effectConcentration = document.ResultsAndDiscussion.EffectConcentrations />
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectConc /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity">
		<#local effectConcentration = document.ResultsAndDiscussion.ResultsFetuses.EffectLevelsFetuses.Efflevel/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction">
		<#local effectConcentration = document.ResultsAndDiscussion.ResultsOfExaminationsParentalGeneration.EffectLevelsP0.Efflevel/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if> 
	 
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local effectConcentration = document.ResultsAndDiscussion.TestRs/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.picklist effectConcentrations.Genotoxicity /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo">
		<#local effectConcentration = document.ResultsAndDiscussion.TestRs/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.picklist effectConcentrations.Genotoxicity /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity">
		<#local effectConcentration = document.ResultsAndDiscussion.EffectLevels.Efflevel/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>	
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther">
	
	<#local effectConcentration = document.ResultsAndDiscussion.EffectLevels.Efflevel />
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
	
	<#local effectConcentration = document.ResultsAndDiscussion.EffectLevels />
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
	
</#if>
</@compress>
</#macro>

<#macro doserDescriptorInformation document>
<@compress single_line=true>
<#if document?has_content>

	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms">
		
		<#local doseDescriptor = document.ResultsAndDiscussion.EffectConcentrations />
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity">
		<#local doseDescriptor = document.ResultsAndDiscussion.ResultsFetuses.EffectLevelsFetuses.Efflevel/>
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if> 
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction">
		<#local doseDescriptor = document.ResultsAndDiscussion.ResultsOfExaminationsParentalGeneration.EffectLevelsP0.Efflevel/>
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity">
		<#local doseDescriptor = document.ResultsAndDiscussion.EffectLevels.Efflevel/>
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>	
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther">
	
	<#local doseDescriptor = document.ResultsAndDiscussion.EffectLevels.Efflevel />
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
	
	<#local doseDescriptor = document.ResultsAndDiscussion.EffectLevels />
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion" || docDefId=="ENDPOINT_STUDY_RECORD.EyeIrritation" || docDefId=="ENDPOINT_STUDY_RECORD.SkinSensitisation">
	
	<#if document.ApplicantSummaryAndConclusion.InterpretationOfResults?has_content>
		<#local doseDescriptorsItem><@com.picklist document.ApplicantSummaryAndConclusion.InterpretationOfResults /></#local>
			${doseDescriptorsItem?replace(",","")}
		<#else>
	</#if>
	</#if>
	
</#if>
</@compress>
</#macro>

<#macro routeOfAdministrationOrDose document>
<@compress single_line=true>
<#if document?has_content>

	<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
		<#local toxicityToBirdsDose><@com.picklist document.MaterialsAndMethods.TestMaterials.DoseMethod /></#local>
		${toxicityToBirdsDose?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity">
	
	<#local testType><@com.picklist document.MaterialsAndMethods.StudyDesign.TestType /></#local>
		${testType?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods">
		<#local routeOfAdministration><@com.picklist document.MaterialsAndMethods.StudyDesign.StudyType /></#local>
		${routeOfAdministration?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.BasicToxicokinetics" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo" || docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction" || docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation">
		<#local routeOfAdministration><@com.picklist document.MaterialsAndMethods.AdministrationExposure.RouteOfAdministration /></#local>
		${routeOfAdministration?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal">
		<#local routeOfAdministration><@com.picklist document.MaterialsAndMethods.AdministrationExposure.TypeOfCoverage /></#local>
		${routeOfAdministration?replace(",","")}
			<#else>
	</#if>	
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal">
		<#local routeOfAdministration><@com.picklist document.MaterialsAndMethods.AdministrationExposure.TypeOfCoverage /></#local>
		${routeOfAdministration?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion">
		<#local skinIrritation><@com.picklist document.MaterialsAndMethods.TestSystem.TypeOfCoverage /></#local>
		${skinIrritation?replace(",","")}
		<#else>	
	</#if>
	
</#if>
</@compress>
</#macro>

<#macro exposureDuration document>
<@compress single_line=true>
<#if document?has_content>
	
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
		<#local exposureDuration><@com.quantity document.MaterialsAndMethods.StudyDesign.TotalExposureDuration /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction" || docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo">
		<#local exposureDuration><@com.text document.MaterialsAndMethods.AdministrationExposure.DurationOfTreatmentExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion">
		<#local exposureDuration><@com.text document.MaterialsAndMethods.TestSystem.DurationOfTreatmentExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>
			
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal">
		<#local exposureDuration><@com.text document.MaterialsAndMethods.AdministrationExposure.DurationOfExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.BasicToxicokinetics">    
		<#local exposureDuration><@com.text document.MaterialsAndMethods.AdministrationExposure.DurationAndFrequencyOfTreatmentExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>	
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation">
		<#local exposureDuration><@com.quantity document.MaterialsAndMethods.AdministrationExposure.DurationOfExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>	
	
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity">
	<#assign exposureDurationRepeatable = document.MaterialsAndMethods.StudyDesign.ExposureDuration />
		<#if exposureDurationRepeatable?has_content>
			<#list exposureDurationRepeatable as exposure>
			<#if exposure?has_content>
		
			<#local exposureDuration><@com.quantity exposure.TotalExposureDuration /></#local>
			${exposureDuration?replace(",","")}<#if exposure_has_next>; </#if>										
				<#else>
			</#if>	
			
			</#list>
		</#if>
	</#if>
	
	
</#if>
</@compress>
</#macro>

<#macro metabolicActivation document>
<@compress single_line=true>
<#if document?has_content>
	
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local metabActivation><@com.picklist document.MaterialsAndMethods.Method.MetabolicActivation /></#local>
		${metabActivation?replace(",","")}
		<#else>
	</#if>
</#if>
</@compress>
</#macro>

<#macro metabolicActivationSystem document>
<@compress single_line=true>
<#if document?has_content>
	
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local metabActivationSystem><@com.text document.MaterialsAndMethods.Method.MetabolicActivationSystem /></#local>
		${metabActivationSystem?replace(",","")}
		<#else>
	</#if>
</#if>
</@compress>
</#macro>

<#--
<#macro keyResult document>
<@compress single_line=true>
<#if document?has_content>
	
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms" >
		
		<#local results = document.ResultsAndDiscussion.EffectConcentrations />
		<#if results?has_content>
			<@firstKeyResult results />			
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity">
		<#local resultsToxicityDevelopmental = document.ResultsAndDiscussion.ResultsFetuses.EffectLevelsFetuses.Efflevel/>
		<#if resultsToxicityDevelopmental?has_content>
			<@firstKeyResult resultsToxicityDevelopmental />			
		</#if>
	</#if> 
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction">
		<#local resultsToxicityReproduction = document.ResultsAndDiscussion.ResultsOfExaminationsParentalGeneration.EffectLevelsP0.Efflevel/>
		<#if resultsToxicityReproduction?has_content>
			<@firstKeyResult resultsToxicityReproduction />			
		</#if>
	</#if> 
	 
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local resultsGeneticVitro = document.ResultsAndDiscussion.TestRs/>
		<#if resultsGeneticVitro?has_content>
			<@firstKeyResult resultsGeneticVitro />			
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo">
		<#local resultsGeneticVivo = document.ResultsAndDiscussion.TestRs/>
		<#if resultsGeneticVivo?has_content>
			<@firstKeyResult resultsGeneticVivo />			
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity">
		<#local resultsCarcinogenicity = document.ResultsAndDiscussion.EffectLevels.Efflevel/>
		<#if resultsCarcinogenicity?has_content>
			<@firstKeyResult resultsCarcinogenicity />			
		</#if>
	</#if>	
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther">
	
	<#local results = document.ResultsAndDiscussion.EffectLevels.Efflevel />
		<#if results?has_content>
			<@firstKeyResult results />			
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
	
	<#local results = document.ResultsAndDiscussion.EffectLevels />
		<#if results?has_content>
			<@firstKeyResult results />			
		</#if>
	</#if>
	
</#if>
</@compress>
</#macro>
-->

<#-- Macro for CAS number -->
<#macro CASNumber substance>
<#compress>
<#assign substanceId = substance />
	<#if substanceId?has_content>
	<#assign refSubstance = iuclid.getDocumentForKey(substanceId.ReferenceSubstance.ReferenceSubstance)/>
		<#if refSubstance?has_content>
			<@com.text refSubstance.Inventory.CASNumber />			
		</#if>
	</#if>
</#compress>
</#macro>

<#macro guidelines document>
<#compress>
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId!="ENDPOINT_STUDY_RECORD.DistributionModelling">
	<#if docDefId!="ENDPOINT_STUDY_RECORD.EffectivenessAgainstTargetOrganisms">

	<#local guideline = document.MaterialsAndMethods.Guideline />
	
	<#list guideline as guideline>
		<#if guideline.Guideline?has_content>
		<#local guidelineRow><@com.picklist guideline.Guideline /></#local>
			${guidelineRow?replace(",","")}<#if guideline_has_next>; </#if>
		</#if>
	</#list>
	
	</#if>
	</#if>
</#compress>	
</#macro>

<#macro testMaterialInformation document>
<#compress>

	<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId!="ENDPOINT_STUDY_RECORD.DistributionModelling">
	<#if docDefId!="ENDPOINT_STUDY_RECORD.EffectivenessAgainstTargetOrganisms">

	<#local testMaterialInformation = document.MaterialsAndMethods.TestMaterials.TestMaterialInformation />
	<#local testMaterial = iuclid.getDocumentForKey(testMaterialInformation) />
		<#if testMaterial?has_content>
			<#if testMaterial.Name?has_content>
		
				${testMaterial.Name?replace(",","")}
				
				<#if testMaterial.Composition.CompositionList?has_content>
					<#list testMaterial.Composition.CompositionList as testmaterialComposition>
						<#if testmaterialComposition?has_content>
						<#local refSubstanaceOfTestMaterial = iuclid.getDocumentForKey(testmaterialComposition.ReferenceSubstance) />
							<#if refSubstanaceOfTestMaterial?has_content && refSubstanaceOfTestMaterial.Inventory.CASNumber?has_content>					
							(CAS number: ${refSubstanaceOfTestMaterial.Inventory.CASNumber?replace(",","")}
								<#if refSubstanaceOfTestMaterial.Inventory.CASNumber?has_content && refSubstanaceOfTestMaterial.Inventory.InventoryEntry?has_content> / </#if><#if refSubstanaceOfTestMaterial.Inventory.InventoryEntry?has_content> EC number: <@com.inventoryECNumber refSubstanaceOfTestMaterial.Inventory.InventoryEntry/></#if>)							
							</#if>
						</#if>
					</#list>
				</#if>
			
			</#if>
		</#if>
	</#if>
	</#if>
</#compress>
</#macro>

<#function getDistributionModelling document>
<#local escapeDistributionModelling = []/>
<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId="ENDPOINT_STUDY_RECORD.DistributionModelling">
		<#return []>
	<#else>
		<#return escapeDistributionModelling>
	</#if>
	<#return escapeDistributionModelling>
</#function>

<#function getOtherSubstanceList mixture>
	<#local substanceList = []/>

	<#local compositionList = iuclid.getSectionDocumentsForParentKey(mixture.documentKey, "FLEXIBLE_RECORD", "MixtureComposition") />
	
	<#list compositionList as composition>
		<#local componentList = composition.Components.Components/>
	
		<#list componentList as component>
			<#if isComponentOtherSubstance(component)>
				<#local substance = iuclid.getDocumentForKey(component.Reference)/>
				<#if substance?has_content && (substance.documentType=="SUBSTANCE" || substance.documentType=="MIXTURE")>
					<#local substanceList = com.addDocumentToSequenceAsUnique(substance, substanceList)/>	
				</#if>	
			</#if>
		</#list>
	</#list>
	
	<#return substanceList />
</#function>
<#function isComponentOtherSubstance component>
	<#return component.Function?has_content && com.picklistValueMatchesPhrases(component.Function, ["absorbent", "adsorbent", "anticaking agent", "anticoagulant", "booster", "buffer", "coagulant", "coating agent", "colourant", "complexing agent", "conditioner", "controlled release agent", "crystal growth regulator", "dehydrating agent", "denaturant", "drying agent", "dye", "emulsifier", "filler", "flow aid agent", "fragrance", "hardener", "lubricant",
	 "moisturiser", "neutraliser", "odour masking agent", "pH adjuster", "pigment", "propellant", "solvent", "stabiliser", "stiffener", "UV absorber", "viscosity modifier", "water repellent", "wetting agent", "other:"]) />
</#function>

<#function getActiveSubstanceList mixture>
	<#local substanceList = []/>

	<#local compositionList = iuclid.getSectionDocumentsForParentKey(mixture.documentKey, "FLEXIBLE_RECORD", "MixtureComposition") />
	
	<#list compositionList as composition>
	<#local componentList = composition.Components.Components/>
	
		<#list componentList as component>
			<#if isComponentActiveSubstance(component)>
				<#local substance = iuclid.getDocumentForKey(component.Reference)/>
				<#if substance?has_content && (substance.documentType=="SUBSTANCE" || substance.documentType=="MIXTURE")>
					<#local substanceList = com.addDocumentToSequenceAsUnique(substance, substanceList)/>	
				</#if>		
			</#if>			
		</#list>
	</#list>
	
	<#return substanceList />
</#function>
<#function isComponentActiveSubstance component>
	<#return component.Function?has_content && com.picklistValueMatchesPhrases(component.Function, ["active substance"]) />
</#function>

<#macro keyResultForValue effectConcentrations effectC>
<#compress>

	<#local key = effectConcentrations.KeyResult />	

	<#if effectConcentrations?has_content>
	
		<#if !key>
			(Value: ${effectC?replace(",","")?replace("&gt;", ">")?replace("&lt;", "<")})
			
			<#else>				
			Key Result: Yes (Value: ${effectC?replace(",","")?replace("&gt;", ">")?replace("&lt;", "<")})
		</#if>
		<#else>
	</#if>
</#compress>
</#macro>

<#macro glpCompliance document>
<#compress>
<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId!="ENDPOINT_STUDY_RECORD.DistributionModelling">
	<#if docDefId!="ENDPOINT_STUDY_RECORD.EffectivenessAgainstTargetOrganisms">
		<#assign glpCompliant><@com.picklist document.MaterialsAndMethods.GLPComplianceStatement /></#assign>
		<#if glpCompliant?has_content>${glpCompliant?replace(",","")}</#if>
	</#if>
	</#if>
</#compress>
</#macro>
</#compress>sep=,
<#compress> 
<#-- Literature reference report for substances and mixtures with CSV output -->
<#-- Import common macros and functions -->
<#import "../../application/docbook+xmlas/macros_common.ftl" as com>
<#-- Include utilities for the list of relevant endpoint records containing literature references -->
<#include "literature_reference_utilities_csv.ftl" />
<#assign substance = com.getReportSubject(rootDocument) />
<#assign mixture = com.getReportSubject(rootDocument) />
<#-- Print the headears for each column -->
Type,Section number,Section name,Document name,Document UUID,<#if substance.documentType=="SUBSTANCE">CAS number (from reference substance in substance 1.1),</#if>Robust study summary,Adequacy of study,Study period,Data waiving,Data waiving justification,Type of information,Reliability,Data access,Guideline (materials and methods),GLP compliant,Test material information name (and CAS number of test material),Species / test organism,Strain / cell type,Route of application / dose method,Exposure duration,Metabolic activation,Metabolic activation system,Study outcome (dose descriptor),Study outcome (value/result),Reference type,Title,Author,Bibliographic source,Year,Testing Laboratory,Report number,Company owner,Company study number,Report date,Remarks,Confidentiality claim on endpoint,Regulatory programme(s)<#if rootDocument.documentType=="MIXTURE">,BPR Annex II/III requirements</#if>
<#compress>					
	<#if substance.documentType=="SUBSTANCE">
	
		<#-- Substance derived Literature References -->					
		<#list substanceLiteratureReferenceList as dataSourceIdentifier>
		<#assign documentList = iuclid.getSectionDocumentsForParentKey(substance.documentKey, dataSourceIdentifier.docType, dataSourceIdentifier.docSubType) />			
			<#list documentList as document>
				<#if document?has_content>
				<#list document.DataSource.Reference as referenceItem>
					<#if referenceItem?has_content>				
					<@tableRowForLiteratureReference document referenceItem dataSourceIdentifier "Substance" document.name document.documentKey.uuid document.documentKey.snapshotUuid substance.documentKey.uuid/><#if referenceItem_has_next>; </#if>
					</#if>								
				</#list>
				</#if>
			</#list>
		</#list>
	</#if>
		
	<#if mixture.documentType=="MIXTURE">
	
		<#-- Biocidal Product derived Literature References -->							
		<#list mixtureLiteratureReferenceList as dataSourceIdentifier>
		<#assign documentList = iuclid.getSectionDocumentsForParentKey(mixture.documentKey, dataSourceIdentifier.docType, dataSourceIdentifier.docSubType) />
			<#list documentList as document>
				<#if document?has_content>
					<#list document.DataSource.Reference as referenceItem>
						<#if referenceItem?has_content>
							<@tableRowForLiteratureReference document referenceItem dataSourceIdentifier "Biocidal product" document.name document.documentKey.uuid document.documentKey.snapshotUuid mixture.documentKey.uuid/><#if referenceItem_has_next>; </#if>											
						</#if>
					</#list>
				</#if>
			</#list>							
		</#list>
	
		<#-- Literature References in the active substances linked to a mixture -->
		<#assign activeSubstanceList = getActiveSubstanceList(mixture) />
	
		<#list activeSubstanceList as substance>
			<#if substance?has_content>
				<#list substanceOfMixtureReferenceList as dataSourceIdentifier>
					<#if dataSourceIdentifier?has_content>
					<#assign documentList = iuclid.getSectionDocumentsForParentKey(substance.documentKey, dataSourceIdentifier.docType, dataSourceIdentifier.docSubType) />
						<#list documentList as document>
							<#if document?has_content>
								<#list document.DataSource.Reference as referenceItem>
									<#if referenceItem?has_content>											
										<@tableRowForLiteratureReference document referenceItem dataSourceIdentifier "Active Substance" document.name document.documentKey.uuid document.documentKey.snapshotUuid substance.documentKey.uuid/><#if referenceItem_has_next>; </#if>						
									</#if>									
								</#list>
							</#if>
						</#list>
					</#if>
				</#list>
			</#if>
		</#list>	
					
		<#-- Literature References in other substances linked to a mixture -->
		<#assign otherSubstanceList = getOtherSubstanceList(mixture) />
		
		<#list otherSubstanceList as substance>	
			<#if substance?has_content>
				<#list substanceOfMixtureReferenceList as dataSourceIdentifier>
					<#if dataSourceIdentifier?has_content>
						<#assign documentList = iuclid.getSectionDocumentsForParentKey(substance.documentKey, dataSourceIdentifier.docType, dataSourceIdentifier.docSubType) />
						<#list documentList as document>
							<#if document?has_content>
								<#list document.DataSource.Reference as referenceItem>
									<#if referenceItem?has_content>											
										<@tableRowForLiteratureReference document referenceItem dataSourceIdentifier "Other Substance" document.name document.documentKey.uuid document.documentKey.snapshotUuid substance.documentKey.uuid/><#if referenceItem_has_next>; </#if>						
									</#if>									
								</#list>
							</#if>
						</#list>
					</#if>
				</#list>
			</#if>
		</#list>
		
	</#if>
</#compress>
<#-- Macros and functions -->
<#-- table for Literature References for both substances and mixtures -->					
<#compress>
<#macro tableRowForLiteratureReference document referenceItem dataSourceIdentifier type="" documentName="" documentUUID="" dossierUUID="" rootUUID="">
<#compress>
<#if referenceItem?has_content && dataSourceIdentifier?has_content>
<#assign dataSource = iuclid.getDocumentForKey(referenceItem)/>
<#assign adequacy><@com.picklist document.AdministrativeData.PurposeFlag /></#assign>
<#assign studyPeriod><@com.text document.AdministrativeData.StudyPeriod /></#assign>
<#assign dataWaivingJustification><@com.picklistMultiple document.AdministrativeData.DataWaivingJustification /></#assign>
<#assign typeOfInformation><@com.picklist document.AdministrativeData.StudyResultType /></#assign>
<#assign literatureType><@com.picklist dataSource.GeneralInfo.LiteratureType /></#assign>
<#assign reliability><@com.picklist document.AdministrativeData.Reliability /></#assign>
<#assign dataAccess><@com.picklist document.DataSource.DataAccess /></#assign>
<#assign confidentialityFlagPath = "document." + "AdministrativeData.DataProtection" + ".confidentiality" />
<#assign confidentialityFlag = confidentialityFlagPath?eval />
<#assign regulatoryPath = "document." + "AdministrativeData.DataProtection" + ".legislations" />
<#assign regulation = regulatoryPath?eval />
<#assign regulatoryProgrammes><@com.picklistMultiple regulation /></#assign>
<#assign robust = document.AdministrativeData.RobustStudy />
			
<#if dataSource?has_content>
<#compress>
<@com.text type />,<@com.text dataSourceIdentifier.sectionNr />,<@compress single_line=true>${dataSourceIdentifier.sectionName?replace(",","")}</@compress>,<@compress single_line=true>${documentName?replace(",","")}</@compress>,<@compress single_line=true><#assign docUrl=iuclid.webUrl.documentView(document.documentKey) /><#if docUrl?has_content>"=HYPERLINK(""${docUrl}"", ""<@com.text documentUUID />"")"<#else>${documentUUID?replace(",","")}</#if></@compress>,<#if substance.documentType=="SUBSTANCE"><@compress single_line=true><@CASNumber substance/></@compress>,</#if><#if robust>yes<#else>no</#if>,${adequacy?replace(",","")},${studyPeriod?replace(",","")},<@com.picklist document.AdministrativeData.DataWaiving />,<@compress single_line=true>${dataWaivingJustification?replace(",","")}</@compress>,${typeOfInformation?replace(",","")},${reliability?replace(",","")},${dataAccess?replace(",","")},<@compress single_line=true><@guidelines document /></@compress>,<@glpCompliance document />,<@compress single_line=true><@testMaterialInformation document /></@compress>,<@speciesInfo document />,<@strainInfo document />,<@routeOfAdministrationOrDose document />,<@exposureDuration document />,<@metabolicActivation document />,<@metabolicActivationSystem document />,<@doserDescriptorInformation document />,<@valueOfResult document />,<#if literatureType?has_content>${literatureType?replace(",","")}<#else/>No reference type provided</#if>,<#if dataSource.GeneralInfo.Name?has_content>${dataSource.GeneralInfo.Name?replace(",","")}<#else/>No title provided</#if>,<@compress single_line=true><#if dataSource.GeneralInfo.Author?has_content>${dataSource.GeneralInfo.Author?replace(",","")}<#else/>No author provided</#if></@compress>,<@compress single_line=true><#if dataSource.GeneralInfo.Source?has_content>${dataSource.GeneralInfo.Source?replace(",","")}<#else/>No bibliographic source provided</#if></@compress>,<#if dataSource.GeneralInfo.ReferenceYear?has_content>${dataSource.GeneralInfo.ReferenceYear?replace(",","")}<#else/>No year provided</#if>,<#if dataSource.GeneralInfo.TestLab?has_content>${dataSource.GeneralInfo.TestLab?replace(",","")}<#else/>No testing laboratory provided</#if>,<#if dataSource.GeneralInfo.ReportNo?has_content>${dataSource.GeneralInfo.ReportNo?replace(",","")}<#else/>No report number provided</#if>,<#if dataSource.GeneralInfo.CompanyOwner?has_content>${dataSource.GeneralInfo.CompanyOwner?replace(",","")}<#else/>No company owner provided</#if>,<#if dataSource.GeneralInfo.CompanyOwnerStudyNo?has_content>${dataSource.GeneralInfo.CompanyOwnerStudyNo?replace(",","")}<#else/>No company study number provided</#if>,<#if dataSource.GeneralInfo.ReportDate?has_content>${dataSource.GeneralInfo.ReportDate?replace(",","")}<#else/>No report date provided</#if>,<#if dataSource.GeneralInfo.Remarks?has_content>${dataSource.GeneralInfo.Remarks?replace(",","")}<#else/>no remarks in the literature reference</#if>,<#if confidentialityFlag?has_content>endpoint is flagged confidential<#else/>endpoint is not flagged confidential</#if>,<#if regulation?has_content><@compress single_line=true>${regulatoryProgrammes?replace(",","")}</@compress></#if><#if rootDocument.documentType=="MIXTURE">,<@com.text dataSourceIdentifier.AnnexIIIrequirements /></#if>
</#compress>	
</#if>

</#if>
</#compress>
</#macro>
</#compress>

<#macro speciesInfo document>
<@compress single_line=true>
<#if document?has_content>	

	<#local docDefId = document.documentType +"."+ document.documentSubType />
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion" || docDefId=="ENDPOINT_STUDY_RECORD.EyeIrritation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther" || docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo" || docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction" || docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.BasicToxicokinetics">

		<#local species><@com.picklist document.MaterialsAndMethods.TestAnimals.Species /></#local>
		${species?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
	
	<#local speciesEcoTox><@com.picklist document.MaterialsAndMethods.TestOrganisms.TestOrganismsSpecies /></#local>
		${speciesEcoTox?replace(",","")}
		<#else>
	</#if>	
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" >
	<#if document.MaterialsAndMethods.TestOrganisms.TestOrganisms?has_content>
		<#list document.MaterialsAndMethods.TestOrganisms.TestOrganisms as testorganisms>			
			<#if testorganisms.Species?has_content>
			<#local speciesTestOrganisms><@com.picklist testorganisms.Species /></#local>
				${speciesTestOrganisms?replace(",","")}<#if testorganisms_has_next>; </#if>
				<#else>
			</#if>
		</#list>
	</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms">
	<#local speciesSoilMicroorganism><@com.picklist document.MaterialsAndMethods.TestOrganisms.TestOrganismsInoculum /></#local>
		${speciesSoilMicroorganism?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinSensitisation">
	<#local speciesSkinSensitisation><@com.picklist document.MaterialsAndMethods.InVivoTestSystem.TestAnimals.Species /></#local>
		${speciesSkinSensitisation?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local speciesAndStrainGeneticVitro = document.MaterialsAndMethods.Method.SpeciesStrain/>
		<#if speciesAndStrainGeneticVitro?has_content>
			<#list speciesAndStrainGeneticVitro as speciesAndStrain>			
			
				<#local speciesAndStrainVitro><@com.picklist speciesAndStrain.SpeciesStrain /></#local>
				<#if speciesAndStrainVitro?has_content>
				species / strain: ${speciesAndStrainVitro?replace(",","")}<#if speciesAndStrain_has_next>; </#if>
					<#else>
				</#if>
			</#list>
		</#if>
	</#if>

</#if>
</@compress>
</#macro>

<#macro strainInfo document>
<@compress single_line=true>
<#if document?has_content>
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion" || docDefId=="ENDPOINT_STUDY_RECORD.EyeIrritation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther" || docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo" || docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction" || docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.BasicToxicokinetics">

		<#local strain><@com.picklist document.MaterialsAndMethods.TestAnimals.Strain /></#local>
		${strain?replace(",","")}
		<#else>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinSensitisation">
	<#local strainSkinSensitisation><@com.picklist document.MaterialsAndMethods.InVivoTestSystem.TestAnimals.Strain /></#local>
		${strainSkinSensitisation?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local speciesAndStrainGeneticVitro = document.MaterialsAndMethods.Method.SpeciesStrain/>
		<#if speciesAndStrainGeneticVitro?has_content>
			<#list speciesAndStrainGeneticVitro as speciesAndStrain>			
			
				<#local speciesAndStrainVitro><@com.picklist speciesAndStrain.SpeciesStrain /></#local>
				<#if speciesAndStrainVitro?has_content>
				species / strain: ${speciesAndStrainVitro?replace(",","")}<#if speciesAndStrain_has_next>; </#if>
					<#else>
				</#if>
			</#list>
		</#if>
	</#if>
	
</#if>
</@compress>
</#macro>

<#macro valueOfResult document>
<@compress single_line=true>
<#if document?has_content>

	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms">
		
		<#local effectConcentration = document.ResultsAndDiscussion.EffectConcentrations />
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectConc /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity">
		<#local effectConcentration = document.ResultsAndDiscussion.ResultsFetuses.EffectLevelsFetuses.Efflevel/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction">
		<#local effectConcentration = document.ResultsAndDiscussion.ResultsOfExaminationsParentalGeneration.EffectLevelsP0.Efflevel/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if> 
	 
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local effectConcentration = document.ResultsAndDiscussion.TestRs/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.picklist effectConcentrations.Genotoxicity /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo">
		<#local effectConcentration = document.ResultsAndDiscussion.TestRs/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.picklist effectConcentrations.Genotoxicity /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity">
		<#local effectConcentration = document.ResultsAndDiscussion.EffectLevels.Efflevel/>
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>	
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther">
	
	<#local effectConcentration = document.ResultsAndDiscussion.EffectLevels.Efflevel />
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
	
	<#local effectConcentration = document.ResultsAndDiscussion.EffectLevels />
		<#if effectConcentration?has_content>
			<#list effectConcentration as effectConcentrations>
				<#if effectConcentrations?has_content>
					<#local effectC><@com.range effectConcentrations.EffectLevel /></#local>
					<#if effectC?has_content>
					<@keyResultForValue effectConcentrations effectC /><#if effectConcentrations_has_next>; </#if>
						<#else>
					</#if>					
				</#if>		
			</#list>
		</#if>
	</#if>
	
</#if>
</@compress>
</#macro>

<#macro doserDescriptorInformation document>
<@compress single_line=true>
<#if document?has_content>

	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms">
		
		<#local doseDescriptor = document.ResultsAndDiscussion.EffectConcentrations />
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity">
		<#local doseDescriptor = document.ResultsAndDiscussion.ResultsFetuses.EffectLevelsFetuses.Efflevel/>
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if> 
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction">
		<#local doseDescriptor = document.ResultsAndDiscussion.ResultsOfExaminationsParentalGeneration.EffectLevelsP0.Efflevel/>
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity">
		<#local doseDescriptor = document.ResultsAndDiscussion.EffectLevels.Efflevel/>
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>	
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther">
	
	<#local doseDescriptor = document.ResultsAndDiscussion.EffectLevels.Efflevel />
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
	
	<#local doseDescriptor = document.ResultsAndDiscussion.EffectLevels />
		<#if doseDescriptor?has_content>
			<#list doseDescriptor as doseDescriptors>
				<#if doseDescriptors?has_content>
					<#local doseDescriptorsItem><@com.picklist doseDescriptors.Endpoint /></#local>
					${doseDescriptorsItem?replace(",","")}
						<#else>
				</#if>		
			</#list>
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion" || docDefId=="ENDPOINT_STUDY_RECORD.EyeIrritation" || docDefId=="ENDPOINT_STUDY_RECORD.SkinSensitisation">
	
	<#if document.ApplicantSummaryAndConclusion.InterpretationOfResults?has_content>
		<#local doseDescriptorsItem><@com.picklist document.ApplicantSummaryAndConclusion.InterpretationOfResults /></#local>
			${doseDescriptorsItem?replace(",","")}
		<#else>
	</#if>
	</#if>
	
</#if>
</@compress>
</#macro>

<#macro routeOfAdministrationOrDose document>
<@compress single_line=true>
<#if document?has_content>

	<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
		<#local toxicityToBirdsDose><@com.picklist document.MaterialsAndMethods.TestMaterials.DoseMethod /></#local>
		${toxicityToBirdsDose?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity">
	
	<#local testType><@com.picklist document.MaterialsAndMethods.StudyDesign.TestType /></#local>
		${testType?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods">
		<#local routeOfAdministration><@com.picklist document.MaterialsAndMethods.StudyDesign.StudyType /></#local>
		${routeOfAdministration?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.BasicToxicokinetics" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo" || docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction" || docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation">
		<#local routeOfAdministration><@com.picklist document.MaterialsAndMethods.AdministrationExposure.RouteOfAdministration /></#local>
		${routeOfAdministration?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal">
		<#local routeOfAdministration><@com.picklist document.MaterialsAndMethods.AdministrationExposure.TypeOfCoverage /></#local>
		${routeOfAdministration?replace(",","")}
			<#else>
	</#if>	
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal">
		<#local routeOfAdministration><@com.picklist document.MaterialsAndMethods.AdministrationExposure.TypeOfCoverage /></#local>
		${routeOfAdministration?replace(",","")}
			<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion">
		<#local skinIrritation><@com.picklist document.MaterialsAndMethods.TestSystem.TypeOfCoverage /></#local>
		${skinIrritation?replace(",","")}
		<#else>	
	</#if>
	
</#if>
</@compress>
</#macro>

<#macro exposureDuration document>
<@compress single_line=true>
<#if document?has_content>
	
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
		<#local exposureDuration><@com.quantity document.MaterialsAndMethods.StudyDesign.TotalExposureDuration /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction" || docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity" || docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo">
		<#local exposureDuration><@com.text document.MaterialsAndMethods.AdministrationExposure.DurationOfTreatmentExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SkinIrritationCorrosion">
		<#local exposureDuration><@com.text document.MaterialsAndMethods.TestSystem.DurationOfTreatmentExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>
			
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal">
		<#local exposureDuration><@com.text document.MaterialsAndMethods.AdministrationExposure.DurationOfExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.BasicToxicokinetics">    
		<#local exposureDuration><@com.text document.MaterialsAndMethods.AdministrationExposure.DurationAndFrequencyOfTreatmentExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>	
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation">
		<#local exposureDuration><@com.quantity document.MaterialsAndMethods.AdministrationExposure.DurationOfExposure /></#local>
		${exposureDuration?replace(",","")}
		<#else>
	</#if>	
	
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity">
	<#assign exposureDurationRepeatable = document.MaterialsAndMethods.StudyDesign.ExposureDuration />
		<#if exposureDurationRepeatable?has_content>
			<#list exposureDurationRepeatable as exposure>
			<#if exposure?has_content>
		
			<#local exposureDuration><@com.quantity exposure.TotalExposureDuration /></#local>
			${exposureDuration?replace(",","")}<#if exposure_has_next>; </#if>										
				<#else>
			</#if>	
			
			</#list>
		</#if>
	</#if>
	
	
</#if>
</@compress>
</#macro>

<#macro metabolicActivation document>
<@compress single_line=true>
<#if document?has_content>
	
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local metabActivation><@com.picklist document.MaterialsAndMethods.Method.MetabolicActivation /></#local>
		${metabActivation?replace(",","")}
		<#else>
	</#if>
</#if>
</@compress>
</#macro>

<#macro metabolicActivationSystem document>
<@compress single_line=true>
<#if document?has_content>
	
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local metabActivationSystem><@com.text document.MaterialsAndMethods.Method.MetabolicActivationSystem /></#local>
		${metabActivationSystem?replace(",","")}
		<#else>
	</#if>
</#if>
</@compress>
</#macro>

<#--
<#macro keyResult document>
<@compress single_line=true>
<#if document?has_content>
	
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToFish" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxToFish" || docDefId=="ENDPOINT_STUDY_RECORD.ShortTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.LongTermToxicityToAquaInv" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticAlgae" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToAquaticPlant" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToMicroorganisms" || docDefId=="ENDPOINT_STUDY_RECORD.SedimentToxicity" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMacroorganismsExceptArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialArthropods" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToTerrestrialPlants" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToSoilMicroorganisms" >
		
		<#local results = document.ResultsAndDiscussion.EffectConcentrations />
		<#if results?has_content>
			<@firstKeyResult results />			
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.DevelopmentalToxicityTeratogenicity">
		<#local resultsToxicityDevelopmental = document.ResultsAndDiscussion.ResultsFetuses.EffectLevelsFetuses.Efflevel/>
		<#if resultsToxicityDevelopmental?has_content>
			<@firstKeyResult resultsToxicityDevelopmental />			
		</#if>
	</#if> 
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.ToxicityReproduction">
		<#local resultsToxicityReproduction = document.ResultsAndDiscussion.ResultsOfExaminationsParentalGeneration.EffectLevelsP0.Efflevel/>
		<#if resultsToxicityReproduction?has_content>
			<@firstKeyResult resultsToxicityReproduction />			
		</#if>
	</#if> 
	 
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVitro">
		<#local resultsGeneticVitro = document.ResultsAndDiscussion.TestRs/>
		<#if resultsGeneticVitro?has_content>
			<@firstKeyResult resultsGeneticVitro />			
		</#if>
	</#if>
	
	<#if docDefId=="ENDPOINT_STUDY_RECORD.GeneticToxicityVivo">
		<#local resultsGeneticVivo = document.ResultsAndDiscussion.TestRs/>
		<#if resultsGeneticVivo?has_content>
			<@firstKeyResult resultsGeneticVivo />			
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.Carcinogenicity">
		<#local resultsCarcinogenicity = document.ResultsAndDiscussion.EffectLevels.Efflevel/>
		<#if resultsCarcinogenicity?has_content>
			<@firstKeyResult resultsCarcinogenicity />			
		</#if>
	</#if>	
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.RepeatedDoseToxicityOther">
	
	<#local results = document.ResultsAndDiscussion.EffectLevels.Efflevel />
		<#if results?has_content>
			<@firstKeyResult results />			
		</#if>
	</#if>
		
	<#if docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOral" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityInhalation" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityDermal" || docDefId=="ENDPOINT_STUDY_RECORD.AcuteToxicityOtherRoutes" || docDefId=="ENDPOINT_STUDY_RECORD.ToxicityToBirds">
	
	<#local results = document.ResultsAndDiscussion.EffectLevels />
		<#if results?has_content>
			<@firstKeyResult results />			
		</#if>
	</#if>
	
</#if>
</@compress>
</#macro>
-->

<#-- Macro for CAS number -->
<#macro CASNumber substance>
<#compress>
<#assign substanceId = substance />
	<#if substanceId?has_content>
	<#assign refSubstance = iuclid.getDocumentForKey(substanceId.ReferenceSubstance.ReferenceSubstance)/>
		<#if refSubstance?has_content>
			<@com.text refSubstance.Inventory.CASNumber />			
		</#if>
	</#if>
</#compress>
</#macro>

<#macro guidelines document>
<#compress>
	<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId!="ENDPOINT_STUDY_RECORD.DistributionModelling">
	<#if docDefId!="ENDPOINT_STUDY_RECORD.EffectivenessAgainstTargetOrganisms">

	<#local guideline = document.MaterialsAndMethods.Guideline />
	
	<#list guideline as guideline>
		<#if guideline.Guideline?has_content>
		<#local guidelineRow><@com.picklist guideline.Guideline /></#local>
			${guidelineRow?replace(",","")}<#if guideline_has_next>; </#if>
		</#if>
	</#list>
	
	</#if>
	</#if>
</#compress>	
</#macro>

<#macro testMaterialInformation document>
<#compress>

	<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId!="ENDPOINT_STUDY_RECORD.DistributionModelling">
	<#if docDefId!="ENDPOINT_STUDY_RECORD.EffectivenessAgainstTargetOrganisms">

	<#local testMaterialInformation = document.MaterialsAndMethods.TestMaterials.TestMaterialInformation />
	<#local testMaterial = iuclid.getDocumentForKey(testMaterialInformation) />
		<#if testMaterial?has_content>
			<#if testMaterial.Name?has_content>
		
				${testMaterial.Name?replace(",","")}
				
				<#if testMaterial.Composition.CompositionList?has_content>
					<#list testMaterial.Composition.CompositionList as testmaterialComposition>
						<#if testmaterialComposition?has_content>
						<#local refSubstanaceOfTestMaterial = iuclid.getDocumentForKey(testmaterialComposition.ReferenceSubstance) />
							<#if refSubstanaceOfTestMaterial?has_content && refSubstanaceOfTestMaterial.Inventory.CASNumber?has_content>					
							(CAS number: ${refSubstanaceOfTestMaterial.Inventory.CASNumber?replace(",","")}
								<#if refSubstanaceOfTestMaterial.Inventory.CASNumber?has_content && refSubstanaceOfTestMaterial.Inventory.InventoryEntry?has_content> / </#if><#if refSubstanaceOfTestMaterial.Inventory.InventoryEntry?has_content> EC number: <@com.inventoryECNumber refSubstanaceOfTestMaterial.Inventory.InventoryEntry/></#if>)							
							</#if>
						</#if>
					</#list>
				</#if>
			
			</#if>
		</#if>
	</#if>
	</#if>
</#compress>
</#macro>

<#function getDistributionModelling document>
<#local escapeDistributionModelling = []/>
<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId="ENDPOINT_STUDY_RECORD.DistributionModelling">
		<#return []>
	<#else>
		<#return escapeDistributionModelling>
	</#if>
	<#return escapeDistributionModelling>
</#function>

<#function getOtherSubstanceList mixture>
	<#local substanceList = []/>

	<#local compositionList = iuclid.getSectionDocumentsForParentKey(mixture.documentKey, "FLEXIBLE_RECORD", "MixtureComposition") />
	
	<#list compositionList as composition>
		<#local componentList = composition.Components.Components/>
	
		<#list componentList as component>
			<#if isComponentOtherSubstance(component)>
				<#local substance = iuclid.getDocumentForKey(component.Reference)/>
				<#if substance?has_content && (substance.documentType=="SUBSTANCE" || substance.documentType=="MIXTURE")>
					<#local substanceList = com.addDocumentToSequenceAsUnique(substance, substanceList)/>	
				</#if>	
			</#if>
		</#list>
	</#list>
	
	<#return substanceList />
</#function>
<#function isComponentOtherSubstance component>
	<#return component.Function?has_content && com.picklistValueMatchesPhrases(component.Function, ["absorbent", "adsorbent", "anticaking agent", "anticoagulant", "booster", "buffer", "coagulant", "coating agent", "colourant", "complexing agent", "conditioner", "controlled release agent", "crystal growth regulator", "dehydrating agent", "denaturant", "drying agent", "dye", "emulsifier", "filler", "flow aid agent", "fragrance", "hardener", "lubricant",
	 "moisturiser", "neutraliser", "odour masking agent", "pH adjuster", "pigment", "propellant", "solvent", "stabiliser", "stiffener", "UV absorber", "viscosity modifier", "water repellent", "wetting agent", "other:"]) />
</#function>

<#function getActiveSubstanceList mixture>
	<#local substanceList = []/>

	<#local compositionList = iuclid.getSectionDocumentsForParentKey(mixture.documentKey, "FLEXIBLE_RECORD", "MixtureComposition") />
	
	<#list compositionList as composition>
	<#local componentList = composition.Components.Components/>
	
		<#list componentList as component>
			<#if isComponentActiveSubstance(component)>
				<#local substance = iuclid.getDocumentForKey(component.Reference)/>
				<#if substance?has_content && (substance.documentType=="SUBSTANCE" || substance.documentType=="MIXTURE")>
					<#local substanceList = com.addDocumentToSequenceAsUnique(substance, substanceList)/>	
				</#if>		
			</#if>			
		</#list>
	</#list>
	
	<#return substanceList />
</#function>
<#function isComponentActiveSubstance component>
	<#return component.Function?has_content && com.picklistValueMatchesPhrases(component.Function, ["active substance"]) />
</#function>

<#macro keyResultForValue effectConcentrations effectC>
<#compress>

	<#local key = effectConcentrations.KeyResult />	

	<#if effectConcentrations?has_content>
	
		<#if !key>
			(Value: ${effectC?replace(",","")?replace("&gt;", ">")?replace("&lt;", "<")})
			
			<#else>				
			Key Result: Yes (Value: ${effectC?replace(",","")?replace("&gt;", ">")?replace("&lt;", "<")})
		</#if>
		<#else>
	</#if>
</#compress>
</#macro>

<#macro glpCompliance document>
<#compress>
<#local docDefId = document.documentType +"."+ document.documentSubType/>
	<#if docDefId!="ENDPOINT_STUDY_RECORD.DistributionModelling">
	<#if docDefId!="ENDPOINT_STUDY_RECORD.EffectivenessAgainstTargetOrganisms">
		<#assign glpCompliant><@com.picklist document.MaterialsAndMethods.GLPComplianceStatement /></#assign>
		<#if glpCompliant?has_content>${glpCompliant?replace(",","")}</#if>
	</#if>
	</#if>
</#compress>
</#macro>
</#compress>