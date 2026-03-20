@isTest(SeeAllData=true)
public class rmatriggerhandlerTest1 {
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

            Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                                 ProductCode='SSD123',
                                                 Product_Type__c='Hardware',
                                                 Product_Type_2__c='SAN Storage ArrayS',
                                                 Controller_Code__c='CS2001',
                                                 Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                 Family='SAN Storage Array');
            insert testProduct2;
            // Create test asset
            insert asset = new Asset(Name = 'TEST-ASSET',
                                     AccountId = account.Id,
                                     //ContactId = contact.Id,
                                     SLA__c = 'Premium',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                                     assetRmaShi__c = 'Asset RMA SHI',HPE_Serial_Number__c ='AA000000NIM');
            System.assertNotEquals(null,                      asset.Id);
            System.assertEquals(account.Id,                 asset.AccountId);
            System.assertEquals('Premium',                     asset.SLA__c);
            
            //Create test case
            insert aCase = new Case(AccountId = account.Id,
                                    AssetId   = asset.Id,
                                    RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId(),
                                    //ContactId = contact.Id,
                                    Subject = 'TESTING PLEASE IGNORE Do not delete this case1',
                                    Status ='New', 
                                    sub_status__c = 'Assigned',
                                    Technology_Area__c = '3rd Party Apps', Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)',  
                                    Origin = 'phone', Estimated_Effort__c = '15 minutes');
            
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            System.assertEquals('TESTING PLEASE IGNORE Do not delete this case1', aCase.Subject);
            
            //Create test Address Book
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
                   From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaStatus__c='Draft' AND rmaPart__c='[SR-SSD-160GB]' and createddate > 2019-01-01T00:00:00.000+0000 LIMIT 1 FOR UPDATE];
        }
        void insertRMADraft01()
        {
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,rmaPart__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaDeliveryDateTime__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaStatus__c='Draft' AND rmaPart__c='[SR-SSD-160GB]' and createddate > 2019-01-01T00:00:00.000+0000 LIMIT 1 FOR UPDATE];              
        }
                
        
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
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        Test.stopTest();
    }
    
    static void rmaSLADateTimeBefore4PMMiddleEastCountries_00(){
        TestData      testData;
        testData = new TestData();
        RMAv2__c rma;
        test.startTest();
        rma = [Select Id,Name,
               rmaCaseNumber__c,
               rmaDiskShelfAsset__c,rmaPart__c,
               rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
               Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
               rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
               rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
               rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
               From RMAv2__c where rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' AND rmaPart__c='[SR-HDD-2TB]' LIMIT 1 FOR UPDATE];          
        
        rma.Asset_Date_and_Time__c = '6/12/2018 11:51 AM';
        rma.rmaAssetLocalDateTime__c = '6/12/2018 12:00 AM';
        rma.rmaLatitude__c = '28.033886';
        rma.rmaLongitude__c = '1.659626000000003';
        rma.rmaTimeZoneActualOffset__c = '3600 (1 hours)';
        rma.rmaTimeZoneDSTOffset__c = '3600 (1 hours)';
        rma.rmaTimeZoneName__c = 'Pacific Standard Time';
        rma.rmaOverrideShipmentCountry__c ='Iran';
        update rma;
       test.stopTest();
    }
   
    @isTest
    static void rmaSetStatusAndTimestampsv1(){
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
               From RMAv2__c where rmaOutgoingShipmentStatus__c ='OPEN-10: Ordered, waiting for confirmation' order by createddate asc LIMIT 1];        
        rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        rma.rmaGateKeeperStatus__c = 'Automatic';
        rma.rmaTimeZoneActualOffset__c = '-28800 (-8 hours)';
        rma.rmaTimeZoneDSTOffset__c = '3600 (1 hours)';
        update rma;
        rmaTriggerHandler.rmaSetStatusAndTimestamps(rma);
        Test.stopTest();
    }
    
    @isTest
    static void rmaSetStatusAndTimestampsv2(){
        TestData      testData;
        testData = new TestData();
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
               From RMAv2__c where rmaOutgoingShipmentStatus__c ='CLOSED-10: Delivered' and rmaOnsiteCheckInCode__c != null order by createddate desc LIMIT 1];
                rma.rmaOutgoingShipmentStatus__c = 'CLOSED-10: Delivered';
        rma.rmaReturnShipmentStatus__c = 'CLOSED-10: Delivered';
        rma.rmaRetShip2Status__c = 'CLOSED-10: Delivered';
        rma.rmaOnsiteTechStatus__c = 'CLOSED-10: Delivered';        
        rma.rmaGateKeeperStatus__c = 'Automatic';
        rma.rmaTimeZoneActualOffset__c = '-28800 (-8 hours)';
        rma.rmaTimeZoneDSTOffset__c = '3600 (1 hours)';
        rma.rmaOutgoingShipmentCarrier__c = 'DHL';
        rma.rmaOutgoingShipmentDepot__c = 'AMS-005 (Amsterdam, Netherlands)';
        rma.rmaOutgoingShipmentTrackingNumber__c = 'Test12345';

        update rma;
        rmaTriggerHandler.rmaSetStatusAndTimestamps(rma);
        Test.stopTest();
    }
 
    @isTest
    static void rmaSetStatusAndTimestampsv3(){
        TestData      testData;
        testData = new TestData();
        RMAv2__c rma;  
        Test.startTest();
        rma = [Select Id,Name,
               rmaCaseNumber__c,
               rmaDiskShelfAsset__c,
               rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
               Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
               rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
               rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaIsComponentStatusReset__c,
               rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c,rmaOnsiteTechStatus__c, China_Global_Account_RMA__c
               From RMAv2__c where rmaOutgoingShipmentStatus__c= 'CANCELED-10: Canceled'  LIMIT 1];
        
        
        
        rmaTriggerHandler.rmaSetStatusAndTimestamps(rma);
        Test.stopTest();
    }
    @isTest
    static void rmaSetStatusAndTimestampsv4(){
        TestData      testData;
        testData = new TestData();
        RMAv2__c rma;  
        Test.startTest();
        rma = [Select Id,Name,
               rmaCaseNumber__c,
               rmaDiskShelfAsset__c,
               rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
               Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
               rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
               rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaIsComponentStatusReset__c,
               rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c,rmaOnsiteTechStatus__c
               From RMAv2__c  where rmaOutgoingShipmentStatus__c != 'CANCELED-10: Canceled' and rmaOutgoingShipmentStatus__c != 'CLOSED-10: Delivered' and
               rmaOutgoingShipmentStatus__c !='OPEN-10: Ordered, waiting for confirmation' limit 1];
        rma.rmaTimeZoneActualOffset__c = '-28800 (-8 hours)';
        
        
        rma.rmaOutgoingShipmentStatus__c = '';
         rma.rmaReturnShipmentStatus__c = '';
        rma.rmaRetShip2Status__c = '';
        rma.rmaOnsiteTechStatus__c = '';   
        rma.rmaTimeZoneDSTOffset__c = '3600 (1 hours)';
       // update rma;
        rmaTriggerHandler.rmaSetStatusAndTimestamps(rma);
        Test.stopTest();
    }
    
    @isTest
    static void rmaSetSLADueDateTimeValuev1(){
        TestData      testData;
        testData = new TestData();
        RMAv2__c rma;  
        Test.startTest();
        rma = [Select Id,Name,
               rmaCaseNumber__c,
               rmaDiskShelfAsset__c,rmaUplift__c,rmaDeliveryDateTime__c,
               rmaRequestedDeliveryDateTime__c,rmaSLADueDateTime__c,
               rmaTimeZoneActualOffset__c,
               rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
               Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
               rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
               rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaIsComponentStatusReset__c,
               rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c,rmaOnsiteTechStatus__c
               From RMAv2__c  where rmaOutgoingShipmentStatus__c ='OPEN-10: Ordered, waiting for confirmation' and rmaUplift__c='Scheduled'  limit 1];
        rma.rmaTimeZoneActualOffset__c = '-28800 (-8 hours)';
        
        
         
        rma.rmaTimeZoneDSTOffset__c = '3600 (1 hours)';
        update rma;
        rmaTriggerHandler.rmaSetSLADueDateTimeValue(rma);
        Test.stopTest();
    }
    
    @isTest
    static void rmaSetSLADueDateTimeValuev2(){
        TestData      testData;
        testData = new TestData();  
        Test.startTest(); 
        testData.insertRMADraft01();
               
        testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
        testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
        testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '3600 (1 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '3600 (1 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';           
        testData.rma.rmaOutgoingShipmentStatus__c = 'DRAFT-10: Waiting to order';
        testData.rma.rmaReturnShipmentStatus__c = 'DRAFT-10: Waiting to order';
        testData.rma.rmaRetShip2Status__c = 'DRAFT-10: Waiting to order';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOverrideShipmentCountry__c ='Turkey';           
        rmaTriggerHandler.rmaSetSLADueDateTimeValue(testData.rma);
        Test.stopTest();
    }
    
      @isTest static void rmaSetSLADueDateTimeValuev3(){
        TestData      testData;
        testData = new TestData();  
          Test.startTest(); 
        testData.insertRMADraft();
               
          rmaTriggerHandler.rmaDayofweek='Thursday';
        testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
        testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
        testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '-1600 (8 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '-1600 (8 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';           
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        
          
        update testData.rma;
         
        Test.stopTest();
    }
    
     @isTest static void rmaSetSLADueDateTimeValuev4(){
        TestData      testData;
        testData = new TestData();  
         Test.startTest(); 
        testData.insertRMADraft();
               
          rmaTriggerHandler.rmaDayofweek='Friday';
        testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
        testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
        testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '-1600 (8 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '-1600 (8 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';           
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
         
        Test.stopTest();
    }
    
       @isTest static void rmaSetSLADueDateTimeValuev5(){
        TestData      testData;
        testData = new TestData();
           Test.startTest(); 
        testData.insertRMADraft();
               
          rmaTriggerHandler.rmaDayofweek='Saturday';
        testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
        testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
        testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '-1600 (8 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '-1600 (8 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';           
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
         
        Test.stopTest();
    }
    
    @isTest static void rmaSetSLADueDateTimeValuev6(){
        TestData      testData;
        testData = new TestData();   
        Test.startTest();
        testData.insertRMADraft();
                
          rmaTriggerHandler.rmaDayofweek='Sunday';
        testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
        testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
        testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '-1600 (8 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '-1600 (8 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';           
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
         
        Test.stopTest();
    }
    
      @isTest static void rmaSetSLADueDateTimeValuev7(){
        TestData      testData;
        testData = new TestData(); 
          Test.startTest(); 
        testData.insertRMADraft();
               
          rmaTriggerHandler.rmaDayofweek='Monday';
        testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
        testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
        testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '8600 (12 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '8600 (12 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';           
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
         
        Test.stopTest();
    }
    
     @isTest static void rmaSetSLADueDateTimeValuev8(){
        TestData      testData;
        testData = new TestData(); 
         Test.startTest();
        testData.insertRMADraft();
                
          rmaTriggerHandler.rmaDayofweek='Thursday';
        testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
        testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
        testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '8600 (12 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '8600 (12 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';           
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
         
        Test.stopTest();
    }
    
    @isTest static void rmaSetSLADueDateTimeValuev9(){
        TestData      testData;
        testData = new TestData();  
        Test.startTest();
        testData.insertRMADraft();
                
          rmaTriggerHandler.rmaDayofweek='Friday';
        testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
        testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
        testData.rma.rmaLatitude__c = '28.033886';
        testData.rma.rmaLongitude__c = '1.659626000000003';
        testData.rma.rmaTimeZoneActualOffset__c = '8600 (12 hours)';
        testData.rma.rmaTimeZoneDSTOffset__c = '8600 (12 hours)';
        testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';           
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
         
        Test.stopTest();
    }
    
     @isTest static void rmaSetSLADueDateTimeValuev10(){
         TestData      testData;
         testData = new TestData();
         
         Test.startTest();  
         testData.insertRMADraft();
         system.debug('-->> Case Id ' +  testData.aCase.Id + ', case Recordtype ' + testData.aCase.RecordTypeId + ', RecordTypeName ' + Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(testData.aCase.RecordTypeId).getName());		
         
         CaseComment   tComment = new CaseComment();
         tComment.ParentId = testData.aCase.Id;
         tComment.CommentBody = 'Some Comment';
         tComment.IsPublished = false;
         INSERT tComment;
         
         rmaTriggerHandler.rmaDayofweek='Saturday';
         testData.rma.Asset_Date_and_Time__c = '9/13/2018 11:51 AM';
         testData.rma.rmaAssetLocalDateTime__c = '9/13/2018 12:00 AM';
         testData.rma.rmaLatitude__c = '28.033886';
         testData.rma.rmaLongitude__c = '1.659626000000003';
         testData.rma.rmaTimeZoneActualOffset__c = '8600 (12 hours)';
         testData.rma.rmaTimeZoneDSTOffset__c = '8600 (12 hours)';
         testData.rma.rmaTimeZoneName__c = 'Pacific Standard Time';           
         testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
         testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
         testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
         testData.rma.rmaGateKeeperStatus__c = 'Automatic';
         update testData.rma;
         
         Test.stopTest();
    }    
}