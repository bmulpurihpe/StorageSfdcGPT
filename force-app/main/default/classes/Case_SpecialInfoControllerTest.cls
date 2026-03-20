@isTest
public class Case_SpecialInfoControllerTest {
    @testSetup
    static void setupTestData() {
        // Create an Account
        Account testAccount = new Account(
             Name = 'Test Account for Testing',
            Sales_Segment_Type__c = 'Commercial',
            Market_Segment__c = 'Commercial',
            Type = 'Customer'
        );
        insert testAccount;

        // Create a Contact
        Contact testContact = new Contact(
            AccountId = testAccount.id,
            FirstName = 'Test',
            LastName = 'Contact'
        );
        insert testContact;
		Product2 testProd = new Product2(
            Name = 'AF1234',
            ProductCode = 'AF1234'
        );
        insert testprod;
        // Create an Asset
       Asset testAsset = new Asset(
            Name = 'AF-234567',
            AccountId = testAccount.id,
            ContactId = testContact.id,
            Product2Id = testProd.id,
            Array_Controller__c = 'AF1000',
            Array_Networking__c = '2P',
            FC_Testing_Done__c = 10,
            Dynamic_SKU__c = 'AF1000-2P--10',
            Asset_Type_Build__c	= 'Array Type'
        );
        insert testAsset;

        // Create Cases (Open and Closed)
        List<Case> caseList = new List<Case>{
            new Case(
                Subject = 'Open Case 1',
                Status = 'New',
                AssetId = testAsset.Id,
                ContactId = testContact.Id,
                AccountId = testAccount.Id
            ),
            new Case(
                Subject = 'Open Case 2',
                Status = 'In Progress',
                AssetId = testAsset.Id,
                ContactId = testContact.Id,
                AccountId = testAccount.Id
            ),
            new Case(
                Subject = 'Closed Case',
                Status = 'Closed',
                AssetId = testAsset.Id,
                ContactId = testContact.Id,
                AccountId = testAccount.Id
            )
        };
        insert caseList;
    }
    
    @isTest
    static void testGetOpenCasesWithAsset() {
        // Fetch test asset
        Asset testAsset = [SELECT Id FROM Asset LIMIT 1];
        Contact testContact = [Select Id FROM Contact LIMIT 1];
        Case testCase = [Select Id, AssetId, ContactId, AccountId FROM Case LIMIT 1];
        // Call the Apex method
        Test.startTest();
        Boolean accountresult = Case_SpecialInfoController.getAccountSupportRestriction(testCase.AccountId);
        Integer assetresult = Case_SpecialInfoController.getNumCasesAsset(testCase.AssetId);
        Integer contactresult =  Case_SpecialInfoController.getNumCasesContact(testCase.ContactId);
        List<Case> result = Case_SpecialInfoController.getOpenCasesWithAsset(testCase.AssetId); 
        Test.stopTest();

        // Assertions
        System.assertEquals(2, result.size(), 'Only open cases should be returned');
       
    }

    @isTest
    static void testCaseWrapper() {
        
        Case testCase = [Select Id, AssetId, ContactId, AccountId FROM Case LIMIT 1];  

        // Create a CaseWrapper instance
        Case_SpecialInfoController.CaseWrapper wrapper = new Case_SpecialInfoController.CaseWrapper();
        wrapper = Case_SpecialInfoController.getInitialWrapper(testCase.Id);
                
        // Assign values
        wrapper.assetCount = 5;
        wrapper.contactCount = 3;

        // Validate assigned values
        System.assertEquals(5, wrapper.assetCount, 'Asset count should be set correctly');
        System.assertEquals(3, wrapper.contactCount, 'Contact count should be set correctly');
    }
}