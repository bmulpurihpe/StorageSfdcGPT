/**
 * The controller of ForecastUpdateNotification page component.
 */

global without sharing class ForecastUpdateNotificationController
{
    global ForecastUpdateNotificationController() { }

    global String UserId { get; set; }
    global String editedById { get; set; }
    
    private Forecast oldForecasting;
    private Forecast newForecasting;
    private String forecastId;
    private DateTime scheduledEmailTimeStamp;
	private static Map<Id, List<Id>> subRoleMapping; // For user roles cache

    global User User
    {
        get
        {
            return [select Id, Name from User where Id = :UserId];
        }
    }

    global String ForecastURL 
    {
        get
        {
            return Url.getSalesforceBaseUrl().toExternalForm() + '/apex/Forecasting';
        }
    }

    global String RepForecastURL 
    {
        get
        {
            return ForecastURL + '?path=/' + UserId;
        }
    }

    global Forecast NewForecast
    {
        get
        {
            if(newForecasting == null)
            {
                newForecasting = new Forecast();
                List<CustomForecast__c> forecasts = [select Id, QuarterCommit__c, QuarterGut__c, QuarterUpside__c, Month1Commit__c, Month2Commit__c, Month3Commit__c, FollowingWeekCommit__c, UpcomingWeekCommit__c, ScheduledEmailTimeStamp__c, Quota__c, C9_Projection__c, FYFQ__c from CustomForecast__c where User__c = :UserId and Locked__c = false order by LastModifiedDate desc limit 1];
                if(!forecasts.isEmpty())
                {
                    newForecasting = new Forecast(forecasts[0]);
                    newForecasting.Booking = caculateBooking(forecasts[0].FYFQ__c, UserId);
                    forecastId = forecasts[0].Id;
                    scheduledEmailTimestamp = (forecasts[0].ScheduledEmailTimestamp__c == null) ? DateTime.now().addMinutes(-5) : forecasts[0].ScheduledEmailTimestamp__c;
                }
            }
            return newForecasting;
        }
    }
    
    //adding code to return last modified by user
    global User editByUser
    {
        get
        {
            List<CustomForecast__c> forecasteditby = [select LastModifiedById from CustomForecast__c where User__c = :UserId and Locked__c = false order by LastModifiedDate desc limit 1];
            if(!forecasteditby.isEmpty())
            {
                editedById = forecasteditby[0].LastModifiedById;
            }
            return [select Id, Name from User where Id = :editedById];
        }
    }
    
    global Forecast OldForecast
    {
        get
        {
            if(oldForecasting == null)
            {
                oldForecasting = NewForecast.clone();
                Decimal oldValue;
                for(CustomForecast__History history : [select Field, OldValue from CustomForecast__History where ParentId = :forecastId and CreatedDate >= :scheduledEmailTimestamp order by CreatedDate desc])
                {
                    oldValue = (history.OldValue == null) ? null : Decimal.valueOf((String)history.oldValue);
                    if(history.Field == 'QuarterCommit__c')
                    {
                        oldForecasting.QuarterCommit = oldValue;
                    }
                    else if(history.Field == 'QuarterGut__c')
                    {
                        oldForecasting.QuarterGut = oldValue;
                    }
                    else if(history.Field == 'QuarterUpside__c')
                    {
                        oldForecasting.QuarterUpside = oldValue;
                    }
                    else if(history.Field == 'Month1Commit__c')
                    {
                        oldForecasting.Month1Commit = oldValue;
                    }
                    else if(history.Field == 'Month2Commit__c')
                    {
                        oldForecasting.Month2Commit = oldValue;
                    }
                    else if(history.Field == 'Month3Commit__c')
                    {
                        oldForecasting.Month3Commit = oldValue;
                    }
                    else if(history.Field == 'UpcomingWeekCommit__c')
                    {
                        oldForecasting.UpcomingWeekCommit = oldValue;
                    }
                    else if(history.Field == 'FollowingWeekCommit__c')
                    {
                        oldForecasting.FollowingWeekCommit = oldValue;
                    }
                    else if(history.Field == 'Quota__c')
                    {
                        oldForecasting.Quota = oldValue;
                    }
                    else if(history.Field == 'C9_Projection__c')
                    {
                        oldForecasting.C9Projection = oldValue;
                    }
                    else if(history.Field == 'FYFQ__c')
                    {
                        oldForecasting.Booking = caculateBooking(String.valueOf( history.OldValue ), UserId);
                    }
                }
            }
            return oldForecasting;
        }
    }
    
    global Forecast Variance
    {
        get
        {
            Forecast result = new Forecast();
            result.QuarterCommit = getVariance(NewForecast.QuarterCommit, OldForecast.QuarterCommit);
            result.QuarterGut = getVariance(NewForecast.QuarterGut, OldForecast.QuarterGut);
            result.QuarterUpside = getVariance(NewForecast.QuarterUpside, OldForecast.QuarterUpside);
            result.Month1Commit = getVariance(NewForecast.Month1Commit, OldForecast.Month1Commit);
            result.Month2Commit = getVariance(NewForecast.Month2Commit, OldForecast.Month2Commit);
            result.Month3Commit = getVariance(NewForecast.Month3Commit, OldForecast.Month3Commit);
            result.UpcomingWeekCommit = getVariance(NewForecast.UpcomingWeekCommit, OldForecast.UpcomingWeekCommit);
            result.FollowingWeekCommit = getVariance(NewForecast.FollowingWeekCommit, OldForecast.FollowingWeekCommit);
            result.Quota = getVariance(NewForecast.Quota, OldForecast.Quota);
            result.C9Projection = getVariance(NewForecast.C9Projection, OldForecast.C9Projection);
            result.Booking = getVariance(NewForecast.Booking, OldForecast.Booking);
            return result;
        }
    }

    static Decimal getVariance(Decimal newValue, Decimal oldValue)
    {
        Decimal variance;
        if(newValue != null || oldValue != null)
        {
            newValue = (newValue == null) ? 0 : newValue;
            oldValue = (oldValue == null) ? 0 : oldValue;
            variance = newValue - oldValue;
        }
        return variance;
    }
    //For forecast Bookings value caculation, includes get FiscalQuarter and sub-users.
    static Decimal caculateBooking(String fyfq, Id uid)
    {
        Decimal result = 0;
        System.debug(fyfq+', '+uid);
        if(String.isNotBlank(fyfq) && String.isNotBlank(uid))
        {
        list<Id> subUsers = new List<Id>();
        subUsers.add(uid);
        List<User> users = [select Id, Name, UserRoleId from User where Id = :uid limit 1];
        if(users.size() > 0)
        {
            List<String> subRoles = getSubRoles(users[0].UserRoleId, true);
            for(User usr : [select Id, Name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c from User where UserRoleId in :subRoles])
            {
                subUsers.add(usr.Id);
            }
            System.debug('Sub user '+subUsers);
        }
        FiscalQuarter qtr = new FiscalQuarter(fyfq);
            System.debug('Qtr '+qtr);
        List<AggregateResult> wonOppAr = [select SUM(Amount) amt from Opportunity where CloseDate <= :qtr.EndDate and CloseDate >= :qtr.StartDate and OwnerId in :subUsers and IsWon = true];
        result = wonOppAr[0].get('amt') == null ? 0 : (Decimal)wonOppAR[0].get('amt');
        System.debug('Booking--actual '+result);
        }
        System.debug('Booking '+result);
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
    
    global class FiscalQuarter
    {
        global Date StartDate { get; set; }
        global Date EndDate { get; set; }
        
        global FiscalQuarter() {
            this.StartDate = Date.today();
            this.EndDate = Date.today();
        }
        global FiscalQuarter(String text)
        {
            FiscalQuarter qtr = new FiscalQuarter();
            if(String.isBlank(text) || text.length() != 6 || !Pattern.matches('\\d\\d\\d\\d[Qq]\\d', text))
            {
                throw new ForecastingException('Incorrrect format of fiscal quarter [' + text + ']');
            }
            String[] textParts = text.split('[Qq]');
            Integer Year = Integer.valueOf(textParts[0]);
            Integer Quarter = Integer.valueOf(textParts[1]);
            
            List<FiscalyearSettings> fiscalYears = [select Id, IsStandardYear, StartDate, EndDate from FiscalYearSettings where Name=:textParts[0] limit 1];
            if(fiscalYears.size() > 0)
            {
                this.StartDate = fiscalYears[0].StartDate;
                this.EndDate = fiscalYears[0].EndDate;
                if(fiscalYears[0].IsStandardYear)
                {
                    this.StartDate = fiscalYears[0].StartDate.addMonths((Quarter - 1) * 3);
                    this.EndDate = qtr.StartDate.addMonths(3).addDays(-1);
                }
                else
                {
                    List<Period> periods = [SELECT Type, Number, StartDate, EndDate FROM Period WHERE Type = 'Quarter' AND Number = :Quarter AND FiscalYearSettings.Name = :textParts[0] LIMIT 1];
                    if(periods.size() > 0)
                    {
                        this.StartDate = periods[0].StartDate;
                        this.EndDate = periods[0].EndDate;
                    }
                }
            }
        }
    }

    global class Forecast 
    {
        global Decimal QuarterCommit { get; set; }
        global Decimal QuarterGut { get; set; }
        global Decimal QuarterUpside { get; set; }
        global Decimal Month1Commit { get; set; }
        global Decimal Month2Commit { get; set; }
        global Decimal Month3Commit { get; set; }
        global Decimal UpcomingWeekCommit { get; set; }
        global Decimal FollowingWeekCommit { get; set; }
        global Decimal Quota { get; set; }
        global Decimal Booking { get; set; }
        global Decimal C9Projection { get; set; }

        global Forecast() { }

        global Forecast(CustomForecast__c cf)
        {System.debug('Forecast -- '+cf);
            this.QuarterCommit = cf.QuarterCommit__c;
            this.QuarterGut = cf.QuarterGut__c;
            this.QuarterUpside = cf.QuarterUpside__c;
            this.Month1Commit = cf.Month1Commit__c;
            this.Month2Commit = cf.Month2Commit__c;
            this.Month3Commit = cf.Month3Commit__c;
            this.UpcomingWeekCommit = cf.UpcomingWeekCommit__c;
            this.FollowingWeekCommit = cf.FollowingWeekCommit__c;
            this.Quota = cf.Quota__c;
            this.C9Projection = cf.C9_Projection__c;
            this.Booking = 0;
        }
    }
}