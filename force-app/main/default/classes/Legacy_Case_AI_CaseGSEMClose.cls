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
public with sharing class Legacy_Case_AI_CaseGSEMClose implements TriggerAction.AfterInsert{
//trigger caseGSEMClose on Case (after insert,after update) {   
    TriggerSettings__c settings = TriggerSettings__c.getInstance('DCECaseSync');
    String DCEIntAPIUser =Label.DCEIntegration_APIUser;
    //if(UserInfo.getUserId() != DCEIntAPIUser){
    public void afterInsert(List<Case> newList)  {
    if(UserInfo.getUserId() != DCEIntAPIUser) {
        if(settings !=null){
            if(!settings.Disable__c ){
                //if(Trigger.isAfter && Trigger.isInsert){
                    DceSyncController.getCaserecord(newList);  
                //}  
                
            }
        }
       
    }
}
}