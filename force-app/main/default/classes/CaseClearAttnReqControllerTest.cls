@isTest
public class CaseClearAttnReqControllerTest {
    static testMethod void caseInsert(){
        test.startTest();
        
        Profile pf= [Select Id from profile where Name='System Administrator II (pw never expires)']; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'test@gmail.com', 
                         Username = 'johntest@acmetest.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'spart', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id); 
        insert uu;
        
        Case c1 = new Case(Subject = 'TEST-CASE-SUBJECT',
                           Status = 'New', Origin = 'Phone', 
                           Priority='P1',caseAttnReq__c = True,
                          ownerId = uu.Id);
        insert c1;
        
        ApexPages.CurrentPage().getParameters().put('id',c1.id);
        ApexPages.StandardController sc = new ApexPages.standardController(c1);
        CaseClearAttnReqController cs=new CaseClearAttnReqController(sc);
     	cs.caseCommentBody = 'Test';
        cs.caseCommentIsPublished = True;
        cs.caseCommentIsNotified = False;
        cs.saveCaseComment();
        cs.caseClearAttnReq();
        cs.sendEmail();
        Test.stopTest();
    }
    
    static testMethod void caseInsert01(){
        test.startTest();
        
        Profile pf= [Select Id from profile where Name='System Administrator II (pw never expires)']; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'test@gmail.com', 
                         Username = 'johntest@acmetest.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'spart', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        insert uu;
        
        
        Case c1 = new Case(Subject = 'TEST-CASE-SUBJECT',
                           Status = 'New', Origin = 'Phone', 
                           Priority='P1',caseAttnReq__c = False,
                          ownerId = uu.Id);
        insert c1;
        ApexPages.CurrentPage().getParameters().put('id',c1.id);
        ApexPages.StandardController sc = new ApexPages.standardController(c1);
        CaseClearAttnReqController cs=new CaseClearAttnReqController(sc);
     	cs.caseCommentBody = 'Test';
        cs.caseCommentIsPublished = True;
        cs.caseCommentIsNotified = False;
        cs.saveCaseComment();
        cs.caseClearAttnReq();
        cs.sendEmail();
        Test.stopTest();
    }

    static testMethod void caseInsertRecord(){
        test.startTest();
        
        Profile pf= [Select Id from profile where Name='System Administrator II (pw never expires)'];
        
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        
        User opp = new User
            (id=u.Id, email  = 'test@gmail.com');
        Update opp;
        
        Case c1 = new Case(Subject = 'TEST-CASE-SUBJECT',
                           Status = 'New', Origin = 'Phone', 
                           Priority='P1',caseAttnReq__c = True,
                          ownerId = opp.Id);
        insert c1;
        
        ApexPages.CurrentPage().getParameters().put('id',c1.id);
        ApexPages.StandardController sc = new ApexPages.standardController(c1);
        CaseClearAttnReqController cs=new CaseClearAttnReqController(sc);
     	cs.caseCommentBody = '';
        cs.caseCommentIsPublished = True;
        cs.caseCommentIsNotified = False;
        cs.saveCaseComment();
        cs.caseClearAttnReq();
        cs.sendEmail();
        Test.stopTest();
    }
}