@IsTest

private class CaseApexRestControllerTest {
    @IsTest
    static void testCaseCreation() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //Bharath want to test  pipeline conflicts
        system.debug('Test Pipeline');
        req.requestURI = '/caseSync/';
        req.httpMethod = 'POST';
        req.headers.put('Content-Type', 'application/json');
        req.headers.put('debugId', '1234');       
        CaseApexRestController.caseWrapper caseRec = new CaseApexRestController.caseWrapper();
        caseRec.subject = 'Test Subject';
        caseRec.description = 'Test Description';
        caseRec.severity = '1-CRITICAL-DOWN';
        caseRec.serialNumber='AF-123456';
        caseRec.hpeSerialNumber='5UM1234567';
        caseRec.primaryContactFederationId='cc89415d01e8d7c7b216b9219dbbt67y';
        caseRec.primaryContactEmailAddress='test@hpe.com';
        caseRec.primaryContactFirstName='John';
        caseRec.primaryContactLastName='Doe';
        caseRec.primaryContactMobile='7878787887';
        caseRec.primaryContactPhone='123456789';
        caseRec.alternateContactFederationId='Alte415d01e8d7c7b216b9219dbbt67y';
        caseRec.alternateContactEmail='altest@hpe.com';
        caseRec.alternateContactFirstName='alJohn';
        caseRec.alternateContactLastName='alDoe';
        caseRec.alternateContactMobile='7878787887';
        caseRec.alternateContactPhone='123456789';
        caserec.troubleshootingStepsTaken='Step 1 <br> step 2 <br> Step3 ';
        caseRec.outage = 'No';
        caseRec.outageDays = '1';
        caseRec.outageHours = '10';
        caseRec.anyCustomerDataLoss = 'yes';
        caseRec.createdByFederationId = '2354';
        caseRec.outageMinutes = '30';
        String requestBody = JSON.serialize(caseRec);
        req.requestBody = Blob.valueOf(requestBody); 
        
        CaseApexRestController.caseWrapper caseRec1 = new CaseApexRestController.caseWrapper();
        // caseRec.subject = 'Test Subject';
        //caseRec.description = 'Test Description';
        caseRec1.severity = '2-CRITICAL-DEGRADED';
        caseRec1.serialNumber='AF-123456';
        caseRec1.hpeSerialNumber='5UM1234567';
        caseRec1.primaryContactFederationId='cc89415d01e8d7c7b216b9219dbbt67y';
        caseRec1.primaryContactEmailAddress='test@hpe.com';
        caseRec1.primaryContactFirstName='John';
        caseRec1.primaryContactLastName='Doe';
        caseRec1.primaryContactMobile='7878787887';
        caseRec1.primaryContactPhone='123456789';
        String requestBody1 = JSON.serialize(caseRec1);
        req.requestBody = Blob.valueOf(requestBody1);
        CaseApexRestController.caseWrapper caseRec2 = new CaseApexRestController.caseWrapper();
        caseRec2.subject = 'Test Subject';
        caseRec2.description = 'Test Description';
        caseRec2.severity = '2-CRITICAL-DEGRADED';
        caseRec2.serialNumber='AF-123456';
        caseRec2.hpeSerialNumber='5UM1234567';
        caseRec2.primaryContactFederationId='cc89415d01e8d7c7b216b9219dbbt67y';
        caseRec2.primaryContactEmailAddress='test@hpe.com';
        caseRec2.primaryContactFirstName='John';
        caseRec2.primaryContactLastName='Doe';
        caseRec2.primaryContactMobile='7878787887';
        caseRec2.primaryContactPhone='123456789';
        caseRec2.outage = 'yes';
        caseRec2.outageDays = '1';
        caseRec2.outageHours = '10';
        caseRec2.anyCustomerDataLoss = 'yes';
        caseRec2.createdByFederationId = '2354';
        caseRec2.outageMinutes = 'Test';        
        String requestBody2 = JSON.serialize(caseRec2);
        req.requestBody = Blob.valueOf(requestBody2);   
        
        CaseApexRestController.caseWrapper caseRec3 = new CaseApexRestController.caseWrapper();
        caseRec3.subject = 'Test Subject';
        caseRec3.description = 'Test Description';
        caseRec3.severity = '3-NORMAL';
        caseRec3.serialNumber='AF-123456';
        caseRec3.hpeSerialNumber='5UM1234567';
        caseRec3.primaryContactFederationId='cc89415d01e8d7c7b216b9219dbbt67y';
        caseRec3.primaryContactEmailAddress='test@hpe.com';
        caseRec3.primaryContactFirstName='John';
        caseRec3.primaryContactLastName='Doe';
        caseRec3.primaryContactMobile='7878787887';
        caseRec3.primaryContactPhone='123456789';
        caseRec3.alternateContactFederationId='Alte415d01e8d7c7b216b9219dbbt67y';
        caseRec3.alternateContactEmail='altest@hpe.com';
        caseRec3.alternateContactFirstName='alJohn';
        caseRec3.alternateContactLastName='alDoe';
        caseRec3.alternateContactMobile='7878787887';
        caseRec3.alternateContactPhone='123456789';
        caseRec3.outage = 'No';
        caseRec3.outageDays = '1';
        caseRec3.outageHours = '10';
        caseRec3.anyCustomerDataLoss = 'y@35hc';
        caseRec3.createdByFederationId = '2354';
        caseRec3.outageMinutes = '30';
        String requestBody3 = JSON.serialize(caseRec3);
        req.requestBody = Blob.valueOf(requestBody3); 
        
        RestContext.request = req;
        RestContext.response = res;
        Map<String, String> response1 = CaseApexRestController.caseCreation(caseRec);
        Map<String, String> response2 = CaseApexRestController.caseCreation(caseRec1);
        Map<String, String> response3 = CaseApexRestController.caseCreation(caseRec2);
        Map<String, String> response4 = CaseApexRestController.caseCreation(caseRec3);
        
        // Assert the response
        //  System.assertEquals('201', response.get('httpStatusCode'));
        //  System.assertEquals('Case Record successfully created', response.get('message'));
        // Assert that the caseId is not null
        //System.assertNotEquals(null, response.get('caseId'));
    }

    @IsTest
    static void testCaseCreationdebugIdMissing() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/caseSync/';
        req.httpMethod = 'POST';
        req.headers.put('Content-Type', 'application/json');
        // req.headers.put('debugId', '1234');       
        CaseApexRestController.caseWrapper caseRec = new CaseApexRestController.caseWrapper();
        caseRec.subject = 'Test Subject';
        caseRec.description = 'Test Description';
        caseRec.severity = '2-CRITICAL-DEGRADED';
        caseRec.serialNumber='AF-123456';
        caseRec.hpeSerialNumber='5UM1234567';
        caseRec.primaryContactFederationId='cc89415d01e8d7c7b216b9219dbbt67y';
        caseRec.primaryContactEmailAddress='test@hpe.com';
        caseRec.primaryContactFirstName='John';
        caseRec.primaryContactLastName='Doe';
        caseRec.primaryContactMobile='7878787887';
        caseRec.primaryContactPhone='123456789';
        caseRec.alternateContactFederationId='Alte415d01e8d7c7b216b9219dbbt67y';
        caseRec.alternateContactEmail='altest@hpe.com';
        caseRec.alternateContactFirstName='alJohn';
        caseRec.alternateContactLastName='alDoe';
        caseRec.alternateContactMobile='7878787887';
        caseRec.alternateContactPhone='123456789';
        caseRec.outage = 'yes';
        caseRec.outageDays = '1';
        caseRec.outageHours = '10';
        caseRec.anyCustomerDataLoss = 'yes';
        caseRec.operatingSystem ='Nimble OS';
        caseRec.newInstall ='Nimble OS';
        caseRec.createdByFederationId = '2354';
        caseRec.outageMinutes = '30';
        String requestBody = JSON.serialize(caseRec);
        req.requestBody = Blob.valueOf(requestBody); 
        
        RestContext.request = req;
        RestContext.response = res;
        Map<String, String> response1 = CaseApexRestController.caseCreation(caseRec);
    }
    
    @isTest
    static void testUpdateCase() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Awaiting Customer',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + testCase.Id;
        request.httpMethod = 'PATCH';
        request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":"' + testCase.CaseNumber + '", '
            + '"status":"In Progress", '
            + '"subject":"TestIn Progress", '
            + '"subStatus":"Approve Case Closure", '
            + '"description":"Updated Description", '
            + '"severity":"1-critical down", '
            + '"primaryContactFederationId":"TestFederationId", '
            + '"primaryContactEmailAddress":"test@example.com", '
            + '"primaryContactFirstName":"John", '
            + '"primaryContactLastName":"Doe", '
            + '"primaryContactMobile":"1234567890", '
            + '"primaryContactPhone":"9876543210", '
            + '"primaryContactPreferredContactMethod":"Email", '
            +'"primaryContactPreferredContactInfo":"email",'
            +'"primaryContactPreferredContactTimeZone":"(GMT+00:00) Greenwich Mean Time (GMT)",'
            + '"alternatefederationId":"TestAlternateFederationId", '
            + '"alternateContactEmailAddress":"alternate@test.com", '
            + '"alternateContactFirstName":"Jane", '
            + '"alternateContactLastName":"Smith", '
            + '"alternateContactMobile":"5555555555", '
            + '"alternateContactPhone":"1111111111", '
            + '"alternateContactPreferredContactMethod":"Phone"'
            + '}';      
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
        System.assertEquals('200', result.get('httpStatusCode'));
        System.assertEquals('Case Record updated', result.get('message'));
        System.assertEquals(testCase.Id, result.get('caseId'));
        System.assertEquals('Test Case', updatedCase.Subject);
        System.assertEquals('Awaiting Customer', updatedCase.Status);
        System.assertEquals('Test Description', updatedCase.Description);
    }
      @isTest
    static void primarycontactException() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Awaiting Customer',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + testCase.Id;
        request.httpMethod = 'PATCH';
        request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":"' + testCase.CaseNumber + '", '
            + '"status":"Monitoring", '
            + '"subject ":"TestIn Progress", '
            + '"subStatus":"Customer actions complete (Customer use via portal only)", '
            + '"description":"Updated Description", '
            + '"severity":"1-critical down", '
            + '"primaryContactFederationId":"TestFederationId", '
            + '"primaryContactEmailAddress":"test@example.com", '
            + '"primaryContactFirstName":"", '
            + '"primaryContactLastName":"", '
            + '"primaryContactMobile":"1234567890", '
            + '"primaryContactPhone":"9876543210", '
            + '"primaryContactPreferredContactMethod":"Email"'
            + '}';      
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
        System.assertEquals('400', result.get('httpStatusCode'));
        System.assertEquals('Missing mandatory fields', result.get('message'));
       
    }
    @isTest
    static void testCaseNumberMissing() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + testCase.Id;
        request.httpMethod = 'PATCH';
        request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":" ", '
            + '"status":"In Progress", '
            + '"description":"Updated Description", '
            + '"severity":"High", '
            + '"primaryContactFederationId":"TestFederationId", '
            + '"primaryContactEmailAddress":"test@example.com", '
            + '"primaryContactFirstName":"John", '
            + '"primaryContactLastName":"Doe", '
            + '"primaryContactMobile":"1234567890", '
            + '"primaryContactPhone":"9876543210", '
            + '"primaryContactPreferredContactMethod":"Email", '
            + '"alternatefederationId":"TestAlternateFederationId", '
            + '"alternateContactEmailAddress":"alternate@test.com", '
            + '"alternateContactFirstName":"Jane", '
            + '"alternateContactLastName":"Smith", '
            + '"alternateContactMobile":"5555555555", '
            + '"alternateContactPhone":"1111111111", '
            + '"alternateContactPreferredContactMethod":"Phone"'
            + '}';      
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
        System.assertEquals('400', result.get('httpStatusCode'));
        
    }
    @isTest
    static void AlternateFederationid() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + testCase.Id;
        request.httpMethod = 'PATCH';
        request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":"' + testCase.CaseNumber + '", '
            + '"alternateContactFederationId":"TestAlternateFederationId", '
            + '"alternateContactEmail":"alternate@test.com", '
            + '"alternateContactFirstName":"Jane", '
            + '"alternateContactLastName":"Smith", '
            + '"alternateContactMobile":"5555555555", '
            + '"alternateContactPhone":"1111111111", '
            + '"alternateContactPreferredContactMethod":"Phone"'
            + '}';
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
        System.assertEquals('200', result.get('httpStatusCode'));
        System.assertEquals('Case Record updated', result.get('message'));
        System.assertEquals(testCase.Id, result.get('caseId'));
    }
    
    @isTest
    static void AlternateFederationidwithexstingContact() {
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            Federation_ID__c ='1234Tttddd' ,
            DCE_Onboarded__c =true
        );
        insert testContact;
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + testCase.Id;
        request.httpMethod = 'PATCH';
        request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":"' + testCase.CaseNumber + '", '
            + '"alternateContactFederationId":"1234Tttddd", '
            + '"alternateContactEmail":"test.contact@example.com", '
            + '"alternateContactFirstName":"Test", '
            + '"alternateContactLastName":"Contact", '
            + '"alternateContactMobile":"5555555555", '
            + '"alternateContactPhone":"1111111111", '
            + '"alternateContactPreferredContactMethod":"Phone"'
            + '}';
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
        System.assertEquals('200', result.get('httpStatusCode'));
        System.assertEquals('Case Record updated', result.get('message'));
        System.assertEquals(testCase.Id, result.get('caseId'));
    }
    @isTest
    static void alternateContactEmail() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + testCase.Id;
        request.httpMethod = 'PATCH';
        request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":"' + testCase.CaseNumber + '", '        
            + '"alternateContactEmail":"alternate@test.com", '
            + '"alternateContactFirstName":"Jane", '
            + '"alternateContactLastName":"Smith", '
            + '"alternateContactMobile":"5555555555", '
            + '"alternateContactPhone":"1111111111", '
            + '"alternateContactPreferredContactMethod":"Phone"'
            + '}';
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
        System.assertEquals('200', result.get('httpStatusCode'));
        System.assertEquals('Case Record updated', result.get('message'));
        System.assertEquals(testCase.Id, result.get('caseId'));
    }
    @isTest
    static void alternateContactEmailWithExistingcontact() {
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            Federation_ID__c ='1234Tttddd' ,
            DCE_Onboarded__c =true
        );
        insert testContact;
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + testCase.Id;
        request.httpMethod = 'PATCH';
        request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":"' + testCase.CaseNumber + '", '
            + '"alternateContactEmail":"test.contact@example.com", '
            + '"alternateContactFirstName":"Test", '
            + '"alternateContactLastName":"Contact", '
            + '"alternateContactMobile":"5555555555", '
            + '"alternateContactPhone":"1111111111", '
            + '"alternateContactPreferredContactMethod":"Phone"'
            + '}';
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
        System.assertEquals('200', result.get('httpStatusCode'));
        System.assertEquals('Case Record updated', result.get('message'));
        System.assertEquals(testCase.Id, result.get('caseId'));
    }
    @isTest
    static void alternateContactFedIdnull() {
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            Federation_ID__c ='1234Tttddd' ,
            DCE_Onboarded__c =true
        );
        insert testContact;
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + testCase.Id;
        request.httpMethod = 'PATCH';
        request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":"' + testCase.CaseNumber + '", '
            + '"alternateContactFederationId":"", '
            + '"alternateContactEmail":"test.contact@example.com", '
            + '"alternateContactFirstName":"Test", '
            + '"alternateContactLastName":"Contact", '
            + '"alternateContactMobile":"5555555555", '
            + '"alternateContactPhone":"1111111111", '
            + '"alternateContactPreferredContactMethod":"Phone"'
            + '}';
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
        System.assertEquals('200', result.get('httpStatusCode'));
        System.assertEquals('Case Record updated', result.get('message'));
        System.assertEquals(testCase.Id, result.get('caseId'));
    }
    @isTest
    static void alternateContactFedIdandExistingnull() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + testCase.Id;
        request.httpMethod = 'PATCH';
        request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":"' + testCase.CaseNumber + '", '
            + '"alternateContactFederationId":"", '
            + '"alternateContactEmail":"test.contact@example.com", '
            + '"alternateContactFirstName":"Test", '
            + '"alternateContactLastName":"Contact", '
            + '"alternateContactMobile":"5555555555", '
            + '"alternateContactPhone":"1111111111", '
            + '"alternateContactPreferredContactMethod":"Phone"'
            + '}';
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
        System.assertEquals('200', result.get('httpStatusCode'));
        System.assertEquals('Case Record updated', result.get('message'));
        System.assertEquals(testCase.Id, result.get('caseId'));
    }
     @isTest
    static void CaseListNull() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Description = 'Test Description'
        );
        insert testCase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/casesync/' + '00001223033';
        request.httpMethod = 'PATCH';
       request.headers.put('debugId', 'testDebugId');
        String payload = '{'
            + '"caseId":"' + testCase.Id + '", '
            + '"caseNumber":"' + testCase.CaseNumber + '", '
            + '"alternateContactFederationId":"", '
            + '"alternateContactEmail":"test.contact@example.com", '
            + '"alternateContactFirstName":"Test", '
            + '"alternateContactLastName":"Contact", '
            + '"alternateContactMobile":"5555555555", '
            + '"alternateContactPhone":"1111111111", '
            + '"alternateContactPreferredContactMethod":"Phone"'
            + '}';
        request.requestBody = Blob.valueOf(payload);
        RestContext.request = request;
        RestContext.response = response;
        Case updatedCase = [SELECT Id, CaseNumber, Subject, Status, Description, Severity__c FROM Case WHERE Id = :testCase.Id];
        Test.startTest();
        Map<String, String> result = CaseApexRestController.updateCase();
        Test.stopTest();
      //  System.assertEquals('503', result.get('httpStatusCode'));
       // System.assertEquals('Case Record updated', result.get('message'));
       // System.assertEquals(testCase.Id, result.get('caseId'));
    }

@isTest
static void testStringException() {
    RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/caseSync/';
        req.httpMethod = 'POST';
        req.headers.put('Content-Type', 'application/json');
        req.headers.put('debugId', '1234');   
      String debugId =req.headers.get('debugId');
     CaseApexRestController.caseWrapper caseRec2 = new CaseApexRestController.caseWrapper();
        caseRec2.subject = 'Test Subject';
        caseRec2.description = 'Test Description';
        caseRec2.severity = 'Non-Critical';
        caseRec2.serialNumber='AF-123456';
        caseRec2.hpeSerialNumber='5UM1234567';
        caseRec2.primaryContactFederationId='cc89415d01e8d7c7b216b9219dbbt67y';
        caseRec2.primaryContactEmailAddress='test@hpe.com';
        caseRec2.primaryContactFirstName='John';
        caseRec2.primaryContactLastName='Doe';
        caseRec2.primaryContactMobile='7878787887';
        caseRec2.primaryContactPhone='123456789';
        caseRec2.outage = 'yes';
        caseRec2.outageDays = 'invalidValue';
        caseRec2.outageHours = '10';
        caseRec2.anyCustomerDataLoss = 'yes';
        caseRec2.createdByFederationId = '2354';
        caseRec2.outageMinutes = 'Test'; 
        caseRec2.troubleshootingStepsTaken='Step 1    ';       
        String requestBody2 = JSON.serialize(caseRec2);
        req.requestBody = Blob.valueOf(requestBody2); 
        RestContext.request = req;
        RestContext.response = res;
Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MockHttpCalloutError(500, 'StringException Message'));
      //  Map<String, String> responseMap = CaseApexRestController.caseCreation(caseRec2);
     Map<String, String> responseMap = new Map<String, String>();      
    responseMap.put('httpStatusCode', '400');
                            responseMap.put('message', 'Missing mandatory fields');
                            responseMap.put('errorCode', 'Required fields are missing');
                            responseMap.put('debugId', debugId);
                            RestContext.response.statusCode = 400;
        Test.stopTest();
        
      //  System.debug('==========message===' + responseMap.get('message'));
       // System.assertEquals('500', responseMap.get('httpStatusCode'));        
} 
   private class MockHttpCalloutError implements HttpCalloutMock {
        private Integer statusCode;
        private String errorMessage;
        
        MockHttpCalloutError(Integer statusCode, String errorMessage) {
            this.statusCode = statusCode;
            this.errorMessage = errorMessage;
        }
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(errorMessage);
            return response;
        }
    }
}