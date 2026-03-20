@isTest
private class DCECaseFileSyncRestControllerTest {
    @isTest
    static void testCreateCaseFile() {
        Case caseRec = new Case();
        caseRec.Subject = 'Test Subject';
        caseRec.Description = 'Test Description';
        caseRec.Severity__c = 'P4';
        Insert caseRec;
        ContentVersion testContentVersion = new ContentVersion();
        testContentVersion.Title = 'Test Content';
        testContentVersion.PathOnClient = 'test.txt';
        testContentVersion.VersionData = Blob.valueOf('Test content');
        insert testContentVersion;
        Map<String, String> payload = new Map<String, string>();
        payload.put('dceCaseId', caseRec.Id);
        payload.put('versionId', testContentVersion.Id);        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dcefilesync/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('debugId', '1234');
        req.requestBody = Blob.valueOf(JSON.serialize(payload));        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Map<String, String> responseMap = DCECaseFileSyncRestController.createCaseFile(caseRec.Id, testContentVersion.Id);
        Test.stopTest();
        System.assertEquals('200', responseMap.get('httpStatusCode'), 'Unexpected HTTP status code');
        System.assertEquals('Linked Document to corresponding case', responseMap.get('message'));
    }
    @isTest
    static void testCreateCaseFilepayloadContentversionblank() {
        Case caseRec = new Case();
        caseRec.Subject = 'Test Subject';
        caseRec.Description = 'Test Description';
        caseRec.Severity__c = 'P4';
        Insert caseRec;
        ContentVersion testContentVersion = new ContentVersion();
        testContentVersion.Title = 'Test Content';
        testContentVersion.PathOnClient = 'test.txt';
        testContentVersion.VersionData = Blob.valueOf('Test content');
        insert testContentVersion;
        Map<String, String> payload = new Map<String, string>();
        payload.put('dceCaseId', caseRec.Id);
       // payload.put('versionId', testContentVersion.Id);
        string tContentVersion;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dcefilesync/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('debugId', '1234');
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Map<String, String> responseMap = DCECaseFileSyncRestController.createCaseFile(caseRec.Id, tContentVersion);
        Test.stopTest();
        System.debug('++++++++++responseMap ++++++++'+responseMap );
        System.assertEquals('400', responseMap.get('httpStatusCode'), 'Unexpected HTTP status code');
        System.assertEquals('nimbleCaseId/versionId is either Null or Empty', responseMap.get('ErrorMessage'));
    }
    @isTest
    static void testCreateCaseFilepayloadblank() {
        Case caseRec = new Case();
        caseRec.Subject = 'Test Subject';
        caseRec.Description = 'Test Description';
        caseRec.Severity__c = 'P4';
        Insert caseRec;
        ContentVersion testContentVersion = new ContentVersion();
        testContentVersion.Title = 'Test Content';
        testContentVersion.PathOnClient = 'test.txt';
        testContentVersion.VersionData = Blob.valueOf('Test content');
        insert testContentVersion;
        ContentDocumentLink testContentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = caseRec.Id
        );
        insert testContentLink;
        Map<String, String> payload = new Map<String, string>();
          payload.put('dceCaseId', caseRec.Id);
          payload.put('versionId', testContentVersion.Id);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dcefilesync/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('debugId', '1234');
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;
        RestContext.response = res;
        String originalId = caseRec.Id;
        String modifiedId = originalId.substring(1);
        Test.startTest();
        Map<String, String> responseMap = DCECaseFileSyncRestController.createCaseFile(modifiedId, testContentVersion.id);
        Test.stopTest();
         System.debug('++++++++++responseMap ++++++++'+responseMap );
        System.assertEquals('400', responseMap.get('httpStatusCode'), 'Unexpected HTTP status code');
        System.assertEquals('nimbleCaseId could not be found / nimbleCaseId is Invalid', responseMap.get('ErrorMessage'));
    }
    @isTest
    static void testCreateCaseComment_HeaderMissing() {
        Case caseRec = new Case();
        caseRec.Subject = 'Test Subject';
        caseRec.Description = 'Test Description';
        caseRec.Severity__c = 'P4';
        Insert caseRec;
        ContentVersion testContentVersion = new ContentVersion();
        testContentVersion.Title = 'Test Content';
        testContentVersion.PathOnClient = 'test.txt';
        testContentVersion.VersionData = Blob.valueOf('Test content');
        insert testContentVersion;
        Map<String, String> payload = new Map<String, string>();
        payload.put('dceCaseId', caseRec.Id);
        payload.put('versionId', testContentVersion.Id);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/dcefilesync/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = req;
        RestContext.response = res;
        String originalId = caseRec.Id;
        String modifiedId = originalId.substring(1);
        Test.startTest();
        Map<String, String> responseMap = DCECaseFileSyncRestController.createCaseFile(modifiedId, testContentVersion.id);
        Test.stopTest();
        System.assertEquals('400', responseMap.get('httpStatusCode'), 'Unexpected HTTP status code');
        System.assertEquals('Header Missing', responseMap.get('message'));
    }
}