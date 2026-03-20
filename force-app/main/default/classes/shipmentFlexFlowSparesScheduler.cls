global class shipmentFlexFlowSparesScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        String query = 'Select Id,shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where ((NOT shipmentFlexflowUnitSerialNumber__c LIKE \'A%\') and shipmentFlexflowChildSn__c != null and  shipmentFlexflowReferenceA__c!=null and shipmentFlexflowFlexProcessed__c=null) or (shipmentFlexflowFlexProcessed__c=\'Server Error\')';
        shipmentFlexFlowSparesBatch shipmentFlexFlow = new shipmentFlexFlowSparesBatch(query);
        Database.executeBatch(shipmentFlexFlow,10);
    }
}