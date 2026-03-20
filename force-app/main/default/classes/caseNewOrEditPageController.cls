/* Class Name: caseNewOrEditPageController 
* Purpose: This is controller class for case new or edi page(caseNewOrEditPage)
* Main feature: fetching auto complete/auto search data set from TechnicalSubArea Mappings object and forming a JSON data
* Author: Exafort(Azar)
* Created Date: 11th Dec 2017
* Change Log: changed on 16th March 2018
* Change log : changed on 12/9/2022 by Nagalaxmi Telkar - Added code for TS-8195
* Change log : changed on 2/10/2023 by Nagalaxmi Telkar - Added code for TS-8035
* Change log : changed on 2/10/2023 by Nagalaxmi Telkar - Added code for TS-9532
* Change log : changed on 3/8/2023 by Nagalaxmi Telkar - Added code for TS-9491
* Change log : changed on 4/11/2023 by Nagalaxmi Telkar - Added code for TS-9242
* Change log : changed on 7/20/2023 by Nagalaxmi Telkar -  Added logic for TS-7239
* */ 
public with sharing class caseNewOrEditPageController {
    
    public Case cas{get;set;} 
    public String estTimeEff{get;set;}
    private ApexPages.StandardController controller;
    public string searchBoxdisplay{get;set;}
    public string fieldDependencies{get;set;}
    public boolean displayFieldsForEditPage{get;set;}
    public boolean displayProductSymptomsForEditPage{get;set;}
    public List<string> stringpsymptoms{get;set;}
    Public List<SelectOption> SelectedProductSymptoms {set;get;}
    Public List<SelectOption> allProductSymptoms { get; set; }
    Public String profileName {get; set;}
    public Boolean IsCaseAbbreviated{set;get;}
    public string caseOwnerType{get;set;} // Added by vishnu for TS-8809
    public string caseOwnerName{get;set;} // Added by vishnu for TS-8809
    public string caseOwnerId{get;set;}   // Added by vishnu for TS-8809
    public string strFieldSeverity; //Added by Ntelkar for TS-9491
    public string strFieldPriority; //Added by Ntelkar for TS-9491
    public boolean isRender{get;set;}
    public string strFieldIsStorageDefect; //Added by Ntelkar for TS-9242
    
    //Added By Exafort for SFDC-307
    Public List<SelectOption> supportedVersions{get;Set;}
    Public string selectedVersion{get;set;}
    
    //Added by Exafort for SFDC-936	
    public Case existingCase;
    public String timerValue { get; set; } 
    public Case caseRecord { get; set; } 
    public String selectedStatus { get; set; } 
	public String selectedSubStatus { get; set; } 
    public DateTime timerExpiryDateVar { get; set; } 
    public DateTime timerExpiryDateVarSave { get; set; } 
    public Boolean selectedX3Strike { get; set; } 
    //Ended by Exafort for SFDC-936
    
    public Boolean isSupportProvider { get; set; }
    
    public String RecordTypeIdArrayCase{
        get{
            if( RecordTypeIdArrayCase == null )
                RecordTypeIdArrayCase = [SELECT Id FROM RecordType WHERE DeveloperName = 'Array_Case'].Id;
            return( RecordTypeIdArrayCase );
        }set;
    }
    
    public String RecordTypeIdNCVCase{
        get{
            if( RecordTypeIdNCVCase == null )
                RecordTypeIdNCVCase = [SELECT Id FROM RecordType WHERE DeveloperName = 'NCV_Case'].Id;
            return( RecordTypeIdNCVCase );
        }set;
    }
    
    public String RecordTypeIdSSaaS{
        get{
            if( RecordTypeIdSSaaS == null ) 
                RecordTypeIdSSaaS = [SELECT Id FROM RecordType WHERE DeveloperName = 'SSaaS'].Id;
            return( RecordTypeIdSSaaS );
        }set;
    }
    public String RecordTypeIdIP{
        get{
            if( RecordTypeIdIP == null ) 
                RecordTypeIdIP = [SELECT Id FROM RecordType WHERE DeveloperName = 'InfoSight_Portal'].Id;
            return( RecordTypeIdIP );
        }set;
    }
    
    //Added by Ntelkar for TS-9491
    public void changeSeverity() {
        if(strFieldSeverity == 'Critical')
            cas.Severity__c = 'Critical';
        if(strFieldSeverity == 'Critical - Degraded')
            cas.Severity__c = 'Critical - Degraded';
        if(strFieldSeverity == 'Non-Critical')
            cas.Severity__c = 'Non-Critical';
        if(strFieldSeverity == 'Low Priority')
            cas.Severity__c = 'Low Priority';
    }
    
    //Added by Ntelkar for TS-9491
    public void changePriority() {
        if(strFieldPriority == 'P1')
            cas.Priority = 'P1';
        if(strFieldPriority == 'P2')
            cas.Priority = 'P2';
        if(strFieldPriority == 'P3')
            cas.Priority = 'P3';
        if(strFieldPriority == 'P4')
            cas.Priority = 'P4';
    }
    
    //Added by Ntelkar for TS-9491
    public void setStrFieldSeverity(String n) {
        strFieldSeverity = n;
    }
    
    //Added by Ntelkar for TS-9491
    public String getStrFieldSeverity() {
        return strFieldSeverity;
    }
    
    //Added by Ntelkar for TS-9491
    public void setStrFieldPriority(String n) {
        strFieldPriority = n;
    }
    
    //Added by Ntelkar for TS-9491
    public String getStrFieldPriority() {
        return strFieldPriority;
    }
    
    //Added by Ntelkar for TS-9491
    public void getSeverity(){
        changeSeverity();
    }
    
    //Added by Ntelkar for TS-9491
    public void getPriority(){
        changePriority();
    }
       
    //Added by Exafort for SFDC-307
    //The below method will call from the vf page on asset change.
    public String selectedAssetId { get; set; }
    public void versionsOnAssetChange()
    {
        system.debug('## inside versionsOnAssetChange AssetId: ' + selectedAssetId);
        if(cas != null && selectedAssetId != null && selectedAssetId.startsWith(Asset.sObjectType.getDescribe().getKeyPrefix())){
			cas.AssetId = selectedAssetId;
        }
        if (selectedAssetId != null && selectedAssetId.startsWith(Asset.sObjectType.getDescribe().getKeyPrefix())){
            Asset onChangeAsset = [select id,Support_Profile__c,Nimble_Version__c from Asset where id =: selectedAssetId limit 1];
            //	Added by Exafort for SFDC-649
            caseSetNimbleOsVersionHandler handler = new caseSetNimbleOsVersionHandler();
            String assetOsVersion = (onChangeAsset.Nimble_Version__c != null ? handler.getNimbleOsVersion(onChangeAsset.Nimble_Version__c) : null);
            system.debug('assetOsVersion : ' + assetOsVersion);
            //	End of SFDC-649
            supportedVersions = new List<SelectOption>();
            supportedVersions.add(new SelectOption('--None--', '--None--'));        
            string supportProfile = getCaseSupportProfileName(onChangeAsset.Support_Profile__c);
            for(Support_Profile_Version__c spVersions :[Select id,Name,Version__c from Support_Profile_Version__c where Support_Profile__c includes (:supportProfile) and IsActive__c = true]){
                supportedVersions.add(new SelectOption(spVersions.Version__c, spVersions.Version__c));                 
            }
            supportedVersions.sort();
            //	Added by Exafort for SFDC-649
            //	Now set selectedVersion if assetOsVersion exists in the list
            if (assetOsVersion != null) {
                for (SelectOption opt : supportedVersions) {
                    if (opt.getValue() == assetOsVersion) {
                        selectedVersion = opt.getValue();
                        system.debug('selectedVersion : ' + selectedVersion);
                        break;
                    }
                }
            }
            //	End of SFDC-649
            system.debug('supportedVersions :'+supportedVersions);
        }
    }
    
    //The below method will be called on case edit page constructor to set version values.
    public void setSoftwareVersionsOnCaseEdit(string caseActualVersion){ //Set Versions on Case Edit page
        supportedVersions = new List<SelectOption>();
        supportedVersions.add(new SelectOption('--None--', '--None--'));
        
        //The below logic is not applicable for "Infosight Portal".
        if(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() != 'InfoSight Portal'){
            string supportProfileName;
            string supportProfile;
            if(cas != null){
                //For case edit page
                if(cas.Id != null){
                    supportProfileName = cas.Support_Profile__c;    
                    supportProfile = getCaseSupportProfileName(supportProfileName);
                }
                //for creation of case from case tab and asset record page
                if(cas.Id == null && supportProfileName == null && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() != 'NCV Case'){
                    string caseAssetId = ApexPages.currentPage().getParameters().get('assetId');
                    if(caseAssetId != null && caseAssetId != ''){
                        supportProfileName = [Select id,Support_Profile__c from Asset where id=:caseAssetId].Support_Profile__c;
                        if(supportProfileName == null)
                            supportProfileName = getCaseSupportProfileName(null);
                    }
                    
                    if(supportProfileName != null)
                        supportProfile = getCaseSupportProfileName(supportProfileName);   
                }
            }
            //	NCV cases dont have asset  
            if(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'NCV Case'){              
                supportProfile = getCaseSupportProfileName(null);
            }
            //Add all the versions belongs to the case support Profile
            list<SelectOption> allVersionList = caseNewOrEditPageController.getVersionsBasedOnSupportProfile(supportProfile,caseActualVersion);
            if(allVersionList != null){
				supportedVersions.addAll(allVersionList);                
            }
            supportedVersions.sort();
        }
    }
    
    //Bundle all the version values in the list to display in UI
    public static list<SelectOption> getVersionsBasedOnSupportProfile(string supportProfile,string caseActualVersion){
        list<SelectOption> supportedVersions = new list<SelectOption>();
        list<string> allVersionValues = new list<string>();
        for(Support_Profile_Version__c spVersions : [Select id,Name,Version__c from Support_Profile_Version__c where Support_Profile__c includes (:supportProfile) and IsActive__c = true]){
            supportedVersions.add(new SelectOption(spVersions.Version__c, spVersions.Version__c));
            allVersionValues.add(spVersions.Version__c);
        }
        supportedVersions.sort();        
        if(allVersionValues != null && caseActualVersion != null){
            if(!allVersionValues.contains(caseActualVersion)){
                supportedVersions.add(new SelectOption(caseActualVersion, caseActualVersion));
            }
        }
        return supportedVersions;
    }
    // End of SFDC-307 
    
    //Added by Ntelkar for TS-9242
    public void getIsNimbleStorageDefect(){
        setValueForIsNimbleDefect();
    }
    //Added by Ntelkar for TS-9242
    public String getStrFieldIsStorageDefect() {
        return strFieldIsStorageDefect;
    }
    //Added by Ntelkar for TS-9491
    public void setStrFieldIsStorageDefect(String n) {
        strFieldIsStorageDefect = n;
    }
    //Added by Ntelkar for TS-9242
    public void setValueForIsNimbleDefect() {
        if(strFieldIsStorageDefect == 'No')
            cas.caseIsThisCaseRelatedToANimbleProduct__c = 'No';
        if(strFieldIsStorageDefect == 'Yes')
            cas.caseIsThisCaseRelatedToANimbleProduct__c = 'Yes';
    }
    
    
    //Public PageReference retURL;
    //###################################################################################################### caseNewOrEditPageController
    public caseNewOrEditPageController(ApexPages.StandardController controller) {
        allTaMappings = new List<SelectOption>();
        allTsaMappings = new List<SelectOption>();
        SelectedProductSymptoms = new List<SelectOption>();
        allProductSymptoms = new List<SelectOption>();
        stringpsymptoms = new list<string>();
        
        this.controller = controller;
        cas=(Case) controller.getRecord();     
        displayFieldsForEditPage = false;
        displayProductSymptomsForEditPage =false;
        system.debug('### case record type ### '+cas.RecordTypeId);
        
        if(ApexPages.currentPage().getParameters().get('RecordType') != null)                  
            cas.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
      
        // Get current user's profile
        Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        
        // Set boolean based on profile name
        isSupportProvider = ( p.Name == 'Support Provider' ? true : false );
        
        if (cas.Id == null) {
            caseNewRecord();
            caseRecord = new Case(); //Added by Exafort by SFDC-936
        }
        else{
            caseEditRecord(controller);
            
            case getTa = [Select Id,Status, ClosedDate,Technology_Area__c,Sub_Technology_Area__c,Nimble_Version__c,Support_Profile__c,Product_Damage_Symptoms__c,Owner.Id,Owner.Name,Owner.Type,Case_Effort_Summary_Total__c, Estimated_Effort__c, caseClosureEstimatedEffort__c, Current_comment_time_spent__c,Timer_Expiry_Override_Date__c,RecordTypeId from Case where Id=:cas.Id];
            SelectedTaValue = getTa.Technology_Area__c;
            SelectedTsaValue = getTa.Sub_Technology_Area__c;
            
            //Added by Exafort for SFDC-2233
            
            // Get current Record Type name
            String currentRecordTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName();
            // Get previous Record Type name
            String previousRecordTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(getTa.RecordTypeId).getName();
            // If changed from Array Case → InfoSight Portal: Clear AssetId
            if ((previousRecordTypeName == 'Array Case' || previousRecordTypeName == 'SSaaS' ) && currentRecordTypeName == 'InfoSight Portal') {
                System.debug('cas.AssetId ' + cas.AssetId);
                cas.AssetId = null;
            }
            // End by Exafort for SFDC-2233
            
            //	Added By Exafort for SFDC-396
            existingCase = getTa; 
            caseRecord = [Select Id,Status,Sub_Status__c,Timer_Expiry_Date__c,X3_Strike__c from case where Id = :cas.Id];
            timerExpiryDateVar = caseRecord.Timer_Expiry_Date__c;
            System.debug('timer Expiry DateVar: ' + timerExpiryDateVar);
            if(cas.Timer_Expiry_Date__c != null){
                DateTime userTime;
                try {
                    DateTime gmtNow = timerExpiryDateVar; 
                    TimeZone userTimeZone = UserInfo.getTimeZone(); 
                    Integer offsetInMinutes = userTimeZone.getOffset(gmtNow) / 60000; 
                    userTime = gmtNow.addMinutes(offsetInMinutes); 
                    System.debug('user Time: ' +userTime);
                } catch (Exception ex) {
                    System.debug('Error calculating user time: ' + ex.getMessage());
                    userTime = System.now(); 
                }
                timerExpiryDateVar = userTime;
                timerExpiryDateVar.format('M/d/yyyy h:mm a');
            }
            //	End by Exafort for SFDC-936
                        
            //	Added By Exafort for SFDC-307
            selectedVersion =  getTa.Nimble_Version__c;
            
            caseOwnerType = getTa.Owner.Type;               // Added by vishnu for TS-8809
            caseOwnerName = getTa.Owner.Name;               // Added by vishnu for TS-8809
            caseOwnerId = getTa.Owner.Id; 
            // Added by vishnu for TS-8809
            //loadCaseEstimatedEffort(getTa,'initial Load');  // Added by vishnu for TS-8809
            if(SelectedTsaValue == 'Damaged in shipping' || SelectedTsaValue == 'Damaged at customer site not shipping related')
                displayProductSymptomsForEditPage = true;
            else
                displayProductSymptomsForEditPage = false;
            
            if(getTa.Product_Damage_Symptoms__c != null ){
                if(getTa.Product_Damage_Symptoms__c.contains(';'))
                    stringpsymptoms = getTa.Product_Damage_Symptoms__c.split(';');    
                else
                    stringpsymptoms.add(getTa.Product_Damage_Symptoms__c);
                
                for(String recordvalue : stringpsymptoms){
                    SelectedProductSymptoms.add(new SelectOption(recordvalue, recordvalue));
                } 
            }
            Schema.DescribeFieldResult fieldResult = Case.Product_Damage_Symptoms__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry picklistrecords : ple){
                allProductSymptoms.add(new SelectOption(picklistrecords.getLabel(), picklistrecords.getValue()));
            }
            Set<SelectOption> allProductSymptomsSet = new Set<SelectOption>(allProductSymptoms);
            Set<SelectOption> SelectedProductSymptomsSet = new Set<SelectOption>(SelectedProductSymptoms);
            List<SelectOption> duplicatevaluesinPS = new List<SelectOption>();
            
            for(SelectOption allPSrecord :allProductSymptomsSet){
                for(SelectOption selectedPSrecord : SelectedProductSymptomsSet){
                    if(allPSrecord == selectedPSrecord){
                        duplicatevaluesinPS.add(allPSrecord);
                    }
                }
            }
            allProductSymptomsSet.removeAll(duplicatevaluesinPS);
            allProductSymptoms.clear();
            allProductSymptoms.addAll(allProductSymptomsSet);
        }  
        allTsaMappingss(); 
        //Added By Exafort For SFDC-307
        setSoftwareVersionsOnCaseEdit(selectedVersion); 
    }
    
    //	Added by Exafort for SFDC-936
    public void fetchTimerDuration() {
        timerExpiryDateVar = CaseUtility.applyTimerDuration(cas, selectedStatus, selectedSubStatus, selectedX3Strike);
    }
    // End  for SFDC-936
    
    //Added by vishnu on 10th may for redirecting to abbreviated case detail page.TS-5755
    public PageReference validateAndRedirect(){
        PageReference       newPage;
        Id userId;        
        List<User> users;
        Account accQHselected;
        Asset assetQHselected;
        
        // Retrieve the user's profile name
        userId = UserInfo.getUserId();
        users = [SELECT Profile.Name from User where Id = :userId];
        profileName = users[0].Profile.Name;
        system.debug('userId'+userId);
        
        //Added by vishnu on 27th Aug 2019 
        List<Qualified_Handling_User__c> Cmodels ;
        Cmodels = new List<Qualified_Handling_User__c>();
        IsCaseAbbreviated = false; 
        if(cas.AssetId != null)
            assetQHselected = [Select Id,assetQualifiedHandling__c,assetQualifiedHandling__r.Name From Asset where Id=:cas.AssetId];    
        if(cas.AccountId != null)
            accQHselected = [Select Id,accountQualifiedHandling__c,accountQualifiedHandling__r.Name From Account where Id=:cas.AccountId];    
        if(assetQHselected != null && ((assetQHselected.assetQualifiedHandling__c != null || assetQHselected.assetQualifiedHandling__c != '')))
            Cmodels = [Select cmUser__c, QH_Abbreviated_Only__c  From Qualified_Handling_User__c where cmQualifiedHandling__c =:assetQHselected.assetQualifiedHandling__c];
        else if(accQHselected != null && ((accQHselected.accountQualifiedHandling__c != null || accQHselected.accountQualifiedHandling__c != '')))
            Cmodels = [Select cmUser__c ,QH_Abbreviated_Only__c From Qualified_Handling_User__c where cmQualifiedHandling__c =:accQHselected.accountQualifiedHandling__c];
        
        System.debug('Cmodel size is '+Cmodels.size());
        if(Cmodels.size() > 0){
            Set<Id> userIdSet = new Set<Id>();
            Map<ID,Boolean> cModelAbbreviat = new Map<ID,Boolean>();
            for(Qualified_Handling_User__c cModel:Cmodels){
                userIdSet.add(string.valueOf(cModel.cmUser__c));
                cModelAbbreviat.put(cModel.cmUser__c,cModel.QH_Abbreviated_Only__c);
            }
            
            if(!userIdSet.contains(userId))
                IsCaseAbbreviated = true;
            else{
                if(cModelAbbreviat.get(userId))
                    IsCaseAbbreviated = true;
                else
                    IsCaseAbbreviated = false;
            }
        }
        
        system.debug('## IsCaseAbbreviated'+IsCaseAbbreviated);
        
        
        if(profileName == 'Support: Technical Support Rep (TSR)' && IsCaseAbbreviated == true 
           && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'Array Case') { //Removed "&& aCase.caseQH_Requirements__c == 'Case Abbreviation'" by vishnu on 27th Aug 2019 for TS-5980
               //Added by vishnu for Qualified Handling Feature TS-5755
               system.debug('### came into if condition <===');
               string StringToCheckvfIdParameter = ApexPages.currentPage().getParameters().get('id');
               if(StringToCheckvfIdParameter != null){
                   newPage = Page.AbbreviatedCaseDetailPage;
                   newPage.getParameters().put('id',StringToCheckvfIdParameter );
               }else
                   newPage = Page.AbbreviatedCaseDetailPage;
               
           }else{
               string acctId = ApexPages.currentPage().getParameters().get('accountId');
               string assetId = ApexPages.currentPage().getParameters().get('assetId');
               system.debug('## ApexPages.currentPage().getParameters()' + ApexPages.currentPage().getParameters());
               system.debug('## acctId assetId'+assetId);
               Asset[] asst;// = new Asset[];
               Account[] acct;// = new Account[];
               if(!string.isBlank(assetId))
                   asst = [Select Id,assetQualifiedHandling__c,assetQualifiedHandling__r.Name From Asset where Id=:assetId and assetQualifiedHandling__c != null limit 1];
               else if(!string.isBlank(acctId))
                   acct = [Select Id,accountQualifiedHandling__c,accountQualifiedHandling__r.Name From Account where Id=: acctId and accountQualifiedHandling__c != null limit 1];
               
               if(( asst != null && asst.size() > 0) || (acct != null && acct.Size() > 0) && profileName == 'Support: Technical Support Rep (TSR)' && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'Array Case')
                   newPage = Page.AbbreviatedCaseDetailPage;
               else
                   return null;
           }
        return newPage.setRedirect(true);
    }
    //###################################################################################################### caseEditRecord
    public void caseEditRecord(ApexPages.StandardController controller)
    {
        displayFieldsForEditPage = true;
        searchBoxdisplay = 'block';
        caseClosePageController getTATSAFieldDependencies = new caseClosePageController(controller);
        fieldDependencies = getTATSAFieldDependencies.fieldDependencies;
    }
    /* caseSupportProfileName */
    public string getCaseSupportProfileName(string caseSupportProfile){
        if(caseSupportProfile == null){
            caseSupportProfile = 'Legacy Nimble';
        }
        return caseSupportProfile;
    }
    //###################################################################################################### caseNewRecord
    public void caseNewRecord()
    {
        system.debug('#### calling');
        searchBoxdisplay = 'none';
    }
    //#######################################################################################################
    public void productsymptoms(){
        system.debug('SelectedTsaValue--->'+SelectedTsaValue);
        If(SelectedTsaValue == 'Damaged in shipping' || SelectedTsaValue == 'Damaged at customer site not shipping related'){
            displayProductSymptomsForEditPage = true;
        }
        else{
            displayProductSymptomsForEditPage = false;
        }
    }
    
    public List<selectOption> getEstimatedTimeEffort() {
        List<SelectOption> estimatedTimeEffort= new List<SelectOption>();
        Schema.DescribeFieldResult picklistvalueResult = Case.Estimated_Effort__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = picklistvalueResult.getPicklistValues();
        //for(  Schema.PicklistEntry pickListVal : pickListValues ) {
        //estimatedTimeEffort.add(new SelectOption( '0', '--None--'));
        estimatedTimeEffort.add(new SelectOption('5', '5 minutes or less'));
        estimatedTimeEffort.add(new SelectOption('15', '15 minutes'));
        estimatedTimeEffort.add(new SelectOption('30', '30 minutes'));
        estimatedTimeEffort.add(new SelectOption('60', '1 hour'));
        estimatedTimeEffort.add(new SelectOption('120', '2 hours'));
        estimatedTimeEffort.add(new SelectOption('240', '4 hours'));
        estimatedTimeEffort.add(new SelectOption('1440','1 day'));
        //estimatedTimeEffort.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
        //}
        return estimatedTimeEffort;
    }
    
    
    //#######################################################################################################
    public Map<String,list<string> > allTaTsamappings = new Map<string,List<string>>();
    Public List<TechnicalSubArea_Mappings__c> taTsaList = new List<TechnicalSubArea_Mappings__c>();
    public string SelectedTaValue{set;get;}
    public List<Selectoption> allTaMappings ;
    
    public List<SelectOption> getallTaMappings(){
        try{
            allTaMappings = new List<SelectOption>();
            Set<string> TaTsaSet = new set<string>();
			// Added AssetId (cas.AssetId) in the condition for SFDC-2233
            string supportProfileName = getAssetSupportProfileName(cas.AssetId);
            string supportProfile = getCaseSupportProfileName(supportProfileName);               
            taTsaList = getTaTsaList(supportProfile,cas.RecordTypeId);
            system.debug('taTsaList -'+taTsaList);
            for(TechnicalSubArea_Mappings__c TechareaRecord:taTsaList){
                TaTsaSet.add(TechareaRecord.Technical_Area__c);
            }
            allTaMappings.add(new SelectOption('--None--', '--None--'));
            for(String Stringrec: TaTsaSet){
                allTaMappings.add(new SelectOption(Stringrec, Stringrec));
                allTaMappings.sort();
            }
            return allTaMappings;
        }
        Catch(Exception e){
            system.debug('### Exception Occured at getallTaMappings method ### '+e.getMessage());
            return null;
        }
    }
    //#######################################################################################################
    public string SelectedTsaValue{set;get;}
    public List<Selectoption> allTsaMappings {set;get;}
    Public List<TechnicalSubArea_Mappings__c> taTsaListForTsa = new List<TechnicalSubArea_Mappings__c>();
    
    public void allTsaMappingss(){
        
        Id arrayCaseRecId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId();
        Id ssaasCaseRecId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        try{
            system.debug('>>>>>>>>'+SelectedTaValue);
            allTsaMappings = new List<SelectOption>();
            allTsaMappings.add(new SelectOption('--None--', '--None--'));
            // Added "Support_Profile__c includes (:cas.Support_Profile__c)" filter condition for support profile area
            // Added AssetId (cas.AssetId) in the condition for SFDC-2233
            string supportProfileName = getAssetSupportProfileName(cas.AssetId);
            string supportProfile = getCaseSupportProfileName(supportProfileName);
            if(SelectedTaValue != null && SelectedTaValue != ''){
                taTsaListForTsa = getTsaList(supportProfile,SelectedTaValue,cas.RecordTypeId);
            }
            
            
            //taTsaListForTsa = [select id,Technical_SubArea__c,IsDeleted__c,Keywords__c from TechnicalSubArea_Mappings__c where IsDeleted__c=false AND Technical_Area__c=:SelectedTaValue AND Technical_SubArea__c !=null];  
            for(TechnicalSubArea_Mappings__c TechSubareaRecord:taTsaListForTsa){
                allTsaMappings.add(new SelectOption(TechSubareaRecord.Technical_SubArea__c, TechSubareaRecord.Technical_SubArea__c));
                
            }
            allTsaMappings.sort();
        }
        Catch(Exception e){
            system.debug('### Exception Occured at allTsaMappingss method ### '+e.getMessage());
        }
    }
    
    
    //#######################################################################################################
    public pageReference myCustomSave(){
        // Added by Exafort TS-5962
        // Checks for "01234000000BnF4" = Array Case
        // Checks for "0122H000000gkBD" = SSaaS
        
        if((Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'Array Case' || Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'SSaaS') && ((cas.Origin == 'Phone' && cas.Subject == null) || (cas.Origin == 'Phone' && cas.Description == null))){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'When the "Case Origin" is Phone, "Subject" and "Description" fields cannot be blank'));
            return null;
        }
        //End of TS-5962
        
        //	Added By Exafort TS-10404 to Show error Message when Peer Flag is Checked when Creating a New Case
        /*	Below error message commented by Exafort for SFDC-478	
         *	As a part of SFDC-478, this validation rule is no longer required, user can set peer flag inactive to true 
         */  
        /*if(displayFieldsForEditPage == False && cas.Peer_Flag_Inactive__c == True && 
           (Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'Array Case' ||
            Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'InfoSight Portal' ||
            Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'SSaaS' ||
            Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'NCV Case')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Peer Flag Inactive cannot be true when creating case'));
                return null;
            }*/
        // End of TS-10404
        
        //	Added by Exafort for SFDC-936 
        if (cas.Id == null){
            if(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'Array Case' || Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'SSaaS'){
                if ((cas.Status == 'Waiting on Internal' || cas.Status == 'Waiting on Customer' || cas.Status == 'In Progress' )  && cas.Sub_Status__c == null ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Sub-Status cannot be blank for the case when Status is: "'+ cas.Status +'"'));
                    return null; 
                }
                if ((cas.Status == 'Remote Session Scheduled' || cas.Status == 'On Hold') && cas.Timer_Expiry_Override_Date__c == null ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'When the "Status" is "'+ cas.Status +'", "Timer Expiry Manual/Override Date" Cannot be blank'));
                    return null;
                }
                if (cas.Timer_Expiry_Override_Date__c < System.now()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Timer Expiry Manual/Override Date must be greater than or equal to the current date and time'));
                    return null; 
                }
                 if (cas.Status == 'Resolved' || cas.Status == 'Handover' || cas.Status == 'Update Needed'){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Status "' + selectedStatus + '" is not allowed when creating a new Case.'));
                    return null;  
                }
                
            }
        }
        //	Ended By Exafort for SFDC-936
        
        if (cas.Id != null){
            //NTelkar -  Added logic for TS-7239
            if(cas.Status == 'Open' && cas.ClosedDate!= null && (Date.valueOf(cas.ClosedDate)).daysBetween(System.today()) > 180){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Its been more than 180 days since the case closed, so it cannot be opened manually'));
                return null;
            }
            
            //Ntelkar -  Added logic for SFDC-1165
            Case currentCaseToSave = [SELECT OwnerId FROM Case WHERE Id = :cas.Id LIMIT 1];
            if(cas.ownerId != currentCaseToSave.OwnerId){
                System.debug('The current case owner Id is :' + cas.ownerId);
                cas.ownerId = currentCaseToSave.OwnerId;
                System.debug('The owner id after modification is :' + cas.ownerId);
            }
            
            //Added by Ntelkar - TS-8195 and TS-9532
            try{
                Case casePSM = [SELECT Account.ACM_Service_Purchased__c, Account.CS_PSM__c, Auto_Open__c, Auto_Close__c, Account.Primary_PSM__r.Id, Account.Primary_CS_PSM__r.Id FROM Case WHERE Id =: cas.Id];
                if((casePSM.Account.ACM_Service_Purchased__c == true || casePSM.Account.CS_PSM__c == true) && casePSM.Auto_Close__c == false){
                    List<CaseTeamMember> psmList = new List<CaseTeamMember> ();
                    List<CaseTeamMember> ctmSet = new List<CaseTeamMember>();
                    CaseTeamRole ctr = [SELECT Id from CaseTeamRole WHERE Name = 'Proactive Support Manager']; 
                    psmList = [SELECT Id FROM CaseTeamMember WHERE parentId =: cas.Id and TeamRoleId = :ctr.Id];
                    if(psmList.isEmpty()){
                        if(casePSM.Account.Primary_PSM__r.Id != null){
                            CaseTeamMember ctm1 = new CaseTeamMember();
                            ctm1.MemberId = casePSM.Account.Primary_PSM__r.Id;
                            ctm1.ParentId = cas.Id;
                            ctm1.TeamRoleId = ctr.Id;
                            ctmSet.add(ctm1);
                        }if(casePSM.Account.Primary_CS_PSM__r.Id != null){
                            CaseTeamMember ctm2 = new CaseTeamMember();
                            ctm2.MemberId = casePSM.Account.Primary_CS_PSM__r.Id;
                            ctm2.ParentId = cas.Id;
                            ctm2.TeamRoleId = ctr.Id;
                            ctmSet.add(ctm2);
                        }if(!ctmSet.isEmpty())
                            insert ctmSet;
                    }
                }
            }catch(Exception ex){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            }//End of TS-8195 and TS-9532
            
            Case thisCase = [SELECT Estimated_Effort__c,Current_comment_time_spent__c, ClosedDate FROM Case WHERE Id =: cas.Id];
            if(SelectedTaValue == '--None--' || SelectedTaValue == '' || SelectedTaValue == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Technical Area'));
                return null;
            }
            if(SelectedTsaValue == '--None--' || SelectedTsaValue == ''  || SelectedTsaValue == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Technical Sub Area'));
                return null;
            }
            
            //	Added by Exafort for SFDC-936
            //	cas.Status == 'New' || this has been removed for SFDC-1503
            if (Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'Array Case' || Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'SSaaS'){
                if ((cas.Status == 'Waiting on Internal' || cas.Status == 'Waiting on Customer' || cas.Status == 'In Progress' )  && cas.Id != null && cas.Sub_Status__c == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Sub-Status cannot be blank for the case when Status is: "'+ cas.Status +'".'));
                    return null; 
                }
                if ((cas.Status == 'Remote Session Scheduled' || cas.Status == 'On Hold') && cas.Timer_Expiry_Override_Date__c == null ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'When the "Status" is "'+ cas.Status +'", "Timer Expiry Manual/Override Date" Cannot be blank.'));
                    return null;
                }
                if (existingCase.Timer_Expiry_Override_Date__c != cas.Timer_Expiry_Override_Date__c && cas.Timer_Expiry_Override_Date__c < System.now()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Timer Expiry Manual/Override Date must be greater than or equal to the current date and time.'));
                    return null;  
                }
                 //	Added by Exafort for SFDC-935
                if ((cas.Status == 'Handover' && cas.Status != existingCase.Status) || (cas.Status == 'Update Needed' && cas.Status != existingCase.Status)){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The Status "' + selectedStatus + '" should not be set manually'));
                    return null;  
                }
                //	Ended By Exafort for SFDC-935
            }
            //	Ended By Exafort for SFDC-936
     
            //Added By Exafort for SFDC-307
            // If condition updated by exafort for TS-10695
            /*if((selectedVersion == '--None--' || selectedVersion == ''  || selectedVersion == null) && 
               ((Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() != 'InfoSight Portal') &&
               (Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() != 'OPS Case') && 
               (Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() != 'SDOE'))){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Software Version'));
                   return null;
               }*///	Removed by Exafort for SFDC-1152 - As this field is not required fields. 
            
            if(selectedVersion != '--None--')
            cas.Nimble_Version__c = selectedVersion;
            //End of SFDC-307
            
            // Added by Exafort for TS-8034
            /*if(cas.Case_closure_time_spent__c  < 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'You cannot enter a negative value in field - ADD minutes to “Total Time Effort”'));
                return null;
            }*/ //Exafort for SFDC-1152 - field is removed from the layout
            
            List<String> selectedValues = new List<String>();
            if(SelectedTaValue != '--None--' && SelectedTsaValue != '--None--'){
                cas.Technology_Area__c = SelectedTaValue;
                cas.Sub_Technology_Area__c = SelectedTsaValue;
                if(SelectedProductSymptoms.size() > 0){
                    cas.Product_Damage_Symptoms__c = '';
                    for(SelectOption Psymptoms: SelectedProductSymptoms){
                        selectedValues.add(Psymptoms.getValue());
                    }
                    cas.Product_Damage_Symptoms__c = String.join(selectedValues,';'); 
                }  
            }
            //Added by vishnu for TS-8809
            //changed on 2/10/2023 by Nagalaxmi Telkar - Added code for TS-8035
            /*if(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() != 'InfoSight Portal'){
                if(thisCase.Estimated_Effort__c != null && thisCase.Estimated_Effort__c != 'none' && thisCase.Estimated_Effort__c != 'N/A' && cas.Case_Effort_Summary_Total__c == 0 ){
                    String formattedStr = thisCase.Estimated_Effort__c;
                    String[] strArr = formattedStr.split(' ');
                    Decimal totalTimeEffort = 0;
                    if(strArr.size() == 1){
                        if(strArr[0].isNumeric()){
                            if(cas.Case_closure_time_spent__c != null)
                                totalTimeEffort = cas.Case_closure_time_spent__c + Decimal.ValueOf(strArr[0]);
                            else
                                totalTimeEffort = Decimal.ValueOf(strArr[0]);
                            loadCaseEstimatedEffort(cas,'editSave', totalTimeEffort);
                        }
                        else{
                            String numberOnly = strArr[0].replaceAll('[^0-9]', '');
                            if(cas.Case_closure_time_spent__c != null)
                                totalTimeEffort = cas.Case_closure_time_spent__c + Decimal.ValueOf(numberOnly);
                            else
                                totalTimeEffort = Decimal.ValueOf(numberOnly);
                            loadCaseEstimatedEffort(cas,'editSave', totalTimeEffort );
                        }
                    }
                    else if(strArr.size() == 2){
                        if(formattedStr.contains('minutes') || formattedStr.contains('min')){
                            if(cas.Case_closure_time_spent__c != null)
                                totalTimeEffort = cas.Case_closure_time_spent__c + Decimal.ValueOf(strArr[0]);
                            else
                                totalTimeEffort = Decimal.ValueOf(strArr[0]);
                            loadCaseEstimatedEffort(cas,'editSave', totalTimeEffort); 
                        }else if(formattedStr.contains('hour') || formattedStr.contains('hours') || formattedStr.contains('hr')){
                            if(cas.Case_closure_time_spent__c != null)
                                totalTimeEffort = cas.Case_closure_time_spent__c + Decimal.ValueOf(strArr[0]) * 60;
                            else
                                totalTimeEffort = Decimal.ValueOf(strArr[0]) * 60;
                            loadCaseEstimatedEffort(cas,'editSave', totalTimeEffort); 
                        }else if(formattedStr.contains('day')){
                            if(cas.Case_closure_time_spent__c != null)
                                totalTimeEffort = cas.Case_closure_time_spent__c + Decimal.ValueOf(strArr[0]) * 24 * 60;
                            else
                                totalTimeEffort = Decimal.ValueOf(strArr[0]) * 24 * 60;  
                            loadCaseEstimatedEffort(cas,'editSave', totalTimeEffort);
                        }else if(formattedStr.equals('one hour')){
                            if(cas.Case_closure_time_spent__c != null)
                                totalTimeEffort = cas.Case_closure_time_spent__c + Decimal.ValueOf(strArr[0]) * 60;
                            else
                                totalTimeEffort = Decimal.ValueOf(strArr[0]) * 60;
                            loadCaseEstimatedEffort(cas,'editSave', totalTimeEffort);
                        }
                    } else if(strArr.size() == 4){
                        String numberOnly = formattedStr.replaceAll('[^0-9]', '');
                        if(formattedStr.contains('min')){
                            if(cas.Case_closure_time_spent__c != null)
                                totalTimeEffort = cas.Case_closure_time_spent__c + Decimal.ValueOf(numberOnly);
                            else
                                totalTimeEffort = Decimal.ValueOf(numberOnly);
                            loadCaseEstimatedEffort(cas,'editSave', totalTimeEffort);
                        }else if(formattedStr.contains('hour')){
                            if(cas.Case_closure_time_spent__c != null)
                                totalTimeEffort = cas.Case_closure_time_spent__c + Decimal.ValueOf(numberOnly) * 60;
                            else
                                totalTimeEffort = Decimal.ValueOf(numberOnly) * 60;
                            loadCaseEstimatedEffort(cas,'editSave', totalTimeEffort);
                        }else if(formattedStr.contains('day')){
                            if(cas.Case_closure_time_spent__c != null)
                                totalTimeEffort = cas.Case_closure_time_spent__c + Decimal.ValueOf(numberOnly) * 24 * 60;
                            else
                                totalTimeEffort = Decimal.ValueOf(numberOnly) * 24 * 60;
                            loadCaseEstimatedEffort(cas,'editSave', totalTimeEffort);
                        }      
                    }
                }else if(cas.Case_closure_time_spent__c != null && cas.Case_Effort_Summary_Total__c != 0){
                    loadCaseEstimatedEffort(cas,'editSave', cas.Case_closure_time_spent__c); 
                }
                else if(estTimeEff != null){
                    loadCaseEstimatedEffort(cas,'editSave', Decimal.ValueOf(estTimeEff)); 
                }
            }*/
            
            ApexPages.StandardController Controller = new ApexPages.StandardController(cas);
            if(!test.isRunningTest())
                return controller.save();
            else 
                return null;
        }else{
            // Added By Exafort for SFDC-307
            if(selectedVersion != '--None--')
                cas.Nimble_Version__c = selectedVersion;
            
            //Added By Exafort for SFDC-307
            /*if((selectedVersion == '--None--' || selectedVersion == ''  || selectedVersion == null) && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() == 'NCV Case' ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Software Version'));
                return null;
            }*///	Removed by Exafort for SFDC-1152 - As this field is not required fields. 
            
            if(cas.Case_closure_time_spent__c != null)
                loadCaseEstimatedEffort(cas,'newSave', cas.Case_closure_time_spent__c);
            else
                if(estTimeEff != null)
                loadCaseEstimatedEffort(cas,'newSave', Decimal.ValueOf(estTimeEff));
            else 
                loadCaseEstimatedEffort(cas,'newSave', 0);
            if(!test.isRunningTest()){
                PageReference casePage = new ApexPages.StandardController(cas).view();
                casePage.setRedirect(true);
                return casePage;
            }
        }
        return null;
    }
    
    //Added by vishnu for TS-8809
    //changed on 2/10/2023 by Nagalaxmi Telkar - Added code for TS-8035
    public void loadCaseEstimatedEffort(case casedetail,string params, Decimal timeValue){        
        if(params == 'newSave'){
            cas.Estimated_Effort__c = String.valueOf(timeValue);
            cas.caseClosureEstimatedEffort__c = String.valueOf(timeValue);
            cas.Case_closure_time_spent__c  = null;     
            cas.Current_comment_activity__c = null;
            insert cas;
            
            Case_Effort_Tracking__c commentTracking = new Case_Effort_Tracking__c();
            commentTracking.CaseId__c = cas.Id;
            if(caseOwnerType == 'Queue')
                commentTracking.Effort_Queue__c = caseOwnerName;
            else
                commentTracking.Effort_Owner__c = caseOwnerId;
            
            commentTracking.Effort_Amount__c = Integer.valueOf(timeValue);                         
            commentTracking.Effort_Origin__c = 'Case';
            commentTracking.Effort_Timestamp__c = Datetime.now();
            if(cas.Current_comment_activity__c  == null)
                commentTracking.Effort_Type__c  = 'General Case Work';  
            else
                commentTracking.Effort_Type__c = cas.Current_comment_activity__c;
            
            commentTracking.Effort_User__c = UserInfo.getUserId();       
            if(!test.isRunningTest())
                insert commentTracking;
        } 
        /*if(params == 'editSave'){
            Case_Effort_Tracking__c commentTracking = new Case_Effort_Tracking__c();
            commentTracking.CaseId__c = cas.Id;
            commentTracking.Effort_Amount__c = timeValue;                      
            commentTracking.Effort_Origin__c = 'Case';
            commentTracking.Effort_Timestamp__c = Datetime.now();
            if(caseOwnerType == 'Queue')
                commentTracking.Effort_Queue__c = caseOwnerName;
            else
                commentTracking.Effort_Owner__c = caseOwnerId;
            
            if(cas.Current_comment_activity__c  == null)
                commentTracking.Effort_Type__c  = 'General Case Work';  
            else
                commentTracking.Effort_Type__c = cas.Current_comment_activity__c;
            commentTracking.Effort_User__c = UserInfo.getUserId(); 
            if(!test.isRunningTest())
                insert commentTracking;
            cas.caseClosureEstimatedEffort__c = String.valueOf(timeValue + Integer.valueOf(cas.Case_Owner_Time_Effort__c) + Integer.valueOf(cas.Non_Case_Owner_Time_Effort__c));
            cas.Case_closure_time_spent__c  = null;   
            cas.Current_comment_activity__c = null;
            // Added for Exafort TS-10404
            // Added the Try catch to stop showing the DML exception along with the validation error and show only the Validation Error From CaseTrigger
            try{
                update cas;
            }
            catch(DMLException e){
                for ( Integer i = 0; i < e.getNumDml(); i++ ) {
                    cas.addError('Failed to update the case record. Please address the issue with case : ' + e.getDmlMessage(i));
                }
            }
            // End of TS-10404
        } */
    }
    
    // Added by Exafort for Code Optimization.
    public list<TechnicalSubArea_Mappings__c> getTaTsaList(String supportProfile,string caseRecordTypeId){  
        string caseRecodTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseRecordTypeId).getName();
        List<TechnicalSubArea_Mappings__c> taTSAReturnList = new List<TechnicalSubArea_Mappings__c>(); 
        if(caseRecodTypeName == 'Array Case' || caseRecodTypeName == 'NCV Case' || caseRecodTypeName == 'SSaaS' ){
            //	Added by Exafort for SFDC-523
            taTSAReturnList = [select id, Technical_Area__c,Technical_SubArea__c,IsDeleted__c,Keywords__c,Case_Types__c from TechnicalSubArea_Mappings__c
                               where IsDeleted__c=false AND Technical_Area__c !=null AND Technical_SubArea__c !=null AND 
                               Case_Types__c includes (:caseRecodTypeName) AND Support_Profile__c includes (:supportProfile)];
            return taTSAReturnList;
            //	End of SFDC-523
        }
        if(caseRecodTypeName == 'InfoSight Portal'){
            //	Added by Exafort for SFDC-523
            taTSAReturnList = [select id, Technical_Area__c,Technical_SubArea__c,IsDeleted__c,Keywords__c,Case_Types__c from TechnicalSubArea_Mappings__c
                               where IsDeleted__c=false AND Technical_Area__c !=null AND Technical_SubArea__c !=null AND 
                               Case_Types__c includes (:caseRecodTypeName) AND Support_Profile__c includes (:supportProfile) ORDER BY Technical_Area__c ASC,Technical_SubArea__c ASC];
            return taTSAReturnList;
            //	End of SFDC-523
        }
        return null;
    }
    
    // Added by Exafort for Code Optimization.
    public list<TechnicalSubArea_Mappings__c> getTsaList(String supportProfile,String SelectedTaValue, string caseRecordTypeId){
        string caseRecodTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseRecordTypeId).getName();
        List<TechnicalSubArea_Mappings__c> tsaReturnList = new List<TechnicalSubArea_Mappings__c>();
        if(caseRecodTypeName == 'Array Case' || caseRecodTypeName == 'NCV Case' || caseRecodTypeName == 'SSaaS' || caseRecodTypeName == 'InfoSight Portal'){
            //	Added by Exafort for SFDC-523
            tsaReturnList = [select id, Technical_Area__c,Technical_SubArea__c,IsDeleted__c,Keywords__c,Case_Types__c from TechnicalSubArea_Mappings__c
                             where IsDeleted__c=false AND Technical_Area__c !=null AND Technical_SubArea__c !=null AND Case_Types__c includes (:caseRecodTypeName)
                             AND Technical_Area__c =: SelectedTaValue AND Support_Profile__c includes (:supportProfile)];
            return tsaReturnList;
            //	End of SFDC-523
        }
        return null;
    }
    //Added by Exafort for SFDC-2233
    private string getAssetSupportProfileName(String assetId){
        return (assetId == null ? null : [select id,Support_Profile__c from case where id=:cas.id limit 1].Support_Profile__c);
    }
    //Ended by Exafort for SFDC-2233
}