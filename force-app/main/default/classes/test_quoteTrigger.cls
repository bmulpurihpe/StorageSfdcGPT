@isTest
private class test_quoteTrigger {


       private Static Account createAccount(account acc){
            system.debug('/***********************************');
            account acc1= new account();
            acc1.Name='test mansa';
            acc1.Distributor_Email__c='test@test.com';
            acc1.ShippingCity='test';
            acc1.ShippingCountry='test';
            //acc1.ShippingLatitude=12345.234;
            acc1.ShippingPostalCode='test';
            acc1.ShippingState='test';
            acc1.ShippingStreet='test';
            acc1.BillingCity='test';
            acc1.BillingCountry='test';
            //acc1.BillingLatitude=12345.223;
            acc1.BillingPostalCode='test';
            acc1.BillingState='test';
            acc1.BillingStreet='test';
            acc1.Type='Distributor';
            acc1.Distributor__c=acc.id;
            insert acc1;
            system.debug('/***********************************');
            system.debug('acc1.distributor'+acc1.Distributor__c);
            return acc1;
            }
            
            private Static Account createAccount(){
            account acc= new account();
            acc.Name='test mansa';
            acc.Distributor_Email__c='test@test.com';
            acc.ShippingCity='test';
            acc.ShippingCountry='test';
            //acc1.ShippingLatitude=12345.234;
            acc.ShippingPostalCode='test';
            acc.ShippingState='test';
            acc.ShippingStreet='test';
            acc.BillingCity='test';
            acc.BillingCountry='test';
            //acc1.BillingLatitude=12345.223;
            acc.BillingPostalCode='test';
            acc.BillingState='test';
            acc.BillingStreet='test';
            acc.Type='Distributor';
            insert acc;
            return acc;
            }
            
    
    private Static Opportunity createOpportunity(Account acc1, Contact con){        
        Opportunity oppy = new Opportunity();
        oppy.name = 'name';
        oppy.Account = acc1;
        oppy.Type = 'Existing Business';
        oppy.Sales_Area__c ='NA West North';
        oppy.First_Meeting_Date__c = System.today();
        oppy.CloseDate = System.today();
        oppy.First_Meeting_Results__c = 'Near-Team Opportunity (1-6 months)';
        oppy.First_Meeting_Set_By__c = 'Inside Sales';
        oppy.First_Meeting_Notes__c = 'Notes for inside sales';
        oppy.First_Meeting_Source__c = 'Self Prospected by Sales / Cold Call';
       // oppy.First_Meeting_Awareness_Level__c = 'Don’t Know / No Answer';
        oppy.First_Meeting_Score__c = '1 - Poor but acceptable';
        oppy.First_Meeting_Type__c = 'WebEx';
        oppy.First_Meeting_Network_Environment__c = 'ISCSI';
        oppy.StageName = '1-Prequalified';
        Oppy.Sales_Forecast_Category__c = 'Pipeline';
        Oppy.CurrencyIsoCode = 'USD';
        Oppy.Sales_Region__c= 'NA West';
        oppy.Reseller_Account__c=acc1.id; 
        Oppy.HPE_Opportunity_id__C = 'OPE-0000001234';       
        insert oppy;
        system.debug('oppyyyy'+oppy.Reseller_Account__c);
        system.debug('oppyyyy'+oppy.Reseller_Account__r.Distributor__r.name);
        return oppy;
     }
     
     private Static Contact createContact(String email, Account acc1){
        Contact con = new Contact();
        con.lastname='lastname';
        con.email=email;
        con.Account = acc1;
        insert con;
        return con;
    }
     
    static testMethod void myUnitTest() {
        Account acc = createAccount();  
       Contact con = createContact('test@gmail.com', acc);
       Opportunity opp = createOpportunity(acc,con);
        SBQQ__Quote__c quoteTest=new SBQQ__Quote__c();
        quoteTest.SBQQ__Opportunity2__c=opp.id;
        quoteTest.SBQQ__Type__c='Revenue';
        quoteTest.SBQQ__Status__c='Draft';
        quoteTest.Quote_Produced_or__c='Distributor';
        insert quoteTest;
        
        utility.runDupRecTrigger=true;
        quoteTest.SBQQ__Status__c='Approved';
        quoteTest.SBQQ__Primary__c=true;
        update quoteTest;
                
        Sales_Order__c sotest=new Sales_Order__c();
        sotest.Name='test';
        sotest.CurrencyIsoCode='AUD';
        sotest.Type__c='Revenue';
        sotest.status__c='Approved by OA';
        sotest.Opportunity__c=opp.Id;
        insert sotest;
        system.debug('&&&&&&&&&&&&&&&&&salesorder'+sotest);
        Sales_Order_Line__c soltest=new Sales_Order_Line__c();
        soltest.Sales_Order__c=sotest.Id;
        soltest.CurrencyIsoCode='AUD';
        
        
         
    }
    
    
   static testMethod void myUnitTest1() { 
   test.starttest();
   Account acc = createAccount();  
   Contact con = createContact('test@gmail.com', acc);
   Opportunity opp = createOpportunity(acc,con);
   
   account acc1= new account();
            acc1.Name='test mansa';
            acc1.Distributor_Email__c='test@test.com';
            acc1.ShippingCity='test';
            acc1.ShippingCountry='test';
            //acc1.ShippingLatitude=12345.234;
            acc1.ShippingPostalCode='test';
            acc1.ShippingState='test';
            acc1.ShippingStreet='test';
            acc1.BillingCity='test';
            acc1.BillingCountry='test';
            //acc1.BillingLatitude=12345.223;
            acc1.BillingPostalCode='test';
            acc1.BillingState='test';
            acc1.BillingStreet='test';
            acc1.Type='Distributor';
            acc1.Distributor__c=acc.id;
            insert acc1;
            system.debug('/***********************************');
            system.debug('acc1.distributor'+acc1.Distributor__c);
        
        
        
        
        SBQQ__Quote__c quoteTest1=new SBQQ__Quote__c();
        quoteTest1.SBQQ__Opportunity2__c=opp.ID;
        quoteTest1.SBQQ__Type__c='Revenue';
        quoteTest1.SBQQ__Status__c='Approved';
        quoteTest1.Quote_Produced_or__c='Distributor';
        quoteTest1.SBQQ__Primary__c=false;
        insert quoteTest1;
        test.stoptest();
        utility.runDupRecTrigger=true;
        quoteTest1.SBQQ__Status__c='Approved';
        quoteTest1.SBQQ__Primary__c=true;
        update quoteTest1;
       
   }
   
   static testMethod void myUnitTest2() {
    test.starttest();
        Account acc = createAccount();  
       Contact con = createContact('test@gmail.com', acc);
       Opportunity opp = createOpportunity(acc,con);
     SBQQ__Quote__c quoteTest2=new SBQQ__Quote__c();
        quoteTest2.SBQQ__Opportunity2__c=opp.ID;
        quoteTest2.SBQQ__Type__c='Revenue';
        quoteTest2.SBQQ__Status__c='Approved';
        quoteTest2.Quote_Produced_or__c='Distributor';
        quoteTest2.SBQQ__Primary__c=true;
        insert quoteTest2;
        utility.runDupRecTrigger=true;
        quoteTest2.SBQQ__Primary__c=false;
        update quoteTest2;
        test.stoptest();
   }
   
   static testMethod void myUnitTest3() {
    test.starttest();
        Account acc = createAccount();  
       Contact con = createContact('test@gmail.com', acc);
       Opportunity opp = createOpportunity(acc,con);
     SBQQ__Quote__c quoteTest2=new SBQQ__Quote__c();
        quoteTest2.SBQQ__Opportunity2__c=opp.ID;
        quoteTest2.SBQQ__Type__c='Revenue';
        quoteTest2.SBQQ__Status__c='Draft';
        quoteTest2.Quote_Produced_or__c='Distributor';
        quoteTest2.SBQQ__Primary__c=false;
        insert quoteTest2;
        utility.runDupRecTrigger=true;
        quoteTest2.SBQQ__Primary__c=true;
        quoteTest2.SBQQ__Status__c='Approved';
        update quoteTest2;
        test.stoptest();
   }
   
}