global class RemoveNmblRecordsBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        Date sevenDaysAgo = Date.today().addDays(-7);
        return Database.getQueryLocator(
            'SELECT Id FROM NMBL_Log__c WHERE CreatedDate <:sevenDaysAgo limit 150000'
        );
    }
    global void execute(Database.BatchableContext context, List<SObject> scope) {      
        delete scope;
    }
    global void finish(Database.BatchableContext context) {
        System.debug('Old NMBL Log Records deleted successfully!');
    }
}