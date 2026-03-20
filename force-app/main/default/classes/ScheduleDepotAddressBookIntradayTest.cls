@isTest
public class ScheduleDepotAddressBookIntradayTest {
    
    @isTest
    static void testScheduleDepotJob() {
        // Start test context
        Test.startTest();

        // Schedule the job to run 1 minute later
        String cronExp = '0 0 0 15 6 ? 2025'; // Any valid future date/time CRON expression
        String jobName = 'Test Depot Intraday Schedule Job';

        ScheduleDepotAddressBookIntraday job = new ScheduleDepotAddressBookIntraday();
        System.schedule(jobName, cronExp, job);

        Test.stopTest();

        // Assertions (optional)
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        System.assertEquals(1, jobs.size(), 'Scheduled job should be created.');
    }
}