/* Test class for the User Trigger */
@isTest(SeeAllData=true)
public class Test_UserTrigger 
{
    /* Test method to create a portal user to make sure the user trigger fires
     * Update the user as nimble support user to make sure the user update trigger fires */
    static testMethod void createAndUpdatePortalUser()
    {
        User adm = [select Id from User where ProfileId = '00e800000018ois' and Id !=: UserInfo.getUserId() and isActive = true and UserRoleId != null limit 1];
        User ns = [select Id from User where Alias = 'NSForce' and Id !=: UserInfo.getUserId() and isActive = true and UserRoleId != null limit 1];
        String Nimble_Customer_ProfileId = '00e800000018noUAAQ'; 
      //  String Nimble_Customer_RoleId ='00E800000016PEWEA2';
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        Contact c = new Contact(FirstName = 'Test First' , LastName = 'Testlast', AccountId = acc.Id);
        insert c;
        User nimblePortalUser  = new User(Alias = 'standt', Email='portaluser@testorg.com', 
                                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                LocaleSidKey='en_US', ProfileId = Nimble_Customer_ProfileId, 
                                                TimeZoneSidKey='America/Los_Angeles', UserName='portaluser@testorg.com', ContactId = c.Id);
         //Run as other admin user to avoid mixed dml operation error.
        System.runAs(adm)
        {           
           insert nimblePortalUser;
       	}
        //Run as nimble support user while updating the portal user
        System.runAs(ns)
        { 
           nimblePortalUser.Email = 'portaluser1@testorg.com';
           update nimblePortalUser;
       	}
      
    }

}