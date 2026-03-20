/*=====================================================================================================================================
Name                    : trigger_depot_stock_plan(TS-9448)
Description             : Logic to create 10 new depot stock schedule when depot stock plan is inserted
Author                  : 
Version                 : 1.0
Modification History    : Initial Version
Test class              : trigger_depot_stock_planTest
=====================================================================================================================================
*/

trigger trigger_depot_stock_plan on depot_stock_plan__c (after insert) {
    
    if(Trigger.isAfter){
        
        List<depot_stock_schedule__c> depotStockSchedule = New List<depot_stock_schedule__c>();
        
        for(depot_stock_plan__c deptStockPlan : Trigger.New) {
            for (Integer i = 0; i < 10; i++) {
                depot_stock_schedule__c depotStockSch = new depot_stock_schedule__c ();
                depotStockSch.Stock_Plan__c           = deptStockPlan.Id;
                depotStockSch.Demand_Qty__c           = i * 10;
                depotStockSch.Desired_On_Hand_Qty__c  = i;
                depotStockSchedule.add(depotStockSch);
            }    
        }
        
        if(depotStockSchedule.size() > 0){
            try {             
                insert depotStockSchedule; 
            } catch (system.Dmlexception e) {
                system.debug(e);
            }                  
        }
    }
    
}