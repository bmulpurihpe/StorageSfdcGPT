@isTest
public class TestDataFactory 
{
    public static List<User> createTestUsers()
    {
        List<User> testUsers = new List<User>();
        String profileId = UserInfo.getProfileId();
        String orgId = userInfo.getOrganizationId();        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        User runningUser = new User(Alias = uniqueName.substring(18, 23),
                                    Email = 'uniqueName@testorg.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'Running User', 
                                    LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US', 
                                    ProfileId = profileId,
                                    Country = 'United States',
                                    TimezoneSidKey = 'America/Los_Angeles', 
                                    Username = 'uniqueName@testorg.com',
                                    TrainingDivision__c = 'Field Sales',
                                    TrainingEnabled__c = true,
                                    IsActive = true);
        testUsers.add(runningUser);
        List<UserRole> rootRoles = [select Id from UserRole where ParentRoleId = null and PortalType = 'None' limit 1];
        if(rootRoles.size() > 0)
        {
            randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            uniqueName = orgId + randomInt;
            runningUser.UserRoleId = rootRoles[0].Id;
            List<UserRole> childRoles = [select Id from UserRole where ParentRoleId = :rootRoles[0].Id and PortalType = 'None' limit 1];
            if(childRoles.size() > 0)
            {
                User childUser = new User(Alias = uniqueName.substring(18, 23),
                                        Email = 'uniqueName@testorg.com',
                                        EmailEncodingKey = 'UTF-8',
                                        LastName = 'Running User', 
                                        LanguageLocaleKey = 'en_US',
                                        LocaleSidKey = 'en_US', 
                                        ProfileId = profileId, 
                                        Country = 'United States',
                                        TimezoneSidKey = 'America/Los_Angeles', 
                                        Username = 'uniqueName@testorg.com',
                                        TrainingDivision__c = 'Field Sales',
                                        TrainingEnabled__c = true,
                                        UserRoleId = childRoles[0].Id,
                                        IsActive = true);

                testUsers.add(childUser);
            }
        }
        //insert testUsers;
        return testUsers;
    }

    public static User updateCurrentUser()
    {
        User currentUser = [select Id, UserRoleId, TrainingDivision__c, TrainingEnabled__c from User where Id = :UserInfo.getUserId()];
        Boolean updateUser = false;
        if(currentUser.UserRoleId == null)
        {
            List<UserRole> rootRoles = [select Id from UserRole where ParentRoleId = null and PortalType = 'None' limit 1];
            if(rootRoles.size() > 0)
            {
                currentUser.UserRoleId = rootRoles[0].Id;
                updateUser = true;
            }
        }
        if(currentUser.TrainingDivision__c == null)
        {
            currentUser.TrainingDivision__c = 'Field Sales';
            updateUser = true;
        }
        if(!currentUser.TrainingEnabled__c)
        {
            currentUser.TrainingEnabled__c = true;
            updateUser = true;
        }

        if(updateUser)
        {
            Database.update(currentUser, false);
        }
        return currentUser;
    }
}