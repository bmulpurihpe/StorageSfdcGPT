/****************************************************************************************************************************
Created By      : Sudhir Narayanswamy
Created Date    : 1/2/2017
Purpose         : Creating an endpoint, called as NCVcontact. This endpoint will be called by the NCV portal to create the contact
                  in SFDC.

****************************************************************************************************************************/
@RestResource(urlMapping='/createNCVcontact/*')
global with sharing class NCVcontact {
 
    @HttpPost
    global static String doPost(list<contactWrapper> contList) {
      
      List<Contact> contid = new List<Contact>();
 
      for (contactWrapper ct: contList){
 
        Contact cont = new Contact();
          cont.firstname = ct.firstname;
          cont.lastname = ct.lastname;
          cont.phone = ct.phone;
          cont.title = ct.title;
          cont.email = ct.email;
          cont.contact_role__c = ct.contactRole;
          cont.AccountId = ct.account_sfdc;
        
        insert cont;
  
        contid.add(cont);    
      }

       list<responseContactDetails> rcdlst = new list<responseContactDetails>();
         
        for ( Contact cnt : contid){
          responseContactDetails nwrespdet = new responseContactDetails();
            nwrespdet.ContactId = cnt.id;
            nwrespdet.StatusMessage = 'Success';
            nwrespdet.Name = cnt.firstname + ' ' + cnt.lastname;
            nwrespdet.Email = cnt.email;
            nwrespdet.StatusCode =  '200';
              rcdlst.add(nwrespdet);             
        }
      
 
      system.debug(rcdlst);
      
      // Serializing the data 
      String jsonResponse = json.serialize(rcdlst);
      system.debug(jsonResponse);
      return jsonResponse;    
    }

    // Wrapper class created to de-seralize the portal data. 
    global class contactWrapper {
      global String firstname { get; set; }
      global String lastname { get; set; }
      global String phone { get; set; }  
      global String Title { get; set; }
      global String Email { get; set; }
      global String contactRole {get; set;}
      global String account_sfdc {get; set;}
      
    } 

    global class responseContactDetails {
      public String ContactId{get;set;}
      public String StatusMessage{get;set;}
      public String Name{get;set;}
      public string Email{get;set;}
      public string StatusCode{get;set;}
 
      
    }   
}