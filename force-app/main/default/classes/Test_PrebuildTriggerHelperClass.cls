/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_PrebuildTriggerHelperClass {

    static testMethod void myUnitTest() {
        Account acc=new Account();
        acc.name='test1';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.name='test1';
        opp.AccountId=acc.Id;
        opp.Type='New Business';
        opp.StageName='Qualified';
        opp.Distributor__c='test1';
        opp.CloseDate=system.today()+3;
        Opp.HPE_Opportunity_ID__c = 'OPE-0000001234';
        insert opp;
        SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
        SBQuote.SBQQ__Opportunity2__c=opp.id;
        SBQuote.SBQQ__Type__c = 'NFR';
        SBQuote.SBQQ__Primary__c=true;
        SBQuote.SBQQ__Status__c='Draft';
        insert SBQuote;
        SBQuote.SBQQ__Status__c='Approved';
        Test.startTest();
        //update SBQuote;
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test');
        insert p;
        SBQQ__QuoteLine__c qL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id, SBQQ__Product__c = p.Id,BOM_Line_Number__c='1',SBQQ__Quantity__c=1);
        insert qL;
        
        SBQQ__QuoteLine__c qL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1.1',SBQQ__OptionType__c = 'Component');
        insert qL1;       
        opp.SBQQ__PrimaryQuote__c = SBQuote.id;
        update opp;
        Test.stopTest();
        Sales_Order__c so = new Sales_Order__c();
        so.Name='test mansa';
        so.Type__c='Internal';
        so.Status__c='Approved by OA';
        so.Actual_Shipment_Date__c=system.today();
        so.Opportunity__c=opp.id;
        insert so;
        
        Sales_Order_Line__c soline=new Sales_Order_Line__c();      
        soline.Sales_Order__c=so.id;
        insert soline;
        
        PrebuildTrigger_helperclass preHelper = new PrebuildTrigger_helperclass(opp.id);
        
    }
    static testMethod void myUnitTest1() {
        Account acc=new Account();
        acc.name='test1';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.name='test1';
        opp.AccountId=acc.Id;
        opp.Type='New Business';
        opp.StageName='Qualified';
        opp.Distributor__c='test1';
        opp.CloseDate=system.today()+3;
        Opp.HPE_Opportunity_ID__c = 'OPE-0000001234';
        insert opp;
        SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
        SBQuote.SBQQ__Opportunity2__c=opp.id;
        SBQuote.SBQQ__Type__c = 'NFR';
        SBQuote.SBQQ__Primary__c=true;
        SBQuote.SBQQ__Status__c='Draft';
        insert SBQuote;
        SBQuote.SBQQ__Status__c='Approved';
        Test.startTest();
        //update SBQuote;
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test',SBQQ__ExcludeFromOpportunity__c=true);
        insert p;
        SBQQ__QuoteLine__c qL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id, SBQQ__Product__c = p.Id,BOM_Line_Number__c='1',SBQQ__Quantity__c=1);
        insert qL;
        
        SBQQ__QuoteLine__c qL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1.1',SBQQ__OptionType__c = 'Component');
        insert qL1;       
        opp.SBQQ__PrimaryQuote__c = SBQuote.id;
        update opp;
        Test.stopTest();
        Sales_Order__c so = new Sales_Order__c();
        so.Name='test mansa';
        so.Type__c='Internal';
        so.Status__c='Approved by OA';
        so.Actual_Shipment_Date__c=system.today();
        so.Opportunity__c=opp.id;
        insert so;
        Sales_Order_Line__c soline=new Sales_Order_Line__c();      
        soline.Sales_Order__c=so.id;
        insert soline;
        
        PrebuildTrigger_helperclass preHelper = new PrebuildTrigger_helperclass(opp.id);
        
    }
}