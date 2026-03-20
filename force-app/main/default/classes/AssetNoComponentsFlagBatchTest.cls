@isTest
public class AssetNoComponentsFlagBatchTest {

    static testMethod void createDate(){
        Account testAccount;
        Contact testContact;
        Asset testAsset;
        Component__c testComponent;
        
        // Create test Account
        insert testAccount = new Account(Name = 'Acme Corporation');
        
        // Create test Contact
        insert testContact = new Contact(LastName  = 'Doe',
                                         FirstName = 'John',
                                         AccountId = testAccount.Id);
        insert testAsset = new Asset(Name                                      = 'AA-111111',
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
                                      Autosupport_Last_Received__c              = Date.today().addDays(-50));
        
        insert testComponent = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC');
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;
        string query = 'Select id, assetNoComponents__c from Asset where assetComponentCreatedStatus__c = null AND assetComponentProcessedMessage__c = null AND Name = \'AA-111111\'';
        AssetNoComponentsFlagBatch assetNoComp = new AssetNoComponentsFlagBatch(query);
        Database.executeBatch(assetNoComp, 10);
    }
    static testMethod void NoComponents(){
        Account testAccount;
        Contact testContact;
        Asset testAsset;
        Component__c testComponent;
        
        // Create test Account
        insert testAccount = new Account(Name = 'Acme Corporation');
        
        // Create test Contact
        insert testContact = new Contact(LastName  = 'Doe',
                                         FirstName = 'John',
                                         AccountId = testAccount.Id);
        insert testAsset = new Asset(Name                                      = 'AA-111111',
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
                                      Autosupport_Last_Received__c              = Date.today().addDays(-50));
        
        CountAssetPreventRecursive.run = true; 
        assetPreventRecursive.run = true;
        string query = 'Select id, assetNoComponents__c from Asset where assetComponentCreatedStatus__c = null AND assetComponentProcessedMessage__c = null AND Name = \'AA-111111\'';
        AssetNoComponentsFlagBatch assetNoComp = new AssetNoComponentsFlagBatch(query);
        Database.executeBatch(assetNoComp, 10);
    }
}