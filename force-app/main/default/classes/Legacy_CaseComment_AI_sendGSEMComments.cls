/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-27-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger sendGSEMComments on CaseComment (after Insert,after update) {
public with sharing class Legacy_CaseComment_AI_sendGSEMComments implements TriggerAction.AfterInsert{
    public void afterInsert(List<CaseComment> newList)  { 
    //if(Trigger.IsInsert && Trigger.Isafter){ 
        Map<Id,CaseComment> newMap = new Map<Id,CaseComment>(newList);     
        sendGSEMCommentHandler.gsemPPI(newMap);
         DCESyncCaseCommentController.insertCaseCommentsAndUpdateCaseDetails(newList);
    //}
    TriggerSettings__c settings = TriggerSettings__c.getInstance('DceSyncUpdate');
    String DCEIntAPIUser =Label.DCEIntegration_APIUser;
    if(settings !=null){
        if(!settings.Disable__c  && UserInfo.getUserId() != DCEIntAPIUser){
            //if(Trigger.isAfter && Trigger.isInsert){
                DCESyncCaseCommentController.caseCommentInsertDceSync(newList); 
            //}  
        }
    }
}
}