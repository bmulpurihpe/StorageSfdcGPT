@isTest
Public class updateSupportProviderContactEmailTest
{
    static testMethod void test()
    {
        ID ProfileID = [ Select id from Profile where name = 'Support: System Administrator'].id;
        Integer sec = System.now().second();
        Integer ms  = System.now().millisecond();  
        
         User usr = new User(email='test-user@example1.com',profileid = ProfileID, 
                             UserName='test-user-'+sec+ms+'@test-system.'+UserInfo.getUserName().substringAfterLast('.'),alias='tuser1',CommunityNickName='tuser123',TimeZoneSidKey='America/New_York', 
                             LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US', 
                             FirstName = 'Test',LastName = 'UserTest' );
 
           
/* 
            User usr = new User(email='test-user@example1.com',profileid = ProfileID, 
                             UserName='test-user@email.com',alias='tuser1',CommunityNickName='tuser-sandbox',TimeZoneSidKey='America/New_York', 
                             LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US', 
                             FirstName = 'Test',LastName = 'UserTest' );
*/
           insert usr;
           /*Commented out the runAs(usr) as art of TAF troubleshooting to make the test pass which otherwise failed due to the error : 
           System.DmlException: Insert failed. First exception on row 0; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, Legacy_CaseTrigger: 
           execution of BeforeInsert caused by: System.QueryException: List has no rows for assignment to SObject Class.Legacy_Case_BI_CaseOwnertoSupportQueue.beforeInsert: 
           line 59, column 1 External entry point Class.MetadataTriggerHandler.executeActions: line 415, column 1 Class.MetadataTriggerHandler.beforeInsert: line 159, column 1 Class.TriggerBase.run: line 184, column 1 Trigger.Legacy_CaseTrigger: line 17, column 1: []                             
           Stack Trace: Class.updateSupportProviderContactEmailTest.test: line 25, column 1*/
           //System.runAs(usr) {
               RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
               Account serviceAccount = new Account(Name = 'Service',Type = 'Support Provider',RecordTypeId = rt.id);
               insert serviceAccount;
               Contact serviceContact = new Contact(LastName = 'Test',Support_Provider__c = true,AccountId = serviceAccount.Id);
               insert serviceContact;
               Account account = new Account(Name = 'Test',Type = 'Support Provider',RecordTypeId = rt.id,Support_Provider__c = serviceAccount.id);
               insert account;
               Contact contact = new Contact(LastName = 'Test2',AccountId = account.Id);
               insert contact;
               Case caseRec = new Case(Status = 'new',AccountId = account.Id);
               insert caseRec;
               can__c cn = new can__c (canCaseNumber__c = caseRec.Id);
               insert cn;
          //}
    } 
}