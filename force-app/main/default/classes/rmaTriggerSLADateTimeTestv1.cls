/* Purpose: Test class to cover rmaSetSLADueDateTimeValue method in rmaTriggerHandler Class
*  Change Log: Created by Azar
*  Date : 17th Jan 2017
*  changed by: vishnu
*  27th August 2018
*/ 
@isTest(SeeAllData=true)
public class rmaTriggerSLADateTimeTestv1 {
    
    class TestData{
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        SR_Meta_Data__c srMetaData;
        Component__c testComponent1;
        
        
        TestData() {
            
            // Create test account
            account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
            System.assertNotEquals(null,              account.Id);
            System.assertEquals('Test Support Tools QA', account.Name);
            
            // Create test contact
             // Create test contact
            /*insert contact = new Contact(LastName = 'Test Exafort',
                                         AccountId = account.Id,
                                         Email='test@gmail.com',
                                         Phone='999999999');
            //contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Test Exafort' LIMIT 1];
            System.assertNotEquals(null,contact.Id);
            System.assertEquals(account.Id,contact.AccountId);
            System.assertEquals('Test Exafort', contact.LastName);*/
            Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                                 ProductCode='SSD123',
                                                 Product_Type__c='Hardware',
                                                 Product_Type_2__c='SAN Storage ArrayS',
                                                 Controller_Code__c='CS2001',
                                                 Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                 Family='SAN Storage Array');
            insert testProduct2;
            // Create test asset
            // Create test asset
            insert asset = new Asset(Name = 'TEST-ASSET',
                                     AccountId = account.Id,
                                     //ContactId = contact.Id,
                                     SLA__c = 'Premium',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                                     assetRmaShi__c = 'Asset RMA SHI',HPE_Serial_Number__c ='AA000000NIM');
            //asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' LIMIT 1];
            System.assertNotEquals(null,                      asset.Id);
            //System.assertEquals('AA-000000',                  asset.Name);
            System.assertEquals(account.Id,                 asset.AccountId);
            //System.assertEquals(contact.Id,                 asset.ContactId);
            System.assertEquals('Premium',                     asset.SLA__c);
            
            //Create test case
            //aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case1' LIMIT 1];
            insert aCase = new Case(AccountId = account.Id,
                                    AssetId   = asset.Id,
                                    //ContactId = contact.Id,
                                    Subject = 'TESTING PLEASE IGNORE Do not delete this case1');
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            //System.assertEquals(contact.Id,       aCase.ContactId);
            System.assertEquals('TESTING PLEASE IGNORE Do not delete this case1', aCase.Subject);
            
            //Create test Address Book
            //addressBook=[Select Id,Name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
                         //abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id Order BY Name LIMIT 1];
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
            
            /*test.startTest();
            insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                     componentAsset__c = asset.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='123456',
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Chassis');
            test.stopTest();*/
        }
        
        

        void insertRMADraft()
        {
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,rmaPart__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaDeliveryDateTime__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
				   From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-SSD-160GB]' LIMIT 1 FOR UPDATE];          
                   //From RMAv2__c where rmaCaseNumber__c =:aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-SSD-160GB]' LIMIT 1 FOR UPDATE];          
        }
        void insertRMADraft01()
        {
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,rmaPart__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-HDD-2TB]' AND rmaCaseNumber__r.accountId != null LIMIT 1 FOR UPDATE];          
                   //From RMAv2__c where rmaCaseNumber__c =:aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-HDD-2TB]' LIMIT 1 FOR UPDATE];          
        }
        void insertRMADraft02()
        {
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,rmaPart__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-USB]' AND rmaCaseNumber__r.accountId != null LIMIT 1];          
                   //From RMAv2__c where rmaCaseNumber__c =:aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-USB]' LIMIT 1];          
        }
/*        
        
void insertRMADraft()
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
                 rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' , rmaPart__c='[SR-SSD-160GB]');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
void insertRMADraft01()
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
                 rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' , rmaPart__c='[SR-USB]');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }

         void insertRMADraft02()
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
                 rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' , rmaPart__c='[SR-USB]');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }*/

    }
    
    @isTest static void rmaSLADateTimeAfter4PM(){
        
        TestData      testData;
        testData = new TestData(); 
        Test.startTest();
        testData.insertRMADraft02();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOverrideShipmentAttn__c = 'Test';
        testData.rma.rmaOverrideShipmentPhone__c = '9876543210';
      //  testData.rma.rmaOverrideShipmentEmail__c = 'test123@gmail.com';
        update testData.rma;
        test.stopTest();
    }
    @isTest static void rmaSLADateTimeBefore4PM(){
        TestData      testData;
        testData = new TestData();
        Test.startTest();  
        testData.insertRMADraft();
		      
        testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
		testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
		testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '3600 (1 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '3600 (1 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';  
        //update testData.rma;//commented by vishnu on April 24th 2020 to avoid 101 SOQL Issue
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        Test.stopTest();
    }
    @isTest static void rmaSLADateTimeBefore4PMMiddleEastCountries(){
        TestData      testData;
        testData = new TestData();   
        Test.startTest();
        testData.insertRMADraft01();
        
        testData.rma.Asset_Date_and_Time__c = '6/12/2018 11:51 AM';
		testData.rma.rmaAssetLocalDateTime__c = '6/12/2018 12:00 AM';
		testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '3600 (1 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '3600 (1 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';
        testData.rma.rmaOverrideShipmentCountry__c ='Iran';
        testData.rma.rmaOverrideShipmentPhone__c = '9876543210';
        update testData.rma;
        //system.assertEquals('a2D0t000001NQmf', testData.rma.id);
        /*testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;*/
        Test.stopTest();
    }
    static void rmaSLADateTimeBefore4PMMiddleEastCountries_00(){
        TestData      testData;
        testData = new TestData();
        RMAv2__c rma;
        rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,rmaPart__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-HDD-2TB]' LIMIT 1 FOR UPDATE];          
                   //From RMAv2__c where rmaCaseNumber__c =:testData.aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-HDD-2TB]' LIMIT 1 FOR UPDATE];          
        
        rma.Asset_Date_and_Time__c = '6/12/2018 11:51 AM';
		rma.rmaAssetLocalDateTime__c = '6/12/2018 12:00 AM';
		rma.rmaLatitude__c = '28.033886';
        rma.rmaLongitude__c = '1.659626000000003';
        rma.rmaTimeZoneActualOffset__c = '3600 (1 hours)';
        rma.rmaTimeZoneDSTOffset__c = '3600 (1 hours)';
        rma.rmaTimeZoneName__c = 'Pacific Standard Time';
        rma.rmaOverrideShipmentCountry__c ='Iran';
        update rma;
        //system.assertEquals('a2D0t000001NQmf', testData.rma.id);
        /*testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;*/
    }
    @isTest
    static void rmaSLADateTimeBefore4PMMiddleEastCountries_01(){
      	TestData      testData;
        testData = new TestData();
        //rmaSLADateTimeBefore4PMMiddleEastCountries_00();
        RMAv2__c rma;  
        Test.startTest();
        rma = [Select Id,Name,
                 rmaCaseNumber__c,
                 rmaDiskShelfAsset__c,
                 rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                 Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                 rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                 rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaIsComponentStatusReset__c,
                 rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
               From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-HDD-2TB]' order by createddate DESC LIMIT 1];
                 //From RMAv2__c where rmaCaseNumber__c =:testData.aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-HDD-2TB]' LIMIT 1];
        
        //system.assertEquals('a2D0t000001NQmf', rma.id);
        rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaGateKeeperStatus__c = 'Automatic';
        update rma;
        Test.stopTest();
    }
    

    /*@isTest static void rmaSLADateTimeFor4HourSLA(){
          
        TestData      testData;
        testData = new TestData();
        testData.asset.SLA__c = 'Premium 4 Hour';
        update testData.asset;
        testData.insertRMADraft();
        test.startTest();
        testData.rma.rmaRequestedDeliveryDateTime__c = string.valueOf(testData.rma.rmaDeliveryDateTime__c);    
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        test.stopTest();
    }*/
    
    @isTest static void rmaSLADateTimeForScheduledRMA(){
        TestData      testData;
        testData = new TestData();
        test.startTest();
        testData.insertRMADraft();
        
        testData.rma.rmaUplift__c = 'Scheduled';
        testData.rma.rmaDeliveryDate__c = system.today();
        testData.rma.rmaDeliveryTimes__c = '10:00 AM';
        testData.rma.rmaDeliveryDateTime__c = system.now();
        update testData.rma;
        test.stopTest();
    }
	static void rmaSLADateTimeForScheduledRMA_00(){
        TestData      testData;
        testData = new TestData();
        RMAv2__c rma;
        rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,rmaPart__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaDeliveryDateTime__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-SSD-160GB]' LIMIT 1 FOR UPDATE];          
                   //From RMAv2__c where rmaCaseNumber__c =:testData.aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-SSD-160GB]' LIMIT 1 FOR UPDATE];          
        
        rma.rmaUplift__c = 'Scheduled';
        rma.rmaDeliveryDate__c = system.today();
        rma.rmaDeliveryTimes__c = '10:00 AM';
        rma.rmaDeliveryDateTime__c = system.now();
        update rma;
   
    }
    @isTest static void rmaSLADateTimeForScheduledRMAA(){
        TestData      testData;
        testData = new TestData();
        //rmaSLADateTimeForScheduledRMA_00();
        RMAv2__c rma;
          
          Test.startTest();
          rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,rmaPart__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaDeliveryDateTime__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-SSD-160GB]' LIMIT 1 FOR UPDATE];          
                   //From RMAv2__c where rmaCaseNumber__c =:testData.aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-SSD-160GB]' LIMIT 1 FOR UPDATE];          
        
        rma.rmaRequestedDeliveryDateTime__c = string.valueOf(rma.rmaDeliveryDateTime__c);
        rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
       	rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaGateKeeperStatus__c = 'Automatic';
        update rma;
        test.stopTest();
    }
     @isTest
    static void rmaSLADateTimeBefore4PMMiddleEastCountries_011(){
      	TestData      testData;
        testData = new TestData();
        //rmaSLADateTimeBefore4PMMiddleEastCountries_00();
        RMAv2__c rma;  
        Test.startTest();
        rma = [Select Id,Name,
                 rmaCaseNumber__c,
                 rmaDiskShelfAsset__c,
                 rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                 Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                 rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                 rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaIsComponentStatusReset__c,
                 rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
               From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-HDD-2TB]' order by createddate DESC LIMIT 1];
                 //From RMAv2__c where rmaCaseNumber__c =:testData.aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-HDD-2TB]' LIMIT 1];
        
        //system.assertEquals('a2D0t000001NQmf', rma.id);
        rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaGateKeeperStatus__c = 'Automatic';
        update rma;
        Test.stopTest();
    }
}