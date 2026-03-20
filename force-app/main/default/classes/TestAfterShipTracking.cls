@isTest
private class TestAfterShipTracking
{
private static List<Id> testAccountIds = new List<Id>();
private static List<Id> testContactIds = new List<Id>();
private static List<Id> testAssetIds = new List<Id>();
private static List<Id> testCaseIds = new List<Id>();
private static List<Id> testRMAIds = new List<Id>();  
private static List<RMAv2__c> testRMA = new List<RMAv2__c>(); 
private static List <AfterShipTracking__c> testAfterShipTracking = new List<AfterShipTracking__c>();
private static List<AfterShipCheckPoint__c> testAfterShipCheckPoint = new List<AfterShipCheckPoint__c>(); 
Private static List<string> TestAfterShipCourier = new List<string>();
public static string testTime = String.Valueof(system.now()); 
//============================ createTestData======================//
 @isTest     
 static void createTestData()
 {
     createAccount();
     createContact();
     createAsset();
     createCase();
     
     createRMA();
     createCustomSettings();
     createAfterShipTracking();
     
     createAfterShipCheckPoints();
 }    
 
 
 
  //Create Account
     static void createAccount()
     { 
         Account account;
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
         asset = new Asset(Name = assetName,
                    AccountId = testAccountIds[i],
                    ContactId = testContactIds[i],
                    SLA__c = 'Premium',
                    Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                    Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                    Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                    Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',
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
      
 //Create RMA
 static void CreateRMA()
 {
          RMAv2__c rma;
         List<RMAv2__c> rmas;
         
               rma = new RMAv2__c(rmaCaseNumber__c            = testCaseIds[0],
                         rmaType__c                           = 'Advance replacement',
                         rmaLabArray__c                       = 'No',
                         rmaComponent__c                      = 'CHASSIS',
                         rmaNimbleOsVersion__c                = 'CHASSIS: N/A',
                         rmaModel__c                          = 'CHASSIS: CS/ES series',
                         rmaPart__c                           = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',
                         rmaQuantity__c                       = '1',
                         rmaReason__c                         = 'CHASSIS: Bad controller slot',
                         rmaManufacturer__c                   = 'Super Micro',
                         rmaDetailedReason__c                 = 'TEST-RMA-DETAILED-REASON',
                         rmaConfigurationDetails__c           = 'TEST-RMA-CONFIGURATION-DETAILS',
                         rmaShipmentAddressSelector__c        = 'Asset install address',
                         rmaOverrideShipmentPostalCode__c     = '11111',
                         rmaOverrideShipmentCountry__c        = 'United States',
                         rmaOverrideShipmentAttn__c           = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',
                         rmaOverrideShipmentPhone__c          = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',
                         rmaOverrideShipmentEmail__c          = 'test-rma-override-shipment-email@nimblestorage.com',
                         rmaUplift__c                         = 'No: Do not uplift',
                         rmaOutgoingShipmentStatus__c         = 'DRAFT-10: Waiting to order',
                         rmaReturnShipmentStatus__c           = 'DRAFT-10: Waiting to order',
                         rmaRetShip2Status__c                 = 'DRAFT-10: Waiting to order',
                         rmaOnsiteTechStatus__c               = 'DRAFT-10: Waiting to order',
                         rmaTransmitRmaShisWithOrder__c       = 'No SHI',
                         rmaOutgoingShipmentCarrier__c        = 'fedex',
                         rmaOutgoingShipmentTrackingNumber__c = 'TEST-Tracking'
                         );
      insert rma;
      rmas = [SELECT Id,
                     Name,
                     rmaOutgoingShipmentStatus__c,
                     rmaOutShipProviderOrderNumber__c,
                     rmaOutgoingShipmentCarrier__c,
                     rmaOutgoingShipmentTrackingNumber__c,
                     rmaShipmentPhone__c,
                     rmaShipmentEmail__c,
                     CreatedDate,
                     rmaShipmentCountry__c,
                     rmaShipmentAttn__c
              FROM   RMAv2__c];

      testRMAIds.add(rmas[0].id);
      testRMA.add(rmas[0]);
      
      //create another RMA 
      rma = new RMAv2__c(rmaCaseNumber__c            = testCaseIds[0],
                         rmaType__c                           = 'Advance replacement',
                         rmaLabArray__c                       = 'No',
                         rmaComponent__c                      = 'CHASSIS',
                         rmaNimbleOsVersion__c                = 'CHASSIS: N/A',
                         rmaModel__c                          = 'CHASSIS: CS/ES series',
                         rmaPart__c                           = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',
                         rmaQuantity__c                       = '1',
                         rmaReason__c                         = 'CHASSIS: Bad controller slot',
                         rmaManufacturer__c                   = 'Super Micro',
                         rmaDetailedReason__c                 = 'TEST-RMA-DETAILED-REASON',
                         rmaConfigurationDetails__c           = 'TEST-RMA-CONFIGURATION-DETAILS',
                         rmaShipmentAddressSelector__c        = 'Asset install address',
                         rmaOverrideShipmentPostalCode__c     = '11111',
                         rmaOverrideShipmentCountry__c        = 'United States',
                         rmaOverrideShipmentAttn__c           = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',
                         rmaOverrideShipmentPhone__c          = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',
                         rmaOverrideShipmentEmail__c          = 'test-rma-override-shipment-email@nimblestorage.com',
                         rmaUplift__c                         = 'No: Do not uplift',
                         rmaOutgoingShipmentStatus__c         = 'DRAFT-10: Waiting to order',
                         rmaReturnShipmentStatus__c           = 'DRAFT-10: Waiting to order',
                         rmaRetShip2Status__c                 = 'DRAFT-10: Waiting to order',
                         rmaOnsiteTechStatus__c               = 'DRAFT-10: Waiting to order',
                         rmaTransmitRmaShisWithOrder__c       = 'No SHI',
                         rmaOutgoingShipmentCarrier__c        = 'fedex',
                         rmaOutgoingShipmentTrackingNumber__c = 'TEST-Tracking 1'
                         );
      //insert rma;
      rmas = [SELECT Id,
                     Name,
                     rmaOutgoingShipmentStatus__c,
                     rmaOutShipProviderOrderNumber__c,
                     rmaOutgoingShipmentCarrier__c,
                     rmaOutgoingShipmentTrackingNumber__c,
                     rmaShipmentPhone__c,
                     rmaShipmentEmail__c,
                     CreatedDate,
                     rmaShipmentCountry__c,
                     rmaShipmentAttn__c
              FROM   RMAv2__c];

      testRMAIds.add(rmas[0].id);
      testRMA.add(rmas[0]);
     
  }
  
  //Create Custom settings
 static void createCustomSettings()
 { 
     AfterShipSettings__c AfterShipSettings = new AfterShipSettings__c ();
     AfterShipCarrierList__c AfterShipCarrier = new AfterShipCarrierList__c ();
     system.debug('@@ custom settings values  '+ AfterShipSettings +' and list values '+AfterShipCarrier );          
     AfterShipSettings.AfterShipAPIKey__c = 'f6dee104-16b0-462d-a12b-b63177ab7cfd';
     AfterShipSettings.AfterShipEndPointURL__c = 'https://api.aftership.com/v4/trackings'; // Endpoint url of the Aftership tracking
     AfterShipSettings.CheckPointSchedulerPeriod__c = 1;
     AfterShipSettings.TrackingSchedulerPeriod__c = 1;
     AfterShipSettings.DaystoDeletetheAfterShipLogs__c = 0; 
     insert AfterShipSettings;
     
     System.assertEquals(AfterShipSettings.AfterShipAPIKey__c,'f6dee104-16b0-462d-a12b-b63177ab7cfd');
     System.assertEquals(AfterShipSettings.AfterShipEndPointURL__c ,'https://api.aftership.com/v4/trackings');
     System.assertEquals(AfterShipSettings.CheckPointSchedulerPeriod__c ,1);
     System.assertEquals(AfterShipSettings.TrackingSchedulerPeriod__c ,1);
     System.assertEquals(AfterShipSettings.DaystoDeletetheAfterShipLogs__c ,0);
     
     
     AfterShipCarrier.name = 'fedex';
     AfterShipCarrier.Carrier__c = 'fedex';
     insert AfterShipCarrier;
     
     System.assertEquals(AfterShipCarrier.Name,'fedex');
     System.assertEquals(AfterShipCarrier.Carrier__c,'fedex');
     

 }
  
//Create AfterShipTracking
     static void createAfterShipTracking()
     { 
         AfterShipTracking__c AfterShipTracking;
         List<AfterShipTracking__c>  insAfterShipTracking = new List<AfterShipTracking__c>();
         Set<String> sTrackingNumber = new Set<String>();
         
         //String accName = 'TEST-Tracking 1';
         //sAccountNames.add(accName);
         AfterShipTracking = new AfterShipTracking__c (astTrackingNumber__c = 'TEST-Tracking 1',astTrackingCreatedinAfterShip__c = TRUE,astTrackingErrorMessage__c='',astTrackingCreatedTime__c= testTime);
         insAfterShipTracking.add(AfterShipTracking);
         
         AfterShipTracking = new AfterShipTracking__c (astTrackingNumber__c = 'TEST-Tracking 2',astTrackingCreatedinAfterShip__c = FALSE,astTrackingErrorMessage__c='Tracking already exists',astTrackingCreatedTime__c= testTime);
         insAfterShipTracking.add(AfterShipTracking);
         
         insert insAfterShipTracking;
         
          List<AfterShipTracking__c>  lstAfterShipTracking = [SELECT Id,
                         Name,astTrackingNumber__c,
                         astTrackingCreatedinAfterShip__c,astTrackingErrorMessage__c
                  FROM   AfterShipTracking__c
                  order by astTrackingNumber__c];
         
          System.assertEquals(insAfterShipTracking.size(),lstAfterShipTracking.size());
         
          for(Integer i=1;i<=lstAfterShipTracking.size();i++)
          {
            System.assertEquals('TEST-Tracking ' + i, lstAfterShipTracking[i-1].astTrackingNumber__c,'TEST-Tracking ' + i);
            testAfterShipTracking.add(lstAfterShipTracking[i-1]);

          }
         
        
         
     }
    
    
     //Create AfterShipCheckPoint__c
     static void createAfterShipCheckPoints()
     { 
         AfterShipCheckPoint__c AfterShipCheckPoint;
         AfterShipCheckPointforRMA__c AfterShipCheckPointforRMA;
         List<AfterShipCheckPoint__c>  insAfterShipCheckPoint = new List<AfterShipCheckPoint__c>();
         List<AfterShipCheckPointforRMA__c>  insAfterShipCheckPointforRMA = new List<AfterShipCheckPointforRMA__c>();
         
         
         for(Integer i=0; i< 3; i++)
         {
             AfterShipCheckPoint = new AfterShipCheckPoint__c(ascpTrackingNumber__c ='TEST-Tracking 1',ascpCheckPointTime__c = testTime,ascpTrackingCreatedTime__c =testTime);
             insAfterShipCheckPoint.add(AfterShipCheckPoint);
             AfterShipCheckPointforRMA = new AfterShipCheckPointforRMA__c(ascprmaTrackingNumber__c ='TEST-Tracking 1',ascprmaCheckPointTime__c = testTime);
             insAfterShipCheckPointforRMA.add(AfterShipCheckPointforRMA);
         }
         
         insert insAfterShipCheckPoint;
         insert insAfterShipCheckPointforRMA;
         
         List<AfterShipCheckPoint__c>  lstAfterShipCheckPoint = [SELECT Id,
                                                                    Name,ascpTrackingNumber__c,ascpCheckPointTime__c,ascpCountry__c,
                                                                    ascpMessage__c,ascpState__c,ascpTrackingStatus__c 
                                                                    from AfterShipCheckPoint__c];
         
              
         
          //System.assertEquals(insAccounts.size(),              accounts.size());
         
          for(Integer i=0;i<lstAfterShipCheckPoint.size();i++)
          {
            //System.assertEquals('TEST-ACCOUNT' + i, accounts[i].Name,'Account Name - TEST-ACCOUNT' + i);
            //System.assertEquals('AccountTestShi' + i, accounts[i].accountRmaShi__c,'Account Name - TEST-ACCOUNT' + i);
            testAfterShipCheckPoint.add(lstAfterShipCheckPoint[i]);
          }
         
        
         
     }
   
   
     
  ///test methods  
  
  
     //Update AfterShipTracking
     static testMethod void testAfterShipTrackingTrigger()
     { 
          createTestData();
          
          List<AfterShipTracking__c>  updAfterShipTracking = new List<AfterShipTracking__c>();
          
          
          List<AfterShipTracking__c>  lstAfterShipTracking = [SELECT Id,
                         Name,astTrackingNumber__c
                         FROM   AfterShipTracking__c
                         order by astTrackingNumber__c];
         
          
          for(Integer i=1;i<=lstAfterShipTracking.size();i++)
          {
            System.assertEquals('TEST-Tracking ' + i, lstAfterShipTracking[i-1].astTrackingNumber__c,'TEST-Tracking ' + i);
            AfterShipTracking__c AfterShipTracking = new AfterShipTracking__c();
            AfterShipTracking.ID = lstAfterShipTracking[i-1].ID;
            AfterShipTracking.astTrackingStatus__c = 'TEST Status';
            AfterShipTracking.astAfterShipLastUpdate__c = 'TEST Update';
            AfterShipTracking.astSignedBy__c = 'TEST User';
            updAfterShipTracking.add(AfterShipTracking);

          }
        
          test.startTest();
          Update updAfterShipTracking;
        test.stopTest();
        
         
     } 
       
  @IsTest
  static void testAfterShipTrackingRegisterBatch()
  {
      test.startTest();
       createTestData();
      test.stopTest();
      
       // Create an instance of batchable context
        Database.BatchableContext BC;
        SchedulableContext sc;
                    
        // Set mock callout class 
        
        
        AfterShipTrackingBatch batch = new AfterShipTrackingBatch();
        AfterShipTrackingReschedulingClass ReschedulingClass = new AfterShipTrackingReschedulingClass();   
        
     
        AfterShipTrackingBatch.TestResponse = '{"meta": {"code": 401,"message": "Invalid API Key.","type": "Unauthorized" }, "data": {}}';
        AfterShipTrackingBatch.insertTrackinginAfterShip(testAfterShipTracking[0].astTrackingNumber__c,'fedex','OrderID','CustomerName','TrackingCreatedTime',testAfterShipTracking[0].ID);
        //to test the created status 
        AfterShipTrackingBatch.TestResponse = '';
        AfterShipTrackingBatch.insertTrackinginAfterShip(testAfterShipTracking[0].astTrackingNumber__c,'fedex','OrderID','CustomerName','TrackingCreatedTime',testAfterShipTracking[0].ID);
       
        batch.start(BC);
      
        //batch.execute(BC,testRMA);
      
        batch.finish(BC);
      
        ReschedulingClass.execute(sc);
        AfterShipTrackingReschedulingClass.runningJobCount = 6;
        ReschedulingClass.execute(sc);
      
               
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://suptoolsqa-nimble.cs1.force.com/AfterShipWebhook/services/apexrest/AfterShipWebhookService'; //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody =Blob.valueof('[{ "event": "tracking_update", "msg":{"tracking_number": "TEST-Tracking 1", "title": "TEST-Tracking 1","tracking_created_time":"2015-06-11 10:29:31+00:00", "checkpoints": [{"country_name": null, "country_iso3": null,"state": null  },{"country_name": "94621, OAKLAND, US","country_iso3": "USA","state": "CA","city": "OAKLAND","zip": "94621", "message": "Picked up","tag": "InTransit","created_at": "2015-06-11T10:29:31+00:00","checkpoint_time": "2015-06-04T14:11:00"}],"signed_by": "D Johnson"}, "ts": 1403688191 }]');
                
        RestContext.request = req;
        RestContext.response= res;
        
        AfterShipWebhookService s=new AfterShipWebhookService ();
        AfterShipWebhookService.dopost();
     
        
  }
 
 static testMethod void testAfterShipCheckPointBatch()
 {
        createTestData();
       // Create an instance of batchable context
        Database.BatchableContext BC;
        SchedulableContext sc;
        
        AfterShipCheckPointBatch batch = new AfterShipCheckPointBatch();
        AfterShipCheckPointReschedulingClass ReschedulingClass = new AfterShipCheckPointReschedulingClass();
        
     
        batch.start(BC);
        batch.execute(BC,testAfterShipCheckPoint);      
        batch.finish(BC);
        ReschedulingClass.execute(sc);
        AfterShipCheckPointReschedulingClass.runningJobCount = 6;
        ReschedulingClass.execute(sc);
     
        
      
        
        
        
 }  
 static testMethod void testDeleteAfterShipLogs()
 {
       system.debug('****before createTestData method*****');
        createTestData();
     system.debug('****after createTestData method*****');
     
       // Create an instance of batchable context
        Database.BatchableContext BC;
        SchedulableContext sc;
     test.startTest();
        AfterShipTrackingDeleteBatch batch = new AfterShipTrackingDeleteBatch();
        test.stopTest();
              
        batch.start(BC);
        batch.execute(BC,testAfterShipTracking);
        batch.execute(sc);
        batch.finish(BC);
     
 }  
  
  
 }