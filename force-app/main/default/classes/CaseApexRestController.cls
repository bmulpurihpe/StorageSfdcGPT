@RestResource(urlMapping='/casesync/*')
global without sharing class CaseApexRestController {
  // 
    @HttpPost
    global static Map<String, String> caseCreation(CaseApexRestController.caseWrapper caseRec) {
        RestRequest req1 = RestContext.request;
        RestResponse resp = RestContext.response;
        Map<String, String> responseMap = new Map<String, String>(); 
        String debugId =req1.headers.get('debugId');
        DCE_Case_Raw_Input__c newdcecase=createDCECaseRawInput(caseRec);
        
    if(newdcecase.id == null && caseRec.cepCaseId !=null ){
            DCE_Case_Raw_Input__c existingcase =[SELECT Id, Case__c,CreatedById,Case__r.CaseNumber,cepCaseId__c FROM DCE_Case_Raw_Input__c WHERE cepCaseId__c =:caseRec.cepCaseId];
          // DCE_Case_Raw_Input__c existingcase =[SELECT Id, Case__c,Case__r.CaseNumber,cepCaseId__c,workspaceId__c  FROM DCE_Case_Raw_Input__c WHERE workspaceId__c  =:caseRec.workspaceId];
           System.debug('====existingcase=='+existingcase);
        system.debug(' ****newdcecase.id' +  newdcecase.id);
        if(existingcase!= null && existingcase.case__c == null){
                system.debug(' create case');
                responseMap = caseCreate(caseRec, debugId, existingcase);
            }
            else{
                responseMap.put('CaseId', existingcase.Case__c);                       
                responseMap.put('CaseNumber', existingcase.Case__r.CaseNumber);
                responseMap.put('cepCaseId', caseRec.cepCaseId);
                RestContext.response.statusCode = 409;
                responseMap.put('debugId', debugId);
                responseMap.put('errorMessage', caseRec.cepCaseId+ ' ' +'already exists');
                responseMap.put('httpStatusCode', '409');
            }             
        }
        else{
            system.debug(' **** line 9 request body *** ' +  caseRec);
            if (debugId !=null){
                if(caseRec != null) {
                   responseMap = caseCreate(caseRec, debugId, newdcecase);
                }
            }
            else {
                responseMap.put('httpStatusCode', '400');
                responseMap.put('message', 'Header Missing');
                responseMap.put('debugId', debugId);
            } 
        }
        
        return responseMap;
    }
    
    private static void  handleErrorResponse(string statusCode, String errorMessage,String fieldWithError ,Map<String, Object> responseMap,String debugId) {
        if (statusCode == '400') {
            responseMap.put('httpStatusCode', statusCode);
            responseMap.put('message', errorMessage);
            responseMap.put('fieldDataWithError', fieldWithError);
            RestContext.response.statusCode = 400;
            responseMap.put('debugId', debugId);
        } else if (statusCode == '401') {
            responseMap.put('httpStatusCode', statusCode);
            responseMap.put('message', errorMessage);
            responseMap.put('fieldDataWithError', fieldWithError);
            RestContext.response.statusCode = 401;
            responseMap.put('debugId', debugId);
        } else if (statusCode == '403') {
            responseMap.put('httpStatusCode', statusCode);
            responseMap.put('message', errorMessage);
            responseMap.put('fieldDataWithError', fieldWithError);
            RestContext.response.statusCode = 403;
            responseMap.put('debugId', debugId);
        } else if (statusCode == '500') {
            responseMap.put('httpStatusCode', statusCode);
            responseMap.put('message', errorMessage);
            responseMap.put('fieldDataWithError', fieldWithError);
            RestContext.response.statusCode = 500;
            responseMap.put('debugId', debugId);
        } else if (statusCode == '503') {
            responseMap.put('httpStatusCode', statusCode);
            responseMap.put('message', errorMessage);
            responseMap.put('fieldDataWithError', fieldWithError);
            RestContext.response.statusCode = 503;
            responseMap.put('debugId', debugId);
        }
        
    }
    @HttpPatch
    global static Map<String, String> updateCase() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Blob blobRequestBody = request.requestBody;
        String requestBody = blobRequestBody.toString();
        String caseUrlId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        String caseNumber;
        String caseId;
        Map<String, String> responseMap = new Map<String, String>();           
        String debugId = request.headers.get('debugId');
        Map<String, Object> parsedRequestBody = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
        caseNumber = (String) parsedRequestBody.get('caseNumber');
        caseId = (String) parsedRequestBody.get('caseId');
        system.debug(' **** line 179 request body *** ' +  requestBody);
       
        try{
            Case caserec = [SELECT Id, CaseNumber, Subject, Status,Sub_Status__c, Severity__c, Description, ContactId, Preferred_Contact_Info__c, Time_Zone__c,
                            contact.email, contact.Federation_ID__c,Alternate_Contact_Name__c,Alternate_Contact_Name__r.Email,
                            Alternate_Contact_Name__r.Federation_ID__c, Alternate_Contact_Email__c FROM Case WHERE Id = :caseUrlId];
            system.debug(' *** line caserec: ' + caserec);
            
            if((String.isBlank(caseNumber) || String.isBlank(caseId)) || caseId !=caserec.Id){
                
                responseMap.put('httpStatusCode', '400');
                responseMap.put('message', 'CaseId and CaseNumber Missing');
                responseMap.put('errorCode', 'Missing mandatory fields');
                responseMap.put('debugId', debugId);
                RestContext.response.statusCode = 400;  
                String statuscode = '400';
            }
            else{
                String federationId;
                String primaryContactEmailAddress; 
                String primaryContactFirstName; 
                String primaryContactLastName;
                String primaryContactMobile; 
                String primaryContactPhone; 
                String primaryContactPreferredContactMethod; 
                String primaryContactPreferredContactInfo;
                String primaryContactPreferredContactTimeZone; 
                String alternatefederationId;
                String alternateContactEmailAddress;
                String alternateContactFirstName; 
                String alternateContactLastName; 
                String alternateContactMobile; 
                String alternateContactPhone;
                String alternateContactPreferredContactMethod; 
                // Added by Padmaja SFDC-1243
                String serialNumber;
                String hpeSerialNumber;
                String accId;
                if (parsedRequestBody.containsKey('serialNumber')) {
                    serialNumber = (String) parsedRequestBody.get('serialNumber');
                }
                if (parsedRequestBody.containsKey('hpeSerialNumber')) {
                    hpeSerialNumber = (String) parsedRequestBody.get('hpeSerialNumber');
                }

                Map<Id, Asset> assetMap = getAssetMap(serialNumber, hpeSerialNumber);
                      
                      if (!assetMap.isEmpty()) {
                          for (Asset ast : assetMap.Values()) {
                              accId = ast.AccountId ; 
                              break; 
                          }
                      }
                  // End SFDC-1243  
                // Retrieve the contact record using the federation ID
                if (parsedRequestBody.containsKey('subject')) {
                    caserec.Subject = (String) parsedRequestBody.get('subject');
                }
                 if (parsedRequestBody.containsKey('status')) { // Change 'Status' to 'status'
                    //caserec.Status = (String) parsedRequestBody.get('status');
                    system.debug('=======stuss value========'+(String) parsedRequestBody.get('status'));
                      system.debug('=======subStatusstuss value========'+(String) parsedRequestBody.get('subStatus'));
                    if((String) parsedRequestBody.get('status') == 'Monitoring'){
                        caserec.Status = 'Waiting on Customer'; //SFDC-1526
                    }else{
                        caserec.Status = (String) parsedRequestBody.get('status');
                    }
                }
               if (parsedRequestBody.containsKey('subStatus')) {
                   /* if(caserec.Status == 'Awaiting Customer'){
                        caserec.Sub_Status__c = (String) parsedRequestBody.get('subStatus');
                    }
                    else{
                        caserec.Sub_Status__c =''; 
                    }*/
                   if((String) parsedRequestBody.get('subStatus') == 'Customer actions complete (Customer use via portal only)'){
                       caserec.Sub_Status__c ='Customer Actions Complete';
                   }
                }
                if (parsedRequestBody.containsKey('description')) {
                    caserec.Description = (String) parsedRequestBody.get('description');
                }
                if (parsedRequestBody.containsKey('severity')) {
                    caserec.Severity__c = (String) parsedRequestBody.get('severity');
                }
                if (parsedRequestBody.containsKey('primaryContactFederationId')) {
                    federationId = (String) parsedRequestBody.get('primaryContactFederationId');
                }
                if (parsedRequestBody.containsKey('primaryContactEmailAddress')) {
                    primaryContactEmailAddress = (String) parsedRequestBody.get('primaryContactEmailAddress');
                }
                if (parsedRequestBody.containsKey('primaryContactFirstName')) {
                    primaryContactFirstName = (String) parsedRequestBody.get('primaryContactFirstName');
                }
                if (parsedRequestBody.containsKey('primaryContactLastName')) {
                    primaryContactLastName = (String) parsedRequestBody.get('primaryContactLastName');
                }
                if (parsedRequestBody.containsKey('primaryContactMobile')) {
                    primaryContactMobile = (String) parsedRequestBody.get('primaryContactMobile');
                }  
                if (parsedRequestBody.containsKey('primaryContactPhone')) {
                    primaryContactPhone = (String) parsedRequestBody.get('primaryContactPhone');
                }
                if (parsedRequestBody.containsKey('primaryContactPreferredContactMethod')) {
                    primaryContactPreferredContactMethod = (String) parsedRequestBody.get('primaryContactPreferredContactMethod');
                }
                if (parsedRequestBody.containsKey('primaryContactPreferredContactInfo')) {
                    primaryContactPreferredContactInfo = (String) parsedRequestBody.get('primaryContactPreferredContactInfo');
                }
                if (parsedRequestBody.containsKey('primaryContactPreferredContactTimeZone')) {
                    primaryContactPreferredContactTimeZone = (String) parsedRequestBody.get('primaryContactPreferredContactTimeZone');
                }
                system.debug(' *** line 253 ' +  parsedRequestBody.containsKey('alternateContactFederationId'));
                if (parsedRequestBody.containsKey('alternateContactFederationId')) {
                    alternatefederationId = (String) parsedRequestBody.get('alternateContactFederationId'); 
                }
                if (parsedRequestBody.containsKey('alternateContactEmail')) {
                    alternateContactEmailAddress = (String) parsedRequestBody.get('alternateContactEmail');
                }
                if (parsedRequestBody.containsKey('alternateContactPreferredContactMethod')) {
                    alternateContactPreferredContactMethod = (String) parsedRequestBody.get('alternateContactPreferredContactMethod');
                }
                if (parsedRequestBody.containsKey('alternateContactFirstName')) {
                    alternateContactFirstName = (String) parsedRequestBody.get('alternateContactFirstName');
                }
                if (parsedRequestBody.containsKey('alternateContactLastName')) {
                    alternateContactLastName = (String) parsedRequestBody.get('alternateContactLastName');
                }
                if (parsedRequestBody.containsKey('alternateContactMobile')) {
                    alternateContactMobile = (String) parsedRequestBody.get('alternateContactMobile');
                }  
                if (parsedRequestBody.containsKey('alternateContactPhone')) {
                    alternateContactPhone = (String) parsedRequestBody.get('alternateContactPhone');
                }
                if (parsedRequestBody.containsKey('alternateContactPreferredContactMethod')) {
                    alternateContactPreferredContactMethod = (String) parsedRequestBody.get('alternateContactPreferredContactMethod');
                }
                
                if(((alternatefederationId == null || alternatefederationId == '') && parsedRequestBody.containsKey('alternateContactFederationId')) &&
                   (( alternateContactEmailAddress == null || alternateContactEmailAddress == '')&& parsedRequestBody.containsKey('alternateContactEmail'))){
                       
                       caserec.Alternate_Contact_Name__c = null;
                       caserec.Alternate_Contact_Email__c = null;
                       caserec.Alternate_Contact_Phone__c = null;
                   }
                
                else if(((alternatefederationId != null && alternatefederationId != '') && parsedRequestBody.containsKey('alternateContactFederationId'))  ||
                        (( alternateContactEmailAddress != null && alternateContactEmailAddress != '')&& parsedRequestBody.containsKey('alternateContactEmail'))){
                            system.debug(' *** line 299 '  );
                            Contact existingContact = findExistingContact(alternatefederationId, alternateContactEmailAddress ,
                                                                          alternateContactPreferredContactMethod, alternateContactPhone, alternateContactMobile );  
                            system.debug( ' *** line 302 ' + existingcontact );
                            if (existingContact != null) {
                                
                                caserec.Alternate_Contact_Name__c = existingContact.Id;
                                caserec.Alternate_Contact_Email__c = alternateContactEmailAddress;
                                caserec.Alternate_Contact_Phone__c = alternateContactPhone;
                                system.debug(' *** line 306 existingcontactid ' +  caserec.Alternate_Contact_Name__c);
                                
                            } 
                            else if( existingContact == null) {
                               // Added by Padmaja SFDC-1243 
                                Contact newAlternateContact = createNewContact(accId,alternatefederationId,alternateContactEmailAddress,
                                                                               alternateContactFirstName, alternateContactLastName,
                                                                               alternateContactMobile, alternateContactPhone, alternateContactPreferredContactMethod );
                                
                                
                                caserec.Alternate_Contact_Name__c = newAlternateContact.Id;
                                caserec.Alternate_Contact_Email__c = alternateContactEmailAddress;
                                caserec.Alternate_Contact_Phone__c = alternateContactPhone;
                                
                                
                            }
                        } 
                
                
                
                
                
                if(parsedRequestBody.containsKey('primaryContactFederationId')&& (String.isBlank(federationId) ||String.isBlank(primaryContactEmailAddress)||
                                                                                  String.isBlank(primaryContactLastName)) 
                  ){
                      System.debug('=============278 line========');
                      responseMap.put('httpStatusCode', '400');
                      responseMap.put('message', 'Missing mandatory fields');
                      responseMap.put('errorCode', 'Required fields are missing');
                      responseMap.put('debugId', debugId);
                      RestContext.response.statusCode = 400;  
                  }
                else {
                    // Primary Contact Details
                    if(federationId !=null || primaryContactEmailAddress  !=null ){
                        Contact existingContact = findExistingContact(federationId, primaryContactEmailAddress ,
                                                                      primaryContactPreferredContactMethod,primaryContactPhone, primaryContactMobile );
                        if (existingContact != null) {
                            caserec.ContactId = existingContact.Id;
                        } else {
                            // Added by Padmaja SFDC-1243 
                            Contact newContact = createNewContact(accId,federationId,primaryContactEmailAddress,
                                                                  primaryContactFirstName, primaryContactLastName,
                                                                  primaryContactMobile, primaryContactPhone, primaryContactPreferredContactMethod );
                            System.debug('=============newContact========'+newContact);
                            caserec.ContactId = newContact.Id;
                        } 
                        if(caserec.Time_Zone__c != primaryContactPreferredContactTimeZone){
                            caserec.Time_Zone__c =primaryContactPreferredContactTimeZone;
                        }
                        if(caserec.Preferred_Contact_Info__c != primaryContactPreferredContactInfo){
                            caserec.Preferred_Contact_Info__c = primaryContactPreferredContactInfo;
                        }
                    }
                    // AlternateContact  Details
                    
                    
                    system.debug('===caserec====='+caserec);
                    system.debug(' *** line 365 existingcontactid ' +  caserec.Alternate_Contact_Name__c);
                    update caserec;
                    responseMap.put('httpStatusCode', '200');
                    responseMap.put('message', 'Case Record updated');
                    responseMap.put('caseId',caserec.Id); // Use 'c.Id' instead of 'newCase.Id'
                    responseMap.put('debugId', debugId);
                    response.statusCode = 200;
                }
            }
        }
        
        catch (NullPointerException e) {
            String errorMessage = e.getMessage();
            String[] parts = errorMessage.split(':'); 
            String exceptionType = parts[0].trim();
            String fieldWithError = '';
            if (parts.size() > 1) {
                fieldWithError = parts[1].trim();
            }  
            String statuscode = '401';
            system.debug('=====exception message366===' + errorMessage);
            handleErrorResponse(statuscode, errorMessage,fieldWithError,responseMap,debugId);
        } 
        catch (DmlException e) {
            String errorMessage = e.getMessage();
            String[] parts = errorMessage.split(':'); 
            String exceptionType = parts[0].trim();
            String fieldWithError = '';
            if (parts.size() > 1) {
                fieldWithError = parts[1].trim();
            }
            String statuscode = '403';
            system.debug('=====exception message378===' + errorMessage);
            handleErrorResponse(statuscode, errorMessage,fieldWithError,responseMap,debugId);
        } 
        
        catch (System.TypeException e) {
            String errorMessage = e.getMessage();
            String[] parts = errorMessage.split(':'); 
            String exceptionType = parts[0].trim(); 
            String fieldWithError = '';
            if (parts.size() > 1) {
                fieldWithError = parts[1].trim();
            }
            system.debug('=====exception message389===' + errorMessage);
            String statuscode = '500';
            handleErrorResponse(statuscode, errorMessage,fieldWithError,responseMap,debugId);               
        }
        catch (exception  e) {
            String errorMessage = e.getMessage();
            String[] parts = errorMessage.split(':'); 
            String exceptionType = parts[0].trim();
            String fieldWithError = '';
            if (parts.size() > 1) {
                fieldWithError = parts[1].trim();
            }
            String statuscode = '503';
            if(errorMessage == 'List has no rows for assignment to SObject'){
                errorMessage = 'Case record not found';
            }
            system.debug('=====exception message503===' + errorMessage);
           // handleErrorResponse(statuscode, errorMessage,fieldWithError,responseMap,debugId);                 
        }
        return responseMap;
    }
    global class caseWrapper{
        public  String subject; 
        public  String subStatus;
        public  String description; 
        public  String severity; 
        public  String issueType; 
        public  String serialNumber;
        public  String hpeSerialNumber; 
        public  String primaryContactFederationId;  
        public  String primaryContactEmailAddress; 
        public  String primaryContactFirstName; 
        public  String primaryContactLastName;
        public  String primaryContactMobile; 
        public  String primaryContactPhone; 
        public  String primaryContactPreferredContactMethod; 
        public  String primaryContactPreferredContactInfo;
        public  String primaryContactPreferredContactTimeZone; 
        public  String troubleshootingStepsTaken; 
        public  String operatingSystem; 
        public  String newInstall;
        public  String installIssue; 
        public  String vendorCaseNumber; 
        public  String alternateContactEmail;
        public  String alternateContactFederationID; 
        public  String alternateContactFirstName; 
        public  String alternateContactLastName; 
        public  String alternateContactMobile; 
        public  String alternateContactPhone;
        public  String alternateContactPreferredContactMethod; 
        public  String alternateContactPreferredContactTimeZone;
        public  String alternateContactPreferredContactInfo; 
        public  String outage; 
        public  String outageDays; 
        public  String outageHours;
        public  String outageMinutes; 
        public  String anyCustomerDataLoss;
        public  String createdByFederationId;
        public  String cepCaseId;
        //ESS-109191 --start
         public  String workspaceId;
         public  String createdByEmailAddress;
         public  String createdByFirstName;
         public  String createdByLastName;
         public  String subscriptionKey;  
         public  String aasProductName;
         public  String aasProductNumber;
         public  String aasProductLine;
         public  String origin;
    }
    
    public static DCE_Case_Raw_Input__c createDCECaseRawInput(CaseApexRestController.caseWrapper caseRec) {   
        Map<String, String> responseMap = new Map<String, String>(); 
        DCE_Case_Raw_Input__c dceCase = new DCE_Case_Raw_Input__c();
        try{
            dceCase.Subject__c = caseRec.subject;
            dceCase.Description__c = caseRec.description;
            dceCase.Severity__c = caseRec.severity;
            dceCase.Vendor_Case_Number_Optional__c = caseRec.vendorCaseNumber;
            dceCase.Serial_Number__c = caseRec.serialNumber;
            dceCase.HPE_Serial_Number__c = caseRec.hpeSerialNumber;
            dceCase.Primary_Contact_Federation_ID__c = caseRec.primaryContactFederationId;
            dceCase.Primary_contact_email_address__c = caseRec.primaryContactEmailAddress;
            dceCase.Primary_Contact_First_Name__c = caseRec.primaryContactFirstName;
            dceCase.Primarty_Contact_Last_Name__c = caseRec.primaryContactLastName;
            dceCase.Primary_Contact_Mobile__c = caseRec.primaryContactMobile;
            dceCase.Primary_Contact_Phone__c = caseRec.primaryContactPhone;
            dceCase.Primary_Contact_Preferred_Contact_Method__c = caseRec.primaryContactPreferredContactMethod;
            dceCase.Primary_Contact_Preferred_Contact_Time_R__c = caseRec.primaryContactPreferredContactInfo;
            dceCase.Primary_Contact_Preferred_Contact_TimeZ__c = caseRec.primaryContactPreferredContactTimeZone;
            dceCase.Troubleshooting_Steps_Taken__c = caseRec.troubleshootingStepsTaken;
            dceCase.Operating_System__c = caseRec.operatingSystem;
            dceCase.New_Install__c = caseRec.newInstall;
            dceCase.AlternateContactFederationId__c = caseRec.alternateContactFederationID;
            dceCase.Alternate_Contact_Email__c = caseRec.alternateContactEmail;
            dceCase.Alternate_Contact_First_Name__c = caseRec.alternateContactFirstName;
            dceCase.Alternate_Contact_Last_Name__c = caseRec.alternateContactLastName;
            dceCase.Alternate_Contact_Mobile__c = caseRec.alternateContactMobile;
            dceCase.Alternate_Contact_Phone__c = caseRec.alternateContactPhone;
            dceCase.Alternate_Contact_Preferred_Contact_Meth__c = caseRec.alternateContactPreferredContactMethod;
            dceCase.Alt_Contact_Preferred_Contact_Timerange__c = caseRec.alternateContactPreferredContactInfo;
            dceCase.Alt_Contact_Preferred_Contact_Timezone__c = caseRec.alternateContactPreferredContactTimeZone;
            dceCase.Outage__c = Boolean.valueOf(caseRec.outage);
            dceCase.Outage_Days__c = !String.isBlank(caseRec.outageDays)? Integer.valueOf(caseRec.outageDays) : 0;
            dceCase.Outage_Hours__c = !String.isBlank(caseRec.outageHours) ? Integer.valueOf(caseRec.outageHours) : 0;
            dceCase.Outage_Minutes__c = !String.isBlank(caseRec.outageMinutes)? Integer.valueOf(caseRec.outageMinutes) : 0;
            dceCase.Any_Customer_Data_Loss__c = caseRec.anyCustomerDataLoss;
            dceCase.createdByFederationId__c = caseRec.createdByFederationId;
            dceCase.cepCaseId__c =caseRec.cepCaseId;
            dceCase.Json_Data__c = String.valueOf(caseRec);
            //ESS-109191 --Start
            dceCase.workspaceId__c =caseRec.workspaceId;
            dceCase.createdByEmailAddress__c =caseRec.createdByEmailAddress;
            dceCase.createdByFirstName__c =caseRec.createdByFirstName;
            dceCase.createdByLastName__c =caseRec.createdByLastName;
            dceCase.subscriptionKey__c =caseRec.subscriptionKey;
            dceCase.aasProductName__c =caseRec.aasProductName;
            dceCase.aasProductNumber__c =caseRec.aasProductNumber;
            dceCase.aasProductLine__c =caseRec.aasProductLine;
            dceCase.origin__c =caseRec.origin;
            Insert dceCase;
             System.debug('=====dceCase===='+dceCase);
        }
        catch (Exception e) {
            String errorMessage = e.getMessage();
            responseMap.put('httpStatusCode', '500');
            responseMap.put('message', 'An error occurred');
            responseMap.put('errorCode', 'Exception');
            responseMap.put('errorMessage', errorMessage); 
            system.debug('e.getMessage()' + e.getMessage());
        }
        return dceCase; 
    }
    // Case Update after sync
    @future
    public static void caseUpdateOnFuture(String CaseId, String DceCaseRawObjectId,String accId) {
        DCE_Case_Raw_Input__c dcecase=[select id,Case__c,CreatedById,cepCaseId__c,Subject__c,Description__c,Severity__c,Vendor_Case_Number_Optional__c,Serial_Number__c,HPE_Serial_Number__c,
                                       Primary_Contact_Federation_ID__c, Primary_contact_email_address__c,Primary_Contact_First_Name__c,
                                       Primarty_Contact_Last_Name__c,Primary_Contact_Mobile__c,Primary_Contact_Phone__c,Primary_Contact_Preferred_Contact_Method__c,Primary_Contact_Preferred_Contact_Time_R__c,
                                       Primary_Contact_Preferred_Contact_TimeZ__c,Troubleshooting_Steps_Taken__c,Operating_System__c,New_Install__c,
                                       AlternateContactFederationId__c,Alternate_Contact_Email__c,Alternate_Contact_First_Name__c,Alternate_Contact_Last_Name__c,Alternate_Contact_Mobile__c,Alternate_Contact_Phone__c,
                                       Alternate_Contact_Preferred_Contact_Meth__c,Alt_Contact_Preferred_Contact_Timerange__c,Alt_Contact_Preferred_Contact_Timezone__c,
                                       Outage__c,Outage_Days__c, Outage_Hours__c,Outage_Minutes__c,createdByFederationId__c,
                                       Any_Customer_Data_Loss__c from DCE_Case_Raw_Input__c where Id=:DceCaseRawObjectId];
        Case caserec=[Select id,CaseNumber,Status,Comments,Description,Subject,ContactId,Severity__c,AssetId from Case where ID=:CaseId];
        List<case> updateCase=new List<Case>();
        List<CaseComment> casecom=new List<CaseComment>();
        // Primary Contact Details
        if(dcecase.Primary_Contact_Federation_ID__c !=null || dcecase.Primary_contact_email_address__c !=null ){
            
            Contact existingContact = findExistingContact(dcecase.Primary_Contact_Federation_ID__c, dcecase.Primary_contact_email_address__c,dcecase.Primary_Contact_Preferred_Contact_Method__c,
                                                          dcecase.Primary_Contact_Phone__c, dcecase.Primary_Contact_Mobile__c);
            if (existingContact != null) {
                caserec.ContactId = existingContact.Id;
            } else {
                // Added by Padmaja SFDC-1243 
                Contact newContact = createNewContact(accId,dcecase.Primary_Contact_Federation_ID__c,dcecase.Primary_contact_email_address__c,
                                                      dcecase.Primary_Contact_First_Name__c, dcecase.Primarty_Contact_Last_Name__c,
                                                      dcecase.Primary_Contact_Mobile__c, dcecase.Primary_Contact_Phone__c,dcecase.Primary_Contact_Preferred_Contact_Method__c);
                caserec.ContactId = newContact.Id;
            } 
        }
        // AlternateContact  Details
        if(dcecase.AlternateContactFederationId__c !=null || dcecase.Alternate_Contact_email__c !=null ){
            Contact AlternateContact = findExistingContact(dcecase.AlternateContactFederationId__c, dcecase.Alternate_Contact_email__c,dcecase.Alternate_Contact_Preferred_Contact_Meth__c,
                                                           dcecase.Alternate_Contact_Phone__c,dcecase.Alternate_Contact_Mobile__c );
            if (AlternateContact != null) {
                caserec.Alternate_Contact_Name__c = AlternateContact.Id;
            } else {
                // Added by Padmaja SFDC-1243 
                Contact newAlternateContact = createNewContact(accId,dcecase.AlternateContactFederationId__c,dcecase.Alternate_Contact_email__c,
                                                               dcecase.Alternate_Contact_First_Name__c, dcecase.Alternate_Contact_Last_Name__c,
                                                               dcecase.Alternate_Contact_Mobile__c, dcecase.Alternate_Contact_Phone__c,dcecase.Alternate_Contact_Preferred_Contact_Meth__c);
                caserec.Alternate_Contact_Name__c = newAlternateContact.Id;
                
            }
            caserec.Alternate_Contact_Email__c = dcecase.Alternate_Contact_email__c;
            caserec.Alternate_Contact_Phone__c = dcecase.Alternate_Contact_Phone__c;
        }
        
      /* if(dcecase.HPE_Serial_Number__c !=null || dcecase.Serial_Number__c !=null){
             System.debug('+++++++AssetId++++++++'+dcecase.HPE_Serial_Number__c+'=====serial number===='+dcecase.Serial_Number__c);
        caserec.AssetId = getAssetId(dcecase.Serial_Number__c, dcecase.HPE_Serial_Number__c);
        }
        else{
            caserec.AssetId = DCEAPIInoformation.dummyAssetId__c; 
        }
        System.debug('+++++++AssetId++++++++'+caserec.AssetId);*/
        dceCase.Case__c = caserec.id;
        
        /*//Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;

        //Setting the DMLOption on Case instance
        caserec.setOptions(dmlOpts);*/
        // Test
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = TRUE;
        try {
            //update caserec;
            Database.update(caserec,dmo);
            update dceCase;
        } catch (DmlException e) { 
        }
        /*CaseComment  casecommrec=new CaseComment();
String Commentbody= 'Federation ID: ' + dcecase.createdByFederationId__c + '\n' + dcecase.Troubleshooting_Steps_Taken__c.replace('<br>', '\n') +'\n' + dcecase.Operating_System__c +
'\n'+dcecase.New_Install__c + '\n'+caserec.Subject +'\n'+caserec.Description;
CaseComment newCaseComment = new CaseComment(
ParentId = caserec.id,
CommentBody = Commentbody
);
try {
insert newCaseComment;
} catch (DmlException e) {
}*/
        CaseComment casecommrec = new CaseComment();
        String Commentbody = '';
        System.debug('===dcecase======='+dcecase);
        if (dcecase != null) {
            System.debug('===dcecase======='+dcecase.createdByFederationId__c);
            if (dcecase.createdByFederationId__c != null) {
                Commentbody += 'Federation ID: ' + dcecase.createdByFederationId__c + '\n';
            }
            if (dcecase.Troubleshooting_Steps_Taken__c != null) {
                Commentbody += dcecase.Troubleshooting_Steps_Taken__c.replace('<br>', '\n') + '\n';
            }
            if (dcecase.Operating_System__c != null) {
                Commentbody += dcecase.Operating_System__c + '\n';
            }
            if (dcecase.New_Install__c != null) {
                Commentbody += dcecase.New_Install__c + '\n';
            }
           
        }
        Commentbody +=caserec.Subject + '\n';
        Commentbody +=caserec.Description + '\n';
           casecommrec.ParentId = caserec.id;
            casecommrec.CommentBody = Commentbody;
            try {
                insert casecommrec;
            } catch (DmlException e) {
            }
    }
    private static Contact findExistingContact(String primaryContactFederationId, String primaryContactEmail,String PreferredContactMethod,
                                               String primaryContactPhone,String primaryContactMobile) {       
        System.debug('=============primaryContactFederationId========'+primaryContactFederationId + ' in findExistingContact method ');
        System.debug('=============primaryContactEmail========'+primaryContactEmail);
        Contact existingContact;
        try {
            //  existingContact = [SELECT Id,Federation_ID__c,Preferred_Contact_Method__c FROM Contact WHERE Federation_ID__c = :primaryContactFederationId OR Email = :primaryContactEmail LIMIT 1];
            if (primaryContactFederationId != null && primaryContactFederationId != '' ) {
                existingContact = [SELECT Id, Federation_ID__c,email, Preferred_Contact_Method__c,MobilePhone, Phone FROM Contact WHERE Federation_ID__c = :primaryContactFederationId LIMIT 1];
            } else if (primaryContactEmail != null && primaryContactEmail != '') {
                existingContact = [SELECT Id, Federation_ID__c,email, Preferred_Contact_Method__c, MobilePhone, Phone FROM Contact WHERE Email = :primaryContactEmail LIMIT 1];
            }
                System.debug('=============existingContact========'+existingContact);
            if(existingContact !=null){
                if(existingContact.Federation_ID__c == Null){
                    existingContact.Federation_ID__c= primaryContactFederationId;
                }  If(existingContact.Preferred_Contact_Method__c == Null || existingContact.Preferred_Contact_Method__c!=PreferredContactMethod){
                    existingContact.Preferred_Contact_Method__c=PreferredContactMethod;
                }
                if(existingContact.Phone  == null ||  existingContact.Phone != primaryContactPhone ){
                    existingContact.Phone=primaryContactPhone;
                }
                if(existingContact.MobilePhone == null || existingContact.MobilePhone != primaryContactMobile){
                    existingContact.MobilePhone = primaryContactMobile;
                }
                Update existingContact;
            }
        } catch (QueryException e) { 
            system.debug(' *** line 644 ' + existingcontact);
            existingContact = null;
        }  system.debug(' *** line 644 ' + existingcontact);
        
        return existingContact;
    }
   /* private static Id getAssetId(String serialNumber, String hpeSerialNumber) {
        Id assetId;
        try {
            
            If(hpeSerialNumber !=null && hpeSerialNumber !=''){
                System.debug('=============hpeSerialNumber========'+hpeSerialNumber);
                Asset matchingAsset = [SELECT Id FROM Asset WHERE Status='Shipped' AND ( HPE_Serial_Number__c = :hpeSerialNumber OR Original_HPE_Serial_Number__c =:hpeSerialNumber)  LIMIT 1];
                assetId = matchingAsset != null ? matchingAsset.Id : null;   
            }
            else If(serialNumber !=null && serialNumber !=''){
                System.debug('=============serialNumber========'+serialNumber);
                Asset matchingAsset = [SELECT Id FROM Asset WHERE Status='Shipped' AND(SerialNumber = :serialNumber  OR Original_HPE_Serial_Number__c=:serialNumber) LIMIT 1];
                assetId = matchingAsset != null ? matchingAsset.Id : null;    
            }
            System.debug('=============assetId line703========'+assetId);
        } catch (QueryException e) {
            assetId = null;
        }
        return assetId;
    }*/
   // Added by Padmaja SFDC-1243  
    private static Map<Id, Asset> getAssetMap(String serialNumber, String hpeSerialNumber) {
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        try {
            List<Asset> assetList = new List<Asset>();
            
            if (String.isNotBlank(hpeSerialNumber)) {
                assetList = [SELECT Id, AccountId  FROM Asset WHERE Status='Shipped' AND ( HPE_Serial_Number__c = :hpeSerialNumber OR Original_HPE_Serial_Number__c =:hpeSerialNumber)  LIMIT 1];
            } else if (String.isNotBlank(serialNumber)) {
                assetList = [SELECT Id, AccountId  FROM Asset WHERE Status='Shipped' AND(SerialNumber = :serialNumber  OR Original_HPE_Serial_Number__c=:serialNumber) LIMIT 1];
            }
            
            if (!assetList.isEmpty()) {
                for (Asset a : assetList) {
                    assetMap.put(a.Id, a);
                }
            }
            
            System.debug('=============assetMap========' + assetMap);
            
        } catch (QueryException e) {
            System.debug('QueryException: ' + e.getMessage());
        }
        
        return assetMap;
    }

  // Added by Padmaja SFDC-1243 
    private static Contact createNewContact(String accId, String primaryContactFederationId, String primaryContactEmail, String primaryContactFirstName, String primaryContactLastName, String primaryContactMobile, String primaryContactPhone,String PreferredContactMethod) {
        System.debug('=============primaryContactFederationId========'+primaryContactFederationId + ' in createnewcontact method' );
        Contact newContact = new Contact();
        newContact.AccountId = accId; //Label.DO_NOT_CHANGE_ACCOUNTID;  // Added by Padmaja SFDC-1243
        newContact.Email = primaryContactEmail;
        newContact.FirstName = primaryContactFirstName;
        newContact.LastName = primaryContactLastName;
        newContact.MobilePhone = primaryContactMobile;
        newContact.Phone = primaryContactPhone;
        if(primaryContactFederationId != null && primaryContactFederationId != ''){
            newContact.DCE_Onboarded__c =true;
            newContact.Federation_ID__c = primaryContactFederationId;
        }
        newContact.Preferred_Contact_Method__c = PreferredContactMethod;
        
        try {
            insert newContact;
        } catch (DmlException e) {
        }
        return newContact;
    }
        private static Map<String,String> caseCreate(CaseApexRestController.caseWrapper caseRec, string dId, DCE_Case_Raw_Input__c newdcecase1){
        Map<String, String> responseMap = new Map<String, String>();  
        DCE_Case_Raw_Input__c newdcecase = newdcecase1;
        RestResponse resp = RestContext.response;
        String debugId =  dId;
              if((caseRec.origin =='CEP' ||caseRec.origin =='HPE GreenLake Platform') && (String.isBlank(caseRec.subject) ||
                                          String.isBlank(caseRec.description) || 
                                          String.isBlank(caseRec.severity))){
                responseMap.put('httpStatusCode', '400');
                responseMap.put('message', 'Missing mandatory fields');
                responseMap.put('errorCode', 'Required fields are missing');
                responseMap.put('debugId', debugId);
                RestContext.response.statusCode = 400;  
            }
            
     /* if (String.isBlank(caseRec.subject) || String.isBlank(caseRec.description) || String.isBlank(caseRec.primaryContactFederationId) || String.isBlank(caseRec.severity) 
            || String.isBlank(caseRec.primaryContactEmailAddress) || String.isBlank(caseRec.primaryContactLastName)) {
                responseMap.put('httpStatusCode', '400');
                responseMap.put('message', 'Missing mandatory fields');
                responseMap.put('errorCode', 'Required fields are missing');
                responseMap.put('debugId', debugId);
                RestContext.response.statusCode = 400;
            } */
        else{
            String accid;
            try{ 
                String inputString = caseRec.description; // Replace '...' with the provided string
                String description = inputString.replace('\\n', '\n');
                Case newCase = new Case();
                newCase.Subject = caseRec.subject;
                newCase.Description = description;
                
                if(caseRec.severity =='1-CRITICAL-DOWN'){
                    newCase.Severity__c= 'Critical';  
                }
                else if(caseRec.severity =='2-CRITICAL-DEGRADED'){
                    newCase.Severity__c= 'Critical - Degraded';
                }
                else if(caseRec.severity == '3-NORMAL'){  
                    newCase.Severity__c= 'Non-Critical'; 
                }
                else{
                    newCase.Severity__c = 'Low Priority'; 
                }          
                if(UserInfo.getUserId() == Label.DCEIntegration_APIUser){
                newCase.DCE_Sync__c = True;
                }
                if(caseRec.origin=='CEP'){
                 newCase.Origin ='CEP';   
                }else if(caseRec.origin=='HPE GreenLake Platform'){
                 newCase.Origin ='HPE GreenLake Platform';   
                }else{
                newCase.Origin ='Web';
                }
                newCase.caseVendorCaseNumberOptional__c = caseRec.vendorCaseNumber;
                newCase.DCE_Case_Raw_Input__c=newdcecase.id;
                newcase.Preferred_Contact_Info__c  = caseRec.primaryContactPreferredContactInfo;                       
                if (caseRec.outage == 'yes') {
                    newcase.Outage__c = true;
                } else {
                    newcase.Outage__c = false;
                }
                newcase.Time_Zone__c =caseRec.primaryContactPreferredContactTimeZone;
                newcase.Outage_Duration_Days__c = !String.isBlank(caseRec.outageDays)? Integer.valueOf(caseRec.outageDays) : 0;
                newcase.Outage_Duration_Hours__c = !String.isBlank(caseRec.outageHours) ? Integer.valueOf(caseRec.outageHours) : 0;
                newcase.Outage_Duration_Minutes__c = !String.isBlank(caseRec.outageMinutes)? Integer.valueOf(caseRec.outageMinutes) : 0;
                newcase.Any_Customer_Data_Loss__c = caseRec.anyCustomerDataLoss;
                  if((caseRec.hpeSerialNumber !=null && !String.isBlank(caseRec.hpeSerialNumber))  || (caseRec.serialNumber !=null && !String.isBlank(caseRec.serialNumber))){
                    System.debug('+++++++AssetId++++++++'+caseRec.hpeSerialNumber+'=====serial number===='+caseRec.serialNumber);
                    //newcase.AssetId = getAssetId(caseRec.serialNumber, caseRec.hpeSerialNumber); // SFDC-1243 By Padmaja
                      
                      Map<Id, Asset> assetMap = getAssetMap(caseRec.serialNumber, caseRec.hpeSerialNumber);
                      
                      newCase.AssetId = null;
                      if (!assetMap.isEmpty()) {
                          for (Asset ast : assetMap.Values()) {
                              newCase.AssetId = ast.Id; 
                              accid = ast.accountid;
                              break; 
                          }
                      }

                }
                else{
                    newcase.AssetId = DCEAPIInoformation.dummyAssetId__c; 
                }
                insert newCase;
                
                Case CaseRecord = [SELECT Id,Severity__c,DCE_Sync__c,CreatedDate, CaseNumber FROM Case WHERE Id = :newCase.id];
                system.debug('*******CaseRecord******'+CaseRecord);
                responseMap.put('createdAt', String.valueOf(CaseRecord.CreatedDate));
                responseMap.put('debugId', debugId);
                responseMap.put('caseNumber', CaseRecord.CaseNumber);
                responseMap.put('caseId', CaseRecord.Id);
                responseMap.put('message', 'Case Record successfully created');
                responseMap.put('httpStatusCode', '200');
                resp.statusCode = 200;  
                  
                caseUpdateOnFuture(newCase.id, newdcecase.id,accid);
            }
            catch (System.TypeException e) {
                String errorMessage = e.getMessage();
                String[] parts = errorMessage.split(':'); 
                String exceptionType = parts[0].trim(); 
                String fieldWithError = '';
                if (parts.size() > 1) {
                    fieldWithError = parts[1].trim();
                }
                String statuscode = '400';
                handleErrorResponse(statuscode, errorMessage,fieldWithError,responseMap,debugId);               
            } 
            catch (NullPointerException e) {
                String errorMessage = e.getMessage();
                String[] parts = errorMessage.split(':'); 
                String exceptionType = parts[0].trim();
                String fieldWithError = '';
                if (parts.size() > 1) {
                    fieldWithError = parts[1].trim();
                } 
                String statuscode = '401';
                handleErrorResponse(statuscode, errorMessage,fieldWithError,responseMap,debugId);
            } 
            catch (DmlException e) {
                String errorMessage = e.getMessage();
                String[] parts = errorMessage.split(':'); 
                String exceptionType = parts[0].trim();
                String fieldWithError = '';
                if (parts.size() > 1) {
                    fieldWithError = parts[1].trim();
                }
                String statuscode = '403';
                handleErrorResponse(statuscode, errorMessage,fieldWithError,responseMap,debugId);
            } 
            catch (StringException  e) {
                String errorMessage = e.getMessage();
                String[] parts = errorMessage.split(':'); 
                String exceptionType = parts[0].trim();
                String fieldWithError = '';
                if (parts.size() > 1) {
                    fieldWithError = parts[1].trim();
                }
                String statuscode = '500';
                handleErrorResponse(statuscode, errorMessage,fieldWithError,responseMap,debugId);                 
            }
            catch (exception  e) {
                String errorMessage = e.getMessage();
                String[] parts = errorMessage.split(':'); 
                String exceptionType = parts[0].trim();
                String fieldWithError = '';
                if (parts.size() > 1) {
                    fieldWithError = parts[1].trim();
                } 
                String statuscode = '503';
                handleErrorResponse(statuscode, errorMessage,fieldWithError,responseMap,debugId);                 
            }
        }           
            return responseMap;
        
    }
     public static DCE_API_Information__mdt DCEAPIInoformation{
        get{
            if(DCEAPIInoformation==null)
                DCEAPIInoformation =[select id,QualifiedApiName,
                                     DeveloperName,
                                     Contact_API__c,
                                     DCE_Identity_API__c,
                                     createdbyfederationID__c,
                                     Salesforce_API__c,
                                     dummyAssetId__c,
                                     Password__c,
                                     Username__c
                                     from DCE_API_Information__mdt
                                     where QualifiedApiName='Default' ];
            return DCEAPIInoformation;
        }
        private set;
    }
}