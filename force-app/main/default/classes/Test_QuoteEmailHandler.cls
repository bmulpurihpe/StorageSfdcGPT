@isTest(SeeAllData=false)
private class Test_QuoteEmailHandler {

    static testMethod void myUnitTest() {
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Account acc=new Account();
        acc.Name='test mansa';
        insert acc;
        Opportunity opp= new Opportunity();
        opp.Name='test mansa';
        opp.AccountId=acc.id;
        opp.HPE_Opportunity_ID__c='OPE-0123456789';
        opp.CloseDate=system.today()+3;
        opp.StageName='Qualified';
        opp.Sales_Area__c='EMEA';
        opp.SBQQ__QuotePricebookId__c = Test.getStandardPriceBookId();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<SBQQ__Quote__c> quo = new list <SBQQ__Quote__c>();
        
        SBQQ__Quote__c quoteTest=new SBQQ__Quote__c();
        quoteTest.SBQQ__Opportunity2__c=opp.ID;
        quoteTest.SBQQ__Type__c='Revenue';
        quoteTest.SBQQ__Status__c='Draft';
        quoteTest.Quote_Produced_or__c='Distributor';
        quo.add(quoteTest);
                
        SBQQ__Quote__c quoteTest1=new SBQQ__Quote__c();
        quoteTest1.SBQQ__Opportunity2__c=opp.ID;
        quoteTest1.SBQQ__Type__c='Revenue';
        quoteTest1.SBQQ__Status__c='Approved';
        quoteTest1.Quote_Produced_or__c='Distributor';
        quoteTest1.SBQQ__Primary__c=true;
        //quo.add(quoteTest1);
        insert quo;
       
        
        quoteTest.SBQQ__Status__c='Approved';
        quoteTest.SBQQ__Primary__c=true;
        update quoteTest;
        
        
        
        
        String quoteName=[Select Id,Name from SBQQ__Quote__c where ID =:quoteTest.ID].name;
        System.debug('quoteTest.name----'+quoteName);
        email.plainTextBody = 'Accepted';
        email.fromAddress ='test@test.com';
        email.subject = 'Dummy Account Name 123[Ref#'+quoteName+']';
        
        QuoteEmailHandler qeh=new QuoteEmailHandler();
        Messaging.Inboundemailresult res= qeh.handleInboundEmail(email, env);
        
        email.plainTextBody = 'Rejected';
        Messaging.Inboundemailresult res2= qeh.handleInboundEmail(email, env);
    }
}