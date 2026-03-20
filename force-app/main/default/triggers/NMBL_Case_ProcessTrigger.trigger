trigger NMBL_Case_ProcessTrigger on Case (before insert,before update,after insert,after update) {
    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 10-01-2015
    Functionality      : This Trigger on Case object contains below mentioned functionality 
    
    1. update related WorkOrder Status based on change of Case Status.           
    ***************************************************************************************************************/
    if((!UserInfo.getUserId().contains('00580000005J7vc') && UserInfo.getUserId() != System.Label.DCEIntegration_APIUser) 
            || Test.isRunningTest())
{
    List<Case> csList = new List<Case>();
    if(Trigger.isAfter){
        for(Case c : Trigger.new){
            if(Trigger.IsInsert || (Trigger.IsUpdate && Trigger.oldMap.get(c.Id).Status != c.Status)){
                if(c.Status != null)
                    csList.add(c);
            }
        }    
    }
      
    if(csList.size() > 0)
        CaseProcessClass.updateRelatedWorkOrder(csList);
        }
    
}