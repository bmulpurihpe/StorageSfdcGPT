/**
 * @description       : Sends handover emails for updated cases
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 01-30-2026
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   12-05-2025   Nagalaxmi Telkar   Initial Version
**/
public with sharing class Case_AU_ColdHandoverEmailService implements TriggerAction.AfterUpdate{
    /**
     * @description Sends handover emails for updated cases
     * @param newCases Map of new case values
     * @param oldCases Map of old case values
     */
    public void afterUpdate(List<Case> newList, List<Case> oldList){
        Map<Id,Case> oldMap = new Map<Id,Case>(oldList);
        List<Case> identifiedCasesForUpdate = new List<Case>();
        // Identify cases that need handover emails
        for (Case caseToProcess : newList){
            case oldCaseRec = oldMap.get(caseToProcess.id);
            //if(caseToProcess.Status == 'Handover' && !caseToProcess.HandoverNotified__c && oldCaseRec.OwnerId!=caseToProcess.OwnerId && !isSupportQueueGeneral(oldCaseRec.OwnerId))
            if(caseToProcess.Status == 'Handover' && !caseToProcess.HandoverNotified__c && oldCaseRec.OwnerId!=caseToProcess.OwnerId && !isSupportQueueGeneral(oldCaseRec.OwnerId) && (caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId() || caseToProcess.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId() ))
                identifiedCasesForUpdate.add(caseToProcess);
        }
        sendHandoverEmails(identifiedCasesForUpdate);        
    }
    
    
    /**
     * @description Checks if the given owner ID belongs to "Support Queue - General"
     * This method provides a more maintainable way to identify the support queue
     * instead of using hardcoded IDs
     * @param ownerId The owner ID to check
     * @return Boolean true if owner is Support Queue - General, false otherwise
     */
    private static Boolean isSupportQueueGeneral(Id ownerId) {
        if (ownerId == null) {
            return false;
        }
        
        try {
            // Check if this is a Group (Queue) ID
            String ownerIdStr = String.valueOf(ownerId);
            if (ownerIdStr.startsWith('00G')) {
                // Query the Group to check if it's "Support Queue - General"
                List<Group> supportQueues = [SELECT Id, Name, Type 
                                           FROM Group 
                                           WHERE Id = :ownerId 
                                           AND Type = 'Queue' 
                                           AND Name = 'Support Queue - General'
                                           LIMIT 1];
                
                Boolean isSupportQueue = !supportQueues.isEmpty();
                System.debug('Owner ID ' + ownerId + ' is Support Queue - General: ' + isSupportQueue);
                return isSupportQueue;
            }
            
            // If it's not a Group ID, it's not the support queue
            System.debug('Owner ID ' + ownerId + ' is not a queue (not starting with 00G)');
            return false;
            
        } catch (Exception e) {
            System.debug('Error checking if owner is Support Queue - General: ' + e.getMessage());
            // Fallback to hardcoded ID if query fails
            return ownerId == '00G80000001ucU1';
        }
    }
    
    /**
     * @description Sends handover emails for the provided cases
     * @param casesToProcess List of cases that need handover emails
     */
    public static void sendHandoverEmails(List<Case> casesToProcess) {
        List<Case> casesToUpdate = new List<Case>();
        List<Id> caseIds = new List<Id>();
        try {
            // Process each case
            for (Case caseRecord : casesToProcess) {
                String recipientEmail;
                if(isProductionOrg()){
                    if(caseRecord.support_profile__c != 'Alletra MP Block' )//Legacy Nimble
                        recipientEmail = 'nimble-support-global@hpe.com';
                    else//Non Legacy Nimble
                        recipientEmail = 'AlletraMPBlockStorage@hpe.com';
                }else{
                    recipientEmail = 'nimble-support-sfdc@hpe.com';
                }
                
                if (String.isNotBlank(recipientEmail)) {
                    // Send the email
                    if(sendEmail(caseRecord, recipientEmail)){
                        //caseRecord.HandoverNotified__c = true;
                        caseIds.add(caseRecord.Id);
                    }
                }
            }
            
            if(caseIds.size()>0){
                List<Case> listOfCases = [SELECT HandoverNotified__c FROM Case WHERE Id IN:caseIds];
                if(listOfCases != null && listOfCases.size()>0){
                    for(Case thisCase : listOfCases){
                        thisCase.HandoverNotified__c = true;
                        casesToUpdate.add(thisCase);
                    }
                    update casesToUpdate;
                }
            }
            
        } catch (Exception e) {
            System.debug('Error processing handover emails: ' + e.getMessage());
        }
    }
    
    
    /**
     * @description Sends the handover email
     * @param caseRecord The case record
     * @param recipientEmail The recipient email address
     * @return Boolean indicating if email was sent successfully
     */
    private static Boolean sendEmail(Case caseRecord, String recipientEmail) {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String baseUrl = Label.SalesforceURL;
            // Set recipient
            email.setToAddresses(new List<String>{recipientEmail});
            
            // Set subject
            email.setSubject(caseRecord.Subject);
            String htmlBody = '<html><body style="font-family: Arial, sans-serif; font-size: 11px; color: #000000;">';
            String handoverTypeText = 'COLD HANDOVER';
            // Set body
            
            // Main header
            htmlBody += '<p style="margin: 0; padding: 0;"><strong>' + handoverTypeText + ' CASE</strong></p><br/>';
        
            // Case link
            htmlBody += '<p style="margin: 0; padding: 0;">Nimble SFDC Case: <a href="' + baseUrl + '/' + caseRecord.Id + '" target="_blank">' + caseRecord.CaseNumber + '</a></p><br/>';
        
            // Current Summary section
            htmlBody += '<p style="margin: 0; padding: 0;">Current Summary:</p><br/>';
            htmlBody += '<p style="margin: 0; padding: 0;">'+caseRecord.caseCurrentStatus__c+'</p><br/>';
        
            // Next Steps section  
            htmlBody += '<p style="margin: 0; padding: 0;">Next Steps:</p><br/>';
            htmlBody += '<p style="margin: 0; padding: 0;">'+caseRecord.casePlanOfAction__c+'</p><br/>';
        
           // Standard handover message
            htmlBody += '<p style="margin: 0; padding: 0;">Case ownership has been moved to Support Queue. Awaiting Incoming TSE response.</p><br/><br/><br/>';
        
            // Reference number section
            //if (String.isNotBlank(caseRecord.Thread_Id__c)) {
                htmlBody += '<p style="margin: 0; padding: 0;">***********************************************************************************</p>';
                htmlBody += '<p style="margin: 0; padding: 0;">CASE REFERENCE NUMBER REQUIRED - DO NOT MODIFY</p>';
                htmlBody += '<p style="margin: 0; padding: 0;">' + caseRecord.Thread_Id__c + '</p>';
                htmlBody += '<p style="margin: 0; padding: 0;">***********************************************************************************</p>';
            //}
            email.setHtmlBody(htmlBody);
            
            // Set sender options
            email.setUseSignature(true);
            email.setSaveAsActivity(false);
            email.setWhatId(caseRecord.Id);
            
            // Send email
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            
            if (results.size() > 0 && results[0].isSuccess()) {
                System.debug('Handover email sent successfully to: ' + recipientEmail);
                return true;
            } else if (results.size() > 0) {
                System.debug('Email send failed: ' + results[0].getErrors()[0].getMessage());
                return false;
            }
            
        } catch (Exception e) {
            System.debug('Exception sending handover email: ' + e.getMessage());
        }
        
        return false;
    }
    
    /**
     * @description Determines if the current org is production or sandbox
     * @return Boolean true if production, false if sandbox
     */
    private static Boolean isProductionOrg() {
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        return !org.IsSandbox;
    }
}