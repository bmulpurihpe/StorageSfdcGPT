@isTest
public class RemoveNmblRecordsBatchTest {
    static testmethod void testDeleteOldNMBLRecords() {
        String CRON_EXP = '0 0 0 15 3 ? *';
        List<NMBL_Log__c> recordsToInsert = new List<NMBL_Log__c>();
        NMBL_Log__c rec = new NMBL_Log__c(Request__c='Test Record ', Response__c='Test Record ');
        recordsToInsert.add(rec);
        NMBL_Log__c rec1 = new NMBL_Log__c(Request__c='Test Record ', Response__c='Test Record ');
        recordsToInsert.add(rec1);
        insert recordsToInsert;
        Date sevenDaysAgo = Date.today().addDays(-7);
        Date eightDaysAgo = Date.today().addDays(-8);
        Test.setCreatedDate(recordsToInsert[0].Id, eightDaysAgo);     
        Test.setCreatedDate(recordsToInsert[1].Id, eightDaysAgo); 
        Test.startTest();
        String jobId = System.schedule('nmbltest',  CRON_EXP, new RemoveNmblRecordsBatchSchudle());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}