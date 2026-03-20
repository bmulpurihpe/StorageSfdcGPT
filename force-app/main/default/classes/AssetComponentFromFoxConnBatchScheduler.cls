/*
 * Created by Exafort for the JIRA TS-9711
 * Scheduler class for the batch class 'AssetComponentFromFoxConnDataBatch'
 * Process the Asset records with the FoxConnFactoryUCData records to create components
 * Test Class - AssetComponentFromFoxConnScheduler_Test
*/
global class AssetComponentFromFoxConnBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        AssetComponentFromFoxConnDataBatch assetComponentFlow = new AssetComponentFromFoxConnDataBatch();
        Database.executeBatch(assetComponentFlow,10);
    }
}