@istest(SeeAllData=true)
public class caseAttnReqSnoozeControllerTest {
    
    class TestData {
        Case aCase;
        User use;
        Product2 testProduct1; 
        TestData() {
            
            // Create test account
            // create test user
            Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)' limit 1]; 
            User use =userFromDB();
            Account account=[Select Id from Account limit 1];
            Asset asset=[Select Id from Asset limit 1];
            Contact contact=[Select Id from Contact limit 1];
            // Create test case
            insert aCase = new Case(AccountId = account.Id,
                                    AssetId   = asset.Id,
                                    ContactId = contact.Id,
                                    Subject = 'TEST-CASE-SUBJECT', 
                                    OwnerId = use.Id);
            
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            System.assertEquals(contact.Id,       aCase.ContactId);
            System.assertEquals('TEST-CASE-SUBJECT', aCase.Subject);
        }
    }
    
    static testMethod void caseTSENextReturnValidationOnMond(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        User UserRecord =userFromDB();
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id limit 1];
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Monday__c = True;
        contTSE.Saturday__c = False;
        contTSE.Friday__c = False;
        contTSE.Sunday__c=False;
        contTSE.Tuesday__c=False;
        contTSE.Wednesday__c=False;
        contTSE.Thursday__c=False;
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    static testMethod void caseTSENextReturnValidationOnTue(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        
        User UserRecord = userFromDB();
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.Id  limit 1];
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Tuesday__c = True;
        contTSE.Monday__c = False;
        contTSE.Saturday__c = False;
        contTSE.Friday__c = False;
        contTSE.Sunday__c=False;
        
        contTSE.Wednesday__c=False;
        contTSE.Thursday__c=False;
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    static testMethod void caseTSENextReturnValidationOnWed(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        
        User UserRecord = userFromDB();
        
        TestData.aCase.caseAttnReq__c = True;
        TestData.aCase.caseAttnReqDateTime__c = DateTime.now();
        
        update TestData.aCase;
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id  limit 1];
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now().addHours(6);
        contTSE.Shift_Length__c = '8';
        contTSE.Wednesday__c = True;
        contTSE.Monday__c = False;
        contTSE.Saturday__c = False;
        contTSE.Friday__c = False;
        contTSE.Sunday__c=False;
        contTSE.Tuesday__c=False;
        
        contTSE.Thursday__c=False;
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    static testMethod void caseTSENextReturnValidationOnThurs(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        
        User UserRecord =userFromDB();
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id  limit 1];
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Thursday__c = True;
        contTSE.Monday__c = False;
        contTSE.Saturday__c = False;
        contTSE.Friday__c = False;
        contTSE.Sunday__c=False;
        contTSE.Tuesday__c=False;
        contTSE.Wednesday__c=False;
        
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    static testMethod void caseTSENextReturnValidationOnFriday(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        System.assertNotEquals(null,              account.Id);
        System.assertEquals('TEST-ACCOUNT', account.Name);
        System.assertEquals('Account RMA SHI',    account.accountRmaShi__c);
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        User UserRecord =userFromDB();
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.Id  limit 1];
        Case attn=new Case();
        attn.Id=caseRecord.id;
        attn.caseAttnReq__c = True;
        attn.caseAttnReqDateTime__c = DateTime.now();
        attn.AttnSnoozeIntervalInHours__c = '8';
        attn.caseAttnReqSnoozeReason__c =Null;
        Update attn;
        Case caseRecord2 = [Select ownerID,caseCurrendDateTime__c,Is_CaseOwner_On_Shift__c,caseAttnReq__c,caseAttnReqDateTime__c,AttnSnoozeIntervalInHours__c,caseAttnReqSnoozeReason__c,AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id and id=:attn.Id  limit 1];
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Friday__c = True;
        contTSE.Monday__c=False;
        contTSE.Tuesday__c=False;
        contTSE.Wednesday__c=False;
        contTSE.Thursday__c=False;
        contTSE.Saturday__c=False;
        contTSE.Sunday__c=False;
        
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord2);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.save();
        caseController.showHours=true;
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    static testMethod void caseTSENextReturnValidationOnSaturday(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        
        User UserRecord =userFromDB();
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c,Is_CaseOwner_On_Shift__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id  limit 1];
        Case attn=new Case();
        attn.Id=caseRecord.id;
        attn.caseAttnReq__c = True;
        attn.caseAttnReqDateTime__c = DateTime.now();
        attn.AttnSnoozeIntervalInHours__c =Null;
        attn.caseAttnReqSnoozeReason__c = 'Test comment';
        Update attn;
        Case caseRecord2 = [Select ownerID,caseCurrendDateTime__c,Is_CaseOwner_On_Shift__c,caseAttnReq__c,caseAttnReqDateTime__c,AttnSnoozeIntervalInHours__c,caseAttnReqSnoozeReason__c,AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id and id=:attn.Id  limit 1];
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Saturday__c = True;
        contTSE.Friday__c = False;
        contTSE.Monday__c=False;
        contTSE.Tuesday__c=False;
        contTSE.Wednesday__c=False;
        contTSE.Thursday__c=False;
        contTSE.Sunday__c=False;
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord2);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.save();
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    static testMethod void caseTSENextReturnValidationOnSaturdayOnSuday(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        
        User UserRecord =userFromDB();
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id  limit 1];
        Case attn=new Case();
        attn.Id=caseRecord.id;
        attn.caseAttnReq__c = True;
        attn.caseAttnReqDateTime__c = DateTime.now();
        attn.AttnSnoozeIntervalInHours__c = '8';
        attn.caseAttnReqSnoozeReason__c = 'Test comment';
        Update attn;
        Case caseRecord2 = [Select ownerID,caseCurrendDateTime__c,Is_CaseOwner_On_Shift__c,caseAttnReq__c,caseAttnReqDateTime__c,AttnSnoozeIntervalInHours__c,caseAttnReqSnoozeReason__c,AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id and id=:attn.Id  limit 1];
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;   
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Sunday__c = True;
        contTSE.Saturday__c = False;
        contTSE.Friday__c = False;
        contTSE.Monday__c=False;
        contTSE.Tuesday__c=False;
        contTSE.Wednesday__c=False;
        contTSE.Thursday__c=False;
        
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord2);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.save();
        Test.stopTest();
    }
    static testMethod void caseAttnReqIntervalsInHours(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        
        User UserRecord =userFromDB();
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c,caseAttnReqDateTime__c, AttnSnoozeIntervalInHours__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id  limit 1];
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;   
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Sunday__c = True;
        contTSE.Saturday__c = False;
        contTSE.Friday__c = False;
        contTSE.Monday__c=False;
        contTSE.Tuesday__c=False;
        contTSE.Wednesday__c=False;
        contTSE.Thursday__c=False;
        
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.callStatus();
        caseController.displayText();
        caseController.getSnoozeHours();
        Test.stopTest();
        
    }
    static testMethod void caseSaveMethod(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        User UserRecord =userFromDB();
        
        TestData.aCase.caseAttnReq__c = True;
        TestData.aCase.caseAttnReqDateTime__c = DateTime.now();
        TestData.aCase.AttnSnoozeIntervalInHours__c = '8';
        TestData.aCase.caseAttnReqSnoozeReason__c = 'Test comment';
        
        update TestData.aCase;
        
        Case caseRecord = [Select Id,ownerID,caseCurrendDateTime__c,Is_CaseOwner_On_Shift__c,caseAttnReqDateTime__c, AttnSnoozeIntervalInHours__c,caseAttnReqSnoozeReason__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id  limit 1];
        Case attn=new Case();
        attn.Id=caseRecord.id;
        attn.caseAttnReq__c = True;
        attn.caseAttnReqDateTime__c = DateTime.now();
        attn.AttnSnoozeIntervalInHours__c = '8';
        attn.caseAttnReqSnoozeReason__c = 'Test comment';
        Update attn;
        
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc(); 
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Sunday__c = True;
        contTSE.Saturday__c = False;
        contTSE.Friday__c = False;
        contTSE.Monday__c=False;
        contTSE.Tuesday__c=False;
        contTSE.Wednesday__c=False;
        contTSE.Thursday__c=False;
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.save();
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    static testMethod void caseSaveMethodElseIfCondition(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        
        User UserRecord = userFromDB();
        
        TestData.aCase.caseAttnReq__c = True;
        TestData.aCase.caseAttnReqDateTime__c = DateTime.now();
        TestData.aCase.AttnSnoozeIntervalInHours__c = '8';
        TestData.aCase.caseAttnReqSnoozeReason__c = null;
        
        update TestData.aCase;
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c,Is_CaseOwner_On_Shift__c,caseAttnReqDateTime__c, AttnSnoozeIntervalInHours__c,caseAttnReqSnoozeReason__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =:UserRecord.id  limit 1];
        
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Sunday__c = True;
        contTSE.Saturday__c = False;
        contTSE.Friday__c = False;
        contTSE.Monday__c=False;
        contTSE.Tuesday__c=False;
        contTSE.Wednesday__c=False;
        contTSE.Thursday__c=False;
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.save();
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    static testMethod void caseSaveMethodElseCondition(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        
        User UserRecord =userFromDB();
        
        TestData.aCase.caseAttnReq__c = True;
        TestData.aCase.caseAttnReqDateTime__c = DateTime.now();
        TestData.aCase.AttnSnoozeIntervalInHours__c = null;
        TestData.aCase.caseAttnReqSnoozeReason__c = null;
        
        update TestData.aCase;
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c,Is_CaseOwner_On_Shift__c,caseAttnReqDateTime__c, AttnSnoozeIntervalInHours__c,caseAttnReqSnoozeReason__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id  limit 1];
        
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc(); 
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now();
        contTSE.Shift_Length__c = '8';
        contTSE.Sunday__c = True;
        contTSE.Saturday__c = False;
        contTSE.Friday__c = False;
        contTSE.Monday__c=False;
        contTSE.Tuesday__c=False;
        contTSE.Wednesday__c=False;
        contTSE.Thursday__c=False;
        
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc);
        caseController.save();
        caseController.test();
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    static testMethod void casegetSnoozeHours(){
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert account;
        
        
        // Create test contact
        Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = account.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        // Create test asset
        Asset asset =new Asset(Name                                      = 'TEST-ASSET',
                               AccountId                                 = account.Id,
                               ContactId                                 = contact.Id,
                               SLA__c                                    = 'Premium',
                               Install_Street1__c                        = '123 Main Street',
                               Install_Street2__c                        = 'Suite 100',
                               Install_City__c                           = 'San Jose',
                               Install_State_Province__c                 = 'CA',
                               Install_Zip_Code__c                       = '95151',
                               Install_Country__c                        = 'United States',
                               Asset_Type_Build__c						= 'Next Gen',
                               Component_SKU_HPE__c = 'R4U28A',
                               Component_SKU_Nimble_V2__c = '6010',
                               Ship_Date__c                              = Date.today().addDays(-180),
                               assetPartShipLastValidatedDatetime__c     = Date.today(),
                               assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                               Status                                    = 'Shipped',
                               Autosupport_Last_Received__c              = Date.today().addDays(-50),
                               Product2Id								= testProduct1.Id,
                               Array_Controller__c 						= 'CS300',
                               Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c 					= '2P',
                               Array_Cache__c 							= '640F',
                               SSD_Bank_A__c 							= '480F',
                               SSD_Bank_B__c 							= '480F',
                               Expansion_Shelf_Base__c 					= 'AFS2',
                               assetRmaShi__c                                 ='Asset RMA SHI',
                               Array_Capacity__c 						= '11T');
        Insert asset;
        
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        
        PageReference pageRef = Page.caseAttnReqSnooze;
        Test.setCurrentPage(pageRef);
        
        
        
        User UserRecord = userFromDB();
        
        TestData.aCase.caseAttnReq__c = True;
        TestData.aCase.caseAttnReqDateTime__c = DateTime.now();
        
        update TestData.aCase;
        
        Case caseRecord = [Select ownerID,caseCurrendDateTime__c,caseAttnReqDateTime__c, AttnSnoozeIntervalInHours__c,caseAttnReqSnoozeReason__c, AccountId,AssetId,ContactId, Subject from Case Where OwnerID =: UserRecord.id limit 1];
        
        CntrbnMdl_TSE__c contributionCurrent =ContributionTsc();
        CntrbnMdl_TSE__c contTSE = new CntrbnMdl_TSE__c();
        contTSE.Id=contributionCurrent.id;
        contTSE.Enter_Starttime__c = DateTime.now().addHours(5);
        contTSE.Shift_Length__c = '8';
        contTSE.Monday__c = True;
        contTSE.Tuesday__c = True;
        contTSE.Wednesday__c = True;
        contTSE.Thursday__c = True;
        contTSE.Friday__c = True;
        contTSE.Saturday__c = True;
        contTSE.Sunday__c = True;
        contTSE.Employee_Name__c = caseRecord.OwnerId;
        contTSE.Organization__c='TSE';
        Update contTSE;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        caseAttnReqSnoozeController caseController = new caseAttnReqSnoozeController(sc); 
        dateTime startDate=system.now();
        caseController.numberOfHours(startDate,startDate);
        caseController.getSnoozeHours();
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    public static User userFromDB(){
        User use = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
                    TimeZoneSidKey, UserName from user where id =: '0052H00000DPTuj' limit 1];
        return use; 
    }
    //@isTest(SeeAllData=true)
    public static CntrbnMdl_TSE__c ContributionTsc(){
        //User use = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
        //            TimeZoneSidKey, UserName from user where id =: '0052H00000DPTuj' limit 1];
        User use = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
                    TimeZoneSidKey, UserName from user where Name = 'Rich Maxwell' limit 1];

        CntrbnMdl_TSE__c Tsc = [Select id,Enter_Starttime__c,Shift_Length__c,Employee_Name__c,Organization__c,Friday__c,Thursday__c from CntrbnMdl_TSE__c where Employee_Name__c=:use.id limit 1];
        return Tsc; 
    } 	
}