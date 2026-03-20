@isTest
public class CalculateAssetTest {
    
    class TestData {
        Account testAccount;
        Contact testContact;
        Product2 testProduct1;
        
        TestData() {
            
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            
            //Create PROD 1
            insert testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                               ProductCode='CS220',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='SAN Storage Array',
                                               Controller_Code__c='CS200',
                                               Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                               Family='SAN Storage Array');           
        }
    }
    
    
    static testMethod void InsertAssetsForAccount() {
         TestData    testData;
         List<Asset> assets = new List<Asset>();
         List<Account> accounts;
         testData = new TestData();
         for(Integer i=0; i< 20; i++)
         {
              // Create test Asset
           Asset testAsset1 = new Asset(Name                                      = 'AA-111111',
                                        AccountId                                 = testData.testAccount.Id,
                                        ContactId                                 = testData.testContact.Id,
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
                                        Product2Id=testData.testProduct1.Id,
                                        Status='Shipped');
             
            assets.add(testAsset1);
             
         }
        insert assets;
        
        assets = [select Id from asset where AccountId=: testData.testAccount.Id];
        System.assertEquals(20,                  assets.size());
        
        accounts = [select Install_Base__c from Account where Id=: testData.testAccount.Id];
        System.assertEquals(20,                  accounts[0].Install_Base__c);
       
        
    }
    
    static testMethod void updateAssetForAccount() {
         TestData    testData;
         List<Asset> assets = new List<Asset>();
         List<Account> accounts;
         testData = new TestData();

        for(Integer i=0; i< 2; i++)
         {
         Asset testAsset1 = new Asset(Name                                      = 'AA-111111',
                                        AccountId                                 = testData.testAccount.Id,
                                        ContactId                                 = testData.testContact.Id,
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
                                        Product2Id=testData.testProduct1.Id,
                                        Status='Shipped');
             
             
           assets.add(testAsset1);
         }

        insert assets;

        assets = [SELECT  Id,Status FROM asset ];
        System.assertEquals(2,                        assets.size());
    
        accounts = [select Install_Base__c from Account where Id=: testData.testAccount.Id];
        System.assertEquals(2,                  accounts[0].Install_Base__c);
        
        CountAssetPreventRecursive.run = true;
    
        assets = [select Id,Status from asset where AccountId=: testData.testAccount.Id Limit 1];
        assets[0].Status='Returned';
        update assets[0];
        
        assets = [SELECT  Id,Status FROM asset where Status='Returned'];

        System.assertEquals(1,                        assets.size());
        
        accounts = [select Install_Base__c from Account where Id=: testData.testAccount.Id];
        System.assertEquals(1,                  accounts[0].Install_Base__c);
   
    }
    
   static testMethod void deleteAssetForAccount() {
         TestData    testData;
         List<Asset> assets = new List<Asset>();
         List<Account> accounts;
         testData = new TestData();

         Asset testAsset1 = new Asset(Name                                      = 'AA-111111',
                                        AccountId                                 = testData.testAccount.Id,
                                        ContactId                                 = testData.testContact.Id,
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
                                        Product2Id=testData.testProduct1.Id,
                                        Status='Shipped');
             
             
        insert testAsset1; 
    
        accounts = [select Install_Base__c from Account where Id=: testData.testAccount.Id];
        System.assertEquals(1,                  accounts[0].Install_Base__c);
    
        assets = [select Id from asset where AccountId=: testData.testAccount.Id];
        delete assets[0];
    
        accounts = [select Install_Base__c from Account where Id=: testData.testAccount.Id];
        System.assertEquals(0,                  accounts[0].Install_Base__c);
   
    }
    
}