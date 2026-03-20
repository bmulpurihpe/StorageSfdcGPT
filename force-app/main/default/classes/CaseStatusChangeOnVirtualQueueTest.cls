@isTest
public class CaseStatusChangeOnVirtualQueueTest {
    @istest
    public static void testMethod1(){
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;
        
        System.runAs(u) { 
            
            CntrbnMdl_TSE__c contributionModelTSE = new CntrbnMdl_TSE__c();
            contributionModelTSE.Organization__c = 'TSE';
            contributionModelTSE.Team__c = 'APAC';
            contributionModelTSE.Support_Profile__c = 'Backup & Recovery; Legacy Nimble';
            contributionModelTSE.Employee_Name__c = u.id;
            insert contributionModelTSE;
            
            //test.startTest();
            Account     account;
            Contact     contact;
            Product2    product;
            Asset       asset;
            Case        aCase;
            
            account = new Account(Name = 'TEST-ACCOUNT');
            insert account;
            
            contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                                  LastName    = 'TEST-CONTACT-LAST-NAME',
                                  Phone       = 'TEST-CONTACT-PHONE',
                                  MobilePhone = 'TEST-CONTACT-MOBILE',
                                  AccountId   = account.Id);
            insert contact;
            
            product = new Product2();
            product.Name = 'Test Product';
            product.ProductCode = 'SD-Test';
            insert product;
            
            asset = new Asset(Name = 'TEST-ASSET-SHELF',
                              AccountId  = account.Id,
                              ContactId  = contact.Id,
                              product2Id = product.Id,
                              assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                              Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                              Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                              Array_Controller_SKU__c = 'SD-Test',
                              Array_Capacity_SKU__c ='HEAD-HDD-21TB'
                             );
            insert asset;
            
            test.startTest();
            aCase = new Case(AccountId = account.Id,
                             AssetId   = asset.Id,
                             ContactId = contact.Id,
                             Origin = 'Phone',
                             caseCatImpactToCustomer__c='Array Not Coming Up (including DOA)',
                             Status   = 'Open',
                             Priority = 'P4',
                             Technology_Area__c='3rd Party Apps',
                             Sub_Technology_Area__c='Access',
                             Subject  = 'TEST-CASE-SUBJECT');
            insert aCase;
            test.stopTest();
            PageReference pageRef = Page.CaseStatusChangeOnVirtualQueue;
            //  pageRef.getParameters().put('selectedRecId', '%5B"'+aCase.id+'"%5D');
            Test.setCurrentPage(pageRef);
            Cookie cookie = new Cookie('recIds','%5B"'+aCase.id+'"%5D', null, -1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookie});
            
            CaseStatusChangeOnVirtualQueueController CaseStatusChange =new CaseStatusChangeOnVirtualQueueController(); 
            CaseStatusChange.getStatusOptions();
            CaseStatusChange.updateCaseStatus();
        }
    }
}