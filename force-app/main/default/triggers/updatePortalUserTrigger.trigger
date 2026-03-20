trigger updatePortalUserTrigger on User (before update) {
     
     string current_user = UserInfo.getUserId();
     User current_u = [SELECT Email, Alias, Name from User where Id = :current_user];

     if (current_u.Alias == 'NSForce') {
    
        User[] user = Trigger.new;
    
        for(User u : user) {
            //if Nimble Customer Portal Profile
            if (u.ProfileId == '00e800000018noUAAQ') {
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.EmailHeader.triggerUserEmail = false;
                // SIRIANNI: Portal sets the FederationIdentifier
                // u.federationidentifier=u.Email;
                u.setOptions(dmo);
            }
        }
    }
}