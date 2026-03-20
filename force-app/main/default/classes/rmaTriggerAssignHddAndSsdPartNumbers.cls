@isTest
public class rmaTriggerAssignHddAndSsdPartNumbers {
    /*@isTest static void testCaseSSDWearLevelHigh()
{
Account account;
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
contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
System.assertNotEquals(null,contact.Id);
System.assertEquals(account.Id,contact.AccountId);
System.assertEquals('Vishnu Test', contact.LastName);

// Create test asset
asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id LIMIT 1];
System.assertNotEquals(null,                      asset.Id);
System.assertEquals('AA-000000',                  asset.Name);
System.assertEquals(account.Id,                 asset.AccountId);
System.assertEquals(contact.Id,                 asset.ContactId);
System.assertEquals('Premium',                     asset.SLA__c);

//Create test case
aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1 FOR UPDATE];
System.assertNotEquals(null,             aCase.Id);
System.assertEquals(account.Id,       aCase.AccountId);
System.assertEquals(asset.Id,         aCase.AssetId);
System.assertEquals(contact.Id,       aCase.ContactId);
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
System.assertEquals('Com-3258856',       testComponent1.Name);

//Create test RMA
rma = [Select Id,Name,
rmaCaseNumber__c,
rmaDiskShelfAsset__c,
rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaDeliveryDateTime__c,
rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY NAME DESC LIMIT 1];  

System.assertNotEquals(null,rma.Id);
System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
System.assertEquals('Component',rma.rmaSelection__c);

aCase.casePachinkoCaseType__c ='ssdwearlevelhigh';
update aCase;
Test.startTest();
rma.rmaDeliveryDateTime__c = null;
update rma;
Test.stopTest();
}
@isTest static void testzAddOverriddenAddressToAB()
{

Account account;
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
contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
System.assertNotEquals(null,contact.Id);
System.assertEquals(account.Id,contact.AccountId);
System.assertEquals('Vishnu Test', contact.LastName);

// Create test asset
asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id LIMIT 1];
System.assertNotEquals(null,                      asset.Id);
System.assertEquals('AA-000000',                  asset.Name);
System.assertEquals(account.Id,                 asset.AccountId);
System.assertEquals(contact.Id,                 asset.ContactId);
System.assertEquals('Premium',                     asset.SLA__c);

//Create test case
aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1 FOR UPDATE];
System.assertNotEquals(null,             aCase.Id);
System.assertEquals(account.Id,       aCase.AccountId);
System.assertEquals(asset.Id,         aCase.AssetId);
System.assertEquals(contact.Id,       aCase.ContactId);
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
System.assertEquals('Com-3258856',       testComponent1.Name);

//Create test RMA
rma = [Select Id,Name,
rmaCaseNumber__c,
rmaDiskShelfAsset__c,
rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaDeliveryDateTime__c,
rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];  

System.assertNotEquals(null,rma.Id);
System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
System.assertEquals('Component',rma.rmaSelection__c);

rmaStatusInformationsPreventRecursive.run = true;
CountRMAStatusInforPreventRecursive.run = true;
Test.StartTest();
rma.rmaAddOverriddenAddressToAddressBook__c = true;
update rma;
Test.Stoptest();

}
@isTest static void testzRMAOnsiteCompiledNotes()
{ 
Account account;
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
contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
System.assertNotEquals(null,contact.Id);
System.assertEquals(account.Id,contact.AccountId);
System.assertEquals('Vishnu Test', contact.LastName);

// Create test asset
asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id LIMIT 1];
System.assertNotEquals(null,                      asset.Id);
System.assertEquals('AA-000000',                  asset.Name);
System.assertEquals(account.Id,                 asset.AccountId);
System.assertEquals(contact.Id,                 asset.ContactId);
System.assertEquals('Premium',                     asset.SLA__c);

//Create test case
aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1];
System.assertNotEquals(null,             aCase.Id);
System.assertEquals(account.Id,       aCase.AccountId);
System.assertEquals(asset.Id,         aCase.AssetId);
System.assertEquals(contact.Id,       aCase.ContactId);
System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);

//Create test Address Book
addressBook=[Select Id,name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id Order BY Name LIMIT 1];
System.assertNotEquals(null,             addressBook.Id);
System.assertEquals(account.Id,       addressBook.abAccount__c);

//Chassis
testComponent1 =[Select Id,Name,
Sub_State__c,
componentState__c,
componentAsset__c,
componentAccountId__c,
componentComponentSN__c,
componentServicePartNumber__c,
componentType__c, componentDescription__c
From component__c where componentServicePartNumber__c ='SR-CHASSIS-3U-SMC' AND componentAsset__c=:asset.Id LIMIT 1];
//Name='Com-3258853'

rma = [Select Id,Name,
rmaCaseNumber__c,
rmaDiskShelfAsset__c,rmaStatus__c,
rmaOverrideOnsiteSchedulingCode__c,
rmaOverrideOnsitePartHandoverCode__c,
rmaOverrideOnsiteCheckInCode__c,
rmaOverrideOnsitePartDispositionCode__c,
rmaOverrideOnsiteArrivalStreet1__c,
rmaOverrideOnsiteArrivalCity__c,
rmaOverrideOnsiteArrivalPostalCode__c,
rmaOverrideOnsiteArrivalCountry__c,
rmaOnsiteCompiledNotes__c,
rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];

System.assertNotEquals(null,rma.Id);
System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
System.assertEquals('Component',rma.rmaSelection__c);
Test.startTest();
asset.SLA__c = 'Premium 4 Hour Onsite';
update asset;

rma.rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours';
rma.rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site';
rma.rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival';
rma.rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site';      
rma.rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET';
rma.rmaOverrideOnsiteArrivalCity__c = 'TESTCITY';
rma.rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222';
rma.rmaOverrideOnsiteArrivalCountry__c = 'United States';
update rma;

rma = [Select Id,Name,
rmaCaseNumber__c,
rmaDiskShelfAsset__c,rmaStatus__c,
rmaOverrideOnsiteSchedulingCode__c,
rmaOverrideOnsitePartHandoverCode__c,
rmaOverrideOnsiteCheckInCode__c,
rmaOverrideOnsitePartDispositionCode__c,
rmaOverrideOnsiteArrivalStreet1__c,
rmaOverrideOnsiteArrivalCity__c,
rmaOverrideOnsiteArrivalPostalCode__c,
rmaOverrideOnsiteArrivalCountry__c,
rmaOnsiteCompiledNotes__c,
rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];
Test.stopTest();
//System.assertEquals(1,                   rmas.size());
System.assertEquals('Open', rma.rmaStatus__c);
System.assertEquals('WITHIN-4-HOURS-10: Schedule within the next 4 hours', rma.rmaOverrideOnsiteSchedulingCode__c);
System.assertEquals('MANNED-10: Part courier must leave part with somebody at site', rma.rmaOverrideOnsitePartHandoverCode__c);
System.assertEquals('CHECK-IN-10: FE must check in upon arrival', rma.rmaOverrideOnsiteCheckInCode__c);
System.assertEquals('LEAVE-PART-10: FE must leave old part at site', rma.rmaOverrideOnsitePartDispositionCode__c);
System.assertEquals('TESTSTREET', rma.rmaOverrideOnsiteArrivalStreet1__c);
System.assertEquals('TESTCITY', rma.rmaOverrideOnsiteArrivalCity__c);
System.assertEquals('22222-2222', rma.rmaOverrideOnsiteArrivalPostalCode__c);
System.assertEquals('United States', rma.rmaOverrideOnsiteArrivalCountry__c);
System.assertNotEquals(null, rma.rmaOnsiteCompiledNotes__c);

//testRMAOnsiteCompiledNotes02(asset.Id);
//Exafort(vishnu).changed the assets[0].Id to asset.Id
}
@isTest static void testzRMAStatusClosed()
{
Account account;
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
contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
System.assertNotEquals(null,contact.Id);
System.assertEquals(account.Id,contact.AccountId);
System.assertEquals('Vishnu Test', contact.LastName);

// Create test asset
asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id LIMIT 1];
System.assertNotEquals(null,                      asset.Id);
System.assertEquals('AA-000000',                  asset.Name);
System.assertEquals(account.Id,                 asset.AccountId);
System.assertEquals(contact.Id,                 asset.ContactId);
System.assertEquals('Premium',                     asset.SLA__c);

//Create test case
aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1];
System.assertNotEquals(null,             aCase.Id);
System.assertEquals(account.Id,       aCase.AccountId);
System.assertEquals(asset.Id,         aCase.AssetId);
System.assertEquals(contact.Id,       aCase.ContactId);
System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);

//Create test Address Book
addressBook=[Select Id,Name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id ORDER BY Name LIMIT 1];
System.assertNotEquals(null,             addressBook.Id);
System.assertEquals(account.Id,       addressBook.abAccount__c);

//Create test Component
testComponent1 =[Select Id,Name,
Sub_State__c,
componentState__c,
componentAsset__c,
componentAccountId__c,
componentComponentSN__c,
componentServicePartNumber__c,
componentType__c, componentDescription__c
From component__c where componentServicePartNumber__c ='SR-PWR-1200W' AND componentAsset__c=:asset.Id LIMIT 1];

//Create test RMA
rma = [Select Id,Name,
rmaCaseNumber__c,
rmaDiskShelfAsset__c,
rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];  

System.assertNotEquals(null,rma.Id);
System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
System.assertEquals('Flat List',rma.rmaSelection__c);           
Test.startTest();
rma.rmaOutgoingShipmentStatus__c = 'CLOSED-10: Delivered';
rma.rmaReturnShipmentStatus__c = 'CLOSED-10: Delivered';
rma.rmaRetShip2Status__c = 'CLOSED-10: Delivered';
rma.rmaOnsiteTechStatus__c = 'CLOSED-10: Delivered';
rma.rmaOutgoingShipmentDepot__c = 'ACV-003 (Arcata, CA, United States)';
rma.rmaOutgoingShipmentCarrier__c = 'Aeronet';
rma.rmaOutgoingShipmentTrackingNumber__c = 'TestTrack001';
rma.rmaOutgoingShipmentPartSn__c = 'AC-200000';
rma.rmaGateKeeperStatus__c = 'Automatic';
update rma;
Test.stopTest();
}
@isTest static void testzRMAStatusOpen()
{
Account account;
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
contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
System.assertNotEquals(null,contact.Id);
System.assertEquals(account.Id,contact.AccountId);
System.assertEquals('Vishnu Test', contact.LastName);

// Create test asset
asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id LIMIT 1];
System.assertNotEquals(null,                      asset.Id);
System.assertEquals('AA-000000',                  asset.Name);
System.assertEquals(account.Id,                 asset.AccountId);
System.assertEquals(contact.Id,                 asset.ContactId);
System.assertEquals('Premium',                     asset.SLA__c);

//Create test case
aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1];
System.assertNotEquals(null,             aCase.Id);
System.assertEquals(account.Id,       aCase.AccountId);
System.assertEquals(asset.Id,         aCase.AssetId);
System.assertEquals(contact.Id,       aCase.ContactId);
System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);

//Create test Address Book
addressBook=[Select Id,Name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id ORDER BY Name LIMIT 1];
System.assertNotEquals(null,             addressBook.Id);
System.assertEquals(account.Id,       addressBook.abAccount__c);

//Create test Component
testComponent1 =[Select Id,Name,
Sub_State__c,
componentState__c,
componentAsset__c,
componentAccountId__c,
componentComponentSN__c,
componentServicePartNumber__c,
componentType__c, componentDescription__c
From component__c where componentServicePartNumber__c ='SR-HDD-2TB' AND componentAsset__c=:asset.Id LIMIT 1];

//Create test RMA
rma = [Select Id,Name,
rmaCaseNumber__c,
rmaDiskShelfAsset__c,
rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];  

System.assertNotEquals(null,rma.Id);
System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
System.assertEquals('Component',rma.rmaSelection__c);           
Test.startTest();
rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
rma.rmaGateKeeperStatus__c = 'Automatic';
update rma;
Test.stopTest();
}*/
    class TestData
    {
        Account                         testAccount;
        Contact                         testContact;
        Asset                           testAsset;
        Case                            testCase;
        Depot__c                        testDepot;
        DepotMapNbdNd__c                testDepotMapNbdNd;
        RMAv2__c                        testRma;
        ActivateTrigger__c 			 	activateTriggerCustomSetting;
        
        TestData()
        {
            //check the custom setting value set for the rma trigger to run.
            insert activateTriggerCustomSetting = new ActivateTrigger__c(RMATrigger__c = True);
            
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                                 ProductCode='SSD123',
                                                 Product_Type__c='Hardware',
                                                 Product_Type_2__c='SAN Storage ArrayS',
                                                 Controller_Code__c='CS2001',
                                                 Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                 Family='SAN Storage Array');
            insert testProduct2;
            // Create test Asset
            insert testAsset = new Asset(Name                      = 'AA-100400',
                                         AccountId                 = testAccount.Id,
                                         ContactId                 = testContact.Id,
                                         SLA__c                    = 'Premium',
                                         HPE_Serial_Number__c 		= 'AA000000NIM',
                                         Install_Street1__c        = '123 Main Street',
                                         Install_Street2__c        = 'Suite 100',
                                         Install_City__c           = 'San Jose',
                                         Install_State_Province__c = 'CA',
                                         Install_Zip_Code__c       = '95151',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                                         Install_Country__c        = 'United States',
                                         Ship_Date__c              = Date.today().addDays(-180));
            Test.startTest();
            // Create test Case
            insert testCase = new Case(AccountId = testAccount.Id,
                                       AssetId   = testAsset.Id,
                                       ContactId = testContact.Id,
                                       Subject   = 'TEST-CASE-SUBJECT', Technology_Area__c = '3rd Party Apps', Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)');
            
            // Create test Depot
            insert testDepot = new Depot__c(Name                        = 'TST-001',
                                            depotProvider__c            = 'Flash',
                                            depotStockedFor4Hour__c     = 'No',
                                            depotLocationDescription__c = 'Test depot 001',
                                            Returns_Carrier__c          = 'DHL' );
            
            // Create test NBD/ND mapping
            insert testDepotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United States',
                                                            depotMapNbdNdState__c     = 'N/A',
                                                            depotMapNbdNd_NbdDepot__c = testDepot.Id,
                                                            depotMapNbdNd_NdDepot__c  = testDepot.Id);
            
        }
        
        void insertRMAHdd210()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS210/220/420',
                                          rmaPart__c                       = 'HDD: 1TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMAHdd240()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS240/440',
                                          rmaPart__c                       = 'HDD: 2TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMAHdd260()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS260/460',
                                          rmaPart__c                       = 'HDD: 3TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMAHdd12T()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS215/300/500/700, 12T',
                                          rmaPart__c                       = 'HDD: 2TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMAHdd24T()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS215/300/500/700, 24T',
                                          rmaPart__c                       = 'HDD: 2TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMAHdd36T()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS215/300/500/700, 36T',
                                          rmaPart__c                       = 'HDD: 3TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMAHdd48T()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS215/300/500/700, 48T',
                                          rmaPart__c                       = 'HDD: 4TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMAHdd72T()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS215/300/500/700, 72T',
                                          rmaPart__c                       = 'HDD: 6TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd210X2()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS210/210-X2/220/420',
                                          rmaPart__c                       = 'SSD: 80TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd210X4()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS210-X4/220-X2/240/420-X2/440',
                                          rmaPart__c                       = 'SSD: 80TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd220X4()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS220-X4/240-X2/260/420-X4/440-X2/460',
                                          rmaPart__c                       = 'SSD: 80TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd220X8()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS220-X8/240-X4/260-X2/420-X8/440-X4/460-X2',
                                          rmaPart__c                       = 'SSD: 80TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd320F()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS215/300/500/700, 320F',
                                          rmaPart__c                       = 'SSD: 80TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd640F()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS215/300/500/700, 640F',
                                          rmaPart__c                       = 'SSD: 160TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd1200F()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS215/300/500/700, 1200F',
                                          rmaPart__c                       = 'SSD: 300GB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd2400F()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS215/300/500/700, 2400F',
                                          rmaPart__c                       = 'SSD: 600GB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd3200F()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS215/300/500/700, 3200F',
                                          rmaPart__c                       = 'SSD: 800GB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd6400F()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS215/300/500/700, 6400F',
                                          rmaPart__c                       = 'SSD: 1600GB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd3200Fs()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS215/300/500/700, 3200FS',
                                          rmaPart__c                       = 'SSD: 800GB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
        void insertRMASsd6400Fs()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'SSD',
                                          rmaNimbleOsVersion__c            = 'SSD: N/A',
                                          rmaModel__c                      = 'SSD: CS215/300/500/700, 6400FS',
                                          rmaPart__c                       = 'SSD: 1600GB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'SSD: Intel',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        }
    }
    
    // ==================================================================================== testHdd210Before
    @isTest static void testHdd210Before()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        
        testData.insertRMAHdd210();        
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('HDD: CS210/220/420',                            rmas[0].rmaModel__c);
        System.assertEquals('1TB SATA HDD [SR-HDD-1TB]',                     rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testHdd240Before
    @isTest static void testHdd240Before()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMAHdd240(); 
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('HDD: CS240/440',                                rmas[0].rmaModel__c);
        System.assertEquals('2TB SATA HDD [SR-HDD-2TB]',                     rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testHdd260Before
    @isTest static void testHdd260Before()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMAHdd260(); 
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('HDD: CS260/460',                                rmas[0].rmaModel__c);
        System.assertEquals('3TB SAS HDD [SR-HDD-3TB]',                      rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testHdd12TBefore
    @isTest static void testHdd12TBefore()
    {	
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMAHdd12T(); 
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('HDD: CS215/300/500/700, 12T',                   rmas[0].rmaModel__c);
        System.assertEquals('1TB SAS HDD [SR-HDD-1TB-SAS]',                  rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testHdd24TBefore
    @isTest static void testzHdd24TBefore()
    {	
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMAHdd24T();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('HDD: CS215/300/500/700, 24T',                   rmas[0].rmaModel__c);
        System.assertEquals('2TB SAS HDD [SR-HDD-2TB-SAS]',                  rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testHdd36TBefore
    @isTest static void testzHdd36TBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMAHdd36T();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('HDD: CS215/300/500/700, 36T',                   rmas[0].rmaModel__c);
        System.assertEquals('3TB SAS HDD [SR-HDD-3TB-SAS]',                  rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testHdd48TBefore
    @isTest static  void testzHdd48TBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMAHdd48T();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('HDD: CS215/300/500/700, 48T',                   rmas[0].rmaModel__c);
        System.assertEquals('4TB SAS HDD [SR-HDD-4TB-SAS]',                  rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testHdd72TBefore
    @isTest static void testzHdd72TBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMAHdd72T();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('HDD: CS215/300/500/700, 72T',                   rmas[0].rmaModel__c);
        System.assertEquals('6TB SAS HDD [SR-HDD-6TB-SAS]',                  rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd210X2Before
    @isTest static void testSsd210X2Before()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd210X2();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS210/210-X2/220/420',                     rmas[0].rmaModel__c);
        System.assertEquals('80GB SATA SSD [SR-SSD-80GB]',                   rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                    rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd210X4Before
    @isTest static void testSsd210X4Before()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd210X4();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS210-X4/220-X2/240/420-X2/440',           rmas[0].rmaModel__c);
        System.assertEquals('160GB SATA SSD [SR-SSD-160GB]',                 rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                    rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd220X4Before
    @isTest static void testSsd220X4Before()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd220X4();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                               rmas.size());
        System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                           rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS220-X4/240-X2/260/420-X4/440-X2/460',    rmas[0].rmaModel__c);
        System.assertEquals('300GB SATA SSD [SR-SSD-300GB]',                 rmas[0].rmaPart__c);
        System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                    rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd220X8Before
    @isTest static void testSsd220X8Before()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd220X8();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                                  rmas.size());
        System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS220-X8/240-X4/260-X2/420-X8/440-X4/460-X2', rmas[0].rmaModel__c);
        System.assertEquals('600GB SATA SSD [SR-SSD-600GB]',                    rmas[0].rmaPart__c);
        System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd320FBefore
    @isTest static void testSsd320FBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd320F();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                                  rmas.size());
        System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS215/300/500/700, 320F',                     rmas[0].rmaModel__c);
        System.assertEquals('80GB SATA SSD [SR-SSD-3500-80GB]',                 rmas[0].rmaPart__c);
        System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd640FBefore
    @isTest static void testSsd640FBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd640F();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                                  rmas.size());
        System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS215/300/500/700, 640F',                     rmas[0].rmaModel__c);
        System.assertEquals('160GB SATA SSD [SR-SSD-3500-160GB]',               rmas[0].rmaPart__c);
        System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd1200FBefore
    @isTest static void testSsd1200FBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd1200F();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                                  rmas.size());
        System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS215/300/500/700, 1200F',                    rmas[0].rmaModel__c);
        System.assertEquals('300GB SATA SSD [SR-SSD-3500-300GB]',               rmas[0].rmaPart__c);
        System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd2400FBefore
    @isTest static void testSsd2400FBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd2400F();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                                  rmas.size());
        System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS215/300/500/700, 2400F',                    rmas[0].rmaModel__c);
        System.assertEquals('600GB SATA SSD [SR-SSD-3500-600GB]',               rmas[0].rmaPart__c);
        System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd3200FBefore
    @isTest static void testSsd3200FBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd3200F();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                                  rmas.size());
        System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS215/300/500/700, 3200F',                    rmas[0].rmaModel__c);
        System.assertEquals('800GB SATA SSD [SR-SSD-3500-800GB]',               rmas[0].rmaPart__c);
        System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd6400FBefore
    @isTest static void testSsd6400FBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd6400F();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                                  rmas.size());
        System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS215/300/500/700, 6400F',                    rmas[0].rmaModel__c);
        System.assertEquals('1600GB SATA SSD [SR-SSD-1600GB]',                  rmas[0].rmaPart__c);
        System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd3200FsBefore
    @isTest static void testSsd3200FsBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd3200Fs();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                                  rmas.size());
        System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS215/300/500/700, 3200FS',                   rmas[0].rmaModel__c);
        System.assertEquals('800GB SAS SSD [SR-SSD-800GB-SAS]',                 rmas[0].rmaPart__c);
        System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
        Test.stopTest();
    }
    // ==================================================================================== testSsd6400FsBefore
    @isTest static void testSsd6400FsBefore()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        //Test.startTest();
        testData.insertRMASsd6400Fs();
        
        rmas = [SELECT Id,
                rmaLabArray__c,
                rmaComponent__c,
                rmaNimbleOsVersion__c,
                rmaModel__c,
                rmaPart__c,
                rmaQuantity__c,
                rmaManufacturer__c,
                rmaHddSsdSerialNumber__c,
                rmaReason__c
                FROM   RMAv2__c];
        
        System.assertEquals(1,                                                  rmas.size());
        System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
        System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
        System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
        System.assertEquals('SSD: CS215/300/500/700, 6400FS',                   rmas[0].rmaModel__c);
        System.assertEquals('1600GB SAS SSD [SR-SSD-1600GB-SAS]',               rmas[0].rmaPart__c);
        System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
        System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
        System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
        System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
        Test.stopTest();
    }
}