/*
* Added by:Vishnu on 24th April 2020.
* This covers the SR Part Min Required OS version logic in rmaTriggerHandler.
*/
@isTest
public class rmaTriggerSrPartMinReqOsVersion {
    
    class TestData {
        Account account;
        Contact contact;
        SR_Meta_Data__c srMetaData01;
        SR_Meta_Data__c srMetaData02;
        SR_Meta_Data__c srMetaData03;
        ActivateTrigger__c  activateTriggerCustomSetting;
        
        TestData() {  
            //check the custom setting value set for the rma trigger to run.
            insert activateTriggerCustomSetting = new ActivateTrigger__c(RMATrigger__c = True);
            
            // Create test account
            insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
            
            // Create test contact
            /*insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                         AccountId = account.Id,
                                         Email='test@gmail.com',
                                         Phone='999999999');*/
        }
        void insertSRMetaDataWithMinOsVersion(){
            insert srMetaData01 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',srmetadataIsValid__c = True,
                                                      srType__c = 'HDD',
                                                      srMinimumVersionRequired__c = '5.0.9.0',
                                                      srNimbleOSversionExceptions__c = null,
                                                      srShippingProvider__c='Flash');
        }
        void insertSRMetaDataWithOSversionException(){
            insert srMetaData02 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',srmetadataIsValid__c = True,
                                                      srType__c = 'HDD',
                                                      srMinimumVersionRequired__c = '5.0.9.0',
                                                      srNimbleOSversionExceptions__c = '5.1.3.0',
                                                      srShippingProvider__c='Flash');
        }
        void insertSRMetaDataWithOSversionExceptions(){
            insert srMetaData03 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',srmetadataIsValid__c = True,
                                                      srType__c = 'HDD',
                                                      srMinimumVersionRequired__c = '5.0.9.0',
                                                      srNimbleOSversionExceptions__c = '5.1.0.0 - 5.1.4.100',
                                                      srShippingProvider__c='Flash');
        }
    }
    @isTest static void srPartWithMinOSversion(){
        
        TestData      testData;
        testData = new TestData();
    //    testData.insertSRMetaDataWithMinOsVersion();
          SR_Meta_Data__c srMetaDataValue1 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',
                                                           srType__c = 'HDD',
                                                           srShippingProvider__c='Flash');
        
        SR_Meta_Data__c srMetaDataValue2 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-2TB',
                                                           srType__c = 'HDD',
                                                           srShippingProvider__c='Flash');
        Insert srMetaDataValue1;
        Insert srMetaDataValue2;
        RMASubstitution__c rmaSubstitution01 = new RMASubstitution__c (OldPart__c = srMetaDataValue1.Id, 
                                                               NewPart__c = srMetaDataValue2.Id ,
                                                               NimbleOsVersionFrom__c= null,
                                                               Support_Profile__c = 'Legacy Nimble',
                                                               NimbleOsVersionTo__c='2.2.2.2',
                                                               IncludeToNimbleOsInSubstitution__c=true);
        Insert rmaSubstitution01;
        Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                             ProductCode='SSD123',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage ArrayS',
                                             Controller_Code__c='CS2001',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct2;
        Test.startTest();
        // Create test asset
        Asset asset = new Asset(Name = 'TEST-ASSET',
                                AccountId = testData.account.Id,
                                //ContactId = testData.contact.Id,
                                SLA__c = 'Premium',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                                Nimble_Version__c ='5.0.9.100',
                                HPE_Serial_Number__c = 'AA000000NIM',
                                assetRmaShi__c = 'Asset RMA SHI');
        insert asset;
        
        // Create test case
        Case aCase = new Case(AccountId = testData.account.Id,
                              AssetId   = asset.Id,
                              //ContactId = testData.contact.Id,
                              Nimble_Version__c = '5.1.3.0',
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        //Insert Component
        component__c component = new component__c(componentAccountId__c = testData.account.Id,
                                                  componentAsset__c = asset.Id,
                                                  componentServicePartNumber__c='SR-HDD-1TB',
                                                  componentState__c = 'Shipped',
                                                  Sub_State__c='Unknown',
                                                  componentComponentSN__c='123456',
                                                  componentType__c='HDD',
                                                  componentDescription__c='HDD');
        insert component;
        Test.stopTest();
        //Insert Address Book
       AddressBook__c addressBook = new AddressBook__c(abAccount__c = testData.account.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        //Insert RMA
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = asset.Id, rmaOverrideShipmentPhone__c = '9876543210',
                                    rmaComponentV2__c = component.Id,rmaOverrideShipmentEmail__c = 'test@test.com',
                                    rmaAddressBook__c = addressBook.Id,rmaOverrideShipmentAttn__c = 'test',
                                    rmaSelection__c = 'Component');
        insert rma;
        //List<RMAv2__c> rmas;
        /*rmas = [SELECT Id,
                rmaPartNumber__c 
                FROM   RMAv2__c];*/
       
        
        //System.assertEquals(1, rmas.size());
        //System.assertEquals('SR-HDD-1TB',      rmas[0].rmaPartNumber__c);
    }
    @isTest static void srPartWithMinOSversion_01(){
        TestData      testData;
        Exception dmlException;
        testData = new TestData();
        testData.insertSRMetaDataWithMinOsVersion();
        Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                             ProductCode='SSD123',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage ArrayS',
                                             Controller_Code__c='CS2001',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct2;
        // Create test asset
        Asset asset = new Asset(Name = 'TEST-ASSET',
                                AccountId = testData.account.Id,
                                //ContactId = testData.contact.Id,
                                SLA__c = 'Premium',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                                Nimble_Version__c ='5.0.8.100',
                                HPE_Serial_Number__c = 'AA000000NIM',
                                assetRmaShi__c = 'Asset RMA SHI');
        insert asset;
        Test.startTest();
        // Create test case
        Case aCase = new Case(AccountId = testData.account.Id,
                              AssetId   = asset.Id,
                              //ContactId = testData.contact.Id,
                              Nimble_Version__c = '5.0.8.0',
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        //Insert Component
        component__c component = new component__c(componentAccountId__c = testData.account.Id,
                                                  componentAsset__c = asset.Id,
                                                  componentServicePartNumber__c='SR-HDD-1TB',
                                                  componentState__c = 'Shipped',
                                                  Sub_State__c='Unknown',
                                                  componentComponentSN__c='123456',
                                                  componentType__c='HDD',
                                                  componentDescription__c='HDD');
        insert component;
        
        //Insert Address Book
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = testData.account.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        //Insert RMA
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = asset.Id, 
                                    rmaComponentV2__c = component.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component');
        try{
            insert rma; 
        }catch(Exception e){
            dmlException = e;
        }
        Test.stopTest();
        System.assertNotEquals(null, dmlException);
        System.assert(dmlException instanceOf system.Dmlexception);
        //System.assert(dmlException.getMessage().contains('Error'));
        System.assert(dmlException.getMessage().contains('<b> DO NOT SHIP THIS PART..! </b>'
                                                         +'</br> The part selected is not compatible with this version of Nimble OS reported by the array and case.'
                                                         +'</br> Select a different part to fulfill the RMA request.'));
    }
    @isTest static void srPartWithMinOSversion_02(){
        TestData      testData;
        testData = new TestData();
        testData.insertSRMetaDataWithOSversionException();
        Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                             ProductCode='SSD123',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage ArrayS',
                                             Controller_Code__c='CS2001',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct2;
        // Create test asset
        Asset asset = new Asset(Name = 'TEST-ASSET',
                                AccountId = testData.account.Id,
                                //ContactId = testData.contact.Id,
                                SLA__c = 'Premium',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                                Nimble_Version__c ='5.0.9.100',
                                HPE_Serial_Number__c = 'AA000000NIM',
                                assetRmaShi__c = 'Asset RMA SHI');
        insert asset;
        
        // Create test case
        Case aCase = new Case(AccountId = testData.account.Id,
                              AssetId   = asset.Id,
                              //ContactId = testData.contact.Id,
                              Nimble_Version__c = '5.0.9.0',
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        Test.startTest();
        //Insert Component
        component__c component = new component__c(componentAccountId__c = testData.account.Id,
                                                  componentAsset__c = asset.Id,
                                                  componentServicePartNumber__c='SR-HDD-1TB',
                                                  componentState__c = 'Shipped',
                                                  Sub_State__c='Unknown',
                                                  componentComponentSN__c='123456',
                                                  componentType__c='HDD',
                                                  componentDescription__c='HDD');
        insert component;
        
        //Insert Address Book
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = testData.account.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        //Insert RMA
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = asset.Id, rmaOverrideShipmentPhone__c = '9876543210',
                                    rmaComponentV2__c = component.Id,rmaOverrideShipmentEmail__c = 'test@test.com',
                                    rmaAddressBook__c = addressBook.Id,rmaOverrideShipmentAttn__c = 'test',
                                    rmaSelection__c = 'Component');
        insert rma;
        List<RMAv2__c> rmas;
        rmas = [SELECT Id,
                rmaPartNumber__c 
                FROM   RMAv2__c];
        Test.stopTest();
        System.assertEquals(1, rmas.size());
        System.assertEquals('SR-HDD-1TB',      rmas[0].rmaPartNumber__c);
    }
    @isTest static void srPartWithMinOSversion_03(){
        TestData      testData;
        testData = new TestData();
        testData.insertSRMetaDataWithOSversionExceptions();
        Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                             ProductCode='SSD123',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage ArrayS',
                                             Controller_Code__c='CS2001',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct2;
        // Create test asset
        Asset asset = new Asset(Name = 'TEST-ASSET',
                                AccountId = testData.account.Id,
                                //ContactId = testData.contact.Id,
                                SLA__c = 'Premium',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                                Nimble_Version__c ='5.0.9.5',
                                HPE_Serial_Number__c = 'AA000000NIM',
                                assetRmaShi__c = 'Asset RMA SHI');
        insert asset;
        Test.startTest();
        // Create test case
        Case aCase = new Case(AccountId = testData.account.Id,
                              AssetId   = asset.Id,
                              //ContactId = testData.contact.Id,
                              Nimble_Version__c = '5.0.9.0',
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        //Insert Component
        component__c component = new component__c(componentAccountId__c = testData.account.Id,
                                                  componentAsset__c = asset.Id,
                                                  componentServicePartNumber__c='SR-HDD-1TB',
                                                  componentState__c = 'Shipped',
                                                  Sub_State__c='Unknown',
                                                  componentComponentSN__c='123456',
                                                  componentType__c='HDD',
                                                  componentDescription__c='HDD');
        insert component;
        
        //Insert Address Book
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = testData.account.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
        //Insert RMA
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = asset.Id,rmaOverrideShipmentAttn__c = 'test', 
                                    rmaComponentV2__c = component.Id,rmaOverrideShipmentEmail__c = 'test@test.com',
                                    rmaAddressBook__c = addressBook.Id,rmaOverrideShipmentPhone__c = '9876543210',
                                    rmaSelection__c = 'Component');
        insert rma;
        List<RMAv2__c> rmas;
        rmas = [SELECT Id,
                rmaPartNumber__c 
                FROM   RMAv2__c];
        Test.stopTest();
        System.assertEquals(1, rmas.size());
        System.assertEquals('SR-HDD-1TB',      rmas[0].rmaPartNumber__c);
    }
    @isTest static void srPartWithMinOSversion_04(){
        TestData      testData;
        Exception dmlException;
        testData = new TestData();
        testData.insertSRMetaDataWithOSversionExceptions();
        Test.startTest();
        Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                             ProductCode='SSD123',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage ArrayS',
                                             Controller_Code__c='CS2001',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct2;
        // Create test asset
        Asset asset = new Asset(Name = 'TEST-ASSET',
                                AccountId = testData.account.Id,
                                //ContactId = testData.contact.Id,
                                SLA__c = 'Premium',Array_Controller__c = 'AF1000',Product2Id = testProduct2.id,
                                Nimble_Version__c ='5.0.9.100',
                                HPE_Serial_Number__c = 'AA000000NIM',
                                assetRmaShi__c = 'Asset RMA SHI');
        insert asset;
        
        // Create test case
        Case aCase = new Case(AccountId = testData.account.Id,
                              AssetId   = asset.Id,
                              //ContactId = testData.contact.Id,
                              Nimble_Version__c = '5.1.3.0',
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        //Insert Component
        component__c component = new component__c(componentAccountId__c = testData.account.Id,
                                                  componentAsset__c = asset.Id,
                                                  componentServicePartNumber__c='SR-HDD-1TB',
                                                  componentState__c = 'Shipped',
                                                  Sub_State__c='Unknown',
                                                  componentComponentSN__c='123456',
                                                  componentType__c='HDD',
                                                  componentDescription__c='HDD');
        insert component;
        Test.stopTest();
        //Insert Address Book
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = testData.account.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                        abPostalCode__c='1000',
                                                        abDescription__c='Asset Install Address 1');
        insert addressBook;
       
        //Insert RMA
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = asset.Id, 
                                    rmaComponentV2__c = component.Id,
                                   rmaAddressBook__c = addressBook.Id,
                                    rmaSelection__c = 'Component');
        try{
            insert rma; 
         
        }catch(Exception e){
            dmlException = e;
        }
        System.assertNotEquals(null, dmlException);
        System.assert(dmlException instanceOf system.Dmlexception);
        //System.assert(dmlException.getMessage().contains('Error'));
        System.assert(dmlException.getMessage().contains('<b> DO NOT SHIP THIS PART..! </b>'
                                                        +'</br> The part selected is not compatible with this version of Nimble OS reported by the array and case.'
                                                        +'</br> Select a different part to fulfill the RMA request.'));
    }
    
    
}