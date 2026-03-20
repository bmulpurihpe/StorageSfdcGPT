@isTest private class JIRATest {
 
    // Tests authHeader method in JIRA class.
    static testMethod void authHeaderTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        String authHeader = JIRA.authHeader(TestFixture.username, TestFixture.password);
       // System.assertEquals(authHeader, 'Basic eW91ckpJUkF1c2VybmFtZTp5b3VySklSQXBhc3N3b3Jk');
    }
     
    // Tests sendRequest method in JIRA class.
    static testMethod void sendRequestTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        HttpRequest req = new HttpRequest();
        HttpResponse res = JIRA.sendRequest(req);
        System.assertEquals(res.getStatusCode(), 200);
    }
 
    // Tests currentUserIsNotJiraAgent method in JIRA class.
    static testMethod void currentUserIsNotJiraAgentTest() {
        System.assert(JIRA.currentUserIsNotJiraAgent());
    }
 
}