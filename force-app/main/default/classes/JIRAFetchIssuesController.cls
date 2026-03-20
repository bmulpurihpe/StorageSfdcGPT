public class JIRAFetchIssuesController {
 
    private String issuesJson;
 
    // Constructor of this class. Note that a request will be sent to JIRA when this class is constructed.
    public JIRAFetchIssuesController(ApexPages.StandardController stdController) {
        Ops_RMA__c OpsRMA = (Ops_RMA__c)stdController.getRecord();
        this.issuesJson = getResultJson('Ops_RMA__c', OpsRMA.id);
    }
 
    // Sends request to JIRA and returns the request body which should be a valid JSON.
    private static String getResultJson(String objectType, String objectId) {
        try {
            HttpRequest req = buildRequest(JIRA.baseUrl, JIRA.username, JIRA.password, JIRA.systemId, objectType, objectId);
            HttpResponse res = JIRA.sendRequest(req);
            return res.getBody();
        } catch(System.CalloutException e) {
            System.debug(e);
            return '';
        }
    }
 
    // Constructs request needed to fetch JIRA issues from provided parameters.
    @testVisible private static HttpRequest buildRequest(String baseUrl, String username, String password,
                                     String systemId, String objectType, String objectId) {
        HttpRequest req = new HttpRequest();
        String basicAuthHeader = JIRA.authHeader(username, password);
        String endpoint = getEndpoint(baseUrl, systemId, objectType, objectId);
        req.setHeader('Authorization', basicAuthHeader);
        req.setHeader('Content-Type','application/json');
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        return req;
    }
 
    // Creates the endpoint to fetch the issue from provided parameters.
    private static String getEndpoint(String baseUrl, String systemId, String objectType, String objectId) {
        return baseUrl + '/rest/customware/connector/1.0/' + systemId + '/' + objectType + '/' + objectId + '/issue/fetch.json';
    }
 
    public String getIssuesJSON() {
        return this.issuesJson;
    }
 
    public List<JIRAIssue> getIssues() {
        return (List<JIRAIssue>)JSON.deserialize(this.issuesJson , List<JIRAIssue>.class);
    }
 
    // JIRA Issue Object.
    @testVisible class JIRAIssue {
 
        public String summary { get; }
        public String project { get; }
        public String reporter { get; }
        public String key { get;}
        public String status { get; }
        public String resolution { get; }
        public String url { get; }
        public String type { get; }
        public String assignee { get; }
        public String description { get; }
        public String priority { get; }
        public String due_date { get; }
 
    }
 
}