/* Purpose: Test class for ProcessAsupComponent_Schedule class
 * Change Log: Created By Pradeep Aitha
 */
@isTest
public class ProcessAsupComponent_Schedule_Test 
{
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testMethod void testAsupComponentSchedule()
    {
      // Schedule the test job
      String jobId = System.schedule('ProcessAsupComponent_Schedule',
                        CRON_EXP, 
                        new ProcessAsupComponent_Schedule());
    }

}