/**
    * Test Class Name: DceCaseSyncCleanupBatchTest
    * Created By: Rahul singhal
    * Created Date: 02/13/2025 
    *
    * Description:
    * This Salesforce Apex test class is used to test the DceCaseSyncCleanupBatch and DceCaseSyncCleanupBatchSchedule classes.
    * It inserts test records, delete logs, and schedules the batch job for testing.
    *
    * Usage:
    * - Use this test class to validate the functionality of DceCaseSyncCleanupBatch and DceCaseSyncCleanupBatchSchedule.
*/
@isTest
private class DceCaseSyncCleanupBatchTest {
    static testMethod void testBatch() {
        List<DCE_Case_Sync__c > recordsToInsert = new List<DCE_Case_Sync__c >();
        DCE_Case_Sync__c testRecord = new DCE_Case_Sync__c(DCE_Sync__c = 'Success');
        recordsToInsert.add(testRecord);
       // insert recordsToInsert;
        DCE_Case_Sync__c testRecord1 = new DCE_Case_Sync__c(DCE_Sync__c = 'Success');
        recordsToInsert.add(testRecord1);
        insert recordsToInsert;
        Date TwentyEightDaysAgo = Date.today().addDays(-29);
        Test.setCreatedDate(recordsToInsert[0].Id, TwentyEightDaysAgo);     
        Test.setCreatedDate(recordsToInsert[1].Id, TwentyEightDaysAgo); 
       List<DCE_Case_Sync__c> initialRecords = [
            SELECT Id FROM DCE_Case_Sync__c WHERE CreatedDate <= :twentyEightDaysAgo
        ];
        System.assertEquals(2, initialRecords.size(), 'Test setup failed: Records should exist before batch execution.');

        Test.startTest();
        DceCaseSyncCleanupBatchSchedule batchJob = new DceCaseSyncCleanupBatchSchedule();
        String sch='0 0 4 * * ?';
        System.schedule('DceCaseSyncCleanupBatch',sch,batchJob);
               
        Test.stopTest();   
    }
}