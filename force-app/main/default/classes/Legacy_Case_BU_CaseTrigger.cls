/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-16-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-15-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger CaseTrigger on Case (before insert, after insert, after update, before update)
public with sharing class Legacy_Case_BU_CaseTrigger implements TriggerAction.BeforeUpdate {
 
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
//{//System.debug('DEBUG: (CaseTrigger) ===== ENTERED');
    //System.debug('DEBUG: (CaseTrigger) ===== getQueries = ' + Limits.getQueries());
    if(CaseUtility.CASETRIGGER_FLAG )
    {
        Map<String, Id> caseTeamRolesMap = new Map<String, Id>(); 
        Map<Id,Case> oldMap = new Map<Id,Case>(oldList);
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
        //Added by Exafort for TS-4483
        //if (Trigger.isBefore && Trigger.isUpdate){
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
            for (Case caseToProcess : newList){
                case oldCaseRec = oldMap.get(caseToProcess.id);
                
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
                // Added by Exafort for SFDC-1642
                // when a case is accepted by the user from any Queue the status should be New And sub status should be Assigned.
                if (caseToProcess.Status == 'New' && String.valueOf(oldCaseRec.OwnerId).startsWith('00G') && oldCaseRec.OwnerId != caseToProcess.OwnerId && String.valueOf(caseToProcess.OwnerId).startsWith('005')) {
                    caseToProcess.Sub_Status__c = 'Assigned';
                }
                //	End of SFDC-1642
                
                // Added by Exafort for SFDC-1664
                // The method is being invoked to set the Timer Expiry Date when the Case Status and Sub Status are updated from the Public Comment page.
                if ((caseToProcess.Timer_Expiry_Date__c == oldCaseRec.Timer_Expiry_Date__c && caseToProcess.Status != 'On hold' && caseToProcess.Status != 'Remote Session Scheduled' &&
                    (caseToProcess.Status != oldCaseRec.Status || caseToProcess.Sub_Status__c != oldCaseRec.Sub_Status__c)) || caseToProcess.isClone()) {
                    CaseUtility.applyTimerDuration(caseToProcess, caseToProcess.Status, caseToProcess.Sub_Status__c, caseToProcess.X3_Strike__c);
                } 	
                //	End of SFDC-1664
                //  Added by Exafort for SFDC-1988
                if (!CaseUtility.isNimbleSupportUser() && !CaseUtility.isSupportAutomationUser() && !CaseUtility.isEmailIncoming && !CaseUtility.isSupportProviderProfileUser() && !CaseUtility.isSupportProviderH3CProfileUser() && CaseUtility.isCommentInsert) {
                    if(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseToProcess.RecordTypeId).getName() == 'Array Case' || Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseToProcess.RecordTypeId).getName() == 'SSaaS'){
                        if(caseToProcess.Status == null){
                            caseToProcess.addError('Case Status cannot be blank. Please select a status.'); 
                        }
                        if ((caseToProcess.Status == 'Waiting on Internal' || caseToProcess.Status == 'Waiting on Customer' || caseToProcess.Status == 'In Progress' )  && caseToProcess.Sub_Status__c == null ){
                            caseToProcess.addError('Sub-Status cannot be blank when Status is: "'+ caseToProcess.Status +'"');
                        }  
                        if (caseToProcess.Status == 'Closed' && oldCaseRec.Status != 'Closed'){
                            caseToProcess.addError('Case status cannot be changed to  "'+ caseToProcess.Status +'"' + ' from Comment page.');
                        }
                        if ((caseToProcess.Status == 'Remote Session Scheduled' && oldCaseRec.Status != 'Remote Session Scheduled') || (caseToProcess.Status == 'On Hold' && oldCaseRec.Status != 'On Hold')) {
                            caseToProcess.addError('Case status cannot be changed to  "'+ caseToProcess.Status +'"' + ' from Comment page.'  );
                        }
                        if ((caseToProcess.Status == 'Handover' && oldCaseRec.Status != 'Handover') || (caseToProcess.Status == 'Update Needed' && oldCaseRec.Status != 'Update Needed')) {
                            caseToProcess.addError('The Status "' + caseToProcess.Status + '" should not be set manually'  );
                        }
                    }
                }
                //  End of SFDC-1988
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
                
                //Ntelkar added changes for TS-9823
                Set<Case> alternateContactCases = new Set<Case>();
                Map<Id, Id> mapOfCaseIdAndContactId = new Map<Id,Id>();
                
                //The first validation is for the existing Case records and the second validation is for the New Case Record
                if(oldCaseRec.Alternate_Contact_Name__c != caseToProcess.Alternate_Contact_Name__c){
                    if(!mapOfCaseIdAndContactId.containsKey(caseToProcess.Id)){
                       mapOfCaseIdAndContactId.put(caseToProcess.Id, caseToProcess.Alternate_Contact_Name__c);//create a map of current case record id and contact id in current ase record
                    }alternateContactCases.add(caseToProcess);
                }
                if(!mapOfCaseIdAndContactId.isEmpty()) {
                    Map<ID, Contact> mapOfContacts = new Map<ID, Contact>([SELECT Id, Phone, Email, Name FROM Contact WHERE Id IN:mapOfCaseIdAndContactId.values() ]);//fetch contact records for all the contacts in the map created above
                    //for the new cases that passed validations, update the alternate contact fields in case record
                    for(Case cas : alternateContactCases){
                        //if the Alternate contact name is changed to something other than null, then execute if, otherwise execute else
                        if(mapOfContacts.size() > 0){
                            caseToProcess.Alternate_Contact_Phone__c = mapOfContacts.get(mapOfCaseIdAndContactId.get(cas.Id)).Phone; 
                            caseToProcess.Alternate_Contact_Email__c = mapOfContacts.get(mapOfCaseIdAndContactId.get(cas.Id)).Email;
                        }else{
                            caseToProcess.Alternate_Contact_Phone__c = null;
                            caseToProcess.Alternate_Contact_Email__c = null;
                        }
                    }
                }
                
                
                /* Start TS-10254 Mulpuri 11/2/2023*/
                if(caseToProcess.Status =='Awaiting Customer' && oldCaseRec.Status != caseToProcess.Status && String.isBlank(caseToProcess.Sub_Status__c) )
                {
                    caseToProcess.Sub_Status__c ='Complete Action Plan'; 
                }
                //End
                
                 // Added by Exafort TS-10063 and TS-10480 start
                Case caseToProcessOld = oldMap.get(caseToProcess.id);
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
                
                // Removed the code by Exafort for SFDC-1696
                // Not required to update the First Customer Contact field on Case update. Logic is handled in Legacy_EmailMessage_AI_OpenCase
                /*if(caseToProcess.Last_Public_Comment__c != null && caseToProcessOld.Last_Public_Comment__c == null && caseToProcess.First_Customer_Contact__c == null){
                    caseToProcess.First_Customer_Contact__c = caseToProcess.Last_Public_Comment__c;
                }*/
                // End	SFDC-1696
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
                for(Case cas:newList){
                    case oldCaseRec = oldMap.get(cas.id);
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
            
            //  SFDC-307 End 
            
            }
        
       
        //Added on 07/19/2016 - contains validations to close a case - By Azar
        try{
            
            //if(Trigger.isUpdate){
                set<Id> caseID = new set<Id>(); //set of ID's to hold incoming case ID
                for(Case cas : newList){
                    
                    caseID.add(cas.id); //Put case ID's to set of ID's
                    if(CaseUtility.caseRecordIds.size() == 0)
                        CaseUtility.caseRecordIds.add(cas.id);
                }
                List<Bug__c> bugList = new List<Bug__c>(); //List of Bug object to query with case ID
                
                
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
                
                
                //Added End to avoid recursive
                for(Case caseLoop : newList){
                    //Added By vishnu for TS-8555
                    // If condition updated by Exafort for SFDC-822
                    system.debug('is Duplicate' + caseLoop.isDuplicate__c);
                    system.debug('Status' + caseLoop.Status);
                    system.debug('Sub Status' + caseLoop.Sub_Status__c);
                    if(!UserInfo.getUserName().containsIgnoreCase('cokeva') && !UserInfo.getUserName().containsIgnoreCase('supportforce@nimblestorage.com') && 
                       !UserInfo.getUserName().containsIgnoreCase('supportautomation@nimblestorage.com')){
                        //Case status is 'Closed' and Root cause is 'Software Bug' and Case is related to Nimble Product 'Yes' and No bug record is exist, throw an error
                        if(caseLoop.Status == 'Closed'  && caseLoop.casCatClosureRootCause__c == 'Software Bug' && caseLoop.caseIsThisCaseRelatedToANimbleProduct__c == 'Yes' && bugList.size() == 0 && UserInfo.getUserId() != NIMBLE_SUPPORT_USER_ID && oldMap.get(caseLoop.Id).Status != caseLoop.Status && caseLoop.Sub_Status__c != 'Duplicate'){
                             system.debug('in 1st Loop');
                            caseLoop.addError('Bugs Required to close a case if Root Cause is \'Software Bug\' and Case is Related to Nimble is \'Yes\'');
                        }
                        if(caseLoop.Status == 'Closed'  && caseLoop.casCatClosureRootCause__c == 'Software Bug' && caseLoop.caseIsThisCaseRelatedToANimbleProduct__c == 'Yes' && bugList.size() == 0 && UserInfo.getUserId() == NIMBLE_SUPPORT_USER_ID && IsSoftwareBugActivated == true && oldMap.get(caseLoop.Id).Status != caseLoop.Status && caseLoop.Sub_Status__c != 'Duplicate'){
                            system.debug('in 2nd Loop');
                            caseLoop.addError('Bugs Required to close a case if Root Cause is \'Software Bug\' and Case is Related to Nimble is \'Yes\'');
                        }
                    }
                    //END of validation for closing a case. 
                    //Calculate GMT and send email alert when priority is P1
                    //if(Trigger.isUpdate && Trigger.isBefore){
                        if((oldMap.get(caseLoop.Id).Priority != 'P1' && caseLoop.Priority == 'P1' && caseLoop.Status != 'Closed') || (oldMap.get(caseLoop.Id).Status == 'Closed' && caseLoop.Status == 'Open' && caseLoop.Priority == 'P1')){
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
                        string OldOwnerId = oldMap.get(caseLoop.Id).OwnerId;
                        string newOwnerId = caseLoop.OwnerId;
                        if(oldMap.get(caseLoop.Id).OwnerId != caseLoop.OwnerId && OldOwnerId.startsWith('00G') && !newOwnerId.startsWith('00G')){
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
                    //}
                    
                    //Added on 28th Sept 2016 - New Case Comment if Case is closed as Duplicate - By Azar  
                    
                              
                }
                //Code Added by Exafort - Starts
                //To throw an error when a H3C user is assigning to Non-H3C case
                //if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
                    if(RecursiveTriggerRestrictiion.runOnce()){
                        Boolean isOwnerNew = false;
                        for(Case eachCase : newList){
                            if(oldMap.get(eachCase.Id).OwnerId != eachCase.OwnerId){
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
                        }
                    }
                //}
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
            //}
        }
        catch(Exception e){
            system.debug('Case Trigger - Update - Error Caught '+e.getMessage());
        }
        //CaseUtility.GSEMrunOnce Added by Exafort on 22 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295  
        if(CaseUtility.GSEMrunOnce()){
            //TS-6918 validation on case to close the related Onsite tasks and GSEM's before closing the case - By Vishnu on 14th Feb 2020.
            //if (Trigger.isBefore && Trigger.isUpdate){
                Set<Id> caseIds = new Set<Id>();
                for(case aCaseRec:newList){
                    system.debug(' VVV Cases  1 ===>');
                    Case OldCaseRec = oldMap.get(aCaseRec.Id);
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
                for(Case aCaseRecord : newList) {
                    Case OldCaseRecord = oldMap.get(aCaseRecord.Id);
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
            
            // else if (Trigger.isBefore && Trigger.isUpdate){
            for (Case caseToProcess : newList){
                Case oldCase = oldMap.get(caseToProcess.Id);
                
                //	Added by Exafort for SFDC-478
                Account accountInfo = accountEntries.get(caseToProcess.AccountId);
                Boolean peerFlagSetToTrue = oldCase.Peer_Flag_Inactive__c == false && caseToProcess.Peer_Flag_Inactive__c == true;
                //	Check if the Peer Flag Inactive checkbox is currently set to True
                if(caseToProcess.Peer_Flag_Inactive__c == True){
                    /*	If any of the following conditions are met, update Peer Flag Inactive to False:
                    *	Case priority is being updated to P1
                    *	RMA is newly associated with the case
                    *	If its a Critical Account Case
                    *	If Case account has PSM purchased
                    */
                    if((oldCase.Priority != 'P1' && caseToProcess.Priority == 'P1') || 
                       (caseToProcess.caseRMAAssociated__c == true) || 
                       caseToProcess.caseAccountCritical__c == true ||
                       (accountInfo != null && accountInfo.ACM_Service_Purchased__c == true)){
                           caseToProcess.Peer_Flag_Inactive__c = false;
                       }
                }
                //	End of SFDC-478
                
                //  To Show validation error for the below conditions
                If( caseToProcess.Peer_Flag_Inactive__c == True && caseToProcess.Priority == 'P1'){
                    //  Peer Flag inactive cannot be made true for P1 case 
                    caseToProcess.addError('Peer Flag Inactive cannot be true for P1 case');
                }else If( peerFlagSetToTrue && caseToProcess.caseRMAAssociated__c == True){
                    //  Peer Flag inactive cannot be made true for Case with RMA
                    caseToProcess.addError('Peer Flag Inactive cannot be true as this case has RMA');
                }else If( peerFlagSetToTrue && caseToProcess.caseAccountCritical__c == True){
                    //  Peer Flag inactive cannot be made true for Case for Critical account cases
                    caseToProcess.addError('Peer Flag Inactive cannot be true as this is a Critical Account Case');
                }
                
                //Account accountInfo = accountEntries.get(caseToProcess.AccountId);
                system.debug('accountInfo === ' + accountInfo);
                if (accountInfo != null){
                    //  If PSM purchased, Peer flag inactive can't be set to true
                    If( peerFlagSetToTrue && accountInfo.ACM_Service_Purchased__c == True){
                        caseToProcess.addError('Peer Flag Inactive cannot be true as Case\'s account has PSM purchased');
                    }
                }
            }
       // }
            }
        }
    //}
    

    }   

}