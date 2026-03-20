/*
=============================================================================================================
Description             : This Trigger is used to insert new case comment on parent case when new case comment 
is added on OPS Case
Created Date            : 28 April 2021 for TS-6417 BY EXAFORT(Guru Dev)
Test class              : CaseCommentInsertonParentcase_test
==============================================================================================================
*/  
trigger CaseCommentInsertonParentcase on CaseComment (before insert, after insert){
    Set <Id> caseCommIds = new Set <Id>();
    List<casecomment> cascommentlist = New List<casecomment>();
    List<casecomment> Insertcascommentlist = New List<casecomment>();
    List<Case> ParentCaseList = New List<Case>();////added by exafort for TS-8401 on 06/28/21 
    String DCEIntAPIUser =Label.DCEIntegration_APIUser;
    Map<Id, List<CaseComment>> mapOfCaseToCaseComments = new Map<Id, List<CaseComment>>();

    //Start Mulpuri 12/06/2023 TS-10270 
    if(Trigger.isBefore && Trigger.isInsert){
        for(Casecomment com: Trigger.new)
        {
            if(UserInfo.getUserId() == DCEIntAPIUser)
                com.IsPublished = True;
        }
    }
    // End

    //if(RecursiveCheck.runOnce){//to avoid recursion
    //RecursiveCheck.runOnce = false;
    if(Trigger.isAfter && Trigger.isInsert){
    for(CaseComment cc : Trigger.new) {
        //Only public comments to be added to parent case
        if(cc.IsPublished){
            caseCommIds.add(cc.ParentId);
            cascommentlist.add(cc);                        
        }                
        if(cc.CommentBody != null){
            System.debug('Getting map ready');
            if(mapOfCaseToCaseComments.get(cc.ParentId)!=null){
                mapOfCaseToCaseComments.get(cc.ParentId).add(cc);
            }else{
                mapOfCaseToCaseComments.put(cc.ParentId,new List<CaseComment>{cc});
            }
        }               
    } 
    
    if(caseCommIds.size() > 0){
        if(RecursiveCheck.runOnce){//to avoid recursion
            RecursiveCheck.runOnce = false;
            List<case> caselist = New List<case>();//list to hold case records
            caselist = [select id, Owner.Id, Owner.Name, Owner.Type,RMAmapped__r.rmaCaseNumber__c,
                        caseBUteam__c,CaseNumber,casePachinkoCaseType__c,caseAttnReq__c,
                        RecordTypeId, OPSCaseRMAMappedCase__c,CaseMapping__c,CaseDocket__r.cdDoNotSetParentCaseARF__c,
                        CaseDocket__r.cddonotupdateparentcase__c from case where Id IN: caseCommIds];
            system.debug('caselist----'+caselist);
            Id OPSCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId();
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            List<Case> attentionCasesUpdate = new List<Case>();
            for(Case cas : caselist){//looping the case records
                if(!mapOfCaseToCaseComments.isEmpty()){
                    System.debug('Map is not empty');
                    for(CaseComment caseComm : mapOfCaseToCaseComments.get(cas.Id) ){
                        System.debug('Is the comment body starting with account:'  +caseComm.CommentBody.containsIgnoreCase('[account:'));
                        if(cas.caseAttnReq__c && ((cas.RecordTypeId == Schema.SObjectType.case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId()) || 
                                              (cas.RecordTypeId == Schema.SObjectType.case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId())) &&
                                               (!caseComm.CommentBody.containsIgnoreCase('[account:')) &&
                                              ( UserInfo.getUserId() != DCEIntAPIUser)
                                         ) {//for recordType Array and SSaaS.
                            System.debug('Turning off the flag when comments are published for Array Case and SSaaS-TS-10304');
                            cas.caseAttnReq__c = false;
                            attentionCasesUpdate.add(cas);
                        }//Added for TS-10016 , TS-10455
                    }
                    
                }else{
                    System.debug('Oh No... Map is empty');
                }
                
                if(cas.RecordTypeId == OPSCaseRecordTypeId  && cas.CaseMapping__c != null && !cas.CaseDocket__r.cddonotupdateparentcase__c){//Check for OPS case
                    for(casecomment csc : cascommentlist){
                        Casecomment newcomment = New Casecomment();
                        //newcomment.CommentBody = '*** RELATED }}{{'+ cas.caseBUteam__c +' CASE UPDATE ('+ cas.casePachinkoCaseType__c +':'+cas.CaseNumber+') '
                        newcomment.CommentBody = '*** RELATED '+ cas.caseBUteam__c +' CASE UPDATE ('+ cas.casePachinkoCaseType__c +':'+cas.CaseNumber+')\n'
                            + baseUrl + '/' + cas.id +'\n\n'+ csc.CommentBody;
                        newcomment.ParentId = cas.CaseMapping__c;
                        if(UserInfo.getUserId() != DCEIntAPIUser)
                        newcomment.IsPublished = false;
                        Insertcascommentlist.add(newcomment);//list holds the new comment  
                        ////added by exafort for TS-8401 on 07/09/21
                        if(!cas.CaseDocket__r.cdDoNotSetParentCaseARF__c){
                            Case parentCase = New case();
                            parentCase.Id = cas.CaseMapping__c;
                            parentCase.caseAttnReq__c = True;
                            parentCase.caseAttnReqCreator__c  =  UserInfo.getName() +' ('+UserInfo.getUserEmail()+')';
                            parentCase.caseAttnReqDateTime__c = system.now();
                            parentCase.caseAttnReqSource__c ='Ops Case Update';
                            parentCase.AttnSnoozeIntervalInHours__c = null;
                            parentCase.caseAttnReqSnoozeReason__c = null;
                            ParentCaseList.add(parentCase); 
                        }
                        //Added end
                    }
                }  
            }
            
            if(Insertcascommentlist.size() > 0){
                insert Insertcascommentlist;
            }
            if(ParentCaseList.size() > 0){////added by exafort for TS-8401 on 06/28/21
                update ParentCaseList;
            }if(attentionCasesUpdate.size() > 0)
                update attentionCasesUpdate;//Added for TS-10016
        }
    }
    }
    
}