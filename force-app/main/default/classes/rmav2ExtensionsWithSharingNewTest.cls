@isTest
public class rmav2ExtensionsWithSharingNewTest {
    
    class TestData {
        Account          account;
        Contact          contact;
        Asset            asset01;
        Case             aCase;
        RMAv2__c         rma;
        AddressBook__c ab01;
        AddressBook__c ab02;
        
        List<Account>          accounts;
        List<Contact>          contacts;
        List<Asset>            assets;
        List<Case>             cases;
        List<RMAv2__c>         rmas;
        List<AddressBook__c>          abs;
        
        TestData()
        {
            // Create test account
            account = new Account(Name = 'TEST-ACCOUNT');
            insert account;
            accounts = [SELECT Id,
                        Name
                        FROM   Account
                        WHERE  Name = 'TEST-ACCOUNT'];
            
            System.assertEquals(1,              accounts.size());
            System.assertEquals('TEST-ACCOUNT', accounts[0].Name);
            
            
            //Create AdressBookEntries 01
            ab01 = new AddressBook__c(abAccount__c= account.Id,
                                      abStreet1__c = 'STREET1',
                                      abStreet2__c = 'STREET2',
                                      abCity__c='CITY',
                                      abCountry__c='India',
                                      abPostalCode__c = '600000',
                                      abStateProvince__c='STATE',
                                      abDescription__c = 'TEST DESCRIPTION');
            
            
            insert ab01;
            
            abs = [SELECT Id,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abPostalCode__c,abCountry__c,abDescription__c
                   FROM   AddressBook__c where abDescription__c='TEST DESCRIPTION'];
            
            System.assertEquals('STREET1', abs[0].abStreet1__c);
            System.assertEquals('STREET2', abs[0].abStreet2__c);
            System.assertEquals('CITY', abs[0].abCity__c);
            System.assertEquals('STATE', abs[0].abStateProvince__c);
            System.assertEquals('TEST DESCRIPTION', abs[0].abDescription__c);
            
            //Create AdressBookEntries 02
            ab02 = new AddressBook__c(abAccount__c= account.Id,
                                      abStreet1__c = 'AB02 STREET 1',
                                      abStreet2__c = 'AB02 STREET 2',
                                      abCity__c='AB02 CITY',
                                      abCountry__c='India',
                                      abPostalCode__c = '500000',
                                      abStateProvince__c='AB02 STATE',
                                      abDescription__c = 'AB02 DESCRIPTION');
            
            
            insert ab02;
            
            abs = [SELECT Id,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abPostalCode__c,abCountry__c,abDescription__c
                   FROM   AddressBook__c where abDescription__c='AB02 DESCRIPTION'];
            
            System.assertEquals('AB02 STREET 1', abs[0].abStreet1__c);
            System.assertEquals('AB02 STREET 2', abs[0].abStreet2__c);
            System.assertEquals('AB02 CITY', abs[0].abCity__c);
            System.assertEquals('AB02 STATE', abs[0].abStateProvince__c);
            System.assertEquals('AB02 DESCRIPTION', abs[0].abDescription__c);
            

            
            // Create test contact
            contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',Email ='contact@test.com',Phone='9999999999',
                                  AccountId = account.Id);
            insert contact;
            contacts = [SELECT Id,
                        LastName,
                        Email,
                        Phone,
                        AccountId
                        FROM   Contact
                        WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
            
            System.assertEquals(1,                        contacts.size());
            System.assertEquals('TEST-CONTACT-LAST-NAME', contacts[0].LastName);
            System.assertEquals('contact@test.com', contacts[0].Email);
            System.assertEquals('9999999999', contacts[0].Phone);
            System.assertEquals(account.Id,            contacts[0].AccountId);
            
            // Create test asset 01
            asset01 = new Asset(Name = 'TEST-ASSET',
                              AccountId = account.Id,
                              ContactId = contact.Id,
                              assetPartShipAddressBook__c = ab02.Id,
                              assetPartShipLastValidatedDatetime__c = Date.today(),
                              SLA__c = 'Premium',
                              Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                              Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                              Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                              Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',assetNrdEndDate__c = Date.today() + 10);
            insert asset01;
            assets = [SELECT Id,
                      Name,
                      AccountId,
                      ContactId,
                      SLA__c,
                      Install_Street1__c,
                      Install_Street2__c,
                      Install_City__c,assetNrdEndDate__c,
                      Install_State_Province__c
                      
                      FROM   Asset
                      WHERE  Name = 'TEST-ASSET'];
            
            System.assertEquals(1,                             assets.size());
            System.assertEquals('TEST-ASSET',                  assets[0].Name);
            System.assertEquals(account.Id,                 assets[0].AccountId);
            System.assertEquals(contact.Id,                 assets[0].ContactId);
            System.assertEquals('Premium',                     assets[0].SLA__c);
            System.assertEquals('TEST-ASSET-INSTALL-STREET1',  assets[0].Install_Street1__c);
            System.assertEquals('TEST-ASSET-INSTALL-STREET2',  assets[0].Install_Street2__c);
            System.assertEquals('TEST-ASSET-INSTALL-CITY',     assets[0].Install_City__c);
            System.assertEquals('TEST-ASSET-INSTALL-STATE',    assets[0].Install_State_Province__c);
            System.assertEquals(Date.today() + 10,    assets[0].assetNrdEndDate__c);

            
            // Create test case
            aCase = new Case(AccountId = account.Id,
                             AssetId   = asset01.Id,
                             ContactId = contact.Id,
                             Subject = 'TEST-CASE-SUBJECT');
            insert aCase;
            cases = [SELECT Id,
                     AccountId,
                     AssetId,
                     ContactId,
                     Subject
                     FROM   Case
                     WHERE  Subject = 'TEST-CASE-SUBJECT'];
            
            System.assertEquals(1,                   cases.size());
            System.assertEquals(account.Id,       cases[0].AccountId);
            System.assertEquals(asset01.Id,         cases[0].AssetId);
            System.assertEquals(contact.Id,       cases[0].ContactId);
            System.assertEquals('TEST-CASE-SUBJECT', cases[0].Subject);
            
            
            // Create test RMA
            rma = new RMAv2__c(rmaCaseNumber__c                 = acase.Id,
                               rmaType__c                       = 'Advance replacement',
                               rmaLabArray__c                   = 'No',
                               rmaComponent__c                  = 'CHASSIS',
                               rmaNimbleOsVersion__c            = 'CHASSIS: N/A',
                               rmaModel__c                      = 'CHASSIS: CS/ES series',
                               rmaPart__c                       = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',
                               rmaQuantity__c                   = '1',
                               rmaReason__c                     = 'CHASSIS: Bad controller slot',
                               rmaManufacturer__c               = 'Super Micro',
                               rmaDetailedReason__c             = 'TEST-RMA-DETAILED-REASON',
                               rmaConfigurationDetails__c       = 'TEST-RMA-CONFIGURATION-DETAILS',
                               rmaAddressBook__c                =  ab02.Id,
                               rmaOverrideShipmentPostalCode__c = '666666',
                               rmaOverrideShipmentCountry__c    = 'India',
                               rmaOverrideShipmentAttn__c       = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',
                               rmaOverrideShipmentPhone__c      = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',
                               rmaOverrideShipmentEmail__c      = 'test-rma-override-shipment-email@nimblestorage.com',
                               rmaUplift__c                     = 'No: Do not uplift',
                               rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                               rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                               rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                               rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order',
                               rmaTransmitRmaShisWithOrder__c   = 'No SHI');
            insert rma;
            rmas = [SELECT Id,
                    rmaCaseNumber__c,
                    rmaType__c,
                    rmaLabArray__c,
                    rmaComponent__c,
                    rmaNimbleOsVersion__c,
                    rmaModel__c,
                    rmaPart__c,
                    rmaQuantity__c,
                    rmaAddressBook__c,
                    rmaReason__c,
                    rmaManufacturer__c,
                    rmaDetailedReason__c,
                    rmaConfigurationDetails__c,
                    rmaShipmentAddressSelector__c,
                    rmaOverrideShipmentPostalCode__c,
                    rmaOverrideShipmentCountry__c,
                    rmaOverrideShipmentAttn__c,
                    rmaOverrideShipmentPhone__c,
                    rmaOverrideShipmentEmail__c,
                    rmaUplift__c,
                    rmaOutgoingShipmentStatus__c,
                    rmaReturnShipmentStatus__c
                    FROM   RMAv2__c];
            
            System.assertEquals(1,                                                        rmas.size());
            System.assertEquals(acase.Id,                                               rmas[0].rmaCaseNumber__c);
            System.assertEquals('Advance replacement',                                    rmas[0].rmaType__c);
            System.assertEquals('No',                                                     rmas[0].rmaLabArray__c);
            System.assertEquals('CHASSIS' ,                                               rmas[0].rmaComponent__c);
            System.assertEquals('CHASSIS: N/A',                                           rmas[0].rmaNimbleOsVersion__c);
            System.assertEquals('CHASSIS: CS/ES series',                                  rmas[0].rmaModel__c);
            System.assertEquals('CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',      rmas[0].rmaPart__c);
            System.assertEquals('1',                                                      rmas[0].rmaQuantity__c);
            System.assertEquals('CHASSIS: Bad controller slot',                           rmas[0].rmaReason__c);
            System.assertEquals('Super Micro',                                            rmas[0].rmaManufacturer__c);
            System.assertEquals('TEST-RMA-DETAILED-REASON',                               rmas[0].rmaDetailedReason__c);
            System.assertEquals(ab02.Id,                                                 rmas[0].rmaAddressBook__c);
            System.assertEquals('TEST-RMA-CONFIGURATION-DETAILS',                         rmas[0].rmaConfigurationDetails__c);
            System.assertEquals('666666',                                                  rmas[0].rmaOverrideShipmentPostalCode__c);
            System.assertEquals('India',                                          rmas[0].rmaOverrideShipmentCountry__c);
            System.assertEquals('TEST-RMA-OVERRIDE-SHIPMENT-ATTN',                        rmas[0].rmaOverrideShipmentAttn__c);
            System.assertEquals('TEST-RMA-OVERRIDE-SHIPMENT-PHONE',                       rmas[0].rmaOverrideShipmentPhone__c);
            System.assertEquals('test-rma-override-shipment-email@nimblestorage.com',     rmas[0].rmaOverrideShipmentEmail__c);
            System.assertEquals('No: Do not uplift',                                      rmas[0].rmaUplift__c);
            System.assertEquals('DRAFT-10: Waiting to order',                             rmas[0].rmaOutgoingShipmentStatus__c);
            System.assertEquals('DRAFT-10: Waiting to order',                             rmas[0].rmaReturnShipmentStatus__c);
        }
        
        void updateOnsiteAsset() {
             asset01.SLA__c = 'Premium 4 Hour Onsite';
             update asset01;
        }
        
        
    }
    
    static testMethod void rmaNewCaseBasedAsset()
    { RMAv2__c rmas;
     ID testRmaId;
     
     TestData testData = new TestData();
     
     rmas = [SELECT Id,
             rmaCaseNumber__c,
             rmaType__c,
             rmaLabArray__c,
             rmaComponent__c,
             rmaNimbleOsVersion__c,
             rmaModel__c,
             rmaPart__c,
             rmaQuantity__c,
             rmaAddressBook__c,
             rmaReason__c,
             rmaManufacturer__c,
             rmaDetailedReason__c,
             rmaConfigurationDetails__c,
             rmaUplift__c,
             rmaOutgoingShipmentStatus__c,
             rmaReturnShipmentStatus__c,
             rmaOutgoingShipmentDateTimeOpened__c,
             rmaShowOnSiteSectionsAlways__c
             FROM   RMAv2__c];
     rmas.Id = null;
     
     ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
     rmav2ExtensionsWithSharingNew newRMA = new rmav2ExtensionsWithSharingNew(sc);
     
     PageReference pageRef = Page.rmaV2NewPage;
     //pageRef.getParameters().put('id', String.valueOf(rmas.Id));
     Test.setCurrentPage(pageRef);
     
     newRMA.assetOnChange();
     newRMA.addressBookOnChange();
     newRMA.populateAddressFields();
     newRMA.getAddressOptions();
     newRMA.showOnSiteSectionOnChange();
     newRMA.SaveRMA();
     
     System.assertEquals('Attn: TEST-CONTACT-LAST-NAME', newRMA.shpLabelAssetContact);
     System.assertEquals('Contact Phone: 9999999999', newRMA.shpLabelContactPhone);
     System.assertEquals('Contact Email: contact@test.com', newRMA.shpLabelContactEmail);
     System.assertEquals(Date.today(), newRMA.shpLocationValidationOn);
     System.assertEquals(testData.ab02.Id, newRMA.addressBookLinkedId);
     System.assertEquals(true, newRMA.hideOnSiteSections);
     System.assertEquals('TEST-ACCOUNT', newRMA.shpAccountName);
     System.assertEquals('AB02 STREET 1', newRMA.shpLabelStreet1);
     System.assertEquals('AB02 STREET 2', newRMA.shpLabelStreet2);
     System.assertEquals('India', newRMA.shpLabelCountry);
     System.assertEquals('AB02 CITY, ', newRMA.shpLabelCity);
     System.assertEquals('AB02 STATE', newRMA.shpLabelState);
     System.assertEquals('500000', newRMA.shpLabelPostalCode);
     System.assertNotEquals(true, newRMA.alwaysShownOnSiteSection);
    }
    
    
    static testMethod void rmaNewDiskShelfAsset()
    { RMAv2__c rmas;
     ID testRmaId;
     
     TestData testData = new TestData();
     Test.startTest();
     rmas = [SELECT Id,rmaModel__c,rmaDiskShelfAsset__c FROM   RMAv2__c];
     rmas.rmaModel__c = 'CHASSIS: ES1 series';
     rmas.rmaDiskShelfAsset__c =testData.asset01.Id;
     
     update rmas; 
     
     rmas = [SELECT Id,
             rmaCaseNumber__c,
             rmaType__c,
             rmaLabArray__c,
             rmaComponent__c,
             rmaFaRequired__c,
             rmaNimbleOsVersion__c,
             rmaModel__c,
             rmaPart__c,
             rmaDiskShelfAsset__c,
             rmaQuantity__c,
             rmaAddressBook__c,
             rmaReason__c,
             rmaManufacturer__c,
             rmaDetailedReason__c,
             rmaConfigurationDetails__c,
             rmaUplift__c,
             rmaOutgoingShipmentStatus__c,
             rmaReturnShipmentStatus__c,
             rmaOutgoingShipmentDateTimeOpened__c,
             rmaShowOnSiteSectionsAlways__c
             FROM   RMAv2__c];
     
     ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
     rmav2ExtensionsWithSharingNew newRMA = new rmav2ExtensionsWithSharingNew(sc);
     
     PageReference pageRef = Page.rmaV2NewPage;
     //pageRef.getParameters().put('id', String.valueOf(rmas.Id));
     Test.setCurrentPage(pageRef);
     
     newRMA.assetOnChange();
     newRMA.addressBookOnChange();
     newRMA.populateAddressFields();
     newRMA.getAddressOptions();
     newRMA.showOnSiteSectionOnChange();
     newRMA.SaveRMA();
      Test.stopTest();
     System.assertEquals('Attn: TEST-CONTACT-LAST-NAME', newRMA.shpLabelAssetContact);
     System.assertEquals('Contact Phone: 9999999999', newRMA.shpLabelContactPhone);
     System.assertEquals('Contact Email: contact@test.com', newRMA.shpLabelContactEmail);
     System.assertEquals(Date.today(), newRMA.shpLocationValidationOn);
     System.assertEquals(testData.ab02.Id, newRMA.addressBookLinkedId);
     System.assertEquals(true, newRMA.hideOnSiteSections);
     System.assertEquals('TEST-ACCOUNT', newRMA.shpAccountName);
     System.assertEquals('AB02 STREET 1', newRMA.shpLabelStreet1);
     System.assertEquals('AB02 STREET 2', newRMA.shpLabelStreet2);
     System.assertEquals('India', newRMA.shpLabelCountry);
     System.assertEquals('AB02 CITY, ', newRMA.shpLabelCity);
     System.assertEquals('AB02 STATE', newRMA.shpLabelState);
     System.assertEquals('500000', newRMA.shpLabelPostalCode);
     System.assertNotEquals(true, newRMA.alwaysShownOnSiteSection);
    }
    
    static testMethod void rmaEditCaseBasedAsset()
    { RMAv2__c rmas;
     ID testRmaId;
     
     TestData testData = new TestData();
     test.startTest();
     
     rmas = [SELECT Id,
             rmaCaseNumber__c,
             rmaType__c,
             rmaLabArray__c,
             rmaComponent__c,
             rmaFaRequired__c,
             rmaNimbleOsVersion__c,
             rmaModel__c,
             rmaPart__c,
             rmaQuantity__c,
             rmaAddressBook__c,
             rmaReason__c,
             rmaManufacturer__c,
             rmaDetailedReason__c,
             rmaConfigurationDetails__c,
             rmaUplift__c,
             rmaOutgoingShipmentStatus__c,
             rmaReturnShipmentStatus__c,
             rmaOutgoingShipmentDateTimeOpened__c,
             rmaShowOnSiteSectionsAlways__c
             FROM   RMAv2__c];
     
     update rmas;
     test.stopTest();
     
     ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
     rmav2ExtensionsWithSharingNew newRMA = new rmav2ExtensionsWithSharingNew(sc);
     
     PageReference pageRef = Page.rmaV2NewPage;
     pageRef.getParameters().put('id', String.valueOf(rmas.Id));
     Test.setCurrentPage(pageRef);
     
     newRMA.assetOnChange();
     newRMA.addressBookOnChange();
     newRMA.populateAddressFields();
     newRMA.getAddressOptions();
     newRMA.showOnSiteSectionOnChange();
     newRMA.SaveRMA();
     
     System.assertEquals('Attn: TEST-CONTACT-LAST-NAME', newRMA.shpLabelAssetContact);
     System.assertEquals('Contact Phone: 9999999999', newRMA.shpLabelContactPhone);
     System.assertEquals('Contact Email: contact@test.com', newRMA.shpLabelContactEmail);
     System.assertEquals(Date.today(), newRMA.shpLocationValidationOn);
     System.assertEquals(testData.ab02.Id, newRMA.addressBookLinkedId);
     System.assertEquals(true, newRMA.hideOnSiteSections);
     System.assertEquals('TEST-ACCOUNT', newRMA.shpAccountName);
     System.assertEquals('AB02 STREET 1', newRMA.shpLabelStreet1);
     System.assertEquals('AB02 STREET 2', newRMA.shpLabelStreet2);
     System.assertEquals('India', newRMA.shpLabelCountry);
     System.assertEquals('AB02 CITY, ', newRMA.shpLabelCity);
     System.assertEquals('AB02 STATE', newRMA.shpLabelState);
     System.assertEquals('500000', newRMA.shpLabelPostalCode);
     System.assertNotEquals(true, newRMA.alwaysShownOnSiteSection);
    }
    
    static testMethod void rmaEditDiskShelfAsset()
    { RMAv2__c rmas;
     ID testRmaId;
     
     TestData testData = new TestData();
     test.startTest();
     
     rmas = [SELECT Id,
             rmaCaseNumber__c,
             rmaDiskShelfAsset__c,
             rmaType__c,
             rmaLabArray__c,
             rmaComponent__c,
             rmaNimbleOsVersion__c,
             rmaModel__c,
             rmaPart__c,
             rmaQuantity__c,
             rmaAddressBook__c,
             rmaReason__c,
             rmaManufacturer__c,
             rmaDetailedReason__c,
             rmaConfigurationDetails__c,
             rmaUplift__c,
             rmaOutgoingShipmentStatus__c,
             rmaReturnShipmentStatus__c,
             rmaOutgoingShipmentDateTimeOpened__c,
             rmaShowOnSiteSectionsAlways__c
             FROM   RMAv2__c];
     rmas.rmaModel__c = 'CHASSIS: ES1 series';
     rmas.rmaDiskShelfAsset__c =testData.Asset01.Id;
     
     update rmas;
     test.stopTest();
     
     ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
     rmav2ExtensionsWithSharingNew newRMA = new rmav2ExtensionsWithSharingNew(sc);
     
     PageReference pageRef = Page.rmaV2NewPage;
     pageRef.getParameters().put('id', String.valueOf(rmas.Id));
     Test.setCurrentPage(pageRef);
     
     newRMA.assetOnChange();
     newRMA.addressBookOnChange();
     newRMA.populateAddressFields();
     newRMA.getAddressOptions();
     newRMA.showOnSiteSectionOnChange();
     newRMA.SaveRMA();
     
     System.assertEquals('Attn: TEST-CONTACT-LAST-NAME', newRMA.shpLabelAssetContact);
     System.assertEquals('Contact Phone: 9999999999', newRMA.shpLabelContactPhone);
     System.assertEquals('Contact Email: contact@test.com', newRMA.shpLabelContactEmail);
     System.assertEquals(Date.today(), newRMA.shpLocationValidationOn);
     System.assertEquals(testData.ab02.Id, newRMA.addressBookLinkedId);
     System.assertEquals(true, newRMA.hideOnSiteSections);
     System.assertEquals('TEST-ACCOUNT', newRMA.shpAccountName);
     System.assertEquals('AB02 STREET 1', newRMA.shpLabelStreet1);
     System.assertEquals('AB02 STREET 2', newRMA.shpLabelStreet2);
     System.assertEquals('India', newRMA.shpLabelCountry);
     System.assertEquals('AB02 CITY, ', newRMA.shpLabelCity);
     System.assertEquals('AB02 STATE', newRMA.shpLabelState);
     System.assertEquals('500000', newRMA.shpLabelPostalCode);
     System.assertNotEquals(true, newRMA.alwaysShownOnSiteSection);
    }
    
    
    static testMethod void rmaChangeDiskShelfOnsiteAsset()
    { RMAv2__c rmas;
     ID testRmaId;
     
     TestData testData = new TestData();
     Test.startTest();
     testData.updateOnsiteAsset();
     
     rmas = [SELECT Id,
             rmaCaseNumber__c,
             rmaDiskShelfAsset__c,
             rmaType__c,
             rmaLabArray__c,
             rmaComponent__c,
             rmaNimbleOsVersion__c,
             rmaModel__c,
             rmaPart__c,
             rmaQuantity__c,
             rmaAddressBook__c,
             rmaReason__c,
             rmaManufacturer__c,
             rmaDetailedReason__c,
             rmaConfigurationDetails__c,
             rmaUplift__c,
             rmaOutgoingShipmentStatus__c,
             rmaReturnShipmentStatus__c,
             rmaOutgoingShipmentDateTimeOpened__c,
             rmaShowOnSiteSectionsAlways__c
             FROM   RMAv2__c];
     rmas.rmaModel__c = 'CHASSIS: ES1 series';
     rmas.rmaDiskShelfAsset__c =testData.Asset01.Id;
     rmas.rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours';
     rmas.rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site';
     rmas.rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival';
     rmas.rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site';      
     rmas.rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET';
     rmas.rmaOverrideOnsiteArrivalCity__c = 'TESTCITY';
     rmas.rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222';
     rmas.rmaOverrideOnsiteArrivalCountry__c = 'United States';
     
     update rmas;
     Test.stopTest();
     
     ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
     rmav2ExtensionsWithSharingNew newRMA = new rmav2ExtensionsWithSharingNew(sc);
     
     PageReference pageRef = Page.rmaV2NewPage;
     pageRef.getParameters().put('id', String.valueOf(rmas.Id));
     Test.setCurrentPage(pageRef);

     
     System.assertEquals('Attn: TEST-CONTACT-LAST-NAME', newRMA.shpLabelAssetContact);
     System.assertEquals('Contact Phone: 9999999999', newRMA.shpLabelContactPhone);
     System.assertEquals('Contact Email: contact@test.com', newRMA.shpLabelContactEmail);
     System.assertEquals(Date.today(), newRMA.shpLocationValidationOn);
     System.assertEquals(false, newRMA.hideOnSiteSections);
    }
    
    static testMethod void rmaHDDandValidNRD()
    { RMAv2__c rmas;
     ID testRmaId;
     
     TestData testData = new TestData();
     test.startTest();
     
     rmas = [SELECT Id,
             rmaCaseNumber__c,
             rmaType__c,
             rmaLabArray__c,
             rmaComponent__c,
             rmaNimbleOsVersion__c,
             rmaModel__c,
             rmaPart__c,
             rmaQuantity__c,
             rmaAddressBook__c,
             rmaReason__c,
             rmaManufacturer__c,
             rmaDetailedReason__c,
             rmaConfigurationDetails__c,
             rmaUplift__c,
             rmaOutgoingShipmentStatus__c,
             rmaReturnShipmentStatus__c,
             rmaOutgoingShipmentDateTimeOpened__c,
             rmaShowOnSiteSectionsAlways__c
             FROM   RMAv2__c];
     
     rmas.rmaLabArray__c                   = 'No';
     rmas.rmaComponent__c                  = 'HDD';
     rmas.rmaNimbleOsVersion__c            = 'HDD: N/A';
     rmas.rmaModel__c                      = 'HDD: CS240/440';
     rmas.rmaPart__c                       = 'HDD: 2TB - save RMA to compute exact part';
     rmas.rmaQuantity__c                   = '1';
     rmas.rmaManufacturer__c               = 'HDD: Seagate';
     rmas.rmaHddSsdSerialNumber__c         = 'ABC123';
     rmas.rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)';
     
     update rmas;
     test.stopTest();
     
     ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
     rmav2ExtensionsWithSharingNew newRMA = new rmav2ExtensionsWithSharingNew(sc);
     
     PageReference pageRef = Page.rmaV2NewPage;
     pageRef.getParameters().put('id', String.valueOf(rmas.Id));
     Test.setCurrentPage(pageRef);
     
     newRMA.assetOnChange();
     newRMA.addressBookOnChange();
     newRMA.populateAddressFields();
     newRMA.getAddressOptions();
     newRMA.showOnSiteSectionOnChange();
     newRMA.SaveRMA();
     
     System.assertEquals('Attn: TEST-CONTACT-LAST-NAME', newRMA.shpLabelAssetContact);
     System.assertEquals('Contact Phone: 9999999999', newRMA.shpLabelContactPhone);
     System.assertEquals('Contact Email: contact@test.com', newRMA.shpLabelContactEmail);
     System.assertEquals(Date.today(), newRMA.shpLocationValidationOn);
     System.assertEquals(testData.ab02.Id, newRMA.addressBookLinkedId);
     System.assertEquals(true, newRMA.hideOnSiteSections);
     System.assertEquals(true, newRMA.assetNrdIsInEffect); 
     System.assertEquals('TEST-ACCOUNT', newRMA.shpAccountName);
     System.assertEquals('AB02 STREET 1', newRMA.shpLabelStreet1);
     System.assertEquals('AB02 STREET 2', newRMA.shpLabelStreet2);
     System.assertEquals('India', newRMA.shpLabelCountry);
     System.assertEquals('AB02 CITY, ', newRMA.shpLabelCity);
     System.assertEquals('AB02 STATE', newRMA.shpLabelState);
     System.assertEquals('500000', newRMA.shpLabelPostalCode);
     System.assertNotEquals(true, newRMA.alwaysShownOnSiteSection);
    }
    
    static testMethod void rmaSSDandValidNRD()
    { RMAv2__c rmas;
     ID testRmaId;
     
     TestData testData = new TestData();
     test.startTest();
     
     rmas = [SELECT Id,
             rmaCaseNumber__c,
             rmaType__c,
             rmaLabArray__c,
             rmaComponent__c,
             rmaNimbleOsVersion__c,
             rmaModel__c,
             rmaPart__c,
             rmaQuantity__c,
             rmaAddressBook__c,
             rmaReason__c,
             rmaManufacturer__c,
             rmaDetailedReason__c,
             rmaConfigurationDetails__c,
             rmaUplift__c,
             rmaOutgoingShipmentStatus__c,
             rmaReturnShipmentStatus__c,
             rmaOutgoingShipmentDateTimeOpened__c,
             rmaShowOnSiteSectionsAlways__c
             FROM   RMAv2__c];
     
     rmas.rmaLabArray__c                   = 'No';
     rmas.rmaComponent__c                  = 'SSD';
     rmas.rmaNimbleOsVersion__c            = 'SSD: N/A';
     rmas.rmaModel__c                      = 'SSD: CS215/300/500/700, 2400F';
     rmas.rmaPart__c                       = 'SSD: 600GB - save RMA to compute exact part';
     rmas.rmaQuantity__c                   = '1';
     rmas.rmaManufacturer__c               = 'SSD: Intel';
     rmas.rmaHddSsdSerialNumber__c         = 'ABC123';
     rmas.rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
     
     update rmas;
     test.stopTest();
     
     ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
     rmav2ExtensionsWithSharingNew newRMA = new rmav2ExtensionsWithSharingNew(sc);
     
     PageReference pageRef = Page.rmaV2NewPage;
     pageRef.getParameters().put('id', String.valueOf(rmas.Id));
     Test.setCurrentPage(pageRef);
     
     newRMA.assetOnChange();
     newRMA.addressBookOnChange();
     newRMA.populateAddressFields();
     newRMA.getAddressOptions();
     newRMA.showOnSiteSectionOnChange();
     newRMA.SaveRMA();
     
     System.assertEquals('Attn: TEST-CONTACT-LAST-NAME', newRMA.shpLabelAssetContact);
     System.assertEquals('Contact Phone: 9999999999', newRMA.shpLabelContactPhone);
     System.assertEquals('Contact Email: contact@test.com', newRMA.shpLabelContactEmail);
     System.assertEquals(Date.today(), newRMA.shpLocationValidationOn);
     System.assertEquals(testData.ab02.Id, newRMA.addressBookLinkedId);
     System.assertEquals(true, newRMA.hideOnSiteSections);
     System.assertEquals(true, newRMA.assetNrdIsInEffect); 
     System.assertEquals('TEST-ACCOUNT', newRMA.shpAccountName);
     System.assertEquals('AB02 STREET 1', newRMA.shpLabelStreet1);
     System.assertEquals('AB02 STREET 2', newRMA.shpLabelStreet2);
     System.assertEquals('India', newRMA.shpLabelCountry);
     System.assertEquals('AB02 CITY, ', newRMA.shpLabelCity);
     System.assertEquals('AB02 STATE', newRMA.shpLabelState);
     System.assertEquals('500000', newRMA.shpLabelPostalCode);
     System.assertNotEquals(true, newRMA.alwaysShownOnSiteSection);
    }
    
}