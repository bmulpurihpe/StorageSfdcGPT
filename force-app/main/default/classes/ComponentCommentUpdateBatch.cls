/* Purpose: A batch class to update the component's comment if 2 Active controllers in Shipped-Online status found.
* Change Log: Created by Exafort to fix the issue mentioned in TS-6159
Update Log: Updated by Exafort for TS-9374 to process only for componentAsset__c != null and componentType = Controller components
Update Log: Updated by Exafort for TS-9633 to process component record based on asset and updateds done on execute method
*/ 
global class ComponentCommentUpdateBatch implements Database.Batchable<sObject>{
    global final String Query;
    
    global ComponentCommentUpdateBatch(String q)
    {
        Query=q; 
    }
    
    global ComponentCommentUpdateBatch(){
        Query = 'select id, name, (select id, name,componentType__c,componentStatus__c,componentComments__c,componentAsset__r.Name from components__r '+
            'where componentType__c = \'Controller\' and componentAsset__c != null) from asset';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> AssetRecord){
        
        List<Component__c> updateComponentController = new List<Component__c>();
        List<Component__c> clearComponentComment = new List<Component__c>();
        
        for(Asset assetList : [select id, name, (select id,name,componentType__c,componentStatus__c,componentComments__c,lastmodifiedby.name from components__r 
                                                 where componentType__c = 'Controller') from asset where Id =:AssetRecord]) {
            for(component__c  comp : assetList.components__r){
                if(comp.componentComments__c != null){
                    comp.componentComments__c = '';
                    clearComponentComment.add(comp);     
                }
            }  
        }
        
        for(Asset assetList : AssetRecord){
            List<Component__c> componentWithAddComments = new List<Component__c>();
            integer countShippedOnlineComp = 0;
            
            if(assetList.components__r.size() > 2){
                for(component__c componentRecord : assetList.components__r){
                    if(componentRecord.componentStatus__c == 'Shipped-Online')
                    {
                        countShippedOnlineComp = countShippedOnlineComp + 1;
                    }
                    else
                    {
                        componentRecord.componentComments__c = '2 Active controllers in Shipped-Online status found. This is a potential candidate for unlinking from Asset - '+componentRecord.componentAsset__r.name;
                        componentWithAddComments.add(componentRecord);
                    }
                }
            }
            
            if(countShippedOnlineComp >= 2){
                updateComponentController.addAll(componentWithAddComments);
            }
            
        }
        
        // Clear Component Comment
        if(clearComponentComment.size() > 0){
            update clearComponentComment;
        }
        
        // Update Component Comment
        if(updateComponentController.size() > 0){
            update updateComponentController;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }   
    
}