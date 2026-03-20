@isTest
private class CaseRecommendationTests
{
    
    static testMethod void testRecommendations()
    {
        Account          account;
        Contact          contact;
        Asset            asset;
        Case             aCase;
        Outstanding_Recommendation__c rec;
        
        // Create test account
        account = new Account(Name = 'TEST-ACCOUNT');
        insert account;
        
        // Create test contact
        contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                              AccountId = account.id);
        insert contact;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        
        //create asset          
        asset = new Asset(Name = 'TEST-ASSET',
                          AccountId = account.id,
                          ContactId = contact.id,
                          Product2id = prd.id,
                          SLA__c = 'Premium',
                          Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                          Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                          Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                          Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                          Array_Controller__c = 'CS3001',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                          Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                          Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        insert asset;
        
        
        // Create test case - Set 1
        aCase = new Case(AccountId = account.id,
                         AssetId   = asset.id,
                         ContactId = contact.id,
                         Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        
        
        //create test Recommendations
        
        rec = new Outstanding_Recommendation__c(Status__c = 'Requested',
                                                Recommended_Action__c   = 'Test1',
                                                Case__c = aCase.id,
                                                Asset__c = asset.id,
                                                Account__c = account.id,
                                                Contact__c = contact.id);
        
        insert rec;
        
        
        
        Test.startTest();  
        
        ApexPages.CurrentPage().getParameters().put('id',aCase.id);
        ApexPages.StandardController sc = new ApexPages.standardController(acase);
        CaseRecommendation cs=new CaseRecommendation(sc);
        cs.showMore();
        
        cs.cse = aCase;
        cs.cseAccountID = account.id;
        cs.executeCount();
        cs.getFooter();
        cs.getdisableValue();
        cs.getRecz();
        
        cs.cse = aCase; 
        cs.cseAccountID = null; 
        cs.total_size   =10;
        cs.list_size = 5;
        cs.executeCount();
        cs.getFooter();
        cs.getdisableValue();
        cs.getRecz();
        
        cs.cse = aCase; 
        cs.cseAccountID = account.id; 
        cs.total_size   =10;
        cs.list_size = 10;
        cs.executeCount();
        cs.getFooter();
        cs.getdisableValue();
        cs.getRecz();
        
        cs.cse = aCase;
        cs.cseAccountID = account.id;
        cs.total_size   = 5;
        cs.list_size = 10;
        cs.executeCount();
        cs.getFooter();
        cs.getdisableValue();
        cs.getRecz();
        
        
        
        Test.stopTest();
        
        
        
    }
    
    static testMethod void testRecommendationList()
    {
        Account          account;
        Contact          contact;
        Asset            asset;
        Case             aCase;
        Outstanding_Recommendation__c rec;
        
        // Create test account
        account = new Account(Name = 'TEST-ACCOUNT');
        insert account;
        
        // Create test contact
        contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                              AccountId = account.id);
        insert contact;
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd;
        
        //create asset          
        asset = new Asset(Name = 'TEST-ASSET',
                          AccountId = account.id,
                          ContactId = contact.id,
                          Product2id = prd.id,
                          SLA__c = 'Premium',
                          Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                          Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                          Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                          Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                          Array_Controller__c = 'CS3001',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                          Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                          Asset_Type_Build__c ='Testasupassettype',Array_Controller_SKU__c = 'HF60');
        insert asset;
        
        
        // Create test case - Set 1
        aCase = new Case(AccountId = account.id,
                         AssetId   = asset.id,
                         ContactId = contact.id,
                         Subject = 'TEST-CASE-SUBJECT');
        insert aCase;
        
        
        //create test Recommendations
        
        rec = new Outstanding_Recommendation__c(Status__c = 'Requested',
                                                Recommended_Action__c   = 'Test1',
                                                Case__c = aCase.id,
                                                Asset__c = asset.id,
                                                Account__c = account.id,
                                                Contact__c = contact.id);
        
        insert rec;
        
        
        
        Test.startTest();  
        
        ApexPages.CurrentPage().getParameters().put('id',aCase.id);
        ApexPages.StandardController sc = new ApexPages.standardController(acase);
        CaseRecommendationList cs=new CaseRecommendationList(sc);
        cs.showMore();
        
        
        cs.cse = aCase;
        cs.cseAccountID = account.id;
        cs.executeCount();
        cs.getFooter();
        cs.getdisableValue();
        cs.getRecz();
        
        cs.cse = aCase; 
        cs.cseAccountID = null; 
        cs.total_size   =10;
        cs.list_size = 5;
        cs.executeCount();
        cs.getFooter();
        cs.getdisableValue();
        cs.getRecz();
        
        cs.cse = aCase; 
        cs.cseAccountID = account.id; 
        cs.total_size   =10;
        cs.list_size = 10;
        cs.executeCount();
        cs.getFooter();
        cs.getdisableValue();
        cs.getRecz();
        
        cs.cse = aCase;
        cs.cseAccountID = account.id;
        cs.total_size   = 5;
        cs.list_size = 10;
        cs.executeCount();
        cs.getFooter();
        cs.getdisableValue();
        cs.getRecz();
        
        
        
        Test.stopTest();
        
        
        
    }
    
    
}