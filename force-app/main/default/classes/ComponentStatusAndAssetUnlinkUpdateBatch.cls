/* Purpose: A batch class to update the components status and unlink asset
 * Change Log: Created by Azar
 */ 
global class ComponentStatusAndAssetUnlinkUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    global final String Query; //string to get the query
    
    global ComponentStatusAndAssetUnlinkUpdateBatch(String q){ /******** constructor **********/
        
        Query=q; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ /**********Start Method**************/
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Component__c> component){ /********* Execute Method ***********/
        
        List<Component__c> componentStatusUpdate = new List<Component__c>(); //list to update comp when asup no of days betwn asset and comp is greater than 4 and less than or equal to 30
        List<Component__c> componentUpdateToRemoveAsset = new List<Component__c>(); //list to unlink asset connection from components when days betwn asset and comp is greater than 30        
        List<Component__c> allComponentToUpdate = new List<Component__c>(); // List to add all the component eligible for updated 
        for(Component__c comp : component){
            if(comp.componentNoOfDaysBetweenAssetAndComp__c > 8 && comp.componentNoOfDaysBetweenAssetAndComp__c <= 30){
                /*** update status if asup between comp and asset is greater than 8 and lesser than or equal to 30 Days ****/
                comp.componentState__c ='Shipped';
                comp.Sub_State__c = 'Unknown';
                componentStatusUpdate.add(comp);
            }
            if(comp.componentNoOfDaysBetweenAssetAndComp__c  > 30){
                /*** update status and remove asset if asup between comp and asset is greater than 30 days****/
                comp.componentState__c ='Shipped';
                comp.Sub_State__c = 'Unknown';
                comp.componentAsset__c = null;
                componentUpdateToRemoveAsset.add(comp);
            }
            
            
        }
		
        if(componentStatusUpdate.size() > 0){
            //update componentStatusUpdate;
            allComponentToUpdate.addAll(componentStatusUpdate);
        }
        if(componentUpdateToRemoveAsset.size() > 0){
            //update componentUpdateToRemoveAsset;
            allComponentToUpdate.addAll(componentUpdateToRemoveAsset);
        }
       
        system.debug('## allComponentToUpdate'+allComponentToUpdate);
        if(allComponentToUpdate.size() > 0){
            update allComponentToUpdate; //TS-6159 update all the Components using single list.
        }
            
        
    }
    
    global void finish(Database.BatchableContext BC){
        //TS-6159 - ComponentCommentUpdateBatch - A batch class to update the component's comment if 2 Active controllers in Shipped-Online status found.
        ComponentCommentUpdateBatch component = new ComponentCommentUpdateBatch();
		Database.executeBatch(component);
     }   
}