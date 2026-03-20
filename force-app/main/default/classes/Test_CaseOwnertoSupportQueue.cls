/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 06-06-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   06-06-2024   Nagalaxmi Telkar   Initial Version
**/
@isTest
public class Test_CaseOwnertoSupportQueue {
    static testMethod void testCaseOwnersupportQueue()
    {
        //string user = UserInfo.getUserId();
        User u = [SELECT name,profile.name from User where name = 'Nimble Support' AND IsActive = true Limit 1]; 
        System.debug('u =====>'+u.Name);
        System.debug('u =====>'+u.Id);
        Account          account;
        Contact          contact;
        Asset            asset;
        Case             aCase;
        Case             aCaseone;
        List<Account>          accounts;
        List<Contact>          contacts;
        List<Case>             cases;
        ID testAccountId;
        ID testContactId;
        ID testCaseId;
        
        // Create test account
        account = new Account(Name = 'TEST-ACCOUNT');
        insert account;
        accounts = [SELECT Id,
                    Name
                    FROM   Account
                    WHERE  Name = 'TEST-ACCOUNT'];
        
        System.assertEquals(1,              accounts.size());
        System.assertEquals('TEST-ACCOUNT', accounts[0].Name);
        testAccountId = accounts[0].id;
        
        // Create test contact
        contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                              AccountId = testAccountId);
        insert contact;
        contacts = [SELECT Id,
                    LastName,
                    AccountId
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        
        System.assertEquals(1,                        contacts.size());
        System.assertEquals('TEST-CONTACT-LAST-NAME', contacts[0].LastName);
        System.assertEquals(testAccountId,            contacts[0].AccountId);
        testContactId = contacts[0].id;
        
        // Create test case
        System.runAs(u){
            aCase = new Case(AccountId = testAccountId,
                             ContactId = testContactId,
                             Subject = 'TEST-CASE-SUBJECT',QueueId__c = null,Auto_Open__c = true,Auto_Close__c=false,changeOwnerIdTo__c = null);

            insert aCase;
            
            aCaseone = new Case(AccountId = testAccountId,
                             ContactId = testContactId,
                             Subject = 'TEST-CASE-SUBJECT',QueueId__c = null,Auto_Open__c = true,Auto_Close__c=false,changeOwnerIdTo__c = u.Id);
            
            Test.startTest();
                insert aCaseone;
            Test.stopTest();
           
        }
    }
}