trigger NMBL_SalesOrderLine_ProcessTrigger on Sales_Order_Line__c (before insert,before update,after insert,after update) {
    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-11-2015
    Functionality      : This Trigger on Sales Order Line contains below mentioned functionality 
    
    1. update Pro Install Flag to True on Sales Order Line.          
    ***************************************************************************************************************/
    List<Sales_Order_Line__c> soLList  = new List<Sales_Order_Line__c>();
    if(Trigger.isAfter){
        for(Sales_Order_Line__c soL : Trigger.new){
            if(Trigger.IsInsert || (Trigger.IsUpdate && Trigger.oldMap.get(soL.Id).Product__c != soL.Product__c)){
                if(soL.Product__c != null)  
                    soLList.add(soL) ;
            }
        }   
    }
    
    if(soLList.size() > 0)
    {
        SalesOrderLineProcessClass.UpdateSalesOrderFields(soLList); 
        
    }
    //***Code written By Saurav-Mansa Systems****
    //Code for Upgrade Serial Number
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            SalesOrderLineProcessClass.SerialNumbersForUpgradeQuotes(Trigger.new);
        }
        
        //Code for Start Date on Revenue Order Lines
        if(Trigger.isInsert)
        {
            SalesOrderLineProcessClass.StartDateOnRevenueOrderLines(Trigger.new);
        }
    }
    //***End of Code by Saurav***
    
}