/*
=============================================================================================================
Description             : This Trigger is used to insert new case comment on parent case when new case comment 
is added on OPS Case
Created Date            : 28 April 2021 for TS-6417 BY EXAFORT(Guru Dev)
Test class              : CaseCommentInsertonParentcase_test
==============================================================================================================
*/  
//trigger CaseCommentInsertonParentcase on CaseComment (before insert, after insert){
public with sharing class Legacy_CaseComment_BI_InsertOnParentCase implements TriggerAction.BeforeInsert{
    Set <Id> caseCommIds = new Set <Id>();
    List<casecomment> cascommentlist = New List<casecomment>();
    List<casecomment> Insertcascommentlist = New List<casecomment>();
    List<Case> ParentCaseList = New List<Case>();////added by exafort for TS-8401 on 06/28/21 
    String DCEIntAPIUser =Label.DCEIntegration_APIUser;
    Map<Id, List<CaseComment>> mapOfCaseToCaseComments = new Map<Id, List<CaseComment>>();
    //Start Mulpuri 12/06/2023 TS-10270 
    //if(Trigger.isBefore && Trigger.isInsert){
    public void beforeInsert(List<CaseComment> newList){
        for(Casecomment com: newList)
        {
            if(UserInfo.getUserId() == DCEIntAPIUser)
                com.IsPublished = True;
        }
    //}
    // End
    CaseUtility.isCommentInsert = true; // Added by Exafort SFDC-1988
    }

    //if(RecursiveCheck.runOnce){//to avoid recursion
    //RecursiveCheck.runOnce = false;
    
}