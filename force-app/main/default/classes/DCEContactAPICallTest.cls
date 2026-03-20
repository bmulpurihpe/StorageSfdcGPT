@isTest
global class DCEContactAPICallTest {   
    @isTest
    static void DCEContactInfo() {
        Contact testContact = new Contact(Email = 'test@email.com', Firstname='Test', Lastname='APITest');
        insert testContact;
        Set<Id> conIds = new Set<Id>{testContact.Id};
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        DCEContactAPICall.requestDCEContactInfo(conIds);
        Test.stopTest();
        testContact = [SELECT Id, DCE_Onboarded__c, Federation_ID__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(true, testContact.DCE_Onboarded__c);
        System.assertEquals('test_federation_id', testContact.Federation_ID__c);
    }
    global class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"records": {"test@email.com": {"federationIdentifier": "test_federation_id", "isOnboarded": true}}}');
            res.setStatusCode(200);
            return res;
        }
    }
}