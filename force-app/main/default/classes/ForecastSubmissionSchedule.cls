/**
 * This scheduled is supposed to execute at a given date every week to snapshot forecast for users with specified forecast level.
 */
global class ForecastSubmissionSchedule implements Schedulable
{
    global String level;
    
    global ForecastSubmissionSchedule()
    {
      this(null);
    }
    
    global ForecastSubmissionSchedule(String l)
    {
        this.level = l;
    }
    
    global void execute(SchedulableContext SC)
    {
        ForecastSubmissionBatch batch = new ForecastSubmissionBatch(level);
        Database.executeBatch(batch, 10);
    }
}