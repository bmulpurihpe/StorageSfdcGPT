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
public with sharing class Legacy_Case_AU_CaseTriggerV1 implements TriggerAction.AfterUpdate {
    //{//System.debug('DEBUG: (CaseTrigger) ===== ENTERED');
    //System.debug('DEBUG: (CaseTrigger) ===== getQueries = ' + Limits.getQueries());
public void afterUpdate(List<Case> newList, List<Case> oldList){
    //Added by exfort for TS-10445
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
       
         //if(Trigger.isAfter && Trigger.isUpdate){
            //Ntelkar added changes for TS-9823
            Map<Id,Case> oldMap = new Map<Id,Case>(oldList);
            List<Case> closedCases = new List<Case>();
            Set<Id> alternateContactCases1 = new Set<Id>();
        
            //	Added by exafort for TS-10445
            set<id> severeAccountIdCheck = new set<id>(); 
            for(Integer i = 0; i<newList.size(); i++){
                Case nCase = newList.get(i);
                Case oCase = oldList.get(i);
                if((nCase.Status == 'Closed' || nCase.Status == 'Closed(Duplicate)') && 
                   nCase.Status != oCase.Status &&
                   (UserInfo.getUserId() == CaseUtility.NIMBLE_SUPPORT_USER_ID || Test.isRunningTest())){
                   
                   closedCases.add(nCase);
                }
                
                if(oCase.Alternate_Contact_Name__c != nCase.Alternate_Contact_Name__c ) {
                    alternateContactCases1.add(nCase.Id);
                }
                //	Added by exafort for zerto TS-10445
                if((nCase.Status == 'Closed' || nCase.Status == 'Closed(Duplicate)') && nCase.Status != oCase.Status){
                    if(nCase.AccountId != null){
                        severeAccountIdCheck.add(nCase.AccountId); 
                    }
                }                  
            }

            //	Added by exafort for TS-10445
            set<id> severeAccountId = CaseUtility.getManagementEscalationWithAccountsInCodeRedSeverity(severeAccountIdCheck); 
            if(severeAccountId != null){
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                for(Case cas : [select id,CaseNumber,Account.Name,AccountId,Status,Owner.Email,Owner.Type,
                                Account.Primary_PSM__r.Email,Account.Secondary_PSM__r.Email,Auto_Close__c from case where Id IN :newMap.keySet()]){
                    List<String> toEmailList = CaseUtility.getEmailToAddressFromCaseOfAccountRed(cas);
                    //	Added By Exafort for SFDC-1245
                    if(severeAccountId.contains(cas.AccountId) && toEmailList != null && cas.Auto_Close__c != true){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toEmailList);
                        Messaging.SingleEmailMessage renderResult = Messaging.renderStoredEmailTemplate(
                            System.Label.Case_Closed_CodeRed_Escalation_Alert_Template_Id,
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
            //	End of TS-10445
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
        //}

        try{
            
            
            //if(Trigger.isUpdate){
                set<Id> caseID = new set<Id>(); //set of ID's to hold incoming case ID
                for(Case cas : newList){
                    
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
                //if(trigger.isAfter && trigger.isUpdate && assetPreventRecursiveV1.runOnce()){
                if(assetPreventRecursiveV1.runOnce()){
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
                        system.debug('caseRecordList.RecordTypeId'+caseRecordList.RecordTypeId);
                        system.debug('opsCaseRecordTypeId'+opsCaseRecordTypeId);
                        system.debug('caseRecordList.CaseMapping__c'+caseRecordList.CaseMapping__c);
                        system.debug('caseRecordList.CaseDocket__c'+caseRecordList.CaseDocket__c);
                        
                        system.debug('caseRecordList.status '+caseRecordList.status );
                        system.debug('caseRecordList.CaseDocket__r.cddonotupdateparentcase__c'+caseRecordList.CaseDocket__r.cddonotupdateparentcase__c);
                        
                        if(caseRecordList.RecordTypeId == opsCaseRecordTypeId && caseRecordList.CaseMapping__c != null && caseRecordList.CaseDocket__c !=null)
                        {
                            Case oldCase = oldMap.get(caseRecordList.Id);
                             system.debug('oldCase.status '+oldCase.status );
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
                for(Case caseLoop : newList){
                    //Added By vishnu for TS-8555
                    // If condition updated by Exafort for SFDC-822
                    if(!UserInfo.getUserName().containsIgnoreCase('cokeva') && !UserInfo.getUserName().containsIgnoreCase('supportforce@nimblestorage.com') && 
                       !UserInfo.getUserName().containsIgnoreCase('supportautomation@nimblestorage.com')){
                        //Case status is 'Closed' and Root cause is 'Software Bug' and Case is related to Nimble Product 'Yes' and No bug record is exist, throw an error
                        if(caseLoop.Status == 'Closed' && caseLoop.casCatClosureRootCause__c == 'Software Bug' && caseLoop.caseIsThisCaseRelatedToANimbleProduct__c == 'Yes' && bugList.size() == 0 && UserInfo.getUserId() != NIMBLE_SUPPORT_USER_ID && oldMap.get(caseLoop.Id).Status != caseLoop.Status && caseLoop.Sub_Status__c != 'Duplicate'){
                            
                            caseLoop.addError('Bugs Required to close a case if Root Cause is \'Software Bug\' and Case is Related to Nimble is \'Yes\'');
                        }
                        if(caseLoop.Status == 'Closed' && caseLoop.casCatClosureRootCause__c == 'Software Bug' && caseLoop.caseIsThisCaseRelatedToANimbleProduct__c == 'Yes' && bugList.size() == 0 && UserInfo.getUserId() == NIMBLE_SUPPORT_USER_ID && IsSoftwareBugActivated == true && oldMap.get(caseLoop.Id).Status != caseLoop.Status && caseLoop.Sub_Status__c != 'Duplicate'){
                             
                            caseLoop.addError('Bugs Required to close a case if Root Cause is \'Software Bug\' and Case is Related to Nimble is \'Yes\'');
                        }
                    }
                   //END of validation for closing a case. 
                    
                    //Added on 28th Sept 2016 - New Case Comment if Case is closed as Duplicate - By Azar  
                    
                    //if(Trigger.isUpdate && Trigger.isAfter){
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
                            if(oldMap.get(caseLoop.Id).AttnSnoozeIntervalInHours__c == null && caseLoop.AttnSnoozeIntervalInHours__c !=null && caseLoop.caseAttnReqDateTimeHelper__c != null){
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
                            if(oldMap.get(caseLoop.Id).AttnSnoozeIntervalInHours__c != null && caseLoop.AttnSnoozeIntervalInHours__c !=null && oldMap.get(caseLoop.Id).AttnSnoozeIntervalInHours__c != caseLoop.AttnSnoozeIntervalInHours__c  && caseLoop.caseAttnReqDateTimeHelper__c != null){
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
                            if(oldMap.get(caseLoop.Id).caseEngageNCVBilling__c == false && caseLoop.caseEngageNCVBilling__c == true){
                                CaseComment ncvBillingEmail = new CaseComment();
                                ncvBillingEmail.CommentBody = 'Email Sent To Accounts Receivable and the Portal team \n\n The following case has been referred to you for ncv billing issues. \n\n***************************\nCase: '+caseLoop.CaseNumber+'\nStatus: '+caseLoop.Status+'\nPriority Level: '+caseLoop.Priority+'\nSubject: '+caseLoop.Subject+'\nDescription: '+caseLoop.Description+'\n\n'+caseLoop.Thread_Id__c;
                                ncvBillingEmail.IsPublished = False;
                                ncvBillingEmail.ParentId = caseLoop.Id;
                                ncvBillingEmailSentComment.add(ncvBillingEmail);
                            }
                            //Added by exafort(vishnu) for SLA Expiry
                            string OldOwnerId = oldMap.get(caseLoop.Id).OwnerId;
                            string newOwnerId = caseLoop.OwnerId;
                            system.debug('Old Owner====> '+oldMap.get(caseLoop.Id).OwnerId);
                            system.debug('New Owner====> '+caseLoop.OwnerId);
                            system.debug('SLA When Owner Changed===> '+caseLoop.SLAWhenOwnerChanged__c);
                            if((oldMap.get(caseLoop.Id).OwnerId != caseLoop.OwnerId && OldOwnerId.startsWith('00G') && !newOwnerId.startsWith('00G') && caseLoop.SLAWhenOwnerChanged__c != null)||Test.isRunningTest()){
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
                            for(Case eachCaseRec : newList){
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
                    //}            
                }
                //Code Added by Exafort - Starts
                
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
       
        }

    }  
}