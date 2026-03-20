/*                              <<<< === Apex Class to hold NEC Multi Edit Page Logic=== >>>>
=============================================================================================================
Name                    : NECController
Description             : Contains the logic to show the NEC Definitions with the assets to create/edit the
Definition values specific to onject type used in definition as NEC records.
Created Date            : 11th april 2019
Author                  : Vishnu R
Version                 : 1.0
Modification History    : Guru Dev(Exafort) for TS-9364
==============================================================================================================
*/
public with sharing class NECController {
    
    public Boolean timer {get;set;}
    /*public Case CaseRec {get;set;}
private ApexPages.StandardController controller;*/
    public Set<String> GroupsForRepeat{get;set;}
    public Set<String> FilteredGroups;
    public String SelectedGroup{get;set;}
    public List<SelectOption> Groups{get;set;}
    public Id Recordid {get;set;}
    public String objectName {set;get;}
    public List<NECWrapper> lstChildWrapInitial;     
    public List<NECWrapper> WrapsobjectWithNECDefinitions {get;set;}
    public Map<string,List<NECWrapper>> NECDefinitionWithGroupMappings {get;set;}
    public String ObjectRecordtype {set;get;}   
    public Map<String,Id> GetRecordTypeIdForNec {set;get;}
    public string Case_RMA_Number_AddressBook_Account{set;get;} //TS-8921
    public String SelectedGroupFromURL{get;set;} //TS-6846
    
    public NECController(){ 
        /*this.controller = controller;
CaseRec=(Case)controller.getRecord();*/
        system.Debug('Constructor calling $$');
        GetRecordTypeIdForNec = new Map<String,Id>();
        Recordid = Apexpages.currentPage().getParameters().get('id');
        if(Recordid != null){
            objectName = Recordid.getSObjectType().getDescribe().getName();
        }else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please pass the record Id to the view/edit the Characteristics...!'));
            timerOn();
        }
        
        system.debug('#### object Name ===>'+objectName);//case
        List<RecordType> RecordTypeIdsList = [select Id,Name from RecordType where sObjectType='NEC_Record__c'];
        for(RecordType RTrec : RecordTypeIdsList){
            GetRecordTypeIdForNec.put(RTrec.Name, RTrec.Id);
        }
        system.debug('### record types for NEC Record ### '+GetRecordTypeIdForNec);
        if(objectName == 'Case'){
            ObjectRecordtype = 'Case';
            if(Recordid!=null){
                Case_RMA_Number_AddressBook_Account=[select id,casenumber from case where id =:Recordid].casenumber;
            }           
        }else if(objectName == 'RMAv2__c'){
            ObjectRecordtype = 'RMAv2';
            if(Recordid!=null){
                Case_RMA_Number_AddressBook_Account=[select id,Name from RMAv2__c where id =:Recordid].Name;
            }                       
        }
        //Added by Guru Dev(Exafort) for TS-8921 on 02/01/2022
        else if(objectName == 'AddressBook__c'){
            ObjectRecordtype = 'Address Book';
            if(Recordid!=null){
                Case_RMA_Number_AddressBook_Account=[select id,Name from AddressBook__c where id =:Recordid].Name;
            }                       
        }
        //Added end
        //Added by Guru Dev(Exafort)
        else if(objectName == 'Account'){
            ObjectRecordtype = 'Account';
            if(Recordid != null){
                Case_RMA_Number_AddressBook_Account = [select id,Name from Account where id =:Recordid].Name;
            }
        }
        //Added end
        
        SelectedGroup = 'All';        
        Groups = new List<SelectOption>();        
        List<NEC_Definition__c> CECDefinitionGroups = [Select Id,necGroup__c from NEC_Definition__c where recordtype.Name =:ObjectRecordtype ORDER BY necGroup__c ];
        FilteredGroups = new Set<String>();
        for(NEC_Definition__c CecDefRec : CECDefinitionGroups){
            if(CecDefRec.necGroup__c != null && CecDefRec.necGroup__c != '')
                FilteredGroups.add(CecDefRec.necGroup__c);
        }
        system.debug('values are====>'+FilteredGroups);
        //Groups.add(new SelectOption('None','None'));
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
        chooseGroupNameBasedOnURL(); // added to get the group name from url for TS-6846
        groupSelectionUpdate();
    }
    //TS-6846
    public void chooseGroupNameBasedOnURL(){
        SelectedGroupFromURL = ApexPages.currentPage().getParameters().get('groupname');
        system.debug('Selected group value ===>'+SelectedGroupFromURL);
        if(SelectedGroupFromURL != null){
            SelectedGroup = SelectedGroupFromURL;    
        }
        system.debug('Selected group value ===>'+SelectedGroupFromURL);
    }
    public void groupSelectionUpdate(){
        
        GroupsForRepeat.clear();
        system.debug('Selected group value ===>'+SelectedGroup);
        if(SelectedGroup == 'All'){
            GroupsForRepeat.addAll(FilteredGroups);
        }else{
            GroupsForRepeat.add(SelectedGroup);
        }        
        WrapsobjectWithNECDefinitions = new list<NECWrapper>();
        NECDefinitionWithGroupMappings = new Map<string,List<NECWrapper>>();
        Map<Id,NECWrapper> MapForStoringValues ;
        Map<String,Id> MapForNECD = new Map<String,Id>();        
        /*List<Case> CasesWithNECRecrds = [Select Id,CaseNumber,NecAssetName__c,(Select Id,name,necrCase_del__c,necrDescription__c,necrKeyName__c,
necrKeyName__r.Name,necrKeyName__r.necFieldType__c,
necrLastModifiedDateTime__c,necrValue__c,necrLabel__c,
necrGroupName__c From NEC_Records_del__r 
where necrGroupName__c IN :GroupsForRepeat) 
From Case where Id =:Recordid ORDER BY caseNumber];*/
        List<NEC_Definition__c> NECdefitions = [Select Id,Name,necDefaultValue__c,necDescription__c,
                                                necFieldType__c,necFieldTypePicklistItems__c,
                                                necGroup__c,necLabel__c,necSortOrder__c 
                                                From NEC_Definition__c where necGroup__c IN :GroupsForRepeat  ORDER BY necGroup__c,necSortOrder__c];
        system.debug('NECdefitions---'+NECdefitions);
        
        List<NEC_Definition__c> MasterNECdefinitions=[select id,Name,recordtypeId,necGroup__c,
                                                      (select id,recordtypeId,necrKeyName__c,necrValue__c,necrRMAv2__c,necrAddressBook__c,
                                                       necrCase__c from NEC_Records__r where necrCase__c =:Recordid ) from NEC_Definition__c where 
                                                      necGroup__c IN :GroupsForRepeat ORDER BY necGroup__c,necSortOrder__c];
        
        system.debug('===============> MasterNECdefinitions ' +MasterNECdefinitions);
        
        for(NEC_Definition__c NECDrec:NECdefitions){
            MapForNECD.put(NECDrec.Name,NECDrec.Id);
        }
        
        For(String StringValue:GroupsForRepeat){
            MapForStoringValues = New Map<Id,NECWrapper>();
            system.debug('##### GroupsForRepeat Value ====>'+GroupsForRepeat);
            system.debug('##### GroupsForRepeat list size ====>'+GroupsForRepeat.size());            
            List<NECWrapper> lstChildWrapInitial = new List<NECWrapper>();            
            System.debug('### NECDefMain-Data ====>'+NECdefitions);
            
            for(NEC_Definition__c ecd : NECdefitions){                                       
                for(integer i=0;i<MasterNECdefinitions.size();i++){
                    if(MasterNECdefinitions[i].id==ecd.id){
                        if(MasterNECdefinitions[i].NEC_Records__r.size() > 0){                                                        
                            for(integer j=0;j<MasterNECdefinitions[i].NEC_Records__r.size();j++){ 
                                if(MasterNECdefinitions[i].necGroup__c == StringValue){ //Check existing record or new record
                                    if(MasterNECdefinitions[i].NEC_Records__r[j].necrKeyName__c==ecd.id){                                  
                                        NECWrapper cwrap = new NECWrapper();                    
                                        if(ecd.necFieldType__c == 'Text'){
                                            cwrap.isText = true;
                                            if(MasterNECdefinitions[i].NEC_Records__r[j].necrValue__c == null){
                                                cwrap.textvalue = ecd.necDefaultValue__c;
                                            } else{
                                                cwrap.textvalue = MasterNECdefinitions[i].NEC_Records__r[j].necrValue__c;
                                            }                                            
                                        }
                                        else if(ecd.necFieldType__c == 'Picklist'){
                                            cwrap.isPicklist = true;  
                                            if(MasterNECdefinitions[i].NEC_Records__r[j].necrValue__c == null){
                                                cwrap.picklistVal= ecd.necDefaultValue__c;
                                            }else{
                                                cwrap.picklistVal = MasterNECdefinitions[i].NEC_Records__r[j].necrValue__c;
                                            }                                            
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
                                            if(MasterNECdefinitions[i].NEC_Records__r[j].necrValue__c == null){
                                                cwrap.isCheckboxSelected= Boolean.valueOf(ecd.necDefaultValue__c);
                                            }
                                            else{
                                                cwrap.isCheckboxSelected = Boolean.valueOf(MasterNECdefinitions[i].NEC_Records__r[j].necrValue__c);
                                            }                                            
                                        }
                                        cwrap.KeyName = ecd.Name;
                                        cwrap.GroupName = ecd.necGroup__c;
                                        cwrap.keyLabel = ecd.necLabel__c ;
                                        cwrap.keyDescription = ecd.necDescription__c;
                                        lstChildWrapInitial.add(cwrap);
                                        break;
                                    }
                                    
                                }                             
                            }
                        }else{      
                            if(ecd.necGroup__c == StringValue){    
                                NECWrapper cwrap = new NECWrapper();                    
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
                                cwrap.KeyName = ecd.Name;
                                cwrap.GroupName = ecd.necGroup__c;
                                cwrap.keyLabel = ecd.necLabel__c ;
                                cwrap.keyDescription = ecd.necDescription__c;
                                lstChildWrapInitial.add(cwrap); //Master List to add NECDefinition/NECRecord                                                                                      
                            } 
                        }
                    }                    
                }                                                
            }
            system.debug('###===> NEC wrapper Master List ===>'+lstChildWrapInitial);            
            NECDefinitionWithGroupMappings.put(StringValue,lstChildWrapInitial);
            system.debug('NECDefinitionWithGroupMappings----'+NECDefinitionWithGroupMappings);
            
            if(NECDefinitionWithGroupMappings.size()>0){
                //*****************Loop for displaying the Map values <-> START
                for (string key: NECDefinitionWithGroupMappings.keySet()) {
                    System.debug(LoggingLevel.DEBUG, 'key: ' + key + ' ====> value: ' + NECDefinitionWithGroupMappings.get(key));
                }
                //*****************Loop for displaying the Map values <-> END
            }else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please Create Defintions'));
                timerOn();
            }
            
        }
    }
    
    //Saving the NEC records after mass edit.
    public void InsertOrUpdateEACRecords(){
        try{
            Map<Id,NECWrapper> CollectValuesFromMassEdit = New Map<Id,NECWrapper> ();
            //List<CaseChildWrapper> lstChildWrapInMassEdit = new List<CaseChildWrapper>();
            List<String> GetMasterNECData=new List<String>();
            Map<String,Id> MapForNECD = new Map<String,Id>();
            List<NEC_Record__c> GetNEC_Record=new List<NEC_Record__c>();
            
            //Filter KeyName and id
            List<NEC_Definition__c> NECDValuesInList = [Select Id,Name,necLabel__c,necSortOrder__c From NEC_Definition__c where recordtype.Name =:ObjectRecordtype ORDER BY necSortOrder__c ASC];
            for(NEC_Definition__c NECDrec:NECDValuesInList){
                MapForNECD.put(NECDrec.Name,NECDrec.Id);
            }
            
            List<NEC_Record__c> ProcessEACRExistingValues = new List<NEC_Record__c>();
            List<NEC_Record__c> NECRecordMaster = new List<NEC_Record__c>();
            Map<id,List<NEC_Record__c>> MapWithAssetAndExistingEACRecords = new Map<id,List<NEC_Record__c>>();        
            List<NEC_Definition__c> NECDNECRecordc =new List<NEC_Definition__c>();
            
            //Get NEC_Definition and NEC_Records based recordtype
            if(ObjectRecordtype == 'Case'){
                NECDNECRecordc=[select id,Name,recordtypeId,(select id,recordtypeId,necrKeyName__c,necrValue__c,necrRMAv2__c,necrCase__c,necrAddressBook__c,necrAccount__c
                                                             from NEC_Records__r where necrCase__c =:Recordid ) from NEC_Definition__c
                                where recordtype.Name =:ObjectRecordtype];
            }else if(ObjectRecordtype == 'RMAv2'){   
                NECDNECRecordc=[select id,Name,recordtypeId,(select id,recordtypeId,necrKeyName__c,necrValue__c,necrRMAv2__c,necrCase__c,necrAddressBook__c,necrAccount__c
                                                             from NEC_Records__r where necrRMAv2__c =:Recordid ) from NEC_Definition__c
                                where recordtype.Name =:ObjectRecordtype];
            }
            //Added by Guru Dev(Exafort) for TS-8921 on 02/01/2022
            else if(ObjectRecordtype == 'Address Book'){   
                NECDNECRecordc=[select id,Name,recordtypeId,(select id,recordtypeId,necrKeyName__c,necrValue__c,necrRMAv2__c,necrCase__c,necrAddressBook__c,necrAccount__c 
                                                             from NEC_Records__r where necrAddressBook__c =:Recordid ) from NEC_Definition__c
                                where recordtype.Name =:ObjectRecordtype];
            }
            //Added end
            //Added by Guru Dev(Exafort)
            else if(ObjectRecordtype == 'Account'){   
                NECDNECRecordc = [select id,Name,recordtypeId,(select id,recordtypeId,necrKeyName__c,necrValue__c,necrRMAv2__c,necrCase__c,necrAddressBook__c,necrAccount__c
                                                             from NEC_Records__r where necrAccount__c =:Recordid ) from NEC_Definition__c
                                where recordtype.Name =:ObjectRecordtype];
            }
            //Added end
            System.debug(' ====>====>====> ObjectRecordtype: '+  ObjectRecordtype );
            for(String GroupRecVal: NECDefinitionWithGroupMappings.keySet()){            
                for(NECWrapper ARRec:NECDefinitionWithGroupMappings.get(GroupRecVal)){                
                    System.debug(' ====>====>====> Lis of Values related Filter: '+  ARRec );               
                    String NECKeyvalue = MapForNECD.get(ARRec.KeyName);                
                    //System.debug(' ====>Key ID ====>====> Lis of Values related Filter: '+  NECKeyvalue );
                    //System.debug(' ====>Record ID ====>====> '+  Recordid );
                    //System.debug(' ====>Pick List Value ====>====> '+  ARRec.picklistVal );                             
                    if(NECDNECRecordc.size() > 0){                      
                        for(integer j=0;j<NECDNECRecordc.size();j++){//NECDefinition Master Loop                       
                            if(NECDNECRecordc[j].id ==NECKeyvalue){
                                if(NECDNECRecordc[j].NEC_Records__r.size() > 0){//Load old NECRecord
                                    for(integer i=0;i<NECDNECRecordc[j].NEC_Records__r.size();i++){ //NEC Record Loop                       
                                        if(NECDNECRecordc[j].NEC_Records__r[i].necrKeyName__c==NECKeyvalue){//Compare NECKeyname ID  
                                            if(ARRec.isPicklist==true){
                                                NECDNECRecordc[j].NEC_Records__r[i].necrValue__c=ARRec.picklistVal;
                                            }
                                            if(ARRec.isText==true){
                                                NECDNECRecordc[j].NEC_Records__r[i].necrValue__c=ARRec.textValue;
                                            }
                                            if(ARRec.ischeckbox==true){
                                                NECDNECRecordc[j].NEC_Records__r[i].necrValue__c= String.valueOf(ARRec.isCheckboxSelected);
                                            }   
                                            if(ARRec.ischeckbox==false && ARRec.isText==false && ARRec.isPicklist==false){
                                                NECDNECRecordc[j].NEC_Records__r[i].necrValue__c= String.valueOf(ARRec.isCheckboxSelected);
                                            }      
                                            if(ObjectRecordtype == 'Case'){
                                                NECDNECRecordc[j].NEC_Records__r[i].necrCase__c=Recordid;
                                                NECDNECRecordc[j].NEC_Records__r[i].RecordTypeId =GetRecordTypeIdForNec.get('Case Records');                                            
                                            }
                                            else if(ObjectRecordtype == 'RMAv2'){                                            
                                                NECDNECRecordc[j].NEC_Records__r[i].necrRMAv2__c=Recordid;                                             
                                                NECDNECRecordc[j].NEC_Records__r[i].RecordTypeId =GetRecordTypeIdForNec.get('RMAv2 Records');
                                            }
                                            //Added by Guru Dev(Exafort) for TS-8921 on 02/01/2022
                                            else if(ObjectRecordtype == 'Address Book'){                                            
                                                NECDNECRecordc[j].NEC_Records__r[i].necrAddressBook__c=Recordid;                                             
                                                NECDNECRecordc[j].NEC_Records__r[i].RecordTypeId =GetRecordTypeIdForNec.get('Address Book Records');
                                            }
                                            //End
                                            //Added by Guru Dev(Exafort)
                                            else if(ObjectRecordtype == 'Account'){                                            
                                                NECDNECRecordc[j].NEC_Records__r[i].necrAccount__c = Recordid;                                             
                                                NECDNECRecordc[j].NEC_Records__r[i].RecordTypeId = GetRecordTypeIdForNec.get('Account Records');
                                            }
                                            //Added end
                                            NECRecordMaster.add(NECDNECRecordc[j].NEC_Records__r[i]);
                                            break;
                                        }                                                
                                    }
                                }else{//Load New NECRecord
                                    NEC_Record__c NECRecordMasterV1 =new NEC_Record__c();                                
                                    NECRecordMasterV1.necrKeyName__c=NECKeyvalue;                          
                                    if(ARRec.isPicklist==true){
                                        NECRecordMasterV1.necrValue__c=ARRec.picklistVal;
                                    }  
                                    if(ARRec.isText==true){
                                        NECRecordMasterV1.necrValue__c=ARRec.textValue;
                                    }  
                                    if(ARRec.ischeckbox==true){
                                        NECRecordMasterV1.necrValue__c= String.valueOf(ARRec.isCheckboxSelected);
                                    } 
                                    if(ARRec.ischeckbox==false && ARRec.isText==false && ARRec.isPicklist==false){
                                        NECRecordMasterV1.necrValue__c= String.valueOf(ARRec.isCheckboxSelected);
                                    }
                                    if(ObjectRecordtype == 'Case'){
                                        NECRecordMasterV1.necrCase__c=Recordid;
                                        NECRecordMasterV1.RecordTypeId = GetRecordTypeIdForNec.get('Case Records');
                                    }
                                    else if(ObjectRecordtype == 'RMAv2'){                                    
                                        NECRecordMasterV1.necrRMAv2__c=Recordid;                                     
                                        NECRecordMasterV1.RecordTypeId = GetRecordTypeIdForNec.get('RMAv2 Records');
                                    }
                                    //Added by Guru Dev(Exafort) for TS-8921 on 02/01/2022
                                    else if(ObjectRecordtype == 'Address Book'){                                    
                                        NECRecordMasterV1.necrAddressBook__c=Recordid;                                     
                                        NECRecordMasterV1.RecordTypeId = GetRecordTypeIdForNec.get('Address Book Records');
                                    }
                                    //End
                                    //Added by Guru Dev(Exafort)
                                    else if(ObjectRecordtype == 'Account'){                                    
                                        NECRecordMasterV1.necrAccount__c = Recordid;                                     
                                        NECRecordMasterV1.RecordTypeId = GetRecordTypeIdForNec.get('Account Records');
                                    }
                                    //Added end
                                    NECRecordMaster.add(NECRecordMasterV1);
                                }
                                
                            }
                            
                        }
                        
                    }
                }
            }
            if(NECRecordMaster.size()>0){
                //************Adding all the set items in the Set into List for upsertion(Create or Update).
                system.debug('NECRecordMaster---'+NECRecordMaster);
                upsert NECRecordMaster; //Update List
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Records Saved Successfully'));
                timerOn();
            }   
        }
        catch(Exception e){
            system.debug(e.getMessage());
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Records Upsertion Failed.ERROR-'+e.getMessage()));
            timerOn();
        }
        
    }
    //************************************************************************************************************ timerOn
    public void timerOn(){
        timer = true;
    }
    //************************************************************************************************************ timerOff
    public void timerOff(){
        timer = false;
    }
    //************************************************************************************************************ NECWrapper class
    public class NECWrapper{
        public String GroupName {set; get;}
        public String KeyName {set; get;}
        public String keyLabel {set; get;}
        public String keyDescription {set; get;}
        public Boolean ischeckbox {get;set;}
        public Boolean isText {get;set;}
        public Boolean isPicklist {get;set;}
        public Boolean isCheckboxSelected {set; get;}
        public String textValue {set; get;}
        public String picklistVal {set; get;}
        public list<SelectOption> picklistValues {get;set;}
        
        public NECWrapper(){
            this.GroupName = '';
            this.KeyName='';
            this.keyLabel='';
            this.keyDescription='';
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