/**
 * @description       : Test class for CaseUtility.cls
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 10-07-2025
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   07-26-2022   Nagalaxmi Telkar   Initial Version
**/
@isTest
public class CaseUtility_Test{

    /*@testSetup 
        static void setUp() {
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
        
        //Account supportProvider = new Account(Name = 'Test SP', Type = 'Support Provider');
        //insert supportProvider;
         //create accounts
         Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
         insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        
        TechnicalSubArea_Mappings__c tsm = new TechnicalSubArea_Mappings__c(CaseType__c = 'Array Case',Technical_SubArea__c='TestArea', Technical_Area__c='TestArea', Peak_Area__c = 'Test Area' );
        insert tsm;
        
        CustomerImpactMapping__c cim = new CustomerImpactMapping__c(Customer_Impact__c= 'Test Impact' ,
                                                                    Esc_Rotation__c='Test rotation',
                                                                    PEAK_Area__c = 'Test Area');
                                                                    
        insert cim;
        
        
    }*/
    
    public static testMethod void testCreateOutStandingRecomendationOnCaseInsert(){
         
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
        
        //Account supportProvider = new Account(Name = 'Test SP', Type = 'Support Provider');
        //insert supportProvider;
         //create accounts
         Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
         insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        
        TechnicalSubArea_Mappings__c tsm = new TechnicalSubArea_Mappings__c(Case_Types__c = 'Array Case',Technical_SubArea__c='TestArea', Technical_Area__c='TestArea', Peak_Area__c = 'Test Area' );
        insert tsm;
        
        CustomerImpactMapping__c cim = new CustomerImpactMapping__c(Customer_Impact__c= 'Test Impact' ,
                                                                    Esc_Rotation__c='Test rotation',
                                                                    PEAK_Area__c = 'Test Area');
                                                                    
        insert cim;
         //Asset asst1 = [SELECT Id FROM Asset LIMIT 1];
         //Account acc1 = [SELECT Id FROM Account LIMIT 1]; 
         //Account acc2 = [SELECT Id FROM Account WHERE Support_Provider__c =: acc1.Id];
         Case c1 = new Case(casePachinkoCaseType__c = 'Type1', AccountId = acc1.Id, AssetId = asst1.Id, Status = 'Open');        
         Case c2 = new Case(casePachinkoCaseType__c = 'Type2', AccountId = acc1.Id, AssetId = asst1.Id, Status = 'Open');
         Test.startTest();
         insert c1;
         
         Outstanding_Recommendation__c ord = new Outstanding_Recommendation__c(Case_Velocity_Type__c = 'Type1',
                                                                                 Asset__c = asst1.Id, 
                                                                                 Status__c = 'Requested',
                                                                                 Case__c = c1.Id);
                                                                                 
         insert ord;
        Outstanding_Recommendation__c ord2 = new Outstanding_Recommendation__c(Case_Velocity_Type__c = 'Type1',
                                                                                Asset__c = asst1.Id,
                                                                                 Account__c = acc1.Id, 
                                                                                 Status__c = 'Requested',
                                                                                 Case__c = c1.Id);
                                                                                 
         insert ord2;
         insert c2;
         
         Case cstatus = [SELECT Status FROM Case WHERE Id =: c1.Id];
        cstatus.Status = 'Closed';
        cstatus.Technology_Area__c = '3rd Party Apps';
        cstatus.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        update cstatus ;
         Test.stopTest();
    }
    
    public static testMethod void testPopulateEscalationAndPeakArea(){
    
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
        
        //Account supportProvider = new Account(Name = 'Test SP', Type = 'Support Provider');
        //insert supportProvider;
         //create accounts
         Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
         insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        
        TechnicalSubArea_Mappings__c tsm = new TechnicalSubArea_Mappings__c(Case_Types__c = 'Array Case',Technical_SubArea__c='TestArea', Technical_Area__c='TestArea', Peak_Area__c = 'Test Area' );
        insert tsm;
        
        CustomerImpactMapping__c cim = new CustomerImpactMapping__c(Customer_Impact__c= 'Test Impact' ,
                                                                    Esc_Rotation__c='Test rotation',
                                                                    PEAK_Area__c = 'Test Area');
                                                                    
        insert cim;
        
        //Asset asst1 = [SELECT Id FROM Asset LIMIT 1];
        //Account acc1 = [SELECT Id FROM Account LIMIT 1];
        //CustomerImpactMapping__c cim = [SELECT Id FROM CustomerImpactMapping__c LIMIT 1];
  
        Case casePeak = new Case(casePachinkoCaseType__c = 'Type1',Sub_Technology_Area__c='TestArea', Technology_Area__c='TestArea', AccountId = acc1.Id, AssetId = asst1.Id, caseCatImpactToCustomer__c = cim.Id);
        
        Test.startTest();
            insert casePeak ;
            
        Case changeSTA = [SELECT Sub_Technology_Area__c FROM Case WHERE Id =: casePeak.Id];
        changeSTA.Sub_Technology_Area__c  = 'Changed';
        update changeSTA;
        
        Boolean runas = CaseUtility.runningInASandbox;
          
        Test.stopTest();
    }
    
    static testMethod void TestForCreateCaseEffortTrackingRecordMins(){
        
        Account account = new Account();
        account.Name = 'test corp';
        account.phone= '01123123';
        account.billingcity='London';
        account.billingpostalcode='SW1635HJ';
        account.billingcountry='United Kingdom';
        account.billingstreet='address 1';
        insert account;
        
        //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;
    
        RecordType recordTypeArraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.RecordTypeId = recordTypeArraycase.id;
        cas.Estimated_Effort__c = '15 minutes';
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        insert cas;

        cas.Current_comment_time_spent__c = 15;
        cas.Current_comment_activity__c = 'General Case Work';
        update cas;

        test.startTest(); 
          CaseComment   tComment = new CaseComment();
          tComment.ParentId = cas.Id;
          tComment.CommentBody = 'Test class comment';   
          tComment.IsPublished = True;
          
          insert tComment;
        test.stopTest(); 
    }
    
    static testMethod void TestForCreateCaseEffortTrackingRecordHr(){
        
        Account account = new Account();
        account.Name = 'test corp';
        account.phone= '01123123';
        account.billingcity='London';
        account.billingpostalcode='SW1635HJ';
        account.billingcountry='United Kingdom';
        account.billingstreet='address 1';
        insert account;
        
        //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;
    
        RecordType recordTypeArraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.RecordTypeId = recordTypeArraycase.id;
        cas.Estimated_Effort__c = '1 hour';
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        insert cas;

        cas.Current_comment_time_spent__c = 15;
        cas.Current_comment_activity__c = 'General Case Work';
        update cas;

        test.startTest(); 
          CaseComment   tComment = new CaseComment();
          tComment.ParentId = cas.Id;
          tComment.CommentBody = 'Test class comment';   
          tComment.IsPublished = True;
          
          insert tComment;
        test.stopTest(); 
    }

    static testMethod void TestForCreateCaseEffortTrackingRecordDay(){
        
        Account account = new Account();
        account.Name = 'test corp';
        account.phone= '01123123';
        account.billingcity='London';
        account.billingpostalcode='SW1635HJ';
        account.billingcountry='United Kingdom';
        account.billingstreet='address 1';
        insert account;
        
        //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;
    
        RecordType recordTypeArraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.RecordTypeId = recordTypeArraycase.id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.Estimated_Effort__c = '1 Day';
        insert cas;

        cas.Current_comment_time_spent__c = 15;
        cas.Current_comment_activity__c = 'General Case Work';
        update cas;

        test.startTest(); 
          CaseComment   tComment = new CaseComment();
          tComment.ParentId = cas.Id;
          tComment.CommentBody = 'Test class comment';   
          tComment.IsPublished = True;
          
          insert tComment;
        test.stopTest(); 
    }


    static testMethod void TestForCreateCaseEffortTrackingRecord1Dgt(){
        
        Account account = new Account();
        account.Name = 'test corp';
        account.phone= '01123123';
        account.billingcity='London';
        account.billingpostalcode='SW1635HJ';
        account.billingcountry='United Kingdom';
        account.billingstreet='address 1';
        insert account;
        
        //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;
    
        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             Product_Type__c    ='Hardware',
                                             Product_Type_2__c  ='File Storage',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='File Storage');
        insert testProduct1;

        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = account.Id, 
                               Product2Id                   = testProduct1.id,
                               HPE_Serial_Number__c         = 'AFTestM10',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Asset_Type_Build__c          = 'File Storage',
                               Status                       = 'Shipped',
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        RecordType recordTypeArraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.AssetId = asst.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.RecordTypeId = recordTypeArraycase.id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.Estimated_Effort__c = '8';
        test.startTest();
        insert cas;
        
        
        cas.Current_comment_time_spent__c = 15;
        cas.Current_comment_activity__c = 'General Case Work';
        CaseUtility.addToMapOfOrgWideEmailAddress('salesforce-dev-test@hpe.com');
        update cas;

         
          CaseComment   tComment = new CaseComment();
          tComment.ParentId = cas.Id;
          tComment.CommentBody = 'Test class comment';   
          tComment.IsPublished = True;
          
          insert tComment;
        test.stopTest(); 
    }
    @isTest
    static void populateEscalationAndPeakArea() {
       
        
        // Create Engineering Escalation Mapping
        Engineering_Escalation_Mapping__c engMap = new Engineering_Escalation_Mapping__c(
            IsActive__c = true,
            Rot_Code__c = 'ROT123'
        );
        insert engMap;
        
        // Create TechnicalSubArea Mapping
        TechnicalSubArea_Mappings__c tsaMapping = new TechnicalSubArea_Mappings__c(
            Technical_Area__c = 'Storage',
            Technical_SubArea__c = 'Nimble',
            Case_Types__c = 'Array Case',
            Peak_Area__c = 'Peak Area 1',
            Escalation_Rotation__c = 'ESCROT1',
            Default_Peak__c = 'Default Peak',
            Default_Escalation_Rotation__c = 'Default ESC',
            Support_Profile__c = 'Legacy Nimble'
        );
        insert tsaMapping;
        
        // Create TA_TSA_Engineering_Escalation__c child
        TA_TSA_Engineering_Escalation__c esc = new TA_TSA_Engineering_Escalation__c(
            TechnicalSubArea_Mapping__c = tsaMapping.Id,
            Support_Profile__c = 'Legacy Nimble',
            Engineering_Escalation_Mapping__c = engMap.Id
        );
        insert esc;
        
        // Create a Case record
        Case testCase = new Case(
            Technology_Area__c = 'Storage',
            Sub_Technology_Area__c = 'Nimble'
        );
        insert testCase;
        
        // Add your method call here (the method that contains SFDC-1387 logic)
        List<Case> caseList = [SELECT Id, Technology_Area__c, Sub_Technology_Area__c, RecordTypeId, Support_Profile__c,
                               Escalation_Rotation__c, Peak_Area__c FROM Case WHERE Id = :testCase.Id];
        
        // Simulate invoking the logic
        // Replace this with actual method if encapsulated, else paste logic inline here
        //MyCaseHelperClass.applyTSAMapping(caseList); // <-- Use actual class/method name
        
        // Validate updates
        System.assertEquals('ROT123', caseList[0].Escalation_Rotation__c, 'Escalation Rotation mismatch');
        System.assertEquals('Peak Area 1', caseList[0].Peak_Area__c, 'Peak Area mismatch');
    }
    
     @IsTest//(SeeAllData=true)
    static  void managementEscalationUpdate(){
        Account account = new Account(Name = 'TEST-ACCOUNT');
        insert account;
        Management_Escalation__c managerEscalationInsert = new Management_Escalation__c();
        managerEscalationInsert.Severity__c = 'Red';
        managerEscalationInsert.Region__c = 'AMS';
        managerEscalationInsert.Customer_Temp__c = 'Test';  
        managerEscalationInsert.Executive_Visibility__c = 'Yes';
        managerEscalationInsert.Account__c = account.id;
        insert managerEscalationInsert;
        Case c1 = new Case(Status = 'New', Origin = 'Phone' ,AccountId = account.Id);
        insert c1;
        case c2 = new case();
        c2.id = c1.Id;
        c2.Status = 'Closed';
        Update c2;
    }
    
    public static void applyTimerDurationTest_UsingUtility() {
        // Insert Case_Sub_Status_Mapping__c for timer logic
        insert new Case_Sub_Status_Mapping__c(
            Status__c = 'New',
            Default_Timer_in_Minutes__c = 120
        );
        
        // Insert test Account
        Account acc = new Account(Name = 'Test Account', accountRmaShi__c = 'Account RMA SHI');
        insert acc;
        
        // Insert test Contact
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id, Email = 'test@test.com');
        insert con;
        
        // Insert test Asset
        Asset asset = new Asset(Name = 'Test Asset', AccountId = acc.Id, ContactId = con.Id, SLA__c = 'Premium');
        insert asset;
        
        // Get Record Type Id
        Id ssaaSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        
        // Insert test Case
        Case testCase = new Case(
            Status = 'New',
            Subject = 'Test Case',
            Description = 'Test',
            RecordTypeId = ssaaSRecordTypeId,
            Origin = 'Phone',
            AccountId = acc.Id,
            AssetId = asset.Id
        );
        insert testCase;
        
        Test.startTest();
        // Call your utility method directly
        CaseUtility.applyTimerDuration(
            testCase, 
            testCase.Status, 
            testCase.Sub_Status__c, 
            testCase.X3_Strike__c
        );
        update testCase;
        Test.stopTest();
        
        // Validate timer fields
        Case updatedCase = [
            SELECT Timer_Expiry_Date__c, Timer_Expiry_Date_Change_for_Scheduled__c 
            FROM Case 
            WHERE Id = :testCase.Id
        ];
        
        System.assertNotEquals(null, updatedCase.Timer_Expiry_Date__c, 'Timer Expiry Date should be set by utility method');
        System.assertNotEquals(null, updatedCase.Timer_Expiry_Date_Change_for_Scheduled__c, 'Scheduled Timer should be set by utility method');
    }
    
    static testMethod void isOrgwideEmailAddressTest_UsingUtility() {
        System.assertEquals(true, CaseUtility.isOrgwideEmailAddress(
            'supportcase@nimblestorage.com'
        ));
    }

    @isTest(SeeAllData=true)
    static void getPachinkoCodeListFromCustomSettingsTest_UsingUtility() {
        List<String> getPCodeList = CaseUtility.getPachinkoCodeListFromCustomSettings();
        System.assertNotEquals(getPCodeList.size(), 0);
    }
    
}