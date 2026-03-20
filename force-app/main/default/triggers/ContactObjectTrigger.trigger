/* Purpose: Trigger on contact, to activate/inactivate portal users
*          based on the contact activation/inactivation.
* Change Log: Pradeep Aitha
*/ 
trigger ContactObjectTrigger on Contact (before insert, before update, after insert, after update) {   
    
    Boolean isContCreatedByGSEMAPIUser = false;
    TriggerSettings__c settings = TriggerSettings__c.getInstance('DceSyncUpdate');
    String GSEMAPIUser = Label.GSEMAPI_USER;
    String DCEIntAPIUser =Label.DCEIntegration_APIUser;
    String GLCPIntAPIUser=Label.GLCP_Integration_API_User;
    if(UserInfo.getUserId() != DCEIntAPIUser && UserInfo.getUserId() != GSEMAPIUser  && UserInfo.getUserId() !=GLCPIntAPIUser){
            if(settings !=null){
                if(!settings.Disable__c ){
                    if(Trigger.isAfter && Trigger.isInsert){
                        set<Id> conIdS=new set<Id>();
                        
                        String uidOfCreator;
                        String uidOfGSEMAPIUser;
                        
                        For(contact con: trigger.new){
                            
                            uidOfCreator = (String) con.CreatedById;
                            uidOfGSEMAPIUser = (String) System.Label.GSEMAPI_USER;
                            
                            System.debug('uidOfCreator: ' + uidOfCreator);
                            System.debug('uidOfCreator: ' + uidOfGSEMAPIUser);                    
                            System.debug('uidOfCreator.contains(uidOfGSEMAPIUser) ' + uidOfCreator.contains(uidOfGSEMAPIUser));
                            
                            isContCreatedByGSEMAPIUser = uidOfCreator.contains(uidOfGSEMAPIUser);
                            
                            if(!isContCreatedByGSEMAPIUser){
                                
                                conIdS.add(con.id);
                            }
                        }
                        system.debug('===calling ===');
                        if (!TriggerHelper.isExecutingContactTrigger()) {
                        if(!Test.isRunningTest() && conIdS.size() > 0){ // changed by Larry 07-07-2023 to fix bug temporarily, needs discussion
                            DCEContactAPICall.requestDCEContactInfo(conIdS);
                        }
                        }
                    }
                           
                if(Trigger.isAfter && Trigger.isUpdate){
                    set<Id> conIdS=new set<Id>();
                    
                    String uidOfCreator;
                    String uidOfGSEMAPIUser;
    
                    For(contact con: trigger.new){
                        
                        uidOfCreator = (String) con.CreatedById;
                        uidOfGSEMAPIUser = (String) System.Label.GSEMAPI_USER;
                        
                        isContCreatedByGSEMAPIUser = uidOfCreator.contains(uidOfGSEMAPIUser);
                        
                        if(!isContCreatedByGSEMAPIUser){
                            
                            conIdS.add(con.id);
                        }
                    }
                    if(!Test.isRunningTest() && conIdS.size() > 0){ // changed by Larry 07-07-2023 to fix bug temporarily, needs discussion
                        DceSyncController.contactUpdateDceSync(trigger.new, trigger.oldMap);  
                    }
                }
            }
        }
    }
    // SFDC-1277 used to track Contact fields Last modified date -- Padmaja 
    if(Trigger.isBefore && Trigger.isInsert){
        DCEContactInfoSyncController.contactInfoLastUpdateSync(trigger.new, null);
     }
      if(Trigger.isBefore && Trigger.IsUpdate){
         DCEContactInfoSyncController.contactInfoLastUpdateSync(trigger.new, trigger.oldMap);
       }   
	
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        Set<Id> inactiveContIds = new Set<Id>();
        Set<Id> activeContIds = new Set<Id>();
        for(Integer i = 0; i<Trigger.new.size(); i++)
        {
            Contact newC = Trigger.new.get(i);
            Contact oldC = Trigger.old.get(i);
            //only if the inactive check box is set to true.
            if(newC.contactInactive__c != oldC.contactInactive__c && newC.contactInactive__c)
            {
                inactiveContIds.add(newC.Id);                
            }
            //only if the inactive check box is set to false.
            else if(newC.contactInactive__c != oldC.contactInactive__c && !newC.contactInactive__c)
            {
                activeContIds.add(newC.Id);
            }
        }
        //get the user records associated with the inactive contacts
        List<User> usrs = ContactObjectUtil.getUsersforContacts(inactiveContIds);
        for(User usr : usrs)
        {
            //Inactivate users
            //future method is called because MIXED DML OPERATION i.e.., update on user object cannot happen in 
            //same transaction with the standard object Contact. 
            ContactObjectUtil.inactivateUser(usr.Id, usr.FederationIdentifier, usr.Email, usr.username);
        }
        //get the user records associated with the active contacts
        usrs = ContactObjectUtil.getUsersforContacts(activeContIds);
        for(User usr : usrs)
        {
            //Activate users
            //future method is called because MIXED DML OPERATION i.e.., update on user object cannot happen in 
            //same transaction with the standard object Contact. 
            ContactObjectUtil.activateUser(usr.Id, usr.FederationIdentifier, usr.Email, usr.username);
        }
    }
    
}