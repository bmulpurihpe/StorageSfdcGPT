@isTest
public class CaseCategorizationController_Test {
    static testmethod void test() { 
        
        //createTestData();
        Account     account;
        Contact     contact;
        Product2    product;
        Asset       asset;
        Case        aCase;
        
        // Create test account
        account = new Account(Name = 'TEST-ACCOUNT');
        insert account;
        
        
        // Create test active contact
        contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                              LastName    = 'TEST-CONTACT-LAST-NAME',
                              Phone       = 'TEST-CONTACT-PHONE',
                              MobilePhone = 'TEST-CONTACT-MOBILE',
                              AccountId   = account.Id);
        insert contact;
        
        
        // Create test product of family SAN Storage Array
        
        product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;
        
        // Create test Shipped asset
        asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                          Status = 'Shipped',
                          AccountId  = account.Id,
                          ContactId  = contact.Id,
                          product2Id = product.Id,
                          SLA__c = 'Premium',
                          Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                          Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                          Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                          Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                          assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                          Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                          Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                          Array_Controller_SKU__c = 'SD-Test',
                          Array_Capacity_SKU__c ='HEAD-HDD-21TB');
        insert asset;
        test.startTest();
        // Create test case
        aCase = new Case(AccountId = account.Id,
                         AssetId   = asset.Id,
                         ContactId = contact.Id,
                         Status = 'Open',
                         Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        CaseCategorizationController.getCaseDetails(aCase.id);
        test.stopTest();
    }
    
}