/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 05-12-2025
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   08-30-2023   Nagalaxmi Telkar   Initial Version
**/
@isTest 
public class OpenCase_Test {

    public static testMethod void test01(){
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimmble');
        insert psp;
        
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test2@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;

        User u1 = new User(Alias = 'testMe', Email='standardusertest@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName1);
        insert u1;

        Account account = new Account(Name = 'Test Account', Primary_CS_PSM__c = u1.Id,ACM_Start_Date__c = Date.today(),Primary_PSM__c = u.Id, ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
        insert account;

        Contact c1 = new Contact();
        c1.AccountId = account.ID;
        c1.FirstName = 'test1';
        c1.LastName = 'test1';
        c1.email = 'test1@gmail.com';
        insert c1;


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
                                             Support_Profile__c = psp.Id,
                                             Support_Profile_Name__c = 'Legacy Nimble',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='Adaptive Flash Array Gen5'
                                   );
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
                               Status                       = 'Shipped',
                               assetConcierge_Service__c = true,
                               CS_PSM__c=true,
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
    
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.Alternate_Contact_Name__c = c1.Id;
        cas.ContactId = c.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        cas.X3_Strike__c = True;
        test.starttest();
        insert cas;
        
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;
        
         EmailMessage incomingMail1 = new EmailMessage();
        incomingMail1.fromaddress= 'test@gmail.com';
        incomingMail1.toAddress = 'test@gmail.com';
        incomingMail1.subject = ' Test Message';
        incomingMail1.TextBody= 'This is the message body ';
        incomingMail1.parentid=Cas.id;
        incomingMail1.incoming=true;
        
        insert incomingMail1 ;   
        
       new EmailMessageHandler().cloneCase(cas, incomingMail1);
        test.stoptest();
    }

    public static testMethod void test01A(){
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimmble');
        insert psp;
        
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test2@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;

        Account account = new Account(Name = 'Test Account', Primary_CS_PSM__c = u.Id,ACM_Start_Date__c = Date.today(),Primary_PSM__c = u.Id, ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
        insert account;

        Contact c1 = new Contact();
        c1.AccountId = account.ID;
        c1.FirstName = 'test1';
        c1.LastName = 'test1';
        c1.email = 'test1@gmail.com';
        insert c1;

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
                                             Support_Profile__c = psp.Id,
                                             Support_Profile_Name__c = 'Legacy Nimble',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='Adaptive Flash Array Gen5'
                                   );
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
                               Status                       = 'Shipped',
                               assetConcierge_Service__c = true,
                               CS_PSM__c=true,
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
    
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.Alternate_Contact_Name__c = c1.Id;
        cas.ContactId = c.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        cas.X3_Strike__c = True;
        test.starttest();
        insert cas;
        
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;
        
         EmailMessage incomingMail1 = new EmailMessage();
        incomingMail1.fromaddress= 'test@gmail.com';
        incomingMail1.toAddress = 'test@gmail.com';
        incomingMail1.subject = ' Test Message';
        incomingMail1.TextBody= 'This is the message body ';
        incomingMail1.parentid=Cas.id;
        incomingMail1.incoming=true;
        
        insert incomingMail1 ;   
        
       new EmailMessageHandler().cloneCase(cas, incomingMail1);
        test.stoptest();
    }

    
    public static testMethod void test02(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Sub_Status__c = 'Customer Approved';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
         cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;       
    }
    
    public static testMethod void test03(){
        Account sp = new Account(Name = 'H3C');
        insert sp;
        
        Account acc = new Account(
            Name = 'Test Account',
            Support_Provider__c = sp.Id // set Id, not name
        );
        User u = [SELECT Id FROM User WHERE Alias = 'NSForce' LIMIT 1];
        System.runAs(u) {
            // Setup test queue
            Group testGroup = new Group(Name = 'Support Queue - General', Type = 'Queue');
            insert testGroup;
            
            QueueSObject testQueue = new QueueSObject(QueueId = testGroup.Id, SObjectType = 'Case');
            insert testQueue;
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='SSaaS' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.RecordTypeId = recordTypearraycase.id;
        cas.AccountId = acc.Id;
        cas.OwnerId = testGroup.Id;  
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=True;
        insert incomingMail ;       
    }
    }
    
    public static testMethod void test04(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='InfoSight Portal' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.RecordTypeId = recordTypearraycase.id;
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=false;
        insert incomingMail ;       
    }
    public static testMethod void test04A(){

        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimmble');
        insert psp;

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
                                             Support_Profile__c = psp.Id,
                                             Support_Profile_Name__c = 'Legacy Nimble',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='Adaptive Flash Array Gen5'
                                   );
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
                               Status                       = 'Shipped',
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='InfoSight Portal' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.ContactId = c.Id;
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.RecordTypeId = recordTypearraycase.id;
        cas.ClosedDate = system.Today()-35;
        cas.CreatedDate = system.today()-40;
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        Test.startTest();
        insert incomingMail ;    
        Test.stopTest();   
    }
     
    
    public static testMethod void test05(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        RecordType recordTypearrayAccount = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
        Account supportProvider = new Account(Name = 'Toshiba IT-Services Corporation', RecordTypeId = recordTypearrayAccount.Id);
        insert supportProvider;
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI', Support_Provider__c = supportProvider.Id);
        insert account;
      
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.AccountId = account.Id;
        cas.Auto_Close__c = true;
        cas.RecordTypeId = recordTypearraycase.id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;       
    }
    
    public static testMethod void test06(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        RecordType recordTypearrayAccount = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
        Account supportProvider = new Account(Name = 'H3C Corporation', RecordTypeId = recordTypearrayAccount.Id);
        insert supportProvider;
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI', Support_Provider__c = supportProvider.Id);
        insert account;
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.AccountId = account.Id;
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.RecordTypeId = recordTypearraycase.id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.Estimated_Effort__c = '1 day';
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;       
    }

   
    public static testMethod void test08(){
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
    
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='New';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.Estimated_Effort__c = '30 min';
        cas.RecordTypeId = recordTypearraycase.id;
        cas.Current_comment_time_spent__c = 10;
        cas.Current_comment_activity__c=null;
        
        test.startTest();
        
        insert cas;
        
        CaseComment tComment = new CaseComment();
        tComment.ParentId = cas.Id;
        tComment.CommentBody = 'Test class comment';          
        insert tComment;  
        test.stopTest();  
    }

    public static testMethod void test09(){
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimmble');
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
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;
    
        RecordType recordTypeOPScase = [select id,Name from RecordType where SobjectType='case' and Name='OPS Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.ContactId = c.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.RecordTypeId = recordTypeOPScase.id;
        cas.Estimated_Effort__c = '1 hour';
        Test.starttest();
        insert cas;
        
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.ccAddress = 'test1@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= String.valueOf('X').repeat(4000);
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;
        
         EmailMessage incomingMail1 = new EmailMessage();
        incomingMail1.fromaddress= 'test@gmail.com';
        incomingMail1.toAddress = 'test@gmail.com';
        incomingMail1.subject = ' Test Message';
        incomingMail1.ccAddress = 'test1@gmail.com';
        incomingMail1.TextBody= 'This is the message body ';
        incomingMail1.TextBody= String.valueOf('X').repeat(4000);
        incomingMail1.parentid=Cas.id;
        incomingMail1.incoming=true;
        insert incomingMail1 ;   
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)'];
       
        
       new EmailMessageHandler().cloneCase(cas, incomingMail1);
       Test.stoptest();
    }


/*public static testMethod void test10(){
        
    Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimmble');
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
    c.birthdate = Date.newInstance(1992, 04, 12);
    insert c;

    //Insert contact for Account
    Contact c1 = new Contact();
    c1.AccountId = account.ID;
    c1.FirstName = 'test';
    c1.LastName = 'test';
    c1.email = 'test@gmail.com';
    c1.birthdate = Date.newInstance(1992, 04, 12);
    insert c1;


    RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
    Case cas= new Case();
    cas.Subject= 'testsubject';
    cas.Status ='Closed';
    cas.Origin = 'phone';
    cas.Auto_Close__c = true;
    cas.AssetId = asst.Id;
    cas.AccountId = account.Id;
    cas.ContactId = c.Id;
    cas.RecordTypeId = recordTypearraycase.id;
    cas.Technology_Area__c = '3rd Party Apps';
    cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
    //cas.AssetId = asst.Id;
    Test.startTest();
    insert cas;

    
    Case caseSupport = [Select Owner.Id,Owner.Name,Owner.Type,Case_Effort_Summary_Total__c,caseClosureEstimatedEffort__c, 
    Current_comment_time_spent__c, Current_comment_activity__c,Account.Support_Provider__c, Owner.Email, 
    AssetId,CreatedDate,ClosedDate,Case_Owner_Time_Effort__c,Non_Case_Owner_Time_Effort__c,Support_Profile__c,
    Subject,Estimated_Effort__c,Contact.Email,Status,LastModifiedDate, Auto_Close__c,OwnerId,caseAccountSupportProvider__c,
    RecordType.Name,DateTime_First_Available_To_Work__c, Asset.Asset_Type__c,RecordTypeId, ContactId, Id from case where id = :cas.id];
    System.debug('case support profile : '+caseSupport.Support_Profile__c);
    test.stoptest();

    EmailMessage incomingMail = new EmailMessage();
    incomingMail.fromaddress= 'test@gmail.com';
    incomingMail.toAddress = 'test@gmail.com';
    incomingMail.subject = ' Test Message';
    incomingMail.TextBody= 'This is the message body ';
    incomingMail.parentid=Cas.id;
    incomingMail.incoming=true;
    insert incomingMail ;
    
     EmailMessage incomingMail1 = new EmailMessage();
        incomingMail1.fromaddress= 'test@gmail.com';
        incomingMail1.toAddress = 'test@gmail.com';
        incomingMail1.subject = ' Test Message';
        incomingMail1.TextBody= 'This is the message body ';
        incomingMail1.parentid=Cas.id;
        incomingMail1.incoming=true;
        insert incomingMail1 ;   
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)'];
        
        
    new EmailMessageHandler().cloneCase(caseSupport, incomingMail1);
    }*/


    public static testMethod void test11(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='SDOE' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.RecordTypeId = recordTypearraycase.id;
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=false;
        insert incomingMail ;       
    }

    public static testMethod void test12(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='SSaaS' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;       
    }

    public static testMethod void test13(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;       
    }
    ////NCV Case is not in use, deactivated in SFDC-1594, hence removing the below code.
    /*public static testMethod void test14(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='NCV Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress = 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = 'Test Message';
        incomingMail.TextBody = 'This is the message body ';
        incomingMail.parentid = Cas.id;
        incomingMail.incoming = false;
        insert incomingMail ;       
    }
*/
    /*static testMethod void testCSPSMAlert(){
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;

        Account acc = new Account(Name = 'Test Account', CS_PSM__c = true,Primary_CS_PSM__c = u.Id);
        insert acc;

        Contact contact1 = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = acc.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact1;
        //Account acc = new Account(Name = 'Test Account',);
        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             Product_Type__c    ='Hardware',
                                             Product_Type_2__c  ='File Storage',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='File Storage');
        insert testProduct1;
        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = acc.Id, 
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
        String assetType = [Select Asset_Type__c From Asset Where Id =: asst.Id].Asset_Type__c;
        System.assertEquals(assetType,'File Storage');

        Id recordTypeForCase = [select Id, Name from RecordType where Name = 'Array Case' LIMIT 1].Id;
        Test.startTest();
        Case c1 = new Case(Status = 'New', 
                           Origin = 'Web', 
                           Priority='P1', 
                           ContactId = contact1.Id,
                           AssetId = asst.Id,
                           AccountId = acc.Id,
                           Subject = 'Testing',
                           Case_Type__c = 'External',
                           caseDontSendCaseOpenEmail__c = false,
                           RecordTypeId = recordTypeForCase
                           ); 
        insert c1;
        Test.stopTest();
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress = 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = 'Test Message';
        incomingMail.TextBody = 'This is the message body ';
        incomingMail.parentid = c1.id;
        incomingMail.incoming = false;
        insert incomingMail ; 
    }*/

/*@IsTest
    public static testMethod void test02(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.RecordTypeId = recordTypearraycase.id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;       
    }*/

    public static testMethod void test07A(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        RecordType recordTypearrayAccount = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
        Account supportProvider = new Account(Name = 'HPE', RecordTypeId = recordTypearrayAccount.Id);
        insert supportProvider;
        Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI', Support_Provider__c = supportProvider.Id);
        insert account;
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.AccountId = account.Id;
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.RecordTypeId = recordTypearraycase.id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.Estimated_Effort__c = '1 day';
        insert cas;
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;       
    }
    
    Public static testMethod void test16(){
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimmble');
        insert psp;
        
         Account account = new Account(Name = 'Test Account',ACM_Start_Date__c = Date.today(), ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
        insert account;

        Contact c1 = new Contact();
        c1.AccountId = account.ID;
        c1.FirstName = 'test1';
        c1.LastName = 'test1';
        c1.email = 'test1@gmail.com';
        insert c1;


        //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;

        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
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
                               Status                       = 'Shipped',
                               assetConcierge_Service__c = true,
                               CS_PSM__c=true,
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        
        
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Waiting on Internal';
        cas.Sub_Status__c='Waiting on Account team';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.ContactId = c.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        cas.X3_Strike__c = True;
        test.starttest();
        insert cas;
        
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ; 
        
        Case updatedCase = [SELECT Id, Status, Sub_Status__c, X3_Strike__c FROM Case WHERE Id = :cas.Id];
        System.assertEquals('Update Needed', updatedCase.Status);
        System.assertEquals('Customer Replied', updatedCase.Sub_Status__c);
        System.assertEquals(true, updatedCase.X3_Strike__c);
        
        
    }
    
    Public static testMethod void test16A(){
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimmble');
        insert psp;
        
         Account account = new Account(Name = 'Test Account',ACM_Start_Date__c = Date.today(), ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
        insert account;

        Contact c1 = new Contact();
        c1.AccountId = account.ID;
        c1.FirstName = 'test1';
        c1.LastName = 'test1';
        c1.email = 'test1@gmail.com';
        insert c1;


        //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;

        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
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
                               Status                       = 'Shipped',
                               assetConcierge_Service__c = true,
                               CS_PSM__c=true,
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        
        
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Waiting on Customer';
        cas.Sub_Status__c='Complete Action Plan';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.ContactId = c.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        cas.X3_Strike__c = True;
        test.starttest();
        insert cas;
        
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;
        
        /*Case updatedCase = [SELECT Id, Status, Sub_Status__c, X3_Strike__c FROM Case WHERE Id = :cas.Id];
        System.assertEquals('Update Needed', updatedCase.Status);
        System.assertEquals('Customer Replied', updatedCase.Sub_Status__c);
        System.assertEquals(false, updatedCase.X3_Strike__c);*/
        
        
    }
     Public static testMethod void test16B(){
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimmble');
        insert psp;
        
         Account account = new Account(Name = 'Test Account',ACM_Start_Date__c = Date.today(), ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
        insert account;

        Contact c1 = new Contact();
        c1.AccountId = account.ID;
        c1.FirstName = 'test1';
        c1.LastName = 'test1';
        c1.email = 'test1@gmail.com';
        insert c1;


        //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;

        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
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
                               Status                       = 'Shipped',
                               assetConcierge_Service__c = true,
                               CS_PSM__c=true,
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        
        
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='New';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.ContactId = c.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        test.starttest();
        insert cas;
        
         cas.Status ='Update Needed';
         cas.Sub_Status__c='First Strike';
         cas.X3_Strike__c = True;
         Update cas;
         
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;
        
        /*Case updatedCase = [SELECT Id, Status, Sub_Status__c, X3_Strike__c FROM Case WHERE Id = :cas.Id];
        System.assertEquals('Update Needed', updatedCase.Status);
        System.assertEquals('Customer Replied', updatedCase.Sub_Status__c);
        System.assertEquals(false, updatedCase.X3_Strike__c);*/
        
        
    }
    
    Public static testMethod void test16C(){
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimmble');
        insert psp;
        
        Account account = new Account(Name = 'Test Account',ACM_Start_Date__c = Date.today(), ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
        insert account;
        
        Contact c1 = new Contact();
        c1.AccountId = account.ID;
        c1.FirstName = 'test1';
        c1.LastName = 'test1';
        c1.email = 'test1@gmail.com';
        insert c1;
        
        
        //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;
        
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
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
                               Status                       = 'Shipped',
                               assetConcierge_Service__c = true,
                               CS_PSM__c=true,
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        
        
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='New';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.ContactId = c.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        test.starttest();
        insert cas;
        
        cas.Status ='Update Needed';
        cas.Sub_Status__c='Account Team Due';
        cas.X3_Strike__c = True;
        update cas;
        
        
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=Cas.id;
        incomingMail.incoming=true;
        insert incomingMail ;
        
        /*Case updatedCase = [SELECT Id, Status, Sub_Status__c, X3_Strike__c FROM Case WHERE Id = :cas.Id];
        System.assertEquals('Update Needed', updatedCase.Status);
        System.assertEquals('Customer Replied', updatedCase.Sub_Status__c);
        System.assertEquals(true, updatedCase.X3_Strike__c);  */      
        
    }
    
    //  Test method to check the First_Customer_Contact__c update
    public static testMethod void test17(){
        
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());        
        String uniqueUserName = 'test17@test1234567890.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='New';
        cas.Origin = 'phone';
        cas.caseAttnReq__c = False;
        cas.First_Customer_Contact__c = null;
        cas.RecordTypeId = recordTypearraycase.id;
        insert cas;
        
        Test.startTest();
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'standarduser@testorg.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=cas.id;
        incomingMail.incoming=false;
        insert incomingMail;
        Test.stopTest();
        
        Case updCas = [select First_Customer_Contact__c from Case limit 1];
        system.assertNotEquals(updCas.First_Customer_Contact__c, Null);
    }
    
    
    public static testMethod void test_FirstOutgoingEmailFlagUpdate() {
        // Create Account
        RecordType recordTypearrayAccount = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
        Account supportProvider = new Account(Name = 'Toshiba IT-Services Corporation', RecordTypeId = recordTypearrayAccount.Id);
        insert supportProvider;
        Account acc = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI', Support_Provider__c = supportProvider.Id);
        insert acc;
        
        // Create Contact
        Contact con = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john@example.com', AccountId = acc.Id);
        insert con;
        
        // Create Case
        Case testCase = new Case(
            Subject = '[ ref: Test Case',
            Status = 'New', // not Closed
            Origin = 'Phone',
            AccountId = acc.Id,
            ContactId = con.Id,
            First_Outgoing_Email__c = false
        );
        insert testCase;
        
        // Create EmailMessage that is outgoing
        EmailMessage em = new EmailMessage(
            ParentId = testCase.Id,
            Incoming = false, // outgoing
            Subject = 'Test Email [ ref:_ABC123 ]',
            FromAddress = 'agent@example.com',
            ToAddress = 'customer@example.com'
        );
        insert em;
                
     
    }
    
    
    
    
    public static testMethod void testAlternateContactLogic() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact primaryCon = new Contact(
            FirstName = 'Primary',
            LastName = 'Contact',
            Email = 'primary@example.com',
            AccountId = acc.Id
        );
        insert primaryCon;
        
        Contact altCon = new Contact(
            FirstName = 'Alternate',
            LastName = 'Contact',
            Email = 'alternate@example.com',
            AccountId = acc.Id
        );
        insert altCon;
        
        Id roleId;
        List<CaseTeamRole> roleList = [SELECT Id FROM CaseTeamRole WHERE Name = 'Alternate Contact Name' LIMIT 1];
        if (roleList.isEmpty()) {
            CaseTeamRole newRole = new CaseTeamRole(
                Name = 'Alternate Contact Name',
                AccessLevel = 'Read/Write'
            );
            insert newRole;
            roleId = newRole.Id;
        } else {
            roleId = roleList[0].Id;
        }
        
        // Step 1: Insert case without ClosedDate
        Case c = new Case(
            Subject = 'Test Case',
            Status = 'Closed',
            Origin = 'Phone',
            AccountId = acc.Id,
            ContactId = primaryCon.Id,
            Alternate_Contact_Name__c = altCon.Id,
            ClosedDate = system.Today()-35,
        CreatedDate = system.today()-40
        );
        insert c;
   
        EmailMessage incomingMail = new EmailMessage();
        incomingMail.fromaddress= 'test@gmail.com';
        incomingMail.toAddress = 'test@gmail.com';
        incomingMail.subject = ' Test Message';
        incomingMail.TextBody= 'This is the message body ';
        incomingMail.parentid=c.id;
        incomingMail.incoming=true;
        Test.startTest();
        insert incomingMail ;    
        Test.stopTest();   
        

    }

    public static testMethod void test18(){
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        User u = [SELECT Id FROM User WHERE Alias = 'NSForce' LIMIT 1];
        System.runAs(u) {
            // Setup test queue
            Group testGroup = new Group(Name = 'Support Queue - Automatic', Type = 'Queue');
            insert testGroup;
            
            QueueSObject testQueue = new QueueSObject(QueueId = testGroup.Id, SObjectType = 'Case');
            insert testQueue;
            
            // Account with blank Support_Provider__c
            Account acc = new Account(Name = 'Test Account', Support_Provider__c = null);
            insert acc;
            Case cas= new Case();
            cas.Subject= 'testsubject';
            cas.Status ='Closed';
            cas.Origin = 'phone';
            cas.Auto_Close__c = true;
            cas.RecordTypeId = recordTypearraycase.id;
            cas.OwnerId = testGroup.Id;
            cas.AccountId = acc.Id;
            insert cas;
            
            EmailMessage incomingMail = new EmailMessage();
            incomingMail.fromaddress= 'test@gmail.com';
            incomingMail.toAddress = 'test@gmail.com';
            incomingMail.subject = ' Test Message';
            incomingMail.TextBody= 'This is the message body ';
            incomingMail.parentid=Cas.id;
            incomingMail.incoming=true;
            insert incomingMail ;       
        } 
    }
    

   
}