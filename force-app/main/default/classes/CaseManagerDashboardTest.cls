@isTest
public without sharing class CaseManagerDashboardTest {
    @TestSetup
    public static void setupTestData(){
        //Setup case data
        Account testAcct = new Account(
            Name = 'Test Account for Testing',
            Sales_Segment_Type__c = 'Commercial',
            Market_Segment__c = 'Commercial',
            Type = 'Customer'
        );
        insert testAcct;  
        Contact testContact = new Contact(
            AccountId = testAcct.id,
            FirstName = 'Test',
            LastName = 'Contact'
        );
        insert testContact;
        
        
        Product2 testProd = new Product2(
            Name = 'AF1234',
            ProductCode = 'AF1234'
        );
        insert testProd;
        Asset testAsset = new Asset(
            Name = 'AF-234567',
            AccountId = testAcct.id,
            ContactId = testContact.id,
            Product2Id = testProd.id,
            Array_Controller__c = 'AF1000',
            Array_Networking__c = '2P',
            FC_Testing_Done__c = 10,
            Dynamic_SKU__c = 'AF1000-2P--10'

        );
        insert testAsset;
        Test.startTest();
        Case testCase = new Case(
            AccountId = testAcct.id,
            ContactId = testContact.id,
            AssetId = testAsset.id,
            Status = 'New',
            caseCatImpactToCustomer__c = 'No Impact - Initial Installation',
            Type = 'Production',
            Estimated_Effort__c = '30 minutes',
            Subject = 'Test Subject',
            Description = 'Test Description',
            Technology_Area__c = 'Sizing (for Performance)',
            Sub_Technology_Area__c = 'CPU / Controller'
        );
        insert testCase;
        


        //Setup Escalations
        caseEscalationTypeDefinition__c enggEscTypeDef = new caseEscalationTypeDefinition__c(
            Name = 'Engineering Escalation',
            caseEscalationTypeDefinitionGroup__c = 'Engineering Escalation'
        );
        insert enggEscTypeDef;
        caseEscalation__c caseEsc = new caseEscalation__c(
            caseEscalationCase__c = testCase.id,
            caseEscalationTypeDefinition__c = enggEscTypeDef.id,
            caseEscalationJIRAId__c = 'ESC-10000'
        );
        insert caseEsc;

        //Setup Management Escalations
        Management_Escalation__c testMgmtEsc = new Management_Escalation__c(
            Case__c = testCase.id,
            Severity__c = 'Red',
            Region__c = 'APAC',
            Customer_Temp__c = 'Test',
            Executive_Visibility__c = 'No',
            Problem_Statement__c = 'Test'
        );
        insert testMgmtEsc;

        //Setup Bugs
        Bug__c testBug = new Bug__c(
            Case__c = testCase.id,
            BugId__c = 'CONS-11111'
        );
        insert testBug;
        
        ESCA_Consult__c esca = new ESCA_Consult__c(
             Case__c = testCase.Id,
             OTC_Number__c = 'OTC-12345'
        );

        //Setup Transfers
        GSEM__c testTransfer = new GSEM__c(
            GSEM__c = testCase.id,
            Company_Name__c = 'Test Company',
            Contact_Last_Name__c = 'Test',
            Cust_ticket__c = 'T-54321',
            Problem_Title__c = 'Some title',
            System_Serial_No__c = '6.1.200.0'
        );
        insert testTransfer;
        test.stopTest();
    }

    static testMethod void getEscalationsTest() {
        Case testCase = [select id, casenumber from Case where status = 'New' limit 1];
        Test.startTest();
        List<CaseManagerDashboard.CaseEscalations> escs = CaseManagerDashboard.getEscalations(testCase.id);
        Boolean mgmtEscCreated = false;
        for(CaseManagerDashboard.CaseEscalations caseEsc : escs) {
            if(caseEsc.Name.contains('ME-')) {
                mgmtEscCreated = true;
            }
        }
        Test.stopTest();                    
        System.assert(escs.size() > 1, 'No Escalations found for Case');
        System.assert(mgmtEscCreated = true, 'No Escalations found for Case');
    }
    static testMethod void getBugsConsultsTest() {
        Case testCase = [select id, casenumber from Case where status = 'New' limit 1];
        Test.startTest();
        List<CaseManagerDashboard.CaseConsults> bugs = CaseManagerDashboard.getConsultsBugs(testCase.id);
        Boolean consultsCreated = false;
        Boolean escaconsultsCreated = false;
        for(CaseManagerDashboard.CaseConsults caseconsult : bugs) {
            if(caseconsult.Name.contains('CONS')) {
                consultsCreated = true;
            }
            if(caseconsult.Name.contains('OTC')) {
                escaconsultsCreated = true;
            }
            
        }
        Test.stopTest();                    
        System.assert(bugs.size() > 0, 'No Bugs/Consults found for Case');
        System.assert(consultsCreated = true, 'No Escalations found for Case');
    }
    static testMethod void getTransfersTest() {
        Case testCase = [select id, casenumber from Case where status = 'New' limit 1];
        Test.startTest();
        List<GSEM__c> transfers = CaseManagerDashboard.getTransfers(testCase.id);
        Test.stopTest();                   
        System.assert(transfers.size() > 0, 'No Transfers found for Case');
    }
}