/* Change log
* 05FEB2017 - Andy SNAPBI - Excluded overlay splits from queries
*
*
*/

public with sharing class ForecastingStatsService
{
    public ForecastingStatsService() { }

    public ForecastingStatsService(ForecastingController controller) { }

    @RemoteAction @ReadOnly
    public static ForecastSummary GetForecastSummary(String userId, String fiscalQuarter, Boolean includeWeekly)
    {
        User user;
        List<User> users = [select Id, Name, UserRoleId, ForecastLevel__c from User where Id = :userId limit 1];
        if(users.size() > 0)
        {
            ForecastSummary forecastSummary = new ForecastSummary();
            forecastSummary.UserId = users[0].Id;
            forecastSummary.UserName = users[0].Name;
            
            ForecastingDataModel.FiscalQuarterInfo quarter = new ForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
            
            List<Id> allUserIds = new List<Id>();
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            
            loadWeeklyForecasts(forecastSummary, userId, allUserIds, quarter);
            if(users[0].ForecastLevel__c == 'Level 1') //Load Monthly Forecast data for AE users
            {
                loadMonthlyForecasts(forecastSummary, userId, quarter);
                loadSalesStageMetrics(forecastSummary, userId, quarter);
            }

            loadSummaryNumbers(forecastSummary, userId, allUserIds, quarter);
            refillMonthCurrent(forecastSummary);
            return forecastSummary;
        }
        else
        {
            return null;
        }
    }

    @RemoteAction @ReadOnly
    public static ForecastSummary GetTeamRepTotal(String userId, String fiscalQuarter)
    {
        Set<Id> repUserIds = new Set<Id>();
        for(ForecastingDataModel.UserInfo user : ForecastingService.GetAllSubordinateUsers(userId))
        {
            if(user.ForecastLevel == 'Level 1')
            {
                repUserIds.add(user.UserId);
            }
        }

        ForecastingDataModel.FiscalQuarterInfo qtr = new ForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
        ForecastSummary repTotal = new ForecastSummary();

        List<AggregateResult> wonOppAr = [select SUM(SplitAmount) amt from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and SplitOwnerId in :repUserIds and Opportunity.IsWon = true and Opportunity.Exclude_from_Bookings__c = false];
        repTotal.QTDBooking = wonOppAr[0].get('amt') == null ? 0 : (Decimal)wonOppAR[0].get('amt');
        
        //Current Week
        List<AggregateResult> currentWeekAr = [select SUM(QuarterCommit__c) qtrCommit, SUM(QuarterGut__c) qtrGut, SUM(QuarterUpside__c) qtrUpside, SUM(Month1Commit__c) m1, SUM(Month2Commit__c) m2, SUM(Month3Commit__c) m3, SUM(UpcomingWeekCommit__c) upcomingWeek, SUM(FollowingWeekCommit__c) followingWeek, SUM(Quota__c) quota from CustomForecast__c where User__c in :repUserIds and FYFQ__c = :qtr.FormattedString and Locked__c = false];
        repTotal.QtrCommit = (Decimal)currentWeekAr[0].get('qtrCommit');
        repTotal.QtrGut = (Decimal)currentWeekAr[0].get('qtrGut');
        repTotal.QtrUpside = (Decimal)currentWeekAr[0].get('qtrUpside');
        repTotal.Month1Commit = (Decimal)currentWeekAr[0].get('m1');
        repTotal.Month2Commit = (Decimal)currentWeekAr[0].get('m2');
        repTotal.Month3Commit = (Decimal)currentWeekAr[0].get('m3');
        repTotal.UpcomingWeekCommit = (Decimal)currentWeekAr[0].get('upcomingWeek');
        repTotal.FollowingWeekCommit = (Decimal)currentWeekAr[0].get('followingWeek');
        repTotal.Quota = (Decimal)currentWeekAr[0].get('quota');

        //Last Week
        ForecastingDataModel.WeekInfo lastWeek = getLastWeek(qtr);
        if(lastWeek != null)
        {
            List<AggregateResult> lastWeekAr = [select SUM(UpcomingWeekCommit__c) upcomingWeek from CustomForecast__c where User__c in :repUserIds and FYFQ__c = :qtr.FormattedString and YYWW__c = :lastWeek.FormattedString];
            repTotal.LastWeekCommit = (Decimal)lastWeekAr[0].get('upcomingWeek');

            List<AggregateResult> lastWeekWonOppWr = [select SUM(SplitAmount) amt from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and Opportunity.IsWon = true and Opportunity.CloseDate >= :lastWeek.StartDate and Opportunity.CloseDate <= :lastWeek.EndDate and SplitOwnerId in :repUserIds and Opportunity.Exclude_from_Bookings__c = false];
            repTotal.LastWeekActual = (Decimal)lastWeekWonOppWr[0].get('amt');
        }

        List<AggregateResult> monthlyAr = [select SUM(SplitAmount) amt, CALENDAR_MONTH(Opportunity.CloseDate) month from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and Opportunity.IsWon = true and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and SplitOwnerId in :repUserIds and Opportunity.Exclude_from_Bookings__c = false group by CALENDAR_MONTH(Opportunity.CloseDate)];
        for(AggregateResult ar : monthlyAr)
        {
            Integer month = (Integer)ar.get('month');
            Decimal amount = (Decimal)ar.get('amt');
            if(month == qtr.StartDate.month())
            {
                repTotal.Month1Actual = amount;
            }
            else if(month == qtr.StartDate.addMonths(1).month())
            {
                repTotal.Month2Actual = amount;
            }
            else if(month == qtr.StartDate.addMonths(2).month())
            {
                repTotal.Month3Actual = amount;
            }
        }

        repTotal.CurrentMonthIndex = qtr.CurrentMonthIndex;
        if(repTotal.CurrentMonthIndex == 1)
        {
            repTotal.CurrentMonthCommit = repTotal.Month1Commit;
            repTotal.CurrentMonthActual = repTotal.Month1Actual;
            repTotal.Month1 = (repTotal.Month1Commit != null) ? repTotal.Month1Commit : repTotal.Month1Actual;
            repTotal.Month2 = (repTotal.Month2Commit != null) ? repTotal.Month2Commit : repTotal.Month2Actual;
            repTotal.Month3 = (repTotal.Month3Commit != null) ? repTotal.Month3Commit : repTotal.Month3Actual;
        }
        else if(repTotal.CurrentMonthIndex == 2)
        {
            repTotal.CurrentMonthCommit = repTotal.Month2Commit;
            repTotal.CurrentMonthActual = repTotal.Month2Actual;
            repTotal.Month1 = repTotal.Month1Actual;
            repTotal.Month2 = (repTotal.Month2Commit != null) ? repTotal.Month2Commit : repTotal.Month2Actual;
            repTotal.Month3 = (repTotal.Month3Commit != null) ? repTotal.Month3Commit : repTotal.Month3Actual;
        }
        else if(repTotal.CurrentMonthIndex == 3)
        {
            repTotal.CurrentMonthCommit = repTotal.Month3Commit;
            repTotal.CurrentMonthActual = repTotal.Month3Actual;
            repTotal.Month1 = repTotal.Month1Actual;
            repTotal.Month2 = repTotal.Month2Actual;
            repTotal.Month3 = (repTotal.Month3Commit != null) ? repTotal.Month3Commit : repTotal.Month3Actual;
        }
        else if(repTotal.CurrentMonthIndex == 0) // Past Quarter
        {
            repTotal.CurrentMonthCommit = repTotal.Month3Commit;
            repTotal.CurrentMonthActual = repTotal.Month3Actual;
            repTotal.Month1 = repTotal.Month1Actual;
            repTotal.Month2 = repTotal.Month2Actual;
            repTotal.Month3 = repTotal.Month3Actual;
        }
        return repTotal;
    }

    private static void loadSummaryNumbers(ForecastSummary forecastSummary, String userId, List<Id> teamUserId, ForecastingDataModel.FiscalQuarterInfo qtr) 
    {
        if(forecastSummary != null) 
        {
            List<AggregateResult> openOppAr = [select SUM(SplitAmount) a, SUM(SplitRevenue__c) e from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and SplitOwnerId in :teamUserId and Opportunity.IsClosed = false and Opportunity.Exclude_from_Bookings__c = false];
            forecastSummary.TotalPipe = openOppAr[0].get('a') == null ? 0 : (Decimal)openOppAr[0].get('a');
            forecastSummary.WeightedPipe = openOppAr[0].get('e') == null ? 0 : (Decimal)openOppAr[0].get('e');
            
            List<AggregateResult> advStageOppAr = [select SUM(SplitAmount) a from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and SplitOwnerId in :teamUserId and Opportunity.Exclude_from_Bookings__c = false and (Opportunity.StageName like '4%' or Opportunity.StageName like '5%' or Opportunity.StageName like '6%' or Opportunity.StageName like '7%')];
            forecastSummary.AdvStagePipe = advStageOppAr[0].get('a') == null ? 0 : (Decimal)advStageOppAr[0].get('a'); 
            
            List<AggregateResult> wonOppAr = [select SUM(SplitAmount) a from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and SplitOwnerId in :teamUserId and Opportunity.IsWon = true and Opportunity.Exclude_from_Bookings__c = false];
            forecastSummary.QTDBooking = wonOppAr[0].get('a') == null ? 0 : (Decimal)wonOppAr[0].get('a'); 

            List<AggregateResult> sfcOppAr = [select SUM(SplitAmount) a, Opportunity.Sales_Forecast_Category__c c from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and SplitOwnerId in :teamUserId and Opportunity.Sales_Forecast_Category__c != 'Closed' and Opportunity.Exclude_from_Bookings__c = false group by Opportunity.Sales_Forecast_Category__c];
            for(AggregateResult ar : sfcOppAr)
            {
                String category = (String)ar.get('c');
                Decimal amount = (Decimal)ar.get('a');
                if(category == 'Won')
                {
                    forecastSummary.SfcWon = amount;
                }
                else if(category == 'Expected')
                {
                    forecastSummary.SfcExpected = amount;
                }
                else if(category == 'Upside')
                {
                    forecastSummary.SfcUpside = amount;
                }
                else if(category == 'Pipeline')
                {
                    forecastSummary.SfcPipeline = amount;
                }
            }
            
            List<AggregateResult> monthAggregate = [select SUM(SplitAmount) a, CALENDAR_MONTH(Opportunity.CloseDate) d from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and Opportunity.IsWon = true and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and SplitOwnerId in :teamUserId and Opportunity.Exclude_from_Bookings__c = false group by CALENDAR_MONTH(Opportunity.CloseDate)];
            for(AggregateResult aggregate : monthAggregate)
            {
                Integer month = (Integer)aggregate.get('d');
                Decimal amount = (Decimal)aggregate.get('a');
                if(month == qtr.StartDate.month())
                {
                    forecastSummary.Month1Actual = amount;
                }
                else if(month == qtr.StartDate.addMonths(1).month())
                {
                    forecastSummary.Month2Actual = amount;
                }
                else if(month == qtr.StartDate.addMonths(2).month())
                {
                    forecastSummary.Month3Actual = amount;
                }
            }
            
            List<CustomForecast__c> latestForecasts = [select YYWW__c, User__c, User__r.Name, UpcomingWeekCommit__c, FollowingWeekCommit__c, Month1Commit__c, Month2Commit__c, Month3Commit__c, QuarterCommit__c, QuarterGut__c, QuarterUpside__c, Quota__c, C9_Projection__c from CustomForecast__c where User__c = :userId and FYFQ__c = :qtr.FormattedString order by CreatedDate desc limit 2];
            if(latestForecasts.size() >= 1)
            {
                forecastSummary.QtrCommit = latestForecasts[0].QuarterCommit__c;
                forecastSummary.QtrGut = latestForecasts[0].QuarterGut__c;
                forecastSummary.QtrUpside = latestForecasts[0].QuarterUpside__c;
                forecastSummary.Month1Commit = latestForecasts[0].Month1Commit__c;
                forecastSummary.Month2Commit = latestForecasts[0].Month2Commit__c;
                forecastSummary.Month3Commit = latestForecasts[0].Month3Commit__c;
                forecastSummary.UpcomingWeekCommit = latestForecasts[0].UpcomingWeekCommit__c;
                forecastSummary.FollowingWeekCommit = latestForecasts[0].FollowingWeekCommit__c;
                forecastSummary.Quota = latestForecasts[0].Quota__c;
                forecastSummary.C9Projection = latestForecasts[0].C9_Projection__c;

                forecastSummary.CurrentMonthIndex = qtr.CurrentMonthIndex;
                if(forecastSummary.CurrentMonthIndex == 1)
                {
                    forecastSummary.CurrentMonthCommit = forecastSummary.Month1Commit;
                    forecastSummary.CurrentMonthActual = forecastSummary.Month1Actual;
                    forecastSummary.Month1 = (forecastSummary.Month1Commit != null) ? forecastSummary.Month1Commit : forecastSummary.Month1Actual;
                    forecastSummary.Month2 = (forecastSummary.Month2Commit != null) ? forecastSummary.Month2Commit : forecastSummary.Month2Actual;
                    forecastSummary.Month3 = (forecastSummary.Month3Commit != null) ? forecastSummary.Month3Commit : forecastSummary.Month3Actual;
                }
                else if(forecastSummary.CurrentMonthIndex == 2)
                {
                    forecastSummary.CurrentMonthCommit = forecastSummary.Month2Commit;
                    forecastSummary.CurrentMonthActual = forecastSummary.Month2Actual;
                    forecastSummary.Month1 = forecastSummary.Month1Actual;
                    forecastSummary.Month2 = (forecastSummary.Month2Commit != null) ? forecastSummary.Month2Commit : forecastSummary.Month2Actual;
                    forecastSummary.Month3 = (forecastSummary.Month3Commit != null) ? forecastSummary.Month3Commit : forecastSummary.Month3Actual;
                }
                else if(forecastSummary.CurrentMonthIndex == 3)
                {
                    forecastSummary.CurrentMonthCommit = forecastSummary.Month3Commit;
                    forecastSummary.CurrentMonthActual = forecastSummary.Month3Actual;
                    forecastSummary.Month1 = forecastSummary.Month1Actual;
                    forecastSummary.Month2 = forecastSummary.Month2Actual;
                    forecastSummary.Month3 = (forecastSummary.Month3Commit != null) ? forecastSummary.Month3Commit : forecastSummary.Month3Actual;
                }
                else if(forecastSummary.CurrentMonthIndex == 0) // Past Quarter
                {
                    forecastSummary.CurrentMonthCommit = forecastSummary.Month3Commit;
                    forecastSummary.CurrentMonthActual = forecastSummary.Month3Actual;
                    forecastSummary.Month1 = forecastSummary.Month1Actual;
                    forecastSummary.Month2 = forecastSummary.Month2Actual;
                    forecastSummary.Month3 = forecastSummary.Month3Actual;
                }
            }

            //LastWeekCommit, LastWeekActual            
            if(latestForecasts.size() == 2)
            {
                forecastSummary.LastWeekCommit = latestForecasts[1].UpcomingWeekCommit__c;
            }
            ForecastingDataModel.WeekInfo lastWeek = getLastWeek(qtr);
            if(lastWeek != null)
            {
                List<AggregateResult> lastWeekAggregate = [select sum(SplitAmount) a from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and Opportunity.IsWon = true and Opportunity.CloseDate >= :lastWeek.StartDate and Opportunity.CloseDate <= :lastWeek.EndDate and SplitOwnerId in :teamUserId and Opportunity.Exclude_from_Bookings__c = false];
                forecastSummary.LastWeekActual = (Decimal)lastWeekAggregate[0].get('a');
            }
        }
    }

    private static void loadSalesStageMetrics(ForecastSummary forecastSummary, String userId, ForecastingDataModel.FiscalQuarterInfo qtr)
    {
        if(forecastSummary != null)
        {
            List<AggregateResult> stageSfcAr = [select SUM(SplitAmount) amt, Opportunity.Sales_Forecast_Category__c category,  Opportunity.StageName stage from OpportunitySplit
                                                where SplitType.DeveloperName = 'Revenue' and SplitOwnerId = :userId and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and Opportunity.Sales_Forecast_Category__c != 'Closed' and Opportunity.Exclude_from_Bookings__c = false
                                                group by Opportunity.Sales_Forecast_Category__c, Opportunity.StageName];
            Map<String, SalesStageMetricsEntry> stageMetricsMap = new Map<String, SalesStageMetricsEntry>();
            SalesStageMetricsEntry entry;
            for(AggregateResult ar : stageSfcAr)
            {
                Decimal amount = (Decimal)ar.get('amt');
                String category = (String)ar.get('category');
                String stage = (String)ar.get('stage');
                if(!stageMetricsMap.containsKey(stage))
                {
                    entry = new SalesStageMetricsEntry();
                    entry.Stage = stage;
                    stageMetricsMap.put(stage, entry);
                }
                else
                {
                    entry = stageMetricsMap.get(stage);
                }
                entry.updateSfcAmount(category, amount);
            }
            forecastSummary.SalesStageMetrics = new List<SalesStageMetricsEntry>();
            forecastSummary.SalesStageMetrics.addAll(stageMetricsMap.values());
            forecastSummary.SalesStageMetrics.sort();
        }
    }

    private static void loadMonthlyForecasts(ForecastSummary forecastSummary, String userId, ForecastingDataModel.FiscalQuarterInfo qtr)
    {
        if(forecastSummary != null)
        {
            forecastSummary.MonthlyForecasts = new List<ForecastEntry>();
            ForecastEntry newEntry;
            for(Integer i = 1; i <=3; i ++)
            {
                newEntry = new ForecastEntry();
                newEntry.UserId = userId;
                newEntry.MonthIndex = i;
                newEntry.Editable = false;
                forecastSummary.MonthlyForecasts.add(newEntry);
            }
            
            
            List<AggregateResult> wonOppAr = [select SUM(SplitAmount) amt, CALENDAR_MONTH(Opportunity.CloseDate) month from OpportunitySplit 
                                              where SplitType.DeveloperName = 'Revenue' and SplitOwnerId = :userId and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and Opportunity.IsWon = true and Opportunity.Exclude_from_Bookings__c = false
                                              group by CALENDAR_MONTH(Opportunity.CloseDate)];
            for(AggregateResult ar : wonOppAr)
            {
                Integer month = (Integer)ar.get('month');
                Decimal amount = (Decimal)ar.get('amt');
                if(month == qtr.StartDate.month())
                {
                    forecastSummary.MonthlyForecasts[0].QtrBooking = amount;
                }
                else if(month == qtr.StartDate.addMonths(1).month())
                {
                    forecastSummary.MonthlyForecasts[1].QtrBooking = amount;
                }
                else if(month == qtr.StartDate.addMonths(2).month())
                {
                    forecastSummary.MonthlyForecasts[2].QtrBooking = amount;
                }
            }
            
            List<AggregateResult> openOppAr = [select SUM(SplitAmount) amt, SUM(SplitRevenue__c) rev, CALENDAR_MONTH(Opportunity.CloseDate) month from OpportunitySplit 
                                               where SplitType.DeveloperName = 'Revenue' and SplitOwnerId = :userId and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and Opportunity.IsClosed = false and Opportunity.Exclude_from_Bookings__c = false
                                               group by CALENDAR_MONTH(Opportunity.CloseDate)];
            for(AggregateResult ar : openOppAr)
            {
                Integer month = (Integer)ar.get('month');
                Decimal amount = (Decimal)ar.get('amt');
                Decimal expectedRevenue = (Decimal)ar.get('rev');
                if(month == qtr.StartDate.month())
                {
                    forecastSummary.MonthlyForecasts[0].Pipeline = amount;
                    forecastSummary.MonthlyForecasts[0].WeightedPipeline = expectedRevenue;
                }
                else if(month == qtr.StartDate.addMonths(1).month())
                {
                    forecastSummary.MonthlyForecasts[1].Pipeline = amount;
                    forecastSummary.MonthlyForecasts[1].WeightedPipeline = expectedRevenue;
                }
                else if(month == qtr.StartDate.addMonths(2).month())
                {
                    forecastSummary.MonthlyForecasts[2].Pipeline = amount;
                    forecastSummary.MonthlyForecasts[2].WeightedPipeline = expectedRevenue;
                }
            }

            List<AggregateResult> advStageOppAr = [select SUM(SplitAmount) amt, CALENDAR_MONTH(Opportunity.CloseDate) month from OpportunitySplit 
                                                   where SplitType.DeveloperName = 'Revenue' and SplitOwnerId = :userId and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and Opportunity.Exclude_from_Bookings__c = false
                                                   and (Opportunity.StageName like '4%' or Opportunity.StageName like '5%' or Opportunity.StageName like '6%' or Opportunity.StageName like '7%') 
                                                   group by CALENDAR_MONTH(Opportunity.CloseDate)];
            for(AggregateResult ar : advStageOppAr)
            {
                Integer month = (Integer)ar.get('month');
                Decimal amount = (Decimal)ar.get('amt');
                if(month == qtr.StartDate.month())
                {
                    forecastSummary.MonthlyForecasts[0].AdvStagePipeline = amount;
                }
                else if(month == qtr.StartDate.addMonths(1).month())
                {
                    forecastSummary.MonthlyForecasts[1].AdvStagePipeline = amount;
                }
                else if(month == qtr.StartDate.addMonths(2).month())
                {
                    forecastSummary.MonthlyForecasts[2].AdvStagePipeline = amount;
                }
            }

            List<AggregateResult> sfcOppAr = [select SUM(SplitAmount) amt, CALENDAR_MONTH(Opportunity.CloseDate) month, Opportunity.Sales_Forecast_Category__c category from OpportunitySplit 
                                              where SplitType.DeveloperName = 'Revenue' and SplitOwnerId = :userId and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and Opportunity.Sales_Forecast_Category__c != 'Closed' and Opportunity.Exclude_from_Bookings__c = false
                                              group by CALENDAR_MONTH(Opportunity.CloseDate), Opportunity.Sales_Forecast_Category__c];
            for(AggregateResult ar : sfcOppAr)
            {
                Integer month = (Integer)ar.get('month');
                Decimal amount = (Decimal)ar.get('amt');
                String category = (String)ar.get('category');
                if(month == qtr.StartDate.month())
                {
                    forecastSummary.MonthlyForecasts[0].updateSfcAmount(category, amount);
                }
                else if(month == qtr.StartDate.addMonths(1).month())
                {
                    forecastSummary.MonthlyForecasts[1].updateSfcAmount(category, amount);
                }
                else if(month == qtr.StartDate.addMonths(2).month())
                {
                    forecastSummary.MonthlyForecasts[2].updateSfcAmount(category, amount);
                }
            }
        }
    }

    private static void loadWeeklyForecasts(ForecastSummary forecastSummary, String userId, List<Id> teamUserId, ForecastingDataModel.FiscalQuarterInfo qtr)
    {
        if(forecastSummary != null) 
        {
            forecastSummary.WeeklyForecasts = new List<ForecastEntry>();
            for(CustomForecast__c forecast : [select YYWW__c, User__c, User__r.Name, UpcomingWeekCommit__c, FollowingWeekCommit__c, Month1Commit__c, Month2Commit__c, Month3Commit__c, QuarterCommit__c,QuarterGut__c, QuarterUpside__c, Locked__c, Quota__c, C9_Projection__c from CustomForecast__c where User__c = :userId and FYFQ__c = :qtr.FormattedString order by CreatedDate limit 13])
            {
                forecastSummary.WeeklyForecasts.add(new ForecastEntry(forecast));
            }
            completeWeeklyList(forecastSummary.WeeklyForecasts, qtr);
            
            for(OpportunitySplit oppSplit : [select convertCurrency(SplitAmount), SplitOwnerId, convertCurrency(SplitRevenue__c), Opportunity.Sales_Forecast_Category__c, Opportunity.CloseDate, Opportunity.IsWon, Opportunity.IsClosed, Opportunity.StageName from OpportunitySplit where SplitType.DeveloperName = 'Revenue' and SplitOwnerId in :teamUserId and Opportunity.CloseDate <= :qtr.EndDate and Opportunity.CloseDate >= :qtr.StartDate and Opportunity.Exclude_from_Bookings__c = false])
            {
                for(Integer i = 0; i < qtr.Weeks.size(); i++)
                {
                    ForecastingDataModel.WeekInfo w = qtr.Weeks[i];
                    ForecastEntry weekEntry = forecastSummary.WeeklyForecasts[i];
                    Opportunity opp = oppSplit.Opportunity;
                    if(opp.CloseDate.daysBetween(w.StartDate) <= 0 && opp.CloseDate.daysBetween(w.EndDate) >= 0)
                    {
                        Decimal amount = (oppSplit.SplitAmount == null) ? 0 : convertCurrency(oppSplit.SplitAmount, opp.CloseDate);
                        Decimal rev = (oppSplit.SplitRevenue__c == null) ? 0 : convertCurrency(oppSplit.SplitRevenue__c, opp.CloseDate);
                        
                        if(opp.IsWon)
                        {
                            weekEntry.WeeklyActual = (weekEntry.WeeklyActual == null) ? 0 : weekEntry.WeeklyActual;
                            weekEntry.WeeklyActual += amount;
                        }
                        if(!opp.IsClosed)
                        {
                            weekEntry.Pipeline = (weekEntry.Pipeline == null) ? 0 : weekEntry.Pipeline;
                            weekEntry.Pipeline += amount;

                            weekEntry.WeightedPipeline = (weekEntry.WeightedPipeline == null) ? 0 : weekEntry.WeightedPipeline;
                            weekEntry.WeightedPipeline += rev;
                        }
                        if(String.isNotBlank(opp.StageName) && (opp.StageName.startsWith('4') || opp.StageName.startsWith('5') || opp.StageName.startsWith('6') || opp.StageName.startsWith('7')))
                        {
                            weekEntry.AdvStagePipeline = (weekEntry.AdvStagePipeline == null) ? 0 : weekEntry.AdvStagePipeline;
                            weekEntry.AdvStagePipeline += amount;
                        }
                        if(opp.Sales_Forecast_Category__c == 'Pipeline')
                        {
                            weekEntry.SfcPipeline = (weekEntry.SfcPipeline == null) ? 0 : weekEntry.SfcPipeline;
                            weekEntry.SfcPipeline += amount;
                        }
                        else if(opp.Sales_Forecast_Category__c == 'Upside')
                        {
                            weekEntry.SfcUpside = (weekEntry.SfcUpside == null) ? 0 : weekEntry.SfcUpside;
                            weekEntry.SfcUpside += amount;
                        }
                        else if(opp.Sales_Forecast_Category__c == 'Expected')
                        {
                            weekEntry.SfcExpected = (weekEntry.SfcExpected == null) ? 0 : weekEntry.SfcExpected;
                            weekEntry.SfcExpected += amount;
                        }
                        else if(opp.Sales_Forecast_Category__c == 'Won')
                        {
                            weekEntry.SfcWon = (weekEntry.SfcWon == null) ? 0 : weekEntry.SfcWon;
                            weekEntry.SfcWon += amount;
                        }
                    }

                    if(weekEntry.Editable == true)
                    {
                        forecastSummary.CurrentWeekIndex = i;
                    }
                }
            }
            Decimal cumulativeBooking = 0;
            for(ForecastEntry weekEntry : forecastSummary.WeeklyForecasts)
            {
                weekEntry.QtrBooking = (weekEntry.WeeklyActual == null ? 0 : weekEntry.WeeklyActual) + cumulativeBooking;
                cumulativeBooking = weekEntry.QtrBooking;
                weekEntry.QtrBooking = (weekEntry.QtrBooking == 0) ? null : weekEntry.QtrBooking;
                
            }
            for(Integer i = 1; i < forecastSummary.WeeklyForecasts.size(); i++)
            {
                forecastSummary.WeeklyForecasts[i].QtrCommitUp = forecastSummary.WeeklyForecasts[i].QtrCommit > forecastSummary.WeeklyForecasts[i-1].QtrCommit;
                forecastSummary.WeeklyForecasts[i].QtrCommitDown = forecastSummary.WeeklyForecasts[i].QtrCommit < forecastSummary.WeeklyForecasts[i-1].QtrCommit;
                forecastSummary.WeeklyForecasts[i].QtrGutUp = forecastSummary.WeeklyForecasts[i].QtrGut > forecastSummary.WeeklyForecasts[i-1].QtrGut;
                forecastSummary.WeeklyForecasts[i].QtrGutDown = forecastSummary.WeeklyForecasts[i].QtrGut < forecastSummary.WeeklyForecasts[i-1].QtrGut;
                forecastSummary.WeeklyForecasts[i].QtrUpsideUp = forecastSummary.WeeklyForecasts[i].QtrUpside > forecastSummary.WeeklyForecasts[i-1].QtrUpside;
                forecastSummary.WeeklyForecasts[i].QtrUpsideDown = forecastSummary.WeeklyForecasts[i].QtrUpside < forecastSummary.WeeklyForecasts[i-1].QtrUpside;
            }
        }
    }
    
    private static void refillMonthCurrent(ForecastSummary forecastSummary)
    {
        if(forecastSummary != null)
        {
            for(ForecastEntry week : forecastSummary.WeeklyForecasts)
            {
                if(forecastSummary.CurrentMonthIndex == 2 && week.MonthIndex > 1)
                {
                    week.Month1Commit = forecastSummary.Month1Actual;
                }
                else if(forecastSummary.CurrentMonthIndex == 3 && week.MonthIndex == 3)
                {
                    week.Month1Commit = forecastSummary.Month1Actual;
                    week.Month2Commit = forecastSummary.Month2Actual;
                }
                else if(forecastSummary.CurrentMonthIndex == 4)
                {   //viewing history
                    week.Month1Commit = forecastSummary.Month1Actual;
                    week.Month2Commit = forecastSummary.Month2Actual;
                    week.Month3Commit = forecastSummary.Month3Actual;
                }
                if(week.Editable == true)
                {
                    break;
                }
            }
        }
    }
    
    private static void completeWeeklyList(List<ForecastEntry> weeklyList, ForecastingDataModel.FiscalQuarterInfo qtr)
    {
        Date qtrStart = qtr.StartDate;
        for(ForecastingDataModel.WeekInfo week : qtr.Weeks)
        {
            Boolean found = false;
            Date weekMiddle = week.StartDate.addDays(3);
            for(ForecastEntry entry : weeklyList)
            {
                
                if(entry.YYWW == week.FormattedString)
                {
                    entry.MonthIndex = (weekMiddle.year() - qtrStart.year()) * 12 + weekMiddle.month() - qtrStart.month() + 1;
                    found = true;
                }
            }
            if(!found)
            {
                ForecastEntry newentry = new ForecastEntry();
                newentry.YYWW = week.FormattedString;
                newentry.MonthIndex = (weekMiddle.year() - qtrStart.year()) * 12 + weekMiddle.month() - qtrStart.month() + 1;
                weeklyList.add(newentry);
            }
        }
        weeklyList.sort();
    }

    @RemoteAction @ReadOnly
    public static ForecastingOppListResponse GetOpportunityListing(ForecastingOppListRequest request)
    {   
        List<Id> allUserIds = new List<Id>();
        allUserIds.add(request.userId);
        allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(request.userId));

        ForecastingDataModel.FiscalQuarterInfo qtr = new ForecastingDataModel.FiscalQuarterInfo(request.FiscalQtr);
        Date startDate = qtr.StartDate;
        Date endDate = qtr.EndDate;
        
        Integer pageSize = (request.PageSize == null) ? 50 : request.PageSize;

        String closeDate = '';
        String closeDateSplit = '';
        if(request.CloseDate == 'This Week')
        {
            closeDate = 'AND CloseDate = THIS_WEEK ';
            closeDateSplit = 'AND Opportunity.CloseDate = THIS_WEEK ';
        }
        else if(request.CloseDate == 'Next Week')
        {
            closeDate = 'AND CloseDate = NEXT_WEEK ';
            closeDateSplit = 'AND Opportunity.CloseDate = NEXT_WEEK ';
             
        }
        else if(request.CloseDate == 'This Month')
        {
            closeDate = 'AND CloseDate = THIS_MONTH ';
            closeDateSplit = 'AND Opportunity.CloseDate = THIS_MONTH ';
        }
        else if(request.CloseDate == 'Next Month')
        {
            closeDate = 'AND CloseDate = NEXT_MONTH ';
            CloseDateSplit = 'AND Opportunity.CloseDate = NEXT_MONTH '; 
        }
        else if(request.CloseDate == 'This Quarter')
        {
            closeDate = 'AND CloseDate <= :endDate AND CloseDate >= :startDate ';
            closeDateSplit = 'AND Opportunity.CloseDate <= :endDate AND Opportunity.CloseDate >= :startDate ';
        }
        else if(request.CloseDate == 'Next Quarter')
        {
            ForecastingDataModel.FiscalQuarterInfo nextQtr = qtr.Next;
            startDate = nextQtr.StartDate;
            endDate = nextQtr.EndDate;
            closeDate = 'AND CloseDate <= :endDate AND CloseDate >= :startDate ';
            closeDateSplit = 'AND Opportunity.CloseDate <= :endDate AND Opportunity.CloseDate >= :startDate ';
        }
        else if(request.CloseDate == 'This Fiscal Year')
        {
            startDate = qtr.FiscalYear.StartDate;
            endDate = qtr.FiscalYear.EndDate;
            closeDate = 'AND CloseDate <= :endDate AND CloseDate >= :startDate ';
            closeDateSplit = 'AND Opportunity.CloseDate <= :endDate AND Opportunity.CloseDate >= :startDate ';
        }
        else if(request.CloseDate == 'Next Fiscal Year')
        {
            startDate = qtr.FiscalYear.Next.StartDate;
            endDate = qtr.FiscalYear.Next.EndDate;
            closeDate = 'AND CloseDate <= :endDate AND CloseDate >= :startDate ';
            closeDateSplit = 'AND Opportunity.CloseDate <= :endDate AND Opportunity.CloseDate >= :startDate ';
        }
        
        String status = '';
        String statusSplit = '';
        if(request.status == 'All Open')
        {
            status = 'AND IsClosed=false ';
            statusSplit = 'AND Opportunity.IsClosed=false ';
        }
        else if(request.status == 'All Won')
        {
            status = 'AND IsWon=true ';
            statusSplit = 'AND Opportunity.IsWon=true ';
        }
        else if(request.status == 'All Open & Won')
        {
            status = 'AND (IsClosed=false OR IsWon=true) ';
            statusSplit = 'AND (Opportunity.IsClosed=false OR Opportunity.IsWon=true) ';
        }
        else if(request.status == 'Closed Lost')
        {
            status = 'AND StageName=\'8- Closed Lost\' ';
            statusSplit = 'AND Opportunity.StageName=\'8- Closed Lost\' ';
        }
        else if(request.status == 'Closed No Decision')
        {
            status = 'AND StageName=\'8- Closed No Decision\' ';
            statusSplit = 'AND Opportunity.StageName=\'8- Closed No Decision\' ';
        }
        
        String stage = '';
        String stageSplit = '';
        if(request.Stage == 'Initial Stage Opps')
        {
            stage = 'AND (StageName like \'2%\' OR StageName like \'3%\') ';
            stageSplit = 'AND (Opportunity.StageName like \'2%\' OR Opportunity.StageName like \'3%\') ';
        }
        else if(request.Stage == 'Adv Stage Opps') 
        {
            stage = 'AND (StageName like \'4%\' OR StageName like \'5%\' OR StageName like \'6%\' OR StageName like \'7%\') ';
            stageSplit = 'AND (Opportunity.StageName like \'4%\' OR Opportunity.StageName like \'5%\' OR Opportunity.StageName like \'6%\' OR Opportunity.StageName like \'7%\') ';
        }
        
        String salesRegion = '';
        String salesRegionSplit = '';
        if(request.SalesRegion != 'All')
        {
            salesRegion = 'AND Sales_Region__c=\'' + request.SalesRegion + '\' ';
            salesRegionSplit = 'AND Opportunity.Sales_Region__c=\'' + request.SalesRegion + '\' ';
        }
        
        String forecastCategory = '';
        String forecastCategorySplit = '';
        if(request.ForecastCategory != 'All')
        {
            forecastCategory = 'AND Sales_Forecast_Category__c=\''+request.ForecastCategory+'\' ';
            forecastCategorySplit = 'AND Opportunity.Sales_Forecast_Category__c=\''+request.ForecastCategory+'\' ';
        }
        
        String probability = '';
        String probabilitySplit = '';
        if(String.isNotBlank(request.Probability))
        {
            probability = 'AND Probability ' + request.Probability + ' ';
            probabilitySplit = 'AND Opportunity.Probability ' + request.Probability + ' ';
        }
        
        String sortBy = 'ORDER BY ' + (String.isBlank(request.SortField) ? 'CloseDate' : request.SortField) + ' ';
        String order = (request.IsAscendingOrder == true) ? 'ASC' : 'DESC NULLS LAST';

        String query = 'SELECT Name, StageName, Type, Opportunity_Deal_Type__c, Exclude_from_Bookings__c, OwnerId, Owner.Name, Probability, ForecastCategory, ForecastCategoryName, convertCurrency(ExpectedRevenue), CloseDate, convertCurrency(Amount), (select Id, convertCurrency(SplitAmount), SplitOwnerId, SplitOwner.Name, SplitPercentage from OpportunitySplits ), NextStep, IsClosed, Sales_Forecast_Category__c, Next_Step_Field_Last_Updated_On__c, AccountId, Account.Name, Reseller_Account__c, Reseller_Account__r.Name FROM Opportunity ';
        query += 'WHERE Id in (select OpportunityId from OpportunitySplit where SplitOwnerId IN :allUserIds) ';
        query += closeDate;
        query += stage;
        query += status;
        query += salesRegion;
        query += forecastCategory;
        query += probability;
        query += sortBy;
        query += order;
        query += ' LIMIT 10000';
        
        String countQuery = 'SELECT COUNT(Id) cnt FROM Opportunity ';
        countQuery += 'WHERE Id in (select OpportunityId from OpportunitySplit where SplitOwnerId IN :allUserIds) ';
        countQuery += closeDate;
        countQuery += stage;
        countQuery += status;
        countQuery += salesRegion;
        countQuery += forecastCategory;
        countQuery += probability;
        
        String arQuery = 'select COUNT(Opportunity.Id) cnt, SUM(SplitAmount) amt from OpportunitySplit ';
        arQuery += 'where SplitOwnerId in :allUserIds and Opportunity.Exclude_from_Bookings__c = false ';
        arQuery += closeDateSplit;
        arQuery += stageSplit;
        arQuery += statusSplit;
        arQuery += salesRegionSplit;
        arQuery += forecastCategorySplit;
        arQuery += probabilitySplit;
        
        ApexPages.StandardSetcontroller oppController = new ApexPages.StandardSetcontroller(Database.getQueryLocator(query));
        oppController.setPageSize(pageSize);
        
        if(request.PageIndex != null && request.PageIndex > 0)
        {
            oppController.setPageNumber(request.PageIndex);
        }
        ForecastingOppListResponse response = new ForecastingOppListResponse();
        response.HasNext = oppController.getHasNext();
        response.HasPrevious = oppController.getHasPrevious();
        response.PageIndex = oppController.getPageNumber();
        
        List<AggregateResult> opps = Database.query(countQuery);
        response.RecordCount = opps[0].get('cnt') == null ? 0 : (Integer)opps[0].get('cnt');
        
        List<AggregateResult> oppAr = Database.query(arQuery);
        response.TotalAmount = oppAr[0].get('amt') == null ? 0 : (Decimal)oppAR[0].get('amt');
        //response.RecordCount = oppAr[0].get('cnt') == null ? 0 : (Integer)oppAr[0].get('cnt');
        response.PageCount = Math.ceil(oppController.getResultSize() * 1.0 / pageSize).intValue();

        for(SObject opp : oppController.getRecords())
        {
            response.Opportunities.add(new OpportunityEntry((Opportunity)opp));
        }
        return response;
    }

    @RemoteAction
    public static List<CustomForecast__History> GetEditHistory(Id userId, String quarter, String week, String field)
    {
        return [select OldValue, NewValue, CreatedBy.Name, CreatedDate from CustomForecast__History 
                where ParentId in (select Id from CustomForecast__c where User__c = :userId and FYFQ__c = :quarter and YYWW__c = :week) 
                and CreatedById != :userId and Field = :field 
                order by CreatedDate desc];
    }

    @RemoteAction
    public static void SaveForecast(Id userId, ForecastEntry entryValue)
    {
        CustomForecast__c target = null;
        List<CustomForecast__c> forecasts = [select User__c, FYFQ__c, YYWW__c, LastEdited__c, SubmittedOn__c, Locked__c, UpcomingWeekCommit__c, FollowingWeekCommit__c, Month1Commit__c, Month2Commit__c, Month3Commit__c, QuarterCommit__c, QuarterGut__c, QuarterUpside__c, ScheduledEmailTimeStamp__c, Quota__c, C9_Projection__c from CustomForecast__c where User__c = :userId and Locked__c = false order by CreatedDate desc limit 1];
        if(forecasts.size() == 1)
        {
            target = forecasts[0];
        }
        else
        {
            throw new ForecastingException('Error occured while saving the forecast. Please contact your system admin.');
        }
        target.UpcomingWeekCommit__c = entryValue.UpcomingWeekCommit;
        target.FollowingWeekCommit__c = entryValue.FollowingWeekCommit;
        target.Month1Commit__c = entryValue.Month1Commit;
        target.Month2Commit__c = entryValue.Month2Commit;
        target.Month3Commit__c = entryValue.Month3Commit;
        target.QuarterCommit__c = entryValue.QtrCommit;
        target.QuarterGut__c = entryValue.QtrGut;
        target.QuarterUpside__c = entryValue.QtrUpside;
        target.LastEdited__c = DateTime.now();
        target.Quota__c = entryValue.Quota;
        target.C9_Projection__c = entryValue.C9Projection;
        
        try
        {            
            if(target.ScheduledEmailTimeStamp__c == null || target.ScheduledEmailTimeStamp__c < DateTime.now().addMinutes(-5))
            {
                target.ScheduledEmailTimeStamp__c = DateTime.now();
                scheduleForecastUpdateNotification(userId);
            }
            upsert target;

        }
        catch (Exception e)
        {
            throw new ForecastingException('Failed to save forecast. Error message is: ' + e.getMessage());
        }

    }

    private static void scheduleForecastUpdateNotification(Id userId)
    {
        String jobName = ForecastUpdateSchedule.JOB_NAME + '_' + userId;
        List<CronTrigger> scheduledJobs = [select Id from CronTrigger where CronJobDetail.Name = :jobName];
        if(!scheduledJobs.isEmpty())
        {
            System.abortJob(scheduledJobs[0].Id);
        }
        DateTime scheduleTime = DateTime.now().addMinutes(5);
        String cronExp = scheduleTime.format('ss mm HH dd MM') + ' ?';
        ForecastUpdateSchedule sch = new ForecastUpdateSchedule(userId, UserInfo.getUserId());
        System.debug(System.schedule(jobName, cronExp, sch));
    }

    private static List<DatedConversionRate> ExchangeRateTable;
    private static Decimal DefaultExchangeRate;
    private static Decimal convertCurrency(Decimal amount, Date d)
    {
        if(amount == null)
        {
            return null;
        }
        String defaultCurrency = UserInfo.getDefaultCurrency();
        Decimal rate = 1;
        if(defaultCurrency != 'USD' || Test.isRunningTest())
        {
            if(DefaultExchangeRate == null)
            {
                List<CurrencyType> currencies = [select Id, IsoCode, ConversionRate from CurrencyType where IsoCode=:defaultCurrency limit 1];
                DefaultExchangeRate = currencies.size() > 0 ? currencies[0].ConversionRate : 1;
            }
            if(ExchangeRateTable == null)
            {
                ExchangeRateTable = [select StartDate, NextStartDate, ConversionRate from DatedConversionRate where IsoCode=:defaultCurrency];
            }
            if(d == null)
            {
                d = Date.today();
            }
            rate = DefaultExchangeRate == null ? rate : DefaultExchangeRate;
            for(DatedConversionRate exchangeRate : ExchangeRateTable)
            {
                if(exchangeRate.StartDate <= d && exchangeRate.NextStartDate >= d)
                {
                    rate = exchangeRate.ConversionRate;
                }
            }
        }
        return amount / rate;
    }

    private static ForecastingDataModel.WeekInfo getLastWeek(ForecastingDataModel.FiscalQuarterInfo qtr)
    {
        ForecastingDataModel.WeekInfo lastWeek = null;
        if(qtr.EndDate.daysBetween(Date.today()) > 0)
        {
            //viewing history
            lastWeek = qtr.Weeks[12];
        }
        else if(qtr.StartDate.daysBetween(Date.today()) >= 0)
        {
            //viewing current
            for(ForecastingDataModel.WeekInfo w : qtr.Weeks)
            {
                if(w.EndDate.daysBetween(Date.today()) <= 0)
                {
                    break;
                }
                lastWeek = w;
            }
        }
        return lastWeek;
    }
    
    public class ForecastSummary
    {
        public String UserId { get; set; }
        public String UserName { get; set; }
        public List<ForecastEntry> WeeklyForecasts { get; set; }
        public List<ForecastEntry> MonthlyForecasts { get; set; }
        public List<SalesStageMetricsEntry> SalesStageMetrics { get; set; }
        public Integer CurrentWeekIndex { get; set; }
        public Integer CurrentMonthIndex { get; set; }   // 1, 2 or 3 representing the month index; 4 for past months

        public Decimal QtrCommit { get; set; }
        public Decimal QtrGut { get; set; }
        public Decimal QtrUpside { get; set; }
        public Decimal TotalPipe { get; set; }
        public Decimal WeightedPipe { get; set; }
        public Decimal AdvStagePipe { get; set; }
        public Decimal QTDBooking { get; set; }
        public Decimal Month1 { get; set; }
        public Decimal Month2 { get; set; }
        public Decimal Month3 { get; set; }
        public Decimal Month1Actual { get; set; }
        public Decimal Month2Actual { get; set; }
        public Decimal Month3Actual { get; set; }
        public Decimal Month1Commit { get; set; }
        public Decimal Month2Commit { get; set; }
        public Decimal Month3Commit { get; set; }
        public Decimal CurrentMonthCommit { get; set; }
        public Decimal CurrentMonthActual { get; set; }
        public Decimal UpcomingWeekCommit { get; set; }
        public Decimal FollowingWeekCommit { get; set; }
        public Decimal LastWeekCommit { get; set; }
        public Decimal LastWeekActual { get; set; }
        public Decimal SfcWon { get; set; }
        public Decimal SfcExpected { get; set; }
        public Decimal SfcUpside { get; set; }
        public Decimal SfcPipeline { get; set; }
        public Decimal Quota { get; set; }
        public Decimal C9Projection { get; set; }
        
        public ForecastSummary()
        {
            WeeklyForecasts = new List<ForecastEntry>();
            MonthlyForecasts = new List<ForecastEntry>();
            SalesStageMetrics = new List<SalesStageMetricsEntry>();
        }
    }

    public class ForecastEntry implements Comparable
    {
        public String UserId { get; set; }
        public String UserName { get; set; }
        public String YYWW { get; set; }
        public Integer MonthIndex { get; set; } //1, 2 or 3
        public Boolean Editable { get; set; }

        public Decimal Month1Commit { get; set; }
        public Decimal Month2Commit { get; set; }
        public Decimal Month3Commit { get; set; }
        public Decimal UpcomingWeekCommit { get; set; }
        public Decimal FollowingWeekCommit { get; set; }
        public Decimal WeeklyActual { get; set; }

        public Decimal QtrCommit { get; set; }
        public Decimal QtrGut { get; set; }
        public Decimal QtrUpside { get; set; }

        public Boolean QtrCommitUp { get; set; }
        public Boolean QtrCommitDown { get; set; }
        public Boolean QtrGutUp { get; set; }
        public Boolean QtrGutDown { get; set; }
        public Boolean QtrUpsideUp { get; set; }
        public Boolean QtrUpsideDown { get; set; }

        public Decimal QtrBooking { get; set; }
        public Decimal Pipeline { get; set; }
        public Decimal WeightedPipeline { get; set; }
        public Decimal AdvStagePipeline { get; set; }

        public Decimal SfcPipeline { get; set; }
        public Decimal SfcUpside { get; set; }
        public Decimal SfcExpected { get; set; }
        public Decimal SfcWon { get; set; }
        
        public Decimal Quota { get; set; }
        public Decimal C9Projection { get; set; }
        
        public ForecastEntry()
        {

        }

        public ForecastEntry(CustomForecast__c forecast)
        {
            UserId = forecast.User__c;
            UserName = forecast.User__r.Name;
            YYWW = forecast.YYWW__c;
            UpcomingWeekCommit = forecast.UpcomingWeekCommit__c;
            FollowingWeekCommit = forecast.FollowingWeekCommit__c;
            Month1Commit = forecast.Month1Commit__c;
            Month2Commit = forecast.Month2Commit__c;
            Month3Commit = forecast.Month3Commit__c;
            QtrCommit = forecast.QuarterCommit__c;
            QtrGut = forecast.QuarterGut__c;
            QtrUpside= forecast.QuarterUpside__c;
            Editable = !forecast.Locked__c;
            Quota = forecast.Quota__c;
            C9Projection = forecast.C9_Projection__c;
        }

        public void updateSfcAmount(String category, Decimal amount)
        {
            if(String.isNotBlank(category))
            {
                if(category.equalsIgnoreCase('Pipeline'))
                {
                    SfcPipeline = amount;
                }
                else if(category.equalsIgnoreCase('Upside'))
                {
                    SfcUpside = amount;
                }
                else if(category.equalsIgnoreCase('Expected'))
                {
                    SfcExpected = amount;
                }
                else if(category.equalsIgnoreCase('Won'))
                {
                    SfcWon = amount;
                }
            }
        }
        
        public Integer compareTo(Object compareTo) 
        {
            if(compareTo == null || !(compareTo instanceOf ForecastEntry))
            {
                return 1;
            }
            if(YYWW > ((ForecastEntry)compareTo).YYWW)
            {
                return 1;
            }
            else if(YYWW == ((ForecastEntry)compareTo).YYWW)
            {
                return 0;
            }
            else
            {
                return -1;
            }
        }
    }

    public class SalesStageMetricsEntry implements Comparable
    {
        public String Stage { get; set; }
        public Decimal SfcPipeline { get; set; }
        public Decimal SfcUpside { get; set; }
        public Decimal SfcExpected { get; set; }
        public Decimal SfcWon { get; set; }

        public void updateSfcAmount(String category, Decimal amount)
        {
            if(String.isNotBlank(category))
            {
                if(category.equalsIgnoreCase('Pipeline'))
                {
                    SfcPipeline = amount;
                }
                else if(category.equalsIgnoreCase('Upside'))
                {
                    SfcUpside = amount;
                }
                else if(category.equalsIgnoreCase('Expected'))
                {
                    SfcExpected = amount;
                }
                else if(category.equalsIgnoreCase('Won'))
                {
                    SfcWon = amount;
                }
            }
        }

        public Integer compareTo(Object compareTo)
        {
            if(compareTo == null || !(compareTo instanceOf SalesStageMetricsEntry))
            {
                return 1;
            }
            if(Stage > ((SalesStageMetricsEntry)compareTo).Stage)
            {
                return 1;
            }
            else if(Stage == ((SalesStageMetricsEntry)compareTo).Stage)
            {
                return 0;
            }
            else 
            {
                return -1;
            }
        }

    }
    
    public class ForecastingOppListRequest
    {
        public String UserId { get; set; }
        public String FiscalQtr { get; set; }
        public String Probability { get; set; }
        public String CloseDate { get; set; }
        public String Status { get; set; }
        public String Stage { get; set; }
        public String SalesRegion { get; set; }
        public String ForecastCategory { get; set; }
        
        public String SortField { get; set; }
        public Boolean IsAscendingOrder { get; set; }
        public Integer PageIndex { get; set; }
        public Integer PageSize { get; set; }
        
    }
    
    public class ForecastingOppListResponse
    {
        public ForecastingOppListResponse()
        {
            Opportunities = new List<OpportunityEntry>();
        }
        
        public List<OpportunityEntry> Opportunities { get; set; }
        public Boolean HasNext { get; set; }
        public Boolean HasPrevious { get; set; }
        public Integer PageIndex { get; set; }
        public Integer PageCount { get; set; }
        public Integer RecordCount { get; set; }
        public Decimal TotalAmount { get; set; }
    }
    
    public class OpportunityEntry
    {
        public OpportunityEntry(Opportunity opp)
        {
            this.OppId = opp.Id;
            this.OppName = opp.Name;
            this.Stage = opp.StageName;
            
            this.Probability = opp.Probability;
            //this.CloseDate = (opp.CloseDate == null) ? '' : formatDate(opp.CloseDate);
            this.CloseDate = (opp.CloseDate == null) ? '' : opp.CloseDate.format();
            this.ForecastCategory = opp.Sales_Forecast_Category__c;
            this.Type = opp.Type;
            this.ExcludeFromBookings = opp.Exclude_from_Bookings__c;
            this.DealType = opp.Opportunity_Deal_Type__c;
            this.NextStep = opp.NextStep;
            this.OwnerId = opp.OwnerId;
            this.OwnerName = opp.Owner.Name;
            if(!opp.IsClosed && opp.Next_Step_Field_Last_Updated_On__c != null && opp.Next_Step_Field_Last_Updated_On__c.daysBetween(Date.today()) > 15)
            {
                this.HighlightLevel = 1;
            }
            if(!opp.IsClosed && opp.Next_Step_Field_Last_Updated_On__c != null && opp.Next_Step_Field_Last_Updated_On__c.daysBetween(Date.today()) > 30)
            {
                this.HighlightLevel = 2;
            }
            if(!opp.IsClosed && opp.CloseDate != null && opp.CloseDate.daysBetween(Date.today()) > 0)
            {
                this.HighlightLevel = 3;
            }
            this.AccountId = opp.AccountId;
            this.AccountName = opp.Account.Name;
            this.ResellerId = opp.Reseller_Account__c;
            this.ResellerName = opp.Reseller_Account__r.Name;
            this.oppSplits = new List<OpportunitySplitEntry>();
            this.Amount = (opp.Amount == null) ? 0 : ForecastingStatsService.convertCurrency(opp.Amount, opp.CloseDate);
            this.SplitAmount = getSplitAmounts(opp.OpportunitySplits, opp);
        }
        
        public String OppId { get; set; }
        public String OppName { get; set; }
        public Decimal Amount { get; set; }
        public Decimal SplitAmount { get; set; }
        public String Stage { get; set; }
        public Decimal Probability { get; set; }
        public String CloseDate { get; set; }
        public String ForecastCategory { get; set; }
        public String Type { get; set; }
        public Boolean ExcludeFromBookings { get; set; }
        public String DealType { get; set; }
        public String NextStep { get; set; }
        public String OwnerId { get; set; }
        public String OwnerName { get; set; }
        public Integer HighlightLevel { get; set; }
        public String AccountId { get; set; }
        public String AccountName { get; set; }
        public String ResellerId { get; set; }
        public String ResellerName { get; set; }
        public List<OpportunitySplitEntry> oppSplits { get; set; }
        
        
        private String formatDate(Date d)
        {
            String month = (d.month() < 10) ? '0' + d.month() : '' + d.month();
            String day = (d.day() < 10) ? '0' + d.day() : '' + d.day();
            return month + '/' + day + '/' + d.year();
        }
        
        private Decimal getSplitAmounts(List<OpportunitySplit> splits, Opportunity opp)
        {
            Decimal splitAmount = 0;           
            for(OpportunitySplit split : splits)
            {
                Decimal amount = (split.SplitAmount == null) ? 0 : ForecastingStatsService.convertCurrency(split.SplitAmount, opp.CloseDate);
                this.oppSplits.add(new OpportunitySplitEntry(split, amount));
                if(split.SplitOwnerId == opp.OwnerId)
                {
                    splitAmount = amount;    
                }
            }      
            return splitAmount;
        }
    }
    
    public class OpportunitySplitEntry
    {
        public OpportunitySplitEntry(OpportunitySplit oppSplit, Decimal splitAmount)
        {
            this.SplitId = oppSplit.Id;
            this.SplitOwnerId = oppSplit.SplitOwnerId;
            this.SplitOwnerName = oppSplit.SplitOwner.Name;
            this.SplitAmount = splitAmount;
            this.SplitPercentage = oppSplit.SplitPercentage;
        }
        
        public String SplitId { get; set; }
        public String SplitOwnerId { get; set; }
        public String SplitOwnerName { get; set; }
        public Decimal SplitAmount { get; set; }
        public Decimal SplitPercentage { get; set; }
    }
}