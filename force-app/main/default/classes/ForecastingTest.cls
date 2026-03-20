@isTest
private class ForecastingTest 
{
    @testSetup 
    static void setup()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        
        Opportunity opp1 = new Opportunity(Name='acme 1', AccountId=acc.Id, StageName='2-Qualified', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Pipeline', CloseDate=Date.today().addMonths(0));
        Opportunity opp2 = new Opportunity(Name='acme 2', AccountId=acc.Id, StageName='2-Qualified', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Pipeline', CloseDate=Date.today().addMonths(1));
        Opportunity opp3 = new Opportunity(Name='acme 3', AccountId=acc.Id, StageName='2-Qualified', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Pipeline', CloseDate=Date.today().addMonths(2));

        Opportunity opp4 = new Opportunity(Name='acme 4', AccountId=acc.Id, StageName='3- Pilot Expected', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Upside', CloseDate=Date.today().addMonths(0));
        Opportunity opp5 = new Opportunity(Name='acme 5', AccountId=acc.Id, StageName='3- Pilot Expected', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Upside', CloseDate=Date.today().addMonths(1));
        Opportunity opp6 = new Opportunity(Name='acme 6', AccountId=acc.Id, StageName='3- Pilot Expected', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Upside', CloseDate=Date.today().addMonths(2));

        Opportunity opp7 = new Opportunity(Name='acme 7', AccountId=acc.Id, StageName='3- Pilot Expected', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Expected', CloseDate=Date.today().addMonths(0));
        Opportunity opp8 = new Opportunity(Name='acme 8', AccountId=acc.Id, StageName='3- Pilot Expected', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Expected', CloseDate=Date.today().addMonths(1));
        Opportunity opp9 = new Opportunity(Name='acme 9', AccountId=acc.Id, StageName='3- Pilot Expected', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Expected', CloseDate=Date.today().addMonths(2));
        
        insert new List<Opportunity> { opp1, opp2, opp3, opp4, opp5, opp6, opp7, opp8, opp9 };
    }


    @isTest
    static void testForecastingDataModel()
    {
        User currentUser = [SELECT Id, Name, UserRoleId, UserRole.Name, ForecastEnabled__c, ViewForecastAs__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ForecastingDataModel.UserInfo usr = new ForecastingDataModel.UserInfo(currentUser);
        ForecastingDataModel.UserInfo usr2 = usr.ViewForecastAs;
        
        ForecastingDataModel.FiscalQuarterInfo qtr = new ForecastingDataModel.FiscalQuarterInfo();
        qtr = new ForecastingDataModel.FiscalQuarterInfo(Date.Today());
        qtr = new ForecastingDataModel.FiscalQuarterInfo('2015Q1');
        System.assertEquals('2015Q1', qtr.FormattedString);
        System.assertEquals('2015Q2', qtr.Next.FormattedString);
        System.assertEquals('2014Q4', qtr.Previous.FormattedString);

        ForecastingDataModel.FiscalYearInfo y = new ForecastingDataModel.FiscalYearInfo(2016);
        y.StartDate = Date.newInstance(2016, 1, 1);
        y.EndDate = Date.newInstance(2016, 12, 31);
        System.assertEquals(2017, y.Next.year);
        System.assertEquals(2015, y.Previous.year);
        
        ForecastingDataModel.WeekInfo week = new ForecastingDataModel.WeekInfo();
        ForecastingDataModel.WeekInfo week2 = new ForecastingDataModel.WeekInfo(Date.today(), Date.today().addDays(1));
        Date d = Date.newInstance(2015, 1, 1);
        week = new ForecastingDataModel.WeekInfo(d);
        String w = week.FormattedString;
        w = week.FormattedShortString;
    }
    
    @isTest
    static void  testForecastingController()
    {
        User u = new User(Id=UserInfo.getUserId(), ForecastEnabled__c=true);
        update u;
        
        PageReference pageRef = new PageReference('/apex/forecasting');
        Test.setCurrentPage(pageRef);
        ForecastingController controller = new ForecastingController();
        controller.setupForecast();
        
        String userId = UserInfo.getUserId();
        pageRef = new PageReference('/apex/forecasting?quarter=2015Q1&path=/'+userId);
        Test.setCurrentPage(pageRef);
        controller = new ForecastingController();

        String path = controller.UserPath;
        System.assertEquals('2015Q1', controller.CurrentFiscalQuarter.FormattedString);
        System.assertNotEquals(null, controller.CurrentViewingUser);
        System.assertNotEquals(null, ForecastingController.GetDirectSubordinateUsers(UserInfo.getUserId()));
        System.assertNotEquals(null, ForecastingController.GetAllSubordinateUsers(UserInfo.getUserId()));
    }
    
    @isTest
    static void testForecastingService()
    {
        Id userId = UserInfo.getUserId();
        User user = new User(ForecastLevel__c = 'Level 1', Id = userId, ForecastEnabled__c = true);
        update user;

        ForecastingDataModel.WeekInfo weekInfo = new ForecastingDataModel.WeekInfo();
        ForecastingDataModel.FiscalQuarterInfo qtrInfo = new ForecastingDataModel.FiscalQuarterInfo();

        String qtr = qtrInfo.FormattedString;
        String week = weekInfo.FormattedString;
        
        List<CustomForecast__c> forecasts = new List<CustomForecast__c>();
        forecasts.add(new CustomForecast__c(YYWW__c=week, FYFQ__c=qtr, User__c=userId, QuarterCommit__c=1000));
        forecasts.add(new CustomForecast__c(YYWW__c=week, FYFQ__c=qtr, User__c=userId, QuarterCommit__c=1000));
        forecasts.add(new CustomForecast__c(YYWW__c=week, FYFQ__c=qtr, User__c=userId, QuarterCommit__c=1000));
        insert forecasts;
        
        ForecastingService.GetDirectSubordinateUsers(userId);
        ForecastingService.GetAllSubordinateUsers(userId);
        ForecastingService.GetDirectSubordinateUserIds(userId);
        ForecastingService.GetParentRoleUserIds(userId);
        ForecastingService.GetAllSubordinateUserIds(userId);
        ForecastingService.GetUser(userId);
        ForecastingService.GetStartOfCurrentFiscalYear();
        ForecastingService.initForecast(userId);
    }
    
    @isTest
    static void testForecastingStatsService()
    {
        Id userId = UserInfo.getUserId();
        User user = new User(ForecastLevel__c = 'Level 1', Id = userId, ForecastEnabled__c = true);
        update user;
        
        Account acc = new Account(Name='acme');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='acme 1', OwnerId = userId, AccountId=acc.Id, StageName='2-Qualified', Type='Other (parts, spares, services, etc)', Sales_Forecast_Category__c='Pipeline', CloseDate=Date.today().addMonths(0));
        insert opp;
        
		ForecastingDataModel.WeekInfo weekInfo = new ForecastingDataModel.WeekInfo();
        ForecastingDataModel.FiscalQuarterInfo qtrInfo = new ForecastingDataModel.FiscalQuarterInfo();
        
        String qtr = qtrInfo.FormattedString;
        String week = weekInfo.FormattedString;
        
        CustomForecast__c forecast = new CustomForecast__c(YYWW__c=week, FYFQ__c=qtr, User__c=userId, QuarterCommit__c=1000);
        insert forecast;
        
        ForecastingStatsService.GetForecastSummary(userId, qtr, true);
        ForecastingStatsService.GetTeamRepTotal(userId, qtr);

        ForecastingStatsService.ForecastingOppListRequest req = new ForecastingStatsService.ForecastingOppListRequest();
        req.userId = userId;
        req.FiscalQtr = qtr;
        req.status = 'All Open';
        req.SalesRegion = 'All';
        req.ForecastCategory = 'All';
        //req.Probability = '>= 0';
        ForecastingStatsService.GetOpportunityListing(req);

        ForecastingStatsService.ForecastEntry entry = new ForecastingStatsService.ForecastEntry();
        entry.UserId = userId;
        entry.QtrCommit = 200;
        entry.QtrUpside = 250;
        entry.QtrGut = 300;
        ForecastingStatsService.SaveForecast(userId, entry);
        
        ForecastingStatsService.GetEditHistory(userId, qtr, week, null);
    }
    
    @isTest
    static void testForecastingException()
    {
        ForecastingException ex = new ForecastingException();
    }
    
    @isTest
    static void testBatchJob()
    {
      List<user> users = [select Id from User where ForecastEnabled__c=true and IsActive=true];
      if(users.size() > 0)
      {
        CustomForecast__c f = new CustomForecast__c(User__c=users[0].Id, Locked__c=false, Month1Commit__c=100);
        insert f;
        Test.startTest();
        ForecastSubmissionBatch job = new ForecastSubmissionBatch(null);
        Database.executeBatch(job);
        Test.stopTest();
        
        f = [select Id, Locked__c, SubmittedOn__c from CustomForecast__c where Id=:f.Id limit 1];
        System.assertEquals(true, f.Locked__c);
        List<CustomForecast__c> newFc = [select Id, Month1Commit__c, User__c, Locked__c from CustomForecast__c where Locked__c=false];
        System.assertEquals(1, newFc.size());
        //System.assertEquals(100, newFc[0].Month1Commit__c);
        System.assertEquals(users[0].Id, newFc[0].User__c);
      }
    }
    
    @isTest
    static void testBatchJob2()
    {
      List<user> users = [select Id from User where ForecastEnabled__c=true and IsActive=true];
      if(users.size() > 0)
      {
        CustomForecast__c f = new CustomForecast__c(User__c=users[0].Id, Locked__c=false, Month1Commit__c=100, YYWW__c = '201541', FYFQ__c = '2016Q3');
        insert f;
        Test.startTest();
        ForecastSubmissionBatch job = new ForecastSubmissionBatch(null);
        Database.executeBatch(job);
        Test.stopTest();

        List<CustomForecast__c> newFcs = [select Id, Month1Commit__c, User__c, Locked__c from CustomForecast__c where User__c = :users[0].Id order by CreatedDate desc];
        System.assertEquals(2, newFcs.size());  
      }
    }
    
    @isTest
    static void testSchedule()
    {
      ForecastSubmissionSchedule schedule = new ForecastSubmissionSchedule();
      schedule.execute(null);
    }
    
    @isTest
    static void testForecastUpdateSchedule()
    {
        List<user> users = [select Id from User where ForecastEnabled__c = true and IsActive = true and Id != :UserInfo.getUserId()];
        if(users.size() > 0)
        {
            String userId = users[0].Id;
            CustomForecast__c forecast = new CustomForecast__c(User__c = userId, Locked__c = false);
            insert forecast;

            ForecastUpdateSchedule schCls = new ForecastUpdateSchedule(userId, UserInfo.getUserId());
            String jobName = ForecastUpdateSchedule.JOB_NAME + '_' + userId;
            String cronExp = '0 0 23 ? * SUN';
            Test.startTest();
            System.schedule(jobName, cronExp, schCls);
            Test.stopTest();

        }
    }
}