@isTest
public with sharing class CaseTriggerUpdateTest {
    @TestSetup
    static void setupTestData(){
        //Setup case data
        Account testAcct = new Account(
            Name = 'Test Account for Testing',
            Sales_Segment_Type__c = 'Commercial',
            Market_Segment__c = 'Commercial',
            Type = 'Customer'
        );
        insert testAcct;  
        Contact testContact = new Contact(
            AccountId = testAcct.id,
            FirstName = 'Test',
            LastName = 'Contact'
        );
        insert testContact;
        Product2 testProd = new Product2(
            Name = 'AF1234',
            ProductCode = 'AF1234'
        );
        insert testProd;
        Asset testAsset = new Asset(
            Name = 'AF-234567',
            AccountId = testAcct.id,
            ContactId = testContact.id,
            Product2Id = testProd.id,
            Array_Controller__c = 'AF1000',
            Array_Networking__c = '2P',
            FC_Testing_Done__c = 10,
            Dynamic_SKU__c = 'AF1000-2P--10',
            Asset_Type_Build__c	= 'Array Type'
        );
        insert testAsset;
        test.startTest();
        List<RecordType> caseRecordTypes = [Select Id, Name From RecordType where sObjectType='Case' and isActive=true];
        List<Case> testCasesToInsert = new List<Case>();
        for(RecordType recordType : caseRecordTypes) {
            system.debug('recordType.Id :'+recordType.Id);
            Case testCase = new Case(
                
                RecordTypeId = recordType.Id,
                AccountId = testAcct.id,
                ContactId = testContact.id,
                AssetId = testAsset.id,
                Status = 'New',
                caseCatImpactToCustomer__c = 'No Impact - Initial Installation',
                Type = 'Production',
                Estimated_Effort__c = '30 minutes',
                Subject = 'Test Subject',
                Description = 'Test Description',
                Technology_Area__c = 'Sizing (for Performance)',
                Sub_Technology_Area__c = 'CPU / Controller'
                );
            testCasesToInsert.add(testCase);
        }
        insert testCasesToInsert;
        test.stopTest();
    }

    static testMethod void updateCaseTypeForEmail_SDOE_ForBeforeInsert() {
        Case testCase = [select id, casenumber, case_type_for_email__c, Asset.Asset_Type__c from Case where RecordType.Name = 'SDOE' limit 1];
        System.debug('testCase.Asset.Asset_Type__c:   ' + testCase.Asset.Asset_Type__c);
        test.startTest();
        System.assertEquals('SDOE', testCase.case_type_for_email__c);
        test.stopTest();
    }
    static testMethod void updateCaseTypeForEmail_InfoSight_ForBeforeInsert() {
        Case testCase = [select id, casenumber, case_type_for_email__c, Asset.Asset_Type__c from Case where RecordType.Name = 'InfoSight Portal' limit 1];
        System.debug('testCase.Asset.Asset_Type__c:   ' + testCase.Asset.Asset_Type__c);
        test.startTest();
        System.assertEquals('InfoSight', testCase.case_type_for_email__c);
        test.stopTest();
    }
    static testMethod void updateCaseTypeForEmail_ArrayCase_ForBeforeInsert() {
        Case testCase = [select id, casenumber, case_type_for_email__c, Asset.Asset_Type__c from Case where RecordType.Name = 'Array Case' 
                            AND Asset.Asset_Type__c <> 'Block Storage' limit 1];
        System.debug('testCase.Asset.Asset_Type__c:   ' + testCase.Asset.Asset_Type__c);
        test.startTest();
        System.assertEquals('Array', testCase.case_type_for_email__c);
        test.stopTest();
    }
}