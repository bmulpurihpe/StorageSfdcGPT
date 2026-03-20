/**
 * This class contains remote actions of Forecasting page.
 * 30AUG2016: Andy Getz - added Quota__c to query string on line 251 in order to have value carried over after snapshot
 */
 
public class ForecastingService
{
    private static Map<Id, List<Id>> subRoleMapping;
    private static Map<Id, List<User>> forecastingUsers;
    
    //Gets all direct subordinate users of specified user
    @Readonly @RemoteAction
    public static List<ForecastingDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId)
    {
        List<ForecastingDataModel.UserInfo> result = new List<ForecastingDataModel.UserInfo>();
        List<Id> roleIds = new List<Id>();
        if(userOrRoleId == null)
        {
            roleIds = getSubRoles(null, false);
        }
        else if(userOrRoleId.getSObjectType() == Schema.User.SObjectType)
        {
            List<User> users = [select Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c from User where Id=:userOrRoleId limit 1];
            if(users.size() > 0)
            {
                roleIds.add(users[0].UserRoleId);
            }
        }
        else if(userOrRoleId.getSObjectType() == Schema.UserRole.SObjectType)
        {
            roleIds.add(userOrRoleId);
        }
        if(roleIds.size() > 0)
        {
            for(Id roleId : roleIds)
            {
                List<Id> subRoles = getSubRoles(roleId, false);
                for(Id rid : subRoles)
                {
                    List<ForecastingDataModel.UserInfo> users = getUsersByRole(rid, true);
                    if(users.size() > 0)
                    {
                        result.addAll(users);
                    }
                    else
                    {
                        result.addAll(GetDirectSubordinateUsers(rid));
                    }
                }
            }
        }
        return result;
    }

    //Gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<ForecastingDataModel.UserInfo> GetAllSubordinateUsers(String userId)
    {
        List<ForecastingDataModel.UserInfo> result = new List<ForecastingDataModel.UserInfo>();
        List<User> users = [select Id, Name, UserRoleId from User where Id = :userId limit 1];
        if(users.size() > 0)
        {
            List<String> subRoles = getSubRoles(users[0].UserRoleId, true);
            for(User usr : [select Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c from User where UserRoleId in :subRoles])
            {
                result.add(new ForecastingDataModel.UserInfo(usr));
            }
        }
        return result;
    }

    public static List<Id> GetAllSubordinateUserIds(String userId)
    {
        List<Id> result = new List<Id>();
        List<ForecastingDataModel.UserInfo> users = GetAllSubordinateUsers(userId);
        for(ForecastingDataModel.UserInfo user : users)
        {
            result.add(user.UserId);
        }
        return result;
    }

    public static List<Id> GetDirectSubordinateUserIds(String userId)
    {
        List<Id> result = new List<Id>();
        List<ForecastingDataModel.UserInfo> users = GetDirectSubordinateUsers(userId);
        for(ForecastingDataModel.UserInfo user : users)
        {
            result.add(user.UserId);
        }
        return result;
    }

    public static Set<Id> GetParentRoleUserIds(String userId)
    {
        Set<Id> result = new Set<Id>();
        List<User> users = [select UserRoleId from User where Id = :userId limit 1];
        if(users.size() > 0 && users[0].UserRoleId != null)
        {

            result = getParentRoleUserIdsByRole(users[0].UserRoleId);
        }
        return result;
    }

    private static Set<Id> getParentRoleUserIdsByRole(String roleId)
    {
        Set<Id> result = new Set<Id>();
        List<UserRole> userRoles = [select Id, ParentRoleId from UserRole where Id = :roleId and PortalType = 'None'];
        if(userRoles.size() > 0 && userRoles[0].ParentRoleId != null)
        {
            String parentRoleId = userRoles[0].ParentRoleId;
            result = (new Map<Id, User>([select Id from User where UserRoleId = :parentRoleId and ForecastEnabled__c = true])).keySet(); 
            if(result.isEmpty())
            {
                result = getParentRoleUserIdsByRole(parentRoleId);
            }
        }
        return result;
    }
    
    public static List<Id> getSubRoles(Id roleId, Boolean traverseAll)
    {
        List<Id> result = new List<Id>();
        subRoleMapping = getSubRoleMapping();
        List<Id> directRoles = subRoleMapping.get(roleId);
        if(directRoles != null)
        {
            result.addAll(directRoles);
            if(traverseAll)
            {
                for(Id rid : directRoles)
                {
                    result.addAll(getSubRoles(rid, true));
                }
            }
        }
        return result;
    }
    
    static Map<Id, List<Id>> getSubRoleMapping()
    {
        if(subRoleMapping == null)
        {
            subRoleMapping = new Map<Id, List<Id>>();
            for(UserRole role : [select Id, Name, ParentRoleId from UserRole where PortalType = 'None'])
            {
                if(!subRoleMapping.containsKey(role.ParentRoleId))
                {
                    subRoleMapping.put(role.ParentRoleId, new List<Id> {role.Id});
                }
                else
                {
                    subRoleMapping.get(role.ParentRoleId).add(role.Id);
                }
            }
        }
        return subRoleMapping;
    }
    
    private static List<ForecastingDataModel.UserInfo> getUsersByRole(Id roleId, Boolean forecastOnly)
    {
        List<ForecastingDataModel.UserInfo> result = new List<ForecastingDataModel.UserInfo>();
        List<User> users = new List<User>();
        if(!forecastOnly)
        {
            users = [select Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c from User where UserRoleId = :roleId];
            
        }
        else
        {
            if(forecastingUsers == null)
            {
                forecastingUsers = new Map<Id, List<User>>();
                for(User usr : [select Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c from User where ForecastEnabled__c = true])
                {
                    if(forecastingUsers.containsKey(usr.UserRoleId))
                    {
                        forecastingUsers.get(usr.UserRoleId).add(usr);
                    }
                    else
                    {
                        forecastingUsers.put(usr.UserRoleId, new List<User> { usr });
                    }
                }
            }
            users = forecastingUsers.get(roleId);
            users = (users == null) ? new List<User>() : users;
        }
        for(User usr : users)
        {
            result.add(new ForecastingDataModel.UserInfo(usr));
        }
        return result;
    }

    public static ForecastingDataModel.UserInfo GetUser(String userId)
    {
        List<User> users = [select Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c from User where Id = :userId limit 1];
        if(users.size() > 0)
        {
            return new ForecastingDataModel.UserInfo(users[0]);
        }
        else
        {
            return null;
        }
    }
    
    public static Date GetStartOfCurrentFiscalYear()
    {
        List<Period> periods = [select StartDate from Period where Type = 'Year' and StartDate <= Today and EndDate >= Today limit 1];
        if(periods.size() > 0)
        {
            return periods[0].StartDate;
        }
        return null;
    }
    
    public static void initForecast(Id userId)
    {
        List<User> users = [select Id, IsActive from User where Id=:userId and ForecastEnabled__c=true and IsActive=true];
        if(users.size() > 0)
        {
            String[] quarterWeek = getLatestForecastWeek();
            String fyfq = quarterWeek[0];
            String yyww = quarterWeek[1];
            List<CustomForecast__c> currentForecasts = getForecasts(userId, fyfq, yyww);
            if(currentForecasts.size() == 0)
            {
                submitForecasts(getForecasts(userId, null, null, false, null));
                insertNewForecast(userId, fyfq, yyww);
            }
            else
            {
                ForecastingService.deleteDuplicate(currentForecasts);
            }
        }
        else
        {
            submitForecasts(getForecasts(userId, null, null, false, null));
        }
    }
    
    public static List<CustomForecast__c> getForecasts(Id userId, String fyfq, String yyww)
    {
        return getForecasts(userId, fyfq, yyww, null, null);
    }
    
    public static List<CustomForecast__c> getForecasts(Id userId, String fyfq, String yyww, Boolean locked, Integer limitNumber)
    {
        String soql = 'select Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById, User__c, LastEdited__c, Locked__c, FYFQ__c, YYWW__c, FollowingWeekCommit__c, Month1Commit__c, Month2Commit__c, Month3Commit__c, QuarterCommit__c, QuarterGut__c, QuarterUpside__c, UpcomingWeekCommit__c, Quota__c from CustomForecast__c where ';
        if(userId != null)
        {
            soql += ' User__c=:userId and ';
        }
        if(fyfq != null)
        {
            soql += ' FYFQ__c=:fyfq and ';
        }
        if(yyww != null)
        {
            soql += ' YYWW__c=:yyww and ';
        }
        if(locked != null)
        {
            soql += ' Locked__c=:locked ';
        }
        soql = soql.removeEnd(' and ').removeEnd(' where ');
        soql += ' order by CreatedDate desc';
        if(limitNumber != null)
        {
            soql += ' limit ' + limitNumber;
        }
        return Database.query(soql);
    }
    
    public static String[] getLatestForecastWeek()
    {
        ForecastingDataModel.FiscalQuarterInfo currentQtr = new ForecastingDataModel.FiscalQuarterInfo();
        String fyfq = currentQtr.FormattedString;
        ForecastingDataModel.WeekInfo currentWeek = currentQtr.getWeek(toStartOfWeek(Date.today()));
        String yyww = currentWeek != null ? currentWeek.FormattedString : (new ForecastingDataModel.WeekInfo()).FormattedString;
        List<CustomForecast__c> latestForecast = [select Id, FYFQ__c, YYWW__c, Locked__c from CustomForecast__c where FYFQ__c!=null and YYWW__c != null and User__r.IsActive=true and User__r.ForecastEnabled__c=true order by FYFQ__c desc, YYWW__c desc limit 1];
        if(latestForecast.size() > 0)
        {
            fyfq = latestForecast[0].FYFQ__c;
            yyww = latestForecast[0].YYWW__c;
            if(latestForecast[0].Locked__c == true)
            {
                return getNextForecastWeek();
            }
        }
        return new String[] {fyfq, yyww};
    }
    
    public static String[] getNextForecastWeek()
    {
        Date nextWeekStartDay = toStartOfWeek(Date.today().addDays(7));
        ForecastingDataModel.FiscalQuarterInfo quarter = new ForecastingDataModel.FiscalQuarterInfo();
        ForecastingDataModel.WeekInfo nextWeek = quarter.getWeek(nextWeekStartDay);
        if(nextWeek == null)
        {
            quarter = quarter.next;
            nextWeek = quarter.getWeek(nextWeekStartDay);
        }
        String fyfq = quarter.FormattedString;
        String yyww = nextWeek.FormattedString;
        return new String[] {fyfq, yyww};
    }
    
    public static void submitForecasts(List<CustomForecast__c> forecasts)
    {
        if(forecasts != null && forecasts.size() > 0)
        {
            for(CustomForecast__c f : forecasts)
            {
                f.Locked__c = true;
                f.LastEdited__c = DateTime.now();
                f.SubmittedOn__c = DateTime.now();
            }
            update forecasts;
        }
    }
    
    public static Date toStartOfWeek(Date d)
    {
        //always return sunday
        if(d != null)
        {
            Integer days = Date.newInstance(2010, 1, 3).daysBetween(d);
            Integer weekOfDay = Math.mod(days, 7);
            return d.addDays(-weekOfDay);
        }
        return d;
    }
    
    
    private static void insertNewForecast(Id userId, String fyfq, String yyww)
    {
        List<CustomForecast__c> forecasts = getForecasts(userId, fyfq, null, null, 1);
        if(forecasts.size() == 0)
        {
            insert new CustomForecast__c(User__c=userId, FYFQ__c=fyfq, YYWW__c=yyww);
        }
        else
        {
            CustomForecast__c forecast = forecasts[0].clone(false, false, false, false);
            forecast.FYFQ__c = fyfq;
            forecast.YYWW__c = yyww;
            forecast.Locked__c = false;
            forecast.LastEdited__c = DateTime.now();
            forecast.SubmittedOn__c = null;
            insert forecast;
        }
    }
    
    private static void deleteDuplicate(List<CustomForecast__c> forecasts)
    {
        if(forecasts != null && forecasts.size() > 1)
        {
            //sort by createddate desc
            for(Integer i = 0; i < forecasts.size(); i++)
            {
                for(Integer j = i + 1; j < forecasts.size(); j++)
                {
                    if(forecasts[i].CreatedDate < forecasts[j].CreatedDate)
                    {
                        CustomForecast__c t = forecasts[j];
                        forecasts.set(j, forecasts[i]);
                        forecasts.set(i, t);
                    }
                }
            }
            Set<String> keys = new Set<String>();
            List<CustomForecast__c> toBeRemoved = new List<CustomForecast__c>();
            for(Integer i = 0; i < forecasts.size(); i++)
            {
                String key = forecasts[i].User__c + forecasts[i].FYFQ__c + forecasts[i].YYWW__c;
                if(keys.contains(key))
                {
                    toBeRemoved.add(forecasts[i]);
                }
                else
                {
                    keys.add(key);
                }
            }
            if(toBeRemoved.size() > 0)
            {
                delete toBeRemoved;
            }
        }
    }
}