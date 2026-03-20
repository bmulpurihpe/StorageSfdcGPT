trigger NMBL_SalesOrder_ProcessTrigger on Sales_Order__c (before insert,before update,after insert,after update) {

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-11-2015
    Functionality      : This Trigger on Sales Order contains below mentioned functionality 
    
    1. on insert/update of sales order status to 'Approved by OA' a new WorkOrder will be created.          
    ***************************************************************************************************************/
    List<Sales_Order__c> soList = new List<Sales_Order__c>();
    if(Trigger.isAfter){
        for(Sales_Order__c so : Trigger.new){
            if(Trigger.IsInsert || (Trigger.IsUpdate && (Trigger.oldMap.get(so.Id).Shipment_Date__c != so.Shipment_Date__c || Trigger.oldMap.get(so.Id).Status__c != so.Status__c))){
                    soList.add(so);
            }   
        }             
    }
    if(soList.size() > 0)
        SalesOrderProcessClass.InsertWorkOrder(soList);
  
}