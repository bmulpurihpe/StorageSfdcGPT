@isTest
public class schedule_EvalConversion_emails_Test {
    
    
    static testMethod void testEvalConversionEmails()
    {
      String CRON_EXP =  '0 0 0 15 3 ? 2022';
      // Schedule the test job
      String jobId = System.schedule('schedule_EvalConversion_emails_Schedule',
                        CRON_EXP, 
                        new schedule_batch_EvalConversion_emails());
    }

}