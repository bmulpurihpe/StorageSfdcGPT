global class GSEMJobManager {
    
    //
    // Methods for All jobs
    // 
    
    public static void getAllGSEMJobs(){

        List<CronTrigger> jobs  = new List<CronTrigger>();
        
        getGSEMRequesterJobs();
        getGSEMOEMProviderJobs();
        
        return;
        
    }
    
    public static void startAllGSEMJobs(Integer pollingPeriodInMins){
        
        startGSEMRequesterJobs(pollingPeriodInMins);
        startGSEMOEMProviderJobs(pollingPeriodInMins);
        
        return;
    }
    
    public static void stopAllGSEMJobs(){
        
        List<CronTrigger> jobs  = new List<CronTrigger>();
        
        stopGSEMRequesterJobs();
        stopGSEMOEMProviderJobs();
        
        return;
    }
    
    //
    // Methods for Requester jobs
    //     
    
    public static void getGSEMRequesterJobs(){
        
        String likeValue = 'GSEM Requester%';
        
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime From CronTrigger where CronJobDetail.Name LIKE : likeValue];
        
        //system.debug('Currently running GSEM Jobs: ' + jobs);
        
        for(CronTrigger job : jobs){
            system.debug('Job Name: ' + job.CronJobDetail.Name);
        }
        
        return;
    }
    
    public static void startGSEMRequesterJobs(Integer pollingPeriodInMins){        
        
        scheduledWebCallOut.SchedulerMethod(pollingPeriodInMins);
        
        return;
    }
    
    public static void stopGSEMRequesterJobs(){
        
        String likeValue = 'GSEM Requester%';
        
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime From CronTrigger where CronJobDetail.Name LIKE : likeValue];
        
        //system.debug('Currently running GSEM Jobs: ' + jobs);
        
        for(CronTrigger job : jobs){
            system.debug('Removing: ' + job.CronJobDetail.Name);
            System.abortJob(job.id);
        }
        
        return;
    } 
    
    //
    // Methods for OEM Provider jobs
    //     
    
    public static void getGSEMOEMProviderJobs(){
        
        String likeValue = 'GSEM OEM Provider%';
        
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime From CronTrigger where CronJobDetail.Name LIKE :likeValue];
        
        for(CronTrigger job : jobs){
            system.debug('Job Name: ' + job.CronJobDetail.Name);
        }
        
        return;
    }
    
    public static void startGSEMOEMProviderJobs(Integer pollingPeriodInMins){        
        
        scheduledOEMCallOut.SchedulerMethod(pollingPeriodInMins);
            
        return;
    }  

    public static void stopGSEMOEMProviderJobs(){
        
        String likeValue = 'GSEM OEM Provider%';
        
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime From CronTrigger where CronJobDetail.Name LIKE :likeValue];
        
        //system.debug('Currently running GSEM Jobs: ' + jobs);
        
        for(CronTrigger job : jobs){
            system.debug('Removing: ' + job.CronJobDetail.Name);
            System.abortJob(job.id);
        }
        
        return;
    } 
    

}