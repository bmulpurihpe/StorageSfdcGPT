trigger DCECaseUpdate on DCE_Case_Sync__c (after update) {
    DceSyncCaseUpdateController.dceSyncCaseUpdate(trigger.new, trigger.oldMap);  
}