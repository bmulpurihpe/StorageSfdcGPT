/*                              <<<< === Test Class for AssetComponentPopulationFromArenaBatch apex class === >>>>
    =============================================================================================================
        Name                    : AssetComponentPopulationBatchTestv1
        Description             : To verify the minimum test coverage for the logic in the AssetComponentPopulationFromArenaBatch class.
								  new version of the test class AssetComponentPopulationBatchTest,resolving all the 101 SOQL issues. 
        Created Date            : 14th april 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
@isTest
private class AssetComponentPopulationBatchTestv1 {
    
    class TestData {
        Account testAccount;
        Product2 testProduct1;//CS220
        Product2 testProduct2;//ES1-H90T
        Product2 testProduct3;//NGA-CS300
        Contact testContact;
        Asset   testAsset1;//Legacy - Returned
        Asset   testAsset2;//Legacy - Shipped
        Asset   testAsset3;//Other
        Asset   testAsset4;//Next-Gen
        SR_Meta_Data__c testSrMetaData;
        Component__c testComponent1;
        Component__c testComponent2;
        Component__c testComponent3;
        Component__c testComponent4;
        Case aCase;
        RMAv2__c rmas;
        AddressBook__c ab;
        ArenaPartSubstitution__c aps;
        
        TestData() {
            
            //Custom Settings
            ArenaPLM__c arenaPLMLogin = new ArenaPLM__c();
            arenaPLMLogin.Name='Arena PLM Login';
            arenaPLMLogin.UserName__c='testUser';
            arenaPLMLogin.Password__c='testPassword';
            insert arenaPLMLogin;
            insert aps =new ArenaPartSubstitution__c(apsSFDCPart__c = 'TestPart',aspEquivalentArenaPart__c = 'test part');
            
        }
        
        //void insertArena(){
            
        //}
        
        void InsertProduct_01(){
            //Create PROD 1
            insert testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                               ProductCode='CS220',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='SAN Storage Array',
                                               Controller_Code__c='CS200',
                                               Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                               Family='SAN Storage Array');
        }
        
        void InsertProduct_02(){
            //Create PROD 2
            insert testProduct2 = new Product2(Name = 'ES1-H90T',
                                               ProductCode='ES1-H90T',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='Expansion Shelves',
                                               Product_Sub_Type__c='ES1',
                                               Description='90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable',
                                               Family='Expansion Shelves');
        }
        
        void InsertProduct_03(){
            //Create PROD 3
            insert testProduct3 = new Product2(Name = 'CS300 Storage Array',
                                               ProductCode='NGA-CS300',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='SAN Storage Array',
                                               Controller_Code__c='CS300',
                                               Component_Code__c = 'CS300',
                                               Description='CS300 Storage Array',
                                               Family='SAN Storage Array');
        }
        
        void CreateTestAccount_01(){
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
        }
        
        void CreateTestContact_01(){
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
        }
        
        void CreateTestAsset_01(){
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
        }
        
        void createAssetAsShipped(){
            // Create test Asset 2
            insert testAsset2 = new Asset(Name                                 = 'AA-111111',
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
                                          Product2Id=testProduct1.Id);
        }
        
        void CreateTestAsset_03(){
            // Create test Asset 3
            insert testAsset3 = new Asset(Name                                      = 'AA-333333',
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
                                          Product2Id=testProduct2.Id);
        }
        
        void CreateTestAsset_04(){
            // Create test Asset 4
            insert testAsset4 = new Asset(Name                                      = 'AA-444444',
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
                                          Product2Id=testProduct3.Id,
                                          Array_Controller__c='CS300',
                                          Array_Networking__c='4G',
                                          Array_Capacity__c='36T',
                                          Array_Cache__c='3200F',
                                          Array_Controller_SKU__c=null,
                                          Array_Networking_SKU__c='PCI-1GTx2',
                                          Array_Capacity_SKU__c='HEAD-HDD-36TB',
                                          Array_Cache_SKU__c='HEAD-FLC-3200GB');
        }
        
        void CreateTestSrMetaData_01(){
            insert testSrMetaData = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1200W',srmetadataIsValid__c = true,
                                                        srType__c = 'PWR(power supply)',Is_In_Prod__c = true,
                                                        srDescription__c='Service Power Supply Unit for CS Arrays, 1200W',
                                                        srShippingProvider__c='Flash');
        }
        
        void changeToLowerAsset() {
            testAsset1.Name = 'AA-100000';
            update testAsset1;
        }
        
        void updateAssetAsReturned(){
            testAsset1.Status = 'Returned';
            update testAsset1;
        }
        
        void createComponentForShippedAsset(){
            
            insert testComponent1 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC');
            
            insert testComponent2 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,
                                                     componentServicePartNumber__c='SR-USB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC');
            
            insert testComponent3 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,
                                                     componentServicePartNumber__c='SR-HDD-600GB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='HDD',
                                                     componentDescription__c='Service HDD, 600GB, with carrier');
            insert testComponent3 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,                                                    
                                                     componentServicePartNumber__c = 'SR-CONT',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='Controller',
                                                     componentDescription__c='Service HDD, 600GB, with carrier');
        }
       
        void insertShipmentFlexRows(){
            //Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where shipmentFlexflowUnitSerialNumber__c=\'AF-109474\'';
            Shipment_Flexflow__c shipmentFlexFlow;
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Controller Vendor S/N',
                                                               shipmentFlexflowChildSn__c='10000',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Controller Vendor S/N',
                                                               shipmentFlexflowChildSn__c='10000',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',                                                              
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Controller Vendor S/N',
                                                               shipmentFlexflowChildSn__c='10000',
                                                               shipmentFlexflowItem__c='SR-CONT',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='LEFT PSU',
                                                               shipmentFlexflowChildSn__c='10001',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Right PSU',
                                                               shipmentFlexflowChildSn__c='10002',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Power Supply',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowChildLotNumber__c = 'PWS-1K21P-1R',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Power Supply',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowChildLotNumber__c = 'PWS-1K23A-1R',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null); 
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='207-0001-001',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowChildLotNumber__c = '123456Test',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Power Supply',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowChildLotNumber__c = '123456Test',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='207-0003-001',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowChildLotNumber__c = '123456Test',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='207-0003-001',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='SR-CS440-',
                                                               shipmentFlexflowChildLotNumber__c = '123456Test',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Test1',
                                                               shipmentFlexflowChildSn__c='10004',
                                                               shipmentFlexflowItem__c='NMB-SR-CON',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Test2',
                                                               shipmentFlexflowChildSn__c='10005',
                                                               shipmentFlexflowItem__c='NMBR-SR-HD',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            //CUEXAZ7MNXGXGVQ2PXN9
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-650-0109-001',
                                                               shipmentFlexflowChildSn__c='10006',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-220-0102-001',
                                                               shipmentFlexflowChildSn__c='10007',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = null);
            
        }
    }
    // ###################################################################################################### validateTestData
    static testMethod void validateTestData() {
        TestData      testData;
        List<Product2> testProduct2;
        List<Account> accounts;
        List<Contact> contacts;
        List<Asset>   assets;
        List<SR_Meta_Data__c>   srMetaDatas;
        
        testData = new TestData();
        testData.InsertProduct_01();
        testData.InsertProduct_02();
        testData.InsertProduct_03();
        testData.CreateTestAccount_01();
        testData.CreateTestContact_01();
        testData.CreateTestAsset_01();
        Test.startTest();
        testData.CreateTestAsset_03();
        testData.CreateTestAsset_04();
        testData.CreateTestSrMetaData_01();
        
        //Validate test Product 1
        testProduct2 = [SELECT Name,
                        ProductCode,
                        Product_Type__c,
                        Product_Type_2__c,
                        Controller_Code__c,
                        Description,
                        Family FROM Product2 where Name='CS220 Storage Array'];
        
        
        
        System.assertEquals(1,                  testProduct2.size());
        System.assertEquals('CS220 Storage Array', testProduct2[0].Name);
        System.assertEquals('CS220', testProduct2[0].ProductCode);
        System.assertEquals('Hardware', testProduct2[0].Product_Type__c);
        System.assertEquals('SAN Storage Array', testProduct2[0].Product_Type_2__c);
        System.assertEquals('CS200', testProduct2[0].Controller_Code__c);
        System.assertEquals('12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr', testProduct2[0].Description);
        System.assertEquals('SAN Storage Array', testProduct2[0].Family);
        
        //Validate test Product 2
        testProduct2 = [SELECT Name,
                        ProductCode,
                        Product_Type__c,
                        Product_Type_2__c,
                        Product_Sub_Type__c,
                        Description,
                        Family FROM Product2 where Name='ES1-H90T'];
        
        System.assertEquals(1,                  testProduct2.size());
        System.assertEquals('ES1-H90T', testProduct2[0].Name);
        System.assertEquals('ES1-H90T', testProduct2[0].ProductCode);
        System.assertEquals('Hardware', testProduct2[0].Product_Type__c);
        System.assertEquals('Expansion Shelves', testProduct2[0].Product_Type_2__c);
        System.assertEquals('ES1', testProduct2[0].Product_Sub_Type__c);
        System.assertEquals('90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable', testProduct2[0].Description);
        System.assertEquals('Expansion Shelves', testProduct2[0].Family);
        
        
        //Validate test Product 3
        testProduct2 = [SELECT Name,
                        ProductCode,
                        Product_Type__c,
                        Product_Type_2__c,
                        Controller_Code__c,
                        Component_Code__c,
                        Description,
                        Family FROM Product2 where Name='CS300 Storage Array'];
        
        System.assertEquals(1,                  testProduct2.size());
        System.assertEquals('CS300 Storage Array', testProduct2[0].Name);
        System.assertEquals('NGA-CS300', testProduct2[0].ProductCode);
        System.assertEquals('Hardware', testProduct2[0].Product_Type__c);
        System.assertEquals('SAN Storage Array', testProduct2[0].Product_Type_2__c);
        System.assertEquals('CS300', testProduct2[0].Controller_Code__c);
        System.assertEquals('CS300', testProduct2[0].Component_Code__c);
        System.assertEquals('CS300 Storage Array', testProduct2[0].Description);
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
        
        // Validate test Asset 1
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
        System.assertEquals('CS220',assets[0].assetArenaProductCode__c);
        System.assertEquals('SAN Storage Array',assets[0].Asset_Product_Family__c);
        System.assertEquals('CS220 Storage Array',assets[0].Product_Name__c);
        System.assertEquals('Shipped',assets[0].Status);
        
        
        // Validate test Asset 3
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
                  Status
                  FROM   Asset where Name='AA-333333'];
        
        System.assertEquals(1,                                       assets.size());
        System.assertEquals('AA-333333',                             assets[0].Name);
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
        System.assertEquals(TestData.testProduct2.Id, assets[0].Product2Id);
        
        //System.assertEquals('Other',assets[0].Asset_Type__c);
        System.assertEquals('ES1-H90T',assets[0].assetArenaProductCode__c);
        System.assertEquals('Expansion Shelves',assets[0].Asset_Product_Family__c);
        System.assertEquals('ES1-H90T',assets[0].Product_Name__c);
        System.assertEquals('Shipped',assets[0].Status);
        
        
        
        // Validate test Asset 4
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
                  Status,
                  Array_Controller__c,
                  Array_Networking__c,
                  Array_Capacity__c,
                  Array_Cache__c,
                  Array_Controller_SKU__c,
                  Array_Networking_SKU__c,
                  Array_Capacity_SKU__c,
                  Array_Cache_SKU__c
                  FROM   Asset where Name='AA-444444'];
        
        System.assertEquals(1,                                       assets.size());
        System.assertEquals('AA-444444',                             assets[0].Name);
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
        System.assertEquals(TestData.testProduct3.Id, assets[0].Product2Id);
        
        System.assertEquals('Next Gen',assets[0].Asset_Type__c);
        System.assertEquals('CS300',assets[0].assetArenaProductCode__c);
        System.assertEquals('SAN Storage Array',assets[0].Asset_Product_Family__c);
        System.assertEquals('CS300-4G-36T-3200F',assets[0].Product_Name__c);
        System.assertEquals('Shipped',assets[0].Status);
        
        System.assertEquals('CS300',assets[0].Array_Controller__c);
        System.assertEquals('4G',assets[0].Array_Networking__c);
        System.assertEquals('36T',assets[0].Array_Capacity__c);
        System.assertEquals('3200F',assets[0].Array_Cache__c);
        System.assertEquals('NGA-CS300',assets[0].Array_Controller_SKU__c);
        Test.stopTest();
        srMetaDatas = [Select srPart__c,
                       srType__c,
                       srDescription__c,
                       srShippingProvider__c from SR_Meta_Data__c];
        
        System.assertEquals(1,                                       srMetaDatas.size());
        System.assertEquals('SR-PWR-1200W',                             srMetaDatas[0].srPart__c);
        System.assertEquals('PWR(power supply)',                 srMetaDatas[0].srType__c);
        System.assertEquals('Service Power Supply Unit for CS Arrays, 1200W',                 srMetaDatas[0].srDescription__c);
        System.assertEquals('Flash',                 srMetaDatas[0].srShippingProvider__c);
        
        
    }
    // ###################################################################################################### assetTypeLegacy_HigherAssetSN_WithoutShipmentFlexFlow
    static testMethod void assetTypeLegacy_HigherAssetSN_WithoutShipmentFlexFlow() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
        testData.InsertProduct_01();
        testData.CreateTestAccount_01();
        testData.CreateTestContact_01();
        testData.CreateTestAsset_01();
        //testData.();
        
        String baseUrl = 'https://api.arenasolutions.com/v1';
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(baseUrl + '/login', 'ArenaLoginCallouts');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=0','ArenaItemLimit0to400');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=400','ArenaItemLimit400to800');
        multimock.setStaticResource(baseUrl + '/items/WEYHUJR67H0H0FAD5A3Q/bom','ArenaPBOMs');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        string queryshipment = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = \'AA-111111\' AND shipmentFlexflowFlexProcessed__c = null';
        AssetFlexFlowCatchUpProcessbatch  shipmentBatch = new AssetFlexFlowCatchUpProcessbatch(queryshipment);
        Database.executeBatch(shipmentBatch);
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber,Inventory_SKUs__c from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-111111\' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        
        Test.stopTest();
        
        
        List<Component__c> components = [Select Id from Component__c];
        System.assertEquals(23,components.size());
        
        //List<Component__c> Highercomponents = [Select Id,componentState__c,Sub_State__c,componentAsset__c,componentTransaction__c,componentLocation__c,componentAssetStatus__c,componentServicePartNumber__c,componentAssetName__c,componentComponentSN__c,componentType__c,componentItem__c,ComponentCreatedFromInformation__c from Component__c where componentServicePartNumber__c='SR-HDD-1TB-SAS' or componentServicePartNumber__c='SR-SSD-3500-80GB'];
        
        //Higher Part Should Exist (Skipping Lower Part)
        List<Component__c> Highercomponents = [Select Id from Component__c where componentServicePartNumber__c='SR-HDD-1TB-SAS' or componentServicePartNumber__c='SR-SSD-3500-80GB'];
        System.assertEquals(16,Highercomponents.size());
        
        //Check the Status of the Asset
        assets = [Select Id,Name,assetComponentCreatedStatus__c,assetComponentProcessedMessage__c,Inventory_SKUs__c from Asset where Name='AA-111111'];
        System.assertEquals(1,assets.size());
        System.assertEquals('AA-111111',assets[0].Name);
        System.assertEquals('Success',assets[0].assetComponentCreatedStatus__c);
        System.assertEquals(null,assets[0].assetComponentProcessedMessage__c);

    }
    // ###################################################################################################### assetTypeLegacy_LowerAssetSN_WithoutShipmentFlexFlow
    static testMethod void assetTypeLegacy_LowerAssetSN_WithoutShipmentFlexFlow() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
        testData.InsertProduct_01();
        testData.CreateTestAccount_01();
        testData.CreateTestContact_01();
        testData.CreateTestAsset_01();
        testData.changeToLowerAsset();
        
        String baseUrl = 'https://api.arenasolutions.com/v1';
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(baseUrl + '/login', 'ArenaLoginCallouts');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=0','ArenaItemLimit0to400');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=400','ArenaItemLimit400to800');
        multimock.setStaticResource(baseUrl + '/items/WEYHUJR67H0H0FAD5A3Q/bom','ArenaPBOMs');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        string queryshipment = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = \'AA-100000\' AND shipmentFlexflowFlexProcessed__c = null' ;
        AssetFlexFlowCatchUpProcessbatch  shipmentBatch = new AssetFlexFlowCatchUpProcessbatch(queryshipment);
        Database.executeBatch(shipmentBatch);
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber,Inventory_SKUs__c from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-100000\' order by assetArenaProductCode__c';
        
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        
        Test.stopTest();
        
        
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentAsset__c,componentTransaction__c,componentLocation__c,componentAssetStatus__c,componentServicePartNumber__c,componentAssetName__c,componentComponentSN__c,componentType__c,componentItem__c,ComponentCreatedFromInformation__c from Component__c];
        System.assertEquals(23,components.size());
        
        //Lower Part Should Exist (Skipping Higher Part)
        List<Component__c> Lowercomponents = [Select Id from Component__c where componentServicePartNumber__c='SR-HDD-1TB' or componentServicePartNumber__c='SR-SSD-80GB'];
        System.assertEquals(16,Lowercomponents.size());
        
        //Check the Status of the Asset
        assets = [Select Id,Name,assetComponentCreatedStatus__c,assetComponentProcessedMessage__c,Inventory_SKUs__c from Asset where Name='AA-100000'];
        System.assertEquals(1,assets.size());
        System.assertEquals('AA-100000',assets[0].Name);
        System.assertEquals('Success',assets[0].assetComponentCreatedStatus__c);
        System.assertEquals(null,assets[0].assetComponentProcessedMessage__c);
        
        
    }
    // ###################################################################################################### assetTypeLegacy_OneReturned_AnotherShipped_MatchingSN
    static testMethod void assetTypeLegacy_OneReturned_AnotherShipped_MatchingSN() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
        testData.InsertProduct_01();
        testData.CreateTestAccount_01();
        testData.CreateTestContact_01();
        testData.CreateTestAsset_01();
        Test.startTest();
        testData.createComponentForShippedAsset();
        testData.updateAssetAsReturned();
        testData.createAssetAsShipped();
        
        String baseUrl = 'https://api.arenasolutions.com/v1';
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(baseUrl + '/login', 'ArenaLoginCallouts');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=0','ArenaItemLimit0to400');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=400','ArenaItemLimit400to800');
        multimock.setStaticResource(baseUrl + '/items/WEYHUJR67H0H0FAD5A3Q/bom','ArenaPBOMs');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        string queryshipment = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = \'AA-111111\' AND shipmentFlexflowFlexProcessed__c = null' ;
        AssetFlexFlowCatchUpProcessbatch  shipmentBatch = new AssetFlexFlowCatchUpProcessbatch(queryshipment);
        Database.executeBatch(shipmentBatch);
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber,Inventory_SKUs__c from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-111111\' order by assetArenaProductCode__c';
        
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        
        Test.stopTest();
        
        
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentAsset__c,componentTransaction__c,componentLocation__c,componentAssetStatus__c,componentServicePartNumber__c,componentAssetName__c,componentComponentSN__c,componentType__c,componentItem__c,ComponentCreatedFromInformation__c from Component__c];
        System.assertEquals(4,components.size());
        System.assertEquals(testData.testAsset2.Id,components[0].componentAsset__c);
        System.assertEquals(testData.testAsset2.Id,components[1].componentAsset__c);
        
        
        //Check the Status of the Asset
        assets = [Select Id,Name,assetComponentCreatedStatus__c,assetComponentProcessedMessage__c,Inventory_SKUs__c from Asset where Name='AA-111111' and Status='Shipped'];
        System.assertEquals(1,assets.size());
        System.assertEquals('AA-111111',assets[0].Name);
        System.assertEquals('Success',assets[0].assetComponentCreatedStatus__c);
        System.assertEquals(null,assets[0].assetComponentProcessedMessage__c);
        
        
    }
	// ###################################################################################################### assetTypeOther_WithoutShipmentFlexFlow
    static testMethod void assetTypeOther_WithoutShipmentFlexFlow() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
        testData.InsertProduct_02();
        testData.CreateTestAccount_01();
        testData.CreateTestContact_01();
        testData.CreateTestAsset_03();
        
        String baseUrl = 'https://api.arenasolutions.com/v1';
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(baseUrl + '/login', 'ArenaLoginCallouts');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=0','ArenaItemLimit0to400');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=400','ArenaItemLimit400to800');
        multimock.setStaticResource(baseUrl + '/items/6O8R4T1GHRARAPH0SM9Z/bom','ArenaPBOMs');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        string queryshipment = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = \'AA-333333\' AND shipmentFlexflowFlexProcessed__c = null' ;
        AssetFlexFlowCatchUpProcessbatch  shipmentBatch = new AssetFlexFlowCatchUpProcessbatch(queryshipment);
        Database.executeBatch(shipmentBatch);
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber,Inventory_SKUs__c from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-333333\' order by assetArenaProductCode__c';
        
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        
        Test.stopTest();
        
        
        List<Component__c> components = [Select Id from Component__c];
        //System.assertEquals(23,components.size());
        
        //Deprecated part should be skipped for other
        List<Component__c> Depcomponents = [Select Id from Component__c where componentServicePartNumber__c='SR-HDD-1TB'];
        System.assertEquals(0,Depcomponents.size());
        
        
        //Check the Status of the Asset
        assets = [Select Id,Name,assetComponentCreatedStatus__c,assetComponentProcessedMessage__c,Inventory_SKUs__c from Asset where Name='AA-333333'];
        System.assertEquals(1,assets.size());
        System.assertEquals('AA-333333',assets[0].Name);
        //System.assertEquals('Success',assets[0].assetComponentCreatedStatus__c);
        System.assertEquals(null,assets[0].assetComponentProcessedMessage__c);
        
        
        
    }
    // ###################################################################################################### assetTypeComponentSKU_ArenaItem_Error_WithoutShipmentFlexFlow
    static testMethod void assetTypeComponentSKU_ArenaItem_Error_WithoutShipmentFlexFlow() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
        testData.InsertProduct_03();
        testData.CreateTestAccount_01();
        testData.CreateTestContact_01();
        testData.CreateTestAsset_04();
        
        String baseUrl = 'https://api.arenasolutions.com/v1';
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(baseUrl + '/login', 'ArenaLoginCallouts');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=0','ArenaItemLimit0to400');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=400','ArenaItemLimit400to800');
        multimock.setStaticResource(baseUrl + '/items/6O8R4T1GHRARAPH0SM9Z/bom','ArenaPBOMs');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true; 
        string queryshipment = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = \'AA-444444\' AND shipmentFlexflowFlexProcessed__c = null' ;
        AssetFlexFlowCatchUpProcessbatch  shipmentBatch = new AssetFlexFlowCatchUpProcessbatch(queryshipment);
        Database.executeBatch(shipmentBatch);
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber,Inventory_SKUs__c from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-444444\' order by assetArenaProductCode__c';
        
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        
        Test.stopTest();
        
        List<Component__c> components = [Select Id from Component__c];
        System.assertEquals(0,components.size());
        
        //Check the Status of the Asset
        assets = [Select Id,Name,assetComponentCreatedStatus__c,assetComponentProcessedMessage__c,Inventory_SKUs__c from Asset where Name='AA-444444'];
        System.assertEquals(1,assets.size());
        System.assertEquals('AA-444444',assets[0].Name);
        System.assertEquals('Error',assets[0].assetComponentCreatedStatus__c);
        System.assertEquals('BOM not found in Arena for any of the Item(s) and Shipment Flex Flow Information does not Exist',assets[0].assetComponentProcessedMessage__c);
          
    }
    // ###################################################################################################### assetTypeComponentSKU_ArenaBOMofItem_Error_WithoutShipmentFlexFlow
    static testMethod void assetTypeComponentSKU_ArenaBOMofItem_Error_WithoutShipmentFlexFlow() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
        testData.InsertProduct_03();
        testData.CreateTestAccount_01();
        testData.CreateTestContact_01();
        testData.CreateTestAsset_04();
        Shipment_Flexflow__c shipmentFlexFlow;
        insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-444444',
                                                           shipmentFlexflowChildPn__c='Controller Vendor S/N',
                                                           shipmentFlexflowChildSn__c='10000',
                                                           shipmentFlexflowItem__c='NMB-CS440-',
                                                           shipmentFlexflowReferenceA__c='SO202020',
                                                           shipmentFlexflowFlexProcessed__c = null);
        
        String baseUrl = 'https://api.arenasolutions.com/v1';
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(baseUrl + '/login', 'ArenaLoginCallouts');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=0','ArenaItemLimit0to400');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=400','ArenaItemLimit400to800');
        multimock.setStaticResource(baseUrl + '/items/6O8R4T1GHRARAPH0SM9Z/bom','ArenaPBOMs');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        string queryshipment = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = \'AA-444444\' AND shipmentFlexflowFlexProcessed__c = null' ;
        AssetFlexFlowCatchUpProcessbatch  shipmentBatch = new AssetFlexFlowCatchUpProcessbatch(queryshipment);
        Database.executeBatch(shipmentBatch);
        System.debug('### SOQL Queries===>'+Limits.getLimitQueries());
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber,Inventory_SKUs__c from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-444444\' order by assetArenaProductCode__c';
        
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        
        Test.stopTest();
        List<Component__c> components = [Select Id from Component__c];
        System.assertEquals(0,components.size());
        
        //Check the Status of the Asset
        assets = [Select Id,Name,assetComponentCreatedStatus__c,assetComponentProcessedMessage__c,Inventory_SKUs__c from Asset where Name='AA-444444'];
        System.assertEquals(1,assets.size());
        System.assertEquals('AA-444444',assets[0].Name);
        //System.assertEquals('Error',assets[0].assetComponentCreatedStatus__c);
        //System.assertEquals('BOM not found in Arena for any of the Item(s) and Shipment Flex Flow Information does not Exist',assets[0].assetComponentProcessedMessage__c);
        
    }
    // ###################################################################################################### assetTypeLegacy_HigherAssetSN_WithShipmentFlexFlow
    static testMethod void assetTypeLegacy_HigherAssetSN_WithShipmentFlexFlow() {
        TestData    testData;
        List<Asset> assets;
        List<Component__c> components;
        List<Shipment_Flexflow__c> shipmentFlexFlow;
        
        testData = new TestData();
        testData.InsertProduct_01();
        testData.CreateTestAccount_01();
        testData.CreateTestContact_01();
        testData.CreateTestAsset_01();
        testData.insertShipmentFlexRows();
        
        
        
        String baseUrl = 'https://api.arenasolutions.com/v1';
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(baseUrl + '/login', 'ArenaLoginCallouts');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=0','ArenaItemLimit0to400');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=400','ArenaItemLimit400to800');
        multimock.setStaticResource(baseUrl + '/items/WEYHUJR67H0H0FAD5A3Q/bom','ArenaPBOMs');
        multimock.setStaticResource(baseUrl + '/items/CUEXAZ7MNXGXGVQ2PXN9/whereused','ArenaWhereUsed');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber,Inventory_SKUs__c from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-111111\' order by assetArenaProductCode__c';        
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
        components = [Select Id from Component__c];
        System.assertEquals(27,components.size());
        
        //Shipment Flex has 2 Record with Same Child Serial, only one should be added to Component
        components = [Select Id from Component__c where componentComponentSN__c='10000'];
        System.assertEquals(1,components.size());
        
        //Additonal Flex Flow Item
        components = [Select componentServicePartNumber__c,componentComponentSN__c,componentLocation__c,componentTransaction__c,componentItem__c,componentProcessedByFLEX__c,ComponentCreatedFromInformation__c from Component__c where componentComponentSN__c='10006'];
        System.assertEquals(1,components.size());
        System.assertEquals('SR-PCI-1GT',components[0].componentServicePartNumber__c);
        System.assertEquals('10006',components[0].componentComponentSN__c);
        System.assertEquals(null,components[0].componentLocation__c);
        System.assertEquals('SO202020',components[0].componentTransaction__c);
        System.assertEquals('NMB-',components[0].componentItem__c);
        System.assertEquals(true,components[0].componentProcessedByFLEX__c);
        System.assertEquals('Added from Flex Flow Data',components[0].ComponentCreatedFromInformation__c);
        
        //Find the existing component and update the SN from Shipment Flex Flow
        components = [Select componentServicePartNumber__c,componentComponentSN__c,componentLocation__c,componentTransaction__c,componentItem__c,componentProcessedByFLEX__c,ComponentCreatedFromInformation__c from Component__c where  componentServicePartNumber__c='SR-CONT-CS220' and componentComponentSN__c='10000'];
        System.assertEquals(1,components.size());
        System.assertEquals('SR-CONT-CS220',components[0].componentServicePartNumber__c);
        System.assertEquals('10000',components[0].componentComponentSN__c);
        System.assertEquals(null,components[0].componentLocation__c);
        System.assertEquals('SO202020',components[0].componentTransaction__c);
        System.assertEquals(true,components[0].componentProcessedByFLEX__c);
        System.assertEquals('Added from BOM Items',components[0].ComponentCreatedFromInformation__c);
        
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-PWR-1200W' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true  and componentLocation__c='left side' and componentComponentSN__c='10001'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-PWR-1200W' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true  and componentLocation__c='right side' and componentComponentSN__c='10002'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-PWR-1200W' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true  and componentLocation__c='unknown' and componentComponentSN__c='10003'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-CON' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true and componentItem__c='NMB-' and componentComponentSN__c='10004'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-HD' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true and componentItem__c='NMBR-' and componentComponentSN__c='10005'];
        System.assertEquals(1,components.size());
        
        
        //Total Error in Shipment Flex Flow
        shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c,shipmentFlexflowChildSn__c, shipmentFlexflowUnitSerialNumber__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Error'];
        System.assertEquals(4,shipmentFlexFlow.size());
        System.assertEquals('Error',shipmentFlexFlow[0].shipmentFlexflowFlexProcessed__c);
        //System.assertEquals('10007',shipmentFlexFlow[0].shipmentFlexflowChildSn__c);
        
        //Total Success in Shipment Flex Flow
        shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c,shipmentFlexflowChildSn__c, shipmentFlexflowUnitSerialNumber__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Success'];
        System.assertEquals(11,shipmentFlexFlow.size());
        
        shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c,shipmentFlexflowChildSn__c, shipmentFlexflowUnitSerialNumber__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c= null];
        
        //Check the Status of the Asset
        assets = [Select Id,Name,assetComponentCreatedStatus__c,assetComponentProcessedMessage__c,Inventory_SKUs__c from Asset where Name='AA-111111'];
        System.assertEquals(1,assets.size());
        System.assertEquals('AA-111111',assets[0].Name);
        System.assertEquals('Success',assets[0].assetComponentCreatedStatus__c);
        System.assertEquals(null,assets[0].assetComponentProcessedMessage__c);
        List<Shipment_Flexflow__c> shipmentFlexFlowobj = [select shipmentFlexflowUnitSerialNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = 'AA-111111'];
        for(Shipment_Flexflow__c shipObj : shipmentFlexFlowobj){
            shipObj.shipmentFlexflowFlexProcessed__c = null;
        }
        update shipmentFlexFlowobj;       
        for(Component__c comp : components){
            comp.componentComponentSN__c = null;
            comp.ComponentCreatedFromInformation__c = 'Added from BOM items';
            //comp.componentComponentSN__c = null;
            comp.componentItem__c = null;
            comp.componentType__c = null;
            comp.componentDescription__c = null;
            comp.componentTransaction__c = null;
            //comp.componentServicePartNumber__c = null;
        }
        update components;
        string queryshipment = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = \'AA-111111\' AND shipmentFlexflowFlexProcessed__c = null' ;
        AssetFlexFlowCatchUpProcessbatch  shipmentBatch = new AssetFlexFlowCatchUpProcessbatch(queryshipment);
        Database.executeBatch(shipmentBatch);
        
        
        
    }
    // ###################################################################################################### assetTypeLegacy_HigherAssetSN_WithShipmentFlexFlowMethod2
    static testMethod void assetTypeLegacy_HigherAssetSN_WithShipmentFlexFlowMethod2() {
        TestData    testData;
        List<Asset> assets;
        List<Component__c> components;
        List<Shipment_Flexflow__c> shipmentFlexFlow;
        
        testData = new TestData();
        testData.InsertProduct_01();
        testData.CreateTestAccount_01();
        testData.CreateTestContact_01();
        testData.CreateTestAsset_01();
        testData.insertShipmentFlexRows();
        
        
        
        String baseUrl = 'https://api.arenasolutions.com/v1';
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(baseUrl + '/login', 'ArenaLoginCallouts');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=0','ArenaItemLimit0to400');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=400','ArenaItemLimit400to800');
        multimock.setStaticResource(baseUrl + '/items/WEYHUJR67H0H0FAD5A3Q/bom','ArenaPBOMs');
        multimock.setStaticResource(baseUrl + '/items/CUEXAZ7MNXGXGVQ2PXN9/whereused','ArenaWhereUsed');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber,Inventory_SKUs__c from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-111111\' order by assetArenaProductCode__c';        
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
        components = [Select Id from Component__c];
        System.assertEquals(27,components.size());
        
        //Shipment Flex has 2 Record with Same Child Serial, only one should be added to Component
        components = [Select Id from Component__c where componentComponentSN__c='10000'];
        System.assertEquals(1,components.size());
        
        //Additonal Flex Flow Item
        components = [Select componentServicePartNumber__c,componentComponentSN__c,componentLocation__c,componentTransaction__c,componentItem__c,componentProcessedByFLEX__c,ComponentCreatedFromInformation__c from Component__c where componentComponentSN__c='10006'];
        System.assertEquals(1,components.size());
        System.assertEquals('SR-PCI-1GT',components[0].componentServicePartNumber__c);
        System.assertEquals('10006',components[0].componentComponentSN__c);
        System.assertEquals(null,components[0].componentLocation__c);
        System.assertEquals('SO202020',components[0].componentTransaction__c);
        System.assertEquals('NMB-',components[0].componentItem__c);
        System.assertEquals(true,components[0].componentProcessedByFLEX__c);
        System.assertEquals('Added from Flex Flow Data',components[0].ComponentCreatedFromInformation__c);
        
        //Find the existing component and update the SN from Shipment Flex Flow
        components = [Select componentServicePartNumber__c,componentComponentSN__c,componentLocation__c,componentTransaction__c,componentItem__c,componentProcessedByFLEX__c,ComponentCreatedFromInformation__c from Component__c where  componentServicePartNumber__c='SR-CONT-CS220' and componentComponentSN__c='10000'];
        System.assertEquals(1,components.size());
        System.assertEquals('SR-CONT-CS220',components[0].componentServicePartNumber__c);
        System.assertEquals('10000',components[0].componentComponentSN__c);
        System.assertEquals(null,components[0].componentLocation__c);
        System.assertEquals('SO202020',components[0].componentTransaction__c);
        System.assertEquals(true,components[0].componentProcessedByFLEX__c);
        System.assertEquals('Added from BOM Items',components[0].ComponentCreatedFromInformation__c);
        
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-PWR-1200W' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true  and componentLocation__c='left side' and componentComponentSN__c='10001'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-PWR-1200W' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true  and componentLocation__c='right side' and componentComponentSN__c='10002'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-PWR-1200W' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true  and componentLocation__c='unknown' and componentComponentSN__c='10003'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-CON' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true and componentItem__c='NMB-' and componentComponentSN__c='10004'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-HD' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true and componentItem__c='NMBR-' and componentComponentSN__c='10005'];
        System.assertEquals(1,components.size());
        
        
        //Total Error in Shipment Flex Flow
        shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c,shipmentFlexflowChildSn__c, shipmentFlexflowUnitSerialNumber__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Error'];
        System.assertEquals(4,shipmentFlexFlow.size());
        System.assertEquals('Error',shipmentFlexFlow[0].shipmentFlexflowFlexProcessed__c);
        //System.assertEquals('10007',shipmentFlexFlow[0].shipmentFlexflowChildSn__c);
        
        //Total Success in Shipment Flex Flow
        shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c,shipmentFlexflowChildSn__c, shipmentFlexflowUnitSerialNumber__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Success'];
        System.assertEquals(11,shipmentFlexFlow.size());
        
        shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c,shipmentFlexflowChildSn__c, shipmentFlexflowUnitSerialNumber__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c= null];
        
        //Check the Status of the Asset
        assets = [Select Id,Name,assetComponentCreatedStatus__c,assetComponentProcessedMessage__c, Autosupport_Last_Received__c,Inventory_SKUs__c from Asset where Name='AA-111111'];
        System.assertEquals(1,assets.size());
        System.assertEquals('AA-111111',assets[0].Name);
        System.assertEquals('Success',assets[0].assetComponentCreatedStatus__c);
        System.assertEquals(null,assets[0].assetComponentProcessedMessage__c);
        
        for(Asset assetObj : assets){
            assetObj.Autosupport_Last_Received__c = null;
        }   
        update assets;
        
        List<Shipment_Flexflow__c> shipmentFlexFlowobj = [select shipmentFlexflowUnitSerialNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = 'AA-111111'];
        for(Shipment_Flexflow__c shipObj : shipmentFlexFlowobj){
            shipObj.shipmentFlexflowFlexProcessed__c = null;
        }
        update shipmentFlexFlowobj;       
        for(Component__c comp : components){
            comp.componentComponentSN__c = null;
            comp.ComponentCreatedFromInformation__c = 'Added from BOM items';
            //comp.componentComponentSN__c = null;
            comp.componentItem__c = null;
            comp.componentType__c = null;
            comp.componentDescription__c = null;
            comp.componentTransaction__c = null;
            //comp.componentServicePartNumber__c = null;
        }
        update components;
        string queryshipment = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = \'AA-111111\' AND shipmentFlexflowFlexProcessed__c = null' ;
        AssetFlexFlowCatchUpProcessbatch  shipmentBatch = new AssetFlexFlowCatchUpProcessbatch(queryshipment);
        Database.executeBatch(shipmentBatch);
        
    }
    // ###################################################################################################### test_Scheduler
    static testMethod void test_Scheduler_AssetComponentPopulationScheduler() {
        Test.StartTest();
        AssetComponentPopulationScheduler sh1 = new AssetComponentPopulationScheduler();            
        String sch = '0 0 23 * * ?';
        system.schedule('test_AssetComponentPopulationScheduler', sch, sh1);
       
        Test.stopTest();
    }
    // ###################################################################################################### srMetaDataCreationFromArena
    static testMethod void srMetaDataCreationFromArena() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
        SR_Meta_Data__c srMetaData;
        
        insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-CABLE-Seeding',
                                                srType__c = '-CABLE-',srmetadataIsValid__c = true,
                                                srDescription__c='',Is_In_Prod__c = true,
                                                srShippingProvider__c='');
        
        String baseUrl = 'https://api.arenasolutions.com/v1';
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(baseUrl + '/login', 'ArenaLoginCallouts');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=0','ArenaItemLimit0to400');
        multimock.setStaticResource(baseUrl + '/items?limit=400&offset=400','ArenaItemLimit400to800');
        
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        srMetaDataPopulationBatch e = new srMetaDataPopulationBatch();
        Database.executeBatch(e);
        Test.stopTest();
        
        
        List<SR_Meta_Data__c> srMetaDatas = [Select Id from SR_Meta_Data__c];
        //System.assertEquals(10,srMetaDatas.size());
         
    }
    // ###################################################################################################### srMetaDataPopulationScheduler
    static testMethod void test_Scheduler_srMetaDataPopulationScheduler() {
        Test.StartTest();
        srMetaDataPopulationScheduler sh1 = new srMetaDataPopulationScheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('test_srMetaDataPopulationScheduler', sch, sh1);
        Test.stopTest();
    }
}