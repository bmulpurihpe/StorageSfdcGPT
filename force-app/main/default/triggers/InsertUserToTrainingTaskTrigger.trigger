trigger InsertUserToTrainingTaskTrigger on User (after insert, after update) 
{
    // Merged user trigger createPortalUserTrigger    
    if(Trigger.isAfter && Trigger.isInsert) {
        User[] user = Trigger.new;
         for(User u : user) {
              User newuser = [SELECT Username, Email, ProfileId from User where Id = :u.Id];
              if (newuser.ProfileId == '00e800000018noUAAQ') {
                  Database.DMLOptions dmo = new Database.DMLOptions();
                  dmo.EmailHeader.triggerUserEmail = false;
                  // SIRIANNI: Portal sets the FederationIdentifier
                  // newuser.federationidentifier=newuser.Email;
                  newuser.setOptions(dmo);
                  update newuser;
             }
         }
    }
    
    
    List<String> userIds = new List<String>();
    for(User u : Trigger.new)
    {
        if(u.TrainingEnabled__c)
        {
            userIds.add(u.Id);
        }
    }
    if(userIds.size() > 0)
    {
        List<PermissionSet> permissionSets = [select Id from PermissionSet where Name = 'Training_Tab_Access'];
        if(permissionSets.size() > 0)
        {
            String trainingPermission = permissionSets[0].Id;
            List<PermissionSetAssignment> assignments = [select AssigneeId from PermissionSetAssignment where AssigneeId in :userIds and PermissionSetId = :trainingPermission];
            Set<String> assignedUsers = new Set<String>();
            for(PermissionSetAssignment assignment : assignments)
            {
                assignedUsers.add(assignment.AssigneeId);
            }
            List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
            for(String userId : userIds)
            {
                if(!assignedUsers.contains(userId))
                {
                    newAssignments.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permissionSets[0].Id));
                }                
            }
            if(newAssignments.size() > 0)
            {
                insert newAssignments;
            }            
        }        
    }
    if(Trigger.isInsert)
    {   
        InsertUserToTrainingTaskTriggerHandler.insertTrainingTask(Trigger.new);            
    }
    else if (Trigger.isUpdate)
    {
        InsertUserToTrainingTaskTriggerHandler.updateTrainingTask(Trigger.oldMap, Trigger.newMap);      
    }
    
    //Moved from another trigger on user Trg_PortalUser
    if(Test.isRunningTest()){
        updationuser.isfutureupdate = false ;
    }
   if(updationuser.isfutureupdate!=true)
   {  
       Set<id> UidsToProcess=new Set<id>();
       Set<id> AidsToProcess=new Set<id>();
       Set<id> InternalUserIds=new Set<id>();
       list<user> InternalUsersList=new list<user>();

       for(user u:trigger.new){
            //Allow the trigger logic for pilot users
            if(u.pilot_user__c == True ){
                UidsToProcess.add(u.id);
                AidsToProcess.add(u.accountid);
            }
       }
       
       //Improper Naming
      portalUserCls.proccedUser(UidsToProcess,AidsToProcess);
   } 
}