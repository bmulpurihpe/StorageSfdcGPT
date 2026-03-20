/*                             <<<< === nimbleServicePortalControllerV1 Apex class === >>>>
=====================================================================================================================================
Name                    : nimbleServicePortalControllerV1(Retired "nimbleServicePortalController" for TS-8637)
Description             : Logic to create & update case and case docket field data
Created Date            : 10/20/2021
Author                  : Guru Dev(Exafort)
Version                 : 1.0
Modification History    : Initial Version - This apex class is referred in "nimbleServicePortal" and "nimbleServicePortalFormPage"
=====================================================================================================================================
*/
public class nimbleServicePortalControllerV1{
    
    public List<Case_Docket__c> cdRecord{set;get;}
    public String additionalInfo{get;set;}
    public Boolean isThisUnderDuress{set;get;}
    public String RecordidFromURL{set;get;}
    public string selectedRequest{get;set;}
    public string selectedRequestFromURL{get;set;}
    public String objectName{set;get;}
    public String selectedReqName{set;get;}
    public String warningMsg{get;set;}
    //public List<SelectOption> requestList {get;set;}
    public List<servicePortalWrap> servicePortalWrapList {get;set;}
    public List<servicePortalWrap> servicePortalWraptempList {get;set;}
    public List<CaseDocketFieldDefinition__c> caseDocketFieldDefList{get;set;}
    public Map<string,Id> mapForCaseDockets;
    public Map<string,string> mapForCaseDocketsName;
    public Map<string,Id> mapForCaseDocketsFields;
    public List<Case_Docket__c> caseDocketList;
    public List<sObject> passedIdRecordvalues;
    public List<String> listOfStrings {get; set;}
    public string textval {set; get;}
    public Boolean timer {get;set;}
    public string fieldDefintionsforCase;
    public string relatedId;  
    
    //Newly added for form page 
    public List<Case> CaseRecord{set;get;} //new list
    Public List<Case> caseListUpdate;
    Public Set<Id> caseListUpdateSet;
    public string CurrentVFPageName{get;set;}
    Public Map<Id,CaseDocketFieldData__c> caseDocketFieldDataMap;
    Public Map<String,CaseDocketFieldData__c> caseDocketFieldDataMaplabel;
    public Boolean isFormPage = false;
    Public Boolean SetFormActionVar = false;
    Public string docketFormAction;
    Public string docketBuTeam;
    Public Id CaseIdRec;
    Public Boolean ErrorMessageOnSave = false;
    Public Boolean SaveButtonClick = False;
    Public Boolean SuccessMessageOnSave = False;
    //Added for TS-8845
    Public string RecordIdObjName{get;set;}
    Public List<Case> MyCaseList{get;set;}
    Public List<AggregateResult> PopularItemList{get;set;}
    Public List<Case> casesForRecordIdinUrlcase{get;set;}
    Public List<Sobject> casesForRecordIdinUrlSobj{get;set;}
    Public Sobject SobjectRecsobj{get;set;}
    Public List<Sobject> SobjectRecs{get;set;}
    Public string CurrentPageRelatedID{get;set;}
    Public string RelatedIdObjName{get;set;}
    Public string RelatedIdObjectName{get;set;}
    Public List<Sobject> relatedObj{get;set;}
    Public List<CaseDocketFieldData__c> casesForRecordIdinUrlsobject{get;set;}
    
    //Added for TS-8935
    public String RecordidFromURLV1{set;get;}
    Public string RecordIdObjNameV1{get;set;}
    
    //Attachment TS-6516
    public String fileName{get;set;}
    public transient String fileBody;
    public string AttachmentId;
    public String getfileBody(){
        return fileBody;
    }
    public void setfileBody(String fileBody){
        this.fileBody = fileBody;
    }
    
    
    //************************************************************************************************************ Constructor
    public nimbleServicePortalControllerV1(){
        //additionalInfo = '';
        //requestList = new List<SelectOption>();
        //requestList.add(new SelectOption('None','None'));
        
        textval ='';
        selectedRequest= '';
        fieldDefintionsforCase = null;
        passedIdRecordvalues = new List<sObject>();
        listOfStrings = new List<String>();
        cdRecord = new List<Case_Docket__c>();
        CaseRecord = new List<Case>();//added for form page
        caseDocketList= new List<Case_Docket__c>();
        mapForCaseDockets = new Map<string,Id>();
        mapForCaseDocketsName = new Map<string,string>();
        mapForCaseDocketsFields = new Map<string,Id>();
        caseDocketFieldDefList = new List<CaseDocketFieldDefinition__c>();
        
        //Added for form page 
        caseDocketFieldDataMap =  New Map<Id,CaseDocketFieldData__c>();
        caseDocketFieldDataMaplabel =  New Map<String,CaseDocketFieldData__c>();
        CurrentVFPageName = ApexPages.currentPage().getUrl().substringAfter('apex/').split('\\?')[0];
        
        docketFormAction = '';
        docketBuTeam = '';
        caseListUpdate = New List<Case>();
        caseListUpdateSet = New Set<Id>();
        //Added for TS-8845
        MyCaseList = New List<Case>();
        PopularItemList = New List<AggregateResult>();
        casesForRecordIdinUrlcase = New List<Case>();
        SobjectRecs = New List<Sobject>();
        casesForRecordIdinUrlSobj = New List<Sobject>();
        casesForRecordIdinUrlsobject = New List<CaseDocketFieldData__c>();
        SobjectRecsobj = Schema.getGlobalDescribe().get('Case').newSObject() ;
        //Added end
        
        //Breadscrumb fuctionality - Added for TS-8845 By Exafort(Guru Dev) 18 Jan/2022
        CurrentPageRelatedID  = ApexPages.CurrentPage().getparameters().get('relatedId');//gets the related id from the URL
        if(CurrentPageRelatedID != null && CurrentPageRelatedID != ''){
            Id urlRelatedID = CurrentPageRelatedID;
            RelatedIdObjName = urlRelatedId.getSObjectType().getDescribe().getName();//gets the related id object name from the URL
            RelatedIdObjectName = (RelatedIdObjName == 'RMAv2__c' ? 'RMA' : RelatedIdObjName);
        }
        //Added for TS-8935 By Exafort(Guru Dev) 03 Feb/2022
        RecordidFromURLV1 = Apexpages.currentPage().getParameters().get('id');//Gets the Id from the URL
        if(RecordidFromURLV1 != null && RecordidFromURLV1 != '' && RecordidFromURLV1 !='recordid'){
            Id urlID = RecordidFromURLV1;
            RecordIdObjNameV1 = urlID.getSObjectType().getDescribe().getName();//Gets the URL Id object name
        }
        //Added End----TS-8935        
        //Added End
        //if(CurrentVFPageName.contains('Form')){
        //caseDocketList = [select Id,Name,cdLabel__c,cddonotupdateparentcase__c,cdDoNotSetParentCaseARF__c,cdEstimated_Time_to_Resolve__c,cdDocInternalURL__c,
        //cdCasePriority__c,cdHideOnPortal__c,cdResponsibleBUTeam__c,cdUnderlyingObject__c
        //From Case_Docket__c where cdDocketType__c !='Request']; //where cdHideOnPortal__c = false
        caseDocketList = [select Id,Name,cdLabel__c,cddonotupdateparentcase__c,cdDoNotSetParentCaseARF__c,
                          cdEstimated_Time_to_Resolve__c,cdDocInternalURL__c,cdCasePriority__c,cdHideOnPortal__c,
                          cdResponsibleBUTeam__c,cdUnderlyingObject__c From Case_Docket__c ORDER BY Name ASC]; //TS-8979 where cdHideOnPortal__c = false
        if(!caseDocketList.isEmpty()){
            for(Case_Docket__c cdocket: caseDocketList){
                //mapForCaseDockets.put(cdocket.Name,cdocket.Id);
                //listOfStrings.add(cdocket.Name);
                //Added underlying object field check with recordId objName for TS-8935 by Exafort(Guru Dev)
                if(cdocket.cdHideOnPortal__c == false && ((RecordIdObjNameV1 != null && cdocket.cdUnderlyingObject__c == RecordIdObjNameV1) 
                                                          || cdocket.cdUnderlyingObject__c == null /**TS-9051**/))
                {
                    listOfStrings.add(cdocket.cdLabel__c);    
                }
                mapForCaseDockets.put(cdocket.cdLabel__c,cdocket.Id);
                mapForCaseDocketsName.put(cdocket.Name,cdocket.cdLabel__c);
            }
            system.debug('listOfStrings---'+listOfStrings.size());
        }else{
            system.debug('### please add the records in the case docket object ###');
        }
        
        ChooseNameBasedOnURL();         //to get the request name passed from the URL.
        getFieldInfosFromCaseDocket();  //to process the wrapper list by querying the case docket field defintions based on the datatype of the fields.
        
        
    }
    
    //************************************************************************************************************ ChooseNameBasedOnURL
    public void ChooseNameBasedOnURL(){
        selectedRequestFromURL = ApexPages.currentPage().getParameters().get('name');
        system.debug('#### selectedRequestFromURL value ===>'+selectedRequestFromURL);
        //Added for form page
        //CurrentVFPageName = ApexPages.currentPage().getUrl().substringAfter('apex/').split('\\?')[0];
        system.debug('CurrentVFPageName---'+CurrentVFPageName);
        //added end
        if(selectedRequestFromURL != null){ 
            selectedRequest = mapForCaseDocketsName.get(selectedRequestFromURL); 
        }
        system.debug('#### Selected request ===>'+selectedRequest);
    }
    //************************************************************************************************************ getFieldInfosFromCaseDocket
    public void getFieldInfosFromCaseDocket(){
        system.debug('servicePortalWrapList---'+servicePortalWrapList);
        system.debug('servicePortalWraptempList----'+servicePortalWraptempList);
        
        
        servicePortalWrapList = new List<servicePortalWrap>();
        servicePortalWraptempList = new List<servicePortalWrap>();
        
        
        string requestObjname = null;
        
        RecordidFromURL = Apexpages.currentPage().getParameters().get('id');    //getting the "Id" value from the url.
        system.debug(' ### RecordidFromURL        ===> '+RecordidFromURL);
        system.debug(' ### selected Request Name  ===> '+selectedReqName);
        system.debug(' ### selected Request Label ===> '+selectedRequest);
        if(selectedReqName != null && (selectedRequest == null || selectedRequest =='')){//TS-8845
            List<Case_Docket__c> CaseDocketTempList = [Select id,cdLabel__c,name from Case_Docket__c where name =:selectedReqName and cdHideOnPortal__c = false];
            selectedRequest = CaseDocketTempList[0].cdLabel__c;
        }     
        
        //system.debug('### Selected value from picklist ==>'+selectedRequestFromURL);
        //selectedRequestFromURL = ApexPages.currentPage().getParameters().get('name');
        system.debug('#### selectedRequestFromURL value ===>'+selectedRequestFromURL);
        
        List<CaseDocketFieldData__c> caseDocketFieldDataList = New List<CaseDocketFieldData__c>();//List to Store CaseDocketFieldData records
        
        if(RecordidFromURL != null && (CurrentVFPageName.contains('Form') || CurrentVFPageName.contains('form'))){
            isFormPage =  true;
            system.Debug('it is form page');
            caseDocketFieldDataList = [select id,cdfdataCase__c,cdfdataCaseDocket__c,cdfdataCaseDocket__r.cdLabel__c,cdfdataCaseDocket__r.Name,
                                       Value__c,cdfdataCaseDocketFieldDefinition__c,cdfdataKeyName__c,cdfdataCaseDocketFieldDefinition__r.cdfdLabel__c
                                       from CaseDocketFieldData__c where cdfdataCase__c =: RecordidFromURL];
            CaseIdRec = RecordidFromURL;
            CaseRecord = [select id,CaseNumber,Subject,Account.Name,Contact.Name,OwnerId,Status from Case where Id =:RecordidFromURL];
            system.debug('selectedRequest----------'+selectedRequest);
            if(caseDocketFieldDataList.size () > 0 && (selectedRequest == null || selectedRequest == '')){
                system.debug('comes in line 144');
                selectedRequest = caseDocketFieldDataList[0].cdfdataCaseDocket__r.cdLabel__c;
                selectedReqName = caseDocketFieldDataList[0].cdfdataCaseDocket__r.Name;
                for(CaseDocketFieldData__c cdfdrec: caseDocketFieldDataList){
                    caseDocketFieldDataMap.put(cdfdrec.cdfdataCaseDocketFieldDefinition__c,cdfdrec);
                    //caseDocketFieldDataMaplabel.put(cdfdrec.cdfdataCaseDocketFieldDefinition__r.cdfdLabel__c,cdfdrec);
                }
            }
        }
        system.debug('selectedRequest value'+selectedRequest);
        //added end
        //Added for TS-8854 By Exafort(Guru Dev) on 02 Dec/2021
        if(RecordidFromURL != null && RecordidFromURL != '' && RecordidFromURL != 'recordid'){
            Id tempRecordidFromURL = Id.valueOf(RecordidFromURL); // To get the record id from the URL
            RecordIdObjName = tempRecordidFromURL.getSObjectType().getDescribe().getName(); //Object name from URL record id
            system.debug('RecordIdObjName---'+RecordIdObjName);
            Map<string,string> objectVal = New Map<string,string>(); //Map to hold the object fields in a key and value pair
            
            objectVal.put('Case','Id,CaseNumber,Account.Id,Account.Name,Asset.Id,Asset.SerialNumber,Contact.Id,Contact.Name');
            objectVal.put('Account','Id,Name');
            objectVal.put('Asset','Id,SerialNumber,Contact.Id,Contact.Name,Account.Id,Account.Name');
            objectVal.put('Contact','Id,Name,Account.Id,Account.Name');
            objectVal.put('RMAv2__c','Id,Name,rmaAssetId__c,rmaAssetSerialNumber__c,rmaCaseNumber__r.CaseNumber,rmaCaseNumber__c');
            objectVal.put('Asset_Stage__c','Id,Name');
            objectVal.put('AddressBook__c','Id,Name');
            objectVal.put('depot__c','Id,Name');
            objectVal.put('Opportunity','Id,Name');
            
            String QueryFieldName = objectVal.get(RecordIdObjName); //will have the query fields for object name from URL
            system.debug('QueryFieldName---'+QueryFieldName);
            List<string> relatedIdForRecordIdinUrl = New List<string>();//List to hold the related object record id for id passed in the URL
            
            if(QueryFieldName != null && QueryFieldName != ''){//Changed the conditon for TS-9047 By Exafort(Guru Dev)
                List<string> QueryFieldList = QueryFieldName.split(',');
                QueryFieldName = 'SELECT '+ QueryFieldName + ' From ' + RecordIdObjName  + ' WHERE id = \''+RecordidFromURL+'\'';
                SobjectRecs = Database.query(QueryFieldName); //Sobject list holds the record information for record id passed in the URL
                SobjectRecsobj = Database.query(QueryFieldName);//holds the same above info in a sobject
                for(string fieldsetval : QueryFieldList){
                    string fieldval = fieldsetval.remove('.');
                    if(fieldval.containsIgnoreCase('Id') || fieldval == 'rmaCaseNumber__c'){
                        if(String.valueOf((SobjectRecsobj.get(fieldval))) != null)
                            relatedIdForRecordIdinUrl.add(String.valueOf((SobjectRecsobj.get(fieldval)))); //Adding the related ids for record in the URL into single list
                    }
                }
            }
            
            
            //Breadscrumb functionality for getting the related Id record information
            if(CurrentPageRelatedID != null && RelatedIdObjName != null){ 
                string fields = objectVal.get(RelatedIdObjName); // gets the query fields for related id object name from the above map
                if(fields != null){
                    String queryString = 'SELECT '+fields+' FROM ' + RelatedIdObjName + ' WHERE Id=: CurrentPageRelatedID';
                    relatedObj = Database.query(queryString);//holds the related id record information from the URL
                }
                relatedIdForRecordIdinUrl.add(CurrentPageRelatedID); //Adding the related id for record in the URL
            }
            system.debug('relatedIdForRecordIdinUrl--'+relatedIdForRecordIdinUrl);
            
            string orConditions = null;
            for(string currentId : relatedIdForRecordIdinUrl){
                string relatedIDPrefix = currentId.substring (0, 3);
                string condition = null;                
                // Switch case to find the related ids object name for forming related cases section query
                switch on relatedIDPrefix {
                    When '500'{
                        condition  = 'CaseMapping__c = \'' + currentId + '\'';
                    }
                    When '02i'{
                        condition = 'Assetmapped__c = \''+ currentId + '\'';
                    }
                    When 'a5W'{
                        condition = 'Asset_Stage__c = \'' + currentId + '\'';
                    }
                    When 'a2D'{
                        condition = 'RMAmapped__c = \'' + currentId + '\'';
                    }
                    When 'a2G'{
                        condition = 'Depot__c = \'' + currentId + '\'';
                    }
                }
                
                if (condition != null){
                    orConditions = (orConditions != null ? orConditions + ' Or ' : '') + condition;
                }
                system.debug('orConditions---' + orConditions);
            }
            
            //For second vertical panel - holds the records for popular items section in the VF page
            PopularItemList =  [Select
                                caseDocket__r.cdLabel__c DocketLabel, Count(id) Total 
                                from Case
                                Where
                                Recordtype.name = 'Ops Case' and caseDocket__r.cdHideOnPortal__c = false 
                                and caseDocket__c != null
                                and caseDocket__r.cdUnderlyingObject__c =:RecordIdObjName//TS-8935
                                and createdby.Profile.Id =:userinfo.getProfileId()
                                group by 
                                caseDocket__r.cdLabel__c order by count(id) desc limit 15
                               ];
            
            system.debug('PopularItemList--' + PopularItemList.size());
            
            if(relatedIdForRecordIdinUrl != Null){
                //getting the related id equivalent data from case docket field data object
                casesForRecordIdinUrlsobject = [SELECT cdfdataCase__r.id from CaseDocketFieldData__c where Value__c IN : relatedIdForRecordIdinUrl order by CreatedDate DESC limit 15];
            }
            system.debug('casesForRecordIdinUrlsobject---'+casesForRecordIdinUrlsobject);
            
            string ids = '';
            if(casesForRecordIdinUrlsobject.size () > 0){
                //getting the case id for equivalent data from case docket field data object
                for (CaseDocketFieldData__c caseObj : casesForRecordIdinUrlsobject){
                    if (ids.length() > 0){
                        ids += ',';
                    }
                    ids += '\'' + caseObj.cdfdataCase__r.ID + '\'';
                }
            }
            system.debug('ids===='+ids);
            //Forming related cases section query
            String soqlQuery;
            String Recordtypename ='Ops Case';
            soqlQuery = 'SELECT Id,CaseNumber,Subject,CaseDocket__c,CaseDocket__r.cdUnderlyingObject__c from Case Where recordtype.Name = \'' + Recordtypename +'\'';
            
            boolean orConditionAdded = false;
            boolean idPresent = false;
            if (orConditions != null && orConditions.length() > 0){
                soqlQuery += ' and (' + orConditions;
                orConditionAdded = true;
            }
            
            if (ids != null && ids.length() > 0){
                soqlQuery +=  (orConditionAdded? ' or ' : ' and ( ') + ' id in (' + ids + '))';
                idPresent = True;
            }
            else{
                soqlQuery +=  ')';
            }
            
            soqlQuery += ' order by CreatedDate DESC limit 15';
            
            system.debug('Third Panel soqlQuery---' + soqlQuery);
            if(orConditionAdded || idPresent){
                casesForRecordIdinUrlSobj = Database.query(soqlQuery); //getting the related cases information in a sobject list 
            }
            if(casesForRecordIdinUrlSobj.size() > 0){
                casesForRecordIdinUrlcase = New List<Case>(); // To clear the existing items when using reset button in vf page(to avoid duplicate cases)
                casesForRecordIdinUrlcase.addAll((List<Case>)casesForRecordIdinUrlSobj);//converting sobject list into case object type list
                system.debug('casesForRecordIdinUrlcase--'+casesForRecordIdinUrlcase);
            }
        }
        else{//Added by Exafort(Guru Dev) for TS-9049
            PopularItemList =  [Select
                                caseDocket__r.cdLabel__c DocketLabel, Count(id) Total 
                                from Case
                                Where
                                Recordtype.name = 'Ops Case' and caseDocket__r.cdHideOnPortal__c = false 
                                and caseDocket__c != null
                                and createdby.Profile.Id =:userinfo.getProfileId()
                                group by 
                                caseDocket__r.cdLabel__c order by count(id) desc limit 15
                               ];
        }
        
        //For First vertical panel - On page load holds the records for My cases Section in the VF Page
        MyCaseList = [Select Id,ContactEmail,Owner.Id,CaseNumber,Status,Subject from Case Where Recordtype.Name ='OPS Case' and  (ContactEmail =:Userinfo.getUserEmail() or Owner.Id =:Userinfo.getUserId()) Order By CaseNumber DESC limit 15];
        //Added end for TS-8845
        
        Id caseDocketPortalTypeCheck = mapForCaseDockets.get(selectedRequest);
        if(selectedRequest != ''){
            if(caseDocketPortalTypeCheck != null){
                cdRecord = [select Id,Name,cdLabel__c,cdDescription__c,cddonotupdateparentcase__c,cdDoNotSetParentCaseARF__c,cdEstimated_Time_to_Resolve__c,
                            cdDocExternalURL__c,cdUnderlyingObject__c,cdJiraOrigin__c,cdJiraOrigin__r.Name,cdResponsibleBUTeam__c,cdFormAction__c,cdFormActionBuTeam__c 
                            From Case_Docket__c where cdLabel__c =:selectedRequest];  
                //Query to get the case docket field definitions
                system.debug('isFormPage---'+isFormPage);
                if(!isFormPage){
                    caseDocketFieldDefList = [select Id,Name,cdfdCaseDocket__c,cdfdDescription__c,cdfdFieldDefault__c,cdfdFieldOption__c,cdfdFieldType__c,
                                              cdfdHideOnPortal__c,cdfdLabel__c,cdfdOrdinal__c,cdfdReadOnly__c,cdfdRequired__c,cdfdUnderlyingObject__c,cdfdPortalType__c from 
                                              CaseDocketFieldDefinition__c where cdfdCaseDocket__r.cdLabel__c =:selectedRequest 
                                              and cdfdPortalType__c !='Form' Order By cdfdOrdinal__c]; //AND cdfdHideOnPortal__c = false
                }
                else if(isFormPage){
                    caseDocketFieldDefList = [select Id,Name,cdfdCaseDocket__c,cdfdDescription__c,cdfdFieldDefault__c,cdfdFieldOption__c,cdfdFieldType__c,
                                              cdfdHideOnPortal__c,cdfdLabel__c,cdfdOrdinal__c,cdfdReadOnly__c,cdfdRequired__c,cdfdUnderlyingObject__c,cdfdPortalType__c from 
                                              CaseDocketFieldDefinition__c where cdfdCaseDocket__r.cdLabel__c =:selectedRequest 
                                              Order By cdfdOrdinal__c]; //AND cdfdHideOnPortal__c = false
                }
                //code logic to get the object name from the passed record if from the URL.
                map<string,string> recordValues = new Map<string,string>();
                if(cdRecord != null && cdRecord.Size() > 0 )
                    requestObjname =cdRecord[0].cdUnderlyingObject__c; // added to display the warning message  - TS-6455
                requestObjname = requestObjname!= null ? requestObjname.replace('__c', '').replace('v2',''):'Object';
                docketFormAction = cdRecord[0].cdFormAction__c;
                docketBuTeam = cdRecord[0].cdFormActionBuTeam__c;
                
                if(RecordidFromURL != null && RecordidFromURL != '' && RecordidFromURL != 'recordid'){
                    String IdPrefix = RecordidFromURL.substring(0,3);
                    Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();
                    for(Schema.SObjectType stype : gd.values())
                    {
                        Schema.DescribeSObjectResult r = stype.getDescribe();
                        String prefix = r.getKeyPrefix();
                        if(prefix!=null && prefix.equals(IdPrefix))
                        {
                            objectName = r.getName();
                            System.debug('### Object Name======> ' + objectName);
                        }
                    }
                    Map <String, Schema.SObjectField> fieldMap = gd.get(objectName).getDescribe().fields.getMap();
                    sObject sObjectRec = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet()), ',') + ' FROM '+objectName + ' WHERE id = \''+RecordidFromURL+'\'');
                    for(Schema.SObjectField sfield : fieldMap.Values())
                    {
                        schema.describefieldresult dfield = sfield.getDescribe();
                        recordValues.put(dfield.getname(),String.valueOf(sObjectRec.get(dfield.getname())));
                    }
                    if(cdRecord != null && cdRecord.Size() > 0 ){
                        if(objectName == null || objectName != cdRecord[0].cdUnderlyingObject__c){//// added to display the warning message  - TS-6455
                            
                            warningMsg = 'This request must be made via the related '+requestObjname+'\'s home page';
                            
                        }
                    }
                }
                else{
                    system.debug('#### Record Id Not passed in the url ####');
                    warningMsg = 'This request must be made via the related '+requestObjname+'\'s home page';
                    // added to display the warning message  - TS-6455
                }
                system.debug('recordValues---'+recordValues);
                
                //Code logic to construct the wrapper list of fields for vf page display.
                //servicePortalWrapList.clear();
                System.debug('#### caseDocketFieldDefList list size ===>'+caseDocketFieldDefList.size());
                System.debug('#### caseDocketFieldDefList ===>'+caseDocketFieldDefList);
                
                for(CaseDocketFieldDefinition__c cdfd: caseDocketFieldDefList){
                    mapForCaseDocketsFields.put(cdfd.cdfdLabel__c,cdfd.Id);
                    servicePortalWrap  servicePortalW = new servicePortalWrap();
                    if(cdfd.cdfdFieldType__c == 'Text'){ // for Text datatype fields
                        //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                        if(cdfd.cdfdHideOnPortal__c == True){
                            servicePortalW.hideOnPortal = True;
                        }
                        //Added End
                        servicePortalW.isText = true;
                        servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                        servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                        servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                        if(cdfd.cdfdDescription__c != null){
                            servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                        }else{
                            servicePortalW.cfieldDesc = 'Please Add the Field Description';
                        }
                        if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                            servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                        } 
                        else{
                            servicePortalW.textvalue = null;
                        }
                        if(isFormPage){
                            CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                            if(cdfd.cdfdPortalType__c == 'Request'){
                                servicePortalW.cfieldReadOnly = True;
                            }
                            if(cdfdOldValues != null)
                                servicePortalW.textvalue = cdfdOldValues.Value__c; //added for form page
                        } 
                        
                        //fieldDefintionsforCase += fieldDefintionsforCase + servicePortalW.cfieldLabel + ' : ' + servicePortalW.textvalue;
                    }
                    else if(cdfd.cdfdFieldType__c == 'Picklist'){ // for picklist type fields
                        //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                        if(cdfd.cdfdHideOnPortal__c == True){
                            servicePortalW.hideOnPortal = True;
                        }
                        //Added End
                        servicePortalW.isPicklist = true;
                        servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                        servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                        servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                        if(cdfd.cdfdDescription__c != null){
                            servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                        }else{
                            servicePortalW.cfieldDesc = 'Please Add the Field Description';
                        }
                        if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                            servicePortalW.picklistVal= cdfd.cdfdFieldDefault__c;
                        }
                        //Added for form page
                        if(isFormPage){
                            CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                            if(cdfd.cdfdPortalType__c == 'Request'){
                                servicePortalW.cfieldReadOnly = True;
                            }
                            if(cdfdOldValues != null)
                                servicePortalW.picklistVal = cdfdOldValues.Value__c; //added for form page
                            //Added end 
                        } 
                        //else{
                        //    servicePortalW.picklistVal = 'None';
                        //}
                        //Added for TS-6903 by Exafort(Guru Dev) on 24May/2022
                        String pipeRemoveVal;
                        List<String> lstpklist = New List<String>();
                        if(cdfd.cdfdFieldOption__c.startsWith('|')){
                            pipeRemoveVal = cdfd.cdfdFieldOption__c.removeStart('|');
                            lstpklist = pipeRemoveVal.split('\\|');
                        }
                        else
                            lstpklist =  cdfd.cdfdFieldOption__c.split('\\|');//Added end                      
                        system.debug('lstpklist---'+lstpklist);
                        List<selectOption> lstselectoption = new List<selectoption>();
                        lstselectoption.add(new SelectOption('','--None--'));//Added for TS-6903 by Exafort(Guru Dev) on 23May/2022
                        for(String s : lstpklist){
                            lstselectoption.add(new SelectOption(s,s));
                        }
                        servicePortalW.picklistValues = lstselectoption;
                        
                    }
                    else if(cdfd.cdfdFieldType__c == 'Boolean'){ //for Boolean type fields
                        //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                        if(cdfd.cdfdHideOnPortal__c == True){
                            servicePortalW.hideOnPortal = True;
                        }
                        //Added End
                        servicePortalW.isCheckbox = true;
                        servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                        servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                        servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                        if(cdfd.cdfdDescription__c != null){
                            servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                        }else{
                            servicePortalW.cfieldDesc = 'Please Add the Field Description';
                        }
                        if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                            servicePortalW.isCheckboxSelected = Boolean.valueOf(cdfd.cdfdFieldDefault__c);
                        }else{
                            servicePortalW.isCheckboxSelected = false;
                        }
                        //Added for form page
                        if(isFormPage){
                            CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                            if(cdfd.cdfdPortalType__c == 'Request'){
                                servicePortalW.cfieldReadOnly = True;
                            }
                            if(cdfdOldValues != null)
                                servicePortalW.isCheckboxSelected = Boolean.valueOf(cdfdOldValues.Value__c); //added for form page
                            //Added end 
                        }     
                    }
                    else if(cdfd.cdfdFieldType__c == 'Text Area'){ //for Text area type fields
                        //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                        if(cdfd.cdfdHideOnPortal__c == True){
                            servicePortalW.hideOnPortal = True;
                        }
                        //Added End
                        servicePortalW.isTextArea = true;
                        servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                        servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                        servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                        if(cdfd.cdfdDescription__c != null){
                            servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                        }else{
                            servicePortalW.cfieldDesc = 'Please Add the Field Description';
                        }
                        if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                            servicePortalW.textAreaValue = string.valueOf(cdfd.cdfdFieldDefault__c);
                        }else{
                            servicePortalW.textAreaValue = null;
                        }
                        //Added for form page
                        system.debug('isFormPage--'+isFormPage);
                        if(isFormPage){
                            CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                            if(cdfd.cdfdPortalType__c == 'Request'){
                                servicePortalW.cfieldReadOnly = True;
                            }
                            if(cdfdOldValues != null)
                                servicePortalW.textAreaValue = cdfdOldValues.Value__c; //added for form page
                            //Added end 
                        }                    
                    }
                    else if(cdfd.cdfdFieldType__c == 'Attachment'){ //for attachment TS-6516
                        if(cdfd.cdfdHideOnPortal__c == True){
                            servicePortalW.hideOnPortal = True;
                        }
                        servicePortalW.IsAttachment = true;
                        servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                        servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                        servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                        if(cdfd.cdfdDescription__c != null){
                            servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                        }else{
                            servicePortalW.cfieldDesc = 'Please Add the Field Description';
                        }
                        /*if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
								servicePortalW.textAreaValue = string.valueOf(cdfd.cdfdFieldDefault__c);
								}else{
								 servicePortalW.textAreaValue = null;
									}*/
                        //Added for form page
                        system.debug('isFormPage--'+isFormPage);
                        if(isFormPage){
                            //CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                            //if(cdfd.cdfdPortalType__c == 'Request'){
                            servicePortalW.cfieldReadOnly = True;
                            // }
                            //  if(cdfdOldValues != null)
                            //      servicePortalW.textAreaValue = cdfdOldValues.Value__c; //added for form page
                            //Added end
                        }  
                        
                    }
                    
                    else if(cdfd.cdfdFieldType__c == 'API' ){ //for API type fields
                        system.debug('comes in api '+cdfd.cdfdLabel__c);
                        
                        
                        system.debug('### Object Name ==>'+objectName);
                        system.debug('#### Id from the URL ===>'+RecordidFromURL);
                        system.debug('### Object Name in CDFD ==>'+cdfd.cdfdUnderlyingObject__c);
                        
                        //code to get picklist/multiselectpicklist from schema.
                        servicePortalW.isApI = false;
                        Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(cdfd.cdfdUnderlyingObject__c).getDescribe();
                        Map<String,Schema.SObjectField> fieldMap = dsr.fields.getMap();
                        Schema.SObjectField field = fieldMap.get(cdfd.cdfdFieldOption__c);
                        if(field != null)
                        {
                            Schema.DescribeFieldResult dfr = field.getDescribe();
                            System.debug('### field type ===>'+ dfr.getType());
                            if(dfr.getType()==Schema.DisplayType.Picklist){
                                //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                                if(cdfd.cdfdHideOnPortal__c == True){
                                    servicePortalW.hideOnPortal = True;
                                }
                                //Added End
                                servicePortalW.isPicklist = true;
                                servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                                servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                                servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                                if(cdfd.cdfdDescription__c != null){
                                    servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                                }else{
                                    servicePortalW.cfieldDesc = 'Please Add the Field Description';
                                }
                                
                                //code block to get the list of picklist vlaues.
                                List<selectOption> lstSelectOptions = new List<selectoption>();
                                List<Schema.PicklistEntry> pickListValList = dfr.getPicklistValues();
                                for( Schema.PicklistEntry pickListVal : pickListValList){
                                    lstSelectOptions.add(new SelectOption(pickListVal.getLabel(),pickListVal.getValue()));
                                }
                                servicePortalW.picklistValues = lstSelectOptions;
                                
                                if(RecordidFromURL != null && RecordidFromURL != 'recordid' && RecordidFromURL != '' && !isFormPage){//TS-9050 Added "RecordidFromURL != ''" when id is not passed in the URL
                                    servicePortalW.picklistVal = recordValues.get(cdfd.cdfdFieldOption__c);
                                }
                                //added for form page
                                if(isFormPage){
                                    CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                                    if(cdfd.cdfdPortalType__c == 'Request'){
                                        servicePortalW.cfieldReadOnly = True;
                                    }
                                    if(cdfdOldValues != null)
                                        servicePortalW.picklistVal = cdfdOldValues.Value__c; 
                                    //Added end 
                                }   
                                //}else{
                                //   servicePortalW.picklistVal = recordValues.get(cdfd.cdfdFieldOption__c);
                                //}
                            }
                            else if(dfr.getType()==Schema.DisplayType.Boolean){
                                //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                                if(cdfd.cdfdHideOnPortal__c == True){
                                    servicePortalW.hideOnPortal = True;
                                }
                                //Added End
                                servicePortalW.isCheckbox = true;
                                servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                                servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                                servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                                if(cdfd.cdfdDescription__c != null){
                                    servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                                }else{
                                    servicePortalW.cfieldDesc = 'Please Add the Field Description';
                                }
                                if(RecordidFromURL != null && RecordidFromURL != 'recordid' && RecordidFromURL != '' && !isFormPage){//TS-9050
                                    if(cdfd.cdfdFieldOption__c != null && !isFormPage)
                                        servicePortalW.isCheckboxSelected = Boolean.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));
                                }else if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                                    servicePortalW.isCheckboxSelected = Boolean.valueOf(cdfd.cdfdFieldDefault__c);
                                }else{
                                    servicePortalW.isCheckboxSelected = false;
                                }
                                //added for form page
                                if(isFormPage){
                                    CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                                    if(cdfd.cdfdPortalType__c == 'Request'){
                                        servicePortalW.cfieldReadOnly = True;
                                    }
                                    if(cdfdOldValues != null)
                                        servicePortalW.isCheckboxSelected = Boolean.ValueOf(cdfdOldValues.Value__c); 
                                    //Added end 
                                }   
                                
                            }
                            else if(dfr.getType() == Schema.DisplayType.STRING  || dfr.getType() == Schema.DisplayType.MULTIPICKLIST){
                                //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                                if(cdfd.cdfdHideOnPortal__c == True){
                                    servicePortalW.hideOnPortal = True;
                                }
                                //Added End
                                servicePortalW.isText = true;
                                servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                                servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                                servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                                if(cdfd.cdfdDescription__c != null){
                                    servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                                }else{
                                    servicePortalW.cfieldDesc = 'Please Add the Field Description';
                                }
                                if(RecordidFromURL != null && RecordidFromURL != 'recordid' && RecordidFromURL != '' && !isFormPage){//TS-9050
                                    servicePortalW.textvalue = recordValues.get(cdfd.cdfdFieldOption__c);
                                } 
                                else if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                                    servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                                }
                                else{
                                    servicePortalW.textvalue = null;
                                }
                                //Added for form page
                                if(isFormPage){
                                    CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                                    if(cdfd.cdfdPortalType__c == 'Request'){
                                        servicePortalW.cfieldReadOnly = True;
                                    }
                                    if(cdfdOldValues != null)
                                        servicePortalW.textvalue = cdfdOldValues.Value__c; 
                                    //Added end 
                                }   
                                
                            }
                            else if(dfr.getType() == Schema.DisplayType.TEXTAREA){
                                //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                                if(cdfd.cdfdHideOnPortal__c == True){
                                    servicePortalW.hideOnPortal = True;
                                }
                                //Added End
                                servicePortalW.isTextArea = true;
                                servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                                servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                                servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                                if(cdfd.cdfdDescription__c != null){
                                    servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                                }else{
                                    servicePortalW.cfieldDesc = 'Please Add the Field Description';
                                }
                                if(RecordidFromURL != null && RecordidFromURL != 'recordid'&& RecordidFromURL != '' && !isFormPage){//TS-9050
                                    servicePortalW.textAreaValue = recordValues.get(cdfd.cdfdFieldOption__c);
                                } 
                                else if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                                    servicePortalW.textAreaValue = cdfd.cdfdFieldDefault__c;
                                }else{
                                    servicePortalW.textAreaValue = null;
                                }
                                //Added for form page
                                if(isFormPage){
                                    CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                                    if(cdfd.cdfdPortalType__c == 'Request'){
                                        servicePortalW.cfieldReadOnly = True;
                                    }
                                    if(cdfdOldValues != null)
                                        servicePortalW.textAreaValue = cdfdOldValues.Value__c;
                                }//Added end  
                            }
                            else if(dfr.getType() == Schema.DisplayType.ID){
                                //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                                if(cdfd.cdfdHideOnPortal__c == True){
                                    servicePortalW.hideOnPortal = True;
                                    if(RecordidFromURL != null && RecordidFromURL != '')
                                        servicePortalW.isText = True;
                                }
                                if(cdfd.cdfdHideOnPortal__c == false){
                                    servicePortalW.isText = true;  
                                }
                                //Added End
                                servicePortalW.isApI = true;
                                servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                                servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                                servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                                if(cdfd.cdfdDescription__c != null){
                                    servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                                }else{
                                    servicePortalW.cfieldDesc = 'Please Add the Field Description';
                                }
                                if(RecordidFromURL != null && RecordidFromURL != 'recordid' && RecordidFromURL != '' && !isFormPage){//TS-9050
                                    servicePortalW.textvalue = String.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));
                                } 
                                else if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                                    servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                                }
                                else{
                                    servicePortalW.textvalue = null;
                                }
                                //Added for form page
                                if(isFormPage){
                                    CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                                    if(cdfd.cdfdPortalType__c == 'Request'){
                                        servicePortalW.cfieldReadOnly = True;
                                    }
                                    if(cdfdOldValues != null)
                                        servicePortalW.textvalue = String.ValueOf(cdfdOldValues.Value__c);
                                }//Added end  
                                
                            }
                            /**else if(dfr.getType() == Schema.DisplayType.ID && cdfd.cdfdHideOnPortal__c == true){
servicePortalW.isText = false;  
servicePortalW.isApI = true;
servicePortalW.hideOnPortal = true;
servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
if(cdfd.cdfdDescription__c != null){
servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
}else{
servicePortalW.cfieldDesc = 'Please Add the Field Description';
}
if(RecordidFromURL != null && RecordidFromURL != 'recordid' && !isFormPage){
servicePortalW.textvalue = String.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));

} 
else if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
}
else{
servicePortalW.textvalue = null;
}
//Added for form page
if(isFormPage){
CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
if(cdfd.cdfdPortalType__c == 'Request'){
servicePortalW.cfieldReadOnly = True;
}
if(cdfdOldValues != null)
servicePortalW.textvalue = String.ValueOf(cdfdOldValues.Value__c);
}//Added end  

}*/
                            else if(dfr.getType() == Schema.DisplayType.REFERENCE){
                                //Added for TS-7856 By Exafort(Guru Dev) on 01/25/22
                                if(cdfd.cdfdHideOnPortal__c == True){
                                    servicePortalW.hideOnPortal = True;
                                }
                                //Added End
                                servicePortalW.isText = true;
                                servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                                servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                                servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                                if(cdfd.cdfdDescription__c != null){
                                    servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                                }else{
                                    servicePortalW.cfieldDesc = 'Please Add the Field Description';
                                }
                                if(RecordidFromURL != null && RecordidFromURL != 'recordid' && RecordidFromURL != '' && !isFormPage){//TS-9050
                                    servicePortalW.textvalue = String.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));
                                } 
                                else if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                                    servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                                }
                                else{
                                    servicePortalW.textvalue = null;
                                }
                                //Added for form page
                                if(isFormPage){
                                    CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                                    if(cdfd.cdfdPortalType__c == 'Request'){
                                        servicePortalW.cfieldReadOnly = True;
                                    }
                                    if(cdfdOldValues != null)
                                        servicePortalW.textvalue = String.ValueOf(cdfdOldValues.Value__c);
                                }//Added end  
                                
                            }
                            else{
                                servicePortalW.isText = true;
                                servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                                servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                                servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                                if(cdfd.cdfdDescription__c != null){
                                    servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                                }else{
                                    servicePortalW.cfieldDesc = 'Please Add the Field Description';
                                }
                                if(RecordidFromURL != null && RecordidFromURL != 'recordid' && RecordidFromURL != ''&& !isFormPage){
                                    servicePortalW.textvalue = String.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));
                                } 
                                else if(cdfd.cdfdFieldDefault__c != null && !isFormPage){
                                    servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                                }
                                else{
                                    servicePortalW.textvalue = null;
                                }
                                //Added for form page
                                if(isFormPage){
                                    CaseDocketFieldData__c cdfdOldValues = caseDocketFieldDataMap.get(cdfd.id);
                                    if(cdfd.cdfdPortalType__c == 'Request'){
                                        servicePortalW.cfieldReadOnly = True;
                                    }
                                    if(cdfdOldValues != null)
                                        servicePortalW.textvalue = String.ValueOf(cdfdOldValues.Value__c);
                                }//Added end  
                                
                                
                            }
                        }
                        else
                        {
                            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please enter valid field api names'));
                        }
                    }
                    if((cdfd.cdfdPortalType__c =='Request' && !isFormPage || cdfd.cdfdPortalType__c !='Form' && !isFormPage ||cdfd.cdfdPortalType__c =='Both' ||
                        isFormPage)){
                            servicePortalWrapList.add(servicePortalW);
                        }
                }
                system.debug('### final list retuning to page ==>'+servicePortalWrapList);
                system.debug('### final list size retuning to page ==>'+servicePortalWrapList.size());
                
                
            }
            else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Selected Case docket  ' + selectedRequest +'  is defined Hide On Portal'));
            }
        }else{
            if(cdRecord.size() > 0){
                cdRecord.clear();
                System.debug('### No Request has selected');
            }
        }
    }
    //method for save button
    //************************************************************************************************************ insertCaseDocketFieldData1
    public void insertCaseDocketFieldData1(){
        SaveButtonClick = True;
        system.debug('filename--'+filename);
        system.debug('filebody--'+filebody);
        insertCaseDocketFieldData();
        ClearAttachmentNameBody();
        if(SaveButtonClick && ErrorMessageOnSave && !SuccessMessageOnSave)
            system.debug('comes in IF');
        else
            getFieldInfosFromCaseDocket();
        
    }
    //method for save & new button
    
    
    //************************************************************************************************************ insertCaseDocketFieldData2
    public void insertCaseDocketFieldData2(){
        
        SaveButtonClick = True;
        insertCaseDocketFieldData();
        ClearAttachmentNameBody();
        servicePortalWrapList = servicePortalWraptempList ; // copying the list to show the same values after clicking "Save and New Button"
        system.debug('servicePortalWrapList---'+servicePortalWrapList);
        system.debug('servicePortalWraptempList---'+servicePortalWraptempList);
        
    }
    //************************************************************************************************************ insertCaseDocketFieldData
    public void SetFormAction(){
        SetFormActionVar = True;
        insertCaseDocketFieldData2();
        //servicePortalWrapList = servicePortalWraptempList ;
    }
    //***************************************************************************************************************
    public void ClearAttachmentNameBody(){//Added to remove the attachment cache when clicking save button for second cas
        if(SaveButtonClick){
           fileName ='';
           fileBody = '';
        }
    }
    //***************************************************************************************************************
    public void insertCaseDocketFieldData(){
        
        
        relatedId = null;
        Boolean allowcaseinsert = false;
        system.debug('### insertCaseDocketFieldData method calling ===>'+textval);
        List<CaseDocketFieldData__c> ListToInsert = new List<CaseDocketFieldData__c>();
        List<CaseDocketFieldData__c> ListToUpdate = new List<CaseDocketFieldData__c>();
        Set<Id> ListToUpdateSet = new Set<Id>();
        
        system.debug('### insertCaseDocketFieldData method calling ===>');
        
        servicePortalWraptempList = servicePortalWrapList;
        system.debug('### size of the servicePortalWraptempList ==>'+servicePortalWraptempList.size());
        
        if(CaseIdRec != null){
            List<CaseDocketFieldData__c> caseDocketFieldDataNewList = New List<CaseDocketFieldData__c>();//List to avoid multiple case update on save button click
            caseDocketFieldDataNewList = [select id,cdfdataCase__c,cdfdataCaseDocket__c,cdfdataCaseDocket__r.cdLabel__c,cdfdataCaseDocket__r.Name,
                                          Value__c,cdfdataCaseDocketFieldDefinition__c,cdfdataKeyName__c,cdfdataCaseDocketFieldDefinition__r.cdfdLabel__c
                                          from CaseDocketFieldData__c where cdfdataCase__c =: CaseIdRec];
            for(CaseDocketFieldData__c CDFDNValues: caseDocketFieldDataNewList){
                caseDocketFieldDataMaplabel.put(CDFDNValues.cdfdataCaseDocketFieldDefinition__r.cdfdLabel__c,CDFDNValues);
            }
        }
        
        
        if(!servicePortalWraptempList.isEmpty()){
            additionalInfo = '\r\n   ' ;
            additionalInfo += '\r\n  ' ;
            Boolean PicklistValueNull = false;
            Boolean TextValueNull = false;
            Boolean TextAreaValueNull = false;
            Boolean  CheckboxValue = false;
            Boolean attachmentValueNull = false;//Attachment TS-6516
            
            for(servicePortalWrap ssportalrec:servicePortalWrapList){
                /*if(ssportalrec.cfieldLabel == 'Is this under duress ?'){
if(ssportalrec.isCheckboxSelected == true){
isThisUnderDuress = true;
}
}else 
if(ssportalrec.cfieldLabel == 'Additional Info'){
additionalInfo += ssportalrec.textAreaValue + '\r\n';
}*/
                
                
                if(ssportalrec.ischeckbox){
                    
                    additionalInfo += ssportalrec.cfieldLabel + ' : ' + String.valueOf(ssportalrec.isCheckboxSelected) + '\r\n';
                    
                    if(ssportalrec.cfieldLabel == 'Is this under duress ?'){
                        if(ssportalrec.isCheckboxSelected == true){
                            
                            isThisUnderDuress = true;
                        }
                    }
                    
                }else if(ssportalrec.isApI){
                    String id = String.escapeSingleQuotes(ssportalrec.textvalue);
                    
                    String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                    if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
                        relatedId = ssportalrec.textvalue;
                        additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textvalue +'     '+ baseUrl+'/'+ssportalrec.textvalue + '\r\n';  
                    }else{
                        //TS-7856 By Guru Dev(Exafort)
                        if(ssportalrec.textvalue == null){
                            ssportalrec.textvalue = ''; 
                        }
                        //Added end
                        additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textvalue + '\r\n'; 
                    }
                }else if(ssportalrec.isPicklist){
                    //TS-7856 By Guru Dev(Exafort)
                    if(String.valueOf(ssportalrec.picklistVal) == null){
                        ssportalrec.picklistVal = '';
                    }
                    //Added end
                    additionalInfo += ssportalrec.cfieldLabel + ' :  ' + String.valueOf(ssportalrec.picklistVal) + '\r\n';
                }else if(ssportalrec.isTextArea){
                    //TS-7856 By Guru Dev(Exafort)
                    if(ssportalrec.textAreaValue == null){
                        ssportalrec.textAreaValue = '';
                    }
                    //Added end
                    additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textAreaValue + '\r\n';
                }else if(ssportalrec.isText){
                    
                    /*String id = String.escapeSingleQuotes(ssportalrec.textvalue); 
String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textvalue +'     '+ baseUrl+'/'+ssportalrec.textvalue + '\r\n';  
}else{
additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textvalue + '\r\n'; 
}*/
                    //TS-7856 By Guru Dev(Exafort)
                    if(ssportalrec.textvalue == null){
                        ssportalrec.textvalue = '';
                    }
                    //Added end
                    additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textvalue + '\r\n'; 
                }
                else if(ssportalrec.IsAttachment && fileName != '' && fileBody != ''){//Attachment TS-6516
                    additionalInfo += ssportalrec.cfieldLabel + ' :  ' + string.valueOf(filename) + '\r\n';
                }
                
                
                if(ssportalrec.isText ||
                   ssportalrec.isPicklist || 
                   ssportalrec.isTextArea ||
                   ssportalrec.IsAttachment && fileName != '' ||//attachment
                   ssportalrec.ischeckbox){
                       allowcaseinsert = true;
                   }
                if(ssportalrec.isPicklist && ssportalrec.cfieldRequired && (ssportalrec.picklistVal == null ||ssportalrec.picklistVal =='')){
                    PicklistValueNull = True;
                    
                }
                if(ssportalrec.isText && ssportalrec.cfieldRequired && (ssportalrec.textValue == null ||ssportalrec.textValue =='')){
                    TextValueNull = True;
                    
                }
                if(ssportalrec.isTextArea && ssportalrec.cfieldRequired && (ssportalrec.textAreaValue == null ||ssportalrec.textAreaValue =='')){
                    TextAreaValueNull = True;
                    
                }
                if(ssportalrec.ischeckbox && ssportalrec.cfieldRequired && (!ssportalrec.ischeckboxSelected)){
                    CheckboxValue = True;
                    
                }
                if(ssportalrec.IsAttachment && ssportalrec.cfieldRequired && (fileName == null || fileName =='')){//Attachment TS-6516
                    attachmentValueNull = True;
                }
                
                system.debug('#### allowcaseinsert===>'+allowcaseinsert);
            }
            
            if(allowcaseinsert && !PicklistValueNull && !TextValueNull && !TextAreaValueNull && !CheckboxValue && !attachmentValueNull){
                
                system.debug('#### additionalInfo ====>'+additionalInfo);
                system.debug('#### isThisUnderDuress ====>'+isThisUnderDuress);
                system.debug('#### relatedId ====>'+relatedId);
                
                
                if(relatedId == null){
                    relatedId = 'Not-A-Valid-SF-Id';
                }
                system.debug('#### additionalInfo ====>'+additionalInfo);
                system.debug('#### isThisUnderDuress ====>'+isThisUnderDuress);
                system.debug('#### relatedId ====>'+relatedId);
                //passing parameters to create a case and returning the case id.
                Id insertedcCaseId = insertOpsCase(additionalInfo,isThisUnderDuress,relatedId,isFormPage,docketFormAction,docketBuTeam);
                system.debug('insertedcCaseId--'+insertedcCaseId);
                //If the case id returned from the above method is not null ,looping through the list returned from vf page to create case docket field data.
                if(insertedcCaseId != null){
                    for(servicePortalWrap ssportal:servicePortalWrapList){
                        if(ssportal.ischeckbox){// if(ssportal.ischeckbox && ssportal.ischeckboxSelected) changed for TS-7856
                            CaseDocketFieldData__c cdfdata = new CaseDocketFieldData__c();
                            cdfdata.cdfdataCaseDocket__c = mapForCaseDockets.get(selectedRequest);
                            cdfdata.cdfdataCaseDocketFieldDefinition__c = mapForCaseDocketsFields.get(ssportal.cfieldLabel);
                            cdfdata.Value__c = String.valueOf(ssportal.isCheckboxSelected);
                            cdfdata.cdfdataCase__c = insertedcCaseId;
                            if(ssportal.cfieldLabel == 'Is this under duress ?' && !ssportal.ischeckboxSelected)// To avoid creation of case docket field data for default definitions TS-7856
                                ssportal.IsthisunderduressNull = True;
                            if(isFormPage){
                                CaseDocketFieldData__c cdfdID = caseDocketFieldDataMaplabel.get(ssportal.cfieldLabel);
                                if(cdfdID !=null){
                                    cdfdata.id = cdfdID.Id;
                                    if(cdfdID.Value__c == null)//TS-7856 (Guru Dev) to avoid irregular update when old case docket field data is null
                                        cdfdID.Value__c = '';
                                    if(cdfdID.Value__c != String.valueOf(ssportal.isCheckboxSelected)){
                                        if(ListToUpdateSet.Contains(cdfdata.Id)){
                                        }
                                        else{
                                            ListToUpdateSet.add(cdfdata.id);
                                            ListToUpdate.add(cdfdata);
                                        }
                                    }
                                }
                                else if(cdfdID == null){
                                    if(ssportal.cfieldLabel != 'Is this under duress ?'){
                                        ListToInsert.add(cdfdata);
                                    }
                                }     
                            }
                            else
                                if(!ssportal.IsthisunderduressNull)//TS-7856
                                ListToInsert.add(cdfdata);
                        }
                        else if(ssportal.isText){//TS-7856
                            CaseDocketFieldData__c cdfdata = new CaseDocketFieldData__c();
                            cdfdata.cdfdataCaseDocket__c = mapForCaseDockets.get(selectedRequest);
                            cdfdata.cdfdataCaseDocketFieldDefinition__c = mapForCaseDocketsFields.get(ssportal.cfieldLabel);
                            cdfdata.Value__c = String.valueOf(ssportal.textValue);
                            cdfdata.cdfdataCase__c = insertedcCaseId;
                            if(isFormPage){
                                CaseDocketFieldData__c cdfdID = caseDocketFieldDataMaplabel.get(ssportal.cfieldLabel);
                                if(cdfdID !=null){
                                    cdfdata.id = cdfdID.Id;
                                    if(cdfdID.Value__c == null)//TS-7856
                                        cdfdID.Value__c = '';
                                    if(cdfdID.Value__c != String.valueOf(ssportal.textValue)){
                                        if(ListToUpdateSet.Contains(cdfdata.Id)){
                                        }
                                        else{
                                            ListToUpdateSet.add(cdfdata.id);
                                            ListToUpdate.add(cdfdata);
                                            
                                        }
                                        
                                    }
                                }
                                else
                                    ListToInsert.add(cdfdata);
                            }
                            else
                                ListToInsert.add(cdfdata);
                        }
                        else if(ssportal.isPicklist){//TS-7856
                            CaseDocketFieldData__c cdfdata = new CaseDocketFieldData__c();
                            cdfdata.cdfdataCaseDocket__c = mapForCaseDockets.get(selectedRequest);
                            cdfdata.cdfdataCaseDocketFieldDefinition__c = mapForCaseDocketsFields.get(ssportal.cfieldLabel);
                            cdfdata.Value__c = String.valueOf(ssportal.picklistVal);
                            cdfdata.cdfdataCase__c = insertedcCaseId;
                            if(isFormPage){
                                CaseDocketFieldData__c cdfdID = caseDocketFieldDataMaplabel.get(ssportal.cfieldLabel);
                                if(cdfdID !=null){
                                    cdfdata.id = cdfdID.Id;
                                    if(cdfdID.Value__c == null)//TS-7856
                                        cdfdID.Value__c = '';
                                    if(cdfdID.Value__c != String.valueOf(ssportal.picklistVal)){
                                        if(ListToUpdateSet.Contains(cdfdata.Id)){
                                        }
                                        else{
                                            ListToUpdateSet.add(cdfdata.id);
                                            ListToUpdate.add(cdfdata);
                                            
                                        }
                                    }
                                }
                                else
                                    ListToInsert.add(cdfdata);
                            }
                            else
                                ListToInsert.add(cdfdata);
                        }
                        else if(ssportal.IsAttachment && fileName != ''&& fileBody !=''){//Attachment TS-6516
                            CaseDocketFieldData__c cdfdata = new CaseDocketFieldData__c();
                            cdfdata.cdfdataCaseDocket__c = mapForCaseDockets.get(selectedRequest);
                            cdfdata.cdfdataCaseDocketFieldDefinition__c = mapForCaseDocketsFields.get(ssportal.cfieldLabel);
                            cdfdata.Value__c = AttachmentId;
                            cdfdata.cdfdataCase__c = insertedcCaseId;
                            if(isFormPage){
                                CaseDocketFieldData__c cdfdID = caseDocketFieldDataMaplabel.get(ssportal.cfieldLabel);
                                if(cdfdID !=null){
                                    cdfdata.id = cdfdID.Id;
                                    if(cdfdID.Value__c != String.valueOf(fileName)){
                                        if(ListToUpdateSet.Contains(cdfdata.Id)){
                                            system.debug('id already present');
                                        }
                                        else{
                                            ListToUpdateSet.add(cdfdata.id);
                                            ListToUpdate.add(cdfdata);
                                            
                                        }
                                        
                                    }
                                    system.debug('ListToUpdate--'+ListToUpdate);
                                }
                                else
                                    ListToInsert.add(cdfdata);
                            }
                            else
                                ListToInsert.add(cdfdata);
                        }
                        else if(ssportal.isTextArea){//TS-7856
                            CaseDocketFieldData__c cdfdata = new CaseDocketFieldData__c();
                            cdfdata.cdfdataCaseDocket__c = mapForCaseDockets.get(selectedRequest);
                            cdfdata.cdfdataCaseDocketFieldDefinition__c = mapForCaseDocketsFields.get(ssportal.cfieldLabel);
                            String txtArea = String.valueOf(ssportal.textAreaValue);
                            if(String.isNotEmpty(txtArea)  && txtArea.length() > 255)
                            {
                                cdfdata.Value__c =txtArea.subString(0,255);
                            }
                            else
                            {
                                cdfdata.Value__c = txtArea;
                            }
                            cdfdata.cdfdataCase__c = insertedcCaseId;
                            if(ssportal.cfieldLabel == 'Additional Info' && ssportal.textAreaValue == '')
                                ssportal.AdditionalInfoNull = True;
                            if(isFormPage){
                                CaseDocketFieldData__c cdfdID = caseDocketFieldDataMaplabel.get(ssportal.cfieldLabel);
                                if(cdfdID !=null){
                                    cdfdata.id = cdfdID.Id;
                                    if(cdfdID.Value__c == null)//TS-7856
                                        cdfdID.Value__c = '';
                                    if(cdfdID.Value__c != String.valueOf(ssportal.textAreaValue)){
                                        if(ListToUpdateSet.Contains(cdfdata.Id)){
                                        }
                                        else{
                                            ListToUpdateSet.add(cdfdata.id);
                                            ListToUpdate.add(cdfdata);
                                            
                                        } 
                                    }
                                }
                                else if(cdfdID == null){
                                    if(ssportal.cfieldLabel != 'Additional Info'){
                                        ListToInsert.add(cdfdata);
                                    }
                                }
                                
                            }
                            else
                                if(!ssportal.AdditionalInfoNull)//TS-7856
                                ListToInsert.add(cdfdata);
                        }  
                    }
                    
                    if(!ListToInsert.IsEmpty()){
                        system.debug('ListToInsert---'+ListToInsert);
                        insert ListToInsert;
                        //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Field Defintions Saved Successfully'));
                        //calling the timeron method to get the time when the page messages is displayed.
                        timerOn();
                    }
                    else{
                        System.debug('### ListToInsert is Empty');
                    }
                    
                    if(!ListToUpdate.IsEmpty() || !caseListUpdate.IsEmpty() || !ListToInsert.IsEmpty() && isFormPage){
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Case Updated Successfully'));
                        timerOn();
                        if(!ListToUpdate.IsEmpty()){
                            update ListToUpdate;
                        }
                    }
                    else if(isFormPage){
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No New Case values for Update'));
                        timerOn();
                        
                    }
                    
                }else{
                    System.debug('### Error inserting case.Case Id returned is null');
                } 
            }else{
                ErrorMessageOnSave = True;
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Fill All the Required Fields Information'));
                System.debug('### servicePortalwrapList has null values');
                //calling the timeron method to get the time when the page messages is displayed.
                timerOn();
                
            }
        }
        else{
            System.debug('### servicePortalwrapList is Empty');
        }
    }
    
    
    //************************************************************************************************************ insertOpsCase
    public Id insertOpsCase(String caseDescFromAdditionalInfo,Boolean underDuress,string relatedRecId,Boolean vfPageVar,string relatedDocketFormAction,string dBuTeam){
        if(!vfPageVar){
            Boolean createOPSCase = false;
            Case aCase = new Case();
            system.debug('$$$$ selected request from the url ===>'+selectedRequest);
            system.debug('$$$$ caseDocketList size ===>'+caseDocketList.size());
            string accId = NimbleServicePortalAccountId__c.getInstance().AccountId__c; //Getting the Account id From the custom setting.
            Account portalAccount = [select Id,Name From Account where Id =:Id.valueOf(accId)]; //Querying the 
            Group opsQueueId = [select Id from Group where Name = 'Support Queue - OPS' and Type = 'Queue' LIMIT 1];
            for(Case_Docket__c cdocket: caseDocketList){
                system.debug('$$$$ selected request from the List '+cdocket.cdLabel__c);
                if(selectedRequest == cdocket.cdLabel__c){ //checking the selected request against the case docket records.
                    aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId();//getting the recordtype id for the OPS case.
                    if(underDuress == true){
                        aCase.Priority =  'P1';
                    }else{
                        aCase.Priority =  cdocket.cdCasePriority__c;
                    }
                    if(cdocket.cdUnderlyingObject__c == 'Asset'  && (relatedRecId != 'Not-A-Valid-SF-Id')){
                        aCase.Assetmapped__c = Id.valueOf(relatedRecId);
                        //Asset AssetList = [select Id,name From Asset where Id=:Id.valueOf(relatedRecId) LIMIT 1];
                        //aCase.Asset = AssetList.Name;
                        //system.debug('Standard field asset ===>'+aCase.Asset);
                    }else if(cdocket.cdUnderlyingObject__c == 'RMAv2__c' && (relatedRecId != 'Not-A-Valid-SF-Id')){ //(relatedRecId != '' || relatedRecId != null)
                        aCase.RMAmapped__c = Id.valueOf(relatedRecId);
                    }
                    else if(cdocket.cdUnderlyingObject__c == 'Asset_Stage__c' && (relatedRecId != 'Not-A-Valid-SF-Id')){//added by exafort on 04/16 for TS-7268
                        aCase.Asset_Stage__c = Id.valueOf(relatedRecId);
                    }
                    else if(cdocket.cdUnderlyingObject__c == 'depot__c' && (relatedRecId != 'Not-A-Valid-SF-Id')){//added by exafort on 04/16 for TS-7268
                        aCase.Depot__c = Id.valueOf(relatedRecId);
                    }
                    else if(cdocket.cdUnderlyingObject__c == 'Case' && (relatedRecId != 'Not-A-Valid-SF-Id')){//added by exafort on 04/16 for TS-6417
                        aCase.CaseMapping__c = Id.valueOf(relatedRecId);
                    }
                    //Added by Exafort(Guru Dev) for TS-8390 on 02/28
                    else if(cdocket.cdUnderlyingObject__c == 'Account' && (relatedRecId != 'Not-A-Valid-SF-Id')){
                        aCase.Accountmapped__c = Id.valueOf(relatedRecId);
                    }
                    else if(cdocket.cdUnderlyingObject__c == 'AddressBook__c' && (relatedRecId != 'Not-A-Valid-SF-Id')){
                        aCase.AddressBookmapped__c = Id.valueOf(relatedRecId);
                    }
                    else if(cdocket.cdUnderlyingObject__c == 'Contact' && (relatedRecId != 'Not-A-Valid-SF-Id')){
                        aCase.Contactmapped__c = Id.valueOf(relatedRecId);
                    }
                    else if(cdocket.cdUnderlyingObject__c == 'Opportunity' && (relatedRecId != 'Not-A-Valid-SF-Id')){
                        aCase.Opportunitymapped__c = Id.valueOf(relatedRecId);
                    }
                    //Added end
                    
                    if(CurrentPageRelatedID !=  null && RelatedIdObjName =='Case'){//TS-8934
                        aCase.CaseMapping__c = CurrentPageRelatedID;
                    }
                    
                    aCase.caseCaseSummary__c = cdocket.cdLabel__c;
                    aCase.Description = caseDescFromAdditionalInfo;
                    aCase.Subject = cdocket.cdLabel__c;
                    aCase.casePachinkoCaseType__c = cdocket.Name;
                    aCase.Instructions__c =  cdocket.cdDocInternalURL__c;
                    aCase.Auto_Close__c = true;
                    aCase.caseBUteam__c = cdocket.cdResponsibleBUTeam__c;
                    aCase.Ownerid = opsQueueId.Id;          //assigning ops queue id
                    
                    aCase.AccountId = portalAccount.Id ;    //assigning account id
                    aCase.Origin = 'Email';//added by exafort on 03/10/2021 for TS-7993
                    aCase.CaseDocket__c = cdocket.Id;//added by exafort on 07/20/2021 for TS-8404 and TS-8401
                    //Added by exafort on 11 August 2021 for TS-8529
                    DateTime dt = System.now();
                    if(cdocket.cdEstimated_Time_to_Resolve__c != null && cdocket.cdEstimated_Time_to_Resolve__c > 0){
                        Integer offSetETTR =  integer.valueOf(cdocket.cdEstimated_Time_to_Resolve__c);
                        Datetime addTime = dt.addMinutes(offSetETTR);
                        Datetime ettrTriggerTime = addTime.addMinutes(-60);
                        aCase.OPS_Case_ETTR__c = ettrTriggerTime;
                    }
                    
                    
                    //Added end by exafort on 11 August 2021 for TS-8529
                    aCase.ContactId = insertPortalContact(portalAccount.Id);    //calling the method to map the contact to the created case.
                    createOPSCase = true;
                }else{
                    system.debug('@@@  Not a valid case docket <===');
                } 
            }
            system.debug('aCase>>'+aCase);
            if(createOPSCase){ //creating case if the createOPSCase is true 
                insert aCase;
                
                if(fileName!='' && fileBody != ''){//Attachment TS-6516
                    Attachment at=new Attachment();
                    at.Name=fileName;
                    at.Body=  EncodingUtil.base64Decode(fileBody);
                    at.Parentid=aCase.id;
                    Insert at;
                    AttachmentId = at.id;
                }
                SuccessMessageOnSave = True;
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Case Created Successfully'));
                timerOn(); 
            }else{
                system.debug('$$$ ==================> ');
            }
            return aCase.Id;
        }
        else{
            //Condition for form page
            Id formCaseID = Id.valueOf(RecordidFromURL);
            Boolean caseUpdatNeed = false;
            if(SetFormActionVar){
                //On Save & New Button click on form page
                List<Case> CaseNewValues = New List<Case>();
                caseListUpdate = New List<Case>();
                caseListUpdateSet = New Set<Id>();
                CaseNewValues = [Select id,Status,OwnerId from case where id =:formCaseID]; //To check the current case values
                if(CaseNewValues.size() > 0){
                    Case linkedCase = New Case();
                    if(relatedDocketFormAction != '' && relatedDocketFormAction == 'Close'){
                        linkedCase.OwnerId = CaseNewValues[0].OwnerId;
                        if(string.valueOf(linkedCase.OwnerId).startsWith('00G')){
                            linkedCase.OwnerId = UserInfo.getUserId(); 
                            caseUpdatNeed = true;
                        }
                        if(CaseNewValues[0].Status !='Closed'){
                            relatedDocketFormAction = 'Closed';
                            caseUpdatNeed = true;
                        } 
                    }
                    else if(relatedDocketFormAction != '' && relatedDocketFormAction == 'Resolve' && CaseNewValues[0].Status !='Resolved'){
                        relatedDocketFormAction = 'Resolved';
                        caseUpdatNeed = true;
                        
                    }
                    else if(relatedDocketFormAction != '' && relatedDocketFormAction == 'Handover' && CaseNewValues[0].Status !='Handover'){
                        linkedCase.caseBUteam__c = dBuTeam;
                        caseUpdatNeed = true;
                    }
                    if(caseUpdatNeed){
                        linkedCase.id = CaseNewValues[0].Id;
                        linkedCase.Status = relatedDocketFormAction;
                        if(caseListUpdateSet.contains(linkedCase.id)){
                            system.debug('Id already exists');
                        }
                        else{
                            caseListUpdateSet.add(linkedCase.id);
                            caseListUpdate.add(linkedCase);
                        }
                        
                    }
                }
                system.debug('caseListUpdate---'+caseListUpdate);
                if(caseListUpdate.size() > 0){
                    Update caseListUpdate;     
                } 
            }
            return formCaseID;
        }
        
    }
    //************************************************************************************************************ insertPortalContact
    //passing account id as parameter to map/create a contact under "Nimble Service Portal Account"
    public Id insertPortalContact(Id accountid){
        //fetching all the contacts under the account to map the case contact
        //List<Contact> allContacts = [Select Id,Name from Contact Where Email =: userinfo.getUserEmail() and id =: accountid Limit 1];
        List<Contact> allContacts = [Select Id,Name from Contact Where Email =: userinfo.getUserEmail() and AccountId =: accountid Limit 1];//Where condition 'AccountId' - Added by exafort on Jan 5 2021 // TS-7290
        if(allContacts.size() == 1){
            return allContacts[0].Id;
        }
        else{
            //A new contact will be created with the info from current logged in user
            Contact conRec = new Contact();
            conRec.AccountId = accountid;
            conRec.FirstName = userinfo.getFirstName();
            conRec.LastName = userinfo.getLastName();
            conRec.Email = userinfo.getUserEmail();
            insert conRec;
            return conRec.Id;
        }
    }
    //************************************************************************************************************ servicePortalWrap wrapper class
    public class servicePortalWrap{
        public Boolean cfieldRequired {set; get;}
        public Boolean cfieldReadOnly {set; get;}
        public Boolean ischeckbox {get;set;}
        public Boolean isApI {get;set;}
        public Boolean isText {get;set;}
        public Boolean isTextArea {get;set;}
        public Boolean isPicklist {get;set;}
        public Boolean isMultiSelectPicklist {get;set;}
        public Boolean isCheckboxSelected {set; get;}
        public Boolean hideOnPortal {set;get;}
        public String cfieldLabel {set; get;}
        public String cfieldAPIName {set;get;}
        public String cfieldDesc {set;get;}
        public String textValue {set; get;}
        public String textAreaValue {set; get;}
        public String picklistVal {set; get;}
        public list<SelectOption> picklistValues {get;set;}
        public Boolean IsthisunderduressNull {get;set;}//TS-7856
        public Boolean AdditionalInfoNull {get;set;}//TS-7856
        
        //Attachment TS-6516
        public Boolean IsAttachment {get;set;}
        
        
        
        
        
        public servicePortalWrap(){
            this.cfieldRequired = false;
            this.cfieldReadOnly = false;
            this.ischeckbox = false;
            this.isText = false;
            this.isApI = false;
            this.isTextArea = false;
            this.isPicklist = false;
            this.isMultiSelectPicklist = false;
            this.isCheckboxSelected = false;
            this.hideOnPortal = false;
            this.cfieldLabel='';
            this.cfieldAPIName ='';
            this.cfieldDesc='';
            this.textValue = '';
            this.textAreaValue = '';
            this.picklistVal = '';
            this.picklistValues =  new List<SelectOption>();
            this.IsthisunderduressNull = false;//TS-7856
            this.AdditionalInfoNull = false;//TS-7856
            //Attachment TS-6516
            this.IsAttachment = false;
            
            
        }
    }
    
    //************************************************************************************************************ clearMessage
    public void clearMessage(){
        ApexPages.getMessages().clear(); //method to clear the messages
    }
    //************************************************************************************************************ timerOn
    public void timerOn(){
        timer = true; //making the boolean timer to true so that the time starts ticking when the error message gets displayed on the page 
    }
    
    //************************************************************************************************************ timerOff
    public void timerOff(){
        
        timer = false; //making the boolean timer to false so that the errormessages can be cleared from the vf page
    }
    
}