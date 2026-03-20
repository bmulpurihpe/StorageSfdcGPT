@istest
public class ScheduledExecEscCheckInBatchTest 
{
    static testMethod void createTestBatch()
    {
        Test.startTest();
        
        ScheduledExecEscCheckInBatch schExecEscChkInBatch = new ScheduledExecEscCheckInBatch();
        String sched = '0 15 * * * ?';
        String jobId = system.schedule('ScheduledExecEscCheckInBatchTest', sched, schExecEscChkInBatch);
        
        Test.stopTest();
        return;
    }
}