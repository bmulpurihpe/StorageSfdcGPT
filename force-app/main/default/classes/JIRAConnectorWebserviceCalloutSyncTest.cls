@isTest private class JIRAConnectorWebserviceCalloutSyncTest {
 
    // Tests synchronizeWithJIRAIssue method in JIRAConnectorWebserviceCalloutSync.
    static testMethod void synchronizeWithJIRAIssueTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(TestFixture.baseUrl, TestFixture.systemId, TestFixture.objectType, TestFixture.objectId);
        Test.stopTest();
    }
 
    // Tests buildRequest method in JIRAConnectorWebserviceCalloutSync.
    static testMethod void buildRequestTest() {
        HttpRequest req = JIRAConnectorWebserviceCalloutSync.buildRequest(TestFixture.baseUrl, TestFixture.username,
                TestFixture.password, TestFixture.systemId, TestFixture.objectType, TestFixture.objectId);
        System.assertEquals(req.getMethod(), 'PUT');
        System.assertEquals(req.getEndpoint(), 'https://nimblejira.nimblestorage.com/rest/customware/connector/1.0/1/Ops_RMA__c/1/issue/synchronize.json');
        //System.assertEquals(req.getEndpoint(), 'http://198.54.169.47:8080/rest/customware/connector/1.0/1/Ops_RMA__c/1/issue/synchronize.json');
    }
 
    // Tests syncJIRAIssue trigger.
    static testMethod void syncJIRAIssueTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        string key = 'test';
        List<Account> accList = NMBL_testUtil.createResellerAccount(key,1,true);
        List<SR_Meta_Data__c> srMetaDataList = NMBL_testUtil.createSRMetaData(key,1,true);
        List<AddressBook__c> addressBookList = NMBL_testUtil.createaddressBook(key,1,accList.get(0),true);
        List<Case> caseList = NMBL_testUtil.createCase(key,1,true);
        List<RMAv2__c> RMAv2List = NMBL_testUtil.createRMAv2(key,1,caseList.get(0), addressBookList.get(0), srMetaDataList.get(0), true);
        List<Ops_RMA__c> opsRMAList = NMBL_testUtil.createOpsRMA(key, 1, RMAv2List.get(0), true);
        
        /*
        Account acc = new Account(Name= 'test Account');
        insert acc;  
        
        SR_Meta_Data__c srMetaData = new SR_Meta_Data__c();
            
            srMetaData.srShippingProvider__c ='Nimble';
            srMetaData.srPart__c = 'CBL100';
            srMetaData.srType__c = 'Cable';
        insert srMetaData;
        
        AddressBook__c addBook = new AddressBook__c();
            
            addBook.abAccount__c =acc.id;
            //addBook.currencyIsoCode = 'USD - U.S. Dollar';
            addBook.abDescription__c = 'test';
            addBook.abCity__c = 'San Jose';
            addBook.abStateProvince__c = 'CA';
            addBook.abStreet1__c = 'River Oaks';
            addBook.abPostalCode__c= '11111';
            addBook.abCountry__c ='United States';
        
        insert addBook;
        
         Case cs = new Case(casecatCategory__c ='Backup Integration',caseSubCategory__c = 'CommVault');
         insert cs;
            
        //lookup 'Connector Test' in AddressBook__c
        
        
        // insert object
        Ops_RMA__c ops = new Ops_RMA__c();
        
        RMAv2__c rma2 = new RMAv2__c();
            rma2.rmaCaseNumber__c = cs.id;
            rma2.rmaType__c = 'Advanced replacement';
            rma2.rmaFaRequired__c = 'No FA Required';
            rma2.rmaDetailedReason__c = 'test'; 
            rma2.rmaAddressBook__c= addBook.id;
            rma2.rmaSrFlatList__c = srMetaData.id;
            rma2.rmaUplift__c = 'No: Do not uplift';
            rma2.rmaOutgoingShipmentStatus__c = 'DRAFT-10: Waiting to Order';
            rma2.rmaReturnShipmentStatus__c = 'DRAFT-10: Waiting to Order';
            rma2.rmaReason__c = 'CHASSIS: Bad controller slot';   
            rma2.rmaSelection__c = 'Flat List'; 
            rma2.rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order';
            rma2.rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order';
            rma2.rmaTransmitRmaShisWithOrder__c   = 'No SHI';
        insert rma2;
        
        ops.RMAv2__c = RMA2.Id;
        //ops.RMAv2__c = 'RMA-088794';
        insert ops;
        
        //update object
        ops.FA_required__c ='Engineering FA';
        update ops;
        */
        opsRMAList[0].FA_required__c = 'Engineering FA';
        update opsRMAList;
    }
 
    // Tests caseCommentSync trigger.
   /* static testMethod void caseCommentSyncTriggerTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        // insert case
        Case case1 = new Case();
        insert case1;
 
        // insert casecomment
        CaseComment caseComment = new CaseComment();
        caseComment.ParentId = case1.id;
        insert caseComment;    
    }*/
     
}