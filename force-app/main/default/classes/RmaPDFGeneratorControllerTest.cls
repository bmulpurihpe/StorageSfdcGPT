@isTest
public class RmaPDFGeneratorControllerTest {
    
    static testMethod void testControllerInitialization() {
        
        ID ProfileID = [ Select id from Profile where name = 'Support: System Administrator'].id;
        
        User usr = new User(email = 'test-rmauser@example.com', profileid = ProfileID, 
                            UserName = 'test-userforrma@example1.com' + userinfo.getusername().substringafterlast('.'), alias = 'tuser1', 
                            CommunityNickName = 'tuser123', TimeZoneSidKey = 'America/New_York', 
                            LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', 
                            FirstName = 'Test', LastName = 'UserTest' );
        insert usr;
        
        // Create test account
        Account acc = new Account(Name = 'TEST-ACCOUNT', accountRmaShi__c = 'Account RMA SHI', Global_Account__c = 'Test'); 
        insert acc;
        
        // Create test contact
        Contact con = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                  AccountId = acc.Id,
                                  Email = 'test@gmail.com',
                                  Phone = '999999999');
        insert con;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode = 'CS220', 
                                             Product_Type__c = 'Hardware',
                                             Product_Type_2__c = 'SAN Storage Array',
                                             Controller_Code__c = 'CS200',
                                             Description = '12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family = 'SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset assetRecord = new Asset(Name = 'TEST-ASSET',
                                      AccountId = acc.Id,
                                      ContactId = con.Id,
                                      SLA__c = 'Premium 4 Hour',
                                      HPE_Serial_Number__c = 'AA000000NIM',
                                      Product2Id = testProduct1.id,
                                      Array_Controller__c = 'CS300',
                                      Array_Networking__c = '2P',
                                      Array_Networking_2__c = '2P',
                                      Array_Networking_3__c = '2P',
                                      Array_Cache__c = '640F',
                                      SSD_Bank_A__c = '480F',
                                      SSD_Bank_B__c = '480F',
                                      Asset_Type_Build__c = 'AFA2',
                                      Install_Country__c = 'China',
                                      Dual_Support_Providers__c = true,
                                      assetRmaShi__c = 'Asset RMA SHI');
        insert assetRecord;
        Id ownerId = UserInfo.getUserId();
        Test.startTest();
        // Create test case
        Case aCase = new Case(AccountId = acc.Id,
                              AssetId   = assetRecord.Id,
                              ContactId = con.Id,
                              OwnerId = usr.id,
                              Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        
        AddressBook__c addressBook = new AddressBook__c(abAccount__c = acc.Id,
                                                        abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
                                                        abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
                                                        abCity__c = 'TEST-ASSET-INSTALL-CITY',
                                                        abStateProvince__c = 'TEST-ASSET-INSTALL-STATE',
                                                        abCountry__c = 'China',
                                                        abPostalCode__c = '1000',
                                                        abDescription__c = 'Asset Install Address 1');
        insert addressBook;
        
        component__c testComponent1 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = assetRecord.Id,
                                                       componentServicePartNumber__c = 'SR-CHASSIS-3U-SMC',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c = 'Unknown',
                                                       componentComponentSN__c = '123456',
                                                       componentType__c = 'Chassis',
                                                       componentDescription__c = 'Chassis');
        insert testComponent1;
        
        component__c testComponent2 = new component__c(componentAccountId__c = acc.Id,
                                                       componentAsset__c = assetRecord.Id,
                                                       componentServicePartNumber__c = 'SR-USB',
                                                       componentState__c = 'Shipped',
                                                       Sub_State__c = 'Unknown',
                                                       componentComponentSN__c = '654321',
                                                       componentType__c = 'USB',
                                                       componentDescription__c = 'USB');
        insert testComponent2;
        
        RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                    rmaDiskShelfAsset__c = assetRecord.Id, 
                                    rmaComponentV2__c = testComponent1.Id,
                                    rmaAddressBook__c = addressBook.Id,
                                    rmaOnsite_Task__c = 'Test Onsite Task',
                                    China_GA_Fault_Location__c = 'A',
                                    rmaSelection__c = 'Component'); 
        insert rma;
        
        // Create a PageReference with the RMA Id parameter
        RMAv2__c rmaRecord = [SELECT Id,rmaOnsite_Task__c FROM RMAv2__c LIMIT 1];
        
        PageReference pageRef = new PageReference('/apex/rmaPDFGeneratorPage?id=' + rmaRecord.Id);
        Test.setCurrentPage(pageRef);
        Test.stopTest();
        // Initialize the controller
        rmaPDFGeneratorController controller = new rmaPDFGeneratorController();
        String assetName1 = controller.getDiskShelfAssetName();
        String productCode = controller.getAssetProductCode();
        String serialNumber = controller.getSerialNumber();
        List<String> line = controller.getRmaFaultLines();
        List<String> onsiteTask = controller.getRmaOnsiteTaskLines();
        rmaPDFGeneratorController.processIds(new List<Id>{rmaRecord.Id});
        
    }
}