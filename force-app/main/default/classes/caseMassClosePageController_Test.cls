@isTest 
public class caseMassClosePageController_Test {   
public static testMethod void Test(){
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
    	Case aCase1;
    
     Profile prof = [select id from profile where name ='System Administrator II (pw never expires)' limit 1];
    
        User u = new User();
        u.LastName ='JohnTest23';
        u.alias ='J1oeTest';
        u.email= 'Test@J.com';
        u.username='jdoe1@hpe.'+UserInfo.getUserName().substringAfterLast('.');
        u.CommunityNickname = 'jdoe1';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= prof.Id;
        u.LanguageLocaleKey='en_US';
    u.BU_Team__c = 'Renewals';
        insert u;
    system.runAs(u){
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        System.assertNotEquals(null,              account.Id);
        System.assertEquals('TEST-ACCOUNT', account.Name);
        System.assertEquals('Account RMA SHI',    account.accountRmaShi__c);
        
  
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        System.assertNotEquals(null,                        contact.Id);
        System.assertEquals('TEST-CONTACT-LAST-NAME', contact.LastName);
        System.assertEquals(account.Id,            contact.AccountId);
        System.assertEquals('test@gmail.com',            contact.Email);
        System.assertEquals('999999999',            contact.Phone);
    
  

        
    //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
       
        
      	List <Case> lstCase = new List<Case>();

        
        
        // Create test case
        Case testcase1 = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT',
                                Product_Damage_Symptoms__c = 'Test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                                Case_closure_time_spent__c = 1,
                                Technology_Area__c ='Array Hardware',
        						Sub_Technology_Area__c  = 'Damaged in shipping',
                                caseBUteam__c = 'Renewals'
                                );
    lstCase.add(testcase1);
         Case testcase2 = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE1-SUBJECT',
                                Product_Damage_Symptoms__c = 'Test',
                                  Technology_Area__c ='Array Hardware',
        						Sub_Technology_Area__c  = 'Damaged in shipping',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                                Case_closure_time_spent__c = 1);
    lstCase.add(testcase2);
         Test.startTest();
    Insert lstCase;
       
        TechnicalSubArea_Mappings__c tsamapping = new TechnicalSubArea_Mappings__c();
        tsamapping.Technical_Area__c ='Array Hardware';
        tsamapping.Technical_SubArea__c = 'Damaged in shipping';
        tsamapping.IsDeleted__c = false;
        tsamapping.Case_Types__c = 'Array Case';
        insert tsamapping;
        
         //Test.startTest();

       Test.setCurrentPage(Page.caseMassClosePage);

        
      ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstCase);
    	sc.setSelected(lstCase);
       caseMassClosePageController closeCase = new caseMassClosePageController(sc);
        closeCase.caseobj = testcase2;
    closeCase.myCustomSave();
    closeCase.myCustomCancel();
 	Test.stopTest();
    }
        //closeCase.SelectedTaValue = 'Array Hardware';
        //closeCase.SelectedTsaValue = 'Damaged in shipping';
        
}
}