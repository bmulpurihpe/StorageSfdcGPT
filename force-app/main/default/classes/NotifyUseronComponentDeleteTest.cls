@isTest
private class NotifyUseronComponentDeleteTest {
    private static component__c component;
    public static List<RMAv2__c> lstRMA;
    private static Case aCase;
    private static  AddressBook__c addressBook;
    static void createTestData()
    {
        // Create test account
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        // Create test asset
        Asset asset = new Asset(Name = 'TEST-ASSET',
                                AccountId = account.Id,
                                ContactId = contact.Id,
                                SLA__c = 'Premium',
                                HPE_Serial_Number__c = 'AA000000NIM',
                                assetRmaShi__c = 'Asset RMA SHI');
        insert asset;
        
        // Create test case
        aCase = new Case(AccountId = account.Id,
                         AssetId   = asset.Id,
                         ContactId = contact.Id,
                         Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        
        //Insert Component
        component = new component__c(componentAccountId__c = account.Id,
                                     componentAsset__c = asset.Id,
                                     componentServicePartNumber__c='SR-HDD-1TB',
                                     componentState__c = 'Shipped',
                                     Sub_State__c='Unknown',
                                     componentComponentSN__c='123456',
                                     componentType__c='HDD',
                                     componentDescription__c='HDD');
        insert component;
        
        //Insert Address Book
        addressBook = new AddressBook__c(abAccount__c = account.Id,
                                         abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                         abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                         abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                         abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
                                         abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
                                         abPostalCode__c='1000',
                                         abDescription__c='Asset Install Address 1');
        insert addressBook;
        
       //Insert RMA
        lstRMA = new List<RMAv2__c>(); 
        lstRMA.add(new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                rmaDiskShelfAsset__c = asset.Id, 
                                rmaComponentV2__c = component.Id,
                                rmaAddressBook__c = addressBook.Id,
                                rmaSelection__c = 'Component'));
        
        lstRMA.add(new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                rmaDiskShelfAsset__c = asset.Id, 
                                rmaComponentV2__c = component.Id,
                                rmaAddressBook__c = addressBook.Id,
                                rmaSelection__c = 'Component'));
        
    }  
    
    static Testmethod void Test_DeleteComponent(){ 
        Test.startTest();
        createTestData();
        Test.stopTest();
        
List<RMAv2__c> lstRMAnew = new List<RMAv2__c>();          
        lstRMAnew.addAll(lstRMA);
        insert lstRMAnew;
        system.debug('@@comp rmalst'+lstRMA);
        system.debug('@@Comp'+component);
        Delete component;
        //Assert for Nimble_Automation_Logs__c 
        Map<ID,List<Nimble_Automation_Logs__c>> mapRmaLogs = new Map<ID,List<Nimble_Automation_Logs__c>>(); 
        for(Nimble_Automation_Logs__c rmalog : [Select Id,NALCase_Number__c,NALRMA_Number__c,NALkey__c,NALvalue__c,NALproccess__c From Nimble_Automation_Logs__c]){
            if(mapRmaLogs.containsKey(rmalog.NALRMA_Number__c))
                mapRmaLogs.get(rmalog.NALRMA_Number__c).add(rmalog);
            else
                mapRmaLogs.put(rmalog.NALRMA_Number__c,new List<Nimble_Automation_Logs__c>{rmalog});
        }
        
        System.assertEquals(2, mapRmaLogs.Size());
        System.assertEquals(1, mapRmaLogs.get(lstRMA[0].ID).size());
        System.assertEquals(1, mapRmaLogs.get(lstRMA[1].ID).size());
        
        
    }
    
}