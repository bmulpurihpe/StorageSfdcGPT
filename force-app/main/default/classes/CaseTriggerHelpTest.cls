//Change Log:Added Test.StartTest() and Test.stopTest() in all the test methods-24 jan 2019
@isTest(seeAllData = false)
public class CaseTriggerHelpTest
  {// 1-6-15  Chris Sorrows  Made edits to this class to fix the following issues:
   //                        1. Some variable names were confusing.  They were too short and not
   //                           descriptive enough, or were named the same as the class name.
   //                        2. Broke single "main" test method into multiple methods due to
   //                           single method was overrunning SOQL governor limits.

   /*public static testMethod void test01()
     {Group groupGeneral = new Group(Type = 'queue', name = 'Support Queue - General');
      insert groupGeneral;
	
      Group groupTest = new Group(name = 'Test');
      insert groupTest;

      Group groupTsc = new Group(Type = 'queue', name = 'Support Queue TSC');
      insert groupTsc;

      UserRole aUserRole = [select id from UserRole limit 1];
      //  SObject aProfile   = [select id from Profile limit 1]; // Commented by mansaMansa on 5/22/2015 to avoid test class issue
     SObject aProfile   = [select id from Profile where name='System Administrator II (pw never expires)' limit 1]; // Added by Mansa on 5/22/2015 to avoid test class issue

      User userTest1 = new User(Username= 'testspUser1@company.com',Alias = 'test',UserPermissionsMobileUser = false,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',UserRole = aUserRole,Email = 'testspuser1@company.com',Lastname = 'user',Firstname = 'test',ProfileId = aProfile.id);
      insert userTest1;
	
      User userTest2 = new User(Username= 'testspUser2@company.com',Alias = 'test2',UserPermissionsMobileUser = false,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',UserRole = aUserRole,Email = 'testspuser2@company.com',Lastname = 'user',Firstname = 'test',ProfileId = aProfile.id);
      insert userTest2;

      User userTest3 = new User(Username= 'testspUser3@company.com',Alias = 'test3',UserPermissionsMobileUser = false,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',UserRole = aUserRole,Email = 'testspuser3@company.com',Lastname = 'user',Firstname = 'test',ProfileId = aProfile.id);
      insert userTest3;

      User userTest4 = new User(Username= 'testspUser4@company.com',Alias = 'test4',UserPermissionsMobileUser = false,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',UserRole = aUserRole,Email = 'testspuser4@company.com',Lastname = 'user',Firstname = 'test',ProfileId = aProfile.id);
      insert userTest4;
		
      GroupMember groupMemberTest1 = new GroupMember(UserOrGroupId = userTest1.Id, GroupId = groupGeneral.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert groupMemberTest1;
        }

      GroupMember groupMemberTest2 = new GroupMember(UserOrGroupId = userTest2.Id, GroupId = groupGeneral.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert groupMemberTest2;
        }

      GroupMember groupMemberTest3 = new GroupMember(UserOrGroupId = userTest3.Id, GroupId = groupTsc.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert groupMemberTest3;
        }
		
      GroupMember groupMemberTest4 = new GroupMember(UserOrGroupId = userTest4.Id, GroupId = groupTsc.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert groupMemberTest4;
        }

      GroupMember groupMemberTest5 = new GroupMember(UserOrGroupId = groupTest.Id, GroupId = grouptsc.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
      {insert groupMemberTest5;
      }

      QueueSobject mappingObject = new QueueSobject(QueueId = groupTsc.Id, SobjectType = 'Case');
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject;
        }
	
      QueueSobject mappingObject2 = new QueueSobject(QueueId = groupGeneral.Id, SobjectType = 'Case');
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject2;
        }

      ID profileSupportSystemAdministratorId = [Select id from Profile where name = 'Support: System Administrator'].id;
		
      User userTest = new User(email             = 'test-user@example1.com',
                               profileid         = profileSupportSystemAdministratorId,
                               UserName          = 'test-usercasehelperxxx@email.com',
                               alias             = 'tuser1',
                               CommunityNickName = 'testuser',
                               TimeZoneSidKey    = 'America/New_York',
                               LocaleSidKey      = 'en_US',
                               EmailEncodingKey  = 'ISO-8859-1',
                               LanguageLocaleKey = 'en_US',
                               FirstName         = 'Test',
                               LastName          = 'UserTest');
      insert userTest;
		
		
      System.runAs(userTest)
        {RecordType recordTypeSupportProvider = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
         RecordType recordTypeChannel         = [select id,Name from RecordType where SobjectType='Account' and Name='Channel' Limit 1];

         Account accountService = new Account(Name = 'Service',Type='Support Provider',RecordTypeId = recordTypeSupportProvider.id);
         insert accountService;

         Contact contactService = new Contact(LastName = 'Test',Support_Provider__c = true,AccountId = accountService.Id);
         insert contactService;

         Account accountReseller = new Account(Name = 'Test',type= 'Reseller',Support_Provider__c = accountService.id,RecordTypeId = recordTypeChannel.id);
         insert accountReseller;

         Contact contactReseller = new Contact(LastName = 'Test2',AccountId = accountReseller.Id);
         insert contactReseller;
		
         // ===== FIRST TEST =====
         Case caseOld = new Case(Status = 'new',AccountId = accountReseller.Id,ownerId = userTest1.id);
         insert caseOld;
		
         Test.startTest();
         Case caseNew = new Case(Status = 'new',AccountId = accountReseller.Id,ownerId = userTest2.id,Escalated__c = true);
         insert caseNew;
         
		
         List<Case> listCaseOld = new List<Case>{caseOld};
         List<Case> listCaseNew = new List<Case>{caseNew};

         CaseTriggerHelp CTH = new CaseTriggerHelp();
         CaseTriggerHelp.validateOwner(listCaseOld, ListCaseNew);

         accountReseller.Support_Provider__c = null;
         update accountReseller;
		
         caseNew.Escalated__c = false;
         update caseNew;

         CaseTriggerHelp.validateOwner(listCaseOld, listCaseNew);
		system.debug('#### test class '+Limits.getQueries());
         Test.stopTest();
        }
     }*/

   public static testMethod void test02()
     {Group groupGeneral = new Group(Type = 'queue', name = 'Support Queue - General');
      insert groupGeneral;

      Group groupTest = new Group(name = 'Test');
      insert groupTest;

      Group groupTsc = new Group(Type = 'queue', name = 'Support Queue TSC');
      insert groupTsc;

      UserRole aUserRole = [select id from UserRole limit 1];
     //  SObject aProfile   = [select id from Profile limit 1]; // Commented by mansaMansa on 5/22/2015 to avoid test class issue
      SObject aProfile   = [select id from Profile where name='System Administrator II (pw never expires)' limit 1]; // Added by Mansa on 5/22/2015 to avoid test class issue
  list<user> masterUser = new list<User>();
     /*  User userTest1 = new User(Username= 'testspUser1@company.com',Alias = 'test',UserPermissionsMobileUser = false,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',UserRole = aUserRole,Email = 'testspuser1@company.com',Lastname = 'user',Firstname = 'test',ProfileId = aProfile.id);
     masterUser.add(userTest1);

      User userTest2 = new User(Username= 'testspUser2@company.com',Alias = 'test2',UserPermissionsMobileUser = false,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',UserRole = aUserRole,Email = 'testspuser2@company.com',Lastname = 'user',Firstname = 'test',ProfileId = aProfile.id);
     masterUser.add(userTest2);

      User userTest3 = new User(Username= 'testspUser3@company.com',Alias = 'test3',UserPermissionsMobileUser = false,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',UserRole = aUserRole,Email = 'testspuser3@company.com',Lastname = 'user',Firstname = 'test',ProfileId = aProfile.id);
      masterUser.add(userTest3);

      User userTest4 = new User(Username= 'testspUser4@company.com',Alias = 'test4',UserPermissionsMobileUser = false,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',UserRole = aUserRole,Email = 'testspuser4@company.com',Lastname = 'user',Firstname = 'test',ProfileId = aProfile.id);
      masterUser.add(userTest4);
      
      insert masterUser;
      GroupMember groupMemberTest1 = new GroupMember(UserOrGroupId = masterUser[0].Id, GroupId = groupGeneral.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert groupMemberTest1;
        }

     GroupMember groupMemberTest2 = new GroupMember(UserOrGroupId =  masterUser[1].Id, GroupId = groupGeneral.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert groupMemberTest2;
        }

      GroupMember groupMemberTest3 = new GroupMember(UserOrGroupId = masterUser[2].Id, GroupId = groupTsc.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert groupMemberTest3;
        }

      GroupMember groupMemberTest4 = new GroupMember(UserOrGroupId =  masterUser[3].Id, GroupId = groupTsc.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert groupMemberTest4;
        }

      GroupMember groupMemberTest5 = new GroupMember(UserOrGroupId = groupTest.Id, GroupId = grouptsc.Id);
      System.runAs(new User(Id = UserInfo.getUserId()))
      {insert groupMemberTest5;
      }*/

      QueueSobject mappingObject = new QueueSobject(QueueId = groupTsc.Id, SobjectType = 'Case');
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject;
        }

      QueueSobject mappingObject2 = new QueueSobject(QueueId = groupGeneral.Id, SobjectType = 'Case');
      System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject2;
        }

      ID profileSupportSystemAdministratorId = [Select id from Profile where name = 'Support: System Administrator'].id;

      User userTest = new User(email             = 'test-user@example1.com',
                               profileid         = profileSupportSystemAdministratorId,
                               UserName          = 'test-usercasehelper01xxx@email.com',
                               alias             = 'tuser1',
                               CommunityNickName = 'testuser',
                               TimeZoneSidKey    = 'America/New_York',
                               LocaleSidKey      = 'en_US',
                               EmailEncodingKey  = 'ISO-8859-1',
                               LanguageLocaleKey = 'en_US',
                               FirstName         = 'Test',
                               LastName          = 'UserTest');
     // insert userTest;

      
            RecordType recordTypeSupportProvider = [select id,Name from RecordType where SobjectType='Account' and Name='Support Provider' Limit 1];
         RecordType recordTypeChannel         = [select id,Name from RecordType where SobjectType='Account' and Name='Channel' Limit 1];

         Account accountService = new Account(Name = 'Service',Type='Support Provider',RecordTypeId = recordTypeSupportProvider.id);
         insert accountService;

         Contact contactService = new Contact(LastName = 'Test',Support_Provider__c = true,AccountId = accountService.Id);
         insert contactService;

         Account accountReseller = new Account(Name = 'Test',type= 'Reseller',Support_Provider__c = accountService.id,RecordTypeId = recordTypeChannel.id);
         insert accountReseller;

         Contact contactReseller = new Contact(LastName = 'Test2',AccountId = accountReseller.Id);
         insert contactReseller;

          
         system.debug('#### test class '+Limits.getQueries());
		 
         // ===== SECOND TEST =====
         Case caseOld2 = new Case(Status = 'new',AccountId = accountReseller.Id,ownerId = groupGeneral.id);
         insert caseOld2;
		Test.startTest();
         Case caseNew2 = new Case(Status = 'new',AccountId = accountReseller.Id,ownerId = groupTsc.id,Escalated__c = true);
         insert caseNew2;
		system.debug('#### test class '+Limits.getQueries());
         List<Case> listCaseOld2 = new List<Case>{caseOld2};
         List<Case> listCaseNew2 = new List<Case>{caseNew2};

         CaseTriggerHelp CTH2 = new CaseTriggerHelp();
         CaseTriggerHelp.validateOwner(listCaseOld2, listCaseNew2);

         accountReseller.Support_Provider__c = null;
         update accountReseller;

         caseNew2.Escalated__c = false;
         update caseNew2;

         CaseTriggerHelp.validateOwner(listCaseOld2, listCaseNew2);
         Test.stopTest();
       
     }
  }