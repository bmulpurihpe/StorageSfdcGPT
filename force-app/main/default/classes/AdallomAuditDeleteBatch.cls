global class AdallomAuditDeleteBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM AdallomAudit__c';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<AdallomAudit__c> scope) {
        
         delete scope;
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}