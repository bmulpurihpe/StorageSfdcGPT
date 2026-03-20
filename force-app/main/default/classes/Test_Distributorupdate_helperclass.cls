/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class Test_Distributorupdate_helperclass {
   /* @testSetup static void setupData() {
    
        Datetime thisDate = System.now();
        TimeZone tz = TimeZone.getTimeZone('America/Los_Angeles');
        String changedDate =thisDate.format('MM/dd/yyyy HH:mm:ss',String.valueOf(tz));
        String checkHour;
        String checkMinutes;
        checkHour = changedDate.substring(11,13);
        checkMinutes = changedDate.substring(14,16);
        String currentTime = checkHour+checkMinutes;
        
        User_Activation__c UserTime = new User_Activation__c(Name='Test Time', Activation_Time__c=currentTime);
        insert userTime;
        
        Account portalAccount1 = new Account(
            Name='Setup Sample Account',
            OwnerId = UserInfo.getUserId()
        );
        Database.insert(portalAccount1);
        
         Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            Email = System.now().millisecond() + 'test@test.com',
            AccountId = portalAccount1.Id,Phone ='5435345345',
            Title ='testcont',MobilePhone ='9874561230',
            Department = 'TestData'
        );
        Database.insert(contact1);
    
    }
    */
    static testMethod void myUnitTest() {
        string key = 'test';
        List<Account> accList = NMBL_TestUtil.createAccount(key,1, true);
        List<Contact> contList = NMBL_TestUtil.createContact(accList.get(0),1,true);
            
        User adminUser=[Select ID from User where Profile.Name='System Administrator II (pw never expires)' and isActive=True and UserRoleID!=null limit 1];
        User user = new User();    
          
        System.runAs(adminUser){
            user.ProfileID = [Select Id From Profile Where Name='NS-SALES-PartnerPortal-Disti-Manage-Quotes'].id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'unique';
            user.LastName = 'gottobeveryUniQue';
            user.Username = 'test@gottobeveryUniQue.com';   
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = 'no@email.com';
            user.IsActive = true;
            user.ContactId = contList.get(0).Id;
            insert user;
            
            //assign permission set to Disti users for Advanced Approvals
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'AdvancedApprovalsUser'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
              psa.AssigneeId = user.Id;
              psa.PermissionSetId = ps.Id;
            insert psa;
        }
        //Profile profId = [Select id from Profile where Name ='NS-SALES-PartnerPortal-Disti-Manage-Quotes' Limit 1];
        
        //User_Activation__c UserTime = [Select id,name,Activation_Time__c from User_Activation__c limit 1];
        
       // UserRole portalRole = [Select Id From UserRole Where PortalType ='None' Limit 1];
        
        //Contact contact1 = [Select id from contact limit 1];
        
        //User user1 = [Select id from User where Profile.Name = 'NS-SALES-PartnerPortal-Disti-Manage-Quotes' AND IsActive = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
      
        system.runAs(user){
            Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1), Pricebook2Id = pb2.Id, HPE_Opportunity_ID__c='OPE-0123456789');
            insert opp;
            
            Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test', Family='All Flash Array');
            insert p;
            
            Test.StartTest();
            SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__PricebookId__c= pb2.Id ,SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__status__c='Draft');    
            insert quote;
            
            list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
            
            SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            line.SBQQ__ListPrice__c = 1000;
            line.BOM_Line_Number__c='1';
            line.SBQQ__Quantity__c = 1;
            line.Distributor_discount__c = 75;
            //line.total_list_price_hardware__c = 1000;
            
            insert line; //
            /*
            SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            line2.SBQQ__ListPrice__c = 999;
            line2.BOM_Line_Number__c='2';
            line2.SBQQ__Quantity__c = 1;
            line2.Distributor_discount__c = 70;
            insert line2; 
            */
            
             SBQQ__QuoteLine__c cline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline.SBQQ__RequiredBy__c=line.Id;
            cline.SBQQ__Bundled__c=true;
            cline.SBQQ__BundledQuantity__c=4;
            cline.SBQQ__ListPrice__c = 100;
            cline.BOM_Line_Number__c='1';
            cline.SBQQ__OptionType__c = 'Component';
            cline.SBQQ__Quantity__c = 6;
            //cline.Discount_Category__c='Hardware';
          //  insert cline;  //
          
          
          
            
            SBQQ__QuoteLine__c cline4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline4.SBQQ__RequiredBy__c=line.Id;
            cline4.SBQQ__Bundled__c=true;
            cline4.SBQQ__BundledQuantity__c=5;
            cline4.SBQQ__ListPrice__c = 1000;
            cline4.BOM_Line_Number__c='1';
            cline4.SBQQ__OptionType__c = 'Component';
            cline4.SBQQ__Quantity__c = 7;
            listQl.add(cline4);
            
            SBQQ__QuoteLine__c cline5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline5.SBQQ__RequiredBy__c=line.Id;
            cline5.SBQQ__Bundled__c=true;
            cline5.SBQQ__BundledQuantity__c=7;
            cline5.SBQQ__ListPrice__c = 1000;
            cline5.BOM_Line_Number__c='1';
            cline5.SBQQ__OptionType__c = 'Component';
            cline5.SBQQ__Quantity__c = 9;
            listQl.add(cline5); 
            
             SBQQ__QuoteLine__c cline6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline6.SBQQ__RequiredBy__c=line.Id;
            cline6.SBQQ__Bundled__c=true;
            cline6.SBQQ__BundledQuantity__c=9;
            cline6.SBQQ__ListPrice__c = 1000;
            cline6.BOM_Line_Number__c='1';
            cline6.SBQQ__OptionType__c = 'Component';
            cline6.SBQQ__Quantity__c = 10;
            listQl.add(cline6);
            
            SBQQ__QuoteLine__c cline9 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline9.SBQQ__RequiredBy__c=line.Id;
            cline9.SBQQ__Bundled__c=true;
            cline9.SBQQ__BundledQuantity__c=7;
            cline9.SBQQ__ListPrice__c = 1000;
            cline9.BOM_Line_Number__c='1';
            cline9.SBQQ__OptionType__c = 'Component';
            cline9.SBQQ__Quantity__c = 9;
            listQl.add(cline9);
            
            SBQQ__QuoteLine__c cline10 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline10.SBQQ__RequiredBy__c=line.Id;
            cline10.SBQQ__Bundled__c=true;
            cline10.SBQQ__BundledQuantity__c=9;
            cline10.SBQQ__ListPrice__c = 1000;
            cline10.BOM_Line_Number__c='1';
            cline10.SBQQ__OptionType__c = 'Component';
            cline10.SBQQ__Quantity__c = 10;
            listQl.add(cline10);
            
            SBQQ__QuoteLine__c cline11 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline11.SBQQ__RequiredBy__c=line.Id;
            cline11.SBQQ__Bundled__c=true;
            cline11.SBQQ__BundledQuantity__c=9;
            cline11.SBQQ__ListPrice__c = 1000;
            cline11.BOM_Line_Number__c='1';
            cline11.SBQQ__OptionType__c = 'Component';
            cline11.SBQQ__Quantity__c = 10;
            listQl.add(cline11);
            
            SBQQ__QuoteLine__c cline2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline2.SBQQ__RequiredBy__c=line.Id;
            cline2.SBQQ__Bundled__c=true;
            cline2.SBQQ__BundledQuantity__c=5;
            cline2.SBQQ__ListPrice__c = 1000;
            cline2.BOM_Line_Number__c='1.1';
            cline2.SBQQ__OptionType__c = 'Component';
            cline2.SBQQ__Quantity__c = 7;
            listQl.add(cline2);
            
            SBQQ__QuoteLine__c cline3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline3.SBQQ__RequiredBy__c=line.Id;
            cline3.SBQQ__Bundled__c=true;
            cline3.SBQQ__BundledQuantity__c=5;
            cline3.SBQQ__ListPrice__c = 1000;
            cline3.BOM_Line_Number__c='1.1';
            cline3.SBQQ__OptionType__c = 'Component';
            cline3.SBQQ__Quantity__c = 7;
            listQl.add(cline3);
            
            SBQQ__QuoteLine__c cline7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline7.SBQQ__RequiredBy__c=line.Id;
            cline7.SBQQ__Bundled__c=true;
            cline7.SBQQ__BundledQuantity__c=5;
            cline7.SBQQ__ListPrice__c = 1000;
            cline7.BOM_Line_Number__c='1.1';
            cline7.SBQQ__OptionType__c = 'Component';
            cline7.SBQQ__Quantity__c = 7;
            listQl.add(cline7);
            
            SBQQ__QuoteLine__c cline8 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline8.SBQQ__RequiredBy__c=line.Id;
            cline8.SBQQ__Bundled__c=true;
            cline8.SBQQ__BundledQuantity__c=5;
            cline8.SBQQ__ListPrice__c = 1000;
            cline8.BOM_Line_Number__c='1.1';
            cline8.SBQQ__OptionType__c = 'Component';
            cline8.SBQQ__Quantity__c = 7;
            listQl.add(cline8);
            
            SBQQ__QuoteLine__c cline12 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline12.SBQQ__RequiredBy__c=line.Id;
            cline12.SBQQ__Bundled__c=true;
            cline12.SBQQ__BundledQuantity__c=5;
            cline12.SBQQ__ListPrice__c = 1000;
            cline12.BOM_Line_Number__c='1.1';
            cline12.SBQQ__OptionType__c = 'Component';
            cline12.SBQQ__Quantity__c = 7;
            listQl.add(cline12);
            
            SBQQ__QuoteLine__c cline13 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline13.SBQQ__RequiredBy__c=line.Id;
            cline13.SBQQ__Bundled__c=true;
            cline13.SBQQ__BundledQuantity__c=5;
            cline13.SBQQ__ListPrice__c = 1000;
            cline13.BOM_Line_Number__c='1.1';
            cline13.SBQQ__OptionType__c = 'Component';
            cline13.SBQQ__Quantity__c = 7;
            listQl.add(cline13);
            
            SBQQ__QuoteLine__c cline14 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            cline14.SBQQ__RequiredBy__c=line.Id;
            cline14.SBQQ__Bundled__c=true;
            cline14.SBQQ__BundledQuantity__c=5;
            cline14.SBQQ__ListPrice__c = 1000;
            cline14.BOM_Line_Number__c='1.1';
            cline14.SBQQ__OptionType__c = 'Component';
            cline14.SBQQ__Quantity__c = 7;
            listQl.add(cline14);
        

                quote.SBQQ__Status__c = 'Draft';
                CheckRecursive.resetRunOnceFlag();
                update quote; 
          
                line.distributor_discount__c = 80;
                update line;
                quote.SBQQ__Status__c = 'Approved';
                CheckRecursive.resetRunOnceFlag();
                update quote;
                
                Sales_Order__c so = new Sales_Order__c();
                so.Opportunity__c = opp.Id;
                insert so;
                
                test.stopTest();
                Distributorupdate_helperclass quote1= new Distributorupdate_helperclass(so.id);
                Distributorupdate_helperclass.OrderLineRow q1 = new Distributorupdate_helperclass.OrderLineRow(line);
                //q1.OrderLineRow(qline)= listQl; 
                quote1.soid=so.id;
                boolean quoteval=quote1.initOrderLines();
            }
        //test.stoptest();
    }
    
    static testMethod void myUnitTest2() {
        string key = 'test';
        List<Account> accList = NMBL_TestUtil.createAccount(key,1, true);
        List<Contact> contList = NMBL_TestUtil.createContact(accList.get(0),1,true);
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        User adminUser=[Select ID from User where Profile.Name='System Administrator II (pw never expires)' and isActive=True and UserRoleID!=null limit 1];
        User user = new User();    
        Product2 p = new Product2();
        
        System.runAs(adminUser){
        
            user.ProfileID = [Select Id From Profile Where Name='NS-SALES-PartnerPortal-Disti-Manage-Quotes'].id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'unique';
            user.LastName = 'gottobeveryUniQue';
            user.Username = 'test1@gottobeveryUniQue.com';   
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = 'no@email.com';
            user.IsActive = true;
            user.ContactId = contList.get(0).Id;
            
            insert user;
            
            //assign permission set to Disti users for Advanced Approvals
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'AdvancedApprovalsUser'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
              psa.AssigneeId = user.Id;
              psa.PermissionSetId = ps.Id;
            insert psa;
            
            p = new Product2(Name='Test',IsActive=true,Productcode='Test', Family='All Flash Array', Product_Type__c='Hardware', Product_Type_2__c='Controller');
            insert p;
        }
        
        //Profile profId = [Select id from Profile where Name ='System Administrator II (pw never expires)' Limit 1];
        
        //User_Activation__c UserTime = [Select id,name,Activation_Time__c from User_Activation__c limit 1];
        
       // UserRole portalRole = [Select Id From UserRole Where PortalType ='None' Limit 1];
        
        //Contact contact1 = [Select id from contact limit 1];
        /*User user1 = new User(Alias = 'standt1',Country='United States',Email='demo2@testNMBL.com', 
                           EmailEncodingKey='UTF-8', LastName='Test1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                           ProfileId = profId.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testNMBLUser1@testNMBL.com',
                           TrainingDivision__c='IT',TrainingEnabled__c=true,Employment_Start_Date__c=Date.today());
        */
        //User user1 = [Select id from User where Profile.Name = 'NS-SALES-PartnerPortal-Disti-Manage-Quotes' AND IsActive = true LIMIT 1];
        SBQQ__Quote__c qt = new SBQQ__Quote__c();

        
        system.runAs(user){
            Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1),Pricebook2Id = pb2.Id, HPE_Opportunity_ID__c='OPE-0123456798');
            insert opp;
            
            //Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test', Family='All Flash Array', Product_Type__c='Hardware', Product_Type_2__c='Controller');
            //insert p;
            Test.startTest();
            SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__PricebookId__c= pb2.Id, SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__status__c='Draft');    
            
            insert quote;
            
            list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
            
            SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
            line.SBQQ__ListPrice__c = 1000;
            line.BOM_Line_Number__c='1';
            line.SBQQ__Quantity__c = 1;
            line.Distributor_discount__c = 75;      
            insert line;          

            quote.SBQQ__Status__c = 'Draft';
            CheckRecursive.resetRunOnceFlag();
            update quote; 
            
            qt = quote.clone();
            insert qt;
            
            Test.stopTest();
            
        }
        system.runAs(AdminUser){
            SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c(SBQQ__Quote__c=qt.Id,SBQQ__Product__c=p.Id);
            qli.SBQQ__ListPrice__c = 1000;
            qli.BOM_Line_Number__c='1';
            qli.SBQQ__Quantity__c = 3;
            qli.Distributor_discount__c = 70;      
            insert qli; 
            
            qt.SBQQ__Status__c = 'Draft';
            CheckRecursive.resetRunOnceFlag();
            update qt; 
        }
    }
}