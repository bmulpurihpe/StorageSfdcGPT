@isTest
public class ManagementEscalationTriggerTest {
    
    @isTest
    static void testMethod1() {
        Escalation_Manager_Region_Mapping__c eMRegionMapping = new Escalation_Manager_Region_Mapping__c();
        eMRegionMapping.Region__c = 'AMS';
        eMRegionMapping.Support_Profile__c = 'Alletra MP File';
        eMRegionMapping.Escalation_Manager__c = userInfo.getUserId();
        insert eMRegionMapping;
        
        Product_Support_Profile__c psp = new Product_Support_Profile__c(Name = 'Alletra MP File');
        insert psp;
        
        //	Product
        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             Product_Type_2__c  ='Hardware',
                                             Controller_Code__c ='CS200',
                                             Support_Profile__c = psp.id,
                                             Support_Profile_Name__c = 'Alletra MP File',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='File Storage');
        insert testProduct1;
        
        // Account
        Account account = new Account();
        account.Name = 'test corp';
        account.phone= '01123123';
        account.billingcity='London';
        account.billingpostalcode='SW1635HJ';
        account.billingcountry='United Kingdom';
        account.ACM_Service_Used_Percentage__c= 80;
        account.billingstreet='address 1';
        insert account;
        
        //	Insert contact for Account
        Contact caseContact = new Contact();
        caseContact.AccountId = account.ID;
        caseContact.FirstName = 'test';
        caseContact.LastName = 'test';
        caseContact.email = 'test@gmail.com';
        caseContact.birthdate = Date.newInstance(1992, 04, 12);
        insert caseContact;
        
        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = account.Id, 
                               Product2Id                   = testProduct1.id,
                               HPE_Serial_Number__c         = 'AFTestM10',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Asset_Type_Build__c          = 'Other',
                               Status                       = 'Shipped',
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        
        Asset asst1 = [select id from asset limit 1];
        Contact caseContact1 = [select id from Contact limit 1];
        
        Test.StartTest();
        
        // Case
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType = 'case' and Name = 'Array Case' Limit 1];
        Case cas = new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = caseContact1.Id;
        cas.RecordTypeId = recordTypearraycase.id;
        cas.AssetId = asst1.Id;
        insert cas;
        
        Management_Escalation__c managerEscalationInsert = new Management_Escalation__c();
        managerEscalationInsert.Severity__c = 'Red';
        managerEscalationInsert.Region__c = 'AMS';
        managerEscalationInsert.Customer_Temp__c = 'Test';  
        managerEscalationInsert.Executive_Visibility__c = 'Yes';
        managerEscalationInsert.Case__c = cas.id;
        insert managerEscalationInsert;
        
        Management_Escalation__c managerEscalationUpdate = new Management_Escalation__c();
        managerEscalationUpdate.Id = managerEscalationInsert.id;
        managerEscalationUpdate.Region__c = 'EMEA';
        Update managerEscalationUpdate;
        
        Test.StopTest();
    }
    @isTest
    static void testMethod2() {
        Account account1 = new Account();
        account1.Name = 'test corp';
        account1.phone= '01123123';
        account1.billingcity='London';
        account1.billingpostalcode='SW1635HJ';
        account1.billingcountry='United Kingdom';
        account1.billingstreet='address 1';
        insert account1;
        
        Case cas = new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        insert cas;
        
        Test.StartTest();
        
        Management_Escalation__c managerEscalationInsert = new Management_Escalation__c();
        managerEscalationInsert.Severity__c = 'Green';
        managerEscalationInsert.Region__c = 'AMS';
        managerEscalationInsert.Customer_Temp__c = 'Test';  
        managerEscalationInsert.Executive_Visibility__c = 'Yes';
        managerEscalationInsert.Case__c = cas.id;
        managerEscalationInsert.Account__c = account1.ID;
        insert managerEscalationInsert;
        
        Management_Escalation__c managerEscalationUpdate = new Management_Escalation__c();
        managerEscalationUpdate.Id = managerEscalationInsert.id;
        managerEscalationUpdate.Region__c = 'EMEA';
        managerEscalationUpdate.Severity__c = 'Red';
        Update managerEscalationUpdate;
        
        Management_Escalation__c managerEscalationInsert1 = new Management_Escalation__c();
        managerEscalationInsert1.Severity__c = 'Green';
        managerEscalationInsert1.Region__c = 'AMS';
        managerEscalationInsert1.Customer_Temp__c = 'Test';  
        managerEscalationInsert1.Executive_Visibility__c = 'Yes';
        managerEscalationInsert1.Case__c = cas.id;
        managerEscalationInsert1.Account__c = account1.ID;
        managerEscalationInsert1.Status__c = 'Closed';
        try{
        insert managerEscalationInsert1;
        }
        catch (Exception e) {
            
        }
        
        Test.StopTest();
    }
    
    @isTest
    static void testMethod3() {
        Account account1 = new Account();
        account1.Name = 'test corp';
        account1.phone= '01123123';
        account1.billingcity='London';
        account1.billingpostalcode='SW1635HJ';
        account1.billingcountry='United Kingdom';
        account1.billingstreet='address 1';
        insert account1;
        
        Case cas = new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        insert cas;
        
        Management_Escalation__c managerEscalationInsert = new Management_Escalation__c();
        managerEscalationInsert.Severity__c = 'Green';
        managerEscalationInsert.Region__c = 'AMS';
        managerEscalationInsert.Customer_Temp__c = 'Test';  
        managerEscalationInsert.Executive_Visibility__c = 'Yes';
        managerEscalationInsert.Case__c = cas.id;
        managerEscalationInsert.Account__c = account1.ID;
        insert managerEscalationInsert;
        
        Test.StartTest();
        
        delete managerEscalationInsert;
        
        Test.StopTest();
    }
}