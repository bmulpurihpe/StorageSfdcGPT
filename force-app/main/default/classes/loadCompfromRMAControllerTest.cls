/*                              <<<< === Test Class for loadCompfromRMAController apex class === >>>>
=============================================================================================================
Name                    : loadCompfromRMAController
Description             : To verify the test coverage for the logics in the loadCompfromRMAController class.
Created Date            : 8 th Nov 201
Author                  : Exafort (Komathi Priya)
Version                 : 1.0
Modification History    : Initial Version
==============================================================================================================
*/
@isTest
public class loadCompfromRMAControllerTest {
    static String str ='';
    public static String[] csvFileLines;
    public static Blob csvFileBody;
    public static Account account;
    public static Contact contact;
    public static Asset asset01;
    public static Case aCase;
    public static RMAv2__c rma;
    public static AddressBook__c ab01;
    public static List<Account> accounts;
    public static List<Contact> contacts;
    public static List<Asset> assets;
    public static List<Case> cases;
    public static List<RMAv2__c> rmas;
    public static List<AddressBook__c> abs;
    
       
    static testmethod void testfileupload(){
        
        //TestData testData = new TestData();
        
         // Create test account
            account = new Account(Name = 'TEST-ACCOUNT');
            insert account;
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
            
            // Create test contact
            contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',Email ='contact@test.com',Phone='9999999999',
                                  AccountId = account.Id);
            insert contact;
            // Create test asset 01
            asset01 = new Asset(Name = 'TEST-ASSET',
                                AccountId = account.Id,
                                ContactId = contact.Id,
                                assetPartShipAddressBook__c = ab01.Id,
                                assetPartShipLastValidatedDatetime__c = Date.today(),
                                SLA__c = 'Premium',
                                Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                                Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                                Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                                Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',assetNrdEndDate__c = Date.today() + 10,
                                HPE_Serial_Number__c = 'asset001');
            insert asset01;
            // Create test case
            aCase = new Case(AccountId = account.Id,
                             AssetId   = asset01.Id,
                             ContactId = contact.Id,
                             Subject = 'TEST-CASE-SUBJECT');
            insert aCase;
        
        Component__c com = new Component__c(componentServicePartNumber__c ='SR-CONT-303',componentComponentSN__c='NC16C15893');
            insert com;
        
       
        
        Test.startTest(); 
        
        
        // Create test RMA
        rmas = new List<RMAv2__c>();
        rmas.add(new RMAv2__c(rmaCaseNumber__c                 = aCase.Id,
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
                         rmaShipmentAddressSelector__c    = 'Asset install address',
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
                         rmaTransmitRmaShisWithOrder__c   = 'No SHI'));
        
        // Create test RMA
        rmas.add(new RMAv2__c(rmaCaseNumber__c                 = aCase.Id,
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
                         rmaShipmentAddressSelector__c    = 'Asset install address',
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
                         rmaTransmitRmaShisWithOrder__c   = 'No SHI'));

        insert rmas;
        
        ActivateTrigger__c at = new ActivateTrigger__c();
        at.RMATrigger__c = false;
        insert at;
        
        
        List<RMAv2__c> newRmas = new List<RMAv2__c>([Select id, name from Rmav2__c limit 2]);
        str = 'RMA #,Incoming Part #,Serial number,Comp\n'+newRmas[0].Name+',SR-CHASSIS-3U-X9,AF-125080,comp-01\n'+newRmas[1].Name+',SR-CONT-301,NC16C15893,comp-01\n'+newRmas[1].Name+'00,SR-CONT-301,NC16C15899,comp-01';
    	csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        
        loadCompfromRMAController importData = new loadCompfromRMAController();
        //importData.RMAname = '';// RMAname;// = new 
        importData.csvFileBody = csvFileBody;
        //importData.loadCompfromRMAController();
        importData.importCSVFile();
        importData.insertComponent();
        Test.stopTest();
        List<RMAv2__c> newRmasUpd = new List<RMAv2__c>([Select id, name from Rmav2__c]);
        List<Component__c> comp = new List<Component__c>([Select id, name from Component__c]);
        System.assertEquals(3, comp.size());
        System.assertEquals(2, newRmasUpd.size());
        
    } 
  static testmethod void testFileUploadNegative(){
      
      Test.startTest();
     
      csvFileBody = null;
        String csvAsString =''; 
        csvFileLines =  csvAsString.split('\n'); 
        
        loadCompfromRMAController importData = new loadCompfromRMAController();
        importData.csvFileBody = csvFileBody;
        importData.importCSVFile();
        Test.stopTest();
  
  }
        
}