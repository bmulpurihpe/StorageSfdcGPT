trigger subscriptionTrigger on Subscription__c (after insert) {

    if(Trigger.IsInsert && Trigger.isAfter){
        subscriptionTriggerHandler.createSubscriptionDetail(Trigger.New, TRUE, NULL);
    }
}