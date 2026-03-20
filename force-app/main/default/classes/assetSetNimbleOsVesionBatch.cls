global class assetSetNimbleOsVesionBatch implements Database.Batchable<sObject> {
    global final String Query;
    
    global assetSetNimbleOsVesionBatch(String queryString){
        Query=queryString;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Start Method to Execute the query
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<Asset> assets){
        
        if(assetPreventRecursive.runOnce() && CountAssetPreventRecursive.runOnce()) 
        {               
            assetTriggerSetFieldsHandler assetTriggerSetField = new assetTriggerSetFieldsHandler();
            assets = assetTriggerSetField.setNimbleOsVersion(assets);
            update assets;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}