/*                              <<<< === Apex Class for Support Calendar === >>>>
=============================================================================================================
Name                    : calendarEvent_Controller
Description             : To insert or update parent and child records through a JSON taken from REST Apex class
Created Date            : 24th Nov, 2017
Author                  : Vishnu R 
Version                 : 1.0
Modification History    : Initial Version
** Modified by vishnu on Feb 13th 2019 - Added the default date format
** Modified by vishnu on May 23rd 2019 - Added escapejava() to handle double quotes in the event subject.TS-5820
** Modified by vishnu on Jul 11th 2019 - Added AND StartDateTime > LAST_N_WEEKS:4 in the event query in the firstTimePageLoad method.TS-5820
** Modified by vishnu on Nov 12th 2020 - Added try catch in new and edit event methods to resolve the invalid datetime error while parsing string date times.ESS-52447 
** Modified by Nagalaxmi Telkar on July 12th 2022 - Added a validation on "Event Type" to exclude Zoom meetings from TSE's calendar
** Modified by Nagalaxmi Telkar on June 2023 - TS-9800
** Modified by Vasanthika on Jan 29th 2026 (capture Name value from User object) - SFDC-639
--------------------------------------------------------------------------------------------------------------
*/
global without sharing class calendarEvent_Controller {
    public ApexPages.StandardController controller;
    public String userTimeZone{get;set;}
    public Event newEvent {get;set;}
    public boolean showOnlyTeamEvents{get;set;} 
    public boolean showOnlyOrganizationEvents{get;set;}
    public String eventSubject{get;set;}
    public String tempEventDate{get;set;}
    public Date allDayStartDate{get;set;}
    public Date allDayEndDate{get;set;}
    public String tempEventId{get;set;}
    public String tempviewEventId{get;set;}
    public list<calEvent> events{get;set;}
    public list<calEvent> events1{get;set;}
    public report reportId{get;set;}
    public Map<string,List<calEvent>> mapEvents{get;set;}
    public list<list<calEvent>> listEvent{get;set;}
    Public string selectedname{get;set;}
    Public string uname{get;set;}
    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated correctly
    string fullDayDateFormat = 'yyyy-MM-dd';
    string normalDayDateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ';
    
    public List<String> teams = new List<String>();
    public List<String> organizations = new List<String>();
    
    public calendarEvent_Controller(){
        if(!Test.isRunningTest()){ 
            reportId = [Select Id from Report where name='gcm support calendar' Limit 1];   
        }
        User userDetails = [Select Name,TimeZoneSidKey from User where id =: USerInfo.getUserId()];
        userTimeZone = userDetails.TimeZoneSidKey;
        uname = userDetails.Name;
        newEvent = new Event();
        showOnlyTeamEvents = true;
        showOnlyOrganizationEvents = true;
        // Start - Adding this line because the filter event is not working because "editEventDetails" is rendering with null values
        //editEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c, zoom_app__Make_it_Zoom_Meeting__c,eventSubType__c, StartDateTime, EndDateTime, Description, IsCancelled__c from Event WHERE zoom_app__Make_it_Zoom_Meeting__c = false LIMIT 1];
        //viewEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c, eventSubType__c, zoom_app__Make_it_Zoom_Meeting__c, StartDateTime, EndDateTime, Description, IsCancelled__c from Event WHERE zoom_app__Make_it_Zoom_Meeting__c = false LIMIT 1];
        
        //editEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c ,eventSubType__c, StartDateTime, EndDateTime, Description, IsCancelled__c from Event WHERE eventType__c = 'Leave' OR eventType__c = 'Busy' OR eventType__c = 'Bulletin' LIMIT 1];
        //viewEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c, eventSubType__c, StartDateTime, EndDateTime, Description, IsCancelled__c from Event WHERE eventType__c = 'Leave' OR eventType__c = 'Busy' OR eventType__c = 'Bulletin' LIMIT 1];
        
        editEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c ,eventSubType__c, StartDateTime, EndDateTime, Description, IsCancelled__c from Event WHERE eventType__c != null LIMIT 1];
        viewEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c, eventSubType__c, StartDateTime, EndDateTime, Description, IsCancelled__c from Event WHERE eventType__c != null LIMIT 1];
        
        
        // End - Adding this line because the filter event is not working because "editEventDetails" is rendering with null values
        //Default date population to the all day event fields based on user locale.
        //Added by vishnu on 14th Dec 2018 for populating today date/datetime.
        /*Date TodaysDate = System.today();
DateTime TodaysDateTime = DateTime.now();
new_allDayStartDateInString = String.valueof(TodaysDate.format());
new_allDayEndDateInString = String.valueof(TodaysDate.format());
new_allDayStartDateTimeInString = string.valueOf(TodaysDateTime.format());
new_allDayEndDateTimeInString = string.valueOf(TodaysDateTime.format());*/
    }
    //*****Added bu vishnu on 29th Jan 2018-START
    public String new_allDayStartDateInString{get;set;}
    public String new_allDayEndDateInString{get;set;}
    public String new_allDayStartDateTimeInString{get;set;}
    public String new_allDayEndDateTimeInString{get;set;}
    public String edit_allDayStartDateTimeInString{get;set;}
    public String edit_allDayEndDateTimeInString{get;set;}
    //*****Added bu vishnu on 29th Jan 2018-END
    public String allDayStartDateInString{get;set;}
    public String allDayEndDateInString{get;set;}
    
    //*********************************************************************************************************changeDate    
    public void changeDate(){
        System.debug('### Inside ChangeDate ###');
        allDayStartDateInString = '';
        allDayEndDateInString = '';
        System.debug('tempEventDate ======>'+tempEventDate);
        List<String> dateParts = tempEventDate.split('-');
        String presentTime = datetime.now().formatGMT('HH:mm:ss');
        String[] timeInArrays = presentTime.split(':');
        newEvent.StartDateTime = DateTime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]), Integer.valueOf(timeInArrays[0]), Integer.valueOf(timeInArrays[1]), Integer.valueOf(timeInArrays[2]));
        newEvent.EndDateTime = DateTime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]), Integer.valueOf(timeInArrays[0]), Integer.valueOf(timeInArrays[1]), Integer.valueOf(timeInArrays[2]));
        allDayStartDate = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
        allDayEndDate = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
        allDayStartDateInString = dateParts[1]+'/'+dateParts[2]+'/'+dateParts[0];
        allDayEndDateInString = dateParts[1]+'/'+dateParts[2]+'/'+dateParts[0];
    }
    
    public String editEventSubject{get;set;}
    public Event editEventDetails{get;set;}
    //*********************************************************************************************************editEvent
    public void editEvent(){
        System.debug('### Inside Edit Event ###');
        allDayStartDateInString = '';
        allDayEndDateInString = '';
        //editEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c, zoom_app__Make_it_Zoom_Meeting__c, eventSubType__c, StartDateTime, EndDateTime, Description, IsCancelled__c from Event where Id =: tempEventId AND zoom_app__Make_it_Zoom_Meeting__c = false];
        //editEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c, eventSubType__c, StartDateTime, EndDateTime, Description, IsCancelled__c from Event where Id =: tempEventId AND (eventType__c = 'Leave' OR eventType__c = 'Busy' OR eventType__c = 'Bulletin')];
        editEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c, eventSubType__c, StartDateTime, EndDateTime, Description, IsCancelled__c from Event where Id =: tempEventId AND eventType__c != null];
        editEventSubject =  editEventDetails.Subject;
        //*****Added by vishnu on 29th Jan 2018-START
        system.debug('### Event Id ==>'+editEventDetails.Id);
        system.debug('### Start Date/Time ==>'+editEventDetails.StartDateTime);
        system.debug('### End Date/Time ==>'+editEventDetails.EndDateTime);
        system.debug('### Start Date/Time In GMT==>'+editEventDetails.StartDateTime.format('MM/dd/yyyy hh:mm a'));
        system.debug('### End Date/Time IN GMT==>'+editEventDetails.EndDateTime.format('MM/dd/yyyy hh:mm a'));
        if((editEventDetails.StartDateTime != Null || editEventDetails.EndDateTime != Null)){
            if(editEventDetails.IsAllDayEvent == false){
                edit_allDayStartDateTimeInString = String.valueOf(editEventDetails.StartDateTime.format('MM/dd/yyyy hh:mm a'));
                edit_allDayEndDateTimeInString = String.valueOf(editEventDetails.EndDateTime.format('MM/dd/yyyy hh:mm a'));                
            }
            else{
                edit_allDayStartDateTimeInString = edit_allDayEndDateTimeInString = '';
            }
            //            edit_allDayStartDateTimeInString = String.valueOf(editEventDetails.StartDateTime.formatGmt('MM/dd/yyyy hh:mm a'));
            //            edit_allDayEndDateTimeInString = String.valueOf(editEventDetails.EndDateTime.formatGmt('MM/dd/yyyy hh:mm a'));	//11:59:59pm of end day
            system.debug('### edit_allDayStartDateTimeInString ==>'+ edit_allDayStartDateTimeInString);
            system.debug('### edit_allDayEndDateTimeInString' + edit_allDayEndDateTimeInString);
            
        }
        system.debug('### Start Date/Time ==>'+edit_allDayStartDateTimeInString);
        system.debug('### End Date/Time ==>'+edit_allDayEndDateTimeInString);
        //*****Added by vishnu on 29th Jan 2018-END
        if(editEventDetails.IsAllDayEvent == true){
            allDayStartDate = editEventDetails.StartDateTime.dateGmt();
            allDayEndDate = editEventDetails.EndDateTime.dateGmt();
            String[] startDateParts = String.valueOf(allDayStartDate).split('-');
            String[] endDateParts = String.valueOf(allDayEndDate).split('-');
            allDayStartDateInString = startDateParts[1]+'/'+startDateParts[2]+'/'+startDateParts[0];
            allDayEndDateInString = endDateParts[1]+'/'+endDateParts[2]+'/'+endDateParts[0];
            system.debug('### All Day Start Date/Time ==>'+allDayStartDateInString);
            system.debug('### All Day End Date/Time ==>'+allDayEndDateInString);
        }else{
            allDayStartDate =  allDayEndDate = null;
        }
    }
    public String viewEventSubject{get;set;}
    public Event viewEventDetails{get;set;}
    //*********************************************************************************************************viewEvent
    public void viewEvent(){
        System.debug('### Inside View Event ###');     
        allDayStartDateInString = '';
        allDayEndDateInString = '';
        //viewEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c,zoom_app__Make_it_Zoom_Meeting__c , eventSubType__c, StartDateTime, EndDateTime,
        //                    Description, IsCancelled__c from Event where Id =: tempviewEventId AND zoom_app__Make_it_Zoom_Meeting__c = false];
        
        //viewEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c, eventSubType__c, StartDateTime, EndDateTime,
        //                    Description, IsCancelled__c from Event where Id =: tempviewEventId AND (eventType__c = 'Leave' OR eventType__c = 'Busy' OR eventType__c = 'Bulletin')];
        
        viewEventDetails = [Select Id, OwnerId, Subject, IsAllDayEvent, eventType__c, eventSubType__c, StartDateTime, EndDateTime,
                            Description, IsCancelled__c from Event where Id =: tempviewEventId AND eventType__c != null];
        
        
        viewEventSubject =  viewEventDetails.Subject;
        if(viewEventDetails.IsAllDayEvent == true){
            allDayStartDate = viewEventDetails.StartDateTime.dateGmt();
            allDayEndDate = viewEventDetails.EndDateTime.dateGmt();
            String[] startDateParts = String.valueOf(allDayStartDate).split('-');
            String[] endDateParts = String.valueOf(allDayEndDate).split('-');
            allDayStartDateInString = startDateParts[1]+'/'+startDateParts[2]+'/'+startDateParts[0];
            allDayEndDateInString = endDateParts[1]+'/'+endDateParts[2]+'/'+endDateParts[0];
        }
    }
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('-NONE-','-None-'));
        options.add(new SelectOption('USER','User'));
        options.add(new SelectOption('REGION','Region'));
        return options;
    }
    //*********************************************************************************************************getTeamList
    // Gathering teams list - Start
    public List<SelectOption> getTeamList() {
        List<SelectOption> teamList = new List<SelectOption>();
        /*Schema.DescribeFieldResult teamFieldResult = CntrbnMdl_TSE__c.Team__c.getDescribe();
List<Schema.PicklistEntry> tle = teamFieldResult.getPicklistValues();
for(Schema.PicklistEntry gatherTeamValues : tle){
if(gatherTeamValues.isActive() == true){
teamList.add(new SelectOption(gatherTeamValues.getLabel(),gatherTeamValues.getValue()));
}
}*/
        teamList.add(new SelectOption('RTP', 'RTP'));
        teamList.add(new SelectOption('Minnesota', 'Minnesota'));
        teamList.add(new SelectOption('HQ', 'HQ'));
        teamList.add(new SelectOption('APAC', 'APAC'));
        teamList.add(new SelectOption('EMEA', 'EMEA'));
        teamList.add(new SelectOption('Weekend', 'Weekend'));
        teamList.add(new SelectOption('Colorado', 'Colorado'));
        teamList.add(new SelectOption('Other', 'Other'));
        teamList.add(new SelectOption('GRS', 'GRS')); // Added by Exafort for TS-9732
        return teamList;
    }
    //*********************************************************************************************************getOrganizationList
    public List<String> getTeamListValues() {
        return teams;
    }
    //*********************************************************************************************************getOrganizationList
    public void setTeamListValues(List<String> teams) {
        this.teams = teams;
    }
    // Gathering teams list - End
    //*********************************************************************************************************getOrganizationList
    // Gathering organizations list - Start
    public List<SelectOption> getOrganizationList() {
        List<SelectOption> orgList = new List<SelectOption>();
        Schema.DescribeFieldResult orgFieldResult = CntrbnMdl_TSE__c.Organization__c.getDescribe();
        List<Schema.PicklistEntry> ole = orgFieldResult.getPicklistValues();
        for(Schema.PicklistEntry gatherOrgValues : ole){
            if(gatherOrgValues.isActive() == true){
                orgList.add(new SelectOption(gatherOrgValues.getLabel(),gatherOrgValues.getValue()));
            }
        }
        return orgList;
    }
    //*********************************************************************************************************getOrganizationListValues
    public List<String> getOrganizationListValues() {
        return organizations;
    }
    //*********************************************************************************************************setOrganizationListValues
    public void setOrganizationListValues(List<String> organizations) {
        this.organizations = organizations;
    }
    // Gathering organizations list - End
    
    public Map<Id, String> eventAndItsOwnerMap = new Map<Id, String>();
    //public Map<Id, Id> eventAndItsOwnerMaponpageLoad = new Map<Id, Id>();
    public Set<Id> eventAndItsOwnerSetonpageLoad = new Set<Id>();
    //*********************************************************************************************************pageLoad
    public void pageLoad() {
        events = new list<calEvent>();
        //List <Event> EventPageLoadQuery = [Select Id, OwnerId, Subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c,zoom_app__Make_it_Zoom_Meeting__c ,eventSubType__c,IsCancelled__c from Event where eventType__c!= 'Bulletin' AND zoom_app__Make_it_Zoom_Meeting__c = false AND IsCancelled__c=false];
        
        //List <Event> EventPageLoadQuery = [Select Id, OwnerId, Subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c, eventSubType__c,IsCancelled__c from Event where eventType__c!= 'Bulletin' AND (eventType__c = 'Leave' OR eventType__c = 'Busy') AND IsCancelled__c=false];
        
        List <Event> EventPageLoadQuery = [Select Id, OwnerId, Subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c, eventSubType__c,IsCancelled__c from Event where eventType__c!= 'Bulletin' AND eventType__c != null AND IsCancelled__c=false];
        
        for(Event eachEvent : EventPageLoadQuery ){
            //eventAndItsOwnerMaponpageLoad.put(eachEvent.Id, eachEvent.OwnerId);
            eventAndItsOwnerSetonpageLoad.add(eachEvent.OwnerId);
        }
        List< CntrbnMdl_TSE__c> TseUserRecordsForEvents = [Select Id, Name, Employee_Name__c, Team__c, Organization__c from CntrbnMdl_TSE__c where Employee_Name__c In : eventAndItsOwnerSetonpageLoad];
        for(Event eachEventRec : EventPageLoadQuery ){
            for(CntrbnMdl_TSE__c eachTSE : TseUserRecordsForEvents ){
                If(eachEventRec.OwnerId == eachTSE.Employee_Name__c){
                    eventAndItsOwnerMap.put(eachEventRec.Id, eachTSE.Team__c);
                }
            }
        }
        system.debug('Event and Its owner MAP records--->'+eventAndItsOwnerMap);
        /*for(Event eachEvent : [Select Id, OwnerId, Subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c, eventSubType__c from Event where eventType__c!= 'Bulletin']){
for(CntrbnMdl_TSE__c eachTSE : [Select Id, Name, Employee_Name__c, Team__c, Organization__c from CntrbnMdl_TSE__c where Employee_Name__c =: eachEvent.OwnerId LIMIT 1]){
eventAndItsOwnerMap.put(eachEvent.Id, eachTSE.Team__c);
}
}*/
        firstTimePageLoad();
        
    }
    //*********************************************************************************************************firstTimePageLoad
    public void firstTimePageLoad(){
        
        Set<Id> eventUsers = new Set<Id>();
        Set<calEvent> eventSet = new Set<calEvent>();
        Set<String> eventUrlSet = new Set<String>();
        string profileName; // Added by Exafort for TS-9755
        listEvent = new List<List<calEvent>>();
        
        System.debug('teams =====>'+teams);
        System.debug('organizations =====>'+organizations);
        events.clear();
        
        // Added by Exafort for TS-9755
        id profileId = userinfo.getProfileId();
        List<Profile> profileList = [Select Name from Profile where Id =: profileId];
        if(profileList.size() > 0){
            for(profile loggedinProfileName : profileList){
                profileName = loggedinProfileName.name;
            }
        }
        
        List<CntrbnMdl_TSE__c> allContributionModelTSEs = [Select Id, Name, Employee_Name__c, Team__c, Organization__c from CntrbnMdl_TSE__c where Employee_Name__c != null];
        
        if(profileName == 'Support: GRS Engineer' || profileName == 'Support: GRS Manager' || profileName == 'Support: GRS Manager'){
            if(allContributionModelTSEs.size() > 0 || allContributionModelTSEs.size() > 0){
                for(CntrbnMdl_TSE__c ctse : allContributionModelTSEs){
                    if(ctse.Team__c == 'GRS'){
                        eventUsers.add(ctse.Employee_Name__c);
                    }
                }
            }
        }
        else{
            if(allContributionModelTSEs.size() > 0 || allContributionModelTSEs.size() > 0){
                for(CntrbnMdl_TSE__c ctse : allContributionModelTSEs){
                    if(ctse.Team__c != 'GRS'){
                        eventUsers.add(ctse.Employee_Name__c);
                    }
                }
            }
        }
        // End of TS-9755
        System.debug('eventUsers =====>'+eventUsers);        
        
        if(eventUsers.size() > 0 && eventUsers != null){
            //List <event> EventListForQuery = [Select id, OwnerId, subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c,zoom_app__Make_it_Zoom_Meeting__c,
            // eventSubType__c, IsCancelled__c from Event where OwnerId =: eventUsers AND IsCancelled__c=false AND StartDateTime >= LAST_N_WEEKS:4
            //  AND zoom_app__Make_it_Zoom_Meeting__c = false];
            //List <event> EventListForQuery = [Select id, OwnerId, subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c,
            //                              eventSubType__c, IsCancelled__c from Event where OwnerId =: eventUsers AND IsCancelled__c=false AND StartDateTime >= LAST_N_WEEKS:4
            //                            AND (eventType__c = 'Leave' OR eventType__c = 'Busy' OR eventType__c = 'Bulletin' )];                               
            
            
            List <event> EventListForQuery = [Select id, OwnerId, subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c,
                                              eventSubType__c, IsCancelled__c from Event where OwnerId =: eventUsers AND IsCancelled__c=false AND StartDateTime >= LAST_N_WEEKS:4
                                              AND eventType__c != null];                               
            
            
            for(Event evnt: EventListForQuery ){
                Date startDate = null;
                Date endDate = null;
                DateTime startDT = null;
                DateTime endDT = null;
                if(evnt.isAllDayEvent){
                    startDT = evnt.StartDateTime;
                    endDT = evnt.EndDateTime+1;
                    //Added +1 to EndDateTime according to the document of fullcalendar.io (DO NOT REMOVE "+1")
                }
                else{
                    startDT = evnt.StartDateTime;
                    endDT = evnt.EndDateTime;
                }
                calEvent myEvent = new calEvent(evnt.Id);
                //Added escapeJava() for the event subject to handled the double quote issue with the JSON on 23rd may 2019 -TS-5820.
                if(evnt.Subject != null){
                    myEvent.title =evnt.Subject.escapeJava();  
                }
                myEvent.allDay = evnt.isAllDayEvent;
                if(evnt.isAllDayEvent && startDT!=null){
                    myEvent.startString = startDT.formatGMT(fullDayDateFormat);
                    myEvent.endString = endDT.formatGMT(fullDayDateFormat);
                }
                else{
                    //Not placing .formatGMT for startDateTime to show the correct event start time on UI of full calendar
                    myEvent.startString = startDT.format(normalDayDateFormat);
                    myEvent.endString = endDT.format(normalDayDateFormat);
                    //Placing .formatGMT for endDateTime to show the correct event end time on UI of full calendar.
                }
                myEvent.url = '/'+evnt.Id;
                myEvent.eventType = evnt.eventType__c;
                if(eventAndItsOwnerMap.get(evnt.Id) == 'RTP'){
                    myEvent.className = 'event-personal-rtp';
                }
                else if(eventAndItsOwnerMap.get(evnt.Id) == 'Minnesota'){myEvent.className = 'event-personal-minnesota';}
                else if(eventAndItsOwnerMap.get(evnt.Id) == 'GRS'){myEvent.className = 'event-personal-GRS';} // Added by Exafort for TS-9732
                else if(eventAndItsOwnerMap.get(evnt.Id) == 'HQ'){myEvent.className = 'event-personal-hq';}
                else if(eventAndItsOwnerMap.get(evnt.Id) == 'APAC'){myEvent.className = 'event-personal-apac';}
                else if(eventAndItsOwnerMap.get(evnt.Id) == 'EMEA'){myEvent.className = 'event-personal-emea';}
                else if(eventAndItsOwnerMap.get(evnt.Id) == 'Weekend'){myEvent.className = 'event-personal-weekend';}
                else if(evnt.eventType__c == 'Bulletin'){myEvent.className = 'event-personal-bulletin';}
                else if(eventAndItsOwnerMap.get(evnt.Id) == 'Colorado'){myEvent.className = 'event-personal-colorado';}
                else if(eventAndItsOwnerMap.get(evnt.Id) == null || eventAndItsOwnerMap.get(evnt.Id) == 'Other' || eventAndItsOwnerMap.get(evnt.Id) == 'PSM'
                        || eventAndItsOwnerMap.get(evnt.Id) == 'TSM/TL' || eventAndItsOwnerMap.get(evnt.Id) == 'Infosight' || eventAndItsOwnerMap.get(evnt.Id) == 'Invalid'){myEvent.className = 'event-other';}
                events.add(myEvent);
                if(events.size() == 1000)
                {
                    //eventSet.addAll(events);
                    listEvent.add(events);
                    events = new List<calEvent>();
                    
                }
            }
            
            for(calEvent eachEvent : eventSet){
                String eventUrl = eachEvent.url;
                eventUrl = eventUrl.removeStart('/');
                eventUrlSet.add(eventUrl);
            }
            eventSet.addAll(events);
            events.clear();
            events.addAll(eventSet);
            listEvent.add(events);
        }
        System.debug('events =====>'+events);
        System.debug('events size =====>'+events.size());
    }
    
    //*********************************************************************************************************toggleTeamOrgEvents
    //
    // Team and Organization Toggle Events - Start
    public void toggleTeamOrgEvents(){
        try{
            Set<Id> eventUsers = new Set<Id>();
            listEvent = new List<List<calEvent>>();
            System.debug('teams =====>'+teams);
            System.debug('organizations =====>'+organizations);
            if(teams.size() > 0 || organizations.size() > 0){
                events.clear();
            }
            else{
                firstTimePageLoad();
            }
            List<CntrbnMdl_TSE__c> contributionModelTSEs_Teams = [Select Id, Name, Employee_Name__c, Team__c, Organization__c
                                                                  from CntrbnMdl_TSE__c where Team__c =: teams];
            List<CntrbnMdl_TSE__c> contributionModelTSEs_Orgs = [Select Id, Name, Employee_Name__c, Team__c, Organization__c 
                                                                 from CntrbnMdl_TSE__c where Organization__c =: organizations];
            if(contributionModelTSEs_Teams.size() > 0 || contributionModelTSEs_Orgs.size() > 0){
                for(CntrbnMdl_TSE__c ctse : contributionModelTSEs_Teams){
                    eventUsers.add(ctse.Employee_Name__c);
                }
                for(CntrbnMdl_TSE__c ctse : contributionModelTSEs_Orgs){
                    eventUsers.add(ctse.Employee_Name__c);
                }
            }
            if(eventUsers.size() > 0){
                //Added EventList query line by Exafort(vishnu) on 22/05/2018
                system.debug('@@@ line 318::' +eventUsers.size() + eventUsers);
                
                //List <Event> EventList = [Select id, subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c, zoom_app__Make_it_Zoom_Meeting__c ,eventSubType__c ,IsCancelled__c from Event where OwnerId =: eventUsers AND eventType__c!= 'Bulletin' AND zoom_app__Make_it_Zoom_Meeting__c = false AND IsCancelled__c=false];
                //List <Event> EventList = [Select id, subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c,eventSubType__c ,IsCancelled__c from Event where OwnerId =: eventUsers AND eventType__c!= 'Bulletin' AND (eventType__c = 'Leave' OR eventType__c = 'Busy') AND IsCancelled__c=false];
                List <Event> EventList = [Select id, subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c,eventSubType__c ,IsCancelled__c 
                                          from Event 
                                          where OwnerId =: eventUsers AND eventType__c != 'Bulletin' AND eventType__c != null AND IsCancelled__c = false];
                
                //Map <ID,Event> mapEventList = new Map <ID,Event>([Select id, subject, isAllDayEvent, StartDateTime, EndDateTime, eventType__c, eventSubType__c ,IsCancelled__c from Event where OwnerId =: eventUsers AND eventType__c!= 'Bulletin' AND IsCancelled__c=false]);
                
                //List <Event> EventList;
                for(Event evnt: EventList){
                    Date startDate = null;
                    Date endDate = null;
                    DateTime startDT = null;
                    DateTime endDT = null;
                    if(evnt.isAllDayEvent){
                        startDT = evnt.StartDateTime;
                        endDT = evnt.EndDateTime+1;
                        //Added +1 to EndDateTime according to the document of fullcalendar.io (DO NOT REMOVE +1)
                    }
                    else{
                        startDT = evnt.StartDateTime;
                        endDT = evnt.EndDateTime;
                    }
                    calEvent myEvent = new calEvent(evnt.Id);
                    myEvent.title = evnt.Subject;
                    myEvent.allDay = evnt.isAllDayEvent;
                    if(evnt.isAllDayEvent && startDT!=null){
                        myEvent.startString = startDT.formatGMT(fullDayDateFormat);
                        myEvent.endString = endDT.formatGMT(fullDayDateFormat);
                    }
                    else{
                        //Not placing .formatGMT for startDateTime to show the correct event start time on UI of full calendar
                        myEvent.startString = startDT.format(normalDayDateFormat);
                        myEvent.endString = endDT.format(normalDayDateFormat);
                        //Placing .formatGMT for endDateTime to show the correct event end time on UI of full calendar.
                    }
                    myEvent.url = '/'+evnt.Id;
                    myEvent.eventType = evnt.eventType__c;
                    if(eventAndItsOwnerMap.get(evnt.Id) == 'RTP'){
                        myEvent.className = 'event-personal-rtp';
                    }
                    else if(eventAndItsOwnerMap.get(evnt.Id) == 'Minnesota'){
                        myEvent.className = 'event-personal-minnesota';
                    }
                    else if(eventAndItsOwnerMap.get(evnt.Id) == 'GRS'){ // Added by Exafort for TS-9732
                        myEvent.className = 'event-personal-GRS';
                    }
                    else if(eventAndItsOwnerMap.get(evnt.Id) == 'HQ'){
                        myEvent.className = 'event-personal-hq';
                    }
                    else if(eventAndItsOwnerMap.get(evnt.Id) == 'APAC'){
                        myEvent.className = 'event-personal-apac';
                    }
                    else if(eventAndItsOwnerMap.get(evnt.Id) == 'EMEA'){
                        myEvent.className = 'event-personal-emea';
                    }
                    else if(eventAndItsOwnerMap.get(evnt.Id) == 'Weekend'){
                        myEvent.className = 'event-personal-weekend';
                    }
                    else if(evnt.eventType__c == 'Bulletin'){
                        myEvent.className = 'event-personal-bulletin';
                    }
                    else if(eventAndItsOwnerMap.get(evnt.Id) == 'Colorado'){
                        myEvent.className = 'event-personal-colorado';
                    }
                    else if(eventAndItsOwnerMap.get(evnt.Id) == null || eventAndItsOwnerMap.get(evnt.Id) == 'Other' || eventAndItsOwnerMap.get(evnt.Id) == 'PSM'
                            || eventAndItsOwnerMap.get(evnt.Id) == 'TSM/TL' || eventAndItsOwnerMap.get(evnt.Id) == 'Infosight' || 
                            eventAndItsOwnerMap.get(evnt.Id) == 'Invalid'){
                                myEvent.className = 'event-other';
                            }
                    
                    events.add(myEvent);
                    
                    if(events.size() == 1000)
                    {
                        //eventSet.addAll(events);
                        listEvent.add(events);
                        events = new List<calEvent>();
                        System.debug('Listevents size =====>'+listEvent.size());
                        System.debug('Listevents =====>'+listEvent);
                    }
                }
                Set<calEvent> eventSet = new Set<calEvent>();
                Set<String> eventUrlSet = new Set<String>();
                for(calEvent eachEvent : eventSet){
                    String eventUrl = eachEvent.url;
                    eventUrl = eventUrl.removeStart('/');
                    eventUrlSet.add(eventUrl);
                }
                eventSet.addAll(events);
                events.clear();
                events.addAll(eventSet);
                listEvent.add(events);
                
            }
            //mapEvents = new Map<string,List<calEvent>>();
            //mapEvents.put('events',events);
            System.debug('Listevents size =====>'+listEvent.size());
            System.debug('Listevents =====>'+listEvent);
            System.debug('events =====>'+events);
            System.debug('events size =====>'+events.size());
        }
        catch(exception ex)
        {
            throw ex;
        }
    }
    // Team and Organization Toggle Events - End
    //*********************************************************************************************************calEvent
    public class calEvent{
        public Id eventId{get;set;}
        public calEvent(Id tempEventId){
            eventId = tempEventId;
        }
        public Boolean equals(Object obj) {
            if (obj instanceof calEvent) {
                calEvent c = (calEvent)obj;
                return (eventId==c.eventId);
            }
            return false;
        }
        public Id hashCode() {
            return (eventId);
        }
        public String title{get;set;}
        public Boolean allDay {get;set;}
        public String startString{get;set;}
        public String endString{get;set;}
        public String url{get;set;}
        public String className{get;set;}
        public String eventType{get;set;}
    }
    //*********************************************************************************************************saveNewEvent
    //Method to save the New Event.
    public PageReference saveNewEvent(){
        if(selectedname=='USER' || selectedname=='REGION'){
            system.debug('SAVE EVENT IS FIRING');
            system.debug('newEvent.OwnerId ===> '+newEvent.OwnerId);
            system.debug('newEvent.Owner ===> '+newEvent.Owner.Name);
            system.debug('newEvent.eventType__c ===> '+newEvent.eventType__c);
            system.debug('newEvent.eventSubType__c ===> '+newEvent.eventSubType__c);
            system.debug('newEvent.Subject ===> '+eventSubject);
            system.debug('newEvent.StartDate Time ===> '+newEvent.StartDateTime);
            system.debug('newEvent.EndDate Time ===> '+newEvent.EndDateTime);
            //**************Added by vishnu on 29th Jan 2018 - START
            system.debug('newEvent.EndDate Time [Custom]===> '+new_allDayStartDateTimeInString);
            system.debug('newEvent.EndDate Time [Custom]===> '+new_allDayEndDateTimeInString);
            //**************Added by vishnu on 29th Jan 2018 - END
            if(newEvent.OwnerId != null && selectedname=='USER'){
                List<CntrbnMdl_TSE__c> queryToFetchEmployeeRelatedTSE = [Select Id, Name, Employee_Name__c, Team__c, Organization__c from CntrbnMdl_TSE__c where Employee_Name__c =: newEvent.OwnerId LIMIT 1];
                if(queryToFetchEmployeeRelatedTSE.size() > 0){
                    //newEvent.Related_Contribution_Model_TSE__c = queryToFetchEmployeeRelatedTSE[0].Id;
                    newEvent.WhatId = queryToFetchEmployeeRelatedTSE[0].Id;
                }
            }
            else if(newEvent.OwnerId == null ){
                system.debug('Inside Null user save event <====');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select User'));
                return null;
            }
            else if(newEvent.Assigned_To_Region__c == null && selectedname == 'REGION'){
                system.debug('Inside Null user save event <====');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select Region'));
                return null;
            }
            else if(newEvent.eventType__c == 'Manager on Duty' && selectedname == 'REGION'){
                //system.debug('Inside Null user save event <====');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Event cannot be created for "Manager on Duty" type for create event on Region'));
                return null;
            }
            newEvent.Subject = eventSubject;
            //**************Added by vishnu on 29th Jan 2018 to assign the Datetime values to Event Start & End datetime fields - START
            //system.debug('newEvent.EndDate Time C===> '+DateTime.parse(new_allDayStartDateTimeInString));
            //system.debug('newEvent.EndDate Time C===> '+DateTime.parse(new_allDayEndDateTimeInString));
            if(new_allDayStartDateTimeInString != '' && new_allDayEndDateTimeInString != ''){
                try{
                    newEvent.StartDateTime =  DateTime.parse(new_allDayStartDateTimeInString);
                    newEvent.EndDateTime = DateTime.parse(new_allDayEndDateTimeInString);
                }catch (exception e){
                    Datetime strtdtm = getConvertDateTime(new_allDayStartDateTimeInString);
                    system.debug('Rv testing start date time ==>'+strtdtm);
                    Datetime enddtm = getConvertDateTime(new_allDayEndDateTimeInString);
                    system.debug('Rv testing start date time ==>'+enddtm);
                    newEvent.StartDateTime =  strtdtm;
                    newEvent.EndDateTime = enddtm;
                }  
            }
            //**************Added by vishnu on 29th Jan 2018 to assign the Datetime values to Event Start & End datetime fields -END
            newEvent.Event_Start_Date__c = newEvent.StartDateTime;
            newEvent.Event_End_Date__c = newEvent.EndDateTime;
            if(newEvent.IsAllDayEvent){
                System.debug('new_allDayStartDateInString =====>'+new_allDayStartDateInString);
                System.debug('new_allDayEndDateInString =====>'+new_allDayEndDateInString);
                if(new_allDayStartDateInString != null && new_allDayStartDateInString != '' && new_allDayEndDateInString != null && new_allDayEndDateInString != '' ){
                    String[] startDateParts = new_allDayStartDateInString.split('/');
                    String[] endDateParts = new_allDayEndDateInString.split('/');
                    newEvent.StartDateTime = DateTime.newInstanceGMT(Integer.valueOf(startDateParts[2]), Integer.valueOf(startDateParts[0]), Integer.valueOf(startDateParts[1]), 0, 0, 0);
                    newEvent.EndDateTime = DateTime.newInstanceGMT(Integer.valueOf(endDateParts[2]), Integer.valueOf(endDateParts[0]), Integer.valueOf(endDateParts[1]), 0, 0, 0);
                    newEvent.Event_Start_Date__c = DateTime.newInstance(Integer.valueOf(startDateParts[2]), Integer.valueOf(startDateParts[0]), Integer.valueOf(startDateParts[1]), 0, 0, 0);
                    newEvent.Event_End_Date__c = DateTime.newInstance(Integer.valueOf(endDateParts[2]), Integer.valueOf(endDateParts[0]), Integer.valueOf(endDateParts[1]), 0, 0, 0);
                }
            }
            if(newEvent.StartDateTime != null && newEvent.EndDateTime != null && newEvent.IsAllDayEvent == false){
                Long StartDateTime = newEvent.StartDateTime.getTime();
                Long EndDateTime = newEvent.EndDateTime.getTime();
                Long milliseconds = EndDateTime - StartDateTime;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                newEvent.DurationInMinutes = (integer)minutes;
            }
            
            if(newEvent.eventType__c == null){
                system.debug('Inside Null type save event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Event Type'));
                return null;
            }
            if(newEvent.eventSubType__c == null && newEvent.eventType__c != 'Bulletin'){
                system.debug('Inside Null subtype save event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Event SubType'));
                return null;
            }
            if((eventSubject == null || eventSubject == '') && selectedname == 'USER'){
                system.debug('Inside Null Subject save event <===== '+newEvent.Subject +eventSubject);
                if(!Test.isRunningTest()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Subject'));
                    return null;
                } 
            }
            if(newEvent.IsAllDayEvent == true && (new_allDayStartDateInString == null || new_allDayStartDateInString == '')){
                system.debug('Inside Null Subject save event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Start Date'));
                return null;
            }
            if(newEvent.IsAllDayEvent == true && (new_allDayEndDateInString == null || new_allDayEndDateInString == '')){
                system.debug('Inside Null Subject save event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter End Date'));
                return null;
            }
            if(newEvent.IsAllDayEvent == false && newEvent.StartDateTime == null){
                system.debug('Inside Null Start Date time save event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Event Start Date/Time'));
                return null;
            }
            if(newEvent.IsAllDayEvent == false && newEvent.EndDateTime == null){
                system.debug('Inside Null End Date time save event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select End Date/Time'));
                return null;
            }
            try{
                System.debug('newEvent =====>'+newEvent);
                if(selectedname == 'USER'){
                    insert newEvent;
                }
                else{
                    calendarEvent_Controller.insertEventForUsers(newEvent);
                }
                if(newEvent.Id != null){
                    newEvent = new Event();
                    new_allDayStartDateInString = null;
                    new_allDayEndDateInString = null;
                }
                /*PageReference pr = new PageReference('/apex/calendarEvent');
pr.setRedirect(true);
return pr;*/
            }
            catch(Exception e){
                System.debug('Error Details =====>'+e.getMessage());
                return null;
            }
            if(teams.size() > 0 || organizations.size() > 0){
                toggleTeamOrgEvents();  
            }
            
            PageReference pr = new PageReference('/apex/calendarEvent');
            pr.setRedirect(true);
            return pr;  
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Create Event for'));  
        }
        return null;
    }
    //*********************************************************************************************************saveEditEvent
    public PageReference saveEditEvent(){
        System.debug('### Save Edit Event ###');
        //      try
        {
            System.debug('newEvent.OwnerId =====>'+editEventDetails.OwnerId);
            System.debug('editEventDetails.Description =====>'+editEventDetails.Description);
            
            system.debug('StartDateTime ---> ' + editEventDetails.StartDateTime.getTime());
            system.debug('EndDateTime ---> ' + editEventDetails.EndDateTime.getTime());
            
            
            if(newEvent.OwnerId != null){
                List<CntrbnMdl_TSE__c> queryToFetchEmployeeRelatedTSE = [Select Id, Name, Employee_Name__c, Team__c, Organization__c from CntrbnMdl_TSE__c where Employee_Name__c =: editEventDetails.OwnerId LIMIT 1];
                System.debug('queryToFetchEmployeeRelatedTSE =====>'+queryToFetchEmployeeRelatedTSE);
                if(queryToFetchEmployeeRelatedTSE.size() > 0)
                    //editEventDetails.Related_Contribution_Model_TSE__c = queryToFetchEmployeeRelatedTSE[0].Id;
                    editEventDetails.WhatId = queryToFetchEmployeeRelatedTSE[0].Id;
            }
            else if(editEventDetails.OwnerId == null){
                system.debug('Inside Null user save Edit event <====');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select User'));
                return null;
            }
                        
            if(editEventDetails.eventType__c == null){
                system.debug('Inside Null type save Edit event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Event Type'));
                return null;
            }
            if(editEventDetails.eventSubType__c == null && editEventDetails.eventType__c != 'Bulletin'){
                system.debug('Inside Null subtype save Edit event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Event SubType'));
                return null;
            }
            if(editEventSubject == null || editEventSubject == ''){
                system.debug('Inside Null Subject save Edit event <===== ');
                if(!Test.isRunningTest()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Subject'));
                    return null;
                }
            }
            system.debug('is all day--->'+editEventDetails.IsAllDayEvent);
            system.debug('all day start date string'+ allDayStartDateInString);
            if(editEventDetails.IsAllDayEvent == true && (allDayStartDateInString == null || allDayStartDateInString == '')){
                system.debug('Inside Null Subject Start Date save edit event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Start Date'));
                return null;
            }
            system.debug('all day start date string'+ allDayEndDateInString);
            if(editEventDetails.IsAllDayEvent == true && ( allDayEndDateInString == null || allDayEndDateInString == '')){
                system.debug('Inside Null Subject End Date save edit event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter End Date'));
                return null;
            }
            if(editEventDetails.IsAllDayEvent == false && (edit_allDayStartDateTimeInString == null || edit_allDayStartDateTimeInString == '')){
                system.debug('Inside Null Start Date time save Edit event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select Event Start Date/Time'));
                return null;
            }
            if(editEventDetails.IsAllDayEvent == false && (edit_allDayEndDateTimeInString == null || edit_allDayEndDateTimeInString == '')){
                system.debug('Inside Null End Date time save Edit event <===== ');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select End Date/Time'));
                return null;
            }
            if(editEventSubject !=null){
                editEventDetails.Subject = editEventSubject;    
            }  
            if(editEventDetails.StartDateTime != null)
                editEventDetails.Event_Start_Date__c = editEventDetails.StartDateTime;
            if(editEventDetails.EndDateTime != null)
                editEventDetails.Event_End_Date__c = editEventDetails.EndDateTime;
            
            editEventDetails.IsCancelled__c = editEventDetails.IsCancelled__c;
            //*****Added by vishnu on 29th Jan 2018 for assigning the Start and End Date/Time to the Event fields after edit.-Start
            system.debug('### '+edit_allDayStartDateTimeInString);
            system.debug('### '+edit_allDayEndDateTimeInString);
            try{
                editEventDetails.StartDateTime = Datetime.parse(edit_allDayStartDateTimeInString);
                editEventDetails.EndDateTime = Datetime.parse(edit_allDayEndDateTimeInString);
            }catch (exception e){
                Datetime edit_strtdtm = getConvertDateTime(edit_allDayStartDateTimeInString);
                system.debug('Rv testing start date time ==>'+edit_strtdtm);
                Datetime edit_enddtm = getConvertDateTime(edit_allDayEndDateTimeInString);
                system.debug('Rv testing start date time ==>'+edit_enddtm);
                editEventDetails.StartDateTime =  edit_strtdtm;
                editEventDetails.EndDateTime = edit_enddtm;
            } 
            //*****Added by vishnu on 29th Jan 2018 for assigning the Start and End Date/Time to the Event fields after edit.- End
            if(editEventDetails.IsAllDayEvent){
                String[] startDateParts = allDayStartDateInString.split('/');
                String[] endDateParts = allDayEndDateInString.split('/');
                editEventDetails.StartDateTime = DateTime.newInstanceGmt(Integer.valueOf(startDateParts[2]), Integer.valueOf(startDateParts[0]), Integer.valueOf(startDateParts[1]), 0, 0, 0);
                editEventDetails.EndDateTime = DateTime.newInstanceGmt(Integer.valueOf(endDateParts[2]), Integer.valueOf(endDateParts[0]), Integer.valueOf(endDateParts[1]), 0, 0, 0);
                editEventDetails.Event_Start_Date__c = DateTime.newInstanceGmt(Integer.valueOf(startDateParts[2]), Integer.valueOf(startDateParts[0]), Integer.valueOf(startDateParts[1]), 0, 0, 0);
                editEventDetails.Event_End_Date__c = DateTime.newInstanceGmt(Integer.valueOf(endDateParts[2]), Integer.valueOf(endDateParts[0]), Integer.valueOf(endDateParts[1]), 0, 0, 0);
            }
            System.debug('Just before update call : editEventDetails.Description =====>'+editEventDetails.Description);
            
             if((editEventDetails.EndDateTime < editEventDetails.StartDateTime)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'End: Event duration cannot be negative'));
                return null;
            }
            
            update editEventDetails;
        }
        //        catch(Exception e)
        {
            //			system.debug('Error Details =====>'+e.getMessage());
        }
        // 
        if(teams.size() > 0 || organizations.size() > 0){
            toggleTeamOrgEvents();
            // return null;    
        }
        
        PageReference pr = new PageReference('/apex/calendarEvent');
        pr.setRedirect(true);
        return pr;
        
    }
    //*********************************************************************************************************getConvertDateTime
    public DateTime getConvertDateTime(string strDT) {
        system.debug('getConvertDateTime called with strDT ===>'+strDT);
        if(strDT == null ||strDT == ''){
            return null;
        }
        String[] strDTDivided = strDT.split(' ');
        String[] DDate = strDTDivided.get(0).split('/');
        String TTime = strDTDivided.get(1);
        string month = DDate.get(0);
        string day = DDate.get(1);
        string year = DDate.get(2);
        string hour = TTime.split(':').get(0);
        string minute = TTime.split(':').get(1);
        string second = '00';
        if (strDTDivided.get(2) == 'PM') {
            hour = String.ValueOf(Integer.ValueOf(hour) + 12);
        }
        string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
        Datetime myDate = datetime.valueOf(stringDate);
        system.debug('datetime before return===>'+myDate);
        return myDate;
    }
    // Added by Exafort for TS-9347
    public static void insertEventForUsers(Event eve){
        list<Event> evntInsertList = new list<Event>();
        set<string> eventTypes = new set<string>();
        map<string,list<user>> userValMap = new map<string,list<user>>();
        eventTypes.add(eve.Assigned_To_Region__c);
        map<id,CntrbnMdl_TSE__c> contributionMap = new map<id,CntrbnMdl_TSE__c>();
        
        /*for(CntrbnMdl_TSE__c contributionTSE : [Select Id, Name, Employee_Name__c, Team__c, Organization__c 
from CntrbnMdl_TSE__c 
where Employee_Name__r.isactive = True and Team__c in:eventTypes]){
if(!contributionMap.containsKey(contributionTSE.Employee_Name__c)){
contributionMap.put(contributionTSE.Employee_Name__c,contributionTSE);
system.debug('contributionMap ' + contributionMap);
}
}*/
        
        List<CntrbnMdl_TSE__c> contributionModelRec = new List<CntrbnMdl_TSE__c>();
        
        // Query only active users CntrbnMdl records based on event type
        for(CntrbnMdl_TSE__c tse : [Select Id, Name, Employee_Name__c, Employee_Name_Text__c, Team__c, Organization__c 
                                    from CntrbnMdl_TSE__c 
                                    where Employee_Name__r.isactive = True and Team__c in:eventTypes]){
                                        contributionModelRec.add(tse);
                                    }
        
        // Insert bulk records
        for(CntrbnMdl_TSE__c contributionRecords : contributionModelRec){
            Event newEvnt = new Event();
            newEvnt.OwnerId = contributionRecords.Employee_Name__c;
            newEvnt.eventType__c = eve.eventType__c;
            newEvnt.eventSubType__c = eve.eventSubType__c;
            // Added by Exafort for TS-9565
            newEvnt.Subject = contributionRecords.Employee_Name_Text__c +' '+ eve.eventType__c;
            /*if(eve.Subject == null || eve.Subject == ''){
newEvnt.Subject = contributionRecords.Employee_Name_Text__c +' '+ eve.eventType__c;    
}
else{
newEvnt.Subject = eve.Subject;
}*/
            newEvnt.IsAllDayEvent = eve.IsAllDayEvent;
            newEvnt.StartDateTime = eve.StartDateTime;
            newEvnt.EndDateTime = eve.EndDateTime;
            newEvnt.WhatId  = contributionRecords.Id;
            newEvnt.Event_Start_Date__c = eve.Event_Start_Date__c;
            newEvnt.Event_End_Date__c = eve.Event_End_Date__c;
            evntInsertList.add(newEvnt);
        }
        // End of TS-9347        
        if(evntInsertList.size()>0){
            system.debug('Insert===>'+evntInsertList.size());
            system.debug('evntInsertList:'+evntInsertList);
            try {
                insert evntInsertList;
            }
            catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
    }
}