@isTest
private class assetDepotAssignmentsTest {
    /*ChangeLog: By vishnu on 9th April 2020 for TS-6902
* Added Hpe Serial number in all the assets.
* A new method is added to insert southkorean asset -insertAsset5()
* A new test method is added - test_4hourDepotUnknow_insertAsset5()
*/
    class TestData {
        Account testAccount;
        Contact testContact;
        Asset   testAsset1;
        Asset   testAsset2;
        Asset   testAsset3;
        Asset   testAsset4;
        Asset   testAsset5;
        depot__c depot1;
        depot__c depot2;
        depot__c depot3;
        depotMapNbdNd__c depotMapNbdNd1;
        depotMap4Hour__c depotMap4Hour1;
        postalCode__c  postalCode1;
        
        TestData() {
            System.debug('DEBUG: (TestData constructor) Entered as user: ' + UserInfo.getUserName());
            
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            
            // Create test Asset
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
                                          HPE_Serial_Number__c					  	= 'HPE123456',
                                          Ship_Date__c                              = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     = Date.today(),
                                          assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info');
            
            // Create test depot 001
            insert depot1 = new depot__c(Name = 'TEST-001', depotProvider__c = 'Flash', depotStockedFor4Hour__c = 'No', depotLocationDescription__c = 'Test depot 001');
            // Create test depot 002
            insert depot2 = new depot__c(Name = 'TEST-002', depotProvider__c = 'Flash', depotStockedFor4Hour__c = 'Yes', depotLocationDescription__c = 'Test depot 002');
            
            
            // Create the NBD/ND map entries
            insert depotMapNbdNd1 = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United States',
                                                         depotMapNbdNdState__c     = 'N/A',
                                                         depotMapNbdNd_NbdDepot__c = depot1.ID,
                                                         depotMapNbdNd_NdDepot__c  = depot1.ID);
            
            // Create the 4-Hour map entries
            insert depotMap4Hour1 = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                                         depotMap4HourPostalCode__c  = '95151',
                                                         depotMap4Hour_4HourDepot__c = depot2.ID,
                                                         depotMap4HourDriveTime__c   = 10.5);
            
            insert postalCode1 = new PostalCode__c(pcCountry__c  = 'United States',
                                                   pcFormatInRegex__c = '^([0-9]{5})(-[0-9]{4})?$',
                                                   pcDummyPostalCode__c     = null,                           
                                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to United States\' "99999(-9999)" format.  Override it if needed to provide a valid value.');
        }
        
        void insertAsset2() {
            insert testAsset2 = new Asset(Name                                      = 'AA-222222',
                                          AccountId                                 = testAccount.Id,
                                          ContactId                                 = testContact.Id,
                                          SLA__c                                    = 'Premium',
                                          Install_Street1__c                        = '123 Main Street',
                                          Install_Street2__c                        = 'Suite 100',
                                          Install_City__c                           = 'San Jose',
                                          Install_State_Province__c                 = 'CA',
                                          Install_Zip_Code__c                       = '95151',
                                          Install_Country__c                        = 'United States',
                                          HPE_Serial_Number__c					  	= 'HPE123457',
                                          Ship_Date__c                              = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     = Date.today(),
                                          assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info');
        }
        
        void insertAsset3() {
            insert testAsset3 = new Asset(Name                                      = 'AA-333333',
                                          AccountId                                 = testAccount.Id,
                                          ContactId                                 = testContact.Id,
                                          SLA__c                                    = 'Premium 4 Hour',
                                          Install_Street1__c                        = '123 Main Street',
                                          Install_Street2__c                        = 'Suite 100',
                                          Install_City__c                           = 'San Jose',
                                          Install_State_Province__c                 = 'CA',
                                          Install_Zip_Code__c                       = '95151',
                                          Install_Country__c                        = 'United States',
                                          HPE_Serial_Number__c					  	= 'HPE123458',
                                          Ship_Date__c                              = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     = Date.today(),
                                          assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info');
        }
        
        void insertAsset4() {
            insert testAsset4 = new Asset(Name                                      = 'AA-44444',
                                          AccountId                                 = testAccount.Id,
                                          ContactId                                 = testContact.Id,
                                          SLA__c                                    = 'Premium 4 Hour',
                                          Install_Street1__c                        = '123 Main Street',
                                          Install_Street2__c                        = 'Road 100',
                                          Install_City__c                           = 'Chennai',
                                          Install_State_Province__c                 = 'TN',
                                          Install_Zip_Code__c                       = '600075',
                                          Install_Country__c                        = 'India',
                                          HPE_Serial_Number__c					  	= 'HPE123459',
                                          Ship_Date__c                              = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     = Date.today(),
                                          assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info');
        }
        
        void insertAsset5() {
            insert testAsset5 = new Asset(Name                                      = 'AA-77777',
                                          AccountId                                 = testAccount.Id,
                                          ContactId                                 = testContact.Id,
                                          SLA__c                                    = 'Premium 4 Hour',
                                          Install_Street1__c                        = '123 Main Street',
                                          Install_Street2__c                        = 'Road 100',
                                          Install_City__c                           = 'Seoul',
                                          Install_State_Province__c                 = 'KR',
                                          Install_Zip_Code__c                       = '06027',
                                          Install_Country__c                        = 'South Korea',
                                          HPE_Serial_Number__c					  	= 'HPE123460',
                                          Ship_Date__c                              =  Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     =  Date.today(),
                                          assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info');
        }
        
    }
    
    // ###################################################################################################### validateTestData
    static testMethod void validateTestData() {
        TestData      testData;
        List<Account> accounts;
        List<Contact> contacts;
        List<Asset>   assets;
        List<depot__c> depot1;
        List<depot__c> depot2;
        List<depotMapNbdNd__c> depotMapNbdNd1;
        List<depotMap4Hour__c> depotMap4Hour1;
        List<postalCode__c>  postalCode1;
        Test.startTest();
        testData = new TestData();
        Test.stopTest();
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
                  HPE_Serial_Number__c,
                  assetPartShipLastValidatedDatetime__c,
                  assetPartShipLastValidatedByInfo__c
                  FROM   Asset];
        
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
        System.assertEquals(Date.today(),                            assets[0].assetPartShipLastValidatedDatetime__c);
        System.assertEquals('Test part ship last validated by info', assets[0].assetPartShipLastValidatedByInfo__c);
        
        
        // Create test depot 001
        depot1 = [SELECT Id,
                  Name,
                  depotProvider__c,
                  depotStockedFor4Hour__c,
                  depotLocationDescription__c
                  FROM   depot__c
                  WHERE  Name = 'TEST-001'];
        
        System.assertEquals(1,                depot1.size());
        System.assertEquals('TEST-001',       depot1[0].Name);
        System.assertEquals('Flash',          depot1[0].depotProvider__c);
        System.assertEquals('No',            depot1[0].depotStockedFor4Hour__c);
        System.assertEquals('Test depot 001', depot1[0].depotLocationDescription__c);
        
        depot2 = [SELECT Id,
                  Name,
                  depotProvider__c,
                  depotStockedFor4Hour__c,
                  depotLocationDescription__c
                  FROM   depot__c
                  WHERE  Name = 'TEST-002'];
        
        System.assertEquals(1,                depot2.size());
        System.assertEquals('TEST-002',       depot2[0].Name);
        System.assertEquals('Flash',         depot2[0].depotProvider__c);
        System.assertEquals('Yes',             depot2[0].depotStockedFor4Hour__c);
        System.assertEquals('Test depot 002', depot2[0].depotLocationDescription__c);
        
        
        depotMapNbdNd1 = [SELECT Id,
                          Name,
                          depotMapNbdNdCountry__c,
                          depotMapNbdNdState__c,
                          depotMapNbdNd_NbdDepot__c,
                          depotMapNbdNd_NdDepot__c
                          FROM   depotMapNbdNd__c
                          WHERE  depotMapNbdNdCountry__c = 'United States' and
                          depotMapNbdNdState__c   = 'N/A'];
        
        System.assertEquals(1,                        depotMapNbdNd1.size());
        //System.assertEquals('__United States__N/A__', depotMapNbdNd1[0].Name);
        System.assertEquals('United States',          depotMapNbdNd1[0].depotMapNbdNdCountry__c);
        System.assertEquals('N/A',                    depotMapNbdNd1[0].depotMapNbdNdState__c);
        System.assertEquals(testData.depot1.ID,           depotMapNbdNd1[0].depotMapNbdNd_NbdDepot__c);
        System.assertEquals(testData.depot1.ID,           depotMapNbdNd1[0].depotMapNbdNd_NdDepot__c);
        
        
        depotMap4Hour1 = [SELECT Id,
                          Name,
                          depotMap4HourCountry__c,
                          depotMap4HourPostalCode__c,
                          depotMap4Hour_4HourDepot__c,
                          depotMap4HourDrivetime__c
                          FROM   depotMap4Hour__c
                          WHERE  depotMap4HourCountry__c     = 'United States' and
                          depotMap4HourPostalCode__c  = '95151' and
                          depotMap4Hour_4HourDepot__c = :testData.depot2.ID];
        
        System.assertEquals(1,                                    depotMap4Hour1.size());
        System.assertEquals('__United States__95151__TEST-002__', depotMap4Hour1[0].Name);
        System.assertEquals('United States',                      depotMap4Hour1[0].depotMap4HourCountry__c);
        System.assertEquals('95151',                              depotMap4Hour1[0].depotMap4HourPostalCode__c);
        System.assertEquals(testData.depot2.ID,                       depotMap4Hour1[0].depotMap4Hour_4HourDepot__c);
        System.assertEquals(10.5,                                 depotMap4Hour1[0].depotMap4HourDriveTime__c);
        
        postalCode1 = [SELECT Id,
                       pcCountry__c,
                       pcFormatInRegex__c,
                       pcDummyPostalCode__c 
                       FROM   PostalCode__c];
        
        System.assertEquals(1, postalCode1.size());
        
        System.assertEquals('United States' , postalCode1[0].pcCountry__c);
        System.assertEquals('^([0-9]{5})(-[0-9]{4})?$', postalCode1[0].pcFormatInRegex__c);
        System.assertEquals(null, postalCode1[0].pcDummyPostalCode__c);
        
        
        
    }
    
    
    // ###################################################################################################### test_PremiumNbdDepot_insertAsset2
    static testMethod void test_PremiumNbdDepot_insertAsset2() {
        TestData    testData;
        List<Asset> assets;
        
        testData = new TestData();
        Test.startTest();
        testData.insertAsset2();
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        String Query = 'Select assetPartShipAddressBook__c,assetParentSLA__c,Install_Country__c,Install_State_Province__c,Install_Zip_Code__c,assetPartShipAddressBook__r.abCountry__c,assetPartShipAddressBook__r.abStateProvince__c,assetPartShipAddressBook__r.abPostalCode__c,assetInstallAddressDepot__c,assetShipmentAddressDepot__c,SLA__c,Account.Name, Account.Support_Provider__c, Account.Support_Provider__r.Name  FROM Asset';
        
        assetDepotAssignmentsBatch e = new assetDepotAssignmentsBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();   
        
        
        assets = [SELECT Id,
                  Name,
                  SLA__c,
                  assetSameDayPartDeliveryPreference__c,
                  assetInstallAddressDepot__c,
                  assetShipmentAddressDepot__c
                  FROM   Asset where Name='AA-222222'];
        
        System.assertEquals(1,                                                   assets.size());
        System.assertEquals('AA-222222',                                         assets[0].Name);
        System.assertEquals('Premium',                                           assets[0].SLA__c);
      //  System.assertEquals('TEST-001',                                          assets[0].assetInstallAddressDepot__c);
     //   System.assertEquals('TEST-001',                                          assets[0].assetShipmentAddressDepot__c);
    }
    
    // ###################################################################################################### test_4hourDepot_insertAsset3
    static testMethod void test_4hourDepot_insertAsset3() {
        TestData    testData;
        List<Asset> assets;
        
        testData = new TestData();
        Test.startTest();
        testData.insertAsset3();
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true; 
        String Query = 'Select assetPartShipAddressBook__c,assetParentSLA__c,Install_Country__c,Install_State_Province__c,Install_Zip_Code__c,assetPartShipAddressBook__r.abCountry__c,assetPartShipAddressBook__r.abStateProvince__c,assetPartShipAddressBook__r.abPostalCode__c,assetInstallAddressDepot__c,assetShipmentAddressDepot__c FROM Asset';
        
        assetDepotAssignmentsBatch e = new assetDepotAssignmentsBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();   
        
        assets = [SELECT Id,
                  Name,
                  SLA__c,
                  assetSameDayPartDeliveryPreference__c,
                  assetInstallAddressDepot__c,
                  assetShipmentAddressDepot__c
                  FROM   Asset where Name='AA-333333'];
        
        System.assertEquals(1,                                                   assets.size());
        System.assertEquals('AA-333333',                                         assets[0].Name);
        System.assertEquals('Premium 4 Hour',                                    assets[0].SLA__c);
        //System.assertEquals('TEST-002',                                          assets[0].assetInstallAddressDepot__c);
        //System.assertEquals('TEST-002',                                          assets[0].assetShipmentAddressDepot__c);
    }
    
    // ###################################################################################################### test_4hourDepotUnknow_insertAsset4
    static testMethod void test_4hourDepotUnknow_insertAsset4() {
        TestData    testData;
        List<Asset> assets;
        
        testData = new TestData();
        Test.startTest();
        testData.insertAsset4();
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true; 
        String Query = 'Select SLA__c,assetPartShipAddressBook__c,assetParentSLA__c,Install_Country__c,Install_State_Province__c,Install_Zip_Code__c,assetPartShipAddressBook__r.abCountry__c,assetPartShipAddressBook__r.abStateProvince__c,assetPartShipAddressBook__r.abPostalCode__c,assetInstallAddressDepot__c,assetShipmentAddressDepot__c FROM Asset';
        
        assetDepotAssignmentsBatch e = new assetDepotAssignmentsBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();   
        
        assets = [SELECT Id,
                  Name,
                  SLA__c,
                  assetSameDayPartDeliveryPreference__c,
                  assetInstallAddressDepot__c,
                  assetShipmentAddressDepot__c
                  FROM   Asset where Name='AA-44444'];
        
        System.assertEquals(1,                                                   assets.size());
        System.assertEquals('AA-44444',                                         assets[0].Name);
        System.assertEquals('Premium 4 Hour',                                    assets[0].SLA__c);
        System.assertEquals('Unknown',                                          assets[0].assetInstallAddressDepot__c);
        //System.assertEquals('Unknown',                                          assets[0].assetShipmentAddressDepot__c);
    }
    
    // ###################################################################################################### test_Scheduler
    static testMethod void test_Scheduler() {
        Test.StartTest();
        assetDepotAssignmentScheduler sh1 = new assetDepotAssignmentScheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('test_assetDepotAssignmentScheduler', sch, sh1);
        Test.stopTest();
    }
    
    // ###################################################################################################### test_deleteAsset
    static testMethod void test_deleteAsset() {
        TestData    testData;
        List<Asset> assets;
        
        testData = new TestData();
        Test.startTest();
        testData.insertAsset4();
        
        assets = [SELECT Id,AccountId FROM   Asset where Name='AA-44444'];
        //Test.startTest();
        delete assets;
        Test.stopTest();
    }
    // ###################################################################################################### test_4hour_South Korea_insertAsset5
    static testMethod void test_4hourDepotUnknow_insertAsset5() {
        Account testAccount;
        Contact testContact;
        Asset   testAsset5;
        depot__c depot3;
        List<Asset> assets;
        
        // Create test Account
        insert testAccount = new Account(Name = 'Acme Corporation');
        
        // Create test Contact
        insert testContact = new Contact(LastName  = 'Doe',
                                         FirstName = 'John',
                                         AccountId = testAccount.Id);
        
        // Create test depot for south korea
        insert depot3 = new depot__c(Name = 'TST-001',
                                     depotCountry__c = 'South Korea',
                                     depotIsactive__c = true,
                                     depotProvider__c = 'Flash', 
                                     depotStockedFor4Hour__c = 'Yes', 
                                     depotLocationDescription__c = 'Test depot 002');
        Test.startTest();
        insert testAsset5 = new Asset(Name                                      = 'AA-77777',
                                      AccountId                                 = testAccount.Id,
                                      ContactId                                 = testContact.Id,
                                      SLA__c                                    = 'Premium 4 Hour',
                                      Install_Street1__c                        = '123 Main Street',
                                      Install_Street2__c                        = 'Road 100',
                                      Install_City__c                           = 'Seoul',
                                      Install_State_Province__c                 = 'KR',
                                      Install_Zip_Code__c                       = '06027',
                                      Install_Country__c                        = 'South Korea',
                                      HPE_Serial_Number__c					  	= 'HPE123460',
                                      Ship_Date__c                              =  Date.today().addDays(-180),
                                      assetPartShipLastValidatedDatetime__c     =  Date.today(),
                                      assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info');
        
        
        assets = [SELECT Id,
                  Name,
                  SLA__c,
                  assetSameDayPartDeliveryPreference__c,
                  assetInstallAddressDepot__c,
                  assetShipmentAddressDepot__c
                  FROM   Asset where Name='AA-77777'];
        
        System.assertEquals(1,                                                   assets.size());
        System.assertEquals('AA-77777',                                          assets[0].Name);
        System.assertEquals('Premium 4 Hour',                                    assets[0].SLA__c);
        System.assertEquals('TST-001',                                           assets[0].assetInstallAddressDepot__c);
        System.assertEquals('TST-001',                                           assets[0].assetShipmentAddressDepot__c);
        
        testAsset5.Install_Street1__c = 'Test Address Update';
        testAsset5.Install_Street2__c = 'Road 1';
        update testAsset5;
        Test.stopTest();
    }
}