@isTest
public class rmav2ExtensionsWithSharingDetailTest {
    
    class TestData {
        
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        SR_Meta_Data__c srMetaData;
        EOAPart__c eoaPart;
        Product2 testProduct1;
        Component__c testComponent1;
        Component__c testComponent2;
        Component__c testComponent3;
        Component__c testComponent4;
        
        
        
        TestData() {
            
            // Create test account
            insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                         BillingStreet = 'Am Tierpark 16',
                                         BillingCity = 'Cologne',
                                         BillingPostalCode = '54321',
                                         BillingState = 'Nordrhein-Westfalen',
                                         BillingCountry = 'Germany');
            System.assertNotEquals(null,              account.Id);
            System.assertEquals('TEST-ACCOUNT', account.Name);
            System.assertEquals('Account RMA SHI',    account.accountRmaShi__c);
            
            
            // Create test contact
            /*insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                         AccountId = account.Id,
                                         Email='test@gmail.com',
                                         Phone='999999999');
            System.assertNotEquals(null,                        contact.Id);
            System.assertEquals('TEST-CONTACT-LAST-NAME', contact.LastName);
            System.assertEquals(account.Id,            contact.AccountId);
            System.assertEquals('test@gmail.com',            contact.Email);
            System.assertEquals('999999999',            contact.Phone);*/
            
            insert testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                               ProductCode='CS220',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='SAN Storage Array',
                                               Controller_Code__c='CS200',
                                               Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                               Family='SAN Storage Array');
            
            // Create test asset
            insert asset = new Asset(Name = 'TEST-ASSET',
                                     AccountId = account.Id,
                                     //ContactId = contact.Id,
                                     Product2Id	= testProduct1.Id,
                                     SLA__c = 'Premium',Array_Controller__c = 'CS300',
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
                                     Array_Capacity__c 			= '11T',
                                     assetRmaShi__c = 'Asset RMA SHI',HPE_Serial_Number__c ='AA000000NIM');
            
            /*System.assertNotEquals(null,                      asset.Id);
System.assertEquals('TEST-ASSET',                  asset.Name);
System.assertEquals(account.Id,                 asset.AccountId);
System.assertEquals(contact.Id,                 asset.ContactId);
System.assertEquals('Premium',                     asset.SLA__c);
System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);*/
            
            // Create test case
            insert aCase = new Case(AccountId = account.Id,
                                    AssetId   = asset.Id,
                                    //ContactId = contact.Id,
                                    Subject = 'TEST-CASE-SUBJECT');
            
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            //System.assertEquals(contact.Id,       aCase.ContactId);
            System.assertEquals('TEST-CASE-SUBJECT', aCase.Subject);
            
            insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                    abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                    abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                    abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                    abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                    abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                    abPostalCode__c='1000',
                                                    abDescription__c='Asset Install Address 1');
            
            System.assertNotEquals(null,             addressBook.Id);
            System.assertEquals(account.Id,       addressBook.abAccount__c);
            System.assertEquals('TEST-ASSET-INSTALL-STREET1',         addressBook.abStreet1__c);
            System.assertEquals('TEST-ASSET-INSTALL-STREET2',       addressBook.abStreet2__c);
            System.assertEquals('TEST-ASSET-INSTALL-CITY', addressBook.abCity__c);
            System.assertEquals('TEST-ASSET-INSTALL-STATE', addressBook.abStateProvince__c);
            System.assertEquals('TEST-ASSET-INSTALL-COUNTRY', addressBook.abCountry__c);
            System.assertEquals('1000', addressBook.abPostalCode__c);
            System.assertEquals('Asset Install Address 1', addressBook.abDescription__c);
            
        }
        
        void insertComponents()
        {
            
            insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='123456',
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Chassis');
        }
        void insertComponents01()
        {   
            
            insert testComponent2 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-USB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='0654321',
                                                     componentType__c='USB',
                                                     componentDescription__c='USB');
        }
        void insertComponents02()
        {
            
            insert testComponent3 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-SDD-1TB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='13579',
                                                     componentType__c='SSD',
                                                     componentDescription__c='SSD');
        }
        void insertComponents03()
        {
            insert testComponent4 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-Bezel-CS-series',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='02468',
                                                     componentType__c='BEZEL',
                                                     componentDescription__c='BEZEL');   
        }
        
        
        void insertRMA01()
        {
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent1.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component',rmaOverrideShipmentPhone__c = '9876543210',
                                      rmaOverrideShipmentAttn__c = 'test',rmaOverrideShipmentEmail__c = 'test@gmail.com',
                                      rmaDeliveryDate__c = system.today().addDays(2),
                                      rmaDeliveryTimes__c = '10:00 PM');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        void insertRMA02()
        {
            asset.SLA__c = 'Premium 4 Hour Onsite';
            asset.assetNrdEndDate__c = Date.today() + 10;
            update asset;
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent3.Id, rmaOverrideShipmentAttn__c = 'test',
                                      rmaAddressBook__c = addressBook.Id,rmaOverrideShipmentEmail__c = 'test@gmail.com',
                                      rmaSelection__c = 'Component',rmaOverrideShipmentPhone__c = '9876543210',
                                      rmaFaRequired__c = 'Engineering FA',
                                      rmaOnsiteHddSsdSlot__c = '1',
                                      rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours',
                                      rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site',
                                      rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival',
                                      rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site',      
                                      rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET',
                                      rmaOverrideOnsiteArrivalCity__c = 'TESTCITY',
                                      rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222',
                                      rmaOverrideOnsiteArrivalCountry__c = 'United States');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent3.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);   
        }
        
        void insertRMA03()
        {
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent1.Id, rmaOverrideShipmentAttn__c = 'test',rmaOverrideShipmentEmail__c = 'test@gmail.com',
                                      rmaAddressBook__c = addressBook.Id,rmaOverrideShipmentPhone__c = '9876543210',
                                      rmaSelection__c = 'Component',
                                      rmaDeliveryDate__c = system.today(),
                                      rmaDeliveryTimes__c = '10:00 PM',
                                      rmaAssetLocalDateTime__c = '10/08/2020 01:00 PM'
                                     );  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
    }  
    
    static testMethod void rmaAssetLocalTime()
    { 
        //Test.startTest();
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        Test.startTest();
        testData.insertRMA03();
        
        
        testData.rma = [SELECT Id,
                        rmaCaseNumber__c,
                        rmaAssetLocalDateTime__c,
                        rmaDeliveryDate__c,
                        rmaDeliveryTimes__c,
                        rmaType__c,
                        rmaFaRequired__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,
                        rmaShipmentAccountName__c,
                        rmaShipmentAttn__c,
                        rmaShipmentStreet1__c,
                        rmaShipmentStreet2__c,
                        rmaShipmentCity__c,
                        rmaShipmentState__c,
                        rmaShipmentCountry__c,
                        rmaShipmentPostalCode__c,
                        rmaShipmentPhone__c,
                        rmaShipmentEmail__c,
                        rmaAllowOrderCancel__c,
                        rmaCaseNumber__r.casePachinkoCaseType__c,
                        rmaIsNBDOnsiteRetain__c,
                        rmaIsNBDOverriden__c,rmaFailedPart__c
                        FROM   RMAv2__c];
        
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetail newRma = new rmav2ExtensionsWithSharingDetail(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', String.valueOf(testData.rma.Id));
        Test.setCurrentPage(pageRef);
        system.debug('SOQL Limit ===>'+Limits.getqueries());       
        newRma.submitRMA();
        newRma.getHistories();
        newRma.getShipmentLabelDetails();
        //newRma.getOpenShipmentStatus();
        //newRma.getSubmitRMALabel();
        
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        Test.stopTest();
        //newRma.cancelRMA();
        //System.assertEquals(true,newRma.hideOnSiteSections);
        //System.assertEquals(false, newRma.hideReturnSections);
        
        
    }
    
    static testMethod void rmaCloneError()
    {  
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        Test.startTest();
        testData.insertRMA01();
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        testData.rma = [SELECT Id,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        //rmaReason__c,
                        rmaManufacturer__c,
                        //rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSLA__c,
                        rmaCaseNumber__r.casePachinkoCaseType__c,
                        rmaIsNBDOnsiteRetain__c,
                        rmaIsNBDOverriden__c,rmaFailedPart__c
                        FROM   RMAv2__c where rmaAssetSLA__c != null];
        //testData.rma.Id = null;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetail rma = new rmav2ExtensionsWithSharingDetail(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', testData.rma.Id);
        Test.setCurrentPage(pageRef);
        rma.cloneRMA();
        Test.stopTest();
        List<RMAv2__c> lstRma = [SELECT Id  FROM   RMAv2__c];
        System.assertEquals(1,lstRma.size());
    }
    
    static testMethod void rmaDelete()
    { 
        
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        Test.startTest();
        testData.insertRMA01();
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        testData.rma = [SELECT Id,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,rmaCaseNumber__r.casePachinkoCaseType__c,
                        rmaIsNBDOnsiteRetain__c,
                        rmaIsNBDOverriden__c,rmaFailedPart__c
                        FROM   RMAv2__c];
        
        //Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetail rma = new rmav2ExtensionsWithSharingDetail(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', testData.rma.Id);
        Test.setCurrentPage(pageRef);
        
        rma.deleteRMA();
        
        List<RMAv2__c> lstRma = [SELECT Id  FROM   RMAv2__c];  
        System.assertEquals(0,lstRma.size());
        Test.stopTest();
        
        
        
    }
    static testMethod void rmaCancel()
    { 
        
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        Test.startTest();
        testData.insertRMA01();
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        testData.rma = [SELECT Id,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,
                        rmaCaseNumber__r.casePachinkoCaseType__c,
                        rmaIsNBDOnsiteRetain__c,
                        rmaIsNBDOverriden__c,rmaFailedPart__c
                        FROM   RMAv2__c];
        
        //Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetail rma = new rmav2ExtensionsWithSharingDetail(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', testData.rma.Id);
        Test.setCurrentPage(pageRef);
        rma.submitRMA();
        rma.cancelRMA();
        
        List<RMAv2__c> lstRma = [SELECT Id  FROM  RMAv2__c];  
        System.assertEquals(1,lstRma.size());
        Test.stopTest();
    }
    
    
    static testMethod void rmaDeleteError()
    { 
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        Test.stopTest();
        testData.insertComponents();
        
        testData.insertRMA01();
        
        testData.asset.SLA__c = null;
        update testData.asset;
        
        testData.rma = [SELECT Id,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,
                        rmaCaseNumber__r.casePachinkoCaseType__c,
                        rmaIsNBDOnsiteRetain__c,
                        rmaIsNBDOverriden__c,rmaFailedPart__c
                        FROM   RMAv2__c];
        
        Schema.DescribeSObjectResult r = RMAv2__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        testData.rma.Id = keyPrefix + 'S0000001dHFB';
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetail rma = new rmav2ExtensionsWithSharingDetail(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', testData.rma.Id);
        Test.setCurrentPage(pageRef);
        
        rma.deleteRMA();
        
        List<RMAv2__c> lstRma = [SELECT Id  FROM   RMAv2__c];  
        System.assertEquals(1,lstRma.size());
        
        
        
    }
    static void rmaClone1()
    { 
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        testData.insertRMA01();
    }
    
    @isTest(SeeAllData=true)
    static void submitRMA(){
        Test.startTest();
        RMAv2__c rma = [Select Id,Name,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaFaRequired__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,
                        rmaShipmentAccountName__c,
                        rmaShipmentAttn__c,
                        rmaShipmentStreet1__c,
                        rmaShipmentStreet2__c,
                        rmaShipmentCity__c,
                        rmaShipmentState__c,
                        rmaShipmentCountry__c,
                        rmaShipmentPostalCode__c,
                        rmaShipmentPhone__c,
                        rmaShipmentEmail__c,
                        rmaAllowOrderCancel__c,
                        rmaCaseNumber__r.casePachinkoCaseType__c,
                        rmaIsNBDOnsiteRetain__c,
                        rmaIsNBDOverriden__c,rmaFailedPart__c 
                        From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' LIMIT 1];
        
        
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingDetail newRma = new rmav2ExtensionsWithSharingDetail(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', String.valueOf(rma.Id));
        Test.setCurrentPage(pageRef);
        
        newRma.submitRMA();
        
        
    }
    
    @isTest(SeeAllData=true)
    static void submitRMA01(){
        Test.startTest();
        RMAv2__c rma = [Select Id,Name,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaFaRequired__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,
                        rmaShipmentAccountName__c,
                        rmaShipmentAttn__c,
                        rmaShipmentStreet1__c,
                        rmaShipmentStreet2__c,
                        rmaShipmentCity__c,
                        rmaShipmentState__c,
                        rmaShipmentCountry__c,
                        rmaShipmentPostalCode__c,
                        rmaShipmentPhone__c,
                        rmaShipmentEmail__c,
                        rmaAllowOrderCancel__c,
                        rmaCaseNumber__r.casePachinkoCaseType__c,
                        rmaIsNBDOnsiteRetain__c,
                        rmaIsNBDOverriden__c,rmaFailedPart__c ,rmaShowReturnSectionsAlways__c
                        From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' and
                        rmaUplift__c = 'Premium Onsite' LIMIT 1];
        
        SR_Meta_Data__c srData = [Select Id,Name from SR_Meta_Data__c where srPartShipSLAOverride__c = 'NBD & Onsite Override' limit 1];
        
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingDetail newRma = new rmav2ExtensionsWithSharingDetail(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', String.valueOf(rma.Id));
        Test.setCurrentPage(pageRef);
        
        newRma.submitRMA();
        
        
    }
    
    @isTest(SeeAllData=true)
    static void submitRMA02(){
        Test.startTest();
        RMAv2__c rma = [Select Id,Name,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaFaRequired__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,
                        rmaShipmentAccountName__c,
                        rmaShipmentAttn__c,
                        rmaShipmentStreet1__c,
                        rmaShipmentStreet2__c,
                        rmaShipmentCity__c,
                        rmaShipmentState__c,
                        rmaShipmentCountry__c,
                        rmaShipmentPostalCode__c,
                        rmaShipmentPhone__c,
                        rmaShipmentEmail__c,
                        rmaAllowOrderCancel__c,
                        rmaCaseNumber__r.casePachinkoCaseType__c,
                        rmaIsNBDOnsiteRetain__c,
                        rmaIsNBDOverriden__c,rmaFailedPart__c ,rmaShowReturnSectionsAlways__c
                        From RMAv2__c where rmaShowOnSiteSectionsAlways__c = true LIMIT 1];
        
        SR_Meta_Data__c srData = [Select Id,Name from SR_Meta_Data__c where srPartShipSLAOverride__c = 'NBD & Onsite Override' limit 1];
        
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingDetail newRma = new rmav2ExtensionsWithSharingDetail(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', String.valueOf(rma.Id));
        Test.setCurrentPage(pageRef);
        
        newRma.submitRMA();
        newRma.getRenderEFAPriority();
        newRma.getDraftShipmentStatus();
        
        
    }
    
    
    
    
}