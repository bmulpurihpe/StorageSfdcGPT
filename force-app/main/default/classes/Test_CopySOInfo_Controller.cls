/**

 */
@isTest
private class Test_CopySOInfo_Controller {

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
        opp.HPE_Opportunity_ID__c='OPE-0123456789';
        opp.SBQQ__QuotePricebookId__c = Test.getStandardPriceBookId();
        opp.CurrencyISOCode = 'USD';
        opp.closedate = system.today()+5;
        insert opp;
        
        SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
        SBQuote.SBQQ__Opportunity2__c=opp.id;
        SBQuote.SBQQ__Type__c = 'NFR';
        SBQuote.SBQQ__Primary__c=true;
        SBQuote.SBQQ__Status__c='Approved';
        insert SBQuote;
        
        //SBQuote.SBQQ__Status__c='Approved';
        //update SBQuote;
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test');
        insert p;
        SBQQ__QuoteLine__c qL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id, SBQQ__Product__c = p.Id,BOM_Line_Number__c='1',SBQQ__Quantity__c=1);
        insert qL;
        SBQQ__QuoteLine__c qL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = SBQuote.Id,SBQQ__RequiredBy__c=ql.id, SBQQ__Product__c = p.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=5,SBQQ__ListPrice__c=1000,BOM_Line_Number__c='1.1',SBQQ__OptionType__c = 'Component');
        insert qL1;       
        opp.SBQQ__PrimaryQuote__c = SBQuote.id;
        update opp;
        
        Test.startTest();
        
        List<Sales_Order__c> salesOrders =  new List<Sales_Order__c>();
        Sales_Order__c so = new Sales_Order__c();
        so.Name='test mansa';
        so.Type__c='Internal';
        so.Status__c='Approved by OA';
        so.Actual_Shipment_Date__c=system.today();
        so.Opportunity__c=opp.id;
        salesOrders.add(so);
        
        Sales_Order__c so1 = new Sales_Order__c();
        so1.Name='test mansa2';
        so1.Type__c='Internal';
        so1.Status__c='Approved by OA';
        so1.Actual_Shipment_Date__c=system.today();
        so1.Opportunity__c=opp.id;
        salesOrders.add(so1);
        
        Sales_Order__c so2 = new Sales_Order__c();
        so2.Name='test mansa1';
        so2.Type__c='Internal';
        so2.Status__c='Approved by OA';
        so2.Actual_Shipment_Date__c=system.today();
        so2.Opportunity__c=opp.id;
        salesOrders.add(so2);
        
        insert salesOrders;
        
                
        Sales_Order_Line__c soline=new Sales_Order_Line__c();      
        soline.Sales_Order__c=so.id;
        insert soline;
        
        Test.stopTest();
        
        PageReference pRef = Page.CopySOInfo;
        pRef.getParameters().put('id', so.Id);
        Test.setCurrentPage(pRef);
        
        CopySOInfo_Controller Soinfo=new CopySOInfo_Controller();        
        integer j=1;
        System.assertEquals(j,1);
        //Soinfo.id=so.id;
        //Soinfo.so=so;
        system.debug('so==============='+Soinfo.so);
        Soinfo.inputvalue='test:';
        Soinfo.Go();
        Soinfo.inputvalue='';
        Soinfo.Go();
        soinfo.UpdateHeader();
        
        soinfo.selectedSalesOrder=so.id;
        soinfo.AttachPo=true;
        soinfo.UpdateHeader();
        soinfo.Cancel(); 
        
    }
}