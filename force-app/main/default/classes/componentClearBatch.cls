global class componentClearBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    
    global final String Query; //Batch Query
    
    global componentClearBatch(string q){
        Query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Component__c>  components)
    {
        delete components;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    
}