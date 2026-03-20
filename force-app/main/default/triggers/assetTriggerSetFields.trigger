trigger assetTriggerSetFields on Asset (before insert,before update) {
    
    
    if(trigger.IsBefore && trigger.IsInsert)
    {
        for (Asset triggerAsset : trigger.new){
            triggerAsset.assetComponentCreatedStatus__c = null;
            triggerAsset.assetComponentProcessedMessage__c = null;
            
        }
    }
    
    if(trigger.IsBefore && (trigger.IsInsert ||trigger.IsUpdate))
    {
        assetTriggerSetFieldsHandler assetTriggerSetField = new assetTriggerSetFieldsHandler();
        assetTriggerSetField.setNimbleOsVersion(trigger.new);
    }
    

}