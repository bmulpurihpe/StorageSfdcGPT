/*                              <<<< === Batch Apex === >>>>
    =============================================================================================================
        Name                    : AssetNoComponentsFlagBatch
        Description             : To update no of components for Asset.
        Created Date            : 09/06/2016(MM/DD/YYYY)
        Author                  : Azar
        Version                 : 1.0
        Modification History    : Initial Version 
    ==============================================================================================================
*/
global class AssetNoComponentsFlagBatch implements Database.Batchable<sObject>{
    
    global final String Query; //string to get the query
    
    
    global AssetNoComponentsFlagBatch(String q){ /******** constructor **********/
        
        Query=q; //Select id, assetNoComponents__c from Asset where assetCreatedDateDiffFromToday__c >= 2 AND assetComponentCreatedStatus__c = null AND assetComponentProcessedMessage__c = null;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ /**********Start Method**************/
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> asset){ /********* Execute Method ***********/
        if(assetPreventRecursive.runOnce() && CountAssetPreventRecursive.runOnce()) 
        {
            List<Asset> updateTrue = new List<Asset>();
            List<Asset> updateFalse = new List<Asset>();
            List<Component__c> compList = new List<Component__c>();
            set<id> getId = new set<Id>();
            for(Asset assetId : asset){
                getId.add(assetId.Id);
            }
            if(getId.size() > 0){
                compList = [Select Id, componentAsset__c from Component__c where componentAsset__c =: getId];
            }
            if(compList.size() > 0){
                for(Asset assetLoop : asset){
                    assetLoop.assetNumberOfComponents__c = compList.size();
                    updateTrue.add(assetLoop);
                }
            } 
            if(compList.size() == 0){
                for(Asset assetLoop : asset){
                    assetLoop.assetNumberOfComponents__c = 0;
                    updateFalse.add(assetLoop);
                }
            }
            
            /*for(Asset assetLoop : asset){
if(assetLoop.assetCreatedDateDiffFromToday__c >= 2 && assetLoop.assetComponentCreatedStatus__c == null && assetLoop.assetComponentProcessedMessage__c == null && compList.size() == 0){
assetLoop.assetNoComponents__c = true;
updateTrue.add(assetLoop);
} 
else{
assetLoop.assetNoComponents__c = false;
updateFalse.add(assetLoop);
}
}*/
            if(updateTrue.size() > 0){
                update updateTrue;
            }
            if(updateFalse.size() > 0){
                update updateFalse;
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        
    } 
}