/** PURPOSE : To unlink all the Asset records whenever Depot Change
* Date: 10th August 2020
* Author: Exafort  
* Ref :TS-7503 
* Testclass : GeolocationTestClass
* */
global class assetBatchUpdateFromDepot  implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{ 
    
    private string query = '';
    private set<id> depotIDSet;
    
    public assetBatchUpdateFromDepot(set<id> depotID) {                 
        depotIDSet = new set<id>();
        depotIDSet =  depotID;
        query = 'select id, name, assetInstallAddressChanged__c,assetNearbyDepot__c,assetClosestShipDepot__c,assetAddress__c from Asset where (assetNearbyDepot__c IN: depotIDSet or assetClosestShipDepot__c IN: depotIDSet) and (SLA__c like \'%4%\')';         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> mapOfAsset) {
        List<Depot__c> depotList = [select id from depot__c where id IN: depotIDSet];    
        list<Asset> assetUpdate = new list<Asset>();
        system.debug('mapOfAsset ' +mapOfAsset.size());
        if(depotList.size() > 0 && mapOfAsset.size() > 0){     
            for(depot__c depotsasset : depotList){
                for(Asset assetid : mapOfAsset)
                {
                    if(depotsasset.Id == assetid.assetNearbyDepot__c){
                        assetid.assetNearbyDepot__c = null;          
                        assetid.assetInstallAddressChanged__c = true;
                        assetid.assetInstallAddressDepot__c = 'Unknown';
                        assetid.assetDepotStatus__c = 'To be calculated';
                    }
                    if(depotsasset.Id == assetid.assetClosestShipDepot__c){
                        assetid.assetShipAddressChanged__c = true;
                        assetid.assetClosestShipDepot__c = null;
                        assetid.assetShipmentAddressDepot__c = 'Unknown';
                    }
                    assetUpdate.add(assetid);
                }
            }
        }
        if(assetUpdate.size() > 0){
            // Added by Exafort for TS-9536
            Database.SaveResult[] assetList = Database.update(assetUpdate, false);
            
            // Iterate through each returned result
            for (Database.SaveResult asst : assetList) {
                if (asst.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Asset Updated successfully Asset ID : ' + asst.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : asst.getErrors()) {
                        System.debug(err.getStatusCode() + ' : ' + err.getMessage() + '. Asset fields that affected this error : ' + err.getFields());
                    }
                }
            }
            // Added end
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        try
        {                        
            addressBatchUpdateFromDepot b = new addressBatchUpdateFromDepot(depotIDSet); 
            Database.executeBatch(b,10);                                  
        }
        catch(Exception e){
            system.debug('Error on Depot Update'+e.getMessage());
        }          
    }
    
}