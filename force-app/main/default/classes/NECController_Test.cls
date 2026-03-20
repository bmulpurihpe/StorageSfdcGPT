/*                              <<<< === Test Class for NECController apex class === >>>>
    =============================================================================================================
        Name                    : NECController_Test
        Description             : To verify the minimum test coverage for the logic in the NECController class.
        Created Date            : 11th april 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
@isTest
public class NECController_Test {

    static testmethod void NEC_Test_NecController_01(){
             
        Account aAccount;
        Contact aContact; 
        Asset aAsset;
        Case aCase;
        RMAv2__c aRMA;
        NEC_Definition__c NECDef;
        NEC_Definition__c NECDef1;
        NEC_Definition__c NECDef2;
        NEC_Record__c NECr;
        NEC_Record__c NECr1;
        NEC_Record__c NECr2;
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        // Creating new test Assets
        Test.startTest();
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        /*insert aAsset = new Asset(Name = 'TEST-ASSET',
                                  AccountId = aAccount.Id,
                                  ContactId = aContact.Id,HPE_Serial_Number__c ='AA000000NIM',
                                  SLA__c = 'Premium',Status ='Shipped',Group_Name__c ='TEST-ASSET-Group',
                                  assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               		Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               		Asset_Type_Build__c ='Testasupassettype');*/
        
        insert aAsset = new Asset(Name = 'TestAsset', AccountId = aAccount.Id,Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype');
       
        
       // Create test case
     	insert aCase = new Case(AccountId = aAccount.Id,
                       AssetId   = aAsset.Id,
                       ContactId = aContact.Id,
                       Subject = 'TEST-CASE-SUBJECT');
        
        //creating new EAC Definition
        insert NECDef = new NEC_Definition__c(Name = 'ForText',necSortOrder__c = 10,necFieldType__c= 'Text',necGroup__c ='Dark Site',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef1 = new NEC_Definition__c(Name = 'ForBoolean',necSortOrder__c = 20,necFieldType__c= 'Boolean',necGroup__c ='true',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef2 = new NEC_Definition__c(Name = 'ForPicklist',necSortOrder__c = 30,necFieldType__c= 'Picklist',
                                               necFieldTypePicklistItems__c = 'test|test1',necGroup__c ='Dark Site1',necDescription__c='SDesc', necLabel__c='SDesc');
        
        Test.stopTest();
        
        PageReference pageRef = Page.NECmultiEditViewPage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(aCase.Id));
        Test.setCurrentPage(pageRef);
        
        NECController NEC_controller = new NECController();
        
        NEC_controller.SelectedGroup = 'All';
        NEC_controller.groupSelectionUpdate();
        NEC_controller.timerOff();
        NEC_controller.InsertOrUpdateEACRecords();
        //************************************************************************
        
    }
    static testmethod void NEC_Test_NecController_02(){
             
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        Case aCase;
        AddressBook__c aAddressBook;
        RMAv2__c aRMA;
        NEC_Definition__c NECDef;
        NEC_Definition__c NECDef1;
        NEC_Definition__c NECDef2;
        NEC_Record__c NECr;
        NEC_Record__c NECr1;
        NEC_Record__c NECr2;
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
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
        // Creating new test Assets
          insert aAsset = new Asset(Name = 'TestAsset', AccountId = aAccount.Id,Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype');
        
       // Create test case
     	insert aCase = new Case(AccountId = aAccount.Id,
                       AssetId   = aAsset.Id,
                       ContactId = aContact.Id,
                       Subject = 'TEST-CASE-SUBJECT');
       Test.startTest();
       insert aAddressBook = new AddressBook__c(abAccount__c = aAccount.Id,
                                                    abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                    abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                    abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                    abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                                    abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                                    abPostalCode__c='1000',
                                                    abDescription__c='Asset Install Address 1');
      // Create test RMA
      insert aRMA = new RMAv2__c(rmaCaseNumber__c         = aCase.Id,
                         rmaAddressBook__c				  = aAddressBook.Id,
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
                         rmaShipmentAddressSelector__c    = '',
                         rmaOverrideShipmentPostalCode__c = '11111',
                         rmaOverrideShipmentCountry__c    = 'United States',
                         rmaOverrideShipmentAttn__c       = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',
                         rmaOverrideShipmentPhone__c      = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',
                         rmaOverrideShipmentEmail__c      = 'test-rma-override-shipment-email@nimblestorage.com',
                         rmaUplift__c                     = 'No: Do not uplift',
                         rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                         rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                         rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                         rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order',
                         rmaTransmitRmaShisWithOrder__c   = 'No SHI');
        Test.stopTest();
        //creating new EAC Definition
        insert NECDef = new NEC_Definition__c(Name = 'ForText',necSortOrder__c = 10,necFieldType__c= 'Text',necGroup__c ='Dark Site',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef1 = new NEC_Definition__c(Name = 'ForBoolean',necSortOrder__c = 20,necFieldType__c= 'Boolean',necGroup__c ='Dark Site1',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef2 = new NEC_Definition__c(Name = 'ForPicklist',necSortOrder__c = 30,necFieldType__c= 'Picklist',
                                               necFieldTypePicklistItems__c = 'test|test1',necGroup__c ='Dark Site1',necDescription__c='SDesc', necLabel__c='SDesc');
        
        
        
        PageReference pageRef = Page.NECmultiEditViewPage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(aRMA.Id));
        Test.setCurrentPage(pageRef);
        
        NECController NEC_controller = new NECController();
        
        NEC_controller.SelectedGroup = 'All';
        NEC_controller.groupSelectionUpdate();
        NEC_controller.timerOff();
        NEC_controller.InsertOrUpdateEACRecords();
        //*************************************************************************
        
        
    }
    static testmethod void NEC_Test_NecController_03(){
             
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        Case aCase;
        RMAv2__c aRMA;
        NEC_Definition__c NECDef;
        NEC_Definition__c NECDef1;
        NEC_Definition__c NECDef2;
        NEC_Record__c NECr;
        NEC_Record__c NECr1;
        NEC_Record__c NECr2;
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        // Creating new test Assets
        Test.startTest();
           Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        // Creating new test Assets
          insert aAsset = new Asset(Name = 'TestAsset', AccountId = aAccount.Id,Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype');
       // Create test case
     	insert aCase = new Case(AccountId = aAccount.Id,
                       AssetId   = aAsset.Id,
                       ContactId = aContact.Id,
                       Subject = 'TEST-CASE-SUBJECT');
        
        //creating new NEC Definition
        insert NECDef = new NEC_Definition__c(Name = 'ForText',necSortOrder__c = 10,necFieldType__c= 'Text',necGroup__c ='Dark Site',necDescription__c='SDesc', necLabel__c='SDesc',necDefaultValue__c = 'ForText');
        insert NECDef1 = new NEC_Definition__c(Name = 'ForBoolean',necSortOrder__c = 20,necFieldType__c= 'Boolean',necGroup__c ='Dark Site1',necDescription__c='SDesc', necLabel__c='SDesc',necDefaultValue__c = 'True');
        insert NECDef2 = new NEC_Definition__c(Name = 'ForPicklist',necSortOrder__c = 30,necFieldType__c= 'Picklist',necFieldTypePicklistItems__c = 'test|test1',necGroup__c ='Dark Site1',necDescription__c='SDesc', necLabel__c='SDesc',necDefaultValue__c = 'ForPicklist');
        
        //creating new NEC Records
        insert NECr = new NEC_Record__c(necrCase__c = aCase.Id,necrKeyName__c = NECDef.Id,necrValue__c = 'ForText');
        insert NECr1 = new NEC_Record__c(necrCase__c = aCase.Id,necrKeyName__c = NECDef1.Id,necrValue__c = 'True');
        insert NECr2 = new NEC_Record__c(necrCase__c = aCase.Id,necrKeyName__c = NECDef2.Id,necrValue__c = 'ForPicklist');

        Test.stopTest();
        
        PageReference pageRef = Page.NECmultiEditViewPage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(aCase.Id));
        Test.setCurrentPage(pageRef);
        
        NECController NEC_controller = new NECController();
        
        NEC_controller.SelectedGroup = 'All';
        NEC_controller.groupSelectionUpdate();
        NEC_controller.timerOff();
        NEC_controller.InsertOrUpdateEACRecords();
        //*************************************************************************
    }
    
    
}