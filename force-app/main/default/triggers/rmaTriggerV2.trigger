trigger rmaTriggerV2 on RMAv2__c (before insert, before update,after insert, after update, before delete) {

    Boolean isActivated = ActivateTrigger__c.getInstance().RMATrigger__c; 
    //Added by Exafort on 4 Dec 19, to run the trigger based on the custom setting value.
    
    if (isActivated)
    {
        new rmaTriggerHandler().run();
    }
}