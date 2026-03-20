global class assetES1AFSProductFixBatch implements Database.Batchable<sObject>{
    
   global final String Query;
   //Query all the Address Book Country
   global assetES1AFSProductFixBatch(){
               Query='Select assetComponentCreatedStatus__c,assetComponentProcessedMessage__c,assetArenaProductCode__c from Asset where assetArenaProductCode__c=\'ES1-AFS\'';
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
       //Start Method to Execute the query
       return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<Asset>  assets){
                    
      for(Asset assetToProcess: assets){ 
          
           Boolean assetInvolvedInRMA = false;   

          //Check Asset Is Involved in RMA
          for(RMAv2__c rma: [Select Id,rmaDiskShelfAsset__c,rmaCaseNumber__r.Asset.Id from RMAv2__c where rmaSelection__c!= null and (rmaDiskShelfAsset__c =:assetToProcess.Id or rmaCaseNumber__r.Asset.Id =:assetToProcess.Id)]){ 
              assetInvolvedInRMA = true;
              //assetToProcess.assetAFSDebug__c = 'RMA Exist for Asset';
              assetToProcess.assetComponentProcessedMessage__c = 'RMA Exist for Asset';
          }
          
          if(assetInvolvedInRMA == false)
          {
              assetToProcess.assetComponentCreatedStatus__c = null;
              assetToProcess.assetComponentProcessedMessage__c = 'For Re-Process';
              //assetToProcess.assetAFSDebug__c = 'Re-Processed';
              delete [Select Id from Component__c where componentAsset__c =: assetToProcess.Id]; 
          }
          
          update assetToProcess;
          
      }    
   }

   global void finish(Database.BatchableContext BC){

   }

}