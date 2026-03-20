public class CaseProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-11-2015
    Functionality      : This apex class is called by Case object Trigger and it contains below mentioned 
                         functionality 
    
                        1. Update WorkOrder status based on change of Case Status to "Closed"           
    ***************************************************************************************************************/

    public static void updateRelatedWorkOrder(List<Case> csList){       
        Set<String> cNumber                 = new Set<String>();
        List<WorkOrder__c> woList           = new List<WorkOrder__c>();
        List<WorkOrder__c> woupdateList     = new List<WorkOrder__c>();
        Map<String,Case> cMap               = new Map<String,Case>();

        for(Case c : csList){
                cNumber.add(c.CaseNumber);
                cMap.put(c.CaseNumber,c);
            
        }  
        
        // Get all Case(s) against CaseNumber
        if(cMap.size() > 0)
            woList  = [ SELECT id,Nimble_Customer_Support_case__c,Support_Case_closed__c
                        FROM WorkOrder__c 
                        WHERE Nimble_Customer_Support_case__c in : cNumber];                         
        
        for(WorkOrder__c  wo : woList){
              if(cMap.containsKey(wo.Nimble_Customer_Support_case__c)&& cMap.get(wo.Nimble_Customer_Support_case__c).Status.startsWithIgnoreCase('Closed') )
                  wo.Support_Case_closed__c = true;
              else
                  wo.Support_Case_closed__c = false; 
              
              woupdateList.add(wo);
           
        } 
        
        if(woupdateList.size() > 0)
            update woupdateList;
    }

}