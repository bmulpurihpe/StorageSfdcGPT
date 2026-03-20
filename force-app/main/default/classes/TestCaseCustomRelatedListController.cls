@isTest
public class TestCaseCustomRelatedListController
{
    static testMethod void testCustomRelatedList()
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
        List<Case> caseList = new List<Case>();
        Case c1 = new Case(AssetId = testAsset.Id, AccountId = testAcct.Id, Case_Type__c = 'External');
        Case c2 = new Case(AssetId = testAsset.Id, AccountId = testAcct.Id, Case_Type__c = 'Internal');
        caseList.add(c1);
        caseList.add(c2);
        Test.startTest();
        insert caseList;
        ApexPages.StandardController sc = new ApexPages.StandardController(testAsset);
        CaseCustomRelatedListController cnctrl = new CaseCustomRelatedListController(sc);
        PageReference pageRef = Page.CaseCustomRelatedListPage;
        Test.setCurrentPage(pageRef);
        List<Case> cList = cnctrl.getCases();
        System.assertEquals(1,cList.size());   
        Test.stopTest();     
        
    }
    
}