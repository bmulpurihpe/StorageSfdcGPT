@isTest
Private class ComponentNICDeleteBatchTest {

    class TestData{
        Account testAccount;
        Product2 testProduct1;
        Asset   testAsset1;
        Contact testContact;
        Component__c testComponent1;
        
        TestData(){
            // Create test Product2
            insert testProduct1 = new Product2(Name = 'CS215 Storage Array',
                                               ProductCode='CS215',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='SAN Storage Array',
                                               Controller_Code__c='CS215',
                                               Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                               Family='SAN Storage Array');
            
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            
            // Create test Asset 1
            insert testAsset1 = new Asset(Name                                      = 'AA-111111',
                                          AccountId                                 = testAccount.Id,
                                          ContactId                                 = testContact.Id,
                                          SLA__c                                    = 'Premium',
                                          Install_Street1__c                        = '123 Main Street',
                                          Install_Street2__c                        = 'Suite 100',
                                          Install_City__c                           = 'San Jose',
                                          Install_State_Province__c                 = 'CA',
                                          Install_Zip_Code__c                       = '95151',
                                          Install_Country__c                        = 'United States',
                                          Ship_Date__c                              = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     = Date.today(),
                                          assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                                          Status                                    = 'Shipped',
                                          Autosupport_Last_Received__c              = Date.today().addDays(-50),
                                          Product2Id=testProduct1.Id);
            
            // Create test Component
            insert testComponent1 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,
                                                     componentServicePartNumber__c='SR-PCI-10SFP',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='NIC_CARD',
                                                     componentTransaction__c = null,
                                                     componentItem__c = null,
                                                     componentDescription__c='Spare Dual 10G SFP+ Optical NIC for base');
        }
    }
    static testmethod void deleteComponents(){
        TestData      testData;
        List<Product2> testProduct2;
        List<Account> accounts;
        List<Contact> contacts;
        List<Asset>   assets;
        
        testData = new TestData();
        
        testProduct2 = [SELECT Name,
                        ProductCode,
                        Product_Type__c,
                        Product_Type_2__c,
                        Controller_Code__c,
                        Description,
                        Family FROM Product2 where Name='CS215 Storage Array'];
        
        //validate testProdcut2
        System.assertEquals(1,                  testProduct2.size());
        System.assertEquals('CS215 Storage Array', testProduct2[0].Name);
        System.assertEquals('CS215', testProduct2[0].ProductCode);
        System.assertEquals('Hardware', testProduct2[0].Product_Type__c);
        System.assertEquals('SAN Storage Array', testProduct2[0].Product_Type_2__c);
        System.assertEquals('CS215', testProduct2[0].Controller_Code__c);
        System.assertEquals('12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr', testProduct2[0].Description);
        System.assertEquals('SAN Storage Array', testProduct2[0].Family);
        
        // Validate test Account
        accounts = [SELECT Id,
                    Name
                    FROM   Account];
        
        System.assertEquals(1,                  accounts.size());
        System.assertEquals('Acme Corporation', accounts[0].Name);
        
        // Validate test Contact
        contacts = [SELECT Id,
                    LastName,
                    FirstName,
                    AccountId
                    FROM   Contact];
        
        System.assertEquals(1,                       contacts.size());
        System.assertEquals('Doe',                   contacts[0].LastName);
        System.assertEquals('John',                  contacts[0].FirstName);
        System.assertEquals(testData.testAccount.Id, contacts[0].AccountId);
        
        //validate test asset
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
                  Product2Id,
                  Asset_Type__c,
                  assetArenaProductCode__c,
                  Asset_Product_Family__c,
                  Product_Name__c,
                  Status, Autosupport_Last_Received__c    
                  FROM   Asset where Name='AA-111111'];
        
        System.assertEquals(1,                                       assets.size());
        System.assertEquals('AA-111111',                             assets[0].Name);
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
        System.assertEquals(Date.today().addDays(-50),               assets[0].Autosupport_Last_Received__c );
        System.assertEquals(Date.today(),                            assets[0].assetPartShipLastValidatedDatetime__c);
        System.assertEquals('Test part ship last validated by info', assets[0].assetPartShipLastValidatedByInfo__c);
        System.assertEquals(TestData.testProduct1.Id, assets[0].Product2Id);
        
        System.assertEquals('Legacy',assets[0].Asset_Type__c);
        System.assertEquals('CS215',assets[0].assetArenaProductCode__c);
        System.assertEquals('SAN Storage Array',assets[0].Asset_Product_Family__c);
        System.assertEquals('CS215 Storage Array',assets[0].Product_Name__c);
        System.assertEquals('Shipped',assets[0].Status);
        
        ComponentNICDeleteBatch componentDeleteBatch = new ComponentNICDeleteBatch();
        Database.executeBatch(componentDeleteBatch, 10);
    }
}