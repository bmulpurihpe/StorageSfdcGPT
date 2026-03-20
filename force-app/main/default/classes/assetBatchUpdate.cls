global class assetBatchUpdate implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{    
    private String strParameter;
    private string query = '';
    private String abQuery;
    public assetBatchUpdate(String strParam) {
        strParameter = strParam;        
    }
    
    public assetBatchUpdate(string strParam, string soql) {
        strParameter = strParam;
        query = soql;
    }
    public assetBatchUpdate(string strParam, string soql, string addressbookQuery) {
        strParameter = strParam;
        query = soql;
        abQuery = addressbookQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // If custom call is made, no need to override it
        if (query == ''){
            //	Added By Exafort for SFDC-1445
            if(strParameter == 'Intraday'){
                query = 'Select Id, Name, assetGeolocation__c,Install_Country__c,SLA__c FROM Asset where (assetInstallAddressChanged__c = true or assetShipAddressChanged__c = true) and (SLA__c = \'Premium 4 Hour\' or SLA__c = \'Premium 4 Hour Onsite\' or SLA__c = \'TSC: Premium 4 Hour\' or SLA__c = \'TSC: Premium 4 Hour Onsite\') AND assetDontCalculateDepot__c = false AND Install_Country__c != \'South Korea\' AND Id IN (SELECT AssetId FROM AssetHistory WHERE Field IN (\'AssetInstallAddressChanged__c\', \'AssetShipAddressChanged__c\') AND CreatedDate = LAST_N_DAYS:1)';
            }
            if(strParameter == 'Daily'){
                query = 'Select Id, Name, assetGeolocation__c,Install_Country__c,SLA__c FROM Asset where (assetInstallAddressChanged__c = true or assetShipAddressChanged__c = true) and (SLA__c = \'Premium 4 Hour\' or SLA__c = \'Premium 4 Hour Onsite\' or SLA__c = \'TSC: Premium 4 Hour\' or SLA__c = \'TSC: Premium 4 Hour Onsite\') AND assetDontCalculateDepot__c = false AND Install_Country__c != \'South Korea\'';
            }
            if(strParameter == 'Weekly'){
                query = 'Select Id, Name, assetGeolocation__c,Install_Country__c,SLA__c FROM Asset where (SLA__c = \'Premium 4 Hour\' or SLA__c = \'Premium 4 Hour Onsite\' or SLA__c = \'TSC: Premium 4 Hour\' or SLA__c = \'TSC: Premium 4 Hour Onsite\') AND assetDontCalculateDepot__c = false AND Install_Country__c != \'South Korea\'';
            }
            if(strParameter == 'Geolocation'){
                query = 'Select Id, Name, assetGeolocation__c,assetAddressWithoutStreet__c,assetAddressWithCity__c,assetAddress__c,Install_Country__c,SLA__c FROM Asset where (SLA__c = \'Premium 4 Hour\' or SLA__c = \'Premium 4 Hour Onsite\' or SLA__c = \'TSC: Premium 4 Hour\' or SLA__c = \'TSC: Premium 4 Hour Onsite\') AND assetDontCalculateDepot__c = false AND Install_Country__c != \'South Korea\'';
            }
        }
        system.debug('@@@ Database.getQueryLocator@@@ '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> assetlist) {
        //	Added By Exafort for SFDC-1445
        if(strParameter == 'Intraday' || strParameter == 'Daily' || strParameter == 'Weekly' || strParameter == 'Custom' || strParameter == 'New Depot'){
            String Objtapi = 'Asset';
            map<id, map<id, Location>> objectIdDepotsId = new map<id, map<id, Location>>();
            map<string, Location> Objectidloc = new map<string, Location>();
            map<id, boolean> Objectidbool = new map<id, boolean>();
            list<Asset> assetlistupdate = new list<Asset>();
             //	Added By Exafort For TS-10717
            list<depot__c> depotslistNonJapan = [select id,name,depotLocation__c,depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes'];
            list<depot__c> depotslistTSCJapan = [select id,name,depotLocation__c,depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes' and depotProvider__c = 'TSC'];
            
            map<id, id> depotmapsNotIn150Miles = new map<id, id>();
            map<id, string> depotNotIn150MilesName = new map<id, string>();
            map<id, string> depotNotIn150MilesProvider = new map<id, string>();
            
            string assetid = '';
            Location addresslocation = new Location();
            
            system.debug('size'+depotslistNonJapan.size());
            system.debug('assetsize'+assetlist.size());        
            
            for(Asset assets : assetlist)
            {
                boolean isOutofCoverage = false;
                map<id, Location> outOfCoverageDepotmaps = new map<id, Location>();
                map<id, Location> depotmaps = new map<id, Location>();
                list<double> outOfCoverageDepotListWithDistance = new list<Double>();
                
                 //	Added By Exafort For TS-10717
                list<depot__c> depotslist = new list<depot__c>();
                if(assets.SLA__c != null && assets.SLA__c.Contains('TSC:') &&  assets.Install_Country__c != null && assets.Install_Country__c == 'Japan' ){
                    depotslist = depotslistTSCJapan;
                }
                else{
                    depotslist = depotslistNonJapan;
                }
                
                assetid = assets.Id;
                for(depot__c dp : depotslist){
                    Location depotlocation = new location();
                    depotlocation = dp.depotLocation__c;
                    if(depotlocation != null && assets.assetGeolocation__c != null){
                        double distanceval = depotlocation.getDistance(assets.assetGeolocation__c, 'mi');                    
                        if(distanceval <= X4HourDepotCalculationSetting__c.getInstance().X4HourDepotSearchRadiusInMiles__c){
                            // Added by Exafort for TS-5631 to check "Asset install country and Depot Within USA or FullyForeign" and the if condition
                            Boolean isValidDepot = Geolocationaddress.isDepotAndShipToWithinUSAorFullyForeign(assets.Install_Country__c, dp);
                            if(isValidDepot){
                            // End of changes for TS-5631
                                depotmaps.put(dp.Id, dp.depotLocation__c);
                                //assetid = assets.Id;
                                addresslocation = assets.assetGeolocation__c;
                                system.debug('After Distance');
                                Objectidbool.put(dp.Id, false);
                            }
                        }else{
                            // Added by Exafort for TS-5631 to check "Asset install country and Depot Within USA or FullyForeign"
                            Boolean isValidDepot = Geolocationaddress.isDepotAndShipToWithinUSAorFullyForeign(assets.Install_Country__c, dp);
                            if(isValidDepot){
                            // End of changes for TS-5631                                
                                outOfCoverageDepotmaps.put(dp.Id, dp.depotLocation__c);
                                addresslocation = assets.assetGeolocation__c;
                                outOfCoverageDepotListWithDistance.add(distanceval);
                                Objectidbool.put(dp.Id, true);
                            }
                        }
                    }
                }
                outOfCoverageDepotListWithDistance.sort();
                //addressmap.put(ab.Id, ab.addressGeoCode__c);
                map<id, Location> depotMapstoUse = depotmaps;
                if(depotmaps.size() < 0){
                    isOutofCoverage = true;
                    
                    // Find the closest 5 and map to one of them
                    map<id, Location> closetOOCDepotMaps = new map<id, Location>();
                    for(integer i=0; i < outOfCoverageDepotListWithDistance.size() && i < 5; i++){
                        Location depotlocation = new location();
                        for (id key: outOfCoverageDepotmaps.keySet()){
                            depotlocation = outOfCoverageDepotmaps.get(key);
                            if(outOfCoverageDepotListWithDistance.get(i) == depotlocation.getDistance(addresslocation, 'mi')){
                                closetOOCDepotMaps.put(key, depotlocation);
                            }
                        }
                    }
                    depotMapstoUse = closetOOCDepotMaps;
                }
                if(depotMapstoUse.size()>0){
                    Objectidloc.put(assets.Id, assets.assetGeolocation__c);
                    objectIdDepotsId.put(assets.Id, depotMapstoUse);
                } 
            }
         
            Geolocationaddress.addressDepotMap(objectIdDepotsId, Objectidloc, Objtapi, Objectidbool, depotmapsNotIn150Miles, depotNotIn150MilesName, depotNotIn150MilesProvider);
        }
        else if(strParameter == 'Geolocation'){
            Map<id, String> Assetsmap = new Map<id, String>();
            Map<id, String> AssetswithoutStreet = new Map<id, String>();
            Map<id, String> AssetswithCity = new Map<id, String>();
            // Added by exafort for TS-5631
            Map<Id, String> AssetswithCountry = New Map<Id, String>();
            for(Asset assets : assetlist)
            {                
                Assetsmap.put(assets.Id, assets.assetAddress__c);
                AssetswithoutStreet.put(assets.Id, assets.assetAddressWithoutStreet__c);
                AssetswithCity.put(assets.Id, assets.assetAddressWithCity__c);
                // Added by exafort for TS-5631
                AssetswithCountry.put(assets.Id, assets.Install_Country__c);
            }
             // Added new parameter "AssetswithCountry" to check for isDepotAndShipToWithinUSAorFullyForeign
            Geolocationaddress.geocodeAddress(Assetsmap, 'Asset', AssetswithoutStreet, AssetswithCity, AssetswithCountry);
        }
    }    
    
    global void finish(Database.BatchableContext BC) {
        //	Added By Exafort for SFDC-1445
        if(strParameter == 'Intraday'  || strParameter == 'Daily' || strParameter == 'Weekly'){
            rmaDepotBatchUpdate s = new rmaDepotBatchUpdate(strParameter);
            Database.executeBatch(s, 1);
        }
        if(strParameter == 'New Depot'){
            addressbookBatchUpdate abu = new addressbookBatchUpdate('New Depot', abQuery);
            Database.executeBatch(abu, 10); 
        }  
    }
}