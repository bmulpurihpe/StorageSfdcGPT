trigger assetTriggerClearComponentStatusOnClone on Asset (before insert) {
    
    for (Asset triggerAsset : trigger.new){
        triggerAsset.assetComponentCreatedStatus__c = null;
        triggerAsset.assetComponentProcessedMessage__c = null;
        
    }
    

}