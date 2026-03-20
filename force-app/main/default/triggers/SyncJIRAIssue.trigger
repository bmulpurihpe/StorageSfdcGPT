trigger SyncJIRAIssue on Ops_RMA__c (after update) {
/****
// Check whether current user is not JIRA agent so that we don't create an infinite loop.
    if (JIRA.currentUserIsNotJiraAgent()) {
        for (Ops_RMA__c o: Trigger.new) {  
            String objectType ='Ops_RMA__c'; //Please change this according to the object type
            String objectId = o.id;
            // Calls the actual callout to synchronize with the JIRA issue.
            if(!Test.isRunningTest()&& o.JIRA__c != null)
                JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRA.baseUrl, JIRA.systemId, objectType, objectId);
        }
    }*****/
 }