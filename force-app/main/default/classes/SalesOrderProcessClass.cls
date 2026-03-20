public class SalesOrderProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-25-2015
    Functionality      : This apex class is called by SalesOrder object Trigger and it contains below mentioned 
                         functionality 
    
                                  
    ***************************************************************************************************************/

    public static void InsertWorkOrder(List<Sales_Order__c> SOList){
        Set<Id> SoIdSet                          = new Set<Id>(); 
        Set<Id> SorderIdSet                      = new Set<Id>(); 
        Set<String> pcode                        = new Set<String>{'PRO-INSTALL-ARRAY','PRO-INSTALL-ARRAY1', 'PRO-INSTALL-ARRAY2'};
        List<Sales_Order__c>  sorderList         = new List<Sales_Order__c>(); 
        List<Sales_Order_Line__c>  soLineList    = new List<Sales_Order_Line__c>(); 
        List<WorkOrder__c>    wOrderList         = new List<WorkOrder__c>();
        List<WorkOrder__c>    woinsertList       = new List<WorkOrder__c>();
        Map<Id,Sales_Order_Line__c> soLineMap    = new Map<Id,Sales_Order_Line__c>();
        Map<Id,WorkOrder__c> woMap    = new Map<Id,WorkOrder__c>();
        string usrId = [select id,Alias,Profile.Name from User where Alias = 'oper' and Name = 'Operations' and Profile.Name ='Operations: Standard User' limit 1].Id;
        
        for(Sales_Order__c so : SOList){
          if(so.Status__c == 'Approved by OA' && so.SO_Number__c != null && so.Shipment_Date__c != null && so.Type__c != 'Eval Order')
            SoIdSet.add(so.Id);
        }   
        
        
        if(SoIdSet.size() > 0)
            sorderList  = [ SELECT id,Opportunity__c,Opportunity__r.Nimble_SE_to_perform_installation__c,Opportunity__r.Sales_Theater__c,SO_Number__c,Ship_to_Company__c
                            FROM Sales_Order__c
                            WHERE id in : SoIdSet ];
                            
                            
        for( Sales_Order__c so : sorderList ){
          if(so.Opportunity__r.Nimble_SE_to_perform_installation__c != true && so.Opportunity__r.Sales_Theater__c == 'NA')
              SorderIdSet.add(so.Id);        
        }   
        
        for( Sales_Order_Line__c sL : [Select id,Sales_Order__c,Nimble_Version__c,Product__c,Product__r.Productcode FROM Sales_Order_Line__c where Sales_Order__c in : SorderIdSet AND Product__r.Productcode in : pcode]){
          if(!soLineMap.containsKey(sL.Sales_Order__c))
              soLineMap.put(sL.Sales_Order__c,sL);    
        }  
       
        if(SorderIdSet.size() > 0)
            wOrderList = [SELECT id,Sales_Order_Lookup__c
                          FROM WorkOrder__c
                          WHERE Sales_Order_Lookup__c in :SorderIdSet];  
                      
        for( WorkOrder__c wo : wOrderList){
            woMap.put(wo.Sales_Order_Lookup__c,wo);
        }
                     
        for( Sales_Order__c so : sorderList){
           if(soLineMap.containsKey(so.Id) && !woMap.containsKey(so.Id)){
               WorkOrder__c wo = new WorkOrder__c();
               wo.Name = so.SO_Number__c+'-'+so.Ship_to_Company__c;
               wo.Sales_Order__c = so.SO_Number__c;
               wo.Sales_Order_Lookup__c = so.Id;
               wo.OwnerId = usrId;
               woinsertList.add(wo);
           }        
        } 
        
        if(woinsertList.size() > 0)
            insert woinsertList;
               
    }   
}