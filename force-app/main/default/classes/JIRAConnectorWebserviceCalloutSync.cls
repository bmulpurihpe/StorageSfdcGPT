global class JIRAConnectorWebserviceCalloutSync {
 
    @future (callout=true) WebService static void synchronizeWithJIRAIssue(String baseUrl, String systemId, String objectType, String objectId) {
        try {
            HttpRequest req = buildRequest(baseUrl, JIRA.username, JIRA.password, systemId, objectType, objectId);
            JIRA.sendRequest(req);
        } catch(System.CalloutException e) {         
            System.debug(e);
        }
    }
 
    // Constructs request needed to synchronize a JIRA issue from provided parameters.
    public static HttpRequest buildRequest(String baseUrl, String username, String password,
                                           String systemId, String objectType, String objectId) {
        HttpRequest req = new HttpRequest();
        String basicAuthHeader = JIRA.authHeader(username, password);
        String endpoint = getEndpoint(baseUrl, systemId, objectType, objectId);
        req.setHeader('Authorization', basicAuthHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', '0');
        req.setEndpoint(endpoint);
        req.setMethod('PUT');
        return req;
    }
 
    // Creates the endpoint to synchronize the issue from provided parameters.
    private static String getEndpoint(String baseUrl, String systemId, String objectType, String objectId) {
        return baseUrl + '/rest/customware/connector/1.0/' + systemId + '/' + objectType +  '/' + objectId + '/issue/synchronize.json';
    }
 
}