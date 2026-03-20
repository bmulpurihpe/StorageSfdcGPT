trigger NMBL_WorkOrder_ProcessTrigger on WorkOrder__c (After Insert, After Update, Before Insert, Before Update) {
    
    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-30-2015
    Functionality      : This Trigger on Work Order contains below mentioned functionality 
    
    1. on insert/update of "Nimble Customer Support Case" field update Support Case Status.         
    ***************************************************************************************************************/
    // Below recurssive condition is added by Sudhir on 30-5-2017
    //if(checkRecursive.runOnce()){ 
        System.debug('====1 Entered NMBL_WorkOrder_ProcessTrigger with values :: '+ trigger.new);
        List<WorkOrder__c> WoList         = new List<WorkOrder__c>(); 
        List<WorkOrder__c> WoAfterList    = new List<WorkOrder__c>(); 
        if(Trigger.isBefore){
        System.debug('====2 Entered isBefore with values :: '+ trigger.new);
         for(WorkOrder__c wo : Trigger.new){
             if(Trigger.IsInsert || (Trigger.IsUpdate && Trigger.oldMap.get(wo.Id).Nimble_Customer_Support_case__c != wo.Nimble_Customer_Support_case__c)) {
                 if( wo.Nimble_Customer_Support_case__c != null) 
                     WoList.add(wo);
             } 
         } 
              
        }
        
        System.debug('====3 isAfter is next');
        if(Trigger.isAfter){
         System.debug('====4 Entered isAfter with values :: '+ trigger.new);
         for(WorkOrder__c wo : Trigger.new){
             if(Trigger.IsInsert)
                 WoAfterList.add(wo);
         }
        }
        
        if( WoList.size() > 0)
         WorkOrderProcessClass.updateWorkOrder(WoList);
           
        /*if(WoAfterList.size() > 0)
         WorkOrderProcessClass.updateSalesOrder(WoAfterList);*/
        
        if( Utility.runWorkOrderTrigger==true){
         
            //if(updation.isfutureupdate!=true){
            new Installation_Work_Order_Trigger_Class().run();
            //}
        
        }
    //}    //End of recursion
         
}