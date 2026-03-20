@isTest
private class AssetComponentPopulationBatchTest {
    
    class TestData {
        Account testAccount;
        Account testAccount1;
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
        
        
        TestData() {
            
            
            //Custom Settings
            ArenaPLM__c arenaPLMLogin = new ArenaPLM__c();
            arenaPLMLogin.Name='Arena PLM Login';
            arenaPLMLogin.UserName__c='testUser';
            arenaPLMLogin.Password__c='testPassword';
            insert arenaPLMLogin;
            
            
            //Create PROD 1
            insert testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                               ProductCode='CS220',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='SAN Storage Array',
                                               Controller_Code__c='CS200',
                                               Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                               Family='SAN Storage Array');
            
            //Create PROD 2
            insert testProduct2 = new Product2(Name = 'ES1-H90T',
                                               ProductCode='ES1-H90T',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='Expansion Shelves',
                                               Product_Sub_Type__c='ES1',
                                               Description='90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable',
                                               Family='Expansion Shelves');
            
            //Create PROD 3
            insert testProduct3 = new Product2(Name = '6050',
                                               ProductCode='6050',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='Controller',
                                               Controller_Code__c='',
                                               Component_Code__c = 'AF500',
                                               Description='CS300 Storage Array',
                                               Family='All Flash Array Gen6');
            
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            insert testAccount1 = new Account(Name = 'Test Corporation');
            
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
                                          Asset_Type_Build__c						= 'Next Gen',
                                          Component_SKU_HPE__c = 'R4U28A',
                                          Component_SKU_Nimble_V2__c = '6010',
                                          Ship_Date__c                              = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     = Date.today(),
                                          assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                                          Status                                    = 'Shipped',
                                          Autosupport_Last_Received__c              = Date.today().addDays(-50),
                                          Product2Id								= testProduct1.Id,
                                          Array_Controller__c 						= 'CS300',
                                          Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                                          Array_Networking_3__c 					= '2P',
                                          Array_Cache__c 							= '640F',
                                          SSD_Bank_A__c 							= '480F',
                                          SSD_Bank_B__c 							= '480F',
                                          Expansion_Shelf_Base__c 					= 'AFS2',
                                          Array_Capacity__c 						= '11T');
            
            // Create test Asset 3
            insert testAsset3 = new Asset(Name                                      = 'AA-3333332',
                                          AccountId                                 = testAccount1.Id,
                                          ContactId                                 = testContact.Id,
                                          SLA__c                                    = 'Premium',
                                          Install_Street1__c                        = '123 Main Street',
                                          Install_Street2__c                        = 'Suite 100',
                                          Install_City__c                           = 'San Jose',
                                          Install_State_Province__c                 = 'CA',
                                          Install_Zip_Code__c                       = '951510',
                                          Install_Country__c                        = 'United States',
                                          Ship_Date__c                              = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     = Date.today(),
                                          Asset_Type_Build__c						= 'AFA3',
                                          Component_SKU_HPE__c 						= 'R4U28A',
                                          Component_SKU_Nimble_V2__c				= '6010',
                                          assetPartShipLastValidatedByInfo__c       = 'Test part',
                                          Status                                    = 'Shipped',
                                          contains_HPESKU__c 						= true,
                                          Product2Id								= testProduct3.Id,
                                          Array_Controller__c 						= 'CS300',
                                          Array_Networking__c 						= '2P',
                                          Array_Networking_2__c 					= '2P',
                                          Array_Networking_3__c 					= '2P',
                                          Array_Cache__c 							= '640F',
                                          SSD_Bank_A__c 							= '480F',
                                          SSD_Bank_B__c								= '480F',
                                          Expansion_Shelf_Base__c 					= 'AFS2',
                                          Array_Capacity__c 						= '11T');
            system.debug('insert'+testAsset3.Component_SKU_HPE__c);
            //testAsset3.Component_SKU_HPE__c = 'R4U28A';
            //update testAsset3;
            system.debug('update'+testAsset3.Component_SKU_HPE__c);
            
            insert testSrMetaData = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1200W',
                                                        srType__c = 'PWR(power supply)',
                                                        srDescription__c='Service Power Supply Unit for CS Arrays, 1200W',
                                                        srmetadataIsValid__c = True,
                                                        srShippingProvider__c='Flash');
            
        }
        
        void changeToLowerAsset() {
            testAsset1.Name = 'AA-100000';
            update testAsset1;
        }
        
        void updateAssetAsReturned()
        {
            testAsset3.Status = 'Returned';
            update testAsset3;
        }
        
        void createComponentForShippedAsset()
        {
            
            insert testComponent1 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC');
            
            insert testComponent2 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC');
            
            insert testComponent3 = new component__c(componentAccountId__c = testAccount1.Id,
                                                     componentAsset__c = testAsset3.Id,
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='HDD',
                                                     componentDescription__c='Service HDD, 600GB, with carrier'
                                                    );
            insert testComponent3 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,                                                    
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='Controller',
                                                     componentDescription__c='Service HDD, 600GB, with carrier');
        }
        
        void createAssetAsShipped()
        {
            // Create test Asset 2
            /*insert testAsset2 = new Asset(Name                                 = 'AA-111111',
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
Product2Id=testProduct1.Id);*/
        }
        
        
        void insertShipmentFlexRows()
        {
            //Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where shipmentFlexflowUnitSerialNumber__c=\'AF-109474\'';
            Shipment_Flexflow__c shipmentFlexFlow;
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10000',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10000',
                                                               shipmentFlexflowItem__c='NMB-SR-',
                                                               shipmentFlexflowReferenceA__c='SO202020',                                                              
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10000',
                                                               shipmentFlexflowItem__c='NMB-SR-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10001',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10002',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowChildLotNumber__c = 'PWS-1K21P-1R',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowChildLotNumber__c = 'PWS-1K23A-1R',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowChildLotNumber__c = '123456Test',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowChildLotNumber__c = '123456Test',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowChildLotNumber__c = '123456Test',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMB-SR-',
                                                               shipmentFlexflowChildLotNumber__c = '123456Test',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10004',
                                                               shipmentFlexflowItem__c='NMB-SR-CON',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10005',
                                                               shipmentFlexflowItem__c='NMB-SR-HD',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            //CUEXAZ7MNXGXGVQ2PXN9
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10006',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='NMB-',
                                                               shipmentFlexflowChildSn__c='10007',
                                                               shipmentFlexflowItem__c='NMBR-SR-',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Success');
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
        
        //Validate test Product 1
        testProduct2 = [SELECT Name,
                        ProductCode,
                        Product_Type__c,
                        Product_Type_2__c,
                        Controller_Code__c,
                        Description,
                        Family FROM Product2 where Name='CS220 Storage Array'];
        
        //Validate test Product 2
        testProduct2 = [SELECT Name,
                        ProductCode,
                        Product_Type__c,
                        Product_Type_2__c,
                        Product_Sub_Type__c,
                        Description,
                        Family FROM Product2 where Name='ES1-H90T'];
        //Validate test Product 3
        testProduct2 = [SELECT Name,
                        ProductCode,
                        Product_Type__c,
                        Product_Type_2__c,
                        Controller_Code__c,
                        Component_Code__c,
                        Description,
                        Family FROM Product2 where Name='CS300 Storage Array'];
        // Validate test Account
        accounts = [SELECT Id,
                    Name
                    FROM   Account];
        
        // Validate test Contact
        contacts = [SELECT Id,
                    LastName,
                    FirstName,
                    AccountId
                    FROM   Contact];
        
        
        srMetaDatas = [Select srPart__c,
                       srType__c,
                       srDescription__c,
                       srShippingProvider__c from SR_Meta_Data__c];
        
        
    }
    
    // ###################################################################################################### assetTypeLegacy_HigherAssetSN_WithoutShipmentFlexFlow
    static testMethod void assetTypeLegacy_HigherAssetSN_WithoutShipmentFlexFlow() {
        TestData    testData;
        List<Asset> assets;
        testData = new TestData();
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
        
        
        //CountAssetPreventRecursive.runOnce();
        //assetPreventRecursive.runOnce();
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,Inventory_SKUs__c,Component_SKU_HPE__c,System_Capacity_GB__c,SerialNumber from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null order by assetArenaProductCode__c';
        //String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Inventory_SKUs__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset where Asset_Type__c =\'AFA3\' limit 1';
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;
        //assetPreventRecursive AB = new assetPreventRecursive();
        
        system.debug('CountAssetPreventRecursive.run'+CountAssetPreventRecursive.run);
        system.debug('assetPreventRecursive.run'+assetPreventRecursive.run);
        
        
        
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        // CountAssetPreventRecursive.run = true; 
        // assetPreventRecursive AB = new assetPreventRecursive(); 
        
        Database.executeBatch(e);
        string queryshipment = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c = \'AA-111111\' AND shipmentFlexflowFlexProcessed__c = null';
        AssetFlexFlowCatchUpProcessbatch  shipmentBatch = new AssetFlexFlowCatchUpProcessbatch(queryshipment);
        Database.executeBatch(shipmentBatch);
        Test.stopTest();
        
        
        List<Component__c> components = [Select Id from Component__c];
        
        List<Component__c> Highercomponents = [Select Id from Component__c where componentServicePartNumber__c='SR-HDD-1TB-SAS' or componentServicePartNumber__c='SR-SSD-3500-80GB'];
        
    }
    
    static testMethod void testschedule() {
        Test.StartTest();
        AssetComponentPopulationScheduler sh1 = new AssetComponentPopulationScheduler();            
        String sch = '0 0 23 * * ?';
        system.schedule('test_AssetComponentPopulationScheduler', sch, sh1);
        Test.stopTest();
    }
    static testMethod void Assettest1(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Product2 testProduct1 = new Product2(Name 				= 'CS220 Storage Array',
                                             ProductCode		='CS220',
                                             Product_Type__c	='Hardware',
                                             Product_Type_2__c	='SAN Storage Array',
                                             Controller_Code__c	='CS200',
                                             Description		='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family				='SAN Storage Array');
        insert testProduct1;
        
        Asset asst = new Asset(Name 						= 'AA-111112', 
                               AccountId					= acc.Id, 
                               Product2Id 					= testProduct1.id,
                               HPE_Serial_Number__c 		= 'HPE123457',
                               Array_Controller__c 			= 'CS300',
                               Array_Networking__c 			= '2P',
                               Array_Networking_2__c 		= '2P',
                               Array_Networking_3__c 		= '2P',
                               Array_Cache__c 				= '640F',
                               SSD_Bank_A__c 				= '480F',
                               SSD_Bank_B__c 				= '480F',
                               Asset_Type_Build__c 			='AFA3',
                               Status 						= 'Shipped',
                               Component_SKU_HPE__c 		= 'R4U28A',
                               Component_SKU_Nimble_V2__c 	= '6010',
                               Expansion_Shelf_Base__c 		= 'AFS2',
                               Array_Capacity__c 			= '11T');
        insert asst;
        
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD');
        insert c1;
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Inventory_SKUs__c,Component_SKU_HPE__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-111112\' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
    }
    static testMethod void Assettest2(){
        test.startTest();
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Product2 testProduct2 = new Product2(Name 					= 'ES1-H90T',
                                             ProductCode			='ES1-H90T',
                                             Product_Type__c		='Hardware',
                                             Product_Type_2__c		='Expansion Shelves',
                                             Product_Sub_Type__c	='ES1',
                                             Description			='90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable',
                                             Family					='Expansion Shelves');
        insert testProduct2;
        
        Asset asst1 = new Asset(Name 								= 'AA-111112', 
                                AccountId 							= acc.Id, 
                                Product2Id 							= testProduct2.id,
                                HPE_Serial_Number__c				= 'HPE123457',
                                Array_Controller__c 				= 'CS300',
                                Array_Networking__c 				= '2P',
                                Array_Networking_2__c 				= '2P',
                                Array_Networking_3__c 				= '2P',
                                Array_Cache__c	 					= '640F',
                                SSD_Bank_A__c 						= '480F',
                                SSD_Bank_B__c 						= '480F',
                                Asset_Type_Build__c 				='AFA3',
                                Status 								= 'Shipped',
                                Component_SKU_HPE__c 				= 'R4U28A',
                                Component_SKU_Nimble_V2__c 			= '6010',
                                Expansion_Shelf_Base__c 			= 'AFS2',
                                Array_Capacity__c 					= '11T');
        
        insert asst1;
        
        Asset asst2 = new Asset(Name                                     = 'AA-444444',
                                AccountId                                = acc.Id,
                                // ContactId                             = con.Id,
                                SLA__c                                   = 'Premium',
                                Install_Street1__c                       = '123 Main Street',
                                Install_Street2__c                       = 'Suite 100',
                                Install_City__c                          = 'San Jose',
                                Install_State_Province__c                = 'CA',
                                Install_Zip_Code__c                      = '95151',
                                Install_Country__c                       = 'United States',
                                Ship_Date__c                             = Date.today().addDays(-180),
                                assetPartShipLastValidatedDatetime__c    = Date.today(),
                                assetPartShipLastValidatedByInfo__c      = 'Test part ship last validated by info',
                                Status                                   = 'Shipped',
                                Product2Id								 = testProduct2.Id,
                                Array_Controller__c						 ='CS300',
                                Array_Networking__c						 ='4G',
                                Array_Capacity__c						 ='36T',
                                Array_Cache__c							 ='3200F',
                                Array_Controller_SKU__c					 =null,
                                Array_Networking_SKU__c					 ='PCI-1GTx2',
                                Array_Capacity_SKU__c					 ='HEAD-HDD-36TB',
                                Array_Cache_SKU__c						 ='HEAD-FLC-3200GB',
                                Expansion_Shelf_Base__c 				 = 'AFS2'	
                               );
        insert asst2;
        
        Shipment_Flexflow__c ship1 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                              shipmentFlexflowChildPn__c='NMB-',
                                                              shipmentFlexflowChildSn__c='10000',
                                                              shipmentFlexflowItem__c='NMB-SR-',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Success');
        insert ship1;
        Shipment_Flexflow__c ship2 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111113',
                                                              shipmentFlexflowChildPn__c='NMB-',
                                                              shipmentFlexflowChildSn__c='10000',
                                                              shipmentFlexflowItem__c='NMB-SR-',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Success');
        insert ship2;
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Inventory_SKUs__c,Component_SKU_HPE__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-111112\' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        test.stopTest();
        
    }
    
    static testMethod void Assettest3(){
        test.startTest();
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Product2 testProduct2 = new Product2(Name 				= 'ES1-H90T',
                                             ProductCode		='ES1-H90T',
                                             Product_Type__c	='Hardware',
                                             Product_Type_2__c	='Expansion Shelves',
                                             Product_Sub_Type__c='ES1',
                                             Description		='90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable',
                                             Family				='Expansion Shelves');
        insert testProduct2;
        
        Asset asst1 = new Asset(Name 							= 'AA-111112', 
                                AccountId 						= acc.Id, 
                                Product2Id 						= testProduct2.id,
                                HPE_Serial_Number__c 			= 'HPE123457',
                                Array_Controller__c 			= 'CS300',
                                Array_Networking__c 			= '2P',
                                Array_Networking_2__c 			= '2P',
                                Array_Networking_3__c 			= '2P',
                                Array_Cache__c 					= '640F',
                                SSD_Bank_A__c 					= '480F',
                                SSD_Bank_B__c 					= '480F',
                                Asset_Type_Build__c 			='AFA3',
                                Status 							= 'Shipped',
                                Component_SKU_HPE__c 			= 'R4U28A',
                                Component_SKU_Nimble_V2__c 		= '6010',
                                Expansion_Shelf_Base__c 		= 'AFS2',
                                Array_Capacity__c 				= '11T');
        
        insert asst1;
        
        Shipment_Flexflow__c ship1 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                              shipmentFlexflowChildPn__c='NMB-',
                                                              shipmentFlexflowChildSn__c='10000',
                                                              shipmentFlexflowItem__c='NMB-SR-',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Success');
        insert ship1;
        Shipment_Flexflow__c ship2 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='NMB-',
                                                              shipmentFlexflowChildSn__c='10000',
                                                              shipmentFlexflowItem__c='NMB-SR-',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Success');
        insert ship2;
        Shipment_Flexflow__c ship3 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                              shipmentFlexflowChildPn__c='NMB-',
                                                              shipmentFlexflowChildSn__c='10003',
                                                              shipmentFlexflowItem__c='NMBR-SR-',
                                                              shipmentFlexflowChildLotNumber__c = 'PWS-1K23A-1R',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Success');
        insert ship3;
        
        Shipment_Flexflow__c ship4 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                              shipmentFlexflowChildPn__c='NMB-',
                                                              shipmentFlexflowChildSn__c='10006',
                                                              shipmentFlexflowItem__c='NMBR-SR-',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Success');
        insert ship4;
        
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Inventory_SKUs__c,Component_SKU_HPE__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-111112\' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        test.stopTest();
        
    }
    
    static testMethod void Assettest4(){
        test.startTest();
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Product2 testProduct2 = new Product2(Name 				= 'ES1-H90T',
                                             ProductCode		='ES1-H90T',
                                             Product_Type__c	='Hardware',
                                             Product_Type_2__c	='Expansion Shelves',
                                             Product_Sub_Type__c='ES1',
                                             Description		='90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable',
                                             Family				='Expansion Shelves');
        insert testProduct2;
        
        Asset asst1 = new Asset(Name 							= 'AA-111112', 
                                AccountId 						= acc.Id, 
                                Product2Id 						= testProduct2.id,
                                HPE_Serial_Number__c 			= 'HPE123457',
                                Array_Controller__c 			= 'CS300',
                                Array_Networking__c 			= '2P',
                                Array_Networking_2__c 			= '2P',
                                Array_Networking_3__c 			= '2P',
                                Array_Cache__c 					= '640F',
                                SSD_Bank_A__c 					= '480F',
                                SSD_Bank_B__c 					= '480F',
                                Asset_Type_Build__c 			='AFA3',
                                Status	 						= 'Returned',
                                Component_SKU_HPE__c 			= 'R4U28A',
                                Component_SKU_Nimble_V2__c 		= '6010',
                                Expansion_Shelf_Base__c 		= 'AFS2',
                                Array_Capacity__c 				= '11T');
        
        insert asst1;
        
        Asset asst2 = new Asset(Name 							= 'AA-111112', 
                                AccountId 						= acc.Id, 
                                Product2Id 						= testProduct2.id,
                                HPE_Serial_Number__c 			= 'HPE123457',
                                Array_Controller__c 			= 'CS300',
                                Array_Networking__c 			= '2P',
                                Array_Networking_2__c 			= '2P',
                                Array_Networking_3__c 			= '2P',
                                Array_Cache__c 					= '640F',
                                SSD_Bank_A__c 					= '480F',
                                SSD_Bank_B__c				 	= '480F',
                                Asset_Type_Build__c 			='AFA2',
                                Status 							= 'Returned',
                                Component_SKU_HPE__c 			= 'R4U28A',
                                Component_SKU_Nimble_V2__c 		= '6010',
                                Expansion_Shelf_Base__c 		= 'AFS2',
                                Array_Capacity__c 				= '11T');
        
        insert asst2;
        
        Shipment_Flexflow__c ship1 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                              shipmentFlexflowChildPn__c='NMB-',
                                                              shipmentFlexflowChildSn__c='10000',
                                                              shipmentFlexflowItem__c='NMB-SR-',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Success');
        
        Component__c c1 = new Component__c(componentAsset__c= asst1.Id,componentType__c ='SSD');
        insert c1;
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Inventory_SKUs__c,Component_SKU_HPE__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset  where Status=\'Returned\' and assetComponentCreatedStatus__c=null and Name=\'AA-111112\' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        test.stopTest();
        
    }
    static testMethod void Assettest5(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Product2 testProduct2 = new Product2(Name 				= 'ES1-H90T',
                                             ProductCode		='ES1-H90T',
                                             Product_Type__c	='Hardware',
                                             Product_Type_2__c	='Expansion Shelves',
                                             Product_Sub_Type__c='ES1',
                                             Description		='90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable',
                                             Family				='Expansion Shelves');
        insert testProduct2;
        
        Asset asst1 = new Asset(Name 							= 'AA-111112', 
                                AccountId 						= acc.Id, 
                                Product2Id 						= testProduct2.id,
                                HPE_Serial_Number__c 			= 'HPE123457',
                                Array_Controller__c 			= 'CS300',
                                Array_Networking__c 			= '2P',
                                Array_Networking_2__c 			= '2P',
                                Array_Networking_3__c 			= '2P',
                                Array_Cache__c 					= '640F',
                                SSD_Bank_A__c 					= '480F',
                                SSD_Bank_B__c 					= '480F',
                                Asset_Type_Build__c 			='AFA3',
                                Status 							= 'Returned',
                                Component_SKU_HPE__c 			= 'R4U28A,CS215',
                                Component_SKU_Nimble_V2__c 		= '6010',
                                Expansion_Shelf_Base__c 		= 'AFS2',
                                Array_Capacity__c 				= '11T');
        
        insert asst1;
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Inventory_SKUs__c,Component_SKU_HPE__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset  where Status=\'Returned\' and assetComponentCreatedStatus__c=null and Name=\'AA-111112\' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        
    }
    
    static testMethod void GenerateSN(){
        String srPart;
        String srLocation;
        String srItem;
        Boolean matchingComponentFound;
        Shipment_Flexflow__c shipmentFlexFlowLine;
        
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Product2 testProduct2 = new Product2(Name 				= 'ES1-H90T',
                                             ProductCode		='ES1-H90T',
                                             Product_Type__c	='Hardware',
                                             Product_Type_2__c	='Expansion Shelves',
                                             Product_Sub_Type__c='ES1',
                                             Description		='90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable',
                                             Family				='Expansion Shelves');
        insert testProduct2;
        
        Asset asst1 = new Asset(Name 							= 'AA-111112', 
                                AccountId 						= acc.Id, 
                                Product2Id 						= testProduct2.id,
                                HPE_Serial_Number__c 			= 'HPE123457',
                                Array_Controller__c 			= 'CS300',
                                Array_Networking__c 			= '2P',
                                Array_Networking_2__c 			= '2P',
                                Array_Networking_3__c 			= '2P',
                                Array_Cache__c 					= '640F',
                                SSD_Bank_A__c 					= '480F',
                                SSD_Bank_B__c 					= '480F',
                                Asset_Type_Build__c 			= 'AFA3',
                                Status 							= 'Returned',
                                Component_SKU_HPE__c 			= 'R4U28A',
                                Component_SKU_Nimble_V2__c 		= '6010',
                                Expansion_Shelf_Base__c 		= 'AFS2',
                                Array_Capacity__c 				= '11T');
        
        insert asst1;
        
        Asset asst2 = new Asset(Name 							= 'AA-111112', 
                                AccountId 						= acc.Id, 
                                Product2Id 						= testProduct2.id,
                                HPE_Serial_Number__c 			= 'HPE123457',
                                Array_Controller__c 			= 'CS300',
                                Array_Networking__c 			= '2P',
                                Array_Networking_2__c 			= '2P',
                                Array_Networking_3__c 			= '2P',
                                Array_Cache__c 					= '640F',
                                SSD_Bank_A__c 					= '480F',
                                SSD_Bank_B__c 					= '480F',
                                Asset_Type_Build__c 			='AFA2',
                                Status 							= 'Returned',
                                Component_SKU_HPE__c 			= 'R4U28A',
                                Component_SKU_Nimble_V2__c 		= '6010',
                                Expansion_Shelf_Base__c 		= 'AFS2',
                                Array_Capacity__c 				= '11T');
        
        insert asst2;
        
        Shipment_Flexflow__c ship1 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='NMB-',
                                                              shipmentFlexflowChildSn__c='10000',
                                                              shipmentFlexflowItem__c='NMB-SR-',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Success');
        
        Component__c c1 = new Component__c(componentAsset__c= asst1.Id,componentType__c ='SSD');
        insert c1;
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Inventory_SKUs__c,Component_SKU_HPE__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset  where Status=\'Returned\' and assetComponentCreatedStatus__c=null and Name=\'AA-111112\' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        
        //GenerateComponentSNFromShipmentFlexFlow.ShipmentFlexFlowWrapper(Shipment_Flexflow__c shipmentFlexFlowLine,String srPartProcessed,String srPartLocation,String srChildItem);
    }
    
    static testMethod void GenerateSN1()
    {
        test.startTest();
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Product2 testProduct2 = new Product2(Name 					= 'ES1-H90T',
                                             ProductCode			='ES1-H90T',
                                             Product_Type__c		='Hardware',
                                             Product_Type_2__c		='Expansion Shelves',
                                             Product_Sub_Type__c	='ES1',
                                             Description			='90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable',
                                             Family					='Expansion Shelves');
        insert testProduct2;
        
        Asset asst1 = new Asset(Name 								= 'AA-111112', 
                                AccountId 							= acc.Id, 
                                Product2Id 							= testProduct2.id,
                                HPE_Serial_Number__c 				= 'HPE123457',
                                Array_Controller__c 				= 'CS300',
                                Array_Networking__c 				= '2P',
                                Array_Networking_2__c 				= '2P',
                                Array_Networking_3__c 				= '2P',
                                Array_Cache__c 						= '640F',
                                SSD_Bank_A__c 						= '480F',
                                SSD_Bank_B__c 						= '480F',
                                Asset_Type_Build__c 				='AFA3',
                                Status 								= 'Shipped',
                                Component_SKU_HPE__c 				= 'R4U28A',
                                Component_SKU_Nimble_V2__c 			= '6010',
                                Expansion_Shelf_Base__c 			= 'AFS2',
                                Array_Capacity__c 					= '11T');
        
        insert asst1;
        
        Shipment_Flexflow__c ship1 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='Power Supply',
                                                              shipmentFlexflowChildSn__c='10000',
                                                              shipmentFlexflowItem__c='TEST',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship1;
        Shipment_Flexflow__c ship2 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='Power Supply',
                                                              shipmentFlexflowChildSn__c='10000',
                                                              shipmentFlexflowItem__c='NMBR-SR-',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship2;
        Shipment_Flexflow__c ship3 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='Power Supply',
                                                              shipmentFlexflowChildSn__c='10003',
                                                              shipmentFlexflowItem__c='Test',
                                                              shipmentFlexflowChildLotNumber__c = 'PWS-1K23A-1R',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship3;
        
        Shipment_Flexflow__c ship4 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='Power Supply',
                                                              shipmentFlexflowChildSn__c='10005',
                                                              shipmentFlexflowItem__c='TEST',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship4;
        
        Shipment_Flexflow__c ship5 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='Power Supply',
                                                              shipmentFlexflowChildSn__c='10006',
                                                              shipmentFlexflowItem__c='Test',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship5;
        
        Shipment_Flexflow__c ship6 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='Power Supply',
                                                              shipmentFlexflowChildSn__c='10007',
                                                              shipmentFlexflowItem__c='Test',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship6;
        
        Shipment_Flexflow__c ship7 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='207-0001-001',
                                                              shipmentFlexflowChildSn__c='10007',
                                                              shipmentFlexflowItem__c='Test',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship7;
        
        Shipment_Flexflow__c ship8 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='207-0003-001',
                                                              shipmentFlexflowChildSn__c='10007',
                                                              shipmentFlexflowItem__c='Test',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship8;
        
        Shipment_Flexflow__c ship9 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='LEFT PSU',
                                                              shipmentFlexflowChildSn__c='10007',
                                                              shipmentFlexflowItem__c='Test',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship9;
        
        Shipment_Flexflow__c ship10 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                               shipmentFlexflowChildPn__c='RIGHT PSU',
                                                               shipmentFlexflowChildSn__c='10007',
                                                               shipmentFlexflowItem__c='Test',
                                                               shipmentFlexflowReferenceA__c='SO202020',
                                                               shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship10;
        //Component__c c1 = new Component__c(componentAsset__c= asst1.Id,componentType__c ='SSD',componentServicePartNumber__c = 'SR-HDD-1TB-SAS',componentComponentSN__c='10006');
        //insert c1;
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Inventory_SKUs__c,Component_SKU_HPE__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-111112\' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
        test.stopTest();
        
    }
    
    static testMethod void GenerateSN2()
    {
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Product2 testProduct2 = new Product2(Name 					= 'ES1-H90T',
                                             ProductCode			='ES1-H90T',
                                             Product_Type__c		='Hardware',
                                             Product_Type_2__c		='Expansion Shelves',
                                             Product_Sub_Type__c	='ES1',
                                             Description			='90TB Raw, 66-132TB Usable, 1920GB Flash Cache, Hyb Exp Shelf, 2x1M Qual SAS cable',
                                             Family					='Expansion Shelves');
        insert testProduct2;
        
        Asset asst1 = new Asset(Name 								= 'AA-111112', 
                                AccountId 							= acc.Id, 
                                Product2Id 							= testProduct2.id
                                ,HPE_Serial_Number__c 				= 'HPE123457',
                                Array_Controller__c 				= 'CS300',
                                Array_Networking__c 				= '2P',
                                Array_Networking_2__c 				= '2P',
                                Array_Networking_3__c 				= '2P',
                                Array_Cache__c 						= '640F',
                                SSD_Bank_A__c 						= '480F',
                                SSD_Bank_B__c 						= '480F',
                                Asset_Type_Build__c 				='AFA3',
                                Status 								= 'Shipped',
                                Component_SKU_HPE__c 				= 'R4U28A',
                                Component_SKU_Nimble_V2__c 			= '6010',
                                Expansion_Shelf_Base__c 			= 'AFS2',
                                Array_Capacity__c 					= '11T');
        
        insert asst1;
        
        Shipment_Flexflow__c ship1 = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111112',
                                                              shipmentFlexflowChildPn__c='NMB-',
                                                              shipmentFlexflowChildSn__c='PQS2015AP1210506DA',
                                                              shipmentFlexflowItem__c='NMB-52C763',
                                                              shipmentFlexflowReferenceA__c='SO202020',
                                                              shipmentFlexflowFlexProcessed__c = 'Error');
        insert ship1;
        
        
        
        
        
        //Component__c c1 = new Component__c(componentAsset__c= asst1.Id,componentType__c ='SSD',componentServicePartNumber__c = 'SR-HDD-1TB-SAS',componentComponentSN__c='10006');
        //insert c1;
        
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Inventory_SKUs__c,Component_SKU_HPE__c,assetArenaProductCode__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset  where Status=\'Shipped\' and assetComponentCreatedStatus__c=null and Name=\'AA-111112\' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch e = new AssetComponentPopulationFromArenaBatch(Query);
        Database.executeBatch(e);
    }
    
    
    
}