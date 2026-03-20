/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 09-26-2025
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-14-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger CaseTrigger on Case (before insert, after insert, after update, before update)
public with sharing class Legacy_Case_AI_CaseTrigger  implements TriggerAction.AfterInsert{
    //System.debug('DEBUG: (CaseTrigger) ===== ENTERED');
    //System.debug('DEBUG: (CaseTrigger) ===== getQueries = ' + Limits.getQueries());
    public void afterInsert(List<Case> newList)  {   
    //Added by exfort for TS-10444
    Map<Id,Case> newMap = new Map<Id,Case>(newList);
    if(CaseUtility.CASETRIGGER_FLAG )
    {
    
        Map<String, Id> caseTeamRolesMap = new Map<String, Id>();
        Map<String, Id> caseTeamRolesMapRunOnce = new Map<String, Id>();
        //Added By Exafort TS-10404 Start 
        Map<Id, Account> accountEntries = new Map<Id, Account>();        
        Set<Id> accountIds = new Set<Id>();
        if(checkRecursive.runOnce()){
            
            for (Case caseToProcess : newList) {
                accountIds.add(caseToProcess.AccountId);
            }
            //  Read account info
            accountEntries = new Map<Id, Account>([
                SELECT CS_PSM__c,ACM_Service_Purchased__c, Primary_PSM__c, Primary_PSM__r.Email, Primary_CS_PSM__c, Primary_CS_PSM__r.Email FROM Account WHERE Id IN :accountIds
            ]);
        }
         //Added By Exafort TS-10404 End 
        caseTeamRolesMapRunOnce = RecursiveTriggerRestrictiion.caseTeamRolesMap;
        if(caseTeamRolesMapRunOnce != null && caseTeamRolesMapRunOnce.size() > 0) {
                caseTeamRolesMap = caseTeamRolesMapRunOnce;
        } else {
            caseTeamRolesMap = RecursiveTriggerRestrictiion.getCaseTeamRolesMap();
        }
       
       
        //End of TS-4483
        //Added by Pradeep.
        //if(Trigger.isAfter && Trigger.isInsert){
            List<CaseComment> Insertcasecomment = new List<CaseComment>();//added by exafort for TS-6417,TS-8404,TS-8401 on 05/03/21
            set<String> pachinkoCaseTypes = new set<String> ();
            List<Case> caseList = new List<Case>();
            Map<Id, Case> mapOfCases = new Map<Id,Case>();
            Boolean createdCaseTeamRole = false;
            List<Case> casesForAlert = new List<Case>();
            List<CaseTeamMember> ctmSet = new List<CaseTeamMember>();
            List<String> apexErrors = new List<String>();
            Boolean isSandbox = CaseUtility.runningInASandbox;
            //	Added By exafort for zerto TS-10444
            set<id> severeAccoutIdCheck = new set<id>();
            for( Case c : newList){
                //This map creation is for PSM cases which need check on the account.
                if(c.AccountId != null && c.ParentId == null){
                    if(!mapOfCases.containsKey(c.Id))
                        mapOfCases.put(c.Id, c);
                }

                if(c.casePachinkoCaseType__c != '' && c.casePachinkoCaseType__c != null){ // check for null{  
                    pachinkoCaseTypes.add(c.casePachinkoCaseType__c);
                    caseList.add(c);
                }

                //Added by exafort for TS-6417,TS-8404 and TS-8401 on Aug 04-2021
                Id opsCaseRecordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId();
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                if(c.CaseDocket__c != null && opsCaseRecordTypeId1 == c.RecordTypeId && (c.RMAmapped__c != null ||
                                                                                         c.CaseMapping__c !=null)){
                                                                                             ID docketid = c.CaseDocket__c;
                                                                                             Case_Docket__c cdr = CaseUtility.caseDocketRecMap.get(docketid);
                                                                                             if(cdr!= null && !cdr.cddonotupdateparentcase__c){
                                                                                                 Casecomment newcomment = New Casecomment();
                                                                                                 newcomment.CommentBody ='*** RELATED '+ c.caseBUteam__c +' CASE CREATED ('+ c.casePachinkoCaseType__c +':'+c.CaseNumber+')\n'
                                                                                                     +baseUrl+'/'+c.Id+'\n'+'\n'+c.Subject;
                                                                                                 //'\n'+'\n'+ 'Case #:'+ caseToProcess.CaseNumber;
                                                                                                 newcomment.ParentId = c.CaseMapping__c;
                                                                                                 newcomment.IsPublished = false;
                                                                                                 Insertcasecomment.add(newcomment);
                                                                                             }
                                                                                         }
                //Added end
                
                //	Added By exafort for TS-10444
                if(c.AccountId != null){
                    severeAccoutIdCheck.add(c.AccountId); 
                }
            }
            
            //	Added by exafort for TS-10444
            set<id> severeAccountId = CaseUtility.getManagementEscalationWithAccountsInCodeRedSeverity(severeAccoutIdCheck);
            if(severeAccountId != null){
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                for(Case cas : [select id,ContactId,CaseNumber,Account.Name,AccountId,Status,Owner.Email,Owner.Type,
                                Account.Primary_PSM__r.Email,Account.Secondary_PSM__r.Email,Auto_Close__c from case where Id IN :newMap.keySet()]){
                    
                    List<String> toEmailList = CaseUtility.getEmailToAddressFromCaseOfAccountRed(cas);
                    //	Added By Exafort for SFDC-1245
                    if(severeAccountId.contains(cas.AccountId) && toEmailList != null && cas.Auto_Close__c != true){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toEmailList);
                        //	We have used the custom Label to store the template Id to reduce the SOQL Usage.
                        Messaging.SingleEmailMessage renderResult = Messaging.renderStoredEmailTemplate(
                            System.Label.Case_Creation_CodeRed_Escalation_Alert_Template_Id,
                            NULL,
                            cas.id
                        );
                        mail.setSubject(renderResult.getSubject());
                        mail.setPlainTextBody(renderResult.getPlainTextBody());
                        mail.setSaveAsActivity(false); 
                        emailList.add(mail);
                    }  
                }
                Messaging.sendEmail(emailList);
            }
            //End of TS-10444
            //If the PSM cases map is not empty, then fetch the cases 
            //SFDC-320
            if(!mapOfCases.isEmpty()){
                casesForAlert = [SELECT CaseNumber,Subject,Asset.assetSupportExpiredGracePeriodInactive__c,CreatedBy.Name, casePachinkoCaseType__c, Asset.Asset_Type__c, ContactId, Contact.Email, Owner.Name, Alternate_Contact_Name__r.Email,Alternate_Contact_Name__r.Phone, Alternate_Contact_Name__c, Account.Primary_CS_PSM__r.Id, ParentId,
                                        Account.Primary_PSM__r.Id, Account.Primary_CS_PSM__r.Email, Account.Primary_CS_PSM__c, Account.Primary_PSM__c, Account.Primary_PSM__r.Email, RecordType.Name,Contact.iamabot__c,Case_Handling__c,Support_Profile__c,
                                        Account.ACM_Service_Purchased__c,Asset.assetConcierge_Service__c, Account.CS_PSM__c, Account.Support_Provider__c, caseDontSendCaseOpenEmail__c, Case_Type__c, Status, Auto_Open__c,caseProject__c 
                                        FROM Case 
                                        WHERE Id IN: mapOfCases.keyset()];
            }

            /*If the list of cases in PSM cases map exists then run the flow for cases with Record Types "Array Case" and "SSaaS" with these conditions;
                1. Support provider of the account should be null
                2. caseDontSendCaseOpenEmail__c should be false
                3. Case Type should be External
                4. Manually created cases OR Automation cases

                If the Case has alternate contact/Case's account has Primary PSM or Primary CS PSM, then create "Case Team Role" for these users - Check under the Related of Case
                and create a list of emailId of Contact/Alternate contact/Primary PSM/Primary CS PSM

                We will convert this list to array as the Messaging.SingleEmailMessage API needs the array of email Ids for CC addresses
            */
            if(casesForAlert.size()>0){
                //List<String> emailIds = new List<String>();
                //List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
                //List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
                for(Case newCase: casesForAlert){
                    if((newCase.RecordType.Name == 'Array Case' || newCase.RecordType.Name == 'SSaaS') && newCase.Subject != null){
                        if(newCase.Account.Support_Provider__c == null && 
                        !newCase.caseDontSendCaseOpenEmail__c &&
                        newCase.Case_Type__c == 'External' &&
                        (newCase.Status != 'Closed' || (newCase.Auto_Open__c && newCase.Status == 'Closed')) &&
                        !newCase.caseProject__c &&
                        !newCase.Subject.contains('PROBLEM SUBMITTAL GSEM') &&
                        (newCase.Subject == null || !newCase.Subject.contains('Email Loop Protection') || !newCase.Subject.contains('Undelivered Mail Returned to Sender')) &&
                        (newCase.casePachinkoCaseType__c != 'assetrenewalnotice45' || newCase.casePachinkoCaseType__c != 'assetrenewalnotice90' ) &&
                        (newCase.Asset.assetSupportExpiredGracePeriodInactive__c == false || (newCase.Asset.assetSupportExpiredGracePeriodInactive__c == true && newCase.CreatedBy.Name != 'Nimble Support'))
                        ){
                            //This logic for creating Alternate contact Case Team Member works for both PSM and Non PSM
                            if(newCase.Alternate_Contact_Name__c !=null && newCase.Alternate_Contact_Name__r.Email != null){
                                System.debug('Alternate Contact passed ==line 383');
                                CaseTeamMember alternateContact = new CaseTeamMember();
                                alternateContact.MemberId = newCase.Alternate_Contact_Name__r.Id;
                                alternateContact.ParentId = newCase.Id;
                                alternateContact.TeamRoleId = caseTeamRolesMap.get('Alternate Contact Name');
                                ctmSet.add(alternateContact);   
                                //emailIds.add(newCase.Alternate_Contact_Name__r.Email);
                            }//SFDC-320
                            if((newCase.Asset.assetConcierge_Service__c && newCase.Account.CS_PSM__c && newCase.Account.Primary_PSM__c != null && newCase.Account.Primary_CS_PSM__c != null) && (newCase.Account.Primary_PSM__c == newCase.Account.Primary_CS_PSM__c)){ 
                                CaseTeamMember ctmpsm = new CaseTeamMember();
                                ctmpsm.MemberId = newCase.Account.Primary_PSM__r.Id;
                                ctmpsm.ParentId = newCase.Id;
                                ctmpsm.TeamRoleId = caseTeamRolesMap.get('Proactive Support Manager');
                                ctmSet.add(ctmpsm); 
                                //emailIds.add(newCase.Account.Primary_PSM__r.Email); 
                                createdCaseTeamRole = true;
                            }//SFDC-320
                            if((newCase.Asset.assetConcierge_Service__c || newCase.Account.CS_PSM__c) && !createdCaseTeamRole){
                                if(newCase.Asset.assetConcierge_Service__c && newCase.Account.Primary_PSM__c != null && newCase.Account.Primary_PSM__r.Email != null){
                                    CaseTeamMember ctmpsm = new CaseTeamMember();
                                    ctmpsm.MemberId = newCase.Account.Primary_PSM__r.Id;
                                    ctmpsm.ParentId = newCase.Id;
                                    ctmpsm.TeamRoleId = caseTeamRolesMap.get('Proactive Support Manager');
                                    ctmSet.add(ctmpsm); 
                                    //emailIds.add(newCase.Account.Primary_PSM__r.Email);
                                }
                                if(newCase.Account.CS_PSM__c && newCase.Account.Primary_CS_PSM__c != null && newCase.Account.Primary_CS_PSM__r.Email != null){
                                    CaseTeamMember cspsm = new CaseTeamMember();
                                    cspsm.MemberId = newCase.Account.Primary_CS_PSM__r.Id;
                                    cspsm.ParentId = newCase.Id;
                                    cspsm.TeamRoleId = caseTeamRolesMap.get('Proactive Support Manager');
                                    ctmSet.add(cspsm); 
                                    //emailIds.add(newCase.Account.Primary_CS_PSM__r.Email);
                                }
                            }
                            /*String [] emailsAsArray;
                            createdCaseTeamRole = false;
                            if(newCase.ContactId != null && !newCase.Contact.iamabot__c && newCase.Contact.Email != null){
                                if(emailIds.size() > 0){
                                    emailsAsArray = new String [emailIds.size()];
                                    Integer i = 0;
                                    for (String singleCCEmail: emailIds) {
                                        emailsAsArray[i++] = singleCCEmail;
                                    }
                                }
            
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                message.setTargetObjectId(newCase.ContactId);
                                if(emailIds.size() > 0)
                                    message.setCcAddresses(emailsAsArray);
                                message.setWhatId(newCase.Id); //This is important for the merge fields in template to work
                                message.setToAddresses(new String[] { newCase.Contact.email});
                                
                                //send emails to emailIds with from "salesforce-dev-test@hpe.com" for Sandbox and "hpe-services-storage@hpe.com" for production and template = ArcusTemplate
                                if(newCase.Asset.Asset_Type__c == 'Block Storage' || newCase.Asset.Asset_Type__c == 'File Storage'){
                                    message.setTemplateID(System.Label.Case_Alert_New_Case_to_Arcus_Customers);
                                
                                    
                                    System.debug('###  Case Handling >>> '+newCase.Case_Handling__c);
                                    System.debug('###  Support Profile >>> '+newCase.Support_Profile__c);
                                    System.debug('###  Case Status>>> '+newCase.Status);
                                    System.debug('###  Case Owner>>> '+newCase.Owner.Name);
                                        
                                    if(!isSandbox){
                                        if(newCase.Case_Handling__c != null && newCase.Support_Profile__c != null){
                                            if(newCase.Case_Handling__c.contains('dHCI') && newCase.Support_Profile__c == 'Alletra MP Block' && newCase.Status != 'Closed' && newCase.Owner.Name == 'Support Queue - General'){
                                                String[] toAdd = new String[]{'gsr.pcbe.coe@hpe.com'};
                                                message.setToAddresses(toAdd);
                                                System.debug('### To Addresses >>> '+message.getToAddresses());
                                            }else if(newCase.Case_Handling__c.contains('PCAI') && newCase.Support_Profile__c == 'Alletra MP File' && newCase.Status != 'Closed' && newCase.Owner.Name == 'Support Queue - General' && (!newCase.Subject.contains('SCARECROW HAWK') || !newCase.Subject.equals('Warning: could not send message for past 4 hours') || !newCase.Subject.equals('Returned mail: see transcript for details'))){
                                               String[] toAdd = new String[]{'gsr.pcai.coe@hpe.com'};
                                                message.setToAddresses(toAdd);
                                                System.debug('### To Addresses >>> '+message.getToAddresses()); 
                                            }
                                        }
                                        //setting up from email address on the email message
                                        CaseUtility.addToMapOfOrgWideEmailAddress('hpe-services-storage@hpe.com');
                                        if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey('hpe-services-storage@hpe.com')) {
                                            message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get('hpe-services-storage@hpe.com'));
                                            System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get('hpe-services-storage@hpe.com'));
                                        }
                                        message.setReplyTo('hpe-services-storage@hpe.com');
                                    }else{
                                        if(newCase.Case_Handling__c != null && newCase.Support_Profile__c != null){
                                            if((newCase.Case_Handling__c.contains('dHCI') && newCase.Support_Profile__c == 'Alletra MP Block' && newCase.Status != 'Closed' && newCase.Owner.Name == 'Support Queue - General') ){
                                                String[] toAdd = new String[]{'nimble-support-sfdc@hpe.com'};
                                                message.setToAddresses(toAdd);
                                                System.debug('### To Addresses >>> '+message.getToAddresses());
                                            }else if(newCase.Case_Handling__c.contains('PCAI') && newCase.Support_Profile__c == 'Alletra MP File' && newCase.Status != 'Closed' && newCase.Owner.Name == 'Support Queue - General' && (!newCase.Subject.contains('SCARECROW HAWK') || !newCase.Subject.equals('Warning: could not send message for past 4 hours') || !newCase.Subject.equals('Returned mail: see transcript for details'))){
                                                String[] toAdd = new String[]{'vaddismitha@gmail.com'};
                                                message.setToAddresses(toAdd);
                                                System.debug('### To Addresses >>> '+message.getToAddresses());
                                            }
                                        }
                                        //setting up from email address on the email message
                                        CaseUtility.addToMapOfOrgWideEmailAddress(System.label.FileStorage_OrgWideEmail_Label);
                                        if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey(System.label.FileStorage_OrgWideEmail_Label)) {
                                            message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.FileStorage_OrgWideEmail_Label));
                                            System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.FileStorage_OrgWideEmail_Label));
                                        }
                                        message.setReplyTo(System.label.FileStorage_OrgWideEmail_Label); 
                                    }     
                                }
                                //send emails to emailIds with from "salesforce-dev-test@hpe.com" for Sandbox and "supportcase@nimblestorage.com" for production and template = NonArcusTemplate
                                if(newCase.Asset.Asset_Type__c != 'Block Storage' && newCase.Asset.Asset_Type__c != 'File Storage'){
                                    message.setTemplateID(System.Label.Case_Alert_New_Case_Alert_to_Outside_Contact);
                                    
                                    if(!isSandbox){
                                        //setting up from email address on the email message
                                        CaseUtility.addToMapOfOrgWideEmailAddress('supportcase@nimblestorage.com');
                                        if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey('supportcase@nimblestorage.com')) {
                                            message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get('supportcase@nimblestorage.com'));
                                            System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get('supportcase@nimblestorage.com'));
                                        }
                                        message.setReplyTo('supportcase@nimblestorage.com');
                                    }else{
                                        //setting up from email address on the email message
                                        CaseUtility.addToMapOfOrgWideEmailAddress(System.label.BlockStorage_OrgWideEmail_Label);
                                        if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey(System.label.BlockStorage_OrgWideEmail_Label)) {
                                            message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.BlockStorage_OrgWideEmail_Label));
                                            System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get(System.label.BlockStorage_OrgWideEmail_Label));
                                        }
                                        message.setReplyTo(System.label.BlockStorage_OrgWideEmail_Label);
                                    }
                                }
                                messages.add(message);
                            }  */    
                        }
                    }
                }
                /*try{
                    results = Messaging.sendEmail(messages);
                }catch(EmailException ex){
                    // Add an error for the apex email
                    apexErrors.add(
                        String.format('*** FAILED TO SEND EMAILS ***\n\nException Type: {0}\nException Message: {1}\nStack Trace String: {2}\n\n', new String[]{
                            ex.getTypeName(),
                            ex.getMessage(),
                            ex.getStackTraceString()
                        })
                    );
            
                    System.debug('### Exception Message >>> '+ex.getMessage());
                    System.debug('### Exception StackTraceString >>> '+ex.getStackTraceString());
                }*/

                if(ctmSet.size()> 0){
                    try{
                        insert ctmSet; 
                    }catch(DMLException ex){
                        ex.getStackTraceString();
                    }
                }
            }
            if(caseList.size() > 0)
                CaseUtility.createOutStandingRecomendationOnCaseInsert(caseList, pachinkoCaseTypes);
            //Added by exafort for TS-6417,TS-8404 and TS-8401 on Aug 04-2021
            if(Insertcasecomment.size() > 0){
                insert Insertcasecomment;
            }
            //Added end
        //}
        
    
        //Added on 07/19/2016 - contains validations to close a case - By Azar
        try{
            //if(trigger.isInsert){
                //List<PachinkoCaseTypes__c> lstpachinko = PachinkoCaseTypes__c.getall().values();
                //Commented out this because this was causing duplicate variable issue as scope changed and this variable is not useful 
                //set<string> pachinkoCaseTypes = new set<string>();
                //SFDC-2015 - removing for loop added below code
                
                /*for(PachinkoCaseTypes__c pachinkocodes : lstpachinko)
                {
                    pachinkoCaseTypes.add(pachinkocodes.Code__c);
                }*/
                
                //if(trigger.isAfter && trigger.isInsert){
                    
                    List<Case> caseID = new List<Case>();
                    set<Id> assetId = new set<Id>();
                    set<Id> contactId = new set<Id>();
                    List<CaseComment> newCaseCommentsaddressInvalid = new List<CaseComment>();
                                      
                    List<case> p1AlertCase = new List<case>();
                    
                    for(Case caseLoop : newList){
                        Case myCase = newList[0];
                        
                        assetId.add(caseLoop.AssetId);
                        contactId.add(caseLoop.ContactId);
                        caseID.add(caseLoop);
                        
                    }
                    
                    List<Asset> assetList = new List<Asset>();
                    if(assetId.size() > 0){
                        assetList = [Select id, assetPartShipLastValidatedDatetime__c, System_Name__c, SerialNumber from Asset where Id =: assetId];
                    }
                    List<Contact> contactList = new List<Contact>();
                    if(contactId.size() > 0){
                        contactList = [Select id, FirstName from Contact where Id =: contactId];
                    }               
                    
                    //Added on 8th Dec 2016 - Start - Add case comment if Asset address is last validated 6 months ago
                    
                    for(Case caseLoop : caseID){
                        //if(caseLoop.casePachinkoCaseType__c != null && pachinkoCaseTypes.contains(caseLoop.casePachinkoCaseType__c)){
                        //SFDC-2015
                        if(caseLoop.Support_Profile__c == 'Legacy Nimble'){
                             if(caseLoop.casePachinkoCaseType__c != null && CaseUtility.getPachinkoCodeListFromCustomSettings().contains(caseLoop.casePachinkoCaseType__c)){
                                for(Asset assetLoop : assetList){
                                    if(assetLoop.assetPartShipLastValidatedDatetime__c != null){
                                        Integer noOfDays = Date.valueOf(assetLoop.assetPartShipLastValidatedDatetime__c).daysBetween(system.today());
                                        if(noOfDays >= 180){
                                            for(Contact con : contactList){
                                                // Added by Exafort for SFDC-1947
                                                Id templateId = Label.Case_Shipment_Address_Not_Validated_Template_Id;
                                                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, caseLoop.Id,con.Id);
                                                String renderedBody = mail.getPlainTextBody();
                                                String renderedSubject = mail.getSubject();
                                                //	End of SFDC-1947                                            
                                                CaseComment newCommmant = new CaseComment();
                                                newCommmant.CommentBody = 'Subject: ' + renderedSubject + '\n\n' + renderedBody;
                                                newCommmant.IsPublished = True;
                                                newCommmant.ParentId = caseLoop.Id;
                                                newCaseCommentsaddressInvalid.add(newCommmant);  
                                            }
                                        }
                                    }
                                } 
                            }
                        }
                    }
                    if(newCaseCommentsaddressInvalid.size() > 0){
                        insert newCaseCommentsaddressInvalid;
                    }
                //}
            //}
            
            
            
        }
        catch(Exception e){
            system.debug('Case Trigger - Update - Error Caught '+e.getMessage());
        }
        //CaseUtility.GSEMrunOnce Added by Exafort on 22 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295  
        if(CaseUtility.GSEMrunOnce()){
            //TS-6918 validation on case to close the related Onsite tasks and GSEM's before closing the case - By Vishnu on 14th Feb 2020.
        }
        }
    }
}