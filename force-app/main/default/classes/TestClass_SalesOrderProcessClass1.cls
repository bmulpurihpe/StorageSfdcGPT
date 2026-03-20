@isTest
public class TestClass_SalesOrderProcessClass1 {

    //public static User Usr = TestDataRecord_Util.getRunningUser();
    public static testMethod void AssetProcess() {
        Test.startTest();
       // System.runAs(Usr){
        /*
        Utility.runDupRecTrigger = true;
            List<Account> acList                        =   TestDataRecord_Util.createAccountRecords(1,Usr);
            List<Opportunity> OppList                   =   TestDataRecord_Util.createOpportunityRecords(acList,Usr,1);
            List<Eval__c> EvalList                      =   TestDataRecord_Util.createEvalRecords(oppList,Usr,1);
            List<Product2> ProdList                     =   TestDataRecord_Util.createProductRecords(1,Usr);
            List<SBQQ__Quote__c>  QuoteList             =   TestDataRecord_Util.createQuoteRecords(OppList,Usr,1);
            List<Sales_Order__c>  SOList                =   TestDataRecord_Util.createSalesOrderRecords(OppList,Usr,1);
            List<Sales_Order_Line__c> SOLineList        =   TestDataRecord_Util.createSalesOrderLineRecords(SOList,ProdList,Usr,1); 
            List<Sales_Order__c>  SorderUpdList         =   TestDataRecord_Util.updateSaleOrderRecords(SOList,1,Usr);
            */
       // }  
       try{
           Sales_Order__c s = new Sales_Order__c();
           s.Name = 'TestSalesOrderData';
           //s.Opportunity__c = oppList[i].id ,                                            
           s.Type__c ='Revenue';
           s.Shipment_Date__c  = Date.Today();
           s.Status__c = 'New';
           s.SO_Number__c = '12345';      
           insert s;
           }Catch(Exception e){}
        
        Test.stopTest(); 
      }  
}