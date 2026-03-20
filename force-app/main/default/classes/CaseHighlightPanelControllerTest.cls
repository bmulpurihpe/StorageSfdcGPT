@isTest
public class CaseHighlightPanelControllerTest {
   
    @testSetup
    static void setupTestData() {
        
		Id myRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Array_Case').getRecordTypeId();

        // Create a test Case record
        List<RecordType> newRecordTypeList =CaseHighlightPanelController.getRecordTypes();
        Case testCase = new Case(
            Subject = 'Test Case',
            RecordTypeId = newRecordTypeList[0].Id
        );
        insert testCase;
    }


    @isTest
    static void testUpdateCaseRecordType() {
        Case testCase = [SELECT Id, RecordTypeId FROM Case LIMIT 1];
        RecordType newRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Id != :testCase.RecordTypeId LIMIT 1];

        Test.startTest();
        CaseHighlightPanelController.updateCaseRecordType(testCase.Id, newRecordType.Id);
        Test.stopTest();

        Case updatedCase = [SELECT RecordTypeId FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(newRecordType.Id, updatedCase.RecordTypeId, 'RecordTypeId should be updated');
    }
}