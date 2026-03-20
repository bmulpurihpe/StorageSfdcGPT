/*
Description: This Salesforce Apex class implements a batch job that deletes records from the object that has createddate older than 4 weeks.
JIRA: https://jira.storage.hpecorp.net/browse/SFDC-812
*/
global class DceCaseSyncCleanupBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date Fourweeksolder = Date.today().addDays(-28);
        return Database.getQueryLocator(
          'SELECT Id FROM DCE_Case_Sync__c WHERE CreatedDate <: Fourweeksolder'
        );
    }
    global void execute(Database.BatchableContext bc, List<DCE_Case_Sync__c> scope) {  
        System.debug('In progress');
        delete scope;
    }
    global void finish(Database.BatchableContext bc) {
        System.debug('DCE Case Sync Cleanup Completed!');
    }
}