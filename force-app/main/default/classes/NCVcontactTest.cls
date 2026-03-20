@isTest
private class NCVcontactTest {
    @isTest static void testMethod1() {    
               
                      
       Test.startTest();
  
        list<NCVcontact.contactWrapper> contlst = new list<NCVcontact.contactWrapper>();
        NCVcontact.contactWrapper contwrap = new  NCVcontact.contactWrapper(); 
        contwrap.firstname = 'S2';
        contwrap.lastname = 'S2';
        contwrap.phone = '1234';
        contwrap.title = 'mgr';
        contwrap.Email = 'S2@s2.com';
        contwrap.ContactRole = 'Business';
        contwrap.account_sfdc = '0018000001AAHXG';
        contlst.add(contwrap);
            
          //String myJSON = JSON.serialize(contlst);
            
       string jsonString =   '{"contList" : [{"firstname" : "S2","lastname" : "Sm2","phone" : "99850383","title": "Manager","Email": "test@test.com","ContactRole": "Business Buyer","account_sfdc":"0018000001AAHXG"}]}';
 
       //NCVcontact.doPost(jsonString);
       
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createNCVcontact/NCVcontact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        NCVcontact.doPost(contlst);
        
       Test.stopTest();
 
    }
}