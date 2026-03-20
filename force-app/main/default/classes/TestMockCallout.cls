@isTest
global class TestMockCallout implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse respost = new HttpResponse();
        respost.setHeader('Content-Type', 'application/json');

        Integration_Settings__c assetCs=new Integration_Settings__c();
        assetCs.name='HPEIntegration';
        assetCs.Body__c   ='grant_type=password&client_id=3MVG9ZL0ppGP5UrBu3ssBxR86SwycplFWB92uAjD8vrt3yKqM3.moenJ5f_TwWR7hIv7O5nRoy5vlIj8NZDu1&client_secret=265800839368963396&username=mydevorg55555@gmail.com&password=Bestintheworld@123BRgo7Pi2PlErg8veAxyfgqfk';
        assetCs.EndPoint__c='http://ext-itg-webserv-corona.austin.hp.com/QuoteIds/hpe/2.4/assetServices/NimbleAsset/json En';
        assetCs.EndPointLogin__c='https://itg.marketplace.hpe.com/marketplace/ingramnotification/services//oauth2/token';
        assetCs.AuthorizationHeader__c='Basic VGVzdFBPQzoxcWF6MndzeA==';
        assetCs.Username__c='TestPOC';
        assetCs.Password__c='1qaz2wsx';
        insert assetCs;
        String endPoint = String.valueOf(assetCs.EndPointLogin__c);
        respost.setBody('{"access_token":"wXuuiNZlHPz7mtWMaUTKae03r6KN","token_type":"Bearer","expires_in":7199}');

        respost.setStatusCode(200);
          return respost;
              
          }
          
       
    
}