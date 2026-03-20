/**
* @description       : 
* @author            : Nagalaxmi Telkar
* @group             : 
* @last modified on  : 11-12-2025
* @last modified by  : Nagalaxmi Telkar
* Modifications Log
* Ver   Date         Author             Modification
* 1.0   05-05-2023   Nagalaxmi Telkar   Initial Version
**/
public with Sharing class EmailMessageHandler{
    Map<string, id> queueMap = new Map<string, id>();
    List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
    List<Id> casesIds = new List<Id>();
    List<Case> listOfCasesToUpdate = new List<Case>();
    Map<Id, EmailMessage> mapOfCaseToEmail = new Map<Id, EmailMessage>();
    List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
    Boolean caseAlreadyInList = false;
    Map<Id,Case> uniqueRecords = new Map<Id, Case>();
   
    public void reopenCase(EmailMessage[] emailMessages){
        system.debug('Entered into the email message handler 1');
                /** Added by Exafort(Azar) 
        *  Purpose - To assign case to corressponding queue based on support provider 
        *  */
        List<Group> qs = [select id,name From Group where Type='queue' and (name ='Support Queue - General' or name = 'Support Queue - TSC' or name = 'Support Queue - H3C' or name = 'Support Queue - NCV' or name = 'Support Queue - Automatic' or name = 'Support Queue - SSaaS' or name = 'Tech Hub Queue - SDOE' or name = 'Support Queue - InfoSight Portal')];
        List<Case> cases = new List<Case>();
        for(Group gr : qs){
            queueMap.put(gr.Name, gr.id);
        }
        /*** End of getting query to assign queue ***/
        
        for(EmailMessage emailMessage : emailMessages){
            casesIds.add(emailMessage.ParentId);
            mapOfCaseToEmail.put(emailMessage.ParentId, emailMessage);
        }
       
        if(!casesIds.isEmpty()){
            cases = [SELECT Owner.Id,Owner.Name,Owner.Type,Case_Effort_Summary_Total__c,caseClosureEstimatedEffort__c, Alternate_Contact_Name__c,Alternate_Contact_Name__r.Id,
                     Current_comment_time_spent__c, Current_comment_activity__c , ContactId,Account.Support_Provider__c, Owner.Email, 
                     AssetId,CreatedDate,ClosedDate,Case_Owner_Time_Effort__c,Non_Case_Owner_Time_Effort__c,Support_Profile__c,
                     Subject,Estimated_Effort__c,Contact.Email,Status,LastModifiedDate, Auto_Close__c,OwnerId,caseAccountSupportProvider__c,
                     RecordType.Name,DateTime_First_Available_To_Work__c, Asset.Asset_Type__c,Sub_Status__c,X3_Strike__c,First_Outgoing_Email__c,RecordTypeId
                     FROM Case 
                     WHERE Id = :casesIds ];  
        }
        
        for(Id caseId : mapOfCaseToEmail.keySet()){
            system.debug('Entered into the email message handler 2');
            Boolean rejectSubject = mapOfCaseToEmail.get(caseId).subject != null &&(mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Out of office ') ||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('OOO') ||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('out of the office') ||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('PTO')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Auto Reply' )||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Auto Response')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('[Auto-Reply]')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('[Out of office]')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Out-of-office')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('auto-response') ||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('[Out-of-office]') ||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('autoresponse RE')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('autoreply') ||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('autoresponse')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('vacation')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('auto response')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Out of Office' )||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Automatic reply') || mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('[알림] 휴가로 인한 부재') ||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Delivery delayed:New case comment notification.') ||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Delivery delayed:') ||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Undeliverable')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('Email Loop Protection')||mapOfCaseToEmail.get(caseId).subject.containsIgnoreCase('[Email Loop Protection]'));
            
            Boolean rejectSurvey = !mapOfCaseToEmail.get(caseId).incoming && (mapOfCaseToEmail.get(caseId).fromaddress != null && mapOfCaseToEmail.get(caseId).fromaddress.containsIgnoreCase('donotreply')) && ((mapOfCaseToEmail.get(caseId).HtmlBody != null && mapOfCaseToEmail.get(caseId).HtmlBody.containsIgnoreCase('clicktools.com'))  ||(mapOfCaseToEmail.get(caseId).TextBody != null && mapOfCaseToEmail.get(caseId).TextBody.containsIgnoreCase('clicktools.com')));
            
            Boolean rejectUndeliverable = false;
            
            if (mapOfCaseToEmail.get(caseId).subject != null){
                Pattern patternUndeliverable = Pattern.compile('(?i).*?undeliverable.*');
                Matcher matcherUndeliverable = patternUndeliverable.matcher(mapOfCaseToEmail.get(caseId).subject);
                rejectUndeliverable  = matcherUndeliverable.matches();
            }
            
            if (!rejectSubject && !rejectSurvey && !rejectUndeliverable){
                system.debug('Entered into the email message handler 3');
                
                // Handle Case Attention Flag based on email direction-SFDC-2007
                for(Case aCase : cases){
                    if(aCase.Id == caseId){
                        // Set Case Attention Flag based on email direction
                        if(mapOfCaseToEmail.get(caseId).Incoming == false && mapOfCaseToEmail.get(caseId).Subject.contains('[ ref:_')) {
                            // Outgoing email - turn OFF the Case Attn Flag
                            aCase.caseAttnReq__c = false;
                            system.debug('Case Attn Flag turned OFF for outgoing email on case: ' + caseId);
                        } 
                        
                        listOfCasesToUpdate.add(aCase);
                    }
                }
                
                if(cases.size()>0){
                    for(Case aCase : cases){
                        system.debug('Entered into the email message handler 33');
                        if(aCase.Status == 'Closed' && aCase.RecordType.Name != 'Ops Case' && (String.isBlank(aCase.Account.Support_Provider__c ) || String.isEmpty(aCase.Account.Support_Provider__c ))){
                            system.debug('Entered into the email message handler 4');
                            //  Incoming email and make sure the incoming email is not from system itself as reported in SFDC-1852                            
                            if (mapOfCaseToEmail.get(caseId).Incoming == true && CaseUtility.isOrgwideEmailAddress(mapOfCaseToEmail.get(caseId).FromAddress) == false){
                                caseUtility.VALIDATE_OWNER_TRIGGER = false;
                                caseUtility.isEmailIncoming = true; //Added for Exafort SFDC-1988
                                if((Date.valueOf(aCase.ClosedDate)).daysBetween(System.today()) <= 30){//Trying to reopen closed case less than or equal to 30 days
                                    //  Added by Exafort for SFDC-1469
                                    resetTimer(aCase, true);
                                    aCase.Status = 'Update Needed'; 
                                    if(aCase.RecordType.Name != 'InfoSight Portal'){  // Added by Exafort for SFDC-1923
                                        aCase.Sub_Status__c = 'Reopen';
                                    }
                                    //  End of change for SFDC-1469
                                    aCase.Reopened__c = true;
                                    aCase.caseAttnReq__c = True; // Added by Exafort for SFDC-1586 whenever case status is update needed then Attn Req should be True
                                    reopenCaseUtility(aCase, queueMap);
                                }else if((Date.valueOf(aCase.ClosedDate)).daysBetween(System.today()) > 30){//Cases closed since more than 30 days
                                    system.debug('Entered into the email message handler 5');
                                    cloneCase(aCase,mapOfCaseToEmail.get(caseId));
                                }
                            }
                        }else if((aCase.Status != 'Closed' || aCase.Status != 'Resolved') && aCase.Status != 'New' && aCase.RecordType.Name != 'Ops Case' && (String.isBlank(aCase.Account.Support_Provider__c ) || String.isEmpty(aCase.Account.Support_Provider__c ))){
                            system.debug('Entered into the email message handler 6');
                            //  Incoming email and make sure the incoming email is not from system itself as reported in SFDC-1852
                            if (mapOfCaseToEmail.get(caseId).Incoming == true && CaseUtility.isOrgwideEmailAddress(mapOfCaseToEmail.get(caseId).FromAddress) == false){
                                caseUtility.VALIDATE_OWNER_TRIGGER = false;
                                caseUtility.isEmailIncoming = true; //Added for Exafort SFDC-1988
                                //  Exafort added for Status/Sub Status SFDC-1516
                                Switch on (aCase.Status){
                                    when 'Waiting on Customer'{
                                        resetTimer (aCase, true);
                                    }                                    
                                    when 'Update Needed'{
                                        resetTimer (aCase, (aCase.Sub_Status__c == 'First Strike' || aCase.Sub_Status__c == 'Second Strike'));
                                    }                                    
                                    when else{
                                        resetTimer (aCase, false);
                                    }
                                }// End of SFDC-1516
                                
                            }
                        }else if(aCase.Status == 'Closed' && aCase.RecordType.Name == 'Ops Case'){
                            if (mapOfCaseToEmail.get(caseId).Incoming == true){
                                caseUtility.VALIDATE_OWNER_TRIGGER = false;
                                aCase.Status = 'Open';
                                reopenCaseUtility(aCase, queueMap);
                            }
                        } else if(aCase.Status != 'Closed' && !mapOfCaseToEmail.get(caseId).incoming && mapOfCaseToEmail.get(caseId).subject != null && mapOfCaseToEmail.get(caseId).subject.contains('[ ref:_') && !aCase.First_Outgoing_Email__c){
                            System.debug('I am ready to change the value here');
                            aCase.First_Outgoing_Email__c = true;
                            
                            for(Case existingCase : listOfCasesToUpdate){
                                if(existingCase.Id == aCase.Id){
                                    caseAlreadyInList = true;
                                    break;
                                }
                            }

                            listOfCasesToUpdate.add(aCase);
                        }
                    }

                    for (Case record : listOfCasesToUpdate) {
                        uniqueRecords.put(record.Id, record);
                    }
                    if(!uniqueRecords.isEmpty()){
                        try {
                            // Now, update or delete using the values from the map
                            update uniqueRecords.values();
                        } catch(DMLException e) {
                            System.debug('Error updating cases: ' + e.getMessage());
                            // Consider logging to a custom object or sending alerts
                        }
                    }
                }
            }            
        }
    }         
            
    
    
    
    private void reopenCaseUtility(Case aCase, Map<string, id> mapForQueue){
        caseUtility.VALIDATE_OWNER_TRIGGER = false;
        //aCase.Status = 'Open'; //Added by Exafort for SFDC-1469
        /* ------- START -----------
* Below Lines of code is to assign the case to corressponding support queue for automation cases.
* Author: Exafort(Azar)
* Date: 9th Oct 2017
* updated By Exafort(vishnu) for assign auto close cases to rightful queue
* */
        if(mapForQueue.get('Support Queue - Automatic') == aCase.ownerId){
            aCase.DateTime_First_Available_To_Work__c = System.now();
            aCase.OwnerId = mapForQueue.get('Support Queue - General');
        }
        
        if((aCase.caseAccountSupportProvider__c == '' || aCase.caseAccountSupportProvider__c == null) && aCase.Auto_Close__c == true){
            if(aCase.RecordType.Name == 'Array Case' && aCase.Auto_Close__c == true){
                if(mapForQueue.get('Support Queue - General') != null){
                    aCase.OwnerId = mapForQueue.get('Support Queue - General');
                }
            }                            
            else if(aCase.RecordType.Name == 'NCV Case' && aCase.Auto_Close__c == true){
                if(mapForQueue.get('Support Queue - NCV') != null){
                    aCase.OwnerId = mapForQueue.get('Support Queue - NCV');
                }
            }
            //Added by exafort on March 23 2021 for TS-8011 START
            else if(aCase.RecordType.Name == 'SSaaS' && aCase.Auto_Close__c == true){
                if(mapForQueue.get('Support Queue - SSaaS') != null){
                    aCase.OwnerId = mapForQueue.get('Support Queue - SSaaS');
                }
            }
            //Added by exafort on March 23 2021 for TS-8011 END
            //Added by exafort on April 07 2021 for TS-8103 START
            else if(aCase.RecordType.Name == 'SDOE' && aCase.Auto_Close__c == true){
                if(mapForQueue.get('Tech Hub Queue - SDOE') != null){
                    aCase.OwnerId = mapForQueue.get('Tech Hub Queue - SDOE');
                }
            }
            //Added by exafort on April 07 2021 for TS-8103 END
            //Added by vishnu on july 14 2021 for TS-8358
            else if(aCase.RecordType.Name == 'InfoSight Portal' && aCase.Auto_Close__c == true){
                if(mapForQueue.get('Support Queue - InfoSight Portal') != null){
                    aCase.OwnerId = mapForQueue.get('Support Queue - InfoSight Portal');
                }
            }//Added by vishnu on july 14 2021 for TS-8358
        }
        else if(aCase.caseAccountSupportProvider__c != null && aCase.caseAccountSupportProvider__c == 'Toshiba IT-Services Corporation' && aCase.Auto_Close__c == true){
            if(mapForQueue.get('Support Queue - TSC') != null){
                aCase.OwnerId = mapForQueue.get('Support Queue - TSC');
            }
        }
        else if(aCase.caseAccountSupportProvider__c != null && aCase.caseAccountSupportProvider__c.contains('H3C') && aCase.Auto_Close__c == true){
            if(mapForQueue.get('Support Queue - H3C') != null){
                aCase.OwnerId = mapForQueue.get('Support Queue - H3C');
            }
        }
        /*----END-----*/
        update aCase;
    }
    
    public void cloneCase(Case caseToClone, EmailMessage emailMsg){ 
        List<CaseTeamMember> ctmSet = new List<CaseTeamMember>();
        Boolean createdCaseTeamRole = false;
        Map<String, Id> caseTeamRolesMap = new Map<String, Id>();
        Map<String, Id> caseTeamRolesMapRunOnce = new Map<String, Id>();
        List<String> emailIds = new List<String>();
        Datetime now = Datetime.now(); Integer offset = UserInfo.getTimezone().getOffset(now); Datetime local = now.addSeconds(offset/1000);  
        Case clonedCase = caseToClone.clone(false,false,false,false);
        clonedCase.caseClosureCaseReason__c = null;
        clonedCase.caseClosureCategory__c = null;
        clonedCase.caseClosureArrayDowntimeMinutes__c = null;
        clonedCase.caseClosureBusinessImpact__c = null;
        clonedCase.casecatClosureCategory__c = null;
        clonedCase.caseClosureDetail__c = null;
        clonedCase.caseClosureEnvironmentDowntimeMinutes__c = null;
        clonedCase.casCatClosureRootCause__c = null;
        clonedCase.caseCatClosureSubCategory__c = null;
        clonedCase.Closure_Volume_Downtime_Minutes__c = null;
        clonedCase.caseClosureEstimatedEffort__c = null;
        clonedCase.Primary_Closure_Root_Cause__c = null;
        clonedCase.Secondary_Closure_Root_Cause__c = null;
        clonedCase.casePlanOfAction__c = null;
        clonedCase.caseCurrentStatus__c = null;
        clonedCase.AssetId = caseToClone.AssetId;
        clonedCase.Estimated_Effort__c = caseToClone.Estimated_Effort__c;
        clonedCase.Subject = caseToClone.Subject;
        clonedCase.ParentId = caseToClone.Id;
        clonedCase.DCE_Sync__c = false;
        clonedCase.AccountId = caseToClone.AccountId;
        clonedCase.Alternate_Contact_Name__c = caseToClone.Alternate_Contact_Name__r.Id;
        clonedCase.Origin = 'Email';//SFDC 701
        clonedCase.X3_Strike__c = False; //SFDC 1633
        clonedCase.RecordTypeId = caseToClone.RecordTypeId; //SFDC 1633//SFDC-2131
        if(String.valueOf(emailMsg.TextBody).length()>31950 )
            clonedCase.Description = '[Message Clipped] \n \n'+String.valueOf(emailMsg.TextBody).left(31000);
        else 
            clonedCase.Description = emailMsg.TextBody;
        
        clonedCase.Sub_Status__c = null;
        clonedCase.caseAttnReq__c =  False; // Added by Exafort for SFDC-1586
        clonedCase.Status = 'New';
        if(!Test.isRunningTest()){
              //SFDC-2131-Ntelkar
             if(caseToClone.RecordTypeId == Schema.SObjectType.case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId())
                 clonedCase.OwnerId = queueMap.get('Support Queue - General');
             if(caseToClone.RecordTypeId == Schema.SObjectType.case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId())
                 clonedCase.OwnerId = queueMap.get('Support Queue - InfoSight Portal');
             if(caseToClone.RecordTypeId == Schema.SObjectType.case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId())
                 clonedCase.OwnerId = queueMap.get('Support Queue - SSaaS');
        }
               
        
        try{
            insert clonedCase;
        }catch(DMLException ex){
            System.debug('There was an exception cloning the case : '+ex.getMessage());
        }

        Case casesForAlert = [SELECT CaseNumber,Subject, Asset.Asset_Type__c, ContactId, Contact.Email, Owner.Name, Alternate_Contact_Name__r.Email,Alternate_Contact_Name__r.Phone, Alternate_Contact_Name__c, Account.Primary_CS_PSM__r.Id, ParentId,
                                        Account.Primary_PSM__r.Id, Account.Primary_CS_PSM__r.Email, Account.Primary_CS_PSM__c, Account.Primary_PSM__c, Account.Primary_PSM__r.Email, RecordType.Name,Contact.iamabot__c,Case_Handling__c,Support_Profile__c,
                                        Account.ACM_Service_Purchased__c,Asset.assetConcierge_Service__c, Asset.CS_PSM__c, Account.CS_PSM__c, Account.Support_Provider__c, caseDontSendCaseOpenEmail__c, Case_Type__c, Status, Auto_Open__c,caseProject__c 
                                        FROM Case 
                                        WHERE Id =: clonedCase.Id];
        
        caseTeamRolesMapRunOnce = RecursiveTriggerRestrictiion.caseTeamRolesMap;
        if(caseTeamRolesMapRunOnce != null && caseTeamRolesMapRunOnce.size() > 0) {
                caseTeamRolesMap = caseTeamRolesMapRunOnce;
        } else {
            caseTeamRolesMap = RecursiveTriggerRestrictiion.getCaseTeamRolesMap();
        }


        System.debug('Alternate contact is : '+casesForAlert.Alternate_Contact_Name__c);
        if(casesForAlert.Alternate_Contact_Name__c !=null && casesForAlert.Alternate_Contact_Name__r.Email != null){
            System.debug('Alternate Contact passed : '+casesForAlert.Alternate_Contact_Name__c);
            CaseTeamMember alternateContact = new CaseTeamMember();
            alternateContact.MemberId = casesForAlert.Alternate_Contact_Name__r.Id;
            alternateContact.ParentId = casesForAlert.Id;
            alternateContact.TeamRoleId = caseTeamRolesMap.get('Alternate Contact Name');
            ctmSet.add(alternateContact);   
            emailIds.add(casesForAlert.Alternate_Contact_Name__r.Email);
        }
        if((casesForAlert.Asset.assetConcierge_Service__c && casesForAlert.Asset.CS_PSM__c && casesForAlert.Account.Primary_PSM__c != null && casesForAlert.Account.Primary_CS_PSM__c != null) && (casesForAlert.Account.Primary_PSM__c == casesForAlert.Account.Primary_CS_PSM__c)){ 
            CaseTeamMember ctmpsm = new CaseTeamMember();
            ctmpsm.MemberId = casesForAlert.Account.Primary_PSM__r.Id;
            ctmpsm.ParentId = casesForAlert.Id;
            ctmpsm.TeamRoleId = caseTeamRolesMap.get('Proactive Support Manager');
            ctmSet.add(ctmpsm); 
            emailIds.add(casesForAlert.Account.Primary_PSM__r.Email); 
            createdCaseTeamRole = true;
        }if((casesForAlert.Asset.assetConcierge_Service__c || casesForAlert.Asset.CS_PSM__c) && !createdCaseTeamRole){
            if(casesForAlert.Asset.assetConcierge_Service__c && casesForAlert.Account.Primary_PSM__c != null && casesForAlert.Account.Primary_PSM__r.Email != null){
                CaseTeamMember ctmpsm = new CaseTeamMember();
                ctmpsm.MemberId = casesForAlert.Account.Primary_PSM__r.Id;
                ctmpsm.ParentId = casesForAlert.Id;
                ctmpsm.TeamRoleId = caseTeamRolesMap.get('Proactive Support Manager');
                ctmSet.add(ctmpsm); 
                emailIds.add(casesForAlert.Account.Primary_PSM__r.Email);
            }
            if(casesForAlert.Asset.CS_PSM__c && casesForAlert.Account.Primary_CS_PSM__c != null && casesForAlert.Account.Primary_CS_PSM__r.Email != null){
                CaseTeamMember cspsm = new CaseTeamMember();
                cspsm.MemberId = casesForAlert.Account.Primary_CS_PSM__r.Id;
                cspsm.ParentId = casesForAlert.Id;
                cspsm.TeamRoleId = caseTeamRolesMap.get('Proactive Support Manager');
                ctmSet.add(cspsm); 
                emailIds.add(casesForAlert.Account.Primary_CS_PSM__r.Email);
            }
        }
        String [] emailsAsArray;
        createdCaseTeamRole = false;
        if(emailIds.size() > 0){
            emailsAsArray = new String [emailIds.size()];
            Integer i = 0;
            String emails;
            
            for (String singleCCEmail: emailIds) {
                emailsAsArray[i++] = singleCCEmail;
            }
        }

        if(ctmSet.size()> 0){
            try{
                insert ctmSet; 
            }catch(DMLException ex){
                ex.getStackTraceString();
            }
        }
        sendEmail(caseToClone, clonedCase, emailMsg.fromAddress, emailsAsArray); 

    }
    
    private void sendEmail(Case caseToClone, Case clonedCase, String fromAdd, String[] ccAddresses){
        EmailTemplate emailTemplate = [SELECT body, Id FROM EmailTemplate WHERE DeveloperName = 'NewCaseFromOldCase'];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.setTargetObjectId(caseToClone.ContactId);
        
        //if(caseToClone.Support_Profile__c  == 'Alletra MP Block' || caseToClone.Support_Profile__c == 'Alletra MP File'){
        if(caseToClone.Support_Profile__c != null){
            if(!caseToClone.Support_Profile__c.equals('Legacy Nimble')){
                System.debug('Email Message Reply to is set for : hpe-services-storage@hpe.com for Support Profile : '+caseToClone.Asset.Asset_Type__c + ': CaseUtility.runningInASandbox : '+CaseUtility.runningInASandbox);
                if(!CaseUtility.runningInASandbox){
                    CaseUtility.addToMapOfOrgWideEmailAddress('hpe-services-storage@hpe.com');
                    if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey('hpe-services-storage@hpe.com')) {
                        message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get('hpe-services-storage@hpe.com'));
                        System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get('hpe-services-storage@hpe.com'));
                    }
                    message.setReplyTo('hpe-services-storage@hpe.com');
                }else{
                    CaseUtility.addToMapOfOrgWideEmailAddress(System.label.Non_Legacy_Nimble_OrgWideEmail_Label);
                    if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey(System.label.Non_Legacy_Nimble_OrgWideEmail_Label)) {
                        message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.Non_Legacy_Nimble_OrgWideEmail_Label));
                        System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.Non_Legacy_Nimble_OrgWideEmail_Label));
                    }
                    message.setReplyTo(System.label.Non_Legacy_Nimble_OrgWideEmail_Label);
                } 
            }
            //else if(caseToClone.Support_Profile__c == 'Backup & Recovery' || caseToClone.Support_Profile__c == 'Legacy Nimble' || caseToClone.Support_Profile__c == null ){
            else{
                System.debug('Email Message Reply to is set for : supportcase@nimblestorage.com for Support Profile : '+caseToClone.Asset.Asset_Type__c + ': CaseUtility.runningInASandbox : '+CaseUtility.runningInASandbox);
                if(!CaseUtility.runningInASandbox){
                    CaseUtility.addToMapOfOrgWideEmailAddress('supportcase@nimblestorage.com');
                    if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey('supportcase@nimblestorage.com')) {
                        message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get('supportcase@nimblestorage.com'));
                        System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get('supportcase@nimblestorage.com'));
                    }
                    message.setReplyTo('supportcase@nimblestorage.com');
                }else{
                    CaseUtility.addToMapOfOrgWideEmailAddress(System.label.Legacy_Nimble_OrgWideEmail_Label);
                    if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey(System.label.Legacy_Nimble_OrgWideEmail_Label)) {
                        message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.Legacy_Nimble_OrgWideEmail_Label));
                        System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.Legacy_Nimble_OrgWideEmail_Label));
                    }
                    message.setReplyTo(System.label.Legacy_Nimble_OrgWideEmail_Label);
                }
            }
        }else{
            if(!CaseUtility.runningInASandbox){
                CaseUtility.addToMapOfOrgWideEmailAddress('hpe-services-storage@hpe.com');
                if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey('hpe-services-storage@hpe.com')) {
                    message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get('hpe-services-storage@hpe.com'));
                    System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get('hpe-services-storage@hpe.com'));
                }
                message.setReplyTo('hpe-services-storage@hpe.com');
            }else{
                CaseUtility.addToMapOfOrgWideEmailAddress(System.label.Non_Legacy_Nimble_OrgWideEmail_Label);
                if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey(System.label.Non_Legacy_Nimble_OrgWideEmail_Label)) {
                    message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.Non_Legacy_Nimble_OrgWideEmail_Label));
                    System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.Non_Legacy_Nimble_OrgWideEmail_Label));
                }
                message.setReplyTo(System.label.Non_Legacy_Nimble_OrgWideEmail_Label);
            } 
        }
        message.setUseSignature(false);
        message.setBccSender(true);
        message.setTemplateID(emailTemplate.Id);
        message.setWhatId(clonedCase.Id); //This is important for the merge fields in template to work
        message.toAddresses = new String[] { caseToClone.Contact.email, caseToClone.Owner.Email, fromAdd};
        if(ccAddresses != null && ccAddresses.size()>0)
            message.setCcAddresses(ccAddresses);
            
        messages.add(message);    
        try{
            results = Messaging.sendEmail(messages);
            if (results[0].success){
                CaseComment cc;
                System.debug('The email was sent successfully for : .'+clonedCase.Id);
                if(String.valueOf(message.getPlainTextBody()).length()>3900){
                    String truncatedMessage = '[Message Clipped] \n\n';
                    cc = new CaseComment(ParentId = clonedCase.Id,CommentBody = truncatedMessage + String.valueOf(message.getPlainTextBody()).left(3900));
                }else
                    cc = new CaseComment(ParentId = clonedCase.Id,CommentBody = message.getPlainTextBody());
                
                try{
                    insert cc;
                }catch(DMLException ex){
                    System.debug('There was an exception inserting the case comment : '+ex.getMessage());  
                } 
            }
            
            else
                System.debug('The email failed to send: ' +results[0].errors[0].message);
        }catch(EmailException ex){
            ex.getMessage();
        }catch(DMLException ex){
            System.debug('There was an exception inserting the case comment : '+ex.getMessage());  
        }
    }

    // Added by Exafort for TS-10065
    public void updateFirstCustomerContactOnCase(EmailMessage[] emailMessages){
        // Enqueue this for asynchronous processing using the Queueable interface
        System.enqueueJob(new OpenCaseQueueable(emailMessages,System.now()));
    }
    // End of TS-10065 */

    private void resetTimer(Case aCase, boolean reset3Strike){
        if(aCase.Status != 'Handover'){
            aCase.Status = 'Update Needed'; //Added by Exafort for SFDC-1469
        }
        if(aCase.RecordType.Name != 'InfoSight Portal'){   // Added by Exafort for SFDC-1923
            aCase.Sub_Status__c = 'Customer Replied'; //Added by Exafort for SFDC-1469 
        }
        aCase.Timer_Expiry_Date__c = null;
        aCase.Timer_Expiry_Date_Change_for_Scheduled__c= null;
        aCase.Timer_Expiry_Override_Date__c= null;
        aCase.Timer_Expiry_Date_Overridden__c = False;
        if (reset3Strike){
            aCase.X3_Strike__c = False;
        }
        aCase.caseAttnReq__c = True; // Added by Exafort for SFDC-1586 whenever case status is update needed then Attn Req should be True
        //reopenCaseUtility(aCase, queueMap);
        // Added by Exafort for SFDC-1847 to update a Case when an incoming email is received and the Case Status is not equal to Closed
        listOfCasesToUpdate.add(aCase);
        // End of SFDC-1847
    }
}