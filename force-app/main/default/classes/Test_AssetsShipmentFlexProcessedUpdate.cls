/* Apex test class: Test_AssetsShipmentFlexProcessedUpdate
 * This is the test class with unit test methods to achieve minimum code coverage for the "AssetsShipmentFlexProcessedUpdate" batch class.
 * Author: Exafort(Vishnu)
 * Date: 2nd November 2018
 * */
@isTest(SeeAllData=false)
public class Test_AssetsShipmentFlexProcessedUpdate {
    class TestData {
        Account account;
        Contact contact;
        Asset   asset;
        Shipment_Flexflow__c ShipmentFlexflow;
        TestData() {
            
            // Create test account
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
            
            // Create test asset
            insert asset = new Asset(Name = 'TEST-ASSET',
                                     AccountId = account.Id,
                                     ContactId = contact.Id,SLA__c = 'Premium',
                                     assetRmaShi__c = 'Asset RMA SHI',status ='Shipped',
                                     assetComponentCreatedStatus__c = '',HPE_Serial_Number__c ='TEST-ASSETNIM');
            
            System.assertNotEquals(null,                      asset.Id);
            System.assertEquals('TEST-ASSET',                  asset.Name);
            System.assertEquals(account.Id,                 asset.AccountId);
            System.assertEquals(contact.Id,                 asset.ContactId);
            System.assertEquals('Premium',                     asset.SLA__c);
            System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
            
            //create test Shipment Flexflow
            insert ShipmentFlexflow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c = 'TEST-ASSET',
                                                              shipmentFlexflowFlexProcessed__c='Error');
            }
        }
    
    Static testmethod void Test_AssetsShipmentFlexProcessedUpdate_Batch_01(){
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        testData.asset.assetComponentCreatedStatus__c = 'Partial Success';
        update testData.asset;
        String query = 'Select Id,Name,Asset_Type__c,assetComponentCreatedStatus__c FROM Asset where assetComponentCreatedStatus__c = \'Partial Success\' AND Status = \'Shipped\'';
        AssetsShipmentFlexProcessedUpdate AssetshipmentFlexFlow = new AssetsShipmentFlexProcessedUpdate(query);
        Database.executeBatch(AssetshipmentFlexFlow,1);
        Test.stopTest();
    }
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    Static testmethod void Test_AssetsShipmentFlexProcessedScheduler_Batch_02(){
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('AssetsShipmentFlexProcessedScheduler_testJob',CRON_EXP, new AssetsShipmentFlexProcessedScheduler());
        Test.stopTest();
    }
}