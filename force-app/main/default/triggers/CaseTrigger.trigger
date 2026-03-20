/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 01-30-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   10-05-2023   Nagalaxmi Telkar   Initial Version
**/
trigger CaseTrigger on Case (before insert, after insert, after update, before update)
{//System.debug('DEBUG: (CaseTrigger) ===== ENTERED');
    //System.debug('DEBUG: (CaseTrigger) ===== getQueries = ' + Limits.getQueries());
    if(CaseUtility.CASETRIGGER_FLAG )
    {
        
        Map<String, Id> caseTeamRolesMap = new Map<String, Id>(); 
        Map<String, Id> caseTeamRolesMapRunOnce = new Map<String, Id>();
        //Added By Exafort TS-10404 Start 
        Map<Id, Account> accountEntries = new Map<Id, Account>();        
        Set<Id> accountIds = new Set<Id>();
        if(checkRecursive.runOnce()){
            
            for (Case caseToProcess : trigger.new) {
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
        if (Trigger.isBefore && Trigger.isInsert)
        {
            Map<string,Case_Docket__c> caseDocketMap = new Map<string,Case_Docket__c>();
            
            List<Case_Docket__c> cdRecords = New List<Case_Docket__c>();
            if (caseDocketMap == null || caseDocketMap.isEmpty()) {
                //List<Case_Docket__c> cdRecords = [select Id,Name,cdLabel__c,cdCasePriority__c,cdDocInternalURL__c,cdResponsibleBUTeam__c From Case_Docket__c where name like '%e2r%'];
                //Added by exafort for TS-8404 and TS-8401 on Aug 04/2021
                List<Case_Docket__c> caseDocketRecords = [select Id,Name,cdLabel__c,cdCasePriority__c,cdDocInternalURL__c,
                                                          cdResponsibleBUTeam__c,cdDoNotSetParentCaseARF__c,cddonotupdateparentcase__c From Case_Docket__c];
                for(Case_Docket__c cdd : caseDocketRecords){
                    CaseUtility.caseDocketRecMap.put(cdd.id,cdd);
                    if(cdd.Name != null && cdd.Name.contains('e2r')){
                        cdRecords.add(cdd);
                    }
                }
                //Added end
                system.debug('cdRecords'+cdRecords.size());
                system.debug('caseDocketRecMap'+CaseUtility.caseDocketRecMap.size());
                if(!cdRecords.isEmpty()){
                    for(Case_Docket__c cdRec:cdRecords){
                        caseDocketMap.put(cdRec.name,cdRec);
                    }
                }
            }
           /* Moved this to the begining of the trigger to use for TS-10404
            Set<Id> accountIds = new Set<Id>();
            for (Case caseToProcess : trigger.new) 
                accountIds.add(caseToProcess.AccountId);
            
            Map<Id, Account> accountEntries = new Map<Id, Account>([
                SELECT CS_PSM__c,ACM_Service_Purchased__c, Primary_PSM__c, Primary_PSM__r.Email, Primary_CS_PSM__c, Primary_CS_PSM__r.Email FROM Account WHERE Id IN :accountIds
            ]);
            */
            for (Case caseToProcess : trigger.new) {
                //Added by exafort for TS-10388
                caseToProcess.DateTime_First_Available_To_Work__c = null;
                caseToProcess.First_Customer_Contact__c = null;
                caseToProcess.SLAWhenOwnerChangedInMinutes__c = null;
                caseToProcess.Reopened__c = false;
                //End of TS-10388 
                
                if(caseToProcess.Subject != null){
                    caseToProcess.DateTime_First_Available_To_Work__c = system.now();
                } 
                if(caseToProcess.Status == 'New' && (caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId() || caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId())){
                    String emailIds = '';
                    if(caseToProcess.Alternate_Contact_Email__c != null)
                        emailIds += caseToProcess.Alternate_Contact_Email__c  + ','; 
                    Account accountEntry = accountEntries.get(caseToProcess.AccountId);
                    if (accountEntry != null){
                        if(accountEntry.ACM_Service_Purchased__c && accountEntry.Primary_PSM__c != null && accountEntry.Primary_PSM__r.Email != null)
                            emailIds += accountEntry.Primary_PSM__r.Email + ',';
                        if(accountEntry.CS_PSM__c && accountEntry.Primary_CS_PSM__c != null && accountEntry.Primary_CS_PSM__r.Email != null)
                            emailIds += accountEntry.Primary_CS_PSM__r.Email + ',';       
                    }
                    
                    caseToProcess.Additional_CC_PSM__c = emailIds;      
                }
            }
            for (Case caseToProcess : Trigger.new){
                //Added By Ntelkar for TS-9926
                if(caseToProcess.caseIsThisCaseRelatedToANimbleProduct__c != null)
                    caseToProcess.Is_this_a_Storage_issue__c = caseToProcess.caseIsThisCaseRelatedToANimbleProduct__c;
                  
                if(caseToProcess.isclone()) {
                    //MW:::TS-10277:::Setting IsEscalated to false if a case is being cloned
                    if(caseToProcess.IsEscalated) {
                        caseToProcess.IsEscalated = false;
                    }
                    if(caseToProcess.caseEscalationType__c != null) {
                        caseToProcess.caseEscalationType__c = null;
                    }
                    //Added by Mulpuri for TS-9908 on 6/8/23
                    if(caseToProcess.DCE_Sync__c ){
                        //system.debug('+++++isclone process : ' +caseToProcess.DCE_Sync__c); 
                            //In Salesforce, when trying to clone records, the values of fields which are not added to the page 
                            //layout are not copied over to the newly created cloned record.
                        caseToProcess.DCE_Sync__c = False;
                        //caseToProcess.Sub_Status__c = '--None--';
                    }
                }
                  
                //Added by Exafort for TS-4483
                if(caseToProcess.casePlanOfAction__c != null){
                    caseToProcess.Plan_of_Action_Updated__c = system.now();
                    system.debug('Entered to insert the date time in plan of action');
                }
                //End of TS-4483
                //Added by exafort on 06/11 for TS-6417
                if(caseToProcess.RMAmapped__c != null){
                    caseToProcess.CaseMapping__c = caseToProcess.OPSCaseRMAMappedCase__c;
                }
                //getting the recordtype id for the OPS case and comapring with the exisitng case record type.
                if(caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId()){
                    if(caseDocketMap.get(caseToProcess.Origin) != null){
                        Case_Docket__c cdmatchedRec = caseDocketMap.get(caseToProcess.Origin);
                        //updating case details from the matched case docket.
                        caseToProcess.Origin = 'Email';
                        caseToProcess.Priority = cdmatchedRec.cdCasePriority__c;
                        caseToProcess.casePachinkoCaseType__c = cdmatchedRec.Name;
                        caseToProcess.caseCaseSummary__c = cdmatchedRec.cdLabel__c;
                        caseToProcess.Instructions__c =  cdmatchedRec.cdDocInternalURL__c;
                        caseToProcess.caseBUteam__c = cdmatchedRec.cdResponsibleBUTeam__c;
                        caseToProcess.E2RProcessedMessage__c = 'Success';
                        if(caseToProcess.SuppliedEmail != null || caseToProcess.SuppliedName != null){
                            caseToProcess.ContactId = createContactForOpsCase.insertOpsCaseContact(caseToProcess.SuppliedEmail,caseToProcess.SuppliedName);
                        }else{
                            caseToProcess.E2RProcessedMessage__c = 'Error creating contact.';
                        }
                    }else{
                        caseToProcess.E2RProcessedMessage__c = 'Unable to fecth/find e2r entries in case docket.';
                    }
                }
                
                 else if((caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId() || caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId()) &&
                        caseToProcess.Origin =='Web' && caseToProcess.Priority!='P2' && caseToProcess.Outage__c){
                            //Case Priority change based on Outage field is True or not JIRA Ticket TS-10172 Added by Bharath 09/30/2023
                            //BM 07/17/24: Case Priority set to P2 SFDC-463
                            caseToProcess.Priority='P2';
                            caseToProcess.Priority_High_Watermark__c='P2';
                            caseToProcess.Severity__c ='Critical - Degraded';
                            
                 }
                 /* Start TS-10245 Mulpuri 11/2/2023*/
                 if(caseToProcess.Origin =='Web' && UserInfo.getName() == 'DCE Integration API User' ){
                    caseToProcess.casePachinkoCaseType__c='hpesccase'; 
                 }
                 //End
                 if(caseToProcess.Origin =='Web'){
                     if(!String.isBlank(caseToProcess.Severity__c)){
                        if(caseToProcess.Severity__c == 'Critical')
                            caseToProcess.Priority = 'P1';
                        else if(caseToProcess.Severity__c == 'Critical - Degraded')
                            caseToProcess.Priority = 'P2';
                        else if(caseToProcess.Severity__c == 'Non-Critical')
                            caseToProcess.Priority = 'P3';
                        else if(caseToProcess.Severity__c == 'Low Priority')
                            caseToProcess.Priority = 'P4';
                    }if(!String.isBlank(caseToProcess.Priority)){
                        if(caseToProcess.Priority == 'P1')
                            caseToProcess.Severity__c = 'Critical';
                        else if(caseToProcess.Priority == 'P2')
                            caseToProcess.Severity__c = 'Critical - Degraded';
                        else if(caseToProcess.Priority == 'P3')
                            caseToProcess.Severity__c = 'Non-Critical';
                        else if(caseToProcess.Priority == 'P4')
                            caseToProcess.Severity__c = 'Low Priority';
                    }
                 }
                 
                 
                if (caseToProcess.caseEscalationType__c == null){
                    caseToProcess.caseEscalationType__c = 'Not Escalated';
                }
                Pattern ptoPattern = Pattern.compile('\\b(?i)pto\\b');
                if (caseToProcess.subject != null &&
                    (caseToProcess.subject.containsIgnoreCase('Out of office' )    ||
                     caseToProcess.subject.containsIgnoreCase('Automatisch antwoord' )        ||
                     caseToProcess.subject.containsIgnoreCase('Automatisch' )         ||
                     caseToProcess.subject.containsIgnoreCase('Absence Re' )          ||
                     caseToProcess.subject.containsIgnoreCase('Automatische Antwort' )    ||
                     caseToProcess.subject.containsIgnoreCase('Réponse Automatique' )     ||
                     caseToProcess.subject.containsIgnoreCase('Autosvar' )                ||
                     caseToProcess.subject.containsIgnoreCase('außer haus' )              ||
                     caseToProcess.subject.containsIgnoreCase('Absence du bureau' )       ||
                     caseToProcess.subject.containsIgnoreCase('OOO')                ||
                     caseToProcess.subject.containsIgnoreCase('out of the office' ) ||
                     //caseToProcess.subject.containsIgnoreCase('PTO')              ||
                     ptoPattern.matcher(caseToProcess.subject).find()               ||
                     caseToProcess.subject.containsIgnoreCase('Auto Reply' )        ||
                    // caseToProcess.subject.containsIgnoreCase('[Email Loop Protection]' )        ||
                    // caseToProcess.subject.containsIgnoreCase('Email Loop Protection' ) ||
                     caseToProcess.subject.containsIgnoreCase('Auto Response')      ||
                     caseToProcess.subject.containsIgnoreCase('[Auto-Reply]' )      ||
                     caseToProcess.subject.containsIgnoreCase('[Out of office]')    ||
                     caseToProcess.subject.containsIgnoreCase('Out-of-office' )     ||
                     caseToProcess.subject.containsIgnoreCase('auto-response')      ||
                     caseToProcess.subject.containsIgnoreCase('[Out-of-office]' )   ||
                     caseToProcess.subject.containsIgnoreCase('autoresponse RE')    ||
                     caseToProcess.subject.containsIgnoreCase('autoreply')          ||
                     caseToProcess.subject.containsIgnoreCase('autoresponse')       ||
                     (caseToProcess.subject.containsIgnoreCase('vacation') && !caseToProcess.account_name__c.containsIgnoreCase('vacation')) ||
                     caseToProcess.subject.containsIgnoreCase('auto response')      ||
                     caseToProcess.subject.containsIgnoreCase('Out of Office' )     ||
                     caseToProcess.subject.containsIgnoreCase('Automatic reply')    ||
                     caseToProcess.subject.containsIgnoreCase('Delivery delayed:')  ||     
                     caseToProcess.subject.containsIgnoreCase('Delivery delayed:New case comment notification.') ||
                     caseToProcess.subject.containsIgnoreCase('[알림] 휴가로 인한 부재')    ||
                     caseToProcess.subject.containsIgnoreCase('[Email Loop Protection]')||
                     caseToProcess.subject.containsIgnoreCase('Email Loop Protection') ||
                     caseToProcess.subject.containsIgnoreCase('Undeliverable')))
                {// Email subject is a out-of-office type, so don't create the case.
                    caseToProcess.addError('Out-of-office type subjects are not allowed to create new cases.');
                    // }
                    // else
                    // {// No Errors, so allow case to be created.
                    // }
                }
                
                // Added by Exafort TS-10064 part 1 start
                id supportQueueGeneralId = '00G80000001ucU1EAI';
                if((Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId() == caseToProcess.RecordTypeId ||
                    Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId() == caseToProcess.RecordTypeId ||
                    Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId() == caseToProcess.RecordTypeId) 
                    && caseToProcess.OwnerId == supportQueueGeneralId ){
                    caseToProcess.DateTime_First_Available_To_Work__c = System.now();
                }
                //End of TS-10064
            }
        }
        
        //Added by Exafort for TS-4483
        if (Trigger.isBefore && Trigger.isUpdate){
            String userId;
            String supportQueueGeneral;
            String supportQueueAutomatic;
            //TS-9778
            if(!Test.isRunningTest()){
                //userId = [SELECT Id FROM User WHERE Alias = 'NSForce' LIMIT 1].Id;
                userId ='00580000003xTOl';
                //supportQueueGeneral = [SELECT Id FROM Group WHERE Name = 'Support Queue - General' LIMIT 1].Id;
                supportQueueGeneral = '00G80000001ucU1EAI';
                //supportQueueAutomatic = [SELECT Id FROM Group WHERE Name = 'Support Queue - Automatic' LIMIT 1].Id;
                supportQueueAutomatic='00G34000003rkEyEAI';
            }
            Set<String> newVersionSet = New Set<String>();// SFDC-307
            for (Case caseToProcess : Trigger.new){
                case oldCaseRec = Trigger.oldMap.get(caseToProcess.id);
                
                //Added by Ntelkar for TS-9778 and TS-10352
                if(!Test.isRunningTest()){
                    if(userId != null && supportQueueGeneral != null && supportQueueAutomatic != null){
                        if(oldCaseRec.OwnerId == supportQueueAutomatic  && UserInfo.getUserId() == userId && oldCaseRec.Status != caseToProcess.Status && caseToProcess.Status == 'Open' &&  caseToProcess.Auto_Open__c)
                        caseToProcess.OwnerId = supportQueueGeneral ;
                    }if(userId != null && supportQueueGeneral != null){
                        if(oldCaseRec.OwnerId == supportQueueGeneral && oldCaseRec.OwnerId != caseToProcess.OwnerId &&  oldCaseRec.Status == 'Handover'){
                            caseToProcess.Status = 'Open';
                            System.debug('Handover status is changed to Open');
                        }   
                    }
                }
                // Added by Exafort
                // Checks if the case ownerId is changed and also if the new case owner is current login user
                // Update the "Accepted By" field with the new case owner name
                system.debug('caseToProcess.OwnerId : ' + caseToProcess.OwnerId);
                system.debug('oldCaseRec.OwnerId : ' + oldCaseRec.OwnerId);
                if(caseToProcess.OwnerId != oldCaseRec.OwnerId && caseToProcess.OwnerId == UserInfo.getUserId()){
                    caseToProcess.Last_Accepted_By__c = UserInfo.getName();
                }
                // End
                
                if(oldCaseRec.casePlanOfAction__c != caseToProcess.casePlanOfAction__c){
                    system.debug('Entered to update the case plan of action');
                    caseToProcess.Plan_of_Action_Updated__c = system.now();
                }
                string NIMBLE_SUPPORT_USER_ID = '00580000003xTOlAAM';
                system.debug('Login User --> ' + UserInfo.getUserId());
                if(UserInfo.getUserId() != NIMBLE_SUPPORT_USER_ID && caseToProcess.E2CP__Most_Recent_Public_Comment__c != oldCaseRec.E2CP__Most_Recent_Public_Comment__c){
                    system.debug('New Comment --> ' + caseToProcess.E2CP__Most_Recent_Public_Comment__c);
                    system.debug('OLD Comment --> ' + oldCaseRec.E2CP__Most_Recent_Public_Comment__c);
                    caseToProcess.Last_Public_Comment__c = system.now();
                }
                /* Start TS-10254 Mulpuri 11/2/2023*/
                if(caseToProcess.Status =='Awaiting Customer' && oldCaseRec.Status != caseToProcess.Status && String.isBlank(caseToProcess.Sub_Status__c) )
                {
                    caseToProcess.Sub_Status__c ='Complete Action Plan'; 
                }
                //End
                
                 // Added by Exafort TS-10063 and TS-10480 start
                Case caseToProcessOld = trigger.oldmap.get(caseToProcess.id);
                //  Case is being reopened
                if(
                    (caseToProcess.status != 'Closed' && caseToProcessOld.status == 'Closed') || 
                    (caseToProcess.status != 'Closed(Duplicate)' && caseToProcessOld.status == 'Closed(Duplicate)') ||
                    (caseToProcess.status != 'Merged' && caseToProcessOld.status == 'Merged'))
                {
                        caseToProcess.Reopened__c = true;
                        String currentOwnerId = caseToProcess.OwnerId;
                        
                        if(currentOwnerId.substring(0, 3) == '00G'){
                            // Resetting
                            caseToProcess.DateTime_First_Available_To_Work__c = System.now();
                        }
                    }
                // End of TS-10063 and TS-10480 
                
                // Added by Exafort TS-10064 part 2 start
                id supportQueueGeneralId = '00G80000001ucU1EAI';
                if((Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId() == caseToProcess.RecordTypeId || 
                    Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId() == caseToProcess.RecordTypeId || 
                    Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId() == caseToProcess.RecordTypeId) &&
                   (caseToProcessOld.OwnerId != caseToProcess.OwnerId) && (caseToProcess.OwnerId == supportQueueGeneralId)){
                       caseToProcess.DateTime_First_Available_To_Work__c = System.now();
                   }
                //End of TS-10064
                
                // Added by Exafort for TS-10065
                // Check's if its the first public comment inserted for the case
                // Then updated the case first customer contact field
                if(caseToProcess.Last_Public_Comment__c != null && caseToProcessOld.Last_Public_Comment__c == null && caseToProcess.First_Customer_Contact__c == null){
                    caseToProcess.First_Customer_Contact__c = caseToProcess.Last_Public_Comment__c;
                }
                // End of TS-10065
                // SFDC-307 Start [Checking if the Version is changed and Storing the Version in a set]
                if(oldCaseRec.Nimble_Version__c != caseToProcess.Nimble_Version__c){
                    newVersionSet.Add(caseToProcess.Nimble_Version__c);
                }
                // SFDC-307 End
            }
            // SFDC-307 Start            
            Map<string,string> versionWithSupportProfile = new Map<string,string>(); 
            if(newVersionSet.size() > 0){
                //  Storing the Version and Support Profile of the changed version in a Map
                For(Support_Profile_Version__c Versions : [select id, Support_Profile__c, Version__c from Support_Profile_Version__c where Version__c in:newVersionSet and IsActive__c = true]){
                    versionWithSupportProfile.put(Versions.Version__c, Versions.Support_Profile__c);
                }
                string apiUsers = system.label.CaseVersionAPIUsers;
                List<string> apiUsersList = apiUsers.split(',');
                system.debug('apiUsersList -'+ apiUsersList);
                for(Case cas:Trigger.New){
                    case oldCaseRec = Trigger.oldMap.get(cas.id); 
                    system.debug('UserInfo.getUserId()----->' + UserInfo.getUserId());
                    if((oldCaseRec.Nimble_Version__c != cas.Nimble_Version__c && !apiUsersList.contains(UserInfo.getUserId()) )){
                        String versionSupportProfiles = versionWithSupportProfile.get(cas.Nimble_Version__c);
                        string caseSupportProfile = cas.Support_Profile__c;
                        
                        //  If no, support profile available, default to 'Legacy Nimble'
                        if( cas.Support_Profile__c == null){
                            caseSupportProfile = 'Legacy Nimble';
                        }
                        
                        // Checking if the new version is available in the versionWithSupportProfile Map
                        if(versionWithSupportProfile.ContainsKey(cas.Nimble_Version__c)){
                            
                            if(versionSupportProfiles == null || !versionSupportProfiles.Contains(caseSupportProfile)){
                                //  The selected version is not compatible with the support profile
                                cas.addError('Provided Software version is not available for Support profile: ' + caseSupportProfile);
                            }
                            
                        }else{
                            //  This error Message is for a scenario where the Version is not availabe as a record in the Support Profile - Version object
                            cas.addError('Provided Software version is not available for Support profile: ' + caseSupportProfile);
                        }
                    }
                }
            }
            //  SFDC-307 End 
            
        }
        
        //End of TS-4483
        //Added by Pradeep.
        if(Trigger.isAfter && Trigger.isInsert){
            List<CaseComment> Insertcasecomment = new List<CaseComment>();//added by exafort for TS-6417,TS-8404,TS-8401 on 05/03/21
            set<String> pachinkoCaseTypes = new set<String> ();
            List<Case> caseList = new List<Case>();
            Map<Id, Case> mapOfCases = new Map<Id,Case>();
            Boolean createdCaseTeamRole = false;
            List<Case> casesForAlert = new List<Case>();
            List<CaseTeamMember> ctmSet = new List<CaseTeamMember>();
            List<String> apexErrors = new List<String>();
            Boolean isSandbox = CaseUtility.runningInASandbox;
            
            for( Case c : trigger.new){
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
            }
            
            //If the PSM cases map is not empty, then fetch the cases 
            //SFDC-320
            if(!mapOfCases.isEmpty()){
                casesForAlert = [SELECT CaseNumber,Subject, Asset.Asset_Type__c, ContactId, Contact.Email, Alternate_Contact_Name__r.Email,Alternate_Contact_Name__r.Phone, Alternate_Contact_Name__c, Account.Primary_CS_PSM__r.Id, ParentId,
                                        Account.Primary_PSM__r.Id, Account.Primary_CS_PSM__r.Email, Account.Primary_CS_PSM__c, Account.Primary_PSM__c, Account.Primary_PSM__r.Email, RecordType.Name,Contact.iamabot__c,
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
                List<String> emailIds = new List<String>();
                List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
                List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
                for(Case newCase: casesForAlert){
                    if((newCase.RecordType.Name == 'Array Case' || newCase.RecordType.Name == 'SSaaS') && newCase.Subject != null){
                        if(newCase.Account.Support_Provider__c== null && !newCase.caseDontSendCaseOpenEmail__c && newCase.Case_Type__c == 'External' && (newCase.Status != 'Closed' || (newCase.Auto_Open__c && newCase.Status== 'Closed')) && !newCase.caseProject__c && !newCase.Subject.contains('PROBLEM SUBMITTAL GSEM')){
                            //This logic for creating Alternate contact Case Team Member works for both PSM and Non PSM
                            if(newCase.Alternate_Contact_Name__c !=null && newCase.Alternate_Contact_Name__r.Email != null){
                                System.debug('Alternate Contact passed ==line 383');
                                CaseTeamMember alternateContact = new CaseTeamMember();
                                alternateContact.MemberId = newCase.Alternate_Contact_Name__r.Id;
                                alternateContact.ParentId = newCase.Id;
                                alternateContact.TeamRoleId = caseTeamRolesMap.get('Alternate Contact Name');
                                ctmSet.add(alternateContact);   
                                emailIds.add(newCase.Alternate_Contact_Name__r.Email);
                            }//SFDC-320
                            if((newCase.Asset.assetConcierge_Service__c && newCase.Account.CS_PSM__c && newCase.Account.Primary_PSM__c != null && newCase.Account.Primary_CS_PSM__c != null) && (newCase.Account.Primary_PSM__c == newCase.Account.Primary_CS_PSM__c)){
                                CaseTeamMember ctmpsm = new CaseTeamMember();
                                ctmpsm.MemberId = newCase.Account.Primary_PSM__r.Id;
                                ctmpsm.ParentId = newCase.Id;
                                ctmpsm.TeamRoleId = caseTeamRolesMap.get('Proactive Support Manager');
                                ctmSet.add(ctmpsm); 
                                emailIds.add(newCase.Account.Primary_PSM__r.Email); 
                                createdCaseTeamRole = true;
                            }//SFDC-320
                            if((newCase.Asset.assetConcierge_Service__c || newCase.Account.CS_PSM__c) && !createdCaseTeamRole){
                                if(newCase.Asset.assetConcierge_Service__c && newCase.Account.Primary_PSM__c != null && newCase.Account.Primary_PSM__r.Email != null){
                                    CaseTeamMember ctmpsm = new CaseTeamMember();
                                    ctmpsm.MemberId = newCase.Account.Primary_PSM__r.Id;
                                    ctmpsm.ParentId = newCase.Id;
                                    ctmpsm.TeamRoleId = caseTeamRolesMap.get('Proactive Support Manager');
                                    ctmSet.add(ctmpsm); 
                                    emailIds.add(newCase.Account.Primary_PSM__r.Email);
                                }
                                if(newCase.Account.CS_PSM__c && newCase.Account.Primary_CS_PSM__c != null && newCase.Account.Primary_CS_PSM__r.Email != null){
                                    CaseTeamMember cspsm = new CaseTeamMember();
                                    cspsm.MemberId = newCase.Account.Primary_CS_PSM__r.Id;
                                    cspsm.ParentId = newCase.Id;
                                    cspsm.TeamRoleId = caseTeamRolesMap.get('Proactive Support Manager');
                                    ctmSet.add(cspsm); 
                                    emailIds.add(newCase.Account.Primary_CS_PSM__r.Email);
                                }
                            }
                            String [] emailsAsArray;
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
                                
                                    if(!isSandbox){
                                        //setting up from email address on the email message
                                        CaseUtility.addToMapOfOrgWideEmailAddress('hpe-services-storage@hpe.com');
                                        if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey('hpe-services-storage@hpe.com')) {
                                            message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get('hpe-services-storage@hpe.com'));
                                            System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get('hpe-services-storage@hpe.com'));
                                        }
                                        message.setReplyTo('hpe-services-storage@hpe.com');
                                    }else{
                                        //setting up from email address on the email message
                                        CaseUtility.addToMapOfOrgWideEmailAddress('salesforce-dev-test2@hpe.com');
                                        if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey('salesforce-dev-test2@hpe.com')) {
                                            message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get('salesforce-dev-test2@hpe.com'));
                                            System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get('salesforce-dev-test2@hpe.com'));
                                        }
                                        message.setReplyTo('salesforce-dev-test2@hpe.com'); 
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
                                        CaseUtility.addToMapOfOrgWideEmailAddress('salesforce-dev-test@hpe.com');
                                        if (CaseUtility.orgWideEmailAddressIdsFromAddress.containsKey('salesforce-dev-test@hpe.com')) {
                                            message.setOrgWideEmailAddressId(CaseUtility.orgWideEmailAddressIdsFromAddress.get('salesforce-dev-test@hpe.com'));
                                            System.debug('### OrgWideEmailAddressId >>> '+CaseUtility.orgWideEmailAddressIdsFromAddress.get('salesforce-dev-test@hpe.com'));
                                        }
                                        message.setReplyTo('salesforce-dev-test@hpe.com');
                                    }
                                }
                                messages.add(message);
                            }      
                        }
                    }
                }
                try{
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
                }

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
        }
        if(Trigger.isAfter && Trigger.isUpdate){
            //Ntelkar added changes for TS-9823
            
            List<Case> closedCases = new List<Case>();
            Set<Id> alternateContactCases1 = new Set<Id>();
            for(Integer i = 0; i<Trigger.new.size(); i++){
                Case nCase = Trigger.new.get(i);
                Case oCase = Trigger.old.get(i);
                if((nCase.Status == 'Closed' || nCase.Status == 'Closed(Duplicate)') && 
                   nCase.Status != oCase.Status &&
                   (UserInfo.getUserId() == CaseUtility.NIMBLE_SUPPORT_USER_ID || Test.isRunningTest())){
                   
                   closedCases.add(nCase);
                }
                
                if(oCase.Alternate_Contact_Name__c != nCase.Alternate_Contact_Name__c ) {
                    alternateContactCases1.add(nCase.Id);
                }
            }
            if(closedCases.size() > 0)
            CaseUtility.validateRecommendationOnCaseClose(closedCases);
        
            List<CaseTeamMember> ctmSet = new List<CaseTeamMember>();
            if(alternateContactCases1.size()>0) {
                List<Case> caseList = [SELECT Id, Alternate_Contact_Name__r.Id FROM Case WHERE Id IN :alternateContactCases1];
                
                for(Case cse : caseList){
                    CaseTeamMember ctm1 = new CaseTeamMember();
                    ctm1.MemberId = cse.Alternate_Contact_Name__r.Id;
                    ctm1.ParentId = cse.Id;
                    ctm1.TeamRoleId = caseTeamRolesMap.get('Alternate Contact Name');
                    ctmSet.add(ctm1); 
                }  
            } 
            if(!ctmSet.isEmpty()){
                try{
                    Database.insert(ctmSet, false);//End of TS-9823
                }catch(DMLException dml){
                    System.debug(dml);
                }
            }   
        }
        
        // The below code will send survey emails when a Case is closed
        // (if other criteria is also met), and update Contacts as needed.
       /* if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
        {
            //Added by Pradeep to avoid SOQL exception 10/6/2016
            List<Case> cList = new List<Case>();
            for(Integer i = 0; i < Trigger.new.size(); i++)
            {
                Case nC = Trigger.new.get(i);
                if((Trigger.isInsert && nC.Status == 'Closed') ||
                   Trigger.isUpdate && nC.Status == 'Closed' && Trigger.old.get(i).Status <> 'Closed')
                {
                    cList.add(nC);
                }
            }
            if(cList.size() > 0)
            {
                List<EmailTemplate> emailTemplates;
                Id emailTemplateId;
                Set<Id> relatedAccountIds = new Set<Id>();
                Set<Id> relatedContactIds = new Set<Id>();
                Account relatedAccount;
                Contact relatedContact;
                Set<Id> contactIdsToReceiveSurvey = new Set<Id>();
                List<Map<String, Id>> surveyIdsList = new List<Map<String, Id>>();
                Map<String, Id> surveyIdsMap;
                List<Contact> contactsToUpdate;
                Boolean statusChangedToClosed;
                //Added by Exafort for TS-7759
                Id accId = ParticularAccountId__c.getInstance().Account_id__c;
                string infoContactEmail;
                Id Inosightemplate = Infosight_Portal_Customer_SurveyTemplate__c.getInstance().Infosight_Email_Template__c;                
                
                // Get the ID of the email template for the survey
                emailTemplates = [SELECT Id FROM EmailTemplate WHERE Name = 'Survey: Support Closed Case 01'];
                
                if (emailTemplates.size() <> 1)
                {System.debug('DEBUG: (CaseTrigger) Failed to find one email template with name = "Survey: Support Closed Case 01"');
                 System.debug('DEBUG: (CaseTrigger) emailTemplates size <> 1; size = ' + emailTemplates.size());
                 return;
                }
                emailTemplateId = emailTemplates[0].Id;
                // Retrieve the related Account and Contact objects for the Cases to be processed
                for (Case caseToProcess : Trigger.new)
                {  
                    if(caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId()){
                        infoContactEmail = caseToProcess.Infosight_Contact_Email__c; ////Added by Exafort for TS-7759
                    }
                    //if(caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId()){ //Added by Exafort for TS-7759
                    if (caseToProcess.accountId != null) {relatedAccountIds.add(caseToProcess.accountId);} else {continue;}
                    if (caseToProcess.contactId != null) {relatedContactIds.add(caseToProcess.contactId);} else {continue;}
                    //}
                    //infoContactEmail = caseToProcess.Infosight_Contact_Email__c; ////Added by Exafort for TS-7759
                }
                system.debug('infoContactEmail' + infoContactEmail);
                
                //System.debug('DEBUG: (caseTrigger) relatedAccountIds = ' + relatedAccountIds);
                //System.debug('DEBUG: (caseTrigger) relatedContactIds = ' + relatedContactIds);
                
                Map<Id, Account> relatedAccountsMap = new Map<Id, Account>([SELECT Id, Support_Provider__c FROM Account WHERE Id IN :relatedAccountIds]);
                Map<Id, Contact> relatedContactsMap = new Map<Id, Contact>([SELECT Id, contactLastSurveySentDate__c, Email FROM Contact WHERE Id IN :relatedContactIds]);
                //Added by Exafort for TS-7759
                Map<Id, Account> relatedAccountsInfosightMap = new Map<Id, Account>([SELECT Id, Support_Provider__c FROM Account WHERE Id = :accId]);
                Map<Id, Contact> relatedContactsInfosightMap = new Map<Id, Contact>([SELECT Id, contactLastSurveySentDate__c, Email FROM Contact WHERE AccountId = :accId and Email = :infoContactEmail]);
                system.debug('relatedAccountsInfosightMap' + relatedAccountsInfosightMap);
                system.debug('relatedContactsInfosightMap' + relatedContactsInfosightMap);
                //System.debug('DEBUG: (caseTrigger) relatedAccountsMap = ' + relatedAccountsMap);
                //System.debug('DEBUG: (caseTrigger) relatedContactsMap = ' + relatedContactsMap);
                
                // Iterate through each Case to see if a survey should be sent
                for (Case caseToProcess : Trigger.new)
                {// If Case is missing a related Account or Contact, skip it
                    System.debug('DEBUG: (caseTrigger) ===== PROCESSING INDIVIDUAL CASE =====');
                    System.debug('DEBUG: (caseTrigger) caseToProcess.accountId = ' + caseToProcess.accountId);
                    System.debug('DEBUG: (caseTrigger) caseToProcess.contactId = ' + caseToProcess.contactId);
                    if((caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId()) ||
                       (caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId() && caseToProcess.Infosight_Account__c == null && caseToProcess.Infosight_Contact_Name__c == null)){ //Added by Exafort for TS-7759
                           if (caseToProcess.accountId == null || caseToProcess.contactId == null)
                           {System.debug('DEBUG: (caseTrigger) accountId or contactId is null - skipping this case');
                            continue;
                           }
                           
                           relatedAccount = relatedAccountsMap.get(caseToProcess.accountId);
                           relatedContact = relatedContactsMap.get(caseToProcess.contactId);
                           
                           System.debug('DEBUG: (caseTrigger) relatedAccount.id = ' + relatedAccount.id);
                           System.debug('DEBUG: (caseTrigger) relatedContact.id = ' + relatedContact.id);
                           
                           // Evaluate if Case Status was changed to Closed, either by
                           // it being set to Closed on new case creation, or changed
                           // to Closed from another value if existing case was edited.
                           // Only Cases with Status changed to Closed will receive a survey.
                           statusChangedToClosed = false;
                           if ((Trigger.isInsert && caseToProcess.Status == 'Closed') ||
                               (Trigger.isUpdate && caseToProcess.Status == 'Closed' && Trigger.oldMap.get(caseToProcess.Id).Status <> 'Closed'))
                           {statusChangedToClosed = true;
                           }
                           
                           // Survey is sent if following criteria is met:
                           //   Case Type is External
                           //   Case is not Auto Closed
                           //   Case Status was changed to Closed
                           //   Case Owner is a User (not a Queue); User IDs always start with 005
                           //   Account Support Provider is blank/null (indicating Nimble was the provider)
                           //   Contact has not already been marked to receive a survey earlier in this batch of cases
                           //   Contact Email does not contain nimblestorage.com
                           //   Contact Last Survey Sent Date is blank/null or more than 30 days ago
                           System.debug('DEBUG: (CaseTrigger) caseToProcess.Case_Type__c = ' + caseToProcess.Case_Type__c);
                           System.debug('DEBUG: (CaseTrigger) caseToProcess.Auto_Close__c = ' + caseToProcess.Auto_Close__c);
                           System.debug('DEBUG: (CaseTrigger) statusChangedToClosed = ' + statusChangedToClosed);
                           System.debug('DEBUG: (CaseTrigger) caseToProcess.OwnerId = ' + caseToProcess.OwnerId);
                           System.debug('DEBUG: (CaseTrigger) String.valueof(caseToProcess.OwnerId).startsWith(005) = ' + String.valueof(caseToProcess.OwnerId).startsWith('005'));
                           System.debug('DEBUG: (CaseTrigger) relatedAccount.Support_Provider__c = ' + relatedAccount.Support_Provider__c);
                           System.debug('DEBUG: (CaseTrigger) caseToProcess.contactId = ' + caseToProcess.contactId);
                           System.debug('DEBUG: (CaseTrigger) contactIdsToReceiveSurvey.contains(caseToProcess.contactId) = ' + contactIdsToReceiveSurvey.contains(caseToProcess.contactId));
                           System.debug('DEBUG: (CaseTrigger) relatedContact.Email = ' + relatedContact.Email);
                           if (relatedContact.Email != null)
                           {System.debug('DEBUG: (CaseTrigger) relatedContact.Email.containsIgnoreCase(nimblestorage.com) = ' + relatedContact.Email.containsIgnoreCase('nimblestorage.com'));
                           }
                           System.debug('DEBUG: (CaseTrigger) relatedContact.contactLastSurveySentDate__c = ' + relatedContact.contactLastSurveySentDate__c);
                           
                           if (caseToProcess.Case_Type__c == 'External'                                                        &&
                               //caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId() &&
                               !caseToProcess.Auto_Close__c                                                                    &&
                               statusChangedToClosed                                                                           &&
                               String.valueof(caseToProcess.OwnerId).startsWith('005')                                         &&
                               relatedAccount.Support_Provider__c == null                                                      &&
                               !contactIdsToReceiveSurvey.contains(caseToProcess.contactId)                                    &&
                               (relatedContact.Email != null && !relatedContact.Email.containsIgnoreCase('nimblestorage.com')) &&
                               (relatedContact.contactLastSurveySentDate__c == null || relatedContact.contactLastSurveySentDate__c.daysbetween(System.today()) > 30)
                              )
                           {surveyIdsMap = new Map<String, Id>();
                            surveyIdsMap.put('caseId',          caseToProcess.Id);
                            surveyIdsMap.put('contactId',       caseToProcess.contactId);
                            if(caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId()){// Added by exafort for TS-7759
                                surveyIdsMap.put('emailTemplateId', emailTemplateId);
                            }
                            if(caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId()){// Added by exafort for TS-7759
                                surveyIdsMap.put('emailTemplateId', Inosightemplate);
                            }
                            surveyIdsList.add(surveyIdsMap);
                            contactIdsToReceiveSurvey.add(caseToProcess.contactId);
                            System.debug('DEBUG: (CaseTrigger) Added following IDs to be processed for survey:');
                            System.debug('DEBUG: (CaseTrigger)   caseId          = ' + caseToProcess.Id);
                            System.debug('DEBUG: (CaseTrigger)   contactId       = ' + caseToProcess.contactId);
                            System.debug('DEBUG: (CaseTrigger)   emailTemplateId = ' + emailTemplateId);
                           }
                       }
                    //Added by Exafort for TS-7759
                    if(caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId()){
                        if(caseToProcess.Infosight_Contact_Email__c != null && caseToProcess.Infosight_Contact_Name__c != null){
                            infoContactEmail = caseToProcess.Infosight_Contact_Email__c;
                            Account relatedInfositeAccount;
                            Contact relatedInfositeContact;
                            Id matchedContact;
                            //Id Inosightemplate = Infosight_Portal_Customer_SurveyTemplate__c.getInstance().Infosight_Email_Template__c;
                            statusChangedToClosed = false;
                            //Map<Id, Account> relatedAccountsInfosightMap = new Map<Id, Account>([SELECT Id, Support_Provider__c FROM Account WHERE Id = :accId]);
                            //Map<Id, Contact> relatedCaseContactsMap = new Map<Id, Contact>([SELECT Id, contactLastSurveySentDate__c, Email FROM Contact WHERE AccountId != :accId and Email = :infoContactEmail]);
                            //Map<Id, Contact> relatedContactsInfosightMap = new Map<Id, Contact>([SELECT Id, contactLastSurveySentDate__c, Email FROM Contact WHERE AccountId = :accId and Email = :infoContactEmail]);                          
                            //if(relatedCaseContactsMap.size() == 1){
                            //for(Id Contactid : relatedCaseContactsMap.keyset()){
                            // matchedContact = Contactid;
                            //}
                            //}
                            //if(relatedCaseContactsMap.size() == 0 || relatedCaseContactsMap.size() > 1){
                            if(relatedContactsInfosightMap.size() > 0){
                                for(Id Contactid : relatedContactsInfosightMap.keyset()){
                                    matchedContact = Contactid;
                                }
                            }
                            //}
                            relatedInfositeAccount = relatedAccountsInfosightMap.get(accId);
                            if(matchedContact != null){
                                relatedInfositeContact = relatedContactsInfosightMap.get(matchedContact);
                            }
                            if ((Trigger.isInsert && caseToProcess.Status == 'Closed') ||
                                (Trigger.isUpdate && caseToProcess.Status == 'Closed' && Trigger.oldMap.get(caseToProcess.Id).Status <> 'Closed'))
                            {
                                statusChangedToClosed = true;
                            }
                            if(caseToProcess.Case_Type__c == 'External' && !caseToProcess.Auto_Close__c && statusChangedToClosed && !contactIdsToReceiveSurvey.contains(relatedInfositeContact.Id) &&
                               String.valueof(caseToProcess.OwnerId).startsWith('005') && relatedInfositeAccount.Support_Provider__c == null && !relatedInfositeContact.Email.containsIgnoreCase('nimblestorage.com') &&
                               (relatedInfositeContact.contactLastSurveySentDate__c == null || relatedInfositeContact.contactLastSurveySentDate__c.daysbetween(System.today()) > 30)){
                                   surveyIdsMap = new Map<String, Id>();
                                   surveyIdsMap.put('caseId',          caseToProcess.Id);
                                   surveyIdsMap.put('contactId',       relatedInfositeContact.id);
                                   surveyIdsMap.put('emailTemplateId', Inosightemplate);
                                   surveyIdsList.add(surveyIdsMap);
                                   contactIdsToReceiveSurvey.add(relatedInfositeContact.id);
                               } 
                        } 
                    }
                    //End of TS-7759
                }
                
                // Send the surveys
                surveyUtilities.sendSurveys(surveyIdsList);
                
                // Update the Contacts' Last Survey Sent Date fields
                System.debug('DEBUG: (CaseTrigger) contactIdsToReceiveSurvey size = ' + contactIdsToReceiveSurvey.size());
                contactsToUpdate = [SELECT Id, contactLastSurveySentDate__c FROM Contact WHERE Id IN :contactIdsToReceiveSurvey];
                System.debug('DEBUG: (CaseTrigger) contactsToUpdate size = ' + contactsToUpdate.size());
                for (Contact contactToUpdate : contactsToUpdate)
                {contactToUpdate.contactLastSurveySentDate__c = System.today();
                }
                update contactsToUpdate;
            }
        }
        
       */
        //Added on 07/19/2016 - contains validations to close a case - By Azar
        try{
            if(trigger.isInsert){
                List<PachinkoCaseTypes__c> lstpachinko = PachinkoCaseTypes__c.getall().values();
                set<string> pachinkoCaseTypes = new set<string>();
                for(PachinkoCaseTypes__c pachinkocodes : lstpachinko)
                {
                    pachinkoCaseTypes.add(pachinkocodes.Code__c);
                }
                if(trigger.isBefore && trigger.isInsert){
                    system.debug('### current user Name ### '+UserInfo.getName());
                    List<CaseTeamMember> ctmSet = new List<CaseTeamMember>();
                    for(Case caseLoop : trigger.new){
                        if(caseLoop.casePachinkoCaseType__c != null && pachinkoCaseTypes.contains(caseLoop.casePachinkoCaseType__c)){
                            caseLoop.PartShipValidatedSixMonthsAgoSendEmail__c = true;
                        }

                        system.debug('### caseLoop.Priority ### '+caseLoop.Priority);
                        //Calculate GMT and send email alert when priority is P1
                        if(caseLoop.Priority == 'P1'){
                            caseLoop.Americas_P1alert__c = 'Americas_P1alert@nimblestorage.com';
                            caseLoop.EMEA_P1alert__c = 'EMEA_P1alert@nimblestorage.com';
                            caseLoop.APAC_P1alert__c = 'APAC_P1alert@nimblestorage.com';
                            caseLoop.Weekend_P1alert__c = 'Weekend_P1alert@nimblestorage.com';
                            caseLoop.OPS_P1alert__c = 'nimble-support-ops@hpe.com';
                            Datetime createdDateTime = DateTime.now(); 
                            string timeFormat = createdDateTime.format('kk:mm:ss','GMT');
                            if(timeFormat != null && timeFormat.substringBefore(':') != null){
                                caseLoop.caseP1AlertGMT__c = integer.valueOf(timeFormat.substringBefore(':'));
                                caseLoop.caseP1AlertDay__c = createdDateTime.format('EEEE');
                            }
                            
                        }
                        else{
                            if(caseLoop.caseP1AlertGMT__c != null){
                                caseLoop.caseP1AlertGMT__c = null;
                            }
                            if(caseLoop.caseP1AlertDay__c != null){
                                caseLoop.caseP1AlertDay__c = null;
                            } 
                        }
                        system.debug('### caseLoop.caseP1AlertGMT__c ### '+caseLoop.caseP1AlertGMT__c);
                    }
                }
                if(trigger.isAfter && trigger.isInsert){
                    
                    List<Case> caseID = new List<Case>();
                    set<Id> assetId = new set<Id>();
                    set<Id> contactId = new set<Id>();
                    List<CaseComment> newCaseCommentsaddressInvalid = new List<CaseComment>();
                                      
                    List<case> p1AlertCase = new List<case>();
                    
                    for(Case caseLoop : trigger.new){
                        Case myCase = trigger.new[0];
                        
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
                        if(caseLoop.casePachinkoCaseType__c != null && pachinkoCaseTypes.contains(caseLoop.casePachinkoCaseType__c)){
                            
                            for(Asset assetLoop : assetList){
                                if(assetLoop.assetPartShipLastValidatedDatetime__c != null){
                                    Integer noOfDays = Date.valueOf(assetLoop.assetPartShipLastValidatedDatetime__c).daysBetween(system.today());
                                    if(noOfDays >= 180){
                                        for(Contact con : contactList){
                                            string commentBody = 'Subject: Nimble Case #'+caseLoop.CaseNumber+ ' - ' +caseLoop.Subject+'\n Hello '+con.FirstName+', \n\n We have received a case for '+ caseLoop.Subject+' for your array '+assetLoop.System_Name__c+'('+assetLoop.SerialNumber+'). \n However, our records indicate that the shipping information for ' +assetLoop.System_Name__c+'('+ assetLoop.SerialNumber +') has not validated in six months or more. \n\n Please note that a current, validated shipping address and handling instruction allows for faster resolution of the issue, in the event a replacement part shipment is required. \n\n Shipping address and handling instruction validation may be performed through the following link , after signing in using your InfoSight credentials. \n https://infosight.hpe.com/settings/nimble/assetRegistry \n\n A Nimble Storage Technical Support Engineer will review the case shortly.\n\n Thank You \n Nimble Storage Support';
                                            CaseComment newCommmant = new CaseComment();
                                            newCommmant.CommentBody = commentBody;
                                            newCommmant.IsPublished = True;
                                            newCommmant.ParentId = caseLoop.Id;
                                            newCaseCommentsaddressInvalid.add(newCommmant);  
                                        }
                                    }
                                }
                            } 
                        }
                    }
                    if(newCaseCommentsaddressInvalid.size() > 0){
                        insert newCaseCommentsaddressInvalid;
                    }
                }
            }
            
            
            if(Trigger.isUpdate){
                set<Id> caseID = new set<Id>(); //set of ID's to hold incoming case ID
                for(Case cas : trigger.new){
                    
                    caseID.add(cas.id); //Put case ID's to set of ID's
                    if(CaseUtility.caseRecordIds.size() == 0)
                        CaseUtility.caseRecordIds.add(cas.id);
                }
                List<Bug__c> bugList = new List<Bug__c>(); //List of Bug object to query with case ID
                /*if(caseID.size() > 0){ //Commented by exafort by exafort on May 06 2021 for TS-5295
bugList = [select id, Case__c, Case__r.Id, Name from Bug__c where Case__r.Id IN :caseID]; //Query Bug object with CaseID
}*/
                
                //Added by exafort on May 06 2021 for TS-5295 START
                boolean isIdChanged = CaseUtility.caseRecordIds.equals(caseID);
                
                if(!isIdChanged){
                    CaseUtility.caseRecordIds.clear();
                    CaseUtility.caseRecordIds.addall(caseID);  
                    CaseUtility.restrictBugListBinding = false;
                }
                if(caseID.size() > 0 && !CaseUtility.restrictBugListBinding ){ 
                    bugList = [select id, Case__c, Case__r.Id, Name from Bug__c where Case__r.Id IN :caseID]; //Query Bug object with CaseID
                    CaseUtility.restrictBugListBinding = true;
                    CaseUtility.bugListDetails = bugList;
                    
                }
                if( CaseUtility.restrictBugListBinding){
                    bugList = new List<Bug__c>();
                    bugList = CaseUtility.bugListDetails;
                    
                }
                
                //Added by exafort on May 06 2021 for TS-5295 END
                
                
                List<CaseComment> newCaseCommentsPublic = new List<CaseComment>(); //List of Case Comment to insert Public comment if case is closed as duplicate
                List<CaseComment> newCaseCommentsPrivate = new List<CaseComment>(); //List of Case Comment to insert Private comment if case is closed as duplicate
                List<CaseComment> slaCaseComment = new List<CaseComment>(); // //List of Case Comment to insert Private comment of SLA details
                //List<CaseComment> newCaseCommentsaddressInvalid = new List<CaseComment>();
                List<CaseComment> attnReqSnoozeList = new List<CaseComment>();
                List<Case> CaseForAfterUpdate = new List<Case>();
                string newCaseCommentBody = ''; //String is used to hold the comment
                Boolean IsSoftwareBugActivated = BugsRequiredForSoftwareBugRootCause__c.getInstance().Activate__c;
                string NIMBLE_SUPPORT_USER_ID = '00580000003xTOlAAM';
                
                //Query NCV Billing Email Template to put in comment body if Engage NCV Billing Email is sent
                
                List<CaseComment> ncvBillingEmailSentComment = new List<CaseComment>();
                Map<Id, String> getCaseOwnerNameMap = new Map<Id, String>();
                //Added by exafort for TS-8401 and TS-8404 on Aug 03/2021
                Id opsCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId();
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                List<CaseComment> Insertcasecommentclosed = new List<CaseComment>();//added by exafort for TS-8404 and TS-8401 on Aug 03/2021
                //List<Case> ParentCaseList = New List<Case>();
                //Added by Guru Dev(Exafort) for TS-6417 to avoid recursive
                Set<Id> ParentCaseList = New Set<Id>();
                List<Case> ParentCaseUpdateList = New List<Case>();
                //Added end
                //Added by Guru Dev(Exafort) for TS-6417,TS-8404,TS-8401 to avoid recursive on 01Oct 2021
                if(trigger.isAfter && trigger.isUpdate && assetPreventRecursiveV1.runOnce()){
                    //Added new fields on below query by exafort for TS-8404 and TS-8401 on Aug 03/2021
                    //List<case> CasesWithOwnerNames = [Select Id,Owner.Name From case where Id IN :caseID];
                    //Added "CaseDocket__r.Do_Not_Set_Parent_Case_ARF_upon_closure__c" in the below query by exafort for TS-9504
                    List<case> CasesWithOwnerNames = [Select Id,Owner.Name,CaseDocket__r.cdDoNotSetParentCaseARF__c,
                                                  CaseDocket__r.cddonotupdateparentcase__c,RecordTypeId,status,CaseMapping__c,
                                                  caseBUteam__c,casePachinkoCaseType__c,CaseNumber,casePortalResolutionNotes__c,
                                                  Asset.assetNimbleOsVersion__c,CaseDocket__r.Do_Not_Set_Parent_Case_ARF_Upon_Closure__c From case where Id IN :caseID];
                    system.debug('CasesWithOwnerNames'+CasesWithOwnerNames);
                    for(Case caseRecordForMap : CasesWithOwnerNames){         
                        getCaseOwnerNameMap.put(caseRecordForMap.Id,caseRecordForMap.Owner.Name);
                    }
                    for(Case caseRecordList : CasesWithOwnerNames){
                        //Added by exafort for TS-6417,TS-8404 and TS-8401 on Aug 03/2021
                        if(caseRecordList.RecordTypeId == opsCaseRecordTypeId && caseRecordList.CaseMapping__c != null && caseRecordList.CaseDocket__c !=null)
                        {
                            Case oldCase = Trigger.oldMap.get(caseRecordList.Id);
                            if(oldCase.Status != caseRecordList.status && (caseRecordList.Status == 'Closed' || caseRecordList.status =='Closed(Duplicate)')
                               && !caseRecordList.CaseDocket__r.cddonotupdateparentcase__c){
                                   system.debug('comes in line 479');
                                   Casecomment newcommentclosed = New Casecomment();
                                   newcommentclosed.CommentBody = '*** RELATED '+ caseRecordList.caseBUteam__c +' CASE CLOSED ('+ caseRecordList.casePachinkoCaseType__c +':'+caseRecordList.CaseNumber+')\n'
                                       + baseUrl + '/' + caseRecordList.id;
                                   if(!String.isBlank(caseRecordList.casePortalResolutionNotes__c)){
                                       newcommentclosed.CommentBody += '\n' + caseRecordList.casePortalResolutionNotes__c;
                                   }
                                   newcommentclosed.ParentId = caseRecordList.CaseMapping__c;  
                                   newcommentclosed.IsPublished = false;
                                   Insertcasecommentclosed.add(newcommentclosed);
                                   //////added by exafort for TS-8401 on 07/09/21
                                  // Added "!CaseDocket__r.Do_Not_Set_Parent_Case_ARF_upon_closure__c" in below condition by Exafort for TS-9504
                                   if(!caseRecordList.CaseDocket__r.cdDoNotSetParentCaseARF__c &&
                                      !caseRecordList.CaseDocket__r.Do_Not_Set_Parent_Case_ARF_upon_closure__c){
                                       system.debug('comes in line 536');
                                       Case parentCase = New case();
                                       parentCase.Id = caseRecordList.CaseMapping__c;
                                       parentCase.caseAttnReq__c = True;
                                       parentCase.caseAttnReqCreator__c  =  UserInfo.getName() +' ('+UserInfo.getUserEmail()+')';
                                       parentCase.caseAttnReqDateTime__c = system.now();
                                       parentCase.caseAttnReqSource__c ='Ops Case Update';
                                       parentCase.AttnSnoozeIntervalInHours__c = null;
                                       parentCase.caseAttnReqSnoozeReason__c = null;
                                       if(ParentCaseList.contains(parentCase.id)){
                                           system.debug('ID already exists');
                                       }
                                       else{
                                           ParentCaseList.add(parentCase.id);
                                           ParentCaseUpdateList.add(parentCase);
                                       }
                                   }
                                   //Added end
                                   
                               } 
                        }
                    }
                        //Added end
                        
                    if(Insertcasecommentclosed.size() > 0){
                        ////added by exafort for TS-8404
                        insert Insertcasecommentclosed;
                    }
                    if(ParentCaseUpdateList.size() > 0){////added by exafort for TS-8404
                        system.debug('comes in line 563');
                        update ParentCaseUpdateList;
                    }
                }
                
                //Added End to avoid recursive
                for(Case caseLoop : trigger.new){
                    //Added By vishnu for TS-8555
                    if(!UserInfo.getUserName().containsIgnoreCase('cokeva')){
                        //Case status is 'Closed' and Root cause is 'Software Bug' and Case is related to Nimble Product 'Yes' and No bug record is exist, throw an error
                        if(caseLoop.Status == 'Closed' && caseLoop.casCatClosureRootCause__c == 'Software Bug' && caseLoop.caseIsThisCaseRelatedToANimbleProduct__c == 'Yes' && bugList.size() == 0 && UserInfo.getUserId() != NIMBLE_SUPPORT_USER_ID){
                            
                            caseLoop.addError('Bugs Required to close a case if Root Cause is \'Software Bug\' and Case is Related to Nimble is \'Yes\'');
                        }
                        if(caseLoop.Status == 'Closed' && caseLoop.casCatClosureRootCause__c == 'Software Bug' && caseLoop.caseIsThisCaseRelatedToANimbleProduct__c == 'Yes' && bugList.size() == 0 && UserInfo.getUserId() == NIMBLE_SUPPORT_USER_ID && IsSoftwareBugActivated == true){
                            
                            caseLoop.addError('Bugs Required to close a case if Root Cause is \'Software Bug\' and Case is Related to Nimble is \'Yes\'');
                        }
                    }
                    //END of validation for closing a case. 
                    //Calculate GMT and send email alert when priority is P1
                    if(Trigger.isUpdate && Trigger.isBefore){
                        if((Trigger.OldMap.get(caseLoop.Id).Priority != 'P1' && caseLoop.Priority == 'P1' && caseLoop.Status != 'Closed') || (Trigger.OldMap.get(caseLoop.Id).Status == 'Closed' && caseLoop.Status == 'Open' && caseLoop.Priority == 'P1')){
                            caseLoop.Americas_P1alert__c = 'Americas_P1alert@nimblestorage.com';
                            caseLoop.EMEA_P1alert__c = 'EMEA_P1alert@nimblestorage.com';
                            caseLoop.APAC_P1alert__c = 'APAC_P1alert@nimblestorage.com';
                            caseLoop.Weekend_P1alert__c = 'Weekend_P1alert@nimblestorage.com';
                            caseLoop.OPS_P1alert__c = 'nimble-support-ops@hpe.com';
                            Datetime createdDateTime = DateTime.now(); 
                            string timeFormat = createdDateTime.format('kk:mm:ss','GMT');
                            if(timeFormat != null && timeFormat.substringBefore(':') != null){
                                caseLoop.caseP1AlertGMT__c = integer.valueOf(timeFormat.substringBefore(':'));
                                caseLoop.caseP1AlertDay__c = createdDateTime.format('EEEE');
                            }
                        }
                        else{
                            if(caseLoop.caseP1AlertGMT__c != null){
                                caseLoop.caseP1AlertGMT__c = null;
                            }
                            if(caseLoop.caseP1AlertDay__c != null){
                                caseLoop.caseP1AlertDay__c = null;
                            } 
                        }
                        //Added by exafort(vishnu) for SLA Expiry
                        //SLA Expiry formula field Helper
                        //Update when owner changed
                        string OldOwnerId = Trigger.OldMap.get(caseLoop.Id).OwnerId;
                        string newOwnerId = caseLoop.OwnerId;
                        if(Trigger.OldMap.get(caseLoop.Id).OwnerId != caseLoop.OwnerId && OldOwnerId.startsWith('00G') && !newOwnerId.startsWith('00G')){
                            System.debug('Inside If ====>');
                            caseLoop.caseOwnerChanged__c = true;
                            caseLoop.SLAWhenOwnerChanged__c = caseLoop.caseSLAExpiry__c;
                            caseLoop.SLAWhenOwnerChangedInMinutes__c = caseLoop.caseSLAExpiryMinutes__c;
                        }
                        else{
                            System.debug('Inside else ====>');
                            caseLoop.caseOwnerChanged__c = false;
                        }
                        System.debug('SLA =========>'+caseLoop.SLAWhenOwnerChanged__c);
                        System.debug('SLA =========>'+caseLoop.SLAWhenOwnerChangedInMinutes__c);
                    }
                    
                    //Added on 28th Sept 2016 - New Case Comment if Case is closed as Duplicate - By Azar  
                    
                    if(Trigger.isUpdate && Trigger.isAfter){
                        if(assetPreventRecursive.runOnce() && CountAssetPreventRecursive.runOnce())  //Boolean variable to prevent Recursive Trigger
                        {
                            if(caseLoop.Status == 'Closed(Duplicate)'){
                                
                                //If case status is 'Closed Duplicate' then add a public comment on Parent Case
                                newCaseCommentBody = 'This case is closed as Duplicate';
                                
                                CaseComment newCommmand = new CaseComment();
                                newCommmand.CommentBody = newCaseCommentBody;
                                newCommmand.IsPublished = TRUE;
                                newCommmand.ParentId = caseLoop.id;
                                newCaseCommentsPublic.add(newCommmand);
                                
                                if(caseLoop.Duplicate_Case__c != null){
                                    //If case is Closed as Duplicated with another case, then add private comment on Duplicated Case
                                    newCaseCommentBody = 'Case '+caseLoop.CaseNumber+' Closed as Duplicate';
                                    
                                    CaseComment newCommmant = new CaseComment();
                                    newCommmant.CommentBody = newCaseCommentBody;
                                    newCommmant.IsPublished = False;
                                    newCommmant.ParentId = caseLoop.Duplicate_Case__c;
                                    newCaseCommentsPrivate.add(newCommmant);
                                }
                            }
                            //Add case comment when attn req snooze is set
                            if(Trigger.oldMap.get(caseLoop.Id).AttnSnoozeIntervalInHours__c == null && caseLoop.AttnSnoozeIntervalInHours__c !=null && caseLoop.caseAttnReqDateTimeHelper__c != null){
                                CaseComment attnReqComment = new CaseComment();
                                //string snoozePeriod = string.valueOf(caseLoop.caseAttnReqDateTime__c.addHours(integer.valueof(caseLoop.AttnSnoozeIntervalInHours__c)));
                                //string snoozePeriod = string.valueOf(caseLoop.caseAttnReqDateTimeHelper__c.addHours(integer.valueof(caseLoop.AttnSnoozeIntervalInHours__c)));
                                DateTime snoozePeriodToUserLocal = caseLoop.caseAttnReqDateTimeHelper__c.addHours(integer.valueof(caseLoop.AttnSnoozeIntervalInHours__c));
                                DateTime snoozePeriodToUserLocal1 = DateTime.newInstance(snoozePeriodToUserLocal.year(), snoozePeriodToUserLocal.month(), snoozePeriodToUserLocal.day(), snoozePeriodToUserLocal.hour(), snoozePeriodToUserLocal.minute(), snoozePeriodToUserLocal.second());
                                String snoozePeriod = snoozePeriodToUserLocal1.format();
                                attnReqComment.CommentBody = 'Attn Req Flag Snoozed + '+caseLoop.AttnSnoozeIntervalInHours__c+' hours. Snoozed Attn Req Date Time is '+snoozePeriod+'\n Reason: \n '+caseLoop.caseAttnReqSnoozeReason__c;
                                attnReqComment.IsPublished = False;
                                attnReqComment.ParentId = caseLoop.Id;
                                attnReqSnoozeList.add(attnReqComment);
                            }
                            if(Trigger.oldMap.get(caseLoop.Id).AttnSnoozeIntervalInHours__c != null && caseLoop.AttnSnoozeIntervalInHours__c !=null && Trigger.oldMap.get(caseLoop.Id).AttnSnoozeIntervalInHours__c != caseLoop.AttnSnoozeIntervalInHours__c  && caseLoop.caseAttnReqDateTimeHelper__c != null){
                                CaseComment attnReqComment = new CaseComment();
                                //string snoozePeriod = string.valueOf(caseLoop.caseAttnReqDateTime__c.addHours(integer.valueof(caseLoop.AttnSnoozeIntervalInHours__c)));
                                //string snoozePeriod = string.valueOf(caseLoop.caseAttnReqDateTimeHelper__c.addHours(integer.valueof(caseLoop.AttnSnoozeIntervalInHours__c)));
                                DateTime snoozePeriodToUserLocal = caseLoop.caseAttnReqDateTimeHelper__c.addHours(integer.valueof(caseLoop.AttnSnoozeIntervalInHours__c));
                                DateTime snoozePeriodToUserLocal1 = DateTime.newInstance(snoozePeriodToUserLocal.year(), snoozePeriodToUserLocal.month(), snoozePeriodToUserLocal.day(), snoozePeriodToUserLocal.hour(), snoozePeriodToUserLocal.minute(), snoozePeriodToUserLocal.second());
                                String snoozePeriod = snoozePeriodToUserLocal1.format();
                                attnReqComment.CommentBody = 'Attn Req Flag Re-Snoozed + '+caseLoop.AttnSnoozeIntervalInHours__c+' hours. Re-Snoozed Attn Req Date Time is '+snoozePeriod+'\n Reason: \n '+caseLoop.caseAttnReqSnoozeReason__c; 
                                attnReqComment.IsPublished = False;
                                attnReqComment.ParentId = caseLoop.Id;
                                attnReqSnoozeList.add(attnReqComment);
                            }
                            if(Trigger.oldMap.get(caseLoop.Id).caseEngageNCVBilling__c == false && caseLoop.caseEngageNCVBilling__c == true){
                                CaseComment ncvBillingEmail = new CaseComment();
                                ncvBillingEmail.CommentBody = 'Email Sent To Accounts Receivable and the Portal team \n\n The following case has been referred to you for ncv billing issues. \n\n***************************\nCase: '+caseLoop.CaseNumber+'\nStatus: '+caseLoop.Status+'\nPriority Level: '+caseLoop.Priority+'\nSubject: '+caseLoop.Subject+'\nDescription: '+caseLoop.Description+'\n\n'+caseLoop.Thread_Id__c;
                                ncvBillingEmail.IsPublished = False;
                                ncvBillingEmail.ParentId = caseLoop.Id;
                                ncvBillingEmailSentComment.add(ncvBillingEmail);
                            }
                            //Added by exafort(vishnu) for SLA Expiry
                            string OldOwnerId = Trigger.OldMap.get(caseLoop.Id).OwnerId;
                            string newOwnerId = caseLoop.OwnerId;
                            system.debug('Old Owner====> '+Trigger.OldMap.get(caseLoop.Id).OwnerId);
                            system.debug('New Owner====> '+caseLoop.OwnerId);
                            system.debug('SLA When Owner Changed===> '+caseLoop.SLAWhenOwnerChanged__c);
                            if((Trigger.OldMap.get(caseLoop.Id).OwnerId != caseLoop.OwnerId && OldOwnerId.startsWith('00G') && !newOwnerId.startsWith('00G') && caseLoop.SLAWhenOwnerChanged__c != null)||Test.isRunningTest()){
                                CaseComment slaComment = new CaseComment();
                                string prioritySLA = '';
                                string slaWhenOwnerChange = '';
                                string slaMet = '';
                                string caseAge = '';
                                if(caseLoop.Priority == 'P1'){
                                    prioritySLA = '30 minutes';
                                }
                                else if(caseLoop.Priority == 'P2'){
                                    prioritySLA = '2 hours';
                                }
                                else if(caseLoop.Priority == 'P3'){
                                    prioritySLA = '8 hours';
                                }
                                else if(caseLoop.Priority == 'P4'){
                                    prioritySLA = '24 hours';
                                }
                                if(caseLoop.SLAWhenOwnerChanged__c != null && caseLoop.SLAWhenOwnerChanged__c.Contains('-')){
                                    slaWhenOwnerChange = caseLoop.SLAWhenOwnerChanged__c +'<0';
                                    slaMet = 'miss';
                                }
                                else if(caseLoop.SLAWhenOwnerChanged__c != null && !caseLoop.SLAWhenOwnerChanged__c.Contains('-')){
                                    slaWhenOwnerChange = caseLoop.SLAWhenOwnerChanged__c +'>0';
                                    slaMet = 'yes';
                                }
                                if(caseLoop.Age_Days__c != null){
                                    caseAge = string.valueOf(caseLoop.Age_Days__c);
                                }
                                else{
                                    caseAge = '0';
                                }
                                //slaComment.CommentBody = UserInfo.getFirstName()+' '+UserInfo.getLastName()+' took ownership (priority:'+caseLoop.priority+', age(days): '+caseAge+', sla: '+prioritySLA+', status: '+slaWhenOwnerChange+', ‘met’ : '+slaMet+')';
                                slaComment.CommentBody = getCaseOwnerNameMap.get(caseLoop.Id)+' took ownership (priority:'+caseLoop.priority+', age(days): '+caseAge+', sla: '+prioritySLA+', status: '+slaWhenOwnerChange+', ‘met’ : '+slaMet+')';
                                slaComment.IsPublished = False;
                                slaComment.ParentId = caseLoop.Id;
                                slaCaseComment.add(slaComment);
                            }
                            //Code Ends For SLA Expiry
                            ////**********************
                            Set<Id> CaseIds = new Set<Id>();
                            //Ntelkar Removed "Support Queue - SSaaS" from the selection
                            List<Group> qs = [select id,name From Group where Type='queue' and (name ='Support Queue - General' or name ='Support Queue - OPS' or name = 'Support Queue - TSC' or name = 'Support Queue - H3C' or name = 'Support Queue - NCV' or name = 'Support Queue - Automatic' or name = 'Tech Hub Queue - SDOE')];
                            Map<string, id> queueMap = new Map<string, id>();
                            for(Group gr : qs){
                                queueMap.put(gr.Name, gr.id);
                            }
                            system.debug('>>>>>>>>>');
                            for(Case eachCaseRec : Trigger.New){
                                CaseIds.add(eachCaseRec.Id);
                                system.debug('>>>>>>>>>');
                            }
                            List<Case> CaseForExecution = [Select Id,OwnerId,Status,Auto_Close__c,caseAccountSupportProvider__c,RecordType.Name,DateTime_First_Available_To_Work__c From case Where Id = :CaseIds ];
                            system.debug('After List');
                            if(!CaseForExecution.isEmpty()){
                                for(Case eachCaseRec : CaseForExecution){
                                    Boolean isCaseUpdateReqd = false;
                                    system.debug('>>>>>>>>>');
                                    if(eachCaseRec.ownerId == queueMap.get('Support Queue - Automatic') && eachCaseRec.Auto_Close__c == True && eachCaseRec.Status != 'Closed' && eachCaseRec.Status != 'Closed(Duplicate)'){
                                        system.debug('>>>>>>>>>');
                                        if(eachCaseRec.RecordType.Name == 'Array Case'){
                                            system.debug('Assigning SQ-General AS Owner =======>');
                                            eachCaseRec.OwnerId = queueMap.get('Support Queue - General');
                                            eachCaseRec.DateTime_First_Available_To_Work__c = System.now();
                                            isCaseUpdateReqd = true;
                                        }
                                        else if(eachCaseRec.RecordType.Name == 'NCV Case'){
                                            system.debug('Assigning SQ-NCV AS Owner =======>');
                                            eachCaseRec.OwnerId = queueMap.get('Support Queue - NCV');
                                            eachCaseRec.DateTime_First_Available_To_Work__c = System.now();
                                            isCaseUpdateReqd = true;
                                        }
                                        //Added by exafort on March 23 2021 for TS-8011 START
                                        //Ntelkar removed this validation for SSaaS queue - TS-9411
                                        /*else if(eachCaseRec.RecordType.Name == 'SSaaS'){                                           
                                            eachCaseRec.OwnerId = queueMap.get('Support Queue - SSaaS');
                                            eachCaseRec.DateTime_First_Available_To_Work__c = System.now();
                                            isCaseUpdateReqd = true;
                                        }*///Added by exafort on March 23 2021 for TS-8011 END
                                        //Added by exafort on  April 07 2021 for TS-8103 START 
                                        else if(eachCaseRec.RecordType.Name == 'SDOE'){                                           
                                            eachCaseRec.OwnerId = queueMap.get('Tech Hub Queue - SDOE');
                                            eachCaseRec.DateTime_First_Available_To_Work__c = System.now();
                                            isCaseUpdateReqd = true;
                                        }//Added by exafort on  April 07 2021 for TS-8103  END
                                        
                                        else if(eachCaseRec.caseAccountSupportProvider__c != null && eachCaseRec.caseAccountSupportProvider__c.contains('H3C')){
                                            system.debug('Assigning SQ-H3C AS Owner =======>');
                                            eachCaseRec.OwnerId = queueMap.get('Support Queue - H3C');
                                            eachCaseRec.DateTime_First_Available_To_Work__c = System.now();
                                            isCaseUpdateReqd = true;
                                        }
                                        else if(eachCaseRec.caseAccountSupportProvider__c != null && eachCaseRec.caseAccountSupportProvider__c == 'Toshiba IT-Services Corporation'){
                                            system.debug('Assigning SQ-TSC AS Owner =======>');
                                            eachCaseRec.OwnerId = queueMap.get('Support Queue - TSC');
                                            eachCaseRec.DateTime_First_Available_To_Work__c = System.now();
                                            isCaseUpdateReqd = true;
                                        }
                                    }
                                    if(isCaseUpdateReqd) {
                                        CaseForAfterUpdate.add(eachCaseRec);
                                    }
                                }
                            }
                            ////*******************************************************************//
                        }
                    }            
                }
                //Code Added by Exafort - Starts
                //To throw an error when a H3C user is assigning to Non-H3C case
                if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
                    if(RecursiveTriggerRestrictiion.runOnce()){
                        Boolean isOwnerNew = false;
                        for(Case eachCase : Trigger.New){
                            if(Trigger.oldMap.get(eachCase.Id).OwnerId != eachCase.OwnerId){
                                isOwnerNew = true;
                            }
                        }
                        if(isOwnerNew ||Test.isRunningTest()){
                            Set<Id> storeAllH3CUsersId = new Set<Id>();
                            Set<Id> storeH3CQueueId = new Set<Id>();
                            Set<Id> storeAllQueuesId = new Set<Id>();
                            Set<Id> storeQueueRelatedUsersId = new Set<Id>();
                            Map<Id, Id> storeUsersInMap = new Map<Id, Id>();
                            
                            for(User eachUser : [Select Id, Name, Email, Username, Profile.Name from User where Profile.Name = 'Support Provider H3C']){
                                storeAllH3CUsersId.add(eachUser.Id);
                            }
                            System.debug('storeAllH3CUsersId =====>'+storeAllH3CUsersId);
                            List<Group> fetchRelatedGroups = [Select Id, Name from Group where Type = 'Queue' AND (Name = 'Support Queue - H3C' OR Name = 'Support Queue - General')];
                            List<Group> fetchH3CGroup = [Select Id, Name from Group where Type = 'Queue' AND Name = 'Support Queue - H3C'];
                            System.debug('fetchRelatedGroups =====>'+fetchRelatedGroups);
                            for(Group h3cGroup : fetchH3CGroup){
                                storeH3CQueueId.add(h3cGroup.Id);
                            }
                            for(Group eachGroup : fetchRelatedGroups){
                                storeAllQueuesId.add(eachGroup.Id);
                            }
                            System.debug('storeAllQueuesId =====>'+storeAllQueuesId);
                            List<GroupMember> fetchAllRelatedGroupUsers = [Select UserOrGroupId from GroupMember where GroupId =: storeAllQueuesId];
                            List<Id> fetchSubRelatedGroupsList = new List<Id>();
                            for(GroupMember eachMember : fetchAllRelatedGroupUsers){
                                String eachMemberUserIdInString = (String)eachMember.UserOrGroupId;
                                if(eachMemberUserIdInString.startsWith('005')){
                                    storeQueueRelatedUsersId.add(eachMember.UserOrGroupId);
                                }
                                else if(eachMemberUserIdInString.startsWith('00G')){
                                    fetchSubRelatedGroupsList.add(eachMemberUserIdInString);
                                }
                            }
                            //if(!Test.isRunningTest()){
                                List<GroupMember> fetchAllRelatedSubGroupUsers = [Select UserOrGroupId from GroupMember where GroupId =: fetchSubRelatedGroupsList];
                                for(GroupMember eachSubMember : fetchAllRelatedSubGroupUsers){
                                    String eachSubMemberUserIdInString = (String)eachSubMember.UserOrGroupId;
                                    if(eachSubMemberUserIdInString.startsWith('005')){
                                        storeQueueRelatedUsersId.add(eachSubMember.UserOrGroupId);
                                    }
                                }
                            //}
                            System.debug('storeQueueRelatedUsersId =====>'+storeQueueRelatedUsersId);
                            System.debug('storeQueueRelatedUserId List Size =====>'+storeQueueRelatedUsersId.size());
                            for(Case fetchEachCase : Trigger.New){
                                String OwnerIdInString = fetchEachCase.OwnerId;
                                System.debug('OwnerIdInString =====>'+OwnerIdInString);
                                if(OwnerIdInString.startsWith('005')){
                                    if((fetchEachCase.caseAccountSupportProvider__c == 'H3C Service Provider' || fetchEachCase.Account_Name__c == 'H3C Service Provider') && fetchEachCase.OwnerId != null && (!storeQueueRelatedUsersId.contains(fetchEachCase.OwnerId))){
                                        fetchEachCase.addError('Cannot assign a Non-H3C user to H3C related case');
                                    }
                                    if((fetchEachCase.caseAccountSupportProvider__c != 'H3C Service Provider') && fetchEachCase.OwnerId != null && storeAllH3CUsersId.contains(fetchEachCase.OwnerId)){
                                        fetchEachCase.addError('Cannot assign a H3C user to Non-H3C related case');
                                    }
                                }
                                else if(OwnerIdInString.startsWith('00G')){
                                    if((fetchEachCase.caseAccountSupportProvider__c == 'H3C Service Provider' || fetchEachCase.Account_Name__c == 'H3C Service Provider') && fetchEachCase.OwnerId != null && (!storeAllQueuesId.contains(fetchEachCase.OwnerId))){
                                        fetchEachCase.addError('Cannot assign a Non-H3C queue to H3C related case');
                                    }
                                    if((fetchEachCase.caseAccountSupportProvider__c != 'H3C Service Provider') && fetchEachCase.OwnerId != null && (storeH3CQueueId.contains(fetchEachCase.OwnerId))){
                                        fetchEachCase.addError('Cannot assign a H3C queue to Non-H3C related case');
                                    }
                                }
                            }
                        }
                    }
                }
                //Code Added by Exafort - Ends
                
                if(newCaseCommentsPublic.size() > 0){
                    //Insert the public comment on direct parent case
                    insert newCaseCommentsPublic;
                }
                if(newCaseCommentsPrivate.size() > 0){
                    //insert the private comment on Duplicated case
                    insert newCaseCommentsPrivate;
                }
                if(attnReqSnoozeList.size() > 0){
                    insert attnReqSnoozeList;
                }
                if(ncvBillingEmailSentComment.size() > 0){
                    insert ncvBillingEmailSentComment;
                }
                if(slaCaseComment.size() > 0){
                    insert slaCaseComment;
                }
                if(CaseForAfterUpdate.size() > 0){
                    update CaseForAfterUpdate;
                }
            }
        }
        catch(Exception e){
            system.debug('Case Trigger - Update - Error Caught '+e.getMessage());
        }
        //CaseUtility.GSEMrunOnce Added by Exafort on 22 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295  
        if(CaseUtility.GSEMrunOnce()){
            //TS-6918 validation on case to close the related Onsite tasks and GSEM's before closing the case - By Vishnu on 14th Feb 2020.
            if (Trigger.isBefore && Trigger.isUpdate){
                Set<Id> caseIds = new Set<Id>();
                for(case aCaseRec:Trigger.New){
                    system.debug(' VVV Cases  1 ===>');
                    Case OldCaseRec = Trigger.OldMap.get(aCaseRec.Id);
                    if((aCaseRec.Status == 'Closed' || aCaseRec.Status == 'Closed(Duplicate)') &&  aCaseRec.Status != OldCaseRec.Status ){
                        caseIds.add(aCaseRec.Id);
                    }  
                }
                Map<Id, List<GSEM__c>> casesWithOpenGsemMap = new Map<Id, List<GSEM__c>>();
                Id gsemRecordTypeId = Schema.getGlobalDescribe().get('GSEM__c').getDescribe().getRecordTypeInfosByName().get('Nimble to PN').getRecordTypeId();
                for(GSEM__c aGsemRec :[SELECT Id,GSEM__c,Confirm_Close__c FROM GSEM__c WHERE GSEM__c IN :caseIds AND Confirm_Close__c = 'OPEN' AND RECORDTYPEID =: gsemRecordTypeId ]) 
                {
                    if(!casesWithOpenGsemMap.containsKey(aGsemRec.GSEM__c)){
                        casesWithOpenGsemMap.put(aGsemRec.GSEM__c,new List<GSEM__c> {aGsemRec});
                    }
                    else{
                        casesWithOpenGsemMap.get(aGsemRec.GSEM__c).add(aGsemRec);
                    }
                }
                Map<Id, List<Onsite_Task__c>> casesWithOpenOnsiteTaskMap = new Map<Id, List<Onsite_Task__c>>();
                /*commented by exafort for case 101 soql limit TS-7728 on 18 nov 2020
for(Onsite_Task__c oNsiteTask :[SELECT Id,Case__c,Scheduling_Status__c FROM Onsite_Task__c WHERE Case__c IN :caseIds AND Scheduling_Status__c NOT IN ('Partner Complete','Cancelled')]) 
{
if(!casesWithOpenOnsiteTaskMap.containsKey(oNsiteTask.Case__c)){
casesWithOpenOnsiteTaskMap.put(oNsiteTask.Case__c,new List<Onsite_Task__c> {oNsiteTask});
}
else{
casesWithOpenOnsiteTaskMap.get(oNsiteTask.Case__c).add(oNsiteTask);
}
}
commented by exafort for case 101 soql limit TS-7728 on 18 nov 2020 */
                for(Case aCaseRecord : trigger.new) {
                    Case OldCaseRecord = Trigger.OldMap.get(aCaseRecord.Id);
                    if((aCaseRecord.Status == 'Closed' || aCaseRecord.Status == 'Closed(Duplicate)') &&  aCaseRecord.Status != OldCaseRecord.Status ){ 
                        if((casesWithOpenGsemMap.containsKey(aCaseRecord.Id) && casesWithOpenGsemMap.get(aCaseRecord.Id).size() > 0)
                           // ||(casesWithOpenOnsiteTaskMap.containsKey(aCaseRecord.Id) && casesWithOpenOnsiteTaskMap.get(aCaseRecord.Id).size() > 0)
                          ) {
                              aCaseRecord.addError('Please verify if all GSEMs are Closed before closing this case'
                                                   +'</br> <b>Conditions:</b>'
                                                   +'</br> 1.GSEMs "Confirm Closed" status should be "CLOSED".'
                                                  );
                          }
                    }
                }
                //By Vishnu on 14th Feb 2020.
            }
        }
        //  Added By Exafort TS-10404
        if (Trigger.isBefore && Trigger.isInsert){            
            for (Case caseToProcess : Trigger.new){
                
                system.debug('caseToProcess.Peer_Flag_Inactive__c = ' + caseToProcess.Peer_Flag_Inactive__c);
                
                //  Stops the Case Creation with Peerflag inactive as True                
                if( caseToProcess.Peer_Flag_Inactive__c == True){
                    caseToProcess.addError('Peer Flag Inactive cannot be true when creating case');
                }
                
            }
        }else if (Trigger.isBefore && Trigger.isUpdate){
            for (Case caseToProcess : Trigger.new){
                Case oldCase = Trigger.OldMap.get(caseToProcess.Id);
                
                //  To Show validation error for the below conditions
                If( caseToProcess.Peer_Flag_Inactive__c == True && caseToProcess.Priority == 'P1'){
                    //  Peer Flag inactive cannot be made true for P1 case 
                    caseToProcess.addError('Peer Flag Inactive cannot be true for P1 case');
                }else If( oldCase.Peer_Flag_Inactive__c == False && caseToProcess.Peer_Flag_Inactive__c == True && caseToProcess.caseRMAAssociated__c == True){
                    //  Peer Flag inactive cannot be made true for Case with RMA
                    caseToProcess.addError('Peer Flag Inactive cannot be true as this case has RMA');
                }else If( oldCase.Peer_Flag_Inactive__c == False && caseToProcess.Peer_Flag_Inactive__c == True && caseToProcess.caseAccountCritical__c == True){
                    //  Peer Flag inactive cannot be made true for Case for Critical account cases
                    caseToProcess.addError('Peer Flag Inactive cannot be true as this is a Critical Account Case');
                }
                
                Account accountInfo = accountEntries.get(caseToProcess.AccountId);               
                system.debug('accountInfo === ' + accountInfo);
                if (accountInfo != null){
                    //  If PSM purchased, Peer flag inactive can't be set to true
                    If( oldCase.Peer_Flag_Inactive__c == False && caseToProcess.Peer_Flag_Inactive__c == True && accountInfo.ACM_Service_Purchased__c == True){
                        caseToProcess.addError('Peer Flag Inactive cannot be true as Case\'s account has PSM purchased');
                    }
                }
            }
        }
        // End of TS - 10404
    }
}