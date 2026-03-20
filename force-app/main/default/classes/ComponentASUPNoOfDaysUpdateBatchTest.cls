@isTest
private class ComponentASUPNoOfDaysUpdateBatchTest {

    class TestData {
        
        Account testAccount;
        Contact testContact;
        Asset   testAsset1;
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
                                          Autosupport_Last_Received__c              = Date.today(),
                                          HPE_Serial_Number__c						= '123456'
                                          );
            
            insert testComponent1 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC',
                                                     componentMostRecentASUP__c = Date.today().addDays(-6));
        }
    }
    static testMethod void asupBetween4To30Days() {
        TestData      testData;
        List<Component__c> componentCheck;
        testData = new TestData();
        string query = 'select id, componentAsset_ASUP_Last_Received__c,componentMostRecentASUP__c,componentNoOfDaysBetweenAssetAndComp__c  from component__c where componentServicePartNumber__c = \'SR-CHASSIS-3U-SMC\'';
        ComponentStatusAndAssetUnlinkUpdateBatch comp = new ComponentStatusAndAssetUnlinkUpdateBatch(query);
        Database.executeBatch(comp, 10);
        componentCheck = [Select componentAccountId__c, componentAsset__c, componentServicePartNumber__c, componentState__c, Sub_State__c, componentComponentSN__c, componentType__c, componentDescription__c, componentMostRecentASUP__c, componentNoOfDaysBetweenAssetAndComp__c from Component__c where componentAsset__r.Name = 'AA-111111'];
        
    }
    static testMethod void asupGreaterThan30Days() {
         Account testAccount;
        Contact testContact;
        Asset   testAsset1;
        Component__c testComponent1;
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
                                          Autosupport_Last_Received__c              = Date.today(),
                                          HPE_Serial_Number__c						= '123456'
                                          );
            
            insert testComponent1 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentAsset__c = testAsset1.Id,
                                                     componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c=null,
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC',
                                                     componentMostRecentASUP__c = Date.today().addDays(-40));
        string query = 'select id, componentAsset_ASUP_Last_Received__c,componentMostRecentASUP__c,componentNoOfDaysBetweenAssetAndComp__c  from component__c where componentServicePartNumber__c = \'SR-CHASSIS-3U-SMC\'';
        ComponentStatusAndAssetUnlinkUpdateBatch comp = new ComponentStatusAndAssetUnlinkUpdateBatch(query);
        Database.executeBatch(comp, 10);
    
    }
}