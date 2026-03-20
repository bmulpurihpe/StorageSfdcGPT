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
private class Test_PrebuildTriggerClas {

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
        Opp.HPE_Opportunity_ID__c = 'OPE-0000001234';
        opp.CloseDate=system.today()+3;
        insert opp;
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='AFS-UPGRADE');
        insert p;
        Prebuild__c pre=new Prebuild__c(Opportunity__c=opp.id);
        pre.Prebuild_Status__c='Rejected';
        insert pre;
        SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
        SBQuote.SBQQ__Opportunity2__c=pre.Opportunity__c;
        SBQuote.SBQQ__Type__c = 'NFR';
        SBQuote.SBQQ__Primary__c=true;
        SBQuote.SBQQ__Status__c='Draft';
        insert SBQuote;
        SBQuote.SBQQ__Status__c='Approved';
        update SBQuote;
        SBQQ__QuoteLine__c qL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id, SBQQ__Product__c = p.Id,BOM_Line_Number__c='1',SBQQ__Quantity__c=1);
        insert qL;
        SBQQ__QuoteLine__c qL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1.1',SBQQ__OptionType__c = 'Component');
        insert qL1;
 /*       SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=SBQuote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 1;
        insert line;
        list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c cline14 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=SBQuote.Id,SBQQ__Product__c=p.Id);
        cline14.SBQQ__RequiredBy__c=line.Id;
        cline14.SBQQ__Bundled__c=true;
        cline14.SBQQ__BundledQuantity__c=5;
        cline14.SBQQ__ListPrice__c = 1000;
        cline14.BOM_Line_Number__c='1.1';
        cline14.SBQQ__OptionType__c = 'Component';
        cline14.SBQQ__Quantity__c = 7;
        listQl.add(cline14);//       
        insert listQl;  */
        pre.Prebuild_Status__c='Approved';
        update pre;
        Test.startTest();
        PrebuildTriggerClass.PrebuildTriggerClassMethod(pre.id);
        PrebuildTriggerClass.calculateWorkingDays(system.today() ,15);
        Test.stoptest();
        PrebuildTriggerClass.PrebuildTriggerClassMethod2(pre.id); 
        
    }
    static testMethod void myUnitTest1() {
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='AFA');
        insert p;
        Account acc1=new Account();
        acc1.name='test';
        insert acc1;
        Opportunity opp1 = new Opportunity();
        opp1.name='test';
        opp1.AccountId=acc1.Id;
        opp1.Type='New Business';
        opp1.StageName='Qualified';
        opp1.Distributor__c='test2';
        opp1.CloseDate=system.today()+3;
        Opp1.HPE_Opportunity_ID__c = 'OPE-0000001234';
        insert opp1;
        Prebuild__c pre1=new Prebuild__c(Opportunity__c=opp1.id);
        pre1.Prebuild_Status__c='Rejected';
        insert pre1;
        SBQQ__Quote__c SBQuote1 = new SBQQ__Quote__c();
        SBQuote1.SBQQ__Opportunity2__c=pre1.Opportunity__c;
        SBQuote1.SBQQ__Type__c = 'NFR';
        SBQuote1.SBQQ__Primary__c=true;
        SBQuote1.SBQQ__ShippingCity__c='test';
        SBQuote1.SBQQ__ShippingStreet__c='test';
        SBQuote1.SBQQ__ShippingName__c='test';
        SBQuote1.SBQQ__ShippingCountry__c='test';
        SBQuote1.SBQQ__ShippingState__c='test';
        SBQuote1.SBQQ__ShippingPostalCode__c='121001';
        SBQuote1.SBQQ__BillingStreet__c='test';
        SBQuote1.SBQQ__BillingCity__c='test';
        SBQuote1.SBQQ__BillingName__c='test';
        SBQuote1.SBQQ__BillingCountry__c='test';
        SBQuote1.SBQQ__BillingState__c='test';
        SBQuote1.SBQQ__BillingPostalCode__c='121001';
        SBQuote1.Sold_To_Street__c='test';
        SBQuote1.Sold_To_City__c='test';
        SBQuote1.Sold_To_Name__c='test';
        SBQuote1.Sold_To_Country__c='test';
        SBQuote1.Sold_To_State__c='test';
        SBQuote1.Sold_To_Postal_Code__c='121001';
        
        SBQuote1.SBQQ__Status__c='Draft';
        insert SBQuote1;
        SBQuote1.SBQQ__Status__c='Approved';
        update SBQuote1;
        SBQQ__QuoteLine__c qL11 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote1.Id, SBQQ__Product__c = p.Id,BOM_Line_Number__c='1',SBQQ__Quantity__c=1);
        insert qL11;
        SBQQ__QuoteLine__c qL111 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote1.Id,SBQQ__RequiredBy__c=ql11.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1.1',SBQQ__OptionType__c = 'Component');
        insert qL111;
        pre1.Prebuild_Status__c='Approved';
        update pre1;
        Test.startTest();
        PrebuildTriggerClass.PrebuildTriggerClassMethod(pre1.id);
        Test.stopTest();
    }
 /*   static testMethod void myUnitTest2() {
        Account accDist=new Account();
        accDist.name='test1';
        accDist.Type='Distributor';
        insert accDist;
        Account acc=new Account();
        acc.name='test1';
        acc.Type = 'Distributor';
        acc.Distributor__c = accDist.id;
        acc.shippingcity = 'test';
        acc.shippingstreet = 'test';
        acc.shippingcountry = 'test';
        acc.shippingstate = 'test';
        acc.shippingpostalcode = '123456';
        
        insert acc;
        Opportunity opp = new Opportunity();
        opp.name='test1';
        opp.AccountId=acc.Id;
        opp.Type='New Business';
        opp.StageName='Qualified';
        opp.Distributor__c='Prebuild';
        opp.CloseDate=system.today()+3;
        opp.Reseller_Account__c = acc.id;
        insert opp;
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='SLA');
        insert p;
        Prebuild__c pre=new Prebuild__c(Opportunity__c=opp.id);
        pre.Prebuild_Status__c='Rejected';
        insert pre;
        SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
        SBQuote.SBQQ__Opportunity2__c=pre.Opportunity__c;
        SBQuote.SBQQ__Type__c = 'NFR';
        SBQuote.SBQQ__Primary__c=true;
        SBQuote.SBQQ__Status__c='Draft';
        SBQuote.SBQQ__ShippingCity__c='';
        SBQuote.SBQQ__ShippingStreet__c='';
        SBQuote.SBQQ__ShippingName__c='';
        SBQuote.SBQQ__ShippingCountry__c='';
        SBQuote.SBQQ__ShippingState__c='';
        SBQuote.SBQQ__ShippingPostalCode__c='';
        SBQuote.SBQQ__BillingName__c='';
        SBQuote.Sold_To_Name__c='';
               
        insert SBQuote;
        SBQuote.SBQQ__Status__c='Approved';
        update SBQuote;
        SBQQ__QuoteLine__c qL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id, SBQQ__Product__c = p.Id,BOM_Line_Number__c='1',SBQQ__Quantity__c=1);
        insert qL;
        SBQQ__QuoteLine__c qL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1.1',SBQQ__OptionType__c = 'Component');
        insert qL1;
 
 //       pre.OpportunityId=opp.id;
        pre.Prebuild_Status__c='Approved';
        update pre;
        PrebuildTriggerClass.quantityCheckSalesOrderLine(pre.id);
        PrebuildTriggerClass.PrebuildTriggerClassMethod(pre.id);
        PrebuildTriggerClass.calculateWorkingDays(system.today() ,15);
        PrebuildTriggerClass.quantityCheckSalesOrderLine(pre.id);
        PrebuildTriggerClass.PrebuildTriggerClassMethod2(pre.id); 
    }  */
    
    static testMethod void myUnitTest2() {
        Account accDist=new Account();
        accDist.name='test1';
        accDist.Type='Distributor';
        insert accDist;
        Account acc=new Account();
        acc.name='test1';
        acc.Type = 'Distributor';
        //acc.Distributor__c = accDist.id;
        acc.shippingcity = 'test';
        acc.shippingstreet = 'test';
        acc.shippingcountry = 'test';
        acc.shippingstate = 'test';
        acc.shippingpostalcode = '123456';
        
        insert acc;
        Opportunity opp = new Opportunity();
        opp.name='test1';
        opp.AccountId=acc.Id;
        opp.Type='New Business';
        opp.StageName='Qualified';
        opp.Distributor__c='Prebuild';
        opp.CloseDate=system.today()+3;
        opp.Reseller_Account__c = acc.id;
        Opp.HPE_Opportunity_ID__c = 'OPE-0000001234';
        insert opp;
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='SLA');
        insert p;
        Prebuild__c pre=new Prebuild__c(Opportunity__c=opp.id);
        pre.Prebuild_Status__c='Rejected';
        insert pre;
        SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
        SBQuote.SBQQ__Opportunity2__c=pre.Opportunity__c;
        SBQuote.SBQQ__Type__c = 'NFR';
        SBQuote.SBQQ__Primary__c=true;
        SBQuote.SBQQ__Status__c='Draft';
        SBQuote.SBQQ__ShippingCity__c='';
        SBQuote.SBQQ__ShippingStreet__c='';
        SBQuote.SBQQ__ShippingName__c='';
        SBQuote.SBQQ__ShippingCountry__c='';
        SBQuote.SBQQ__ShippingState__c='';
        SBQuote.SBQQ__ShippingPostalCode__c='';
        SBQuote.SBQQ__BillingName__c='';
        SBQuote.Sold_To_Name__c='';
               
        insert SBQuote;
        SBQuote.SBQQ__Status__c='Approved';
        update SBQuote;
        SBQQ__QuoteLine__c qL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id, SBQQ__Product__c = p.Id,BOM_Line_Number__c='1',SBQQ__Quantity__c=1);
        insert qL;
        SBQQ__QuoteLine__c qL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1.1.1',SBQQ__OptionType__c = 'Component');
        SBQQ__QuoteLine__c qL2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='a.1',SBQQ__OptionType__c = 'Component');
        SBQQ__QuoteLine__c qL3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='a',SBQQ__OptionType__c = 'Component');
        insert new List<SBQQ__QuoteLine__c>{qL1, qL2, qL3};
            
        pre.Prebuild_Status__c='Approved';
        update pre;
        
 
 //       pre.OpportunityId=opp.id;
        
        Test.startTest();
        
        PrebuildTriggerClass.PrebuildTriggerClassMethod(pre.id);
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTest3() {
        
        Account accDist=new Account();
        accDist.name='Distributor Acc';
        accDist.Type='Distributor';
        insert accDist;
        Account acc=new Account();
        acc.name='test1';
        acc.Type = 'Distributor';
        acc.Distributor__c = accDist.Id;
        insert acc;
        Opportunity opp = new Opportunity();
        opp.name='test1';
        opp.AccountId=acc.Id;
        opp.Type='New Business';
        opp.StageName='Qualified';
        opp.Distributor__c='test1';
        Opp.HPE_Opportunity_ID__c = 'OPE-0000001234';
        opp.CloseDate=system.today()+3;
        insert opp;
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='AFS-UPGRADE');
        insert p;
        Prebuild__c pre=new Prebuild__c(Opportunity__c=opp.id);
        pre.Prebuild_Status__c='Rejected';
        insert pre;
        SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
        SBQuote.SBQQ__Opportunity2__c=pre.Opportunity__c;
        SBQuote.SBQQ__Type__c = 'NFR';
        SBQuote.SBQQ__Primary__c=true;
        SBQuote.SBQQ__Status__c='Draft';
        insert SBQuote;
        SBQuote.SBQQ__Status__c='Approved';
        update SBQuote;
        SBQQ__QuoteLine__c qL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id, SBQQ__Product__c = p.Id,BOM_Line_Number__c='1',SBQQ__Quantity__c=1);
        insert qL;
        SBQQ__QuoteLine__c qL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1.1',SBQQ__OptionType__c = 'Component');
        SBQQ__QuoteLine__c qL2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='a.1',SBQQ__OptionType__c = 'Component');
        insert new List<SBQQ__QuoteLine__c>{qL1, qL2};
 
        pre.Prebuild_Status__c='Approved';
        update pre;
        Test.startTest();
        Sales_Order__c so = new Sales_Order__c();
        so.Name='test mansa';
        so.Type__c='Internal';
        so.Status__c='Approved by OA';
        so.Actual_Shipment_Date__c=system.today();
        so.Opportunity__c=opp.id;
        insert so;
        
        Sales_Order_Line__c soline=new Sales_Order_Line__c();      
        soline.Sales_Order__c=so.id;
        soline.BOM_Line_Number__c = '1.1.1';
        insert soline;
        PrebuildTriggerClass.quantityCheckSalesOrderLine(pre.id);
        Test.stoptest();
        PrebuildTriggerClass.PrebuildTriggerClassMethod2(pre.id); 
        
    }
    
    
    static testMethod void myUnitTest4() {
        Account accDist=new Account();
        accDist.name='test1';
        accDist.Type='Distributor';
        insert accDist;
        Account acc=new Account();
        acc.name='test1';
        acc.Type = 'Distributor';
        acc.Distributor__c = accDist.id;
        acc.shippingcity = 'test';
        acc.shippingstreet = 'test';
        acc.shippingcountry = 'test';
        acc.shippingstate = 'test';
        acc.shippingpostalcode = '123456';
        
        insert acc;
        Opportunity opp = new Opportunity();
        opp.name='test1';
        opp.AccountId=acc.Id;
        opp.Type='New Business';
        opp.StageName='Qualified';
        opp.Distributor__c='Prebuild';
        opp.CloseDate=system.today()+3;
        opp.Reseller_Account__c = acc.id;
        Opp.HPE_Opportunity_ID__c = 'OPE-0000001234';
        insert opp;
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='SLA');
        insert p;
        Prebuild__c pre=new Prebuild__c(Opportunity__c=opp.id);
        pre.Prebuild_Status__c='Rejected';
        insert pre;
        SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
        SBQuote.SBQQ__Opportunity2__c=pre.Opportunity__c;
        SBQuote.SBQQ__Type__c = 'NFR';
        SBQuote.SBQQ__Primary__c=true;
        SBQuote.SBQQ__Status__c='Draft';
        SBQuote.SBQQ__ShippingCity__c='';
        SBQuote.SBQQ__ShippingStreet__c='';
        SBQuote.SBQQ__ShippingName__c='';
        SBQuote.SBQQ__ShippingCountry__c='';
        SBQuote.SBQQ__ShippingState__c='';
        SBQuote.SBQQ__ShippingPostalCode__c='';
        SBQuote.SBQQ__BillingName__c='';
        SBQuote.Sold_To_Name__c='';
               
        insert SBQuote;
        SBQuote.SBQQ__Status__c='Approved';
        update SBQuote;
        SBQQ__QuoteLine__c qL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id, SBQQ__Product__c = p.Id,BOM_Line_Number__c='1',SBQQ__Quantity__c=1);
        insert qL;
        SBQQ__QuoteLine__c qL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1.1',SBQQ__OptionType__c = 'Component');
        SBQQ__QuoteLine__c qL2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1',SBQQ__OptionType__c = 'Component');
        SBQQ__QuoteLine__c qL3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='a',SBQQ__OptionType__c = 'Accessory');
        insert new List<SBQQ__QuoteLine__c>{qL1, qL2, qL3};
            
        pre.Prebuild_Status__c='Approved';
        update pre;
        
        Test.startTest();
        
        PrebuildTriggerClass.PrebuildTriggerClassMethod(pre.id);
        
        Test.stopTest();
    }
    
}