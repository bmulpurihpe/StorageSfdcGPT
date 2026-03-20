/*
Description: This Salesforce Apex class calls another class 'DceCaseSyncCleanupBatch' for scheduling.
JIRA: https://jira.storage.hpecorp.net/browse/SFDC-812
*/
global class DceCaseSyncCleanupBatchSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        DceCaseSyncCleanupBatch dcebatch = new DceCaseSyncCleanupBatch();
        database.executeBatch(dcebatch,200);
    }
}