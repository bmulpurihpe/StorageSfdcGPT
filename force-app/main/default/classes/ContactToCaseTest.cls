/*Change log:Changed the CommunityNickName from 'tsuer' to 'NIMBLECommunityuser' due to duplicate community name issue.
**Reference: https://help.salesforce.com/articleView?id=000038162&type=1
**Changed By:Exafort(vishnu) on 22nd Oct,2018.
*/
@isTest
Public class ContactToCaseTest{
    // NOTE: Divided this test class up into separate test methods because
    //       everything in one method was overriding SOQL governor limits.
    
    static testMethod void test_01()
    { 
        ID ProfileID = [ Select id from Profile where name = 'Support: System Administrator'].id;
        User usr = new User(email='test-user@example1.com',profileid = ProfileID, 
                            UserName='test-user@email.com',alias='tuser1',CommunityNickName='NIMBLECommunityuser',TimeZoneSidKey='America/New_York', 
                            LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US', 
                            FirstName = 'Test',LastName = 'UserTest' );
        
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
        RecordType rt2 = [select id,Name from RecordType where SobjectType='Account' and Name='Channel' Limit 1];
        Account serviceAccount = new Account(Name = 'Service',Type = 'Support Provider',RecordTypeId = rt.id);
        insert serviceAccount;
        Contact serviceContact = new Contact(LastName = 'Test',Support_Provider__c = true,AccountId = serviceAccount.Id);
        insert serviceContact;
        Account account = new Account(Name = 'Test',Type = 'Customer',RecordTypeId = rt2.id,Support_Provider__c = serviceAccount.id);
        insert account;
        Contact contact = new Contact(LastName = 'Test2',AccountId = account.Id);
        insert contact;
        
        Case caseRec = new Case(Status = 'new',AccountId = account.Id);
        insert caseRec;
        test.startTest();
        ContactToCase.updateCase(caseRec.Id);
        test.stopTest();
    } 
    
    static testMethod void test_02()
    {
        ID ProfileID = [ Select id from Profile where name = 'Support: System Administrator'].id;
        User usr = new User(email='test-user@example1.com',profileid = ProfileID, 
                            UserName='test-user@email.com',alias='tuser1',CommunityNickName='NIMBLECommunityuser',TimeZoneSidKey='America/New_York', 
                            LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US', 
                            FirstName = 'Test',LastName = 'UserTest' );
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
        RecordType rt2 = [select id,Name from RecordType where SobjectType='Account' and Name='Channel' Limit 1];
        Account serviceAccount = new Account(Name = 'Service',Type = 'Support Provider',RecordTypeId = rt.id);
        insert serviceAccount;
        Contact serviceContact = new Contact(LastName = 'Test',Support_Provider__c = true,AccountId = serviceAccount.Id);
        insert serviceContact;
        Account account = new Account(Name = 'Test',Type = 'Customer',RecordTypeId = rt2.id,Support_Provider__c = serviceAccount.id);
        insert account;
        Contact contact = new Contact(LastName = 'Test2',AccountId = account.Id);
        insert contact;
        
        Case caseRecd = new Case(Status = 'new');
        insert caseRecd;
        test.startTest();
        ContactToCase.updateCase(caseRecd.Id);
        Delete caseRecd;
        ContactToCase.updateCase(caseRecd.Id);
        test.stopTest();
    } 
    
    static testMethod void test_03()
    {
        ID ProfileID = [ Select id from Profile where name = 'Support: System Administrator'].id;
        User usr = new User(email='test-user@example1.com',profileid = ProfileID, 
                            UserName='test-user@email.com',alias='tuser1',CommunityNickName='NIMBLECommunityuser',TimeZoneSidKey='America/New_York', 
                            LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US', 
                            FirstName = 'Test',LastName = 'UserTest' );
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
        RecordType rt2 = [select id,Name from RecordType where SobjectType='Account' and Name='Channel' Limit 1];
        Account serviceAccount = new Account(Name = 'Service',Type = 'Support Provider',RecordTypeId = rt.id);
        insert serviceAccount;
        Contact serviceContact = new Contact(LastName = 'Test',Support_Provider__c = true,AccountId = serviceAccount.Id);
        insert serviceContact;
        Account account = new Account(Name = 'Test',Type = 'Customer',RecordTypeId = rt2.id,Support_Provider__c = serviceAccount.id);
        insert account;
        Contact contact = new Contact(LastName = 'Test2',AccountId = account.Id);
        insert contact;
        
        Account acc = new Account(Name = 'Test', Type = 'Customer',RecordTypeId = rt2.id,Support_Provider__c = serviceAccount.id );
        insert acc;
        Case caseRcd = new Case(Status = 'new',AccountId = acc.Id);
        insert caseRcd;
        test.startTest();
        ContactToCase.updateCase(caseRcd.Id);
        test.stopTest();
        
    } 
    static testMethod void test_04()
    {
        ID ProfileID = [ Select id from Profile where name = 'Support: System Administrator'].id;
        User usr = new User(email='test-user@example1.com',profileid = ProfileID, 
                            UserName='test-user@email.com',alias='tuser1',CommunityNickName='NIMBLECommunityuser',TimeZoneSidKey='America/New_York', 
                            LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US', 
                            FirstName = 'Test',LastName = 'UserTest' );
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
        RecordType rt2 = [select id,Name from RecordType where SobjectType='Account' and Name='Channel' Limit 1];
        Account serviceAccount = new Account(Name = 'Service',Type = 'Support Provider',RecordTypeId = rt.id);
        insert serviceAccount;
        Contact serviceContact = new Contact(LastName = 'Test',Support_Provider__c = true,AccountId = serviceAccount.Id);
        insert serviceContact;
        Account account = new Account(Name = 'Test',Type = 'Customer',RecordTypeId = rt2.id,Support_Provider__c = serviceAccount.id);
        insert account;
        Contact contact = new Contact(LastName = 'Test2',AccountId = account.Id);
        insert contact;
        
        Account acc = new Account(Name = 'Test', Type = 'Customer',RecordTypeId = rt2.id,Support_Provider__c = serviceAccount.id );
        insert acc;
        Case caseRcd = new Case(Status = 'new',AccountId = acc.Id);
        insert caseRcd;
        test.startTest();
        ContactToCase.updateEscalateCase(caseRcd.Id);
        test.stopTest();
        
        
    } 
    static testMethod void test_05(){
        ID ProfileID = [ Select id from Profile where name = 'Support: System Administrator'].id;
        User usr = new User(email='test-user@example1.com',profileid = ProfileID, 
                            UserName='test-user@email.com',alias='tuser1',CommunityNickName='NIMBLECommunityuser',TimeZoneSidKey='America/New_York', 
                            LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US', 
                            FirstName = 'Test',LastName = 'UserTest' );
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
        RecordType rt2 = [select id,Name from RecordType where SobjectType='Account' and Name='Channel' Limit 1];
        Account serviceAccount = new Account(Name = 'Service',Type = 'Support Provider',RecordTypeId = rt.id);
        insert serviceAccount;
        Contact serviceContact = new Contact(LastName = 'Test',Support_Provider__c = true,AccountId = serviceAccount.Id);
        insert serviceContact;
        Account account = new Account(Name = 'Test',Type = 'Customer',RecordTypeId = rt2.id,Support_Provider__c = serviceAccount.id);
        insert account;
        Contact contact = new Contact(LastName = 'Test2',AccountId = account.Id);
        insert contact;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        Asset asst = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                              Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                              Asset_Type_Build__c ='Testasupassettype',SLA__c = 'TSC');
        
        insert asst;
        test.startTest();
        Case caseRcd = new Case(Status = 'new',AccountId = account.Id,Assetid = asst.id);
        insert caseRcd;
        
        ContactToCase.updateEscalateCase(caseRcd.Id);
        test.stopTest();
    }
}