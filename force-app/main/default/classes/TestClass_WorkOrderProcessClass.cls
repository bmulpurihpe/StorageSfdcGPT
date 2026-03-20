@isTest(SeeAllData=true)
public class TestClass_WorkOrderProcessClass {
            
   public static User Usr = TestDataRecord_Util.getRunningUser();
   public static testMethod void WorkOrderProcess() {
        System.runAs(Usr){
            List<Account> acList                        =   TestDataRecord_Util.createAccountRecords(1,Usr);
            List<Opportunity> OppList                   =   TestDataRecord_Util.createOpportunityRecords(acList,Usr,1);
            List<Product2> ProdList  =  TestDataRecord_Util.createProductRecords(1,Usr);
            List<Case> caseList                =   TestDataRecord_Util.createCaseRecords(Usr,1);
            List<SBQQ__Quote__c>  QuoteList    =   TestDataRecord_Util.createQuoteRecords(OppList,Usr,1);
            Test.startTest();
            List<Sales_Order__c>  SOList       =   TestDataRecord_Util.createSalesOrderRecords(OppList,Usr,1); 
            List<Sales_Order_Line__c> SOLineList = TestDataRecord_Util.createSalesOrderLineRecords(SOList,ProdList,Usr,1); 
            List<WorkOrder__c>  WOList         =   TestDataRecord_Util.InsertWorkOrderRecords(caseList,SOList,Usr,1);
            List<Case> csUpdateList            =   TestDataRecord_Util.updateCaseRecords(caseList,Usr,1);
            Test.stopTest(); 

        }  
        
      }  
  
     
   
}