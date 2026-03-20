@isTest
public class caseSetNimbleOsVersionHandlerTest {
    
    class TestData {
        Account testAccount;
        Contact testContact;
        Asset   testAsset;
        Case aCase;
        
        TestData() {
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            
            
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            Product2 prd = new Product2(Name = 'SSD Storage Array',
                                        ProductCode='HF600',
                                        Product_Type__c='Hardware',
                                        Product_Type_2__c='SAN Storage ArrayS',
                                        Controller_Code__c='CS2001',
                                        Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                        Family='SAN Storage Array');
            insert prd;
            
            // Create test Asset
            insert testAsset = new Asset(Name                                      = 'AA-111111',
                                         AccountId                                 = testAccount.Id,
                                         ContactId                                 = testContact.Id,
                                         SLA__c                                    = 'Premium',
                                         Nimble_Version__c                         = '11.1.111.135-opt123',
                                         Ship_Date__c                              = Date.today().addDays(-180),
                                         
                                         assetPartShipLastValidatedDatetime__c     = Date.today(),
                                         
                                         assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                                         Product2id = prd.id,
                                         
                                         assetRmaShi__c = 'Asset RMA SHI',
                                         HPE_Serial_Number__c ='AA000000NIM',
                                         Array_Controller__c = 'CS3001',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                         Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                         Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
            
            
        }
        
        void insertCase1_WithNimbleOS()
        {
            // Create test case
            aCase = new Case(AccountId = testAccount.Id,
                             AssetId   = testAsset.Id,
                             ContactId = testContact.Id,
                             Nimble_Version__c = '1.1.1.1-opt1234',
                             Subject = 'TEST-CASE-SUBJECT');
            insert aCase;
        }
        
        void insertCase2_WithoutNimbleOS()
        {
            // Create test case
            aCase = new Case(AccountId = testAccount.Id,
                             AssetId   = testAsset.Id,
                             ContactId = testContact.Id,
                             Status = 'Open',
                             Nimble_Version__c = '',
                             Subject = 'TEST-CASE-SUBJECT');
            insert aCase;
        }
        
        void insertCase3_WithOS_AssetOSPresent()
        {
            // Create test case
            aCase = new Case(AccountId = testAccount.Id,
                             AssetId   = testAsset.Id,
                             ContactId = testContact.Id,
                             Nimble_Version__c = 'NMB - 1.2.3.4',
                             Subject = 'TEST-CASE-SUBJECT');
            insert aCase;
        }
        
        void updateAssetOSVerionToNull()
        {
            testAsset.Nimble_Version__c = '';
            update testAsset;
        }
        
    }
    
    static testMethod void test_Insert_setIncomingNimbleOSVersion() {
        TestData    testData;
        List<Case> cases;
        testData = new TestData();
        testData.insertCase1_WithNimbleOS();
        
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Subject,
                 Nimble_Version__c
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-SUBJECT'];
        
        System.assertEquals(1,                   cases.size());
        System.assertEquals(testData.testAccount.Id,       cases[0].AccountId);
        System.assertEquals(testData.testAsset.Id,         cases[0].AssetId);
        System.assertEquals(testData.testContact.Id,       cases[0].ContactId);
        System.assertEquals('1.1.1.1', cases[0].Nimble_Version__c);
        
    }
    
    static testMethod void test_Insert_setAssetOSVersionWhenIncomingNull() {
        TestData    testData;
        List<Case> cases;
        testData = new TestData();
        testData.insertCase2_WithoutNimbleOS();
        
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Subject,
                 Nimble_Version__c
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-SUBJECT'];
        
        System.assertEquals(1,                   cases.size());
        System.assertEquals(testData.testAccount.Id,       cases[0].AccountId);
        System.assertEquals(testData.testAsset.Id,         cases[0].AssetId);
        System.assertEquals(testData.testContact.Id,       cases[0].ContactId);
        System.assertEquals('11.1.111.135', cases[0].Nimble_Version__c);
        
    }
    
    static testMethod void test_Insert_setCaseOsVerionToUnknown() {
        TestData    testData;
        List<Case> cases;
        testData = new TestData();
        testData.updateAssetOSVerionToNull();
        Test.startTest();
        testData.insertCase2_WithoutNimbleOS();
        
        
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Subject,
                 Nimble_Version__c
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-SUBJECT'];
        
        System.assertEquals(1,                   cases.size());
        System.assertEquals(testData.testAccount.Id,       cases[0].AccountId);
        System.assertEquals(testData.testAsset.Id,         cases[0].AssetId);
        System.assertEquals(testData.testContact.Id,       cases[0].ContactId);
        System.assertEquals('Unknown', cases[0].Nimble_Version__c);
        Test.stopTest();
        
    }
    
    static testMethod void test_Insert_setCaseOsVerionToStaticValue() {
        TestData    testData;
        List<Case> cases;
        testData = new TestData();
        testData.insertCase3_WithOS_AssetOSPresent();
        
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Subject,
                 Nimble_Version__c
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-SUBJECT'];
        
        System.assertEquals(1,                   cases.size());
        System.assertEquals(testData.testAccount.Id,       cases[0].AccountId);
        System.assertEquals(testData.testAsset.Id,         cases[0].AssetId);
        System.assertEquals(testData.testContact.Id,       cases[0].ContactId);
        System.assertEquals('NMB - 1.2.3.4', cases[0].Nimble_Version__c);
        
    }
    
    
    static testMethod void test_Update_setNimbleVersionUnknow() {
        TestData    testData;
        List<Case> cases;
        testData = new TestData();
        testData.updateAssetOSVerionToNull();
        Test.startTest();
        testData.insertCase2_WithoutNimbleOS();
        
        testData.aCase.Nimble_Version__c = 'Unknown';
        update testData.aCase;
        
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Subject,
                 Nimble_Version__c
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-SUBJECT'];
        
        System.assertEquals(1,                   cases.size());
        System.assertEquals(testData.testAccount.Id,       cases[0].AccountId);
        System.assertEquals(testData.testAsset.Id,         cases[0].AssetId);
        System.assertEquals(testData.testContact.Id,       cases[0].ContactId);
        System.assertEquals('Unknown', cases[0].Nimble_Version__c);
        Test.stopTest();
        
    }
    
    static testMethod void test_Update_setNimbleVersionToAssetNimbleOs() {
        TestData    testData;
        List<Case> cases;
        testData = new TestData();
        testData.updateAssetOSVerionToNull();
        Test.startTest();
        testData.insertCase2_WithoutNimbleOS();
        
        testData.testAsset.Nimble_Version__c = '2.2.2.2';
        update testData.testAsset;
        
        testData.aCase.Nimble_Version__c = 'Unknown';
        update testData.aCase;
        
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Subject,
                 Nimble_Version__c
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-SUBJECT'];
        
        System.assertEquals(1,                   cases.size());
        System.assertEquals(testData.testAccount.Id,       cases[0].AccountId);
        System.assertEquals(testData.testAsset.Id,         cases[0].AssetId);
        System.assertEquals(testData.testContact.Id,       cases[0].ContactId);
        //System.assertEquals('2.2.2.2', cases[0].Nimble_Version__c);
        Test.stopTest();
        
    }
    
    static testMethod void test_Update_setIncomingCaseNimbleOs() {
        TestData    testData;
        List<Case> cases;
        testData = new TestData();
        testData.insertCase2_WithoutNimbleOS();
        
        //testData.aCase.Nimble_Version__c = '1.2.3.4';
        //update testData.aCase;
        
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Subject,
                 Nimble_Version__c
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-SUBJECT'];
        
        System.assertEquals(1,                   cases.size());
        System.assertEquals(testData.testAccount.Id,       cases[0].AccountId);
        System.assertEquals(testData.testAsset.Id,         cases[0].AssetId);
        System.assertEquals(testData.testContact.Id,       cases[0].ContactId);
        //System.assertEquals('190.180.170.190', cases[0].Nimble_Version__c);
        
    }
    
    static testMethod void test_Update_setIncomingNimbleOsUnknown() {
        TestData    testData;
        List<Case> cases;
        testData = new TestData();
        testData.insertCase2_WithoutNimbleOS();
        
        testData.aCase.Nimble_Version__c = '11.1.111.135';
        update testData.aCase;
        
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Subject,
                 Nimble_Version__c
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-SUBJECT'];
        
        System.assertEquals(1,                   cases.size());
        System.assertEquals(testData.testAccount.Id,       cases[0].AccountId);
        System.assertEquals(testData.testAsset.Id,         cases[0].AssetId);
        System.assertEquals(testData.testContact.Id,       cases[0].ContactId);
        System.assertEquals('11.1.111.135', cases[0].Nimble_Version__c);
        
    }
}