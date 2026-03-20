public class scheduleDepotAddressbook implements Schedulable{
    
    public void execute(SchedulableContext sc){
		List<AsyncApexJob> apexJobs = [SELECT Id, Status, ApexClassID FROM AsyncApexJob WHERE Status in ('Holding', 'Processing', 'Preparing') and ApexClassID in (Select Id from ApexClass where Name in('scheduleDepotAddressbook', 'assetBatchUpdate', 'rmaDepotBatchUpdate'))];
        boolean isBatchRunning = false;
        if(apexJobs.size() > 0){
			isBatchRunning = true;
        }        
        if(X4HourDepotCalculationSetting__c.getInstance().WeeklyBatchFlag__c == false){
            system.debug('Calling addressbookBatchUpdate');            
            addressbookBatchUpdate s = new addressbookBatchUpdate('Daily');
            Database.executeBatch(s, 20);
        }
     
        /*datetime nextScheduleTime = system.now().addMinutes(10);
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second ());
        string cronvalue = second+' '+ minute +' * * * ?' ;
        string jobName = 'Depot calculation ' + nextScheduleTime.format('hh:mm');*/
        
        /* ESC-6123 Change Begin */
        /* 
         * 2020 June 18
         * Ramesh change the addminutes parameter to be parameterized
         */
        integer depotCalculationFrequency = 360;
        if(X4HourDepotCalculationSetting__c.getInstance().DepotCalculationFrequency__c != null){
             depotCalculationFrequency = integer.valueof(X4HourDepotCalculationSetting__c.getInstance().DepotCalculationFrequency__c);
        }
        system.debug('Frequency is = ' + depotCalculationFrequency);
        if(isBatchRunning){
            //	We will check 30 minutes from now. Otherwise take next scheduled Frequency
            depotCalculationFrequency = 30;
        }
        datetime nextScheduleTime = system.now().addMinutes(depotCalculationFrequency);
        /*  ESC-6123 Change End */

        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second ());
        string nextRunHour = string.valueof(nextScheduleTime.hour ());
		string cronvalue = '0 ' + minute + ' ' + nextRunHour + ' * * ?' ;
//        string cronvalue = second + ' '+ minute +' * * * ?' ;        
         //string cronvalue = second+' '+ minute +' * ? * 2-6' ;
        string jobName = 'Depot calculation ' + nextScheduleTime.format('hh:mm');
        
        scheduleDepotAddressbook p =  new scheduleDepotAddressbook();
 
        system.debug('Scheduling to run at ' + nextScheduleTime.format('hh:mm'));
        system.schedule(jobName, cronvalue , p);
        // this section of code will abort the current schedule job
        system.abortJob(sc.getTriggerId());
    }
}