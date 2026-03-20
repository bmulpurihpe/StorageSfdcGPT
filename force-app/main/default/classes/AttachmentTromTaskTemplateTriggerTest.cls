@isTest
public class AttachmentTromTaskTemplateTriggerTest {
    static testmethod void insertTaskTemplateAttachment()
    {
		Profile p = [select Id from Profile limit 1];
        List<User> users = new List<User>();
        User user1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                           EmailEncodingKey='UTF-8', LastName='Test1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                           ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo@camfed.org',
                           TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
        User user2 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                           EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                           ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo1@camfed.org',
                           TrainingDivision__c='Sales',TrainingEnabled__c=true);
        users.add(user1);
        users.add(user2);
        InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
        insert users;
        
       	Account acc = new Account(Name='testAccount');
        insert acc;
		
        Set<String> userIds = new Set<String>();
        userIds.add(user1.Id);
        userIds.add(user2.Id);        
            
        List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
        TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',ForAllDivisions__c = false,
                                                            Effective_Date__c = Date.today().addDays(-1),ExistingUsersWillReceiveThisTask__c = true);
        TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Week1', Subject__c = 'Subject Test2', Description__c = 'Description Test2',ForAllDivisions__c = true,
                                                            Effective_Date__c = Date.today().addDays(-2),ExistingUsersWillReceiveThisTask__c = true);
        taskTemplates.add(taskTemplate1);
        taskTemplates.add(taskTemplate2);
        Insert taskTemplates;
        
        Set<Id> keyIds = new Set<Id>();
        keyIds.add(taskTemplate1.Id);
        keyIds.add(taskTemplate2.Id);
        
        List<Attachment> createAttachments = new List<Attachment>();
        Blob a = Blob.valueOf('aaaaaaaaaaaaaaaaaaaaaa');
        Blob b = Blob.valueOf('bbbbbbbbbbbbbbbbbbbbb');
        Blob c =Blob.valueOf('ccccccccccccccccccc');
        Attachment att1 = new Attachment(Name='att1',Body=a,ParentId=taskTemplate1.Id);
        Attachment att2 = new Attachment(Name='att2',Body=b,ParentId=taskTemplate2.Id);
        Attachment att3 = new Attachment(Name='att3',Body=c,ParentId=acc.Id);
        createAttachments.add(att1);
        createAttachments.add(att2);
        createAttachments.add(att3);
   
        Test.startTest();
        insert createAttachments;
        Test.stopTest();
        
        System.assertEquals(3, [select count() from TrainingTask__c where OwnerId in :userIds and TaskTemplate__c in :keyIds]);
        System.assertEquals(2, [select count() from Attachment where ParentId in :keyIds]);
     }
    
     static testmethod void deleteTaskTemplateAttachment()
    {
		Profile p = [select Id from Profile limit 1];
        List<User> users = new List<User>();
        User user1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                           EmailEncodingKey='UTF-8', LastName='Test1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                           ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo@camfed.org',
                           TrainingDivision__c='IT',TrainingEnabled__c=true);
        User user2 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                           EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                           ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo1@camfed.org',
                           TrainingDivision__c='Sales',TrainingEnabled__c=true);
        users.add(user1);
        users.add(user2);
        InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
        insert users;     
            
        List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
        TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT', ForAllDivisions__c = false,
                                                            Effective_Date__c = Date.today().addDays(-1),ExistingUsersWillReceiveThisTask__c = false);
        TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Week1', Subject__c = 'Subject Test2', Description__c = 'Description Test2',
                                                            ForAllDivisions__c = true,Effective_Date__c = Date.today().addDays(-2),ExistingUsersWillReceiveThisTask__c = false);
        taskTemplates.add(taskTemplate1);
        taskTemplates.add(taskTemplate2);
        Insert taskTemplates;

        List<Attachment> createAttachments = new List<Attachment>();
        Blob a1 = Blob.valueOf('aaaaaaaaaaaaaaaaaaaaaa');
        Blob b = Blob.valueOf('11111111111111111111111');
        Attachment att1 = new Attachment(Name='att1',Body=a1,ParentId=taskTemplate1.Id);
        Attachment att2 = new Attachment(Name='att2',Body=b,ParentId=taskTemplate2.Id);
        createAttachments.add(att1);
        createAttachments.add(att2);
        
        Test.startTest();
        insert createAttachments;     
      	Database.delete(att2.Id);
        Test.stopTest();
        System.assertEquals(0, [select count() from Attachment where ParentId = :taskTemplate2.Id]);
     }
    
    static testmethod void deleteTaskTemplate()
    {
		Profile p = [select Id from Profile limit 1];
        List<User> users = new List<User>();
        User user1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                           EmailEncodingKey='UTF-8', LastName='Test1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                           ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo@camfed.org',
                           TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today().addDays(40));
        User user2 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                           EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                           ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo1@camfed.org',
                           TrainingDivision__c='Sales',TrainingEnabled__c=true);
        users.add(user1);
        users.add(user2);
        InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
        insert users;
        
        List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
        TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',ForAllDivisions__c = true,
                                                            Effective_Date__c = Date.today().addDays(-1),ExistingUsersWillReceiveThisTask__c = false);
        TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Week1', Subject__c = 'Subject Test2', Description__c = 'Description Test2',ForAllDivisions__c = true,
                                                            Effective_Date__c = Date.today().addDays(-2),ExistingUsersWillReceiveThisTask__c = true);
        taskTemplates.add(taskTemplate1);
        taskTemplates.add(taskTemplate2);
        Insert taskTemplates;
        
        Set<Id> keyIds = new Set<Id>();
        keyIds.add(taskTemplate1.Id);
        keyIds.add(taskTemplate2.Id);
        
        List<Attachment> createAttachments = new List<Attachment>();
        Blob a1 = Blob.valueOf('aaaaaaaaaaaaaaaaaaaaaa');
        Blob b = Blob.valueOf('11111111111111111111111');
        Attachment att1 = new Attachment(Name='att1',Body=a1,ParentId=taskTemplate1.Id);
        Attachment att2 = new Attachment(Name='att2',Body=b,ParentId=taskTemplate2.Id);
        createAttachments.add(att1);
        createAttachments.add(att2);
        
        Test.startTest();
        insert createAttachments;     
      	Database.delete(taskTemplate2.Id);
        Test.stopTest();
        System.assertEquals(1, [select count() from Attachment where ParentId In :keyIds]);

     }
}