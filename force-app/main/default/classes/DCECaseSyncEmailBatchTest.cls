/**
    * Test Class Name: DCECaseSyncEmailBatchTest
    * Created By: Jana Reddy
    * Created Date: 10/16/2023 
    *
    * Description:
    * This Salesforce Apex test class is used to test the DCECaseSyncEmailBatch and DCECaseSyncEmailBatchSchedule classes.
    * It inserts test records, sets created dates, and schedules the batch job for testing.
    *
    * Usage:
    * - Use this test class to validate the functionality of DCECaseSyncEmailBatch and DCECaseSyncEmailBatchSchedule.
*/
@isTest
private class DCECaseSyncEmailBatchTest {
    static testMethod void testBatch() {
        List<DCE_Case_Sync__c > recordsToInsert = new List<DCE_Case_Sync__c >();
        DCE_Case_Sync__c testRecord = new DCE_Case_Sync__c(DCE_Sync__c = 'Create Pending');
        recordsToInsert.add(testRecord);
        DCE_Case_Sync__c testRecord1 = new DCE_Case_Sync__c(DCE_Sync__c = 'Update Pending');
        recordsToInsert.add(testRecord1);
        insert recordsToInsert;
        Date sevenDaysAgo = Date.today().addDays(-7);
        Date eightDaysAgo = Date.today().addDays(-8);
        Test.setCreatedDate(recordsToInsert[0].Id, eightDaysAgo);     
        Test.setCreatedDate(recordsToInsert[1].Id, eightDaysAgo); 
        Test.startTest();
        DCECaseSyncEmailBatchSchedule batchJob = new DCECaseSyncEmailBatchSchedule();
        String sch='0 0 4 * * ?';
        System.schedule('DCECaseSyncEmailBatch',sch,batchJob);
        Test.stopTest();   
    }
}