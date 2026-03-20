@isTest
public class rmaTriggerComponentTest {
    
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
                                     SLA__c = 'Premium',
                                     assetRmaShi__c = 'Asset RMA SHI');
            
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
            
            insert testComponent2 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-USB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='654321',
                                                     componentType__c='USB',
                                                     componentDescription__c='USB');
            
            insert testComponent3 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-HDD-1TB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='13579',
                                                     componentType__c='HDD',
                                                     componentDescription__c='HDD');
            
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
                                      rmaSelection__c = 'Component');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        void insertRMA02()
        {
            
            insert account1 = new Account(Name = 'TEST-ACCOUNT1',accountRmaShi__c='Account RMA SHI');
            System.assertNotEquals(null,              account1.Id);
            System.assertEquals('TEST-ACCOUNT1', account1.Name);
            System.assertEquals('Account RMA SHI',    account1.accountRmaShi__c);
            
            testComponent2.componentAccountId__c =  account1.Id;
            update testComponent2;
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent2.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent2.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        void insertRMA03()
        {
            
            testcomponent2.componentState__c = 'Shipped';
            testcomponent2.Sub_State__c = 'RMA in Progress';
            update testComponent2;
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent2.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent2.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        void insertRMA04()
        {
            
            testcomponent2.componentState__c = 'Returned';
            testcomponent2.Sub_State__c = null;
            update testComponent2;
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent2.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent2.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        void insertRMA05()
        {
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent1.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component',
                                      rmaCustomerFaRequired__c=true);  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        
        void insertRMA06()
        {
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Asset');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Asset',rma.rmaSelection__c);             
        }
        
        void insertRMA07()
        {
            insertMetaData();
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent4.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component',
                                     rmaComponentIsAShipOnlyPart__c = true);  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent4.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);   
        }
        
        void insertsrMetData()
        {
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1200W',
                                                    srType__c = 'PWR(power supply)',
                                                    srDescription__c='Service Power Supply Unit for CS Arrays, 1200W',
                                                    srShippingProvider__c='Flash');
        }
        
        void insertEOAPArt()
        {
            insert eoaPart = new EOAPart__c(eoaPartName__c = 'SR-PWR-1200W',
                                            eoaSuggestedFullSystemReplacement__c = 'SR-PWR-1500W');
        }
        
        void insertRMA08()
        {
            insertsrMetData();
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmasrFlatList__c = srMetaData.Id,
                                      rmaSelection__c = 'Flat List');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals('Flat List',rma.rmaSelection__c);   
        }
        
        void insertRMA09()
        {
            insertsrMetData();
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmasrFlatList__c = srMetaData.Id,
                                      rmaSelection__c = 'Flat List');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Flat List',rma.rmaSelection__c);   
        }
        
        void insertRMA10()
        {
            insertsrMetData();
            insertEOAPArt();
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmasrFlatList__c = srMetaData.Id,
                                      rmaSelection__c = 'Flat List');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Flat List',rma.rmaSelection__c);   
        }
        
        
        void insertRMA11()
        {
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1200W',
                                                    srType__c = 'PWR(power supply)',
                                                    srDescription__c='Service Power Supply Unit for CS Arrays, 1200W',
                                                    srShippingProvider__c='Flash');
            
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1500W',
                                                    srType__c = 'PWR(power supply)',
                                                    srDescription__c='Service Power Supply Unit for CS Arrays, 1200W',
                                                    srShippingProvider__c='Nimble');
            
            
            insert eoaPart = new EOAPart__c(eoaPartName__c = 'SR-PWR-1200W',
                                            eoaSuggestedFullSystemReplacement__c = 'SR-PWR-1500W');
            
            
            
            insert testComponent4 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-PWR-1200W',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='02468',
                                                     componentType__c='PWR(power supply)',
                                                     componentDescription__c='Service Power Supply Unit for CS Arrays, 1200W');
            
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent4.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent4.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);   
        }
        
               
        
        void insertRMA12()
        {
            
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1200W',
                                                    srType__c = 'PWR(power supply)',
                                                    srDescription__c='Service Power Supply Unit for CS Arrays, 1200W',
                                                    srShippingProvider__c='Nimble');
            
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1500W',
                                                    srType__c = 'PWR(power supply)',
                                                    srDescription__c='Service Power Supply Unit for CS Arrays, 1200W',
                                                    srShippingProvider__c='Flash');
            
            insert eoaPart = new EOAPart__c(eoaPartName__c = 'SR-PWR-1200W',
                                            eoaSuggestedFullSystemReplacement__c = 'SR-PWR-1500W');
            
            
            insert testComponent4 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-PWR-1200W',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='02468',
                                                     componentType__c='PWR(power supply)',
                                                     componentDescription__c='Service Power Supply Unit for CS Arrays, 1200W');
            
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent4.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent4.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);   
        }
        
        void insertMetaData()
        {
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-Bezel-CS-series',
                                                    srType__c = 'BEZEL',
                                                    srShipOnly__c = true,
                                                    srDescription__c='Service',
                                                    srShippingProvider__c='Nimble');
        }
        
    }
    
    
    static testMethod void rma_Open_Component_WithOutException() {
        
        
        TestData      testData;
        testData = new TestData();
        
        testData.insertComponents();
        testData.insertRMA01();
        Test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        
        
        update testData.rma;
        
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where Id=:testData.testComponent1.Id];
        System.assertEquals(1,components.size());
        System.assertEquals('Shipped',components[0].componentState__c);
        System.assertEquals('RMA in Progress',components[0].Sub_State__c);
        //System.assertEquals(null,components[0].componentException__c);
        Test.stopTest();
    }
    
    static testMethod void rma_Open_Component_WithException01() {
        
        
        TestData      testData;
        testData = new TestData();
        
        testData.insertComponents();
        
        testData.insertRMA02();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        Test.startTest();
        update testData.rma;
        Test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where Id=:testData.testComponent2.Id];
        System.assertEquals(1,components.size());
        System.assertEquals('Shipped',components[0].componentState__c);
        System.assertEquals('RMA in Progress',components[0].Sub_State__c);
        //System.assertEquals('RMA initiated for component not belonging to the account identified on the RMA',components[0].componentException__c);
         
    }
    
    static testMethod void rma_Open_Component_WithException02() {
        
        TestData      testData;
        testData = new TestData();
        
        testData.insertComponents();
        testData.insertRMA03();
        Test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        
        update testData.rma;
        Test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where Id=:testData.testComponent2.id];
        System.assertEquals(1,components.size());
        System.assertEquals('Shipped',components[0].componentState__c);
        System.assertEquals('RMA in Progress',components[0].Sub_State__c);
        System.assertEquals('RMA is already created for a given component',components[0].componentException__c);
        
        
    }
    
    static testMethod void rma_Open_Component_WithException03() {
        
        TestData      testData;
        testData = new TestData();
        
        testData.insertComponents();
        testData.insertRMA04();
        Test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        
        update testData.rma;
         Test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where Id=:testData.testComponent2.id];
        System.assertEquals(1,components.size());
        System.assertEquals('Shipped',components[0].componentState__c);
        System.assertEquals('RMA in Progress',components[0].Sub_State__c);
       // System.assertEquals('RMA initiated on component not shipped to the customer',components[0].componentException__c);
        
       
        
    }
    
    static testMethod void rma_Component_Return2Closed10Delivered_Component_Returned() {
        
        TestData      testData;
        testData = new TestData();
        Test.startTest();
        testData.insertComponents();
        testData.insertRMA01();
        
        testData.rma.rmaRetShip2Status__c = 'CLOSED-10: Delivered';
        
        update testData.rma;
        Test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where Id=:testData.testComponent1.Id];
        System.assertEquals(1,components.size());
        System.assertEquals('Returned',components[0].componentState__c);
        System.assertEquals(null,components[0].Sub_State__c);
        
        
        
    }
    
    static testMethod void rma_Component_Return2Closed10Delivered_Component_FARequired() {
        
        TestData      testData;
        testData = new TestData();
        Test.startTest();
        testData.insertComponents();
        testData.insertRMA05();
        
        testData.rma.rmaRetShip2Status__c = 'CLOSED-10: Delivered';
        
        update testData.rma;
        Test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where Id=:testData.testComponent1.Id];
        System.assertEquals(1,components.size());
        System.assertEquals('Returned for FA',components[0].componentState__c);
        System.assertEquals(null,components[0].Sub_State__c);
        
        
    }
    
    static testMethod void rma_Component_outgoingStatusClosed10Delivered_Chassis_Replacement() {
        
       
        TestData      testData;
        testData = new TestData();
        
        testData.insertComponents();        
        testData.insertRMA01();
        List<component__c> components;
        Test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutgoingShipmentDepot__c  = 'ACV-003 (Arcata, CA, United States)';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'Aeronet';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '753159';
        testData.rma.rmaOutgoingShipmentPartSn__c = 'AA-100000';
        testData.rma.rmaFulfilledPartNumber__c = 'SR-CHASSIS-3U-SMC';
        testData.rma.rmaOutgoingShipmentAfterShipStatus__c = 'picked up';
        //update testData.rma;
        
        
        update testData.rma;
        Test.stopTest();
        //Old component must stay with old Asset
        components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c from Component__c where Id=:testData.testComponent1.Id];
        System.assertEquals(1,components.size());
        System.assertEquals(testData.asset.Id,components[0].componentAsset__c);
        
        
        List<Asset> assets = [Select Id from Asset where Name='AA-100000'];//New created Asset for Chassis type
        System.assertNotEquals(null,assets[0].Id);
        
        //All the Existing asset moves to Newly created asset for Chassis type
        components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c from Component__c where componentAsset__c=:assets[0].Id];
        System.assertEquals(4,components.size());
        
        
        //New component must be created with New Asset with (rmaOutgoingShipmentPartSn__c and rmaFulfilledPartNumber__c)
        components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c from Component__c where componentComponentSN__c='AA-100000' and componentServicePartNumber__c='SR-CHASSIS-3U-SMC'];
        System.assertEquals(1,components.size());
        System.assertEquals(assets[0].Id,components[0].componentAsset__c);
        
        
        
    }
    
    
    /*static testMethod void rma_Component_outgoingStatusClosed10Delivered_Part_Creation_OldPart_Disposed() {
        
        
        TestData      testData;
        testData = new TestData();      
        testData.insertComponents();
        testData.insertRMA07();
        List<component__c> components;
        
       
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        Test.startTest();
        update testData.rma;
        
        testData.rma.rmaOutgoingShipmentStatus__c =  'CLOSED-10: Delivered';
        testData.rma.rmaOutgoingShipmentDepot__c  = 'ACV-003 (Arcata, CA, United States)';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'Aeronet';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '753159';
        testData.rma.rmaOutgoingShipmentPartSn__c = '0123456789';
        testData.rma.rmaFulfilledPartNumber__c = 'SR-Bezel-CS-series';
        update testData.rma;
        
        Test.stopTest();
        
        //Old component must be disposed
        components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c from Component__c where Id=:testData.testComponent4.Id];
        System.assertEquals(1,components.size());
        System.assertEquals(testData.asset.Id,components[0].componentAsset__c);
        System.assertEquals('Disposed',components[0].componentState__c);
        System.assertEquals(null,components[0].Sub_State__c);
        
        //New component must be created with for the Asset with (rmaOutgoingShipmentPartSn__c and rmaFulfilledPartNumber__c)
        components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c from Component__c where componentComponentSN__c='0123456789' and componentServicePartNumber__c='SR-Bezel-CS-series'];
        System.assertEquals(1,components.size());
        
        
        
    }*/
    
    
    static testMethod void rma_FullRMA_Return2Closed10Delivered() {
        
        
        TestData      testData;
        testData = new TestData();
        Test.startTest();
        testData.insertComponents();
        testData.insertRMA06();
        
        testData.rma.rmaRetShip2Status__c = 'CLOSED-10: Delivered';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        Test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where componentState__c='Returned'];
        System.assertEquals(4,components.size());
        
        
    }
    
    static testMethod void rma_Open_FlatList_WithoutDiskShelf_NewComponent() {
        
        TestData      testData;
        testData = new TestData();
        
        testData.insertRMA08();
        Test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        Test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c,componentAccountId__c from Component__c where componentServicePartNumber__c='SR-PWR-1200W'];
        System.assertEquals(1,components.size());
        System.assertEquals(testData.account.Id,components[0].componentAccountId__c);
        System.assertEquals(testData.asset.Id,components[0].componentAsset__c);
        
        
        
    }
    
    static testMethod void rma_Open_FlatList_WithDiskShelf_NewComponent_SRFlastPart() {
        
        TestData      testData;
        testData = new TestData();
        
        testData.insertRMA09();
        Test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        Test.stopTest();
        List<RMAv2__c> rmas = [SELECT Id,rmaPart__c FROM RMAv2__c];
        System.assertEquals(1,rmas.size());
        System.assertEquals('[SR-PWR-1200W]',rmas[0].rmaPart__c);
        
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c,componentAccountId__c from Component__c where componentServicePartNumber__c='SR-PWR-1200W'];
        System.assertEquals(1,components.size());
        System.assertEquals(testData.account.Id,components[0].componentAccountId__c);
        System.assertEquals(testData.asset.Id,components[0].componentAsset__c);
        
        
        
        
    }
    
    static testMethod void rma_Open_FlatList_WithDiskShelf_EOAActive_SRFlashPart() {
        
        
        TestData      testData;
        testData = new TestData();
       
        testData.insertRMA10();
        Test.startTest();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        Test.stopTest();
        List<RMAv2__c> rmas = [SELECT Id,rmaPart__c FROM RMAv2__c];
        System.assertEquals(1,rmas.size());
        System.assertEquals('[SR-PWR-1500W]',rmas[0].rmaPart__c);
        
        
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c,componentAccountId__c from Component__c where componentServicePartNumber__c='SR-PWR-1500W'];
        System.assertEquals(1,components.size());
        System.assertEquals(testData.account.Id,components[0].componentAccountId__c);
        System.assertEquals(testData.asset.Id,components[0].componentAsset__c);
        
        
        
        
    }
    
    
    
    static testMethod void rma_Open_Component_EOAActive_Nimble_Part() {
        
        TestData      testData;
        testData = new TestData();
        
        testData.insertRMA11();
        
        Test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        Test.stopTest();
        List<RMAv2__c> rmas = [SELECT Id,rmaPart__c FROM RMAv2__c];
        System.assertEquals(1,rmas.size());
        System.assertEquals('(SR-PWR-1500W)',rmas[0].rmaPart__c);
        
        
    }
    
    
    static testMethod void rma_Open_Component_EOAActive_Flash_Part() {
        
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        testData.insertRMA12();
        Test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        Test.stopTest();
        List<RMAv2__c> rmas = [SELECT Id,rmaPart__c FROM RMAv2__c];
        System.assertEquals(1,rmas.size());
        System.assertEquals('[SR-PWR-1500W]',rmas[0].rmaPart__c);
        
        
    }
    static testMethod void rmadeleteOpenRMA() {
        
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
                                     SLA__c = 'Premium',
                                     assetRmaShi__c = 'Asset RMA SHI');
            
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
        
        insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='123456',
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Chassis');
        
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent1.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component'); 
        Test.startTest();
        rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaGateKeeperStatus__c = 'Automatic';
        update rma;
        Test.stopTest();
        try{
            Delete rma;
        }
        Catch(DmlException ex){
            
        }
        
        
        
    }
    
}