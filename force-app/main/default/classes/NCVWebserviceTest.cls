@isTest
private class NCVWebserviceTest {
    @isTest static void testMethod1() {  
    
    Test.startTest();
    
      List<NCVWebservice.NCVWrapper> ncvlst = new List<NCVWebservice.NCVWrapper>();
       NCVWebservice.NCVWrapper NCVwrap = new  NCVWebservice.NCVWrapper(); 
       NCVwrap.dt = system.now();
       NCVwrap.account_name = 'Pioneer Rural Electric';
       NCVwrap.account_sfdc = '0018000001AAHXG';
       NCVwrap.user_name = 'Brian Adair';
       NCVwrap.user_sfdc = '0031b000005smhHAAQ';
       NCVwrap.array_sn = 'AA-100857';
       NCVwrap.volume_sn = 'e0a1c9e4052c33346c9ce9000fc02084';
       NCVwrap.volume_name = 'vol1';
       NCVwrap.volume_size = 1024;
       NCVwrap.volume_iops_limit = 3000;
       NCVwrap.volume_status = true;
       NCVwrap.cloud_volume_name = 'sudhir';
       NCVwrap.user_isadmin = true;
       ncvlst.add(NCVwrap);
       
       string jsonString =   '{"volumes":[{"dt":"2011-01-10T08:00:00Z","account_name":"Pioneer Rural Electric","account_sfdc":"0018000001AAHXG","user_name":"Brian Adair","user_sfdc":"0031b000005smhHAAQ","array_sn":"AA-100857","volume_sn":"e0a1c9e4052c33346c9ce9000fc02084","volume_name": "vol1","volume_size":1024,"volume_iops_limit":3000,"volume_status":true,"cloud_volume_name":"sudhir","user_isadmin":true }]}';  
    
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       
       req.requestURI = '/services/apexrest/createNCVcontact/NCVcontact';  //Request URL
       req.httpMethod = 'POST';//HTTP Request Type
       req.requestBody = Blob.valueof(jsonString);
       RestContext.request = req;
       RestContext.response= res;
       NCVWebservice.doPost(ncvlst);
 
       //Added by Sudhir to cover update part. 
       checkRecursive.resetRunOnceFlag();
       string jsonString1 =   '{"volumes":[{"dt":"2011-01-10T08:00:00Z","account_name":"NimbleAdmin","account_sfdc":"001S000000qiaoZIAQ","user_name":"Zaid Tariq","user_sfdc":"003S000000wzlGDIAY","array_sn":"NC-00365","volume_sn":"0e14f635-2fc6-3c0d-93f3-5c68b629e873-1-36-test","volume_name": "vol1","volume_size":1024,"volume_iops_limit":3000,"volume_status":true,"cloud_volume_name":"sudhir","user_isadmin":true }]}';  
       
       RestRequest req1 = new RestRequest(); 
       RestResponse res1 = new RestResponse();
       
       req1.requestURI = '/services/apexrest/createNCVcontact/NCVcontact';  //Request URL
       req1.httpMethod = 'POST';//HTTP Request Type
       req1.requestBody = Blob.valueof(jsonString1);
       RestContext.request = req1;
       RestContext.response= res1;
       
       NCVWebservice.doPost(ncvlst);
    
    Test.stopTest();  
    
    
 }
}