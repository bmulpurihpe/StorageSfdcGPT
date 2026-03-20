global class AssetsShipmentFlexProcessedScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        String query = 'Select Id,Name,CreatedDate,Asset_Type__c,assetComponentCreatedStatus__c,Component_SKUs__c,assetComponentProcessedMessage__c FROM Asset where assetComponentCreatedStatus__c = \'Partial Success\' OR assetComponentCreatedStatus__c=\'Error\'';
        AssetsShipmentFlexProcessedUpdate AssetshipmentFlexFlow = new AssetsShipmentFlexProcessedUpdate(query);
        Database.executeBatch(AssetshipmentFlexFlow,1);
    }
}