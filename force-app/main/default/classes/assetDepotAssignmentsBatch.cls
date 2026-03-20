global class assetDepotAssignmentsBatch implements Database.Batchable<sObject>{
    
    global final String Query;
    global static Map<String, depotMapNbdNd__c> depotMapNbdNd;
    global static Map<String, depotMap4Hour__c> depotMap4Hour;
    global static Map<String, List<PostalCode__c>> postalCodeMap;
    
    global assetDepotAssignmentsBatch(String queryString){
        Query=queryString;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Start Method to Execute the query
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, 
                        List<sObject> scope){
           
            if(assetPreventRecursive.runOnce() && CountAssetPreventRecursive.runOnce()) 
            {               
                assetDepotAssignments depotAssignments = new assetDepotAssignments((List<Asset>) scope);
                depotAssignments.assetDepotMain();
            }
                            
     }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}