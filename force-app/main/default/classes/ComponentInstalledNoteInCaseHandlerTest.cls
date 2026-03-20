@isTest
public class ComponentInstalledNoteInCaseHandlerTest {
    class TestData{
        Account account;
        Account account1;
        Contact contact;
        Product2 prd;
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
            
            //Create test product2
            insert prd = new Product2(Name = 'SSD Storage Array',
                                        ProductCode='HF600',
                                        Product_Type__c='Hardware',
                                        Product_Type_2__c='SAN Storage ArrayS',
                                        Controller_Code__c='CS2001',
                                        Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                        Family='SAN Storage Array');
            
            // Create test asset
            insert asset = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = prd.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',ContactId = contact.Id);
        
            
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
            insert srMetaData = new SR_Meta_Data__c(srPart__c='SR-CHASSIS-3U-SMC',srModelNumbers__c='TestModel,Testmodel1', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
            
            
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
                                                     componentType__c='Controller',
                                                     componentDescription__c='Controller');
            
            insert testComponent2 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMCU',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='123456',
                                                     componentType__c='Controller',
                                                     componentDescription__c='Controller',
                                                     SR_MetaData__c =srMetaData.id);
            
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
                                      rmaOutgoingShipmentStatus__c = 'DRAFT-10: Waiting to order',
                                      rmaOutgoingShipmentCarrier__c = 'DHL',
                                      rmaOutgoingShipmentDepot__c = 'TEST-DEPOT',
                                      rmaOutgoingShipmentPartSn__c = 'TestCompSN',
                                      rmaOutShipDateTimeDelivered__c = System.now(),
                                      rmaOutShipDateTimeEta__c = System.now(),
                                     rmaTransmitRmaShisWithOrder__c = 'Asset RMA SHI');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
    }
    static testMethod void componentInstalledTest(){
        TestData      testData;
        testData = new TestData(); 
        Test.startTest();
        testData.insertComponents();
        testData.insertRMA01();
        testData.testComponent1.Sub_State__c = 'Online';
        testData.testComponent1.componentComponentSN__c = 'SFHSFHSF';
        update testData.testComponent1;
        Test.stopTest();
    }
    static testMethod void componentInstalledTest1(){
        
        TestData      testData;
        testData = new TestData(); 
        
        testData.insertComponents();
        Component__c testComponent6;
        insert testComponent6 = new component__c(componentAccountId__c = testData.account.Id,
                                                 componentAsset__c = testData.asset.Id,
                                                 componentServicePartNumber__c='SR-CONT-CS220',
                                                 componentState__c = 'Shipped',
                                                 Sub_State__c='Unknown',
                                                 componentComponentSN__c='TestCompSN',
                                                 componentType__c='Controller',
                                                 componentDescription__c='Controller');
        Asup_Components__c asupComp1;
        insert asupComp1 = new Asup_Components__c(asupComponentAsset__c = testData.asset.Id,
                                                  asupComponentSN__c = 'TestCompSN');
        
        Test.startTest();
        testData.insertRMA01();
        /*testData.rma.rmaStatus__c = 'Open';
testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
testData.rma.rmaGateKeeperStatus__c = 'Automatic';
update testData.rma;
testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-30: Shipped, waiting for delivery';
update testData.rma;
testData.rma.rmaOutgoingShipmentStatus__c = 'CLOSED-10: Delivered';
update testData.rma;*/
        testComponent6.Sub_State__c = 'Online';
        update testComponent6;
        test.stopTest();
        /*testData.testComponent1.Sub_State__c = 'Online';
update testData.testComponent1;*/
    }
   
      
    /*static testMethod void componentCaseOwnerIsQueue(){
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
Asup_Components__c asupComp1;
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
assetRmaShi__c = 'Asset RMA SHI',
lastAsupDirAccountName__c = 'TestAccName',
lastAsupDirArraySn__c = 'TestAsupSN',
lastAsupDirTimestamp__c = 'TestTimeStamp');

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
Subject = 'TEST-CASE-SUBJECT',
OwnerId = UserInfo.getUserId());

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

insert testComponent1 = new component__c(componentAccountId__c = account.Id,
componentAsset__c = asset.Id,
componentServicePartNumber__c='SR-HDD-360-GB',
componentState__c = 'Shipped',
Sub_State__c='Unknown',
componentComponentSN__c='123456',
componentType__c='HDD',
componentDescription__c='HDD');
insert asupComp1 = new Asup_Components__c(asupComponentAsset__c = asset.Id,
asupComponentSN__c = 'TestCompSN');



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
test.startTest(); 
rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
rma.rmaGateKeeperStatus__c = 'Automatic';
update rma;



rma.rmaOutgoingShipmentStatus__c = 'CLOSED-10: Delivered';
rma.rmaOutgoingShipmentCarrier__c = 'TestCarrier';
rma.rmaOutgoingShipmentDepot__c = 'TestDepot';
rma.rmaOutgoingShipmentTrackingNumber__c = 'Test123';
rma.rmaOutgoingShipmentPartSn__c = 'TestCompSN';
rma.Outgoing_Shipment_Status_Delivered_Time__c = System.now();
update rma;
test.stopTest();
testComponent1.componentState__c = 'Shipped';
testComponent1.Sub_State__c = 'Online';
update testComponent1;
}*/
}