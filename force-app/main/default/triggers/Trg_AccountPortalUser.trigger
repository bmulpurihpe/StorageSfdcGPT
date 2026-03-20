trigger Trg_AccountPortalUser on Account (After Insert, After Update) {
    
   if(updationuser.isfutureupdate!=true)
   {  
   Set<id> UidsToProcess=new Set<id>();
   Set<id> AidsToProcess=new Set<id>();

    for(account a:trigger.new)
    {	//Perks application for Resellers
        //if(a.Type == 'Reseller' || a.Type == 'Sub Distributor'){
    		AidsToProcess.add(a.id);
    	//}
    }

    list<user> lstusr = [select id, pilot_user__c from user where accountid in :AidsToProcess];

    for ( user u : lstusr){	
        if(u.pilot_user__c == True){
     	UidsToProcess.add(u.id);
        }
     }
	//Improper Naming
    portalUserCls.proccedUser(UidsToProcess,AidsToProcess);
   
   
   }    
}