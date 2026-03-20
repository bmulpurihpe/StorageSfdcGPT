public class WorkOrderProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-11-2015
    Functionality      : This apex class is called by WorkOrder object Trigger and it contains below mentioned 
                         functionality 
    
                        1.Update Support Case Status Field based on relevant Nimble Customer Support case number.           
    ***************************************************************************************************************/
    
    public static void updateWorkOrder(List<WorkOrder__c> woList){       
        Set<String> cNumber         = new Set<String>();
        Set<Id> woId                = new Set<Id>();
        List<Case> caseList         = new List<Case>();
        Map<String,Case> cMap       = new Map<String,Case>();

        for(WorkOrder__c wo : woList){
          if(wo.Nimble_Customer_Support_case__c != null)
              cNumber.add(wo.Nimble_Customer_Support_case__c);
        }  
        
        // Get all Case(s) against CaseNumber
        if(cNumber.size() > 0)
            caseList  = [ SELECT id,CaseNumber,Status
                          FROM Case
                          WHERE CaseNumber in : cNumber];
                          
        for(case c :caseList){
            cMap.put(c.CaseNumber,c);       
        } 
        
        
        for(WorkOrder__c  wo : woList){
              if(cMap.containsKey(wo.Nimble_Customer_Support_case__c)&& cMap.get(wo.Nimble_Customer_Support_case__c).Status.startsWithIgnoreCase('Closed') )
                  wo.Support_Case_closed__c = true;
              else
                  wo.Support_Case_closed__c = false; 
           
        } 
    }
     
    /*** Commented below code as a part of Installation Work Order Phase 3 Project ******
    public static void updateSalesOrder(List<WorkOrder__c> woList){ 
        List<Sales_Order__c> sorderList = new List<Sales_Order__c>();
        Set<Id> soId = new Set<Id>();
        for(WorkOrder__c wo : woList){
            soId.add(wo.Sales_Order_Lookup__c);
        }
        
        if(soId.size() > 0)
        sorderList  = [ SELECT Id,Installation_Work_Order__c
                        FROM Sales_Order__c
                        WHERE Id in: soId];
                        
        for(Sales_Order__c so: sorderList){
            if(so.Installation_Work_Order__c != true)
                so.Installation_Work_Order__c = true;
        }
        
        if(sorderList.size() > 0)
            update sorderList;
    }  
    
    **************************************************************************************/    
}