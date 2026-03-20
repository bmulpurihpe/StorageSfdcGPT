/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=false)
private class Test_SalesHeadCountTrigger {

    static testMethod void myUnitTest() {
    	Test.startTest();
        // TO DO: implement unit test
        //Select Profile.Id, ProfileId From User;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> userToInsert = new List<User>();
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Employment_End_Date__c = System.today()+1,Employment_Start_Date__c=System.today()-1,
            TimeZoneSidKey='America/Los_Angeles', UserName='testing1@testorg.com');
       	
       	User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Employment_End_Date__c = System.today()-1,Employment_Start_Date__c=System.today(),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing2@testorg.com');
       	
       	User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today()+1,
            TimeZoneSidKey='America/Los_Angeles', UserName='testing3@testorg.com');
            
        User u4 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today(),Employment_End_Date__c = System.today(),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing4@testorg.com');
       	
       	User u5 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today(),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing5@testorg.com');
        
        User u6 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today().addmonths(1),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing6@testorg.com');
        
        User u7 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today().addYears(-1),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing7@testorg.com');
        
        User u8 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today().addMonths(-1),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing8@testorg.com');
        
        User u9 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today().addMonths(-3),Employment_End_Date__c=System.today().addDays(2),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing9@testorg.com');
        
       	userToInsert.add(u1);
       	userToInsert.add(u2);
       	userToInsert.add(u3);
       	userToInsert.add(u4);
       	userToInsert.add(u5);
        userToInsert.add(u6);
        userToInsert.add(u7);
        userToInsert.add(u8);
        userToInsert.add(u9);
		
		Datetime thisDate = System.now();
    	TimeZone tz = TimeZone.getTimeZone('America/Los_Angeles');
    	String changedDate =thisDate.format('MM/dd/yyyy HH:mm:ss',String.valueOf(tz));
    	String checkHour;
    	String checkMinutes;
    	checkHour = changedDate.substring(11,13);
    	checkMinutes = changedDate.substring(14,16);
 		String currentTime = checkHour+checkMinutes;
		User_Activation__c UserTime = new User_Activation__c(Name='Test Time', Activation_Time__c=currentTime);
		insert userTime;
		
        insert userToInsert;
        
		Integer minutecheck = Integer.valueOf(checkMinutes);
		minuteCheck++;
		checkMinutes = String.valueOf(minuteCheck);
    	String checkMonth = changedDate.substring(0,2);
        //Integer monthCron = Integer.valueOf(checkMonth);
        //monthCron++;
        //checkMonth = String.valueOf(monthCron);
    	String checkDay = changedDate.substring(3,5);
        Integer dayCron = Integer.valueOf(checkDay);
        checkDay = String.valueOf(dayCron);
		Schedule_SalesHeadCount SHC = new Schedule_SalesHeadCount();
		//String sch = '00 56 03 12 8 ?';
		String sch = '0 '+checkMinutes+' '+checkHour+' '+checkDay+' '+checkMonth+' ?';
		String jobID = system.schedule('testSales Head', sch, SHC);
		
		Test.stopTest();

		
    }
    
    static testMethod void myUnitTest1(){
        
    	Test.startTest();
        Utility.salesHeadCountBypassTrigger=false;
        // TO DO: implement unit test
        //Select Profile.Id, ProfileId From User;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> userToInsert = new List<User>();
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id, Employment_End_Date__c = System.today()+1,Employment_Start_Date__c=System.today()-1,
            TimeZoneSidKey='America/Los_Angeles', UserName='testing1@testorg.com');
       	
       	User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id, Employment_End_Date__c = System.today()-1,Employment_Start_Date__c=System.today(),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing2@testorg.com');
       	
       	User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today()+1,
            TimeZoneSidKey='America/Los_Angeles', UserName='testing3@testorg.com');
            
        User u4 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today(),Employment_End_Date__c = System.today(),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing4@testorg.com');
       	
       	User u5 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today(),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing5@testorg.com');
        
        User u6 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today().addmonths(1),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing6@testorg.com');
        
        User u7 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today().addYears(-1),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing7@testorg.com');
        
        User u8 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today().addMonths(-1),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing8@testorg.com');
        
        User u9 = new User(Alias = 'standt', Email='standarduser@testorg.com', IsActive = false,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Activation_Status__c='Pending',
            LocaleSidKey='en_US', ProfileId = p.Id,Employment_Start_Date__c=System.today().addMonths(-3),Employment_End_Date__c=System.today().addDays(2),
            TimeZoneSidKey='America/Los_Angeles', UserName='testing9@testorg.com');
            
       	userToInsert.add(u1);
       	userToInsert.add(u2);
       	userToInsert.add(u3);
       	userToInsert.add(u4);
       	userToInsert.add(u5);
        userToInsert.add(u6);
        userToInsert.add(u7);
        userToInsert.add(u8);
        userToInsert.add(u9);
		
		Datetime thisDate = System.now();
    	TimeZone tz = TimeZone.getTimeZone('America/Los_Angeles');
    	String changedDate =thisDate.format('MM/dd/yyyy HH:mm:ss',String.valueOf(tz));
    	String checkHour;
    	String checkMinutes;
    	checkHour = changedDate.substring(11,13);
    	checkMinutes = changedDate.substring(14,16);
 		String currentTime = checkHour+checkMinutes;
		User_Activation__c UserTime = new User_Activation__c(Name='Test Time', Activation_Time__c=currentTime);
		insert userTime;
		
        insert userToInsert;
        
		Integer minutecheck = Integer.valueOf(checkMinutes);
		minuteCheck++;
		checkMinutes = String.valueOf(minuteCheck);
    	String checkMonth = changedDate.substring(0,2);
        //Integer monthCron = Integer.valueOf(checkMonth);
        //monthCron++;
        //checkMonth = String.valueOf(monthCron);
    	String checkDay = changedDate.substring(3,5);
        //Integer dayCron = Integer.valueOf(checkDay);
        //checkDay = String.valueOf(dayCron);
		Schedule_SalesHeadCount SHC = new Schedule_SalesHeadCount();
		//String sch = '00 56 03 12 8 ?';
		String sch = '0 '+checkMinutes+' '+checkHour+' '+checkDay+' '+checkMonth+' ?';
		String jobID = system.schedule('testSales Head', sch, SHC);
		
		Test.stopTest();

		
        
    }
}