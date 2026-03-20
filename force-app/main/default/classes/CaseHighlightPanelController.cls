public with sharing class CaseHighlightPanelController {
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypes() {
        return [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Case'];
    }

    @AuraEnabled
    public static void updateCaseRecordType(Id caseId, Id recordTypeId) {
        Case caseToUpdate = new Case(Id = caseId, RecordTypeId = recordTypeId);
        update caseToUpdate;
    }
}