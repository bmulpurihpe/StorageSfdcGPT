/* Class Name: NewCommentLexController 
* Purpose: This is controller class for redirecting the e2cp new comment page specific to selected record type. 
* Author: Vishnu Ramireddy
* Created Date: 2nd Dec 2021
* */ 
public with sharing class NewCommentLexController {
    @AuraEnabled
    public static string recordTypeFromCase(Id caserecordId){
        system.debug('Inside Apex class - Case Id ==>'+caserecordId);
        case aCase = [select Id,Recordtype.Name from case where Id=:caserecordId];
        return aCase.recordtype.Name;
    }
}