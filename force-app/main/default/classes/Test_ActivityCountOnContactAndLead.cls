@isTest
private class Test_ActivityCountOnContactAndLead {
    public static Contact contact1;
    public static Account portalAccount1;
    public static List<Contact> cList;
    public static List<Lead> leadsList;
     
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
        
        portalAccount1 = new Account(
            Name='Setup Sample Account',
            OwnerId = UserInfo.getUserId()
        );
        Database.insert(portalAccount1);
        
          contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            Email = System.now().millisecond() + 'test@test.com',
            AccountId = portalAccount1.Id,Phone ='5435345345',
            Title ='testcont',MobilePhone ='9874561230',
            Department = 'TestData'
        );
        Database.insert(contact1);
        
        cList = NMBL_TestUtil.createContact(portalAccount1,2,true);
        leadsList = NMBL_TestUtil.createLead(2,true);
    }
    
    static testMethod void leadTaskTriggerTest() {
    
        leadsList = [Select id from Lead];
       
        
        List<Task> tList = new List<Task>();
        
        //Create Task 1.1 with Lead as WhoId
        
        tList = NMBL_TestUtil.createTask(leadsList[0].Id,2,true);
        
        tList[0].Activity_Disposition__c = 'Attempt - Invalid Data';
        tList[1].Activity_Disposition__c = 'Attempt - Call';
        
        update tList;
        
        //Create Task 1.2 with Lead as WhoId
        
        tList = NMBL_TestUtil.createTask(leadsList[1].Id,2,true);
        
        tList[0].Activity_Disposition__c = 'Attempt - Left Voicemail';
        tList[1].Activity_Disposition__c = 'Interest - Call Back Later';
        
        update tList;
        
      
   }
   
    static testMethod void contactTaskTriggerTest() {
        
        leadsList = [Select id from Lead];
        
        cList = [Select id from contact];
        
        List<Task> tList = new List<Task>();
        
        //Create Task 2.1 with Lead as WhoId
        
        tList = NMBL_TestUtil.createTask(leadsList[1].Id,7,true);
        
        tList[0].Type = 'Email';
        tList[0].Activity_Disposition__c = 'No Interest - Referral - Incorrect Contact';
        tList[1].Activity_Disposition__c = 'No interest-Not Target Market';
        tList[2].Activity_Disposition__c = 'No Interest - Cloud';
        tList[3].Activity_Disposition__c = 'No Interest - Hyperconverged Fan';
        tList[4].Activity_Disposition__c = 'Interest - Meeting Scheduled';
        tList[5].Activity_Disposition__c = 'Partner Call - No Answer';
        tList[6].Activity_Disposition__c = 'No Interest - No longer with company';
       
        update tList ;
        
          
        //Create Task 2.2 with Contact as WhoId
        
        tList = NMBL_TestUtil.createTask(cList[0].Id,2,true);
        
        tList[0].Type = 'Email';
        tList[1].Activity_Disposition__c = 'Attempt - Left Voicemail';
        
        update tList;
    }
}