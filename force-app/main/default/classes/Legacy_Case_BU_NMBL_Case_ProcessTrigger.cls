/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : Nagalaxmi Telkar 
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-20-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger NMBL_Case_ProcessTrigger on Case (before insert,before update,after insert,after update) {
public with sharing class Legacy_Case_BU_NMBL_Case_ProcessTrigger implements TriggerAction.BeforeUpdate{
    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 10-01-2015
    Functionality      : This Trigger on Case object contains below mentioned functionality 
    
    1. update related WorkOrder Status based on change of Case Status.           
    ***************************************************************************************************************/
public void beforeUpdate(List<Case> newList, List<Case> oldList){
  if((!UserInfo.getUserId().contains('00580000005J7vc') && UserInfo.getUserId() != System.Label.DCEIntegration_APIUser) 
            || Test.isRunningTest())
{
    List<Case> csList = new List<Case>();
      
    if(csList.size() > 0)
        CaseProcessClass.updateRelatedWorkOrder(csList);
    }
}
}