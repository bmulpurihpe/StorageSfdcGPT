@isTest
private class ComponentAndFlexClearBatchTest {
    class TestData {
        Account testAccount;
        Contact testContact;
        Asset   testAsset1;
        Shipment_Flexflow__c shipmentFlexFlow;
        Component__c testComponent1;
        
        TestData() {
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            
            // Create test Asset 1
            insert testAsset1 = new Asset(Name                                      = 'AA-111111',
                                          AccountId                                 = testAccount.Id,
                                          ContactId                                 = testContact.Id,
                                          SLA__c                                    = 'Premium',
                                          Install_Street1__c                        = '123 Main Street',
                                          Install_Street2__c                        = 'Suite 100',
                                          Install_City__c                           = 'San Jose',
                                          Install_State_Province__c                 = 'CA',
                                          Install_Zip_Code__c                       = '95151',
                                          Install_Country__c                        = 'United States',
                                          Ship_Date__c                              = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     = Date.today(),
                                          assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                                          Status                                    = 'Shipped',
                                         assetcomponentCreatedStatus__c = 'Success',
                                         assetcomponentProcessedMessage__c='Success');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Controller Vendor S/N',
                                                               shipmentFlexflowChildSn__c='10000',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',shipmentFlexflowFlexProcessed__c='Server Error',
                                                               shipmentFlexflowProcessedMessage__c='Server Error Occured');
            
             insert testComponent1 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='12345678',
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC');
        }
    }
    
     static testMethod void assetComponentFlagClear() {
        
        Test.startTest();
        TestData    testData;
        testData = new TestData();
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;  
        String Query = 'Select Name,Asset.AccountId,Asset_Type__c,Asset_Product_Code__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset';
        assetComponentClearBatch e = new assetComponentClearBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
         
        //Check the Status of the Asset
        List<Asset> assets = [Select Id,Name,assetComponentCreatedStatus__c,assetComponentProcessedMessage__c from Asset];
        System.assertEquals(1,assets.size());
        System.assertEquals(null,assets[0].assetComponentCreatedStatus__c);
        System.assertEquals(null,assets[0].assetComponentProcessedMessage__c);
     }
    
     static testMethod void assetShipmentFlexFlowFlagClear() {
        
        Test.startTest();
        TestData    testData;
        testData = new TestData();
        String Query = 'Select shipmentFlexflowFlexProcessed__c, shipmentFlexflowProcessedMessage__c from Shipment_Flexflow__c';
        shipmentFlexFlowClearBatch e = new shipmentFlexFlowClearBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
         
        //Check the Status of the Asset
        List<Shipment_Flexflow__c> shipFlexFlow = [Select shipmentFlexflowFlexProcessed__c, shipmentFlexflowProcessedMessage__c from Shipment_Flexflow__c];
        System.assertEquals(1,shipFlexFlow.size());
        System.assertEquals(null,shipFlexFlow[0].shipmentFlexflowFlexProcessed__c);
        System.assertEquals(null,shipFlexFlow[0].shipmentFlexflowProcessedMessage__c);
     }
    
    static testMethod void componentClearRecords() {
        
        Test.startTest();
        TestData    testData;
        testData = new TestData();
        String Query = 'Select Id from Component__c';
        componentClearBatch e = new componentClearBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
         
        //Check the Status of the Asset
        List<Component__c> component = [Select Id from Component__c];
        System.assertEquals(0,component.size());
     }
}