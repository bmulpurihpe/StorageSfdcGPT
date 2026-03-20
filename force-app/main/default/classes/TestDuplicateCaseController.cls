/*Purpose:Test class for DuplicateCaseController
* Change Log: 
*/
@isTest
private class TestDuplicateCaseController
{
    static testMethod void testDupCaseController()
    {
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
            Dynamic_SKU__c = 'AF1000-2P--10'
        );
        insert testAsset;
        test.startTest();
        Case parentC = new Case(Status='Open',Category__c='Alerts',Type='Problem',
                                Origin='Web',Reason='Administrative', Nimble_Version__c='1.0.2.0',
                                AssetId=testAsset.Id);
        insert parentC;
        Case childC = new Case(Status='Open',
                                Origin='Web',Nimble_Version__c='1.0.2.0',
                                AssetId=testAsset.Id,Duplicate_Case__c=parentC.Id);
        insert childC;
        ApexPages.Standardcontroller sc1 = New ApexPages.StandardController(childC);
        DuplicateCaseController dc = new DuplicateCaseController(sc1);
        dc.saveDuplicate();
        Case c = [select Id, Status,Sub_Status__c, Type, Reason,Category__c from Case where Id =: childC.Id];
        System.assertEquals(c.Status,'Closed');
        System.assertEquals(c.Sub_Status__c,'Duplicate');
        System.assertEquals(c.Type,'Problem');
        System.assertEquals(c.Reason,'Administrative');
        System.assertEquals(c.Category__c,'Alerts');
        test.stopTest();
    }

}