@isTest
/* Purpose: Test class  for CaseNewSelectionExtController 
*/
public class CaseNewSelectionExtControllerTest 
{
    static testMethod void validateRedirect()
    {
        Account a = new Account(Name = 'TestAccount');
        insert a;
        
        
        Case c = new Case(Account = a);
        insert c;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseNewSelectionExtController cns = new CaseNewSelectionExtController(sc);
        Test.setCurrentPageReference(new PageReference('Page.CaseNewSelectionPage')); 
        /* Test case 1: To invoke NCV case page*/
        
        System.currentPageReference().getParameters().put('RecordType', '01234000000BnF9');
        
        PageReference pg = cns.Redirect();
        system.debug('==== '+pg.getUrl());
        //System.assertEquals('/500/e?def_account_id=&def_asset_id=&def_contact_id=&ent=Case&nooverride=0&RecordType=01234000000BnF9&retURL=%2F500',pg.getUrl());
        System.assertEquals('/apex/caseNewOrEditPage?acctId=&asstId=&contId=&RecordType=01234000000BnF9&retURL=%2F500&sfdc.override=1',pg.getUrl());
        
        /* Test case 2: To invoke Array case page*/
        System.currentPageReference().getParameters().put('RecordType', '01234000000BnF4');
        PageReference pg1 = cns.Redirect();
        //System.assertEquals('/apex/caseNewOrEditPage?ent=Case&RecordType=01234000000BnF4&retURL=%2F500%2Fo&sfdc.override=1',pg1.getUrl());
        System.assertEquals('/apex/caseNewOrEditPage?accountId=&acctId=&assetId=&asstId=&contId=&RecordType=01234000000BnF4&retURL=%2F500&sfdc.override=1',pg1.getUrl());
        
        
        /* Test case 3: To invoke InfoSight Portal case page*/
        System.currentPageReference().getParameters().put('RecordType', Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId());
        PageReference pg2 = cns.Redirect();
        System.assertEquals('/apex/infoSightCaseNewOrEditPage?acctId=&asstId=&contId=&RecordType='+Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId()+'&retURL=%2F500&sfdc.override=1',pg2.getUrl());
        
        /* Test case 4: To invoke SSaaS case page*/
        System.currentPageReference().getParameters().put('RecordType', Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('SSaaS').getRecordTypeId());
        PageReference pg4 = cns.Redirect();
        System.assertEquals('/apex/caseNewOrEditPage?accountId=&acctId=&assetId=&asstId=&contId=&RecordType='+Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('SSaaS').getRecordTypeId()+'&retURL=%2F500&sfdc.override=1',pg4.getUrl());
        
    }           
    
    static testMethod void validateRedirect1()
    {
        //Account a = [Select Name from Account where ID = '00180000016Ymsb'];
        Account a = new Account(Name = 'TestAccount');
        insert a;
        Case c = new Case(Account = a);
        insert c;
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseNewSelectionExtController cns = new CaseNewSelectionExtController(sc);
        Test.setCurrentPageReference(new PageReference('Page.CaseNewSelectionPage'));
        PageReference pg1 = cns.Redirect();
    }
    static testMethod void validateRedirect2(){
        Account acc = new Account();
        acc.Name = 'AccountTest';
        insert acc;
        String aid= acc.id;
        system.debug('Account id '+ aid);
        system.debug('Accound id Size '+aid.length());
        Account getAccount = [Select Name from Account where ID=:aid];
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test1';
        con.CurrencyIsoCode = 'USD';
        insert con;
        Case c = new Case(Account = acc);
        insert c;
        
        /*CaseNewSelectionExtController newcase = new CaseNewSelectionExtController();
        newcase.acctname = acc.Name;
        PageReference ref = CaseNewSelectionExtController.Redirect();*/
        test.startTest();
            

        /*CaseNewSelectionExtController newcase = new CaseNewSelectionExtController();
        newcase.Redirect();*/
        test.stopTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseNewSelectionExtController cns = new CaseNewSelectionExtController(sc);
        Test.setCurrentPageReference(new PageReference('Page.CaseNewSelectionPage'));
        PageReference pg1 = cns.Redirect();     
        
    }
    static testMethod void validateRedirect3(){
        Account a = new Account(Name = 'TestAccount');
        insert a;
        
        
        Case c = new Case(Account = a);
        insert c;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseNewSelectionExtController cns = new CaseNewSelectionExtController(sc);
        Test.setCurrentPageReference(new PageReference('Page.CaseNewSelectionPage')); 
        
        System.currentPageReference().getParameters().put('RecordType', Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('SSaaS').getRecordTypeId());
        PageReference pg4 = cns.Redirect();
        System.assertEquals('/apex/caseNewOrEditPage?accountId=&acctId=&assetId=&asstId=&contId=&RecordType='+Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('SSaaS').getRecordTypeId()+'&retURL=%2F500&sfdc.override=1',pg4.getUrl());

         System.currentPageReference().getParameters().put('RecordType', Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId());
        PageReference pg2 = cns.Redirect();
        System.assertEquals('/apex/infoSightCaseNewOrEditPage?acctId=&asstId=&contId=&RecordType='+Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId()+'&retURL=%2F500&sfdc.override=1',pg2.getUrl());

    }
    static testMethod void validateRedirect4()
    {
        //Account a = [Select Name from Account where ID = '00180000016Ymsb'];
        Account a = new Account(Name = 'Test23');
        insert a;
        Case c = new Case(Account = a);
        insert c;
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseNewSelectionExtController cns = new CaseNewSelectionExtController(sc);
        Test.setCurrentPageReference(new PageReference('Page.CaseNewSelectionPage'));
        PageReference pg1 = cns.Redirect();
    }
    static testMethod void validateRedirect5(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Account getAccount = [Select Name from Account where ID=:acc.Id];
        system.debug('Account ids '+acc.Id);
        Contact con = new Contact();
        con.LastName = 'Test';
        Insert Con;
        Contact getContact = [Select Name from Contact where Id = :con.Id];
         Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                             ProductCode='SSD123',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage ArrayS',
                                             Controller_Code__c='CS2001',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct2;
        Asset asst1 = new Asset(Name = 'TestAsset1', AccountId = acc.Id, Product2Id = testProduct2.id,HPE_Serial_Number__c = 'HPE123457',
                                Array_Controller__c = 'CS3001',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F');
        
        insert asst1;
        Asset getAsset = [Select Name from Asset where Id = :asst1.Id];
        test.startTest();
        Case c = new Case(Account = acc);
        insert c;
        // LJW startTest was orginally here on 10.14.2024
        // test.startTest(); 
        //CaseNewSelectionExtController page = new CaseNewSelectionExtController();

        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseNewSelectionExtController cns = new CaseNewSelectionExtController(sc);
        Test.setCurrentPageReference(new PageReference('Page.CaseNewSelectionPage'));
        PageReference pg1 = cns.Redirect();     
        test.stopTest();
    }    
    static testMethod void validateRedirect6(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        system.debug('ID '+acc.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        CaseNewSelectionExtController cns = new CaseNewSelectionExtController(sc);
        Test.setCurrentPageReference(new PageReference('Page.CaseNewSelectionPage'));
        PageReference pg1 = cns.Redirect();     
        
    }
    static testMethod void validateRedirect7(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact con = new Contact();
        con.LastName = 'name';
        insert con;
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        CaseNewSelectionExtController cns = new CaseNewSelectionExtController(sc);
        Test.setCurrentPageReference(new PageReference('Page.CaseNewSelectionPage'));
        PageReference pg1 = cns.Redirect();
        
    }
    static testMethod void testMethod1() 
    {
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        CaseNewSelectionExtController testAccPlan = new CaseNewSelectionExtController(sc);
        
        PageReference pageRef = testAccPlan.Redirect(); // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(testAccount.Id));
        Test.setCurrentPage(pageRef);
        
        //testAccPlan.save(); call all your function here
        testAccPlan.Redirect();
        Test.StopTest();
    }
    
}