@isTest
public class DceSyncCaseUpdateControllerTest {
    
    @isTest
    static void testDceSyncCaseUpdate() {
        Case testCase = new Case();
        testCase.Subject = 'Test Subject';
        insert testCase;
        
        DCE_Case_Sync__c testDceSync = new DCE_Case_Sync__c();
        testDceSync.Case__c = testCase.Id;
        testDceSync.DCE_Sync__c = 'Create Pending';
        insert testDceSync;
        DCE_Case_Sync__c dce1 = new DCE_Case_Sync__c();
        dce1.Case__c = testCase.Id;
        dce1.DCE_Sync__c = 'Create Pending';
        insert dce1;
        
        DCE_Case_Sync__c dce2 = new DCE_Case_Sync__c();
        dce2.Case__c = testCase.Id;
        dce2.DCE_Sync__c = 'Create Pending';
        insert dce2;
        Test.startTest();
        testDceSync.DCE_Sync__c = 'Success';
        update testDceSync;
        testCase.DCE_Sync__c=true;
        update testCase;
        DceSyncCaseUpdateController.dceSyncCaseUpdate(new List<DCE_Case_Sync__c>{dce1, dce2}, new Map<Id, DCE_Case_Sync__c>{dce1.Id => dce1, dce2.Id => dce2});
        Test.stopTest();
        testCase = [SELECT DCE_Sync__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(true, testCase.DCE_Sync__c);
    }
}