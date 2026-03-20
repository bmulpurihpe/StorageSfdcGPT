@isTest
private class Test_ShipmentDeleteBatch {
    
    @testsetup
    public static void setup(){
        List<Shipment_Flexflow__c> shipments = new List<Shipment_Flexflow__c>();
        for(Integer i = 1; i <= 200; i++ ){
            shipments.add(new Shipment_FlexFlow__c(shipmentFlexflowItem__c = 'Item ' + i));
        }
        insert shipments;
    }
    
    @isTest
    public static void runBatch(){
        Test.startTest();
        Id batchId = Database.executeBatch(new ShipmentDeleteBatch());
        Test.stopTest();
        System.assertEquals(0, [Select count() from Shipment_Flexflow__c]);
    }
}