global class assetComponentClearBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    
    
    global final String Query; //Batch Query
    
    global assetComponentClearBatch(string q){
        Query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset>  assets)
    {
        if(assetPreventRecursive.runOnce() && CountAssetPreventRecursive.runOnce()) 
        {
            for(Asset assetRecord : assets)
            {
                assetRecord.assetcomponentCreatedStatus__c  = null;
                assetRecord.assetcomponentProcessedMessage__c = null;
            }
            
            update Assets;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    
}