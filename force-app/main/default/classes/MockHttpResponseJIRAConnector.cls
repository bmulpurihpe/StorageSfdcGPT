@isTest global class MockHttpResponseJIRAConnector implements HttpCalloutMock {
 
    // Mocks respond method for testing.
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        return res;
    }
     
}