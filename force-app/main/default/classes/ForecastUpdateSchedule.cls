/**
 * A scheduled job send email notification to manager when forecast is edited.
 */

global class ForecastUpdateSchedule implements Schedulable 
{
    global static final String JOB_NAME = 'Forecast update notification';
    private static final String EMAIL_TEMPLATE_NAME = 'Forecast Update Notification';
    private Id userId;
    private Id editorId;

    global ForecastUpdateSchedule(Id uid, Id eid)
    {
        userId = uid;
        editorId = eid;
    }

    global void execute(SchedulableContext sc) 
    {
        List<EmailTemplate> templates = [select Id from EmailTemplate where Name = :EMAIL_TEMPLATE_NAME];
        if(!templates.isEmpty())
        {
            List<User> users = [select Id, Email from User where Id = :userId];
            if(!users.isEmpty())
            {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(templates[0].Id);
                email.setTargetObjectId(editorId);
                email.setWhatId(users[0].Id);
                Set<Id> parentRoleUserIds = ForecastingService.GetParentRoleUserIds(userId);
                List<User> parentUsers = [select Id, Email from User where Id in :parentRoleUserIds];
                if(parentUsers.size() > 0 || userId != editorId)
                {
                    List<String> ccAddresses = new List<String>();
                    if(parentUsers.size() > 0)
                    {
                        for(Integer i = 0; i < parentUsers.size(); i++)
                        {
                            ccAddresses.add(parentUsers[i].Email);
                        }
                    }
                    if(userId != editorId)
                    {
                        ccAddresses.add(users[0].Email);
                    }
                    email.setCcAddresses(ccAddresses);
                }
                //email.setCcAddresses(new List<String> {'matt@snapbi.com'});
                email.setSaveAsActivity(false);
                try
                {
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { email });
                }
                catch(Exception ex)
                {
                    System.debug(ex);
                }
                finally
                {
                    
                    List<CustomForecast__c> forecasts = [select Id, ScheduledEmailTimeStamp__c from CustomForecast__c where User__c = :userId and Locked__c = false order by LastModifiedDate desc limit 1];
                    if(forecasts.size() > 0)
                    {
                        forecasts[0].ScheduledEmailTimeStamp__c = null;
                        update forecasts;
                    }
                }
            }
        }
        removeScheduledJob(userId);
    }

    @future
    static void removeScheduledJob(String userId)
    {
        String jobName = JOB_NAME + '_' + userId;
        List<CronTrigger> scheduledJobs = [select Id from CronTrigger where CronJobDetail.Name = :jobName];
        if(!scheduledJobs.isEmpty())
        {
            try
            {
                System.abortJob(scheduledJobs[0].Id);
            }
            catch(Exception ex)
            {
                System.debug('Exception thrown when remove forecast update scheduled job: ' + ex);
            }
        }
    }
}