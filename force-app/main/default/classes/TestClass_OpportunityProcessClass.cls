@isTest(SeeAllData=true)
public class TestClass_OpportunityProcessClass {

    public static User Usr = TestDataRecord_Util.getRunningUser();
    public static testMethod void AssetProcess() {
        List<Sales_Order__c>  SorderUpdList;
        
        Test.startTest();
        System.runAs(Usr){
            List<Account> acList                        =   TestDataRecord_Util.createAccountRecords(5,Usr);
            List<Opportunity> OppList                   =   TestDataRecord_Util.createOpportunityRecords(acList,Usr,5);
            List<SBQQ__Quote__c>  QuoteList             =   TestDataRecord_Util.createQuoteRecords(OppList,Usr,2);
            List<Eval__c> EvalList                      =   TestDataRecord_Util.createEvalRecords(oppList,Usr,5);
            List<Product2> ProdList                     =   TestDataRecord_Util.createProductRecords(5,Usr);
            List<Pricebook2> Prbook                     =   TestDataRecord_Util.createPricebookRecords(5,Usr);
            List<PricebookEntry> PrEntry                =   TestDataRecord_Util.createPricebookEntryRecords(ProdList,Prbook,5,Usr);
            List<OpportunityLineItem> oppLineItem       =   TestDataRecord_Util.createOpportunityLineRecords(OppList,PrEntry,Usr,5);
            List<Sales_Order__c>  SOList                =   TestDataRecord_Util.createSalesOrderRecords(OppList,Usr,5);
            List<Sales_Order_Line__c> SOLineList        =   TestDataRecord_Util.createSalesOrderLineRecords(SOList,ProdList,Usr,5); 
            SorderUpdList                               =   TestDataRecord_Util.updateSaleOrderRecords(SOList,1,Usr);
            List<Opportunity> OppUpdList                =   TestDataRecord_Util.UpdateOpportunityRecords(OppList,Usr,1);
        }  
        
        Test.stopTest(); 
        // Test 1
        OpportunityProcessClass.newWorkOrder(SorderUpdList,true,false);
        // Test 2
        OpportunityProcessClass.newWorkOrder(SorderUpdList,false,true);
      }  
}