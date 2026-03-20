global class RemoveNmblRecordsBatchSchudle implements Schedulable {
    global void execute(SchedulableContext ctx) {
        RemoveNmblRecordsBatch nmbl= new RemoveNmblRecordsBatch();
        database.executeBatch(nmbl,200);
    }
}