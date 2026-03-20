/*
* Class: PopulateEventsFromSupportCalendarUtility
* The purpose of the class is to update the Contribution model is user is currently "On shift" considering the events on the Support calendar. This calculates for all active employees
* Author: Exafort
* Date: 18th September 2022
* */
public class PopulateEventsFromSupportCalendarUtility {
    // Added by Exafort for TS-9287
    //    public Boolean managerOnDutyFromCalendar = False;
    
    public void execute(Database.BatchableContext BC, List<CntrbnMdl_TSE__c>  TseRecordsToProcess){
        try{
            Boolean isNowOnShift = false, isOnLeave = false, noEvents = false, nullvalues = false, managerOnDutyFromCalendar = False;
            Id managerId;
            
            System.debug('Contribution Model TSE User ====>>'+TseRecordsToProcess);
            List<CntrbnMdl_TSE__c> TseRecordsForUpdate = new List<CntrbnMdl_TSE__c>();
            List<CntrbnMdl_TSE__c> tseManagerRecordsUpdate = new List<CntrbnMdl_TSE__c>();
            Set<id> managerIds = new Set<id>();
            //Integer totalCallouts = Limits.getLimitCallouts();
            //system.debug('totalCallouts = ' + totalCallouts);
            for(CntrbnMdl_TSE__c tseRecord : TseRecordsToProcess)
            {
                /*************************************************************/
                isNowOnShift = false;
                isOnLeave = false;
                noEvents = false;
                nullvalues = false;
                managerOnDutyFromCalendar = False;
                
                tseRecord.Batch_Processed_Message__c = '';
                List<string> shiftDaysList = new List<string>();
                set<string> shiftDaysset = new set<string>();
                system.debug('Contribution Model TSE User ====>>'+tseRecord.Name+' ### Contribution Model TSE User Id ====>>'+tseRecord.Id);
                managerId = tseRecord.Manager__c;
                system.debug('managerId = ' + managerId);
                managerIds.add(tseRecord.Manager__c);
                //Date and Time fields for currentday,current time and Local Date/Time.
                DateTime currentDate = System.now();
                Time currentTime = System.now().Time();
                String userTimeZone = tseRecord.Employee_Name__r.TimeZoneSidKey;
                system.debug('userTimeZone:' + userTimeZone);
                Datetime dateTimeInGMT = currentDate;
                DateTime perviousDateTime = dateTimeInGMT.addDays(-1);
                system.debug('perviousDateTime --> ' + perviousDateTime);
                system.debug('dateTimeInGMT: ' + dateTimeInGMT);
                String currentDay = dateTimeInGMT.format('EEEE');
                system.debug('Current Day --> ' + currentDay);
                String PreviousDay = perviousDateTime.format('EEEE');
                system.debug('Previous Day --> ' + PreviousDay);
                //String currentDay = System.now().format('EEEE');
                DateTime LocalDateTime = DateTime.newInstanceGmt(System.now().year(), System.now().month(), System.now().day(), System.now().Hour(), System.now().Minute(), System.now().Second());
                //Splitting the comma separated shift days formula field.
                if(tseRecord.True_Days__c != null){
                    System.debug('====>>Inside after first for loop ====>>');
                    if(tseRecord.True_Days__c.contains(',')){
                        shiftDaysList = tseRecord.True_Days__c.split(',');
                        System.debug('Shift Day list ====>>'+shiftDaysList);
                    }
                    else if(!tseRecord.True_Days__c.contains(',')){
                        shiftDaysList.add(tseRecord.True_Days__c);
                        System.debug('Shift Day list in else if ====>>'+shiftDaysList);
                    }
                    System.debug('shift days list ====>>'+shiftDaysList.size());
                    //Adding shift days to a Set to aviod duplicates.
                    for(String s: shiftDaysList){
                        shiftDaysset.add(s);
                    }
                }else{
                    //Error message for batch if Shift days are null.
                    tseRecord.Batch_Processed_Message__c += tseRecord.Batch_Processed_Message__c !=null? tseRecord.Batch_Processed_Message__c+'  Please provide "SHIFT DAYS" for the Contribution Model User.'+'\r\n'+'\r\n':'  Please provide "SHIFT DAYS" for the Contribution Model User.'+'\r\n'+'\r\n';
                }
                /*************************************************************/
                system.debug('@@@currentDay ====>>'+currentDay);
                
                if((!shiftDaysset.isEmpty() && (shiftDaysset.contains(currentDay)) || shiftDaysset.contains(PreviousDay))){
                    system.debug('Shift days set items ======>>'+shiftDaysset);
                    System.debug('currentTime ======>>'+currentTime);
                    System.debug('currentDate ======>>'+currentDate);
                    System.debug('currentDate Format======>>'+currentDate.format());
                    If(tseRecord.Enter_Starttime__c != null && (tseRecord.Shift_Length__c != null && Decimal.valueOf(tseRecord.Shift_Length__c) != null)){
                        System.debug('TSE start date time  ======>>'+tseRecord.Enter_Starttime__c);
                        //calculating End shift Date Time and Current day with shift time.
                        DateTime currentDateWithSameTime = DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), tseRecord.Enter_Starttime__c.hour(), tseRecord.Enter_Starttime__c.minute(), tseRecord.Enter_Starttime__c.second());
                        System.debug('currentDateWithSameTime ======>>'+currentDateWithSameTime);
                        string getShiftTimeInMinutes = String.valueOf(Decimal.valueOf(tseRecord.Shift_Length__c) * 60);
                        System.debug('Shift length in minutes=====>'+getShiftTimeInMinutes);
                        Datetime EndShiftDatetime = currentDateWithSameTime.addMinutes(Integer.valueOf(getShiftTimeInMinutes));
                        System.debug('EndShiftDatetime ======>>'+EndShiftDatetime);
                        DateTime YesterdaySameTime = currentDateWithSameTime.addDays(-1);
                        DateTime YesterdayEndShiftDatetime = EndShiftDatetime.addDays(-1);
                        System.debug('currentDate ======>>'+currentDate);
                        System.debug('YesterdaySameTime ======>>'+YesterdaySameTime); 
                        System.debug('YesterdayEndShiftDatetime ======>>'+YesterdayEndShiftDatetime);
                        if((currentDate >= YesterdaySameTime && currentDate <= YesterdayEndShiftDatetime && shiftDaysset.contains(PreviousDay))){
                            system.debug('Entered to perious day logic, TSE shift length extends on the next day');
                        }
                        if((currentDate >= currentDateWithSameTime && currentDate <= EndShiftDatetime && shiftDaysset.contains(currentDay))){
                            system.debug('TSE works on the current day');
                        }
                        if(((currentDate >= currentDateWithSameTime && currentDate <= EndShiftDatetime && shiftDaysset.contains(currentDay)) || (currentDate >= YesterdaySameTime && currentDate <= YesterdayEndShiftDatetime && shiftDaysset.contains(PreviousDay)))){
                            //if(currentDate >= currentDateWithSameTime && currentDate <= EndShiftDatetime || currentDate >= YesterdaySameTime && currentDate <= YesterdayEndShiftDatetime){
                            isNowOnShift = true ;
                        }
                        else {
                            isNowOnShift = false ;
                        }
                    }else{
                        //Error message for batch if Shift length and Shift Start time are null.
                        nullvalues = true;
                        tseRecord.Batch_Processed_Message__c = tseRecord.Batch_Processed_Message__c != null ? tseRecord.Batch_Processed_Message__c + ' Please provide "SHIFT LENGTH / START TIME" for the Contribution Model User.'+'\r\n'+'\r\n':' Please provide "SHIFT LENGTH / START TIME" for the Contribution Model User.'+'\r\n'+'\r\n';
                    }
                    system.debug('On Shift ====>'+isNowOnShift);
                }
                
                // Added By Exafort
                DateTime nextShiftStartDate = getTseDefaultNextStartDateTime(tseRecord);
                setTseNextCalendarEventBasedStartDateTime(tseRecord,nextShiftStartDate);
                system.debug('Next Start DateTime of TSE ' + tseRecord.Next_Start_DateTime__c);
                
                if(tseRecord.Events.size() > 0){
                    System.debug('Looping through Events ======>>');
                    //Loop through events associated to the Model TSE User.
                    boolean nearestRec = false;
                    for(Event eventRecord: tseRecord.Events)
                    {
                        System.debug('record Id comparision <=====>'+tseRecord.Id+'<=======>'+eventRecord.WhatId);
                        //checking the Model User Id with the event What Id.
                        if(tseRecord.Id == eventRecord.WhatId){
                            System.debug('::::all day event====>>'+eventRecord.IsAllDayEvent+'::::event type====>>'+eventRecord.eventType__c);
                            //checking the event type and All day event && eventRecord.IsAllDayEvent == true
                            if(eventRecord.eventType__c == 'Leave'){
                                System.debug('Current Date ====>'+currentDate.date()+'== Start date time====>'+Date.valueOf(eventRecord.StartDateTime));
                                System.debug('Current Date ====>'+currentDate.date()+'== End date time====>'+Date.valueOf(eventRecord.EndDateTime));
                                //checking whether current date is with in the event Start and End date.IF yes,user is on leave.
                                if(eventRecord.IsAllDayEvent == True){
                                    if( currentDate.date() >= Date.valueOf(eventRecord.StartDateTime) &&
                                       currentDate.date() <= Date.valueOf(eventRecord.EndDateTime) ){
                                           isOnLeave = true;
                                           break;
                                       }
                                    else{
                                        isOnLeave = false;
                                    }
                                }
                                // Added by exafort for TS-9347
                                if(eventRecord.IsAllDayEvent == False){
                                    system.debug('event subject : ' + eventRecord.Subject); 
                                    system.debug('all day leave evnt false'); 
                                    if(system.now() >= eventRecord.StartDateTime &&
                                       system.now() <= eventRecord.EndDateTime){
                                           isOnLeave = true;
                                           break;
                                       }
                                    else{
                                        isOnLeave = false;
                                    }
                                }
                                //End of TS-9347
                            }
                            // Added by Exafort for TS-9287
                            managerOnDutyFromCalendar = False;
                            if(eventRecord.eventType__c == 'Manager on Duty'){
                                system.debug('Event Id --> ' + eventRecord.Id);
                                system.debug('Entered into the Manager on Duty.' + Date.valueOf(eventRecord.StartDateTime));
                                system.debug('Current time in Gmt --> ' + system.now());
                                system.debug('Current date --> ' + currentDate.dayGmt() + 'Event Start Date --> ' + eventRecord.StartDateTime);
                                system.debug('Event start date and time --> ' + eventRecord.EndDateTime);
                                if(eventRecord.IsAllDayEvent == False){
                                    system.debug('Entered into all day event as false');
                                    if(system.now() >= eventRecord.StartDateTime &&
                                       system.now() <= eventRecord.EndDateTime){
                                           system.debug('Manager is on duty for the particular time');
                                           managerOnDutyFromCalendar = True;
                                           break;
                                       }
                                    else{
                                        managerOnDutyFromCalendar = False;
                                    }
                                }
                                if(eventRecord.IsAllDayEvent == True){
                                    if( currentDate.date() >= Date.valueOf(eventRecord.StartDateTime) &&
                                       currentDate.date() <= Date.valueOf(eventRecord.EndDateTime)){
                                           managerOnDutyFromCalendar = True;
                                           break;
                                       }
                                    else{
                                        managerOnDutyFromCalendar = False;
                                    }
                                }
                            }
                            // End of TS-9287
                        }
                    }
                }else{
                    noEvents = true;
                    system.debug('====>> No events for the contribution model TSE ====>>'+noEvents);
                }
                System.debug('isNowOnShift====>>' + isNowOnShift);
                System.debug('isOnLeave====>>' + isOnLeave);
                System.debug('noEvents====>>' + noEvents);
                System.debug('nullvalues====>>' + nullvalues);
                /*************************************************************/
                
                // Added by Exafort for TS-9287
                tseRecord.MOD_Now_from_Calendar__c = managerOnDutyFromCalendar;
                system.debug('managerOnDuty Value : ' + managerOnDutyFromCalendar + ' for tseRecord : ' + tseRecord.id);
                // End of TS-9287
                
                //Assigning the values to the fields in Contribution Model TSE related to Is Now SCheduled and Batch processing.
                if( isNowOnShift == true && isOnLeave == false){
                    System.debug('@@@===> TSE On Shift');
                    tseRecord.isNowScheduled__c = true;
                    tseRecord.Batch_Processed_Message__c += ' Success.';
                    tseRecord.Last_Batch_Processed_Date_Time__c = system.now();
                }
                else{
                    System.debug('TSE Off Shift<===@@@');
                    tseRecord.isNowScheduled__c = false;
                    tseRecord.Batch_Processed_Message__c += ' Success.';
                    tseRecord.Last_Batch_Processed_Date_Time__c = system.now();
                }    
                
                /*************************************************************/
                //adding the contribution model TSE records to a list for updation.
                TseRecordsForUpdate.add(tseRecord);
                system.debug('TseRecordsForUpdate --> ' + TseRecordsForUpdate);
                system.debug('######################################################################');
            }
            system.debug('Total Number of Managers = ' + managerIds.size());
            system.debug('Manager Ids = ' + managerIds);
            
            if(!managerIds.isEmpty()){
                //                for(CntrbnMdl_TSE__c contributionOnUpdate : [Select Id, Employee_Name_Text__c from CntrbnMdl_TSE__c where Employee_Name__c =: managerId]){
                for(CntrbnMdl_TSE__c contributionOnUpdate : [Select Id, Employee_Name_Text__c from CntrbnMdl_TSE__c where Employee_Name__c In: managerIds]){                
                    system.debug('contributionOnUpdate --> ' + contributionOnUpdate);
                    contributionOnUpdate.Is_TSE_Manager__c = True;
                    tseManagerRecordsUpdate.add(contributionOnUpdate);
                }
            }
            
            // Update contribution model TSE Manager records
            if(!tseManagerRecordsUpdate.isEmpty()){
                update tseManagerRecordsUpdate;
            }
            
            //updating the contribution model TSE records.
            if(!TseRecordsForUpdate.isEmpty()){
                update TseRecordsForUpdate;
            }
        }
        catch(Exception e){
            system.debug('####===> Error in updating the contribution model TSE records ==>'+e.getMessage());
        }        
    }
    
    /*
* Returns TSEs next start date time without calendar events consideration
*/ 
    private datetime getTseDefaultNextStartDateTime(CntrbnMdl_TSE__c  tseRecord){
        //	Defaults to TSE's work week based start date time
        System.debug('****	Entered on the new Method getTseDefaultNextStartDateTime	****');
        dateTime currentDateShiftStart = getTseDailyStartDateTime(tseRecord);
        DateTime nextShiftStartDate = null;
        // TSE start DateTime and shift length should not be null
        if(tseRecord.Enter_Starttime__c != null && tseRecord.Shift_Length__c != null && currentDateShiftStart != null){            
            DateTime shiftStart = tseRecord.Enter_Starttime__c;
            Integer shiftLength = integer.valueOf(tseRecord.Shift_Length__c);
            
            system.debug('currentDateShiftStart = ' + currentDateShiftStart);
            
            DateTime shiftEndDateTime = currentDateShiftStart.addHours(shiftLength);
            
            system.debug('currentDateShiftStart afer adding shift length = ' + currentDateShiftStart);
            
            system.debug('Shift End Time from current day ' + shiftEndDateTime);
            dateTime localDt = getLocalDateTime();
            string currentWeekDay = currentDateShiftStart.format('EEEE');
            system.debug('shiftStartTimeForCurrentUser = ' + currentDateShiftStart +  ', Current Day =' + currentWeekDay);
            
            string workingDays = tseRecord.True_Days__c;
            nextShiftStartDate = findNextShiftStartDate(currentDateShiftStart, shiftLength, workingDays, system.now(), 0, 0, null, null);
        }
        return nextShiftStartDate;
    }
    
    /*
* Sets the next working datetime for TSE. If in shift now, it is the start of the shift date time
*/
    private void setTseNextCalendarEventBasedStartDateTime(CntrbnMdl_TSE__c tseRecord, DateTime defaultNextShiftStartDate){
        system.debug('****	Entered setTseNextCalendarEventBasedStartDateTime	****');
        system.debug('tseRecord = ' + tseRecord.Id + 'Event Size = ' + tseRecord.Events.size() + ', defaultNextShiftStartDate = ' + defaultNextShiftStartDate);
        
        // Set default next shift start datetime
        tseRecord.Next_Start_DateTime__c = defaultNextShiftStartDate;
        
        if(!(tseRecord.Enter_Starttime__c != null && tseRecord.Shift_Length__c != null)){
            return;
        }
        if(tseRecord.Events.size() <= 0){
            return;
        }
        if (defaultNextShiftStartDate == null){
            return;
        }
        
        datetime nextStartDateTime = null, previousNextStartDateTime, previousEventEndDateTime;
        //	Get All day events based start time
        dateTime allDayEventsBasedStartDateTime = getTseNextCalendarEventStartDateTime(tseRecord, defaultNextShiftStartDate, true);
        //	Get partial day events based start time
        dateTime partialDayEventsBasedStartDateTime1 = getTseNextCalendarEventStartDateTime(tseRecord, defaultNextShiftStartDate, false);
        
        system.debug('allDayEventsBasedStartDateTime = ' + allDayEventsBasedStartDateTime + ', partialDayEventsBasedStartDateTime1 = ' + partialDayEventsBasedStartDateTime1);
        
        if(allDayEventsBasedStartDateTime != null && partialDayEventsBasedStartDateTime1 != null){        
            //	Earliest of the one is the start time
            tseRecord.Next_Start_DateTime__c = (allDayEventsBasedStartDateTime < partialDayEventsBasedStartDateTime1 ? allDayEventsBasedStartDateTime : partialDayEventsBasedStartDateTime1);
        }else if(allDayEventsBasedStartDateTime != null){
            //	No qualifying partials yet, so all day events based start time
            tseRecord.Next_Start_DateTime__c = allDayEventsBasedStartDateTime;
            
            //	There is a possiblity that upon return from PTO, there is a late start on the day
            dateTime partialDayEventsBasedStartDateTime2 = getTseNextCalendarEventStartDateTime(tseRecord, allDayEventsBasedStartDateTime, false);
            system.debug('allDayEventsBasedStartDateTime = ' + allDayEventsBasedStartDateTime + ', partialDayEventsBasedStartDateTime1 = ' + partialDayEventsBasedStartDateTime1 + ', partialDayEventsBasedStartDateTime2 = ' + partialDayEventsBasedStartDateTime2);
            
            if (partialDayEventsBasedStartDateTime2 != null){
                tseRecord.Next_Start_DateTime__c = partialDayEventsBasedStartDateTime2;
            }
        }else if (partialDayEventsBasedStartDateTime1 != null){
            //	Partial based start time
            tseRecord.Next_Start_DateTime__c = partialDayEventsBasedStartDateTime1;
        }
    }   
    
    /*
* Returns shift start datetime based contition Type
* conditionType (0 - work week days based, 1 - all day events based, 2 - partial day events based)
*/ 
    private DateTime findNextShiftStartDate(DateTime currentDateShiftStart, integer shiftLength, string workingDays, DateTime currentDateTime, integer dayStartIndex, integer conditionType, datetime eventStartDateTime, datetime eventEndDateTime){
        dateTime nextShiftStartDate = null;
        
        system.debug('findNextShiftStartDate called Params: currentDateShiftStart = ' + currentDateShiftStart + ', dayStartIndex = ' + dayStartIndex + ', eventStartDateTime = ' + eventStartDateTime + ', eventEndDateTime = ' + eventEndDateTime +
                     ', workingDays = ' + workingDays + ', currentDateTime = ' + currentDateTime);
        if (workingDays == null){
            system.debug('Working days not set, returning');
            return nextShiftStartDate;
        }
        
        if (eventStartDateTime < currentDateShiftStart && eventEndDateTime < currentDateShiftStart){
            system.debug('Past Event, returning');
            return nextShiftStartDate;
        }
        
        if (conditionType == 1){
            if (eventStartDateTime > currentDateShiftStart){
                system.debug('Event start time is in the later than shift start, returning');
                return nextShiftStartDate;
            }
        }
        
        if(conditionType == 2){
            dateTime currentDateShiftEnd = currentDateShiftStart.addHours(shiftLength);
            
            // Added by exafort for ticket TS-10015 begin
            // added new logic if event is on between shift hours in a day
            if (eventStartDateTime < currentDateShiftStart && eventEndDateTime < currentDateShiftStart){	// Past event
                system.debug('Past Event, returning');
                return null;
            }
            if ((currentDateShiftStart  < eventEndDateTime && eventEndDateTime < currentDateShiftEnd) && (eventStartDateTime <= currentDateShiftStart)){	// event end is within current shift window
                system.debug('Future Event, returning');
                return eventEndDateTime.addSeconds(1);
            }
            if (currentDateShiftStart  < eventEndDateTime && eventEndDateTime < currentDateShiftEnd && currentDateShiftStart < eventStartDateTime && eventStartDateTime < currentDateShiftEnd){	// event end is within current shift window
                system.debug('event start and end, on same day');
                return null;
            }
            
            
            if (currentDateShiftStart  <= eventStartDateTime  && eventEndDateTime < currentDateShiftEnd ){
                system.debug('Current event, Affects shift start');
                return eventStartDateTime;
            }
            // End of TS-10015 
            
            system.debug('Returning null because none of the conditions met ****not expected****');
            return null;
        }
        integer dayEndIndex = 30;
        if(conditionType == 0){
            dayEndIndex = 6;
        }
        
        for(integer dayIndex = dayStartIndex; dayIndex <= dayEndIndex; dayIndex++){
            system.debug('** inside for loop, dayIndex ' + dayIndex);
            DateTime currentDateShiftStartWithDayAdded = currentDateShiftStart.addDays(dayIndex);
            DateTime currentDateShiftEndWithDayAdded = currentDateShiftStartWithDayAdded.addHours(shiftLength);
            string weekDay = currentDateShiftStartWithDayAdded.format('EEEE');
            
            system.debug('weekDay = ' + weekDay + ', currentDateTime = ' + currentDateTime + ', currentDateShiftStartWithDayAdded =' + currentDateShiftStartWithDayAdded);
            
            if(workingDays.contains(weekDay)){
                if(conditionType == 0 && currentDateTime < currentDateShiftStartWithDayAdded){
                    nextShiftStartDate = currentDateShiftStartWithDayAdded;
                    break;
                }
                if(conditionType == 1){
                    system.debug('In ConditionType 1, currentDateShiftStartWithDayAdded = ' + currentDateShiftStartWithDayAdded + ', currentDateShiftEndWithDayAdded = ' + currentDateShiftEndWithDayAdded + ', eventStartDateTime = ' + eventStartDateTime + ', eventEndDateTime = ' + eventEndDateTime);
                    // TSEs shift start is within the event start and endtime, skip that day					
                    if(eventStartDateTime <= currentDateShiftStartWithDayAdded && currentDateShiftStartWithDayAdded <= eventEndDateTime){
                        //	TSE has whole day event
                        continue;
                    }
                    if(!(eventStartDateTime <= currentDateShiftStartWithDayAdded && currentDateShiftEndWithDayAdded <= eventEndDateTime)){
                        nextShiftStartDate = currentDateShiftStartWithDayAdded;
                        break;
                    }
                }
                if(conditionType == 2){
                    //	It should not come here
                    system.debug('In ConditionType 2, currentDateShiftStartWithDayAdded = ' + currentDateShiftStartWithDayAdded + ', currentDateShiftEndWithDayAdded = ' + currentDateShiftEndWithDayAdded + ', eventStartDateTime = ' + eventStartDateTime + ', eventEndDateTime = ' + eventEndDateTime);
                }
            }
        }
        
        if(nextShiftStartDate != null){
            system.debug('Next Shift Start date ' + nextShiftStartDate);
        }
        return nextShiftStartDate;
    }
    
    /*
* Returns daily start date time, calendar events not considered
*/ 
    private datetime getTseDailyStartDateTime(CntrbnMdl_TSE__c tseRecord){
        system.debug('tseRecord = ' + tseRecord);
        DateTime dailyStartDateTime = null;
        // TSE start DateTime and shift length should not be null
        if(tseRecord.Enter_Starttime__c != null && tseRecord.Shift_Length__c != null){
            return DateTime.newInstance(System.now().year(), System.now().month(), System.now().day(), tseRecord.Enter_Starttime__c.hour(), tseRecord.Enter_Starttime__c.minute(), tseRecord.Enter_Starttime__c.second());            
        }
        return null;
    }
    
    /*
* Returns start datetime based on allDayEvent = true or false
*/ 
    private DateTime getTseNextCalendarEventStartDateTime(CntrbnMdl_TSE__c tseRecord, DateTime currDateShiftStart, boolean allDayEvent){
        system.debug('****	Entered getTseNextCalendarEventStartDateTime for allDayEvent = ' + allDayEvent);
        system.debug('tseRecord = ' + tseRecord.Id + ', Event Size = ' + tseRecord.Events.size());        
        
        if(!(tseRecord.Enter_Starttime__c != null && tseRecord.Shift_Length__c != null)){
            return null;
        }
        
        if(tseRecord.Events.size() <= 0){
            return null;
        }
        
        boolean nextPotentialStartFound = false;
        datetime nextStartDateTime = null, previousNextStartDateTime, previousEventEndDateTime;
        
        // Event Record found for the TSE
        for(Event eventRecord : tseRecord.Events){
            if(tseRecord.Id == eventRecord.WhatId && eventRecord.eventType__c == 'Leave' && eventRecord.IsAllDayEvent == allDayEvent){
                system.debug('TSE has event record ' + eventRecord);
                DateTime currDateTime = System.now();
                Date currDate = Date.valueOf(currDateTime);
                system.debug('currDate = ' + currDate + ', eventRecord.StartDateTime = ' + eventRecord.StartDateTime + ', eventRecord.EndDateTime =' + eventRecord.EndDateTime);
                dateTime gmtEventStartDateTime = eventRecord.StartDateTime;
                dateTime gmtEventEndDateTime = eventRecord.EndDateTime;
                
                //	All days events need some adjustments, because they are stored without time component
                if(eventRecord.IsAllDayEvent == true){
                    system.debug('adjusting event start and end to gmt values, before adjustment gmtEventStartDateTime =  ' + gmtEventStartDateTime + ', gmtEventEndDateTime = ' + gmtEventEndDateTime);
                    integer tzOffSetInSeconds = getCurrentUserTimeZoneOffsetSeconds();
                    gmtEventStartDateTime = eventRecord.StartDateTime.addSeconds(tzOffSetInSeconds);
                    gmtEventEndDateTime = eventRecord.EndDateTime.addSeconds(tzOffSetInSeconds);
                    gmtEventEndDateTime = gmtEventEndDateTime.addDays(1);
                    gmtEventEndDateTime = gmtEventEndDateTime.addSeconds(-1);
                }
                
                system.debug('gmtEventStartDateTime = ' + gmtEventStartDateTime + ', gmtEventEndDateTime = ' + gmtEventEndDateTime + ', previousNextStartDateTime = ' + previousNextStartDateTime + ', previousEventEndDateTime = ' + previousEventEndDateTime);
                
                //DateTime shiftStart = tseRecord.Enter_Starttime__c;
                Integer shiftLength = integer.valueOf(tseRecord.Shift_Length__c);
                
                string currentWeekDay = currDateShiftStart.format('EEEE');
                string workingDays = tseRecord.True_Days__c;
                integer dayStartIndex = 1;
                
                // Checks that if Current Time has crossed the TSE's Shift Start Time, if TSE has not started today yet, count from today
                if(currDateTime < currDateShiftStart){
                    dayStartIndex = 0;
                }
                
                if(nextStartDateTime != null){
                    if(gmtEventStartDateTime <= previousNextStartDateTime && previousEventEndDateTime <= gmtEventEndDateTime){
                        // There is another event that starts before next start date time, so reset and continue looking
                        currDateShiftStart = previousNextStartDateTime = nextStartDateTime;
                        nextStartDateTime = null;
                    }else{
                        //						system.debug('No need to keep looking, next event is out there after working days');                        
                        //                        break;
                    }
                }
                
                // All day Event?
                if(eventRecord.IsAllDayEvent == true){
                    dateTime dt = findNextShiftStartDate(currDateShiftStart, shiftLength, workingDays, currDateTime, dayStartIndex, 1, gmtEventStartDateTime, gmtEventEndDateTime);
                    if (dt != null){
                        system.debug('setting tseRecord.Next_Start_DateTime__c to ' + dt);
                        nextStartDateTime = previousNextStartDateTime = dt;
                        previousEventEndDateTime = gmtEventEndDateTime;
                    }
                } else if(eventRecord.IsAllDayEvent == false){
                    dateTime dt = findNextShiftStartDate(currDateShiftStart, shiftLength, workingDays, currDateTime, dayStartIndex, 2, gmtEventStartDateTime, gmtEventEndDateTime);
                    
                    // Added by exafort for ticket TS-10015
                    // The below will execute if event start before shift starts and event end after shift ends
                    datetime currendDayendDateTime =  currDateShiftStart.addHours(shiftLength);
                    system.debug('gmtEventStartDateTime ==>'+gmtEventStartDateTime);
                    system.debug('currDateShiftStart ==>'+currDateShiftStart);
                    system.debug('currendDayendDateTime ==>'+currendDayendDateTime);
                    system.debug('gmtEventEndDateTime ==>'+gmtEventEndDateTime);
                    if((dt == null) && (gmtEventStartDateTime <= currDateShiftStart && currendDayendDateTime <= gmtEventEndDateTime)){
                        
                        dateTime nextShiftDateAvailablityCheck = getTseDefaultNextStartDateTime(tseRecord,currDateShiftStart.addDays(1));//To check next shift starts based on true days 
                        setTseNextCalendarEventBasedStartDateTime(tseRecord,nextShiftDateAvailablityCheck);  //To check eventson the day.
                    }
                    // End of TS-10015 
                    
                    if (dt != null){
                        system.debug('setting tseRecord.Next_Start_DateTime__c to ' + dt);
                        nextStartDateTime = previousNextStartDateTime = dt;
                        previousEventEndDateTime = gmtEventEndDateTime;
                    }
                    
                    
                    
                }
            }
        }
        
        if (nextStartDateTime == null){
            nextStartDateTime = previousNextStartDateTime;
        }
        return nextStartDateTime;
    }
    
    integer getCurrentUserTimeZoneOffsetSeconds(){
        TimeZone tz = UserInfo.getTimeZone();
        Integer tzOffset = tz.getOffset(system.now());
        integer tzOffSetInSeconds = tzOffset/1000;
        
        if(tzOffSetInSeconds < 0){
            tzOffSetInSeconds *= -1;
        }        
        System.debug('current User GMT offset in seconds ' + tzOffSetInSeconds);
        return tzOffSetInSeconds;
    }
    
    dateTime getLocalDateTime(){
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        return now.addSeconds(offset/1000);
    }  
    
    //Added by exafort for TS-10015 
    //It will return NextShiftStart datetime based on Working days
    private datetime getTseDefaultNextStartDateTime(CntrbnMdl_TSE__c  tseRecord,DateTime nextShiftStartDateTime){
        //	Defaults to TSE's work week based start date time
        System.debug('****	Entered on the new Method getTseDefaultNextStartDateTime	****');
        dateTime currentDateShiftStart = nextShiftStartDateTime;
        DateTime nextShiftStartDate = null;
        // TSE start DateTime and shift length should not be null
        if(tseRecord.Enter_Starttime__c != null && tseRecord.Shift_Length__c != null && currentDateShiftStart != null){            
            DateTime shiftStart = tseRecord.Enter_Starttime__c;
            Integer shiftLength = integer.valueOf(tseRecord.Shift_Length__c);
            
            system.debug('currentDateShiftStart = ' + currentDateShiftStart);
            
            DateTime shiftEndDateTime = currentDateShiftStart.addHours(shiftLength);
            
            system.debug('currentDateShiftStart afer adding shift length = ' + currentDateShiftStart);
            
            system.debug('Shift End Time from current day ' + shiftEndDateTime);
            dateTime localDt = getLocalDateTime();
            string currentWeekDay = currentDateShiftStart.format('EEEE');
            system.debug('shiftStartTimeForCurrentUser = ' + currentDateShiftStart +  ', Current Day =' + currentWeekDay);
            
            string workingDays = tseRecord.True_Days__c;
            nextShiftStartDate = findNextShiftStartDate(currentDateShiftStart, shiftLength, workingDays, system.now(), 0, 0, null, null);
        }
        return nextShiftStartDate;
    }
    //End of TS-10015 
}