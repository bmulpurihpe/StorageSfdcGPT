@isTest
private class Test_QuoteTriggerHelperClass {
    @testSetup static void setupData() {
    
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
    static testMethod void myUnitTest() {
          User adminUser=[Select ID from User where Profile.Name='System Administrator II (pw never expires)' and isActive=True and UserRoleID!=null limit 1];
          Account acc;
          Account Distacc;
          Contact c;
          SBQQ__Quote__c quoteTest;
          User user = new User();    
          
          System.runAs(adminUser){
              Distacc=new Account();
              Distacc.Name='Disti mansa';
              Distacc.Type='Distributor';
              insert Distacc;
              
              acc=new Account();
              acc.Name='test mansa';
              acc.Type='Distributor';
              acc.Distributor__c=Distacc.Id;
              insert acc;
              c = new Contact(LastName = 'Contact Last Name', AccountId = acc.id);
              insert c;
          
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
              user.ContactId = c.Id;
              insert user;
              
              //Added by Unnat on May 7, 2017 for Advanced Approvals
              //assign permission set to Disti users for Advanced Approvals
              PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'AdvancedApprovalsUser'];
              PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = user.Id;
                psa.PermissionSetId = ps.Id;
              insert psa;
          }
          System.RunAs(user) {
            
            Opportunity opp= new Opportunity();
            opp.Name='test mansa';
            opp.AccountId=acc.id;
            opp.CloseDate=system.today()+3;
            opp.StageName='Qualified';
            opp.Sales_Area__c='EMEA';
            opp.Reseller_Account__c=acc.id;
            /*opp.SoD_Exchange_Unit_Price__c = 23.5 ;
            opp.SoD_File_Server_Unit_Price__c = 23.5 ;
            opp.SoD_Database_Unit_Price__c = 23.5 ;
            opp.SoD_Sharepoint_Unit_Price__c = 23.5 ;
            opp.SoD_Virtual_Desktop_Unit_Price__c = 23.5 ;
            opp.SoD_Virtual_Server_Unit_Price__c = 23.5 ;
            opp.SoD_Price__c = 33.5; */
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
            
            List<SBQQ__Quote__c> quo = new List <SBQQ__Quote__c>();
            
            quoteTest=new SBQQ__Quote__c();
            //quoteTest.SBQQ__Opportunity__c=opp.ID;
            if (SBQQ__Quote__c.SObjectType.getDescribe().fields.getMap().keySet().contains('SBQQ__Opportunity__c') != null) {
                quoteTest.put('SBQQ__Opportunity__c', opp.Id);     
            }
            
            quoteTest.SBQQ__Opportunity2__c=opp.ID;
            quoteTest.SBQQ__Type__c='Revenue';
            quoteTest.SBQQ__Status__c='Draft';
            quoteTest.Quote_Produced_or__c='Distributor';
            quoteTest.SBQQ__Primary__c=true;
            quo.add(quoteTest);
                    
            /*SBQQ__Quote__c quoteTest1=new SBQQ__Quote__c();
            quoteTest1.SBQQ__Opportunity2__c=opp.ID;
            quoteTest1.SBQQ__Type__c='Revenue';
            quoteTest1.SBQQ__Status__c='Approved';
            quoteTest1.Quote_Produced_or__c='Distributor';
            quoteTest1.SBQQ__Primary__c=true;
            quo.add(quoteTest1);*/
            utility.runDupRecTrigger=true;
            insert quo;
            
            System.Test.startTest();
            
            
            Product2 prod = new Product2(Name='Test',IsActive=true,Productcode='SOD-PLATINUM-AF-1M');
            insert prod;
            
            SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quo[0].Id,SBQQ__Product__c=prod.Id);
            line.SBQQ__ListPrice__c = 1000;
            line.BOM_Line_Number__c='1';
            line.SBQQ__Quantity__c = 1;
            line.Product_Type__c='Hardware';
            line.SBQQ__RegularPrice__c=3000;
            line.SBQQ__NetPrice__c=2000;
            line.SoD_Unit_Price__c =33;
            //line.SoD_Pricing__c = 'Storage Based Pricing';
            insert line;
            
            SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quo[0].Id,SBQQ__Product__c=prod.Id);
            line1.SBQQ__ListPrice__c = 1000;
            line1.BOM_Line_Number__c='1';
            line1.SBQQ__Quantity__c = 1;
            line1.Product_Type__c='Hardware';
            line1.SBQQ__RegularPrice__c=3000;
            line1.SBQQ__NetPrice__c=2000;
            line1.SBQQ__SubscriptionTerm__c = 45;
            line1.SoD_Unit_Price__c =33;
            //line1.Monthly_Net_Price__c = 56;
            //line1.SoD_Pricing__c = 'App Based Pricing';
            insert line1;
            
            quo[0].SBQQ__Status__c='Draft';
            quo[0].SBQQ__Primary__c=false;
            quo[0].Record_ID_Custom__c = quo[0].Id;
            //quoteTest.Total_Discount_Percent_Hardware__c=45;
           //quoteTest.Total_Discount_Percent_Support__c=22;
           // utility.runDupRecTrigger=true;
           // update quoteTest;
            
            quo[0].Record_ID_Custom__c='';
            quo[0].Counter__c=4;
            quo[0].Quote_Reviewed__c=true;
            utility.runDupRecTrigger=true;
            update quo[0];
        }
            
        System.Test.stopTest();  
    }
}