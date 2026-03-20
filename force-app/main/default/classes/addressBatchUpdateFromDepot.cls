/** PURPOSE : To unlink all the AddressBook records whenever Depot Change
* Date: 10th August 2020
* Author: Exafort  
* Ref :TS-7503 
* Testclass : GeolocationTestClass
* */
global class addressBatchUpdateFromDepot implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{ 
    
    private string query = '';
    private set<id> depotIDSet;
    
    public addressBatchUpdateFromDepot(set<id> depotID) {                 
        depotIDSet = new set<id>();
        depotIDSet =  depotID;
        query = 'select id, name, abRecalculate_Depot__c,abAddressLine__c,ab4HourDepot__r.Name from AddressBook__c where ab4HourDepot__c IN: depotIDSet';         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<AddressBook__c> mapOfAddressbook) {
        system.debug('mapOfAddressbook ' +mapOfAddressbook.size());
        list<AddressBook__c> addressUpdate = new list<AddressBook__c>();                                  
        if(mapOfAddressbook.size()>0){
            for(AddressBook__c addressid : mapOfAddressbook){
                //	Commented Out By Exafort for SFDC-1445
                //addressid.abRecalculate_Depot__c = true;
                addressid.abDepotCalculationstatus__c = 'To be calculated';
                addressid.abDepotCalculationmessage__c = 'To be calculated';
                addressid.abOldDepotName__c = 'Unknown';
                addressid.ab4HourDepot__c = null;
                //	Added by exafort for SFDC-1445
                addressid.ab4HourDepotTsc__c = null;
                addressUpdate.add(addressid);
            }                
        } 
        if(addressUpdate.size() > 0){
            // Added by Exafort for TS-9536
            Database.SaveResult[] addressList = Database.update(addressUpdate, false);
            
            // Iterate through each returned result
            for (Database.SaveResult address : addressList) {
                if (address.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('AddressBook Updated successfully AddressBook ID : ' + address.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : address.getErrors()) {
                        System.debug(err.getStatusCode() + ' : ' + err.getMessage() + '. AddressBook fields that affected this error : ' + err.getFields());

                    }
                }
            }
            // Added end
        }        
    }   
    
    global void finish(Database.BatchableContext BC) {
        try
        { 
            rmaBatchUpdateFromDepot b = new rmaBatchUpdateFromDepot(depotIDSet); 
            Database.executeBatch(b,10);   
        }
        catch(Exception e){
            system.debug('Error on Depot Update'+e.getMessage());
        }  
    }
    
}