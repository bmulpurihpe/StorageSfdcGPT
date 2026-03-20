@isTest
private class testassignHPETeam{
    @testSetup static void testdata() {
        List<Account> accounts = new List<Account>();
        List<Account> accounts1 = new List<Account>();
        List<Account_Teams_HPE__c> acctTeamHPE = new List<Account_Teams_HPE__c>();
        List<Account_Teams_Zipcode_HPE__c> acctTeamZC =  new List<Account_Teams_Zipcode_HPE__c>();
       
       /****** test scenario 1 *****/
        Account a = new Account(name  = 'Test acct ' , Account_STID__c = '513527575', billingcity = 'San Jose', billingcountry = 'USA');
        insert a;
        
        Account_Teams_HPE__c act = new Account_Teams_HPE__c(Full_Name__c = 'Test', Employee_ID__c = '1111',Sales_Territory_ID__c = '513527575', Active__c=True);
        insert act;
        
        Account_Teams_HPE_Details__c actteamDetails = new Account_Teams_HPE_Details__c(Account__c = a.Id, Account_Teams_HPE__c = act.id, Acct_Id__c =  string.valueOf(a.Id) + string.valueOf(act.Id),
                        Employee_ID__c   ='1111'    , Non_Member__c = true);
        insert actteamDetails ; 
        
        /****** test scenario 2 *****/
        
        Account a1 = new Account(name  = 'Test acct ' , billingpostalCode = '94002-000', billingcity = 'San Jose', billingcountry = 'USA');
        insert a1;
        
        
        Account_Teams_HPE_Details__c actteamDetails1 = new Account_Teams_HPE_Details__c(Account__c = a1.Id, Account_Teams_HPE__c = act.id, Acct_Id__c =  string.valueOf(a1.Id) + string.valueOf(act.Id),
                        Employee_ID__c   ='1111' , Non_Member__c = true);
        insert actteamDetails1 ; 
          
          
        /***** test scenario 3 ****/                                                   
        // insert 10 accounts
        for (Integer i=0;i<10;i++) {
            accounts.add(new Account(name='Account '+i,Account_STID__c = '513527575',
                billingcity='New York', billingcountry='USA'));
        }
        insert accounts;
        
        for (Integer i=0;i<10;i++) {
            accounts1.add(new Account(name='Account '+i,BillingPostalCode= '9400'+i,
                billingcity='New York', billingcountry='USA'));
        }
        insert accounts1;
        
        for(Integer i=0; i<10; i++){
            acctTeamHPE.add(new Account_Teams_HPE__c(Full_Name__c = 'Test '+i, Employee_ID__c = '1111 ' +i,Sales_Territory_ID__c = '513527575', Active__c=True));
        }
        
        insert acctTeamHPE;
        
        for(Integer i=0; i<10; i++){
            acctTeamZC.add(new Account_Teams_Zipcode_HPE__c(ST_ID__c='513527575',Zipcode__c = '9400'+i));
        }
        insert acctTeamZC;
        
    }
   
   
    static testmethod void test() {   
       
        Test.startTest();
         String q = 'SELECT Id, Account_STID__c  FROM Account where Account_STID__c = \'513527575\'';
         Id batchInstanceId = Database.executeBatch(new assignHPETeam(q));
      
        Test.stopTest();
       
    }
    
    static testmethod void test2() {   
    
        Test.startTest();
        String q = 'SELECT Id, Account_STID__c, BillingPostalCode  FROM Account where BillingPostalCode != null';
        Id batchInstanceId = Database.executeBatch(new assignHPETeamZipCode(q));
        
        Test.stopTest();
    
    }
    
}