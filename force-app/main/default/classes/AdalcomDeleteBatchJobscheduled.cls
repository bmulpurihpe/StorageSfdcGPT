global class AdalcomDeleteBatchJobscheduled implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        AdallomAuditDeleteBatch b = new AdallomAuditDeleteBatch (); 
        database.executebatch(b);
    }
}