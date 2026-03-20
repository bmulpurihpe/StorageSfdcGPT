@isTest global class MockHttpResponseFetchJIRAIssue implements HttpCalloutMock {
 
    // Mocks respond method for testing in JIRAFetchIssuesControllerTest.
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody(TestFixture.jiraIssueResponseBody);
        return res;
    }
     
}