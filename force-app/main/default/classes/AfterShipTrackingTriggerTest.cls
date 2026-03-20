/*
Created by by exafort for TS-6823 on 03-29-2021
This test class is referred to the AfterShipTrackingTrigger 
*/
@isTest 
public class AfterShipTrackingTriggerTest {
    
    public static testMethod void testmethod1(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
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
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,                                 
                                 Product2Id =p1.Id,SLA__c = 'Premium',
                                 Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                                 Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                                 Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                                 Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                                 assetRmaShi__c = 'Asset RMA SHI',
                                 Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test'  );
        
        
        
        
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
                                Product_Damage_Symptoms__c = 'Test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId()
                               );
        
        test.startTest();  
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c            = aCase.Id,
                                    rmaType__c                           = 'Advance replacement',
                                    rmaLabArray__c                       = 'No',
                                    rmaComponent__c                      = 'CHASSIS',
                                    rmaNimbleOsVersion__c                = 'CHASSIS: N/A',
                                    rmaModel__c                          = 'CHASSIS: CS/ES series',
                                    rmaPart__c                           = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',
                                    rmaQuantity__c                       = '1',
                                    rmaReason__c                         = 'CHASSIS: Bad controller slot',
                                    rmaManufacturer__c                   = 'Super Micro',
                                    rmaDetailedReason__c                 = 'TEST-RMA-DETAILED-REASON',
                                    rmaConfigurationDetails__c           = 'TEST-RMA-CONFIGURATION-DETAILS',
                                    rmaShipmentAddressSelector__c        = 'Asset install address',
                                    rmaOverrideShipmentPostalCode__c     = '11111',
                                    rmaOverrideShipmentCountry__c        = 'United States',
                                    rmaOverrideShipmentAttn__c           = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',
                                    rmaOverrideShipmentPhone__c          = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',
                                    rmaOverrideShipmentEmail__c          = 'test-rma-override-shipment-email@nimblestorage.com',
                                    rmaUplift__c                         = 'No: Do not uplift',
                                    rmaOutgoingShipmentStatus__c         = 'DRAFT-10: Waiting to order',
                                    rmaReturnShipmentStatus__c           = 'DRAFT-10: Waiting to order',
                                    rmaRetShip2Status__c                 = 'DRAFT-10: Waiting to order',
                                    rmaOnsiteTechStatus__c               = 'DRAFT-10: Waiting to order',
                                    rmaTransmitRmaShisWithOrder__c       = 'No SHI',
                                    rmaOutgoingShipmentCarrier__c        = 'fedex',
                                    rmaOutgoingShipmentTrackingNumber__c = 'TEST-Tracking'
                                    
                                   );
        
        insert rma;
        string rmaName = [select Id,Name from rmav2__c where Id =: rma.Id].Name;
        string testTime = String.Valueof(system.now());         
        AfterShipTracking__c   AfterShipTracking = new AfterShipTracking__c (astTrackingNumber__c = 'TEST-Tracking',astOrderId__c =rmaName,astTrackingCreatedinAfterShip__c = TRUE,astTrackingErrorMessage__c='',astTrackingCreatedTime__c= testTime);
        insert AfterShipTracking;
        AfterShipTracking.astTrackingStatus__c = 'Shipped';
        update AfterShipTracking;
        
        Test.stopTest();
        
        
    }   
}