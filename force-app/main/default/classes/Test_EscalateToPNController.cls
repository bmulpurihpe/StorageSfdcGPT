@istest(SeeAllData=true)
public class Test_EscalateToPNController {
    
    
    static testmethod void Testmethod01(){
        
        Test.StartTest(); 
        
        Account accRec = new Account();
        accRec.Name = 'testAccount';
        insert accRec;
        
        Contact conRec   = new Contact();
        conRec.FirstName = 'contact';
        conRec.LastName  = 'Test';
        conRec.Email     = 'test@customer.com';
        conRec.AccountId = accRec.Id;
        insert conRec;
        
        Case aCaseRec = new Case();
        aCaseRec.Status    = 'New';
        aCaseRec.Origin    = 'Phone';
        aCaseRec.AccountId = accRec.Id;
        aCaseRec.ContactId = conRec.Id;
        insert aCaseRec;

        
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc        = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass = new EscalateToPNController(sc);
        customContClass.userInputSerialNum     = '';
        customContClass.userInputContractId    = 'CNX';
        customContClass.userInputSeverity      = 'MEDIUM';
        customContClass.gsemProblemTitle       = 'Test Problem Title';
        customContClass.gsemProblemDescription = 'Test Problem Description';
        
        
        List<SelectOption> directRoutingDestinationOptions = customContClass.getDirectRoutingDestinationOptions();
        List<SelectOption> caseSeverityOptions = customContClass.getCaseSeverityOptions();
        customContClass.escalateToPN(); 
        
        Test.StopTest();
    }
    static testmethod void Testmethod02(){
        
        Test.StartTest(); 
        
        Account accRec = new Account();
        accRec.Name = 'testAccount';
        insert accRec;
        
        Contact conRec   = new Contact();
        conRec.FirstName = 'contact';
        conRec.LastName  = 'Test';
        conRec.Email     = 'test@customer.com';
        conRec.AccountId = accRec.Id;
        insert conRec;
        
        Case aCaseRec = new Case();
        aCaseRec.Status    = 'New';
        aCaseRec.Origin    = 'Phone';
        aCaseRec.AccountId = accRec.Id;
        aCaseRec.ContactId = conRec.Id;
        insert aCaseRec;
        
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc        = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass = new EscalateToPNController(sc);
        customContClass.userInputSerialNum     = 'AA000000NIM';
        customContClass.userInputContractId    = 'CNX';
        customContClass.userInputSeverity      = 'MEDIUM';
        customContClass.gsemProblemTitle       = 'Test Problem Title';
        customContClass.gsemProblemDescription = 'Test Problem Description';
        
        List<SelectOption> directRoutingDestinationOptions = customContClass.getDirectRoutingDestinationOptions();
        List<SelectOption> caseSeverityOptions = customContClass.getCaseSeverityOptions();
        customContClass.escalateToPN();
        
        Test.StopTest();
    }
    static testmethod void Testmethod03(){
        Test.StartTest(); 
        
        Account accRec = new Account();
        accRec.Name    = 'testAccount';
        insert accRec;
        
        Contact conRec = new Contact();
        conRec.firstName = 'contact';
        conRec.lastName  = 'Test';
        conRec.Email     = 'test@customer.com';
        conRec.AccountId = accRec.Id;
        conRec.phone     = '+91 0000777733';
        insert conRec;
        
        Case aCaseRec = new Case();
        aCaseRec.Status    = 'New';
        aCaseRec.Origin    = 'Phone';
        aCaseRec.Subject   = 'Test Subject for Case';
        aCaseRec.AccountId = accRec.Id;
        aCaseRec.ContactId = conRec.Id;
        insert aCaseRec;
        
        aCaseRec = [Select Id,subject,CaseNumber From Case where Id=:aCaseRec.Id limit 1];
        
        GSEM__c gsemRec = new GSEM__C ();
        gsemRec.GSEM__c                 = aCaseRec.Id;
        gsemRec.Company_Name__c         = accRec.name;
        gsemRec.Contact_Last_Name__c    = conRec.lastname;
        gsemRec.ContactFirstName__c     = conRec.firstname;
        gsemRec.Contact_Email__c        = conRec.email;
        gsemRec.Contact_Phone__c        = conRec.phone;
        gsemRec.Provider_Last_Name__c   ='HP Enterprise';
        gsemRec.Provider_Phone__c       = '1-877-364-6253';
        gsemRec.Problem_Title__c        = aCaseRec.subject;
        gsemRec.Cust_ticket__c          = aCaseRec.CaseNumber;
        gsemRec.System_Serial_No__c     = 'AA-0000000';
        gsemRec.City__c                 = 'WILSONVILLE';
        gsemRec.State__c                = 'OR';
        gsemRec.Country__c              = 'US'; 
        gsemRec.Zipcode__c              = '97070';
        gsemRec.Service_Request_Sent__c = false; 
        gsemRec.sendPPI__c              = false;
        gsemRec.SLA__c                  = 'Premium';
        insert gsemRec;
        //gsemRec.sendPPI__c = true;
        //update gsemRec;
        
        Test.StopTest();
    }
    
    static testmethod void Testmethod04(){
        
        
        Account accRec = new Account();
        accRec.Name = 'testAccount';
        insert accRec;
        
        Contact conRec = new Contact();
        conRec.FirstName = 'contact';
        conRec.LastName  = 'Test';
        conRec.Email     = 'test@customer.com';
        conRec.AccountId = accRec.Id;
        insert conRec;
        
        Asset assetRec = [SELECT Id, Name FROM Asset WHERE Name = 'N/A'];
        //Asset assetRec = new Asset(Name = 'N/A');
        //insert assetRec;
        
        Case aCaseRec = new Case();
        aCaseRec.Status    = 'New';
        aCaseRec.Origin    = 'Phone';
        aCaseRec.AccountId = accRec.Id;
        aCaseRec.ContactId = conRec.Id;
        aCaseRec.AssetId   = assetRec.Id;
        insert aCaseRec;
        
        Test.StartTest(); 
        
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc1                   = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass1            = new EscalateToPNController(sc1);
        customContClass1.userInputSerialNum                = 'AF-000000NIM';
        customContClass1.userInputSAID                     = 'xxxx';
        customContClass1.userInputContractId               = 'CNX';
        customContClass1.userInputSeverity                 = 'MEDIUM';
        customContClass1.gsemProblemTitle                  = 'Test Problem Title';
        customContClass1.gsemProblemDescription            = 'Test Problem Description';
        customContClass1.userInputDirectRoutingDestination = 'Greenlake Platform Support Team';
        List<SelectOption> directRoutingDestinationOptions = customContClass1.getDirectRoutingDestinationOptions();
        List<SelectOption> caseSeverityOptions             = customContClass1.getCaseSeverityOptions();
        customContClass1.escalateToPN();
        
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc2                   = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass2            = new EscalateToPNController(sc2);
        customContClass2.userInputSerialNum                = 'AF-000000NIM';
        customContClass2.userInputSAID                     = 'xxxx';
        customContClass2.userInputContractId               = 'CNX';
        customContClass2.userInputSeverity                 = 'MEDIUM';
        customContClass2.gsemProblemTitle                  = 'Test Problem Title';
        customContClass2.gsemProblemDescription            = 'Test Problem Description';
        customContClass2.userInputDirectRoutingDestination = 'Alletra 9000';
        //List<SelectOption> directRoutingDestinationOptions = customContClass1.getDirectRoutingDestinationOptions();
        //List<SelectOption> caseSeverityOptions = customContClass1.getCaseSeverityOptions();
        customContClass2.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc3 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass3 = new EscalateToPNController(sc3);
        customContClass3.userInputSerialNum = 'AF-000000NIM';
        customContClass3.userInputSAID = 'xxxx';
        customContClass3.userInputContractId               = 'CNX';
        customContClass3.userInputSeverity                 = 'MEDIUM';
        customContClass3.gsemProblemTitle                  = 'Test Problem Title';
        customContClass3.gsemProblemDescription            = 'Test Problem Description';
        customContClass3.userInputDirectRoutingDestination = 'Alletra 9000';
        customContClass3.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc4 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass4 = new EscalateToPNController(sc4);
        customContClass4.userInputSerialNum = 'AF-000000NIM';
        customContClass4.userInputSAID = 'xxxx';
        customContClass4.userInputContractId               = 'CNX';
        customContClass4.userInputSeverity                 = 'MEDIUM';
        customContClass4.gsemProblemTitle                  = 'Test Problem Title';
        customContClass4.gsemProblemDescription            = 'Test Problem Description';
        customContClass4.userInputDirectRoutingDestination = 'DHCI InfoSight Server Backend';
        customContClass4.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc5 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass5 = new EscalateToPNController(sc5);
        customContClass5.userInputSerialNum = 'AF-000000NIM';
        customContClass5.userInputSAID = 'xxxx';
        customContClass5.userInputContractId               = 'CNX';
        customContClass5.userInputSeverity                 = 'MEDIUM';
        customContClass5.gsemProblemTitle                  = 'Test Problem Title';
        customContClass5.gsemProblemDescription            = 'Test Problem Description';
        customContClass5.userInputDirectRoutingDestination = 'InfoSight Server tab issue';
        customContClass5.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc6 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass6 = new EscalateToPNController(sc6);
        customContClass6.userInputSerialNum = 'AF-000000NIM';
        customContClass6.userInputSAID = 'xxxx';
        customContClass6.userInputContractId               = 'CNX';
        customContClass6.userInputSeverity                 = 'MEDIUM';
        customContClass6.gsemProblemTitle                  = 'Test Problem Title';
        customContClass6.gsemProblemDescription            = 'Test Problem Description';
        customContClass6.userInputDirectRoutingDestination = 'M-Series Switch – SN2XXXM';
        customContClass6.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc7 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass7 = new EscalateToPNController(sc7);
        customContClass7.userInputSerialNum = 'AF-000000NIM';
        customContClass7.userInputSAID = 'xxxx';
        customContClass7.userInputContractId               = 'CNX';
        customContClass7.userInputSeverity                 = 'MEDIUM';
        customContClass7.gsemProblemTitle                  = 'Test Problem Title';
        customContClass7.gsemProblemDescription            = 'Test Problem Description';
        customContClass7.userInputDirectRoutingDestination = 'B-series/Brocade series switch';
        customContClass7.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc8 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass8 = new EscalateToPNController(sc8);
        customContClass8.userInputSerialNum = 'AF-000000NIM';
        customContClass8.userInputSAID = 'xxxx';
        customContClass8.userInputContractId               = 'CNX';
        customContClass8.userInputSeverity                 = 'MEDIUM';
        customContClass8.gsemProblemTitle                  = 'Test Problem Title';
        customContClass8.gsemProblemDescription            = 'Test Problem Description';
        customContClass8.userInputDirectRoutingDestination = 'Greenlake Login Issues';
        customContClass8.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc9 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass9 = new EscalateToPNController(sc9);
        customContClass9.userInputSerialNum = 'AF-000000NIM';
        customContClass9.userInputSAID = 'xxxx';
        customContClass9.userInputContractId               = 'CNX';
        customContClass9.userInputSeverity                 = 'MEDIUM';
        customContClass9.gsemProblemTitle                  = 'Test Problem Title';
        customContClass9.gsemProblemDescription            = 'Test Problem Description';
        customContClass9.userInputDirectRoutingDestination = 'Alletra MP Block Storage';
        customContClass9.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc10 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass10 = new EscalateToPNController(sc10);
        customContClass10.userInputSerialNum = 'AF-000000NIM';
        customContClass10.userInputSAID = 'xxxx';
        customContClass10.userInputContractId               = 'CNX';
        customContClass10.userInputSeverity                 = 'MEDIUM';
        customContClass10.gsemProblemTitle                  = 'Test Problem Title';
        customContClass10.gsemProblemDescription            = 'Test Problem Description';
        customContClass10.userInputDirectRoutingDestination = 'Recovery Manager Central (RMC)';
        customContClass10.escalateToPN();
        
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc11 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass11 = new EscalateToPNController(sc11);
        customContClass11.userInputSerialNum = 'AF-000000NIM';
        customContClass11.userInputSAID = 'xxxx';
        customContClass11.userInputContractId               = 'CNX';
        customContClass11.userInputSeverity                 = 'MEDIUM';
        customContClass11.gsemProblemTitle                  = 'Test Problem Title';
        customContClass11.gsemProblemDescription            = 'Test Problem Description';
        customContClass11.userInputDirectRoutingDestination = 'GSR SAPHANA';
        customContClass11.escalateToPN();
                       
        Test.StopTest();
    
    }
    static testmethod void Testmethod05(){
        
        
        Account accRec = new Account();
        accRec.Name = 'testAccount';
        insert accRec;
        
        Contact conRec = new Contact();
        conRec.FirstName = 'contact';
        conRec.LastName  = 'Test';
        conRec.Email     = 'test@customer.com';
        conRec.AccountId = accRec.Id;
        insert conRec;
        
        Asset assetRec = [SELECT Id, Name FROM Asset WHERE Name = 'N/A'];
        //Asset assetRec = new Asset(Name = 'N/A');
        //insert assetRec;
        
        Case aCaseRec = new Case();
        aCaseRec.Status    = 'New';
        aCaseRec.Origin    = 'Phone';
        aCaseRec.AccountId = accRec.Id;
        aCaseRec.ContactId = conRec.Id;
        aCaseRec.AssetId   = assetRec.Id;
        insert aCaseRec;
        
        Test.StartTest(); 
        
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc1                   = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass1            = new EscalateToPNController(sc1);
        customContClass1.userInputSerialNum                = 'AF-000000NIM';
        customContClass1.userInputSAID                     = 'xxxx';
        customContClass1.userInputContractId               = 'CNX';
        customContClass1.userInputSeverity                 = 'MEDIUM';
        customContClass1.gsemProblemTitle                  = 'Test Problem Title';
        customContClass1.gsemProblemDescription            = 'Test Problem Description';
        customContClass1.userInputDirectRoutingDestination = 'Greenlake Platform Support Team';
        List<SelectOption> directRoutingDestinationOptions = customContClass1.getDirectRoutingDestinationOptions();
        List<SelectOption> caseSeverityOptions             = customContClass1.getCaseSeverityOptions();
        customContClass1.escalateToPN();
        
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc2                   = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass2            = new EscalateToPNController(sc2);
        customContClass2.userInputSerialNum                = 'AF-000000NIM';
        customContClass2.userInputSAID                     = 'xxxx';
        customContClass2.userInputContractId               = 'CNX';
        customContClass2.userInputSeverity                 = 'MEDIUM';
        customContClass2.gsemProblemTitle                  = 'Test Problem Title \\';
        customContClass2.gsemProblemDescription            = 'Test Problem Description\\';
        customContClass2.userInputDirectRoutingDestination = 'Alletra 9000';
        //List<SelectOption> directRoutingDestinationOptions = customContClass1.getDirectRoutingDestinationOptions();
        //List<SelectOption> caseSeverityOptions = customContClass1.getCaseSeverityOptions();
        customContClass2.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc3 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass3 = new EscalateToPNController(sc3);
        customContClass3.userInputSerialNum = 'AF-000000NIM';
        customContClass3.userInputSAID = 'xxxx';
        customContClass3.userInputContractId               = 'CNX';
        customContClass3.userInputSeverity                 = 'MEDIUM';
        customContClass3.gsemProblemTitle                  = 'Test Problem Title';
        customContClass3.gsemProblemDescription            = 'Test Problem Description';
        customContClass3.userInputDirectRoutingDestination = 'Alletra 9000';
        customContClass3.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc4 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass4 = new EscalateToPNController(sc4);
        customContClass4.userInputSerialNum = 'AF-000000NIM';
        customContClass4.userInputSAID = 'xxxx';
        customContClass4.userInputContractId               = 'CNX';
        customContClass4.userInputSeverity                 = 'MEDIUM';
        customContClass4.gsemProblemTitle                  = 'Test Problem Title';
        customContClass4.gsemProblemDescription            = 'Test Problem Description';
        customContClass4.userInputDirectRoutingDestination = 'DHCI InfoSight Server Backend';
        customContClass4.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc5 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass5 = new EscalateToPNController(sc5);
        customContClass5.userInputSerialNum = 'AF-000000NIM';
        customContClass5.userInputSAID = 'xxxx';
        customContClass5.userInputContractId               = 'CNX';
        customContClass5.userInputSeverity                 = 'MEDIUM';
        customContClass5.gsemProblemTitle                  = 'Test Problem Title';
        customContClass5.gsemProblemDescription            = 'Test Problem Description';
        customContClass5.userInputDirectRoutingDestination = 'InfoSight Server tab issue';
        customContClass5.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc6 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass6 = new EscalateToPNController(sc6);
        customContClass6.userInputSerialNum = 'AF-000000NIM';
        customContClass6.userInputSAID = 'xxxx';
        customContClass6.userInputContractId               = 'CNX';
        customContClass6.userInputSeverity                 = 'MEDIUM';
        customContClass6.gsemProblemTitle                  = 'Test Problem Title';
        customContClass6.gsemProblemDescription            = 'Test Problem Description';
        customContClass6.userInputDirectRoutingDestination = 'M-Series Switch – SN2XXXM';
        customContClass6.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc7 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass7 = new EscalateToPNController(sc7);
        customContClass7.userInputSerialNum = 'AF-000000NIM';
        customContClass7.userInputSAID = 'xxxx';
        customContClass7.userInputContractId               = 'CNX';
        customContClass7.userInputSeverity                 = 'MEDIUM';
        customContClass7.gsemProblemTitle                  = 'Test Problem Title';
        customContClass7.gsemProblemDescription            = 'Test Problem Description';
        customContClass7.userInputDirectRoutingDestination = 'B-series/Brocade series switch';
        customContClass7.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc8 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass8 = new EscalateToPNController(sc8);
        customContClass8.userInputSerialNum = 'AF-000000NIM';
        customContClass8.userInputSAID = 'xxxx';
        customContClass8.userInputContractId               = 'CNX';
        customContClass8.userInputSeverity                 = 'MEDIUM';
        customContClass8.gsemProblemTitle                  = 'Test Problem Title';
        customContClass8.gsemProblemDescription            = 'Test Problem Description';
        customContClass8.userInputDirectRoutingDestination = 'Greenlake Login Issues';
        customContClass8.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc9 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass9 = new EscalateToPNController(sc9);
        customContClass9.userInputSerialNum = 'AF-000000NIM';
        customContClass9.userInputSAID = 'xxxx';
        customContClass9.userInputContractId               = 'CNX';
        customContClass9.userInputSeverity                 = 'MEDIUM';
        customContClass9.gsemProblemTitle                  = 'Test Problem Title';
        customContClass9.gsemProblemDescription            = 'Test Problem Description';
        customContClass9.userInputDirectRoutingDestination = 'Alletra MP Block Storage';
        customContClass9.escalateToPN();
        
                
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc10 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass10 = new EscalateToPNController(sc10);
        customContClass10.userInputSerialNum = 'AF-000000NIM';
        customContClass10.userInputSAID = 'xxxx';
        customContClass10.userInputContractId               = 'CNX';
        customContClass10.userInputSeverity                 = 'MEDIUM';
        customContClass10.gsemProblemTitle                  = 'Test Problem Title';
        customContClass10.gsemProblemDescription            = 'Test Problem Description';
        customContClass10.userInputDirectRoutingDestination = 'Recovery Manager Central (RMC)';
        customContClass10.escalateToPN();
        
        ApexPages.currentPage().getParameters().put('Id',aCaseRec.Id);
        ApexPages.StandardController sc11 = new ApexPages.StandardController(aCaseRec);
        EscalateToPNController customContClass11 = new EscalateToPNController(sc11);
        customContClass11.userInputSerialNum = 'AF-000000NIM';
        customContClass11.userInputSAID = 'xxxx';
        customContClass11.userInputContractId               = 'CNX';
        customContClass11.userInputSeverity                 = 'MEDIUM';
        customContClass11.gsemProblemTitle                  = 'Test Problem Title';
        customContClass11.gsemProblemDescription            = 'Test Problem Description';
        customContClass11.userInputDirectRoutingDestination = 'GSR SAPHANA';
        customContClass11.escalateToPN();
                       
        Test.StopTest();
    }
    
    
    static testmethod void Testmethod06(){
        Test.StartTest(); 
        
        Account accRec = new Account();
        accRec.Name    = 'testAccount';
        insert accRec;
        
        Contact conRec = new Contact();
        conRec.firstName = 'contact';
        conRec.lastName  = 'Test';
        conRec.Email     = 'test@customer.com';
        conRec.AccountId = accRec.Id;
        conRec.phone     = '+91 0000777733';
        insert conRec;
        
        Case aCaseRec = new Case();
        aCaseRec.Status    = 'New';
        aCaseRec.Origin    = 'Phone';
        aCaseRec.Subject   = 'Test Subject for Case';
        aCaseRec.AccountId = accRec.Id;
        aCaseRec.ContactId = conRec.Id;
        insert aCaseRec;
        
        aCaseRec = [Select Id,subject,CaseNumber From Case where Id=:aCaseRec.Id limit 1];
        
        GSEM__c gsemRec = new GSEM__C ();
        gsemRec.GSEM__c                 = aCaseRec.Id;
        gsemRec.Company_Name__c         = accRec.name;
        gsemRec.Contact_Last_Name__c    = conRec.lastname;
        gsemRec.ContactFirstName__c     = conRec.firstname;
        gsemRec.Contact_Email__c        = conRec.email;
        gsemRec.Contact_Phone__c        = conRec.phone;
        gsemRec.Provider_Last_Name__c   ='HP Enterprise';
        gsemRec.Provider_Phone__c       = '1-877-364-6253';
        gsemRec.Problem_Title__c        = aCaseRec.subject+'\\';
        gsemRec.Problem_Description__c = aCaseRec.subject+'\\';
        gsemRec.Cust_ticket__c          = aCaseRec.CaseNumber;
        gsemRec.System_Serial_No__c     = 'AA-0000000';
        gsemRec.City__c                 = 'WILSONVILLE';
        gsemRec.State__c                = 'OR';
        gsemRec.Country__c              = 'US'; 
        gsemRec.Zipcode__c              = '97070';
        gsemRec.Service_Request_Sent__c = false; 
        gsemRec.sendPPI__c              = false;
        gsemRec.SLA__c                  = 'Premium';
        insert gsemRec;
        //gsemRec.sendPPI__c = true;
        //update gsemRec;
        
        Test.StopTest();
    }
    
}