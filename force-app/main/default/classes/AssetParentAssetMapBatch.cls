/**
created by : Padmaja D
* used to dummy update for AssetParent Map 
**/
global class AssetParentAssetMapBatch implements Database.Batchable<SObject>, Schedulable {
   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<String> nonLegacyValues = new List<String>();
        
        for (String val : System.Label.non_legacy.split(',')) {
            nonLegacyValues.add(val.trim());
        }
        System.debug('****nonLegacyValues ' + nonLegacyValues);
        return Database.getQueryLocator([SELECT Id FROM Asset_Stage__c WHERE parent_Asset_SN__c != null AND Asset__r.Parent_Asset__c = null AND Asset__c != null AND Asset_Status__c = 'Shipped' AND Asset__r.ProductFamily IN :nonLegacyValues
        ]);
    }

    
    global void execute(Database.BatchableContext bc, List<Asset_Stage__c> scope) {
        if (!scope.isEmpty()) {
            System.debug('****Processing scope size: ' + scope.size());
            Database.update(scope, false); 
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
  
    // Schedulable execute
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AssetParentAssetMapBatch(), Integer.valueof(System.label.AssetParentAssetMapBatchBatch_Size) );
    }

}