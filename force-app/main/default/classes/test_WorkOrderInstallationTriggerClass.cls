@isTest(SeeAllData=true) 

private class test_WorkOrderInstallationTriggerClass{
/*
    static testMethod void myUnitTest(){
      
        Account acc = new Account(); 
        acc.CurrencyIsoCode = 'EUR';
        acc.Name= 'test';
        insert acc;
        
        Opportunity opp = new opportunity();
        opp.name = 'test';
        opp.AccountId = acc.id;
        opp.Type = 'New Business';
        opp.Sales_Area__c = 'NA Central TOLA';
        opp.CloseDate = System.today();
        opp.StageName = '2-Qualified';
        opp.CurrencyIsoCode = 'EUR';
        opp.Special_Instructions_for_Installation__c = 'test';
        opp.Installation_security_requirements__c = 'None';
        opp.type = 'New Business';
        insert opp;
        
        opp.Special_Instructions_for_Installation__c = 'test_update';
        update opp;
        
        opp.Special_Instructions_for_Installation__c = 'test_update';
        update opp;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'SysAdm', Email='systemadmin@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='systemadmin12@testorg.com', Phone = '678836387');
                          insert u;   
                          
        OpportunityTeamMember oppMember = new OpportunityTeamMember();
        oppMember.OpportunityId = opp.id;
        oppMember.TeamMemberRole = 'Account Executive (AE)';
        oppMember.userId = u.id;
        insert oppMember;
        OpportunityTeamMember oppMember1 = new OpportunityTeamMember();
        oppMember1.OpportunityId = opp.id;
        oppMember1.TeamMemberRole = 'Systems Engineer (SE)';
        oppMember1.userId = u.id;
        insert oppMember1;
        
        Sales_Order__c so = new Sales_Order__c();
        so.Name = 'test';
        so.Type__c = 'Beta';
        so.CurrencyIsoCode = 'EUR';
        so.Opportunity__c = opp.id;
        so.Shipment_Date__c = Date.newInstance(2015,7,27);
        so.Actual_Shipment_Date__c = Date.newInstance(2015,7,27);
        so.Tracking_Number__c = '5247';
        so.SO_Number__c='SO123';
        so.Shipping_Agent_Code__c = 'JIT';
        so.End_Customer_Contact_Name__c = 'test';
        so.End_Customer_Contact_Email__c = 'test@test.com';
        so.End_Customer_Contact_Phone__c = '897372';
        so.Ship_To_Company__c = 'test';
        so.Ship_To_Contact_Name__c = 'test';
        so.Ship_To_Contact_Phone__c = '87988098';
        so.Ship_To_Contact_Email__c = 'test@test.com';
        so.Ship_To_Address_1__c = '562 test';
        so.Ship_To_Address_2__c = '654 test';
        so.Ship_To_City__c = 'test';
        so.Ship_to_State__c = 'test';
        so.Ship_To_Zip_Postal_Code__c = '65787';
        so.Ship_To_Country__c = 'india';
        so.Ship_To_Contact_Name__c = 'test';
        insert so;
        
        so.Shipment_Date__c = Date.newInstance(2016,7,27);
        so.Actual_Shipment_Date__c = Date.newInstance(2016,7,27);
        so.Tracking_Number__c = '5244';
        so.Shipping_Agent_Code__c = 'AERO';
        so.Pro_Install_Flag__c = true;
        System.debug('test-----');         
        update so;     
           
        Sales_Order_Line__c soLine = new Sales_Order_Line__c();
        soLine.Sales_Order__c = so.id;
        soLine.CurrencyIsoCode = 'EUR';
        soLine.BOM_Line_Number__c='1';
        soLine.Package_Product_Code__c = 'test';
        soLine.Serial_Number__c = 'SO123';
        soLine.Quantity__c = 1;
        insert soLine;
     
        soLine.Quantity__c = 2;        
        update soLine ;
        
        Installation_WorkOrder_Contacts__c insWOcontact = new Installation_WorkOrder_Contacts__c();
        insWOcontact.Name = 'test';
        insWOcontact.Email__c = 'test@test.com';
        insWOcontact.Phone__c = '89798890';
        insWOcontact.Role__c = 'coordinator';
        insert insWOcontact;
        
        Installation_WorkOrder_Contacts__c insWOcontact1 = new Installation_WorkOrder_Contacts__c();
        insWOcontact1.Name = 'test';
  //      insWOcontact1.Email__c = 'test@test.com';
        insWOcontact1.Phone__c = '89798890';
        insWOcontact1.Role__c = 'PSE';
        insWOcontact1.Security_Clear__c = 'TS-SCI clearance';
        insert insWOcontact1;
        
        WorkOrder__c wo = new WorkOrder__c();
        wo.Name='test';
        wo.Date_installer_confirms_receipt_of_work__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.installation_schedule_date_time__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.Verified_installation_location__c = true;
        wo.Verified_security_citizenship_rqmnt__c = true;
        wo.Sales_Order_Lookup__c=so.id;
        wo.Installer_coordinator_name1__c = insWOcontact.id;
        wo.PSE_Name1__c = insWOcontact1.id;
        wo.First_attempt_response__c = 'yes';
        wo.new_installation_schedule__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.Installation_validation_complete__c = Date.newInstance(2016,7,27);
        wo.Reason_for_escalation__c = 'CUSTOMER unresponsive to initial contact over a 4 day period';
        wo.Escalation_closed1__c = true;
        wo.Ship_to_Company__c='test';
        wo.Ship_to_City__c='test';
        wo.Ship_to_State__c='test';
        wo.Reason_for_escalation1__c = 'CUSTOMER unresponsive to initial contact over a 4 day period';
        wo.Escalation_closed2__c = true;
        wo.Support_Case_closed__c = true;
        wo.Nimble_Customer_Support_case__c = 'WO7892';
        wo.Pre_Inst_Approved__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.Escalation_Date_Time__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.Security_Requirement_Notes__c = 'TestClass';      
        insert wo;
        
        Test.startTest(); 
        
        wo.installation_schedule_date_time__c = datetime.newInstance(2016, 7, 28, 13, 5, 23);
        
        checkRecursive.resetRunOnceFlag();
        
        update wo;
        
        //checkRecursive.run = false;
        
        wo.installation_schedule_date_time__c = datetime.newInstance(2016, 7, 28, 13, 5, 24);
        
        update wo;
        
        Test.stopTest(); 
       
     } 
 */    
      static testMethod void myUnitTest_one(){
      
        Account acc = new Account(); 
        acc.CurrencyIsoCode = 'EUR';
        acc.Name= 'test';
        insert acc;
        
        Opportunity opp = new opportunity();
        opp.name = 'test';
        opp.AccountId = acc.id;
        opp.Type = 'New Business';
        opp.Sales_Area__c = 'NA Central TOLA';
        opp.CloseDate = System.today();
        opp.StageName = '2-Qualified';
        opp.CurrencyIsoCode = 'EUR';
        opp.Special_Instructions_for_Installation__c = 'test';
        opp.Installation_security_requirements__c = 'None';
        opp.type = 'New Business';
        insert opp;
      
        Sales_Order__c so = new Sales_Order__c();
        so.Name = 'test';
        so.Type__c = 'Beta';
        so.CurrencyIsoCode = 'EUR';
        so.Opportunity__c = opp.id;
        so.Shipment_Date__c = Date.newInstance(2015,7,27);
        so.Actual_Shipment_Date__c = Date.newInstance(2015,7,27);
        so.Tracking_Number__c = '5247';
        so.SO_Number__c='SO123';
        so.Shipping_Agent_Code__c = 'JIT';
        so.End_Customer_Contact_Name__c = 'test';
        so.End_Customer_Contact_Email__c = 'test@test.com';
        so.End_Customer_Contact_Phone__c = '897372';
        so.Ship_To_Company__c = 'test';
        so.Ship_To_Contact_Name__c = 'test';
        so.Ship_To_Contact_Phone__c = '87988098';
        so.Ship_To_Contact_Email__c = 'test@test.com';
        so.Ship_To_Address_1__c = '562 test';
        so.Ship_To_Address_2__c = '654 test';
        so.Ship_To_City__c = 'test';
        so.Ship_to_State__c = 'test';
        so.Ship_To_Zip_Postal_Code__c = '65787';
        so.Ship_To_Country__c = 'india';
        so.Ship_To_Contact_Name__c = 'test';
        insert so;
        
        Sales_Order_Line__c soLine = new Sales_Order_Line__c();
        soLine.Sales_Order__c = so.id;
        soLine.CurrencyIsoCode = 'EUR';
        soLine.BOM_Line_Number__c='1';
        soLine.Package_Product_Code__c = 'test';
        soLine.Serial_Number__c = 'SO123';
        soLine.Quantity__c = 1;
        insert soLine;
        
        Installation_WorkOrder_Contacts__c insWOcontact = new Installation_WorkOrder_Contacts__c();
        insWOcontact.Name = 'test';
        insWOcontact.Email__c = 'test@test.com';
        insWOcontact.Phone__c = '89798890';
        insWOcontact.Role__c = 'coordinator';
        insert insWOcontact;

        Installation_WorkOrder_Contacts__c insWOcontact1 = new Installation_WorkOrder_Contacts__c();
        insWOcontact1.Name = 'test';
  //      insWOcontact1.Email__c = 'test@test.com';
        insWOcontact1.Phone__c = '89798890';
        insWOcontact1.Role__c = 'PSE';
        insWOcontact1.Security_Clear__c = 'TS-SCI clearance';
        insert insWOcontact1;
        
        
        
        WorkOrder__c wo = new WorkOrder__c();
        wo.Name='test';
        wo.Date_installer_confirms_receipt_of_work__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.installation_schedule_date_time__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.Verified_installation_location__c = true;
        wo.Verified_security_citizenship_rqmnt__c = true;
        wo.Sales_Order_Lookup__c=so.id;
        wo.Installer_coordinator_name1__c = insWOcontact.id;
        wo.PSE_Name1__c = insWOcontact1.id;
        wo.First_attempt_response__c = 'yes';
        wo.new_installation_schedule__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.Installation_validation_complete__c = Date.newInstance(2016,7,27);
        wo.Reason_for_escalation__c = 'CUSTOMER unresponsive to initial contact over a 4 day period';
        wo.Escalation_closed1__c = true;
        wo.Ship_to_Company__c='test';
        wo.Ship_to_City__c='test';
        wo.Ship_to_State__c='test';
        wo.Reason_for_escalation1__c = 'CUSTOMER unresponsive to initial contact over a 4 day period';
        wo.Escalation_closed2__c = true;
        wo.Support_Case_closed__c = true;
        wo.Nimble_Customer_Support_case__c = 'WO7892';
        wo.Pre_Inst_Approved__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.Escalation_Date_Time__c = datetime.newInstance(2015, 7, 28, 13, 5, 23);
        wo.Security_Requirement_Notes__c = 'TestClass';     
        
       
         
       Test.startTest();
          Utility.runWorkOrderTrigger=true;
          checkRecursive.resetRunOnceFlag();
          insert wo;
       Test.stopTest();   
     
          
          wo.Ship_to_City__c = 'San Jose';
          Utility.runWorkOrderTrigger=true;
          checkRecursive.resetRunOnceFlag();
          update wo;
        
        
      
      }
    /* 
     static testMethod void myUnitTest_two(){
     
           WorkOrder__c w = [select name,Sales_Order_Lookup__c from WorkOrder__c limit 1];
           WO_Sales_Order_Lines__c wsl = [select Quantity__c from WO_Sales_Order_Lines__c limit 1];
           
           Sales_Order__c s = [select name from Sales_Order__c where id = :w.Sales_Order_Lookup__c];
           
             Test.startTest(); 
                   
             w.name = 'test-work';       
             checkRecursive.resetRunOnceFlag();
             update w;
             
             wsl.Quantity__c = 2;
          
             update wsl;
             
             s.name = 'test-sales';
        
             update s;
             
             Test.stopTest(); 
      }
      */
      
 }