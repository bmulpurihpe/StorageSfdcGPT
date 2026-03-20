global class ShipmentDeleteBatch implements Database.Batchable<sobject>{
    
    global Database.Querylocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator('Select Id from Shipment_Flexflow__c LIMIT 1000000');
    }   
    
    global void execute(Database.BatchableContext BC, List<Shipment_Flexflow__c> scope){
        
        if(!scope.isEmpty()){
            Delete scope;
        }
    }
    
    global void finish(Database.BatchableContext BC){}
}