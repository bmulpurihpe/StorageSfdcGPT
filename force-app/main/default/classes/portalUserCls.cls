public class portalUserCls{
    //proceedUser
    public static void proccedUser(set<id> uIDs,set<id> aIDs)
    {
        list<user> lstname=new list<user>();
        String MergFields;
        String locationidentifier;
        //need to add additional filters here
        Map<Id, Account> mapAccounts = new Map<Id, Account>( [select Name, CH_Partner_Certification_Level__c,
                                                                     Channel_Program__c,
                                                                     Sales_Region__c,BillingCountry, 
                                                                     BillingState, type ,CH_Main_Contact_at_Partner__c 
                                                                    from account where id in :aIDs ] );
        Map<id,string> CPGIMap = new Map<id,string>();
        Map<id,string> LIMap = new Map<id,string>();
        Map<id,string> BCMap = new Map<id,string>();
        Map<id,string> BSMap = new Map<id,string>();
        Map<id,id> MainContactMap = new Map<id,id>();
        Map<id,String> AccountNameMap = new Map<id,string>();
        // We don't need map's inside the for loop. We can use key directly.
        for ( Account key : mapAccounts.values())
            {   System.debug('----------c1---------'+mapAccounts.get(key.id).CH_Partner_Certification_Level__c);
                if(mapAccounts.get(key.id).Type <> null){
                     MergFields = mapAccounts.get(key.id).Type;    
                  }else{
                  MergFields ='[null]'; 
                 }
                 if(mapAccounts.get(key.id).CH_Partner_Certification_Level__c <> null){
                     list<string> certString =  mapAccounts.get(key.id).CH_Partner_Certification_Level__c.split(' ',2);
                     MergFields += '-'+certString[0];    
                  }else{
                  MergFields ='-[null]'; 
                 }//System.debug('----------c2---------'+mapAccounts.get(key.id).Channel_Program__c);
                 if(mapAccounts.get(key.id).Channel_Program__c <> null){
                     MergFields += '-'+mapAccounts.get(key.id).Channel_Program__c;    
                  }else{
                  MergFields +='-[null]'; 
                 }System.debug('----------c3---------'+mapAccounts.get(key.id).Sales_Region__c);
                 if(mapAccounts.get(key.id).Sales_Region__c <> null){
                     MergFields += '-'+mapAccounts.get(key.id).Sales_Region__c;    
                  }else{MergFields +='-[null]'; 
                 }System.debug('----------c4---------'+mapAccounts.get(key.id).BillingCountry);
                if(mapAccounts.get(key.id).BillingCountry <> null){
                   string CountryCodeFull =  mapAccounts.get(key.id).BillingCountry;
                   integer slength =   CountryCodeFull.length();
                   String CountryCode = CountryCodeFull.mid(slength-3, 2); 
                   MergFields += '-'+CountryCode; 
                   locationidentifier = CountryCode;
                 }else{
                  MergFields +='-[null]'; 
                  locationidentifier = 'US';   
                 }System.debug('----------c5---------'+mapAccounts.get(key.id).BillingState);
                 if(locationidentifier=='US' || locationidentifier=='CA'){
                     if(mapAccounts.get(key.id).BillingState <> null){  
                            MergFields += '-'+mapAccounts.get(key.id).BillingState;            
                      }else{    
                            MergFields +='-[null]'; 
                      }
                }
                CPGIMap.put(key.id,MergFields);   
                LIMap.put(key.id,locationidentifier);
                BSMAP.put(key.id,mapAccounts.get(key.id).BillingState);
                BCMAP.put(key.id,mapAccounts.get(key.id).BillingCountry);
                MainContactMap.put(key.id, key.CH_Main_Contact_at_Partner__c );			
            AccountNameMap.put(key.id, Key.Name );
        }
        
        for(User u:[select id,IsPortalEnabled,CompanyPartnershipGroupIdentifier__c,
                            Locationidentifier__c,LocaleSidKey,AccountId,
                            Locale__c,ApplicationRoleIdentifier__c ,
                            ApplicationRoleIdentifiertext__C, Role_Name__c, 
                            MDF_Requestor__c, companyname, Nimble_Solution_Specialist_NSS__c 
                            from user where id IN :uIDs]){    
            u.CompanyPartnershipGroupIdentifier__c=CPGIMap.get(u.AccountId);
            u.Locationidentifier__c = LIMap.get(u.AccountId);
            u.Locale__c = u.LocaleSidKey.replace('_','-');
            //system.debug('-------------1------'+u.LocaleSidKey+'-----'+u.Locale__c);
            if(u.ApplicationRoleIdentifier__C != null){
                  u.ApplicationRoleIdentifiertext__C = u.ApplicationRoleIdentifier__C;
              }else if(u.ContactId == MainContactMap.get(u.AccountId)){
                  u.ApplicationRoleIdentifier__C = 'Company Administrator';
                  u.ApplicationRoleIdentifiertext__C = 'Company Administrator';
              }else if(u.MDF_Requestor__c == True){
                  u.ApplicationRoleIdentifier__C = 'MDF Requestor';
                  u.ApplicationRoleIdentifiertext__C = 'MDF Requestor';
              }else{
                  u.ApplicationRoleIdentifier__C = '';
                  u.ApplicationRoleIdentifiertext__C = '';
              }
              if(u.CompanyName == null){
                  u.CompanyName = AccountNameMap.get(u.AccountId);
              }
              system.debug('-------------2------'+u.AccountId+'-----'+u.AccountId);
                  u.CompanyIdentifier__c = u.AccountId;
              
              if(u.Nimble_Solution_Specialist_NSS__c == True){
                  u.JobRoleIdentifier__c = 'NSS';                  
               }else{                  
                  u.JobRoleIdentifier__c = '';
               }
              if(u.IsPortalEnabled == false){
                  u.CompanyPartnershipGroupIdentifier__c = 'Nimble';
                  list<string> countryCode = u.LocaleSidKey.split('_',3);
                  u.Locationidentifier__c = countryCode[1];
                  u.Locale__c = u.LocaleSidKey.replace('_','-');
                    if(u.ApplicationRoleIdentifier__C != null){
                       u.ApplicationRoleIdentifiertext__C = u.ApplicationRoleIdentifier__C;
                     } else {
                       u.ApplicationRoleIdentifiertext__C = 'MDF Admin';
                     }
                   u.CompanyName = 'Nimble';
                   u.CompanyIdentifier__c = 'Nimble';
                   u.JobRoleIdentifier__c = '';
                   system.debug('--------user---------'+u);
                    }
             lstname.add(u);
            }
        updationuser.isfutureupdate=true;
     //error handling   
     try{  
        update lstname;
     }catch(Exception e){
     }
    }
}