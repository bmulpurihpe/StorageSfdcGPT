/* Purpose: Test class for ProcessSRMetaData_Batch_Schedule class
 * Change Log: Created By Pradeep Aitha
 */
@isTest
public class ProcessSRMetaData_Batch_Schedule_Test {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testMethod void testSRMetadataSchedule()
    {
      // Schedule the test job
      String jobId = System.schedule('ProcessSRMetaData_Batch_Schedule',
                        CRON_EXP, 
                        new ProcessSRMetaData_Batch_Schedule());
    }

}