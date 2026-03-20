/*
 * Created by Exafort for the JIRA TS-9711
 * Batch class to created component record from the FoxConnFactoryUCData
 * This class pass all the processing Asset into the "FoxConnComponentDataUtil" utility class
 * Test Class - AssetComponentFromFoxConnDataBatch_Test
*/
global class AssetComponentFromFoxConnDataBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'select id,name,Inventory_SKUs__c,accountid,Account.name,HPE_Serial_Number__c from asset '
            			+ ' where Support_Profile__c != \'Legacy Nimble\'';
            			//+' where name = \'TW4BKM30F2\' ';
        return Database.getQueryLocator(query);
    }
    
    /*
     * Added by Exafort for SFDC-1512
     * Logic: First, process the Foxconn records by Asset Name. 
     * Then process any remaining, unprocessed Foxconn records by the Asset’s "HPE Serial Number" (HPE_Serial_Number__c)
     */
    global void execute(Database.BatchableContext BC, List<Asset>  assets){
        processAssets(assets, 'assetName');
        processAssets(assets, 'hpeSerialNumber');
    }
    
    private void processAssets(List<Asset> assets, String fieldType) {
        List<String> assetNameList = new List<String>();
        Set<String> eachInventorySkus = new Set<String>();
        Map<String,String> asstWithComp = new Map<String,String>();
        Map<String,Map<String,id>> assetWithCompId = new Map<String,Map<String,id>>();
        List<String> assetNameFromSerialList = new List<String>();
        
        // Get all the asset name in a list
        for(Asset assetRec : assets){
            if (fieldType == 'assetName' && assetRec.Name != null) {            
                assetNameList.add(assetRec.Name);
            } else if (fieldType == 'hpeSerialNumber' && assetRec.HPE_Serial_Number__c != null) {
                assetNameFromSerialList.add(assetRec.Name);
                assetNameList.add(assetRec.HPE_Serial_Number__c);
            }
        }
        
        //Added by Exafort for TS-10398
        //Quries the incomming asset related Component
        
        Set<String> allAssetNames = new Set<String>();
        allAssetNames.addAll(assetNameList);
        allAssetNames.addAll(assetNameFromSerialList);
        
        List<Component__c> ComponentList = [select Id, componentComponentSN__c,componentAssetName__c, componentServicePartNumber__c, componentDiskModel__c, componentAsset__c, componentProcessedByFLEX__c, 
                                            componentState__c, componentType__c, componentAsset__r.HPE_Serial_Number__c from Component__c 
                                 where componentType__c in ('CDM','PSU','IOM','Memory','BootDevice','SSD','Chassis','FC','NIC','SFP','PWR(power supply)','Switch') AND componentAssetName__c =: allAssetNames];
        system.debug('ComponentList : ' + ComponentList.size());
        
        
        if(ComponentList.size() > 0){
            for(Component__c component :ComponentList){
                
                String key;
                if (fieldType == 'assetName') {
                    key = component.componentAssetName__c;
                } else if (fieldType == 'hpeSerialNumber') {
                    key = component.componentAsset__r != null ? component.componentAsset__r.HPE_Serial_Number__c : null;
                }
                
                
                if (String.isNotBlank(key)) {
                    // asstWithComp map logic
                    if(asstWithComp.containsKey(key)){
                        String existingSN = asstWithComp.get(key) + ',' + component.componentComponentSN__c;
                        asstWithComp.put(key, existingSN);
                    } else {
                        asstWithComp.put(key, component.componentComponentSN__c);
                    }
                    
                    // assetWithCompId map logic
                    if(assetWithCompId.containsKey(key)){
                        Map<String, Id> snWithId = assetWithCompId.get(key);
                        snWithId.put(component.componentComponentSN__c, component.Id);
                    } else {
                        Map<String, Id> snWithId = new Map<String, Id>();
                        snWithId.put(component.componentComponentSN__c, component.Id);
                        assetWithCompId.put(key, snWithId);
                    }
                }
            }
        }
        
        system.debug('asstWithComp : ' + asstWithComp);
        system.debug('asstWithComp Size : ' + asstWithComp.size());
        // End of TS-10398
        
        // Process FoxConnFactoryUCData records for the same assets
        if(assetNameList.size() > 0){
            // Uitlity class to create component records
            FoxConnComponentDataUtil fcdc = new FoxConnComponentDataUtil();
            fcdc.processData(assetNameList,asstWithComp,assetWithCompId,fieldType);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // Calls DM7 batch to populate component records
        DM7ComponentBatch dm7batch = new DM7ComponentBatch();
        Database.executeBatch(dm7batch,100);
    }
    
}