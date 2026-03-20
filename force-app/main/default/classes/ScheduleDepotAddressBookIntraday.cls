global class ScheduleDepotAddressBookIntraday implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        addressbookBatchUpdate batch = new addressbookBatchUpdate('Intraday');
        Database.executeBatch(batch, 20);
    }
}