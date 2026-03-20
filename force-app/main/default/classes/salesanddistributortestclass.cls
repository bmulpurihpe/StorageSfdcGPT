@istest
public class salesanddistributortestclass{
    static testmethod void mytestmethod()
    {
        
        account acc=new account(name='vin',CurrencyIsoCode='',type='distributor');
        insert acc;
        Account acc2 = new Account(name='test account',type='reseller',CurrencyIsoCode='', Distributor__c=acc.id,Distributor_Email__c='vin@gmail.com');
        insert acc2;
        Account acc3 = new Account(name='test account',type='reseller',CurrencyIsoCode='');
        insert acc3;
        
        Product2 prod = new Product2(Name='qlTest',IsActive=true,Productcode='SOD-PLATINUM-AF-1M');
        insert prod;
        opportunity opp = new opportunity(name='test Opp1', type='New Business', HPE_Opportunity_Id__C= 'OPE-0000001234',Sales_Area__c='NA West North',CurrencyIsoCode='USD', SBQQ__QuotePricebookId__c = Test.getStandardPricebookId(),Reseller_Account__c=acc2.id,StageName='prospect', closedate=date.today());
        insert opp;
        opportunity opp1 = new opportunity(name='test Opp', type='New Business',HPE_Opportunity_Id__C= 'OPE-0000001235', Sales_Area__c='NA West North',CurrencyIsoCode='', Reseller_Account__c=acc3.id,StageName='prospect', closedate=date.today(), SBQQ__QuotePricebookId__c = Test.getStandardPricebookId());
        insert opp1;
        
        SBQQ__Quote__c qt=new SBQQ__Quote__c( SBQQ__BillingName__c='vin',SBQQ__Type__c='Revenue', SBQQ__Status__c='Draft', Quote_Produced_or__c='Reseller', SBQQ__Opportunity2__c=opp.id);
        insert qt;
        
        SBQQ__Quote__c qt1=new SBQQ__Quote__c(SBQQ__BillingName__c='test account', SBQQ__Type__c='Revenue', SBQQ__Status__c='Draft', Quote_Produced_or__c='Reseller', SBQQ__Opportunity2__c=opp1.id);
        insert qt1;
        Sales_Order__c sal=new Sales_Order__c(Name='rac', Type__c='Beta', CurrencyIsoCode='USD', opportunity__c=opp.id);
        Insert sal;
        
    }
}