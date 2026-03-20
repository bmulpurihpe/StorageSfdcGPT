@isTest
private class rmav2ExtensionsWithSharingDetailV2Test {
    
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
            insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                         AccountId = account.Id,
                                         Email='test@gmail.com',
                                         Phone='999999999');
            System.assertNotEquals(null,                        contact.Id);
            System.assertEquals('TEST-CONTACT-LAST-NAME', contact.LastName);
            System.assertEquals(account.Id,            contact.AccountId);
            System.assertEquals('test@gmail.com',            contact.Email);
            System.assertEquals('999999999',            contact.Phone);
            
            // Create test asset
            insert asset = new Asset(Name = 'TEST-ASSET',
                                     AccountId = account.Id,
                                     ContactId = contact.Id,
                                     SLA__c = 'Premium',
                                     assetRmaShi__c = 'Asset RMA SHI',HPE_Serial_Number__c ='AA000000NIM');
            
            System.assertNotEquals(null,                      asset.Id);
            System.assertEquals('TEST-ASSET',                  asset.Name);
            System.assertEquals(account.Id,                 asset.AccountId);
            System.assertEquals(contact.Id,                 asset.ContactId);
            System.assertEquals('Premium',                     asset.SLA__c);
            System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
            
            // Create test case
            insert aCase = new Case(AccountId = account.Id,
                                    AssetId   = asset.Id,
                                    ContactId = contact.Id,
                                    Subject = 'TEST-CASE-SUBJECT');
            
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            System.assertEquals(contact.Id,       aCase.ContactId);
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
                                      rmaSelection__c = 'Component',
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
                                      rmaComponentV2__c = testComponent3.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component',
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
                                      rmaComponentV2__c = testComponent1.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component',
                                      rmaDeliveryDate__c = system.today(),
                                      rmaDeliveryTimes__c = '10:00 PM',
                                     rmaAssetLocalDateTime__c = system.today()+' '+'12:00 AM' );  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
    }           
    static testMethod void rmaPremiumAsset()
    { 
       	//Test.startTest();
       	system.debug('SOQL Limit ===>'+Limits.getqueries());
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
       	Test.startTest();
        testData.insertRMA01();
        
        
        testData.rma = [SELECT Id,
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
                        FROM   RMAv2__c];
	
		system.debug('SOQL Limit ===>'+Limits.getqueries());
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetailV2 newRma = new rmav2ExtensionsWithSharingDetailV2(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', String.valueOf(testData.rma.Id));
        Test.setCurrentPage(pageRef);
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        newRma.getShipmentLabelDetails();
        newRma.getOpenShipmentStatus();
        newRma.getSubmitRMALabel();
        newRma.getDraftShipmentStatus();
        newRma.getRenderEFAPriority();
        newRma.submitRMA();
        
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        Test.stopTest();
        //newRma.cancelRMA();
        //System.assertEquals(true,newRma.hideOnSiteSections);
        //System.assertEquals(false, newRma.hideReturnSections);
        
        
    }
    
    static testMethod void rmaClone()
    { 
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        Test.startTest();
        testData.insertRMA01();
        /*testData.rma = [SELECT Id,
                        rmaType__c,
                        rmaStatus__c,                         
                        rmaFaRequired__c,
                        rmaCaseNumber__c,   
                        rmaCustomerFARequired__c,
                        rmaCaseNimbleVersion__c,
                        rmaRCACompleted__c,
                        rmaReturnTo__c,
                        rmaExcludeFromOpsMetrics__c,
                        //rmaWarrantyEntitlement__c, 
                        
                        //Part Selection Section (WHAT)                   
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaManufacturer__c,
                        rmaDiskShelfAsset__c,
                        rmaHddSsdSerialNumber__c,
                        rmaConfigurationDetails__c,
                        
                        
                        //RMA Reason Section (WHY)
                        //rmaReason__c,
                        //rmaGeneralFailureDetails__c,
                        //rmaDetailedReason__c,
                        
                        //Address Selection Section (WHERE)
                        rmaAddressBook__c,
                        rmaAddOverriddenAddressToAddressBook__c,
                        rmaOverrideShipmentAccountName__c,
                        rmaOverrideShipmentStreet1__c,
                        rmaOverrideShipmentStreet2__c,
                        rmaOverrideShipmentCity__c,
                        rmaOverrideShipmentState__c,
                        rmaOverrideShipmentPostalCode__c,
                        rmaOverrideShipmentCountry__c,
                        rmaOverrideShipmentAttn__c,
                        rmaOverrideShipmentPhone__c,
                        rmaOverrideShipmentEmail__c,
                        
                        //SLA/Uplift Selection Section (WHEN)
                        //rmaAssetSLA__c,
                        //rmaShipmentSLA__c,
                        rmaUplift__c,
                        rmaMissedSLA__c,
                        rmaUpliftApprovedBy__c,
                        rmaMissedSLAReason__c,
                        
                        //SHI Section
                        rmaTransmitRmaShisWithOrder__c,
                        rmaSHI__c,
                        
                        //Onsite Service Info Section
                        rmaOnsiteTechStatus__c,
                        rmaOnsiteTechDateTimeOrderConfirmed__c,
                        rmaOnsiteTechDateTimeArrivalEta__c,
                        rmaOnsiteTechOrderNumber__c,
                        rmaOnsiteTechDateTimeArrivalActual__c,
                        rmaOnsiteTechName__c,
                        rmaOnsiteTechDateTimeReleased__c,
                        
                        
                        //Onsite Service - Codes/Notes
                        rmaOverrideOnsiteSchedulingCode__c,
                        rmaOverrideOnsiteSchedulingNotes__c,
                        rmaOverrideOnsitePartHandoverCode__c,
                        rmaOverrideOnsitePartHandoverNotes__c,
                        rmaOverrideOnsiteCheckInCode__c,
                        rmaOverrideOnsiteCheckInNotes__c,
                        rmaOverrideOnsitePartDispositionCode__c,
                        rmaOverrideOnsitePartDispositionNotes__c,
                        
                        //Onsite Service - FE Arrival Address
                        rmaOverrideOnsiteArrivalStreet1__c,
                        rmaOverrideOnsiteArrivalStreet2__c,
                        rmaOverrideOnsiteArrivalCity__c,
                        rmaOverrideOnsiteArrivalState__c,
                        rmaOverrideOnsiteArrivalPostalCode__c,
                        rmaOverrideOnsiteArrivalCountry__c,
                        
                        //Onsite Service - Array Location
                        rmaOverrideAssetLocBuilding__c,
                        rmaOverrideAssetLocFloor__c,
                        rmaOverrideAssetLocDatacenter__c,
                        rmaOverrideAssetLocAreaOrGrid__c,
                        rmaOverrideAssetLocRow__c,
                        rmaOverrideAssetLocRack__c,
                        rmaOverrideAssetLocPositionInRack__c,
                        
                        //Onsite Service - Component Slots
                        rmaOnsiteControllerExpanderSlot__c,
                        rmaOnsiteHddSsdSlot__c, 
                        rmaOnsitePowerSupplySlot__c,
                        rmaOnsiteNicCardSlot__c,
                        
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaShowOnSiteSectionsAlways__c ,
                        rmaShowReturnSectionsAlways__c,
                        rmaAssetSla__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetNrdIsInEffect__c,
                        
                        rmaCaseNumber__r.casePachinkoCaseType__c,
                        rmaIsNBDOnsiteRetain__c,
                        rmaIsNBDOverriden__c,rmaFailedPart__c
                        FROM   RMAv2__c];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetailV2 rma = new rmav2ExtensionsWithSharingDetailV2(sc);
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', testData.rma.Id);
        Test.setCurrentPage(pageRef);
        rma.cloneRMA();
        
        List<RMAv2__c> lstRma = [SELECT Id  FROM   RMAv2__c];  
        System.assertEquals(2,lstRma.size());*/
        Test.stopTest();
        
    }
    static void rmaClone1()
    { 
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        testData.insertRMA01();
    }
    static testmethod void rmaClone_01()
    {
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Component__c testComponent2;
        Component__c testComponent3;
        Component__c testComponent4;
        
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
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        System.assertNotEquals(null,                        contact.Id);
        System.assertEquals('TEST-CONTACT-LAST-NAME', contact.LastName);
        System.assertEquals(account.Id,            contact.AccountId);
        System.assertEquals('test@gmail.com',            contact.Email);
        System.assertEquals('999999999',            contact.Phone);
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',HPE_Serial_Number__c ='AA000000NIM');
        
        System.assertNotEquals(null,                      asset.Id);
        System.assertEquals('TEST-ASSET',                  asset.Name);
        System.assertEquals(account.Id,                 asset.AccountId);
        System.assertEquals(contact.Id,                 asset.ContactId);
        System.assertEquals('Premium',                     asset.SLA__c);
        System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
        
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        System.assertNotEquals(null,             aCase.Id);
        System.assertEquals(account.Id,       aCase.AccountId);
        System.assertEquals(asset.Id,         aCase.AssetId);
        System.assertEquals(contact.Id,       aCase.ContactId);
        System.assertEquals('TEST-CASE-SUBJECT', aCase.Subject);
        
        //Create Address Book
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
        
        insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='123456',
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Chassis');
        Test.startTest();
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent1.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = system.today().addDays(2),
                                  rmaDeliveryTimes__c = '10:00 PM');  
        
        System.assertNotEquals(null,rma.Id);
        System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
        System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
        System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
        System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
        System.assertEquals('Component',rma.rmaSelection__c); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingDetailV2 rmaC = new rmav2ExtensionsWithSharingDetailV2(sc);
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', rma.Id);
        Test.setCurrentPage(pageRef);
        //rmaC.cloneRMA();
        test.stopTest();
    }
   /* @isTest(SeeAllData=true)
    static void rmaCloneMain()
    {
         Account account;
         Contact contact;
         Asset   asset;
         Case aCase;
         RMAv2__c rma;
         AddressBook__c addressBook;
         Component__c testComponent1;
         
         // Create test account
         account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
         System.assertNotEquals(null,              account.Id);
         System.assertEquals('Test Support Tools QA', account.Name);
         
         // Create test contact
         contact = [Select Id,Name,LastName,Email,Phone, AccountId from Contact where Name='Test Exafort' AND AccountId=:account.Id LIMIT 1];
         System.assertNotEquals(null,contact.Id);
         System.assertEquals(account.Id,contact.AccountId);
         System.assertEquals('Test Exafort', contact.Name);
         
         // Create test asset
         asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id LIMIT 1];
         System.assertNotEquals(null,                      asset.Id);
         System.assertEquals('AA-000000',                  asset.Name);
         System.assertEquals(account.Id,                 asset.AccountId);
         System.assertEquals(contact.Id,                 asset.ContactId);
         System.assertEquals('Premium',                     asset.SLA__c);
         
         //Create test case
         aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1 FOR UPDATE];
         System.assertNotEquals(null,             aCase.Id);
         System.assertEquals(account.Id,       aCase.AccountId);
         System.assertEquals(asset.Id,         aCase.AssetId);
         System.assertEquals(contact.Id,       aCase.ContactId);
         System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);

         //Create test Component
         testComponent1 =[Select Id,Name,
                          Sub_State__c,
                          componentState__c,
                          componentAsset__c,
                          componentAccountId__c,
                          componentComponentSN__c,
                          componentServicePartNumber__c,
                          componentType__c, componentDescription__c
                          From component__c where componentServicePartNumber__c ='SR-HDD-2TB' AND componentAsset__c=:asset.Id LIMIT 1 FOR UPDATE];
         //System.assertEquals('Com-3258856',       testComponent1.Name);
         
         //Create test RMA
         rma = [Select Id,Name,
                rmaCaseNumber__c,
                rmaDiskShelfAsset__c,
                rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaDeliveryDateTime__c,
                rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c,rmaFailedPart__c,rmaAssetSla__c,
                rmaAssetNrdIsInEffect__c,rmaPartIsAShipOnlyPart__c,rmaShowReturnSectionsAlways__c
                From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY NAME DESC LIMIT 1];  
         
         System.assertNotEquals(null,rma.Id);
         System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
         System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
         System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
         System.assertEquals('Component',rma.rmaSelection__c);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingDetailV2 rmaC = new rmav2ExtensionsWithSharingDetailV2(sc);
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', rma.Id);
        Test.setCurrentPage(pageRef);
        rmaC.cloneRMA();
        test.stopTest();
    
    }*/
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
                        rmaIsNBDOverriden__c,rmaFailedPart__c,
                        rmaShowReturnSectionsAlways__c
                        FROM   RMAv2__c];
        testData.rma.Id = null;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetailV2 rma = new rmav2ExtensionsWithSharingDetailV2(sc);
        
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
                        rmaIsNBDOverriden__c,rmaFailedPart__c,
                        rmaShowReturnSectionsAlways__c
                        FROM   RMAv2__c];
        
        //Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetailV2 rma = new rmav2ExtensionsWithSharingDetailV2(sc);
        
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
                        rmaIsNBDOverriden__c,rmaFailedPart__c,
                        rmaShowReturnSectionsAlways__c
                        FROM   RMAv2__c];
        
        //Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetailV2 rma = new rmav2ExtensionsWithSharingDetailV2(sc);
        
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
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        Test.startTest();
        testData.insertRMA01();
        
        testData.asset.SLA__c = null;
        update testData.asset;
        Test.stopTest();
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
                        rmaIsNBDOverriden__c,rmaFailedPart__c,
                        rmaShowReturnSectionsAlways__c
                        FROM   RMAv2__c];
        
        Schema.DescribeSObjectResult r = RMAv2__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        testData.rma.Id = keyPrefix + 'S0000001dHFB';
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testData.rma);
        rmav2ExtensionsWithSharingDetailV2 rma = new rmav2ExtensionsWithSharingDetailV2(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', testData.rma.Id);
        Test.setCurrentPage(pageRef);
        
        rma.deleteRMA();
        
        List<RMAv2__c> lstRma = [SELECT Id  FROM   RMAv2__c];  
        System.assertEquals(1,lstRma.size());
        
        
        
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
        rmav2ExtensionsWithSharingDetailV2 newRma = new rmav2ExtensionsWithSharingDetailV2(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', String.valueOf(rma.Id));
        Test.setCurrentPage(pageRef);
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        newRma.getShipmentLabelDetails();
        newRma.getOpenShipmentStatus();
        newRma.getSubmitRMALabel();
        newRma.getDraftShipmentStatus();
        newRma.getRenderEFAPriority();
        newRma.submitRMA();
        
        system.debug('SOQL Limit ===>'+Limits.getqueries());
        Test.stopTest();
         RMAv2__History rmaHistory = [select ParentId  From RMAv2__History limit 1];
        RMAv2__c rma2 = [Select Id,Name,
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
                        rmaIsNBDOverriden__c,rmaFailedPart__c,
                         rmaShowReturnSectionsAlways__c
                   From RMAv2__c where id = :rmaHistory.ParentId];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(rma2);
        rmav2ExtensionsWithSharingDetailV2 newRma2 = new rmav2ExtensionsWithSharingDetailV2(sc2);
        
        PageReference pageRef2 = Page.rmaV2DetailPageV2;
        pageRef2.getParameters().put('id', String.valueOf(rma2.Id));
        Test.setCurrentPage(pageRef2);
        newRma2.getHistories();
    }
    
    
    
   /* static testMethod void rmaOnsite_NRD()
    { 
        

        
        /*TestData      testData;
        testData = new TestData();

        testData.insertComponents();
        
        testData.insertRMA02();*/

      /*  Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        SR_Meta_Data__c srMetaData;
        EOAPart__c eoaPart;
        Component__c testComponent1;
        Component__c testComponent2;
        Component__c testComponent3;
        Component__c testComponent4;
       
                    
            // Create test account
            insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
            System.assertNotEquals(null,              account.Id);
            System.assertEquals('TEST-ACCOUNT', account.Name);
            System.assertEquals('Account RMA SHI',    account.accountRmaShi__c);
            
            
            // Create test contact
            insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                         AccountId = account.Id,
                                         Email='test@gmail.com',
                                         Phone='999999999');
            System.assertNotEquals(null,                        contact.Id);
            System.assertEquals('TEST-CONTACT-LAST-NAME', contact.LastName);
            System.assertEquals(account.Id,            contact.AccountId);
            System.assertEquals('test@gmail.com',            contact.Email);
            System.assertEquals('999999999',            contact.Phone);
            
            // Create test asset
            insert asset = new Asset(Name = 'TEST-ASSET',
                                     AccountId = account.Id,
                                     ContactId = contact.Id,
                                     SLA__c = 'Premium 4 Hour Onsite',
                                     assetRmaShi__c = 'Asset RMA SHI',
                                     assetNrdEndDate__c = Date.today() + 10,
									 HPE_Serial_Number__c ='AA000000NIM');
            
            System.assertNotEquals(null,                      asset.Id);
            System.assertEquals('TEST-ASSET',                  asset.Name);
            System.assertEquals(account.Id,                 asset.AccountId);
            System.assertEquals(contact.Id,                 asset.ContactId);
            System.assertEquals('Premium 4 Hour Onsite',                     asset.SLA__c);
            System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
            
            // Create test case
            insert aCase = new Case(AccountId = account.Id,
                                    AssetId   = asset.Id,
                                    ContactId = contact.Id,
                                    Subject = 'TEST-CASE-SUBJECT');
            
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            System.assertEquals(contact.Id,       aCase.ContactId);
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
            
            insert testComponent3 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-SDD-1TB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='13579',
                                                     componentType__c='SSD',
                                                     componentDescription__c='SSD');
        
        Test.startTest();
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent3.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component',
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
        
        
        rma = [SELECT Id,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaFaRequired__c,
                        rmaShipmentAccountName__c,
                        rmaShowReturnSectionsAlways__c,
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
                        rmaAssetSla__c
                        FROM   RMAv2__c];
        
        Test.stopTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingDetailV2 rma1 = new rmav2ExtensionsWithSharingDetailV2(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', rma.Id);
        Test.setCurrentPage(pageRef);
        
        rma1.getOpenShipmentStatus();
        rma1.getSubmitRMALabel();
        rma1.getDraftShipmentStatus();
        rma1.getRenderEFAPriority();
        rma1.submitRMA();
        rma1.cancelRMA();
        
        //rma1.getHistories();

        
        System.assertEquals(false,rma1.hideOnSiteSections);
        System.assertEquals(true, rma1.hideReturnSections);
        
        
        
        
    }*/
    
    
    static testMethod void rmaHistory_Tracking()
    { 
        

        
        /*TestData      testData;
        testData = new TestData();
        
        
        testData.insertComponents();
        
        testData.insertRMA02();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
       
        update testData.rma;*/
        /*system.debug('===inside method====');
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        SR_Meta_Data__c srMetaData;
        EOAPart__c eoaPart;
        Component__c testComponent1;
        Component__c testComponent2;
        Component__c testComponent3;
        Component__c testComponent4;
        Component__c testComponent5;
       
        
            
            // Create test account
            insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
           
            system.debug('===Account Inserted====');
            
            // Create test contact
            insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                         AccountId = account.Id,
                                         Email='test@gmail.com',
                                         Phone='999999999');
            
            system.debug('===Contact Inserted====');
            // Create test asset
            
            insert asset = new Asset(Name = 'TEST-ASSET',
                                     AccountId = account.Id,
                                     ContactId = contact.Id,
                                     SLA__c = 'Premium 4 Hour Onsite',
                                     assetRmaShi__c = 'Asset RMA SHI', assetNrdEndDate__c = Date.today() + 10);
            
            
            system.debug('===Asset inserted====');
            // Create test case
            insert aCase = new Case(AccountId = account.Id,
                                    AssetId   = asset.Id,
                                    ContactId = contact.Id,
                                    Subject = 'TEST-CASE-SUBJECT');
            
           system.debug('===case inserted====');
            
            insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                    abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                    abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                    abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                    abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                    abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                    abPostalCode__c='1000',
                                                    abDescription__c='Asset Install Address 1');
            
            system.debug('===address book inserted====');
        
       /*insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='123456',
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Chassis');
            system.debug('===component1 inserted====');
            
            insert testComponent2 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-USB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='654321',
                                                     componentType__c='USB',
                                                     componentDescription__c='USB');
            system.debug('===component2 inserted====');
            insert testComponent3 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-USB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='0654321',
                                                     componentType__c='USB',
                                                     componentDescription__c='USB');
            system.debug('===component3 inserted====');
            insert testComponent4 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-SDD-1TB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='13579',
                                                     componentType__c='SSD',
                                                     componentDescription__c='SSD');
            system.debug('===component4 inserted====');
            /*insert testComponent5 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-Bezel-CS-series',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='02468',
                                                     componentType__c='BEZEL',
                                                     componentDescription__c='BEZEL');
           system.debug('===component5 inserted====');
            Test.startTest();
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent4.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component',
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
        
        system.debug('===RMA inserted====');
            rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        	rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        	rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
       		rma.rmaGateKeeperStatus__c = 'Automatic';
        
        
        update rma;
        Test.stopTest();
         system.debug('===RMA Updated====');
            
        
        rma = [SELECT Id,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaFaRequired__c,
                        rmaShipmentAccountName__c,
                        rmaShowReturnSectionsAlways__c,
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
                        rmaAssetSla__c
                        FROM   RMAv2__c];
        
          system.debug('===RMA Queried====');
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingDetailV2 rma1 = new rmav2ExtensionsWithSharingDetailV2(sc);
        
         system.debug('===Detail Page initialization====');
      
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', rma.Id);
        Test.setCurrentPage(pageRef);
        
        
         system.debug('===Detail Page Before Methods====');
        
        rma1.getOpenShipmentStatus();
         system.debug('===Detail Page after 1st Method====');
        rma1.getSubmitRMALabel();
        system.debug('===Detail Page after 2st Method====');
        rma1.getDraftShipmentStatus();
        system.debug('===Detail Page after 3st Method====');
        rma1.getRenderEFAPriority();
        system.debug('===Detail Page after 4st Method====');
        rma1.submitRMA();
        system.debug('===Detail Page after 5st Method====');
        rma1.cancelRMA();
        system.debug('===Detail Page after 6st Method====');
        //rma1.fakeMethod();
        rma1.getHistories();
        system.debug('===Detail Page after 7st Method====');
        
   
        System.assertEquals(false,rma1.hideOnSiteSections);
        System.assertEquals(true, rma1.hideReturnSections);
         
        */
        
        
    }
    

}