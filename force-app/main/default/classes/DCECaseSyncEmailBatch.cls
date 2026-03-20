/**
* Class Name: DCECaseSyncEmailBatch
* Created By: Jana Reddy
* Created Date: 10/16/2023 
*
* Description:
* This Salesforce Apex class implements a batch job that sends email notifications about DCE Case Sync records
* that have been in "Create Pending" or "Update Pending" status for more than 10 minutes.
*
* Usage:
* - Schedule this batch job to run periodically to monitor DCE Case Sync records.
* - Ensure proper access permissions for the 'DCE_Case_Sync__c' object and email sending capabilities.
*/
global class DCECaseSyncEmailBatch implements Database.Batchable<sObject> {
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime cutoffTime = System.now().addMinutes(-10);
        query = 'SELECT Id, DCE_Sync__c, CreatedDate FROM DCE_Case_Sync__c WHERE DCE_Sync__c IN (\'Create Pending\', \'Update Pending\') AND CreatedDate < ' + cutoffTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<DCE_Case_Sync__c> scope) {
        System.debug('========DCE emails===='+System.label.DCE_Notification_Emails);
        String emailAddresses = System.label.DCE_Notification_Emails;
        List<String> emailAddressesList = emailAddresses.split(',');
        if (!scope.isEmpty()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(emailAddressesList);
            email.setSubject('DCE Case Sync Record Status Notification');
            email.setPlainTextBody('There are ' + scope.size() + ' DCE Case Sync records in "Create Pending" or "Update Pending" status for more than 10 minutes.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}