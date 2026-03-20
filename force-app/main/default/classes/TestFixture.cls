@isTest public with sharing class TestFixture {
 
    // All fields in this class are used only in unit tests.
    // No need to change, but make sure to change the unit tests respectively if you change these values.
    public static String baseUrl = 'https://nimblejira.nimblestorage.com'; //http://198.54.169.47:8080;
    public static String systemId = '1';
    public static String username = 'rma_user';
    public static String password = 'nimblerox';
 
    public static String objectType = 'Ops_RMA__c';
    public static String objectId = '1';
    public static String projectKey = 'EFA';
    public static String issueType = '10901';
    //public static String caseId = '1';
 
    public static String jiraIssueResponseBody = '[{"summary": "Project One", "project": "project one", ' +
        '"reporter": "admin@gmail.com", "key": "PO-1", "status": "open", ' +
        '"resolution": "yes", "url": "www.google.com", "type": "bug", "assignee": "admin", ' +
        '"description": "issue 1", "priority": "high", "due_date": "12-12-2015" },' +
        '{"summary": "Project Two", "project": "project two"}]';
     
}