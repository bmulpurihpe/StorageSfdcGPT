@isTest
private class QuoteLineAfterCustomTest {
  
    testMethod static void test() {
        Account acct = new Account(Name='Test');
        insert acct;
        
        Opportunity opp = new Opportunity(Name='Test',AccountId=acct.Id,StageName='Prospecting',CloseDate=System.today());
        insert opp;
        
        Product2 ADFA = new Product2(IsActive = true, Name = 'ADFA', ProductCode = 'ADFA', Family = 'Adaptive Flash Array', Product_Type_2__c ='Adaptive Flash Array', parent_product__c= true);
        insert ADFA;
           
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c=opp.Id;
        quote.Field_Set_Scenario__c='Distributor Pricing';
        quote.RecordTypeId= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Standard Sales Quote').getRecordTypeId();

        insert quote;
        
        SBQQ__QuoteLine__c[] lines = new SBQQ__QuoteLine__c[0];
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=1,SBQQ__Product__c=adfa.Id,SBQQ__Quantity__c=1,SBQQ__ListPrice__c=10000,SBQQ__Incomplete__c=true));
        
        test.startTest();
        insert lines;
        test.stopTest();
    }
}