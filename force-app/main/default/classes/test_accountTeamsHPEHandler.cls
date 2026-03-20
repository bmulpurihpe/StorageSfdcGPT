@isTest 
public class test_accountTeamsHPEHandler
{ 
static testMethod void addAccount()
{ 
Account createTestAccount = new Account(); 
createTestAccount.Name = 'Test Account 1'; 
createTestAccount.Account_STID__c = '150566593';
insert createTestAccount; 

Account_Teams_HPE__c actHPE = new Account_Teams_HPE__c ();
actHPE.Active__c =  true;
actHPE.MDCP_Id__c  = '150566593';
actHPE.Employee_ID__c = 'A123';
actHPE.Full_Name__c = 'John Doe';
actHPE.Manager_Email__c = 'jane.doe@test.com';
actHPE.Email__c = 'john.doe@test.com';
insert actHPE;

} 
}