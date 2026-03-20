@isTest
private class AssetParentAssetMapSchedulerTest {
    
@testSetup
    static void setupData() {
        
        Product2 pro=new Product2();
        pro.Name='test';
        Pro.Component_Code__c='test1';
        pro.ProductCode='test1';
        pro.Asset_Type__c='test1';
        pro.infosight_identifier__c='test1';
        pro.Family='Block Storage';
        pro.asset_Type__c='test1';
        pro.Array_Controller__c='test1';
        insert pro;
        
        Account acc=new Account();
        acc.Name='test acc';
        
        insert acc;
        Contact con= new Contact();
        con.LastName='last';
        con.Email='test@gmail.com';
        
        con.AccountId=acc.Id;
        insert con;
        
        Asset parentAsset = new Asset(Name = 'Parent Asset',ContactId=con.Id,
            AccountId=acc.Id,Product2Id=pro.id);
        insert parentAsset;

        Asset childAsset = new Asset(
            Name = 'Child Asset',
            Product2Id=pro.id,
             Status ='Shipped',
            ContactId=con.Id,
            AccountId=acc.Id
        );
        insert childAsset;

        Asset_Stage__c stage = new Asset_Stage__c(
            parent_Asset_SN__c = 'SN-123',
            Asset__c = childAsset.Id
        );
        insert stage;

    }


    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        Database.executeBatch(new AssetParentAssetMapBatch(), 200);
        Test.stopTest();
       
    }
    
    @isTest
    static void testSchedulableExecution() {
        Test.startTest();
        String jobId = System.schedule(
            'Test Asset Parent Asset Map Batch Job',
            '0 0 12 * * ?', // Run once at 12:00 PM
            new AssetParentAssetMapBatch()
        );
        Test.stopTest();

       
    }
}