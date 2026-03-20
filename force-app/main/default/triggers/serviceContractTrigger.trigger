trigger serviceContractTrigger on ServiceContract  (after insert, after update) {
    if((Trigger.IsInsert || Trigger.IsUpdate) && Trigger.isAfter){
        serviceContractTriggerHandler.updateAccountSubscriptionDates(Trigger.New);
    }
}