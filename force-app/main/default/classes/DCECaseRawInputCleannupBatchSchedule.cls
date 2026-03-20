/*
Description: This Salesforce Apex class calls another class 'DCECaseRawInputCleannupBatch' for scheduling.
JIRA: https://jira.storage.hpecorp.net/browse/SFDC-813
*/
global class DCECaseRawInputCleannupBatchSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        DCECaseRawInputCleannupBatch dcebatch = new DCECaseRawInputCleannupBatch();
        database.executeBatch(dcebatch,200);
    }
}