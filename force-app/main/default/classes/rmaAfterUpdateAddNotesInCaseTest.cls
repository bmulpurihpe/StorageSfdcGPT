@isTest
public class rmaAfterUpdateAddNotesInCaseTest {
    class TestData{
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
        }
        void insertRMA01()
        {
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent1.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component',
                                      Asset_Date_and_Time__c = '1/17/2017 11:51 AM',
                                      rmaAssetLocalDateTime__c = '1/17/2017 12:00 AM',
                                      rmaLatitude__c = '37.4308503',
                                      rmaLongitude__c = '-121.95299920000002',
                                      rmaTimeZoneActualOffset__c = '-28800 (-8 hours)',
                                      rmaTimeZoneDSTOffset__c = '0 (0 hours)',
                                      rmaTimeZoneName__c = 'Pacific Standard Time',
                                      rmaOutShipDateTimeEta__c = System.now());  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
    }
   /* static testMethod void rmaPartShipped(){
        
        TestData      testData;
        
        testData = new TestData();         
        testData.insertComponents();
        
        testData.insertRMA01();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        
        
        Test.startTest();
        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        //testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-30: Shipped, waiting for delivery';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'FedEx';
        testData.rma.rmaOutgoingShipmentDepot__c = 'BFL-001 (Bakersfield, CA, United States)';
        testData.rma.rmaOutgoingShipmentPartSn__c = 'AF-000001';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '3126549876454';
        update testData.rma;
        Test.stopTest();
    }*/
    static testMethod void rmaDeliveryETAChangeTest(){
        TestData      testData;
        Test.startTest();
        testData = new TestData(); 
        
        testData.insertComponents();
        testData.insertRMA01();
        Test.stopTest();
        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutShipDateTimeEta__c = System.now().addDays(2);
        update testData.rma;
        
    }
   /* static testMethod void rmaPartDelivered(){
        TestData      testData;
        testData = new TestData(); 
        
        testData.insertComponents();
        testData.insertRMA01();
        
        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        Test.startTest();
        update testData.rma;
        
        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'CLOSED-10: Delivered';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'FedEx';
        testData.rma.rmaOutgoingShipmentDepot__c = 'BFL-001 (Bakersfield, CA, United States)';
        testData.rma.rmaOutgoingShipmentPartSn__c = 'AF-000001';
        testData.rma.rmaOutgoingShipmentAfterShipStatus__c = 'Delivered';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '3126549876454';
        update testData.rma;
        Test.stopTest();
        
    }*/
    static testMethod void rmaPartDeliveryException(){
        TestData      testData;
        testData = new TestData(); 
       
        testData.insertComponents();
        testData.insertRMA01();
        Test.startTest();
        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutgoingShipmentAfterShipStatus__c = 'Exception';
        update testData.rma;
        Test.stopTest();
        
    }
}