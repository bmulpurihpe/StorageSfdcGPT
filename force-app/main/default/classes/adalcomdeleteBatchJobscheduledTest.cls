@isTest
private class adalcomdeleteBatchJobscheduledTest
{

    static testmethod void schedulerTest() 
    {
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        // Create your test data
        AdallomAudit__c acc = new AdallomAudit__c();
            acc.Name ='Name';
            acc.UserId__c='test';
            acc.ActionType__c='test';
            acc.ObjectName__c='test';
            acc.Timestamp__c=system.now();
        insert acc;
        
        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new AdalcomDeleteBatchJobscheduled());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        // Add assert here to validate result
    }
}