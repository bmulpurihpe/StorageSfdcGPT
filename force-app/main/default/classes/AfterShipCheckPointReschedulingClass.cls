global class AfterShipCheckPointReschedulingClass implements Schedulable{
  public static Integer runningJobCount{
    get{
        if(runningJobCount == null)
            return [Select count() FROM AsyncApexJob WHERE JobType='BatchApex' AND(Status = 'Processing' OR Status = 'Preparing')];
        else
            return runningJobCount;
    }
    set{
        System.assert(Test.isRunningTest(),'This property may only be set in tests');
        runningJobCount = value;
    }
  }
 // Execute method
    global void execute(SchedulableContext SC)
    {
        //taking the End point URL and API key from the custom settings.
        AfterShipSettings__c objAS = AfterShipSettings__c.getInstance(); 
        integer ScheduleTime = (integer)objAS.CheckPointSchedulerPeriod__c;
        system.debug('@@ ScheduleTime'+ ScheduleTime);
        try
        {
           
            //check if there are 5 active batch jobs
             if(runningJobCount < 5) { 
                // Code to be executed when the schedule class wakes up
                      // code
                 AfterShipCheckPointBatch  ASCB = new AfterShipCheckPointBatch();       
                 Database.executeBatch(ASCB);       
             
                // This section of code will schedule the next execution n minutes from now
                datetime nextScheduleTime = system.now().addMinutes(ScheduleTime);
                string minute = string.valueof(nextScheduleTime.minute());
                string second = string.valueof(nextScheduleTime.second ());
                string cronvalue = second+' '+minute+' * * * ?' ;
                string jobName = 'AfterShipCheckPointReschedulingClass ' +
                nextScheduleTime.format('hh:mm');
         
                AfterShipCheckPointReschedulingClass p = new AfterShipCheckPointReschedulingClass();
                system.schedule(jobName, cronvalue , p);
             
                // this section of code will abort the current schedule job
                system.abortJob(sc.getTriggerId());
            }
            else {
           
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 mail.setTargetObjectId(UserInfo.getUserId());
                 mail.setSaveAsActivity(false);
                 mail.setSubject('AfterShipCheckPointBatch will be rescheduled in another '+ScheduleTime+'min');
                 mail.setPlainTextBody('Job for AfterShipCheckPointBatch failed to submit due to job limit  in the org '+UserInfo.getOrganizationId()+' (limit is 5). Next job will be rescheduled in another '+ScheduleTime+'min');
                 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }
        
       }
       catch(Exception e)
       {
           system.debug('@@ Error ' + e.getmessage());
           if(e.getmessage().contains('Attempted to schedule too many concurrent batch jobs in this org'))
           {
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 mail.setTargetObjectId(UserInfo.getUserId());
                 mail.setSaveAsActivity(false);
                 mail.setSubject('AfterShipTrackingBatch will be rescheduled in another '+ScheduleTime+'min');
                 mail.setPlainTextBody('Job for AfterShipTrackingBatch failed to submit due to job limit  in the org '+UserInfo.getOrganizationId()+' (limit is 5). Next job will be rescheduled in another '+ScheduleTime+'min');
                 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
       }
 }
 
 }