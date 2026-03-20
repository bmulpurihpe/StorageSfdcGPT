@isTest
public class ACMServiceUsedAccUpdateTest {
    
    class TestData {
        Account account;
        List<Account> accounts;
        Asset  asset;
        List<Asset> assets;
        
        TestData()
        {
            
            account = new Account(Name = 'Test Account', ACM_Start_Date__c = Date.today(),ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
            insert account;
            accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c FROM   Account WHERE  Name = 'Test Account'];
            
            System.assertEquals(1,              accounts.size());
            System.assertEquals('Test Account', accounts[0].Name);
            System.assertEquals(Date.today(), accounts[0].ACM_Start_Date__c);
            System.assertEquals(Date.today() + 365, accounts[0].ACM_End_Date__c);
            System.assertEquals(1, accounts[0].ACM_Service_Purchased_Quantity__c);
            System.assertEquals(true, accounts[0].ACM_Service_Purchased__c);
        }
        
        void updAccountACMService_False()
        {
            accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c FROM   Account WHERE  Name = 'Test Account'];
            accounts[0].ACM_Service_Purchased__c = false;
            update accounts[0];
            
            accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c FROM   Account WHERE  Name = 'Test Account'];
            System.assertEquals(1,              accounts.size());
            System.assertEquals(false, accounts[0].ACM_Service_Purchased__c);
        }
        
        void updAccountACMQuantity_Null()
        {
            accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c FROM   Account WHERE  Name = 'Test Account'];
            accounts[0].ACM_Service_Purchased_Quantity__c = null;
            update accounts[0];
            
            accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c FROM   Account WHERE  Name = 'Test Account'];
            System.assertEquals(1,              accounts.size());
            System.assertEquals(null, accounts[0].ACM_Service_Purchased_Quantity__c);
        }
        
        void updAccountACMStartAndEndDate_Null()
        {
            accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c FROM   Account WHERE  Name = 'Test Account'];
            accounts[0].ACM_Start_Date__c = null;
            accounts[0].ACM_End_Date__c = null;
            update accounts[0];
            
            accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c FROM   Account WHERE  Name = 'Test Account'];
            System.assertEquals(1,              accounts.size());
            System.assertEquals(null, accounts[0].ACM_Start_Date__c);
            System.assertEquals(null, accounts[0].ACM_End_Date__c);
        }
        
        void createParentChildAsset()
        {
            // Create Parent asset 01
            asset = new Asset(Name = 'PARENT-ASSET',
                              AccountId = account.Id,
                              SLA__c = 'Premium',
                              Install_Street1__c        = 'PARENT-ASSET-INSTALL-STREET1',
                              Install_Street2__c        = 'PARENT-ASSET-INSTALL-STREET2',
                              Install_City__c           = 'PARENT-ASSET-INSTALL-CITY',
                              Install_State_Province__c = 'PARENT-ASSET-INSTALL-STATE',
                              Status ='Shipped',
                              assetConcierge_Service__c = true);
            insert asset;
            assets = [SELECT Id,
                      Name,
                      AccountId,
                      Status,
                      SLA__c,
                      Install_Street1__c,
                      Install_Street2__c,
                      Install_City__c,
                      Install_State_Province__c,
                      assetConcierge_Service__c
                      FROM   Asset
                      WHERE  Name = 'PARENT-ASSET'];
            
            System.assertEquals(1,                             assets.size());
            System.assertEquals('PARENT-ASSET',                  assets[0].Name);
            System.assertEquals(account.Id,                 assets[0].AccountId);
            System.assertEquals('Premium',                     assets[0].SLA__c);
            System.assertEquals('PARENT-ASSET-INSTALL-STREET1',  assets[0].Install_Street1__c);
            System.assertEquals('PARENT-ASSET-INSTALL-STREET2',  assets[0].Install_Street2__c);
            System.assertEquals('PARENT-ASSET-INSTALL-CITY',     assets[0].Install_City__c);
            System.assertEquals('PARENT-ASSET-INSTALL-STATE',    assets[0].Install_State_Province__c);
            System.assertEquals('Shipped',    assets[0].Status);
            System.assertEquals(true,    assets[0].assetConcierge_Service__c);
            
            // Create Child asset
            asset = new Asset(Name = 'CHILD-ASSET',
                              AccountId = account.Id,
                              SLA__c = 'Premium',
                              Install_Street1__c        = 'CHILD-ASSET-INSTALL-STREET1',
                              Install_Street2__c        = 'CHILD-ASSET-INSTALL-STREET2',
                              Install_City__c           = 'CHILD-ASSET-INSTALL-CITY',
                              Install_State_Province__c = 'CHILD-ASSET-INSTALL-STATE',
                              Parent_Asset__c = asset.Id,
                              assetConcierge_Service__c = false);
            insert asset;
            assets = [SELECT Id,
                      Name,
                      AccountId,
                      SLA__c,
                      Install_Street1__c,
                      Install_Street2__c,
                      Install_City__c,
                      Install_State_Province__c,
                      assetConcierge_Service__c
                      FROM   Asset
                      WHERE  Name = 'CHILD-ASSET'];
            
            System.assertEquals(1,                             assets.size());
            System.assertEquals('CHILD-ASSET',                  assets[0].Name);
            System.assertEquals(account.Id,                 assets[0].AccountId);
            System.assertEquals('Premium',                     assets[0].SLA__c);
            System.assertEquals('CHILD-ASSET-INSTALL-STREET1',  assets[0].Install_Street1__c);
            System.assertEquals('CHILD-ASSET-INSTALL-STREET2',  assets[0].Install_Street2__c);
            System.assertEquals('CHILD-ASSET-INSTALL-CITY',     assets[0].Install_City__c);
            System.assertEquals('CHILD-ASSET-INSTALL-STATE',    assets[0].Install_State_Province__c);
            System.assertEquals(true,    assets[0].assetConcierge_Service__c);
        }
        
        void createAsset_Returned()
        {
             // Create Parent asset 01
            asset = new Asset(Name = 'PARENT-ASSET',
                              AccountId = account.Id,
                              SLA__c = 'Premium',
                              Install_Street1__c        = 'PARENT-ASSET-INSTALL-STREET1',
                              Install_Street2__c        = 'PARENT-ASSET-INSTALL-STREET2',
                              Install_City__c           = 'PARENT-ASSET-INSTALL-CITY',
                              Install_State_Province__c = 'PARENT-ASSET-INSTALL-STATE',
                              Status ='Returned',
                              assetConcierge_Service__c = true);
            insert asset;
            assets = [SELECT Id,
                      Name,
                      AccountId,
                      Status,
                      SLA__c,
                      Install_Street1__c,
                      Install_Street2__c,
                      Install_City__c,
                      Install_State_Province__c,
                      assetConcierge_Service__c
                      FROM   Asset
                      WHERE  Name = 'PARENT-ASSET'];
            
            System.assertEquals(1,                             assets.size());
            System.assertEquals('PARENT-ASSET',                  assets[0].Name);
            System.assertEquals(account.Id,                 assets[0].AccountId);
            System.assertEquals('Premium',                     assets[0].SLA__c);
            System.assertEquals('PARENT-ASSET-INSTALL-STREET1',  assets[0].Install_Street1__c);
            System.assertEquals('PARENT-ASSET-INSTALL-STREET2',  assets[0].Install_Street2__c);
            System.assertEquals('PARENT-ASSET-INSTALL-CITY',     assets[0].Install_City__c);
            System.assertEquals('PARENT-ASSET-INSTALL-STATE',    assets[0].Install_State_Province__c);
            System.assertEquals('Returned',    assets[0].Status);
            System.assertEquals(true,    assets[0].assetConcierge_Service__c);
        }

    }
    
    static testMethod void errorAsset01_ACMServiceNotAvailable()
    {
        Asset  asset;
        TestData testData = new TestData();
        testData.updAccountACMService_False();
        
        Exception dmlException;
        
        // Create Parent asset
        asset = new Asset(Name = 'PARENT-ASSET',
                          AccountId = testData.Account.Id,
                          SLA__c = 'Premium',
                          Install_Street1__c        = 'PARENT-ASSET-INSTALL-STREET1',
                          Install_Street2__c        = 'PARENT-ASSET-INSTALL-STREET2',
                          Install_City__c           = 'PARENT-ASSET-INSTALL-CITY',
                          Install_State_Province__c = 'PARENT-ASSET-INSTALL-STATE',
                          assetConcierge_Service__c = true);
        
        
        try
        {
            insert asset;
        }
        catch(Exception ex)
        {
            dmlException = ex;
        }
        
        System.assertNotEquals(null, dmlException);
        System.assert(dmlException instanceOf system.Dmlexception);
        System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.assert(dmlException.getMessage().contains('Concierge Service field cannot be checked - ACM Service is not available for the Account'));
        
        
        
    }
    
    static testMethod void errorAsset_ACMPurchaseQuantityNotAvailable()
    {
        Asset  asset;
        TestData testData = new TestData();
        testData.updAccountACMQuantity_Null();
        
        Exception dmlException;
        
        // Create Parent asset
        asset = new Asset(Name = 'PARENT-ASSET',
                          AccountId = testData.Account.Id,
                          SLA__c = 'Premium',
                          Install_Street1__c        = 'PARENT-ASSET-INSTALL-STREET1',
                          Install_Street2__c        = 'PARENT-ASSET-INSTALL-STREET2',
                          Install_City__c           = 'PARENT-ASSET-INSTALL-CITY',
                          Install_State_Province__c = 'PARENT-ASSET-INSTALL-STATE',
                          assetConcierge_Service__c = true);
        
        
        try
        {
            insert asset;
        }
        catch(Exception ex)
        {
            dmlException = ex;
        }
        
        System.assertNotEquals(null, dmlException);
        System.assert(dmlException instanceOf system.Dmlexception);
        System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        System.assert(dmlException.getMessage().contains('Concierge Service field cannot be checked - ACM Service Purchased Quantity is not available for the Account'));
        
        
        
    }
    
    static testMethod void CountAsset_Shipped()
    {
        List<Account> accounts;
        TestData testData = new TestData();
        testData.createParentChildAsset();
        
        accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c,ACM_Service_Used_Quantity__c FROM   Account WHERE  Name = 'Test Account'];
        
        System.assertEquals(1,              accounts.size());
        System.assertEquals('Test Account', accounts[0].Name);
        System.assertEquals(Date.today(), accounts[0].ACM_Start_Date__c);
        System.assertEquals(Date.today() + 365, accounts[0].ACM_End_Date__c);
        System.assertEquals(1, accounts[0].ACM_Service_Purchased_Quantity__c);
        System.assertEquals(1, accounts[0].ACM_Service_Used_Quantity__c);
        System.assertEquals(true, accounts[0].ACM_Service_Purchased__c);
        
    }
    
    static testMethod void CountCreateAsset_Returned()
    {
        List<Account> accounts;
        TestData testData = new TestData();
        testData.createAsset_Returned();
        
        accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c,ACM_Service_Used_Quantity__c FROM   Account WHERE  Name = 'Test Account'];
        
        System.assertEquals(1,              accounts.size());
        System.assertEquals('Test Account', accounts[0].Name);
        System.assertEquals(Date.today(), accounts[0].ACM_Start_Date__c);
        System.assertEquals(Date.today() + 365, accounts[0].ACM_End_Date__c);
        System.assertEquals(1, accounts[0].ACM_Service_Purchased_Quantity__c);
        System.assertEquals(0, accounts[0].ACM_Service_Used_Quantity__c);
        System.assertEquals(true, accounts[0].ACM_Service_Purchased__c);
        
    }

    static testMethod void ACMStartDateAndEndDate_Update()
    {
        List<Account> accounts;
        TestData testData = new TestData();
        testData.updAccountACMStartAndEndDate_Null();
        testData.createParentChildAsset();
        
        
        accounts = [SELECT Id,Name,ACM_Start_Date__c,ACM_End_Date__c,ACM_Service_Purchased_Quantity__c,ACM_Service_Purchased__c,ACM_Service_Used_Quantity__c FROM   Account WHERE  Name = 'Test Account'];
        
        System.assertEquals(1,              accounts.size());
        System.assertEquals('Test Account', accounts[0].Name);
        System.assertEquals(Date.today(), accounts[0].ACM_Start_Date__c);
        System.assertEquals(Date.today().addYears(1), accounts[0].ACM_End_Date__c);
        System.assertEquals(1, accounts[0].ACM_Service_Purchased_Quantity__c);
        System.assertEquals(1, accounts[0].ACM_Service_Used_Quantity__c);
        System.assertEquals(true, accounts[0].ACM_Service_Purchased__c);
        
    }

}