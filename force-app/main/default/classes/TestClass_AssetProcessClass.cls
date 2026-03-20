@isTest(SeeAllData=true)
public class TestClass_AssetProcessClass {
            
   public static User Usr = TestDataRecord_Util.getRunningUser();
   public static testMethod void AssetProcess() {
        Test.startTest();
        System.runAs(Usr){
            List<Account> acList                        =   TestDataRecord_Util.createAccountRecords(5,Usr);
            List<Opportunity> OppList                   =   TestDataRecord_Util.createOpportunityRecords(acList,Usr,5);
            List<Eval__c> EvalList                      =   TestDataRecord_Util.createEvalRecords(oppList,Usr,5);
            List<Product2> ProdList                     =   TestDataRecord_Util.createProductRecords(5,Usr);
            List<SBQQ__Quote__c>  QuoteList             =   TestDataRecord_Util.createQuoteRecords(OppList,Usr,5);
            List<Sales_Order__c>  SOList                =   TestDataRecord_Util.createSalesOrderRecords(OppList,Usr,5);
            List<Sales_Order_Line__c> SOLineList        =   TestDataRecord_Util.createSalesOrderLineRecords(SOList,ProdList,Usr,5);
            List<WorkOrder__c>       WOList             =   TestDataRecord_Util.createWorkOrderRecords(SOList,Usr,5);
            List<WO_Sales_Order_Lines__c> WOLineList    =   TestDataRecord_Util.createWorkOrderLineRecords(WOList,SOLineList,ProdList,Usr,5);
            List<Asset> AssetList                       =   TestDataRecord_Util.createAssetRecords(acList,EvalList,WOLineList,Usr,5);
            List<Asset> UpdateAssetList                 =   TestDataRecord_Util.updateAssetRecords(AssetList,5,Usr);

        }  
        
        Test.stopTest(); 
      }  
  
     
   
}