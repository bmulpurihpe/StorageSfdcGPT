/*
* Batch class: PopulateEventsFromSupportcalendar
* The purpose of the batch is to update only for Managers in the Contribution model, is user is currently "On shift" considering the events on the Support calendar.
* Author: Exafort(Vishnu)
* Date: 13th July 2018
* Change log: break was added in events loop to exit the loop if a leave event for current day is found.[Added by Exafort(vishnu) on 20 Sep 2018]
* 2022 Sep 18 Split this to multiple classes to support Manager on duty
* */
global class PopulateEventsFromSupportcalendarBatch implements Database.Batchable<sObject>{
    
    global final String Query; //Batch Query
    
    global PopulateEventsFromSupportcalendarBatch(){
        this(
            'Select Id,Name,(Select Id,subject,isAllDayEvent,StartDateTime,EndDateTime,eventType__c,eventSubType__c,IsCancelled__c,WhatId,OwnerId from Events'
            + ' where IsCancelled__c = false),Batch_Processed_Message__c,True_Days__c,Enter_Starttime__c,Shift_Length__c,isNowScheduled__c,Employee_Name__r.TimeZoneSidKey, '
            + ' Start_Date__c,Manager__c, Next_Start_DateTime__c from CntrbnMdl_TSE__c where Is_TSE_Manager__c = True'            
            + ' ORDER BY Name ASC'
			+ (Test.isRunningTest() ? ' limit 50' : '')            
		);
    }
    
    //Fetching string query from the scheduler class.
    global PopulateEventsFromSupportcalendarBatch(string q){
        Query = q;
		system.debug('SOQL : ' + Query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<CntrbnMdl_TSE__c>  TseRecordsToProcess)
    {
        PopulateEventsFromSupportCalendarUtility calendarUtility = new PopulateEventsFromSupportCalendarUtility();
        calendarUtility.execute(BC,TseRecordsToProcess);
    }
    global void finish(Database.BatchableContext BC)
    {
        //Added by exafort to run for all active employee TSE records
        String query = 'Select Id,Name,(Select Id,subject,isAllDayEvent,StartDateTime,EndDateTime,eventType__c,eventSubType__c,IsCancelled__c,WhatId,OwnerId from Events'
            + ' where IsCancelled__c = false order by StartDateTime ASC),Batch_Processed_Message__c,True_Days__c,Enter_Starttime__c,Shift_Length__c,isNowScheduled__c,Employee_Name__r.TimeZoneSidKey, '
            + ' Start_Date__c,Manager__c,Next_Start_DateTime__c from CntrbnMdl_TSE__c where Employee_Name__r.isactive = true and True_Days__c != null ' 
            + ' ORDER BY Name ASC'
			+ (Test.isRunningTest() ? ' limit 50' : '');
        PopulateEventsFromCalendarAllEmployees CntrbnModel = new PopulateEventsFromCalendarAllEmployees(query);
        Database.executeBatch(CntrbnModel,50);
    }
}