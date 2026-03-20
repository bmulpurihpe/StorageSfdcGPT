@isTest(seeAllData=True)
public class Test_OppUpdateFromSalesOrder {
    static testMethod void salesOrderInsertUpdate() {
        Opportunity opp = new Opportunity(Name='TestRollUp',StageName='Prospecting',CloseDate=System.today().addMonths(1));
            insert opp;
            
            Product2 p = new Product2(Name='TestRollup',IsActive=true,Productcode='Test');
            insert p;
            
            SBQQ__Quote__c quote = new SBQQ__Quote__c(  SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true);    
            insert quote;
            
            SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            line.SBQQ__ListPrice__c = 1000;
            line.BOM_Line_Number__c='1';
            line.SBQQ__Quantity__c = 1;
            insert line;          
          
        list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
            
            SBQQ__QuoteLine__c cline4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline4.SBQQ__RequiredBy__c=line.Id;
            cline4.SBQQ__Bundled__c=true;
            cline4.SBQQ__BundledQuantity__c=5;
            cline4.SBQQ__ListPrice__c = 1000;
            cline4.BOM_Line_Number__c='1';
            cline4.SBQQ__OptionType__c = 'Component';
            cline4.SBQQ__Quantity__c = 7;
           
            listQl.add(cline4);
            
            SBQQ__QuoteLine__c cline5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline5.SBQQ__RequiredBy__c=line.Id;
            cline5.SBQQ__Bundled__c=true;
            cline5.SBQQ__BundledQuantity__c=7;
            cline5.SBQQ__ListPrice__c = 1000;
            cline5.BOM_Line_Number__c='1';
            cline5.SBQQ__OptionType__c = 'Component';
            cline5.SBQQ__Quantity__c = 9;
          
            listQl.add(cline5);
           /*
            SBQQ__QuoteLine__c cline10 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline10.SBQQ__RequiredBy__c=line.Id;
            cline10.SBQQ__Bundled__c=true;
            cline10.SBQQ__BundledQuantity__c=9;
            cline10.SBQQ__ListPrice__c = 1000;
            cline10.BOM_Line_Number__c='1';
            cline10.SBQQ__OptionType__c = 'Component';
            cline10.SBQQ__Quantity__c = 10;
     
            listQl.add(cline10);
            */
         quote.SBQQ__Status__c = 'Accepted';
         update quote;
              
          Sales_Order__c so = new Sales_Order__c();
            quote.SBQQ__Status__c = 'Approved';
            update quote;
            so.Opportunity__c = opp.Id;
            insert so;
     
       Test.startTest(); 
            
       
        opp.Latest_Sales_Orders_status__c=so.Status__c;
            opp.Latest_Sales_order_Type__c= so.Type__c;
            
            if(so.Status__c=='Approved by OA'){
                opp.Approved_Sales_Order__c= true;
            }
            else {
                opp.Approved_Sales_Order__c=false;
            }
       update opp;
		
        Database.DeleteResult result1=Database.delete(so,false);  
  		system.debug('=======result-====='+result1);
        Test.stopTest(); 
    }
	
	static testMethod void afterdelete() {
    Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        insert opp;
         Opportunity opp1 = new Opportunity(Name='Test2',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        insert opp1;
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test');
        insert p;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(  SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true);    
        insert quote;
         
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 1;
        insert line;          
      
      list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c cline4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline4.SBQQ__RequiredBy__c=line.Id;
        cline4.SBQQ__Bundled__c=true;
        cline4.SBQQ__BundledQuantity__c=5;
        cline4.SBQQ__ListPrice__c = 1000;
        cline4.BOM_Line_Number__c='1';
        cline4.SBQQ__OptionType__c = 'Component';
        cline4.SBQQ__Quantity__c = 7;
       
        listQl.add(cline4);
        /*
        SBQQ__QuoteLine__c cline5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline5.SBQQ__RequiredBy__c=line.Id;
        cline5.SBQQ__Bundled__c=true;
        cline5.SBQQ__BundledQuantity__c=7;
        cline5.SBQQ__ListPrice__c = 1000;
        cline5.BOM_Line_Number__c='1';
        cline5.SBQQ__OptionType__c = 'Component';
        cline5.SBQQ__Quantity__c = 9;
      
        listQl.add(cline5);
       
        SBQQ__QuoteLine__c cline10 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id,SBQQ__Product__c=p.Id);
        cline10.SBQQ__RequiredBy__c=line.Id;
        cline10.SBQQ__Bundled__c=true;
        cline10.SBQQ__BundledQuantity__c=9;
        cline10.SBQQ__ListPrice__c = 1000;
        cline10.BOM_Line_Number__c='1';
        cline10.SBQQ__OptionType__c = 'Component';
        cline10.SBQQ__Quantity__c = 10;
 
        listQl.add(cline10);*/
        
     quote.SBQQ__Status__c = 'Accepted';
     update quote;
          
      Sales_Order__c so = new Sales_Order__c();
        Sales_Order__c so1 = new Sales_Order__c();
        quote.SBQQ__Status__c = 'Approved';
        update quote;
        so.Opportunity__c = opp.Id;
        insert so;
        //so1.Opportunity__c = opp1.Id;
        //insert so1;
 
   Test.startTest(); 
   Database.DeleteResult result2=Database.delete(so,false);  
system.debug('=======result-====='+result2);
   Test.stopTest(); 
}
}