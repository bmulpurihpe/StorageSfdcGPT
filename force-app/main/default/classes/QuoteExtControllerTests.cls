@isTest
private class QuoteExtControllerTests {
    
    testMethod static void testSubmit() {
        List<Account> accList= NMBL_TestUtil.createAccount('test Account', 1, true);
        List<Opportunity> oppList = NMBL_TestUtil.createOpportunity ('test Opp',1, accList.get(0), true);
        List<SBQQ__Quote__c> quoteList = NMBL_TestUtil.createQuote ('Test Quote',1 , oppList.get(0), true);
        SBQQ__Quote__c quote = quoteList.get(0);
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        QuoteExtController.onSubmit(quote.id);
        con.onPreview();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
        List<Account> accList= NMBL_TestUtil.createAccount('test Account', 1, true);
        List<Opportunity> oppList = NMBL_TestUtil.createOpportunity ('test Opp',1, accList.get(0), true);
        List<SBQQ__Quote__c> quoteList = NMBL_TestUtil.createQuote ('Test Quote',1 , oppList.get(0), true);
        SBQQ__Quote__c quote = quoteList.get(0);
        
        /*SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        */
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }
}