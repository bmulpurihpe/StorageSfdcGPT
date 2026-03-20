/* Class Name: engageNCVBillingController 
* Purpose: This is controller class for engaging the case to To Accounts Receivable (A/R) and the NCV Portal ENG team for Billing. 
* Author: Vishnu Ramireddy
* Created Date: 16th Nov 2021
* */ 
public with sharing class engageNCVBillingController {
    @AuraEnabled
    Public static void updateCaseNcvBilling(Id recId){
        case aCase = [select Id,caseEngageNCVBilling__c  from case where Id=:recId];
        aCase.caseEngageNCVBilling__c = true;
        update aCase;
    }
}