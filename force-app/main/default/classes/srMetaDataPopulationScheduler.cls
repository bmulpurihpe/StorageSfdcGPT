global class srMetaDataPopulationScheduler implements Schedulable{
 global void execute(SchedulableContext sc) {
        srMetaDataPopulationBatch srMetaData = new srMetaDataPopulationBatch();
        Database.executeBatch(srMetaData);
    }
}