global class ComponentNICDeleteBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        ComponentNICDeleteBatch nicDelete = new ComponentNICDeleteBatch();
        Database.executeBatch(nicDelete,10);
    }
    }