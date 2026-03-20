@isTest 
public class AccountTeam_TestClass 
{ 
static testMethod void coverAccountTeam()
{ 
Account createTestAccount = new Account(); 
createTestAccount.Name = 'Test Account 1'; 
createTestAccount.MDCP_Org_ID__c = '150566593';
insert createTestAccount; 
Account_Team__c createTestAccountTeam = new Account_Team__c();
createTestAccountTeam.Account__c = createTestAccount.Id;
createTestAccountTeam.MDCP_ID__c =  '150566593';
insert createTestAccountTeam; 
} 
}