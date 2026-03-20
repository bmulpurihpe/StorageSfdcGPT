/****************************************************************************************************************************
Created By      : Sudhir N
Created Date    : 1/7/2017
Purpose         : Creating an endpoint, called as createNCVrecord. This endpoint will be called by the NCV portal to create the contact
                  in SFDC.

****************************************************************************************************************************/
@RestResource(urlMapping='/captureNCV/*')
global with sharing class NCVWebservice {
 
    @HttpPost
    global static String doPost(list<NCVWrapper> volumes) {
     
        List<Nimble_Cloud_Volume__c> ncvid = new List<Nimble_Cloud_Volume__c>();
        
        for (NCVWrapper ncv: volumes){
                  
            Nimble_Cloud_Volume__c thisncv = new Nimble_Cloud_Volume__c(
                Last_Portal_Update__c = ncv.dt,
                NCV_Account_Name__c = ncv.account_name,
                NCV_Account__c = ncv.account_sfdc,
                Contact_Name__c = ncv.user_name,
                Contact_ID__c = ncv.user_sfdc,
                Asset_Serial_Number__c  = ncv.array_sn,
                Volume_Serial_Number__c =  ncv.volume_sn,
                User_Defined_Volume_Name__c = ncv.cloud_volume_name,
                //User_Defined_Volume_Name__c = ncv.volume_name,
                Volume_Size__c = ncv.volume_size,
                Volume_IOPS_limit__c = ncv.volume_iops_limit,
                Status__c = ncv.volume_status,
                Volume_name__c = ncv.volume_name,
                //Volume_name__c = ncv.cloud_volume_name,
                Admin_user__c = ncv.user_isadmin
            );
              
            ncvid.add(thisncv);
              
            Schema.SObjectField f = Nimble_Cloud_Volume__c.Fields.Volume_Serial_Number__c; 
              
            database.upsert(thisncv,f,true);    
      }
 
 
      list<responseNCVDetails> rncvlst = new list<responseNCVDetails>();
     
         for(Nimble_Cloud_Volume__c ncv :ncvid){
           responseNCVDetails nwrespdet = new responseNCVDetails();
              nwrespdet.dt  = ncv.Last_Portal_Update__c;
              nwrespdet.account_name = ncv.NCV_Account_Name__c;
              nwrespdet.user_name = ncv.Contact_Name__c;
              nwrespdet.array_sn = ncv.Asset_Serial_Number__c;
              nwrespdet.volume_name = ncv.Volume_name__c;
              nwrespdet.StatusCode = '200';
              
              rncvlst.add(nwrespdet);
          } 
 
      // Serializing the data 
      String jsonResponse = json.serialize(rncvlst);
      system.debug(jsonResponse);
      return jsonResponse;
      
      return null;
    }
    
    global class NCVWrapper {
        global Datetime dt { get; set; }    //Format: iso8601 date string
        global String account_name { get; set; }    //Example: "Pioneer Rural Electric"
        global String account_sfdc { get; set; }    //Example: "0018000000n4PQr"
        global String user_name { get; set; }    //Example: "Brian Adair"
        global String user_sfdc { get; set; }    //Example: "0018000000z8WRp"
        global String array_sn { get; set; }    //Example: "AF-378272"
        global String volume_sn { get; set; }     //Example: "e0a1c9e4052c33346c9ce9000fc02084"
        global String volume_name { get; set; }    //Example: "vol1"
        global Decimal volume_size { get; set; }    //will be set to 0 at the time of deletion //Example: "1024"
        global Decimal volume_iops_limit { get; set; }   //will be set to 0 at the time of deletion   //Example: "3000"  
        global Boolean volume_status { get; set; } // 1 is true and 0 is false
        global String cloud_volume_name {get; set;} // Volume name that customer sees
        global Boolean user_isadmin {get; set;}    //# set to 1 for admin user, 0 for non-admin user
      }  
   
     global class responseNCVDetails {
       public Datetime dt { get; set; }
       public String account_name { get; set; }
       public String user_name { get; set; }
       public String array_sn { get; set; }
       public String volume_name { get; set; }
       public string StatusCode { get; set; } 

     }
      
 }