/* Class Name: engageNCVBillingControllerTest 
* Purpose: Test Class for engageNCVBillingController. 
* Author: Vishnu Ramireddy
* Created Date: 16th Nov 2021
* */ 
@isTest
public class engageNCVBillingControllerTest {
    Public static testmethod void mainTest(){
        
        //Inserting Account
        Account aAccount = new Account();
        aAccount.Name = 'TEST-ACCOUNT';
        aAccount.accountRmaShi__c='Account RMA SHI';
        insert aAccount;
        
        //Inserting Contact
        Contact aContact = new Contact();
        aContact.LastName = 'TEST-CONTACT-LAST-NAME';
        aContact.AccountId = aAccount.Id;
        aContact.Email='test@gmail.com';
        aContact.Phone='999999999';
        insert aContact;
        
        //Inserting Case
        Case aTestCase = new Case();
        aTestCase.AccountId = aAccount.Id;
        aTestCase.ContactId = aContact.Id;
        aTestCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
        aTestCase.caseCatImpactToCustomer__c = 'Just a question - no service impact';
        aTestCase.Type = 'Feature Request';
        aTestCase.Nimble_Version__c ='Unknown';
        aTestCase.Estimated_Effort__c = '5 minutes or less';
        aTestCase.Subject = 'Testing Engage NCV Billing Action';
        insert aTestCase;
        
        Test.startTest();
        engageNCVBillingController.updateCaseNcvBilling(aTestCase.Id);
        Test.stopTest();
    }
}