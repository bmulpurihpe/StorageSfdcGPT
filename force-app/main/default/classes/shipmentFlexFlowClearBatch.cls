global class shipmentFlexFlowClearBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    
    
     global final String Query; //Batch Query
    
    global shipmentFlexFlowClearBatch(string q){
        Query = q;
    }
    
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Shipment_Flexflow__c>  shipmentFlexFlows)
    {
       for(Shipment_Flexflow__c shipmentFlexFlow : shipmentFlexFlows )
        {
           shipmentFlexFlow.shipmentFlexflowFlexProcessed__c = null;
           shipmentFlexFlow.shipmentFlexflowProcessedMessage__c = null;
        }
        
        update shipmentFlexFlows;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    
}