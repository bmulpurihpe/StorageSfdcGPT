@IsTest(SeeAllData=true)
public with sharing class EmailCaseCommentsToOwnerTest {
    static testMethod void testNewCommentByDCEUser() {
        String userId = System.Label.DCEIntegration_APIUser;
        User u = [SELECT Email, Name, ContactId from User where Id = :userId];
        
        System.runAs(u) {
            Case testCase = new Case(Subject = 'Test Case', Description = 'Test Description');
            insert testCase;
            
            system.debug('***** Case Id : ' + testCase.Id);
            
            Test.startTest();
            CaseComment testComment = new CaseComment(ParentId = testCase.Id, CommentBody = 'Test Comment',IsPublished = true );
            insert testComment;
            Test.stopTest();
        }
    }
    
    //Ntelkar added this for TAF code coverage.
    static testMethod void testNewCommentByNimbleUser() {
        //String userId = System.Label.DCEIntegration_APIUser;
        User u = [SELECT Email, Name, ContactId from User where Name = 'Nimble Support' AND isActive = true LIMIT 1];
        
        System.runAs(u) {
            Case testCase = new Case(Subject = 'Test Case', Description = 'Test Description');
            insert testCase;
            
            system.debug('***** Case Id : ' + testCase.Id);
            
            Test.startTest();
            CaseComment testComment = new CaseComment(ParentId = testCase.Id, CommentBody = 'Test Comment',IsPublished = true );
            insert testComment;
            Test.stopTest();
        }
    }
    
}