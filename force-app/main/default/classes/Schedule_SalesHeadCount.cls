global with sharing class Schedule_SalesHeadCount implements Schedulable{
    global void execute(SchedulableContext sc){
    	SalesHeadCountBatchClass shc = new SalesHeadCountBatchClass();
    	database.executeBatch(shc);
    }
}