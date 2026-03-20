/**
    * Class Name: UpdateAssetContactBatchSchedule
    * Created By: Jana Reddy
    * Created Date: 11/1/2023
    *
    * Description:
    * This Salesforce Apex class schedules the execution of the UpdateAssetContactBatch batch job at specified intervals.
    *
    * Usage:
    * - Schedule this class to run the UpdateAssetContactBatch batch job periodically.
    * - Adjust the scheduling interval as needed.
*/
global class  UpdateAssetContactBatchSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        UpdateAssetContactBatch UpdateAsset= new  UpdateAssetContactBatch();
        database.executeBatch(UpdateAsset,200);
    }
}