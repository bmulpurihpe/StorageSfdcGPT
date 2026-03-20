@isTest(seeAllData=false)
private class Test_Asset_nRec_FutureClass{
    static testmethod void mytest1(){
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
            con.Email='yesha@hpe.com';
            insert con;
            
            Contact con1=new Contact();
            con1.lastName='Test 1 Contact';
            con1.CurrencyIsoCode='USD';
            con1.accountid=acc.id;
            con1.Email='yesha@hpe.com';
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
            
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'NEC_Definition__c' and Name = 'Asset'].Id;
            
            NEC_Definition__c ndef = new NEC_Definition__c();
            ndef.Name = 'PRO-INSTALL-ARRAY';
            ndef.necGroup__c = 'Asset';
            ndef.necLabel__c = 'Installation';
            ndef.necFieldTypePicklistItems__c = 'Text';
            ndef.necDefaultValue__c = 'Installation';
            ndef.RecordtypeId = strRecordTypeId ;
            ndef.necDescription__c = 'Provide Installation services data in Nimble SFDC';
            ndef.necFieldType__c = 'Text';
            insert ndef;
            
            Product2 pro=new Product2();
            pro.Name='AFA-GEN5-AFS3';
            pro.ProductCode='AFA-GEN5-AFS3';
            pro.Asset_Type__c='AFS3';
            pro.Family='Expansion Shelves';
            pro.IsActive = true;
            insert pro;
            
           
            Product2 pro1=new Product2();
            pro1.Name='PRO-INSTALL-ARRAY';
            Pro1.Component_Code__c='PRO-INSTALL-ARRAY';
            pro1.ProductCode='PRO-INSTALL-ARRAY';
            pro1.Family='Services';
            
            pro1.IsActive = true;
            insert pro1;
            
            Id pid ;
            
            
            Sales_Order__c sotest1 = new Sales_Order__c();
            sotest1.CurrencyIsoCode='AUD';
            sotest1.Type__c='Revenue';
            sotest1.status__c='New';
            sotest1.Opportunity__c=opp.ID;
            sotest1.Bill_To_Address_1__c='47 Jackson Street';
            sotest1.Bill_To_City__c='San Francisco';
            sotest1.Bill_To_Company__c='Mansa';
            sotest1.Bill_To_Contact_Email__c='yesha.benegal@hpe.com';
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
            sotest1.Ship_To_Contact_Email__c='ybenegal@test.com';
            sotest1.Ship_To_Contact_Name__c='Y';
            sotest1.Ship_To_Contact_Phone__c='8860937435';
            sotest1.Ship_To_Country__c='US';
            sotest1.Ship_To_State__c='California';
            sotest1.Ship_To_Zip_Postal_Code__c='94101'; 
            sotest1.Taxable__c='test';
            sotest1.Can_Ship_Early__c='Yes';
            sotest1.End_Customer_Address_1__c='6980 american center drive';
            sotest1.End_Customer_City__c='Belmont';
            sotest1.End_Customer_Company__c='CloudFountain';
            sotest1.End_Customer_Contact_Email__c='yeshab@test.com';
            sotest1.End_Customer_Contact_Name__c='J';
            sotest1.End_Customer_Contact_Phone__c='8860937435';
            sotest1.End_Customer_Country__c='US';
            sotest1.End_Customer_State__c='California';
            sotest1.End_Customer_Zip_Postal_Code__c='94101';
            sotest1.type__c ='Support Renewal';
            sotest1.Name='test536';
                  
            insert sotest1;
            
            Id soID =  sotest1.id;
            
            
            
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
            
            Test.startTest();
            
            Asset nAssRec=new Asset();
            nAssRec.Accountid=acc.id;
           // nAssRec.Contactid=con.id;
            nAssRec.Name='Test asset';
            nAssRec.SerialNumber='123';
            nAssRec.status='Shipped';
            nAssRec.HPE_Serial_Number__c = '100000002';
            nAssRec.Sales_Order_Line_ID__c = tID;
            nAssRec.Sales_Order__c = soID;
            insert nAssRec;
            
            test.stoptest();
        }
    }
    
    static testmethod void mytest2(){
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
        
            
            Account Act1 = new Account( Name = 'Test Ac', Datacenter_Care__c = false, ACM_Service_Purchased__c =false);
            insert Act1;
        
            Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'Jane', email='yesha.benegal@hpe.com',
                                             AccountId = act1.Id);
            insert con1;
        
            Opportunity Opp2 = new Opportunity(Accountid = Act1.id,name ='Test Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'OPE-0008891123', Pricebook2Id = pricebookId);
                          
            insert Opp2;
            
            List<Product2> lstProduct = new List<Product2>();
            
            Product2 pro11=new Product2();
            pro11.Name='PCI-16FCx1C';
            pro11.Component_Code__c='2F';
            pro11.ProductCode='PCI-16FCx1C';
            pro11.Asset_Type__c='AFA2';
            pro11.infosight_identifier__c='';
            pro11.HPE_SKU__C='Q8B90B';
            pro11.Family='All Flash Array Gen5';
            pro11.IsActive = true;
            lstProduct.add(pro11);
            
            Product2 pro12=new Product2();
            pro12.Name='AF20Q';
            pro12.Component_Code__c='AF20Q';
            pro12.ProductCode='AF20Q';
            pro12.Asset_Type__c='AFA2';
            pro12.infosight_identifier__c='AF20Q';
            pro12.HPE_SKU__C='Q8H73A';
            pro12.Family='All Flash Array Gen5';
            pro12.IsActive = true;
            lstProduct.add(pro12);
            
            Product2 pro13=new Product2();
            pro13.Name='AFQ-11TXC';
            pro13.Component_Code__c='11T';
            pro13.ProductCode='AFQ-11TXC';
            pro13.Asset_Type__c='AFA2';
            pro13.infosight_identifier__c='11520F';
            pro13.HPE_SKU__C='Q8H79A';
            pro13.Family='All Flash Array Gen5';
            pro13.IsActive = true;
            lstProduct.add(pro13);
            
            insert lstProduct;
        
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'NEC_Definition__c' and Name = 'Asset'].Id;
            NEC_Definition__c ndef = new NEC_Definition__c();
            ndef.Name = '5WX HPE Nimble Storage dHCI Startup SVC';
            ndef.necGroup__c = 'Asset';
            ndef.necLabel__c = 'Installation';
            ndef.necFieldTypePicklistItems__c = 'Text';
            ndef.necDefaultValue__c = 'Installation';
            ndef.RecordtypeId = strRecordTypeId ;
            ndef.necDescription__c = 'Provide Installation services data in Nimble SFDC';
            ndef.necFieldType__c = 'Text';
            insert ndef;
            
            NEC_Definition__c ndef1 = new NEC_Definition__c();
            ndef1.Name = 'HPE Technical Installation Startup SVC2';
            ndef1.necGroup__c = 'Asset';
            ndef1.necLabel__c = 'Installation';
            ndef1.necFieldTypePicklistItems__c = 'Text';
            ndef1.necDefaultValue__c = 'Installation';
            ndef1.RecordtypeId = strRecordTypeId ;
            ndef1.necDescription__c = 'Provide Installation services data in Nimble SFDC';
            ndef1.necFieldType__c = 'Text';
            insert ndef1;
            
            Nimble_Offer_Code__c  noc3 = new Nimble_Offer_Code__c (Concierge_Manager__c  = false ,HPE_Support_Package_SKU__c ='HT6Z6AC',
                                                             HPE_Support_Package_SKU_Description__c ='HPE NS Proactive Supp Manager Tier A SVC',
                                                             Concierge_Manager_Tier__c = 'C'
                                    );
            insert noc3;
            
             Asset_Stage__c ast1 = new Asset_Stage__c(
                Dynamic_SKU__c= 'AF20Q-2F-11T-1',
                Controller__c = 'Q8H73A',
                Networking__c  = 'Q8B90B',
                SSD_Capacity__c = 'Q8H79A',
                End_Customer_Account_Name__c = 'CloudFountain',
                End_Customer_Account_Ref_ID__c = 'TestCF-23422',
                End_Customer_Ship_to_Contact_Email__c = 'yesha@hpe.com',
                End_Customer_Ship_to_Contact_Name__c = 'YBenegal',
                HPE_Opportunity_ID__c = 'OPE-0008891123',
                HPE_Order_Number__c = 'OTest1',
                HPE_Product_SKU__c = 'Q8H73A',
                HPE_Quote_Number__c = 'QTest1',
                HPE_Serial_Number__c = '500NMTESTHPE',
                Nimble_Serial_Number__c ='AF-TESTHPE',
                Install_Address_City__c = 'Test',
                Install_Address_Country__c = 'Test',
                ES_API_Completed__c = true,
                Install_Address_State__c = 'MA',
                Install_Address_Street1__c = '6 concord Ave',
                Install_Address_Street2__c = 'Concord',
                //Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
                Order_Status__c = 'Shipped',
                Order_Type__c = 'Test',
                Product_Line__c = 'Test',
                //Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
                SLA_Support_Level__c = 'HT6Z6AC',
                Status__c = 'New',
                Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
                Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
                Support_Term__c = null,
                Future_Contract_SLA__c = 'HT6Z6AC',
                Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),            
                Concierge_Manager__c  = false,
                concierge_Manager_SKU__c = 'HT6Z6AC',
                HPE_Install_Service_SKU__c = 'HA114A1,HA124A1',
                HPE_Install_Services_Ordered__c = True,
                Legacy_Asset__c = false
            );
            
            insert ast1;
        }
    }
    
    static testmethod void mytest3(){
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
        
            
            Account Act1 = new Account( Name = 'Test Ac', Datacenter_Care__c = false, ACM_Service_Purchased__c =false);
            insert Act1;
        
            Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'Jane', email='yesha.benegal@hpe.com',
                                             AccountId = act1.Id);
            insert con1;
        
            Opportunity Opp2 = new Opportunity(Accountid = Act1.id,name ='Test Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'OPE-0008891123', Pricebook2Id = pricebookId);
                          
            insert Opp2;
            
            List<Product2> lstProduct = new List<Product2>();
            
            Product2 pro11=new Product2();
            pro11.Name='PCI-16FCx1C';
            pro11.Component_Code__c='2F';
            pro11.ProductCode='PCI-16FCx1C';
            pro11.Asset_Type__c='AFA2';
            pro11.infosight_identifier__c='';
            pro11.HPE_SKU__C='Q8B90B';
            pro11.Family='All Flash Array Gen5';
            pro11.IsActive = true;
            lstProduct.add(pro11);
            
            Product2 pro12=new Product2();
            pro12.Name='AF20Q';
            pro12.Component_Code__c='AF20Q';
            pro12.ProductCode='AF20Q';
            pro12.Asset_Type__c='AFA2';
            pro12.infosight_identifier__c='AF20Q';
            pro12.HPE_SKU__C='Q8H73A';
            pro12.Family='All Flash Array Gen5';
            pro12.IsActive = true;
            lstProduct.add(pro12);
            
            Product2 pro13=new Product2();
            pro13.Name='AFQ-11TXC';
            pro13.Component_Code__c='11T';
            pro13.ProductCode='AFQ-11TXC';
            pro13.Asset_Type__c='AFA2';
            pro13.infosight_identifier__c='11520F';
            pro13.HPE_SKU__C='Q8H79A';
            pro13.Family='All Flash Array Gen5';
            pro13.IsActive = true;
            lstProduct.add(pro13);
            
            insert lstProduct;
        
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'NEC_Definition__c' and Name = 'Asset'].Id;
            NEC_Definition__c ndef = new NEC_Definition__c();
            ndef.Name = '5WX HPE Nimble Storage dHCI Startup SVC';
            ndef.necGroup__c = 'Asset';
            ndef.necLabel__c = 'Installation';
            ndef.necFieldTypePicklistItems__c = 'Text';
            ndef.necDefaultValue__c = 'Installation';
            ndef.RecordtypeId = strRecordTypeId ;
            ndef.necDescription__c = 'Provide Installation services data in Nimble SFDC';
            ndef.necFieldType__c = 'Text';
            insert ndef;
            
            NEC_Definition__c ndef1 = new NEC_Definition__c();
            ndef1.Name = 'HPE Technical Installation Startup SVC2';
            ndef1.necGroup__c = 'Asset';
            ndef1.necLabel__c = 'Installation';
            ndef1.necFieldTypePicklistItems__c = 'Text';
            ndef1.necDefaultValue__c = 'Installation';
            ndef1.RecordtypeId = strRecordTypeId ;
            ndef1.necDescription__c = 'Provide Installation services data in Nimble SFDC';
            ndef1.necFieldType__c = 'Text';
            insert ndef1;
            
            Nimble_Offer_Code__c  noc3 = new Nimble_Offer_Code__c (Concierge_Manager__c  = false ,HPE_Support_Package_SKU__c ='HT6Z6AC',
                                                             HPE_Support_Package_SKU_Description__c ='HPE NS Proactive Supp Manager Tier A SVC',
                                                             Concierge_Manager_Tier__c = 'C'
                                    );
            insert noc3;
            
             Asset_Stage__c ast1 = new Asset_Stage__c(
                Dynamic_SKU__c= 'AF20Q-2F-11T-1',
                Controller__c = 'Q8H73A',
                Networking__c  = 'Q8B90B',
                SSD_Capacity__c = 'Q8H79A',
                End_Customer_Account_Name__c = 'CloudFountain',
                End_Customer_Account_Ref_ID__c = 'TestCF-23422',
                End_Customer_Ship_to_Contact_Email__c = 'yesha@hpe.com',
                End_Customer_Ship_to_Contact_Name__c = 'YBenegal',
                HPE_Opportunity_ID__c = 'OPE-0008891123',
                HPE_Order_Number__c = 'OTest1',
                HPE_Product_SKU__c = 'Q8H73A',
                HPE_Quote_Number__c = 'QTest1',
                HPE_Serial_Number__c = '500NMTESTHPE',
                Nimble_Serial_Number__c ='AF-TESTHPE',
                Install_Address_City__c = 'Test',
                Install_Address_Country__c = 'Test',
                ES_API_Completed__c = true,
                Install_Address_State__c = 'MA',
                Install_Address_Street1__c = '6 concord Ave',
                Install_Address_Street2__c = 'Concord',
                //Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
                Order_Status__c = 'Shipped',
                Order_Type__c = 'Test',
                Product_Line__c = 'Test',
                //Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
                SLA_Support_Level__c = 'HT6Z6AC',
                Status__c = 'New',
                Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
                Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
                Support_Term__c = null,
                Future_Contract_SLA__c = 'HT6Z6AC',
                Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),            
                Concierge_Manager__c  = false,
                concierge_Manager_SKU__c = 'HT6Z6AC',
                HPE_Install_Service_SKU__c = 'HA114A1',
                HPE_Install_Services_Ordered__c = True,
                Legacy_Asset__c = false
            );
            
            insert ast1;
        }
    }
}