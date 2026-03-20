@isTest
public class rmaTriggerUpliftnLogisticsTest {
    class TestData
    {
        Account                         testAccount;
        Contact                         testContact;
        Asset                           testAsset;
        Case                            testCase;
        Depot__c                        testDepot;
        DepotMapNbdNd__c                testDepotMapNbdNd;
        depotMap4Hour__c				testdepotMap4Hour;
        RMAv2__c                        testRma;
        ActivateTrigger__c 			 	activateTriggerCustomSetting;
        
        TestData()
        {
            //check the custom setting value set for the rma trigger to run.
            insert activateTriggerCustomSetting = new ActivateTrigger__c(RMATrigger__c = True);
            Integer soqlQueriesUsed = Limits.getQueries();
            System.debug('SOQL Queries Used 1: ' + soqlQueriesUsed);
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            soqlQueriesUsed = Limits.getQueries();
            System.debug('SOQL Queries Used 2: ' + soqlQueriesUsed);
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            soqlQueriesUsed = Limits.getQueries();
            System.debug('SOQL Queries Used 3: ' + soqlQueriesUsed);
            Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                                 ProductCode='SSD123',
                                                 Product_Type__c='Hardware',
                                                 Product_Type_2__c='SAN Storage ArrayS',
                                                 Controller_Code__c='CS2001',
                                                 Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                 Family='SAN Storage Array');
            insert testProduct2;
            soqlQueriesUsed = Limits.getQueries();
            System.debug('SOQL Queries Used 4: ' + soqlQueriesUsed);
            // Create test Asset
            test.StartTest();
            insert testAsset = new Asset(Name                      = 'AA-100400',
                                         AccountId                 = testAccount.Id,
                                         ContactId                 = testContact.Id,
                                         SLA__c                    = 'Premium',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                                         HPE_Serial_Number__c 	   = 'AA000000NIM',
                                         Install_Street1__c        = '123 Main Street',
                                         Install_Street2__c        = 'Suite 100',
                                         Install_City__c           = 'San Jose',
                                         Install_State_Province__c = 'CA',
                                         Install_Zip_Code__c       = '95151',
                                         Install_Country__c        = 'United States',
                                         Ship_Date__c              = Date.today().addDays(-180));
            soqlQueriesUsed = Limits.getQueries();
            System.debug('SOQL Queries Used 5: ' + soqlQueriesUsed);
            
            // Create test Case
            insert testCase = new Case(AccountId = testAccount.Id,
                                       AssetId   = testAsset.Id,
                                       ContactId = testContact.Id,
                                       Subject   = 'TEST-CASE-SUBJECT', Technology_Area__c = '3rd Party Apps', Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)');
            soqlQueriesUsed = Limits.getQueries();
            System.debug('SOQL Queries Used 6: ' + soqlQueriesUsed); 
            test.StopTest();
        }
        
        void insertDepot001WithNdNBDand4hourEntries(){
            
            // Create test Depot
            insert testDepot = new Depot__c(Name                        = 'TEST-001',
                                            depotProvider__c            = 'Flash',
                                            depotStockedFor4Hour__c     = 'Yes',
                                            depotLocationDescription__c = 'Test depot 001',
                                            Returns_Carrier__c          = 'DHL');
            
            // Create test NBD/ND mapping
            insert testDepotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United States',
                                                            depotMapNbdNdState__c     = 'N/A',
                                                            depotMapNbdNd_NbdDepot__c = testDepot.Id,
                                                            depotMapNbdNd_NdDepot__c  = testDepot.Id);
            // Create test 4-hour mapping
            insert testdepotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                                            depotMap4HourPostalCode__c  = '11111',
                                                            depotMap4Hour_4HourDepot__c =  testDepot.Id,
                                                            depotMap4HourDriveTime__c   = 10.5);
        }
        void insertDepot002WithNdNBDand4hourEntries(){
            
            // Create test Depot
            insert testDepot = new Depot__c(Name                        = 'TEST-002',
                                            depotProvider__c            = 'Flash',
                                            depotStockedFor4Hour__c     = 'Yes',
                                            depotLocationDescription__c = 'Test depot 002',
                                            Returns_Carrier__c          = 'DHL');
            
            // Create test NBD/ND mapping
            insert testDepotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United States',
                                                            depotMapNbdNdState__c     = 'N/A',
                                                            depotMapNbdNd_NbdDepot__c = testDepot.Id,
                                                            depotMapNbdNd_NdDepot__c  = testDepot.Id);
            // Create test 4-hour mapping
            insert testdepotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                                            depotMap4HourPostalCode__c  = '22222',
                                                            depotMap4Hour_4HourDepot__c = testDepot.Id,
                                                            depotMap4HourDriveTime__c   = 20.5);
        }
        void insertDepot003WithNdNBDand4hourEntries(){
            
            // Create test Depot
            insert testDepot = new Depot__c(Name                        = 'TEST-003',
                                            depotProvider__c            = 'Flash',
                                            depotStockedFor4Hour__c     = 'Yes',
                                            depotLocationDescription__c = 'Test depot 003',
                                            Returns_Carrier__c          = 'DHL');
            
            // Create test NBD/ND mapping
            insert testDepotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United States',
                                                            depotMapNbdNdState__c     = 'N/A',
                                                            depotMapNbdNd_NbdDepot__c = testDepot.Id,
                                                            depotMapNbdNd_NdDepot__c  = testDepot.Id);
            
            // Create test 4-hour mapping
            insert testdepotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                                            depotMap4HourPostalCode__c  = '22222',
                                                            depotMap4Hour_4HourDepot__c = testDepot.Id,
                                                            depotMap4HourDriveTime__c   = 30.5);
            
        }
        void insertDepot004WithNdNBDand4hourEntries(){
            
            // Create test Depot
            insert testDepot = new Depot__c(Name                        = 'TEST-004',
                                            depotProvider__c            = 'Flash',
                                            depotStockedFor4Hour__c     = 'No',
                                            depotLocationDescription__c = 'Test depot 004',
                                            Returns_Carrier__c          = 'DHL');
            
            // Create test NBD/ND mapping
            insert testDepotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United States',
                                                            depotMapNbdNdState__c     = 'N/A',
                                                            depotMapNbdNd_NbdDepot__c = testDepot.Id,
                                                            depotMapNbdNd_NdDepot__c  = testDepot.Id);
        }
        void insertDepot005WithNdNBDand4hourEntries(){
            
            // Create test Depot
            insert testDepot = new Depot__c(Name                        = 'TEST-005',
                                            depotProvider__c            = 'Flash',
                                            depotStockedFor4Hour__c     = 'No',
                                            depotLocationDescription__c = 'Test depot 005',
                                            Returns_Carrier__c          = 'DHL');
            
            // Create test NBD/ND mapping
            insert testDepotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United States',
                                                            depotMapNbdNdState__c     = 'N/A',
                                                            depotMapNbdNd_NbdDepot__c = testDepot.Id,
                                                            depotMapNbdNd_NdDepot__c  = testDepot.Id);
        }
        
        void insertRMAHdd210()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS210/220/420',
                                          rmaPart__c                       = 'HDD: 1TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        } 
    }
   /* @isTest static void testConstructor()
    {
        TestData testData;
        testData = new TestData();
        Test.startTest();
        // Create test Case
        case testCase = new case();
        insert testCase = new Case(AccountId = testData.testAccount.Id,
                                   AssetId   = testData.testAsset.Id,
                                   ContactId = testData.testContact.Id,
                                   Subject   = 'TEST-CASE-SUBJECT', Technology_Area__c = '3rd Party Apps', Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)');
        Test.stopTest();
    }*/
    // ==================================================================================== testHdd210Before
    @isTest static void test4Hour_2DepotsStocked()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.insertDepot002WithNdNBDand4hourEntries();

        testData.insertRMAHdd210(); 
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
        rmas[0].rmaOverrideShipmentPostalCode__c = '22222-2222';
        rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
        
        update rmas[0];
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
   
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
        System.assertEquals('22222-2222',             rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-002',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    //  ==================================================================================== test4Hour_1DepotsStocked
    @isTest static void test4Hour_1DepotsStocked()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.insertDepot001WithNdNBDand4hourEntries();
        //Test.startTest();
        testData.insertRMAHdd210();
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
        rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
        rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
        update rmas[0];
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        //Test.stopTest();
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
        System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== test4Hour_0DepotsStocked
    @isTest static void test4Hour_0DepotsStocked()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.insertDepot003WithNdNBDand4hourEntries();
        //Test.startTest();
        testData.insertRMAHdd210();
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
        rmas[0].rmaOverrideShipmentPostalCode__c = '00000-0000';
        rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
        update rmas[0];
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        //Test.stopTest();
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
        System.assertEquals('00000-0000',             rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
        //System.assertEquals('Nimble',                 rmas[0].rmaOutgoingShipmentOrderProvider__c);
        //System.assertEquals('TEST-005',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== test4HourUnknown
    @isTest static void test4HourUnknown()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.insertDepot004WithNdNBDand4hourEntries();
        //Test.startTest();
        testData.insertRMAHdd210();
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
        rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
        rmas[0].rmaOverrideShipmentCountry__c    = 'Unknownistan';
        update rmas[0];
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        //Test.stopTest();
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
        System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('Unknownistan',           rmas[0].rmaOverrideShipmentCountry__c);
        //System.assertEquals('Unknown',                rmas[0].rmaOutgoingShipmentOrderProvider__c);
        //System.assertEquals('Unknown',                rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== testNbdUnknown
    @isTest static void testNbdUnknown()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.insertDepot004WithNdNBDand4hourEntries();
        //Test.startTest();
        testData.insertRMAHdd210();
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
        rmas[0].rmaOverrideShipmentCountry__c    = 'Unknownistan';
        update rmas[0];
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        //Test.stopTest();
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
        System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('Unknownistan',           rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Unknown',                rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('Unknown',                rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== testNd
    @isTest static void testNd()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.insertDepot005WithNdNBDand4hourEntries();
        //Test.startTest();
        testData.insertRMAHdd210();
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'Yes: Uplift to Next Day';
        rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
        rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
        update rmas[0];
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        //Test.stopTest();
        System.assertEquals(1,                          rmas.size());
        System.assertEquals('Yes: Uplift to Next Day',  rmas[0].rmaUplift__c);
        System.assertEquals('11111-1111',               rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('United States (US)',       rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',                   rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-005',                 rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== testNbd
    @isTest static void testNbd()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.insertDepot004WithNdNBDand4hourEntries();
        //Test.startTest();
        testData.insertRMAHdd210();
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,rmaShipmentState__c
                FROM   RMAv2__c];
        system.debug('rmas.rmaShipmentState__c :'+rmas[0].rmaShipmentState__c);
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
        rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
        update rmas[0];
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        //Test.stopTest();
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
        System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',                 rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-004',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testSystemPartReturn
    @isTest static void testSystemPartReturn()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.insertDepot005WithNdNBDand4hourEntries();
        //Test.startTest();
        testData.insertRMAHdd210();
        
        rmas = [SELECT Id,
                rmaType__c,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaType__c                       = 'System/part return';
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
        rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
        update rmas[0];
        
        rmas = [SELECT Id,
                rmaType__c,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        //Test.stopTest();
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('System/part return',     rmas[0].rmaType__c);
        System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
        System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Nimble',                 rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('SRV-NIMBLE',             rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testDeliveryInstruction
    @isTest static void testDeliveryInstruction()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.insertDepot005WithNdNBDand4hourEntries();
        //Test.startTest();
        testData.insertRMAHdd210();
        
        rmas = [SELECT Id FROM  RMAv2__c];
        System.assertEquals(1, rmas.size());
        rmas[0].rmaTransmitRmaShisWithOrder__c = 'Account RMA SHI;Asset RMA SHI;RMA SHI';
        update rmas[0];
        
        rmas = [SELECT Id,
                rmaStatus__c,
                rmaTransmitRmaShisWithOrder__c,
                rmaDeliveryInstructions__c
                FROM   RMAv2__c];
        //Test.stopTest();
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('Draft', rmas[0].rmaStatus__c);
        System.assertEquals('Account RMA SHI;Asset RMA SHI;RMA SHI', rmas[0].rmaTransmitRmaShisWithOrder__c);
        System.assertNotEquals(null, rmas[0].rmaDeliveryInstructions__c);
        
    }
}