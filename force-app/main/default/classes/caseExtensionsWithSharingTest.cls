@isTest
private class caseExtensionsWithSharingTest
  {
   //Commented by vishnu on 16th may 2019 to avoid "System.LimitException: Too many SOQL queries: 101" issue
   // ==================================================================================== createTestData
   /*static testMethod void createTestData()
     {Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      CaseComment caseComment;
      List<Account>     accounts;
      List<Contact>     contacts;
      List<Product2>    products;
      List<Asset>       assets;
      List<Case>        cases;
      List<CaseComment> caseComments;
      ID testAccountId;
      ID testContactActiveId;
      ID testContactInactiveId;
      ID testProductArrayId;
      ID testProductShelfId;
      ID testAssetShippedId;
      ID testAssetScrappedId;
      ID testAssetShelfId;
      ID testCaseId;
      ID testCaseCommentId;

      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
      accounts = [SELECT Id,
                         Name
                  FROM   Account
                  WHERE  Name = 'TEST-ACCOUNT'];

      System.assertEquals(1,              accounts.size());
      System.assertEquals('TEST-ACCOUNT', accounts[0].Name);
      testAccountId = accounts[0].id;

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = testAccountId);
      insert contact;
      contacts = [SELECT Id,
                         FirstName,
                         LastName,
                         Phone,
                         MobilePhone,
                         AccountId
                  FROM   Contact
                  WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];

      System.assertEquals(1,                         contacts.size());
      System.assertEquals('TEST-CONTACT-FIRST-NAME', contacts[0].FirstName);
      System.assertEquals('TEST-CONTACT-LAST-NAME',  contacts[0].LastName);
      System.assertEquals('TEST-CONTACT-PHONE',      contacts[0].Phone);
      System.assertEquals('TEST-CONTACT-MOBILE',     contacts[0].MobilePhone);
      System.assertEquals(testAccountId,             contacts[0].AccountId);
      testContactActiveId = contacts[0].id;

      // Create test inactive contact
      contact = new Contact(FirstName          = 'TEST-CONTACT-INACTIVE-FIRST-NAME',
                            LastName           = 'TEST-CONTACT-INACTIVE-LAST-NAME',
                            Phone              = 'TEST-CONTACT-INACTIVE-PHONE',
                            MobilePhone        = 'TEST-CONTACT-INACTIVE-MOBILE',
                            AccountId          = testAccountId,
                            contactInactive__c = true);
      insert contact;
      contacts = [SELECT Id,
                         FirstName,
                         LastName,
                         Phone,
                         MobilePhone,
                         AccountId,
                         contactInactive__c
                  FROM   Contact
                  WHERE  LastName = 'TEST-CONTACT-INACTIVE-LAST-NAME'];

      System.assertEquals(1,                                  contacts.size());
      System.assertEquals('TEST-CONTACT-INACTIVE-FIRST-NAME', contacts[0].FirstName);
      System.assertEquals('TEST-CONTACT-INACTIVE-LAST-NAME',  contacts[0].LastName);
      System.assertEquals('TEST-CONTACT-INACTIVE-PHONE',      contacts[0].Phone);
      System.assertEquals('TEST-CONTACT-INACTIVE-MOBILE',     contacts[0].MobilePhone);
      System.assertEquals(testAccountId,                      contacts[0].AccountId);
      System.assertEquals(true,                               contacts[0].contactInactive__c);
      testContactInactiveId = contacts[0].id;

      // Create test product of family SAN Storage Array
      product = new Product2(IsActive    = true,
                             ProductCode = 'CS220',
                             Description = 'CS220 Array',
                             Family      = 'SAN Storage Array',
                             Name        = 'CS220 Array');

      insert product;

      products = [SELECT Id,
                         IsActive,
                         ProductCode,
                         Description,
                         Family,
                         Name
                  FROM   Product2
                  WHERE  Family   = 'SAN Storage Array'
                  LIMIT  1];

      System.assertEquals(1,                   products.size());
      System.assertEquals(true,                products[0].IsActive);
      System.assertEquals('CS220',             products[0].ProductCode);
      System.assertEquals('CS220 Array',       products[0].Description);
      System.assertEquals('SAN Storage Array', products[0].Family);
      System.assertEquals('CS220 Array',       products[0].Name);
      testProductArrayId = products[0].id;

      // Create test product of family Disk Shelf
      product = new Product2(IsActive    = true,
                             ProductCode = 'ES25',
                             Description = 'ES25 Disk Shelf',
                             Family      = 'Disk Shelf',
                             Name        = 'ES25 Disk Shelf');

      insert product;

      products = [SELECT Id,
                         IsActive,
                         ProductCode,
                         Description,
                         Family,
                         Name
                  FROM   Product2
                  WHERE  Family   = 'Disk Shelf'
                  LIMIT  1];

      System.assertEquals(1,                   products.size());
      System.assertEquals(true,                products[0].IsActive);
      System.assertEquals('ES25',              products[0].ProductCode);
      System.assertEquals('ES25 Disk Shelf',   products[0].Description);
      System.assertEquals('Disk Shelf',        products[0].Family);
      System.assertEquals('ES25 Disk Shelf',   products[0].Name);
      testProductShelfId = products[0].id;

      test.startTest();
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = testAccountId,
                        ContactId  = testContactActiveId,
                        product2Id = testProductArrayId,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE');
      insert asset;
      assets = [SELECT Id,
                       Name,
                       Status,
                       AccountId,
                       ContactId,
                       Product2Id,
                       Product2.Family,
                       SLA__c,
                       Install_Street1__c,
                       Install_Street2__c,
                       Install_City__c,
                       Install_State_Province__c

                FROM   Asset
                WHERE  Name = 'TEST-ASSET-SHIPPED'];

      System.assertEquals(1,                             assets.size());
      System.assertEquals('TEST-ASSET-SHIPPED',          assets[0].Name);
      System.assertEquals('Shipped',                     assets[0].Status);
      System.assertEquals(testAccountId,                 assets[0].AccountId);
      System.assertEquals(testContactActiveId,           assets[0].ContactId);
      System.assertEquals(testProductArrayId,            assets[0].Product2Id);
      System.assertEquals('SAN Storage Array',           assets[0].Product2.Family);
      System.assertEquals('Premium',                     assets[0].SLA__c);
      System.assertEquals('TEST-ASSET-INSTALL-STREET1',  assets[0].Install_Street1__c);
      System.assertEquals('TEST-ASSET-INSTALL-STREET2',  assets[0].Install_Street2__c);
      System.assertEquals('TEST-ASSET-INSTALL-CITY',     assets[0].Install_City__c);
      System.assertEquals('TEST-ASSET-INSTALL-STATE',    assets[0].Install_State_Province__c);
      testAssetShippedId = assets[0].id;

      // Create test Scrapped asset
      asset = new Asset(Name = 'TEST-ASSET-SCRAPPED',
                        Status = 'Scrapped',
                        AccountId = testAccountId,
                        ContactId = testContactActiveId,
                        Product2Id = testProductArrayId,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE');
      insert asset;
      assets = [SELECT Id,
                       Name,
                       Status,
                       AccountId,
                       ContactId,
                       Product2Id,
                       Product2.Family,
                       SLA__c,
                       Install_Street1__c,
                       Install_Street2__c,
                       Install_City__c,
                       Install_State_Province__c

                FROM   Asset
                WHERE  Name = 'TEST-ASSET-SCRAPPED'];

      System.assertEquals(1,                             assets.size());
      System.assertEquals('TEST-ASSET-SCRAPPED',         assets[0].Name);
      System.assertEquals('Scrapped',                    assets[0].Status);
      System.assertEquals(testAccountId,                 assets[0].AccountId);
      System.assertEquals(testContactActiveId,           assets[0].ContactId);
      System.assertEquals(testProductArrayId,            assets[0].Product2Id);
      System.assertEquals('SAN Storage Array',           assets[0].Product2.Family);
      System.assertEquals('Premium',                     assets[0].SLA__c);
      System.assertEquals('TEST-ASSET-INSTALL-STREET1',  assets[0].Install_Street1__c);
      System.assertEquals('TEST-ASSET-INSTALL-STREET2',  assets[0].Install_Street2__c);
      System.assertEquals('TEST-ASSET-INSTALL-CITY',     assets[0].Install_City__c);
      System.assertEquals('TEST-ASSET-INSTALL-STATE',    assets[0].Install_State_Province__c);
      testAssetScrappedId = assets[0].id;

      // Create test Shelf asset
      asset = new Asset(Name = 'TEST-ASSET-SHELF',
                        Status = 'Shipped',
                        AccountId = testAccountId,
                        ContactId = testContactActiveId,
                        Product2Id = testProductShelfId,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE');
      insert asset;
      assets = [SELECT Id,
                       Name,
                       Status,
                       AccountId,
                       ContactId,
                       Product2Id,
                       Product2.Family,
                       SLA__c,
                       Install_Street1__c,
                       Install_Street2__c,
                       Install_City__c,
                       Install_State_Province__c

                FROM   Asset
                WHERE  Name = 'TEST-ASSET-SHELF'];

      System.assertEquals(1,                             assets.size());
      System.assertEquals('TEST-ASSET-SHELF',            assets[0].Name);
      System.assertEquals('Shipped',                     assets[0].Status);
      System.assertEquals(testAccountId,                 assets[0].AccountId);
      System.assertEquals(testContactActiveId,           assets[0].ContactId);
      System.assertEquals(testProductShelfId,            assets[0].Product2Id);
      System.assertEquals('Disk Shelf',                  assets[0].Product2.Family);
      System.assertEquals('Premium',                     assets[0].SLA__c);
      System.assertEquals('TEST-ASSET-INSTALL-STREET1',  assets[0].Install_Street1__c);
      System.assertEquals('TEST-ASSET-INSTALL-STREET2',  assets[0].Install_Street2__c);
      System.assertEquals('TEST-ASSET-INSTALL-CITY',     assets[0].Install_City__c);
      System.assertEquals('TEST-ASSET-INSTALL-STATE',    assets[0].Install_State_Province__c);
      testAssetShelfId = assets[0].id;

      test.stopTest();
      // Create test case
      aCase = new Case(AccountId = testAccountId,
                       AssetId   = testAssetShippedId,
                       ContactId = testContactActiveId,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      cases = [SELECT Id,
                      AccountId,
                      AssetId,
                      ContactId,
                      Status,
                      Subject
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      System.assertEquals(1,                   cases.size());
      System.assertEquals(testAccountId,       cases[0].AccountId);
      System.assertEquals(testAssetShippedId,  cases[0].AssetId);
      System.assertEquals(testContactActiveId, cases[0].ContactId);
      System.assertEquals('Open',              cases[0].Status);
      System.assertEquals('TEST-CASE-SUBJECT', cases[0].Subject);
      testCaseId = cases[0].id;

      // Create test case comment
      caseComment = new CaseComment(ParentID    = testCaseId,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;

      caseComments = [SELECT Id,
                             ParentId,
                             IsPublished,
                             CommentBody
                      FROM   CaseComment
                      WHERE  ParentId = :testCaseId];

      System.assertEquals(1,                   caseComments.size());
      System.assertEquals(testCaseId,          caseComments[0].ParentId);
      System.assertEquals(true,                caseComments[0].IsPublished);
      System.assertEquals('TEST-CASE-COMMENT', caseComments[0].CommentBody);
      testCaseCommentId = caseComments[0].id;
     }*/
    
    
    /* Commented by Unnat - Nov 17, 2016 - Deployment failures as there are no active users under this profile 

   // ==================================================================================== testViewUrlPortalUser
   static testMethod void testViewUrlPortalUser()
     {List<User> users;
      List<Case> cases;
      Case aCase;

      users = [SELECT Id,
                      accountId
               FROM   User
               WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                      IsActive = true
               LIMIT  1];

      //System.assertEquals(1, users.size());

      // Create test case under portal user's account
      aCase = new Case(AccountId = users[0].accountId,
                       Status = 'Open',
                       Subject = 'TEST-CASE-OPEN-SUBJECT');
      insert aCase;
      cases = [SELECT Id,
                      AccountId,
                      Status,
                      Subject
               FROM   Case
               WHERE  Subject = 'TEST-CASE-OPEN-SUBJECT'];

      System.assertEquals(1,                        cases.size());
      System.assertEquals(users[0].accountId,       cases[0].AccountId);
      System.assertEquals('Open',                   cases[0].Status);
      System.assertEquals('TEST-CASE-OPEN-SUBJECT', cases[0].Subject);

      System.runAs(users[0])
        {ApexPages.StandardController caseController;
         caseExtensionsWithSharing caseExtension;

         caseController = new ApexPages.StandardController(cases[0]);
         caseExtension  = new caseExtensionsWithSharing(caseController);

         System.assertEquals('Nimble Customer Portal Profile', caseExtension.profileName);
         System.assertEquals('/apex/caseportalviewpage', caseExtension.caseDispatchViewUrl().getUrl());
        }
     }

   // ==================================================================================== testEditUrlPortalUser
   static testMethod void testEditUrlPortalUser()
     {List<User> users;
      List<Case> cases;
      Case aCase;

      users = [SELECT Id,
                      accountId
               FROM   User
               WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                      IsActive = true
               LIMIT  1];

      //System.assertEquals(1, users.size());

      // Create test case under portal user's account
      aCase = new Case(AccountId = users[0].accountId,
                       Status = 'Open',
                       Subject = 'TEST-CASE-OPEN-SUBJECT');
      insert aCase;
      cases = [SELECT Id,
                      AccountId,
                      Status,
                      Subject
               FROM   Case
               WHERE  Subject = 'TEST-CASE-OPEN-SUBJECT'];

      System.assertEquals(1,                        cases.size());
      System.assertEquals(users[0].accountId,       cases[0].AccountId);
      System.assertEquals('Open',                   cases[0].Status);
      System.assertEquals('TEST-CASE-OPEN-SUBJECT', cases[0].Subject);

      System.runAs(users[0])
        {ApexPages.StandardController caseController;
         caseExtensionsWithSharing caseExtension;

         caseController = new ApexPages.StandardController(cases[0]);
         caseExtension  = new caseExtensionsWithSharing(caseController);

         System.assertEquals('Nimble Customer Portal Profile', caseExtension.profileName);
         System.assertEquals('/apex/caseportaleditpage', caseExtension.caseDispatchEditUrl().getUrl());
        }
     }

   // ==================================================================================== testNewUrlPortalUser
   static testMethod void testNewUrlPortalUser()
     {List<User> users;
      Case aCase;

      users = [SELECT Id,
                      accountId
               FROM   User
               WHERE  Profile.Name = 'Nimble Customer Portal Profile' and
                      IsActive = true
               LIMIT  1];

      //System.assertEquals(1, users.size());

      // Create test case under portal user's account
      aCase = new Case(AccountId = users[0].accountId,
                       Status = 'Open',
                       Subject = 'TEST-CASE-OPEN-SUBJECT');

      System.runAs(users[0])
        {ApexPages.StandardController caseController;
         caseExtensionsWithSharing caseExtension;

         caseController = new ApexPages.StandardController(aCase);
         caseExtension  = new caseExtensionsWithSharing(caseController);

         System.assertEquals('Nimble Customer Portal Profile', caseExtension.profileName);
         System.assertEquals('/apex/caseportalnewpage', caseExtension.caseDispatchNewUrl().getUrl());
        }
     }
     
     */

     // ==================================================================================== testViewUrlNonPortalUser
   static testMethod void testViewUrlNonPortalUser()
     {List<Case> cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     
      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
      
 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;
 

      test.startTest();
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;

      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      cases = [SELECT Id,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];
      Test.stopTest();
      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertNotEquals('Nimble Customer Portal Profile', caseExtension.profileName);
      System.assertEquals('/' + cases[0].id + '?nooverride=1', caseExtension.caseDispatchViewUrl().getUrl());
     }

   // ==================================================================================== testEditUrlNonPortalUser
   static testMethod void testEditUrlNonPortalUser()
     {List<Case> cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;

      //createTestData();
      //Added by vishnu to avoid 101 SOQL Issue.
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
     product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;
      test.startTest();
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;

      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      cases = [SELECT Id, RecordTypeId,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];
      Test.stopTest();
      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertNotEquals('Nimble Customer Portal Profile', caseExtension.profileName);
      System.assertEquals('/apex/caseneworeditpage?RecordType='+cases[0].RecordTypeId, caseExtension.caseDispatchEditUrl().getUrl());
     }

   
   // ==================================================================================== testImpactDescriptionLow
   static testMethod void testImpactDescriptionLow()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      
       Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case aCase;
      
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

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      caseExtension.casePortalImpact = 'LOW';

      System.assertEquals('(no impact to I/O or operations; administrative/question/etc)', caseExtension.getCasePortalImpactDescription());
     }

   // ==================================================================================== testImpactDescriptionMinor
   static testMethod void testImpactDescriptionMinor()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case aCase;
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

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      caseExtension.casePortalImpact = 'MINOR';

      System.assertEquals('(minor impact to I/O or operations)', caseExtension.getCasePortalImpactDescription());
     }

   // ==================================================================================== testImpactDescriptionMajor
   static testMethod void testImpactDescriptionMajor()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
       Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case aCase;
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
                        product2Id = product.Id,assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB'
                        );
              insert asset;
      
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      caseExtension.casePortalImpact = 'MAJOR';

      System.assertEquals('(major impact to I/O or operations)', caseExtension.getCasePortalImpactDescription());
     }

   // ==================================================================================== testImpactDescriptionCritical
   static testMethod void testImpactDescriptionCritical()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      
       Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case aCase;
      
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

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',
                        Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      caseExtension.casePortalImpact = 'CRITICAL';

      System.assertEquals('(system down; no I/O being served)', caseExtension.getCasePortalImpactDescription());
     }

   // ==================================================================================== testImpactDescriptionUnknown
   static testMethod void testImpactDescriptionUnknown()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
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
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      caseExtension.casePortalImpact = 'UNKNOWN';

      System.assertEquals('(unknown)', caseExtension.getCasePortalImpactDescription());
     }

   // ==================================================================================== testImpactLow
   static testMethod void testImpactLow()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      
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

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertEquals('LOW', caseExtension.casePortalImpact);
     }
     

   // ==================================================================================== testImpactMinor
   static testMethod void testImpactMinor()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
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

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status   = 'Open',
                       Priority = 'P3',
                       Subject  = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertEquals('MINOR', caseExtension.casePortalImpact);
     }

   // ==================================================================================== testImpactMajor
   static testMethod void testImpactMajor()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
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

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status   = 'Open',
                       Priority = 'P2',
                       Subject  = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertEquals('MAJOR', caseExtension.casePortalImpact);
     }

   // ==================================================================================== testImpactCritical
   static testMethod void testImpactCritical()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case aCase;
      
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

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',
                       Status   = 'Open',
                       Priority = 'P1',
                       Subject  = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertEquals('CRITICAL', caseExtension.casePortalImpact);
     }

   // ==================================================================================== testImpactUnknown
   static testMethod void testImpactUnknown()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
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

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status   = 'Open',
                       //Priority = 'UNKNOWN',
                       Subject  = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertEquals('Unknown', caseExtension.casePortalImpact);
     }

    
   // ==================================================================================== testCaseCustomCommentNew
   static testMethod void testCaseCustomCommentNew()
     {List<Case> cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      CaseComment caseComment;
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
      product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

      
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;
      test.startTest();
      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      // Create test case comment
      caseComment = new CaseComment(ParentID    = aCase.Id,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;

      
      cases = [SELECT Id,
                      Subject,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];
      
      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      Test.stopTest();
      System.assertEquals('/apex/caseportalnewcommentpage', caseExtension.caseCustomCommentNew().getUrl());
     }

   // ==================================================================================== testCaseCustomCommentSave
   static testMethod void testCaseCustomCommentSave()
     {List<Case> cases;
      List<CaseComment> caseComments;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      Integer numCommentsBefore;
      Integer numCommentsAfter;
      PageReference returnedPageReference;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      CaseComment caseComment;
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
     
 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;
      
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;
      test.startTest();
      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      // Create test case comment
      caseComment = new CaseComment(ParentID    = aCase.Id,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;
      
      cases = [SELECT Id,
                      Subject,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      caseComments = [SELECT Id,
                             ParentId
                      FROM   CaseComment
                      WHERE  ParentId = :cases[0].id];
      //Test.stopTest();
      if (caseComments.size() == null)
        {numCommentsBefore = 0;
        }
      else
        {numCommentsBefore = caseComments.size();
        }
      
      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      caseExtension.caseCommentNewText = 'TEST-CASE-COMMENT';
      returnedPageReference = caseExtension.caseCustomCommentSave();

      System.assertEquals('/apex/caseportalviewpage', returnedPageReference.getUrl());

      caseComments = [SELECT Id,
                             ParentId
                      FROM   CaseComment
                      WHERE  ParentId = :cases[0].id];

      if (caseComments.size() == null)
        {numCommentsAfter = 0;
        }
      else
        {numCommentsAfter = caseComments.size();
        }
      Test.stopTest();
      System.assertEquals(numCommentsBefore + 1, numCommentsAfter);
     
     }

   // ==================================================================================== testCaseCustomCommentCancel
   static testMethod void testCaseCustomCommentCancel()
     {List<Case> cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      PageReference returnedPageReference;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      CaseComment caseComment;
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
    
 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;
      
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;
      test.startTest();
      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      // Create test case comment
      caseComment = new CaseComment(ParentID    = aCase.Id,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;
      
      cases = [SELECT Id,
                      Subject,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];
      
      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      caseExtension.caseCommentNewText = 'TEST-CASE-COMMENT';
      returnedPageReference = caseExtension.caseCustomCommentCancel();

      Test.stopTest();
      System.assertEquals(null, caseExtension.caseCommentNewText);
      System.assertEquals('/apex/caseportalviewpage', returnedPageReference.getUrl());
     }

   // ==================================================================================== testCaseCustomResolve
   static testMethod void testCaseCustomResolve()
     {List<Case> cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      CaseComment caseComment;
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
      product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

      
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;
      Test.startTest();
      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      // Create test case comment
      caseComment = new CaseComment(ParentID    = aCase.Id,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;

     
      cases = [SELECT Id,
                      Subject,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

       Test.stopTest();
      System.assertEquals('/apex/caseportalresolvepage', caseExtension.caseCustomResolve().getUrl());
     }

   // ==================================================================================== testCaseCustomResolveSave
   static testMethod void testCaseCustomResolveSave()
     {List<Case> cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      PageReference returnedPageReference;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      CaseComment caseComment;
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
      product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

     
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;

      // Create test case
      test.startTest();
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      // Create test case comment
      caseComment = new CaseComment(ParentID    = aCase.Id,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;
    
      
      cases = [SELECT Id,
                      Subject,
                      casePortalResolutionNotes__c,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      cases[0].casePortalResolutionNotes__c = 'TEST-CASE-RESOLUTION-NOTES';
      returnedPageReference = caseExtension.caseCustomResolveSave();
      Test.stopTest();
      cases = [SELECT Id,
                      Status,
                      casePortalResolutionNotes__c
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];
         

      System.assertEquals('Resolved', cases[0].Status);
      System.assertEquals('TEST-CASE-RESOLUTION-NOTES', cases[0].casePortalResolutionNotes__c);
      System.assertEquals('/apex/caseportalviewpage', returnedPageReference.getUrl());
    
     }

   // ==================================================================================== testCaseCustomResolveCancel
   static testMethod void testCaseCustomResolveCancel()
     {List<Case> cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      PageReference returnedPageReference;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      CaseComment caseComment;
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
     
 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

     
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;
      test.startTest();
      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      // Create test case comment
      caseComment = new CaseComment(ParentID    = aCase.Id,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;
      //Test.stopTest();      
      cases = [SELECT Id,
                      Subject,
                      casePortalResolutionNotes__c,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      returnedPageReference = caseExtension.caseCustomResolveCancel();

      Test.stopTest();
      System.assertEquals('/apex/caseportalviewpage', returnedPageReference.getUrl());
     }

   // ==================================================================================== testDisplayResolveButton
   static testMethod void testDisplayResolveButton()
     {List<Case> cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      case acase1;
      CaseComment caseComment;
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
       product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

      
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                        assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                        Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                        Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                        Array_Controller_SKU__c = 'SD-Test',
                        Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;
      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      test.startTest();
      
      // Create test case comment
      caseComment = new CaseComment(ParentID    = aCase.Id,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;

          
      cases = [SELECT Id,
                      Subject,AssetId,AccountId,
                      Status
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];
      cases[0].status = 'Escalated';
      update cases;
            cases[0].status = 'Wait-Fix';
      update cases;
      
      cases[0].status = 'Awaiting Customer';
      update cases;
      //cases[0].status = 'Awaiting Engineering';
      //update cases;
      //cases[0].status = 'Handover';
      //update cases;
      

      

      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);
       
    
      Test.stopTest();
      System.assertEquals(true, caseExtension.displayResolveButton);
     }

   // ==================================================================================== testDisplayNewCommentButton
   static testMethod void testDisplayNewCommentButton()
     {List<Case> cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;

      //createTestData();
        Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      CaseComment caseComment;
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
     
 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

      
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                        assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                        Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                        Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                        Array_Controller_SKU__c = 'SD-Test',
                        Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;
      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'On Hold',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      test.startTest();
      
      
      
      // Create test case comment
      caseComment = new CaseComment(ParentID    = aCase.Id,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;
      
      cases = [SELECT Id,
                      Subject,
                      Status,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];
      cases[0].status = 'Escalated';
      update cases;
      cases[0].status = 'Wait-Fix';
      update cases;
      
      //cases[0].status = 'Awaiting Customer';
      //update cases;
      //cases[0].status = 'Awaiting Engineering';
      //update cases;
      //cases[0].status = 'Handover';
      //update cases;

      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      Test.stopTest();
      System.assertEquals(true, caseExtension.displayNewCommentButton);
     }

   // ==================================================================================== testGetCaseComments
   static testMethod void testGetCaseComments()
     {List<CaseComment> caseComments;
      List<Case>        cases;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case        aCase;
      CaseComment caseComment;
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
     
 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;
      test.startTest();
      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      // Create test case comment
      caseComment = new CaseComment(ParentID    = aCase.Id,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;
      
      cases = [SELECT Id,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      caseComments = caseExtension.getCaseComments();
      Test.stopTest();      
      System.assertEquals(1,                   caseComments.size());
      System.assertEquals('TEST-CASE-COMMENT', caseComments[0].CommentBody);
     }

   // ==================================================================================== testNumMyAttnReqCases
   static testMethod void testNumMyAttnReqCases()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
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
      

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertEquals(0, caseExtension.numMyAttnReqCases);
     }

   // ==================================================================================== testNumNotMyAttnReqCases
   static testMethod void testNumNotMyAttnReqCases()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
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

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertEquals(0, caseExtension.numNotMyAttnReqCases);
     }

   // ==================================================================================== testListMyAttnReqCases
   static testMethod void testListMyAttnReqCases()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
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

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertEquals(0, caseExtension.listMyAttnReqCases.size());
     }

   // ==================================================================================== testListNotMyAttnReqCases
   static testMethod void testListNotMyAttnReqCases()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
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
                        product2Id = product.Id,assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB'
                        );
              insert asset;

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertEquals(0, caseExtension.listNotMyAttnReqCases.size());
     }
      
            // ==================================================================================== testCaseAbbreviation
    /*  static testMethod void testCaseAbbreviation()
      {ApexPages.StandardController caseController;
       caseExtensionsWithSharing caseExtension;
       PageReference returnedPageReference;
       Account account;
       Contact contact;
       Asset   asset;
       Case aCase;
       QualifiedHandling__c qhrecord;
       Qualified_Handling_User__c cModel;
       
       String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
       Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)'];
       User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                         LocaleSidKey='en_US', ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles',
                         UserName=uniqueUserName);
       System.runAs(u){
           //Create new Qulaified Handling
           insert qhrecord = new QualifiedHandling__c(Name = 'US Defense',
                                                      qhFeatures__c = null,
                                                      qhLabel__c= 'Case Abbreviation',
                                                      qhDescription__c = 'Only Limited visibility to the case for TSE.',
                                                      qhDocumentationURL__c='https://nimblejira.nimblestorage.com/browse/TS-5755',
                                                      qhExternalVerbiage__c='Tse can only view the case and add a private comment to Case.');
           //Create new Cmodel 
           //insert cModel = new Qualified_Handling_User__c(cmQualifiedHandling__c = qhrecord.Id,
                                                    //cmUser__c = u.Id);
           
           //Create Contribution Model TSE and update the Qualified Handling detail.
         CntrbnMdl_TSE__c tse = new CntrbnMdl_TSE__c(Employee_Name__c = u.id,team__c='HQ',organization__c='TSE',Qualified_Handling__c='US Defense');
         insert tse;
           
           insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI',
                                        accountQualifiedHandling__c = qhrecord.Id);
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
           
           // Create test asset
           insert asset = new Asset(Name = 'TEST-ASSET',
                                    AccountId = account.Id,
                                    ContactId = contact.Id,
                                    SLA__c = 'Premium',
                                    assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                    assetQualifiedHandling__c = qhrecord.Id );
           
           System.assertNotEquals(null,                      asset.Id);
           System.assertEquals('TEST-ASSET',                  asset.Name);
           System.assertEquals(account.Id,                 asset.AccountId);
           System.assertEquals(contact.Id,                 asset.ContactId);
           System.assertEquals('Premium',                     asset.SLA__c);
           System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
           //Create new case
           aCase = new Case(Status = 'Open',
                            Subject = 'TEST-CASE-SUBJECT',caseAttnReq__c = true,RecordTypeId = '01234000000BnF4',AccountId = account.Id,AssetId=asset.Id);

           caseController = new ApexPages.StandardController(aCase);
           caseExtension  = new caseExtensionsWithSharing(caseController);
           
       }
      } */
   // ==================================================================================== testCaseArticles
   static testMethod void testCaseArticles()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case aCase;
      
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
      
      List<KnowledgeArticleVersion> knowledgeArticleVersions;

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',
                       caseCatImpactToCustomer__c='Array Not Coming Up (including DOA)',
                       Status   = 'Open',
                       Priority = 'P4',
                       Technology_Area__c='3rd Party Apps',
                       Sub_Technology_Area__c='Access',
                       Subject = 'TEST-CASE-SUBJECT',
                       caseAttnReq__c = true);
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);
      knowledgeArticleVersions = caseExtension.getCaseArticles();
      System.assertEquals(0, knowledgeArticleVersions.size());
     }
    
        static testMethod void testmethodv1()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case aCase;
      
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
      
      List<KnowledgeArticleVersion> knowledgeArticleVersions;

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',
                       caseCatImpactToCustomer__c='Array Not Coming Up (including DOA)',
                       Status   = 'Open',
                       Priority = 'P4',
                       Technology_Area__c='3rd Party Apps',
                       Sub_Technology_Area__c='Access',
                       Subject = 'TEST-CASE-SUBJECT',
                       RecordTypeId='01234000000BnF4',
                       caseAttnReq__c = true);
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);
      knowledgeArticleVersions = caseExtension.getCaseArticles();
      ApexPages.currentPage().getParameters().put('RecordType','01234000000BnF4');
      caseExtension.caseDispatchEditUrl().getUrl();
     }
      
    static testMethod void testmethodv2()
     {
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case aCase;
      
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
      
      List<KnowledgeArticleVersion> knowledgeArticleVersions;

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',
                       caseCatImpactToCustomer__c='Array Not Coming Up (including DOA)',
                       Status   = 'Open',
                       Priority = 'P4',
                       Technology_Area__c='3rd Party Apps',
                       Sub_Technology_Area__c='Access',
                       Subject = 'TEST-CASE-SUBJECT',
                       RecordTypeId='01234000000BnF4',
                       caseAttnReq__c = true);
      insert aCase;

      list<RecordType> recordtype= [ select Id,Name from RecordType where sObjectType='Case' and Name='InfoSight Portal'];
      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);
      knowledgeArticleVersions = caseExtension.getCaseArticles();
      ApexPages.currentPage().getParameters().put('RecordType',recordtype[0].Id);
      caseExtension.caseDispatchEditUrl().getUrl();
     }
     
    static testMethod void testmethodv3()
     {
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      Case aCase;
      
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
      
      List<KnowledgeArticleVersion> knowledgeArticleVersions;

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',
                       caseCatImpactToCustomer__c='Array Not Coming Up (including DOA)',
                       Status   = 'Open',
                       Priority = 'P4',
                       Technology_Area__c='3rd Party Apps',
                       Sub_Technology_Area__c='Access',
                       Subject = 'TEST-CASE-SUBJECT',
                        
                       caseAttnReq__c = true);
      insert aCase;

      
      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);
      knowledgeArticleVersions = caseExtension.getCaseArticles();
        //caseExtension.caseDispatchEditUrl().getUrl();
       
     }
 static testMethod void testNewUrlNonPortalUser()
     { List<Case> cases;
      List<asset> aAsset;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
         
    //Added by Dharani on 28th Aug 2019 to avoid "System.NullPointerException: Attempt to de-reference a null object" issue     
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
       aAsset = [SELECT Id, AccountId,ContactId,product2Id
               FROM   asset
               WHERE  Name = 'TEST-ASSET-SHELF'];

      aCase = new Case(AccountId = account.Id,
                       AssetId   = aAsset[0].Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
         insert aCase;
         cases = [SELECT Id, RecordTypeId,AssetId,AccountId
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      caseController = new ApexPages.StandardController(cases[0]);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      System.assertNotEquals('Nimble Customer Portal Profile', caseExtension.profileName);
      System.assertEquals('/apex/casenewpage', caseExtension.caseDispatchNewUrl().getUrl());
     }

    
      static testMethod void testImpactValues()
     {ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
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
      List<SelectOption> returnedValues;

      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Origin = 'Phone',Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      returnedValues = caseExtension.getCasePortalImpactValues();
      System.assertEquals(4, returnedValues.size());
     }

    
     static testMethod void testGoodSave()
     {List<Contact> contacts;
      List<Asset> assets;
      List<Account> accounts;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      Case aCase;
      PageReference returnedPageReference;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      //Case        aCase;
      
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
     
 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

      test.startTest();
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;

      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      assets = [SELECT Id
                FROM   Asset
                WHERE  Name = 'TEST-ASSET-SHIPPED'];

      contacts = [SELECT Id
                  FROM   Contact
                  WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];

      accounts = [SELECT Id
                  FROM   Account
                  WHERE  Name = 'TEST-ACCOUNT'];

      aCase = new Case(Status            = 'Open',
                       Priority          = 'P3',
                       Nimble_Version__c = '1.4.5.0',
                       assetId           = assets[0].id,
                       contactId         = contacts[0].id,
                       accountId         = accounts[0].id,
                       Subject           = 'TEST-CASE-SUBJECT');
        Test.stopTest();
      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      returnedPageReference = caseExtension.caseCustomSave();
      
     }

    
     static testMethod void testErrorInactiveContact()
     {List<Contact> contacts;
      List<Asset> assets;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      Case aCase;
      PageReference returnedPageReference;

      //createTestData();
       Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     
      // Create test inactive contact
      contact = new Contact(FirstName          = 'TEST-CONTACT-INACTIVE-FIRST-NAME',
                            LastName           = 'TEST-CONTACT-INACTIVE-LAST-NAME',
                            Phone              = 'TEST-CONTACT-INACTIVE-PHONE',
                            MobilePhone        = 'TEST-CONTACT-INACTIVE-MOBILE',
                            AccountId          = account.Id,
                            contactInactive__c = true);
      insert contact;
      

      // Create test product of family SAN Storage Array
      
 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

      test.startTest();
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;

      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;


      assets = [SELECT Id
                FROM   Asset
                WHERE  Name = 'TEST-ASSET-SHIPPED'];

      contacts = [SELECT Id
                  FROM   Contact
                  WHERE  LastName = 'TEST-CONTACT-INACTIVE-LAST-NAME'];

      aCase = new Case(Status    = 'Open',
                       Priority  = 'P3',
                       assetId   = assets[0].id,
                       contactId = contacts[0].id,
                       Subject   = 'TEST-CASE-SUBJECT');

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      returnedPageReference = caseExtension.caseCustomSave();
       
     }
    
     static testMethod void testErrorBadAssetStatus()
     {List<Asset> assets;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      Case aCase;
      PageReference returnedPageReference;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;
      test.startTest();
       // Create test Scrapped asset
      asset = new Asset(Name = 'TEST-ASSET-SCRAPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;

      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      // Create test case comment
      /*caseComment = new CaseComment(ParentID    = testCaseId,
                                    IsPublished = true,
                                    CommentBody = 'TEST-CASE-COMMENT');

      insert caseComment;*/

      assets = [SELECT Id
                FROM   Asset
                WHERE  Name = 'TEST-ASSET-SCRAPPED'];

      aCase = new Case(Status   = 'Open',
                       Priority = 'P3',
                       assetId  = assets[0].id,
                       Subject  = 'TEST-CASE-SUBJECT');

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      returnedPageReference = caseExtension.caseCustomSave();
      Test.stopTest();
      
     }
     static testMethod void a_testErrorDiskShelf()
     {List<Asset> assets;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      Case aCase;
      PageReference returnedPageReference;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);

      insert contact;
      // Create test inactive contact
      /*contact = new Contact(FirstName          = 'TEST-CONTACT-INACTIVE-FIRST-NAME',
                            LastName           = 'TEST-CONTACT-INACTIVE-LAST-NAME',
                            Phone              = 'TEST-CONTACT-INACTIVE-PHONE',
                            MobilePhone        = 'TEST-CONTACT-INACTIVE-MOBILE',
                            AccountId          = account.Id,
                            contactInactive__c = true);
      insert contact;*/
      

      // Create test product of family Disk Shelf
      product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;
     
      // Create test Shelf asset
      asset = new Asset(Name = 'TEST-ASSET-SHELF',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;
      Test.startTest();
      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      
      assets = [SELECT Id
                FROM   Asset
                WHERE  Name = 'TEST-ASSET-SHELF'];

      aCase = new Case(Status   = 'Open',
                       Priority = 'P3',
                       AccountId = account.Id,
                       assetId  = assets[0].id,
                       ContactId = contact.Id,
                       Subject  = 'TEST-CASE-SUBJECT');

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);
     
      returnedPageReference = caseExtension.caseCustomSave();
      test.stopTest(); 
     }
 static testMethod void testGoodSave1()
     {List<Contact> contacts;
      List<Asset> assets;
      List<Account> accounts;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      Case aCase;
      PageReference returnedPageReference;

      //createTestData();
      Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      //Case        aCase;
      
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     

      // Create test active contact
      contact = new Contact(FirstName   = 'TEST-CONTACT-FIRST-NAME',
                            LastName    = 'TEST-CONTACT-LAST-NAME',
                            Phone       = 'TEST-CONTACT-PHONE',
                            MobilePhone = 'TEST-CONTACT-MOBILE',
                            AccountId   = account.Id);
      insert contact;
      

      // Create test product of family SAN Storage Array
     
  product = new Product2(IsActive    = true,
                             ProductCode = 'ES25',
                             Description = 'ES25 Disk Shelf',
                             Family      = 'SAN Storage Array',
                             Name        = 'ES25 Disk Shelf');

      insert product;
      test.startTest();
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;

      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;
      
      assets = [SELECT Id
                FROM   Asset
                WHERE  Name = 'TEST-ASSET-SHIPPED'];

      contacts = [SELECT Id
                  FROM   Contact
                  WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];

      accounts = [SELECT Id
                  FROM   Account
                  WHERE  Name = 'TEST-ACCOUNT'];

      aCase = new Case(Status            = 'Open',
                       Priority          = 'P3',
                       Nimble_Version__c = '1.4.5.0',
                       assetId           = asset.Id,
                       contactId         = contacts[0].id,
                       accountId         = accounts[0].id,
                       Subject           = 'TEST-CASE-SUBJECT');
              Test.stopTest();
      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      returnedPageReference = caseExtension.caseCustomSave();
      
     }
      static testMethod void testErrorInactiveContact01()
     {List<Contact> contacts;
      List<Asset> assets;
      ApexPages.StandardController caseController;
      caseExtensionsWithSharing caseExtension;
      Case aCase;
      PageReference returnedPageReference;

      //createTestData();
       Account     account;
      Contact     contact;
      Product2    product;
      Asset       asset;
      
      
      // Create test account
      account = new Account(Name = 'TEST-ACCOUNT');
      insert account;
     
      // Create test inactive contact
      contact = new Contact(FirstName          = 'TEST-CONTACT-INACTIVE-FIRST-NAME',
                            LastName           = 'TEST-CONTACT-INACTIVE-LAST-NAME',
                            Phone              = 'TEST-CONTACT-INACTIVE-PHONE',
                            MobilePhone        = 'TEST-CONTACT-INACTIVE-MOBILE',
                            AccountId          = account.Id,
                            contactInactive__c = true);
      insert contact;
      

      // Create test product of family SAN Storage Array
      
 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SD-Test';
        insert product;

      test.startTest();
      // Create test Shipped asset
      asset = new Asset(Name = 'TEST-ASSET-SHIPPED',
                        Status = 'Shipped',
                        AccountId  = account.Id,
                        ContactId  = contact.Id,
                        product2Id = product.Id,
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                       assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test',
                       Array_Capacity_SKU__c ='HEAD-HDD-21TB');
      insert asset;

      // Create test case
      aCase = new Case(AccountId = account.Id,
                       AssetId   = asset.Id,
                       ContactId = contact.Id,
                       Status = 'Open',
                       Subject = 'TEST-CASE-SUBJECT');
      insert aCase;


      assets = [SELECT Id
                FROM   Asset
                WHERE  Name = 'TEST-ASSET-SHIPPED'];

      contacts = [SELECT Id
                  FROM   Contact
                  WHERE  LastName = 'TEST-CONTACT-INACTIVE-LAST-NAME'];

      aCase = new Case(Status    = 'Open',
                       Priority  = 'P3',
                       assetId   = assets[0].id,
                       contactId = contacts[0].id,
                       Subject   = 'TEST-CASE-SUBJECT');

      caseController = new ApexPages.StandardController(aCase);
      caseExtension  = new caseExtensionsWithSharing(caseController);

      returnedPageReference = caseExtension.caseClearAttnReq();
       
     }

  }