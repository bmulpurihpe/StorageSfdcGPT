trigger Duplicate_AssetRecords_Trigger on Duplicate_Asset__c (before insert,before update,after insert,after update) {

    new DuplicateAssetTriggerHandler(Trigger.newMap, Trigger.oldMap).run(); 

}