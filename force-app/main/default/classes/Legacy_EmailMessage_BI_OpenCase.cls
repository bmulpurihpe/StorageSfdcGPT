/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 06-07-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   06-07-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger OpenCase on EmailMessage (after insert,before insert){
public with sharing class Legacy_EmailMessage_BI_OpenCase implements TriggerAction.BeforeInsert{
    public void beforeInsert(List<EmailMessage> newList){
    EmailMessage[] emailMessages = newList;
    // String emailLoop1 = System.Label.EmailLoopProtection ;
    //String emailLoop2 = System.Label.EmailLoopProtection2;
    //system.debug(emailLoop1);
    /** Added by Exafort(vishnu) 
*  Purpose - To restrict case comments with subject  Delivery delayed: 
*  */
    //if (Trigger.isBefore && Trigger.isInsert){
        for (EmailMessage emailMessage : emailMessages){
            if(emailMessage.subject != null && (
                emailMessage.subject.containsIgnoreCase('Delivery delayed:New case comment notification.') || 
                emailMessage.subject.containsIgnoreCase('Delivery delayed:') )){
                    emailMessage.addError('Out-of-office type subjects are not allowed to create new case comments.');
                }
        }
        //	Added By Exafort for SFDC-462
        Set<Id> caseIds = new Set<Id>();
        
        //	Gather Case IDs related to incoming emails
        for (EmailMessage em : emailMessages) {
            if (em.Incoming && em.ParentId != null && String.valueOf(em.ParentId).startsWith('500')) {
                caseIds.add(em.ParentId);
            }
        }
        
        if (!caseIds.isEmpty()) {
            //	Query the Cases with Status and Duplicate Case lookup
            Map<Id, Case> relatedCases = new Map<Id, Case>(
                [SELECT Id, Status, Duplicate_Case__c
                 FROM Case
                 WHERE Id IN :caseIds AND Status = 'Closed(Duplicate)' AND Duplicate_Case__c != null]
            );
            
            //	Update ParentId on incoming email
            for (EmailMessage em : emailMessages) {
                if (em.Incoming && relatedCases.containsKey(em.ParentId)) {
                    Case originalCase = relatedCases.get(em.ParentId);
                    em.ParentId = originalCase.Duplicate_Case__c;
                }
            }
        }
        //}
    }
}