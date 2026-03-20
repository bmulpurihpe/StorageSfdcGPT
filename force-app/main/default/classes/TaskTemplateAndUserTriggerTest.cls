@isTest
public class TaskTemplateAndUserTriggerTest {
    static testMethod void testInsertUsersAndTastTemplates()
    {   
        User user = [select Id from User where Profile.Name = 'System administrator' and isActive = true limit 1];
        
        System.runAs(User) 
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
                                  TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today().addDays(30));
            User user3 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                                  EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                  ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo2@camfed.org',
                                  TrainingDivision__c='Sales',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
            users.add(user1);
            users.add(user2);
            users.add(user3);
            insert users;
            
            Set<Id> keyIds = new Set<Id>();
            keyIds.add(user1.Id);
            keyIds.add(user2.Id);
            keyIds.add(user3.Id);
            List<TrainingTask__c> tasks = [select Id from TrainingTask__c where OwnerId in :keyIds order by createdDate desc ];
            System.assertEquals(0, tasks.size());
            
            List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
            TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = false);
            TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Week1', Subject__c = 'Subject Test2', Description__c = 'Description Test2',Division__c = 'Sales',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = true);
            taskTemplates.add(taskTemplate1);
            taskTemplates.add(taskTemplate2);
            Insert taskTemplates;
            //tasks = [select Id from TrainingTask__c where OwnerId in :keyIds ];
            //System.assertEquals(5, tasks.size());
        }
    }
    
    static testMethod void testUpdateUserDivision()
    {
        User user = [select Id from User where Profile.Name = 'System administrator' and isActive = true limit 1];
        
        System.runAs(User) 
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
                                  TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today().addDays(30));
            User user3 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                                  EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                  ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo2@camfed.org',
                                  TrainingDivision__c='Sales',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
            users.add(user1);
            users.add(user2);
            users.add(user3);
            InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
            insert users;
            
            Set<Id> keyIds = new Set<Id>();
            keyIds.add(user1.Id);
            keyIds.add(user2.Id);
            keyIds.add(user3.Id);
            
            List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
            TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = false);
            TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Week1', Subject__c = 'Subject Test2', Description__c = 'Description Test2',Division__c = 'Sales',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = false,ForAllDivisions__c = false);
            taskTemplates.add(taskTemplate1);
            taskTemplates.add(taskTemplate2);
            Insert taskTemplates;
            
            user1.TrainingDivision__c = 'Sales';
            update user1;    
            // List<TrainingTask__c> tasks = [select Id,OwnerId from TrainingTask__c where OwnerId in :keyIds and IsClosed__c = false ];
            //System.assertEquals(2, tasks.size());
        }
    }
    
    static testMethod void testUpdateUserEnabled()
    {
        User user = [select Id from User where Profile.Name = 'System administrator' and isActive = true limit 1];
        
        System.runAs(User) 
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
                                  TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today().addDays(30));
            User user3 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                                  EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                  ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo2@camfed.org',
                                  TrainingDivision__c='Sales',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
            users.add(user1);
            users.add(user2);
            users.add(user3);
            InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
            insert users;
            
            Set<Id> keyIds = new Set<Id>();
            keyIds.add(user1.Id);
            keyIds.add(user2.Id);
            keyIds.add(user3.Id);
            
            List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
            TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = false);
            TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Week1', Subject__c = 'Subject Test2', Description__c = 'Description Test2',Division__c = 'Sales',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = false,ForAllDivisions__c = false);
            taskTemplates.add(taskTemplate1);
            taskTemplates.add(taskTemplate2);
            Insert taskTemplates;
            
            user1.TrainingEnabled__c = false;
            Test.startTest();
            update user1;
            Test.stopTest(); 
            //List<TrainingTask__c> tasks = [select Id from TrainingTask__c where OwnerId in :keyIds and IsClosed__c = false ];
            //System.assertEquals(1, tasks.size());
        }
    }
    
    static testMethod void testUpdateTaskTemplateTab()
    {
        User user = [select Id from User where Profile.Name = 'System administrator' and isActive = true limit 1];
        
        System.runAs(User) 
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
                                  TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today().addDays(30));
            User user3 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                                  EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                  ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo2@camfed.org',
                                  TrainingDivision__c='Sales',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
            users.add(user1);
            users.add(user2);
            users.add(user3);
            InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
            insert users;
            
            Set<Id> keyIds = new Set<Id>();
            keyIds.add(user1.Id);
            keyIds.add(user2.Id);
            keyIds.add(user3.Id);
            
            List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
            TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = false);
            TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Week1', Subject__c = 'Subject Test2', Description__c = 'Description Test2',Division__c = 'Sales',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = false,ForAllDivisions__c = false);
            taskTemplates.add(taskTemplate1);
            taskTemplates.add(taskTemplate2);
            Insert taskTemplates;
            
            taskTemplate2.Tab__c = 'Elevate';
            taskTemplate2.ForAllDivisions__c = true;
            update taskTemplate2;
            
            //List<TrainingTask__c> tasks = [select Id from TrainingTask__c where OwnerId in :keyIds and IsClosed__c = false ];
            //System.assertEquals(3, tasks.size());   
        }
    }
    
    static testMethod void testUpdateTaskTemplateDivisionToOtherDivision()
    {
        User user = [select Id from User where Profile.Name = 'System administrator' and isActive = true limit 1];
        
        System.runAs(User) 
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
                                  TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today().addDays(30));
            User user3 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                                  EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                  ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo2@camfed.org',
                                  TrainingDivision__c='Sales',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
            users.add(user1);
            users.add(user2);
            users.add(user3);
            InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
            insert users;
            
            Set<Id> keyIds = new Set<Id>();
            keyIds.add(user1.Id);
            keyIds.add(user2.Id);
            keyIds.add(user3.Id);
            
            List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
            TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = false);
            TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Elevate', Subject__c = 'Subject Test2', Description__c = 'Description Test2',Division__c = 'Sales',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = false,ForAllDivisions__c = false);
            taskTemplates.add(taskTemplate1);
            taskTemplates.add(taskTemplate2);
            Insert taskTemplates;
            
            taskTemplate2.Tab__c = '< 60 Days';
            taskTemplate2.Division__c = 'IT';
            update taskTemplate2;
            
            //List<TrainingTask__c> tasks = [select Id from TrainingTask__c where OwnerId in :keyIds and IsClosed__c = false ];
            //System.assertEquals(3, tasks.size());
        }
    }
    
    static testMethod void testUpdateTaskTemplateAllToDivision()
    {
        User user = [select Id from User where Profile.Name = 'System administrator' and isActive = true limit 1];
        
        System.runAs(User) 
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
                                  TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today().addDays(30));
            User user3 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                                  EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                  ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo2@camfed.org',
                                  TrainingDivision__c='Sales',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
            users.add(user1);
            users.add(user2);
            users.add(user3);
            InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
            insert users;
            
            Set<Id> keyIds = new Set<Id>();
            keyIds.add(user1.Id);
            keyIds.add(user2.Id);
            keyIds.add(user3.Id);
            
            List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
            TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = false);
            TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Elevate', Subject__c = 'Subject Test2', Description__c = 'Description Test2',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = false,ForAllDivisions__c = true);
            taskTemplates.add(taskTemplate1);
            taskTemplates.add(taskTemplate2);
            Insert taskTemplates;
            
            taskTemplate2.ForAllDivisions__c = false;
            taskTemplate2.Division__c = 'Sales';
            taskTemplate2.Tab__c = '< 90 Days';
            Test.startTest();
            update taskTemplate2;
            Test.stopTest();
            
            // List<TrainingTask__c> tasks = [select Id from TrainingTask__c where OwnerId in :keyIds and IsClosed__c = false ];
            // System.assertEquals(2, tasks.size());
        }
    }
    static testMethod void testExistingUsersWillReceiveThisTask()
    {
        User user = [select Id from User where Profile.Name = 'System administrator' and isActive = true limit 1];
        
        System.runAs(User) 
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
                                  TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today().addDays(30));
            User user3 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                                  EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                  ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo2@camfed.org',
                                  TrainingDivision__c='Sales',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
            users.add(user1);
            users.add(user2);
            users.add(user3);
            InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
            insert users;
            
            Set<Id> keyIds = new Set<Id>();
            keyIds.add(user1.Id);
            keyIds.add(user2.Id);
            keyIds.add(user3.Id);
            
            List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
            TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = false);
            TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Elevate', Subject__c = 'Subject Test2', Description__c = 'Description Test2',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = true);
            taskTemplates.add(taskTemplate1);
            taskTemplates.add(taskTemplate2);
            Insert taskTemplates;
            
            taskTemplate2.ForAllDivisions__c = false;
            taskTemplate2.Division__c = 'Sales';
            taskTemplate2.ExistingUsersWillReceiveThisTask__c = false;
            Test.startTest();
            update taskTemplate2;
            Test.stopTest();
            
            // List<TrainingTask__c> tasks = [select Id from TrainingTask__c where OwnerId in :keyIds and IsClosed__c = false ];
            //System.assertEquals(2, tasks.size());
        }
    }
    static testMethod void testDeleteTaskTemplate()
    {
        User user = [select Id from User where Profile.Name = 'System administrator' and isActive = true limit 1];
        
        System.runAs(User) 
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
                                  TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today().addDays(30));
            User user3 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',
                                  EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                                  ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo2@camfed.org',
                                  TrainingDivision__c='Sales',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
            users.add(user1);
            users.add(user2);
            users.add(user3);
            InsertUserToTrainingTaskTriggerHandler.skipInsert = false;
            insert users;
            
            Set<Id> keyIds = new Set<Id>();
            keyIds.add(user1.Id);
            keyIds.add(user2.Id);
            keyIds.add(user3.Id);
            
            List<TaskTemplate__c> taskTemplates = new List<TaskTemplate__c>();
            TaskTemplate__c taskTemplate1 = new TaskTemplate__c(Tab__c = '< 30 Days', Subject__c = 'Subject Test1', Description__c = 'Description Test1',Division__c = 'IT',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = false);
            TaskTemplate__c taskTemplate2 = new TaskTemplate__c(Tab__c = 'Elevate', Subject__c = 'Subject Test2', Description__c = 'Description Test2',
                                                                Effective_Date__c = Date.today(),ExistingUsersWillReceiveThisTask__c = true,ForAllDivisions__c = true);
            taskTemplates.add(taskTemplate1);
            taskTemplates.add(taskTemplate2);
            Insert taskTemplates;
            
            Test.startTest();
            delete taskTemplate2;
            Test.stopTest();
            
            //List<TrainingTask__c> tasks = [select Id from TrainingTask__c where OwnerId in :keyIds and IsClosed__c = false ];
            // System.assertEquals(2, tasks.size());        
        }
    }
}