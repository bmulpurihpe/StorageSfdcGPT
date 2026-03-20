@isTest
public class test_WebServiceCallout {
    
    @isTest static void testmethod1(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GSEM());
        
        
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
        insert g;
        
        
        g = [select Id, Provider_ID__c, sendPPI__c FROM GSEM__c where Id =: g.Id];
        
        
        
        WebServiceCallout.sendNotification(g.id);
               
        WebServiceCallout.getNotification();
        g.Provider_ID__c = '5320867835';
        g.Comment__c = ' TSEte' ;
        g.sendPPI__c = true;
        update g;
        
        MockHttpResponseGenerator_GSEM.isDone = true;
        WebServiceCallout.sendPPINotification(g.Id);
        WebServiceCallout.getNotification();
        
        
        g.Comment__c = 'TEst comment2';
        update g;
        
        
        
        Test.StopTest();
    }
    
    @isTest static void testmethod2(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GSEM());
        
        
        
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
        
        insert g;
        system.debug(' **** ' +g.Name);
        
        Onsite_Task__c ot = new Onsite_Task__c();
        ot.GSEM__c = g.Id;
        ot.Scheduling_Status__c = 'Partner Complete';
        ot.Action_Type__c = 'Task 5320869500-531 has been closed';
        ot.Send_PPI__c = false;
        ot.Case__c = cs.Id;
        insert ot;
        
        Test.startTest();
        
        ot.Comment__c =  'Test';
        //ot.Send_PPI__c = True;
        
        update ot;
        
        WebServiceCallout.sendPPINotificationOTask(ot.id);
        
        Test.StopTest();
    }
    
    @isTest static void allUnderSizedFields_IncomingMessages(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GSEM());
        
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
        insert g;
        
        
        g = [select Id, Provider_ID__c, sendPPI__c FROM GSEM__c where Id =: g.Id];
        
        MockHttpResponseGenerator_GSEM.setAllFieldsToUnderSized();
            
        WebServiceCallout.sendNotification(g.id);
        
        WebServiceCallout.getNotification();
        
        g.Provider_ID__c = '5320867835';
        g.Comment__c = ' TSEte' ;
        g.sendPPI__c = true;
        update g;
        
        WebServiceCallout.getNotification();
        
        
        g.Comment__c = 'TEst comment2';
        update g;

        Test.StopTest();
    }
    
    @isTest static void allMaxSizedFields_IncomingMessages(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GSEM());
        
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
        insert g;
        
        
        g = [select Id, Provider_ID__c, sendPPI__c FROM GSEM__c where Id =: g.Id];
        
        MockHttpResponseGenerator_GSEM.setAllFieldsToMaxSized();
       
        WebServiceCallout.sendNotification(g.id);
        
        WebServiceCallout.getNotification();
        
        g.Provider_ID__c = '5320867835';
        g.Comment__c = ' TSEte' ;
        g.sendPPI__c = true;
        update g;
        
        WebServiceCallout.getNotification();
               
        g.Comment__c = 'TEst comment2';
        update g;

        Test.StopTest();
    }
    
    @isTest static void allOverSizedFields_IncomingMessages(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GSEM());
        
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
        insert g;
        
        
        g = [select Id, Provider_ID__c, sendPPI__c FROM GSEM__c where Id =: g.Id];
        
        
        MockHttpResponseGenerator_GSEM.setAllFieldsToOverSized();
 
        WebServiceCallout.sendNotification(g.id);
                
        WebServiceCallout.getNotification();
        
        g.Provider_ID__c = '5320867835';
        g.Comment__c = ' TSEte' ;
        g.sendPPI__c = true;
        update g;

        WebServiceCallout.getNotification();
        
        
        g.Comment__c = 'TEst comment2';
        update g;
 
        Test.StopTest();
    }
    
    
}