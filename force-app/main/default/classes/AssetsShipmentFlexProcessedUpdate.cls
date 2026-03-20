global class AssetsShipmentFlexProcessedUpdate implements Database.Batchable<sObject>,Database.Stateful {
    
    global final String Query;
    
    global AssetsShipmentFlexProcessedUpdate(string q){ 
        Query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> Assets)
    {
        Set<String> assetNamesInSet = new Set<String>();
        List <Shipment_Flexflow__c> ShipmentFlexflowForAssetToProcess = new List<Shipment_Flexflow__c>();
        List<Shipment_Flexflow__c> ShipmentFlexflowForUpdate = new List<Shipment_Flexflow__c>();
        For(Asset AssetRec:Assets){
            assetNamesInSet.add(AssetRec.Name);
        }
        if(!assetNamesInSet.isEmpty())
        ShipmentFlexflowForAssetToProcess = [Select Id,Name,shipmentFlexflowUnitSerialNumber__c, shipmentFlexflowChildPn__c, shipmentFlexflowItem__c, shipmentFlexflowChildSn__c, shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c IN :assetNamesInSet AND shipmentFlexflowFlexProcessed__c !=''] ;        
        For(Asset asset:Assets){
            if(!ShipmentFlexflowForAssetToProcess.isEmpty()){
                For(Shipment_Flexflow__c ShipmentFlexFlow: ShipmentFlexflowForAssetToProcess ){ 
                    if(asset.Name == ShipmentFlexFlow.shipmentFlexflowUnitSerialNumber__c && ShipmentFlexFlow.shipmentFlexflowFlexProcessed__c != null){
                        ShipmentFlexFlow.shipmentFlexflowFlexProcessed__c = null;
                        ShipmentFlexFlow.shipmentFlexflowProcessedMessage__c = null;
                    }
                    ShipmentFlexflowForUpdate.add(ShipmentFlexFlow);
                }
            }
        }
        if(!ShipmentFlexflowForUpdate.isEmpty()){
            update ShipmentFlexflowForUpdate;  
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}