@isTest(SeeAllData = true)
private class Test_ContactTrigger
{
	/* Test method to verify portal user activation and inactivation
	 * if the contact is activated or inactivated 
	 */
    static testMethod void testPortalUserInactiveandActiveFromContact()
    {
        /*User u = new User();
        u.ProfileId = '00e800000018ois';
        u.IsPortalEnabled = true;
        u.IsActive = true;
        insert u; */
        
        
        //query a active portal user
        List<User> uLst = [select Id, ContactId, Email, Username,FederationIdentifier from User where IsPortalEnabled = true and isActive = true limit 1];
        List<User> admLst = [select Id from User where ProfileId = '00e800000018ois' and Id !=: UserInfo.getUserId() and isActive = true limit 1];
        if(uLst != null && uLst[0].ContactId != null)
        {
            Contact cont = new Contact(Id = uLst[0].ContactId, contactInactive__c = true);            
            //Run as other admin user to avoid mixed dml operation error.
            System.runAs(admLst[0])
            {
                //Test case to inactivate a contact
                Test.startTest();
                update cont;             
                Test.stopTest();
            }
            User resUsr = [select Id, IsActive, Email, Username, FederationIdentifier from User where Id =: uLst[0].Id];
            System.assertEquals(false,resUsr.IsActive);
            /* Modified because no longer the user is appened with inactive */
           // System.assertEquals(true,resUsr.Email.contains('inactive_'));
            System.assertEquals(null,resUsr.FederationIdentifier);
           // System.assertEquals(true,resUsr.Username.contains('inactive_'));
            
          	cont.contactInactive__c = false;            
            update cont;
        }
    }
       //commented the test method as this logic is no longer in place. 
    /*static testMethod void testEmailValidationOnPortalContact()
    {
    
    User u = [select Id, ContactId from User where IsPortalEnabled = true limit 1];
    if(u != null)
    {
        Contact c = new Contact(Id = u.ContactId);
        c.Email = 'contactemail@gmail.com';
        try
        {
            update c;
        }
        catch(Exception e)
        {
            
        }
    }
    }*/

}