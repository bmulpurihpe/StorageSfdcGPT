@isTest
private class CaseCommentsRestControllerTest {
    
    @isTest
    static void testCreateCaseComment_Successful() {
        Case caseRec = new Case();
        caseRec.subject = 'Test Subject';
        caseRec.description = 'Test Description';
        caseRec.Severity__c = 'P4';
        Insert caseRec;
        Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseRec.Id LIMIT 1];
        RestRequest mockRequest = new RestRequest();
        mockRequest.requestURI = '/services/apexrest/CaseComments/';
        mockRequest.httpMethod = 'POST';
        mockRequest.addHeader('Content-Type', 'application/json');
        mockRequest.addHeader('debugId', '1234');
        RestResponse mockResponse = new RestResponse();
        CaseCommentsRestController.CaseCommentRequest validRequestBody = new CaseCommentsRestController.CaseCommentRequest();
        validRequestBody.caseNumber = c.CaseNumber;
        validRequestBody.caseId = c.Id;
        validRequestBody.caseCommentBody = 'Test comment';
        validRequestBody.createdbyFederationId = 'user123';
        validRequestBody.createdbyFirstName = 'John';
        validRequestBody.createdbyLastName = 'Doe';
        validRequestBody.createdbyEmail = 'john.doe@example.com';
        validRequestBody.createdDate = '2023-06-04';
        mockRequest.requestBody = Blob.valueOf(JSON.serialize(validRequestBody));
        RestContext.request = mockRequest;
        RestContext.response = mockResponse;
        mockResponse.statusCode = 200;
        
        Test.startTest();
        Map<String, String> responseMap = CaseCommentsRestController.createCaseComment();
        Test.stopTest();
        // Verify the response
        System.assertEquals('200', responseMap.get('httpStatusCode'), 'Unexpected HTTP status code');
        System.assertEquals('Case Comment created', responseMap.get('message'), 'Unexpected message');
    }
    @isTest
    static void testCreateCaseComment_Exception() {
        Case caseRec = new Case();
        caseRec.subject = 'Test Subject';
        caseRec.description = 'Test Description';
        caseRec.Severity__c = 'P4';
        Insert caseRec;
        Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseRec.Id LIMIT 1];
        RestRequest mockRequest = new RestRequest();
        mockRequest.requestURI = '/services/apexrest/CaseComments/';
        mockRequest.httpMethod = 'POST';
        mockRequest.addHeader('Content-Type', 'application/json');
        mockRequest.addHeader('debugId', '1234');
        RestResponse mockResponse = new RestResponse();
        CaseCommentsRestController.CaseCommentRequest exceptionRequestBody = new CaseCommentsRestController.CaseCommentRequest();
        exceptionRequestBody.caseNumber = c.CaseNumber;
        exceptionRequestBody.caseId = c.Id;
        exceptionRequestBody.caseCommentBody = '';
        exceptionRequestBody.createdbyFederationId = 'user123';
        exceptionRequestBody.createdbyFirstName = 'John';
        exceptionRequestBody.createdbyLastName = 'Doe';
        exceptionRequestBody.createdbyEmail = 'john.doe@example.com';
        exceptionRequestBody.createdDate = '2023-06-04';
        mockRequest.requestBody = Blob.valueOf(JSON.serialize(exceptionRequestBody));
        Test.setMock(HttpCalloutMock.class, new ExceptionMock());
        RestContext.request = mockRequest;
        RestContext.response = mockResponse;
        Test.startTest();
        Map<String, String> responseMap = CaseCommentsRestController.createCaseComment();
        Test.stopTest();
        System.assertEquals('400', responseMap.get('httpStatusCode'), 'Unexpected HTTP status code');
        System.assertEquals('caseCommentBody is not in the proper format', responseMap.get('message'), 'Unexpected message');
    }
    @isTest
    static void testCreateCaseComment_RequestBodyMissing() {
        Case caseRec = new Case();
        caseRec.subject = 'Test Subject';
        caseRec.description = 'Test Description';
        caseRec.Severity__c = 'P4';
        Insert caseRec;
        Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseRec.Id LIMIT 1];
        RestRequest mockRequest = new RestRequest();
        mockRequest.requestURI = '/services/apexrest/CaseComments/';
        mockRequest.httpMethod = 'POST';
        mockRequest.addHeader('Content-Type', 'application/json');
        mockRequest.addHeader('debugId', '1234');
        RestResponse mockResponse = new RestResponse();
        
        // Set an empty request body
        mockRequest.requestBody = Blob.valueOf('{}');
        
        RestContext.request = mockRequest;
        RestContext.response = mockResponse;
        Test.startTest();
        Map<String, String> responseMap = CaseCommentsRestController.createCaseComment();
        Test.stopTest();
        
        System.assertEquals('400', responseMap.get('httpStatusCode'), 'Unexpected HTTP status code');
        System.assertEquals('CaseId and CaseNumber Missing', responseMap.get('message'), 'Unexpected message');
    }
    
    @isTest
    static void testCreateCaseComment_HeaderMissing() {
        Case caseRec = new Case();
        caseRec.subject = 'Test Subject';
        caseRec.description = 'Test Description';
        caseRec.Severity__c = 'P4';
        Insert caseRec;
        
        Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseRec.Id LIMIT 1];
        RestRequest mockRequest = new RestRequest();
        mockRequest.requestURI = '/services/apexrest/CaseComments/';
        mockRequest.httpMethod = 'POST';
        mockRequest.addHeader('Content-Type', 'application/json');
        RestResponse mockResponse = new RestResponse();
        CaseCommentsRestController.CaseCommentRequest requestBody = new CaseCommentsRestController.CaseCommentRequest();
        requestBody.caseNumber = c.CaseNumber;
        requestBody.caseId = c.Id;
        requestBody.caseCommentBody = 'Test comment';
        requestBody.createdbyFederationId = 'user123';
        requestBody.createdbyFirstName = 'John';
        requestBody.createdbyLastName = 'Doe';
        requestBody.createdbyEmail = 'john.doe@example.com';
        requestBody.createdDate = '2023-06-04';
        mockRequest.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = mockRequest;
        RestContext.response = mockResponse;
        Test.startTest();
        Map<String, String> responseMap = CaseCommentsRestController.createCaseComment();
        Test.stopTest();
        System.assertEquals('400', responseMap.get('httpStatusCode'), 'Unexpected HTTP status code');
        System.assertEquals('Header Missing', responseMap.get('message'), 'Unexpected message');
    }
    
    @isTest
    static void testCreateCaseComment_caseIdBlank() {
        Case caseRec = new Case();
        caseRec.subject = 'Test Subject';
        caseRec.description = 'Test Description';
        caseRec.Severity__c = 'P4';
        Insert caseRec;
      
        Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseRec.Id LIMIT 1];
        
        RestRequest mockRequest = new RestRequest();
        mockRequest.requestURI = '/services/apexrest/CaseComments/';
        mockRequest.httpMethod = 'POST';
        mockRequest.addHeader('Content-Type', 'application/json');
        mockRequest.addHeader('debugId', '1234');
        RestResponse mockResponse = new RestResponse();
        CaseCommentsRestController.CaseCommentRequest exceptionRequestBody = new CaseCommentsRestController.CaseCommentRequest();
        exceptionRequestBody.caseNumber = c.CaseNumber;
        exceptionRequestBody.caseId = '';
        exceptionRequestBody.caseCommentBody = 'Testcomment';
        exceptionRequestBody.createdbyFederationId = 'user123';
        exceptionRequestBody.createdbyFirstName = 'John';
        exceptionRequestBody.createdbyLastName = 'Doe';
        exceptionRequestBody.createdbyEmail = 'john.doe@example.com';
        exceptionRequestBody.createdDate = '2023-06-04';
        mockRequest.requestBody = Blob.valueOf(JSON.serialize(null));
        
        RestContext.request = mockRequest;
        RestContext.response = mockResponse;
        Test.startTest();
        Map<String, String> responseMap = CaseCommentsRestController.createCaseComment();
        Test.stopTest();
        System.debug('&&&&&&&&responseMap &&&&&&&&&'+responseMap );
        System.assertEquals('400', responseMap.get('httpStatusCode'), 'Unexpected HTTP status code');
        System.assertEquals('Request is not in the proper format', responseMap.get('message'), 'Unexpected message');
    }
    
    private class ExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"message":"An error occurred"}');
            res.setStatusCode(400);
            return res;
        }
    }
}