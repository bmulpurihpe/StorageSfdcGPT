@isTest
public class assetAddressValidateControllerTest {
    public static TestMethod void TestMethod1(){  
        Account account;
        Contact contact;
        Asset   asset;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     email='test@gmail.com',
                                     Phone='999999999');
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd; 
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        PageReference pageRef = Page.assetAddressValidate;
        system.test.setCurrentPageReference(pageRef);
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id',asset.id);
        assetAddressValidateController asstVal=new assetAddressValidateController();
        
        
        asstVal.timerOn();
        asstVal.timerOff();
        asstVal.myCustomCancel();
        asstVal.validateAsset();
        
        test.stopTest();
        asstVal.timer=true;
        asstVal.currentPageId =asset.id;
        asstVal.objectName='Asset';
        asstVal.isParent=True;
        
    }
    /*public static TestMethod void TestMethod2(){  
        Account account;
        Contact contact;
        Asset   asset;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     email='test@gmail.com',
                                     Phone='999999999');
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd; 
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 Product2id = prd.Id,
                                 SLA__c = 'Premium',
                                 HPE_Serial_Number__c ='AA000000NIM',
                                 Array_Controller__c = 'AF1000',
                                 assetRmaShi__c = 'Asset RMA SHI');
        
        PageReference pageRef = Page.assetAddressValidate;
        system.test.setCurrentPageReference(pageRef);
        Test.StartTest();
        
        assetAddressValidateController asstVal=new assetAddressValidateController();
        
        asstVal.timerOn();
        asstVal.timerOff();
        asstVal.myCustomCancel();
        
        
        test.stopTest();
        asstVal.timer=true;
        asstVal.currentPageId =null;
        asstVal.objectName='Asset';
        asstVal.isParent=True;
        
    }
    public static TestMethod void TestMethod3(){  
        Account account;
        Contact contact;
        Asset   asset;
        Asset asset2;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                     BillingStreet = 'Am Tierpark 16',
                                     BillingCity = 'Cologne',
                                     BillingPostalCode = '54321',
                                     BillingState = 'Nordrhein-Westfalen',
                                     BillingCountry = 'Germany');
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     email='test@gmail.com',
                                     Phone='999999999');
        Product2 prd = new Product2(Name = 'SSD Storage Array',
                                    ProductCode='HF600',
                                    Product_Type__c='Hardware',
                                    Product_Type_2__c='SAN Storage ArrayS',
                                    Controller_Code__c='CS2001',
                                    Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                    Family='SAN Storage Array');
        insert prd; 
        
        asset2= new Asset(Name = 'TEST-ASSET',
                          AccountId = account.Id,
                          ContactId = contact.Id,
                          Product2id = prd.Id,
                          SLA__c = 'Premium',
                          HPE_Serial_Number__c ='AA000000NIM',
                          Array_Controller__c = 'AF1000',
                          
                          assetRmaShi__c = 'Asset RMA SHI');
        insert asset2;
        asset = new Asset(id=asset2.id,
                          Name = 'TEST-ASSET',
                          AccountId = account.Id,
                          ContactId = contact.Id,
                          Product2id = prd.Id,
                          SLA__c = 'Premium',
                          HPE_Serial_Number__c ='AA000000NIM',
                          Array_Controller__c = 'AF1000',
                          
                          assetRmaShi__c = 'Asset RMA SHI');
        
        update asset;
        
        PageReference pageRef = Page.assetAddressValidate;
        system.test.setCurrentPageReference(pageRef);
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id',contact.id);
        assetAddressValidateController asstVal=new assetAddressValidateController();  
        
        asstVal.timerOn();
        asstVal.timerOff();
        asstVal.myCustomCancel();
        
        
        test.stopTest();
        asstVal.timer=true;
        asstVal.currentPageId =asset.id;
        asstVal.objectName='Contact';
        asstVal.isParent=false;
        
    }*/
    
}