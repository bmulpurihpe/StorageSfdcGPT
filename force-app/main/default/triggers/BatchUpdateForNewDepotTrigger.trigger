/*                              <<<< === Apex Trigger=== >>>>
=============================================================================================================
Name                    : BatchUpdateForNewDepotTrigger
Description             : To calculate geolocation for Depot record and uninstall related asset, RMA, AddressBook details from Depot if deactivated.
Created Date            : 19/09/2017
Author                  : Exafort (Azarudeen)
Version                 : 1.2
Modification History    : Initial Version 
Test class              : BatchUpdateForNewDepotTriggerTest
==============================================================================================================
*/
trigger BatchUpdateForNewDepotTrigger on depot__c (after update) {
    
    if(trigger.isUpdate && trigger.isAfter){
        
        list<depot__c> depotlist = [select id, name,depotLocation__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes'];
        List<string> depotID = new List<string>();
		
        for(depot__c incomingNewDepot : Trigger.new){
            
            //Added by exafort on 05/12 for TS-8276
			boolean eligibleFieldsChanged = false;
            depot__c olddepot = Trigger.oldMap.get(incomingNewDepot.Id);
            
            if((olddepot.depotProvider__c != incomingNewDepot.depotProvider__c) ||
               (olddepot.depotStockedFor4Hour__c != incomingNewDepot.depotStockedFor4Hour__c) ||
               (olddepot.depotStockedFor4HourEta__c != incomingNewDepot.depotStockedFor4HourEta__c) ||
               (olddepot.depotIsactive__c != incomingNewDepot.depotIsactive__c) ||
               (olddepot.depotPostalCode__c != incomingNewDepot.depotPostalCode__c) ||
               (olddepot.depotCity__c != incomingNewDepot.depotCity__c) ||
               (olddepot.depotStreet1__c != incomingNewDepot.depotStreet1__c) ||
               (olddepot.depotStreet2__c != incomingNewDepot.depotStreet2__c) ||
               (olddepot.depotCountry__c != incomingNewDepot.depotCountry__c) ||
               (olddepot.depotState__c != incomingNewDepot.depotState__c))
            {
                eligibleFieldsChanged = true;
            }
            //Added end
            //
            if(eligibleFieldsChanged && incomingNewDepot.depotLocation__Latitude__s != null && incomingNewDepot.depotLocation__Longitude__s != null && incomingNewDepot.depotNewDepot__c == true){
                
                depotID.add('Unknown');
                
                decimal searchRadius = DepotReplaceRange__c.getInstance().DepotSearchRangeInMiles__c; //currently 375 miles radius
                
                for(depot__c dp : depotlist){
                    
                    if(dp.Name != incomingNewDepot.Name){
                        
                        Location depotlocation = new location();
                        if(dp.depotLocation__c != null){
                            depotlocation = dp.depotLocation__c;
                        }
                        Location IncomingdepotLocation = Location.newInstance(incomingNewDepot.depotLocation__Latitude__s, incomingNewDepot.depotLocation__Longitude__s);
                        
                        if(depotlocation != null){
                            double distanceval = depotlocation.getDistance(IncomingdepotLocation, 'mi');
                            if(distanceval <= searchRadius){
                                depotID.add(dp.Name);
                            }
                        }
                    } 
                }
                // }
            }
            else {
                system.debug('Depot has NO geolocation value'+incomingNewDepot.depotLocation__c);
            }

        }
        
        if(depotID.size() > 0){
            system.debug('depotID----'+depotID);
            //call batch apex where shipment address depot/install address depot from the depotID result
            //Asset
            //if(system.isBatch() == false && system.isFuture() == false){
            
            
            String depotFormationForQuery = String.format( '(\'\'{0}\'\')', 
                                                          new List<String> { String.join( new List<string>(depotID) , '\',\'') });
            //string Assetquery = 'Select Id, Name,assetLastDepotRecalc__c, assetGeolocation__c FROM Asset where (SLA__c = \'Premium 4 Hour\' or SLA__c = \'Premium 4 Hour Onsite\' or SLA__c = \'TSC: Premium 4 Hour\' or SLA__c = \'TSC: Premium 4 Hour Onsite\') and (assetInstallAddressDepot__c IN'+depotFormationForQuery+'  or assetShipmentAddressDepot__c IN'+depotFormationForQuery+')';            
            string Assetquery = 'Select Id, Name,assetLastDepotRecalc__c,assetGeolocation__c,assetAddressWithoutStreet__c,assetAddressWithCity__c,assetAddress__c,Install_Country__c,SLA__c FROM Asset where (SLA__c = \'Premium 4 Hour\' or SLA__c = \'Premium 4 Hour Onsite\' or SLA__c = \'TSC: Premium 4 Hour\' or SLA__c = \'TSC: Premium 4 Hour Onsite\') and (assetInstallAddressDepot__c IN'+depotFormationForQuery+'  or assetShipmentAddressDepot__c IN'+depotFormationForQuery+')';
            
            //string abquery = 'Select Id, Name,abLastDepotRecalc__c, abGeolocation__c,abRecalculate_Depot__c FROM AddressBook__c where (abOldDepotName__c IN'+depotFormationForQuery+'  or ab4HourDepotName__c IN'+depotFormationForQuery+')';
            //Added abDepot_Recalculation_Failed__c in the SOQL - Komathi(Exafort) TS-6633
            //string abquery = 'Select Id, Name,abLastDepotRecalc__c, abGeolocation__c,abRecalculate_Depot__c,abDepot_Recalculation_Failed__c FROM AddressBook__c where (abOldDepotName__c IN'+depotFormationForQuery+'  or ab4HourDepotName__c IN'+depotFormationForQuery+')';
            string abquery = 'Select Id, Name,abLastDepotRecalc__c, abGeolocation__c,abRecalculate_Depot__c,abDepot_Recalculation_Failed__c,abAddressLine__c, abAddresswithoutstreet__c, abAddresswithCity__c,abCountry__c FROM AddressBook__c where (abOldDepotName__c IN'+depotFormationForQuery+'  or ab4HourDepotName__c IN'+depotFormationForQuery+')';
            
            if(system.isBatch() == false && system.isFuture() == false){
                assetBatchUpdate abu = new assetBatchUpdate('New Depot', Assetquery, abquery);
                Database.executeBatch(abu, 1); 
            }
        }
        //}
    }
}