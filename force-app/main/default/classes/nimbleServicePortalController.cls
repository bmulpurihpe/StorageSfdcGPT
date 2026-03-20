/*                             <<<< === nimbleServicePortalController Apex class === >>>>
=============================================================================================================
Name                    : nimbleServicePortalController
Description             : Logic to create case docket field data.
Created Date            : 21st July 2019
Author                  : Vishnu R
Version                 : 1.0
Modification History    : Initial Version
==============================================================================================================
*/
public class nimbleServicePortalController {
    
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
    
    
    
    
    //************************************************************************************************************ Constructor
    public nimbleServicePortalController(){
        //additionalInfo = '';
        //requestList = new List<SelectOption>();
        //requestList.add(new SelectOption('None','None'));
        
        textval ='';
        selectedRequest= '';
        fieldDefintionsforCase = null;
        passedIdRecordvalues = new List<sObject>();
        listOfStrings = new List<String>();
        cdRecord = new List<Case_Docket__c>();
        caseDocketList= new List<Case_Docket__c>();
        mapForCaseDockets = new Map<string,Id>();
        mapForCaseDocketsName = new Map<string,string>();
        mapForCaseDocketsFields = new Map<string,Id>();
        caseDocketFieldDefList = new List<CaseDocketFieldDefinition__c>();
        
        
        
        caseDocketList = [select Id,Name,cdLabel__c,cddonotupdateparentcase__c,cdDoNotSetParentCaseARF__c,cdEstimated_Time_to_Resolve__c,cdDocInternalURL__c,cdCasePriority__c,cdHideOnPortal__c,cdResponsibleBUTeam__c,cdUnderlyingObject__c From Case_Docket__c]; //where cdHideOnPortal__c = false
        if(!caseDocketList.isEmpty()){
            for(Case_Docket__c cdocket: caseDocketList){
                //mapForCaseDockets.put(cdocket.Name,cdocket.Id);
                //listOfStrings.add(cdocket.Name);
                if(cdocket.cdHideOnPortal__c == false){
                    listOfStrings.add(cdocket.cdLabel__c);    
                }
                mapForCaseDockets.put(cdocket.cdLabel__c,cdocket.Id);
                mapForCaseDocketsName.put(cdocket.Name,cdocket.cdLabel__c);
            } 
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
        if(selectedRequestFromURL != null){
            selectedRequest = mapForCaseDocketsName.get(selectedRequestFromURL);    
        }
        system.debug('#### Selected request ===>'+selectedRequest);
    }
    //************************************************************************************************************ getFieldInfosFromCaseDocket
    public void getFieldInfosFromCaseDocket(){
        servicePortalWrapList = new List<servicePortalWrap>();
        servicePortalWraptempList = new List<servicePortalWrap>();
        string requestObjname = null;
        
        RecordidFromURL = Apexpages.currentPage().getParameters().get('id');    //getting the "Id" value from the url.
        system.debug(' ### RecordidFromURL        ===> '+RecordidFromURL);
        system.debug(' ### selected Request Name  ===> '+selectedReqName);
        system.debug(' ### selected Request Label ===> '+selectedRequest);
        
        //system.debug('### Selected value from picklist ==>'+selectedRequestFromURL);
        //selectedRequestFromURL = ApexPages.currentPage().getParameters().get('name');
        system.debug('#### selectedRequestFromURL value ===>'+selectedRequestFromURL);
        
        //if(selectedRequestFromURL != null){
        //selectedRequest = selectedRequestFromURL;    
        //}
        
        if(selectedRequest != ''){
            cdRecord = [select Id,Name,cdLabel__c,cdDescription__c,cddonotupdateparentcase__c,cdDoNotSetParentCaseARF__c,cdEstimated_Time_to_Resolve__c,cdDocExternalURL__c,cdUnderlyingObject__c,cdJiraOrigin__c,cdJiraOrigin__r.Name,cdResponsibleBUTeam__c From Case_Docket__c where cdLabel__c =:selectedRequest];  
            //Query to get the case docket field definitions
            caseDocketFieldDefList = [select Id,Name,cdfdCaseDocket__c,cdfdDescription__c,cdfdFieldDefault__c,cdfdFieldOption__c,cdfdFieldType__c,
                                      cdfdHideOnPortal__c,cdfdLabel__c,cdfdOrdinal__c,cdfdReadOnly__c,cdfdRequired__c,cdfdUnderlyingObject__c from 
                                      CaseDocketFieldDefinition__c where cdfdCaseDocket__r.cdLabel__c =:selectedRequest  Order By cdfdOrdinal__c]; //AND cdfdHideOnPortal__c = false
            
            //code logic to get the object name from the passed record if from the URL.
            map<string,string> recordValues = new Map<string,string>();
            if(cdRecord != null && cdRecord.Size() > 0 )
                requestObjname =cdRecord[0].cdUnderlyingObject__c; // added to display the warning message  - TS-6455
            requestObjname = requestObjname!= null ? requestObjname.replace('__c', '').replace('v2',''):'Object';
            
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
                    system.debug('#######' + dfield );
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
            
            //Code logic to construct the wrapper list of fields for vf page display.
            //servicePortalWrapList.clear();
            System.debug('#### caseDocketFieldDefList list size ===>'+caseDocketFieldDefList.size());
            for(CaseDocketFieldDefinition__c cdfd: caseDocketFieldDefList){
                mapForCaseDocketsFields.put(cdfd.cdfdLabel__c,cdfd.Id);
                servicePortalWrap  servicePortalW = new servicePortalWrap();
                if(cdfd.cdfdFieldType__c == 'Text' && cdfd.cdfdHideOnPortal__c == false){ // for Text datatype fields
                    servicePortalW.isText = true;
                    servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                    servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                    servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                    if(cdfd.cdfdDescription__c != null){
                        servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                    }else{
                        servicePortalW.cfieldDesc = 'Please Add the Field Description';
                    }
                    if(cdfd.cdfdFieldDefault__c != null){
                        servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                    } 
                    else{
                        servicePortalW.textvalue = null;
                    }
                    
                    //fieldDefintionsforCase += fieldDefintionsforCase + servicePortalW.cfieldLabel + ' : ' + servicePortalW.textvalue;
                }
                else if(cdfd.cdfdFieldType__c == 'Picklist' && cdfd.cdfdHideOnPortal__c == false){ // for picklist type fields
                    servicePortalW.isPicklist = true;
                    servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                    servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                    servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                    if(cdfd.cdfdDescription__c != null){
                        servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                    }else{
                        servicePortalW.cfieldDesc = 'Please Add the Field Description';
                    }
                    if(cdfd.cdfdFieldDefault__c != null){
                        servicePortalW.picklistVal= cdfd.cdfdFieldDefault__c;
                    }
                    //else{
                    //    servicePortalW.picklistVal = 'None';
                    //}
                    List<String> lstpklist = cdfd.cdfdFieldOption__c.split('\\|');
                    List<selectOption> lstselectoption = new List<selectoption>();
                    //lstselectoption.add(new SelectOption('None','None'));
                    for(String s : lstpklist){
                        lstselectoption.add(new SelectOption(s,s));
                    }
                    servicePortalW.picklistValues = lstselectoption;
                    
                }
                else if(cdfd.cdfdFieldType__c == 'Boolean' && cdfd.cdfdHideOnPortal__c == false){ //for Boolean type fields
                    servicePortalW.isCheckbox = true;
                    servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                    servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                    servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                    if(cdfd.cdfdDescription__c != null){
                        servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                    }else{
                        servicePortalW.cfieldDesc = 'Please Add the Field Description';
                    }
                    if(cdfd.cdfdFieldDefault__c != null){
                        servicePortalW.isCheckboxSelected = Boolean.valueOf(cdfd.cdfdFieldDefault__c);
                    }else{
                        servicePortalW.isCheckboxSelected = false;
                    }
                }
                else if(cdfd.cdfdFieldType__c == 'Text Area' && cdfd.cdfdHideOnPortal__c == false){ //for Text area type fields
                    servicePortalW.isTextArea = true;
                    servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                    servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                    servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                    if(cdfd.cdfdDescription__c != null){
                        servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                    }else{
                        servicePortalW.cfieldDesc = 'Please Add the Field Description';
                    }
                    if(cdfd.cdfdFieldDefault__c != null){
                        servicePortalW.textAreaValue = string.valueOf(cdfd.cdfdFieldDefault__c);
                    }else{
                        servicePortalW.textAreaValue = null;
                    }
                }
                
                else if(cdfd.cdfdFieldType__c == 'API' ){ //for API type fields
                    
                    system.debug('### Object Name ==>'+objectName);
                    system.debug('#### Id from the URL ===>'+RecordidFromURL);
                    system.debug('### Object Name in CDFD ==>'+cdfd.cdfdUnderlyingObject__c);
                    
                    //code to get picklist/multiselectpicklist from schema.
                    servicePortalW.isApI = false;
                    Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(cdfd.cdfdUnderlyingObject__c).getDescribe();
                    Map<String,Schema.SObjectField> fieldMap = dsr.fields.getMap();
                    Schema.SObjectField field = fieldMap.get(cdfd.cdfdFieldOption__c);
                    system.debug('field---'+field);
                    if(field != null)
                    {
                        Schema.DescribeFieldResult dfr = field.getDescribe();
                        System.debug('### field type ===>'+ dfr.getType());
                        if(dfr.getType()==Schema.DisplayType.Picklist && cdfd.cdfdHideOnPortal__c == false){
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
                            
                            if(RecordidFromURL != null && RecordidFromURL != 'recordid'){
                                servicePortalW.picklistVal = recordValues.get(cdfd.cdfdFieldOption__c);
                            }
                            //}else{
                            //   servicePortalW.picklistVal = recordValues.get(cdfd.cdfdFieldOption__c);
                            //}
                        }
                        else if(dfr.getType()==Schema.DisplayType.Boolean && cdfd.cdfdHideOnPortal__c == false){
                            servicePortalW.isCheckbox = true;
                            servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                            servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                            servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                            if(cdfd.cdfdDescription__c != null){
                                servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                            }else{
                                servicePortalW.cfieldDesc = 'Please Add the Field Description';
                            }
                            if(RecordidFromURL != null && RecordidFromURL != 'recordid'){
                                if(cdfd.cdfdFieldOption__c != null)
                                    servicePortalW.isCheckboxSelected = Boolean.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));
                            }else if(cdfd.cdfdFieldDefault__c != null){
                                servicePortalW.isCheckboxSelected = Boolean.valueOf(cdfd.cdfdFieldDefault__c);
                            }else{
                                servicePortalW.isCheckboxSelected = false;
                            }
                        }
                        else if((dfr.getType() == Schema.DisplayType.STRING && cdfd.cdfdHideOnPortal__c == false) || (dfr.getType() == Schema.DisplayType.MULTIPICKLIST && cdfd.cdfdHideOnPortal__c == false)){
                            servicePortalW.isText = true;
                            servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                            servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                            servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                            if(cdfd.cdfdDescription__c != null){
                                servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                            }else{
                                servicePortalW.cfieldDesc = 'Please Add the Field Description';
                            }
                            if(RecordidFromURL != null && RecordidFromURL != 'recordid'){
                                servicePortalW.textvalue = recordValues.get(cdfd.cdfdFieldOption__c);
                            } 
                            else if(cdfd.cdfdFieldDefault__c != null){
                                servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                            }
                            else{
                                servicePortalW.textvalue = null;
                            }
                        }
                        else if(dfr.getType() == Schema.DisplayType.TEXTAREA && cdfd.cdfdHideOnPortal__c == false){
                            servicePortalW.isTextArea = true;
                            servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                            servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                            servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                            if(cdfd.cdfdDescription__c != null){
                                servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                            }else{
                                servicePortalW.cfieldDesc = 'Please Add the Field Description';
                            }
                            if(RecordidFromURL != null && RecordidFromURL != 'recordid'){
                                servicePortalW.textAreaValue = recordValues.get(cdfd.cdfdFieldOption__c);
                            } 
                            else if(cdfd.cdfdFieldDefault__c != null){
                                servicePortalW.textAreaValue = cdfd.cdfdFieldDefault__c;
                            }else{
                                servicePortalW.textAreaValue = null;
                            }
                        }
                        else if(dfr.getType() == Schema.DisplayType.ID && cdfd.cdfdHideOnPortal__c == false){
                            servicePortalW.isText = true;
                            servicePortalW.isApI = true;
                            servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                            servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                            servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                            if(cdfd.cdfdDescription__c != null){
                                servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                            }else{
                                servicePortalW.cfieldDesc = 'Please Add the Field Description';
                            }
                            if(RecordidFromURL != null && RecordidFromURL != 'recordid'){
                                servicePortalW.textvalue = String.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));
                            } 
                            else if(cdfd.cdfdFieldDefault__c != null){
                                servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                            }
                            else{
                                servicePortalW.textvalue = null;
                            }
                        }
                        else if(dfr.getType() == Schema.DisplayType.ID && cdfd.cdfdHideOnPortal__c == true){
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
                            if(RecordidFromURL != null && RecordidFromURL != 'recordid'){
                                servicePortalW.textvalue = String.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));
                            } 
                            else if(cdfd.cdfdFieldDefault__c != null){
                                servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                            }
                            else{
                                servicePortalW.textvalue = null;
                            }
                        }
                        else if(dfr.getType() == Schema.DisplayType.REFERENCE && cdfd.cdfdHideOnPortal__c == false){
                            servicePortalW.isText = true;
                            servicePortalW.cfieldLabel = cdfd.cdfdLabel__c;
                            servicePortalW.cfieldRequired = cdfd.cdfdRequired__c;
                            servicePortalW.cfieldReadOnly = cdfd.cdfdReadOnly__c;
                            if(cdfd.cdfdDescription__c != null){
                                servicePortalW.cfieldDesc = cdfd.cdfdDescription__c;
                            }else{
                                servicePortalW.cfieldDesc = 'Please Add the Field Description';
                            }
                            if(RecordidFromURL != null && RecordidFromURL != 'recordid'){
                                servicePortalW.textvalue = String.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));
                            } 
                            else if(cdfd.cdfdFieldDefault__c != null){
                                servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                            }
                            else{
                                servicePortalW.textvalue = null;
                            }
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
                            if(RecordidFromURL != null && RecordidFromURL != 'recordid'){
                                servicePortalW.textvalue = String.valueOf(recordValues.get(cdfd.cdfdFieldOption__c));
                            } 
                            else if(cdfd.cdfdFieldDefault__c != null){
                                servicePortalW.textvalue = cdfd.cdfdFieldDefault__c;
                            }
                            else{
                                servicePortalW.textvalue = null;
                            }
                        }
                    }
                    else
                    {
                        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please enter valid field api names'));
                    }
                }
                servicePortalWrapList.add(servicePortalW);
            }
            system.debug('### final list retuning to page ==>'+servicePortalWrapList);
            system.debug('### final list size retuning to page ==>'+servicePortalWrapList.size());        
        }else{
            cdRecord.clear();
            System.debug('### No Request has selected');
        }
    }
    //method for save button
    //************************************************************************************************************ insertCaseDocketFieldData1
    public void insertCaseDocketFieldData1(){
        
        insertCaseDocketFieldData();
        getFieldInfosFromCaseDocket();
    }
    //method for save & new button
    
    
    //************************************************************************************************************ insertCaseDocketFieldData2
    public void insertCaseDocketFieldData2(){
        
        insertCaseDocketFieldData();
        servicePortalWrapList = servicePortalWraptempList ; // copying the list to show the same values after clicking "Save and New Button"
    }
    //************************************************************************************************************ insertCaseDocketFieldData
    public void insertCaseDocketFieldData(){
        
        
        relatedId = null;
        Boolean allowcaseinsert = false;
        system.debug('### insertCaseDocketFieldData method calling ===>'+textval);
        List<CaseDocketFieldData__c> ListToInsert = new List<CaseDocketFieldData__c>();
        system.debug('### insertCaseDocketFieldData method calling ===>');
        
        servicePortalWraptempList = servicePortalWrapList;
        system.debug('### size of the servicePortalWraptempList ==>'+servicePortalWraptempList.size());
        
        
        
        
        if(!servicePortalWraptempList.isEmpty()){
            additionalInfo = '\r\n   ' ;
            additionalInfo += '\r\n  ' ;
            
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
                        additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textvalue + '\r\n'; 
                    }
                }else if(ssportalrec.isPicklist){
                    additionalInfo += ssportalrec.cfieldLabel + ' :  ' + String.valueOf(ssportalrec.picklistVal) + '\r\n';
                }else if(ssportalrec.isTextArea){
                    additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textAreaValue + '\r\n';
                }else if(ssportalrec.isText){
                    /*String id = String.escapeSingleQuotes(ssportalrec.textvalue); 
String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textvalue +'     '+ baseUrl+'/'+ssportalrec.textvalue + '\r\n';  
}else{
additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textvalue + '\r\n'; 
}*/
                    
                    additionalInfo += ssportalrec.cfieldLabel + ' :  ' + ssportalrec.textvalue + '\r\n'; 
                }
                
                
                
                if( ssportalrec.isText && ssportalrec.textValue != '' || 
                   ssportalrec.isPicklist && ssportalrec.picklistVal != '' || 
                   ssportalrec.isTextArea && ssportalrec.textAreaValue != '' ||
                   ssportalrec.ischeckbox && ssportalrec.ischeckboxSelected){
                       allowcaseinsert = true;
                   }
                system.debug('#### allowcaseinsert===>'+allowcaseinsert);
            }
            if(allowcaseinsert){
                
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
                Id insertedcCaseId = insertOpsCase(additionalInfo,isThisUnderDuress,relatedId);
                
                //If the case id returned from the above method is not null ,looping through the list returned from vf page to create case docket field data.
                if(insertedcCaseId != null){
                    for(servicePortalWrap ssportal:servicePortalWrapList){
                        if(ssportal.ischeckbox && ssportal.ischeckboxSelected){
                            CaseDocketFieldData__c cdfdata = new CaseDocketFieldData__c();
                            cdfdata.cdfdataCaseDocket__c = mapForCaseDockets.get(selectedRequest);
                            cdfdata.cdfdataCaseDocketFieldDefinition__c = mapForCaseDocketsFields.get(ssportal.cfieldLabel);
                            cdfdata.Value__c = String.valueOf(ssportal.isCheckboxSelected);
                            cdfdata.cdfdataCase__c = insertedcCaseId;
                            ListToInsert.add(cdfdata);
                        }else if(ssportal.isText && ssportal.textValue != ''){
                            CaseDocketFieldData__c cdfdata = new CaseDocketFieldData__c();
                            cdfdata.cdfdataCaseDocket__c = mapForCaseDockets.get(selectedRequest);
                            cdfdata.cdfdataCaseDocketFieldDefinition__c = mapForCaseDocketsFields.get(ssportal.cfieldLabel);
                            cdfdata.Value__c = String.valueOf(ssportal.textValue);
                            cdfdata.cdfdataCase__c = insertedcCaseId;
                            ListToInsert.add(cdfdata);
                        }else if(ssportal.isPicklist && ssportal.picklistVal != ''){
                            CaseDocketFieldData__c cdfdata = new CaseDocketFieldData__c();
                            cdfdata.cdfdataCaseDocket__c = mapForCaseDockets.get(selectedRequest);
                            cdfdata.cdfdataCaseDocketFieldDefinition__c = mapForCaseDocketsFields.get(ssportal.cfieldLabel);
                            cdfdata.Value__c = String.valueOf(ssportal.picklistVal);
                            cdfdata.cdfdataCase__c = insertedcCaseId;
                            ListToInsert.add(cdfdata);
                        }else if(ssportal.isTextArea && ssportal.textAreaValue != ''){
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
                            ListToInsert.add(cdfdata);
                        }
                    }
                    
                    if(!ListToInsert.IsEmpty()){
                        insert ListToInsert;
                        //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Field Defintions Saved Successfully'));
                        //calling the timeron method to get the time when the page messages is displayed.
                        timerOn();
                    }
                    else{
                        System.debug('### ListToInsert is Empty');
                    }
                }else{
                    System.debug('### Error inserting case.Case Id returned is null');
                } 
            }else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Fill The Fields Information'));
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
    public Id insertOpsCase(String caseDescFromAdditionalInfo,Boolean underDuress,string relatedRecId){
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
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Case Created Successfully'));
            timerOn();
            
            
        }else{
            system.debug('$$$ ==================> ');
        }
        
        return aCase.Id;
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
            
            
            
        }
    }
    //****************************************************************
    
    
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