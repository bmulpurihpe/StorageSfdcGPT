public class caseAttnReqSnoozeController {
    public Case cas {get; set;}
    private ApexPages.StandardController controller {get; set;}
    public boolean showHours {get; set;}
    public boolean HideStatusOutputField{get;set;}
    public boolean showStatusInputField{get;set;}
    public boolean showSaveButton{get;set;}
    public String redirectUrl{get;set;}
    public boolean refreshRecord{get;set;}
    public string caseOwnerNextReturn{get;set;}
    public integer allDisabled{get;set;}
    public string caseOwnerManager;
    public datetime ownerNxtReturnDateTime;
    /*
Loads pick list value for 24hours based on attn required date and time
*/
    
    public caseAttnReqSnoozeController(ApexPages.StandardController controller) {
        this.controller = controller;
        if(!test.isRunningTest())
            controller.addFields(new List<String>{'OwnerId', 'caseCurrendDateTime__c'});
        cas = (Case) controller.getRecord();
        HideStatusOutputField = false;
        showStatusInputField = false;
        showSaveButton = false;
        redirectUrl = controller.view().getURL();
        string caseOwnId = cas.OwnerId;
        allDisabled = 0;
        
        List<CntrbnMdl_TSE__c> contrbnTSE = new List<CntrbnMdl_TSE__c>();
        system.debug('@@@ TEST Class Debug - case owner ID @@@'+cas.OwnerId);
        if(cas.OwnerId != null && !caseOwnId.startsWith('00G')){    // Ignore Queue
            contrbnTSE = [select id, name, True_Days__c, Enter_Starttime__c, Datetime_GMT__c, Shift_Length__c,TSE_Manager__c,Next_Start_DateTime__c
                          from CntrbnMdl_TSE__c where Employee_Name__c =: cas.OwnerId];
            
        }
        else if(cas.OwnerId != null && caseOwnId.startsWith('00G')){
            caseOwnerNextReturn = 'Case not assigned';
        }
        DateTime currDate = System.now();
        string currDay = DateTime.now().format('EEEE');
        system.debug('@@@ Current Date @@@ '+currDate.format());
        datetime firstdatetime = currDate.addDays(1);
        string firstDay = firstdatetime.format('EEEE');
        datetime seconddatetime = currDate.addDays(2);
        string secondDay = seconddatetime.format('EEEE');
        datetime thirddatetime = currDate.addDays(3);
        string thirdDay = thirddatetime.format('EEEE');
        datetime fourthdatetime = currDate.addDays(4);
        string fourthDay = fourthdatetime.format('EEEE');
        datetime fifthdatetime = currDate.addDays(5);
        string fifthDay = fifthdatetime.format('EEEE');
        datetime sixthdatetime = currDate.addDays(6);
        string sixthDay = sixthdatetime.format('EEEE');
        datetime seventhdatetime = currDate.addDays(7);
        string seventhDay = seventhdatetime.format('EEEE');
        
        
        List<string> shiftDaysList = new List<string>();
        set<string> shiftDaysset = new set<string>();
        //  Find the shift days and add them to list
        if(contrbnTSE.size() == 0 && !caseOwnId.startsWith('00G'))
            caseOwnerNextReturn = 'Owner does not have Contribution Model TSE to display next return';
        
        for(CntrbnMdl_TSE__c con : contrbnTSE){
            if(con.True_Days__c != null){
                if(con.True_Days__c.contains(',')){
                    shiftDaysList = con.True_Days__c.split(',');
                }
                else if(!con.True_Days__c.contains(',')){
                    shiftDaysList.add(con.True_Days__c);
                }
            }
        }
        //  Add the shift days to String Set
        for(String s: shiftDaysList){
            shiftDaysset.add(s);
        }
        system.debug('@@@ shiftDays @@@ '+shiftDaysset);
        /*  This For loop does the following 
*   -  Case Owner Next Return
*/  
        for(CntrbnMdl_TSE__c con : contrbnTSE){
            if(con.Next_Start_DateTime__c != null){
                ownerNxtReturnDateTime = con.Next_Start_DateTime__c;
            }
            integer shiftlength = 8;
            caseOwnerManager = con.TSE_Manager__c;
            if(con.Shift_Length__c != null){
                shiftlength = integer.valueOf(con.Shift_Length__c);
            }
            integer previousHours;
            if(shiftDaysset.contains(currDay)){
                system.debug('@@@ current day @@@');
                string startTime = string.valueOf(con.Enter_Starttime__c.format());
                system.debug('@@@ current day - Enter StartTime @@@ '+startTime);
                string startTimeHour = startTime.substringBetween(' ', ':');
                system.debug('@@@ current day - startTimeHour @@@ '+startTimeHour);
                string StartTimeminutes = startTime.substringBetween(':',':');
                
                if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                    StartTimeminutes = startTime.substringBetween(':',' ');
                    if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                        StartTimeminutes = startTime.substringAfterLast(':');
                    }
                }
                system.debug('@@@ current day - StartTimeminutes @@@ '+StartTimeminutes);
                // integer.valueOf(startTimeHour) != 12 Added by Exafort for TS-4233
                if(startTime.substringAfterLast(' ') != null && startTime.substringAfterLast(' ') == 'PM' && integer.valueOf(startTimeHour) != 12){
                    startTimeHour = string.valueOf((integer.valueOf(startTimeHour) + 12));
                }
                system.debug('@@@ current day - startTimeHour @@@ '+startTimeHour);
                
                Datetime nextworkingday = currDate;
                system.debug('@@@ current day - nextworkingday @@@ '+nextworkingday);
                //Long dt1Long = DateTime.now().getTime();
                Long dt1Long = cas.caseCurrendDateTime__c.getTime();
                system.debug('@@@ current day - Current Date and Time @@@ '+DateTime.now().getTime().format());
                system.debug('@@@ current day - dt1Long @@@ '+dt1Long);
                Date nextWorkingDate = nextworkingday.date();
                system.debug('@@@ current day - nextWorkingDate @@@ '+nextWorkingDate);
                DateTime nextWorkingDateWithTimeSet = Datetime.newInstance(nextWorkingDate.year(), nextWorkingDate.month(), nextWorkingDate.day(), integer.valueOf(startTimeHour) , integer.valueOf(StartTimeminutes), 0);
                system.debug('@@@ current day - nextWorkingDateWithTimeSet @@@ '+nextWorkingDateWithTimeSet.format());
                
                system.debug('@@@ current day - currentdate @@@ '+currDate);
                
                Long dt2Long = nextWorkingDateWithTimeSet.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                system.debug('@@@ current day - hours difference @@@'+hours);
                system.debug('@@@ current day - minutes difference @@@'+minutes);
                previousHours = integer.valueOf(hours);
                if(string.valueOf(integer.valueOf(hours)).contains('-')){
                    previousHours = integer.valueOf(hours) * -1;
                }
                System.debug('@@@ TEST Class Test - currDate @@@ '+currDate);
                System.debug('@@@ TEST Class Test - nextWorkingDateWithTimeSet @@@ '+nextWorkingDateWithTimeSet);
                if(currDate < nextWorkingDateWithTimeSet){
                    if(integer.valueOf(hours) < 24){
                        caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                        if(string.valueOf(integer.valueOf(hours)).contains('-')){
                            Integer negativeHour =  (integer.valueOf(hours) * -1);
                            if(negativeHour != null && (negativeHour > shiftlength)){
                                caseOwnerNextReturn = String.valueOf(negativeHour)+'.'+string.valueOf(integer.valueOf(minutes))+'hours from now.';
                            }
                        }
                    }
                    else{
                        caseOwnerNextReturn = String.valueOf(hours)+'.'+string.valueOf(integer.valueOf(minutes))+' hours from now.';
                    }
                    if(string.valueOf(integer.valueOf(hours)).contains('-')){
                        Integer negativeHour =  (integer.valueOf(hours) * -1);
                        if(negativeHour != null && (negativeHour >= 1 && negativeHour <= shiftlength)){
                            caseOwnerNextReturn = 'Scheduled to be on shift right now';
                        }
                    }
                    if(integer.valueOf(hours) == 0){
                        caseOwnerNextReturn = 'Scheduled to be on shift right now';
                        if(integer.valueOf(minutes) != 0 && integer.valueOf(minutes) > 0){
                            caseOwnerNextReturn = string.valueOf(integer.valueof(minutes))+' minutes from now.';
                        }
                    }
                }
                else if(currDate > nextWorkingDateWithTimeSet){
                    if(string.valueOf(integer.valueOf(hours)).contains('-'))
                    {
                        Integer negativeHour =  (integer.valueOf(hours) * -1);
                        if(negativeHour != null && (negativeHour >= 1 && negativeHour <= shiftlength)){
                            caseOwnerNextReturn = 'Scheduled to be on shift right now';
                        }
                    }
                    if(integer.valueOf(hours) == 0){
                        caseOwnerNextReturn = 'Scheduled to be on shift right now';
                        if(integer.valueOf(minutes) != 0 && integer.valueOf(minutes) > 0){
                            caseOwnerNextReturn = string.valueOf(integer.valueof(minutes))+' minutes from now.';
                        }
                    }
                }
                
            }
            if(shiftDaysset.contains(firstDay) && caseOwnerNextReturn == null && (previousHours > 8 || previousHours == null)){
                system.debug('@@@ first day @@@');
                string startTime = string.valueOf(con.Enter_Starttime__c.format());
                system.debug('@@@ first day - Enter StartTime @@@ '+startTime);
                string startTimeHour = startTime.substringBetween(' ', ':');
                system.debug('@@@ first day - startTimeHour @@@ '+startTimeHour);
                string StartTimeminutes = startTime.substringBetween(':',':');
                system.debug('@@@ first day - StartTimeminutes @@@ '+StartTimeminutes);
                if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                    StartTimeminutes = startTime.substringBetween(':',' ');
                    if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                        StartTimeminutes = startTime.substringAfterLast(':');
                    }
                }
                system.debug('integer.valueOf(startTimeHour) = ' + integer.valueOf(startTimeHour));
                // integer.valueOf(startTimeHour) != 12 Added by Exafort for TS-4233
                if(startTime.substringAfterLast(' ') != null && startTime.substringAfterLast(' ') == 'PM' && integer.valueOf(startTimeHour) != 12){
                    startTimeHour = string.valueOf((integer.valueOf(startTimeHour) + 12));
                }
                Datetime nextworkingday = firstdatetime;
                system.debug('@@@ first day - nextworkingday @@@ '+nextworkingday);
                Long dt1Long = cas.caseCurrendDateTime__c.getTime();
                system.debug('@@@ first day - dt1Long @@@ '+dt1Long);
                Date nextWorkingDate = nextworkingday.date();
                system.debug('@@@ first day - nextWorkingDate @@@ '+nextWorkingDate);
                DateTime nextWorkingDateWithTimeSet = Datetime.newInstance(nextWorkingDate.year(), nextWorkingDate.month(), nextWorkingDate.day(), integer.valueOf(startTimeHour) , integer.valueOf(StartTimeminutes), 0);
                system.debug('@@@ first day - nextWorkingDateWithTimeSet @@@ '+nextWorkingDateWithTimeSet.format());
                Long dt2Long = nextWorkingDateWithTimeSet.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                if(integer.valueOf(hours) < 24){
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                else{
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                /*if(string.valueOf(integer.valueOf(hours)).contains('-')){
Integer negativeHour =  (integer.valueOf(hours) * -1);
if(negativeHour != null && (negativeHour >= 1 && negativeHour <= shiftlength)){
caseOwnerNextReturn = 'Scheduled to be on shift right now';
}
}*/
                
            }
            else if(shiftDaysset.contains(secondDay) && caseOwnerNextReturn == null && (previousHours > 8 || previousHours == null)){
                system.debug('@@@ second day @@@');
                string startTime = string.valueOf(con.Enter_Starttime__c.format());
                system.debug('@@@ second day - Enter StartTime @@@ '+startTime);
                string startTimeHour = startTime.substringBetween(' ', ':');
                system.debug('@@@ second day - startTimeHour @@@ '+startTimeHour);
                string StartTimeminutes = startTime.substringBetween(':',':');
                system.debug('@@@ second day - StartTimeminutes @@@ '+StartTimeminutes);
                if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                    StartTimeminutes = startTime.substringBetween(':',' ');
                    if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                        StartTimeminutes = startTime.substringAfterLast(':');
                    }
                }
                // integer.valueOf(startTimeHour) != 12 Added by Exafort for TS-4233
                if(startTime.substringAfterLast(' ') != null && startTime.substringAfterLast(' ') == 'PM' && integer.valueOf(startTimeHour) != 12){
                    startTimeHour = string.valueOf((integer.valueOf(startTimeHour) + 12));
                }
                Datetime nextworkingday = seconddatetime;
                system.debug('@@@ second day - nextworkingday @@@ '+nextworkingday);
                Long dt1Long = cas.caseCurrendDateTime__c.getTime();
                system.debug('@@@ second day - dt1Long @@@ '+dt1Long);
                Date nextWorkingDate = nextworkingday.date();
                system.debug('@@@ second day - nextWorkingDate @@@ '+nextWorkingDate);
                DateTime nextWorkingDateWithTimeSet = Datetime.newInstance(nextWorkingDate.year(), nextWorkingDate.month(), nextWorkingDate.day(), integer.valueOf(startTimeHour) , integer.valueOf(StartTimeminutes), 0);
                system.debug('@@@ second day - nextWorkingDateWithTimeSet @@@ '+nextWorkingDateWithTimeSet.format());
                Long dt2Long = nextWorkingDateWithTimeSet.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                if(integer.valueOf(hours) < 24){
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                else{
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                if(string.valueOf(integer.valueOf(hours)).contains('-')){
                    Integer negativeHour =  (integer.valueOf(hours) * -1);
                    if(negativeHour != null && (negativeHour >= 1 && negativeHour <= shiftlength)){
                        caseOwnerNextReturn = 'Scheduled to be on shift right now';
                    }
                }
            }
            else if(shiftDaysset.contains(thirdDay) && caseOwnerNextReturn == null && (previousHours > 8 || previousHours == null)){
                system.debug('@@@ third day @@@');
                string startTime = string.valueOf(con.Enter_Starttime__c.format());
                system.debug('@@@ third day - Enter StartTime @@@ '+startTime);
                string startTimeHour = startTime.substringBetween(' ', ':');
                system.debug('@@@ third day - startTimeHour @@@ '+startTimeHour);
                string StartTimeminutes = startTime.substringBetween(':',':');
                system.debug('@@@ third day - StartTimeminutes @@@ '+StartTimeminutes);
                if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                    StartTimeminutes = startTime.substringBetween(':',' ');
                    system.debug('@@@ third day - Else StartTimeminutes @@@ '+StartTimeminutes);
                    if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                        StartTimeminutes = startTime.substringAfterLast(':');
                    }
                }
                // integer.valueOf(startTimeHour) != 12 Added by Exafort for TS-4233
                if(startTime.substringAfterLast(' ') != null && startTime.substringAfterLast(' ') == 'PM' && integer.valueOf(startTimeHour) != 12){
                    startTimeHour = string.valueOf((integer.valueOf(startTimeHour) + 12));
                }
                Datetime nextworkingday = thirddatetime;
                system.debug('@@@ third day - nextworkingday @@@ '+nextworkingday);
                Long dt1Long = cas.caseCurrendDateTime__c.getTime();
                system.debug('@@@ third day - dt1Long @@@ '+dt1Long);
                Date nextWorkingDate = nextworkingday.date();
                system.debug('@@@ third day - nextWorkingDate @@@ '+nextWorkingDate);
                DateTime nextWorkingDateWithTimeSet = Datetime.newInstance(nextWorkingDate.year(), nextWorkingDate.month(), nextWorkingDate.day(), integer.valueOf(startTimeHour) , integer.valueOf(StartTimeminutes), 0);
                system.debug('@@@ third day - nextWorkingDateWithTimeSet @@@ '+nextWorkingDateWithTimeSet.format());
                Long dt2Long = nextWorkingDateWithTimeSet.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                if(integer.valueOf(hours) < 24){
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                else{
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                if(string.valueOf(integer.valueOf(hours)).contains('-')){
                    Integer negativeHour =  (integer.valueOf(hours) * -1);
                    if(negativeHour != null && (negativeHour >= 1 && negativeHour <= shiftlength)){
                        caseOwnerNextReturn = 'Scheduled to be on shift right now';
                    }
                }
            }
            else if(shiftDaysset.contains(fourthDay) && caseOwnerNextReturn == null && (previousHours > 8 || previousHours == null)){
                system.debug('@@@ fourth day @@@');
                string startTime = string.valueOf(con.Enter_Starttime__c.format());
                system.debug('@@@ fourth day - Enter StartTime @@@ '+startTime);
                string startTimeHour = startTime.substringBetween(' ', ':');
                system.debug('@@@ fourth day - startTimeHour @@@ '+startTimeHour);
                string StartTimeminutes = startTime.substringBetween(':',':');
                system.debug('@@@ fourth day - StartTimeminutes @@@ '+StartTimeminutes);
                if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                    StartTimeminutes = startTime.substringBetween(':',' ');
                    if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                        StartTimeminutes = startTime.substringAfterLast(':');
                    }
                }
                // integer.valueOf(startTimeHour) != 12 Added by Exafort for TS-4233
                if(startTime.substringAfterLast(' ') != null && startTime.substringAfterLast(' ') == 'PM' && integer.valueOf(startTimeHour) != 12){
                    startTimeHour = string.valueOf((integer.valueOf(startTimeHour) + 12));
                }
                Datetime nextworkingday = fourthdatetime;
                system.debug('@@@ fourth day - nextworkingday @@@ '+nextworkingday);
                Long dt1Long = cas.caseCurrendDateTime__c.getTime();
                system.debug('@@@ fourth day - dt1Long @@@ '+dt1Long);
                Date nextWorkingDate = nextworkingday.date();
                system.debug('@@@ fourth day - nextWorkingDate @@@ '+nextWorkingDate);
                DateTime nextWorkingDateWithTimeSet = Datetime.newInstance(nextWorkingDate.year(), nextWorkingDate.month(), nextWorkingDate.day(), integer.valueOf(startTimeHour) , integer.valueOf(StartTimeminutes), 0);
                system.debug('@@@ fourth day - nextWorkingDateWithTimeSet @@@ '+nextWorkingDateWithTimeSet.format());
                Long dt2Long = nextWorkingDateWithTimeSet.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                if(integer.valueOf(hours) < 24){
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                else{
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                if(string.valueOf(integer.valueOf(hours)).contains('-')){
                    Integer negativeHour =  (integer.valueOf(hours) * -1);
                    if(negativeHour != null && (negativeHour >= 1 && negativeHour <= shiftlength)){
                        caseOwnerNextReturn = 'Scheduled to be on shift right now';
                    }
                }
            }
            else if(shiftDaysset.contains(fifthDay) && caseOwnerNextReturn == null && (previousHours > 8 || previousHours == null)){
                system.debug('@@@ fifth day @@@');
                string startTime = string.valueOf(con.Enter_Starttime__c.format());
                system.debug('@@@ fifth day - Enter StartTime @@@ '+startTime);
                string startTimeHour = startTime.substringBetween(' ', ':');
                system.debug('@@@ fifth day - startTimeHour @@@ '+startTimeHour);
                string StartTimeminutes = startTime.substringBetween(':',':');
                system.debug('@@@ fifth day - StartTimeminutes @@@ '+StartTimeminutes);
                if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                    StartTimeminutes = startTime.substringBetween(':',' ');
                    if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                        StartTimeminutes = startTime.substringAfterLast(':');
                    }
                }
                // integer.valueOf(startTimeHour) != 12 Added by Exafort for TS-4233
                if(startTime.substringAfterLast(' ') != null && startTime.substringAfterLast(' ') == 'PM' && integer.valueOf(startTimeHour) != 12){
                    startTimeHour = string.valueOf((integer.valueOf(startTimeHour) + 12));
                }
                Datetime nextworkingday = fifthdatetime;
                system.debug('@@@ fifth day - nextworkingday @@@ '+nextworkingday);
                Long dt1Long = cas.caseCurrendDateTime__c.getTime();
                system.debug('@@@ fifth day - dt1Long @@@ '+dt1Long);
                Date nextWorkingDate = nextworkingday.date();
                system.debug('@@@ fifth day - nextWorkingDate @@@ '+nextWorkingDate);
                DateTime nextWorkingDateWithTimeSet = Datetime.newInstance(nextWorkingDate.year(), nextWorkingDate.month(), nextWorkingDate.day(), integer.valueOf(startTimeHour) , integer.valueOf(StartTimeminutes), 0);
                system.debug('@@@ fifth day - nextWorkingDateWithTimeSet @@@ '+nextWorkingDateWithTimeSet.format());
                Long dt2Long = nextWorkingDateWithTimeSet.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                if(integer.valueOf(hours) < 24){
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                else{
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                if(string.valueOf(integer.valueOf(hours)).contains('-')){
                    Integer negativeHour =  (integer.valueOf(hours) * -1);
                    if(negativeHour != null && (negativeHour >= 1 && negativeHour <= shiftlength)){
                        caseOwnerNextReturn = 'Scheduled to be on shift right now';
                    }
                }
            }
            else if(shiftDaysset.contains(sixthDay) && caseOwnerNextReturn == null && (previousHours > 8 || previousHours == null)){
                system.debug('@@@ sixth day @@@');
                
                string startTime = string.valueOf(con.Enter_Starttime__c.format());
                system.debug('@@@ sixth day - Enter StartTime @@@ '+startTime);
                string startTimeHour = startTime.substringBetween(' ', ':');
                system.debug('@@@ sixth day - startTimeHour @@@ '+startTimeHour);
                string StartTimeminutes = startTime.substringBetween(':',':');
                system.debug('@@@ sixth day - StartTimeminutes @@@ '+StartTimeminutes);
                if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                    StartTimeminutes = startTime.substringBetween(':',' ');
                    if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                        StartTimeminutes = startTime.substringAfterLast(':');
                    }
                }
                // integer.valueOf(startTimeHour) != 12 Added by Exafort for TS-4233
                if(startTime.substringAfterLast(' ') != null && startTime.substringAfterLast(' ') == 'PM' && integer.valueOf(startTimeHour) != 12){
                    startTimeHour = string.valueOf((integer.valueOf(startTimeHour) + 12));
                }
                Datetime nextworkingday = sixthdatetime;
                system.debug('@@@ sixth day - nextworkingday @@@ '+nextworkingday);
                Long dt1Long = cas.caseCurrendDateTime__c.getTime();
                system.debug('@@@ sixth day - dt1Long @@@ '+dt1Long);
                Date nextWorkingDate = nextworkingday.date();
                system.debug('@@@ sixth day - nextWorkingDate @@@ '+nextWorkingDate);
                DateTime nextWorkingDateWithTimeSet = Datetime.newInstance(nextWorkingDate.year(), nextWorkingDate.month(), nextWorkingDate.day(), integer.valueOf(startTimeHour) , integer.valueOf(StartTimeminutes), 0);
                system.debug('@@@ sixth day - nextWorkingDateWithTimeSet @@@ '+nextWorkingDateWithTimeSet.format());
                Long dt2Long = nextWorkingDateWithTimeSet.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                if(integer.valueOf(hours) < 24){
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                else{
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                if(string.valueOf(integer.valueOf(hours)).contains('-')){
                    Integer negativeHour =  (integer.valueOf(hours) * -1);
                    if(negativeHour != null && (negativeHour >= 1 && negativeHour <= shiftlength)){
                        caseOwnerNextReturn = 'Scheduled to be on shift right now';
                    }
                }
            }
            else if(shiftDaysset.contains(seventhDay) && caseOwnerNextReturn == null && (previousHours > 8 || previousHours == null)){
                system.debug('@@@ seventh day @@@');
                string startTime = string.valueOf(con.Enter_Starttime__c.format());
                system.debug('@@@ seventh day - Enter StartTime @@@ '+startTime);
                string startTimeHour = startTime.substringBetween(' ', ':');
                system.debug('@@@ seventh day - startTimeHour @@@ '+startTimeHour);
                string StartTimeminutes = startTime.substringBetween(':',':');
                system.debug('@@@ seventh day - StartTimeminutes @@@ '+StartTimeminutes);
                if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                    StartTimeminutes = startTime.substringBetween(':',' ');
                    if(StartTimeminutes == '' || StartTimeminutes == null || StartTimeminutes == 'null'){
                        StartTimeminutes = startTime.substringAfterLast(':');
                    }
                }
                // integer.valueOf(startTimeHour) != 12 Added by Exafort for TS-4233
                if(startTime.substringAfterLast(' ') != null && startTime.substringAfterLast(' ') == 'PM' && integer.valueOf(startTimeHour) != 12){
                    startTimeHour = string.valueOf((integer.valueOf(startTimeHour) + 12));
                }
                Datetime nextworkingday = seventhdatetime;
                system.debug('@@@ seventh day - nextworkingday @@@ '+nextworkingday);
                Long dt1Long = cas.caseCurrendDateTime__c.getTime();
                system.debug('@@@ seventh day - dt1Long @@@ '+dt1Long);
                Date nextWorkingDate = nextworkingday.date();
                system.debug('@@@ seventh day - nextWorkingDate @@@ '+nextWorkingDate);
                DateTime nextWorkingDateWithTimeSet = Datetime.newInstance(nextWorkingDate.year(), nextWorkingDate.month(), nextWorkingDate.day(), integer.valueOf(startTimeHour) , integer.valueOf(StartTimeminutes), 0);
                system.debug('@@@ seventh day - nextWorkingDateWithTimeSet @@@ '+nextWorkingDateWithTimeSet.format());
                Long dt2Long = nextWorkingDateWithTimeSet.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                if(integer.valueOf(hours) < 24){
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                else{
                    caseOwnerNextReturn = String.valueOf(hours)+' hours from now.';
                }
                if(string.valueOf(integer.valueOf(hours)).contains('-')){
                    Integer negativeHour =  (integer.valueOf(hours) * -1);
                    if(negativeHour != null && (negativeHour >= 1 && negativeHour <= shiftlength)){
                        caseOwnerNextReturn = 'Scheduled to be on shift right now';
                    }
                }
            }
        }
        
        
    }
    public PageReference callStatus(){
        HideStatusOutputField = true;
        showStatusInputField = true;
        showSaveButton = true;
        return null;
    }
    public pagereference displayText(){
        HideStatusOutputField = false;
        showStatusInputField = false;
        showSaveButton = false;
        refreshRecord = true;
        return null;
    }
    public PageReference save() {
        // Added by Exafort for TS-6999
        user userRec;
        DateTime currentTime = system.now();
        Long ownerNxtReturninHrs;
        // Calculate the hour difference from case owner next retun time and current system time
        if(ownerNxtReturnDateTime != null){
            Long dt1Long = ownerNxtReturnDateTime.getTime();
            Long dt2Long = currentTime.getTime();
            Long milliseconds = dt1Long - dt2Long;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long days = hours / 24;
            
            ownerNxtReturninHrs = hours;
            system.debug('hours --> ' + hours);
        }
        
        if(caseOwnerManager != null){
            userRec = [select id,Name from user where Name =:caseOwnerManager limit 1];
            system.debug('userRec --> ' + userRec.Id);
        }
        
        if(ownerNxtReturninHrs > 48 && cas.Is_CaseOwner_On_Shift__c == False && userinfo.getUserId() != userRec.Id){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Case Owner will be out for more than 48 Hours, so Attn Req Flag cannot be snoozed'));
            return null;
        }
        // End of TS-6999
        
        if(cas.caseAttnReqDateTime__c != null){
            integer roundedAttnReqMin, roundedAttnReqHour;
            //roundedAttnReqMin = 0;
            roundedAttnReqHour = cas.caseAttnReqDateTime__c.hour();
            //cas.caseAttnReqDateTimeHelper__c = DateTime.newInstance(cas.caseAttnReqDateTime__c.year(), cas.caseAttnReqDateTime__c.month(), cas.caseAttnReqDateTime__c.day(), roundedAttnReqHour, cas.caseAttnReqDateTime__c.minute(), 0);
            cas.caseAttnReqDateTimeHelper__c = DateTime.newInstance(cas.caseAttnReqDateTime__c.year(), cas.caseAttnReqDateTime__c.month(), cas.caseAttnReqDateTime__c.day(), roundedAttnReqHour, 0, 0);
        }
        
        if(cas.AttnSnoozeIntervalInHours__c != null && (cas.caseAttnReqSnoozeReason__c != null)){
            if(cas.caseAttnReq__c){
                cas.caseAttnReq__c = false;
            }
            refreshRecord = true;
            controller.save();
            
            return null;
        }
        else if(cas.AttnSnoozeIntervalInHours__c == null && cas.caseAttnReqSnoozeReason__c != null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Attn Req Flag cannot be snoozed if Interval is not set'));
            return null;
        }
        else if(cas.AttnSnoozeIntervalInHours__c != null && (cas.caseAttnReqSnoozeReason__c == null || cas.caseAttnReqSnoozeReason__c == '')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Attn Req Snooze Reason is required if Attn Flag is snoozed'));
            return null;
        }
        else{
            return null;
        }
    }
    public PageReference test(){
        return null;
    }
    /*
* This does the following
*   - Load Options list
*   -  Rounds the current time to closet next hour, eg. 11.20am will be treated as 12am and 11.55am will be treated as 12pm
*   -  Disable past times for snoozing. So if the attention required is 7.35am, and current time is 9.22am, we disable only 8, but if current time is 9.36 then 8am and 9am will be disabled
*   -  Find the TSE next return time and appending TSE next to the hour, if he/she returns within the Attn required time + 24 hours
*   -  Append APAC, EMEA and AMER (Eastern Time) next to the hours to indicate the shift start time for those regions
*/ 
    public List<SelectOption> getSnoozeHours(){
        try{
            List<selectOption> options = new List<selectOption>(); 
            options.add(new selectOption('', '- None -'));
            if(cas.caseAttnReqDateTime__c != null){  //&& cas.AttReqDateTimeWithSnoozePeriod__c == null
                datetime attnreqdatetime = cas.caseAttnReqDateTime__c;
                
                Time getHour = attnreqdatetime.time();
                Date attnReqDate = Date.newInstance(attnreqdatetime.year(), attnreqdatetime.month(), attnreqdatetime.day());
                
                
                for(integer i=1;i<=24;i++){
                    //Time myTime = Time.newInstance(attnreqdatetime.hour(), attnreqdatetime.minute(), attnreqdatetime.second(), attnreqdatetime.millisecond());
                    Time myTime = Time.newInstance(attnreqdatetime.hour(), 0, 0, 0);
                    myTime = myTime.addHours(i);
                    string stringMyTime = string.valueOf(myTime);
                    stringMyTime = stringMyTime.substringBeforeLast(':');
                    stringMyTime = stringMyTime.substringBefore(':')+':00';
                    if(stringMyTime.substringBefore(':') == '00'){
                        stringMyTime = '24:00';
                    }
                    //  Should the hour be disabled calc starting
                    boolean disable = false;
                    Time currentTime = Time.newInstance(system.now().hour(), system.now().minute(), system.now().second(), system.now().millisecond());
                    //currentTime = currentTime.addHours(i);
                    DateTime currentDateTime = DateTime.newInstance(system.now().year(), system.now().month(), system.now().day(), system.now().hour(), system.now().minute(), system.now().second());
                    Date currentDate = Date.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day());
                    DateTime attreqaddHours = attnreqdatetime.addHours(i);
                    Date attnReqDateCon = Date.newInstance(attreqaddHours.year(), attreqaddHours.month(), attreqaddHours.day());
                    Datetime attnReqDateValue = attnreqdatetime;
                    Datetime currentDateValue = currentDate;
                    Long attnReqDateValue1 = attnReqDateValue.getTime();
                    Long currentDateValue1 = currentDateValue.getTime();
                    Long milliseconds = currentDateValue1 - attnReqDateValue1;
                    Long seconds = milliseconds / 1000;
                    integer minutes = integer.valueOf(seconds / 60);
                    Long hours = minutes / 60;
                    
                    
                    system.debug('### currentDate ### '+currentDate);
                    system.debug('### attnReqDateCon ### '+attnReqDateCon);
                    system.debug('### disable ### '+disable);
                    system.debug('### currentTime ### '+currentTime);
                    system.debug('### myTime ### '+myTime);
                    system.debug('### hours ### '+integer.valueOf(hours));
                    
                    if(integer.valueOf(hours) > 24){
                        disable = true;
                    }
                    else if(currentDate == attnReqDateCon && disable == false && currentTime > myTime){
                        disable = true;
                    }
                    else if(currentDate > attnReqDateCon && disable == false && currentTime < myTime && (integer.valueOf(hours) > 1 && integer.valueOf(hours) <=12)){
                        disable = true;
                    }
                    
                    if(disable == true){
                        allDisabled = allDisabled + 1;
                    }
                    system.debug('### allDisabled ###'+allDisabled);
                    //  Should the hour be disabled calc End
                    
                    //Get current user timezone and find difference between the geolocation teams APAC, EMEA and AMER
                    /*DateTime currentTimeToconvert = DateTime.now();
                    String singaporeTz = currentTimeToconvert.format('yyyy-MM-dd HH:mm:ss', 'Asia/Singapore');
                    system.debug('### myDate ###'+singaporeTz);
                    DateTime singaporeDateTime = DateTime.valueOf(singaporeTz);
                    system.debug('### singaporeDateTime ### '+singaporeDateTime);
                    integer singaporeHoursDiff = numberOfHours(currentTimeToconvert, singaporeDateTime);
                    system.debug('### singaporeHoursDiff ### '+singaporeHoursDiff);
                    
                    String gmtTz = currentTimeToconvert.format('yyyy-MM-dd HH:mm:ss', 'GMT');
                    system.debug('### myDate ###'+gmtTz);
                    DateTime gmtDateTime = DateTime.valueOf(gmtTz);
                    system.debug('### gmtTz ### '+ gmtDateTime);
                    integer gmtHoursDiff = numberOfHours(currentTimeToconvert, gmtDateTime);
                    system.debug('### gmtHoursDiff ### '+ gmtHoursDiff);
                    
                    
                    string europTz = currentTimeToconvert.format('yyyy-MM-dd HH:mm:ss', 'British/London');
                    DateTime europDateTime = DateTime.valueOf(europTz);
                    integer europeHoursDiff = numberOfHours(currentTimeToconvert, europDateTime);
                    system.debug('### europeHoursDiff ### '+europeHoursDiff);
                    
                    string pdtTz = currentTimeToconvert.format('yyyy-MM-dd HH:mm:ss', 'America/Los_Angeles');
                    DateTime pdtDateTime = DateTime.valueOf(pdtTz);
                    integer pdtHoursDiff = numberOfHours(currentTimeToconvert, pdtDateTime);
                    system.debug('### pdtHoursDiff ### '+pdtHoursDiff);*/
                    
                    String teamsStart = ' ';
                    /*
For Every value in pick list
find the GMT equivalent and if that is between 0 - 7 it is APAC Shift, so if it is 00 (24), it should have APAC appended
find the GMT equivalent and if that is between 8 - 15 it is EMEA Shift, so if it is 8, it should have EMEA appended
find the GMT equivalent and if that is between 16 - 23 it is America Shift, so if it is 16, it should have AMER appended
*/
                    DateTime currentOptionDt = DateTime.newInstance(attnreqdatetime.year(), attnreqdatetime.month(), attnreqdatetime.day(), attnreqdatetime.hour(), attnreqdatetime.minute(), attnreqdatetime.second());                    
                    currentOptionDt  = currentOptionDt.addHours(i);
                    
                    if (currentOptionDt.hourGmt() == 0){
                        teamsStart = ' APAC';
                    }
                    else if (currentOptionDt.hourGmt() == 8){
                        teamsStart = ' EMEA';
                    }
                    else if (currentOptionDt.hourGmt() == 16){
                        teamsStart = ' AMER';
                    }                    
                    
                    
                    string TSEStartAppend=' ';
                    string caseOwnerNextReturnString;
                    string caseOwnerNextReturnSupportString;
                    DateTime currentDateForTSEStartAppend;
                    if(cas.caseCurrendDateTime__c != null){
                        currentDateForTSEStartAppend = cas.caseCurrendDateTime__c;
                    }
                    if(caseOwnerNextReturn != null && caseOwnerNextReturn != 'Scheduled to be on shift right now' && caseOwnerNextReturn != 'Owner does not have Contribution Model TSE to display next return'){
                        
                        caseOwnerNextReturnString = caseOwnerNextReturn;
                        caseOwnerNextReturnSupportString = caseOwnerNextReturn;
                        caseOwnerNextReturnString = caseOwnerNextReturnString.substringBefore(' ');
                        
                        system.debug('@@@ TEST Class test - caseOwnerNextReturnString @@@'+caseOwnerNextReturnString);
                        if(caseOwnerNextReturnString != null  && integer.valueOf(caseOwnerNextReturnString) < 24){
                            
                            //caseOwnerNextReturnString = caseOwnerNextReturnString;
                            //system.debug('$$$ caseOwnerNextReturnString.substringBefore(\'.\') $$$ '+caseOwnerNextReturnString);
                            if(caseOwnerNextReturnString != null){
                                currentDateForTSEStartAppend = currentDateForTSEStartAppend.addHours(integer.valueOf(caseOwnerNextReturnString));
                                
                                
                                integer currentDateForTSEStartAppendHour = currentDateForTSEStartAppend.hour();
                                
                                currentDateForTSEStartAppendHour = currentDateForTSEStartAppendHour +1;
                                
                                string appendString=' ';
                                if(currentDateForTSEStartAppendHour <= 9){
                                    caseOwnerNextReturnString = '0'+string.valueOf(currentDateForTSEStartAppendHour);
                                    appendString = '0'+string.valueOf(currentDateForTSEStartAppendHour)+':00';
                                }
                                else if(currentDateForTSEStartAppendHour > 9){
                                    appendString = string.valueOf(currentDateForTSEStartAppendHour)+':00';
                                }
                                //caseOwnerNextReturnString = currentDateForTSEStartAppendHour+':00';
                                caseOwnerNextReturnString = appendString;
                                if(caseOwnerNextReturnString == stringMyTime){
                                    TSEStartAppend = ' TSE';
                                }
                            }
                        }
                        /*else if(caseOwnerNextReturnString != null && !caseOwnerNextReturnString.contains('.') && caseOwnerNextReturnSupportString.substringAfter(' ') == 'minutes'){
caseOwnerNextReturnString = 
}*/
                    }
                    
                    //options.add(new selectOption(string.valueOf(i), '+ '+string.valueOf(i)+'hr '+stringMyTime+geoLocationTeamStarts+TSEStartAppend, disable));
                    options.add(new selectOption(string.valueOf(i), '+ '+string.valueOf(i)+'hr '+stringMyTime+teamsStart+TSEStartAppend, disable));
                }
            }
            /*else if(cas.caseAttnReqDateTime__c != null && cas.AttReqDateTimeWithSnoozePeriod__c != null){
datetime attnreqdatetime = cas.AttReqDateTimeWithSnoozePeriod__c;
system.debug('@@@ attn req date time Time @@@ '+attnreqdatetime.time());
system.debug('@@@ attn req date time Time @@@ '+attnreqdatetime.timeGmt());

system.debug('@@@ attn req date time hour @@@ '+cas.caseAttnReqDateTime__c.hourGMT());
Time getHour = attnreqdatetime.time();
system.debug('@@@ Hour from Attn Req DateTime @@@'+getHour);


for(integer i=1;i<=24;i++){
Time myTime = Time.newInstance(attnreqdatetime.hour(), attnreqdatetime.minute(), attnreqdatetime.second(), attnreqdatetime.millisecond());
myTime = myTime.addHours(i);
system.debug('@@@ MyTime @@@ '+myTime);
string stringMyTime = string.valueOf(myTime);
stringMyTime = stringMyTime.substringBeforeLast(':');
options.add(new selectOption(string.valueOf(i), '+ '+string.valueOf(i)+'hr '+stringMyTime));
}
}*/
            return options;
        }
        Catch(Exception e){
            system.debug('@@@ Exception at getSnoozeHours method in caseAttnReqSnoozeController@@@'+e.getMessage()+'  Line No: '+e.getLineNumber());
            return null;
        }
        
    }
    public integer numberOfHours(DateTime first, DateTime Second){
        Long  firstDateTime = first.getTime();
        Long secondDateTime = Second.getTime();
        Long milliseconds = secondDateTime - firstDateTime;
        Long seconds = milliseconds / 1000;
        integer minutes = integer.valueOf(seconds / 60);
        Long hours = minutes / 60;
        return integer.valueOf(hours);
    }
    
}