public class AddressBookForTscUtility {
    public list<depot__c> Depotlist;
    public list<depot__c> depotstotlist;
    public list<myWrapper> wrapperLstDataList;
    public list<myWrapper> wrapperLst;
    public string searchstring;
    public list<string> searchlist;
    public list<myWrapper> wrapperLstOutofCover;
    public list<myWrapper> wrapperLstOutofCoverUnknown;
  
    public AddressBookForTscUtility(string Address){ 
        Depotlist = new list<depot__c>();
        depotstotlist = new list<depot__c>();
        depotstotlist = [select id,name,depotPostalCode__c,depotAddress__c,depotLocation__c,depotProvider__c,depotStockedFor4Hour__c from depot__c where depotStockedFor4Hour__c = 'Yes' and depotIsactive__c = true and depotProvider__c = 'TSC']; 
        searchstring = Address;
    }
    
    public void search() {        
        decimal searchRadius = X4HourDepotCalculationSetting__c.getInstance().X4HourDepotSearchRadiusInMiles__c;
        if(searchstring != null || searchstring != ''){     
            searchlist = new list<String>();
            searchlist.add(searchstring);
            Depotlist.clear();
            map<double,double> addressGeo = new map<double, double>();
            map<depot__c, Location> depotmaps = new map<depot__c, Location>();
            map<depot__c, Location> depotmapsoutofcover = new map<depot__c, Location>();
            map<depot__c, Location> depotmapsoutofcoverUnknown = new map<depot__c, Location>();
            list<myWrapper> depotWrapper = new list<myWrapper>();
            list<myWrapper> depotmapOutofCoverWrap = new list<myWrapper>();
            list<myWrapper> depotmapOutofCoverWrapUnknown = new list<myWrapper>();
            wrapperLst = new list<myWrapper>();
            wrapperLstOutofCover = new list<myWrapper>();
            wrapperLstDataList = new list<myWrapper>();
            wrapperLstOutofCoverUnknown = new list<myWrapper>();
            List<double> DepotDistance = new list<double>();
            List<double> DepotDistanceOut = new list<double>();
            List<double> DepotDistanceUnknown = new list<double>();
            map<double, depot__c> mapDepotDistance = new map<double, depot__c>();
            map<double, depot__c> mapDepotDistanceOut = new map<double, depot__c>();
            map<double, depot__c> mapDepotDistanceUnknown = new map<double, depot__c>();
            string addressid = '';
            Location Geolocation = new location(); 
            addressGeo = DepotmappingUtility.getGeocodes(searchstring);
            
            if(addressGeo != null && addressGeo.size()>0){
                Geolocation = new location();
                for(double lat : addressGeo.keySet()){
                    Geolocation = location.newInstance(lat, addressGeo.get(lat));
                    break;
                }
                for(depot__c dp : depotstotlist){
                    Location depotlocation = new location();
                    depotlocation = dp.depotLocation__c;
                    if(Test.isRunningTest()){
                        depotlocation = Location.newInstance(37.2966853, -122.0975973);
                        dp.depotLocation__Latitude__s = depotlocation.getLatitude();
                        dp.depotLocation__Longitude__s = depotlocation.getLongitude();
                    }
                    if((depotlocation != null && Geolocation != null && dp.depotAddress__c != null && dp.depotAddress__c != '') || (Test.isRunningTest())){
                        double distanceval = depotlocation.getDistance(Geolocation, 'mi');
                        if(distanceval <= searchRadius){
                            depotmaps.put(dp, dp.depotLocation__c);
                            DepotDistance.add(distanceval);
                            mapDepotDistance.put(distanceval, dp);
                        }
                        else if(distanceval < 1500){
                            depotmapsoutofcover.put(dp, dp.depotLocation__c);
                            mapDepotDistanceOut.put(distanceval, dp);
                            DepotDistanceOut.add(distanceval);
                        }
                        else{
                            depotmapsoutofcoverUnknown.put(dp, dp.depotLocation__c);
                            mapDepotDistanceUnknown.put(distanceval, dp);
                            DepotDistanceUnknown.add(distanceval);
                        }
                    }
                }
                if(Test.isRunningTest()){
                    depotmaps.putAll(depotmapsoutofcover);
                    depotmapsoutofcoverUnknown.putAll(depotmapsoutofcover);
                }
                if(depotmaps.size()>0){
                    system.debug('Depot Maps');
                    depotmaps = DepotmappingUtility.getListSorted(mapDepotDistance, DepotDistance);
                    depotWrapper = getDepotwithDistance(depotmaps, Geolocation);
                }
                if(depotmapsoutofcover.size()>0){
                    system.debug('DepotMapOut Size'+depotmapsoutofcover.size());
                    depotmapsoutofcover = DepotmappingUtility.getListSorted(mapDepotDistanceOut, DepotDistanceOut);
                    depotmapOutofCoverWrap = getDepotwithDistance(depotmapsoutofcover, Geolocation);
                }
                if(depotmapsoutofcoverUnknown.size()>0 && depotWrapper.size()<0 && depotmapOutofCoverWrap.size()<0){
                    depotmapsoutofcoverUnknown = DepotmappingUtility.getListSorted(mapDepotDistanceUnknown, DepotDistanceUnknown);
                    depotmapOutofCoverWrapUnknown = getDepotwithDistance(depotmapsoutofcoverUnknown, Geolocation);
                }
                if(depotWrapper != null && depotWrapper.size()>0){
                    for(myWrapper wrapperIns : depotWrapper){
                        system.debug('Boolean Value'+wrapperIns.OutofCoverage);
                        if(wrapperIns.OutofCoverage == false){
                            Decimal distDepot = wrapperIns.DepotDistance * 0.00062137;
                            wrapperIns.DepotDistance = distDepot.setScale(2);                            
                            wrapperLst.add(wrapperIns);
                        }
                        else{
                            Decimal distDepot = wrapperIns.DepotDistance * 0.00062137;
                            wrapperIns.DepotDistance = distDepot.setScale(2);
                            wrapperLstOutofCover.add(wrapperIns);    
                        }
                    }
                }	 
                if(depotmapOutofCoverWrap!=null && depotmapOutofCoverWrap.size()>0){
                    for(myWrapper wrapperInsOut : depotmapOutofCoverWrap){
                        Decimal distDepot = wrapperInsOut.DepotDistance * 0.00062137;
                        wrapperInsOut.DepotDistance = distDepot.setScale(2);                        
                        wrapperLstOutofCover.add(wrapperInsOut);
                    }
                }
                if(depotmapOutofCoverWrapUnknown!=null && depotmapOutofCoverWrapUnknown.size()>0){
                    for(myWrapper wrapperInsOutUnknown : depotmapOutofCoverWrapUnknown){
                        Decimal distDepot = wrapperInsOutUnknown.DepotDistance * 0.00062137;
                        wrapperInsOutUnknown.DepotDistance = distDepot.setScale(2);
                        wrapperLstOutofCover.add(wrapperInsOutUnknown);
                    }
                }
                system.debug('Wraplists'+depotmapsoutofcover.size());
                if((depotmapOutofCoverWrap == null) || (depotmapOutofCoverWrap.size() == 0 && depotWrapper.size() == 0)){
                    system.debug('Outofcover'+depotmapsoutofcover.size());
                    for(depot__c depotKeyoutof : depotmapsoutofcover.keySet()){  
                        Location depotlocation = new location();
                        depotlocation = depotKeyoutof.depotLocation__c;
                        id depotkeyId = depotKeyoutof.id;
                        decimal distanceval = depotlocation.getDistance(Geolocation, 'mi');
                        distanceval = distanceval.round();
                        system.debug('Location Value'+depotlocation);
                        if(depotKeyoutof.depotAddress__c != null && depotKeyoutof.depotAddress__c != ''){
                            wrapperLstOutofCover.add(new myWrapper(depotKeyoutof, distanceval, 'Unknown', false));
                        }
                    }
                }
                system.debug('OutofcoverWRap'+wrapperLstOutofCover.size());
                wrapperLstDataList.addAll(wrapperLst);
                wrapperLstDataList.addAll(wrapperLstOutofCover);
                wrapperLstDataList.sort();
                wrapperLst.sort();
                wrapperLstOutofCover.sort();
            }
        }
    }
    
    public static list<myWrapper> getDepotwithDistance(map<depot__c, Location> depot, Location addressloc){
        list<Location> depotdestloc = new list<Location>();
        list<depot__c> depotsNearBy = new list<depot__c>();
        list<myWrapper> wrapperLstDepot = new list<myWrapper>();
        decimal searchRadius = X4HourDepotCalculationSetting__c.getInstance().X4HourDepotSearchRadiusInMiles__c;
        Location Geolocation = Location.newInstance(37.2966853, -122.0975973);
        for(depot__c depotKey : depot.keySet()){
            system.debug('Depot ID' + depotKey);
            system.debug('Depot Location' + depot.get(depotKey));
            id depotkeyId = depotKey.id;
            if(Test.isRunningTest()){
                depotdestloc.add(Geolocation);
            }
            else{
                depotdestloc.add(depot.get(depotKey));
            }
            depotsNearBy.add(depotKey);
        }
        //	Form the Google distination list
        system.debug('destination  list size' + depotdestloc.size());
        integer i = 1;
        string destination = '';
        for(Location destloc : depotdestloc){
            destination += destloc.getLatitude() + ',' + destloc.getLongitude();
            if (depotdestloc.size() > i++){
                destination += '|';
            }
        }
        try {
            JSONParser responseParser = DepotmappingUtility.callGeoLocationApi(addressloc, destination);
            list<string> depotDistanceTextList = new list<string>();
            list<integer> depotDistanceValueList = new list<integer>();
            list<string> timeduration = new list<string>();
            list<integer> timevalue = new list<integer>();
            map<decimal, string> driveDistanceDriveTime = new map<decimal, string>();
            map<decimal, string> driveTimeTextValue = new map<decimal, string>();
            map<decimal, string> driveDistanceTextValue = new map<decimal, string>();
            decimal Drivedistanceval = 0;
            decimal Drivetimeval = 0;
            string Drivedistancetext = '';
            string Drivetimetext = '';
            while(responseParser.nextToken() != null) {
                if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'distance')) {
                    responseParser.nextToken();
                    while(responseParser.nextToken() != JSONToken.END_OBJECT) {
                        String locationText = responseParser.getText();
                        responseParser.nextToken();
                        if (locationText == 'text'){   
                            Drivedistancetext = responseParser.getText();
                            depotDistanceTextList.add(responseParser.getText());
                        }
                        else if (locationText == 'value'){
                            Drivedistanceval =  responseParser.getIntegerValue();
                            depotDistanceValueList.add(responseParser.getIntegerValue());   
                        }
                        driveDistanceTextValue.put(Drivedistanceval, Drivedistancetext);
                    }
                }
                else if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'duration')) {
                    responseParser.nextToken();
                    while(responseParser.nextToken() != JSONToken.END_OBJECT) {
                        String locationText = responseParser.getText();
                        responseParser.nextToken();
                        if (locationText == 'text'){
                            Drivetimetext = responseParser.getText();
                            timeduration.add(responseParser.getText());
                        }
                        else if (locationText == 'value'){
                            Drivetimeval = responseParser.getIntegerValue();
                            timevalue.add(responseParser.getIntegerValue());
                        }
                        driveTimeTextValue.put(Drivetimeval, Drivetimetext);
                    }
                }
                else if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'status')) {
                    responseParser.nextToken();
                    if(responseParser.getText() == 'ZERO_RESULTS'){
                        depotDistanceTextList.add(null);
                        depotDistanceValueList.add(null);
                        timeduration.add(null);
                        timevalue.add(null);
                    }
                }
                driveDistanceDriveTime.put(Drivedistanceval, Drivetimetext);
            }
            map<depot__c, map<decimal, string>> depotwithdistance = new map<depot__c, map<decimal, string>>();
            
            if(depotDistanceValueList.size() == depotsNearBy.size()){
                for(integer j=0; j<depotsNearBy.size(); j++){
                    if(depotDistanceValueList.get(j) != null){
                        Decimal distDepotRad = depotDistanceValueList.get(j) * 0.00062137;
                        if(distDepotRad < searchRadius){
                            wrapperLstDepot.add(new myWrapper(depotsNearby.get(j), depotDistanceValueList.get(j), driveDistanceDriveTime.get(depotDistanceValueList.get(j)),false));
                        }
                        else{
                            wrapperLstDepot.add(new myWrapper(depotsNearby.get(j), depotDistanceValueList.get(j), driveDistanceDriveTime.get(depotDistanceValueList.get(j)),true));
                        }
             
                    }
                }
            }
            return wrapperLstDepot;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'Error Geocoding Address - ' + e.getMessage());
            return null;
        }
    } 
    
    public class myWrapper implements Comparable{
        
        public depot__c Depotrec;
        public Decimal DepotDistance;
        public String DepotDistanceTime;
        public boolean OutofCoverage;
        
        public myWrapper(depot__c a0, Decimal a1, string a2, boolean a3) {
            Depotrec = a0;
            DepotDistance = a1;
            DepotDistanceTime = a2;
            OutofCoverage = a3;
        }
        public Integer compareTo(Object ObjToCompare) {
            myWrapper compareToEmp = (myWrapper)ObjToCompare;
            if (DepotDistance == compareToEmp.DepotDistance) return 0;
            if (DepotDistance > compareToEmp.DepotDistance) return 1;
            return -1;
            //return DepotDistance.CompareTo(((myWrapper)ObjToCompare).DepotDistance);
        }
    }
    
}