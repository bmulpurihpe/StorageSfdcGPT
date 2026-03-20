@isTest(seeAllData=True)
public class test_gsemServiceCallout {
    static  Id gsemRecordTypeId = Schema.getGlobalDescribe().get('GSEM__c').getDescribe().getRecordTypeInfosByName().get('PN to Nimble').getRecordTypeId();
    @isTest static void testmethod1(){
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        
        Test.StartTest();
        
        Account acct = new Account();
        acct.Name = 'testAccount';
        insert acct;
        
        Contact con = new Contact();
        con.firstName = 'Conuser';
        con.lastName = 'Test';
        con.Email = 'test@abc.com';
        con.AccountId = acct.Id;
        con.phone = '+1 7667767676';
        insert con;
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Phone';
        cs.Subject = 'Test Subject for Case';
        cs.AccountId = acct.Id;
        cs.ContactId = con.Id;
        cs.isP2NCase__c = true;
        insert cs;
        
        cs = [Select Id,subject,CaseNumber From Case where Id=:cs.Id limit 1];
        
        GSEM__c g = new GSEM__C ();
        g.GSEM__c = cs.Id;
        g.Company_Name__c = acct.name;
        g.Contact_Last_Name__c =con.lastname;
        g.ContactFirstName__c = con.firstname;
        g.Contact_Email__c = con.email;
        g.Contact_Phone__c = con.phone;
        g.Provider_Last_Name__c ='HP Enterprise';
        g.Provider_Phone__c = '1-678-789-4554';
        g.Problem_Title__c = cs.subject;
        g.Cust_ticket__c = cs.CaseNumber;
        g.System_Serial_No__c = 'AF-224477';
        g.City__c = 'San JOse';
        g.State__c= 'CA';
        g.Country__c = 'US'; 
        g.Zipcode__c = '94002';
        g.Service_Request_Sent__c = true; 
        g.sendPPI__c = false;
        g.SLA__c = 'Premium';
        g.recordtypeId = gsemRecordTypeId ;
        g.GSEM_Flow_Type__c = 'GSEM OEM Provider Flow (Pointnext Originated)';
        g.pn2nRequesterID__c = '5320904567';
        insert g;
        
        List<gsem__c> g2 = [select Id, pn2nRequesterID__c  from gsem__c ];
        
        Casecomment ccs = new CaseComment (parentId = cs.Id, commentBody = 'Test Body', IsPublished = true);
        insert ccs;
        
        //Test.StartTest(); 
       /* MockHttpOEMResponseGenerator.isDoneSR = true;
        MockHttpOEMResponseGenerator.isDonePS  = true;
        gsemServiceCallOut.getGSEMNotification();*/
        Test.StopTest();
    }
    
    @isTest static void testmethod2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        Account acct = new Account();
        acct.Name = 'testAccount';
        insert acct;
        
        Contact con = new Contact();
        con.firstName = 'Conuser';
        con.lastName = 'Test';
        con.Email = 'navandan@gmail.com.train';
        con.AccountId = acct.Id;
        con.phone = '+1 7667767676';
        insert con;
        
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 pro13=new Product2();
        pro13.Name='AFQ-11TXC';
        pro13.Component_Code__c='11T';
        pro13.ProductCode='AFQ-11TXC';
        pro13.Asset_Type__c='AFA2';
        pro13.infosight_identifier__c='11520F';
        pro13.HPE_SKU__C='Q8H79A';
        pro13.Family='All Flash Array Gen5';
        
        lstProduct.add(pro13);
        
        Product2 pro14=new Product2();
        pro14.Name='HF40';
        Pro14.Component_Code__c='HF40';
        pro14.ProductCode='HF40';
        pro14.Asset_Type__c='HFA';
        pro14.infosight_identifier__c='HF40';
        pro14.HPE_SKU__C='Q8H39A';
        pro14.Family='Adaptive Flash Array Gen5';
        //insert pro;
        lstProduct.add(pro14);
        
        Product2 pro15=new Product2();
        pro15.Name='PCI-10SFPx1C';
        Pro15.Component_Code__c='2P';
        pro15.ProductCode='PCI-10SFPx1C';
        pro15.Asset_Type__c='All Flash Array Gen5';
        pro15.infosight_identifier__c='';
        pro15.HPE_SKU__C='Q8H39A';
        pro15.Family='Adaptive Flash Array Gen5';
        pro15.Array_Controller__c = 'AF40; AF60; AF80; AF20Q; HF20H; HF40; HF20C; HF60; HF20; AF20; HF40C; HF60C';
        lstProduct.add(pro15);
        
        insert lstProduct;
        
        Asset ast = new Asset();
        ast.SerialNumber = 'CZ293507KN';
        ast.Name = 'CZ293507KN';
        ast.AccountId = acct.Id;
        ast.ContactId = con.Id;
        ast.Status = 'Shipped';
        ast.Dynamic_SKU__c= 'HF40-4P2F-11T-960F';
        ast.Array_Controller__c = 'HF40';
        ast.Array_Networking__c = '2P';
        ast.Array_Capacity__c = '11T';
        ast.array_Cache__c = '960F';
        ast.SSD_Bank_A__c = '480F';
        ast.SSD_Bank_B__c = '480F';
        ast.Order_Type__c = 'Test';
        ast.IS_Array_Controller__c = 'HF40';
        ast.IS_Array_Networking__c = '4P2F' ; 
        ast.Support_End_Date__c = system.today()+365 ;
        ast.Support_Start_Date_Asset__c = system.today() ;
        insert ast;
        
        Test.StartTest(); 
        MockHttpOEMResponseGenerator.isDoneSR = false;
        gsemServiceCallOut.getGSEMNotification();
        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Phone';
        cs.Subject = 'Test Subject for Case';
        cs.AccountId = acct.Id;
        cs.ContactId = con.Id;
        cs.isP2NCase__c = true;
        insert cs;
        
        cs = [Select Id,subject,CaseNumber From Case where Id=:cs.Id limit 1];
        
        GSEM__c g = new GSEM__C ();
        g.GSEM__c = cs.Id;
        g.Company_Name__c = acct.name;
        g.Contact_Last_Name__c =con.lastname;
        g.ContactFirstName__c = con.firstname;
        g.Contact_Email__c = con.email;
        g.Contact_Phone__c = con.phone;
        g.Provider_Last_Name__c ='HP Enterprise';
        g.Provider_Phone__c = '1-678-789-4554';
        g.Problem_Title__c = cs.subject;
        g.Cust_ticket__c = cs.CaseNumber;
        g.System_Serial_No__c = 'AF-224477';
        g.City__c = 'San JOse';
        g.State__c= 'CA';
        g.Country__c = 'US'; 
        g.Zipcode__c = '94002';
        g.Service_Request_Sent__c = true; 
        g.sendPPI__c = false;
        g.SLA__c = 'Premium';
        g.recordtypeId = gsemRecordTypeId ;
        g.GSEM_Flow_Type__c = 'GSEM OEM Provider Flow (Pointnext Originated)';
        g.pn2nRequesterID__c = '5320904567';
        g.Requester_Id__c = '5320904567';
        insert g;
        MockHttpOEMResponseGenerator.isDoneSR = true;
        gsemServiceCallOut.getGSEMNotification();
        MockHttpOEMResponseGenerator.isDonePS = true;
       
        gsemServiceCallOut.getGSEMNotification();
        Test.StopTest();
    }
    
    @isTest static void testmethod3(){
        Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        Account acct = new Account();
        acct.Name = 'testAccount';
        insert acct;
        
        Contact con = new Contact();
        con.firstName = 'Conuser';
        con.lastName = 'Test';
        con.Email = 'test@abc.com';
        con.AccountId = acct.Id;
        con.phone = '+1 7667767676';
        insert con;
        
        
        
        Test.StartTest(); 
        MockHttpOEMResponseGenerator.isDoneSR = false;
        MockHttpOEMResponseGenerator.isDonePS  = false;
        gsemServiceCallOut.getGSEMNotification();
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Phone';
        cs.Subject = 'Test Subject for Case';
        cs.AccountId = acct.Id;
        cs.ContactId = con.Id;
        cs.isP2NCase__c = true;
        insert cs;
        
        cs = [Select Id,subject,CaseNumber From Case where Id=:cs.Id limit 1];
        
        GSEM__c g = new GSEM__C ();
        g.GSEM__c = cs.Id;
        g.Company_Name__c = acct.name;
        g.Contact_Last_Name__c =con.lastname;
        g.ContactFirstName__c = con.firstname;
        g.Contact_Email__c = con.email;
        g.Contact_Phone__c = con.phone;
        g.Provider_Last_Name__c ='HP Enterprise';
        g.Provider_Phone__c = '1-678-789-4554';
        g.Problem_Title__c = cs.subject;
        g.Cust_ticket__c = cs.CaseNumber;
        g.System_Serial_No__c = 'AF-224477';
        g.City__c = 'San JOse';
        g.State__c= 'CA';
        g.Country__c = 'US'; 
        g.Zipcode__c = '94002';
        g.Service_Request_Sent__c = true; 
        g.sendPPI__c = false;
        g.SLA__c = 'Premium';
        g.recordtypeId = gsemRecordTypeId ;
        g.GSEM_Flow_Type__c = 'GSEM OEM Provider Flow (Pointnext Originated)';
        g.pn2nRequesterID__c = '5320904567';
        insert g;
        //MockHttpOEMResponseGenerator.isDoneSR = true;
        //gsemServiceCallOut.getGSEMNotification();
        Test.StopTest();
    }
    
    @isTest static void testmethod4(){
        Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        Account acct = new Account();
        acct.Name = 'testAccount';
        insert acct;
        
        Contact con = new Contact();
        con.firstName = 'Conuser';
        con.lastName = 'Test';
        con.Email = 'test@abc.com';
        con.AccountId = acct.Id;
        con.phone = '+1 7667767676';
        insert con;
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Phone';
        cs.Subject = 'Test Subject for Case';
        cs.AccountId = acct.Id;
        cs.ContactId = con.Id;
        cs.isP2NCase__c = true;
        insert cs;
        
        cs = [Select Id,subject,CaseNumber From Case where Id=:cs.Id limit 1];
        
        GSEM__c g = new GSEM__C ();
        g.GSEM__c = cs.Id;
        g.Company_Name__c = acct.name;
        g.Contact_Last_Name__c =con.lastname;
        g.ContactFirstName__c = con.firstname;
        g.Contact_Email__c = con.email;
        g.Contact_Phone__c = con.phone;
        g.Provider_Last_Name__c ='HP Enterprise';
        g.Provider_Phone__c = '1-678-789-4554';
        g.Problem_Title__c = cs.subject;
        g.Cust_ticket__c = cs.CaseNumber;
        g.System_Serial_No__c = 'AF-224477';
        g.City__c = 'San JOse';
        g.State__c= 'CA';
        g.Country__c = 'US'; 
        g.Zipcode__c = '94002';
        g.Service_Request_Sent__c = true; 
        g.sendPPI__c = false;
        g.SLA__c = 'Premium';
        g.recordtypeId = gsemRecordTypeId ;
        g.GSEM_Flow_Type__c = 'GSEM OEM Provider Flow (Pointnext Originated)';
        g.pn2nRequesterID__c = '5320904567';
        insert g;
        
        Test.StartTest(); 
        MockHttpOEMResponseGenerator.isDoneSR = true;
        MockHttpOEMResponseGenerator.isDonePS  = false;
        gsemServiceCallOut.getGSEMNotification();
        //MockHttpOEMResponseGenerator = trueSR;
        //gsemServiceCallOut.getGSEMNotification();
        Test.StopTest();
    }
     @isTest static void testmethod5(){
        Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        Account acct = new Account();
        acct.Name = 'testAccount';
        insert acct;
        
        Contact con = new Contact();
        con.firstName = 'Conuser';
        con.lastName = 'Test';
        con.Email = 'test@abc.com';
        con.AccountId = acct.Id;
        con.phone = '+1 7667767676';
        insert con;
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Phone';
        cs.Subject = 'Test Subject for Case';
        cs.AccountId = acct.Id;
        cs.ContactId = con.Id;
        cs.isP2NCase__c = true;
        insert cs;
        
        cs = [Select Id,subject,CaseNumber From Case where Id=:cs.Id limit 1];
        
        GSEM__c g = new GSEM__C ();
        g.GSEM__c = cs.Id;
        g.Company_Name__c = acct.name;
        g.Contact_Last_Name__c =con.lastname;
        g.ContactFirstName__c = con.firstname;
        g.Contact_Email__c = con.email;
        g.Contact_Phone__c = con.phone;
        g.Provider_Last_Name__c ='HP Enterprise';
        g.Provider_Phone__c = '1-678-789-4554';
        g.Problem_Title__c = cs.subject;
        g.Cust_ticket__c = cs.CaseNumber;
        g.System_Serial_No__c = 'AF-224477';
        g.City__c = 'San JOse';
        g.State__c= 'CA';
        g.Country__c = 'US'; 
        g.Zipcode__c = '94002';
        g.Service_Request_Sent__c = true; 
        g.sendPPI__c = false;
        g.SLA__c = 'Premium';
        g.recordtypeId = gsemRecordTypeId ;
        g.GSEM_Flow_Type__c = 'GSEM OEM Provider Flow (Pointnext Originated)';
        g.pn2nRequesterID__c = '5320904567';
        insert g;
        
       
        Test.StartTest(); 
        ID jobE = System.enqueueJob(new asyncEntitlementGSEM(g.pn2nRequesterID__c, g.Id));                 
        ID jobAP = System.enqueueJob(new asyncAcceptProblemGSEM(g.pn2nRequesterID__c, cs.CaseNumber,g.Provider_Phone__c, g.Id));                 
        Test.StopTest();
    }
    @isTest static void testmethod6(){
        Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        Account acct = new Account();
        acct.Name = 'testAccount';
        insert acct;
        
        Contact con = new Contact();
        con.firstName = 'Conuser';
        con.lastName = 'Test';
        con.Email = 'test@abc.com';
        con.AccountId = acct.Id;
        con.phone = '+1 7667767676';
        insert con;
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Phone';
        cs.Subject = 'Test Subject for Case';
        cs.AccountId = acct.Id;
        cs.ContactId = con.Id;
        cs.isP2NCase__c = true;
        insert cs;
        
        cs = [Select Id,subject,CaseNumber, status From Case where Id=:cs.Id limit 1];
        
        GSEM__c g = new GSEM__C ();
        g.GSEM__c = cs.Id;
        g.Company_Name__c = acct.name;
        g.Contact_Last_Name__c =con.lastname;
        g.ContactFirstName__c = con.firstname;
        g.Contact_Email__c = con.email;
        g.Contact_Phone__c = con.phone;
        g.Provider_Last_Name__c ='HP Enterprise';
        g.Provider_Phone__c = '1-678-789-4554';
        g.Problem_Title__c = cs.subject;
        g.Cust_ticket__c = cs.CaseNumber;
        g.System_Serial_No__c = 'AF-224477';
        g.City__c = 'San JOse';
        g.State__c= 'CA';
        g.Country__c = 'US'; 
        g.Zipcode__c = '94002';
        g.Service_Request_Sent__c = true; 
        g.sendPPI__c = false;
        g.SLA__c = 'Premium';
        g.recordtypeId = gsemRecordTypeId ;
        g.GSEM_Flow_Type__c = 'GSEM OEM Provider Flow (Pointnext Originated)';
        g.pn2nRequesterID__c = '5320904567';
        insert g;
        
       
        Test.StartTest(); 
        cs.Status = 'Closed';
        update cs;
        Test.StopTest();
    }
    @isTest static void testmethod7(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        
        Test.StartTest(); 
        
                Account acct = new Account();
        acct.Name = 'testAccount';
        insert acct;
        
        Contact con = new Contact();
        con.firstName = 'Conuser';
        con.lastName = 'Test';
        con.Email = 'test@abc.com';
        con.AccountId = acct.Id;
        con.phone = '+1 7667767676';
        insert con;
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Phone';
        cs.Subject = 'Test Subject for Case';
        cs.AccountId = acct.Id;
        cs.ContactId = con.Id;
        cs.isP2NCase__c = true;
        insert cs;
        
        cs = [Select Id,subject,CaseNumber, status From Case where Id=:cs.Id limit 1];
        
        GSEM__c g = new GSEM__C ();
        g.GSEM__c = cs.Id;
        g.Company_Name__c = acct.name;
        g.Contact_Last_Name__c =con.lastname;
        g.ContactFirstName__c = con.firstname;
        g.Contact_Email__c = con.email;
        g.Contact_Phone__c = con.phone;
        g.Provider_Last_Name__c ='HP Enterprise';
        g.Provider_Phone__c = '1-678-789-4554';
        g.Problem_Title__c = cs.subject;
        g.Cust_ticket__c = cs.CaseNumber;
        g.System_Serial_No__c = 'AF-224477';
        g.City__c = 'San JOse';
        g.State__c= 'CA';
        g.Country__c = 'US'; 
        g.Zipcode__c = '94002';
        g.Service_Request_Sent__c = true; 
        g.sendPPI__c = false;
        g.SLA__c = 'Premium';
        g.recordtypeId = gsemRecordTypeId ;
        g.GSEM_Flow_Type__c = 'GSEM OEM Provider Flow (Pointnext Originated)';
        g.pn2nRequesterID__c = '5320904567';
        g.Requester_Id__c =  '5320904567';
        insert g;
        
        
        MockHttpOEMResponseGenerator.isDoneSR = true;
        MockHttpOEMResponseGenerator.isDonePS = true;
        MockHttpOEMResponseGenerator.isDonePPI = false;

        gsemServiceCallOut.getGSEMNotification();
        
        MockHttpOEMResponseGenerator.isDonePPIDupe  = false;
        
        gsemServiceCallOut.getGSEMNotification();
        
        System.CalloutException coExc = new System.CalloutException();
        
        gsemServiceCallOut.sendErrorNotification(coExc);

        
        Test.StopTest();
    }


}