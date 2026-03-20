/* 							<<<< === Test Class for NECCustomLinksDisplayPageController apex class === >>>>
    =============================================================================================================
        Name                    : NECCustomLinksDisplayPageController_Test
        Description             : To verify the minimum test coverage for the logic in the NECCustomLinksDisplayPageController class.
        Created Date            : 30th april 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
@isTest
public class NECCustomLinksDisplayPageController_Test {
    
    Static Testmethod void NECCustomLinksDisplayPageController_01(){
        Account aAccount;
        
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        PageReference pageRef = Page.NECCustomLinksDisplayPage; 
        pageRef.getParameters().put('id', String.valueOf(aAccount.Id));
        Test.setCurrentPage(pageRef);
        
        NECCustomLinksDisplayPageController NEC = new NECCustomLinksDisplayPageController();

    }
    Static Testmethod void NECCustomLinksDisplayPageController_02(){
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        Case aCase;
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        // Creating new test Assets
        Test.startTest();
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        insert aAsset = new Asset(Name = 'TestAsset', AccountId = aAccount.Id,Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype');
        
       // Create test case
     	insert aCase = new Case(AccountId = aAccount.Id,
                       AssetId   = aAsset.Id,
                       ContactId = aContact.Id,
                       Subject = 'TEST-CASE-SUBJECT');
        Test.stopTest();
        
        PageReference pageRef = Page.NECCustomLinksDisplayPage;
        pageRef.getParameters().put('sfdcIFrameOrigin', 'https://nimblestorage--fc1.cs3.my.salesforce.com/500340000180Bh6');
        Test.setCurrentPage(pageRef);
        
        NECCustomLinksDisplayPageController NEC = new NECCustomLinksDisplayPageController();

    }

}