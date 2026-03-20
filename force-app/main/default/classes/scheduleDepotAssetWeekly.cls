public class scheduleDepotAssetWeekly implements Schedulable{    
    public void execute(SchedulableContext sc){
        X4HourDepotCalculationSetting__c customSet = [select id, WeeklyBatchFlag__c from X4HourDepotCalculationSetting__c];
        customSet.WeeklyBatchFlag__c = true;
        update customSet;
        assetBatchUpdate s = new assetBatchUpdate('Weekly');
        Database.executeBatch(s, 10);
    }
}