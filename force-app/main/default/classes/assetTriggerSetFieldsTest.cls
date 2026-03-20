@isTest
private class assetTriggerSetFieldsTest {
    class TestData {
        Account testAccount;
        Contact testContact;
        Asset   testAsset1;
        Product2 testProduct1;
        
        TestData() {
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            insert testProduct1 = new Product2(Name               = 'SSD Storage Array',
                                               ProductCode        = 'SSD123',
                                               Product_Type__c    = 'Hardware',
                                               Product_Type_2__c  = 'SAN Storage ArrayS',
                                               Controller_Code__c = 'CS2001',
                                               Description        = '12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                               Family             = 'SAN Storage Array');
            
            // Create test Asset
            insert testAsset1 = new Asset(Name                 = 'TEST-ASSET',
                                          AccountId            = testAccount.Id,
                                          ContactId            = testContact.Id,
                                          SLA__c               = 'Premium',
                                          Array_Controller__c  = 'CS300',
                                          Product2Id           = testProduct1.id,
                                          assetRmaShi__c       = 'Asset RMA SHI',
                                          HPE_Serial_Number__c = 'AA000000NIM',
                                          Install_Street1__c   = '123 Main Street',
                                          Install_Street2__c   = 'Suite 100',
                                          Install_City__c      = 'San Jose',
                                          Install_State_Province__c = 'CA',
                                          Install_Zip_Code__c = '95151',
                                          Install_Country__c  = 'United States',
                                          Nimble_Version__c   = '11.1.111.135-opt123',
                                          Ship_Date__c        = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c = Date.today(),
                                          assetPartShipLastValidatedByInfo__c   = 'Test part ship last validated by info');
            
            
        }
        
    }
    
    static testMethod void test_setNimbleOSVersion() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
        
        // Validate test Asset
        assets = [SELECT Id,
                  Name,
                  AccountId,
                  ContactId,
                  SLA__c,
                  Install_Street1__c,
                  Install_Street2__c,
                  Install_City__c,
                  Install_State_Province__c,
                  Install_Zip_Code__c,
                  Install_Country__c,
                  Ship_Date__c,
                  assetPartShipLastValidatedDatetime__c,
                  assetPartShipLastValidatedByInfo__c,
                  Nimble_Version__c,
                  assetNimbleOsVersion__c
                  FROM   Asset];
        
        System.assertEquals(1,                                       assets.size());
        System.assertEquals('TEST-ASSET',                             assets[0].Name);
        System.assertEquals(testData.testAccount.Id,                 assets[0].AccountId);
        System.assertEquals(testData.testContact.Id,                 assets[0].ContactId);
        System.assertEquals('Premium',                               assets[0].SLA__c);
        System.assertEquals('123 Main Street',                       assets[0].Install_Street1__c);
        System.assertEquals('Suite 100',                             assets[0].Install_Street2__c);
        System.assertEquals('San Jose',                              assets[0].Install_City__c);
        System.assertEquals('CA',                                    assets[0].Install_State_Province__c);
        System.assertEquals('95151',                                 assets[0].Install_Zip_Code__c);
        System.assertEquals('United States',                         assets[0].Install_Country__c);
        System.assertEquals(Date.today().addDays(-180),              assets[0].Ship_Date__c);
        System.assertEquals(Date.today(),                            assets[0].assetPartShipLastValidatedDatetime__c);
        System.assertEquals('Test part ship last validated by info', assets[0].assetPartShipLastValidatedByInfo__c);
        System.assertEquals('11.1.111.135-opt123', assets[0].Nimble_Version__c);
        System.assertEquals('11.1.111.135', assets[0].assetNimbleOsVersion__c);
    }
    
    static testMethod void test_setNimbleOSVersion_Batch() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
        
        
        Test.startTest();
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        string query = 'Select Id,Nimble_Version__c,assetNimbleOsVersion__c from Asset';
        assetSetNimbleOsVesionBatch e = new assetSetNimbleOsVesionBatch(query);
        Database.executeBatch(e);
        Test.stopTest();
        
        // Validate test Asset
        assets = [SELECT Id,
                  Name,
                  AccountId,
                  ContactId,
                  SLA__c,
                  Install_Street1__c,
                  Install_Street2__c,
                  Install_City__c,
                  Install_State_Province__c,
                  Install_Zip_Code__c,
                  Install_Country__c,
                  Ship_Date__c,
                  assetPartShipLastValidatedDatetime__c,
                  assetPartShipLastValidatedByInfo__c,
                  Nimble_Version__c,
                  assetNimbleOsVersion__c
                  FROM   Asset];
        
        System.assertEquals(1,                                       assets.size());
        System.assertEquals('TEST-ASSET',                             assets[0].Name);
        System.assertEquals(testData.testAccount.Id,                 assets[0].AccountId);
        System.assertEquals(testData.testContact.Id,                 assets[0].ContactId);
        System.assertEquals('Premium',                               assets[0].SLA__c);
        System.assertEquals('123 Main Street',                       assets[0].Install_Street1__c);
        System.assertEquals('Suite 100',                             assets[0].Install_Street2__c);
        System.assertEquals('San Jose',                              assets[0].Install_City__c);
        System.assertEquals('CA',                                    assets[0].Install_State_Province__c);
        System.assertEquals('95151',                                 assets[0].Install_Zip_Code__c);
        System.assertEquals('United States',                         assets[0].Install_Country__c);
        System.assertEquals(Date.today().addDays(-180),              assets[0].Ship_Date__c);
        System.assertEquals(Date.today(),                            assets[0].assetPartShipLastValidatedDatetime__c);
        System.assertEquals('Test part ship last validated by info', assets[0].assetPartShipLastValidatedByInfo__c);
        System.assertEquals('11.1.111.135-opt123', assets[0].Nimble_Version__c);
        System.assertEquals('11.1.111.135', assets[0].assetNimbleOsVersion__c);
        
        
        
    }
}