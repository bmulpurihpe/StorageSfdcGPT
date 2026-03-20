@IsTest
public class CaseCommentInsertClass_Test {
    Static testmethod void CaseCommentInsertClass_Test_01(){
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        Product2 aProduct;
        List<Product2>    products;
        Case aCase;
        QualifiedHandling__c qhrecord;
        Qualified_Handling_User__c cModel;
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.'+UserInfo.getUserName().substringAfterLast('.');
        Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)'];
       User u = new User(Alias = 'standt', Email='standarduser@testorg.exafort5',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        System.runAs(u){
            //Creating new test Account
            insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
            //Creating new test Contact
            insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                          AccountId = aAccount.Id,
                                          Email='test@gmail.com',
                                          Phone='999999999');
            // Creating new test Assets
            Test.startTest();
            //Create new Qulaified Handling
            insert qhrecord = new QualifiedHandling__c(Name = 'Case Abbreviation',
                                                       qhLabel__c= 'Case Abbreviation',
                                                       qhDescription__c = 'Only Limited visibility to the case for TSE.',
                                                       qhDocumentationURL__c='https://nimblejira.nimblestorage.com/browse/TS-5755',
                                                       qhExternalVerbiage__c='Tse can only view the case and add a private comment to Case.');
            //Create new Cmodel 
            insert cModel = new Qualified_Handling_User__c(cmQualifiedHandling__c = qhrecord.Id,
                                                           cmUser__c = userinfo.getUserId());
            
            
            insert aProduct = new Product2(Name = 'CS220 Storage Array',
                                                 ProductCode='CS220', 
                                                 Product_Type__c='Hardware',
                                                 Product_Type_2__c='SAN Storage Array',
                                                 Controller_Code__c='CS200',
                                                 Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                 Family='SAN Storage Array');  
            
            
            
            insert aAsset = new Asset(Name = 'TestAsset', AccountId = aAccount.Id, Product2Id = aProduct.id,HPE_Serial_Number__c = 'HPE123457',
                                   Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                   Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                   Asset_Type_Build__c ='Testasupassettype');
            
            
            // Create test case
            insert aCase = new Case(AccountId = aAccount.Id,
                                    AssetId   = aAsset.Id,
                                    //ContactId = aContact.Id,
                                    Subject = 'TEST-CASE-SUBJECT');
            Test.stopTest();
            
            PageReference pageRef = Page.AbbreviatedCaseDetailPage; // Add your VF page Name here
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
            
            CaseCommentInsertClass Cc = new CaseCommentInsertClass(sc);
            Cc.showNewCommentCreation();
            Cc.SaveAbbCaseComment();
            Cc.timerOff();
        }
    }
    Static testmethod void CaseCommentInsertClass_Test_02(){
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        Product2 aProduct;
        List<Product2>    products;
        Case aCase;
        QualifiedHandling__c qhrecord;
        Qualified_Handling_User__c cModel;
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.'+UserInfo.getUserName().substringAfterLast('.');
        Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)'];
        User u1 = new User(Alias = 'Rv', Email='standarduserRv@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles',
                           UserName=uniqueUserName);
        
        System.runAs(u1){
            //Create new Qulaified Handling
            insert qhrecord = new QualifiedHandling__c(Name = 'Case Abbreviation',
                                                       qhLabel__c= 'Case Abbreviation',
                                                       qhDescription__c = 'Only Limited visibility to the case for TSE.',
                                                       qhDocumentationURL__c='https://nimblejira.nimblestorage.com/browse/TS-5755',
                                                       qhExternalVerbiage__c='Tse can only view the case and add a private comment to Case.');
            //Create new Cmodel 
            /*insert cModel = new Qualified_Handling_User__c(cmQualifiedHandling__c = qhrecord.Id,
cmUser__c = userinfo.getUserId());*/
            //Creating new test Account
            insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',accountQualifiedHandling__c = qhrecord.Id );
            //Creating new test Contact
            insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                          AccountId = aAccount.Id,
                                          Email='test@gmail.com',
                                          Phone='999999999');
            // Creating new test Assets
            Test.startTest();
            
            insert aProduct = new Product2(Name = 'CS220 Storage Array',
                                                 ProductCode='CS220', 
                                                 Product_Type__c='Hardware',
                                                 Product_Type_2__c='SAN Storage Array',
                                                 Controller_Code__c='CS200',
                                                 Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                 Family='SAN Storage Array');  
            
            
            
            insert aAsset = new Asset(Name = 'TestAsset', AccountId = aAccount.Id, Product2Id = aProduct.id,HPE_Serial_Number__c = 'HPE123457',
                                   Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                   Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                   Asset_Type_Build__c ='Testasupassettype');
            
            // Create test case
            insert aCase = new Case(AccountId = aAccount.Id,
                                    AssetId   = aAsset.Id,
                                    //ContactId = aContact.Id,
                                    Subject = 'TEST-CASE-SUBJECT');
            Test.stopTest();
            
            PageReference pageRef = Page.AbbreviatedCaseDetailPage; // Add your VF page Name here
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
            
            CaseCommentInsertClass Cc = new CaseCommentInsertClass(sc);
            Cc.showNewCommentCreation();
            Cc.SaveAbbCaseComment();
            Cc.timerOff();
        }
    }
}