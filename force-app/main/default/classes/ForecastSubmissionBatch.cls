/**
 * Batch job to create next week's CustomForecast.
 */
global class ForecastSubmissionBatch implements Database.Batchable<sObject>
{
    global final String level;
    
    global ForecastSubmissionBatch(String l)
    {
        level = l;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'select Id from CustomForecast__c where Locked__c=false';
        if(level != null)
        {
            query += ' and User__r.ForecastLevel__c=\'Level ' + level + '\'';
        }
        
        List<CustomForecast__c> editableForecasts = Database.query(query);
        ForecastingService.submitForecasts(editableForecasts);
        query = 'select Id from User where ForecastEnabled__c=true and IsActive=true';
        if(level != null)
        {
            query += ' and ForecastLevel__c=\'Level '+level+'\'';
        }
        if(Test.isRunningTest())
        {
            query += ' limit 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope)
    {
        try 
        {
            for(User user : scope)
            {
                ForecastingService.initForecast(user.Id);
            }
        }
        catch(DMLException ex) 
        {
            System.debug(ex);
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
    }
}