/**
    * Class Name: DCECaseSyncEmailBatchSchedule
    * Created By: Jana Reddy
    * Created Date: 10/25/2023 
    *
    * Description:
    * This Salesforce Apex class schedules the execution of the DCECaseSyncEmailBatch batch job at specified intervals.
    *
    * Usage:
    * - Schedule this class to run the DCECaseSyncEmailBatch batch job periodically.
    * - Adjust the scheduling interval as needed.
*/
global class DCECaseSyncEmailBatchSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        DCECaseSyncEmailBatch dceemailbatch= new DCECaseSyncEmailBatch();
        database.executeBatch(dceemailbatch,200);
    }
}