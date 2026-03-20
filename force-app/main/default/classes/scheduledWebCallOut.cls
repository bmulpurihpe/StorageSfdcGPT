global class scheduledWebCallOut implements Schedulable {
    global void execute(SchedulableContext SC) {
        WebServiceCallout.getNotification();
    }
    Public static void SchedulerMethod(Integer pollingPeriodInMins) {
        
        String baseJobName = 'GSEM Requester Job ';

        Integer numOfJobs = 60/pollingPeriodInMins;

        List<String> cronStrings = new List<String>();
        
        String newCronString;
        Integer minuteOffset;
        String currentJobName;
        
        for(Integer jobNum = 0; jobNum < numOfJobs; jobNum++)
        {
            minuteOffset = (jobNum) * pollingPeriodInMins;
            
            newCronString = '0 ' + minuteOffset +'  * * * ?';
            
            // System.debug('newCronString:  ' + newCronString);
            
            currentJobName = baseJobName + (jobNum);
            
            
            System.schedule(currentJobName, newCronString, new scheduledWebCallOut());
            System.debug('Scheduling: ' + currentJobName);
            
        }
    }
}