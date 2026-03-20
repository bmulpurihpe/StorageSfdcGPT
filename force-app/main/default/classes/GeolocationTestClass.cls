//Modified after error
@isTest
public class GeolocationTestClass {
    private static ID testAccountId;
    private static ID testAddressBookId;
    // ==================================================================================== createTestData
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
             Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        insert testProduct1;
            
            // Create test asset
            insert asset = new Asset(Name = 'TEST-ASSET',
                                     AccountId = account.Id,
                                     ContactId = contact.Id,
                                     SLA__c = 'Premium 4 Hour',
                                     HPE_Serial_Number__c ='AA000000NIM',
                                     assetRmaShi__c = 'Asset RMA SHI',
                                    Array_Controller__c = 'CS300',
                                    Product2Id = testProduct1.id,
                                Component_SKU_HPE__c = 'R4U28A');
            
            System.assertNotEquals(null,                      asset.Id);
            System.assertEquals('TEST-ASSET',                  asset.Name);
            System.assertEquals(account.Id,                 asset.AccountId);
            System.assertEquals(contact.Id,                 asset.ContactId);
            System.assertEquals('Premium 4 Hour',                     asset.SLA__c);
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
            
            insert testComponent2 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-USB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='0654321',
                                                     componentType__c='USB',
                                                     componentDescription__c='USB');
            
            insert testComponent3 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-SDD-1TB',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='13579',
                                                     componentType__c='SSD',
                                                     componentDescription__c='SSD');
            
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
    }   
    static testMethod void geolocTestDatav1(){
        Account account;
        Contact contact;
        AddressBook__c addressBook;
        /*Map<id, Location> depotsmaps = new map<id, Location>();
list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
for(depot__c depotsins : Depotsmap){
if(depotsins.depotLocation__c != null)
depotsmaps.put(depotsins.id, depotsins.depotLocation__c);
}*/
        List<depot__c> depots = new list<depot__c>();
        Location locins = Location.newInstance(37.2966853, -122.0975973);
        //depot__c depot;
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
        Map<id, Location> depotsmaps = new map<id, Location>();
        
        /*depot = new depot__c(Name                        = 'DEN-001',
depotProvider__c            = 'Nimble',
depotStockedFor4Hour__c     = 'Yes',
depotLocationDescription__c = 'Test depot DEN-001',
depotStreet1__c              = '1938 Junction Ave',
depotCity__c                 = 'San Jose',
depotState__c                = 'CA',
depotCountry__c              = 'UNITED STATES');*/
        
        depot__c depot = new depot__c();
        depot.Name = 'Test Depot';
        depot.depotProvider__c = 'Flash';
        depot.depotStockedFor4Hour__c = 'Yes';
        depot.depotLocationDescription__c = 'Test Desc';
        depot.depotCity__c = 'New York';
        depot.depotIsactive__c = TRUE;
        depot.Returns_Carrier__c = 'DHL';
        insert depot;
        
        depots.add(depot);
        depotsmaps.put(depot.Id, Location.newInstance(37.2966853, -122.0975973));
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depot.id);
        
        Map<id, string> Depotwithaddressdp = new map<id, string>();
        Depotwithaddressdp.put(depot.id, 'Suite 100, San Jose, CA, 95151, United States');
        map<id, map<id, Location>> depotsmapInside = new map<id, map<id, Location>>();
        map<string, Location> objectIdList = new map<string, Location>();
        map<id, boolean> Objectidbool = new map<id, boolean>();
        depotsmapInside.put(addressBook.id, depotsmaps);
        objectIdList.put(addressBook.id, Location.newInstance(37.2966853, -122.0975973));
        Objectidbool.put(addressBook.id, false);
        Geolocationaddress.geocodeAddress(Depotwithaddressdp, 'depot__c', Depotwithaddressdp, Depotwithaddressdp);
        //Geolocationaddress.addressDepotMap(depotsmaps, addressBook.id, Location.newInstance(37.2966853, -122.0975973), 'AddressBook__c', false);
        Map<id, id> depotRecNotIn150MilesRadius = new Map<id, id>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotNameToRMA = new Map<id, string>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotProviderToRMA = new Map<id, string>();
        Geolocationaddress.addressDepotMap(depotsmapInside, objectIdList, 'AddressBook__c', Objectidbool, depotRecNotIn150MilesRadius, depotRecNotIn150MilesRadiusDepotNameToRMA, depotRecNotIn150MilesRadiusDepotProviderToRMA);
        
    }
    static testMethod void rmaPremiumAsset4Hour()
    { // Create test account
        Account account;
        Contact contact;
        Asset   asset;
        AddressBook__c addressBook;
        /*Map<id, Location> depotsmaps = new map<id, Location>();
list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
for(depot__c depotsins : Depotsmap){
if(depotsins.depotLocation__c != null)
depotsmaps.put(depotsins.id, depotsins.depotLocation__c);
}*/
        depot__c depotrecord = new depot__c();
        depotrecord.Name = 'Test Depot';
        depotrecord.depotProvider__c = 'Flash';
        depotrecord.depotStockedFor4Hour__c = 'Yes';
        depotrecord.depotLocationDescription__c = 'Test Desc';
        depotrecord.depotCity__c = 'New York';
        depotrecord.depotIsactive__c = TRUE;
        depotrecord.Returns_Carrier__c = 'DHL';
        
        insert depotrecord;
        Map<id, Location> depotsmaps = new map<id, Location>();
        depotsmaps.put(depotrecord.id, Location.newInstance(37.2966853, -122.0975973));
        
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
        
        //list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depotrecord.id);
        
        // Create test asset
         Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        insert testProduct1;
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium 4 Hour',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetPartShipAddressBook__c = addressBook.Id,
                                 assetNearbyDepot__c = depotrecord.id,
                                 assetClosestShipDepot__c = depotrecord.id,
                                Array_Controller__c = 'CS300',
                                Product2Id = testProduct1.id,
                                Component_SKU_HPE__c = 'R4U28A');
        
        System.assertNotEquals(null,                      asset.Id);
        System.assertEquals('TEST-ASSET',                  asset.Name);
        System.assertEquals(account.Id,                 asset.AccountId);
        System.assertEquals(contact.Id,                 asset.ContactId);
        System.assertEquals('Premium 4 Hour',                     asset.SLA__c);
        System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
        Test.startTest();
        depotrecord.depotCountry__c = 'United States';
        update depotrecord;
        map<id, map<id, Location>> depotsmapInside = new map<id, map<id, Location>>();
        map<string, Location> objectIdList = new map<string, Location>();
        map<id, boolean> Objectidbool = new map<id, boolean>();
        depotsmapInside.put(asset.id, depotsmaps);
        objectIdList.put(asset.id, Location.newInstance(37.2966853, -122.0975973));
        Objectidbool.put(asset.id, false);
        Map<id, string> Depotwithaddressasset = new map<id, string>();
        Depotwithaddressasset.put(asset.id, 'Suite 100, San Jose, CA, 95151, United States');
        
        Map<id, id> depotRecNotIn150MilesRadius = new Map<id, id>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotNameToRMA = new Map<id, string>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotProviderToRMA = new Map<id, string>();
        try{
            Geolocationaddress.geocodeAddress(Depotwithaddressasset, 'Asset', Depotwithaddressasset, Depotwithaddressasset);
            //Geolocationaddress.addressDepotMap(depotsmaps, asset.id, Location.newInstance(37.2966853, -122.0975973), 'Asset', false);
            Geolocationaddress.addressDepotMap(depotsmapInside, objectIdList, 'Asset', Objectidbool, depotRecNotIn150MilesRadius, depotRecNotIn150MilesRadiusDepotNameToRMA, depotRecNotIn150MilesRadiusDepotProviderToRMA);
        }
        catch(Exception e) {
            
        }
        Test.stopTest();
    }  
    static testMethod void rmaInsertWithOutOfCoverage()
    { 
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Component__c testComponent2;
        Depot__c depot;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
         Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        insert testProduct1;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 assetPartShipAddressBook__c = addressBook.Id,
                                 assetShipmentAddressDepot__c = 'TEST',
                                 SLA__c = 'Premium 4 Hour',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                Array_Controller__c = 'CS300',
                                Product2Id = testProduct1.id,
                                Component_SKU_HPE__c = 'R4U28A');
        
        Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
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
        
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent1.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component'); 
        Test.stopTest();
        
    }
    static testMethod void rmaInsertWithOutOfCoveragePhilippines()
    { 
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Component__c testComponent2;
        
        Depot__c depot = new Depot__c();
        depot.Name = 'Test';
        depot.depotStockedFor4Hour__c = 'Yes';
        depot.depotIsactive__c = TRUE;
        depot.depotProvider__c = 'Flash';
        depot.depotLocationDescription__c = 'Test Desc';
        depot.Returns_Carrier__c = 'DHL';
        insert depot;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='Philippines',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depot.Id);
        
        // Create test asset
         Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        insert testProduct1;
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 assetPartShipAddressBook__c = addressBook.Id,
                                 assetShipmentAddressDepot__c = 'TEST',
                                 SLA__c = 'Premium 4 Hour',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                Array_Controller__c = 'CS300',
                                Product2Id = testProduct1.id,
                                Component_SKU_HPE__c = 'R4U28A');
        
        Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
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
        
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent1.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component'); 
        Test.stopTest();
        
    }
    /*static testMethod void rmaInsert()
    { 
        
        TestData      testData;
        testData = new TestData();
        Test.startTest();
        testData.insertComponents();
        testData.insertRMA01();
        Test.stopTest();
    }*/
    static testMethod void rmaInsertSouthKoreaAB()
    { 
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Component__c testComponent2;
        Depot__c depot;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
       Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        insert testProduct1;
        
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium 4 Hour',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                Array_Controller__c = 'CS300',
                                Product2Id = testProduct1.id,
                                Component_SKU_HPE__c = 'R4U28A');
        Test.startTest();
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert depot = new depot__c(Name = 'Test Depot',
                                    depotProvider__c = 'Flash',
                                    depotStockedFor4Hour__c = 'Yes',
                                    depotLocationDescription__c = 'Test Desc',
                                    depotIsactive__c = true,
                                    depotCountry__c = 'South Korea',
                                    depotCity__c = 'New York',
                                   	Returns_Carrier__c = 'DHL');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='South Korea',
                                                abPostalCode__c='999-999',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depot.id);
        
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
        
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent1.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component'); 
        Test.stopTest();
        
    }
    static testMethod void rmaInsertSouthKoreaABWithOverrideAddress()
    { 
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Component__c testComponent2;
        Depot__c depot;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
         Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        insert testProduct1;
        
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium 4 Hour',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI', 
                                 assetShipmentAddressDepot__c = 'Test Depot',
                                Array_Controller__c = 'CS300',
                                Product2Id = testProduct1.id,
                                Component_SKU_HPE__c = 'R4U28A');
        Test.startTest();
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert depot = new depot__c(Name = 'Test Depot',
                                    depotProvider__c = 'Flash',
                                    depotStockedFor4Hour__c = 'Yes',
                                    depotLocationDescription__c = 'Test Desc',
                                    depotCity__c = 'New York',
                                    depotIsactive__c = true,
                                    depotCountry__c = 'South Korea',
                                   	Returns_Carrier__c = 'DHL');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='Test Country',
                                                abPostalCode__c='999-999',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depot.id);
        
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
        
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent1.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component',
                                  rmaOverrideShipmentCountry__c = 'South Korea'); 
        Test.stopTest();
        
    }
    static testMethod void depotUpdate()
    { // Create test account
        //list<depot__c> depotsmaps = new list<depot__c>();
        //list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
        depot__c depotrecord = new depot__c();
        depotrecord.Name = 'Test Depot';
        depotrecord.depotProvider__c = 'Flash';
        depotrecord.depotStockedFor4Hour__c = 'Yes';
        depotrecord.depotIsactive__c = TRUE;
        depotrecord.depotLocationDescription__c = 'Test Desc';
        depotrecord.depotCity__c = 'New York';
        depotrecord.Returns_Carrier__c = 'DHL';
        
        insert depotrecord;
        
        depotrecord.depotCountry__c = 'United States';
        
        update depotrecord;     
        /*for(depot__c depotsins : Depotsmap){
if(depotsins.depotLocation__c != null)
depotsins.depotStreet1__c = 'Test Street';
depotsmaps.add(depotsins);
}*/
        //update depotsmaps;
    }
    static testMethod void addressbookUpdate()
    { // Create test account
        AddressBook__c addressBook;
        Account account;
        Contact contact;
        list<depot__c> depotsmaps = new list<depot__c>();
        depot__c depotrecord = new depot__c();
        depotrecord.Name = 'Test Depot';
        depotrecord.depotProvider__c = 'Flash';
        depotrecord.depotStockedFor4Hour__c = 'Yes';
        depotrecord.depotLocationDescription__c = 'Test Desc';
        depotrecord.depotCity__c = 'Kawasaki-ku, Kawasaki, Kanagawa';
        depotrecord.depotIsactive__c = TRUE;
        depotrecord.depotCountry__c	 = 'Japan';
        depotrecord.Returns_Carrier__c = 'DHL';
        
        insert depotrecord;
        
        depot__c depotrecord1 = new depot__c();
        depotrecord1.Name = 'Test Depot 1';
        depotrecord1.depotProvider__c = 'TSC';
        depotrecord1.depotStockedFor4Hour__c = 'Yes';
        depotrecord1.depotLocationDescription__c = 'Test Desc';
        depotrecord1.depotCity__c = 'Kawasaki-ku, Kawasaki, Kanagawa';
        depotrecord1.depotIsactive__c = TRUE;
        depotrecord1.depotCountry__c	 = 'Japan';
        depotrecord1.Returns_Carrier__c = 'DHL';
        
        insert depotrecord1;
        //list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
        
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
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='Kawasaki-ku, Kawasaki, Kanagawa',
                                                abCountry__c='Japan',
                                                abPostalCode__c='210-0832',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depotrecord.id);
        addressBook.abStreet1__c = 'Test Install';
        update addressBook;
    }
    static void rmaUpdate()
    { 
        TestData      testData;
        testData = new TestData();
        Test.startTest();
        testData.insertComponents();
        testData.insertRMA02();
        Test.stopTest();
    }
    /*static testMethod void rmaUpdate()
{ 
TestData      testData;

testData = new TestData();

testData.insertComponents();
Test.startTest();
testData.insertRMA02();
Test.stopTest();
rmaStatusInformationsPreventRecursive.run = true;
CountRMAStatusInforPreventRecursive.run = true;
RecursiveTriggerRestrictiion.run = true;
testData.rma.rmaOverrideShipmentCity__c = 'Test City';

update testData.rma;

}*/
    //@isTest(SeeAllData=true)
    //static void rmaUpdateMain()
    //{ 
        /* Account account;
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
contact = [Select Id,LastName,Email,Phone, AccountId from Contact where AccountId=:account.Id LIMIT 1];
System.assertNotEquals(null,contact.Id);
System.assertEquals(account.Id,contact.AccountId);
System.assertEquals('Test Exafort', contact.LastName);

// Create test asset
// asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id LIMIT 1];
asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id LIMIT 1];
System.assertNotEquals(null,                      asset.Id);
System.assertEquals('AA-000000',                  asset.Name);
System.assertEquals(account.Id,                 asset.AccountId);
//System.assertEquals(contact.Id,                 asset.ContactId);
System.assertEquals('Premium',                     asset.SLA__c);

//Create test case
aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1 FOR UPDATE];
System.assertNotEquals(null,             aCase.Id);
System.assertEquals(account.Id,       aCase.AccountId);
System.assertEquals(asset.Id,         aCase.AssetId);
//System.assertEquals(contact.Id,       aCase.ContactId);
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
rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c,rmaOverrideShipmentCity__c
From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY NAME DESC LIMIT 1];  

System.assertNotEquals(null,rma.Id);
System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
System.assertEquals('Component',rma.rmaSelection__c);

Test.startTest();
rmaStatusInformationsPreventRecursive.run = true;
CountRMAStatusInforPreventRecursive.run = true;
RecursiveTriggerRestrictiion.run = true;
rma.rmaOverrideShipmentCity__c = 'Test City';
update rma;
Test.stopTest();
*/
        /*Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent3;
        Depot__c depot;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium 4 Hour',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                Array_Controller__c = 'AF1000');
        
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert depot = new depot__c(Name = 'Test Depot',
                                    depotProvider__c = 'Flash',
                                    depotStockedFor4Hour__c = 'Yes',
                                    depotLocationDescription__c = 'Test Desc',
                                    depotCity__c = 'New York',
                                   	Returns_Carrier__c = 'DHL');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='South Korea',
                                                abPostalCode__c='999-999',
                                                abDescription__c='Asset Install Address 1');
        //,
        //ab4HourDepot__c = depot.id
        
        insert testComponent3 = new component__c(componentAccountId__c = account.Id,
                                                 componentAsset__c = asset.Id,
                                                 componentServicePartNumber__c='SR-SDD-1TB',
                                                 componentState__c = 'Shipped',
                                                 Sub_State__c='Unknown',
                                                 componentComponentSN__c='13579',
                                                 componentType__c='SSD',
                                                 componentDescription__c='SSD');
        Test.startTest();
        /*insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent3.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component',
                                  rmaFaRequired__c = 'Engineering FA'
                                  
                                  //rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours',
                                  //rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site',
                                  //rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival',
                                  // rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site',      
                                  // rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET',
                                  //rmaOverrideOnsiteArrivalCity__c = 'TESTCITY',
                                  //rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222',
                                  //rmaOverrideOnsiteArrivalCountry__c = 'United States'
                                 );
        
        rma.rmaOverrideShipmentCity__c = 'Test City';
        rma.rmaOverrideShipmentPostalCode__c = '12345';
        update rma;*/
        
        
        //Test.stopTest();      
        /*TestData      testData;
testData = new TestData();
testData.insertComponents();
testData.insertRMA02();
Test.startTest();
rmaStatusInformationsPreventRecursive.run = true;
CountRMAStatusInforPreventRecursive.run = true;
RecursiveTriggerRestrictiion.run = true;
testData.rma.rmaOverrideShipmentCity__c = 'Test City';
update testData.rma;
Test.stopTest();*/
        /*RMAv2__c rma;
rmaUpdate();
rma = [Select Id,Name,
rmaCaseNumber__c,
rmaDiskShelfAsset__c,
rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaOverrideShipmentCity__c,
rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
From RMAv2__c];
rma.rmaOverrideShipmentCity__c = 'Test City';
update rma;*/
        //Test.stopTest();
    //}  
    static testMethod void rmaUpdateWithDepot()
    { 
        Account account;
        Contact contact;
        Asset   asset;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Case aCase;
        RMAv2__c rma;
        /*Map<id, Location> depotsmaps = new map<id, Location>();
list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
for(depot__c depotsins : Depotsmap){
if(depotsins.depotLocation__c != null)
depotsmaps.put(depotsins.id, depotsins.depotLocation__c);
}*/
        depot__c depotrecord = new depot__c();
        depotrecord.Name = 'Test Depot';
        depotrecord.depotProvider__c = 'Flash';
        depotrecord.depotStockedFor4Hour__c = 'Yes';
        depotrecord.depotLocationDescription__c = 'Test Desc';
        depotrecord.depotCity__c = 'New York';
        depotrecord.depotIsactive__c = TRUE;
        depotrecord.Returns_Carrier__c = 'DHL';
        
        insert depotrecord;
        Map<id, Location> depotsmaps = new map<id, Location>();
        depotsmaps.put(depotrecord.id, Location.newInstance(37.2966853, -122.0975973));
        
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
        
        //list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depotrecord.id);
        
        // Create test asset
         Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        insert testProduct1;
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium 4 Hour',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                 assetPartShipAddressBook__c = addressBook.Id,
                                 assetNearbyDepot__c = depotrecord.id,
                                 assetClosestShipDepot__c = depotrecord.id,
                                Array_Controller__c = 'CS300',
                                Product2Id = testProduct1.id,
                                Component_SKU_HPE__c = 'R4U28A');
        
        System.assertNotEquals(null,                      asset.Id);
        System.assertEquals('TEST-ASSET',                  asset.Name);
        System.assertEquals(account.Id,                 asset.AccountId);
        System.assertEquals(contact.Id,                 asset.ContactId);
        System.assertEquals('Premium 4 Hour',                     asset.SLA__c);
        System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
        
        insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                 componentAsset__c = asset.Id,
                                                 componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                 componentState__c = 'Shipped',
                                                 Sub_State__c='Unknown',
                                                 componentComponentSN__c='123456',
                                                 componentType__c='Chassis',
                                                 componentDescription__c='Chassis');
        Test.startTest();
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent1.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component',
                                  rmaNearbyDepot__c=depotrecord.id,
                                  rmaStatus__c = 'Draft');  
        Test.stopTest();
        depotrecord.depotCountry__c = 'United States';
        update depotrecord;
        map<id, map<id, Location>> depotsmapInside = new map<id, map<id, Location>>();
        map<string, Location> objectIdList = new map<string, Location>();
        map<id, boolean> Objectidbool = new map<id, boolean>();
        depotsmapInside.put(rma.id, depotsmaps);
        objectIdList.put(rma.id, Location.newInstance(37.2966853, -122.0975973));
        Objectidbool.put(rma.id, false);
        Map<id, string> Depotwithaddressasset = new map<id, string>();
        Depotwithaddressasset.put(rma.id, 'Suite 100, San Jose, CA, 95151, United States');
        
        Map<id, id> depotRecNotIn150MilesRadius = new Map<id, id>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotNameToRMA = new Map<id, string>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotProviderToRMA = new Map<id, string>();
        try{
            Geolocationaddress.geocodeAddress(Depotwithaddressasset, 'Asset', Depotwithaddressasset, Depotwithaddressasset);
            //Geolocationaddress.addressDepotMap(depotsmaps, asset.id, Location.newInstance(37.2966853, -122.0975973), 'Asset', false);
            Geolocationaddress.addressDepotMap(depotsmapInside, objectIdList, 'Asset', Objectidbool, depotRecNotIn150MilesRadius, depotRecNotIn150MilesRadiusDepotNameToRMA, depotRecNotIn150MilesRadiusDepotProviderToRMA);
        }
        catch(Exception e) {
            
        }
    }  
    static testMethod void rmaUpdateWithDepotMoveFuture()
    { 
        Account account;
        Contact contact;
        Asset   asset;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Case aCase;
        RMAv2__c rma;
        
        depot__c depotrecord = new depot__c();
        depotrecord.Name = 'Test Depot';
        depotrecord.depotProvider__c = 'Flash';
        depotrecord.depotStockedFor4Hour__c = 'Yes';
        depotrecord.depotLocationDescription__c = 'Test Desc';
        depotrecord.depotCity__c = 'New York';
        depotrecord.depotIsactive__c = TRUE;
        depotrecord.Returns_Carrier__c = 'DHL';
        
        insert depotrecord;
        Map<id, Location> depotsmaps = new map<id, Location>();
        depotsmaps.put(depotrecord.id, Location.newInstance(37.2966853, -122.0975973));
        
        set<Id> depotIDset = new set<Id>();
        depotIDset.add(depotrecord.Id);
        
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
        
        //list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
        //
        
        
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                ab4HourDepot__c = depotrecord.id);
        system.debug('### Address Book #### '+addressBook.ab4HourDepot__r.Name);
        addressBook.abGeolocation__Latitude__s = depotrecord.depotLocation__Latitude__s;
        addressBook.abGeolocation__Longitude__s = depotrecord.depotLocation__Longitude__s;
        addressBook.ab4HourDepot__c = depotrecord.id;
        update addressBook;
        
        
        system.debug('### After update - Address Book #### '+addressBook.ab4HourDepot__r.Name);
        //depotrecord.depotIsactive__c = false;
        //update depotrecord;
        try{
            depotGeolocationCalcFuture.unlinkRecFromDepot(depotIDset);
        }
        catch(Exception e) {
            
        }
    } 
    static testMethod void rmaUpdateWithDepotPhilippinesWithAB()
    { 
        Account account;
        Contact contact;
        Asset   asset;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Case aCase;
        RMAv2__c rma;
        /*Map<id, Location> depotsmaps = new map<id, Location>();
list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
for(depot__c depotsins : Depotsmap){
if(depotsins.depotLocation__c != null)
depotsmaps.put(depotsins.id, depotsins.depotLocation__c);
}*/
        depot__c depotrecord = new depot__c();
        depotrecord.Name = 'Test Depot';
        depotrecord.depotProvider__c = 'Flash';
        depotrecord.depotStockedFor4Hour__c = 'Yes';
        depotrecord.depotLocationDescription__c = 'Test Desc';
        depotrecord.depotCity__c = 'New York';
        depotrecord.depotIsactive__c = TRUE;
        depotrecord.Returns_Carrier__c = 'DHL';
        
        insert depotrecord;
        Map<id, Location> depotsmaps = new map<id, Location>();
        depotsmaps.put(depotrecord.id, Location.newInstance(37.2966853, -122.0975973));
        
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
        
        //list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='Philippines',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depotrecord.id);
         Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        insert testProduct1;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium 4 Hour',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                 assetPartShipAddressBook__c = addressBook.Id,
                                 assetNearbyDepot__c = depotrecord.id,
                                 assetClosestShipDepot__c = depotrecord.id,
                                 Array_Controller__c = 'CS300',
                                Product2Id = testProduct1.id,
                                Component_SKU_HPE__c = 'R4U28A');
        
        System.assertNotEquals(null,                      asset.Id);
        System.assertEquals('TEST-ASSET',                  asset.Name);
        System.assertEquals(account.Id,                 asset.AccountId);
        System.assertEquals(contact.Id,                 asset.ContactId);
        System.assertEquals('Premium 4 Hour',                     asset.SLA__c);
        System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
        
        insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                 componentAsset__c = asset.Id,
                                                 componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                 componentState__c = 'Shipped',
                                                 Sub_State__c='Unknown',
                                                 componentComponentSN__c='123456',
                                                 componentType__c='Chassis',
                                                 componentDescription__c='Chassis');
        Test.startTest();
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent1.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component');  
        
        depotrecord.depotCountry__c = 'United States';
        update depotrecord;
        map<id, map<id, Location>> depotsmapInside = new map<id, map<id, Location>>();
        map<string, Location> objectIdList = new map<string, Location>();
        map<id, boolean> Objectidbool = new map<id, boolean>();
        depotsmapInside.put(rma.id, depotsmaps);
        objectIdList.put(rma.id, Location.newInstance(37.2966853, -122.0975973));
        Objectidbool.put(rma.id, false);
        Map<id, string> Depotwithaddressasset = new map<id, string>();
        Depotwithaddressasset.put(rma.id, 'Suite 100, San Jose, CA, 95151, United States');
        
        Map<id, id> depotRecNotIn150MilesRadius = new Map<id, id>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotNameToRMA = new Map<id, string>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotProviderToRMA = new Map<id, string>();
        try{
            Geolocationaddress.geocodeAddress(Depotwithaddressasset, 'Asset', Depotwithaddressasset, Depotwithaddressasset);
            //Geolocationaddress.addressDepotMap(depotsmaps, asset.id, Location.newInstance(37.2966853, -122.0975973), 'Asset', false);
            Geolocationaddress.addressDepotMap(depotsmapInside, objectIdList, 'Asset', Objectidbool, depotRecNotIn150MilesRadius, depotRecNotIn150MilesRadiusDepotNameToRMA, depotRecNotIn150MilesRadiusDepotProviderToRMA);
        }
        catch(Exception e) {
            
        }
        Test.stopTest();
    }  
    static testMethod void rmaUpdateWithDepotPhilippinesWithOverrideAddress()
    { 
        Account account;
        Contact contact;
        Asset   asset;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Case aCase;
        RMAv2__c rma;
        /*Map<id, Location> depotsmaps = new map<id, Location>();
list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
for(depot__c depotsins : Depotsmap){
if(depotsins.depotLocation__c != null)
depotsmaps.put(depotsins.id, depotsins.depotLocation__c);
}*/
        depot__c depotrecord = new depot__c();
        depotrecord.Name = 'Test Depot';
        depotrecord.depotProvider__c = 'Flash';
        depotrecord.depotStockedFor4Hour__c = 'Yes';
        depotrecord.depotLocationDescription__c = 'Test Desc';
        depotrecord.depotCity__c = 'New York';
        depotrecord.depotIsactive__c = TRUE;
        depotrecord.Returns_Carrier__c = 'DHL';
        
        insert depotrecord;
        Map<id, Location> depotsmaps = new map<id, Location>();
        depotsmaps.put(depotrecord.id, Location.newInstance(37.2966853, -122.0975973));
        
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
        
        //list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1];
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TES-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depotrecord.id);
         Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        insert testProduct1;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium 4 Hour',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                 assetPartShipAddressBook__c = addressBook.Id,
                                 assetNearbyDepot__c = depotrecord.id,
                                 assetClosestShipDepot__c = depotrecord.id,
                                 Array_Controller__c = 'CS300',
                                Product2Id = testProduct1.id,
                                Component_SKU_HPE__c = 'R4U28A');
        
        System.assertNotEquals(null,                      asset.Id);
        System.assertEquals('TEST-ASSET',                  asset.Name);
        System.assertEquals(account.Id,                 asset.AccountId);
        System.assertEquals(contact.Id,                 asset.ContactId);
        System.assertEquals('Premium 4 Hour',                     asset.SLA__c);
        System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
        
        insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                 componentAsset__c = asset.Id,
                                                 componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                 componentState__c = 'Shipped',
                                                 Sub_State__c='Unknown',
                                                 componentComponentSN__c='123456',
                                                 componentType__c='Chassis',
                                                 componentDescription__c='Chassis');
        Test.startTest();
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent1.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component',
                                  rmaOverrideShipmentCountry__c = 'Philippines');  
        
        depotrecord.depotCountry__c = 'United States';
        update depotrecord;
        map<id, map<id, Location>> depotsmapInside = new map<id, map<id, Location>>();
        map<string, Location> objectIdList = new map<string, Location>();
        map<id, boolean> Objectidbool = new map<id, boolean>();
        depotsmapInside.put(rma.id, depotsmaps);
        objectIdList.put(rma.id, Location.newInstance(37.2966853, -122.0975973));
        Objectidbool.put(rma.id, false);
        Map<id, string> Depotwithaddressasset = new map<id, string>();
        Depotwithaddressasset.put(rma.id, 'Suite 100, San Jose, CA, 95151, United States');
        
        Map<id, id> depotRecNotIn150MilesRadius = new Map<id, id>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotNameToRMA = new Map<id, string>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotProviderToRMA = new Map<id, string>();
        try{
            Geolocationaddress.geocodeAddress(Depotwithaddressasset, 'Asset', Depotwithaddressasset, Depotwithaddressasset);
            //Geolocationaddress.addressDepotMap(depotsmaps, asset.id, Location.newInstance(37.2966853, -122.0975973), 'Asset', false);
            Geolocationaddress.addressDepotMap(depotsmapInside, objectIdList, 'Asset', Objectidbool, depotRecNotIn150MilesRadius, depotRecNotIn150MilesRadiusDepotNameToRMA, depotRecNotIn150MilesRadiusDepotProviderToRMA);
        }
        catch(Exception e) {
            
        }
        Test.stopTest();
    }  
    static testMethod void searchGeoPage()
    { 
        Location originAddressGeoLoc = Location.newInstance(37.2966853, -122.0975973);
        
        depot__c depotrecord = new depot__c();
        depotrecord.Name = 'Test Depot';
        depotrecord.depotProvider__c = 'Flash';
        depotrecord.depotStockedFor4Hour__c = 'Yes';
        depotrecord.depotLocationDescription__c = 'Test Desc';
        depotrecord.depotCity__c = 'New York';
        //depotrecord.depotAddress__c = 'New york';
        depotrecord.depotLocation__Latitude__s = originAddressGeoLoc.getLatitude();
        depotrecord.depotLocation__Longitude__s = originAddressGeoLoc.getLongitude();
        depotrecord.depotIsactive__c = TRUE;
        depotrecord.Returns_Carrier__c = 'DHL';
        
        insert depotrecord;
        
        string destination = 'Suite 100, San Jose, CA, 95151, United States';
        DepotmappingUtility.callGeolocationApi(originAddressGeoLoc, destination);
        string destinationaddress = '';
        string originaddress = originAddressGeoLoc.getLatitude() + ',' + originAddressGeoLoc.getLongitude();        
        originaddress = EncodingUtil.urlEncode(originaddress, 'UTF-8');
        destinationaddress = EncodingUtil.urlEncode(destination, 'UTF-8');        
        string endPoint = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins='+ originaddress +'&destinations=' + destinationaddress ;
        DepotmappingUtility.callGeoLocationApiForEndPoint(endPoint);
        ApexPages.StandardController sc = new ApexPages.StandardController(depotrecord);
        DepotmappingTool dmp = new DepotmappingTool(sc);
        dmp.getOptions();
        dmp.getDepotlist();
        dmp.searchstring = 'San jose';
        dmp.Geolocation = Location.newInstance(37.2966853, -122.0975973);
        //dmp.depotstotlist.add(depotrecord);
        dmp.search();
        DepotmappingTool.myWrapper wrap = new DepotmappingTool.myWrapper(depotrecord, 12.05, '12mins', false);
        wrap.compareTo(wrap);
        //dmp.getDepotwithDistance(depot, adderssloc);
        //dmp.getDepotwithDistance(depot, addressloc);
    }
    static testMethod void depotGeolocationCalcFutureTest()
    { 
        Account account;
        Contact contact;
        Asset   asset;
        AddressBook__c addressBook;
        Component__c testComponent1;
        Case aCase;
        RMAv2__c rma;
        Product2 testProduct1;
        
        depot__c depotrecord = new depot__c();
        depotrecord.Name = 'Test Depot';
        depotrecord.depotProvider__c = 'Flash';
        depotrecord.depotStockedFor4Hour__c = 'Yes';
        depotrecord.depotLocationDescription__c = 'Test Desc';
        depotrecord.depotCity__c = 'New York';
        depotrecord.depotIsactive__c = TRUE;
        depotrecord.Returns_Carrier__c = 'DHL';
        
        insert depotrecord;
        set<id> depotIDSet = new   set<id>();
        depotIDSet.add(depotrecord.id);
        Map<id, Location> depotsmaps = new map<id, Location>();
        depotsmaps.put(depotrecord.id, Location.newInstance(37.2966853, -122.0975973));
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');      
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');               
        //list<depot__c> Depotsmap = [Select id, name, depotLocation__c from depot__c limit 1]; 
        
		insert testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array'); 
        
        // Create test asset
         insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='Philippines',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1',
                                                ab4HourDepot__c = depotrecord.id);
        
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium 4 Hour',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                 assetPartShipAddressBook__c = addressBook.Id,
                                 assetNearbyDepot__c = depotrecord.id,
                                 assetClosestShipDepot__c = depotrecord.id,
                                Array_Controller__c = 'CS300',
                                Array_Controller_SKU__c = 'CS220',
                                 Component_SKU_HPE__c = 'R4U28A',
                                Product2Id = testProduct1.id);
        
        
       
        
        
        
        insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                 componentAsset__c = asset.Id,
                                                 componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                 componentState__c = 'Shipped',
                                                 Sub_State__c='Unknown',
                                                 componentComponentSN__c='123456',
                                                 componentType__c='Chassis',
                                                 componentDescription__c='Chassis');
        Test.startTest();
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
         insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                  rmaDiskShelfAsset__c = asset.Id, 
                                  rmaComponentV2__c = testComponent1.Id,
                                  rmaAddressBook__c = addressBook.Id,
                                  rmaSelection__c = 'Component',
                                  rmaNearbyDepot__c =depotrecord.id,
                                  rmaStatus__c = 'Draft');  
        depotrecord.depotCountry__c = 'United States';
        update depotrecord;
        
        //Added by exafort for SFDC-314
        Geolocationaddress.get4HourDepotList('Japan', 'Legacy Nimble','RMAv2__c');
        Geolocationaddress.get4HourDepotList('Japan', 'Legacy Nimble','Asset');
        Geolocationaddress.get4HourDepotList('Japan', 'Alletra MP Block','RMAv2__c'); 
        Geolocationaddress.get4HourDepotList('Japan', 'Alletra MP Block','Asset'); 
        Geolocationaddress.isDepotAndShipToWithinUSAorFullyForeign('United States',depotrecord);
        //End of SFDC-314
        list<RMAv2__c> rmaList = new list<RMAv2__c>();
        rmaList.add(rma);
        rmaBatchUpdateFromDepot b = new rmaBatchUpdateFromDepot(depotIDSet); 
        Database.executeBatch(b,10);
        b.execute(null,rmaList);
        
        Test.stopTest();
    } 
 
    static testMethod void testMiscMethods(){
        Geolocationaddress.getDepotName(null, null, null, null);
        Geolocationaddress.getDepotID(null, null, null, null);
    }
}