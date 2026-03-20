@isTest private class JIRAConnectorWebserviceCalloutCreateTest {
 
    // Tests createIssue method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void createIssueTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        JIRAConnectorWebserviceCalloutCreate.createIssue(TestFixture.baseUrl, TestFixture.systemId,
                TestFixture.objectType, TestFixture.objectId, TestFixture.projectKey, TestFixture.issueType);
        Test.stopTest();
    }
 
    // Tests buildRequest method in JIRAConnectorWebserviceCalloutCreate.
    static testMethod void buildRequestTest() {
        HttpRequest req = JIRAConnectorWebserviceCalloutCreate.buildRequest(TestFixture.baseUrl, TestFixture.username,
                TestFixture.password, TestFixture.systemId, TestFixture.objectType, TestFixture.objectId,
                TestFixture.projectKey, TestFixture.issueType);
        System.assertEquals(req.getMethod(), 'POST');
        System.assertEquals(req.getEndpoint(), 'https://nimblejira.nimblestorage.com/rest/customware/connector/1.0/1/Ops_RMA__c/1/issue/create.json');
        //System.assertEquals(req.getEndpoint(), 'http://198.54.169.47:8080/rest/customware/connector/1.0/1/Ops_RMA__c/1/issue/synchronize.json');
    }
    
    //Test CreateJIRAIssue Trigger
     static testMethod void CreateJIRAIssueTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        
        string key = 'test';
        List<Account> accList = NMBL_testUtil.createResellerAccount(key,1,true);
        List<SR_Meta_Data__c> srMetaDataList = NMBL_testUtil.createSRMetaData(key,1,true);
        List<AddressBook__c> addressBookList = NMBL_testUtil.createaddressBook(key,1,accList.get(0),true);
        List<Case> caseList = NMBL_testUtil.createCase(key,1,true);
        List<RMAv2__c> RMAv2List = NMBL_testUtil.createRMAv2(key,1,caseList.get(0), addressBookList.get(0), srMetaDataList.get(0), true);
        List<Ops_RMA__c> opsRMAList = NMBL_testUtil.createOpsRMA(key, 1, RMAv2List.get(0), true);
        opsRMAList[0].FA_required__c ='Engineering FA';
        //udpate opsRMAList;
        /*
        // insert object
        RMAv2__c RMA2 = new RMAv2__c();
        insert RMA2;
        Ops_RMA__c ops = new Ops_RMA__c();
        ops.FA_required__c ='Engineering FA';
        ops.RMAv2__c = RMA2.Id;
        insert ops;*/
    }
}