global class scheduledOEMCallOut implements Schedulable {
    global void execute(SchedulableContext SC) {
        gsemServiceCallOut.getGSEMNotification();
    }
    Public static void SchedulerMethod(Integer pollingPeriodInMins) {
        
        String baseJobName = 'GSEM OEM Provider Job ';
        
        Integer numOfJobs = 60/pollingPeriodInMins;

        List<String> cronStrings = new List<String>();
        
        String newCronString;
        Integer minuteOffset;
        String currentJobName;
        
        for(Integer jobNum = 0; jobNum < numOfJobs; jobNum++)
        {
            minuteOffset = (jobNum) * pollingPeriodInMins;
            
            newCronString = '0 ' + minuteOffset +'  * * * ?';
            //System.debug('newCronString:  ' + newCronString);
            
            currentJobName = baseJobName + (jobNum);
            
            System.schedule(currentJobName, newCronString, new scheduledOEMCallOut());
            System.debug('Scheduling: ' + currentJobName);
        }        
    }
}