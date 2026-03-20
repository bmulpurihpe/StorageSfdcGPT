/** PURPOSE : To unlink all the RMA records whenever Depot Change
* Date: 5th August 2020
* Author: Exafort  
* Ref :TS-7503 
* Testclass : GeolocationTestClass
* */
global class rmaBatchUpdateFromDepot  implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{ 
    
    private string query = '';
    private set<id> depotIDSet;
    
    public rmaBatchUpdateFromDepot(set<id> depotID) {                 
        depotIDSet = new set<id>();
        depotIDSet =  depotID;
        query = 'select id, name, rmaRecalculateNearbyDepot__c,rmaShipmentStreet1__c,rmaShipmentStreet2__c,rmaShipmentAddressDetail__c from RMAv2__c where  (rmaNearbyDepot__c IN: depotIDSet) and (rmaAssetSla__c like \'%4%\' or rmaShipmentSla__c like \'%4%\') and (rmaStatus__c = \'Draft\')';         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the RMA records or objects to be passed to execute           
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<RMAv2__c> rmaList) {
        
        system.debug('rmaList ' +rmaList.size());
        list<RMAv2__c> rmaUpdate = new list<RMAv2__c>();                         
        if(rmaList.size()>0){
            for(RMAv2__c rmaid : rmaList){
                rmaid.rmaRecalculateNearbyDepot__c = true;
                rmaid.rmaNearbyDepot__c = null;
                rmaid.rmaDepotCalculationStatus__c = 'To be calculated';
                rmaid.rmaDepotCalculationMessage__c = 'To be calculated';
                rmaid.rmaOutgoingShipmentOrderDepot__c = 'Unknown';
                rmaid.rmaOutgoingShipmentOrderProvider__c = 'Unknown';
                rmaid.rmaOutgoingShipmentOrder4HrDepotFound__c = 'N/A';
                rmaid.rma4HourDepotDistanceMiles__c = null;
                rmaUpdate.add(rmaid);
            }                
        }                      
        
        if(rmaUpdate.size() > 0){
            // Added by Exafort for TS-9536
            Database.SaveResult[] rmav2List = Database.update(rmaUpdate, false);
            
            // Iterate through each returned result
            for (Database.SaveResult rma : rmav2List) {
                if (rma.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('RMAv2 Updated successfully RMAv2 ID : ' + rma.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : rma.getErrors()) {
                        System.debug(err.getStatusCode() + ' : ' + err.getMessage() + '. RMAv2 fields that affected this error : ' + err.getFields());

                    }
                }
            }
            // Added end
        } 
    }   
    
    global void finish(Database.BatchableContext BC) {
        system.debug('rmaBatchUpdateFromDepot finish ' +BC);
        //Added by exafort for SFDC-1445 
        //To reset the recalculate Checkbox after the unlinking process.
        if(depotIDSet != null){
            list<depot__c> updateRecalculateCheckbox = new list<depot__c>();
            for(id depotId : depotIDSet){
                depot__c depot = new depot__c();
                depot.id = depotId;
                depot.depotNewDepot__c = false;
                updateRecalculateCheckbox.add(depot);
            }
            if(updateRecalculateCheckbox != null){
                update updateRecalculateCheckbox;
            }
        }
    }
    
}