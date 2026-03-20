@isTest 
private Class testSendAssetDataRestIntegration{   
@isTest 
     Static void SendAssetDataRestIntegrationTestMethod(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockCallout());
        Test.stopTest();
            Account Act = new Account( Name = 'Test Sudhir Ac');
      insert Act;
      
     Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'John', email='venkat@ns.com',
                                             AccountId = act.Id);
      insert con1;
      Opportunity Opp = new Opportunity(Accountid = Act.id,name ='Test Sudhir Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'OPE-1234567890');
                          
      insert Opp;  
 Product2 prod1=new Product2();
        prod1.Name='HF20';
        prod1.Component_Code__c='HF20';
        prod1.ProductCode='HF20';
        prod1.Asset_Type__c='test1';
        prod1.infosight_identifier__c='HF20';
        prod1.HPE_SKU__C='Q8H72A';
        prod1.Family='Hybrid Flash Array';
        insert prod1;

      Asset a1 = new Asset(Name = 'HPE123456', AccountId  = Act.id, contactid =con1.id,  Opportunity_Asset__c = opp.id,
      SerialNumber ='NM123456' , HPE_Serial_Number__c='HPE123456',ES_API_Call_Completed__c = true, Product2id = prod1.id,
      Array_Cache__c='test1-test1',Array_Capacity__c='test1',Array_Controller__c='test2',Array_Networking__c='test3',
      Expansion_Shelf_Base__c='test1', SSD_Bank_A__c='test1',SSD_Bank_B__c='test1'
      

                      );     
      Insert a1;  
      list<id> assetids=new list<id>();
      assetids.add(a1.id);
    Integration_Settings__c assetCs=new Integration_Settings__c();
        assetCs.name='HPEIntegration';
        assetCs.Body__c ='grant_type=password&client_id=3MVG9ZL0ppGP5UrBu3ssBxR86SwycplFWB92uAjD8vrt3yKqM3.moenJ5f_TwWR7hIv7O5nRoy5vlIj8NZDu1&client_secret=265800839368963396&username=mydevorg55555@gmail.com&password=Bestintheworld@123BRgo7Pi2PlErg8veAxyfgqfk';
        assetCs.EndPoint__c='http://ext-itg-webserv-corona.austin.hp.com/QuoteIds/hpe/2.3/assetServices/NimbleAsset/json';
        assetCs.EndPointLogin__c='https://itg.marketplace.hpe.com/marketplace/ingramnotification/services//oauth2/token';
        assetCs.AuthorizationHeader__c='Basic VGVzdFBPQzoxcWF6MndzeA==';
        assetCs.Username__c='TestPOC';
        assetCs.Password__c='1qaz2wsx';
        insert assetCs;
      list<asset> assetidslist=[select id,status from asset where id in:assetids];
        assetidslist[0].status='Returned';
        update assetidslist;
      SendAssetDataRestIntegration1.futureSendAssetData(assetids);
        
   }
   }