global class addressbookBatchUpdate implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    private String strParameter;
    private string query = '';

    /*** TS-7416 Begin To store the nearest depot if depot is not found within 150 miles radius ***/
    private static list<Double> depotsNotIn150Radius = new list<Double>();
    private static map<double, id> depotmapsNotIn150Radius = new map<double, id>();
	/*** TS-7416 End ***/

    public addressbookBatchUpdate(String strParam) {
        strParameter = strParam;
        system.debug('Batch called with' + strParameter);
    }

    public addressbookBatchUpdate(string strParam, string soql) {
        strParameter = strParam;
        query = soql;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // If custom call is made, no need to override it  
        system.debug('query ' +query);     
        if (query == ''){
            //	Added By Exafort for SFDC-1445
            if(strParameter == 'Intraday'){
                system.debug('Start'+strParameter);             
				query = 'Select Id, Name,abAddressLine__c, abGeolocation__c,abRecalculate_Depot__c,abDepot_Recalculation_Failed__c,abCountry__c FROM AddressBook__c where abGeolocationcalculationstatus__c = \'Success\' and (abRecalculate_Depot__c = true or abDepotCalculationstatus__c = \'To be calculated\') AND Id IN (SELECT ParentId FROM AddressBook__History WHERE Field = \'abDepotCalculationstatus__c\' AND CreatedDate = LAST_N_DAYS:1)';
            }
            if(strParameter == 'Daily'){
                system.debug('Start'+strParameter);
                /***  Begin TS-7416,  Added condition abGeolocationcalculationstatus__c = \'Success\' */
				query = 'Select Id, Name,abAddressLine__c, abGeolocation__c,abRecalculate_Depot__c,abDepot_Recalculation_Failed__c,abCountry__c FROM AddressBook__c where abGeolocationcalculationstatus__c = \'Success\' and (abRecalculate_Depot__c = true or abDepotCalculationstatus__c = \'To be calculated\')';
				/***  End TS-7416 */
            }
            else if(strParameter == 'Weekly'){
                system.debug('Start'+strParameter);
                query = 'Select Id, Name,abAddressLine__c, abGeolocation__c,abRecalculate_Depot__c,abDepot_Recalculation_Failed__c,abCountry__c FROM AddressBook__c';
            }
            else if(strParameter == 'Geolocation'){
                system.debug('Start'+strParameter);
                query = 'Select Id, Name, abGeolocation__c, abRecalculate_Depot__c, abAddressLine__c, abAddresswithoutstreet__c, abAddresswithCity__c,abCountry__c FROM AddressBook__c';
            }
        }
        system.debug('@@ Starting Execution @@' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<AddressBook__c> addressList) {
        system.debug('@@ addressBookUpdateBatch addressList'+ addressList.size() +  addressList);
         system.debug('strParameter '+ strParameter);
        calculate4HourDepots(addressList,strParameter);
    }
    
    public static void calculate4HourDepots(Set<id> addressIdSet, string strParameter){
        List<addressBook__c> abList = [select id, abGeolocation__c, abAddressLine__c, abAddresswithoutstreet__c, abAddresswithCity__c,abCountry__c from AddressBook__C where id in :addressIdSet and abGeolocationcalculationstatus__c = 'Success'];
        calculate4HourDepots(abList, strParameter);
    }
    
    public static void calculate4HourDepots(List<AddressBook__c> addressList, string strParameter){
        //	Added By Exafort for SFDC-1445
        if(strParameter == 'Intraday' || strParameter == 'Daily' || strParameter == 'Weekly' || strParameter == 'Custom' || strParameter == 'New Depot'){
            system.debug('@@ In Execute calculate4HourDepots, addressList size ' + addressList.size());
            //	Added by Exafort for TS-10717
            list<depot__c> depotslistNonJapan = [select id,name,depotLocation__c,depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes'];
            list<depot__c> depotslistJapan = [select id,name,depotLocation__c,depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes' and depotProvider__c != 'TSC'];
            //map<id, Location> depotmaps = new map<id, Location>();
            map<id, map<id, Location>> objectIdDepotsId = new map<id, map<id, Location>>();
            map<string, Location> Objectidloc = new map<string, Location>();
            map<id, boolean> Objectidbool = new map<id, boolean>();
            system.debug('Query' + depotslistNonJapan);
            map<id, id> allDepotMapsNotIn150Miles = new map<id, id>();
            map<id, string> depotNotIn150MilesName = new map<id, string>();
            map<id, string> depotNotIn150MilesProvider = new map<id, string>();
            string addressid = '';
            Location addresslocation = new Location();
            system.debug('@@ Depot list size' + depotslistNonJapan.size());
            
            //  Go through addressbooks and find active 4 hour depotsin 150 (taken from custom setting) mile radius for each one of them
            for(AddressBook__c ab : addressList)
            {
                depotsNotIn150Radius.clear();
				depotmapsNotIn150Radius.clear();
                system.debug('Calling depot assignment funtion for assign4HourDepot ' + ab.abGeolocation__c);
                map<id, Location> depotmaps = new map<id, Location>();
				// Added "ab.abCountry__c" by Exafort for TS-5631
				list<depot__c> depotslist = new list<depot__c>();
                //	Added by Exafort for TS-10717
                if(ab.abCountry__c != null && ab.abCountry__c == 'Japan'){
                    depotslist = depotslistJapan;
                    Geolocationaddress.addressBookNearestTSCId = null;
                    if(ab.abAddressLine__c != null){
                        AddressBookForTscUtility obj = new AddressBookForTscUtility(ab.abAddressLine__c);
                        obj.search();
                        Geolocationaddress.addressBookNearestTSCId = (obj.wrapperLstDataList.size() > 0 ? obj.wrapperLstDataList[0].Depotrec.id : null);
                    }
                }
                else{
                    depotslist = depotslistNonJapan;
                }
                
                depotmaps = assign4HourDepot(ab.Id, ab.abGeolocation__c, depotslist, ab.abCountry__c);
                system.debug('Depot Value'+depotmaps);
                
                /*                
                 *  ESC-6123 June 15, 2020
                 *  Ramesh modified the if statement below to include ab.abDepot_Recalculation_Failed__c == null || 
                 *  in the below condition to fix high level of calls to Google API
                 */
                if(depotmaps.size()>0 && (ab.abDepot_Recalculation_Failed__c == null || ab.abDepot_Recalculation_Failed__c <= X4HourDepotCalculationSetting__c.getInstance().X4MaxFailedDepotRecalculation__c)){
                    objectIdDepotsId.put(ab.Id, depotmaps);
                    Objectidloc.put(ab.Id, ab.abGeolocation__c);
                    Objectidbool.put(ab.Id, false);
                }
				///******** TS-7416 Begin,  July 5, 2020 Added to calculate the nearest depot for Address book ******////                
                else if (ab.abDepot_Recalculation_Failed__c == null || ab.abDepot_Recalculation_Failed__c <= X4HourDepotCalculationSetting__c.getInstance().X4MaxFailedDepotRecalculation__c){

                    system.debug('@@ No 4 hour found for ' + ab.name + ', finding closest 4 hour depot');
                    system.debug('@@ depotsNotIn150Radius.size ' + depotsNotIn150Radius.size());
                    if(depotsNotIn150Radius.size() > 0){
                        Double NextNearestDepot = depotsNotIn150Radius.get(0);
                        for(Double depotDistance: depotsNotIn150Radius) {
                            if(depotDistance < NextNearestDepot) NextNearestDepot = depotDistance;
                        }
                        if(NextNearestDepot != null){
                            system.debug('@@@ Closest depot is ' + depotmapsNotIn150Radius.get(NextNearestDepot));
                            allDepotMapsNotIn150Miles.put(ab.Id, depotmapsNotIn150Radius.get(NextNearestDepot));
                            objectIdDepotsId.put(ab.Id, depotmaps);
                            Objectidloc.put(ab.Id, ab.abGeolocation__c);
                            Objectidbool.put(ab.Id, false);
                         }
                    }
                }
				/**	TS-7416 End **/
            }
            system.debug('Objectidloc ' + Objectidloc);
            system.debug('allDepotMapsNotIn150Miles size ' + allDepotMapsNotIn150Miles.size());
            Geolocationaddress.addressDepotMap(objectIdDepotsId, Objectidloc, 'AddressBook__c', Objectidbool, allDepotMapsNotIn150Miles, depotNotIn150MilesName, depotNotIn150MilesProvider);
        }
        
        else if(strParameter == 'Geolocation'){
            //Map of Depot Id, and Depot Address
            system.debug('@@ In param Geolocation');
            map<id, string> addressbookmaps = new map<id, string>();
            map<id, string> addressbookmapswithouStreet = new map<id, string>();
            map<id, string> addressbookmapswithCity = new map<id, string>();
            // Added by Exafort for TS-5631
            Map<Id, String> addressbookmapswithCountry = New Map<Id, String>();
            
            string depotstring = 'AddressBook__c';
            for(AddressBook__c a : addressList)
            {
                addressbookmaps.put(a.Id, a.abAddressLine__c);
                addressbookmapswithouStreet.put(a.Id, a.abAddresswithoutstreet__c);
                addressbookmapswithCity.put(a.Id, a.abAddresswithCity__c);
                // Added by exafort for TS-5631
                addressbookmapswithCountry.put(a.Id, a.abCountry__c);
            }
            // If(!Test.isRunningTest())
            // Added new parameter "addressbookmapswithCountry" to check for isDepotAndShipToWithinUSAorFullyForeign
            Geolocationaddress.geocodeAddress(addressbookmaps, depotstring, addressbookmapswithouStreet, addressbookmapswithCity,addressbookmapswithCountry); 
        }
    }
    
    /**
     * Added new parameter "shipToCountry" - Addresbook.Country to check for isDepotAndShipToWithinUSAorFullyForeign
     */
    public static map<id, Location> assign4HourDepot(id addressId, Location addresslocation, list<depot__c> depotList, string shipToCountry){
        map<id, Location> depotmaps = new map<id, Location>();
        map<depot__c, double> depotmapsfinal = new map<depot__c, double>();
        map<double, depot__c> distanceDepots = new map<double, depot__c>();
        list<double> distanceValue = new list<double>();
        decimal searchRadius = X4HourDepotCalculationSetting__c.getInstance().X4HourDepotSearchRadiusInMiles__c;
        //system.debug('Search radius is set to be ' + searchRadius);
        for(depot__c dp : depotlist){
            Location depotlocation = new location();
            depotlocation = dp.depotLocation__c;
            if(depotlocation != null && addresslocation != null){
                double distanceval = depotlocation.getDistance(addresslocation, 'mi');
                if(distanceval <= searchRadius){
                    // Added by Exafort for TS-5631 to check "Addressbook country and Depot Within USA or FullyForeign"
                    Boolean isValidDepot = Geolocationaddress.isDepotAndShipToWithinUSAorFullyForeign(shipToCountry,dp);
                    if(isValidDepot){
                        depotmaps.put(dp.Id, dp.depotLocation__c);
                        distanceDepots.put(distanceval, dp);
                        distanceValue.add(distanceval);   
                    }
                    // End of Changes for TS-5631
                }
				///******** TS-7416 Begin, out of coverage, but still need to link to a depot	*/
                else if(distanceval > searchRadius){
                    system.debug('For Address Id ' + addressId + ', Adding depot ' +  dp.Id + ' to depotmapsNotIn150Radius with distance ' + distanceval);
                    // Added by Exafort for TS-5631 to check "Addressbook country and Depot Within USA or FullyForeign"
                    Boolean isValidDepot = Geolocationaddress.isDepotAndShipToWithinUSAorFullyForeign(shipToCountry,dp);
                    if(isValidDepot){
                        depotsNotIn150Radius.add(distanceval);	//	Global variable
                        depotmapsNotIn150Radius.put(distanceval, dp.Id);	//	Global variable
                    }
                    // End of Changes for TS-5631
                }
				/**	TS-7416 End **/
            }
        }
        
        //addressmap.put(ab.Id, ab.addressGeoCode__c);
        //system.debug('Calling geo location method with ' + depotmaps.size() + ' depots in radius');
        return depotmaps;
        //Geolocationaddress.addressDepotMap(depotmaps, addressid, addresslocation, 'AddressBook__c', false);
    }
    
    global void finish(Database.BatchableContext BC) {
        //	Added By Exafort for SFDC-1445
        if(strParameter == 'Intraday' || strParameter == 'Daily'){  
            system.debug('In Finish ' + strParameter + ', calling assetBatchUpdate');
            assetBatchUpdate s = new assetBatchUpdate(strParameter);
            Database.executeBatch(s, 10);
        }
        if(strParameter == 'Weekly'){
            X4HourDepotCalculationSetting__c customSet = [select id, WeeklyBatchFlag__c from X4HourDepotCalculationSetting__c];
            customSet.WeeklyBatchFlag__c = false;
            update customSet;
        }
    }
}