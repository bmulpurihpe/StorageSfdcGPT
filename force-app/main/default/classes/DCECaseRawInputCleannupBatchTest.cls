/**
    * Test Class Name: DCECaseRawInputCleannupBatchTest
    * Created By: Rahul singhal
    * Created Date: 02/13/2025 
    *
    * Description:
    * This Salesforce Apex test class is used to test the DCECaseRawInputCleannupBatch and DCECaseRawInputCleannupBatchSchedule classes.
    * It inserts test records with created date, and schedules the batch job for testing.
    *
    * Usage:
    * - Use this test class to validate the functionality of DCECaseRawInputCleannupBatch and DCECaseRawInputCleannupBatchSchedule.
*/
@isTest
private class DCECaseRawInputCleannupBatchTest {
    static testMethod void testBatch() {
        List<DCE_Case_Raw_Input__c > recordsToInsert = new List<DCE_Case_Raw_Input__c >();
        DCE_Case_Raw_Input__c testRecord = new DCE_Case_Raw_Input__c(Name = 'Success');
        recordsToInsert.add(testRecord);
       // insert recordsToInsert;
        DCE_Case_Raw_Input__c testRecord1 = new DCE_Case_Raw_Input__c(Name = 'Success');
        recordsToInsert.add(testRecord1);
        insert recordsToInsert;
        Date TwentyEightDaysAgo = Date.today().addDays(-29);
        Test.setCreatedDate(recordsToInsert[0].Id, TwentyEightDaysAgo);     
        Test.setCreatedDate(recordsToInsert[1].Id, TwentyEightDaysAgo); 
        Test.startTest();
        DCECaseRawInputCleannupBatchSchedule batchJob = new DCECaseRawInputCleannupBatchSchedule();
        String sch='0 0 4 * * ?';
        System.schedule('DCECaseRawInputCleannupBatch',sch,batchJob);
        Test.stopTest();   
    }
}