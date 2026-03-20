public class ContactObjectUtil 
{
    /* future method to inactivate a portal user
     */
    @future
    public static void inactivateUser(Id  usrId, String fedIdentifier, string email, String username)
    {
        User usr = new User(Id = usrId);
        usr.isActive = false;       
        // SIRIANNI: Set FederationIdentifier to NULL instead of 'inactive_' prefix
        // 'inactive_' prefix can still cause duplicate ID conflict wheras NULL cannot
        usr.FederationIdentifier = null;
        update usr;
    }
    
      /* future method to activate a portal user
     */
    @future
    public static void activateUser(Id  usrId, String fedIdentifier, string email, String username)
    {
        User usr = new User(Id = usrId);
        usr.isActive = true;
        // SIRIANNI: Portal sets the FederationIdentifier upon activate
        // usr.FederationIdentifier = email;
        update usr;
    }
    
    /* Method to get the user records associated with the portal contacts */
    public static List<User> getUsersforContacts(Set<Id> contIds)
    {
        List<User> usrList = [select Id, ContactId, Email, username, FederationIdentifier from User where ContactId in :contIds];
        return usrList;
    }
}