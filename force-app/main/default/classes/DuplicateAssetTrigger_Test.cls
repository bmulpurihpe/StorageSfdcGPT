/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        August 4, 2016
Purpose             :        Test class for the following trigger
                             1) DuplicateAssetTrigger.trigger

**************************************************************************************************************************************/
@isTest
private class DuplicateAssetTrigger_Test{
    
    static testMethod void testMethod1() {
    
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
        
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        
        system.runAs(u){
        
        //insert new AssetJapanCutOffDate__c (Name='CutOffDate', JapanCutOffDate__c = Date.parse('1/2/2018'));
        
        Account acc=new Account();
        acc.Name='Test account';
        acc.CurrencyIsoCode='USD';
        acc.Type='Distributor';
        insert acc;
             
        Contact con=new Contact();
        con.lastName='Test Contact';
        con.CurrencyIsoCode='USD';
        con.accountid=acc.id;
        con.Email='test@test.com';
        insert con;  
        
        Opportunity opp= new Opportunity();
        opp.Name='test mansa';
        opp.AccountId=acc.id;
        opp.CloseDate=system.today()+3;
        opp.StageName='Qualified';
        opp.Sales_Area__c='EMEA';
        opp.Reseller_Account__c=acc.id;
        opp.HPE_Opportunity_ID__c = 'OPE-5643216785';
        opp.Pricebook2Id = pricebookId;
        insert opp;
        
        Sales_Order__c sotest=new Sales_Order__c();
        sotest.Name='test';
        sotest.CurrencyIsoCode='AUD';
        sotest.Type__c='Revenue';
        sotest.status__c='New';
        sotest.Opportunity__c=opp.ID;
        sotest.Bill_To_Address_1__c='47 Jackson Street';
        sotest.Bill_To_City__c='San Francisco';
        sotest.Bill_To_Company__c='Mansa';
        sotest.Bill_To_Contact_Email__c='jitender.padda@mansasys.com';
        sotest.Bill_To_Contact_Name__c='J';
        sotest.Bill_To_Contact_Phone__c='8860937435';
        sotest.Bill_To_Country__c='US';
        sotest.Bill_To_State__c='California';
        sotest.Bill_To_Zip_Postal_Code__c='94101';
        sotest.Freight_Mode__c='test';
        sotest.Payment_Terms__c='test';
        sotest.Planned_Install_Date__c=system.today();
        sotest.PO__c='test';
        sotest.Requested_Ship_Date__c=system.today();
        sotest.Ship_To_Address_1__c='47 Jackson Street';
        sotest.Ship_To_City__c='San Francisco';
        sotest.Ship_To_Company__c='Mansa';
        sotest.Ship_To_Contact_Email__c='jitender.padda@mansasys.com';
        sotest.Ship_To_Contact_Name__c='J';
        sotest.Ship_To_Contact_Phone__c='8860937435';
        sotest.Ship_To_Country__c='US';
        sotest.Ship_To_State__c='California';
        sotest.Ship_To_Zip_Postal_Code__c='94101'; 
        sotest.Taxable__c='test';
        sotest.Can_Ship_Early__c='Yes';
        sotest.End_Customer_Address_1__c='47 Jackson Street';
        sotest.End_Customer_City__c='San Francisco';
        sotest.End_Customer_Company__c='Mansa';
        sotest.End_Customer_Contact_Email__c='jitender.padda@mansasys.com';
        sotest.End_Customer_Contact_Name__c='J';
        sotest.End_Customer_Contact_Phone__c='8860937435';
        sotest.End_Customer_Country__c='US';
        sotest.End_Customer_State__c='California';
        sotest.End_Customer_Zip_Postal_Code__c='94101';
        sotest.type__c ='Support Renewal';
           // sotest.Status__c = 'Submitted to OA';
        insert sotest;
        
        
        Asset nAssRec=new Asset();
        nAssRec.Accountid=acc.id;
        nAssRec.Contactid=con.id;
        nAssRec.Name='Test asset';
        nAssRec.SerialNumber='123';
        nAssRec.status='Shipped';
        nAssRec.HPE_Serial_Number__c = '100000005';
        insert nAssRec;
        
       /* Case caseRec=new Case();
        caseRec.AccountId=acc.id;
        caseRec.ContactId=con.id;
        caseRec.AssetId=nAssRec.Id;
        caseRec.Status='Open';
        caseRec.Type = 'Problem';
        caseRec.caseCatImpactToCustomer__c = 'Admin Operation Failed or Slow';
        caseRec.Nimble_Version__c='3.4.1.0';
        caseRec.Estimated_Effort__c='2 hours';
        insert caseRec;
        */
        

        Duplicate_Asset__c du=new Duplicate_Asset__c();
        du.Account__c=acc.id;         
        //du.Serial_Number__c='123';
        du.Asset_Name__c='test';
        du.sla__c='Premium';
        du.Support_Start_Date__c=date.today();
        du.Support_End_Date__c=date.today()+12;      
        du.Matched_Asset__c= nAssRec.id;
        du.Sales_Order__c = sotest.Id ;
        du.HPE_Serial_Number__c = '100000006';
        Utility.runDupRecTrigger=true;  
       
        Test.startTest();        
       
        insert du;
        
        Test.stopTest(); 
        
        //du.Support_Start_Date__c=date.today() +3;
        //du.Support_End_Date__c=date.today()+ 9;
        
        //update du;  
        }
              
    }

    static testMethod void testMethod1NoContact() {
       Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        
        Id pricebookId = Test.getStandardPricebookId();
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        
        system.runAs(u){
       
        //insert new AssetJapanCutOffDate__c (Name='CutOffDate', JapanCutOffDate__c = Date.parse('1/2/2018'));
        
        Account acc=new Account();
        acc.Name='Test account';
        acc.CurrencyIsoCode='USD';
        acc.Type='Distributor';
        insert acc;
             
        Contact con=new Contact();
        con.lastName='Test Contact';
        con.CurrencyIsoCode='USD';
        con.accountid=acc.id;
        con.Email='test@test.com';
        insert con;  
        
        Opportunity opp= new Opportunity();
        opp.Name='test mansa';
        opp.AccountId=acc.id;
        opp.CloseDate=system.today()+3;
        opp.StageName='Qualified';
        opp.Sales_Area__c='EMEA';
        opp.Reseller_Account__c=acc.id;
        opp.HPE_Opportunity_ID__c = 'OPE-5643216798';
        opp.Pricebook2Id = pricebookId;
        insert opp;
        
        Sales_Order__c sotest=new Sales_Order__c();
        sotest.Name='test';
        sotest.CurrencyIsoCode='AUD';
        sotest.Type__c='Revenue';
        sotest.status__c='New';
        sotest.Opportunity__c=opp.ID;
        sotest.Bill_To_Address_1__c='47 Jackson Street';
        sotest.Bill_To_City__c='San Francisco';
        sotest.Bill_To_Company__c='Mansa';
        sotest.Bill_To_Contact_Email__c='jitender.padda@mansasys.com';
        sotest.Bill_To_Contact_Name__c='J';
        sotest.Bill_To_Contact_Phone__c='8860937435';
        sotest.Bill_To_Country__c='US';
        sotest.Bill_To_State__c='California';
        sotest.Bill_To_Zip_Postal_Code__c='94101';
        sotest.Freight_Mode__c='test';
        sotest.Payment_Terms__c='test';
        sotest.Planned_Install_Date__c=system.today();
        sotest.PO__c='test';
        sotest.Requested_Ship_Date__c=system.today();
        sotest.Ship_To_Address_1__c='47 Jackson Street';
        sotest.Ship_To_City__c='San Francisco';
        sotest.Ship_To_Company__c='Mansa';
        sotest.Ship_To_Contact_Email__c='test@test.com';
        sotest.Ship_To_Contact_Name__c='J';
        sotest.Ship_To_Contact_Phone__c='8860937435';
        sotest.Ship_To_Country__c='US';
        sotest.Ship_To_State__c='California';
        sotest.Ship_To_Zip_Postal_Code__c='94101'; 
        sotest.Taxable__c='test';
        sotest.Can_Ship_Early__c='Yes';
        sotest.End_Customer_Address_1__c='47 Jackson Street';
        sotest.End_Customer_City__c='San Francisco';
        sotest.End_Customer_Company__c='Mansa';
        sotest.End_Customer_Contact_Email__c='jitender.padda@mansasys.com';
        sotest.End_Customer_Contact_Name__c='J';
        sotest.End_Customer_Contact_Phone__c='8860937435';
        sotest.End_Customer_Country__c='US';
        sotest.End_Customer_State__c='California';
        sotest.End_Customer_Zip_Postal_Code__c='94101';
        sotest.type__c ='Support Renewal';
           // sotest.Status__c = 'Submitted to OA';
        insert sotest;
        
        
        Asset nAssRec=new Asset();
        nAssRec.Accountid=acc.id;
        nAssRec.Contactid=con.id;
        nAssRec.Name='Test asset';
        nAssRec.SerialNumber='123';
        nAssRec.status='Shipped';
        nAssRec.HPE_Serial_Number__c = '100000005';
        insert nAssRec;
        
       /* Case caseRec=new Case();
        caseRec.AccountId=acc.id;
        caseRec.ContactId=con.id;
        caseRec.AssetId=nAssRec.Id;
        caseRec.Status='Open';
        caseRec.Type = 'Problem';
        caseRec.caseCatImpactToCustomer__c = 'Admin Operation Failed or Slow';
        caseRec.Nimble_Version__c='3.4.1.0';
        caseRec.Estimated_Effort__c='2 hours';
        insert caseRec;
        */
        

        Duplicate_Asset__c du=new Duplicate_Asset__c();
        du.Account__c=acc.id;         
        //du.Serial_Number__c='123';
        du.Asset_Name__c='test';
        du.sla__c='Premium';
        du.Support_Start_Date__c=date.today();
        du.Support_End_Date__c=date.today()+12;      
        du.Matched_Asset__c= nAssRec.id;
        du.Sales_Order__c = sotest.Id ;
        du.HPE_Serial_Number__c = '100000006';
        Utility.runDupRecTrigger=true;  
       
        Test.startTest();        
        con.accountid=null;
        update con;
        insert du;
        
        Test.stopTest(); 
        
        //du.Support_Start_Date__c=date.today() +3;
        //du.Support_End_Date__c=date.today()+ 9;
        
        //update du;  
        }
              
    }
    
    
    static testMethod void testMethod2() {
       
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        
        Id pricebookId = Test.getStandardPricebookId();
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        
        system.runAs(u){
        
        //insert new AssetJapanCutOffDate__c (Name='CutOffDate', JapanCutOffDate__c = Date.parse('1/2/2018'));
       
        Account acc=new Account();
        acc.Name='Test account';
        acc.CurrencyIsoCode='USD';
        acc.Type='Distributor';
        insert acc; 
        
        Account acc1=new Account();
        acc1.Name='Test account';
        acc1.CurrencyIsoCode='USD';
        acc1.Type='Distributor';
        insert acc1; 
        
        Contact con=new Contact();
        con.lastName='Test Contact';
        con.CurrencyIsoCode='USD';
        con.accountid=acc1.id;
        con.Email='jitender.padda@mansasys.com';
        insert con;
        
        Opportunity opp= new Opportunity();
        opp.Name='test mansa';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today()+3;
        opp.StageName='Qualified';
        opp.Sales_Area__c='EMEA';
        opp.Reseller_Account__c=acc.id;
        opp.HPE_Opportunity_ID__c = 'OPE-5643216675';
        opp.Pricebook2Id = pricebookId;
        insert opp;
        
        List<Sales_Order__c> salesOrderList = new List<Sales_Order__c>();
        
        Sales_Order__c sotest=new Sales_Order__c();
        sotest.Name='test';
        sotest.CurrencyIsoCode='AUD';
        sotest.Type__c='Revenue';
        sotest.status__c='New';
        sotest.Opportunity__c=opp.ID;
        sotest.Bill_To_Address_1__c='47 Jackson Street';
        sotest.Bill_To_City__c='San Francisco';
        sotest.Bill_To_Company__c='Mansa';
        sotest.Bill_To_Contact_Email__c='jitender.padda@mansasys.com';
        sotest.Bill_To_Contact_Name__c='J';
        sotest.Bill_To_Contact_Phone__c='8860937435';
        sotest.Bill_To_Country__c='US';
        sotest.Bill_To_State__c='California';
        sotest.Bill_To_Zip_Postal_Code__c='94101';
        sotest.Freight_Mode__c='test';
        sotest.Payment_Terms__c='test';
        sotest.Planned_Install_Date__c=system.today();
        sotest.PO__c='test';
        sotest.Requested_Ship_Date__c=system.today();
        sotest.Ship_To_Address_1__c='47 Jackson Street';
        sotest.Ship_To_City__c='San Francisco';
        sotest.Ship_To_Company__c='Mansa';
        sotest.Ship_To_Contact_Email__c='jitender.padda@mansasys.com';
        sotest.Ship_To_Contact_Name__c='J';
        sotest.Ship_To_Contact_Phone__c='8860937435';
        sotest.Ship_To_Country__c='US';
        sotest.Ship_To_State__c='California';
        sotest.Ship_To_Zip_Postal_Code__c='94101'; 
        sotest.Taxable__c='test';
        sotest.Can_Ship_Early__c='Yes';
        sotest.End_Customer_Address_1__c='47 Jackson Street';
        sotest.End_Customer_City__c='San Francisco';
        sotest.End_Customer_Company__c='Mansa';
        sotest.End_Customer_Contact_Email__c='jitender.padda@mansasys.com';
        sotest.End_Customer_Contact_Name__c='J';
        sotest.End_Customer_Contact_Phone__c='8860937435';
        sotest.End_Customer_Country__c='US';
        sotest.End_Customer_State__c='California';
        sotest.End_Customer_Zip_Postal_Code__c='94101';
        sotest.type__c ='Support Renewal';
           // sotest.Status__c = 'Submitted to OA';
        //insert sotest;
        salesOrderList.add(sotest);
        
        Sales_Order__c sotest1 = new Sales_Order__c();
        sotest1.CurrencyIsoCode='AUD';
        sotest1.Type__c='Revenue';
        sotest1.status__c='New';
        sotest1.Opportunity__c=opp.ID;
        sotest1.Bill_To_Address_1__c='47 Jackson Street';
        sotest1.Bill_To_City__c='San Francisco';
        sotest1.Bill_To_Company__c='Mansa';
        sotest1.Bill_To_Contact_Email__c='test.abc@r4br.com';
        sotest1.Bill_To_Contact_Name__c='J';
        sotest1.Bill_To_Contact_Phone__c='8860937435';
        sotest1.Bill_To_Country__c='US';
        sotest1.Bill_To_State__c='California';
        sotest1.Bill_To_Zip_Postal_Code__c='94101';
        sotest1.Freight_Mode__c='test';
        sotest1.Payment_Terms__c='test';
        sotest1.Planned_Install_Date__c=system.today();
        sotest1.PO__c='test';
        sotest1.Requested_Ship_Date__c=system.today();
        sotest1.Ship_To_Address_1__c='47 Jackson Street';
        sotest1.Ship_To_City__c='San Francisco';
        sotest1.Ship_To_Company__c='Mansa';
        sotest1.Ship_To_Contact_Email__c='test.abc@r4br.com';
        sotest1.Ship_To_Contact_Name__c='J';
        sotest1.Ship_To_Contact_Phone__c='8860937435';
        sotest1.Ship_To_Country__c='US';
        sotest1.Ship_To_State__c='California';
        sotest1.Ship_To_Zip_Postal_Code__c='94101'; 
        sotest1.Taxable__c='test';
        sotest1.Can_Ship_Early__c='Yes';
        sotest1.End_Customer_Address_1__c='47 Jackson Street';
        sotest1.End_Customer_City__c='San Francisco';
        sotest1.End_Customer_Company__c='Mansa';
        sotest1.End_Customer_Contact_Email__c='test.abc@r4br.com';
        sotest1.End_Customer_Contact_Name__c='J';
        sotest1.End_Customer_Contact_Phone__c='8860937435';
        sotest1.End_Customer_Country__c='US';
        sotest1.End_Customer_State__c='California';
        sotest1.End_Customer_Zip_Postal_Code__c='94101';
        sotest1.type__c ='Support Renewal';
        sotest1.Name='test536';      
        //insert sotest1;
        salesOrderList.add(sotest1);
        
        Asset nAssRec=new Asset();
        nAssRec.Accountid=acc.id;
       // nAssRec.Contactid=con.id;
        nAssRec.Name='Test asset';
        nAssRec.SerialNumber='123';
        nAssRec.status='Shipped';
        nAssRec.HPE_Serial_Number__c = '100000007';
        insert nAssRec;
        
       /* Case caseRec=new Case();
        caseRec.AccountId=acc.id;
        caseRec.AssetId=nAssRec.Id;
        caseRec.Status='Open';
        caseRec.Type = 'Problem';
        caseRec.caseCatImpactToCustomer__c = 'Admin Operation Failed or Slow';
        caseRec.Nimble_Version__c='3.4.1.0';
        caseRec.Estimated_Effort__c='2 hours';
        insert caseRec;*/
        
        
        Duplicate_Asset__c du=new Duplicate_Asset__c();
        du.Account__c=acc.id;         
        du.Serial_Number__c='123';
        du.Asset_Name__c='test';
        du.sla__c='Premium';
        du.Support_Start_Date__c=date.today();
        du.Support_End_Date__c=date.today()+12;      
        du.Matched_Asset__c= nAssRec.id;
        du.Sales_Order__c = sotest.Id ;
        du.HPE_Serial_Number__c = '100000000';
        
        
        Duplicate_Asset__c du1=new Duplicate_Asset__c();
        du1.Account__c=acc1.id;         
        du1.Serial_Number__c='123';
        du1.Asset_Name__c='test';
        du1.sla__c='Premium';
        du1.Support_Start_Date__c=date.today();
        du1.Support_End_Date__c=date.today()+12;      
        du1.Matched_Asset__c= nAssRec.id;
        du1.Sales_Order__c = sotest.Id ;
        du1.HPE_Serial_Number__c = '100000001';
        Utility.runDupRecTrigger=true;  
        
        List<Duplicate_Asset__c> duList = new List<Duplicate_Asset__c>();
        duList.add(du);
        duList.add(du1);
        
        Test.startTest();
        
        insert duList;
        
        Test.stopTest();
        
        //du.Support_Start_Date__c=date.today() +3;
        //du.Support_End_Date__c=date.today()+ 9;
        //du.Sales_Order__c  = sotest1.Id;
        
        //update du;
        }
    }
    
    static testMethod void testMethod3() {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        
        Id pricebookId = Test.getStandardPricebookId();
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        
        system.runAs(u){
       
        //insert new AssetJapanCutOffDate__c (Name='CutOffDate', JapanCutOffDate__c = Date.parse('1/2/2018'));
        List<SOLine__mdt> SOLCapacityMapping = [SELECT Id, MasterLabel, SSD_Capacity__c  FROM SOLine__mdt];
        List<Shelf_Product_ID__mdt> shelfPID = [select Product_ID__c,Product_Name__c from Shelf_Product_ID__mdt];
        Account acc=new Account();
        acc.Name='Test account';
        acc.CurrencyIsoCode='USD';
        acc.Type='Distributor';
        insert acc;
        
        Account acc1=new Account();
        acc1.Name='Test account';
        acc1.CurrencyIsoCode='USD';
        acc1.Type='Distributor';
        insert acc1; 
        
        Contact con=new Contact();
        con.lastName='Test Contact';
        con.CurrencyIsoCode='USD';
        con.accountid=acc1.id;
        con.Email='jitender.padda@mansasys.com';
        insert con;
        
        Contact con1=new Contact();
        con1.lastName='Test 1 Contact';
        con1.CurrencyIsoCode='USD';
        con1.accountid=acc.id;
        con1.Email='jitender1.padda455@mansasys.com';
        insert con1;
        
        Opportunity opp= new Opportunity();
        opp.Name='test mansa';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today()+3;
        opp.StageName='Qualified';
        opp.Sales_Area__c='EMEA';
        opp.Reseller_Account__c=acc.id;
        opp.HPE_Opportunity_ID__c = 'OPE-5643217654';
        opp.Pricebook2Id = pricebookId;
        insert opp; 
        
        
        
        Product2 pro=new Product2();
        pro.Name='AFA-GEN5-AFS3';
        pro.ProductCode='AFA-GEN5-AFS3';
        pro.Asset_Type__c='AFS3';
        pro.Family='Expansion Shelves';
        insert pro;
        
       
        Product2 pro1=new Product2();
        pro1.Name='AFS3-92TE';
        Pro1.Component_Code__c='AFS3-92TE';
        pro1.ProductCode='AFS3-92TE';
        pro1.Asset_Type__c='AFS3';
        pro1.Family='Expansion Shelves';
        
        
        insert pro1;
        
        Id pid ;
        for(Shelf_Product_ID__mdt s: shelfPID){
            if(s.Product_Name__c == pro1.Name){
                pid = s.Product_ID__c;
            }
        }
        
        Sales_Order__c sotest1 = new Sales_Order__c();
        sotest1.CurrencyIsoCode='AUD';
        sotest1.Type__c='Revenue';
        sotest1.status__c='New';
        sotest1.Opportunity__c=opp.ID;
        sotest1.Bill_To_Address_1__c='47 Jackson Street';
        sotest1.Bill_To_City__c='San Francisco';
        sotest1.Bill_To_Company__c='Mansa';
        sotest1.Bill_To_Contact_Email__c='test.abc@r4br.com';
        sotest1.Bill_To_Contact_Name__c='J';
        sotest1.Bill_To_Contact_Phone__c='8860937435';
        sotest1.Bill_To_Country__c='US';
        sotest1.Bill_To_State__c='California';
        sotest1.Bill_To_Zip_Postal_Code__c='94101';
        sotest1.Freight_Mode__c='test';
        sotest1.Payment_Terms__c='test';
        sotest1.Planned_Install_Date__c=system.today();
        sotest1.PO__c='test';
        sotest1.Requested_Ship_Date__c=system.today();
        sotest1.Ship_To_Address_1__c='47 Jackson Street';
        sotest1.Ship_To_City__c='San Francisco';
        sotest1.Ship_To_Company__c='Mansa';
        sotest1.Ship_To_Contact_Email__c='test.abc@r4br.com';
        sotest1.Ship_To_Contact_Name__c='J';
        sotest1.Ship_To_Contact_Phone__c='8860937435';
        sotest1.Ship_To_Country__c='US';
        sotest1.Ship_To_State__c='California';
        sotest1.Ship_To_Zip_Postal_Code__c='94101'; 
        sotest1.Taxable__c='test';
        sotest1.Can_Ship_Early__c='Yes';
        sotest1.End_Customer_Address_1__c='47 Jackson Street';
        sotest1.End_Customer_City__c='San Francisco';
        sotest1.End_Customer_Company__c='Mansa';
        sotest1.End_Customer_Contact_Email__c='test.abc@r4br.com';
        sotest1.End_Customer_Contact_Name__c='J';
        sotest1.End_Customer_Contact_Phone__c='8860937435';
        sotest1.End_Customer_Country__c='US';
        sotest1.End_Customer_State__c='California';
        sotest1.End_Customer_Zip_Postal_Code__c='94101';
        sotest1.type__c ='Support Renewal';
        sotest1.Name='test536';
              
        insert sotest1;
        Test.startTest();
        
        Sales_Order_Line__c sol = new Sales_Order_Line__c();       
        sol.Sales_Order__c =  sotest1.id;
        sol.Product__c = pro.id;
        insert sol;
        
        Id  tID =  sol.Id;
        
        system.debug(' *** line 650 ' +tID);
        Sales_Order_Line__c sol1 = new Sales_Order_Line__c();       
        sol1.Sales_Order__c =  sotest1.id;
        sol1.Attached_to_Sales_Line__c = tID;
        sol1.Product__c = pro1.id;
        insert sol1;
        
        Sales_Order_Line__c sol2 = new Sales_Order_Line__c();       
        sol2.Sales_Order__c =  sotest1.id;
        sol2.Attached_to_Sales_Line__c = tID;
        sol2.Product__c = pro1.id;
        insert sol2;
          
        Asset nAssRec=new Asset();
        nAssRec.Accountid=acc.id;
       // nAssRec.Contactid=con.id;
        nAssRec.Name='Test asset';
        nAssRec.SerialNumber='123';
        nAssRec.status='Shipped';
        nAssRec.HPE_Serial_Number__c = '100000002';
        insert nAssRec;
        
       
        
        
        Duplicate_Asset__c du=new Duplicate_Asset__c();
        du.Account__c=acc.id;         
        du.Serial_Number__c='123';
        du.Asset_Name__c='test';
        du.sla__c='Premium';
        du.Support_Start_Date__c=date.today();
        du.Support_End_Date__c=date.today()+12;      
        du.Matched_Asset__c= nAssRec.id;
        du.Sales_Order__c = sotest1.Id ;
        du.HPE_Serial_Number__c = '100000010';
        du.Sales_Order_Line__c = sol.Id;
        du.Sales_Order_Line_ID__c = tID;
        du.Product__c = pid;
        du.Order_Type__c = 'Purchased';
        du.Status__c = 'Shipped';
        
        Duplicate_Asset__c du1=new Duplicate_Asset__c();
        du1.Account__c=acc1.id;         
        du1.Serial_Number__c='123';
        du1.Asset_Name__c='test';
        du1.sla__c='Premium';
        du1.Support_Start_Date__c=date.today();
        du1.Support_End_Date__c=date.today()+12;      
        du1.Matched_Asset__c= nAssRec.id;
        du1.Sales_Order__c = sotest1.Id ;
        du1.HPE_Serial_Number__c = '100000011';
        du1.Order_type__c = 'OEM Hardware';
        Utility.runDupRecTrigger=true;  
        
        List<Duplicate_Asset__c> duList = new List<Duplicate_Asset__c>();
        duList.add(du);
        duList.add(du1);
        
        
        
        insert duList;
        
        Test.stopTest();
        
        //du.Support_Start_Date__c=date.today() +3;
        //du.Support_End_Date__c=date.today()+ 9;
        //du.Sales_Order__c  = sotest1.Id;
        
        //update du;
        }
    }
    
    static testMethod void testMethod4() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        Id pricebookId = Test.getStandardPricebookId();
        
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        
        system.runAs(u){
       
        //insert new AssetJapanCutOffDate__c (Name='CutOffDate', JapanCutOffDate__c = Date.parse('1/2/2018'));
       
        Account acc=new Account();
        acc.Name='Test account';
        acc.CurrencyIsoCode='USD';
        acc.Type='Distributor';
        insert acc;
        
        Account acc1=new Account();
        acc1.Name='Test account';
        acc1.CurrencyIsoCode='USD';
        acc1.Type='Distributor';
        insert acc1; 
        
        Contact con=new Contact();
        con.lastName='Test Contact';
        con.CurrencyIsoCode='USD';
        con.accountid=acc1.id;
        con.Email='jitender.padda@mansasys.com';
        insert con;
        
        
        Opportunity opp= new Opportunity();
        opp.Name='test mansa';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today()+3;
        opp.StageName='Qualified';
        opp.Sales_Area__c='EMEA';
        opp.Reseller_Account__c=acc.id;
        opp.HPE_Opportunity_ID__c = 'OPE-5643216777';
        opp.Pricebook2Id = pricebookId;
        insert opp; 
       
        Product2 pro=new Product2();
        pro.Name='RF-CTL-T2-PLS-G5-5YR';
        pro.ProductCode='RF-CTL-T2-PLS-G5-5YR';
        pro.infosight_identifier__c='HF20';
        pro.Family='Support';       
        insert pro;
        
        product2 pro2 = new Product2();
        pro2.name = 'SLA-4HR-RFRSH';
        pro2.ProductCode = 'SLA-4HR-RFRSH';
        pro2.Family= 'Support';
        insert pro2;
        
        Sales_Order__c sotest1 = new Sales_Order__c();
        sotest1.CurrencyIsoCode='AUD';
        sotest1.Type__c='Revenue';
        sotest1.status__c='New';
        sotest1.Opportunity__c=opp.ID;
        sotest1.Bill_To_Address_1__c='47 Jackson Street';
        sotest1.Bill_To_City__c='San Francisco';
        sotest1.Bill_To_Company__c='Mansa';
        sotest1.Bill_To_Contact_Email__c='test.abc@r4br.com';
        sotest1.Bill_To_Contact_Name__c='J';
        sotest1.Bill_To_Contact_Phone__c='8860937435';
        sotest1.Bill_To_Country__c='US';
        sotest1.Bill_To_State__c='California';
        sotest1.Bill_To_Zip_Postal_Code__c='94101';
        sotest1.Freight_Mode__c='test';
        sotest1.Payment_Terms__c='test';
        sotest1.Planned_Install_Date__c=system.today();
        sotest1.PO__c='test';
        sotest1.Requested_Ship_Date__c=system.today();
        sotest1.Ship_To_Address_1__c='47 Jackson Street';
        sotest1.Ship_To_City__c='San Francisco';
        sotest1.Ship_To_Company__c='Mansa';
        sotest1.Ship_To_Contact_Email__c='test.abc@r4br.com';
        sotest1.Ship_To_Contact_Name__c='J';
        sotest1.Ship_To_Contact_Phone__c='8860937435';
        sotest1.Ship_To_Country__c='US';
        sotest1.Ship_To_State__c='California';
        sotest1.Ship_To_Zip_Postal_Code__c='94101'; 
        sotest1.Taxable__c='test';
        sotest1.Can_Ship_Early__c='Yes';
        sotest1.End_Customer_Address_1__c='47 Jackson Street';
        sotest1.End_Customer_City__c='San Francisco';
        sotest1.End_Customer_Company__c='Mansa';
        sotest1.End_Customer_Contact_Email__c='test.abc@r4br.com';
        sotest1.End_Customer_Contact_Name__c='J';
        sotest1.End_Customer_Contact_Phone__c='8860937435';
        sotest1.End_Customer_Country__c='US';
        sotest1.End_Customer_State__c='California';
        sotest1.End_Customer_Zip_Postal_Code__c='94101';
        sotest1.type__c ='Support Renewal';
        sotest1.Name='test536';
              
        insert sotest1;
        
        Test.startTest();
        
        Sales_Order_Line__c sol = new Sales_Order_Line__c();       
        sol.Sales_Order__c =  sotest1.id;
        sol.Product__c = pro2.id;
        insert sol;
        
        Id  tID =  sol.Id;
       
        Sales_Order_Line__c sol1 = new Sales_Order_Line__c();       
        sol1.Sales_Order__c =  sotest1.id;
        sol1.Product__c = pro.id;
        sol1.Attached_to_Sales_Line__c = tID;
        insert sol1;
         
       /* Asset nAssRec=new Asset();
        nAssRec.Accountid=acc1.id;
        nAssRec.Contactid=con.id;
        nAssRec.Name='Test asset';
        nAssRec.SerialNumber='123';
        nAssRec.status='Shipped';
        nAssRec.HPE_Serial_Number__c = '100000003';
        insert nAssRec;
        */
        /*Case caseRec=new Case();
        caseRec.AccountId=acc1.id;
        caseRec.ContactId=con.id;
        caseRec.AssetId=nAssRec.Id;
        caseRec.Status='Open';
        caseRec.Type = 'Problem';
        caseRec.caseCatImpactToCustomer__c = 'Admin Operation Failed or Slow';
        caseRec.Nimble_Version__c='3.4.1.0';
        caseRec.Estimated_Effort__c='2 hours';
        insert caseRec;
        
        Case caseRec1=new Case();
        caseRec1.AccountId=acc1.id;
        caseRec.ContactId=con.id;
        caseRec1.AssetId=nAssRec.Id;
        caseRec1.Status='Open';
        caseRec1.Type = 'Problem';
        caseRec1.caseCatImpactToCustomer__c = 'Admin Operation Failed or Slow';
        caseRec1.Nimble_Version__c='3.4.1.0';
        caseRec1.Estimated_Effort__c='2 hours';
        insert caseRec1;*/
        
        
        Duplicate_Asset__c du=new Duplicate_Asset__c();
        du.Account__c=acc.id;         
        du.Serial_Number__c='T-123';
        du.Asset_Name__c='test-123';
        du.sla__c='Premium';
        du.Support_Start_Date__c=date.today();
        du.Support_End_Date__c=date.today()+12;      
        //du.Matched_Asset__c= nAssRec.id;
        du.Sales_Order__c = sotest1.Id ;
        du.Sales_Order_Line__c = sol.Id;
        du.Sales_Order_Line_ID__c = tID;
        du.Product__c = pro.Id;
        du.Order_Type__c = 'Purchased';
        du.Status__c = 'Shipped';
        du.HPE_Serial_Number__c = '100000004';
        
        
        Duplicate_Asset__c du1=new Duplicate_Asset__c();
        du1.Account__c=acc1.id;         
        du1.Serial_Number__c='123';
        du1.Asset_Name__c='test';
        du1.sla__c='Premium';
        du1.Support_Start_Date__c=date.today();
        du1.Support_End_Date__c=date.today()+12;      
       //du1.Matched_Asset__c= nAssRec.id;
        du1.Sales_Order__c = sotest1.Id ;
        du1.Order_Type__c = 'Purchased';
        du1.Status__c = 'Shipped';
        du1.HPE_Serial_Number__c = '100000004';
        Utility.runDupRecTrigger=true;  
        
        List<Duplicate_Asset__c> duList = new List<Duplicate_Asset__c>();
        duList.add(du);
        duList.add(du1);
        
        
        
        insert duList;
        
        //BatchDuplicateAssetRecord bcDupAssets = new BatchDuplicateAssetRecord(); 
        //database.executebatch(bcDupAssets,3);
        
        //BatchDuplicateAssetRecordHandler bcDupHandler = new BatchDuplicateAssetRecordHandler();
        Test.stopTest();
        
        //du.Support_Start_Date__c=date.today() +3;
        //du.Support_End_Date__c=date.today()+ 9;
        //du.Sales_Order__c  = sotest1.Id;
        
        //update du;
        
        }
    }
    
    
    static testMethod void testMethod5() {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        
        Id pricebookId = Test.getStandardPricebookId();
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        
        system.runAs(u){
       
        //insert new AssetJapanCutOffDate__c (Name='CutOffDate', JapanCutOffDate__c = Date.parse('1/2/2018'));
       
        Account acc=new Account();
        acc.Name='Test account';
        acc.CurrencyIsoCode='USD';
        acc.Type='Distributor';
        insert acc;
        
        Account acc1=new Account();
        acc1.Name='Test account';
        acc1.CurrencyIsoCode='USD';
        acc1.Type='Distributor';
        insert acc1; 
        
        Contact con=new Contact();
        con.lastName='Test Contact';
        con.CurrencyIsoCode='USD';
        con.accountid=acc1.id;
        con.Email='jitender.padda@mansasys.com';
        insert con;
        
        Contact con1=new Contact();
        con1.lastName='Test 1 Contact';
        con1.CurrencyIsoCode='USD';
        con1.accountid=acc.id;
        con1.Email='jitender1.padda455@mansasys.com';
        insert con1;
        
        Opportunity opp= new Opportunity();
        opp.Name='test mansa';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today()+3;
        opp.StageName='Qualified';
        opp.Sales_Area__c='EMEA';
        opp.Reseller_Account__c=acc.id;
        opp.HPE_Opportunity_ID__c = 'OPE-5643217654';
        opp.Pricebook2Id = pricebookId;
        insert opp; 
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 pro=new Product2();
        pro.Name='ES3-H210T';
        pro.ProductCode='ES3-H210T';
        pro.Asset_Type__c='Expansion Shelf 3';
        pro.Family='Expansion Shelves';
        insert pro;
        
       
        Product2 pro1=new Product2();
        pro1.Name='ES3-H210TE';
        Pro1.Component_Code__c='ES3-H210TE';
        pro1.ProductCode='ES3-H210TE';
        pro1.Asset_Type__c='Expansion Shelf 3';
        pro1.Family='Expansion Shelves';
        
        
        insert pro1;
        Sales_Order__c sotest1 = new Sales_Order__c();
        sotest1.CurrencyIsoCode='AUD';
        sotest1.Type__c='Revenue';
        sotest1.status__c='New';
        sotest1.Opportunity__c=opp.ID;
        sotest1.Bill_To_Address_1__c='47 Jackson Street';
        sotest1.Bill_To_City__c='San Francisco';
        sotest1.Bill_To_Company__c='Mansa';
        sotest1.Bill_To_Contact_Email__c='test.abc@r4br.com';
        sotest1.Bill_To_Contact_Name__c='J';
        sotest1.Bill_To_Contact_Phone__c='8860937435';
        sotest1.Bill_To_Country__c='US';
        sotest1.Bill_To_State__c='California';
        sotest1.Bill_To_Zip_Postal_Code__c='94101';
        sotest1.Freight_Mode__c='test';
        sotest1.Payment_Terms__c='test';
        sotest1.Planned_Install_Date__c=system.today();
        sotest1.PO__c='test';
        sotest1.Requested_Ship_Date__c=system.today();
        sotest1.Ship_To_Address_1__c='47 Jackson Street';
        sotest1.Ship_To_City__c='San Francisco';
        sotest1.Ship_To_Company__c='Mansa';
        sotest1.Ship_To_Contact_Email__c='test.abc@r4br.com';
        sotest1.Ship_To_Contact_Name__c='J';
        sotest1.Ship_To_Contact_Phone__c='8860937435';
        sotest1.Ship_To_Country__c='US';
        sotest1.Ship_To_State__c='California';
        sotest1.Ship_To_Zip_Postal_Code__c='94101'; 
        sotest1.Taxable__c='test';
        sotest1.Can_Ship_Early__c='Yes';
        sotest1.End_Customer_Address_1__c='47 Jackson Street';
        sotest1.End_Customer_City__c='San Francisco';
        sotest1.End_Customer_Company__c='Mansa';
        sotest1.End_Customer_Contact_Email__c='test.abc@r4br.com';
        sotest1.End_Customer_Contact_Name__c='J';
        sotest1.End_Customer_Contact_Phone__c='8860937435';
        sotest1.End_Customer_Country__c='US';
        sotest1.End_Customer_State__c='California';
        sotest1.End_Customer_Zip_Postal_Code__c='94101';
        sotest1.type__c ='Support Renewal';
        sotest1.Name='test536';
              
        insert sotest1;
        Test.startTest();
        
        Sales_Order_Line__c sol = new Sales_Order_Line__c();       
        sol.Sales_Order__c =  sotest1.id;
        sol.Product__c = pro.id;
        insert sol;
        
        Id  tID =  sol.Id;
        
        
        Sales_Order_Line__c sol1 = new Sales_Order_Line__c();       
        sol1.Sales_Order__c =  sotest1.id;
        sol1.Attached_to_Sales_Line__c = tID;
        sol1.Product__c = pro1.id;
        insert sol1;
        
        
        Sales_Order_Line__c sol2 = new Sales_Order_Line__c();       
        sol2.Sales_Order__c =  sotest1.id;
        sol2.Attached_to_Sales_Line__c = tID;
        sol2.Product__c = pro1.id;
        insert sol2;
        
        Duplicate_Asset__c du1=new Duplicate_Asset__c();
        du1.Account__c=acc1.id;         
       // du1.Serial_Number__c='123';
        du1.Asset_Name__c='test';
        du1.sla__c='Premium';
        du1.Support_Start_Date__c=date.today();
        du1.Support_End_Date__c=date.today()+12;
        du1.Sales_Order_Line__c = sol.Id;
        du1.Product__c = pro.Id;
        du1.Sales_Order_Line_ID__c = tID;
        du1.Sales_Order__c = sotest1.Id ;
        du1.HPE_Serial_Number__c = '100000011';
        du1.Order_type__c = 'OEM Hardware';
        
        insert du1;
        
        Utility.runDupRecTrigger=true;  
        
        
        
        Test.stopTest();
        
        //du.Support_Start_Date__c=date.today() +3;
        //du.Support_End_Date__c=date.today()+ 9;
        //du.Sales_Order__c  = sotest1.Id;
        
        //update du;
        }
    }
    /*
    static testMethod void testBatchDuplicateAssetRecord()
    {
      String CRON_EXP =  '0 0 0 15 3 ? 2022';
      // Schedule the test job
      String jobId = System.schedule('BatchDuplicateAssetRecord_Schedule',
                        CRON_EXP, 
                        new BatchDuplicateAssetRecord());
    }*/
}