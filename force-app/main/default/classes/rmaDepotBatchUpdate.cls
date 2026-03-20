global class rmaDepotBatchUpdate implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    
    private String strParameter;
    private string query = '';
    
    public rmaDepotBatchUpdate(String strParam) {
        strParameter = strParam;
    }

    public rmaDepotBatchUpdate(string strParam, string soql) {
        strParameter = strParam;
        query = soql;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
		// If custom call is made, no need to override it        
        if (query == ''){
            //	Added by exafort for SFDC-1445
            if(strParameter == 'Intraday'){
                query = 'Select Id, Name, rmaGeolocation__c,rmaShipmentCountry__c,rmaCaseNumber__r.Asset.SLA__c FROM RMAv2__c where (rmaRecalculateNearbyDepot__c = true) and (rmaStatus__c = \'Draft\') and (rmaAssetSla__c like \'%4%\' or rmaShipmentSla__c like \'%4%\') AND Id IN (SELECT ParentId FROM RMAv2__History WHERE Field = \'rmaRecalculateNearbyDepot__c\' AND CreatedDate = LAST_N_DAYS:1)'; 
            }
            if(strParameter == 'Daily'){
                query = 'Select Id, Name, rmaGeolocation__c,rmaShipmentCountry__c,rmaCaseNumber__r.Asset.SLA__c FROM RMAv2__c where (rmaRecalculateNearbyDepot__c = true) and (rmaStatus__c = \'Draft\') and (rmaAssetSla__c like \'%4%\' or rmaShipmentSla__c like \'%4%\')'; 
            }
            if(strParameter == 'Weekly'){
                query = 'Select Id, Name, rmaGeolocation__c,rmaShipmentCountry__c,rmaCaseNumber__r.Asset.SLA__c FROM RMAv2__c where (rmaStatus__c = \'Draft\') and (rmaAssetSla__c like \'%4%\' or rmaShipmentSla__c like \'%4%\')'; 
            }
            if(strParameter == 'Geolocation'){
                query = 'Select Id, Name, rmaGeolocation__c, rmaShipmentStreet1__c, rmaShipmentStreet2__c, rmaShipmentAddressDetail__c, rmaShipmentAddresswithCity__c,rmaShipmentCountry__c,rmaCaseNumber__r.Asset.SLA__c FROM RMAv2__c where (rmaStatus__c = \'Draft\') and (rmaAssetSla__c like \'%4%\' or rmaShipmentSla__c like \'%4%\')'; 
            }
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<RMAv2__c> rmalist) {
        //	Added by exafort for SFDC-1445
        if(strParameter == 'Intraday' || strParameter == 'Daily' || strParameter == 'Weekly' || strParameter == 'Custom'){
            //	Added By Exafort For TS-10717
            list<depot__c> depotslistNonJapan = [select id,name,depotLocation__c,depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes'];
            list<depot__c> depotslistTSCJapan = [select id,name,depotLocation__c,depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes' and depotProvider__c = 'TSC'];
            map<id, map<id, Location>> objectIdDepotsId = new map<id, map<id, Location>>();
            map<string, Location> Objectidloc = new map<string, Location>();
            //map<id, Location> depotmaps = new map<id, Location>();
            map<id, boolean> Objectidbool = new map<id, boolean>();
            //system.debug('Query'+depotslist);
            map<id, id> depotmapsNotIn150Miles = new map<id, id>();
            map<id, string> depotNotIn150MilesName = new map<id, string>();
            map<id, string> depotNotIn150MilesProvider = new map<id, string>();
            string addressid = '';
            Location addresslocation = new Location();
            //system.debug('size'+depotslist.size());
            decimal searchRadius = X4HourDepotCalculationSetting__c.getInstance().X4HourDepotSearchRadiusInMiles__c;
            for(RMAv2__c rmains : rmalist)
            {
                map<id, Location> depotmaps = new map<id, Location>();
                addressid = rmains.Id;
                //	Added By Exafort For TS-10717
                list<depot__c> depotslist = new list<depot__c>();
                if(rmains.rmaCaseNumber__r.Asset.SLA__c != null && rmains.rmaCaseNumber__r.Asset.SLA__c.Contains('TSC:') && rmains.rmaShipmentCountry__c != null && rmains.rmaShipmentCountry__c == 'Japan' ){
                    depotslist = depotslistTSCJapan;
                }
                else{
                    depotslist = depotslistNonJapan;
                }
                for(depot__c dp : depotslist){
                    Location depotlocation = new location();
                    depotlocation = dp.depotLocation__c;
                    Location rmaAddressGeo = new location();
                    rmaAddressGeo = rmains.rmaGeolocation__c;
                    if(depotlocation != null && rmaAddressGeo != null){
                        double distanceval = depotlocation.getDistance(rmaAddressGeo, 'mi');
                        if(distanceval <= searchRadius){
                            // Added by Exafort for TS-5631 to check "RMA shipment country and Depot Within USA or FullyForeign"
                            Boolean isValidDepot = Geolocationaddress.isDepotAndShipToWithinUSAorFullyForeign(rmains.rmaShipmentCountry__c, dp);
                            if(isValidDepot){
                                depotmaps.put(dp.Id, dp.depotLocation__c);
                            	//addressid = rmains.Id;
                                addresslocation = rmaAddressGeo;
                            }
                            // End of changes for TS-5631
                            //system.debug('After Distance');*/
                        }
                    }
                }
                if(depotmaps.size()>0){
                    objectIdDepotsId.put(rmains.Id, depotmaps);
                    Objectidloc.put(rmains.Id, rmains.rmaGeolocation__c);
                    Objectidbool.put(rmains.Id, false);
                }
            }
            Geolocationaddress.addressDepotMap(objectIdDepotsId, Objectidloc, 'RMAv2__c', Objectidbool, depotmapsNotIn150Miles, depotNotIn150MilesName, depotNotIn150MilesProvider);
        }
        else if(strParameter == 'Geolocation'){
            map<id, string> rmaMap = new map<id,string>();
            map<id, string> rmaMapwithoutStreet = new map<id,string>();
            map<id, string> rmaMapwithCity = new map<id,string>();
            // Added by Exafort for TS-5631
            Map<Id, String> rmaMapwithCountry = New Map<Id, String>();
            String Objectapi = 'RMAv2__c';
            String address = '';
            String rmaId = '';
            for(RMAv2__c rmains : rmalist)
            {
                address = '';
                address += rmains.rmaShipmentStreet1__c;
                address += rmains.rmaShipmentStreet2__c;
                address += rmains.rmaShipmentAddressDetail__c;
                rmaId = rmains.Id;
                rmaMap.put(rmaId, address);
                rmaMapwithoutStreet.put(rmaId, rmains.rmaShipmentAddressDetail__c);
                rmaMapwithCity.put(rmaId, rmains.rmaShipmentAddresswithCity__c);
                // Added by Exafort for TS-5631
                rmaMapwithCountry.put(rmaId, rmains.rmaShipmentCountry__c);
            }
              // Added new parameter "rmaMapwithCountry" to check for isDepotAndShipToWithinUSAorFullyForeign
            Geolocationaddress.geocodeAddress(rmaMap, Objectapi, rmaMapwithoutStreet, rmaMapwithCity, rmaMapwithCountry);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        if(strParameter == 'Weekly'){
            X4HourDepotCalculationSetting__c customSet = [select id, WeeklyBatchFlag__c from X4HourDepotCalculationSetting__c];
            customSet.WeeklyBatchFlag__c = false;
            update customSet;
        }
    }
}