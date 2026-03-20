/*                              <<<< === createContactForOpsCase Apex class === >>>>
=============================================================================================================
Name                    : createContactForOpsCase
Description             : Logic to map/create contact for the e2r OPS cases.
Created Date            : 25th May 2021
Author                  : Vishnu R
Version                 : 1.0
Modification History    : Initial Version
==============================================================================================================
*/
public class createContactForOpsCase {
    public static string cFirstName;
    public static string cLastName;
    //Getting the Account id From the custom setting.
    public static string accountid = NimbleServicePortalAccountId__c.getInstance().AccountId__c;
    public static Id insertOpsCaseContact(String senderEmail,String caseSuppliedName){
        List<Contact> allContacts = [Select Id from Contact Where Email =:senderEmail and AccountId =:accountid Limit 1];
        if(allContacts.size() == 1){
            return allContacts[0].Id;
        }
        else{
            if(caseSuppliedName != null) {
                cFirstName = caseSuppliedName.contains(', ') ? caseSuppliedName.substringAfter(', ') : caseSuppliedName.substringBefore(' '); 
                cLastName = caseSuppliedName.contains(', ') ? caseSuppliedName.substringBefore(', ') : caseSuppliedName.substringAfter(' '); 
            }    
            Contact conRec = new Contact();
            conRec.AccountId = accountid;
            conRec.FirstName = cFirstName;
            conRec.LastName = cLastName;
            conRec.Email = senderEmail;
            insert conRec;
            return conRec.Id;
        }
    }
}