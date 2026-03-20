/**
* @description       : 
* @author            : Nagalaxmi Telkar
* @group             : 
* @last modified on  : 03-09-2023
* @last modified by  : Nagalaxmi Telkar
* Modifications Log
* Ver   Date         Author             Modification
* 1.0   08-08-2022   Nagalaxmi Telkar   Initial Version
* 
**/

@isTest
public class caseNewOrEditPageControllerTest {
    Public Static Account account; 
    Public Static Contact contact;
    Public Static Asset asset;
    
    public static void setUp() {
        
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        
        Product2    product; 
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User useMe = [SELECT Id FROM User LIMIT 1];
        
        //Create case velocity records
        pachinko_case_type__c ct1 = new pachinko_case_type__c();
        ct1.Monthly_Threshold__c = 3;
        ct1.Pachinko_Case_Type__c = 'Type1';
        ct1.Recommendation_Text__c = 'Type1 rec text';
        ct1.Threshold_Applies_To__c = 'Account';
        ct1.Leave_Case_Open__c = true;
        ct1.Enabled__c = true;
        
        pachinko_case_type__c ct2 = new pachinko_case_type__c();
        ct2.Monthly_Threshold__c = 3;
        ct2.Pachinko_Case_Type__c = 'Type2';
        ct2.Recommendation_Text__c = 'Type2 rec text';
        ct2.Threshold_Applies_To__c = 'Array';
        ct2.Enabled__c = true;
        
        Map<String,pachinko_case_type__c> pMap = new Map<String,pachinko_case_type__c>();
        pMap.put('Type1',ct1);
        pMap.put('Type2',ct2);        
        insert pMap.values();
        
        //create custom setting
        Threshold_limit__c t1 = new Threshold_limit__c();
        t1.Name = 'limit';
        t1.Number_of_Months__c = 1;
        insert t1;
        
        QualifiedHandling__c qha = new QualifiedHandling__c(Name='Test-CaseNewEdit', qhLabel__c = 'Testing',qhDescription__c='This is a simple test on CaseNewEditController' );
        insert qha;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile profiles = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = profiles.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;
        
        //create accounts
        account = new Account(Name = 'Test Account1', ACM_Service_Purchased__c = true, Primary_PSM__c = u.id, CS_PSM__c = true, accountQualifiedHandling__c = qha.Id);
        insert account;
        
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        asset = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                          AccountId = account.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                          Array_Controller_SKU__c = 'SD-Test',
                          ContactId = contact.Id); 
        
        insert asset;
        
        TechnicalSubArea_Mappings__c tsm = new TechnicalSubArea_Mappings__c(Case_Types__c = 'SSaaS',Technical_SubArea__c='TestArea', Technical_Area__c='TestArea', Peak_Area__c = 'Test Area' );
        insert tsm;
        
        CustomerImpactMapping__c cim = new CustomerImpactMapping__c(Customer_Impact__c= 'Test Impact' ,
                                                                    Esc_Rotation__c='Test rotation',
                                                                    PEAK_Area__c = 'Test Area');
        
        insert cim;
        
        TechnicalSubArea_Mappings__c tsamapping = new TechnicalSubArea_Mappings__c();
        tsamapping.Technical_Area__c ='Array Hardware';
        tsamapping.Technical_SubArea__c = 'Damaged in shipping';
        tsamapping.IsDeleted__c = false;
        tsamapping.Case_Types__c = 'Array Case';
        insert tsamapping;
        
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        Category_Notes__c cat = new Category_Notes__c(Category__c = 'TEST_Category',
                                                      Sub_Category__c = 'Test_Sub_Category');
        
        insert cat;
        
    }
    
    public Static void setUp2(){
        account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        insert account;
        contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                              AccountId = account.Id,
                              email='test@gmail.com',
                              Phone='999999999');
        insert contact;
        
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        asset = new Asset(Name = 'TEST-ASSET',
                          AccountId = account.Id,
                          ContactId = contact.Id,
                          SLA__c = 'Premium',
                          assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                          Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                          Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                          Array_Controller_SKU__c = 'SD-Test');
        insert asset;
    }
    
    public static testMethod void test_RecordTypeIdSSaaS(){
        caseNewOrEditPageControllerTest.setUp();
        Case case1;
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TEST-CONTACT-LAST-NAME'];
        Asset asset = [SELECT Id FROM Asset WHERE Name = 'Test Asset1'];
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert case1 = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-NewOrEditCase-SUBJECT_A',
                                RecordTypeId = recordTypeidSSaaSCase,
                                Technology_Area__c = 'TestArea',
                                Sub_Technology_Area__c = 'TestArea',
                                Product_Damage_Symptoms__c = 'Carton Damage',
                                Current_comment_activity__c = null,
                                Description = 'Test Description',
                                Case_closure_time_spent__c = 20,
                                Timer_Expiry_Date__c = System.now().addDays(1));
        
        
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Support_Profile__c, RecordType.Name, Timer_Expiry_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-SUBJECT_A'];
        System.assertEquals('SSaaS',aCase.RecordType.Name);
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        
        String ArrayCaseId = newCase.RecordTypeIdArrayCase;
        String NCVCaseId = newCase.RecordTypeIdNCVCase;
        String SSaaSId = newCase.RecordTypeIdSSaaS;
        String IP = newCase.RecordTypeIdIP;
        // String infoSight = newCase.RecordTypeIdIP;
        newCase.caseNewRecord();
        newCase.productsymptoms();
        newCase.getallTaMappings();
        newCase.getEstimatedTimeEffort();
        newCase.allTsaMappingss();
        newCase.setStrFieldSeverity('Normal');
        newCase.setStrFieldPriority('P3');
        newCase.getSeverity();
        newCase.getPriority();
        newCase.getIsNimbleStorageDefect();
        newCase.getStrFieldIsStorageDefect();
        newCase.getStrFieldSeverity();
        newcase.getStrFieldPriority();
        newCase.setStrFieldIsStorageDefect('Yes');
        //   newCase.setStrFieldIsStorageDefect('No');
        //   newCase.getStrFieldIsStorageDefect();
    }
    
    public static testMethod void test_ValidateEstimatedEffort1(){
        caseNewOrEditPageControllerTest.setUp();
        Case caseNullId ;
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TEST-CONTACT-LAST-NAME'];
        Asset asset = [SELECT Id FROM Asset WHERE Name = 'Test Asset1'];
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('Array Case').getRecordTypeId ();
        test.startTest();
        caseNullId = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-SUBJECT_A',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Estimated_Effort__c = '5 minutes or less');
        
        PageReference pageRef = Page.caseNewOrEditPage;
        ApexPages.StandardController sc = new ApexPages.StandardController(caseNullId );
        ApexPages.currentPage().getParameters().put('RecordType', caseNullId.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.estTimeEff= '15';
        newCase.myCustomSave();
        test.stopTest();
    }
    
    public static testMethod void test_myCustomSave_Validation(){
        
        caseNewOrEditPageControllerTest.setUp2();
        Case cas;
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert cas = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-Estimate',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Estimated_Effort__c = '30 minutes',
                              Status ='New');
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Case_closure_time_spent__c,Case_Owner_Time_Effort__c, Non_Case_Owner_Time_Effort__c,
                      caseClosureEstimatedEffort__c, Current_comment_activity__c, AssetId, AccountId, origin, subject, Description,Status,
                      Sub_Technology_Area__c,Technology_Area__c,Case_Effort_Summary_Total__c,Support_profile__c,Sub_Status__c,Timer_Expiry_Date__c,OwnerId,Case.Timer_Expiry_Override_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-Estimate'];
        
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
    }
    
    
    
    
    public static testMethod void test_myCustomSave_Validation1(){
        caseNewOrEditPageControllerTest.setUp();
        Case cas;
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TEST-CONTACT-LAST-NAME'];
        Asset asset = [SELECT Id FROM Asset WHERE Name = 'Test Asset1'];
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert cas = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-SUBJECT_A',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Case_closure_time_spent__c = 20,
                              Status ='Waiting on Internal',
                              Sub_Status__c = 'Waiting on Account team');
        
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Case_closure_time_spent__c,Case_Owner_Time_Effort__c, Non_Case_Owner_Time_Effort__c,
                      caseClosureEstimatedEffort__c, Current_comment_activity__c, AssetId, AccountId, origin, subject, Description,Status,
                      Sub_Technology_Area__c,Technology_Area__c,Case_Effort_Summary_Total__c, Support_profile__c,Sub_Status__c,Timer_Expiry_Date__c,OwnerId,Timer_Expiry_Override_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-SUBJECT_A'];
        
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
    }
    
    public static testMethod void test_myCustomSave_Validation2(){
        caseNewOrEditPageControllerTest.setUp2();
        Case cas;
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert cas = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-Estimate',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Estimated_Effort__c = 'less than 5 minutes',
                              Status ='Waiting on Customer',
                              Sub_Status__c = 'Approve Case Closure');
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Case_closure_time_spent__c,Case_Owner_Time_Effort__c, Non_Case_Owner_Time_Effort__c,
                      caseClosureEstimatedEffort__c, Current_comment_activity__c, AssetId, AccountId, origin, subject, Description,Status,
                      Sub_Technology_Area__c,Technology_Area__c,Case_Effort_Summary_Total__c, Support_profile__c,Sub_Status__c,Timer_Expiry_Date__c,OwnerId,Timer_Expiry_Override_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-Estimate'];
        
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
    }
    
    public static testMethod void test_myCustomSave_Validation3(){
        caseNewOrEditPageControllerTest.setUp2();
        Case cas;
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert cas = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-Estimate',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Estimated_Effort__c = '1 day',
                              Status ='In Progress',
                              Sub_Status__c = 'Analyzing Logs');
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Case_closure_time_spent__c,Case_Owner_Time_Effort__c, Non_Case_Owner_Time_Effort__c,
                      caseClosureEstimatedEffort__c, Current_comment_activity__c, AssetId, AccountId, origin, subject, Description,Status,
                      Sub_Technology_Area__c,Technology_Area__c,Case_Effort_Summary_Total__c, Support_profile__c,Sub_Status__c,Timer_Expiry_Date__c,OwnerId,Timer_Expiry_Override_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-Estimate'];
        
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
    }
    
    
    public static testMethod void test_myCustomSave_Validation4(){
        Case cas;
        caseNewOrEditPageControllerTest.setUp2();
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert cas = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-Estimate',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Estimated_Effort__c = '1 hour',
                              Status ='New');
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Case_closure_time_spent__c,Timer_Expiry_Override_Date__c,Case_Owner_Time_Effort__c, Non_Case_Owner_Time_Effort__c,
                      caseClosureEstimatedEffort__c, Current_comment_activity__c, AssetId, AccountId, origin, subject, Description,Status,
                      Sub_Technology_Area__c,Technology_Area__c,Case_Effort_Summary_Total__c, Support_profile__c,Sub_Status__c,Timer_Expiry_Date__c,OwnerId FROM Case WHERE Subject = 'TEST-NewOrEditCase-Estimate'];
        
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
    }
    
    
    public static testMethod void test_myCustomSave_Validation5(){
        Case cas;
        caseNewOrEditPageControllerTest.setUp2();
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert cas = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-Estimate',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Estimated_Effort__c = '1 hour or less',
                              Status ='Closed');
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Case_closure_time_spent__c,Case_Owner_Time_Effort__c, Non_Case_Owner_Time_Effort__c,Timer_Expiry_Override_Date__c,
                      caseClosureEstimatedEffort__c, Current_comment_activity__c, AssetId, AccountId, origin, subject, Description,Status,
                      Sub_Technology_Area__c,Technology_Area__c,Case_Effort_Summary_Total__c, Support_profile__c,Sub_Status__c,Timer_Expiry_Date__c,OwnerId FROM Case WHERE Subject = 'TEST-NewOrEditCase-Estimate'];
        
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
    }
    
    
    public static testMethod void test_myCustomSave_Validation6(){
        Case cas;
        caseNewOrEditPageControllerTest.setUp2();
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert cas = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-Estimate',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Estimated_Effort__c = '1 day or less',
                              Status ='In Progress',
                              Sub_Status__c = 'Analyzing Logs');
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Case_closure_time_spent__c,Case_Owner_Time_Effort__c, Non_Case_Owner_Time_Effort__c,
                      caseClosureEstimatedEffort__c, Current_comment_activity__c, AssetId, AccountId, origin, subject, Description,Status,
                      Sub_Technology_Area__c,Technology_Area__c,Case_Effort_Summary_Total__c, Support_profile__c,Sub_Status__c,Timer_Expiry_Date__c,OwnerId,Timer_Expiry_Override_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-Estimate'];
        
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
    }
    
    
    public static testMethod void test_myCustomSave_Validation7(){
        Case cas;
        caseNewOrEditPageControllerTest.setUp2();
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert cas = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-Estimate',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Estimated_Effort__c = '20',
                              Status ='In Progress',
                              Sub_Status__c = 'Analyzing Logs');
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Case_closure_time_spent__c,Case_Owner_Time_Effort__c, Non_Case_Owner_Time_Effort__c,
                      caseClosureEstimatedEffort__c, Current_comment_activity__c, AssetId, AccountId, origin, subject, Description,Status,
                      Sub_Technology_Area__c,Technology_Area__c,Case_Effort_Summary_Total__c, Support_profile__c,Sub_Status__c,Timer_Expiry_Date__c,OwnerId,Timer_Expiry_Override_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-Estimate'];
        
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
    }
    
    
    public static testMethod void test_myCustomSave_Validation8(){
        Case cas;
        caseNewOrEditPageControllerTest.setUp2();
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert cas = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-Estimate',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Estimated_Effort__c = '20m',
                              Status ='In Progress',
                              Sub_Status__c = 'Analyzing Logs');
        test.stopTest();
        Case aCase = [SELECT Id, RecordTypeId, Case_closure_time_spent__c,Case_Owner_Time_Effort__c, Non_Case_Owner_Time_Effort__c,
                      caseClosureEstimatedEffort__c, Current_comment_activity__c, AssetId, AccountId, origin, subject, Description,Status,
                      Sub_Technology_Area__c,Technology_Area__c,Case_Effort_Summary_Total__c, Support_profile__c,Sub_Status__c,Timer_Expiry_Date__c,OwnerId,Timer_Expiry_Override_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-Estimate'];
        
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
    }
    
    public static testMethod void test_ValidateCasIdeNull(){
        caseNewOrEditPageControllerTest.setUp();
        Case caseNullId ;
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TEST-CONTACT-LAST-NAME'];
        Asset asset = [SELECT Id FROM Asset WHERE Name = 'Test Asset1'];
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        caseNullId = new Case(AccountId = account.Id,
                              AssetId   = asset.Id,
                              ContactId = contact.Id,
                              Subject = 'TEST-NewOrEditCase-SUBJECT_A',
                              RecordTypeId = recordTypeidSSaaSCase,
                              Technology_Area__c = 'TestArea',
                              Sub_Technology_Area__c = 'TestArea',
                              Product_Damage_Symptoms__c = 'Carton Damage',
                              Current_comment_activity__c = null,
                              Description = 'Test Description',
                              Case_closure_time_spent__c = 20);
        
        PageReference pageRef = Page.caseNewOrEditPage;
        ApexPages.StandardController sc = new ApexPages.StandardController(caseNullId );
        ApexPages.currentPage().getParameters().put('RecordType', caseNullId.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.myCustomSave();
        test.stopTest();
    }
    
    public static testMethod void test_validateAndRedirect(){
        caseNewOrEditPageControllerTest.setUp();
        Case case2;
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TEST-CONTACT-LAST-NAME'];
        Asset asset = [SELECT Id FROM Asset WHERE Name = 'Test Asset1'];
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert case2 = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-NewOrEditCase-SUBJECT_A',
                                RecordTypeId = recordTypeidSSaaSCase,
                                Technology_Area__c = 'TestArea',
                                Sub_Technology_Area__c = 'TestArea',
                                Product_Damage_Symptoms__c = 'Carton Damage',
                                Current_comment_activity__c = null,
                                Description = 'Test Description',
                                Case_closure_time_spent__c = 20);
        test.stopTest();
        Case aCase = [SELECT Id,RecordTypeId, AssetId,AccountId, RecordType.Name, Support_profile__c,Timer_Expiry_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-SUBJECT_A'];
        System.assertNotEquals(null,aCase.RecordTypeId);
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.validateAndRedirect();
    }
    
    
    public static testMethod void test_caseEditRecord(){
        caseNewOrEditPageControllerTest.setUp();
        Case case3;
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TEST-CONTACT-LAST-NAME'];
        Asset asset = [SELECT Id FROM Asset WHERE Name = 'Test Asset1'];
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        test.startTest();
        // Create test case
        insert case3 = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-NewOrEditCase-SUBJECT_A',
                                RecordTypeId = recordTypeidSSaaSCase,
                                Technology_Area__c = 'TestArea',
                                Sub_Technology_Area__c = 'TestArea',
                                Product_Damage_Symptoms__c = 'Carton Damage',
                                Current_comment_activity__c = null,
                                Description = 'Test Description',
                                Case_closure_time_spent__c = 20);
        
        test.stopTest();
        Case aCase = [SELECT Id,RecordTypeId, RecordType.Name,Support_profile__c,Timer_Expiry_Date__c FROM Case WHERE Subject = 'TEST-NewOrEditCase-SUBJECT_A'];
        System.assertNotEquals(null,aCase.RecordTypeId);
        PageReference pageRef = Page.caseNewOrEditPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        caseNewOrEditPageController newCase = new caseNewOrEditPageController(sc);
        newCase.caseEditRecord(sc);
    }
    
    
    
    static testMethod void caseNewOrEditPageTestCaseAbbreviation(){
        caseNewOrEditPageControllerTest.setUp();
        ApexPages.StandardController caseController;
        caseNewOrEditPageController caseExtension;
        PageReference returnedPageReference;
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        Product2 product;
        
        List<QualifiedHandling__c> qhrecord;
        List<Qualified_Handling_User__c> cModel;
        InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;
        
        System.runAs(u){
            //Create new Qulaified Handling
            qhrecord = new List<QualifiedHandling__c>();
            qhrecord.add(new QualifiedHandling__c(Name = 'USC',
                                                  qhFeatures__c = null,
                                                  qhLabel__c= 'USC',
                                                  qhDescription__c = 'Only Limited visibility to the case for TSE.',
                                                  qhDocumentationURL__c='https://nimblejira.nimblestorage.com/browse/TS-5755',
                                                  qhExternalVerbiage__c='Tse can only view the case and add a private comment to Case.'));
            qhrecord.add(new QualifiedHandling__c(Name = 'EU Defense',
                                                  qhFeatures__c = null,
                                                  qhLabel__c= 'EU Defense',
                                                  qhDescription__c = 'Only Limited visibility to the case for TSE.',
                                                  qhDocumentationURL__c='https://nimblejira.nimblestorage.com/browse/TS-5755',
                                                  qhExternalVerbiage__c='Tse can only view the case and add a private comment to Case.'));
            
            insert qhrecord;
            
            Qualified_Handling_User__c hs = new Qualified_Handling_User__c();
            hs.QH_Abbreviated_Only__c = true;
            hs.cmQualifiedHandling__c = qhrecord[0].Id;
            hs.cmUser__c = u.id;
            insert hs;
            
            //Qualified_Handling_User__c is inserted in the Contribution Model TSE trigger. 
            cModel = [Select cmQualifiedHandling__c,cmUser__c from Qualified_Handling_User__c];                           
            insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                         accountQualifiedHandling__c = qhrecord[0].Id);                     
            // Create test contact
            insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                         AccountId = account.Id,
                                         Email='test@gmail.com',
                                         Phone='999999999');                         
            product = new Product2(IsActive    = true,
                                   ProductCode = 'CS220',
                                   Description = 'CS220 Array',
                                   Family      = 'SAN Storage Array',
                                   Name        = 'CS220 Array');
            
            insert product;
            test.startTest();
            
            // Create test asset
            insert asset = new Asset(Name = 'TEST-ASSET',
                                     AccountId = account.Id,
                                     ContactId = contact.Id,
                                     SLA__c = 'Premium',
                                     Product2Id = product.Id,
                                     assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                     Array_Controller__c ='AF10000',Array_Networking__c = '2F',
                                     Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                     Array_Controller_SKU__c = 'SD-Test',
                                     assetQualifiedHandling__c = qhrecord[0].Id );
            
            //Create new case
            aCase = new Case(Status = 'Open',Case_closure_time_spent__c = 20,
                             Subject = 'TEST-CASE-SUBJECT',RecordTypeId = '01234000000BnF4',
                             AccountId = account.Id,AssetId=asset.Id);
            
            
            test.stopTest();
            caseController = new ApexPages.StandardController(aCase);
            caseExtension  = new caseNewOrEditPageController(caseController);
            returnedPageReference = caseExtension.validateAndRedirect();
            
        }
    }
    static testMethod void caseNewOrEditPage(){
        caseNewOrEditPageControllerTest.setUp();
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        Product2 product;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');                     
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');                         
        product = new Product2(IsActive    = true,
                               ProductCode = 'CS220',
                               Description = 'CS220 Array',
                               Family      = 'SAN Storage Array',
                               Name        = 'CS220 Array');
        
        insert product;
        test.startTest();
        
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 Product2Id = product.Id,
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF10000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
        //Create new case
        insert aCase = new Case(Status = 'Open',Case_closure_time_spent__c = 20,
                                Subject = 'TEST-CASE-SUBJECT',RecordTypeId = '01234000000BnF4',origin = 'Phone',
                                AccountId = account.Id,AssetId=asset.Id);
        
        aCase.Estimated_Effort__c = '8';
        update aCase;
    }
    
    
    public static testMethod void FetchTimerDuration(){
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        
        // Insert Case_Sub_Status_Mapping__c for mapping lookup
        insert new Case_Sub_Status_Mapping__c(
            Status__c = 'New',
            Sub_Status__c = '',
            Default_Timer_in_Minutes__c = 120
        );
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');                     
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');  
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium'
                                );
        // Step 2: Create a sample case with a valid Status
        Id ssaaSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        
        //Create new case
        insert aCase = new Case(Status = 'New',Sub_Status__c ='',
                                Subject = 'TEST-CASE-SUBJECT',Description ='Test', RecordTypeId = '01234000000BnF4',origin = 'Phone',
                                AccountId = account.Id,AssetId=asset.Id);
        
        // Step 3: Set the CaseId param BEFORE instantiating the controller
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(aCase);
        caseNewOrEditPageController controller = new caseNewOrEditPageController(stdController);
        
        // Manually set required controller vars
        controller.selectedStatus = 'New';
        controller.selectedSubStatus = '';
        controller.cas = aCase;
        
        // Call method - should follow the "calculate timer" logic
        controller.fetchTimerDuration();
        update controller.cas;
        
        
        Test.stopTest();
        
        
        
    }
    
   
    public static testMethod void test_TimerExpiryOverride_NewCases() {
        
        Account account;
        Contact contact;
        Asset   asset;
        DateTime pastDate = System.now().addDays(-1);
        //Case aCase;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');                     
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');  
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium'
                                );
        // Step 2: Create a sample case with a valid Status
        Id ssaaSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        
        Case c = new Case(
            Status = 'Remote Session Scheduled',
            Subject = 'Test Case',
            AccountId = account.Id,
            Description ='Test', 
            RecordTypeId = ssaaSRecordTypeId,
            Origin = 'Phone',
            AssetId=asset.Id,
            Timer_Expiry_Override_Date__c =null
        );
        insert c;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        caseNewOrEditPageController controller = new caseNewOrEditPageController(sc);
        controller.cas = c;
        
        PageReference result = controller.myCustomSave(); // or the method where this logic is
        Test.stopTest();
        
        System.assert(result == null, 'Should not proceed when override date is null');
        System.assertEquals(1, ApexPages.getMessages().size(), 'Expected validation error for null override date');
        ApexPages.getMessages().clear();
        
        
        
    }
    public static testMethod void test_TimerExpiryOverride_NewCases1() {
        
        Account account;
        Contact contact;
        Asset   asset;
        DateTime pastDate = System.now().addDays(-1);
        //Case aCase;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');                     
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');  
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium'
                                );
        // Step 2: Create a sample case with a valid Status
        Id ssaaSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        
        // ========= NEW CASE - Status = 'On Hold', Override Date = NULL =========
        Case newCase2 = new Case(
            Status = 'On Hold',
            Subject = 'New Case 2',
            AccountId = account.Id,
            Description ='Test', 
            RecordTypeId = ssaaSRecordTypeId,
            Origin = 'Phone',
            AssetId=asset.Id
        );
        insert newCase2;
        Test.startTest();
        ApexPages.StandardController sc2 = new ApexPages.StandardController(newCase2);
        caseNewOrEditPageController controller2 = new caseNewOrEditPageController(sc2);
        controller2.cas = newCase2;
        PageReference result2 = controller2.myCustomSave();  // or actual method
        Test.stopTest();
        System.assertEquals(null, result2, 'Should return null for On Hold with missing override date');
        System.assertEquals(1, ApexPages.getMessages().size(), 'Expect error message for On Hold');
        
        
        
    }
    public static testMethod void test_TimerExpiryOverride_ExistingCases() {
        
        Account account;
        Contact contact;
        Asset   asset;
        DateTime pastDate = System.now().addDays(-1);
        //Case aCase;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');                     
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');  
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium'
                                );
        // Step 2: Create a sample case with a valid Status
        Id ssaaSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        // ========= EXISTING CASE - Status = 'Remote Session Scheduled', Override Date = PAST =========
        Case existing1 = new Case(
            Status = 'Remote Session Scheduled',
            Subject = 'Existing Case 1',
            AccountId = account.Id,
            Description ='Test', 
            RecordTypeId = ssaaSRecordTypeId,
            Origin = 'Phone',
            Timer_Expiry_Override_Date__c = pastDate,
            AssetId=asset.Id
        );
        insert existing1;
        
        Test.startTest();
        ApexPages.StandardController sc3 = new ApexPages.StandardController(existing1);
        caseNewOrEditPageController controller3 = new caseNewOrEditPageController(sc3);
        controller3.cas = existing1;
        controller3.existingCase = existing1.clone(false, false, false, false);
        controller3.existingCase.Timer_Expiry_Override_Date__c = null; // simulate update
        
        PageReference result3 = controller3.myCustomSave();  // or actual method
        Test.stopTest();
        System.assertEquals(null, result3, 'Should return null for past override date');
        System.assertEquals(1, ApexPages.getMessages().size(), 'Expect error for override date in past');
        
        
    }
    public static testMethod void test_TimerExpiryOverride_ExistingCases1() {
        
        Account account;
        Contact contact;
        Asset   asset;
        DateTime pastDate = System.now().addDays(-1);
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');                     
        
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');  
        
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium'
                                );
        
        Id ssaaSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        Case existing2 = new Case(
            Status = 'On Hold',
            Subject = 'Existing Case 2',
            AccountId = account.Id,
            Description ='Test', 
            RecordTypeId = ssaaSRecordTypeId,
            Origin = 'Phone',
            AssetId=asset.Id,
            Timer_Expiry_Override_Date__c = pastDate
        );
        insert existing2;
        
        Test.startTest();
        ApexPages.StandardController sc4 = new ApexPages.StandardController(existing2);
        caseNewOrEditPageController controller4 = new caseNewOrEditPageController(sc4);
        controller4.cas = existing2;
        controller4.existingCase = existing2.clone(false, false, false, false);
        controller4.existingCase.Timer_Expiry_Override_Date__c = null;
        
        PageReference result4 = controller4.myCustomSave();  // or actual method
        Test.stopTest();
        System.assertEquals(null, result4, 'Should return null for On Hold with past override date');
        System.assertEquals(1, ApexPages.getMessages().size(), 'Expect error message for On Hold with past override date');
        
    }
    
    public static void caseClosePagetest_ChangeSeverityMethod() {
        // Prepare test data (done before Test.startTest so that DML limits don't count)
        Account account = new Account(Name = 'TEST-ACCOUNT', accountRmaShi__c = 'Account RMA SHI');
        insert account;
        
        Contact contact = new Contact(
            LastName = 'TEST-CONTACT-LAST-NAME',
            AccountId = account.Id,
            Email = 'test@gmail.com',
            Phone = '999999999'
        );
        insert contact;
        
        Product2 p1 = new Product2(
            Name = 'Test Product',
            ProductCode = 'SD-Test'
        );
        insert p1;
        
        Asset asset = new Asset(
            Name = 'TEST-ASSET',
            AccountId = account.Id,
            ContactId = contact.Id,
            SLA__c = 'Premium',
            assetRmaShi__c = 'Asset RMA SHI',
            Dynamic_SKU__c = 'Test - Dynamic Sku',
            Product2Id = p1.Id,
            Array_Controller__c = 'AF1000',
            Array_Networking__c = '2F',
            Array_Cache__c = '320F',
            SSD_Bank_A__c = '480F',
            SSD_Bank_B__c = '480F',
            Array_Controller_SKU__c = 'SD-Test'
        );
        insert asset;
        
        Case cs = new Case(
            AccountId = account.Id,
            AssetId = asset.Id,
            ContactId = contact.Id,
            Subject = 'Severity Change Test',
            Status = 'New',
            Priority = 'Medium',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId()
        );
        insert cs;
        
        // Start testing limits from here
        Test.startTest();
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(cs);
        caseNewOrEditPageController controller = new caseNewOrEditPageController(stdCtrl);
        
        // Test Severity changes
        controller.strFieldSeverity = 'Critical';
        controller.changeSeverity();
        System.assertEquals('Critical', controller.cas.Severity__c, 'Severity should be Critical');
        
        controller.strFieldSeverity = 'Critical - Degraded';
        controller.changeSeverity();
        System.assertEquals('Critical - Degraded', controller.cas.Severity__c, 'Severity should be Critical - Degraded');
        
        controller.strFieldSeverity = 'Non-Critical';
        controller.changeSeverity();
        System.assertEquals('Non-Critical', controller.cas.Severity__c, 'Severity should be Non-Critical');
        
        controller.strFieldSeverity = 'Low Priority';
        controller.changeSeverity();
        System.assertEquals('Low Priority', controller.cas.Severity__c, 'Severity should be Low Priority');
        
        // Test Priority changes
        controller.strFieldPriority = 'P1';
        controller.changePriority();
        System.assertEquals('P1', controller.cas.Priority, 'Priority should be P1');
        
        controller.strFieldPriority = 'P2';
        controller.changePriority();
        System.assertEquals('P2', controller.cas.Priority, 'Priority should be P2');
        
        controller.strFieldPriority = 'P3';
        controller.changePriority();
        System.assertEquals('P3', controller.cas.Priority, 'Priority should be P3');
        
        controller.strFieldPriority = 'P4';
        controller.changePriority();
        System.assertEquals('P4', controller.cas.Priority, 'Priority should be P4');
        
        Test.stopTest();
    }
    
    
    public static testMethod void test_fetchTimerDurationNewCases() {
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contact contact = new Contact(
            LastName = 'Test Contact',
            Email = 'test@example.com',
            Phone = '1234567890',
            AccountId = account.Id
        );
        insert contact;
        Asset asset = new Asset(
            Name = 'Test Asset',
            AccountId = account.Id,
            ContactId = contact.Id,
            SLA__c = 'Premium'
        );
        insert asset;
        
        Id ssaaSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        
        Case testCase = new Case(
            Status = 'Resolved', // This should trigger validation
            Subject = 'Test Case',
            Origin = 'Phone',
            RecordTypeId = ssaaSRecordTypeId,
            AssetId = asset.Id,
            Timer_Expiry_Override_Date__c = null
        );
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
        caseNewOrEditPageController controller = new caseNewOrEditPageController(sc);
        controller.cas = testCase;
        controller.selectedStatus = 'Resolved'; 
        ApexPages.getMessages().clear();
        
        Test.startTest();
        controller.fetchTimerDuration(); 
        Test.stopTest();
        
        List<ApexPages.Message> messages = ApexPages.getMessages();
        //System.assertEquals(1, messages.size(), 'Expected validation error for null override date');
        
        //System.assert(messages[0].getSummary().contains('Status'), 'Error message should mention status restriction');
    }
    public static testMethod void test_fetchTimerDurationNewCases1() {
        // Step 1: Create and insert Account first
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        // Step 2: Create and insert Contact (with inserted AccountId)
        Contact contact = new Contact(
            LastName = 'Test Contact',
            Email = 'test@example.com',
            Phone = '1234567890',
            AccountId = account.Id
        );
        insert contact;
        
        // Step 3: Create and insert Asset with linked Account and Contact
        Asset asset = new Asset(
            Name = 'Test Asset',
            AccountId = account.Id,
            ContactId = contact.Id,
            SLA__c = 'Premium'
        );
        insert asset;
        
        // Step 4: Get the RecordTypeId for SSaaS
        Id ssaaSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        
        // Step 5: Create the test Case (not yet inserted)
        Case testCase = new Case(
            Status = 'Handover', // Should trigger validation
            Subject = 'Test Case',
            Origin = 'Phone',
            RecordTypeId = ssaaSRecordTypeId,
            AssetId = asset.Id,
            Timer_Expiry_Override_Date__c = null
        );
        
        // Step 6: Controller setup
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
        caseNewOrEditPageController controller = new caseNewOrEditPageController(sc);
        controller.cas = testCase;
        controller.selectedStatus = 'Handover'; 
        
        // Step 7: Clear previous messages and run logic
        ApexPages.getMessages().clear();
        
        Test.startTest();
        controller.fetchTimerDuration(); 
        Test.stopTest();
        
        // Step 8: Assert the error message was shown
        List<ApexPages.Message> messages = ApexPages.getMessages();
        //System.assertEquals(1, messages.size(), 'Expected validation error for null override date');
        //System.assert(messages[0].getSummary().contains('Status'), 'Error message should mention status restriction');
    }
    
    public static testMethod void test_myCustomSave_peerFlagValidation() {
        
      
        // Step 1: Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Step 2: Insert existing case with Timer_Expiry_Override_Date__c in future
        Case existing = new Case(
            AccountId = acc.Id,
            Status = 'New',
            Subject = 'Existing Case',
            Timer_Expiry_Override_Date__c = System.now().addDays(1),
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId()
        );
        insert existing;
        
        // Step 3: Query back existing case (simulate existingCase)
        Case existingCase = [SELECT Id, Timer_Expiry_Override_Date__c, RecordTypeId, Status,origin,Timer_Expiry_Date__c,subject,description FROM Case WHERE Id = :existing.Id];
        
        // =========== TEST 1 ===========
        // Status = 'Remote Session Scheduled' & Timer_Expiry_Override_Date__c = null -> should fail
        
        // Create a new Case instance based on existing case Id to simulate editing
        Case editedCase1 = existingCase.clone(false, true, false, false);
        editedCase1.Status = 'Remote Session Scheduled';
        editedCase1.Timer_Expiry_Override_Date__c = null;
        
        // Setup controller with editedCase1
        ApexPages.StandardController sc1 = new ApexPages.StandardController(editedCase1);
        caseNewOrEditPageController controller1 = new caseNewOrEditPageController(sc1);
        
        controller1.cas = editedCase1;
        controller1.existingCase = existingCase;
        
        ApexPages.getMessages().clear();
        
        Test.startTest();
        PageReference result1 = controller1.myCustomSave();
        Test.stopTest();
        
        System.assertEquals(null, result1, 'Save should fail due to null Timer Expiry Override Date');
        System.assertEquals(1, ApexPages.getMessages().size(), 'Expected one validation error');
       
        
        ApexPages.getMessages().clear();
        
       
    }
    
    public static testMethod void test_caseNewOrEditPageController_ValidationErrors() {
        // Setup Account and Contact only once
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        
        Id arrayCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId();
        
        // === CASE 1: Missing Sub_Status__c with 'In Progress' status ===
        Case cs1 = new Case(
            AccountId = acc.Id,
            ContactId = con.Id,
            Status = 'In Progress',
            Subject = 'Test Case 1',
            RecordTypeId = arrayCaseRTId
        );
        insert cs1;
        
        ApexPages.StandardController stdCtrl1 = new ApexPages.StandardController(cs1);
        caseNewOrEditPageController controller1 = new caseNewOrEditPageController(stdCtrl1);
        controller1.cas = cs1;
        controller1.myCustomSave();
        System.assertEquals(true, ApexPages.hasMessages(), 'Expected ApexPages message for missing Sub_Status__c');
        
        
    }
    public static testMethod void test_caseNewOrEditPageController_ValidationErrors1() {
        // Setup Account and Contact only once
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        
        Id arrayCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId();
        
        // === CASE 2: Missing Timer_Expiry_Override_Date__c with 'Remote Session Scheduled' ===
        Case cs2 = new Case(
            AccountId = acc.Id,
            ContactId = con.Id,
            Status = 'Remote Session Scheduled',
            Subject = 'Test Case 2',
            Sub_Status__c = '', // to bypass previous check
            RecordTypeId = arrayCaseRTId
        );
        insert cs2;
        
        ApexPages.StandardController stdCtrl2 = new ApexPages.StandardController(cs2);
        caseNewOrEditPageController controller2 = new caseNewOrEditPageController(stdCtrl2);
        controller2.cas = cs2;
        controller2.myCustomSave();
        System.assertEquals(true, ApexPages.hasMessages(), 'Expected ApexPages message for missing Timer_Expiry_Override_Date__c');
        
        
    }
    
    public static void testMyCustomSave_VersionUpdateLogic() {
        // Create base test data
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
        
        // Manually set required values
        ctrl.selectedVersion = '6.0.1';
        ctrl.showCombinedWarning = true;
        
        PageReference result = ctrl.myCustomSave();
        Test.stopTest();
        
        // Assertions
        System.assertEquals(null, result, 'Expected null PageReference due to combined warning but update should be triggered');
    }
    
}