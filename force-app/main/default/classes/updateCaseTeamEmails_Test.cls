@IsTest
public class updateCaseTeamEmails_Test {
    
    @TestSetup
    static void makeData(){
        Profile fetchProfile = [Select Id, Name from Profile where Name = 'System Administrator' LIMIT 1];
        
        //Create test Users
        User user1 = new User(
            FirstName = 'Test',
            LastName = 'User 1',
            Email = 'testuser1@nimblestorage.com',
            Username = 'testuser1@nimblestorage.com',
            ProfileId = fetchProfile.Id,
            Alias = 'TU1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert user1;
        
        User user2 = new User(
        	FirstName = 'Test',
            LastName = 'User 2',
            Email = 'testuser2@nimblestorage.com',
            Username = 'testuser2@nimblestorage.com',
            ProfileId = fetchProfile.Id,
            Alias = 'TU2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert user2;
        
        // Create test Account
        Account acc = new Account(
            Name='Test Name',
            Phone = '1234',
            FAX = '123',
            Billingstreet = 'test'
        );
        insert acc;      
        //Create test Contact
        Contact con = new Contact(
            FirstName='Test Name',
            LastName = 'test',
            AccountId = acc.Id,
            MobilePhone = '1234',
            email='fake@test.com'
        );
        insert con;
        //Create test Case
        Case aCase = new Case(
        	AccountId = acc.Id,
            ContactId = con.Id,
            Subject = 'Test Subject',
            Additional_CC_PSM__c = null
        );
        insert aCase;
    }
    
    @IsTest
    static void test_updateCaseTeamEmails() {

        // Get the data
        String theCaseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<User> theUsersList = [SELECT Id, Email FROM User LIMIT 2];

        //Inner class attributes
        updateCaseTeamEmails.FlowInputs flowInputrequest = new updateCaseTeamEmails.FlowInputs();
        flowInputrequest.caseIdFromFlow = theCaseId;
        flowInputrequest.userListFromFlow = theUsersList;
        
        Test.startTest();
        updateCaseTeamEmails.updateCaseTeamsEmailIds( new List<updateCaseTeamEmails.FlowInputs>{ flowInputrequest } );
        Test.stopTest();
    }
    
    @IsTest
    static void test_updateCaseTeamEmails_1() {

        // Get the data
        String theCaseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<User> theUsersList = [SELECT Id, Email FROM User LIMIT 1];

        //Inner class attributes
        updateCaseTeamEmails.FlowInputs flowInputrequest = new updateCaseTeamEmails.FlowInputs();
        flowInputrequest.caseIdFromFlow = theCaseId;
        flowInputrequest.userListFromFlow = theUsersList;
        
        Test.startTest();
        updateCaseTeamEmails.updateCaseTeamsEmailIds( new List<updateCaseTeamEmails.FlowInputs>{ flowInputrequest } );
        Test.stopTest();
    }
}