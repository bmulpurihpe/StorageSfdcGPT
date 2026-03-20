/**
 * This class is the controller of page Forecasting.
 */
 
public with sharing class ForecastingController 
{
    public ForecastingController()
    {
        //Set Fiscal Quarter
        String q = ApexPages.currentPage().getParameters().get('quarter');
        if(String.isNotBlank(q))
        {
            CurrentFiscalQuarter = new ForecastingDataModel.FiscalQuarterInfo(q);
        }
        else
        {
            CurrentFiscalQuarter = new ForecastingDataModel.FiscalQuarterInfo();
        }
        
        //Set User Nav Path
        String p = ApexPages.currentPage().getParameters().get('path');
        UserNavPath = GetUserNavPath(p);
        if(UserNavPath.size() > 0)
        {
            CurrentViewingUser = ForecastingService.GetUser(UserNavPath[UserNavPath.size() - 1].UserId);
        }
        else
        {
            ForecastingDataModel.UserInfo user = ForecastingService.GetUser(UserInfo.getUserId());
            CurrentViewingUser = (user.ForecastEnabled) ? user : user.ViewForecastAs;
            UserNavPath.add(CurrentViewingUser);
        }

        CurrentWeek = new ForecastingDataModel.WeekInfo();
    }
    
    public ForecastingDataModel.FiscalQuarterInfo CurrentFiscalQuarter { get; private set; }
    public ForecastingDataModel.WeekInfo CurrentWeek { get; private set; }
    public ForecastingDataModel.UserInfo CurrentViewingUser { get; private set; }
    public List<ForecastingDataModel.UserInfo> UserNavPath { get; set; }
    public String UserPath
    {
        get
        {
            String result = '';
            for(ForecastingDataModel.UserInfo usr : UserNavPath)
            {
                if(usr != null)
                {
                    result += '/' + usr.UserId;
                }
            }
            return result;
        }
    }
    
    public List<String> SalesRegions
    {
        get
        {
        	List<String> options = new List<String>();
            Schema.DescribeFieldResult fieldResult = Opportunity.Sales_Region__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : ple)
            {
                options.add(f.getValue());
            }       
            return options;    
        }
    }
    
    public static List<ForecastingDataModel.UserInfo> GetUserNavPath(String path)
    {
        List<ForecastingDataModel.UserInfo> result = new List<ForecastingDataModel.UserInfo>();
        if(isValidPath(path))
        {
            ForecastingDataModel.UserInfo usr;
            for(String pathEntry : path.split('/'))
            {
                if(String.isNotBlank(pathEntry))
                {
                    usr = ForecastingService.GetUser(pathEntry);
                    if(usr != null)
                    {
                        result.add(usr);
                    }
                }
            }
        }
        return result;
    }
    
    public PageReference setupForecast()
    {
        if(CurrentViewingUser != null && CurrentViewingUser.ForecastEnabled)
        {
            ForecastingService.initForecast(CurrentViewingUser.UserId);
        }
        return null;
    }
    
    private static Boolean isValidPath(String path)
    {
        return String.isNotBlank(path) && Pattern.matches('/?(\\w{18}|\\w{15})(/(\\w{18}|\\w{15}))*', path);
    }
    
    //Gets all direct subordinate users of specified user
    @Readonly @RemoteAction
    public static List<ForecastingDataModel.UserInfo> GetDirectSubordinateUsers(Id userOrRoleId)
    {
        return ForecastingService.GetDirectSubordinateUsers(userOrRoleId);
    }
    
    //Gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<ForecastingDataModel.UserInfo> GetAllSubordinateUsers(String userId)
    {
        return ForecastingService.GetAllSubordinateUsers(userId);
    }
}