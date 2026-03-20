@isTest
private class Test_OpportunityTriggerHelper {
    public static List<Call_Blitz__c> cBlitzList;
    public static Contact contact1;
    public static Account portalAccount1;
    public static List<Contact> cList; 
      
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
            OwnerId = UserInfo.getUserId(),
            Type = 'Reseller'
        );
        insert portalAccount1;
        
          contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            Email = System.now().millisecond() + 'test@test.com',
            AccountId = portalAccount1.Id,Phone ='5435345345',
            Title ='testcont',MobilePhone ='9874561230',
            Department = 'TestData'
        );
        insert contact1;
        
        cList = NMBL_TestUtil.createContact(portalAccount1,2,true);
        
        cBlitzList = NMBL_TestUtil.createCallBlitz(portalAccount1,contact1,2,true);
    }

    static testMethod void testOppsCallBlitz(){
  
         portalAccount1 = [Select id from account limit 1];
           
         cBlitzList = [Select id from Call_Blitz__c];    
         List<Opportunity> oppList = NMBL_TestUtil.createOpportunity('Test Opp',2,portalAccount1,false);
         
         //Insert opportunity
         oppList[0].Call_Blitz__c = cBlitzList[0].Id;
         oppList[1].Call_Blitz__c = cBlitzList[0].Id;
         oppList[0].HPE_Opportunity_ID__c = 'OPE-TestCALLBL';
         oppList[1].HPE_Opportunity_ID__c = 'OPE-TestCALLB2';
         insert oppList;
         
         // Update Opportunity
         oppList[0].Call_Blitz__c = cBlitzList[0].Id;
         oppList[1].Call_Blitz__c = cBlitzList[1].Id;
         
         update oppList;
         
         // Delete Opportunity
         delete oppList;
    }
    
    
     static testMethod void testOppsCallBlitz1(){
  
         portalAccount1 = [Select id from account limit 1];
           
         cBlitzList = [Select id from Call_Blitz__c];    
         List<Opportunity> oppList = NMBL_TestUtil.createOpportunity('Test Opp',2,portalAccount1,false);
         
         
         //Insert opportunity
         oppList[0].Call_Blitz__c = cBlitzList[0].Id;
         oppList[1].Call_Blitz__c = cBlitzList[1].Id;
         oppList[0].HPE_Opportunity_ID__c = 'OPE-TestCALLB3';
         oppList[1].HPE_Opportunity_ID__c = 'OPE-TestCALLB4';
         insert oppList;
         
         // Delete Opportunity
         delete oppList;
         
         // UnDelete Opportunity
         undelete oppList;
  
    }
    
}