@isTest
public class assetES1AFSProductFixBatchTest {
    
    class TestData {
        Product2 testProduct;
        Account testAccount;
        Asset   testAsset;
        Component__c testComponent;
        
        TestData() {
            
            insert testProduct = new Product2(Name = 'ES1-AFS',
                                              ProductCode='ES1-AFS',
                                              Merged_Product_Code__c='ES1-AFS',
                                              Product_Type__c='Hardware',
                                              Product_Type_2__c='AFS',
                                              Controller_Code__c='ES1-AFS',
                                              Description='All Flash Exp Shelf, 2x1M Qual SAS cable (empty)',
                                              Family='AFS');
            
              // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            
            // Create test Asset 1
            insert testAsset = new Asset(Name                                      = 'AA-111111',
                                          AccountId                                 = testAccount.Id,
                                          Status                                    = 'Shipped',
                                          assetComponentCreatedStatus__c            = 'Success',
                                          assetComponentProcessedMessage__c         = null,
                                          Product2Id=testProduct.Id);
            
            insert testComponent = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='12345678',
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC');
        }
        
        
    }
    
     static testMethod void ES1_AFS_ClearComponentBatchTest() {
         TestData    testData;
         List<Component__c> components;
         List<Asset> assets;
         testData = new TestData();
         
         components = [Select Id from Component__c];
         System.assertEquals(1,components.size());
         
         assets= [Select assetComponentProcessedMessage__c,assetComponentCreatedStatus__c,assetArenaProductCode__c from Asset where assetArenaProductCode__c='ES1-AFS'];
         System.assertEquals(1,assets.size());
         System.assertEquals('ES1-AFS',assets[0].assetArenaProductCode__c);

         assetES1AFSProductFixBatch e = new assetES1AFSProductFixBatch();
         Database.executeBatch(e,1);

         
         //components = [Select Id from Component__c];
         //System.assertEquals(0,components.size());
         
         //assets = [Select assetComponentProcessedMessage__c,assetComponentCreatedStatus__c from Asset];
         //System.assertEquals(1,assets.size());
         //System.assertEquals(null,assets[0].assetComponentProcessedMessage__c);
         //System.assertEquals(null,assets[0].assetComponentCreatedStatus__c);
         
         
     }
    
}