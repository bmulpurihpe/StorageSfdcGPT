@isTest
public class caseTriggerAddCommentForCatAndSubCatTest {
    
    static testMethod void createTestData()
    {
        Account          account;
        Contact          contact;
        Asset            asset;
        Case             aCase;
        Category_Notes__c CN;
        List<Account>          accounts;
        List<Contact>          contacts;
        List<Asset>            assets;
        List<Case>             cases;
        ID testAccountId;
        ID testContactId;
        ID testAssetId;
        ID testCaseId;
        
        // Create test account
        account = new Account(Name = 'TEST-ACCOUNT');
        insert account;
        
        // Create test contact
        contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                              AccountId = account.id);
        insert contact;
        Product2 testProd = new Product2(
            Name = 'AF1234',
            ProductCode = 'AF1234'
        );
        insert testProd;
        // Create test asset
        asset = new Asset(Name = 'TEST-ASSET',
                          AccountId = account.id,
                          ContactId = contact.id,
                          Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                          Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                          Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                          Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                          SLA__c = 'Premium',
                          assetRmaShi__c = 'Asset RMA SHI',
                          Dynamic_SKU__c='Test - Dynamic Sku',
                          Array_Controller__c ='AF1000',
                          Array_Networking__c = '2F',
                          Array_Cache__c = '320F',
                          SSD_Bank_A__c = '480F',
                          SSD_Bank_B__c = '480F',
                          Array_Controller_SKU__c = 'SD-Test',
                          Product2Id = testProd.id);
        insert asset;      
        
        CN = new Category_Notes__c(category__c='Backup Integration',
                                  sub_Category__c='ACLs',
                                   Notes__c = 'Sample Notes'
                                  );
        insert CN;
         
        test.startTest();
        // Create test case
        aCase = new Case(AccountId = account.id,
                         AssetId   = asset.Id,
                         ContactId = contact.id,
                         casecatCategory__c = 'Backup Integration',
                         caseSubCategory__c = 'ACLs',
                         LatestCommentId__c = '',
                         Origin = 'Web',
                         Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        test.stopTest();
        
        
        
        
        
    }
    
}