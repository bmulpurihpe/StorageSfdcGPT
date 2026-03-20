@istest
public class evaltriggertestclass{
static testmethod void mytestmethod()
{
    account acc=new account(name='pri',CurrencyIsoCode='',type='distributor');
     insert acc;
        
    opportunity opp = new opportunity(name='test Opp',type='New Business',Sales_Area__c='NA West North',CurrencyIsoCode='',Reseller_Account__c=acc.id,StageName='prospect',closedate=date.today());
    insert opp;
    
    Eval__c ev=new Eval__c();
    //ev.name='test';
    ev.opportunity__c=opp.id;
    ev.Eval_Notes__c = 'Test';
    ev.Status_Review_Notes__c = 'Test';
    insert ev;
    
    ev.Eval_Notes__c = 'Test 1';
    ev.Status_Review_Notes__c = 'Test 2';
    
    update ev;
}
}