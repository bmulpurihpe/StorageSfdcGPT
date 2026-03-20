trigger createPortalUserTrigger on User (after insert) {

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