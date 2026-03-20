global class ComponentNICDeleteBatch implements Database.Batchable<sObject>,Database.Stateful{
      global final String Query = 'select id,name,componentAsset__r.product2.productcode, componentType__c from Component__C WHERE (componentAsset__r.product2.productcode like \'%CS215%\' OR componentAsset__r.product2.productcode like \'%CS210%\' OR componentAsset__r.product2.productcode like \'%CS220%\' OR componentAsset__r.product2.productcode like \'%CS240%\' OR componentAsset__r.product2.productcode like \'%CS260%\' OR componentAsset__r.product2.productcode like \'%CS420%\' OR componentAsset__r.product2.productcode like \'%CS440%\' OR componentAsset__r.product2.productcode like \'%CS460%\' ) AND componentType__c like \'%NIC_CARD%\' order by componentType__c';    

     global ComponentNICDeleteBatch(){
     }
     
        global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Component__c> scope)
    {
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){ }
     
     

}