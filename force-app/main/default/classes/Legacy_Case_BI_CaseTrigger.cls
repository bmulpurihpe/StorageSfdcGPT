/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 03-28-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   10-05-2023   Nagalaxmi Telkar   Initial Version
**/
//trigger CaseTrigger on Case (before insert, after insert, after update, before update)
public with sharing class Legacy_Case_BI_CaseTrigger implements TriggerAction.BeforeInsert
{//System.debug('DEBUG: (CaseTrigger) ===== ENTERED');
    //System.debug('DEBUG: (CaseTrigger) ===== getQueries = ' + Limits.getQueries());
    public void beforeInsert(List<Case> newList){
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
        
        //if (Trigger.isBefore && Trigger.isInsert)
        //{
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
            for (Case caseToProcess : newList) 
                accountIds.add(caseToProcess.AccountId);
            
            Map<Id, Account> accountEntries = new Map<Id, Account>([
                SELECT CS_PSM__c,ACM_Service_Purchased__c, Primary_PSM__c, Primary_PSM__r.Email, Primary_CS_PSM__c, Primary_CS_PSM__r.Email FROM Account WHERE Id IN :accountIds
            ]);
            */
            for (Case caseToProcess : newList) {
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
            for (Case caseToProcess : newList){
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
                    if(caseToProcess.First_Outgoing_Email__c) {
                        caseToProcess.First_Outgoing_Email__c = false;
                    }
                    //Added by Mulpuri for TS-9908 on 6/8/23
                    if(caseToProcess.DCE_Sync__c ){
                        //system.debug('+++++isclone process : ' +caseToProcess.DCE_Sync__c); 
                            //In Salesforce, when trying to clone records, the values of fields which are not added to the page 
                            //layout are not copied over to the newly created cloned record.
                        caseToProcess.DCE_Sync__c = False;
                        //caseToProcess.Sub_Status__c = '--None--';
                    }
                    
                    /*  Added by Exafort for SFDC-1633
                     *  When case is cloned, the resulting case should have the “3 Strike” field set to false.
                     */
                    caseToProcess.X3_Strike__c = False;
                    //  End of SFDC-1633 
                    //  SFDC-1695 - When case is cloned,clear the Timer fields 
                    caseToProcess.Timer_Expiry_Date__c = null;
                    caseToProcess.Timer_Expiry_Date_Change_for_Scheduled__c = null;
                    caseToProcess.Timer_Expiry_Override_Date__c = null;
                    caseToProcess.Timer_Expiry_Date_Overridden__c = False;
                    //  End of SFDC-1695 
                }
                
                // Added by Exafort for SFDC-1664
                // This condition handles cases inserted via the Anonymous window to ensure that 'Resolved' or 'Handover' statuses are not allowed during case creation.                if (caseToProcess.Id == null){
                    if(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseToProcess.RecordTypeId).getName() == 'Array Case' || Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseToProcess.RecordTypeId).getName() == 'SSaaS'){
                        if (caseToProcess.Status == 'Resolved' || caseToProcess.Status == 'Handover' || caseToProcess.Status == 'Update Needed' ){
                            caseToProcess.addError('Status "' + caseToProcess.Status + '" is not allowed when creating a new Case.');
                        }
                    }
                //  End of SFDC-1664
                  
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
                //system.debug('caseToProcess.Peer_Flag_Inactive__c = ' + caseToProcess.Peer_Flag_Inactive__c);
                
                //  Stops the Case Creation with Peerflag inactive as True      
                /*  Below error message commented by Exafort for SFDC-478   
                 *  As a part of SFDC-478, this validation rule is no longer required, user can set peer flag inactive to true 
                 */          
                /* if( caseToProcess.Peer_Flag_Inactive__c == True){
                    caseToProcess.addError('Peer Flag Inactive cannot be true when creating case');
                }*/
            }
        
        //}
        
        
       
        //End of TS-4483
        
       
        //Added on 07/19/2016 - contains validations to close a case - By Azar
        try{
            //if(trigger.isInsert){
                List<PachinkoCaseTypes__c> lstpachinko = PachinkoCaseTypes__c.getall().values();
                set<string> pachinkoCaseTypes = new set<string>();
                for(PachinkoCaseTypes__c pachinkocodes : lstpachinko)
                {
                    pachinkoCaseTypes.add(pachinkocodes.Code__c);
                }
                //if(trigger.isBefore && trigger.isInsert){
                    system.debug('### current user Name ### '+UserInfo.getName());
                    List<CaseTeamMember> ctmSet = new List<CaseTeamMember>();
                    for(Case caseLoop : newList){
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
                //}
                
            //}
              
                //Code Added by Exafort - Starts
                //To throw an error when a H3C user is assigning to Non-H3C case
                //if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
                    if(RecursiveTriggerRestrictiion.runOnce()){
                        Boolean isOwnerNew = false;
                        for(Case eachCase : newList){
                            /*if(Trigger.oldMap.get(eachCase.Id).OwnerId != eachCase.OwnerId){
                                isOwnerNew = true;
                            }*/
                        }
                        //if(isOwnerNew ||Test.isRunningTest()){
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
                            for(Case fetchEachCase : newList){
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
                        
                        //}
                    }
                //}
                //Code Added by Exafort - Ends
                
                
                
        }
        catch(Exception e){
            system.debug('Case Trigger - Update - Error Caught '+e.getMessage());
        }
        //CaseUtility.GSEMrunOnce Added by Exafort on 22 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295  
        if(CaseUtility.GSEMrunOnce()){
            
        }
        
        //  Added By Exafort TS-10404
        //if (Trigger.isBefore && Trigger.isInsert){            
            for (Case caseToProcess : newList){
                
                system.debug('caseToProcess.Peer_Flag_Inactive__c = ' + caseToProcess.Peer_Flag_Inactive__c);
                
                //  Stops the Case Creation with Peerflag inactive as True
                /*  Below error message commented by Exafort for SFDC-478   
                 *  As a part of SFDC-478, this validation rule is no longer required, user can set peer flag inactive to true 
                 */            
                /*if( caseToProcess.Peer_Flag_Inactive__c == True){
                    caseToProcess.addError('Peer Flag Inactive cannot be true when creating case');
                }*/
                
                //  Added by Exafort for SFDC-478
                /*  On Case creation, if the user sets the Peer_Flag_Inactive__c to True, it will be flipped to False if any of the following conditions are satisfied
                 *  Priority is 'P1'
                 *  If its a Critical Account Case
                 *  If Case account has PSM purchased
                */
                Account accountInfo = accountEntries.get(caseToProcess.AccountId);
                if(caseToProcess.Priority == 'P1' || caseToProcess.caseAccountCritical__c == true || (accountInfo != null && accountInfo.ACM_Service_Purchased__c == true)){
                    caseToProcess.Peer_Flag_Inactive__c = false;
                }
                //  End of SFDC-478
                
           
            }
        //}
    }
}
}