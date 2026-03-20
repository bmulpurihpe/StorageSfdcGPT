@isTest
private class PortalUserCls_Test {
    
    
    @testSetup static void setupData() {
        Datetime thisDate = System.now();
        TimeZone tz = TimeZone.getTimeZone('America/Los_Angeles');
        String changedDate = thisDate.format('MM/dd/yyyy HH:mm:ss',String.valueOf(tz));
        String checkHour;
        String checkMinutes;
        checkHour = changedDate.substring(11,13);
        checkMinutes = changedDate.substring(14,16);
        String currentTime = checkHour+checkMinutes;
        
        User_Activation__c UserTime = new User_Activation__c(Name='Test Time', Activation_Time__c=currentTime);
        insert userTime;
    }
    static testmethod void myUserPermissionsetTest(){
    
    
          User user = new User();
          user.ProfileID = [Select Id From Profile Where Profile.UserLicense.Name = 'Salesforce' limit 1].id;
          user.EmailEncodingKey = 'ISO-8859-1';
          user.LanguageLocaleKey = 'en_US';
          user.TimeZoneSidKey = 'America/New_York';
          user.LocaleSidKey = 'en_US';
          user.FirstName = 'unique';
          user.LastName = 'gottobeveryUniQue';
          user.Username = 'test@gottobeveryUniQue.com';   
          user.CommunityNickname = 'testUser123';
          user.Alias = 't1';
          user.Email = 'no@email.com';
          user.IsActive = true;
          user.pilot_user__c = True;
          user.TrainingEnabled__c = True;
          insert user;
          
          PermissionSetAssignment pas = [SELECT ID, AssigneeId, PermissionSetId From PermissionSetAssignment WHERE PermissionSet.Name = 'Training_Tab_Access' AND AssigneeId =: user.id];
          System.assertEquals(user.id,pas.AssigneeId);
   
    }
    
    static testmethod void myUserTest(){
          
       Contact contact1;
       Account portalAccount1; 
          updationuser.isfutureupdate = false;
       portalAccount1 = new Account(
                Name='Setup Sample Account',
                OwnerId = UserInfo.getUserId(),
                Type ='Reseller',
                BillingCountry = 'United States'
                );
            
          //insert portalAccount1;
           Database.insert(portalAccount1, false);
            
       contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
               // Email = System.now().millisecond() + 'test@test.com',
               Email = 'test123@gmail.com',
                AccountId = portalAccount1.Id,Phone ='5435345345',
                Title ='testcont',MobilePhone ='9874561230',
                Department = 'TestData'
            );
            
       insert contact1;
       Update contact1;
                        
          User user = new User();
          user.ProfileID = [Select Id From Profile Where Name='NS-SALES-PartnerPortal-Disti-Manage-Quotes'].id;
          user.EmailEncodingKey = 'ISO-8859-1';
          user.LanguageLocaleKey = 'en_US';
          user.TimeZoneSidKey = 'America/New_York';
          user.LocaleSidKey = 'en_US';
          user.FirstName = 'unique';
          user.LastName = 'gottobeveryUniQue';
          user.Username = 'test@gottobeveryUniQue.com';   
          user.CommunityNickname = 'testUser123';
          user.Alias = 't1';
          user.Email = 'no@email.com';
          user.IsActive = true;
          user.pilot_user__c = True;
          user.ContactId = contact1.Id;
          insert user;

          Test.startTest();
          User user1 = [Select id,name,accountid from user limit 1];
          
          user1.pilot_user__c = True;
          user1.ApplicationRoleIdentifier__c = 'MDF Requestor';
          
          update user1;
                     
          Test.stopTest();
    }
}