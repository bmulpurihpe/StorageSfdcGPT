@isTest

public class rmaTriggerActivateTestclass
  {
      public static case cs;
      public static AddressBook__c  ad;
      
      
      static void testData(){
          account acc = new account();
          acc.Name = 'Test account';
          
      
      insert acc;
          
          
          contact co = new contact();
          co.LastName = 'TEST-CONTACT-LAST-NAME';
          co.AccountId = acc.id;
          
           insert co;
         
          
          Asset ass = new Asset();
          ass.Name ='test asset';  
          ass.AccountId = acc.id;
          ass.ContactId =co.Id ;
          ass.SLA__c ='Premium';
          ass.Install_Street1__c='TEST-ASSET-INSTALL-STREET1';
          ass.Install_Street2__c= 'TEST-ASSET-INSTALL-STREET2';
              ass.Install_City__c='TEST-ASSET-INSTALL-CITY';
          ass.Install_State_Province__c='TEST-ASSET-INSTALL-STATE';
              ass.HPE_Serial_Number__c='AA000000NIM';
          ass.assetRmaShi__c='AssetTestShi';
       
               insert ass;
          
          cs = new case();
         
          cs.AccountId = acc.id;
          cs.AssetId = ass.id;
          cs.ContactId =co.Id ;
          cs.Subject = 'newtest';
          insert cs;
          
          depot__c dp = new depot__c();
          dp.Name = 'test001';
          dp.depotProvider__c = 'Nimble';
          dp.depotStockedFor4Hour__c = 'No';
          dp.depotLocationDescription__c = 'testdepot001';
         
          
          insert dp;
          
          ActivateTrigger__c at = new ActivateTrigger__c    ();
          at.RMATrigger__c = True;
            insert at;
          
          
          ad = new AddressBook__c();
          ad.abAccount__c = acc.id;
          ad.abDescription__c ='new addressbook for test';
          ad.abStreet1__c= 'old number';
          ad.abStreet2__c='new number';
          ad.abStateProvince__c='tamilanadu';
          ad.abPostalCode__c='600078';
          insert ad;
          
         
          
                   
          }
          static testMethod void testRMAInsert(){
          
          testData();
          Test.startTest();
          RMAv2__c rma = new RMAv2__c();
          
         rma.rmaType__c = 'Advance replacement';
                         rma.rmaLabArray__c                   = 'No';
                         rma.rmaComponent__c                  = 'CHASSIS';
                         rma.rmaNimbleOsVersion__c            = 'CHASSIS: N/A';
                         rma.rmaModel__c                      = 'CHASSIS: CS/ES series';
                         rma.rmaPart__c                       = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]';
                         rma.rmaQuantity__c                   = '1';
                         rma.rmaReason__c                     = 'CHASSIS: Bad controller slot';
                         rma.rmaManufacturer__c               = 'Super Micro';
                         rma.rmaDetailedReason__c             = 'TEST-RMA-DETAILED-REASON';
                         rma.rmaConfigurationDetails__c       = 'TEST-RMA-CONFIGURATION-DETAILS';
                         rma.rmaShipmentAddressSelector__c    = 'Asset install address';
                         rma.rmaOverrideShipmentPostalCode__c = '11111';
                         rma.rmaOverrideShipmentCountry__c    = 'United States';
                         rma.rmaOverrideShipmentAttn__c       = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN';
                         rma.rmaOverrideShipmentPhone__c      = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE';
                         rma.rmaOverrideShipmentEmail__c      = 'test-rma-override-shipment-email@nimblestorage.com';
                         rma.rmaUplift__c                     = 'No: Do not uplift';
                         rma.rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order';
                         rma.rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order';
                         rma.rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order';
                         rma.rmaTransmitRmaShisWithOrder__c   = 'No SHI';
                         rma.rmaOverrideShipmentAccountName__c = 'new';
          rma.rmaAddOverriddenAddressToAddressBook__c = TRUE ;
          rma.rmaAddressBook__c = ad.Id;
          rma.rmaCaseNumber__c = cs.Id;
          rma.rmaFaRequired__c = 'Engineering FA';
          rma.rmaUplift__c = 'No: Do not uplift';
          rma.rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order';
          rma.rmaReturnShipmentStatus__c = 'DRAFT-10: Waiting to order';
         
          insert rma;
           Test.stopTest();
          
          List<ActivateTrigger__c>  atList = [Select Id, RMATrigger__c from ActivateTrigger__c];
          System.assertEquals(1,atList.size());
          System.assertEquals(true,atList[0].RMATrigger__c);
          
          
          }
  }