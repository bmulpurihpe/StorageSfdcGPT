/*                              <<<< === Apex Class to hold EAC account Multi Edit Page Logic=== >>>>
    =============================================================================================================
        Name                    : EACControllerNewV2
        Description             : Contains the logic to show the EAC Definitions with the assets to create/edit the Definition values specific to assets as EAC records.
        Created Date            : 17th October 2018
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
public class EACControllerNewV2 {
    
 public Id Recordid {get;set;}
    public Boolean timer {get;set;}
    public Set<String> FilteredGroups;
    public Set<Id> AssetIds {get;set;}
    public Account accountRec {get;set;}
    public String SelectedGroup{get;set;}
    public List<SelectOption> Groups{get;set;}
    public Set<String> GroupsForRepeat{get;set;}
     public String objectName {set;get;}
    public String SelectedGroupFromURL{get;set;}
    private ApexPages.StandardController controller;
    public List<AssetChildWrapper> lstChildWrapInitial;
    public List<Account> accountWithAsset = new List<Account>();
    public List<Assetwrapper> WrapAssetsWithEACDefinitions {get;set;}
    public Map<string,List<Assetwrapper>> AssetsEACDefinitionWrapperMap {get;set;}
    public Map<String,Id> GetRecordTypeIdForNec {set;get;}
    public String ObjectRecordtype {set;get;}   
    public Boolean IsMapEmpty {set;get;}
    public Boolean DisableGroupFilter {set;get;}
    //*********** Constructor - START
    public EACControllerNewV2(ApexPages.StandardController controller){
     
        GetRecordTypeIdForNec = new Map<String,Id>();
        Recordid = Apexpages.currentPage().getParameters().get('id');
        if(Recordid != null){
            objectName = Recordid.getSObjectType().getDescribe().getName();
        }else{
            
        }
        system.debug('#### object Name ===>'+objectName);//case
        List<RecordType> RecordTypeIdsList = [select Id,Name from RecordType where sObjectType='NEC_Record__c'];
        for(RecordType RTrec : RecordTypeIdsList){
            GetRecordTypeIdForNec.put(RTrec.Name, RTrec.Id);
        }
        system.debug('### record types for NEC Record ### '+GetRecordTypeIdForNec);
        if(objectName == 'Account'){
            ObjectRecordtype = 'Asset';
        }      
         ObjectRecordtype = 'Asset';
        SelectedGroup = 'None';
        AssetIds = new Set<Id>();
        this.controller = controller;
        accountRec=(Account)controller.getRecord();
        accountWithAsset = [SELECT Id,Name,(Select Id,Name,status From Assets) FROM Account WHERE id=: accountRec.id LIMIT 1];
        //************ Loop to get the list of Assets associated with the Account and adding to the set collection.
        For(Account AccRec: accountWithAsset){
            For(Asset AssetRec: AccRec.Assets){
                AssetIds.add(AssetRec.Id);
            }
        }
        if(AssetIds.isEmpty()){ 
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Assets are mapped under this Account.Please add the Assets to edit the enhanced characteristics.'));
        }
        //***************************************************************************************************************
        Groups = new List<SelectOption>();        
        List<NEC_Definition__c> EACDefinitionGroups = [Select Id,necGroup__c from NEC_Definition__c where recordtype.Name =:ObjectRecordtype ORDER BY necGroup__c];
        FilteredGroups = new Set<String>();
        for(NEC_Definition__c EACDefRec : EACDefinitionGroups){
            if(EACDefRec.necGroup__c != null && EACDefRec.necGroup__c != '')
                FilteredGroups.add(EACDefRec.necGroup__c);
        }
        system.debug('values are====>'+FilteredGroups);
        Groups.add(new SelectOption('None','None'));
        Groups.add(new SelectOption('All','All'));
        for(String picklistvals:FilteredGroups){
            Groups.add(new SelectOption(picklistvals,picklistvals));
        }
        GroupsForRepeat = new Set<String>();
        if(SelectedGroup == 'All'){
            GroupsForRepeat.addAll(FilteredGroups);
        }else{
            GroupsForRepeat.add(SelectedGroup);
        }
        chooseGroupNameBasedOnURL();
        groupSelectionUpdate();
    }
    //*********** Constructor - END
    //************************************************************************************************************chooseGroupNameBasedOnURL
    public void chooseGroupNameBasedOnURL(){
        SelectedGroupFromURL = ApexPages.currentPage().getParameters().get('groupname');
        system.debug('Selected group value ===>'+SelectedGroupFromURL);
        if(SelectedGroupFromURL != null){
        SelectedGroup = SelectedGroupFromURL;    
        }
        system.debug('Selected group value ===>'+SelectedGroupFromURL);
    }
    //************************************************************************************************************groupSelectionUpdate
    public void groupSelectionUpdate(){
        GroupsForRepeat.clear();
        system.debug('Selected group value ===>'+SelectedGroup);
        if(SelectedGroup == 'All'){
            GroupsForRepeat.addAll(FilteredGroups);
        }else{
            GroupsForRepeat.add(SelectedGroup);
        }
        
        WrapAssetsWithEACDefinitions = new list<Assetwrapper>();
        AssetsEACDefinitionWrapperMap = new Map<string,List<Assetwrapper>>();
        Map<Id,Assetwrapper> MapForStoringValues ;
        //************* collection with assets along with the EAC records.
        List<Asset> AllAssetsForEACDef = [Select Id,Name,Status,Group_Name__c,(Select Id,name,necAsset__c,necrDescription__c,necrKeyName__c,necrLastModifiedDateTime__c,necrValue__c,necrGroupName__c,necrKeyName__r.Name,necrKeyName__r.necFieldType__c From NEC_Records__r where necrGroupName__c IN :GroupsForRepeat) From Asset where Id IN:AssetIds ORDER BY Group_Name__c,Name];
        Map<String,Id> MapForEACD = new Map<String,Id>();
               List<NEC_Definition__c> EACDefinition = [Select Id,Name,necLabel__c,necSortOrder__c,necGroup__c,necFieldType__c,necFieldTypePicklistItems__c,necDescription__c,necDefaultValue__c from NEC_Definition__c where necGroup__c IN :GroupsForRepeat ORDER BY necGroup__c,necSortOrder__c]; 
        for(NEC_Definition__c EACDrec:EACDefinition){
            MapForEACD.put(EACDrec.Name,EACDrec.Id);
        }
        For(String StringValue:GroupsForRepeat){
            MapForStoringValues = New Map<Id,Assetwrapper>();
            For(Asset AssetRec: AllAssetsForEACDef){
                integer count = 0;
                //AssetsEACDefinitionWrapperMap.clear();
                system.debug('##### GroupsForRepeat list size ====>'+GroupsForRepeat);
                system.debug('##### GroupsForRepeat list size ====>'+GroupsForRepeat.size());
                system.debug('##### AllAssetsForEACDef list size ====>'+AllAssetsForEACDef);
                system.debug('##### AllAssetsForEACDef size ====>'+AllAssetsForEACDef.size());
                //********** Copying the child records into a temporary list for further processing.
                
                List<NEC_Record__c> tempList = new List<NEC_Record__c>();
                tempList = AssetRec.NEC_Records__r;
                //Dispalying Asset Name,Asset Status and Asset Group by default for all the tables - Start
                //if(SelectedGroup != 'None'){
                    List<AssetChildWrapper> lstChildWrapInitial = new List<AssetChildWrapper>();
                    AssetChildWrapper cwrapforAssetvalueName = new AssetChildWrapper();
                    cwrapforAssetvalueName.headerValue = 'Asset Name';
                    cwrapforAssetvalueName.AssetName = AssetRec.Name;
                    lstChildWrapInitial.add(cwrapforAssetvalueName);
                   	 AssetChildWrapper cwrapforAssetvalueStatus = new AssetChildWrapper();
                    cwrapforAssetvalueStatus.headerValue = 'Asset Status';
                    cwrapforAssetvalueStatus.Assetstatus = AssetRec.Status;
                    lstChildWrapInitial.add(cwrapforAssetvalueStatus);
                    AssetChildWrapper cwrapforAssetvalueGroupName = new AssetChildWrapper();
                    cwrapforAssetvalueGroupName.headerValue = 'Asset Group';
                    cwrapforAssetvalueGroupName.AssetGroupName = AssetRec.Group_Name__c;
                    lstChildWrapInitial.add(cwrapforAssetvalueGroupName);
                //}
                //Dispalying Asset Name,Asset Status and Asset Group by default for all the tables - END
                //Looping through the EAC Definition values to get the Defintion Types and Header Values - START
                System.debug('### .='+EACDefinition);
                for(NEC_Definition__c ecd : EACDefinition){
                    if(ecd.necGroup__c == StringValue){
                        AssetChildWrapper cwrap = new AssetChildWrapper();
                        if(ecd.necFieldType__c == 'Text'){
                            cwrap.isText = true;
                            if(ecd.necDefaultValue__c != null)cwrap.textvalue = ecd.necDefaultValue__c;
                        }
                        else if(ecd.necFieldType__c == 'Picklist'){
                            cwrap.isPicklist = true;
                            if(ecd.necDefaultValue__c != null && ecd.necDefaultValue__c != 'None')cwrap.picklistVal = ecd.necDefaultValue__c;
                            List<String> lstpklist = ecd.necFieldTypePicklistItems__c.split('\\|');
                            List<selectOption> lstselectoption = new List<selectoption>();
                            lstselectoption.add(new SelectOption('None','None'));
                            for(String s : lstpklist){
                                lstselectoption.add(new SelectOption(s,s));
                            }
                            cwrap.picklistValues = lstselectoption;
                        }
                        else if(ecd.necFieldType__c == 'Boolean'){
                            cwrap.isCheckbox = true;
                            if(ecd.necDefaultValue__c != null)cwrap.isCheckboxSelected = Boolean.valueOf(ecd.necDefaultValue__c);
                        }
                        cwrap.headerValue = ecd.Name;
                        lstChildWrapInitial.add(cwrap);
                    }
                }
                //Looping through the EAC Definition values to get the Defintion Types and Header Values - END
                set<String> groupSet = new set<String>();
                if(!tempList.isEmpty()){
                    for(NEC_Record__c EACR:tempList){
                        groupSet.add(EACR.necrGroupName__c);  
                    }   
                }
                
                //comparing against the existing EAC Records.
                if(tempList != null && tempList.size()>0 && groupSet.contains(StringValue)){
                     system.debug('### tempList case');
                    for(NEC_Record__c EACR:AssetRec.NEC_Records__r){
                        if(EACR.necrGroupName__c == StringValue){
                            
                            Assetwrapper assetwrapp = new Assetwrapper(AssetRec);
                            
                            List<AssetChildWrapper> lstChildWrap = new List<AssetChildWrapper>();
                            lstChildWrap = lstChildWrapInitial;
                            if(MapForStoringValues.containsKey(AssetRec.Id)){
                                assetwrapp = MapForStoringValues.get(AssetRec.Id);
                                lstChildWrap = assetwrapp.lstChildWrapper;
                            }
                            //Looping through the child wrapper values.
                            for(AssetChildWrapper ascw : lstChildWrap){
                                //system.debug('### asw =====>'+ascw);
                                //system.debug('### AssetRec Name'+AssetRec.Name+ 'child====>'+EACR.Name);
                                if(ascw.headerValue == EACR.necrKeyName__r.Name){
                                    if(ascw.isCheckbox && EACR.necrKeyName__r.necFieldType__c == 'Boolean'){
                                        ascw.EACRGroupName = EACR.necrGroupName__c;
                                        ascw.EACrecordId = String.valueOf(EACR.Id);
                                        if(EACR.necrValue__c == 'True' || EACR.necrValue__c =='true' ){
                                            ascw.isCheckboxSelected = True;
                                        }else if(!ascw.isCheckboxSelected){
                                            ascw.isCheckboxSelected = False;
                                        }
                                    }else if(ascw.isPicklist && EACR.necrKeyName__r.necFieldType__c == 'picklist'){
                                        ascw.EACrecordId = String.valueOf(EACR.Id);
                                        ascw.EACRGroupName = EACR.necrGroupName__c;
                                        //If(ascw.picklistVal == ''){
                                        ascw.picklistVal = EACR.necrValue__c;
                                        //}
                                    }else if(ascw.isText && EACR.necrKeyName__r.necFieldType__c == 'Text'){
                                        ascw.EACrecordId = String.valueOf(EACR.Id);
                                        ascw.EACRGroupName = EACR.necrGroupName__c;
                                        If(EACR.necrValue__c != null && EACR.necrValue__c != ''){
                                            //If(ascw.textValue == ''){
                                            ascw.textValue = EACR.necrValue__c;
                                            //}
                                        }
                                    }
                                }
                            }
                            //system.debug('### final childWrap ====>'+lstChildWrap);
                            assetwrapp.lstChildWrapper = lstChildWrap;
                            MapForStoringValues.put(AssetRec.Id,assetwrapp); 
                            count = count+1;
                            System.debug('Count>>>::'+count);
                        }
                    }
                }else{
                    system.debug('### tempList Else case <=====');
                    Assetwrapper tempwrapper = new  Assetwrapper(AssetRec);
                    //system.debug('>>> NUll Wrapper>>'+lstChildWrapInitial);
                    tempwrapper.lstChildWrapper = lstChildWrapInitial;
                    MapForStoringValues.put(AssetRec.Id,tempwrapper);
                }              
            }
            WrapAssetsWithEACDefinitions.addAll(MapForStoringValues.values());
            //system.debug('String values===> '+StringValue+'======> '+MapForStoringValues.values());
            AssetsEACDefinitionWrapperMap.put(StringValue,MapForStoringValues.values());
                
            //*****************Loop for displaying the Map values <-> START
            for (string key: AssetsEACDefinitionWrapperMap.keySet()) {
                System.debug(LoggingLevel.DEBUG, 'key: ' + key + ' ====> value: ' + AssetsEACDefinitionWrapperMap.get(key));
            }
            //*****************Loop for displaying the Map values <-> END
        }
    }
    
    //************************************************************************************************************ InsertOrUpdateEACRecords
    //Saving the EAC records after mass edit.
    public void InsertOrUpdateEACRecords(){
        Map<Id,Assetwrapper> CollectValuesFromMassEdit = New Map<Id,Assetwrapper> ();
        List<AssetChildWrapper> lstChildWrapInMassEdit = new List<AssetChildWrapper>();
        //*****************Loop for displaying the Map values <-> START
        for (String key: AssetsEACDefinitionWrapperMap.keySet()) {
            System.debug(LoggingLevel.DEBUG, 'FROM CONTROLLER ====> key: ' + key + ' ====> value: ' + AssetsEACDefinitionWrapperMap.get(key));
        }
        
        //************* Map to store the Enhanced Asset characteristic Definitons.
        Map<String,Id> MapForEACD = new Map<String,Id>();
        List<NEC_Definition__c> EACDValuesInList = [Select Id,Name,necLabel__c,necSortOrder__c From NEC_Definition__c ORDER BY necSortOrder__c ASC];
        for(NEC_Definition__c EACDrec:EACDValuesInList){
            MapForEACD.put(EACDrec.Name,EACDrec.Id);
        }
        //*************
        
        List<NEC_Record__c> ProcessEACRExistingValues = new List<NEC_Record__c>();
        Map<id,List<NEC_Record__c>> MapWithAssetAndExistingEACRecords = new Map<id,List<NEC_Record__c>>();
        
        //************* Get all the EAC records to compare with assetwrapper to avoid dupliactes.
        
        Map<id, set<String>> assertswithkeyName = new Map<id, set<String>>();
        List<Asset> AllAssetswithEACRec = [Select Id,Name,Status,Group_Name__c,(Select Id,necAsset__c,necrDescription__c,necrKeyName__c,necrKeyName__r.Name,necrLastModifiedDateTime__c,necrValue__c,necrGroupName__c From NEC_Records__r) From Asset where Id IN:AssetIds ORDER BY Name];
        For(Asset AssetRec: AllAssetswithEACRec){
            For(NEC_Record__c EACRec:AssetRec.NEC_Records__r){
                if(AssetRec.id == EACRec.necAsset__c){
                    ProcessEACRExistingValues.add(EACRec);
                }
                set<String> tempSet = new set<String>();
                if(assertswithkeyName.containsKey(AssetRec.id)){
                    tempSet = assertswithkeyName.get(AssetRec.id);
                }
                tempSet.add(EACRec.necrKeyName__r.Name);
                assertswithkeyName.put(AssetRec.id,tempSet);
            }
            MapWithAssetAndExistingEACRecords.put(AssetRec.Id,ProcessEACRExistingValues);
        }
        //*****************Loop for displaying the Map values.
        for (Id key: MapWithAssetAndExistingEACRecords.keySet()) {
            System.debug(LoggingLevel.DEBUG, '### key: ' + key + ' ====> value: ' + MapWithAssetAndExistingEACRecords.get(key));
        }
        //*****************
        
        Set<NEC_Record__c> EacrToInsertOrUpdateInSet = new Set<NEC_Record__c>();
        List<NEC_Record__c> EacrlistToInsertOrUpdate = new List<NEC_Record__c>();
        
        //***************Looping through the all the Asset wrapper values from the vf page.
        for(String GroupRecVal: AssetsEACDefinitionWrapperMap.keySet()){
            for(Assetwrapper ARRec:AssetsEACDefinitionWrapperMap.get(GroupRecVal)){
                list<NEC_Record__c> EACrecordsUnderAsset = MapWithAssetAndExistingEACRecords.get(ARRec.assetRec.Id);
                system.debug('### EACrecordsUnderAsset list size ===>'+EACrecordsUnderAsset.size());
                if(EACrecordsUnderAsset.size()> 0){
                    for(AssetChildWrapper childwrap : ARRec.lstChildWrapper){
                        Boolean isCheckboxUpdated= False;
                        Boolean isPicklistUpdated = False;
                        Boolean isTextUpdated = False;
                        set<String> keyNamesSet = new set<String>(); 
                        if(assertswithkeyName.containsKey(ARRec.assetRec.id)){
                            keyNamesSet = assertswithkeyName.get(ARRec.assetRec.id); 
                        }
                        //Loop for comparing the existing values for update.
                        for(NEC_Record__c eacrec:EACrecordsUnderAsset){
                            system.debug('##### Inside the EACrecordsUnderAsset looping <===============');
                            
                            if(ARRec.assetRec.id == eacrec.necAsset__c){
                                system.debug('### Wrapper Asset Id ===>::'+'eac record id =====>::'+eacrec.id);
                                system.debug('### vkeyNamesSet====>>::'+ARRec);
                                system.debug('### vkeyNamesSet====>>::'+keyNamesSet);
                                if(eacrec.necrKeyName__c == MapForEACD.get(childwrap.headerValue)){ 
                                    if(childwrap.isCheckbox && String.ValueOf(childwrap.ischeckboxSelected) != String.valueOf(eacrec.necrValue__c)){
                                        system.debug('### ====> Inside the Existing EAC record updation if condition 1<====[For checkbox]');
                                        eacrec.necrValue__c = String.ValueOf(childwrap.ischeckboxSelected);
                                        EacrToInsertOrUpdateInSet.add(eacrec);
                                        isCheckboxUpdated = true;
                                    }
                                    if(childwrap.istext && String.ValueOf(childwrap.textValue) != String.valueOf(eacrec.necrValue__c)){
                                        system.debug('### ====> Inside the Existing EAC record updation if condition 1<====[For textVal]');
                                        eacrec.necrValue__c = String.ValueOf(childwrap.textValue);
                                        EacrToInsertOrUpdateInSet.add(eacrec);
                                        isTextUpdated = true;
                                    }
                                    if(childwrap.ispicklist && String.ValueOf(childwrap.picklistVal) != String.valueOf(eacrec.necrValue__c) && childwrap.picklistVal != 'None'){
                                        system.debug('### ====> Inside the Existing EAC record updation if condition 1<====[picklist]');
                                        eacrec.necrValue__c = String.ValueOf(childwrap.picklistVal);    
                                        EacrToInsertOrUpdateInSet.add(eacrec);
                                        isPicklistUpdated = true;
                                    }
                                }
                            }
                        }
                        //Logic to create new EAC records 
                        if(childwrap.isCheckbox && childwrap.ischeckboxSelected && !isCheckboxUpdated && !keyNamesSet.Contains(childwrap.headerValue)){
                            NEC_Record__c NewEACRecForSS = new NEC_Record__c();
                            NewEACRecForSS.necAsset__c = ARRec.assetRec.Id;
                            NewEACRecForSS.RecordTypeId = GetRecordTypeIdForNec.get('Asset Records');
                            
                            NewEACRecForSS.necrKeyName__c = MapForEACD.get(childwrap.headerValue);
                            NewEACRecForSS.necrValue__c = String.valueof(childwrap.ischeckboxSelected);
                            EacrToInsertOrUpdateInSet.add(NewEACRecForSS);
                        }
                        if(childwrap.ispicklist && childwrap.picklistVal != '' && !isPicklistUpdated  && !keyNamesSet.Contains(childwrap.headerValue) && childwrap.picklistVal != 'None'){
                            NEC_Record__c NewEACRecForSS = new NEC_Record__c();
                            NewEACRecForSS.necAsset__c = ARRec.assetRec.Id;
                            NewEACRecForSS.RecordTypeId = GetRecordTypeIdForNec.get('Asset Records');
                            NewEACRecForSS.necrKeyName__c = MapForEACD.get(childwrap.headerValue);
                            NewEACRecForSS.necrValue__c = String.valueof(childwrap.picklistVal);
                            EacrToInsertOrUpdateInSet.add(NewEACRecForSS);
                        }
                        if(childwrap.istext && childwrap.textValue != '' && !isTextUpdated && !keyNamesSet.Contains(childwrap.headerValue)){
                            NEC_Record__c NewEACRecForSS = new NEC_Record__c();
                          NewEACRecForSS.necAsset__c = ARRec.assetRec.Id;
                             NewEACRecForSS.RecordTypeId = GetRecordTypeIdForNec.get('Asset Records');
                            NewEACRecForSS.necrKeyName__c = MapForEACD.get(childwrap.headerValue);
                            NewEACRecForSS.necrValue__c = String.valueof(childwrap.textValue);
                            EacrToInsertOrUpdateInSet.add(NewEACRecForSS);
                        }
                    }//records loop
                }else{
                    //Looping through the AssetChildWrapper values to create EAC Records for Initial creation of ECA records.
                    for(AssetChildWrapper childwrap : ARRec.lstChildWrapper){
                        NEC_Record__c NewEACRecForSS = new NEC_Record__c();
                        //ewACRecForSS.necAsset__c = ARRec.assetRec.Id;
                       NewEACRecForSS.RecordTypeId = GetRecordTypeIdForNec.get('Asset Records');
                       NewEACRecForSS.necAsset__c=ARRec.assetRec.Id;
                        NewEACRecForSS.necrKeyName__c = MapForEACD.get(childwrap.headerValue);
                        if(childwrap.isCheckbox && childwrap.ischeckboxSelected){
                            NewEACRecForSS.necrValue__c = String.valueof(childwrap.ischeckboxSelected);
                            EacrToInsertOrUpdateInSet.add(NewEACRecForSS);
                        }else if(childwrap.istext && childwrap.textValue != ''){
                            NewEACRecForSS.necrValue__c = String.valueof(childwrap.textValue);
                            EacrToInsertOrUpdateInSet.add(NewEACRecForSS);
                        } else if(childwrap.ispicklist && childwrap.picklistVal !='' && childwrap.picklistVal != 'None'){
                            NewEACRecForSS.necrValue__c = String.valueof(childwrap.picklistVal);
                            EacrToInsertOrUpdateInSet.add(NewEACRecForSS);
                        }
                    }
                }
            }
        }
        System.debug('##### Final Upsert Set ======>::'+EacrToInsertOrUpdateInSet.size());
        System.debug('##### Final Upsert Set Values ======>::'+EacrToInsertOrUpdateInSet);
        //************Adding all the set items in the Set into List for upsertion(Create or Update).
        EacrlistToInsertOrUpdate.addAll(EacrToInsertOrUpdateInSet);
        System.debug('##### Final Upsert List Size ========>::'+EacrlistToInsertOrUpdate.size());
        system.debug('##### Final Upsert List values Before upsertion ======>::'+EacrlistToInsertOrUpdate);
        try{
            //***************update/Insert the values in the list and showing success message.
            if(EacrlistToInsertOrUpdate.size() == 0){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please Add/update values.None of the Records are Modified/Newly Added'));
            }
            else if(!EacrlistToInsertOrUpdate.isEmpty()){
                upsert EacrlistToInsertOrUpdate;
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Records Saved Successfully'));   
            }
            timerOn();
        }
        catch(Exception e){
            system.debug(e.getMessage());
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Records Upsertion Failed.ERROR-'+e.getMessage()));
            timerOn();
        }
    }
    //************************************************************************************************************ clearMessage
    public void clearMessage(){
        ApexPages.getMessages().clear();
    }
	//************************************************************************************************************ timerOn
    public void timerOn(){
        timer = true;
    }
	//************************************************************************************************************ timerOff
    public void timerOff(){
        timer = false;
    }
    //************************************************************************************************************ Assetwrapper class
    public class Assetwrapper{
        public Asset assetRec{get;set;}
        public List<AssetChildWrapper> lstChildWrapper {set; get;}
        public Assetwrapper(Asset a){
            assetRec=a;
            this.lstChildWrapper = new List<AssetChildWrapper>();
        } 
    }
    //************************************************************************************************************ AssetChildWrapper class
    public class AssetChildWrapper {
        public Asset assetRec {get;set;}
        public Boolean ischeckbox {get;set;}
        public Boolean isText {get;set;}
        public Boolean isPicklist {get;set;}
        public Boolean isCheckboxSelected {set; get;}
        public String textValue {set; get;}
        public String picklistVal {set; get;}
        public String headerValue {set; get;}
        public String AssetName {set; get;}
        public String Assetstatus {set; get;}
        public String AssetGroupName {set; get;}
        public String EACRGroupName {set; get;}
        public string EACrecordId{set;get;}
        public list<SelectOption> picklistValues{get;set;}
        
        public AssetChildWrapper(){
            this.headerValue='';
            this.AssetName='';
            this.Assetstatus='';
            this.AssetGroupName='';
            this.EACrecordId='';
            this.EACRGroupName='';
            this.ischeckbox = false;
            this.isText = false;
            this.isCheckboxSelected = false;
            this.isPicklist = false;
            this.textValue = '';
            this.picklistVal = '';
            this.picklistValues =  new List<SelectOption>();
        }
    }   
}