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
public with sharing class Legacy_Case_AU_CaseGSEMClose implements TriggerAction.AfterUpdate{
//trigger caseGSEMClose on Case (after insert,after update) {   

    public void afterUpdate(List<Case> newList, List<Case> oldList){
        
    TriggerSettings__c settings = TriggerSettings__c.getInstance('DCECaseSync');
    String DCEIntAPIUser =Label.DCEIntegration_APIUser;
    Map<Id,Case> oldMap = new Map<Id,Case>(oldList);
    Map<Id,Case> newMap = new Map<Id,Case>(newList);
    //if(UserInfo.getUserId() != DCEIntAPIUser){
    if(UserInfo.getUserId() != DCEIntAPIUser) {
        if(settings !=null){
            if(!settings.Disable__c ){
                 
                //if(Trigger.isAfter && Trigger.isUpdate){
                    set<Id> caseIds=new set<Id>();
                    for(case caserec:newList){
                        case old = oldMap.get(caserec.Id);
                        if(caserec.isDuplicate__c==false && caserec.ContactID!=null && caserec.ContactID!=old.ContactId){
                            caseIds.add(caserec.id);
                        }
                    }
                    if(!caseIds.isEmpty()){
                        DceSyncController.caseContactUpdateSync(caseIds);
                    }
                    DceSyncController.caseUpdateSync(newList, oldMap); 
                //}
            }
        }
        //if(trigger.isAfter && trigger.IsUpdate){
            caseGSEMCloseHandler.gsemClosePPI(newMap, oldMap);
        //}
    }
}
}