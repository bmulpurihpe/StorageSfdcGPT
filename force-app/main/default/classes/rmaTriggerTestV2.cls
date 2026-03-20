@isTest
private class rmaTriggerTestV2
  {// ==================================================================================== createTestData
      
      
     private static List<Id> testAccountIds = new List<Id>();
     private static List<Id> testContactIds = new List<Id>();
     private static List<Id> testAssetIds = new List<Id>();
     private static List<Id> testCaseIds = new List<Id>();
     private static List<Id> testDepotIds = new List<Id>();
     private static List<Id> testAddressBookIds = new List<Id>();
     private static List<Id> testRMAIds = new List<Id>();  

     static testMethod void createTestData()
     {
         createAccount();
         createContact();
         createAsset();
         Test.startTest();
         createCase();
         createDepot();
         createNBDNDEntries();
         create4HourEntries();
         createRMA();
         Test.stopTest();
         createPostalCode();
         
     }
      
      class TestData{
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        SR_Meta_Data__c srMetaData;
        Component__c testComponent1;
        
        
        TestData() {
            
            // Create test account
            account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
            System.assertNotEquals(null,              account.Id);
            System.assertEquals('Test Support Tools QA', account.Name);
            
            // Create test contact
            contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Test Exafort' LIMIT 1];
            System.assertNotEquals(null,contact.Id);
            System.assertEquals(account.Id,contact.AccountId);
            System.assertEquals('Test Exafort', contact.LastName);
            
            // Create test asset
            asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' LIMIT 1];
            System.assertNotEquals(null,                      asset.Id);
            System.assertEquals('AA-000000',                  asset.Name);
            System.assertEquals(account.Id,                 asset.AccountId);
            System.assertEquals(contact.Id,                 asset.ContactId);
            System.assertEquals('Premium',                     asset.SLA__c);
            
            //Create test case
            aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' LIMIT 1];
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            System.assertEquals(contact.Id,       aCase.ContactId);
            System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);
            
            //Create test Address Book
            addressBook=[Select Id,Name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
                         abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id ORDER BY Name LIMIT 1];
            System.assertNotEquals(null,             addressBook.Id);
            System.assertEquals(account.Id,       addressBook.abAccount__c);
            
        }
      }
     //Create Account
     static void createAccount()
     { 
         Account account;
         ActivateTrigger__c 			 activateTriggerCustomSetting;
         //check the custom setting value set for the rma trigger to run.
         insert activateTriggerCustomSetting = new ActivateTrigger__c(RMATrigger__c = True);
         
         List<Account>  insAccounts = new List<Account>();
         Set<String> sAccountNames = new Set<String>();
         
         for(Integer i=0; i< 1; i++)
         {
             String accName = 'TEST-ACCOUNT' + i;
             sAccountNames.add(accName);
             account = new Account(Name = accName,accountRmaShi__c = 'AccountTestShi' + i);
             insAccounts.add(account);
         }
         
         insert insAccounts;
         
          List<Account>  accounts = [SELECT Id,
                         Name,accountRmaShi__c
                  FROM   Account
                  WHERE  Name IN : sAccountNames order by Name];
         
          System.assertEquals(insAccounts.size(),              accounts.size());
         
          for(Integer i=0;i<accounts.size();i++)
          {
            System.assertEquals('TEST-ACCOUNT' + i, accounts[i].Name,'Account Name - TEST-ACCOUNT' + i);
            System.assertEquals('AccountTestShi' + i, accounts[i].accountRmaShi__c,'Account Name - TEST-ACCOUNT' + i);
            testAccountIds.add(accounts[i].Id);
          }
         
        
         
     }
      
     //Create Contact
     static void createContact()
     {    
         Contact  contact;
         List<Contact>  insContacts = new List<Contact>();
         Set<String> sContactNames = new Set<String>();
         
         for(Integer i=0; i< 1; i++)
         {
             String conName = 'TEST-CONTACT-LAST-NAME' + i;
             sContactNames.add(conName);
             contact = new Contact(LastName = conName,AccountId = testAccountIds[i]);
             insContacts.add(contact);
         }
         
         insert insContacts;
         
          List<Contact>  contacts = [SELECT Id,
                         LastName,
                         AccountId
                  FROM   Contact
                  WHERE  LastName IN: sContactNames order by LastName];
         
          System.assertEquals(insContacts.size(),              contacts.size());
         
          for(Integer i=0;i<contacts.size();i++)
          {
            System.assertEquals('TEST-CONTACT-LAST-NAME' + i, contacts[i].LastName,'Contact LastName - TEST-CONTACT-LAST-NAME' + i);
            System.assertEquals(testAccountIds[i], contacts[i].AccountId,'Contact LastName - TEST-CONTACT-LAST-NAME' + i);
            testContactIds.add(contacts[i].Id);
          }
         
         
         
     }
      
     //Create Asset
     static void createAsset()
     {    
         Asset  asset;
         List<Asset>  insAssets = new List<Asset>();
         Set<String> sAssetNames = new Set<String>();
         
         for(Integer i=0; i< 1; i++)
         {
             String assetName = 'TEST-ASSET' + i;
             sAssetNames.add(assetName);
             Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                                  ProductCode='SSD123',
                                                  Product_Type__c='Hardware',
                                                  Product_Type_2__c='SAN Storage ArrayS',
                                                  Controller_Code__c='CS2001',
                                                  Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                  Family='SAN Storage Array');
             insert testProduct2;
             asset = new Asset(Name = assetName,
                        AccountId = testAccountIds[i],
                        ContactId = testContactIds[i],
                        SLA__c = 'Premium',
                        Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                        Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                        Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                        Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
                        HPE_Serial_Number__c = 'AA000000NIM',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                        assetRmaShi__c = 'AssetTestShi' + i);
             
             insAssets.add(asset);
         }
         
         insert insAssets;
         
          List<Asset>  assets = [SELECT Id,
                       Name,
                       AccountId,
                       ContactId,
                       SLA__c,
                       Install_Street1__c,
                       Install_Street2__c,
                       Install_City__c,
                       Install_State_Province__c,
                       assetRmaShi__c

                FROM   Asset
                WHERE  Name IN:sAssetNames order by Name];
         
          System.assertEquals(insAssets.size(),              assets.size());
         
          for(Integer i=0;i<assets.size();i++)
          {
              System.assertEquals('TEST-ASSET' + i,                  assets[i].Name, 'Asset Name - TEST-ASSET' + i);
              System.assertEquals(testAccountIds[i],                 assets[i].AccountId,'Asset Name - TEST-ASSET' + i);
              System.assertEquals(testContactIds[i],                 assets[i].ContactId,'Asset Name - TEST-ASSET' + i);
              System.assertEquals('Premium',                     assets[i].SLA__c,'Asset Name - TEST-ASSET' + i);
              System.assertEquals('TEST-ASSET-INSTALL-STREET1',  assets[i].Install_Street1__c,'Asset Name - TEST-ASSET' + i);
              System.assertEquals('TEST-ASSET-INSTALL-STREET2',  assets[i].Install_Street2__c,'Asset Name - TEST-ASSET' + i);
              System.assertEquals('TEST-ASSET-INSTALL-CITY',     assets[i].Install_City__c,'Asset Name - TEST-ASSET' + i);
              System.assertEquals('TEST-ASSET-INSTALL-STATE',    assets[i].Install_State_Province__c,'Asset Name - TEST-ASSET' + i);
              System.assertEquals('AssetTestShi' + i,    assets[i].assetRmaShi__c,'Asset Name - TEST-ASSET' + i);
            testAssetIds.add(assets[i].Id);
          }
         
         
         
     }
      
     //Create Case
     static void createCase()
     {    
         Case  acase;
         List<Case>  insCases = new List<Case>();
         Set<String> sCaseSub = new Set<String>();
         
         for(Integer i=0; i< 1; i++)
         {
             String caseSub = 'TEST-CASE-SUBJECT' + i;
             sCaseSub.add(caseSub);
             aCase = new Case(AccountId = testAccountIds[i],
                       AssetId   = testAssetIds[i],
                       ContactId = testContactIds[i],
                       Subject = caseSub);
             
             insCases.add(aCase);
         }
         
         insert insCases;
         
          List<Case>   cases = [SELECT Id,
                      AccountId,
                      AssetId,
                      ContactId,
                      Subject
               FROM   Case
               WHERE  Subject IN :sCaseSub  order by Subject];
         
          System.assertEquals(insCases.size(),              cases.size());
         
          for(Integer i=0;i<cases.size();i++)
          {
              System.assertEquals(testAccountIds[i],       cases[i].AccountId, 'Case Subject - TEST-CASE-SUBJECT' + i);
              System.assertEquals(testAssetIds[i],         cases[i].AssetId,'Case Subject - TEST-CASE-SUBJECT' + i);
              System.assertEquals(testContactIds[i],       cases[i].ContactId,'Case Subject - TEST-CASE-SUBJECT' + i);
              System.assertEquals('TEST-CASE-SUBJECT' + i, cases[i].Subject,'Case Subject - TEST-CASE-SUBJECT' + i);
              testCaseIds.add(cases[i].Id);
          }
         
          
     }
     
     //Create Depot
     // Note: Inorder to avoid 101 soql exception in future with test data  
     // a) Depot Insertion is made a list and inserted at last.
     // b) Excepted result is moved to a seperate map and results are compared as a bulk.
     // c) After creating a depot - adding a depot to the insertion list and expected value key is must. 
     static void createDepot()
     {

          depot__c depot;
          List<depot__c>  insdepot = new List<depot__c>();
          Map<String,depot__c> mapExpectedDepot= new Map<String,depot__c>();  
         
         // Create test depot 001
          depot = new depot__c(Name                        = 'TEST-001',
                           depotProvider__c            = 'Flash',
                           depotStockedFor4Hour__c     = 'Yes',
                           depotLocationDescription__c = 'Test depot 001',
                           Returns_Carrier__c          = 'DHL');
          insdepot.add(depot);
          mapExpectedDepot.put(depot.Name,depot);
    
          // Create test depot 002
          depot = new depot__c(Name                        = 'TEST-002',
                               depotProvider__c            = 'Flash',
                               depotStockedFor4Hour__c     = 'Yes',
                               depotLocationDescription__c = 'Test depot 002',
                               Returns_Carrier__c          = 'DHL');
         insdepot.add(depot);
         mapExpectedDepot.put(depot.Name,depot);

    
          // Create test depot 003
          depot = new depot__c(Name                        = 'TEST-003',
                               depotProvider__c            = 'Flash',
                               depotStockedFor4Hour__c     = 'Yes',
                               depotLocationDescription__c = 'Test depot 003',
                               Returns_Carrier__c          = 'DHL');
          insdepot.add(depot);
          mapExpectedDepot.put(depot.Name,depot);

    
          // Create test depot 004
          depot = new depot__c(Name                        = 'TEST-004',
                               depotProvider__c            = 'Flash',
                               depotStockedFor4Hour__c     = 'No',
                               depotLocationDescription__c = 'Test depot 004',
                               Returns_Carrier__c          = 'DHL');
          insdepot.add(depot);
          mapExpectedDepot.put(depot.Name,depot);

          // Create test depot 005
          depot = new depot__c(Name                        = 'TEST-005',
                               depotProvider__c            = 'Flash',
                               depotStockedFor4Hour__c     = 'No',
                               depotLocationDescription__c = 'Test depot 005',
                               Returns_Carrier__c          = 'DHL');
          insdepot.add(depot);
          mapExpectedDepot.put(depot.Name,depot);
         
          insert insdepot;
         
         
          List<depot__c>   depots = [SELECT Id,
                       Name,
                       depotProvider__c,
                       depotStockedFor4Hour__c,
                       depotLocationDescription__c
                FROM   depot__c];
         
          System.assertEquals(insdepot.size(),              depots.size());
         
         
          for(Integer i=0;i<depots.size();i++)
          {
               if(mapExpectedDepot.containsKey(depots[i].Name))
                  depot = mapExpectedDepot.get(depots[i].Name);
              
              System.assertEquals(depot.Name , depots[i].Name,'Depot Name - ' + depots[i].Name);
              System.assertEquals(depot.depotProvider__c, depots[i].depotProvider__c,'Depot Name - ' + depots[i].Name);
              System.assertEquals(depot.depotStockedFor4Hour__c, depots[i].depotStockedFor4Hour__c,'Depot Name - ' + depots[i].Name);
              System.assertEquals(depot.depotLocationDescription__c, depots[i].depotLocationDescription__c,'Depot Name - ' + depots[i].Name);
              testDepotIds.add(depots[i].Id);
          }
  
        
     }
      
     // Create the NBD/ND map entries 
     // Note: Inorder to avoid 101 soql exception in future with test data  
     // a) Depot Insertion is made a list and inserted at last.
     // b) Excepted result is moved to a seperate map and results are compared as a bulk.
     // c) After creating a depot - adding a depot to the insertion list and expected value key is must. 
     static void createNBDNDEntries()
     {
       depotMapNbdNd__c depotMapNbdNd;
       List<depotMapNbdNd__c>  insdepotNbdNdMap = new List<depotMapNbdNd__c>();
       Map<String,depotMapNbdNd__c> mapExpectedNbdNdDepot= new Map<String,depotMapNbdNd__c>(); 
      
      //NBD/ND Depot- United States
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United States',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[3],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[4]);
      
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
         
      //NBD/ND Depot- United Kindom
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United Kingdom',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[3],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[4]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
      
      //NBD/ND Depot- United Kindom with State
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United Kingdom',
                                           depotMapNbdNdState__c     = 'Isle of Man',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[3],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[4]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
      
       //NBD/ND Depot- Australia
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Australia',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- Austria
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Austria',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- Belgium
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Belgium',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- Bermuda
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Bermuda',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[1],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[1]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- Canada
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Canada',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[1],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[1]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
      //NBD/ND Depot- China   
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'China',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- Denmark 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Denmark',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
    
      //NBD/ND Depot- Finland 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Finland',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
      //NBD/ND Depot- France 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'France',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
      
      //NBD/ND Depot- Germany 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Germany',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- Hong Kong 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Hong Kong',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
      //NBD/ND Depot- India 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'India',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- Indonesia 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Indonesia',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- Ireland 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Ireland',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
      
       //NBD/ND Depot- Japan 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Japan',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- Malaysia 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Malaysia',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
      insdepotNbdNdMap.add(depotMapNbdNd);
      mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
    
       //NBD/ND Depot- Netherlands 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Netherlands',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[2],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[2]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
       //NBD/ND Depot- New Zealand 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'New Zealand',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
      
      //NBD/ND Depot- Norway 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Norway',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
      
       //NBD/ND Depot- Philippines 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Philippines',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
      //NBD/ND Depot- Singapore 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Singapore',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[2],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[2]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
      
       //NBD/ND Depot- South Africa 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'South Africa',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
      
       //NBD/ND Depot- South Korea 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'South Korea',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
      //NBD/ND Depot- Sweden 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Sweden',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
        
      //NBD/ND Depot- Spain 
       depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Spain',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);

         
      
      //NBD/ND Depot- Switzerland 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Switzerland',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);      
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
     //NBD/ND Depot- Taiwan 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Taiwan',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
     
     //NBD/ND Depot- United Arab Emirates 
      depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United Arab Emirates',
                                           depotMapNbdNdState__c     = 'N/A',
                                           depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                           depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
       insdepotNbdNdMap.add(depotMapNbdNd);       
       mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
         
         
       insert insdepotNbdNdMap;
         
         
       List<depotMapNbdNd__c>  depotMapNbdNds = [SELECT Id,
                               Name,
                               depotMapNbdNdCountry__c,
                               depotMapNbdNdState__c,
                               depotMapNbdNd_NbdDepot__c,
                               depotMapNbdNd_NdDepot__c
                        FROM   depotMapNbdNd__c];
         
          System.assertEquals(insdepotNbdNdMap.size(),    depotMapNbdNds.size());
         
          for(Integer i=0;i<depotMapNbdNds.size();i++)
          {
              string keyFormation = '__' + depotMapNbdNds[i].depotMapNbdNdCountry__c +'__'+depotMapNbdNds[i].depotMapNbdNdState__c+'__';
              if(mapExpectedNbdNdDepot.containsKey(keyFormation))
                  depotMapNbdNd = mapExpectedNbdNdDepot.get(keyFormation);

              System.assertEquals(depotMapNbdNd.depotMapNbdNdCountry__c,          depotMapNbdNds[i].depotMapNbdNdCountry__c,'DepotNbdNd Name' + depotMapNbdNds[i].Name);
              System.assertEquals(depotMapNbdNd.depotMapNbdNdState__c,              depotMapNbdNds[i].depotMapNbdNdState__c,'DepotNbdNd Name' + depotMapNbdNds[i].Name);
              System.assertEquals(depotMapNbdNd.depotMapNbdNd_NbdDepot__c,     depotMapNbdNds[i].depotMapNbdNd_NbdDepot__c,'DepotNbdNd Name' + depotMapNbdNds[i].Name);
              System.assertEquals(depotMapNbdNd.depotMapNbdNd_NdDepot__c,     depotMapNbdNds[i].depotMapNbdNd_NdDepot__c,'DepotNbdNd Name' + depotMapNbdNds[i].Name);
          }
     
         
     }
      
     // Create the 4-Hour map entries 
     // Note: Inorder to avoid 101 soql exception in future with test data  
     // a) Depot Insertion is made a list and inserted at last.
     // b) Excepted result is moved to a seperate map and results are compared as a bulk.
     // c) After creating a depot - adding a depot to the insertion list and expected value key is must. 
     static void create4HourEntries()
     {
       depotMap4Hour__c depotMap4Hour;
       List<depotMap4Hour__c>  insdepotMap4Hour = new List<depotMap4Hour__c>();
       Map<String,depotMap4Hour__c> mapExpected4HourDepot= new Map<String,depotMap4Hour__c>(); 
          
      depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                           depotMap4HourPostalCode__c  = '11111',
                                           depotMap4Hour_4HourDepot__c = testDepotIds[0],
                                           depotMap4HourDriveTime__c   = 10.5);
      insdepotMap4Hour.add(depotMap4Hour);
      mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                        '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                        '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                        depotMap4Hour);


      depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                           depotMap4HourPostalCode__c  = '22222',
                                           depotMap4Hour_4HourDepot__c = testDepotIds[1],
                                           depotMap4HourDriveTime__c   = 20.5);
      insdepotMap4Hour.add(depotMap4Hour);
      mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                        '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                        '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                        depotMap4Hour);

 

      depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                           depotMap4HourPostalCode__c  = '22222',
                                           depotMap4Hour_4HourDepot__c = testDepotIds[2],
                                           depotMap4HourDriveTime__c   = 30.5);
      insdepotMap4Hour.add(depotMap4Hour);
      mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                        '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                        '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                        depotMap4Hour);



      depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United Kingdom',
                                           depotMap4HourPostalCode__c  = 'BS3',
                                           depotMap4Hour_4HourDepot__c = testDepotIds[0],
                                           depotMap4HourDriveTime__c   = 10.5);
      insdepotMap4Hour.add(depotMap4Hour);
      mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                        '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                        '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                        depotMap4Hour);

  
      depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United Kingdom',
                                           depotMap4HourPostalCode__c  = 'BS3A',
                                           depotMap4Hour_4HourDepot__c = testDepotIds[1],
                                           depotMap4HourDriveTime__c   = 20.5);
      insdepotMap4Hour.add(depotMap4Hour);
      mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                        '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                        '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                        depotMap4Hour);
         
      insert insdepotMap4Hour;  
         
      List<depotMap4Hour__c> depotMap4Hours = [SELECT Id,
                               Name,
                               depotMap4HourCountry__c,
                               depotMap4HourPostalCode__c,
                               depotMap4Hour_4HourDepot__c,
                               depotMap4HourDrivetime__c
                        FROM   depotMap4Hour__c];
         
       System.assertEquals(insdepotMap4Hour.size(),    depotMap4Hours.size());

        for(Integer i=0;i<depotMap4Hours.size();i++)
          {
                  depotMap4Hour = mapExpected4HourDepot.get('__' + depotMap4Hours[i].depotMap4HourCountry__c + 
                        '__' + depotMap4Hours[i].depotMap4HourPostalCode__c + 
                        '__' + depotMap4Hours[i].depotMap4Hour_4HourDepot__c + '__');
              
                System.assertEquals(depotMap4Hour.depotMap4HourCountry__c, depotMap4Hours[i].depotMap4HourCountry__c,'Depot4Hour Name' + depotMap4Hours[i].Name);
                System.assertEquals(depotMap4Hour.depotMap4HourPostalCode__c, depotMap4Hours[i].depotMap4HourPostalCode__c,'Depot4Hour Name' + depotMap4Hours[i].Name);
                System.assertEquals(depotMap4Hour.depotMap4Hour_4HourDepot__c, depotMap4Hours[i].depotMap4Hour_4HourDepot__c,'Depot4Hour Name' + depotMap4Hours[i].Name);
                System.assertEquals(depotMap4Hour.depotMap4HourDriveTime__c, depotMap4Hours[i].depotMap4HourDriveTime__c,'Depot4Hour Name' + depotMap4Hours[i].Name);
          }   
         
         

     }
      
    static void CreateRMA()
     {
          RMAv2__c rma;
         List<RMAv2__c> rmas;
         
               rma = new RMAv2__c(rmaCaseNumber__c                 = testCaseIds[0],
                         rmaType__c                       = 'Advance replacement',
                         rmaLabArray__c                   = 'No',
                         rmaComponent__c                  = 'CHASSIS',
                         rmaNimbleOsVersion__c            = 'CHASSIS: N/A',
                         rmaModel__c                      = 'CHASSIS: CS/ES series',
                         rmaPart__c                       = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',
                         rmaQuantity__c                   = '1',
                         rmaReason__c                     = 'CHASSIS: Bad controller slot',
                         rmaManufacturer__c               = 'Super Micro',
                         rmaDetailedReason__c             = 'TEST-RMA-DETAILED-REASON',
                         rmaConfigurationDetails__c       = 'TEST-RMA-CONFIGURATION-DETAILS',
                         rmaShipmentAddressSelector__c    = 'Asset install address',
                         rmaOverrideShipmentPostalCode__c = '11111',
                         rmaOverrideShipmentCountry__c    = 'United States',
                         rmaOverrideShipmentAttn__c       = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',
                         //rmaOverrideShipmentPhone__c      = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',
                         rmaOverrideShipmentEmail__c      = 'test-rma-override-shipment-email@nimblestorage.com',
                         rmaUplift__c                     = 'No: Do not uplift',
                         rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                         rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                         rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                         rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order',
                         rmaOverrideShipmentPhone__c = '9876543210',
                         rmaTransmitRmaShisWithOrder__c   = 'No SHI');
      insert rma;
      rmas = [SELECT Id,
                     rmaCaseNumber__c,
                     rmaType__c,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaReason__c,
                     rmaManufacturer__c,
                     rmaDetailedReason__c,
                     rmaConfigurationDetails__c,
                     rmaShipmentAddressSelector__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOverrideShipmentAttn__c,
                     rmaOverrideShipmentPhone__c,
                     rmaOverrideShipmentEmail__c,
                     rmaUplift__c,
                     rmaOutgoingShipmentStatus__c,
                     rmaReturnShipmentStatus__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                        rmas.size());
      System.assertEquals(testCaseIds[0],                                               rmas[0].rmaCaseNumber__c);
      System.assertEquals('Advance replacement',                                    rmas[0].rmaType__c);
      System.assertEquals('No',                                                     rmas[0].rmaLabArray__c);
      System.assertEquals('CHASSIS' ,                                               rmas[0].rmaComponent__c);
      System.assertEquals('CHASSIS: N/A',                                           rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('CHASSIS: CS/ES series',                                  rmas[0].rmaModel__c);
      System.assertEquals('CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',      rmas[0].rmaPart__c);
      System.assertEquals('1',                                                      rmas[0].rmaQuantity__c);
      System.assertEquals('CHASSIS: Bad controller slot',                           rmas[0].rmaReason__c);
      System.assertEquals('Super Micro',                                            rmas[0].rmaManufacturer__c);
      System.assertEquals('TEST-RMA-DETAILED-REASON',                               rmas[0].rmaDetailedReason__c);
      System.assertEquals('TEST-RMA-CONFIGURATION-DETAILS',                         rmas[0].rmaConfigurationDetails__c);
      System.assertEquals('Asset install address',                                  rmas[0].rmaShipmentAddressSelector__c);
      System.assertEquals('11111',                                                  rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United States',                                          rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('TEST-RMA-OVERRIDE-SHIPMENT-ATTN',                        rmas[0].rmaOverrideShipmentAttn__c);
      //System.assertEquals('TEST-RMA-OVERRIDE-SHIPMENT-PHONE',                       rmas[0].rmaOverrideShipmentPhone__c);
      System.assertEquals('test-rma-override-shipment-email@nimblestorage.com',     rmas[0].rmaOverrideShipmentEmail__c);
      System.assertEquals('No: Do not uplift',                                      rmas[0].rmaUplift__c);
      System.assertEquals('DRAFT-10: Waiting to order',                             rmas[0].rmaOutgoingShipmentStatus__c);
      System.assertEquals('DRAFT-10: Waiting to order',                             rmas[0].rmaReturnShipmentStatus__c);
      testRMAIds.add(rmas[0].id);
     }
      
     
      //Create PostalCode
     // Note: Inorder to avoid 101 soql exception in future with test data  
     // a) Postal Code Insertion is made a list and inserted at last.
     // b) Excepted result is moved to a seperate map and results are compared as a bulk.
     // c) After creating a Postal Code - adding a Postal Code to the insertion list and expected value key is must. 
    static void createPostalCode()
     {
          PostalCode__c pc;
          List<PostalCode__c>  insPc = new List<PostalCode__c>();
          Map<String,PostalCode__c> mapExpectedPc= new Map<String,PostalCode__c>();  
         
         // Create test PostalCode 001
          pc = new PostalCode__c(pcCountry__c  = 'Australia',
                           pcFormatInRegex__c = '^([0-9]{4})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Australia\'s "9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 002
          pc = new PostalCode__c(pcCountry__c  = 'Austria',
                           pcFormatInRegex__c = '^([0-9]{4})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Austria\'s "9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 003
          pc = new PostalCode__c(pcCountry__c  = 'Belgium',
                           pcFormatInRegex__c = '^([0-9]{4})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Belgium\'s "9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 004
          pc = new PostalCode__c(pcCountry__c  = 'Bermuda',
                           pcFormatInRegex__c = '^([A-Z][A-Z]) [0-9][0-9]$',
                           pcDummyPostalCode__c     = 'AA 99',                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Bermuda\'s "AA 99" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 005
          pc = new PostalCode__c(pcCountry__c  = 'Canada',
                           pcFormatInRegex__c = '^([A-Z][0-9][A-Z]) [0-9][A-Z][0-9]$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Canada\'s "A9A 9A9" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 006
          pc = new PostalCode__c(pcCountry__c  = 'China',
                           pcFormatInRegex__c = '^([0-9]{6})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to China\'s "999999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 007
          pc = new PostalCode__c(pcCountry__c  = 'Denmark',
                           pcFormatInRegex__c = '^([0-9]{4})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Denmark\'s "9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 008
          pc = new PostalCode__c(pcCountry__c  = 'Finland',
                           pcFormatInRegex__c = '^([0-9]{5})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Finland\'s "99999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 009
          pc = new PostalCode__c(pcCountry__c  = 'France',
                           pcFormatInRegex__c = '^([0-9]{5})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to France\'s "99999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 010
          pc = new PostalCode__c(pcCountry__c  = 'Germany',
                           pcFormatInRegex__c = '^([0-9]{5})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Germany\'s "99999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 011
          pc = new PostalCode__c(pcCountry__c  = 'Hong Kong',
                           pcFormatInRegex__c = '^([0-9]{6})$',
                           pcDummyPostalCode__c     = '999077',                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Hong Kong\'s "999999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 012
          pc = new PostalCode__c(pcCountry__c  = 'India',
                           pcFormatInRegex__c = '^([0-9]{6})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to India\'s "999999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 013
          pc = new PostalCode__c(pcCountry__c  = 'Indonesia',
                           pcFormatInRegex__c = '^([0-9]{5})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Indonesia\'s "99999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 014
          pc = new PostalCode__c(pcCountry__c  = 'Ireland',
                           pcFormatInRegex__c = '^([A-Z][0-9]{2}) [A-Z][0-9][A-Z]{2}$',
                           pcDummyPostalCode__c     = 'A99 A9AA',                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Ireland\'s "A99 A9AA" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 015
          pc = new PostalCode__c(pcCountry__c  = 'Japan',
                           pcFormatInRegex__c = '^([0-9]{3}-[0-9]{2})[0-9]{2}$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Japan\'s "999-9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 016
          pc = new PostalCode__c(pcCountry__c  = 'Malaysia',
                           pcFormatInRegex__c = '^([0-9]{5})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Malaysia\'s "99999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 017
          pc = new PostalCode__c(pcCountry__c  = 'Netherlands',
                           pcFormatInRegex__c = '^([0-9]{4}) [A-Z]{2}$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Netherlands\' "9999 AA" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 018
          pc = new PostalCode__c(pcCountry__c  = 'New Zealand',
                           pcFormatInRegex__c = '^([0-9]{4})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to New Zealand\'s "9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 019
          pc = new PostalCode__c(pcCountry__c  = 'Norway',
                           pcFormatInRegex__c = '^([0-9]{4})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Norway\'s "9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 020
          pc = new PostalCode__c(pcCountry__c  = 'Philippines',
                           pcFormatInRegex__c = '^([0-9]{4})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Philippines\' "9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 021
          pc = new PostalCode__c(pcCountry__c  = 'Singapore',
                           pcFormatInRegex__c = '^([0-9]{2})[0-9]{4}$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Singapore\'s "999999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 022
          pc = new PostalCode__c(pcCountry__c  = 'South Africa',
                           pcFormatInRegex__c = '^([0-9]{4})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to South Africa\'s "9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 023
          pc = new PostalCode__c(pcCountry__c  = 'South Korea',
                           pcFormatInRegex__c = '^([0-9]{3}-[0-9]{3})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to South Korea\'s "999-999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);

          // Create test PostalCode 024
          pc = new PostalCode__c(pcCountry__c  = 'Spain',
                           pcFormatInRegex__c = '^([0-9]{5})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Spain\'s "99999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 025
          pc = new PostalCode__c(pcCountry__c  = 'Sweden',
                           pcFormatInRegex__c = '^([0-9]{5})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Sweden\'s "99999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 026
          pc = new PostalCode__c(pcCountry__c  = 'Switzerland',
                           pcFormatInRegex__c = '^([0-9]{4})$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Switzerland\'s "9999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 027
          pc = new PostalCode__c(pcCountry__c  = 'Taiwan',
                           pcFormatInRegex__c = '^([0-9]{3})[0-9]{2}$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to Taiwan\'s "99999" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 028
          pc = new PostalCode__c(pcCountry__c  = 'United Arab Emirates',
                           pcFormatInRegex__c = '^([A-Z]{3})$',
                           pcDummyPostalCode__c     = 'AAA',                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to United Arab Emirates\' "AAA" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 029
          pc = new PostalCode__c(pcCountry__c  = 'United States',
                           pcFormatInRegex__c = '^([0-9]{5})(-[0-9]{4})?$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to United States\' "99999(-9999)" format.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 030
          pc = new PostalCode__c(pcCountry__c  = 'United Kingdom',
                           pcFormatInRegex__c = '^([A-Z]{1,2}[0-9]{1,2}) [0-9][A-Z]{2}$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to one of United Kingdom\'s six formats.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
          // Create test PostalCode 031
          pc = new PostalCode__c(pcCountry__c  = 'United Kingdom',
                           pcFormatInRegex__c = '^([A-Z]{1,2}[0-9][A-Z]) [0-9][A-Z]{2}$',
                           pcDummyPostalCode__c     = null,                           
                           pcErrorMessage__c='"Shipment Postal Code" will not conform to one of United Kingdom\'s six formats.  Override it if needed to provide a valid value.');
          insPc.add(pc);
          mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
         
         
         insert insPC;
         
         /*List<PostalCode__c>   pcs = [SELECT Id,
                                    pcCountry__c,
                                    pcFormatInRegex__c,
                                    pcDummyPostalCode__c 
                                    FROM   PostalCode__c];
         
          System.assertEquals(insPc.size(),              pcs.size());*/
         
         
          for(Integer i=0;i<insPC.size();i++)
          {
              pc = mapExpectedPc.get(insPC[i].pcCountry__c + '__' + insPC[i].pcFormatInRegex__c);
              
              System.assertEquals(pc.pcCountry__c , insPC[i].pcCountry__c,'Country Name - ' + insPC[i].pcCountry__c);
              System.assertEquals(pc.pcFormatInRegex__c, insPC[i].pcFormatInRegex__c,'Country Name - ' + insPC[i].pcCountry__c);
              System.assertEquals(pc.pcDummyPostalCode__c, insPC[i].pcDummyPostalCode__c,'Country Name - ' + insPC[i].pcCountry__c);
          }
  
        
     }
      
        // ==================================================================================== test4Hour_2DepotsStocked
        // Moved to rmaTriggerUpliftnLogisticsTest test class.
   /*static testMethod void test4Hour_2DepotsStocked()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      
      createTestData();
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
		
      rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
      rmas[0].rmaOverrideShipmentPostalCode__c = '22222-2222';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
      
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
      System.assertEquals('22222-2222',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
      //System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      //System.assertEquals('TEST-002',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/
      
    //  ==================================================================================== test4Hour_1DepotsStocked
    //  Moved to rmaTriggerUpliftnLogisticsTest test class.
   /*static testMethod void test4Hour_1DepotsStocked()
       {List<RMAv2__c> rmas;
      ID testRmaId;

    
      createTestData();
 

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
      rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
      System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
      //System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      //System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/
         // ==================================================================================== test4Hour_0DepotsStocked
         // Moved to rmaTriggerUpliftnLogisticsTest test class.
   /*static testMethod void test4Hour_0DepotsStocked()
       {List<RMAv2__c> rmas;
      ID testRmaId;

  
      createTestData();
       

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
      rmas[0].rmaOverrideShipmentPostalCode__c = '00000-0000';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
      System.assertEquals('00000-0000',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
      //System.assertEquals('Nimble',                 rmas[0].rmaOutgoingShipmentOrderProvider__c);
      //System.assertEquals('TEST-005',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== test4HourUnknown
   // Moved to rmaTriggerUpliftnLogisticsTest test class.
   /*static testMethod void test4HourUnknown()
       {List<RMAv2__c> rmas;
      ID testRmaId;

      
      createTestData();
     

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
      rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Unknownistan';
      update rmas[0];
	  
      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
      System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Unknownistan',           rmas[0].rmaOverrideShipmentCountry__c);
      //System.assertEquals('Unknown',                rmas[0].rmaOutgoingShipmentOrderProvider__c);
      //System.assertEquals('Unknown',                rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testNbdUnknown
   // Moved to rmaTriggerUpliftnLogisticsTest test class.
   /*static testMethod void testNbdUnknown()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      
      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Unknownistan';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Unknownistan',           rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Unknown',                rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('Unknown',                rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testNd
   // Moved to rmaTriggerUpliftnLogisticsTest test class.
   /*static testMethod void testNd()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      
      createTestData();
   

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'Yes: Uplift to Next Day';
      rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                          rmas.size());
      System.assertEquals('Yes: Uplift to Next Day',  rmas[0].rmaUplift__c);
      System.assertEquals('11111-1111',               rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United States (US)',       rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Nimble',                   rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-005',                 rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testNbd
   // Moved to rmaTriggerUpliftnLogisticsTest test class.
   /*static testMethod void testNbd()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
    

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Nimble',                 rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-004',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testSystemPartReturn
   // Moved to rmaTriggerUpliftnLogisticsTest test class.
   /*static testMethod void testSystemPartReturn()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();


      rmas = [SELECT Id,
                     rmaType__c,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaType__c                       = 'System/part return';
      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaType__c,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('System/part return',     rmas[0].rmaType__c);
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('11111-1111',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United States (US)',     rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Nimble',                 rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('SRV-NIMBLE',             rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBlankCountry
   static testMethod void testBlankCountry()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '11111-1111';
      rmas[0].rmaOverrideShipmentCountry__c    = null;

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('Based on your address selections, the "Shipment Country" will be blank.  This field cannot be blank.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testBlankPostalCode
   static testMethod void testBlankPostalCode()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;
      createTestData();
      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = null;
      rmas[0].rmaOverrideShipmentCountry__c    = 'United States (US)';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('Based on your address selections, the "Shipment Postal Code" will be blank.  This field cannot be blank.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeAustralia
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeAustralia()
     {List<RMAv2__c> rmas;
      ID testRmaId;

     
      createTestData();
    

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Australia';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('1234',                   rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Australia',              rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeAustralia
   static testMethod void testBadPostalCodeAustralia()
      {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z3';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Australia';
	
      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Australia\'s "9999" format.  Override it if needed to provide a valid value.'));
      
     }

   // ==================================================================================== testGoodPostalCodeAustria
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeAustria()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Austria';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Austria',           rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeAustria
   static testMethod void testBadPostalCodeAustria()
      {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z3';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Austria';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Austria\'s "9999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeBelgium
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeBelgium()
     {List<RMAv2__c> rmas;
      ID testRmaId;

   
      createTestData();
     

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Belgium';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Belgium',           rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeBelgium
   static testMethod void testBadPostalCodeBelgium()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z3';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Belgium';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Belgium\'s "9999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeBermuda
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeBermuda()
     {List<RMAv2__c> rmas;
      ID testRmaId;

     
      createTestData();
    

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = 'zy 35';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Bermuda';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('zy 35',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Bermuda',           rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-002',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeBermuda
   //   NOTE: This test is commented out because the rmaTrigger will always set a valid
   //         format postal code for Bermuda.  See Bermuda notes in the rmaTrigger
   //         for more info.
//   static testMethod void testBadPostalCodeBermuda()
//     {List<RMAv2__c> rmas;
//      ID testRmaId;
//      Exception dmlException;

//      createTestData();

//      rmas = [SELECT Id,
//                     rmaUplift__c,
//                     rmaOverrideShipmentPostalCode__c,
//                     rmaOverrideShipmentCountry__c
//              FROM   RMAv2__c];

//      System.assertEquals(1, rmas.size());

//      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
//      rmas[0].rmaOverrideShipmentPostalCode__c = 'aa 99z';
//      rmas[0].rmaOverrideShipmentCountry__c    = 'Bermuda';

//      try
//        {update rmas[0];
//        }
//      catch(Exception ex)
//        {dmlException = ex;
//        }

//      System.assertNotEquals(null, dmlException);
//      System.assert(dmlException instanceOf system.Dmlexception);
//      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Bermuda\'s "AA 99" format.  Override it if needed to provide a valid value.'));
//     }

   // ==================================================================================== testGoodPostalCodeCanada
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeCanada()
     {List<RMAv2__c> rmas;
      ID testRmaId;

     
      createTestData();
  

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = 'z8y 3g5';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Canada';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('z8y 3g5',                rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Canada',                 rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-002',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeCanada
   static testMethod void testBadPostalCodeCanada()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = 'a9a 9z9z';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Canada';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Canada\'s "A9A 9A9" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeChina
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeChina()
     {List<RMAv2__c> rmas;
      ID testRmaId;

    
      createTestData();
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '123456';
      rmas[0].rmaOverrideShipmentCountry__c    = 'China';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('123456',                 rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('China',                  rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeChina
   static testMethod void testBadPostalCodeChina()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z345';
      rmas[0].rmaOverrideShipmentCountry__c    = 'China';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to China\'s "999999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeDenmark
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeDenmark()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Denmark';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Denmark',           rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeDenmark
   static testMethod void testBadPostalCodeDenmark()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z3';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Denmark';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Denmark\'s "9999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeFinland
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeFinland()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Finland';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('12345',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Finland',           rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeFinland
   static testMethod void testBadPostalCodeFinland()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z34';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Finland';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Finland\'s "99999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeFrance
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeFrance()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
      rmas[0].rmaOverrideShipmentCountry__c    = 'France';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('12345',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('France',            rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeFrance
   static testMethod void testBadPostalCodeFrance()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z34';
      rmas[0].rmaOverrideShipmentCountry__c    = 'France';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to France\'s "99999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeGermany
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeGermany()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Germany';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('12345',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Germany',           rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeGermany
   static testMethod void testBadPostalCodeGermany()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z34';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Germany';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Germany\'s "99999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeHongKong
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeHongKong()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '123456';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Hong Kong';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('123456',            rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Hong Kong',         rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeHongKong
   //   NOTE: This test is commented out because the rmaTrigger will always set a valid
   //         format postal code for Hong Kong.  See Hong Kong notes in the rmaTrigger
   //         for more info.
//   static testMethod void testBadPostalCodeHongKong()
//     {List<RMAv2__c> rmas;
//      ID testRmaId;
//      Exception dmlException;

//      createTestData();

//      rmas = [SELECT Id,
//                     rmaUplift__c,
//                     rmaOverrideShipmentPostalCode__c,
//                     rmaOverrideShipmentCountry__c
//              FROM   RMAv2__c];

//      System.assertEquals(1, rmas.size());

//      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
//      rmas[0].rmaOverrideShipmentPostalCode__c = '123456a';
//      rmas[0].rmaOverrideShipmentCountry__c    = 'Hong Kong';

//      try
//        {update rmas[0];
//        }
//      catch(Exception ex)
//        {dmlException = ex;
//        }

//      System.assertNotEquals(null, dmlException);
//      System.assert(dmlException instanceOf system.Dmlexception);
//      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Hong Kong\'s "999999" format.  Override it if needed to provide a valid value.'));
//     }

   // ==================================================================================== testGoodPostalCodeIndia
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeIndia()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();
  

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '123456';
      rmas[0].rmaOverrideShipmentCountry__c    = 'India';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('123456',                 rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('India',                  rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeIndia
   static testMethod void testBadPostalCodeIndia()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z345';
      rmas[0].rmaOverrideShipmentCountry__c    = 'India';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to India\'s "999999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeIndonesia
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeIndonesia()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Indonesia';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('12345',                  rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Indonesia',              rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeIndonesia
   static testMethod void testBadPostalCodeIndonesia()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z34';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Indonesia';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Indonesia\'s "99999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeIreland
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeIreland()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      
      createTestData();
    

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = 'a89 z5cd';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Ireland';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('a89 z5cd',               rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Ireland',                rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeIreland
   //   NOTE: This test is commented out because the rmaTrigger will always set a valid
   //         format postal code for Ireland.  See Ireland notes in the rmaTrigger
   //         for more info.
//   static testMethod void testBadPostalCodeIreland()
//     {List<RMAv2__c> rmas;
//      ID testRmaId;
//      Exception dmlException;

//      createTestData();

//      rmas = [SELECT Id,
//                     rmaUplift__c,
//                     rmaOverrideShipmentPostalCode__c,
//                     rmaOverrideShipmentCountry__c
//              FROM   RMAv2__c];

//      System.assertEquals(1, rmas.size());

//      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
//      rmas[0].rmaOverrideShipmentPostalCode__c = 'a99 z9z5';
//      rmas[0].rmaOverrideShipmentCountry__c    = 'Ireland';

//      try
//        {update rmas[0];
//        }
//      catch(Exception ex)
//        {dmlException = ex;
//        }

//      System.assertNotEquals(null, dmlException);
//      System.assert(dmlException instanceOf system.Dmlexception);
//      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Ireland\'s "A99 A9AA" format.  Override it if needed to provide a valid value.'));
//     }

   // ==================================================================================== testGoodPostalCodeJapan
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeJapan()
     {List<RMAv2__c> rmas;
      ID testRmaId;

  
      createTestData();
    

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '123-4567';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Japan';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('123-4567',          rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Japan',             rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeJapan
   static testMethod void testBadPostalCodeJapan()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12-34567';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Japan';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Japan\'s "999-9999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeMalaysia
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeMalaysia()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Malaysia';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('12345',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Malaysia',          rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeMalaysia
   static testMethod void testBadPostalCodeMalaysia()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z34';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Malaysia';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Malaysia\'s "99999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeNetherlands
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeNetherlands()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      

      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '9876 gg';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Netherlands';
      update rmas[0];
       

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('9876 gg',                rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Netherlands',            rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-003',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
     }*/

   // ==================================================================================== testBadPostalCodeNetherlands
   static testMethod void testBadPostalCodeNetherlands()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234 zzz';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Netherlands';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Netherlands\' "9999 AA" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeNewZealand
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeNewZealand()
     {List<RMAv2__c> rmas;
      ID testRmaId;


      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
      rmas[0].rmaOverrideShipmentCountry__c    = 'New Zealand';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('New Zealand',       rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
      
     }*/

   // ==================================================================================== testBadPostalCodeNewZealand
   static testMethod void testBadPostalCodeNewZealand()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z3';
      rmas[0].rmaOverrideShipmentCountry__c    = 'New Zealand';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to New Zealand\'s "9999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeNorway
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeNorway()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Norway';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Norway',            rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeNorway
   static testMethod void testBadPostalCodeNorway()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z3';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Norway';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Norway\'s "9999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodePhilippines
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodePhilippines()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
 

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Philippines';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Philippines',       rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodePhilippines
   static testMethod void testBadPostalCodePhilippines()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z3';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Philippines';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Philippines\' "9999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeSingapore
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeSingapore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '559999';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Singapore';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('559999',            rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Singapore',         rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-003',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeSingapore
   static testMethod void testBadPostalCodeSingapore()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '5x9999';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Singapore';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Singapore\'s "999999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeSouthAfrica
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeSouthAfrica()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
      rmas[0].rmaOverrideShipmentCountry__c    = 'South Africa';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('South Africa',      rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeSouthAfrica
   static testMethod void testBadPostalCodeSouthAfrica()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z3';
      rmas[0].rmaOverrideShipmentCountry__c    = 'South Africa';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to South Africa\'s "9999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeSouthKorea
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeSouthKorea()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '123-456';
      rmas[0].rmaOverrideShipmentCountry__c    = 'South Korea';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('123-456',                rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('South Korea',            rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeSouthKorea
   static testMethod void testBadPostalCodeSouthKorea()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '123-4z6';
      rmas[0].rmaOverrideShipmentCountry__c    = 'South Korea';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to South Korea\'s "999-999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeSpain
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeSpain()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
     

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Spain';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('12345',                  rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Spain',                  rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeSpain
   static testMethod void testBadPostalCodeSpain()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z45';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Spain';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Spain\'s "99999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeSweden
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeSweden()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
     

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Sweden';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
      System.assertEquals('12345',                  rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Sweden',                 rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeSweden
   static testMethod void testBadPostalCodeSweden()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z45';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Sweden';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Sweden\'s "99999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeSwitzerland
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeSwitzerland()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Switzerland';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Switzerland',       rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeSwitzerland
   static testMethod void testBadPostalCodeSwitzerland()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12z3';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Switzerland';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Switzerland\'s "9999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeTaiwan
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeTaiwan()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
   

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '55599';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Taiwan';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                   rmas.size());
      System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
      System.assertEquals('55599',             rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('Taiwan',            rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeTaiwan
   static testMethod void testBadPostalCodeTaiwan()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '5x599';
      rmas[0].rmaOverrideShipmentCountry__c    = 'Taiwan';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to Taiwan\'s "99999" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testGoodPostalCodeUnitedArabEmirates
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeUnitedArabEmirates()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
    

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = 'abc';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United Arab Emirates';
      update rmas[0];

      
      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                      rmas.size());
      System.assertEquals('No: Do not uplift',    rmas[0].rmaUplift__c);
      System.assertEquals('abc',                  rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United Arab Emirates', rmas[0].rmaOverrideShipmentCountry__c);
      System.assertEquals('Flash',                rmas[0].rmaOutgoingShipmentOrderProvider__c);
      System.assertEquals('TEST-001',             rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeUnitedArabEmirates
   //   NOTE: This test is commented out because the rmaTrigger will always set a valid
   //         format postal code for United Arab Emirates.
//   static testMethod void testBadPostalCodeUnitedArabEmirates()
//     {List<RMAv2__c> rmas;
//      ID testRmaId;
//      Exception dmlException;

//      createTestData();

//      rmas = [SELECT Id,
//                     rmaUplift__c,
//                     rmaOverrideShipmentPostalCode__c,
//                     rmaOverrideShipmentCountry__c
//              FROM   RMAv2__c];

//      System.assertEquals(1, rmas.size());

//      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
//      rmas[0].rmaOverrideShipmentPostalCode__c = 'a12';
//      rmas[0].rmaOverrideShipmentCountry__c    = 'United Arab Emirates';

//      try
//        {update rmas[0];
//        }
//      catch(Exception ex)
//        {dmlException = ex;
//        }

//      System.assertNotEquals(null, dmlException);
//      System.assert(dmlException instanceOf system.Dmlexception);
//      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
//      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to United Arab Emirates\' "AAA" format.  Override it if needed to provide a valid value.'));
//     }

   // ==================================================================================== testGoodPostalCodeUnitedKingdom1
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeUnitedKingdom1()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
     

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
      rmas[0].rmaOverrideShipmentPostalCode__c = 'BS3 9ZZ';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United Kingdom';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
      System.assertEquals('BS3 9ZZ',                rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United Kingdom',         rmas[0].rmaOverrideShipmentCountry__c);
      //System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      //System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testGoodPostalCodeUnitedKingdom2
   // Moved to rmaTriggerGoodPostalCodeTests test class.
   /*static testMethod void testGoodPostalCodeUnitedKingdom2()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();


      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
      rmas[0].rmaOverrideShipmentPostalCode__c = 'BS3A 9ZZ';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United Kingdom';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c,
                     rmaOutgoingShipmentOrderProvider__c,
                     rmaOutgoingShipmentOrderDepot__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
      System.assertEquals('BS3A 9ZZ',               rmas[0].rmaOverrideShipmentPostalCode__c);
      System.assertEquals('United Kingdom',         rmas[0].rmaOverrideShipmentCountry__c);
      //System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
      //System.assertEquals('TEST-002',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     }*/

   // ==================================================================================== testBadPostalCodeUnitedKingdom
   static testMethod void testBadPostalCodeUnitedKingdom()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = 'AA99A 9AA';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United Kingdom';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to one of United Kingdom\'s six formats.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testBadPostalCodeUnitedStates
   static testMethod void testBadPostalCodeUnitedStates()
     {List<RMAv2__c> rmas;
      ID testRmaId;
      Exception dmlException;

      createTestData();

      rmas = [SELECT Id,
                     rmaUplift__c,
                     rmaOverrideShipmentPostalCode__c,
                     rmaOverrideShipmentCountry__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaUplift__c                     = 'No: Do not uplift';
      rmas[0].rmaOverrideShipmentPostalCode__c = '12345-999z';
      rmas[0].rmaOverrideShipmentCountry__c    = 'United States';

      try
        {update rmas[0];
        }
      catch(Exception ex)
        {dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('"Shipment Postal Code" will not conform to United States\' "99999(-9999)" format.  Override it if needed to provide a valid value.'));
     }

   // ==================================================================================== testHdd210Before
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testHdd210Before()
     {List<RMAv2__c> rmas;
      ID testRmaId;

  
      createTestData();
 

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'HDD';
      rmas[0].rmaNimbleOsVersion__c            = 'HDD: N/A';
      rmas[0].rmaModel__c                      = 'HDD: CS210/220/420';
      rmas[0].rmaPart__c                       = 'HDD: 1TB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'HDD: Seagate';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('HDD: CS210/220/420',                            rmas[0].rmaModel__c);
      System.assertEquals('1TB SATA HDD [SR-HDD-1TB]',                     rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
      
     }*/

   // ==================================================================================== testHdd240Before
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testHdd240Before()
     {List<RMAv2__c> rmas;
      ID testRmaId;

    
      createTestData();
      

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());

      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'HDD';
      rmas[0].rmaNimbleOsVersion__c            = 'HDD: N/A';
      rmas[0].rmaModel__c                      = 'HDD: CS240/440';
      rmas[0].rmaPart__c                       = 'HDD: 2TB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'HDD: Seagate';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)';
      update rmas[0];

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('HDD: CS240/440',                                rmas[0].rmaModel__c);
      System.assertEquals('2TB SATA HDD [SR-HDD-2TB]',                     rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
      
     }*/

   // ==================================================================================== testHdd260Before
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testHdd260Before()
     {List<RMAv2__c> rmas;
      ID testRmaId;

   
      createTestData();
    

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'HDD';
      rmas[0].rmaNimbleOsVersion__c            = 'HDD: N/A';
      rmas[0].rmaModel__c                      = 'HDD: CS260/460';
      rmas[0].rmaPart__c                       = 'HDD: 3TB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'HDD: Seagate';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)';
      update rmas[0];
	  //Test.stopTest();
      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('HDD: CS260/460',                                rmas[0].rmaModel__c);
      System.assertEquals('3TB SAS HDD [SR-HDD-3TB]',                      rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
      
     }*/

   // ==================================================================================== testHdd12TBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testHdd12TBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

     
      createTestData();
      

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'HDD';
      rmas[0].rmaNimbleOsVersion__c            = 'HDD: N/A';
      rmas[0].rmaModel__c                      = 'HDD: CS215/300/500/700, 12T';
      rmas[0].rmaPart__c                       = 'HDD: 1TB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'HDD: Seagate';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('HDD: CS215/300/500/700, 12T',                   rmas[0].rmaModel__c);
      System.assertEquals('1TB SAS HDD [SR-HDD-1TB-SAS]',                  rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
      
     }*/

   // ==================================================================================== testHdd24TBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testHdd24TBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

 
      createTestData();
   

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
      //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'HDD';
      rmas[0].rmaNimbleOsVersion__c            = 'HDD: N/A';
      rmas[0].rmaModel__c                      = 'HDD: CS215/300/500/700, 24T';
      rmas[0].rmaPart__c                       = 'HDD: 2TB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'HDD: Seagate';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)';
      update rmas[0];
	  //Test.stopTest();
      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('HDD: CS215/300/500/700, 24T',                   rmas[0].rmaModel__c);
      System.assertEquals('2TB SAS HDD [SR-HDD-2TB-SAS]',                  rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
      
     }*/

   // ==================================================================================== testHdd36TBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testHdd36TBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

    
      createTestData();
      

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'HDD';
      rmas[0].rmaNimbleOsVersion__c            = 'HDD: N/A';
      rmas[0].rmaModel__c                      = 'HDD: CS215/300/500/700, 36T';
      rmas[0].rmaPart__c                       = 'HDD: 3TB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'HDD: Seagate';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)';
      update rmas[0];
	  //Test.stopTest();
      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('HDD: CS215/300/500/700, 36T',                   rmas[0].rmaModel__c);
      System.assertEquals('3TB SAS HDD [SR-HDD-3TB-SAS]',                  rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
      
     }*/

   // ==================================================================================== testHdd48TBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testHdd48TBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

    
      createTestData();
   

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'HDD';
      rmas[0].rmaNimbleOsVersion__c            = 'HDD: N/A';
      rmas[0].rmaModel__c                      = 'HDD: CS215/300/500/700, 48T';
      rmas[0].rmaPart__c                       = 'HDD: 4TB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'HDD: Seagate';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)';
      update rmas[0];
	  //Test.stopTest();
      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('HDD: CS215/300/500/700, 48T',                   rmas[0].rmaModel__c);
      System.assertEquals('4TB SAS HDD [SR-HDD-4TB-SAS]',                  rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
      
     }*/

   // ==================================================================================== testHdd72TBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testHdd72TBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      
      createTestData();
   

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'HDD';
      rmas[0].rmaNimbleOsVersion__c            = 'HDD: N/A';
      rmas[0].rmaModel__c                      = 'HDD: CS215/300/500/700, 72T';
      rmas[0].rmaPart__c                       = 'HDD: 6TB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'HDD: Seagate';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)';
      update rmas[0];
	  //Test.stopTest();
      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('HDD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('HDD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('HDD: CS215/300/500/700, 72T',                   rmas[0].rmaModel__c);
      System.assertEquals('6TB SAS HDD [SR-HDD-6TB-SAS]',                  rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('HDD: Seagate',                                  rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('HDD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
      
     }*/

   // ==================================================================================== testSsd210X2Before
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd210X2Before()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
  

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS210/210-X2/220/420';
      rmas[0].rmaPart__c                       = 'SSD: 80GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS210/210-X2/220/420',                     rmas[0].rmaModel__c);
      System.assertEquals('80GB SATA SSD [SR-SSD-80GB]',                   rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                    rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd210X4Before
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd210X4Before()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
   

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS210-X4/220-X2/240/420-X2/440';
      rmas[0].rmaPart__c                       = 'SSD: 160GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS210-X4/220-X2/240/420-X2/440',           rmas[0].rmaModel__c);
      System.assertEquals('160GB SATA SSD [SR-SSD-160GB]',                 rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                    rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd220X4Before
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd220X4Before()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
      

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS220-X4/240-X2/260/420-X4/440-X2/460';
      rmas[0].rmaPart__c                       = 'SSD: 300GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

     rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                               rmas.size());
      System.assertEquals('No',                                            rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                           rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                      rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS220-X4/240-X2/260/420-X4/440-X2/460',    rmas[0].rmaModel__c);
      System.assertEquals('300GB SATA SSD [SR-SSD-300GB]',                 rmas[0].rmaPart__c);
      System.assertEquals('1',                                             rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                    rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                        rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)', rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd220X8Before
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd220X8Before()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
     

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS220-X8/240-X4/260-X2/420-X8/440-X4/460-X2';
      rmas[0].rmaPart__c                       = 'SSD: 600GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                  rmas.size());
      System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS220-X8/240-X4/260-X2/420-X8/440-X4/460-X2', rmas[0].rmaModel__c);
      System.assertEquals('600GB SATA SSD [SR-SSD-600GB]',                    rmas[0].rmaPart__c);
      System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd320FBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd320FBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
    

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS215/300/500/700, 320F';
      rmas[0].rmaPart__c                       = 'SSD: 80GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                  rmas.size());
      System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS215/300/500/700, 320F',                     rmas[0].rmaModel__c);
      System.assertEquals('80GB SATA SSD [SR-SSD-3500-80GB]',                 rmas[0].rmaPart__c);
      System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd640FBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd640FBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
     

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
      //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS215/300/500/700, 640F';
      rmas[0].rmaPart__c                       = 'SSD: 160GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                  rmas.size());
      System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS215/300/500/700, 640F',                     rmas[0].rmaModel__c);
      System.assertEquals('160GB SATA SSD [SR-SSD-3500-160GB]',               rmas[0].rmaPart__c);
      System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd1200FBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd1200FBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      
      createTestData();
      

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
      //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS215/300/500/700, 1200F';
      rmas[0].rmaPart__c                       = 'SSD: 300GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                  rmas.size());
      System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS215/300/500/700, 1200F',                    rmas[0].rmaModel__c);
      System.assertEquals('300GB SATA SSD [SR-SSD-3500-300GB]',               rmas[0].rmaPart__c);
      System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
      
     }*/

   // ==================================================================================== testSsd2400FBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd2400FBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
     

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS215/300/500/700, 2400F';
      rmas[0].rmaPart__c                       = 'SSD: 600GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                  rmas.size());
      System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS215/300/500/700, 2400F',                    rmas[0].rmaModel__c);
      System.assertEquals('600GB SATA SSD [SR-SSD-3500-600GB]',               rmas[0].rmaPart__c);
      System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd3200FBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd3200FBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
    

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS215/300/500/700, 3200F';
      rmas[0].rmaPart__c                       = 'SSD: 800GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                  rmas.size());
      System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS215/300/500/700, 3200F',                    rmas[0].rmaModel__c);
      System.assertEquals('800GB SATA SSD [SR-SSD-3500-800GB]',               rmas[0].rmaPart__c);
      System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd6400FBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd6400FBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
      

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS215/300/500/700, 6400F';
      rmas[0].rmaPart__c                       = 'SSD: 1600GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                  rmas.size());
      System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS215/300/500/700, 6400F',                    rmas[0].rmaModel__c);
      System.assertEquals('1600GB SATA SSD [SR-SSD-1600GB]',                  rmas[0].rmaPart__c);
      System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd3200FsBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd3200FsBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
      

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS215/300/500/700, 3200FS';
      rmas[0].rmaPart__c                       = 'SSD: 800GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                  rmas.size());
      System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS215/300/500/700, 3200FS',                   rmas[0].rmaModel__c);
      System.assertEquals('800GB SAS SSD [SR-SSD-800GB-SAS]',                 rmas[0].rmaPart__c);
      System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
     }*/

   // ==================================================================================== testSsd6400FsBefore
   // Commented By vishnu on 27th April 2020 and added in "rmaTriggerAssignHddAndSsdPartNumbers" Test class.
   /*static testMethod void testSsd6400FsBefore()
     {List<RMAv2__c> rmas;
      ID testRmaId;

      createTestData();
      

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1, rmas.size());
	  //Test.startTest();
      rmas[0].rmaLabArray__c                   = 'No';
      rmas[0].rmaComponent__c                  = 'SSD';
      rmas[0].rmaNimbleOsVersion__c            = 'SSD: N/A';
      rmas[0].rmaModel__c                      = 'SSD: CS215/300/500/700, 6400FS';
      rmas[0].rmaPart__c                       = 'SSD: 1600GB - save RMA to compute exact part';
      rmas[0].rmaQuantity__c                   = '1';
      rmas[0].rmaManufacturer__c               = 'SSD: Intel';
      rmas[0].rmaHddSsdSerialNumber__c         = 'ABC123';
      rmas[0].rmaReason__c                     = 'SSD: Starting to fail (proactive replacement)';
      update rmas[0];
      //Test.stopTest();

      rmas = [SELECT Id,
                     rmaLabArray__c,
                     rmaComponent__c,
                     rmaNimbleOsVersion__c,
                     rmaModel__c,
                     rmaPart__c,
                     rmaQuantity__c,
                     rmaManufacturer__c,
                     rmaHddSsdSerialNumber__c,
                     rmaReason__c
              FROM   RMAv2__c];

      System.assertEquals(1,                                                  rmas.size());
      System.assertEquals('No',                                               rmas[0].rmaLabArray__c);
      System.assertEquals('SSD',                                              rmas[0].rmaComponent__c);
      System.assertEquals('SSD: N/A',                                         rmas[0].rmaNimbleOsVersion__c);
      System.assertEquals('SSD: CS215/300/500/700, 6400FS',                   rmas[0].rmaModel__c);
      System.assertEquals('1600GB SAS SSD [SR-SSD-1600GB-SAS]',               rmas[0].rmaPart__c);
      System.assertEquals('1',                                                rmas[0].rmaQuantity__c);
      System.assertEquals('SSD: Intel',                                       rmas[0].rmaManufacturer__c);
      System.assertEquals('ABC123',                                           rmas[0].rmaHddSsdSerialNumber__c);
      System.assertEquals('SSD: Starting to fail (proactive replacement)',    rmas[0].rmaReason__c);
      }*/
     
      // ==================================================================================== testRMAStatusOpen
      // Added by Exafort(vishnu) to avoid 101 SOQL Issues.
     @isTest(SeeAllData=true)
      static void testRMAStatusOpen()
      {
          Account account;
          Contact contact;
          Asset   asset;
          Case aCase;
          RMAv2__c rma;
          AddressBook__c addressBook;
          Component__c testComponent1;
          
          // Create test account
          account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
          System.assertNotEquals(null,              account.Id);
          System.assertEquals('Test Support Tools QA', account.Name);
          
          // Create test contact
          contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
          System.assertNotEquals(null,contact.Id);
          System.assertEquals(account.Id,contact.AccountId);
          System.assertEquals('Vishnu Test', contact.LastName);
          
          // Create test asset
          asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id order by createddate ASC LIMIT 1];
          System.assertNotEquals(null,                      asset.Id);
          System.assertEquals('AA-000000',                  asset.Name);
          System.assertEquals(account.Id,                 asset.AccountId);
          
          //Create test case
          aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1];
          System.assertNotEquals(null,             aCase.Id);
          System.assertEquals(account.Id,       aCase.AccountId);
          System.assertEquals(asset.Id,         aCase.AssetId);
       
          
          //Create test Address Book
          addressBook=[Select Id,Name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
                       abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id ORDER BY Name LIMIT 1];
          System.assertNotEquals(null,             addressBook.Id);
          System.assertEquals(account.Id,       addressBook.abAccount__c);
          
          //Create test Component
          testComponent1 =[Select Id,Name,
                           Sub_State__c,
                           componentState__c,
                           componentAsset__c,
                           componentAccountId__c,
                           componentComponentSN__c,
                           componentServicePartNumber__c,
                           componentType__c, componentDescription__c
                           From component__c where componentServicePartNumber__c ='SR-HDD-2TB' AND componentAsset__c=:asset.Id LIMIT 1];
          
          //Create test RMA
          rma = [Select Id,Name,
                 rmaCaseNumber__c,
                 rmaDiskShelfAsset__c,
                 rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                 Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                 rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                 rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                 rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                 From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];  
          
          System.assertNotEquals(null,rma.Id);
          System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
          System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
          System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
          System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
          System.assertEquals('Component',rma.rmaSelection__c);           
          Test.startTest();
          //rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
          //rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
         // rma.rmaGateKeeperStatus__c = 'Automatic';
          //update rma;
          Test.stopTest();
     }
      
     //==================================================================================== testRMAStatusClosed
     @isTest(SeeAllData=true)
     static void testRMAStatusClosed()
     {
         Account account;
         Contact contact;
         Asset   asset;
         Case aCase;
         RMAv2__c rma;
         AddressBook__c addressBook;
         Component__c testComponent1;
         
         // Create test account
         account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
         System.assertNotEquals(null,              account.Id);
         System.assertEquals('Test Support Tools QA', account.Name);
         
         // Create test contact
         contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
         System.assertNotEquals(null,contact.Id);
         System.assertEquals(account.Id,contact.AccountId);
         System.assertEquals('Vishnu Test', contact.LastName);
         
         // Create test asset
         asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id order by createddate ASC LIMIT 1];
         System.assertNotEquals(null,                      asset.Id);
         System.assertEquals('AA-000000',                  asset.Name);
         System.assertEquals(account.Id,                 asset.AccountId);
          
         //Create test case
         aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1];
         System.assertNotEquals(null,             aCase.Id);
         System.assertEquals(account.Id,       aCase.AccountId);
         System.assertEquals(asset.Id,         aCase.AssetId);
         
         
         //Create test Address Book
         addressBook=[Select Id,Name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
                      abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id ORDER BY Name LIMIT 1];
         System.assertNotEquals(null,             addressBook.Id);
         System.assertEquals(account.Id,       addressBook.abAccount__c);
         
         //Create test Component
         testComponent1 =[Select Id,Name,
                          Sub_State__c,
                          componentState__c,
                          componentAsset__c,
                          componentAccountId__c,
                          componentComponentSN__c,
                          componentServicePartNumber__c,
                          componentType__c, componentDescription__c
                          From component__c where componentServicePartNumber__c ='SR-PWR-1200W' AND componentAsset__c=:asset.Id LIMIT 1];
         
         //Create test RMA
         rma = [Select Id,Name,
                rmaCaseNumber__c,
                rmaDiskShelfAsset__c,
                rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];  
         
         System.assertNotEquals(null,rma.Id);
         System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
         System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
         System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
         System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
         //System.assertEquals('Flat List',rma.rmaSelection__c);           
         Test.startTest();
         rma.rmaOutgoingShipmentStatus__c = 'CLOSED-10: Delivered';
         rma.rmaReturnShipmentStatus__c = 'CLOSED-10: Delivered';
         rma.rmaRetShip2Status__c = 'CLOSED-10: Delivered';
         rma.rmaOnsiteTechStatus__c = 'CLOSED-10: Delivered';
         rma.rmaOutgoingShipmentDepot__c = 'ACV-003 (Arcata, CA, United States)';
         rma.rmaOutgoingShipmentCarrier__c = 'Aeronet';
         rma.rmaOutgoingShipmentTrackingNumber__c = 'TestTrack001';
         rma.rmaOutgoingShipmentPartSn__c = 'AC-200000';
         rma.rmaGateKeeperStatus__c = 'Automatic';
         update rma;
         Test.stopTest();
     }

      //==================================================================================== testRMAStatusCancelled
      /*@isTest(SeeAllData=true)
      static void testRMAStatusCancelled()
      {
          testRMAStatusOpen();
          RMAv2__c rma;
          
          Test.startTest();
          rma = [Select Id,Name,
                 rmaCaseNumber__c,
                 rmaDiskShelfAsset__c,
                 rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                 Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                 rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                 rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaIsComponentStatusReset__c,
                 rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                 From RMAv2__c LIMIT 1];  
          rma.rmaIsComponentStatusReset__c = false;
          rma.rmaOutgoingShipmentStatus__c = 'CANCELED-10: Canceled';
          rma.rmaReturnShipmentStatus__c = 'CANCELED-10: Canceled';
          rma.rmaRetShip2Status__c = 'CANCELED-10: Canceled';
          rma.rmaOnsiteTechStatus__c = 'CANCELED-10: Canceled';
          rma.rmaGateKeeperStatus__c = 'Automatic';
          update rma;
          Test.stopTest();
          
      }*/
      
     //==================================================================================== testRMAOnsiteCompiledNotes01 without rmaDiskShelfAsset__c
     /*@isTest(SeeAllData=true)
      static void testRMAOnsiteCompiledNotes()
     { 
         //Commented By Exafort(vishnu)
         //createTestData();
         //****************************************************************///
         /*Account account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
         insert account;
         
         // Create test contact
         Contact contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                       AccountId = account.Id,
                                       Email='test@gmail.com',
                                       Phone='999999999');
         insert contact;
         
         // Create test asset
         Asset asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium 4 Hour Onsite',
                                 HPE_Serial_Number__c = 'AA000000NIM',
                                 assetRmaShi__c = 'Asset RMA SHI');
         insert asset;
         
         
         // Create test case
         Case aCase = new Case(AccountId = account.Id,
                               AssetId   = asset.Id,
                               ContactId = contact.Id,
                               Subject = 'TEST-CASE-SUBJECT');
         insert aCase;
         Test.startTest();
         //Create test RMA
         RMAv2__c rma = new RMAv2__c(rmaCaseNumber__c                 = aCase.Id,
                                     rmaType__c                       = 'Advance replacement',
                                     rmaLabArray__c                   = 'No',
                                     rmaComponent__c                  = 'CHASSIS',
                                     rmaNimbleOsVersion__c            = 'CHASSIS: N/A',
                                     rmaModel__c                      = 'CHASSIS: CS/ES series',
                                     rmaPart__c                       = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',
                                     rmaQuantity__c                   = '1',
                                     rmaReason__c                     = 'CHASSIS: Bad controller slot',
                                     rmaManufacturer__c               = 'Super Micro',
                                     rmaDetailedReason__c             = 'TEST-RMA-DETAILED-REASON',
                                     rmaConfigurationDetails__c       = 'TEST-RMA-CONFIGURATION-DETAILS',
                                     rmaShipmentAddressSelector__c    = 'Asset install address',
                                     rmaOverrideShipmentPostalCode__c = '11111',
                                     rmaOverrideShipmentCity__c       = 'Sanjose',
                                     rmaOverrideShipmentCountry__c    = 'United States',
                                     rmaOverrideShipmentAttn__c       = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',
                                     rmaOverrideShipmentPhone__c      = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',
                                     rmaOverrideShipmentEmail__c      = 'test-rma-override-shipment-email@nimblestorage.com',
                                     rmaOverrideOnsiteCheckInCode__c  = 'CHECK-IN-10: FE must check in upon arrival',
                                     rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site',
                                     rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours',
                                     rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site',
                                     rmaUplift__c                     = 'No: Do not uplift',
                                     rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                     rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                     rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                     rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order',
                                     rmaTransmitRmaShisWithOrder__c   = 'No SHI');
         insert rma;
         
         //commented by Exafort(vishnu) and handled the Asset as Premium 4 Hour Onsite to avoid ERROR:Too Many SOQL Queries:101
         List<Asset> assets;
         assets = [SELECT Id  FROM   Asset];
         System.assertEquals(1, assets.size());       
         assets[0].SLA__c = 'Premium 4 Hour Onsite';
         update assets[0];
         
         List<RMAv2__c> rmas;
         rmas = [SELECT Id FROM   RMAv2__c];
         System.assertEquals(1, rmas.size());
         
         rmas[0].rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours';
         rmas[0].rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site';
         rmas[0].rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival';
         rmas[0].rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site';      
         rmas[0].rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET';
         rmas[0].rmaOverrideOnsiteArrivalCity__c = 'TESTCITY';
         rmas[0].rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222';
         rmas[0].rmaOverrideOnsiteArrivalCountry__c = 'United States';
         update rmas[0];
         
         rmas = [SELECT Id,
                 rmaStatus__c,
                 rmaOverrideOnsiteSchedulingCode__c,
                 rmaOverrideOnsitePartHandoverCode__c,
                 rmaOverrideOnsiteCheckInCode__c,
                 rmaOverrideOnsitePartDispositionCode__c,
                 rmaOverrideOnsiteArrivalStreet1__c,
                 rmaOverrideOnsiteArrivalCity__c,
                 rmaOverrideOnsiteArrivalPostalCode__c,
                 rmaOverrideOnsiteArrivalCountry__c,
                 rmaOnsiteCompiledNotes__c
                 FROM   RMAv2__c];
         
         System.assertEquals(1,                   rmas.size());
         System.assertEquals('Draft', rmas[0].rmaStatus__c);
         System.assertEquals('WITHIN-4-HOURS-10: Schedule within the next 4 hours', rmas[0].rmaOverrideOnsiteSchedulingCode__c);
         System.assertEquals('MANNED-10: Part courier must leave part with somebody at site', rmas[0].rmaOverrideOnsitePartHandoverCode__c);
         System.assertEquals('CHECK-IN-10: FE must check in upon arrival', rmas[0].rmaOverrideOnsiteCheckInCode__c);
         System.assertEquals('LEAVE-PART-10: FE must leave old part at site', rmas[0].rmaOverrideOnsitePartDispositionCode__c);
         System.assertEquals('TESTSTREET', rmas[0].rmaOverrideOnsiteArrivalStreet1__c);
         System.assertEquals('TESTCITY', rmas[0].rmaOverrideOnsiteArrivalCity__c);
         System.assertEquals('22222-2222', rmas[0].rmaOverrideOnsiteArrivalPostalCode__c);
         System.assertEquals('United States', rmas[0].rmaOverrideOnsiteArrivalCountry__c);
         System.assertNotEquals(null, rmas[0].rmaOnsiteCompiledNotes__c);*/
         /*Account account;
         Contact contact;
         Asset   asset;
         Case aCase;
         RMAv2__c rma;
         AddressBook__c addressBook;
         Component__c testComponent1;
         // Create test account
         
            account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
            System.assertNotEquals(null,              account.Id);
            System.assertEquals('Test Support Tools QA', account.Name);
            
            // Create test contact
            contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
            System.assertNotEquals(null,contact.Id);
            System.assertEquals(account.Id,contact.AccountId);
            System.assertEquals('Vishnu Test', contact.LastName);
            
            // Create test asset
            asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id LIMIT 1];
            System.assertNotEquals(null,                      asset.Id);
            System.assertEquals('AA-000000',                  asset.Name);
            System.assertEquals(account.Id,                 asset.AccountId);
            System.assertEquals(contact.Id,                 asset.ContactId);
            System.assertEquals('Premium',                     asset.SLA__c);
            
            //Create test case
            aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1];
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            System.assertEquals(contact.Id,       aCase.ContactId);
            System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);
            
            //Create test Address Book
            addressBook=[Select Id,name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
                         abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id Order BY Name LIMIT 1];
            System.assertNotEquals(null,             addressBook.Id);
            System.assertEquals(account.Id,       addressBook.abAccount__c);
         
           //Chassis
            testComponent1 =[Select Id,Name,
                             Sub_State__c,
                             componentState__c,
                             componentAsset__c,
                             componentAccountId__c,
                             componentComponentSN__c,
                             componentServicePartNumber__c,
                             componentType__c, componentDescription__c
                             From component__c where componentServicePartNumber__c ='SR-CHASSIS-3U-SMC' AND componentAsset__c=:asset.Id LIMIT 1];
            				 //Name='Com-3258853'
         
         rma = [Select Id,Name,
                rmaCaseNumber__c,
                rmaDiskShelfAsset__c,rmaStatus__c,
                rmaOverrideOnsiteSchedulingCode__c,
                rmaOverrideOnsitePartHandoverCode__c,
                rmaOverrideOnsiteCheckInCode__c,
                rmaOverrideOnsitePartDispositionCode__c,
                rmaOverrideOnsiteArrivalStreet1__c,
                rmaOverrideOnsiteArrivalCity__c,
                rmaOverrideOnsiteArrivalPostalCode__c,
                rmaOverrideOnsiteArrivalCountry__c,
                rmaOnsiteCompiledNotes__c,
                rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);
         Test.startTest();
         asset.SLA__c = 'Premium 4 Hour Onsite';
         update asset;
         
         rma.rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours';
         rma.rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site';
         rma.rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival';
         rma.rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site';      
         rma.rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET';
         rma.rmaOverrideOnsiteArrivalCity__c = 'TESTCITY';
         rma.rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222';
         rma.rmaOverrideOnsiteArrivalCountry__c = 'United States';
         update rma;
         Test.stopTest();
         rma = [Select Id,Name,
                rmaCaseNumber__c,
                rmaDiskShelfAsset__c,rmaStatus__c,
                rmaOverrideOnsiteSchedulingCode__c,
                rmaOverrideOnsitePartHandoverCode__c,
                rmaOverrideOnsiteCheckInCode__c,
                rmaOverrideOnsitePartDispositionCode__c,
                rmaOverrideOnsiteArrivalStreet1__c,
                rmaOverrideOnsiteArrivalCity__c,
                rmaOverrideOnsiteArrivalPostalCode__c,
                rmaOverrideOnsiteArrivalCountry__c,
                rmaOnsiteCompiledNotes__c,
                rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];
         
         //System.assertEquals(1,                   rmas.size());
         System.assertEquals('Open', rma.rmaStatus__c);
         System.assertEquals('WITHIN-4-HOURS-10: Schedule within the next 4 hours', rma.rmaOverrideOnsiteSchedulingCode__c);
         System.assertEquals('MANNED-10: Part courier must leave part with somebody at site', rma.rmaOverrideOnsitePartHandoverCode__c);
         System.assertEquals('CHECK-IN-10: FE must check in upon arrival', rma.rmaOverrideOnsiteCheckInCode__c);
         System.assertEquals('LEAVE-PART-10: FE must leave old part at site', rma.rmaOverrideOnsitePartDispositionCode__c);
         System.assertEquals('TESTSTREET', rma.rmaOverrideOnsiteArrivalStreet1__c);
         System.assertEquals('TESTCITY', rma.rmaOverrideOnsiteArrivalCity__c);
         System.assertEquals('22222-2222', rma.rmaOverrideOnsiteArrivalPostalCode__c);
         System.assertEquals('United States', rma.rmaOverrideOnsiteArrivalCountry__c);
         System.assertNotEquals(null, rma.rmaOnsiteCompiledNotes__c);
         
         //testRMAOnsiteCompiledNotes02(asset.Id);
         //Exafort(vishnu).changed the assets[0].Id to asset.Id
     }*/
      
     //==================================================================================== testRMAOnsiteCompiledNotes02 with rmaDiskShelfAsset__c
      /*static void testRMAOnsiteCompiledNotes02(ID assetsID)
     {  
       List<RMAv2__c> rmas;
       rmas = [SELECT Id,rmaModel__c,rmaDiskShelfAsset__c FROM   RMAv2__c where rmaComponentV2__c =:testData.testComponent1.Id AND rmaCaseNumber__c=:testData.aCase.Id LIMIT 1];
       System.assertEquals(1, rmas.size());
       rmas.rmaModel__c = 'CHASSIS: ES1 series';
       rmas.rmaDiskShelfAsset__c = assetsID;
       update rmas;

      rmas = [SELECT Id,
              rmaStatus__c,
              rmaOverrideOnsiteSchedulingCode__c,
              rmaOverrideOnsitePartHandoverCode__c,
              rmaOverrideOnsiteCheckInCode__c,
              rmaOverrideOnsitePartDispositionCode__c,
              rmaOverrideOnsiteArrivalStreet1__c,
              rmaOverrideOnsiteArrivalCity__c,
              rmaOverrideOnsiteArrivalPostalCode__c,
              rmaOverrideOnsiteArrivalCountry__c,
              rmaDiskShelfAsset__c,
              rmaOnsiteCompiledNotes__c
              FROM   RMAv2__c];

          System.assertEquals(1,                   rmas.size());
          System.assertEquals('Open', rmas[0].rmaStatus__c);
          System.assertEquals('WITHIN-4-HOURS-10: Schedule within the next 4 hours', rmas[0].rmaOverrideOnsiteSchedulingCode__c);
          System.assertEquals('MANNED-10: Part courier must leave part with somebody at site', rmas[0].rmaOverrideOnsitePartHandoverCode__c);
          System.assertEquals('CHECK-IN-10: FE must check in upon arrival', rmas[0].rmaOverrideOnsiteCheckInCode__c);
          System.assertEquals('LEAVE-PART-10: FE must leave old part at site', rmas[0].rmaOverrideOnsitePartDispositionCode__c);
          System.assertEquals('TESTSTREET', rmas[0].rmaOverrideOnsiteArrivalStreet1__c);
          System.assertEquals('TESTCITY', rmas[0].rmaOverrideOnsiteArrivalCity__c);
          System.assertEquals('22222-2222', rmas[0].rmaOverrideOnsiteArrivalPostalCode__c);
          System.assertEquals('United States', rmas[0].rmaOverrideOnsiteArrivalCountry__c);
          System.assertEquals(assetsID, rmas[0].rmaDiskShelfAsset__c);
          System.assertNotEquals(null, rmas[0].rmaOnsiteCompiledNotes__c);
 		  
      
     }*/
      
   // ==================================================================================== testDeliveryInstruction
   // Moved to rmaTriggerUpliftnLogisticsTest test class.
   /*static testMethod void testDeliveryInstruction()
     {List<RMAv2__c> rmas;
      ID testRmaId;

    
      createTestData();
     
      
      rmas = [SELECT Id FROM  RMAv2__c];
      System.assertEquals(1, rmas.size());
      rmas[0].rmaTransmitRmaShisWithOrder__c = 'Account RMA SHI;Asset RMA SHI;RMA SHI';
      update rmas[0];
      

      rmas = [SELECT Id,
                     rmaStatus__c,
                     rmaTransmitRmaShisWithOrder__c,
                     rmaDeliveryInstructions__c
              FROM   RMAv2__c];

      System.assertEquals(1,                        rmas.size());
      System.assertEquals('Draft', rmas[0].rmaStatus__c);
      System.assertEquals('Account RMA SHI;Asset RMA SHI;RMA SHI', rmas[0].rmaTransmitRmaShisWithOrder__c);
      System.assertNotEquals(null, rmas[0].rmaDeliveryInstructions__c);
      
      
     }*/
     
   // ==================================================================================== testAddOverriddenAddressToAB
   @isTest(SeeAllData=true)
   static void testAddOverriddenAddressToAB(){
      //List<RMAv2__c> rmas;
      //List<AddressBook__c> ab;
      //ID testRmaId;
	  //createTestData();
      //rmas = [SELECT Id,rmaAddOverriddenAddressToAddressBook__c FROM   RMAv2__c];
      //System.assertEquals(1, rmas.size());
      
       Account account;
       Contact contact;
       Asset   asset;
       Case aCase;
       RMAv2__c rma;
       AddressBook__c addressBook;
       Component__c testComponent1;
       
       // Create test account
       account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
       System.assertNotEquals(null,              account.Id);
       System.assertEquals('Test Support Tools QA', account.Name);
       
       // Create test contact
       contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
       System.assertNotEquals(null,contact.Id);
       System.assertEquals(account.Id,contact.AccountId);
       System.assertEquals('Vishnu Test', contact.LastName);
       
       // Create test asset
       asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id order by createddate ASC LIMIT 1];
       System.assertNotEquals(null,                      asset.Id);
       System.assertEquals('AA-000000',                  asset.Name);
       System.assertEquals(account.Id,                 asset.AccountId);
        
       
       //Create test case
       aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1 FOR UPDATE];
       System.assertNotEquals(null,             aCase.Id);
       System.assertEquals(account.Id,       aCase.AccountId);
       System.assertEquals(asset.Id,         aCase.AssetId);
       System.assertEquals(contact.Id,       aCase.ContactId);
       System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);
       
       //Create test Component
       testComponent1 =[Select Id,Name,
                        Sub_State__c,
                        componentState__c,
                        componentAsset__c,
                        componentAccountId__c,
                        componentComponentSN__c,
                        componentServicePartNumber__c,
                        componentType__c, componentDescription__c
                        From component__c where componentServicePartNumber__c ='SR-HDD-2TB' AND componentAsset__c=:asset.Id LIMIT 1 FOR UPDATE];
       //System.assertEquals('Com-3258856',       testComponent1.Name);
       
       //Create test RMA
       rma = [Select Id,Name,
              rmaCaseNumber__c,
              rmaDiskShelfAsset__c,
              rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
              Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
              rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
              rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaDeliveryDateTime__c,
              rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
              From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];  
       
       System.assertNotEquals(null,rma.Id);
       System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
       System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
       System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
       System.assertEquals('Component',rma.rmaSelection__c);
       
      rmaStatusInformationsPreventRecursive.run = true;
      CountRMAStatusInforPreventRecursive.run = true;
	  Test.StartTest();
      rma.rmaAddOverriddenAddressToAddressBook__c = true;
      update rma;
      Test.Stoptest();

      //ab = [SELECT Id,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,abPostalCode__c  FROM  AddressBook__c];
      /*System.assertEquals(1,                   ab.size());
      System.assertEquals('TEST-ASSET-INSTALL-STREET1,',ab[0].abStreet1__c);
      System.assertEquals('TEST-ASSET-INSTALL-STREET2',ab[0].abStreet2__c);
      System.assertEquals('TEST-ASSET-INSTALL-CITY', ab[0].abCity__c);
      System.assertEquals('TEST-ASSET-INSTALL-STATE', ab[0].abStateProvince__c);
      System.assertEquals('United States', ab[0].abCountry__c);
      System.assertEquals('11111', ab[0].abPostalCode__c);*/

     }
      
   // ==================================================================================== testCaseSSDWearLevelHigh
   @isTest(SeeAllData=true)
   static void testCaseSSDWearLevelHigh()
   {
         Account account;
         Contact contact;
         Asset   asset;
         Case aCase;
         RMAv2__c rma;
         AddressBook__c addressBook;
         Component__c testComponent1;
         
         // Create test account
         account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
         System.assertNotEquals(null,              account.Id);
         System.assertEquals('Test Support Tools QA', account.Name);
         
         // Create test contact
         contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
         System.assertNotEquals(null,contact.Id);
         System.assertEquals(account.Id,contact.AccountId);
         System.assertEquals('Vishnu Test', contact.LastName);
         
         // Create test asset
         asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id order by createddate ASC LIMIT 1];
         System.assertNotEquals(null,                      asset.Id);
         System.assertEquals('AA-000000',                  asset.Name);
         System.assertEquals(account.Id,                 asset.AccountId);
                 
         //Create test case
         aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1 FOR UPDATE];
         System.assertNotEquals(null,             aCase.Id);
         System.assertEquals(account.Id,       aCase.AccountId);
         System.assertEquals(asset.Id,         aCase.AssetId);
         System.assertEquals(contact.Id,       aCase.ContactId);
         System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);

         //Create test Component
         testComponent1 =[Select Id,Name,
                          Sub_State__c,
                          componentState__c,
                          componentAsset__c,
                          componentAccountId__c,
                          componentComponentSN__c,
                          componentServicePartNumber__c,
                          componentType__c, componentDescription__c
                          From component__c where componentServicePartNumber__c ='SR-HDD-2TB' AND componentAsset__c=:asset.Id LIMIT 1 FOR UPDATE];
         //System.assertEquals('Com-3258858',       testComponent1.Name);
         
         //Create test RMA
         rma = [Select Id,Name,
                rmaCaseNumber__c,
                rmaDiskShelfAsset__c,
                rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                rmaReturnShipmentStatus__c,rmaRetShip2Status__c,rmaDeliveryDateTime__c,
                rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY NAME DESC LIMIT 1];  
         
         System.assertNotEquals(null,rma.Id);
         System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
         System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
         System.assertEquals(testComponent1.Id,rma.rmaComponentV2__c);
         System.assertEquals('Component',rma.rmaSelection__c);
         
         //aCase.casePachinkoCaseType__c ='ssdwearlevelhigh';
         //update aCase;
         Test.startTest();
         rma.rmaDeliveryDateTime__c = null;
         update rma;
         Test.stopTest();
     }
}