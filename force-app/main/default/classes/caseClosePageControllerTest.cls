/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-09-2023   Nagalaxmi Telkar   Initial Version
**/
@isTest 
public class caseClosePageControllerTest {
    
    public static testMethod void caseClosePagetestTATSAValues(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
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
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 assetNimbleOsVersion__c = '6.1.2.500',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
        
        
        
        System.assertNotEquals(null,                      asset.Id);
        System.assertEquals('TEST-ASSET',                  asset.Name);
        System.assertEquals(account.Id,                 asset.AccountId);
        System.assertEquals(contact.Id,                 asset.ContactId);
        System.assertEquals('Premium',                     asset.SLA__c);
        System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
        //Test.startTest();
        
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT',
                                Product_Damage_Symptoms__c = 'Test',
                                Status    = 'Closed',
                                Description ='Test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId());
        //Case_closure_time_spent__c = 1);
        
        
        
        TechnicalSubArea_Mappings__c tsamapping = new TechnicalSubArea_Mappings__c();
        tsamapping.Technical_Area__c ='Array Hardware';
        tsamapping.Technical_SubArea__c = 'Damaged in shipping';
        tsamapping.IsDeleted__c = false;
        tsamapping.Case_Types__c = 'Array Case';
        insert tsamapping;
        
        tsamapping = new TechnicalSubArea_Mappings__c();
        tsamapping.Technical_Area__c ='3rd Party Apps';
        tsamapping.Technical_SubArea__c = 'Exchange';
        tsamapping.IsDeleted__c = false;
        tsamapping.Case_Types__c = 'SSaaS';
        insert tsamapping;
        
        System.assertNotEquals(null,aCase.Id);
        System.assertEquals(account.Id,aCase.AccountId);
        System.assertEquals(asset.Id,aCase.AssetId);
        System.assertEquals(contact.Id,aCase.ContactId);
        System.assertEquals('TEST-CASE-SUBJECT',aCase.Subject);
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        caseClosePageController closeCase = new caseClosePageController(sc);
        //closeCase.SelectedTaValue = 'Array Hardware';
        //closeCase.SelectedTsaValue = 'Damaged in shipping';
        closeCase.estTimeEff = '15 minutes';
        
        closeCase.getClosedStatus();
        closeCase.myCustomSave();
        
        closeCase.getallTaMappings();
        closeCase.allTsaMappingss();
        closeCase.getEstimatedTimeEffort();
        closeCase.getSeverity();
        closeCase.getPriority();
        //newCase.changeSeverity();
        //newCase.changePriority();
        closeCase.getStrFieldSeverity();
        closeCase.getStrFieldPriority();
        
        insert new TechnicalSubArea_Mappings__c(
            Technical_Area__c = 'unknown',
            Technical_SubArea__c = 'unknown',
            IsDeleted__c = false,
            Case_Types__c = 'SSaaS'
        );
        
        //newly added
        // Create test case
        //Test.startTest();
        Case aCase1 = new Case(
            AccountId = account.Id,
            AssetId = asset.Id,
            ContactId = contact.Id,
            Subject = 'TEST-CASE-SUBJECT1',
            Product_Damage_Symptoms__c = 'Test record',
            Technology_Area__c = '3rd Party Apps',
            Sub_Technology_Area__c = 'Exchange',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId(),
            Case_closure_time_spent__c = 1
        );
        insert aCase1;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(aCase1);
        caseClosePageController closeCase1 = new caseClosePageController(sc1);
          closeCase1.selectedVersion = '6.1.2.500';
        closeCase1.showCombinedWarning = true;
        closeCase1.myCustomSave();
        closeCase1.SelectedTaValue = aCase1.Technology_Area__c;
        closeCase1.SelectedTsaValue = aCase1.Sub_Technology_Area__c;
        closeCase1.allTsaMappingss();
        closeCase1.myCustomSave();
        //Test.stopTest();       
        
        insert new TechnicalSubArea_Mappings__c(
            Technical_Area__c = 'unknown',
            Technical_SubArea__c = 'unknown',
            IsDeleted__c = false,
            Case_Types__c = 'InfoSight Portal'
        );
        
        // Create test case
        // Third case - InfoSight Portal
        //Test.startTest();
        Case aCase2 = new Case(
            AccountId = account.Id,
            AssetId = asset.Id,
            ContactId = contact.Id,
            Subject = 'TEST-CASE-SUBJECT2',
            Product_Damage_Symptoms__c = 'Test record',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId(),
            Technology_Area__c = 'unknown',
            Sub_Technology_Area__c = 'unknown'
        );
        insert aCase2;
        

        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(aCase2);
        caseClosePageController closeCase2 = new caseClosePageController(sc2);
        closeCase2.selectedVersion = '6.1.2.500';
        closeCase2.showCombinedWarning = true;
        closeCase2.myCustomSave();
        closeCase2.SelectedTaValue = aCase2.Technology_Area__c;
        closeCase2.SelectedTsaValue = aCase2.Sub_Technology_Area__c;
        closeCase2.allTsaMappingss();
            // Manually set required values
     
        //closeCase2.myCustomSave(); // optional
        Test.stopTest();
    }
        
       

    public static testMethod void caseClosePagetestTATSANullValues(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        System.assertNotEquals(null,account.Id);
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
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
        System.assertNotEquals(null,                      asset.Id);
        System.assertEquals('TEST-ASSET',                  asset.Name);
        System.assertEquals(account.Id,                 asset.AccountId);
        System.assertEquals(contact.Id,                 asset.ContactId);
        System.assertEquals('Premium',                     asset.SLA__c);
        System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
        test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT',
                                Product_Damage_Symptoms__c = 'Test record',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId());
                                //RecordTypeId = '01234000000BnF9');
        
        TechnicalSubArea_Mappings__c tsamapping = new TechnicalSubArea_Mappings__c();
        tsamapping.Technical_Area__c ='Array Hardware';
        tsamapping.Technical_SubArea__c = 'Damaged in shipping';
        tsamapping.IsDeleted__c = false;
        tsamapping.Keywords__c = '';
        tsamapping.Case_Types__c = 'Array Case';
        insert tsamapping;
        
        System.assertNotEquals(null,             aCase.Id);
        System.assertEquals(account.Id,       aCase.AccountId);
        System.assertEquals(asset.Id,         aCase.AssetId);
        System.assertEquals(contact.Id,       aCase.ContactId);
        System.assertEquals('TEST-CASE-SUBJECT', aCase.Subject);
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        caseClosePageController closeCase = new caseClosePageController(sc);
        //closeCase.SelectedTaValue = 'Array Hardware';
        //closeCase.SelectedTsaValue = 'Damaged in shipping';
        closeCase.getClosedStatus();
        closeCase.myCustomSave();
        closeCase.getallTaMappings();
        closeCase.allTsaMappingss();
        Test.stopTest();
        
    }
    public static testMethod void caseClosePagetest_infosightcaserecordType(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
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
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
        
        System.assertNotEquals(null,                      asset.Id);
        System.assertEquals('TEST-ASSET',                  asset.Name);
        System.assertEquals(account.Id,                 asset.AccountId);
        System.assertEquals(contact.Id,                 asset.ContactId);
        System.assertEquals('Premium',                     asset.SLA__c);
        System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
        
        Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT',
                                Product_Damage_Symptoms__c = 'Test record',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId());
        
        
        TechnicalSubArea_Mappings__c tsamapping = new TechnicalSubArea_Mappings__c();
        tsamapping.Technical_Area__c ='unknown';
        tsamapping.Technical_SubArea__c = 'unknown';
        tsamapping.IsDeleted__c = false;
        tsamapping.Case_Types__c = 'InfoSight Portal';
        insert tsamapping;
        
        System.assertNotEquals(null,             aCase.Id);
        System.assertEquals(account.Id,       aCase.AccountId);
        System.assertEquals(asset.Id,         aCase.AssetId);
        System.assertEquals(contact.Id,       aCase.ContactId);
        System.assertEquals('TEST-CASE-SUBJECT', aCase.Subject);
        //PageReference pageRef = Page.caseNewOrEditPage;
        //Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        caseClosePageController closeCase = new caseClosePageController(sc);
        //closeCase.SelectedTaValue = 'Array Hardware';
        //closeCase.SelectedTsaValue = 'Damaged in shipping';
        closeCase.getClosedStatus();
        closeCase.myCustomSave();
        closeCase.getallTaMappings();
        closeCase.allTsaMappingss();
        Test.stopTest();
        
    }
    
    public static testMethod void caseClosePagetest_caseefforttracking(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
        
        
        Test.startTest();
        // Create test case
        case aCase32;
        insert aCase32 = new Case(AccountId = account.Id,
                                  AssetId   = asset.Id,
                                  ContactId = contact.Id,
                                  Subject = 'TEST-CASE-SUBJECT',
                                  Product_Damage_Symptoms__c = 'Test record',
                                  Case_closure_time_spent__c = 200,  
                                  caseClosureEstimatedEffort__c='4 hours',
                                  Status='Closed',
                                  caseCaseSummary__c ='Test case summary',
                                  casCatClosureRootCause__c ='Case Automation Error',                                
                                  RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId());
        aCase = [select id,OwnerId,Case_Effort_Summary_Total__c,AccountId,AssetId,ContactId,Subject,Product_Damage_Symptoms__c,Asset.Autosupport_Last_Received__c,Asset.assetNimbleOsVersion__c,
                 Current_comment_activity__c,Case_closure_time_spent__c,Case_Owner_Time_Effort__c,Non_Case_Owner_Time_Effort__c,caseClosureEstimatedEffort__c,caseCaseSummary__c,RecordTypeId,casCatClosureRootCause__c,caseAssetNimbleOSVersion__c, Auto_Close__c
                 from case where id =: aCase32.Id];
        
        CaseEscalationTypeDefinition__c ted = new CaseEscalationTypeDefinition__c(
            caseEscalationTypeDefinitionGroup__c = 'Engineering Escalation');
            //caseEscalationTypeDefinitionUser__c   = '005De000001agebIAA'   
        insert ted; 
        
        insert new caseEscalation__c(
            caseEscalationCase__c = aCase.Id,
            Escalation_Closure_Status__c = 'Open',
            caseEscalationTypeDefinition__c    = ted.Id
        );
        
        insert new Management_Escalation__c(
            Case__c = aCase.Id,
            Status__c = 'Open',
            Severity__c ='Yellow',
            Account__c = account.Id,
            Region__c ='AMS',
            Customer_Temp__c ='Test',
            Executive_Visibility__c ='No'
        );
        insert new ESCA_Consult__c(
            Case__c = aCase.Id,
            Status__c = 'In Progress'
        );
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        caseClosePageController closeCase = new caseClosePageController(sc); 
        closeCase.SelectedTaValue = 'Array Hardware';
        closeCase.SelectedTsaValue = 'Damaged in shipping';
        // closeCase.getClosedStatus();
        closeCase.myCustomSave();
        //closeCase.getallTaMappings();
        //closeCase.allTsaMappingss();
        Test.stopTest();
        
    }
    
    public static testMethod void caseClosePagetest_caseefforttracking1(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
        
        
        Test.startTest();
        // Create test case
        case aCase32;
        insert aCase32 = new Case(AccountId = account.Id,
                                  AssetId   = asset.Id,
                                  ContactId = contact.Id,
                                  Subject = 'TEST-CASE-SUBJECT',
                                  Product_Damage_Symptoms__c = 'Test record',                                  
                                  caseClosureEstimatedEffort__c='1 day',
                                  caseCaseSummary__c ='Test case summary',
                                  casCatClosureRootCause__c ='Case Automation Error',                                
                                  RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId());
         Case_Effort_Tracking__c commentTracking = new Case_Effort_Tracking__c();
        commentTracking.CaseId__c = aCase32.Id;
        commentTracking.Effort_Owner__c =  UserInfo.getUserId();       
        commentTracking.Effort_Amount__c = 5;                            
        commentTracking.Effort_Origin__c = 'Case';
        commentTracking.Effort_Timestamp__c = Datetime.now();       
        commentTracking.Effort_Type__c  = 'General Case Work';           
        commentTracking.Effort_User__c = UserInfo.getUserId();
        insert commentTracking;  
        aCase = [select id,OwnerId,Case_Effort_Summary_Total__c,AccountId,AssetId,ContactId,Subject,Product_Damage_Symptoms__c,Case_Owner_Time_Effort__c,Non_Case_Owner_Time_Effort__c,Asset.assetNimbleOsVersion__c,
                 Current_comment_activity__c,Case_closure_time_spent__c,caseClosureEstimatedEffort__c,caseCaseSummary__c,RecordTypeId,casCatClosureRootCause__c,caseAssetNimbleOSVersion__c, Auto_Close__c, Asset.Autosupport_Last_Received__c
                 from case where id =: aCase32.Id];
         
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        caseClosePageController closeCase = new caseClosePageController(sc); 
        closeCase.setStrFieldSeverity('Normal');
        closeCase.setStrFieldIsStorageDefect('Yes');
        closeCase.getIsNimbleStorageDefect();
        closeCase.SelectedTaValue = 'Array Hardware';
        closeCase.SelectedTsaValue = 'Damaged in shipping';
        // closeCase.getClosedStatus();       
        closeCase.myCustomSave();
        //closeCase.getallTaMappings();
        //closeCase.allTsaMappingss();
        Test.stopTest();
        
    }
    
    public static testMethod void caseClosePagetest_caseefforttracking2(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
        
        
        Test.startTest();
        // Create test case
        case aCase32;
        insert aCase32 = new Case(AccountId = account.Id,
                                  AssetId   = asset.Id,
                                  ContactId = contact.Id,
                                  Subject = 'TEST-CASE-SUBJECT',
                                  Product_Damage_Symptoms__c = 'Test record',                                  
                                  caseClosureEstimatedEffort__c='1 day',
                                  caseCaseSummary__c ='Test case summary',
                                  casCatClosureRootCause__c ='Case Automation Error',                                
                                  RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId());
         Case_Effort_Tracking__c commentTracking = new Case_Effort_Tracking__c();
        commentTracking.CaseId__c = aCase32.Id;
        commentTracking.Effort_Owner__c =  UserInfo.getUserId();       
        commentTracking.Effort_Amount__c = 5;                            
        commentTracking.Effort_Origin__c = 'Case';
        commentTracking.Effort_Timestamp__c = Datetime.now();       
        commentTracking.Effort_Type__c  = 'General Case Work';           
        commentTracking.Effort_User__c = UserInfo.getUserId();
        insert commentTracking;  
        aCase = [select id,OwnerId,Case_Effort_Summary_Total__c,AccountId,AssetId,ContactId,Subject,Product_Damage_Symptoms__c,Case_Owner_Time_Effort__c,Non_Case_Owner_Time_Effort__c,Asset.assetNimbleOsVersion__c,
                 Current_comment_activity__c,Case_closure_time_spent__c,caseClosureEstimatedEffort__c,caseCaseSummary__c,RecordTypeId,casCatClosureRootCause__c,caseAssetNimbleOSVersion__c, Auto_Close__c, Asset.Autosupport_Last_Received__c
                 from case where id =: aCase32.Id];
         
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        caseClosePageController closeCase = new caseClosePageController(sc); 
        closeCase.estTimeEff= '15';
        closeCase.setStrFieldPriority('P3');
        closeCase.setStrFieldIsStorageDefect('No');
        closeCase.getIsNimbleStorageDefect();
        closeCase.getStrFieldIsStorageDefect();
        closeCase.SelectedTaValue = 'Array Hardware';
        closeCase.SelectedTsaValue = 'Damaged in shipping';
        // closeCase.getClosedStatus();       
        closeCase.myCustomSave();
        //closeCase.getallTaMappings();
        //closeCase.allTsaMappingss();
        Test.stopTest();
        
    }
    
        public static testMethod void caseClosePagetest_ChangeSeverityMethod() {
        Account account;
        Contact contact;
        Asset   asset;
        Case cs;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        //  Insert a Case to use in the controller
        cs = new Case(
            AccountId = account.Id,
            AssetId   = asset.Id,
            ContactId = contact.Id,
            Subject = 'Severity Change Test',
            Status = 'New',
            Priority = 'Medium',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId()
        );
        insert cs;
        
        // Create controller instance
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(cs);
        caseClosePageController controller = new caseClosePageController(stdCtrl);
        
        // ---- Test 1: 'Critical' ----
        controller.strFieldSeverity = 'Critical';
        controller.changeSeverity();
        System.assertEquals('Critical', controller.cas.Severity__c, 'Severity should be set to Critical');
        
        // ---- Test 2: 'Critical - Degraded' ----
        controller.strFieldSeverity = 'Critical - Degraded';
        controller.changeSeverity();
        System.assertEquals('Critical - Degraded', controller.cas.Severity__c, 'Severity should be set to Critical - Degraded');
        
        // ---- Test 3: 'Normal' ----
        controller.strFieldSeverity = 'Normal';
        controller.changeSeverity();
        System.assertEquals('Normal', controller.cas.Severity__c, 'Severity should be set to Normal');
        
        // ---- Test 4: 'Low Priority' ----
        controller.strFieldSeverity = 'Low Priority';
        controller.changeSeverity();
        System.assertEquals('Low Priority', controller.cas.Severity__c, 'Severity should be set to Low Priority');
        
        // ---- Test 1: 'P1' ----
        controller.strFieldPriority = 'P1';
        controller.changePriority();
        System.assertEquals('P1', controller.cas.Priority, 'Priority should be set to P1');
        
        // ---- Test 2: 'P2' ----
        controller.strFieldPriority = 'P2';
        controller.changePriority();
        System.assertEquals('P2', controller.cas.Priority, 'Priority should be set to P2');
        
        // ---- Test 3: 'P3' ----
        controller.strFieldPriority = 'P3';
        controller.changePriority();
        System.assertEquals('P3', controller.cas.Priority, 'Priority should be set to P3');
        
        // ---- Test 4: 'P4' ----
        controller.strFieldPriority = 'P4';
        controller.changePriority();
        System.assertEquals('P4', controller.cas.Priority, 'Priority should be set to P4');
    }
    
    
    
    public static testMethod void test_compareVersions_and_redirectToDetailPage() {
         Account account;
        Contact contact;
        Asset   asset;
        Case cs;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        Case cs1;
        //  Insert a Case to use in the controller
        cs = new Case(
            AccountId = account.Id,
            AssetId   = asset.Id,
            ContactId = contact.Id,
            Subject = 'Severity Change Test',
            Status = 'New',
            Priority = 'Medium',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId()
        );
        insert cs;
        // ==== Test compareVersions ====
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        caseClosePageController controller = new caseClosePageController(std);
       Test.stopTest();
        // Case 1: Equal versions
        System.assertEquals(0, controller.compareVersions('1.2.3', '1.2.3'), 'Should return 0 for equal versions');
        
        // Case 2: caseVersion < assetVersion
        System.assertEquals(-1, controller.compareVersions('1.2.3', '1.3.0'), 'Should return -1 when caseVersion is less');
        
        // Case 3: caseVersion > assetVersion
        System.assertEquals(1, controller.compareVersions('2.0', '1.9.9'), 'Should return 1 when caseVersion is greater');
        
        // Case 4: Null or blank values
        System.assertEquals(0, controller.compareVersions(null, '1.0'), 'Should return 0 when caseVersion is null');
        System.assertEquals(0, controller.compareVersions('1.0', null), 'Should return 0 when assetVersion is null');
        System.assertEquals(0, controller.compareVersions('', ''), 'Should return 0 when both versions are blank');
        
        // Case 5: Versions with hyphen suffixes
        System.assertEquals(0, controller.compareVersions('1.2.3-beta', '1.2.3-rc'), 'Should ignore suffix and return 0');
        System.assertEquals(1, controller.compareVersions('2.0.0-alpha', '1.9.9'), 'Should compare base versions only');
 
    }
    
    
    public static testMethod void testMyCustomSave_VersionUpdateLogic() {
        
        // Setup data
        Account acc = new Account(Name = 'Test Acc');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Email = 'test@test.com');
        insert con;
        
        Product2 prod = new Product2(Name = 'Test Product', ProductCode = 'TP001');
        insert prod;
        
        Asset ast = new Asset(
            Name = 'Test Asset',
            AccountId = acc.Id,
            ContactId = con.Id,
            Product2Id = prod.Id,
            assetNimbleOsVersion__c = '6.0.0', // Make asset version lower
            Autosupport_Last_Received__c = Date.today().addDays(-10), // Prevent version comparison warning block
            assetRmaShi__c = 'Test RMA',
            Dynamic_SKU__c = 'SKU1'
        );
        insert ast;
        
        Case cs = new Case(
            AccountId = acc.Id,
            ContactId = con.Id,
            AssetId = ast.Id,
            Subject = 'Test Case',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId()
        );
        insert cs;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cs);
        caseClosePageController ctrl = new caseClosePageController(stdController);
        
        // Setup inputs to ensure the updateAssetVersions block is executed
        ctrl.selectedVersion = '6.1.0'; // Higher than asset version to trigger update
        ctrl.showCombinedWarning = true;
        ctrl.userConfirmedOverride = true;
        
        // These two are required to prevent early return
        ctrl.SelectedTaValue = 'Array Hardware';
        ctrl.SelectedTsaValue = 'Damaged in shipping';
        
        // Invoke the method
        PageReference result = ctrl.myCustomSave();
        Test.stopTest();
        
        // Assertions
        System.assertEquals(null, result, 'Expected null PageReference when save completes.');
    }
    
}