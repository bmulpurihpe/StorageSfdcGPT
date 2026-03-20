public with sharing class JIRA {
 
    // Change values in this class according to you JIRA/Salesforce coordinates.
 
    
    public static String baseUrl =  'https://nimblejira.nimblestorage.com'; //'https://198.54.169.46';//'http://198.54.169.47:8080'; // Base URL of your JIRA instance
    public static String systemId = '1'; // Salesforce Connector System ID in JIRA
    public static String username = 'rma_user';  // JIRA username
    public static String password = 'nimblerox'; // JIRA password
    

    /*public static String baseUrl; 
    public static String systemId;
    public static String username;
    public static String password;

    public JIRA() {
        //retreive the values from the custom settings
        JIRA_Auth__c jira = JIRA_Auth__c.getInstance();
        baseUrl = jira.Base_URL__c;        // Base URL of your JIRA instance
        systemId = jira.System_Id__c;      // Salesforce Connector System ID in JIRA
        username = jira.username__c;       // JIRA username
        password = jira.password__c;       // JIRA password
    } */
 
    public static String agentProfileName = 'JIRA Agent'; // Jira agent profile name in Salesforce
 
    // Constructs Basic Http Authentication header from provided credentials
    public static String authHeader(String u, String p) {
        Blob headerValue = Blob.valueOf(u + ':' + p);
        return 'Basic ' + EncodingUtil.base64Encode(headerValue);
    }
 
    // Sends a request and returns the response
    public static HttpResponse sendRequest(HttpRequest req) {
        Http http = new Http();
        return http.send(req);
    }
 
    // Detects whether current user is not JIRA agent. By calling this you can make sure that
    // infinite loops won't happen in triggers (for instance when synchronizing an issue with JIRA)
    public static Boolean currentUserIsNotJiraAgent() {
        Boolean allow = false;
        List<Profile> jiraAgentProfile = [SELECT Id FROM Profile WHERE Name=:JIRA.agentProfileName];
        if (!jiraAgentProfile.isEmpty()) {
            String jiraProfileAgentId = String.valueOf(jiraAgentProfile[0].id);
            allow = UserInfo.getProfileId() != jiraProfileAgentId;
        }
        return allow || Test.isRunningTest();
    }
 
}