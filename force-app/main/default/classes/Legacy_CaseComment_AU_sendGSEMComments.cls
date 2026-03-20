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
public with sharing class Legacy_CaseComment_AU_sendGSEMComments implements TriggerAction.AfterUpdate{
    public void afterUpdate(List<CaseComment> oldList, List<CaseComment> newList)  {  
    TriggerSettings__c settings = TriggerSettings__c.getInstance('DceSyncUpdate');
    String DCEIntAPIUser =Label.DCEIntegration_APIUser;
    if(settings !=null){
        if(!settings.Disable__c  && UserInfo.getUserId() != DCEIntAPIUser){
            Map<Id,CaseComment> oldMap = new Map<Id,CaseComment>(oldList); 
            //if(Trigger.isAfter && Trigger.isUpdate){
                DCESyncCaseCommentController.caseCommentUpdateDceSync(newList, oldMap);  
            //}
        }
    }
}
}