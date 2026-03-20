trigger rmaSubstitutionTrigger on RMASubstitution__c (before insert,before update) {
    new rmaSubstitutionTriggerHandler().run();
}