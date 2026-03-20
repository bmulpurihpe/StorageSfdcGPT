@isTest
private class contactExtensionsWithSharingTest 
  {
       static testMethod void createTestData(){
        Account account;
        Contact contact;
        Asset   asset;
        Case    aCase;
        List<Account> accounts;
        List<Contact> contacts;
        List<Asset>   assets;
        List<Case>    cases;
        ID testAccountId;
        ID testContactId;
        ID testAssetShippedId;
        ID testAssetScrappedId;
        ID testCaseOpenId;
        ID testCaseClosedId;
        
        account acc = new Account(Name = 'TEST-ACCOUNT');
        insert acc;
        
        contact con = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                                  LastName    = 'TEST-CONTACT-LAST-NAME',
                                  Phone       = 'TEST-CONTACT-PHONE',
                                  MobilePhone = 'TEST-CONTACT-MOBILE',
                                  AccountId   = acc.Id);
        insert con;
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        asset asst = new Asset(Name = 'TEST-ASSET-SHIPPED',
                               Status = 'Shipped',
                               AccountId = acc.id,
                               ContactId = con.Id,
                               SLA__c = 'Premium',
                               Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                               Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                               Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                               Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype',Product2Id = testProduct1.id);
        insert asst;
        
        /*asset asst1 = new Asset(Name = 'TEST-ASSET-SCRAPPED',
Status = 'Scrapped',
AccountId = acc.Id,
ContactId = con.Id,
SLA__c = 'Premium',
Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
Asset_Type_Build__c ='Testasupassettype', Product2Id = testProduct1.id);
insert asst1;*/
        
        aCase = new Case(AccountId = acc.id,
                         AssetId   = asst.id,
                         ContactId = con.id,
                         Status = 'Open',
                         Subject = 'TEST-CASE-OPEN-SUBJECT');
        insert aCase;
        
        /*Case aCase1 = new Case(AccountId = acc.Id,
AssetId   = asst.Id,
ContactId = con.Id,
Status = 'Closed',
Subject = 'TEST-CASE-CLOSED-SUBJECT');
insert aCase1;*/
    }
    static testMethod void testViewUrlNonPortalUser(){
        List<Contact> contacts;
        ApexPages.StandardController contactController;
        contactExtensionsWithSharing contactExtension;
        
        createTestData();
        
        contacts = [SELECT Id
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        
        contactController = new ApexPages.StandardController(contacts[0]);
        contactExtension  = new contactExtensionsWithSharing(contactController);
        
        System.assertNotEquals('Nimble Customer Portal Profile', contactExtension.profileName);
        System.assertEquals(null, contactExtension.accountId);
        System.assertEquals('/' + contacts[0].id + '?nooverride=1', contactExtension.contactDispatchViewUrl().getUrl());
    }
    static testMethod void testEditUrlNonPortalUser(){
        List<Contact> contacts;
        ApexPages.StandardController contactController;
        contactExtensionsWithSharing contactExtension;
        
        createTestData();
        
        contacts = [SELECT Id
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        
        contactController = new ApexPages.StandardController(contacts[0]);
        contactExtension  = new contactExtensionsWithSharing(contactController);
        
        System.assertNotEquals('Nimble Customer Portal Profile', contactExtension.profileName);
        System.assertEquals(null, contactExtension.accountId);
        System.assertEquals('/' + contacts[0].id + '/e?nooverride=1', contactExtension.contactDispatchEditUrl().getUrl());
    }
    static testMethod void testNewUrlNonPortalUser(){
        Contact contact;
        ApexPages.StandardController contactController;
        contactExtensionsWithSharing contactExtension;
        
        contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                              LastName    = 'TEST-CONTACT-LAST-NAME',
                              Phone       = 'TEST-CONTACT-PHONE',
                              MobilePhone = 'TEST-CONTACT-MOBILE');
        
        contactController = new ApexPages.StandardController(contact);
        contactExtension  = new contactExtensionsWithSharing(contactController);
        
        System.assertNotEquals('Nimble Customer Portal Profile', contactExtension.profileName);
        System.assertEquals(null, contactExtension.accountId);
        System.assertEquals('/003/e' + '?nooverride=1', contactExtension.contactDispatchNewUrl().getUrl());
    }
    static testMethod void testNumActiveAssetsContactIsOn(){
        List<Contact> contacts;
        ApexPages.StandardController contactController;
        contactExtensionsWithSharing contactExtension;
        
        createTestData();
        
        contacts = [SELECT Id
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        
        contactController = new ApexPages.StandardController(contacts[0]);
        contactExtension  = new contactExtensionsWithSharing(contactController);
        
        System.assertEquals(1, contactExtension.numActiveAssetsContactIsOn());
    }
    static testMethod void testNumActiveCasesContactIsOn(){
        List<Contact> contacts;
        ApexPages.StandardController contactController;
        contactExtensionsWithSharing contactExtension;
        
        createTestData();
        
        contacts = [SELECT Id
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        
        contactController = new ApexPages.StandardController(contacts[0]);
        contactExtension  = new contactExtensionsWithSharing(contactController);
        
        System.assertEquals(1, contactExtension.numActiveCasesContactIsOn());
    }
    static testMethod void testViewUrlPortalUser(){
        List<User> users;
        List<Contact> contacts;
        Contact contact;
        
        users = [SELECT Id,
                 accountId
                 FROM   User
                 WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                 IsActive = true
                 LIMIT  1];
        contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                              LastName    = 'TEST-CONTACT-LAST-NAME',
                              Phone       = 'TEST-CONTACT-PHONE',
                              MobilePhone = 'TEST-CONTACT-MOBILE',
                              AccountId   = users[0].accountId);
        insert contact;
        
        contacts = [SELECT Id
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        System.runAs(users[0])
        {
            ApexPages.StandardController contactController;
            contactExtensionsWithSharing contactExtension;
            
            contactController = new ApexPages.StandardController(contacts[0]);
            contactExtension  = new contactExtensionsWithSharing(contactController);
            
            System.assertEquals('Nimble Customer Portal Profile', contactExtension.profileName);
            System.assertEquals(users[0].accountId, contactExtension.accountId);
            System.assertEquals('/apex/contactportalviewpage', contactExtension.contactDispatchViewUrl().getUrl());
        }
    }
    static testMethod void testEditUrlPortalUser()
    {
        List<User> users;
        List<Contact> contacts;
        Contact contact;
        
        users = [SELECT Id,
                 accountId
                 FROM   User
                 WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                 IsActive = true
                 LIMIT  1];
        
        contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                              LastName    = 'TEST-CONTACT-LAST-NAME',
                              Phone       = 'TEST-CONTACT-PHONE',
                              MobilePhone = 'TEST-CONTACT-MOBILE',
                              AccountId   = users[0].accountId);
        insert contact;
        contacts = [SELECT Id,
                    FirstName,
                    LastName,
                    Phone,
                    MobilePhone,
                    AccountId
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        
        
        System.runAs(users[0])
        {
            ApexPages.StandardController contactController;
            contactExtensionsWithSharing contactExtension;
            
            contactController = new ApexPages.StandardController(contacts[0]);
            contactExtension  = new contactExtensionsWithSharing(contactController);
            
            System.assertEquals('Nimble Customer Portal Profile', contactExtension.profileName);
            System.assertEquals(users[0].accountId, contactExtension.accountId);
            System.assertEquals('/apex/contactportaleditpage', contactExtension.contactDispatchEditUrl().getUrl());
        }
    }
    static testMethod void testNewUrlPortalUser()
    {
        List<User> users;
        Contact contact;
        
        users = [SELECT Id,
                 accountId
                 FROM   User
                 WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                 IsActive = true
                 LIMIT  1];
        
        contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                              LastName    = 'TEST-CONTACT-LAST-NAME',
                              Phone       = 'TEST-CONTACT-PHONE',
                              MobilePhone = 'TEST-CONTACT-MOBILE',
                              AccountId   = users[0].accountId);
        
        System.runAs(users[0])
        {
            ApexPages.StandardController contactController;
            contactExtensionsWithSharing contactExtension;
            
            contactController = new ApexPages.StandardController(contact);
            contactExtension  = new contactExtensionsWithSharing(contactController);
            
            System.assertEquals('Nimble Customer Portal Profile', contactExtension.profileName);
            System.assertEquals(users[0].accountId, contactExtension.accountId);
            System.assertEquals('/apex/contactportalnewpage', contactExtension.contactDispatchNewUrl().getUrl());
        }
    }
    static testMethod void testErrorDuplicateContact()
    {
        List<User> users;
        List<Contact> contacts;
        Contact contact;
        
        users = [SELECT Id,
                 accountId
                 FROM   User
                 WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                 IsActive = true
                 LIMIT  1];
        contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                              LastName    = 'TEST-CONTACT-LAST-NAME',
                              Phone       = 'TEST-CONTACT-PHONE',
                              MobilePhone = 'TEST-CONTACT-MOBILE',
                              AccountId   = users[0].accountId);
        insert contact;
        contacts = [SELECT Id,
                    FirstName,
                    LastName,
                    Phone,
                    MobilePhone,
                    AccountId
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        
        System.runAs(users[0])
        {
            ApexPages.StandardController contactController;
            contactExtensionsWithSharing contactExtension;
            PageReference returnedPageReference;
            
            contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                                  LastName    = 'TEST-CONTACT-LAST-NAME',
                                  Phone       = 'TEST-CONTACT-PHONE',
                                  MobilePhone = 'TEST-CONTACT-MOBILE');
            
            contactController = new ApexPages.StandardController(contact);
            contactExtension  = new contactExtensionsWithSharing(contactController);
            
            System.assertEquals('Nimble Customer Portal Profile', contactExtension.profileName);
            System.assertEquals(users[0].accountId, contactExtension.accountId);
            
            returnedPageReference = contactExtension.contactCustomSave();
            System.assertEquals(null, returnedPageReference);
            System.assertEquals('Duplicate contact exists for this same First Name and Last Name.  Contact cannot be saved for duplicate contacts.', contactExtension.saveErrorMessage);
        }
    }
    static testMethod void testErrorPhones()
    {
        List<User> users;
        Contact contact;
        
        users = [SELECT Id,
                 accountId
                 FROM   User
                 WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                 IsActive = true
                 LIMIT  1];
        System.runAs(users[0])
        {
            ApexPages.StandardController contactController;
            contactExtensionsWithSharing contactExtension;
            PageReference returnedPageReference;
            
            contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                                  LastName    = 'TEST-CONTACT-LAST-NAME');
            
            contactController = new ApexPages.StandardController(contact);
            contactExtension  = new contactExtensionsWithSharing(contactController);
            
            System.assertEquals('Nimble Customer Portal Profile', contactExtension.profileName);
            System.assertEquals(users[0].accountId, contactExtension.accountId);
            
            returnedPageReference = contactExtension.contactCustomSave();
            System.assertEquals(null, returnedPageReference);
            System.assertEquals('Phone and Mobile Phone are both blank.  At least one is required to save contact.', contactExtension.saveErrorMessage);
        }
    }
    static testMethod void testErrorActiveAsset()
    {
        List<User> users;
        List<Contact> contacts;
        List<Asset> assets;
        Contact contact;
        Asset asset;
        
        users = [SELECT Id,
                 accountId
                 FROM   User
                 WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                 IsActive = true
                 LIMIT  1];
        contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                              LastName    = 'TEST-CONTACT-LAST-NAME',
                              Phone       = 'TEST-CONTACT-PHONE',
                              MobilePhone = 'TEST-CONTACT-MOBILE',
                              AccountId   = users[0].accountId);
        insert contact;
        contacts = [SELECT Id,
                    FirstName,
                    LastName,
                    Phone,
                    MobilePhone,
                    AccountId,
                    contactInactive__c
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                          Status = 'Shipped',
                          AccountId = users[0].accountId,
                          ContactId = contacts[0].id,
                          SLA__c = 'Premium',
                          Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                          Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                          Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                          Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                          Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                          Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                          Asset_Type_Build__c ='Testasupassettype');
        insert asset;
        assets = [SELECT Id,
                  Name,
                  Status,
                  AccountId,
                  ContactId,
                  SLA__c,
                  Install_Street1__c,
                  Install_Street2__c,
                  Install_City__c,
                  Install_State_Province__c
                  
                  FROM   Asset
                  WHERE  Name = 'TEST-ASSET-SHIPPED'];
        
        
        System.runAs(users[0])
        {
            ApexPages.StandardController contactController;
            contactExtensionsWithSharing contactExtension;
            PageReference returnedPageReference;
            
            contacts[0].contactInactive__c = true;
            
            contactController = new ApexPages.StandardController(contacts[0]);
            contactExtension  = new contactExtensionsWithSharing(contactController);
            
            System.assertEquals('Nimble Customer Portal Profile', contactExtension.profileName);
            System.assertEquals(users[0].accountId, contactExtension.accountId);
            
            returnedPageReference = contactExtension.contactCustomSave();
            System.assertEquals(null, returnedPageReference);
            System.assertEquals('Cannot store contact as Inactive because it is a contact on active assets (assets in Shipped or Return Pending status).', contactExtension.saveErrorMessage);
        }
    }
    static void testErrorActiveCase()
    {
        List<User> users;
        List<Contact> contacts;
        List<Asset> assets;
        List<Case> cases;
        Contact contact;
        Asset asset;
        Case aCase;
        
        users = [SELECT Id,
                 accountId
                 FROM   User
                 WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                 IsActive = true
                 LIMIT  1];
        contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                              LastName    = 'TEST-CONTACT-LAST-NAME',
                              Phone       = 'TEST-CONTACT-PHONE',
                              MobilePhone = 'TEST-CONTACT-MOBILE',
                              AccountId   = users[0].accountId);
        insert contact;
        contacts = [SELECT Id,
                    FirstName,
                    LastName,
                    Phone,
                    MobilePhone,
                    AccountId,
                    contactInactive__c
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                             ProductCode='SSD123',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage ArrayS',
                                             Controller_Code__c='CS2001',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct2;
        asset = new Asset(Name = 'TEST-ASSET-SCRAPPED',
                          Status = 'Scrapped',
                          AccountId = users[0].accountId,
                          ContactId = contacts[0].id,
                          SLA__c = 'Premium',
                          Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                          Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                          Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                          Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',Product2Id = testProduct2.id,HPE_Serial_Number__c = 'HPE123457',
                          Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                          Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                          Asset_Type_Build__c ='Testasupassettype');
        insert asset;
        assets = [SELECT Id,
                  Name,
                  Status,
                  AccountId,
                  ContactId,
                  SLA__c,
                  Install_Street1__c,
                  Install_Street2__c,
                  Install_City__c,
                  Install_State_Province__c
                  
                  FROM   Asset
                  WHERE  Name = 'TEST-ASSET-SCRAPPED'];
        
        
        // Create test case under portal user's account
        aCase = new Case(AccountId = users[0].accountId,
                         AssetId   = assets[0].id,
                         ContactId = contacts[0].id,
                         Status = 'Open',
                         Subject = 'TEST-CASE-OPEN-SUBJECT');
        insert aCase;
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Status,
                 Subject
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-OPEN-SUBJECT'];
        System.runAs(users[0])
        {
            ApexPages.StandardController contactController;
            contactExtensionsWithSharing contactExtension;
            PageReference returnedPageReference;
            
            contacts[0].contactInactive__c = true;
            
            contactController = new ApexPages.StandardController(contacts[0]);
            contactExtension  = new contactExtensionsWithSharing(contactController);
            
            System.assertEquals('Nimble Customer Portal Profile', contactExtension.profileName);
            System.assertEquals(users[0].accountId, contactExtension.accountId);
            
            returnedPageReference = contactExtension.contactCustomSave();
            System.assertEquals(null, returnedPageReference);
            System.assertEquals('Cannot store contact as Inactive because it is a contact on active cases (cases not in Closed status).', contactExtension.saveErrorMessage);
        }
    }   
  }