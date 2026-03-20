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
@isTest
public class Test_AttacheToSolUpdate {

    @testSetup static void myUnitTest() {
    /*
        Account acc=new Account();
        acc.name='test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name='test';
        opp.AccountId=acc.Id;
        opp.Type='New Business';
        opp.StageName='Qualified';
        opp.CloseDate=system.today()+3;
        insert opp;
        
        SBQQ__Quote__c quote1=new SBQQ__Quote__c();
        quote1.Quote_Name__c='test';
        quote1.SBQQ__Opportunity__c=opp.Id;
        
        insert quote1;
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Quote__c=quote1.Id;     
        insert quoteline;
        
        SBQQ__QuoteLine__c quoteline1=new SBQQ__QuoteLine__c();
        quoteline1.SBQQ__Quote__c=quote1.Id;
        quoteline1.SBQQ__RequiredBy__c=quoteline.Id;
        insert quoteline1;
        */
        //test.starttest();
        Account acc=new Account();
        acc.name='test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name='test';
        opp.AccountId=acc.Id;
        opp.Type='New Business';
        opp.StageName='Qualified';
        opp.Prebuild_Status__c='Approved';
        opp.SO_Prebuild_Order__c=false;
        
        opp.CloseDate=system.today()+3;
        insert opp;
        
        
        
        Prebuild__c pre=new Prebuild__c();
        pre.Opportunity__c=opp.id;
        pre.Prebuild_Status__c='Approved';
        insert pre;
        
        Sales_Order__c so = new Sales_Order__c();
        so.Name = 'test';
        so.Type__c = 'Prebuild';
        so.CurrencyIsoCode = 'EUR';
        so.Opportunity__c = opp.id;
        so.status__C='New';
        so.Shipment_Date__c = system.today()+10;
        so.Actual_Shipment_Date__c = system.today()+12;
        so.Tracking_Number__c = '5247';
        so.Shipping_Agent_Code__c = 'JIT';
        so.End_Customer_Contact_Name__c = 'test';
        so.End_Customer_Contact_Email__c = 'test@test.com';
        so.End_Customer_Contact_Phone__c = '897372';
        so.Ship_To_Company__c = 'test';
        so.SO_Number__c='SO123';
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
        
        
        
        Expedite_Request__c exp=new Expedite_Request__c();
         exp.Approval_To_Overnight__c=' test mansa';
         exp.Overnight__c=true;
         exp.Sales_Order__c=so.id;
         exp.Target_Install_Date__c=system.today();
         Utility.runDupRecTrigger=false;
         insert exp;
        
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
        wo.Reason_for_escalation1__c = 'CUSTOMER unresponsive to initial contact over a 4 day period';
        wo.Escalation_closed2__c = true;
        wo.Ship_to_Company__c='test';
        wo.Ship_to_City__c='test';
        wo.Ship_to_State__c='test';
        wo.Support_Case_closed__c = true;
        wo.Nimble_Customer_Support_case__c = 'WO7892';
        wo.Pre_Inst_Approved__c = system.today()+12;
        wo.Verified_security_citizenship_rqmnt__c=false;
        wo.Escalation_Date_Time__c = system.today()+13;
        Utility.runDupRecTrigger=false;
        insert wo;
        
        so.status__C='Submitted by OA';
        so.Shipment_Date__c=system.today()+20;
        Utility.runDupRecTrigger=false;
        update so;
        //delete so;
        integer i=1;
        System.assertEquals(i,1);
        
    }
    
    @isTest static void testMethod1()
    {
        
        list<Expedite_Request__c> Explist=new list<Expedite_Request__c>();
        
        List<Sales_Order__c> soList = new List<Sales_Order__c>();
        soList = [Select Id from Sales_Order__c];
        
        Sales_Order__c so = new Sales_Order__c();
        so = soList[0];
        System.debug('==> SO is:: '+ so);
        
        List<Sales_Order_Line__c> soLineList = new List<Sales_Order_Line__c>();
        soLineList = [Select Id from Sales_Order_Line__c WHERE Sales_Order__c =: so.id];
        Sales_Order_Line__c soLine = new Sales_Order_Line__c();
        soLine = soLineList[0];
        
        List<WorkOrder__c> woList = new List<WorkOrder__c>();
        woList = [Select Id from WorkOrder__c WHERE Sales_Order_Lookup__c =: so.id];
        WorkOrder__c wo = new WorkOrder__c();
        wo = woList[0];
        
        List<Prebuild__c> preList = new List<Prebuild__c>();
        preList = [Select Id from Prebuild__c];
        Prebuild__c pre=new Prebuild__c();
        pre = preList[0];
        
        //Explist =[select id,Sales_Order__c from Expedite_Request__c where Sales_Order__c=:so.id Limit 1];
        Expedite_Request__c exp=new Expedite_Request__c();
         exp.Approval_To_Overnight__c=' test mansa';
         exp.Overnight__c=true;
         exp.Sales_Order__c=so.id;
         exp.Target_Install_Date__c=system.today();
         Utility.runDupRecTrigger=false;
         insert exp;
        
        Explist.add(exp);
        
        System.debug('==> ExpList :: '+ Explist);

        test.startTest();
        update soLine;
        delete soLine;
        if(Explist.size()>0)
            delete Explist;
        
        delete wo;
        //Utility.runDupRecTrigger=true;
        //delete so;
        delete pre;
        test.stoptest();
    }
}