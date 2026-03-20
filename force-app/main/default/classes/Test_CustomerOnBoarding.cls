@isTest
private class Test_CustomerOnBoarding {

    static testMethod void myUnitTest() {
        
        Account Ac = new Account (Name='Mansa Test',Description='Test Product Entry 1');
        insert Ac;
        
        Contact Con=new Contact(Lastname='test',accountid=ac.id);
        insert con;
        date dt=system.today();
        
        Contact con1=new Contact(Lastname='test1', accountid=ac.id);
        insert con1;
        
        Opportunity opp=new Opportunity(name='test',type='New Business',AccountId=ac.id, Sales_Region__c='test', StageName='test',CloseDate=dt);
        insert opp;
        
        Opportunitycontactrole oprole=new opportunitycontactrole(contactid=con1.id,opportunityid=opp.id);
        insert oprole;
        oprole.role='business user';
        update oprole;
        
        ApexPages.currentPage().getParameters().put('oppid',opp.id);
        
        CustomerOnBoarding conboard=new CustomerOnBoarding();
        conboard.ExistContact();
        conboard.NewContact();
        conboard.getNextButtonDisabled();
        conboard.getPageNumber();
        conboard.getPageSize();
        conboard.getTotalPageNumber();
        conboard.getwrapperlst();
        conboard.nextBtnClick();
        conboard.saverecord();
        conboard.removerecord();
        conboard.getpagesize1();
        conboard.refreshpagesize();
        conboard.previousBtnClick();
        conboard.getoprolelist();
        
        
    }
}