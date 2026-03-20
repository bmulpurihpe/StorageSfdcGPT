@isTest
private class Test_QuoteTriggerHandler {

    @testsetup static void intialSetup(){
        
        
        Account acc=new Account();
        acc.name='Account 1';
        acc.shippingcity = 'test';
        acc.shippingstreet = 'test';
        acc.shippingcountry = 'test';
        acc.shippingstate = 'test';
        acc.shippingpostalcode = '123456';
        acc.Type = 'Distributor';
        Insert acc;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.name='Opportunity 1';
        opp.AccountId=acc.Id;
        opp.Type='New Business';
        opp.StageName='Qualified';
        opp.Distributor__c='Prebuild';
        opp.CloseDate=system.today()+3;
        opp.Reseller_Account__c = acc.id;
        opp.Type = 'New Business';
        Opp.HPE_Opportunity_ID__c = 'OPE-0000001235';
        oppList.add(opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.name='Opportunity 2';
        opp1.AccountId=acc.Id;
        opp1.Type='New Business';
        opp1.StageName='Qualified';
        opp1.Distributor__c='Prebuild';
        opp1.CloseDate=system.today()+3;
        opp1.Reseller_Account__c = acc.id;
        opp1.Type = 'New Business';
        Opp1.HPE_Opportunity_ID__c = 'OPE-0000001234';
        oppList.add(opp1);
        
        insert oppList;
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='AFA',Separate_Order_Line_Per_Unit__c=true);
        insert p;
        
       
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
        SBQuote.SBQQ__Opportunity2__c=opp.Id;
        SBQuote.Quote_Source__c='Indirect';
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
        
    }

    static testMethod void updateQuoteTest() {
        Test.startTest();
        SBQQ__Quote__c SBQuote = [Select Id, SBQQ__Opportunity2__c from SBQQ__Quote__c LIMIT 1];
        SBQuote.SBQQ__Opportunity2__c = [Select Id from Opportunity where Name = 'Opportunity 2' LIMIT 1].Id;
        
        QuoteTriggerHandler.isExecuted = false;        
        update SBQuote;
        Test.stopTest();
    }
    
    static testMethod void deleteQuoteTest() {
        
        SBQQ__Quote__c SBQuote = [Select Id, SBQQ__Opportunity2__c from SBQQ__Quote__c LIMIT 1];
        QuoteTriggerHandler.isExecuted = false;
        delete SBQuote;
        
        Test.startTest();
        QuoteTriggerHandler.isExecuted = false; 
        undelete SBQuote;
        Test.stopTest();
        
    }
}