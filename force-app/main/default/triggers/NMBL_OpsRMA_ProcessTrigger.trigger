trigger NMBL_OpsRMA_ProcessTrigger on Ops_RMA__c (before insert,before update,after insert,after update) {

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 11-10-2015
    Functionality      : This Trigger on Asset contains below mentioned functionality 
    Change Log         : PA(3/20/2016) - Included logic to close rmas
    1. update Nimble version on Work Order Lines           
    ***************************************************************************************************************/
    List<Ops_RMA__c> OpRMAList = new  List<Ops_RMA__c>();
    if(Trigger.isBefore){
        for(Ops_RMA__c opR : Trigger.new){
            if(Trigger.IsUpdate && (Trigger.oldMap.get(opR.Id).Current_Location__c != opR.Current_Location__c || Trigger.oldMap.get(opR.Id).EFA_Priority__c != opR.EFA_Priority__c)){
                   OpsRMAProcessClass.UpdateOpsRMA(Trigger.old,Trigger.new);           
            }
            if(Trigger.IsUpdate){
                OpsRMAProcessClass.UpdateOpsRMA_v2(Trigger.old,Trigger.new);
            }
        }
         
    }
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert){
            OpsRMAProcessClass.CloseRMAs(Trigger.new, null, true);
        }
        if(Trigger.isUpdate){
            if(NMBLOpsRMAProcessTriggerRecursive.runOnce() && OpsRMAProcessClassAvoidRecursive.runOnce()){
                OpsRMAProcessClass.CloseRMAs(Trigger.new, Trigger.old, false);
            }
        }
            
    }
}