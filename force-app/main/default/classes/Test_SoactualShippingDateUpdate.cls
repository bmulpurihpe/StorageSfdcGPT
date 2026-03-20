@isTest(seeAllData=true)
private class Test_SoactualShippingDateUpdate {
    
   
   
     static testMethod void test1(){
       /* Account a1=new Account();
        a1.Name='AccTesting';
        a1.CurrencyIsoCode='USD';
        insert a1;
        
        Opportunity op1=new Opportunity();
        op1.Name='OpTesting';
        op1.Account=a1;
        op1.Type='Existing Business';
        op1.Sales_Area__c='NA COM West NorCal';
        op1.CloseDate=System.today()+30;
        op1.StageName='8-  Closed No Decision';
        op1.CurrencyIsoCode='USD';
        insert op1;
        
         Test.startTest();
        
        Sales_Order__c so=new Sales_Order__c();
        so.Status__c='Submitted to OA';
        so.Name='Testing';
        so.CurrencyIsoCode='USD';
        so.Type__c='Revenue';
        so.Opportunity__c=op1.id;
        insert so;
         Sales_Order__c so1=[select Status__c, Name,CurrencyIsoCode,Type__c,Opportunity__c from Sales_Order__c where id=:so.id];
        so1.Status__c='Approved by OA';
        update so1;
 */
         Test.startTest();
        set<Id> sid = new set<Id>(); 
        List<Sales_Order__c> so1=[select id,Status__c, Name,CurrencyIsoCode,Type__c,Opportunity__c from Sales_Order__c where Status__c='Submitted to OA' and id =: 'a1m2H000002ajbg'];
        for(sales_Order__c s1 : so1){
            sid.add(s1.id);
        }
        List<Sales_Order_Line__c> soline = [select Id, Serial_Number__c from Sales_Order_Line__c where sales_Order__c in: sid];
       for(Sales_Order__c s:so1){
           
      
         s.Status__c='Approved by OA';
         s.Type__c='Prebuild';
          s.SO_Number__c ='ABC1111';
           s.Actual_Shipment_Date__c =System.today()+25;
           s.Re_Certification_Flag__c = true;
           
           /////
            WorkOrder__c w=new WorkOrder__c();
              w.scheduled_ship_date__c=System.today()+30;
             w.Sales_Order_Lookup__c=s.id;
          insert w;
           /////
           
        }
        Database.SaveResult[] results = Database.Update(so1, false);
        
   
     ////////////////
      
       /* WorkOrder__c w=new WorkOrder__c();
              w.scheduled_ship_date__c=System.today()+30;
             w.Sales_Order_Lookup__c=soc.id;
              w.actual_ship_date__c=System.today()+25;
        w.Carrier__c='FXF-AVT';
              w.Tracking_1__c='3771977521';
              w.Ship_to_Address_2__c='William Childress';
              w.Ship_to_Address_1__c='265 Hegenberger Rd Ste 100';
              w.Ship_to_City__c='SAN LEANDRO';
              w.Ship_to_State__c='CA';
              w.Ship_to__c='94111-3628';
              w.Ship_To_Country__c='US';
              insert w;
        }
    
        
        Expedite_Request__c expTest1 =new Expedite_Request__c();
        expTest1.Sales_Order__c=soc.Id;
        expTest1.Target_Install_Date__c=System.today();
        insert expTest1;
        
       
   */
         Sales_Order__c soc=[select id from Sales_Order__c where Type__c=
                                    'Prebuild' Limit 1];
         
              

        
         Database.DeleteResult DR_Dels = Database.delete(soc,false);
         
        
         

       
        
        Test.stopTest();
   
    }
  
  
     

}