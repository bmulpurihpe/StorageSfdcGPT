/* Purpose: Schedular class to process the Contribution model TSE User schedule
 * Author: Exafort(Vishnu)
 * Change Log: Added Order By in the SOQL Query
 * 2022 Sep 18 Updated SOQL query to take only the Manager TSE record
 */
global class TSEEventScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        //Added query Is_TSE_Manager__c = True for TS-9286 by Exafort
        String query = 'Select Id,Name,(Select Id,subject,isAllDayEvent,StartDateTime,EndDateTime,eventType__c,eventSubType__c,IsCancelled__c,WhatId,OwnerId from Events'
            + ' where IsCancelled__c = false order by EndDateTime ASC),Batch_Processed_Message__c,True_Days__c,Enter_Starttime__c,Shift_Length__c,isNowScheduled__c,Employee_Name__r.TimeZoneSidKey, '
            + ' Start_Date__c,Manager__c,Next_Start_DateTime__c from CntrbnMdl_TSE__c where Employee_Name__r.isactive = true and Is_TSE_Manager__c = True and True_Days__c != null '
            //+ ' Start_Date__c,Manager__c from CntrbnMdl_TSE__c where id=\'a2c34000001Dszq\' '
            + 'ORDER BY Name ASC '
            + (Test.isRunningTest() ? ' limit 50' : '');
        PopulateEventsFromSupportcalendarBatch PopulateEventsFromSupportCalendar = new PopulateEventsFromSupportcalendarBatch(query);
        Database.executeBatch(PopulateEventsFromSupportCalendar,50);
    }
}