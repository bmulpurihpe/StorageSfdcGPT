/* Apex test class: TSEEventScheduler_Test
 * This is the test class with unit test methods to achieve minimum code coverage for the "TSEEventScheduler" scheduler class.
 * Author: Exafort(Vishnu)
 * Date: 2nd August 2018
 * */
@istest
public class TSEEventScheduler_Test {
    public static String CRON_EXP = '0 0 0 15 3 ?';
    static testMethod void test_01()
    {
        // Schedule the test job
        String jobId = System.schedule('TSEEventSchedulerJob_testJob',CRON_EXP, new TSEEventScheduler());
    }
}