/*
=============================================================================================================
Description             : To verify the minimum test coverage for the logic in the "rmaDepotStockoutOPScase"
Created Date            : 30 March 2021 for TS-7959 BY EXAFORT
Apex class 				: rmaDepotStockoutOPScase
==============================================================================================================
*/
@isTest
public class rmaDepotStockoutOPScase_test {
    Static TestMethod void rmaDepotStockoutOPScase_test01(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        AddressBook__c addressbook;
        Case_Docket__c cd;
        CaseDocketFieldDefinition__c CDFD;
        CaseDocketFieldDefinition__c CDFD1;
        CaseDocketFieldDefinition__c CDFD2;
        CaseDocketFieldDefinition__c CDFD3;
        CaseDocketFieldDefinition__c CDFD4;
        CaseDocketFieldDefinition__c CDFD5;
      
        rmav2__c rmas;
       
        insert account = new Account(Name = 'Nimble service portal - Production',accountRmaShi__c='Account RMA SHI');
        System.assertNotEquals(null,              account.Id);
        System.assertEquals('Nimble service portal - Production', account.Name);
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
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
        
        
        
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
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId(),
                                Case_closure_time_spent__c = 1);
        insert addressbook = new AddressBook__c(abAccount__c= account.Id,
                                                abStreet1__c = 'STREET1',
                                                abStreet2__c = 'STREET2',
                                                abCity__c='CITY',
                                                abCountry__c='India',
                                                abPostalCode__c = '600000',
                                                abStateProvince__c='STATE',
                                                abDescription__c = 'TEST DESCRIPTION');
        Test.startTest();
        
        List<Case_Docket__c> cdlist = New List<Case_Docket__c>();
        insert cd = new Case_Docket__c(Name ='req.logistics.rma.manual.dispatch',
                                       cdLabel__c ='Automatic dispatch RMA',
                                       cdResponsibleBUTeam__c ='Logistics',
                                       cdCasePriority__c ='P2');
        cdlist.add(cd);
        insert CDFD = new CaseDocketFieldDefinition__c(Name ='Part Number',
                                                       cdfdCaseDocket__c = cd.id,
                                                       cdfcKeyName__c ='Part Number',
                                                       cdfdLabel__c ='Part Number',
                                                       cdfdFieldType__c ='API',
                                                       cdfdUnderlyingObject__c ='RMAv2__c',
                                                       cdfdFieldOption__c ='rmaPartNumber__c');
          insert CDFD1 = new CaseDocketFieldDefinition__c(Name ='RMA Number',
                                                       cdfdCaseDocket__c = cd.id,
                                                       cdfcKeyName__c ='RMA Number',
                                                       cdfdLabel__c ='RMA Number',
                                                       cdfdFieldType__c ='API',
                                                       cdfdUnderlyingObject__c ='RMAv2__c',
                                                       cdfdFieldOption__c ='Name');
          insert CDFD2 = new CaseDocketFieldDefinition__c(Name ='SLA',
                                                       cdfdCaseDocket__c = cd.id,
                                                       cdfcKeyName__c ='SLA',
                                                       cdfdLabel__c ='SLA',
                                                       cdfdFieldType__c ='API',
                                                       cdfdUnderlyingObject__c ='RMAv2__c',
                                                       cdfdFieldOption__c ='rmaShipmentSla__c');
          insert CDFD3 = new CaseDocketFieldDefinition__c(Name ='Depot',
                                                       cdfdCaseDocket__c = cd.id,
                                                       cdfcKeyName__c ='Depot',
                                                       cdfdLabel__c ='Depot',
                                                       cdfdFieldType__c ='API',
                                                       cdfdUnderlyingObject__c ='RMAv2__c',
                                                       cdfdFieldOption__c ='rmaOutgoingShipmentOrderDepot__c');
          insert CDFD4 = new CaseDocketFieldDefinition__c(Name ='Reason for automation failure',
                                                       cdfdCaseDocket__c = cd.id,
                                                       cdfcKeyName__c ='Reason for automation failure',
                                                       cdfdLabel__c ='Reason for automation failure',
                                                       cdfdFieldType__c ='Picklist',
                                                       cdfdFieldOption__c ='|Depot Stockout|Bad Address|System Down|Other');
        insert CDFD5 = new CaseDocketFieldDefinition__c(Name ='SLA Miss?',
                                                       cdfdCaseDocket__c = cd.id,
                                                       cdfcKeyName__c ='SLA Miss?',
                                                       cdfdLabel__c ='SLA Miss?',
                                                       cdfdFieldType__c ='Picklist',
                                                       cdfdFieldOption__c ='|Yes|no');
        integer confirmtime = 15;
        List<ID> rmaidlist = New List<ID>();
        
        insert rmas = new rmav2__c(rmaType__c = 'Advance replcement',
                                   rmaFaRequired__c ='No FA Required',
                                   rmaCaseNumber__c = aCase.id,
                                   rmaDetailedReason__c ='test rma',
                                   rmaAddressBook__c =addressbook.id,
                                   rmaUplift__c ='No: Do not uplift',
                                   rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order',
                                   rmaReturnShipmentStatus__c ='DRAFT-10: Waiting to order');
        rmas.rmaOutgoingShipmentStatus__c ='OPEN-10: Ordered, waiting for confirmation';
        rmas.rmaReturnShipmentStatus__c ='OPEN-10: Ordered, waiting for confirmation';
        update rmas;
        rmaidlist.add(rmas.id);
        
       
        NimbleServicePortalAccountId__c dummyCustomSetting = new NimbleServicePortalAccountId__c();         
        dummyCustomSetting.Name = 'Account Id';        
        dummyCustomSetting.AccountId__c = account.Id;        
        insert dummyCustomSetting;
        pachinko_case_type__c ct1 = new pachinko_case_type__c();
        ct1.Monthly_Threshold__c = 3;
        ct1.Pachinko_Case_Type__c = cd.Name;
        ct1.Recommendation_Text__c = 'Type1 rec text';
        ct1.Threshold_Applies_To__c = 'Case';
        ct1.Leave_Case_Open__c = true;
        ct1.Enabled__c = true;
        insert ct1;
        
        Threshold_limit__c t1 = new Threshold_limit__c();
        t1.Name = 'limit';
        t1.Number_of_Months__c = 1;
        insert t1;
        string addtionalinfo ='test';
        
                rmaDepotStockoutOPScase.insertCaseDocketFieldData(rmaidlist);
                //Id caseid = rmaDepotStockoutOPScase.insertOpsCase(addtionalinfo, cdlist);


        
        //rmaDepotStockoutOPScase.insertPortalContact(account.id);
        
        Test.stopTest();
        
    }
}