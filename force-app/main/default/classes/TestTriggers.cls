//Added ActivateTrigger__c in the testmethods.By vishnu on 9th july 2020 and on 25th Aug 2020.
@isTest
private class TestTriggers {
    
    static testMethod void Test1() {
        //check the custom setting value set for the EmailCaseCommentsToOwner,EmailCaseComments to run.
        ActivateTrigger__c        activateTriggerCustomSetting;
        insert activateTriggerCustomSetting = new ActivateTrigger__c(EmailCaseCommentsToOwnerTrigger__c = True,EmailCaseCommentsTrigger__c = True);
        
        insert new Case( Auto_Open__c = true);
        insert new EmailMessage(ParentId = [select Id from Case].Id);
    }
    
    static testMethod void Test2() {
        CaseCommentMailerToOwnerUtils.DoNothing();
        CaseCommentMailerUtils.DoNothing();
    }
    
    
    static testMethod void testSendMail() {
        //check the custom setting value set for the EmailCaseCommentsToOwner,EmailCaseComments to run.
        ActivateTrigger__c        activateTriggerCustomSetting;
        insert activateTriggerCustomSetting = new ActivateTrigger__c(EmailCaseCommentsToOwnerTrigger__c = True,EmailCaseCommentsTrigger__c = True);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        //User u = new User(IsActive = true, Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='supportforce@nimblestorage.com', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='supportforce@nimblestorage.com.Exafort3');
        //insert u;
        
        
            
            string user = UserInfo.getUserId();
            List<User> uuu = [ SELECT Id, IsActive, Alias,Username from User where Id = :user limit 1];
            
            system.debug(LoggingLevel.ERROR, 'XXXXX ' + uuu + ' XXX');
            Test.startTest();
            insert new Contact(Email = 'dddddddd@nimblestorage.com', LastName = 'DDDDDD');
            insert new Case(ContactId = [select Id from Contact limit 1].Id, OwnerId = UserInfo.getUserId(), Status = 'Open', Supportforce_Comment_Flag__c = true, Auto_Open__c = true, Auto_Close__c = false);     
            insert new CaseComment(ParentId = [select Id from Case where Supportforce_Comment_Flag__c = true limit 1].Id, CommentBody = 'testing123456', IsPublished = false);
            //insert new CaseComment(ParentId = [select Id from Case where Supportforce_Comment_Flag__c = true limit 1].Id, CommentBody = 'testing123456789', IsPublished = false);
            Test.stopTest();
        
        List<CaseComment> cc = [ SELECT Id, ParentId, CommentBody, IsPublished from CaseComment limit 1 ];  
        
        
        if(cc.isEmpty()) {
            system.debug(LoggingLevel.ERROR, 'LIST CC IS EMPTY');
        } else {
            CaseCommentMailerUtils.sendError('testing Error Handling in CaseComment Trigger');
            system.debug(LoggingLevel.ERROR, 'LIST CC CONTAINS ' + cc.size() + ' MEMBERS');
            for(integer i=0;i<cc.size();i++) {
                CaseComment item = cc[i];
                system.debug(LoggingLevel.ERROR, 'Id: ' + item.get('Id'));
            }
        }
        
        CaseCommentMailerUtils.sendMail(cc, System.Label.Case_Alert_New_Case_to_Arcus_Customers, true);
        
        CaseCommentMailerToOwnerUtils.sendMail(cc, 'User Name', true);
        CaseCommentMailerToOwnerUtils.sendError('test error'); 
        
    }
    
    static testMethod void testSendMail2() {
        //check the custom setting value set for the EmailCaseCommentsToOwner,EmailCaseComments to run.
        ActivateTrigger__c        activateTriggerCustomSetting;
        insert activateTriggerCustomSetting = new ActivateTrigger__c(EmailCaseCommentsToOwnerTrigger__c = True,EmailCaseCommentsTrigger__c = True);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
       // User u = new User(IsActive = true, Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='xxx@testorg.com');
       // insert u;
        
     //   System.runAs(u) {
            Test.startTest();
            string user = UserInfo.getUserId();
            insert new Contact(Email = 'supportforce@nimblestorage.com', LastName = 'Support');
            //insert new Case(ContactId = [select Id from Contact limit 1].Id, OwnerId = UserInfo.getUserId(), Supportforce_Comment_Flag__c = true, Auto_Open__c = true, Auto_Close__c = false,Status = 'Awaiting Customer',Sub_Status__c = 'Customer Actions Complete');
        insert new Case(ContactId = [select Id from Contact limit 1].Id, OwnerId = UserInfo.getUserId(), Supportforce_Comment_Flag__c = true, Auto_Open__c = true, Auto_Close__c = false,Status = 'Awaiting Customer');
        insert new CaseComment(ParentId = [select Id from Case where Supportforce_Comment_Flag__c = true limit 1].Id, CommentBody = 'testing123456', IsPublished = false);
            Test.stopTest();
    //    }       
        List<CaseComment> cc = [ SELECT Id, ParentId, CommentBody, IsPublished from CaseComment limit 1 ];  
        if(cc.isEmpty()) {
            system.debug(LoggingLevel.ERROR, 'LIST CC IS EMPTY');
        } else {
            CaseCommentMailerUtils.sendError('testing Error Handling in CaseComment Trigger');
            system.debug(LoggingLevel.ERROR, 'LIST CC CONTAINS ' + cc.size() + ' MEMBERS');
            for(integer i=0;i<cc.size();i++) {
                CaseComment item = cc[i];
                system.debug(LoggingLevel.ERROR, 'Id: ' + item.get('Id'));
            }
        }
        //CaseCommentMailerUtils.sendMail(cc, '00X80000001RZpEEAW');  //sandbox
        CaseCommentMailerToOwnerUtils.sendMail(cc, 'User Name', true); 
        
        CaseCommentMailerUtils.sendMail(cc, '00X80000001v7FDEAY', true); //production  
    }
    //Added by vishnu to cover the "EmailcaseCommentsToOwner" trigger on 14thJuly2020.
    static testMethod void testSendMail_1() {
        //check the custom setting value set for the EmailCaseCommentsToOwner,EmailCaseComments to run.
        ActivateTrigger__c        activateTriggerCustomSetting;
        insert activateTriggerCustomSetting = new ActivateTrigger__c(EmailCaseCommentsToOwnerTrigger__c = True,EmailCaseCommentsTrigger__c = True);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      //  User u = new User(IsActive = true, Alias = 'standt', Email='supportforce@nimblestorage.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='xxx@testorg.com');
      //  insert u;
        
       // System.runAs(u) {
            Test.startTest();
            string user = UserInfo.getUserId();
            insert new Contact(Email = 'standarduser@testorg.com', LastName = 'Support');
            //insert new Case(ContactId = [select Id from Contact limit 1].Id, OwnerId = UserInfo.getUserId(), Supportforce_Comment_Flag__c = true, Auto_Open__c = true, Auto_Close__c = false,Status = 'Awaiting Customer',Sub_Status__c = 'Customer Actions Complete');
        insert new Case(ContactId = [select Id from Contact limit 1].Id, OwnerId = UserInfo.getUserId(), Supportforce_Comment_Flag__c = true, Auto_Open__c = true, Auto_Close__c = false,Status = 'Awaiting Customer');
        insert new CaseComment(ParentId = [select Id from Case where Supportforce_Comment_Flag__c = true limit 1].Id, CommentBody = 'testing123456', IsPublished = false);
            Test.stopTest();
      //  }       
        List<CaseComment> cc = [ SELECT Id, ParentId, CommentBody, IsPublished from CaseComment limit 1 ];  
        if(cc.isEmpty()) {
            system.debug(LoggingLevel.ERROR, 'LIST CC IS EMPTY');
        } else {
            CaseCommentMailerUtils.sendError('testing Error Handling in CaseComment Trigger');
            system.debug(LoggingLevel.ERROR, 'LIST CC CONTAINS ' + cc.size() + ' MEMBERS');
            for(integer i=0;i<cc.size();i++) {
                CaseComment item = cc[i];
                system.debug(LoggingLevel.ERROR, 'Id: ' + item.get('Id'));
            }
        }
        //CaseCommentMailerUtils.sendMail(cc, '00X80000001RZpEEAW');  //sandbox
        CaseCommentMailerToOwnerUtils.sendMail(cc, 'User Name', true); 
        
        CaseCommentMailerUtils.sendMail(cc, '00X80000001v7FDEAY', true); //production  
    }
    static testMethod void OpenCaseTriggerCoverage() {
        insert new Case( Status = 'Closed', Technology_Area__c = 'dummy', Sub_Technology_Area__c = 'dummySub', Auto_Open__c = true);
        insert new EmailMessage(Subject = 'Undeliverable',ParentId = [select Id from Case].Id);
    }
    static testMethod void OpenCaseTriggerCoverage1() {
        insert new Case( Status = 'Closed', Technology_Area__c = 'dummy', Sub_Technology_Area__c = 'dummySub', Auto_Open__c = true,OwnerId = '00G34000003rkEy',Auto_Close__c =true);
        insert new EmailMessage(ParentId = [select Id from Case].Id);
    }
    static testMethod void OpenCaseTriggerCoverage2() {
        Account account;
        Case aCase;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',Support_Provider__c = null);
        insert aCase = new Case( Status = 'Closed', Technology_Area__c = 'dummy', Sub_Technology_Area__c = 'dummySub', Auto_Open__c = true,AccountId = account.Id,OwnerId = '00G34000003rkEy',Auto_Close__c =true,Subject = 'TEST-CASE-SUBJECT');
        insert new EmailMessage(ParentId = [select Id from Case].Id);
    }
    /*static testMethod void OpenCaseTriggerCoverage3() {
        Account account;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',Support_Provider__c = null);
        Case aCase;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',Support_Provider__c = account.id);
        insert aCase = new Case( Status = 'Closed', Technology_Area__c = 'dummy', Sub_Technology_Area__c = 'dummySub', Auto_Open__c = true,AccountId = account.Id,OwnerId = '00G34000003rkEy',Auto_Close__c =true,Subject = 'TEST-CASE-SUBJECT');
        insert new EmailMessage(ParentId = [select Id from Case].Id);
    }*/
    
    
    static testMethod void testCoverage(){
        
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimble');
        insert psp;
    
        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                                ProductCode        ='S0S38A',
                                                Product_Type__c    ='Hardware',
                                                Support_Profile__c = psp.Id,
                                                Support_Profile_Name__c = 'Legacy Nimble',
                                                Controller_Code__c ='CS200',
                                                Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                Family             ='Adaptive Flash Array Gen5'
                                    );
        insert testProduct1;
        
        Account account = new Account();
        account.Name = 'test corp';
        account.phone= '01123123';
        account.billingcity='London';
        account.billingpostalcode='SW1635HJ';
        account.billingcountry='United Kingdom';
        account.billingstreet='address 1';
        insert account;
        Asset asst = new Asset(Name                         = 'AA-111112', 
                                Product2Id                   = testProduct1.id,
                                AccountId                        = account.Id,
                                HPE_Serial_Number__c         = 'AFTestM10',
                                Array_Controller__c          = 'CS300',
                                Array_Networking__c          = '2P',
                                Array_Networking_2__c        = '2P',
                                Array_Networking_3__c        = '2P',
                                Array_Cache__c               = '640F',
                                SSD_Bank_A__c                = '480F',
                                SSD_Bank_B__c                = '480F',
                                Status                       = 'Shipped',
                                Component_SKU_HPE__c         = 'R4U28A',
                                Component_SKU_Nimble_V2__c   = '6010',
                                Expansion_Shelf_Base__c      = 'AFS2',
                                Array_Capacity__c            = '11T');
        insert asst;
    
        //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        insert c;
    
        Case cas = new Case();
        cas.Subject= 'testsubject';
        cas.Status ='New';
        cas.Origin = 'Web';
        cas.Priority = 'P1';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.ContactId = c.Id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.AssetId = asst.Id;
        Test.startTest();
        insert cas;
        
        CaseComment cc = new CaseComment();
        cc.ParentId = cas.Id;
        cc.CommentBody = 'testing123456';
        cc.IsPublished = false;
        insert cc;

        List<CaseComment> casecomm = [ SELECT Id, ParentId, CommentBody, IsPublished FROM CaseComment WHERE ParentId =: cas.Id limit 1 ];
        CaseCommentMailerUtils.sendMail(casecomm, '00X80000001v7FDEAY', true);
        Test.stopTest();
    }
}