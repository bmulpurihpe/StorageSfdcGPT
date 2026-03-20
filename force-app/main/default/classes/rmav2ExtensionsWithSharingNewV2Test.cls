@isTest
public class rmav2ExtensionsWithSharingNewV2Test {
    class TestData{
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase; 
        RMAv2__c rma;
        AddressBook__c addressBook;
        SR_Meta_Data__c srMetaData;
        SR_Meta_Data__c srMetaData1;
        SR_Meta_Data__c srMetaData2;
        EOAPart__c eoaPart;
        Component__c testComponent1;
        Component__c testComponent2;
        Component__c testComponent3;
        Component__c testComponent4;
        
        TestData() {
            Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                          BillingStreet = 'Am Tierpark 16',
                                          BillingCity = 'Cologne',
                                          BillingPostalCode = '54321',
                                          BillingState = 'Nordrhein-Westfalen',
                                          BillingCountry = 'Germany');
            insert account;
            Contact contact = new Contact (LastName = 'TEST-CONTACT-LAST-NAME',
                                           AccountId = account.Id,
                                           Email='test@gmail.com',
                                           Phone='999999999');
            insert contact;
            Product2 prd = new Product2(Name = 'SSD Storage Array',
                                        ProductCode='HF600',
                                        Product_Type__c='Hardware',
                                        Product_Type_2__c='SAN Storage ArrayS',
                                        Controller_Code__c='CS2001',
                                        Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                        Family='SAN Storage Array');
            insert prd;
            Asset asset = new Asset(Name = 'TEST-ASSET',
                                    AccountId = account.Id,
                                    ContactId = contact.Id,
                                    Product2id = prd.id,
                                    SLA__c = 'Premium',
                                    assetRmaShi__c = 'Asset RMA SHI',
                                    HPE_Serial_Number__c ='AA000000NIM',
                                    Array_Controller__c = 'CS3001',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                    Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                    Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
            insert asset;
            Case aCase = new Case(AccountId = account.Id,
                                  AssetId   = asset.Id,
                                  ContactId = contact.Id,
                                  Subject = 'TEST-CASE-SUBJECT');
            insert aCase;
            AddressBook__c addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                            abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                            abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                            abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                            abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                            abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                            abPostalCode__c='1000',
                                                            abDescription__c='Asset Install Address 1');
            insert addressBook;
        }
        void insertComponents(){
            Component__c testComponent1 = new Component__c(componentAccountId__c = account.Id,
                                                           componentAsset__c = asset.Id,
                                                           componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                           componentState__c = 'Shipped',
                                                           Sub_State__c='Unknown',
                                                           componentComponentSN__c='123456',
                                                           componentType__c='Chassis',
                                                           componentDescription__c='Chassis');
            insert testComponent1;
            Component__c testComponent2 = new Component__c(componentAccountId__c = account.Id,
                                                           componentAsset__c = asset.Id,
                                                           componentServicePartNumber__c='SR-USB',
                                                           componentState__c = 'Shipped',
                                                           Sub_State__c='Unknown',
                                                           componentComponentSN__c='654321',
                                                           componentType__c='USB',
                                                           componentDescription__c='USB');
            insert testComponent2;
            Component__c testComponent3 = new Component__c(componentAccountId__c = account.Id,
                                                           componentAsset__c = asset.Id,
                                                           componentServicePartNumber__c='SR-HDD-1TB',
                                                           componentState__c = 'Shipped',
                                                           Sub_State__c='Unknown',
                                                           componentComponentSN__c='13579',
                                                           componentType__c='HDD',
                                                           componentDescription__c='HDD');
            insert testComponent3;
            Component__c testComponent4 = new Component__c(componentAccountId__c = account.Id,
                                                           componentAsset__c = asset.Id,
                                                           componentServicePartNumber__c='SR-Bezel-CS-series',
                                                           componentState__c = 'Shipped',
                                                           Sub_State__c='Unknown',
                                                           componentComponentSN__c='02468',
                                                           componentType__c='BEZEL',
                                                           componentDescription__c='BEZEL');
            insert testComponent4;
        }
        void insertRMA01(){
            RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                        rmaDiskShelfAsset__c = asset.Id, 
                                        rmaComponentV2__c = testComponent1.Id,
                                        rmaAddressBook__c = addressBook.Id,
                                        rmaSelection__c = 'Component',
                                        rmaOverrideShipmentAttn__c = 'Test',
                                        rmaOverrideShipmentEmail__c = 'test1@gmail.com');
            insert rma;
        }
        void insertRMA02(){
            RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                        rmaDiskShelfAsset__c = asset.Id, 
                                        rmaComponentV2__c = testComponent1.Id,
                                        rmaAddressBook__c = addressBook.Id,
                                        rmaSelection__c = 'Component',
                                        rmaOverrideShipmentAttn__c = 'Test',
                                        rmaOverrideShipmentEmail__c = 'test1@gmail.com');
            insert rma;
        }
        void insertRMA03(){
            RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                        rmaDiskShelfAsset__c = asset.Id, 
                                        rmaComponentV2__c = testComponent1.Id,
                                        rmaAddressBook__c = addressBook.Id,
                                        rmaSelection__c = 'Component',
                                        rmaOverrideShipmentAttn__c = 'Test',
                                        rmaOverrideShipmentEmail__c = 'test1@gmail.com');
            insert rma;
        }
        void insertRMA04(){
            //asset.SLA__c = 'Premium 4 Hour Onsite';
            //update asset;
            RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                        rmaDiskShelfAsset__c = asset.Id, 
                                        rmaComponentV2__c = testComponent4.Id,
                                        rmaAddressBook__c = addressBook.Id,
                                        rmaSelection__c = 'Component',
                                        rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours',
                                        rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site',
                                        rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival',
                                        rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site',      
                                        rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET',
                                        rmaOverrideOnsiteArrivalCity__c = 'TESTCITY',
                                        rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222',
                                        rmaOverrideOnsiteArrivalCountry__c = 'United States',
                                        rmaOverrideShipmentAttn__c = 'Test',
                                        rmaOverrideShipmentEmail__c = 'test1@gmail.com');
            insert rma;
        }
        void insertRMA05(){
            insertsrMetData();
            RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                        rmaAddressBook__c = addressBook.Id,
                                        rmasrFlatList__c = srMetaData.Id,
                                        rmaSelection__c = 'Flat List',
                                        rmaOverrideShipmentAttn__c = 'Test',
                                        rmaOverrideShipmentEmail__c = 'test1@gmail.com');
            insert rma;
        }
        void insertsrMetData(){
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1200W',
                                                    srType__c = 'PWR(power supply)',
                                                    srDescription__c='Service Power Supply Unit for CS Arrays, 1200W',
                                                    srShippingProvider__c='Flash',srPartShipSLAOverride__c = 'NBD & Onsite Override',srmetadataIsValid__c = true);
            
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1500W',
                                                    srType__c = 'PWR(power supply)',
                                                    srDescription__c=null,
                                                    srShippingProvider__c='Flash',srPartShipSLAOverride__c = 'NBD & Onsite Override',srmetadataIsValid__c = true);
            //Added a new Sr Metadata by vishnu on 25th jan 2019.
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-USB',
                                                    srType__c = 'PWR(power supply)',
                                                    srDescription__c=null,
                                                    srShippingProvider__c='Flash',srPartShipSLAOverride__c = 'NBD & Onsite Override',srmetadataIsValid__c = true);
        }
        void insertsrMetData01(){
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-CHASSIS',
                                                    srType__c = 'PWR(power supply)',
                                                    srDescription__c=null,
                                                    srShippingProvider__c='Flash',srPartShipSLAOverride__c = 'NBD & Onsite Override');
        }
    }
    static testMethod void rmaAsset_Premium_Edit() {
        
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact (LastName = 'TEST-CONTACT-LAST-NAME',
                                   AccountId = acc.Id,
                                   Email='test@gmail.com',
                                   Phone='999999999');
        insert con;
        /*Product2 prd = new Product2 (Name = 'Test Prd',
CurrencyIsoCode = 'USD',
ProductCode = 'HF60',
Component_Code__c = 'Test Prd',
Product_Type__c='Hardware',
Product_Type_2__c='SAN Storage ArrayS',
Controller_Code__c='CS2001',
Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
Family='SAN Storage Array');
insert prd;*/
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        /* Asset ass1 = new Asset(Name = 'TEST-ASSET',
AccountId = acc.Id,
ContactId = con.Id,
SLA__c = 'Premium',
Product2id = prd.id,
//Array_Controller__c = 'AF1000',
Array_Controller_SKU__c = 'HF60',
Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
Asset_Type_Build__c ='Testasupassettype'
);
insert ass1;*/
        
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        component__c testComponent1 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='123456',
                                                       componentType__c='Chassis',
                                                       componentDescription__c='Chassis');
        insert testComponent1;
        test.startTest();
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent1.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaDeliveryDate__c = Date.today().addDays(2),
                                    rmaDeliveryTimes__c = '11:00 AM',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        RMAv2__c rma2 = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                     rmaDiskShelfAsset__c = ass1.Id, 
                                     rmaComponentV2__c = testComponent1.Id,
                                     rmaAddressBook__c = addressBook.Id,
                                     rmaFailedPart__c ='SR-SSD-3500-600GB',
                                     rmaSelection__c = 'Spares or Upgrades',
                                     rmaDeliveryDate__c = Date.today().addDays(2),
                                     rmaDeliveryTimes__c = '11:00 AM',
                                     rmaOverrideShipmentAttn__c = 'Test',
                                     rmaOverrideShipmentPhone__c = '12345', 
                                     rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma2;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma2);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaEditRecord();
        
    }
    
    static testMethod void rmaAsset_Premium_NRD_InEffect(){
        
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact (LastName = 'TEST-CONTACT-LAST-NAME',
                                   AccountId = acc.Id,
                                   Email='test@gmail.com',
                                   Phone='999999999');
        insert con;
        /*Product2 prd = new Product2 (Name = 'Test Prd',
CurrencyIsoCode = 'USD',
ProductCode = 'HF60',
Component_Code__c = 'Test Prd',
Product_Type__c='Hardware',
Product_Type_2__c='SAN Storage ArrayS',
Controller_Code__c='CS2001',
Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
Family='SAN Storage Array');
insert prd;*/
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        /* Asset ass1 = new Asset(Name = 'TEST-ASSET',
AccountId = acc.Id,
ContactId = con.Id,
SLA__c = 'Premium',
Product2id = prd.id,
//Array_Controller__c = 'AF1000',
Array_Controller_SKU__c = 'HF60',
Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
Asset_Type_Build__c ='Testasupassettype'
);
insert ass1;*/
        
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        component__c testComponent1 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='123456',
                                                       componentType__c='Chassis',
                                                       componentDescription__c='Chassis');
        insert testComponent1;
        test.startTest();
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent1.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaDeliveryDate__c = Date.today().addDays(2),
                                    rmaDeliveryTimes__c = '11:00 AM',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        RMAv2__c rma2 = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                     rmaDiskShelfAsset__c = ass1.Id, 
                                     rmaComponentV2__c = testComponent1.Id,
                                     rmaAddressBook__c = addressBook.Id,
                                     rmaFailedPart__c ='SR-SSD-3500-600GB',
                                     rmaSelection__c = 'Spares or Upgrades',
                                     rmaDeliveryDate__c = Date.today().addDays(2),
                                     rmaDeliveryTimes__c = '11:00 AM',
                                     rmaOverrideShipmentAttn__c = 'Test',
                                     rmaOverrideShipmentPhone__c = '12345',
                                     rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma2;
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaEditRecord();
        //  newRMA.saveRMA();
        sc = new ApexPages.StandardController(rma2);
        newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        newRMA.rmaEditRecord();
        
        pageRef.getParameters().put('rmaOutgoingShipmentStatusParam','Canceled');
        newRMA.populateAddressFields();
        newRMA.showRMACancellationReason();
        newRMA.saveRMA();
        test.stopTest();
    }
    static testMethod void rmaAsset_Premium_New_AccountSHI() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact (LastName = 'TEST-CONTACT-LAST-NAME',
                                   AccountId = acc.Id,
                                   Email='test@gmail.com',
                                   Phone='999999999');
        insert con;
        /*Product2 prd = new Product2 (Name = 'Test Prd',
CurrencyIsoCode = 'USD',
ProductCode = 'HF60',
Component_Code__c = 'Test Prd',
Product_Type__c='Hardware',
Product_Type_2__c='SAN Storage ArrayS',
Controller_Code__c='CS2001',
Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
Family='SAN Storage Array');
insert prd;*/
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        /* Asset ass1 = new Asset(Name = 'TEST-ASSET',
AccountId = acc.Id,
ContactId = con.Id,
SLA__c = 'Premium',
Product2id = prd.id,
//Array_Controller__c = 'AF1000',
Array_Controller_SKU__c = 'HF60',
Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
Asset_Type_Build__c ='Testasupassettype'
);
insert ass1;*/
        
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        component__c testComponent1 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='123456',
                                                       componentType__c='Chassis',
                                                       componentDescription__c='Chassis');
        insert testComponent1;
        test.startTest();
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent1.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaDeliveryDate__c = Date.today().addDays(2),
                                    rmaDeliveryTimes__c = '11:00 AM',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        RMAv2__c rma2 = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                     rmaDiskShelfAsset__c = ass1.Id, 
                                     rmaComponentV2__c = testComponent1.Id,
                                     rmaAddressBook__c = addressBook.Id,
                                     rmaFailedPart__c ='SR-SSD-3500-600GB',
                                     rmaSelection__c = 'Spares or Upgrades',
                                     rmaDeliveryDate__c = Date.today().addDays(2),
                                     rmaDeliveryTimes__c = '11:00 AM',
                                     rmaOverrideShipmentAttn__c = 'Test',
                                     rmaOverrideShipmentPhone__c = '12345', 
                                     rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma2;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        
        newRMA.assetOnChange();
        newRMA.caseOnChange();
        newRMA.faRequiredOnChange();
        newRMA.addressBookOnChange();
        newRMA.showOnSiteSectionOnChange();
        newRMA.showReturnSectionOnChange();
        newRMA.populateAddressFields();
        newRMA.getAddressOptions();
        newRMA.getTransmitRMASHICheckboxes();
        newRMA.saveRMA();
        test.stopTest();
        
    }
    static testMethod void rmaAsset_Premium_New_NoSHI() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact (LastName = 'TEST-CONTACT-LAST-NAME',
                                   AccountId = acc.Id,
                                   Email='test@gmail.com',
                                   Phone='999999999');
        insert con;
        /*Product2 prd = new Product2 (Name = 'Test Prd',
CurrencyIsoCode = 'USD',
ProductCode = 'HF60',
Component_Code__c = 'Test Prd',
Product_Type__c='Hardware',
Product_Type_2__c='SAN Storage ArrayS',
Controller_Code__c='CS2001',
Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
Family='SAN Storage Array');
insert prd;*/
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        /* Asset ass1 = new Asset(Name = 'TEST-ASSET',
AccountId = acc.Id,
ContactId = con.Id,
SLA__c = 'Premium',
Product2id = prd.id,
//Array_Controller__c = 'AF1000',
Array_Controller_SKU__c = 'HF60',
Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
Asset_Type_Build__c ='Testasupassettype'
);
insert ass1;*/
        
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        component__c testComponent1 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='123456',
                                                       componentType__c='Chassis',
                                                       componentDescription__c='Chassis');
        insert testComponent1;
        test.startTest();
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent1.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaDeliveryDate__c = Date.today().addDays(2),
                                    rmaDeliveryTimes__c = '11:00 AM',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        RMAv2__c rma2 = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                     rmaDiskShelfAsset__c = ass1.Id, 
                                     rmaComponentV2__c = testComponent1.Id,
                                     rmaAddressBook__c = addressBook.Id,
                                     rmaFailedPart__c ='SR-SSD-3500-600GB',
                                     rmaSelection__c = 'Spares or Upgrades',
                                     rmaDeliveryDate__c = Date.today().addDays(2),
                                     rmaDeliveryTimes__c = '11:00 AM',
                                     rmaOverrideShipmentAttn__c = 'Test',
                                     rmaOverrideShipmentPhone__c = '12345', 
                                     rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma2;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.saveRMA();
        Test.stopTest();
        
    }
    static testMethod void rmaAsset_Premium_NRD_InEffect1() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact (LastName = 'TEST-CONTACT-LAST-NAME',
                                   AccountId = acc.Id,
                                   Email='test@gmail.com',
                                   Phone='999999999');
        insert con;
        /*Product2 prd = new Product2 (Name = 'Test Prd',
CurrencyIsoCode = 'USD',
ProductCode = 'HF60',
Component_Code__c = 'Test Prd',
Product_Type__c='Hardware',
Product_Type_2__c='SAN Storage ArrayS',
Controller_Code__c='CS2001',
Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
Family='SAN Storage Array');
insert prd;*/
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        /* Asset ass1 = new Asset(Name = 'TEST-ASSET',
AccountId = acc.Id,
ContactId = con.Id,
SLA__c = 'Premium',
Product2id = prd.id,
//Array_Controller__c = 'AF1000',
Array_Controller_SKU__c = 'HF60',
Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
Asset_Type_Build__c ='Testasupassettype'
);
insert ass1;*/
        
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        component__c testComponent1 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='123456',
                                                       componentType__c='Chassis',
                                                       componentDescription__c='Chassis');
        insert testComponent1;
        test.startTest();
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent1.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaDeliveryDate__c = Date.today().addDays(2),
                                    rmaDeliveryTimes__c = '11:00 AM',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        
        RMAv2__c rma2 = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                     rmaDiskShelfAsset__c = ass1.Id, 
                                     rmaComponentV2__c = testComponent1.Id,
                                     rmaAddressBook__c = addressBook.Id,
                                     rmaFailedPart__c ='SR-SSD-3500-600GB',
                                     rmaSelection__c = 'Spares or Upgrades',
                                     rmaDeliveryDate__c = Date.today().addDays(2),
                                     rmaDeliveryTimes__c = '11:00 AM',
                                     rmaOverrideShipmentAttn__c = 'Test',
                                     rmaOverrideShipmentPhone__c = '12345',
                                     rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma2;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaEditRecord();
        newRMA.saveRMA();
        test.stopTest();
    }
    static testMethod void rmaAsset_Premium_AssetSelection() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact (LastName = 'TEST-CONTACT-LAST-NAME',
                                   AccountId = acc.Id,
                                   Email='test@gmail.com',
                                   Phone='999999999');
        insert con;
        /*Product2 prd = new Product2 (Name = 'Test Prd',
CurrencyIsoCode = 'USD',
ProductCode = 'HF60',
Component_Code__c = 'Test Prd',
Product_Type__c='Hardware',
Product_Type_2__c='SAN Storage ArrayS',
Controller_Code__c='CS2001',
Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
Family='SAN Storage Array');
insert prd;*/
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        /* Asset ass1 = new Asset(Name = 'TEST-ASSET',
AccountId = acc.Id,
ContactId = con.Id,
SLA__c = 'Premium',
Product2id = prd.id,
//Array_Controller__c = 'AF1000',
Array_Controller_SKU__c = 'HF60',
Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
Asset_Type_Build__c ='Testasupassettype'
);
insert ass1;*/
        
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        component__c testComponent1 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='123456',
                                                       componentType__c='Chassis',
                                                       componentDescription__c='Chassis');
        insert testComponent1;
        test.startTest();
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent1.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaDeliveryDate__c = Date.today().addDays(2),
                                    rmaDeliveryTimes__c = '11:00 AM',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        
        RMAv2__c rma2 = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                     rmaDiskShelfAsset__c = ass1.Id, 
                                     rmaComponentV2__c = testComponent1.Id,
                                     rmaAddressBook__c = addressBook.Id,
                                     rmaFailedPart__c ='SR-SSD-3500-600GB',
                                     rmaSelection__c = 'Spares or Upgrades',
                                     rmaDeliveryDate__c = Date.today().addDays(2),
                                     rmaDeliveryTimes__c = '11:00 AM',
                                     rmaOverrideShipmentAttn__c = 'Test',
                                     rmaOverrideShipmentPhone__c = '12345', 
                                     rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma2;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('identity','Asset');
        ApexPages.currentPage().getParameters().put('isSelected','true');
        Apexpages.currentPage().getParameters().put('assetToProcess',ass1.Name);
        //Added by vishnu on 25th jan 2019 for getting the paramters from the vf page.
        ApexPages.currentPage().getParameters().put('srPart','SR-USB');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getassetOuterMap1();
        newRMA.getSrMetaDataOptions();
        newRMA.checkboxOnChange();
        //newRMA.OnsiteValueForNBD('SR-USB');
        newRMA.saveRMA();
        test.stopTest();
        
    }
    static testMethod void rmaAsset_Premium_NotShipToPart() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                  AccountId = acc.Id,
                                  Email='test@gmail.com',
                                  Phone='999999999');
        insert con;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        test.startTest();
        component__c testComponent4 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-Bezel-CS-series',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='02468',
                                                       componentType__c='BEZEL',
                                                       componentDescription__c='BEZEL');
        insert testComponent4;
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent4.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaEditRecord();
        newRMA.saveRMA();
        test.stopTest();
    }
    static testMethod void rmaAsset_Premium_ComponentSelection() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                  AccountId = acc.Id,
                                  Email='test@gmail.com',
                                  Phone='999999999');
        insert con;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        test.startTest();
        component__c testComponent4 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-Bezel-CS-series',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='02468',
                                                       componentType__c='BEZEL',
                                                       componentDescription__c='BEZEL');
        insert testComponent4;
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent4.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('identity','Component');
        ApexPages.currentPage().getParameters().put('identityValue',testcomponent4.Id);
        ApexPages.currentPage().getParameters().put('isSelected','true');
        ApexPages.currentPage().getParameters().put('componentType','CHASSIS');
        Apexpages.currentPage().getParameters().put('assetToProcess',ass1.Name);
        //Added by vishnu on 25th jan 2019 for getting the paramters from the vf page.
        ApexPages.currentPage().getParameters().put('srPart','SR-CHASSIS');
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getassetOuterMap1();
        newRMA.checkboxOnChange();
        test.stopTest();
    }
    static testMethod void rmaAsset_Premium_SpareSelection() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                  AccountId = acc.Id,
                                  Email='test@gmail.com',
                                  Phone='999999999');
        insert con;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        test.startTest();
        component__c testComponent4 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-Bezel-CS-series',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='02468',
                                                       componentType__c='BEZEL',
                                                       componentDescription__c='BEZEL');
        insert testComponent4;
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent4.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('identity','Spares or Upgrades');
        ApexPages.currentPage().getParameters().put('identityValue',testcomponent4.Id);
        ApexPages.currentPage().getParameters().put('isSelected','true');
        ApexPages.currentPage().getParameters().put('componentType','CHASSIS');
        //Added by vishnu on 25th jan 2019 for getting the paramters from the vf page.
        ApexPages.currentPage().getParameters().put('srPart','SR-CHASSIS');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.checkboxOnChange();
        test.stopTest();
    }
    static testMethod void rmaAsset_Premium_NoneSelection() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                  AccountId = acc.Id,
                                  Email='test@gmail.com',
                                  Phone='999999999');
        insert con;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        test.startTest();
        component__c testComponent4 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-Bezel-CS-series',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='02468',
                                                       componentType__c='BEZEL',
                                                       componentDescription__c='BEZEL');
        insert testComponent4;
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent4.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSelected','false');
        //Added by vishnu on 25th jan 2019 for getting the paramters from the vf page.
        ApexPages.currentPage().getParameters().put('srPart','SR-PWR-1200W');
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.checkboxOnChange();
        test.stopTest();
    }
    static testMethod void rmaAsset_Premium_FlatViewSelection() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                  AccountId = acc.Id,
                                  Email='test@gmail.com',
                                  Phone='999999999');
        insert con;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        test.startTest();
        component__c testComponent4 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-Bezel-CS-series',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='02468',
                                                       componentType__c='BEZEL',
                                                       componentDescription__c='BEZEL');
        insert testComponent4;
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent4.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSelected','false');
        //Added by vishnu on 25th jan 2019 fro getting the paramters from the vf page.
        ApexPages.currentPage().getParameters().put('srPart','SR-USB');
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.checkboxOnChange();
        
        newRMA.partScreenSelection = 'Flat List View';
        newRMA.onPartSelectionViewChange();
        test.stopTest();
    }
    static testMethod void rmaAsset_Premium_ComponentViewSelection() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                  AccountId = acc.Id,
                                  Email='test@gmail.com',
                                  Phone='999999999');
        insert con;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        test.startTest();
        component__c testComponent4 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-Bezel-CS-series',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='02468',
                                                       componentType__c='BEZEL',
                                                       componentDescription__c='BEZEL');
        insert testComponent4;
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent4.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSelected','false');
        //Added by vishnu on 25th jan 2019 for getting the paramters from the vf page.
        ApexPages.currentPage().getParameters().put('srPart','SR-CHASSIS');
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.checkboxOnChange();
        
        newRMA.rmaNewRecord();
        newRMA.checkboxOnChange();
        newRMA.partScreenSelection = 'Component View';
        newRMA.onPartSelectionViewChange();
        test.stopTest();
    }
    static testMethod void rmaCallingMethods() {
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                  BillingStreet = 'Am Tierpark 16',
                                  BillingCity = 'Cologne',
                                  BillingPostalCode = '54321',
                                  BillingState = 'Nordrhein-Westfalen',
                                  BillingCountry = 'Germany');
        insert acc;
        Contact con = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                  AccountId = acc.Id,
                                  Email='test@gmail.com',
                                  Phone='999999999');
        insert con;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2id = prd.id,HPE_Serial_Number__c = 'HPE123457',SLA__c = 'Premium',
                               Array_Controller__c = 'AF1000',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        
        insert ass1;
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = ass1.Id,
                              ContactId = con.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        test.startTest();
        component__c testComponent4 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-Bezel-CS-series',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='02468',
                                                       componentType__c='BEZEL',
                                                       componentDescription__c='BEZEL');
        insert testComponent4;
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent4.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaOverrideShipmentPhone__c = '12345', 
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('isSelected','false');
        //Added by vishnu on 25th jan 2019 fro getting the paramters from the vf page.
        ApexPages.currentPage().getParameters().put('srPart','SR-CHASSIS');
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.checkboxOnChange();
        //newRMA.OnsiteValueForNBD('SR-USB');
        newRMA.partScreenSelection = 'Component View';
        newRMA.onPartSelectionViewChange();
        
        //added by exafort(vishnu) on 22nd Jan 2018
        newRMA.CFAOnChange();
        newRMA.clearOnsiteSectionsFields();
        newRMA.onEFASourceChange();
        newRMA.getPageDetails();
        newRMA.FirstPage();
        newRMA.LastPage();
        newRMA.previous();
        NewRMA.next();
        newRMA.getprev();
        newRMA.getnxt();
        test.stopTest();
    }
    static testMethod void rmaAsset_4HourOnsite() {
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                      BillingStreet = 'Am Tierpark 16',
                                      BillingCity = 'Cologne',
                                      BillingPostalCode = '54321',
                                      BillingState = 'Nordrhein-Westfalen',
                                      BillingCountry = 'Germany');
        insert account;
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        Asset ass1 = new Asset(Name = 'TEST-ASSET',
                               AccountId = account.Id,
                               ContactId = contact.Id,
                               Product2id = prd.id,
                               SLA__c = 'Premium 4 Hour Onsite',HPE_Serial_Number__c ='AA000000NIM',
                               Array_Controller__c = 'AF1000',
                               assetRmaShi__c = 'Asset RMA SHI',assetNrdEndDate__c = Date.today() + 10);
        insert ass1;
       
        test.startTest();
         Case aCase = new Case(AccountId = account.Id,
                              AssetId   = ass1.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        component__c testComponent4 = new component__c(componentAccountId__c = account.Id,
                                                       componentAsset__c = ass1.Id,
                                                       componentServicePartNumber__c='SR-Bezel-CS-series',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c='Unknown',
                                                       componentComponentSN__c='02468',
                                                       componentType__c='BEZEL',
                                                       componentDescription__c='BEZEL');
        insert testComponent4;
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = ass1.Id, 
                                    rmaComponentV2__c = testComponent4.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component',
                                    rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours',
                                    rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site',
                                    rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival',
                                    rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site',      
                                    rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET',
                                    rmaOverrideOnsiteArrivalCity__c = 'TESTCITY',
                                    rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222',
                                    rmaOverrideOnsiteArrivalCountry__c = 'United States',
                                    rmaOnsiteTechStatus__c = 'DRAFT-10: Waiting to order',
                                    rmaOverrideShipmentAttn__c = 'Test',
                                    rmaUplift__c = 'Scheduled',
                                    rmaDeliveryDateTime__c = DateTime.now(),
                                    rmaOverrideShipmentEmail__c = 'test1@gmail.com');
        insert rma;
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        system.debug('### SOQL Limits'+Limits.getSoslQueries());
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaEditRecord();
        newRMA.saveRMA();
        
        test.stopTest();
    }
    @isTest static void testAssetLocalDateTime(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        test.startTest();
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(2),
                                  rmaDeliveryTimes__c = '11:00 AM', rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev1(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id= prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c=false; 
        vb.CurrencyIsoCode='USD';
        vb.srmetadataIsValid__c = true;
        insert vb;
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '11:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev2(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c=false; 
        vb.CurrencyIsoCode='USD';
        vb.srmetadataIsValid__c = true;
        insert vb;
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '11:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void testAssetLocalDateTimev3(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c= True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '12:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev4(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c= True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '12:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev5(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '01:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev6(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id=prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '01:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev7(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id = prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '02:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev8(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id = prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '02:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev9(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd; 
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '03:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev10(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id = prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '03:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev11(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id = prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '04:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev12(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id = prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '04:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev13(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '05:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev130(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '05:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev14(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '06:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        newRMA.saveRMA();
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev15(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '06:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev150(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id = prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '07:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }    
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev16(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id = prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '07:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }    
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev17(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = true; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '08:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }   
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev18(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = true; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '08:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }  
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev19(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2id = prd.Id,
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '09:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }  
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev20(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '09:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }  
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev21(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '10:00 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        test.stopTest();
    }  
    @isTest(SeeAllData=true) 
    static void testAssetLocalDateTimev22(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent1;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        
        //Test.stopTest();
        //Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        
        insert addressBook = new AddressBook__c(abAccount__c = account.Id,
                                                abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                abPostalCode__c='1000',
                                                abDescription__c='Asset Install Address 1');
        
        
        test.startTest();
        
        SR_Meta_Data__c vb = new SR_Meta_Data__c();
        vb.srPart__c='No SR-Part v1';
        vb.srmetadataIsValid__c =true;
        vb.srShipOnly__c=false;
        vb.srShippingProvider__c='Nimble';
        vb.srAutoEFA__c=false;
        vb.srmetadataIsValid__c = True; 
        vb.CurrencyIsoCode='USD';
        insert vb;
        
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
                                  rmaSelection__c = 'Component',
                                  rmaDeliveryDate__c = Date.today().addDays(3),
                                  rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM',
                                  rmaDeliveryTimes__c = '10:30 PM',
                                  rmaOverrideShipmentAttn__c = 'Test',
                                  rmaOutgoingShipmentDepot__c = 'AMD-001',
                                  rmaOverrideShipmentEmail__c = 'test1@gmail.com');  
        
        
        
        PageReference pageRef = Page.rmaV2NewPageV2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(rma);
        rmav2ExtensionsWithSharingNewV2 newRMA = new rmav2ExtensionsWithSharingNewV2(sc);
        
        newRMA.rmaNewRecord();
        newRMA.getSrMetaDataOptions();
        newRMA.getOnsiteTechStatusOptions();
        newRMA.srFlatListOnChange();
        newRMA.saveRMA();
        newRMA.assetCountry = 'Australia';
        newRMA.assetLongitude = 153.0059279;
        newRMA.assetLatitude = -27.4515704;
        newRMA.assetrawOffset = 0;
        newRMA.assetdstOffset = 3000;
        newRMA.timeZoneName = 'Australia';
        newRMA.calculateGeolocationBasedOnCountry();
        newRMA.calculateAssetTimeZone();
        newRMA.clearReturnSectionFields();
        newRMA.OnsiteValueForNBD('SR-USB');
        newRMA.getOverrideSchedulingOptions();
        test.stopTest();
    }
}