/*
* Batch class: PopulateEventsFromCalendarAllEmployees
* The purpose of the batch is to update the Contribution model is user is currently "On shift" considering the events on the Support calendar. This calculates for all active employees
* Author: Exafort
* Date: 15th September 2022
* */
global class PopulateEventsFromCalendarAllEmployees implements Database.Batchable<sObject>{
    global final String Query; //Batch Query
    
    global PopulateEventsFromCalendarAllEmployees(){
        this(
            'Select Id,Name,(Select Id,subject,isAllDayEvent,StartDateTime,EndDateTime,eventType__c,eventSubType__c,IsCancelled__c,WhatId,OwnerId from Events'
            + ' where IsCancelled__c = false AND isAllDayEvent = true),Batch_Processed_Message__c,True_Days__c,Enter_Starttime__c,Shift_Length__c,isNowScheduled__c,Employee_Name__r.TimeZoneSidKey, '
            + ' Start_Date__c, Manager__c  from CntrbnMdl_TSE__c where Employee_Name__r.isactive = true '
            + ' ORDER BY Name ASC'
        	+ (Test.isRunningTest() ? ' limit 50' : '')
		);
    }
    
    //Fetching string query from the scheduler class.
    global PopulateEventsFromCalendarAllEmployees(string q){
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
        
    }
    
}