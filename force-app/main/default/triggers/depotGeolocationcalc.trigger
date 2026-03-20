/*
* Calculates Geolocation for inserted/updated records. Also marks related asset, address book and RMA for recalculation
*/
trigger depotGeolocationcalc on depot__c (after insert,before insert,before update,after update) {
    string address = '';
    string depotid = '';
    string Objectapi = 'depot__c';
    Map<id, String> Depot = new Map<id, String>();
    map<id, string> depotmapswithouStreet = new map<id, string>();
    map<id, string> depotmapswithCity = new map<id, string>();
    list<depot__c> depotList = new list<depot__c>();
    //	Added by Exafort for SFDC-1445
    Boolean isInsert = False;
    
    if(Trigger.IsUpdate && Trigger.IsAfter){
        for (depot__c depotnew : Trigger.new) {
            
            // Access the "old" record by its ID in Trigger.oldMap
            depot__c depotold = Trigger.oldMap.get(depotnew.Id);
            //	Added by Exafort for SFDC-1445
            if(((depotnew.depotNewDepot__c != depotold.depotNewDepot__c) && depotnew.depotNewDepot__c == true) || (depotnew.depotIsactive__c != depotold.depotIsactive__c) || (depotold.depotPostalCode__c != depotnew.depotPostalCode__c) || (depotold.depotCity__c != depotnew.depotCity__c) || (depotold.depotStreet1__c != depotnew.depotStreet1__c) || (depotold.depotStreet2__c != depotnew.depotStreet2__c) || (depotold.depotCountry__c != depotnew.depotCountry__c) || (depotold.depotState__c != depotnew.depotState__c)){
                //address =  depotnew.depotAddress__c;              
                depotid = depotnew.Id;
                if(depotnew.depotAddress__c != null){
                    Depot.put(depotnew.Id, depotnew.depotAddress__c);
                }
                if(depotnew.depotWithoutStreet__c != null){
                    depotmapswithouStreet.put(depotnew.Id, depotnew.depotWithoutStreet__c);
                }
                if(depotnew.depotWithCity__c != null){
                    depotmapswithCity.put(depotnew.Id, depotnew.depotWithCity__c);
                }
                depotList.add(depotnew);
            }
        }
    }
    if(Trigger.IsInsert && Trigger.IsAfter){
        for (depot__c depotnew : Trigger.new) {
            // address =  depotnew.depotAddress__c;
            depotid = depotnew.Id;
            if(depotnew.depotAddress__c != null){
                Depot.put(depotnew.Id, depotnew.depotAddress__c);
            }
            if(depotnew.depotWithoutStreet__c != null){
                depotmapswithouStreet.put(depotnew.Id, depotnew.depotWithoutStreet__c);
            }
            if(depotnew.depotWithCity__c != null){
                depotmapswithCity.put(depotnew.Id, depotnew.depotWithCity__c);
            }
        }
        //	Added by Exafort for SFDC-1445
        isInsert = true;
    }
    
    if(Trigger.IsInsert && Trigger.IsBefore){
        for (depot__c depotnew : Trigger.new) {
            depotnew.depotGeolocationcalculationstatus__c = 'To be calculated';
            depotnew.depotGeolocationcalculationmessage__c = '';
            depotnew.depotLocation__Latitude__s = null;
            depotnew.depotLocation__Longitude__s = null;
            //	Added by Exafort for SFDC-1445
            depotnew.depotNewDepot__c = true;
            depotnew.TimeTriggerHelper__c = null;
        }
    }
    
    if(Trigger.IsUpdate && Trigger.IsBefore){
        for (depot__c depotnew : Trigger.new) {
            depot__c depotold = Trigger.oldMap.get(depotnew.Id);
            //	Added by Exafort for SFDC-1445
            if(((depotnew.depotNewDepot__c != depotold.depotNewDepot__c) && depotnew.depotNewDepot__c == true) || (depotnew.depotIsactive__c != depotold.depotIsactive__c) || (depotold.depotPostalCode__c != depotnew.depotPostalCode__c) || (depotold.depotCity__c != depotnew.depotCity__c) || (depotold.depotStreet1__c != depotnew.depotStreet1__c) || (depotold.depotStreet2__c != depotnew.depotStreet2__c) || (depotold.depotCountry__c != depotnew.depotCountry__c) || (depotold.depotState__c != depotnew.depotState__c)){                 
                //if(depotnew.depotGeolocationcalculationstatus__c != 'To be calculated'){
                depotnew.depotGeolocationcalculationstatus__c = 'To be calculated';
                depotnew.depotGeolocationcalculationmessage__c = '';
                depotnew.depotLocation__Latitude__s = null;
                depotnew.depotLocation__Longitude__s = null;
                //	Added by Exafort for SFDC-1445
                depotnew.depotNewDepot__c = true;
                depotList.add(depotnew);
                //}
            }
        }
    }
    if(!Depot.isEmpty()){
        if(System.IsBatch() == false && System.isFuture() == false){
            Geolocationaddress.geocodeAddressFuture(Depot, Objectapi, depotmapswithouStreet, depotmapswithCity);
        }
        //	Added by Exafort for SFDC-1445
        if(isInsert){
            if(Depot.Keyset() != null){
                list<depot__c> updateRecalculateCheckbox = new list<depot__c>();
                for(id depotId : Depot.Keyset()){
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
        //	End of SFDC-1445
    }
    
    if((Trigger.IsUpdate && Trigger.IsAfter) && depotList.size() > 0){/// TS-7503 added by Exafort on 10th August 2020(Trigger.IsUpdate && Trigger.IsAfter)
        try{
            set<id> depotSet = new set<id>();
            
            for(Depot__c dep : depotList){
                depot__c oldDepotRecord = Trigger.oldMap.get(dep.Id);
                
                // Added by Exafort for TS-10240
                // if condition restrict the batch run, if the address changes on inactive deopt
                if(oldDepotRecord.depotIsactive__c == True || dep.depotIsactive__c == True){
                    depotSet.add(dep.id);
                }
                // End of TS-10240
            }
            
            if(!depotSet.isEmpty() && System.IsBatch() == false && System.isFuture() == false){
                depotGeolocationCalcFuture.unlinkRecFromDepot(depotSet);
            }
            
        }
        catch(Exception e){
            system.debug('Error on Update'+e.getMessage());
        }
    }   
}