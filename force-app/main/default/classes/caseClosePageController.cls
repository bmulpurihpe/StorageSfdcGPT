/* Class Name: caseClosePageController
* Purpose: This is controller class for case close page(caseClosePage)
* Main feature: fetching auto complete/auto search data set from TechnicalSubArea Mappings object and forming a JSON data
* Author: Exafort(Azar)
* Created Date: 11th Dec 2017
* Change Log: changed on 16th March 2018
* Change log : changed on 2/10/2023 by Nagalaxmi Telkar - Added code for TS-8035
* Change log : changed on 4/11/2023 by Nagalaxmi Telkar - Added code for TS-9242
* */ 

public with sharing class caseClosePageController {
    public Case cas{get;set;}
    public String estTimeEff{get;set;}
    private ApexPages.StandardController controller;
    public Solution caseSolution{get;set;}
    public string fieldDependencies{get;set;} 
    public string caseOwnerType{get;set;} 
    public string caseOwnerName{get;set;} 
    public string caseOwnerId{get;set;} 
    public string strFieldSeverity; //Added by Ntelkar for TS-9491
    public string strFieldPriority; //Added by Ntelkar for TS-9491
    public string strFieldIsStorageDefect; //Added by Ntelkar for TS-9242
    Public List<SelectOption> supportedVersions{get;Set;} //    Added By Exafort for SFDC-307
    Public string selectedVersion{set;get;} //  Added By Exafort for SFDC-307
    public String selectedStatus { get; set; } // Added by Exafort for SFDC-936
    public String casNimbleVersion { get; set; }
    public String assetOsVersion { get; set; }
    public String warningMessage { get; set; }
    public Boolean showWarning { get; set; }
    public Boolean userConfirmedOverride { get; set; }
    
    //  Added By Exafort for SFDC-727
    public Boolean showCombinedWarning { get; set; }
    public String combinedWarningMessage { get; set; }
    public Boolean showCancelButton { get; set; }
   //   Ended By Exafort for SFDC-727
    
    /** constructor method **/
    public caseClosePageController(ApexPages.StandardController controller){
        showWarning = False;
        userConfirmedOverride = False;
        this.controller = controller;
        cas=(Case) controller.getRecord();        
        fieldDependencies='';
        system.debug('### case record type ### '+cas.RecordTypeId);
        //call data set method for auto complete box. Load the data when the constructor is called.
        getDependentOptionsImpl();
        //Owner.Id,Owner.Name,Owner.Type Added by exafort on 9/16/2020 TS-3370
        //case getTa = [Select Id,Technology_Area__c,Nimble_Version__c,Support_Profile__c,Sub_Technology_Area__c,Owner.Id,Owner.Name,Owner.Type,Case_Effort_Summary_Total__c, Case_Owner_Time_Effort__c from Case where Id=:cas.Id];
        //  Added 2 additional fields to the select query By Exafort for SFDC-307
        case getTa = [Select Id, Technology_Area__c, Sub_Technology_Area__c, Owner.Id, Owner.Name, Owner.Type, Case_Effort_Summary_Total__c, Case_Owner_Time_Effort__c, Nimble_Version__c, Support_Profile__c,caseAssetNimbleOSVersion__c from Case where Id=:cas.Id];
        SelectedTaValue = getTa.Technology_Area__c;
        SelectedTsaValue = getTa.Sub_Technology_Area__c;
        
        //  Added By Exafort for SFDC-307
        selectedVersion =  getTa.Nimble_Version__c;
        
        system.debug('SelectedVersion:'+SelectedVersion);
        caseOwnerType = getTa.Owner.Type;// Added by exafort on 9/16/2020 TS-3370
        caseOwnerName = getTa.Owner.Name;// Added by exafort on 9/16/2020 TS-3370
        caseOwnerId = getTa.Owner.Id;// Added by exafort on 9/16/2020 TS-3370
        allTaMappings = new List<SelectOption>();
        allTsaMappings = new List<SelectOption>();
        allTsaMappingss();
        //Added by exafort for SFDC-307
        setSoftwareVersionsOnCaseEdit(getTa.Support_Profile__c,SelectedVersion);
        //  Added by exafort for SFDC-936
        onChangeStatus();
    }
    
    //Added by Ntelkar for TS-9491
    public void changeSeverity() {
        if(strFieldSeverity == 'Critical')
            cas.Severity__c = 'Critical';
        if(strFieldSeverity == 'Critical - Degraded')
            cas.Severity__c = 'Critical - Degraded';
        if(strFieldSeverity == 'Normal')
            cas.Severity__c = 'Normal';
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
    
    //Added by Ntelkar for TS-9242
    public String getStrFieldIsStorageDefect(){
        return strFieldIsStorageDefect;
    }
    
    //Added by Ntelkar for TS-9242
    public void setStrFieldIsStorageDefect(String strVal) {
        strFieldIsStorageDefect = strVal;
    }
    
    //Added by Ntelkar for TS-9242
    public void getIsNimbleStorageDefect(){
        setValueForIsNimbleDefect();
    }
    
    //Added by Ntelkar for TS-9242
    public void setValueForIsNimbleDefect() {
        if(strFieldIsStorageDefect == 'No')
            cas.caseIsThisCaseRelatedToANimbleProduct__c = 'No';
        if(strFieldIsStorageDefect == 'Yes')
            cas.caseIsThisCaseRelatedToANimbleProduct__c = 'Yes';
    }
    
    //  Added By Exafort for SFDC-307    
    /* This method is called on case edit page constructor to set version value */
    public void setSoftwareVersionsOnCaseEdit(string caseSupportProfile,string caseActualVersion){ // Change method Name 
        supportedVersions = new List<SelectOption>();
        supportedVersions.add(new SelectOption('--None--', '--None--'));
        string supportProfileName = caseSupportProfile;
        string supportProfile = getCaseSupportProfileName(supportProfileName);
        
        //Add all the versions belongs to the case support Profile
        list<SelectOption> allVersionList = caseNewOrEditPageController.getVersionsBasedOnSupportProfile(supportProfile,caseActualVersion);
        if(allVersionList != null){
            supportedVersions.addAll(allVersionList);            
        }
        supportedVersions.sort(); 
    } 
    
    public string getCaseSupportProfileName(string caseSupportProfile){
        if(caseSupportProfile == null){
            caseSupportProfile = 'Legacy Nimble';
        }
        return caseSupportProfile;
    }
    // End of SFDC-307
    
    //Method to get the data set for auto complete from TechnicalSubArea Mappings object
    public void getDependentOptionsImpl() {
        //Query TechnicalSubArea Mappings object to get all the necessary details to form a JSON data for auto complete
        List<TechnicalSubArea_Mappings__c> taTsaMap = new List<TechnicalSubArea_Mappings__c>();
        //Support Product Area
        string supportProfile = [select id,Support_Profile__c,caseAssetNimbleOSVersion__c from case where id=:cas.id limit 1].Support_Profile__c;
        if(supportProfile == '' || supportProfile == Null){
            supportProfile = 'Legacy Nimble'; 
        }
        taTsaMap = getTaTsaList(supportProfile,cas.RecordTypeId,1);
        for(TechnicalSubArea_Mappings__c taTSARec : taTsaMap){
            taTSARec.Technical_Area__c = taTSARec.Technical_Area__c.trim();
            taTSARec.Technical_SubArea__c = taTSARec.Technical_SubArea__c.trim();
            //Wherever keywords are empty just assign '' to avoid unexpected cases
            if(taTSARec.Keywords__c == null)
                taTSARec.Keywords__c = '';
            //Some keywords would contain " (ex "term", will produce '"term"' in JSON) which will affect JSON format. So putting escape sequances wherever " 
            if(taTSARec.Technical_SubArea__c.contains('"')){
                taTSARec.Technical_SubArea__c = taTSARec.Technical_SubArea__c.replace('"', '\\"');
            }
            //fieldDependencies+= '{"techarea":"'+taTSARec.Technical_Area__c+'","subtecharea":"'+taTSARec.Technical_SubArea__c+'","keywords":"'+taTSARec.Keywords__c+'","label":"'+taTSARec.Technical_Area__c+' => '+taTSARec.Technical_SubArea__c+' => "},';
            //Forming JSON format with collected items
            fieldDependencies+= '{"techarea":"'+taTSARec.Technical_Area__c+'","subtecharea":"'+taTSARec.Technical_SubArea__c+'","keywords":"'+taTSARec.Keywords__c+'","label":"'+taTSARec.Technical_Area__c+' => '+taTSARec.Technical_SubArea__c+' => '+taTSARec.Keywords__c+' => "},';
            
        }
        //Remove the trailing , from the JSON data
        fieldDependencies = fieldDependencies.removeEnd(',');
        //connot be considered as JSON if we dont have []
        fieldDependencies = '['+fieldDependencies+']';
        
        system.debug('@@@ fieldDependencies @@@ '+fieldDependencies);
        //return fieldDependencies;
    }
    
    //Method to display only Closed status values in Status picklist field.
    public List<SelectOption> getClosedStatus(){
        try{
            List<selectOption> options = new List<selectOption>(); 
            //options.add(new selectOption('', '- None -'));
            List<CaseStatus> caseStatusList = [Select Id, MasterLabel From CaseStatus Where IsClosed = true];
            for(CaseStatus statusLoop: caseStatusList){
                options.add(new selectOption(statusLoop.MasterLabel, statusLoop.MasterLabel));
            }
            return options;
        }
        Catch(Exception e){
            system.debug('### Exception Occured at getClosedStatus method ### '+e.getMessage());
            return null;
        }
    }
    // Added by Exafort for SFDC - 936
    public  PageReference onChangeStatus() {
        //loadSubStatusOptions();
        getClosedSubStatusOptions();
        return null;
    }
    
    // Controller method to fetch Sub Status options based on Status = 'Closed'
    public List<SelectOption> getClosedSubStatusOptions() {
        System.Debug('The starus is coming');
        System.Debug('The starus is '+ selectedStatus);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '- None -'));
        
        try {
            if (String.isBlank(selectedStatus)) {
                System.Debug('The starus is null');
                return options;
            }
            // If status is Merged → Return only '- None -'
            if (selectedStatus == 'Merged') {
                System.Debug('The starus is Open');
                return options;
            }
            // If status is Closed → Fetch related sub statuses
            if (selectedStatus == 'Closed') {
                System.Debug('The starus is closed');
                List<Case_Sub_Status_Mapping__c> mappingList = [
                    SELECT Sub_Status__c 
                    FROM Case_Sub_Status_Mapping__c 
                    WHERE Status__c = 'Closed'];
                //Added by Exafort for SFDC-2180
                Set<String> allowedSubStatuses = new Set<String>{'No Response from Customer','Customer Approved'};
                
                for (Case_Sub_Status_Mapping__c subStatusLoop : mappingList) {
                    if (allowedSubStatuses.contains(subStatusLoop.Sub_Status__c)) {
                        options.add(new SelectOption(subStatusLoop.Sub_Status__c, subStatusLoop.Sub_Status__c));
                    }
                }
                if (cas.Sub_Status__c == 'Duplicate' && !options.contains(new SelectOption('Duplicate', 'Duplicate'))) {
                        options.add(new SelectOption('Duplicate', 'Duplicate'));
                    }
            }
            //End of SFDC-2180
            
            return options;
        } catch (Exception e) {
            System.debug('### Exception in getClosedSubStatusOptions: ' + e.getMessage());
            return options;
        }
    }
    
    // Ended by Exafort for SFDC - 936
    //#######################################################################################################
    public Map<String,list<string> > allTaTsamappings = new Map<string,List<string>>();
    Public List<TechnicalSubArea_Mappings__c> taTsaList = new List<TechnicalSubArea_Mappings__c>();
    public string SelectedTaValue{set;get;}
    public List<Selectoption> allTaMappings ;
    
    public List<SelectOption> getallTaMappings(){
        try{
            allTaMappings = new List<SelectOption>();
            Set<string> TaTsaSet = new set<string>();
            //Support Product Area
            string supportProfile = [select id,Support_Profile__c,caseAssetNimbleOSVersion__c from case where id=:cas.id limit 1].Support_Profile__c;
            if(supportProfile == '' || supportProfile == Null){
                supportProfile = 'Legacy Nimble'; 
            }
            taTsaList = getTaTsaList(supportProfile,cas.RecordTypeId,2); 
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
        try{
            system.debug('>>>>>>>>'+SelectedTaValue);
            allTsaMappings = new List<SelectOption>();
            allTsaMappings.add(new SelectOption('--None--', '--None--'));
            system.debug('## cas.RecordTypeId'+cas.RecordTypeId);
            if(SelectedTaValue != null && SelectedTaValue != ''){
                //Support Product Area
                string supportProfile = [select id,Support_Profile__c,caseAssetNimbleOSVersion__c from case where id=:cas.id limit 1].Support_Profile__c;
                if(supportProfile == '' || supportProfile == Null){
                    supportProfile = 'Legacy Nimble'; 
                }
                taTsaListForTsa = getTsaList(supportProfile,SelectedTaValue,cas.RecordTypeId);
                
            }
            
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
    public pageReference myCustomSave()
    {
        //	Added By Exafort for SFDC-1789 to resolve the popup stuck issue on case close.
        if(userConfirmedOverride == true){
            showCombinedWarning = false;
        }
        //	End of SFDC-1789
        if(SelectedTaValue == '--None--' || SelectedTaValue == '' || SelectedTaValue == null ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Technical Area'));
            return null;
        }
        if(SelectedTsaValue == '--None--' || SelectedTsaValue == ''  || SelectedTsaValue == null ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Technical Sub Area'));
            return null;
        }
        
        //  Begin - Added By Exafort for SFDC-307
        //  If condition updated by exafort for TS-10695
        if((selectedVersion == '--None--' || selectedVersion == ''  || selectedVersion == null) && 
           Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName() != 'InfoSight Portal'){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Software Version'));
               return null;
           }
        
        //  Added By Exafort for SFDC-727
        List<String> warningLines = new List<String>(); 
        List<String> warningVersionLines = new List<String>();
        List<String> warningOpentypeLines = new List<String>();
        //  Ended By Exafort for SFDC-727
        
        // Added by Exafort for SFDC-524
        casNimbleVersion  = selectedVersion;
        //	assetOsVersion = cas.caseAssetNimbleOSVersion__c;
        // 	assetOsVersion updated by Exafort for SFDC-2165
        assetOsVersion = cas.Asset.assetNimbleOsVersion__c;
        cas.Nimble_Version__c = selectedVersion;
        system.debug('Case Asset : ' + cas.assetId);
        system.debug('Case Auto close staus : ' + cas.Auto_Close__c);
        //system.debug('Auto support last received : ' + cas.asset.Autosupport_Last_Received__c);
        Integer daysSinceLastReceived = -1 ;
        if(cas.asset.Autosupport_Last_Received__c != null){
            Date today = Date.today();
            Date lastReceivedDate = cas.asset.Autosupport_Last_Received__c.date();
            if (lastReceivedDate != null){
                daysSinceLastReceived = lastReceivedDate.daysBetween(today);
                system.debug('daysSinceLastReceived : ' + daysSinceLastReceived);
                if(!userConfirmedOverride && casNimbleVersion != 'Unknown' && assetOsVersion != 'Unknown' && casNimbleVersion != null && 
                   assetOsVersion != null && cas.Auto_Close__c == false && (daysSinceLastReceived >= 0 && daysSinceLastReceived <= 5)){
                       if (compareVersions(casNimbleVersion, assetOsVersion) < 0) {
                           system.debug('Entered to compare software version');
                           warningVersionLines.add('Selected Software Version is lower than Asset\'s OS Version. Click OK to save anyway, or Cancel to update the Software Version.');
                           warningLines.add('Selected Software Version is lower than Asset\'s OS Version. Click OK to save anyway, or Cancel to update the Software Version.');
                           showWarning = True;
                           //return null;
                       } 
                   }
            }
        }
        // End of SFDC-524
        
        
        system.debug('cas.Nimble_Version__c : ' + cas.Nimble_Version__c);
        system.debug('Asset OS Version : ' + cas.caseAssetNimbleOSVersion__c);
        //  End - Changes by Exafort for SFDC-307
        
        if(SelectedTaValue != '--None--' && SelectedTsaValue != '--None--'){
            cas.Technology_Area__c = SelectedTaValue;
            cas.Sub_Technology_Area__c = SelectedTsaValue;
        }
        
        // Added by Exafort for SFDC-727 
        Set<String> openTypes = new Set<String>();
        
        // Perform a single query to get related child records using subqueries
        Case c = [
            SELECT Id,
            (SELECT Id FROM Case_Escalations__r WHERE Escalation_Closure_Status__c = 'Open' LIMIT 1),
            (SELECT Id FROM Management_Escalations__r WHERE Status__c != 'Closed' LIMIT 1),
            (SELECT Id FROM ESCA_Consult__r WHERE Status__c NOT IN ('Closed', 'Auto Closed') LIMIT 1)
            FROM Case
            WHERE Id = :cas.Id
        ];
        
        // Check each child relationship result
        if (!c.Case_Escalations__r.isEmpty()) {
            openTypes.add('Case Escalations');
        }
        if (!c.Management_Escalations__r.isEmpty()) {
            openTypes.add('Management Escalations');
        }
        if (!c.ESCA_Consult__r.isEmpty()) {
            openTypes.add('Consults');
        }
        
        // Add error message if any are open
        if (!openTypes.isEmpty()) {
            System.debug('Adding warning messages');
            warningOpentypeLines.add('This case has one or more open ' +
                             String.join(new List<String>(openTypes), ' , ') +
                             '.');
            warningLines.add('Note that this case has one or more open ' +
                             String.join(new List<String>(openTypes), ' , ') +
                             '.');
           
        }
        // If any warnings found
        if (!warningVersionLines.isEmpty() && !warningOpentypeLines.isEmpty() && !userConfirmedOverride) {
            showCombinedWarning = true;
            showCancelButton = true;
            combinedWarningMessage = String.join(warningLines, ' <br/><br/>'); // separated by new lines
            return null;
        }
        else if(!warningVersionLines.isEmpty() && !userConfirmedOverride){
            showCombinedWarning = true;
            showCancelButton = true;
            combinedWarningMessage = String.join(warningVersionLines, ' <br/><br/>'); // separated by new lines
            return null; 
        }
        else if(!warningOpentypeLines.isEmpty() && !userConfirmedOverride) {
            showCombinedWarning = true;
            showCancelButton = false;
            combinedWarningMessage = String.join(warningOpentypeLines, ' <br/><br/>'); // separated by new lines
            return null; 
        }
        // Ended by Exafort for SFDC-727
        // Added by Exafort for TS-8034
        /*if(cas.Case_closure_time_spent__c  < 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'You cannot enter a negative value in field - ADD minutes to “Total Time Effort”'));
            return null;
        }*/
        //Added by exafort on 9/16/2020 START - TS-3370  
        //Capture the effort details in 'Case effort tracking' object      
        /*if(cas.Case_closure_time_spent__c != null){
            Case_Effort_Tracking__c commentTracking = new Case_Effort_Tracking__c();
            commentTracking.CaseId__c = cas.Id;
            if(caseOwnerType == 'Queue')
                commentTracking.Effort_Queue__c = caseOwnerName;
            else
                commentTracking.Effort_Owner__c = caseOwnerId;
            commentTracking.Effort_Amount__c = cas.Case_closure_time_spent__c;                            
            commentTracking.Effort_Origin__c = 'Case';
            commentTracking.Effort_Timestamp__c = Datetime.now();
            if(cas.Current_comment_activity__c  == null)
                commentTracking.Effort_Type__c  = 'General Case Work';  
            else
                commentTracking.Effort_Type__c = cas.Current_comment_activity__c;
            
            commentTracking.Effort_User__c = UserInfo.getUserId();
            loadCaseEstimatedEffort(cas,'onSave', cas.Case_closure_time_spent__c);         
            insert commentTracking;
            
            cas.Case_closure_time_spent__c  = null;
            cas.Current_comment_activity__c = null;
        } else if(estTimeEff != null){
            Case_Effort_Tracking__c commentTracking = new Case_Effort_Tracking__c();
            commentTracking.CaseId__c = cas.Id;
            if(caseOwnerType == 'Queue')
                commentTracking.Effort_Queue__c = caseOwnerName;
            else
                commentTracking.Effort_Owner__c = caseOwnerId;
            
            commentTracking.Effort_Amount__c = Integer.valueOf(estTimeEff);                            
            commentTracking.Effort_Origin__c = 'Case';
            commentTracking.Effort_Timestamp__c = Datetime.now();
            if(cas.Current_comment_activity__c  == null)
                commentTracking.Effort_Type__c  = 'General Case Work';  
            else
                commentTracking.Effort_Type__c = cas.Current_comment_activity__c;
            
            commentTracking.Effort_User__c = UserInfo.getUserId();
            loadCaseEstimatedEffort(cas,'onSave', Decimal.ValueOf(estTimeEff));         
            insert commentTracking;
            cas.Case_closure_time_spent__c  = null;   
            cas.Current_comment_activity__c = null;
        }*/
        ApexPages.StandardController Controller = new ApexPages.StandardController(cas);
        system.debug('showWarning : ' + showWarning);
        //	Added By Exafort : Update the Asset if the Case has a lower Software version than the Asset's Nimble OS version.
        PageReference pageReference = Controller.save();
        
        // Only proceed if save was successful
        if (pageReference != null) {
            if (cas.AssetId != null && !String.isBlank(selectedVersion) && showWarning == True) {
                List<Id> assetIds = new List<Id>{cas.AssetId};
                    List<String> versions = new List<String>{selectedVersion};
                        assetUpdateUtility.updateAssetVersions(assetIds, versions);
            }
        }
        
        // Return PageReference from save() → redirect happens
        return pageReference;
    }
    
    public List<selectOption> getEstimatedTimeEffort() {
        List<SelectOption> estimatedTimeEffort= new List<SelectOption>();
        Schema.DescribeFieldResult picklistvalueResult = Case.caseClosureEstimatedEffort__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = picklistvalueResult.getPicklistValues();
        
        estimatedTimeEffort.add(new SelectOption('5', '5 minutes or less'));
        estimatedTimeEffort.add(new SelectOption('15', '15 minutes'));
        estimatedTimeEffort.add(new SelectOption('30', '30 minutes'));
        estimatedTimeEffort.add(new SelectOption('60', '1 hour'));
        estimatedTimeEffort.add(new SelectOption('120', '2 hours'));
        estimatedTimeEffort.add(new SelectOption('240', '4 hours'));
        estimatedTimeEffort.add(new SelectOption('1440','1 day'));
        
        return estimatedTimeEffort;
    }
    
    //Added by Exafort on 9/17/2020 TS-3370 START
    // Assign initial value of 'Estimated Effort (upon closure)' field based on 'Total Time Effort'
    public void loadCaseEstimatedEffort(case casedetail,string params,Decimal timeValue){   
        if( params == 'onSave')
            cas.caseClosureEstimatedEffort__c = String.valueOf(timeValue + Integer.valueOf(cas.Case_Owner_Time_Effort__c) + Integer.valueOf(cas.Non_Case_Owner_Time_Effort__c));
    }
    //Added by Exafort on 9/17/2020 TS-3370 END
    
    // Added by Exafort for Code Optimization.
    public list<TechnicalSubArea_Mappings__c> getTaTsaList(String supportProfile,string caseRecordTypeId,Integer condition){
        string caseRecodTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseRecordTypeId).getName();
        List<TechnicalSubArea_Mappings__c> taTSAMapReturn = new List<TechnicalSubArea_Mappings__c>(); 
        if(condition == 1 && (caseRecodTypeName == 'Array Case' || caseRecodTypeName == 'NCV Case' || caseRecodTypeName == 'SSaaS' || caseRecodTypeName == 'InfoSight Portal' || caseRecodTypeName == 'SDOE')){
            //  Added by Exafort for SFDC-523
            taTSAMapReturn = [select id, Technical_Area__c,Technical_SubArea__c,IsDeleted__c,Keywords__c,Case_Types__c from TechnicalSubArea_Mappings__c where IsDeleted__c=false AND Technical_Area__c !=null AND Technical_SubArea__c !=null AND Case_Types__c includes (:caseRecodTypeName) AND Support_Profile__c includes (:supportProfile) ORDER BY Technical_Area__c ASC,Technical_SubArea__c ASC];
            return taTSAMapReturn;
            //  End of SFDC-523
        }
        if(condition == 2 && (caseRecodTypeName == 'Array Case' || caseRecodTypeName == 'NCV Case' || caseRecodTypeName == 'SSaaS' || caseRecodTypeName == 'InfoSight Portal' || caseRecodTypeName == 'SDOE')){
            //  Added by Exafort for SFDC-523
            taTSAMapReturn = [select id, Technical_Area__c,Technical_SubArea__c,IsDeleted__c,Keywords__c,Case_Types__c from TechnicalSubArea_Mappings__c where IsDeleted__c=false AND Technical_Area__c !=null AND Technical_SubArea__c !=null AND Case_Types__c includes (:caseRecodTypeName) AND Support_Profile__c includes (:supportProfile)];
            return taTSAMapReturn;
            //  End of SFDC-523
        }
        return null;
    }
    // Added by Exafort for Code Optimization.
    public list<TechnicalSubArea_Mappings__c> getTsaList(String supportProfile,String SelectedTaValue, string caseRecordTypeId){
        string caseRecodTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseRecordTypeId).getName();
        List<TechnicalSubArea_Mappings__c> tsaReturnList = new List<TechnicalSubArea_Mappings__c>();
        if(caseRecodTypeName == 'Array Case' || caseRecodTypeName == 'NCV Case' || caseRecodTypeName == 'SSaaS' || caseRecodTypeName == 'InfoSight Portal'|| caseRecodTypeName == 'SDOE'){
            //  Added by Exafort for SFDC-523
            tsaReturnList = [select id, Technical_Area__c,Technical_SubArea__c,IsDeleted__c,Keywords__c,Case_Types__c from TechnicalSubArea_Mappings__c 
                             where IsDeleted__c=false AND Technical_Area__c !=null AND Technical_SubArea__c !=null AND Case_Types__c includes (:caseRecodTypeName) AND Technical_Area__c =: SelectedTaValue  AND Support_Profile__c includes (:supportProfile)];
            return tsaReturnList;
            //  End of SFDC-523
        }
        return null;
    }
    // Added by Exafort for SFDC-524
    @TestVisible
    private Integer compareVersions(String caseVersion, String assetVersion) {
        if (String.isBlank(caseVersion) || String.isBlank(assetVersion)) return 0;
        
        caseVersion = caseVersion.split('-')[0];
        assetVersion = assetVersion.split('-')[0];
        
        List<String> parts1 = caseVersion.split('\\.');
        List<String> parts2 = assetVersion.split('\\.');
        
        Integer maxLength = Math.max(parts1.size(), parts2.size());
        
        for (Integer i = 0; i < maxLength; i++) {
            Integer num1 = i < parts1.size() ? Integer.valueOf(parts1[i]) : 0;
            Integer num2 = i < parts2.size() ? Integer.valueOf(parts2[i]) : 0;
            
            if (num1 < num2) return -1;
            if (num1 > num2) return 1;
        }
        
        return 0;
    }
    // End of SFDC-524
    
    public PageReference redirectToDetailPage() {
        // Get the ID from the current page's parameters
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        
        if (recordId != null) {
            // Create the URL to redirect to the standard detail page
            PageReference detailPage = new PageReference('/' + recordId);
            detailPage.setRedirect(true);
            system.debug('Redirect Executed');
            return detailPage;
        } else {
            // If no ID found, you can stay on the same page or handle as needed
            return null;
        }
    }
}