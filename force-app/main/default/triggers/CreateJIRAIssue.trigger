trigger CreateJIRAIssue on Ops_RMA__c(after insert,after update) {
   /**** // Check whether current user is not JIRA agent so that we don't create an infinite loop.
    if (JIRA.currentUserIsNotJiraAgent() && HelperClass.firstRun) {
        for (Ops_RMA__c o : Trigger.new) {
          if(o.FA_required__c=='Engineering FA' && o.JIRA__c == null){
            // Define parameters to be used in calling Apex Class
              String objectType ='Ops_RMA__c';  // Please change this according to the object type
              String objectId = o.id;
              String projectKey = 'EFA'; //Please change this according to the JIRA project key
              String issueType = '10901';     //Please change this according to the JIRA issue type ID
              HelperClass.firstRun = false;
            // Calls the actual callout to create the JIRA issue.
              if(!Test.isRunningTest())
                  JIRAConnectorWebserviceCalloutCreate.createIssue(JIRA.baseUrl, JIRA.systemId, objectType, objectId, projectKey, issueType);
          }
        }
    }****/
}