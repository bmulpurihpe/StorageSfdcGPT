public class Geolocationaddress {
    // Static variable to avoid recursive occurence
    public static Boolean geocodingCalled = false;
    //	Added by Exafort for SFDC-314    
    private static List<depot__c> activeJapanLegacyNimble4HourDepotList = null;
    private static List<depot__c> activeJapanNonLegacyNimble4HourDepotList = null;
    private static List<depot__c> allActive4HourDepotList = null;
	//	End of SFDC-314
	//	Added by exafort for TS-10717 to store the nearest TSC depot for address book
    public static id addressBookNearestTSCId;
    // TS-7467 --START-- July 13, 2020 Getting the Timezone encoding it and passing it as Endpoint URL to callout
    public static JSONParser callGeolocationTimeZoneApi(double Latitude,double Longitude,string assettimeStamp){       
        string endPoint = 'https://maps.googleapis.com/maps/api/timezone/json?location=' + Latitude + ',' + Longitude +'&timestamp=' + assettimeStamp + '&sensor=false';
        return callGeoLocationApiForEndPoint(endPoint);         
    }
    // TS-7467 --END--
    
    
    //Getting the address encoding it and passing it as Endpoint URL to callout
    public static JSONParser callGeolocationApi(string address){
        string geoAddress = EncodingUtil.urlEncode(address, 'UTF-8');
        string endPoint = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + geoAddress + '&sensor=false';
        return callGeoLocationApiForEndPoint(endPoint);
    }
    
    //Getting the Oringin address and Destination address encoding them and passing it as Endpoint URL to callout
    public static JSONParser callGeolocationApi(Location originAddressGeoLoc, string destination ){
        string destinationaddress = '';
        string originaddress = '';
        //string originaddress = originAddressGeoLoc.getLatitude() + ',' + originAddressGeoLoc.getLongitude();
        //TS-5228 removed to the scientific notation in the location value. eg: Convert 4.077E-4 to 0.0004077 to get the result from Google API      
        originaddress = Decimal.valueOf(originAddressGeoLoc.getLatitude()).toPlainString() + ',' + Decimal.valueOf(originAddressGeoLoc.getLongitude()).toPlainString();        
        originaddress = EncodingUtil.urlEncode(originaddress, 'UTF-8');
        destinationaddress = EncodingUtil.urlEncode(destination, 'UTF-8');        
        string endPoint = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins='+ originaddress +'&destinations=' + destinationaddress ;
        return callGeoLocationApiForEndPoint(endPoint);
    }
    
    //Getting the End point URL and returning the json data from the Callout
    public static JSONParser callGeoLocationApiForEndPoint(string endPoint){
        if (endPoint != null){
            String geocodingKey = X4HourDepotCalculationSetting__c.getInstance().GoogleServerKey__c;
            endPoint += '&key=' + geocodingKey;
            
            system.debug('Google Request endPoint ' + endPoint);
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('GET');
            request.setTimeout(6000);
            system.debug('Response Body Before');
            
            //For test class purpose
            if(Test.isRunningTest()){
                system.debug('Is Test');
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                String responsestr = '';
                if(endPoint.contains('https://maps.googleapis.com/maps/api/geocode/json?address=')){
                    responsestr = '{"results":[{"address_components":[{"long_name":"1938","short_name":"1938","types":["street_number"]},{"long_name":"Junction Avenue","short_name":"Junction Ave","types":["route"]},{"long_name":"North San Jose","short_name":"North San Jose","types":["neighborhood","political"]},{"long_name":"San Jose","short_name":"San Jose","types":["locality","political"]},{"long_name":"Santa Clara County","short_name":"Santa Clara County","types":[ "administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},{"long_name":"95131","short_name":"95131","types":["postal_code"]},{"long_name":"2102","short_name":"2102","types":["postal_code_suffix"]}],"formatted_address":"1938 Junction Ave, San Jose, CA 95131, USA","geometry":{"location":{"lat":37.3822546,"lng":-121.9104787},"location_type":"ROOFTOP","viewport":{"northeast":{"lat":37.3836035802915,"lng":-121.9091297197085},"southwest":{"lat":37.3809056197085,"lng":-121.9118276802915}}},"place_id":"ChIJxaC9jPrLj4AR1G3yPhzYYtk","types":["street_address"]}],"status":"OK"}';
                }
                else{
                    responsestr = '{  "destination_addresses" : [ "24 Litchfield St, Darwin City NT 0800, Australia" ], "origin_addresses" : [ "585 Darwin River Rd, Darwin River NT 0841, Australia" ], "rows" : [{"elements" : [{"distance" : {"text" : "39.5 mi","value" : 63567},"duration" : {"text" : "53 mins","value" : 3198},"status" : "OK"}]}],"status" : "OK"}';
                }
                res.setBody(responsestr);
                res.setStatusCode(200);
                return JSON.createParser(res.getBody());
            }
            else{
                system.debug('Callout Inside');
                //Callout with respected URL data
                HttpResponse response = http.send(request);
                system.debug('Response Body After'+response.getBody());
                system.debug('JSON.createParser(response.getBody());'+JSON.createParser(response.getBody()));
                return JSON.createParser(response.getBody());
            }
        }
        return null;
    }
    
    //Method with Object id and nearby Depots, map of Object id and its location, Object api
    public static void addressDepotMap( map<id, map<id, Location>> depot, map<string, Location> objectIdList, String Objectapi, map<id, boolean> Objectidbool, map<id, id> depotmapsNotIn150Radius, map<id, string> depotRecNotIn150MilesRadiusDepotName, map<id, string> depotRecNotIn150MilesRadiusDepotProvider)
    {
        //Google server key as Custom settings
        String geocodingKey = X4HourDepotCalculationSetting__c.getInstance().GoogleServerKey__c;
        //Asset assetrecord = new Asset();
        list<Asset> assetrecord = new list<Asset>();
        list<AddressBook__c> addressbookrecord = new list<AddressBook__c>();
        List<RMAv2__c> rmaRecord = new List<RMAv2__c>();
        List<Asset> abToUpdateAssetsShipmentAddressDepot = new List<Asset>();
        List<Asset> rmaAsset = new List<Asset>();
        List<AddressBook__c> rmaAssetABDepot = new List<AddressBook__c>();
        List<AddressBook__c> rmaABDepotList = new List<AddressBook__c>();
        Map<ID, ID> abDepotIfNotIn150MilesToRMA = new Map<ID, ID>();
        Map<ID, string> abDepotIfNotIn150MilesToRMA1 = new Map<ID, string>();
        Map<ID, string> abDepotIfNotIn150MilesToRMA2 = new Map<ID, string>();
        Map<ID, string> rmaOverrideShipmentStree1 = new Map<ID, string>();
        Map<ID, string> rmaOverrideShipmentStree2 = new Map<ID, string>();
        Map<ID, string> rmaOverrideShipmentCity = new Map<ID, string>();
        Map<ID, string> rmaOverrideShipmentState = new Map<ID, string>();
        Map<ID, string> rmaOverrideShipmentPostalCode = new Map<ID, string>();
        Map<ID, string> rmaOverrideShipmentCountry = new Map<ID, string>();
        Map<ID, string>  rmaShipmentCountry = new Map<ID, string>();
        Map<ID, ID> rmaAbDepot = new Map<ID, ID>();
        Map<ID, string> rmaAbDepotName = new Map<ID, string>();
        Map<ID, string> rmaAbDepotProvider = new Map<ID, string>();
        list<id> rmaABlist = new list<id>();
        List<Id> rmaDiskShelfAsset = new List<Id>();
        List<Id> rmaAssetAB = new List<Id>();
        List<Id> rmaAssetABDepotID = new List<Id>();
        list<id> addressrecid = new list<id>();
        set<string> assetShipmentDepot = new set<string>();
        List<Depot__c> depotWithShipmentAddress = new List<depot__c>();
        map<id, id> assetAddressmap = new map<id, id>();
        map<id, depot__c> depotMapObj = new map<id, depot__c>();
        map<id, AddressBook__c> assetrecAddressrecmap = new map<id, AddressBook__c>();
        map<id, id> depotWithShipmentAddressDepotMap = new map<id, id>();
        Map<ID, string>  depotWithShipmentAddressDepotNameMap = new Map<ID, string>();
        Map<ID, string>  depotWithShipmentAddressDepotProviderMap = new Map<ID, string>();
        //	Added by exafort for TS-10717
        map<Id,Asset> assetIdWithValue = new map<Id,Asset>();
        
        //To get the Addressbook details, if the call is from Asset in order to update Shipment depot
        if(Objectapi == 'Asset' && objectIdList != null && objectIdList.size()>0 ){
            system.debug('Asset Size' + objectIdList.size());
            
            assetrecord =  [select id, name, assetLastDepotRecalc__c, assetPartShipAddressBook__c,SLA__c,Install_Country__c from Asset where id IN: objectIdList.keySet()];
            system.debug('Asset Records'+assetrecord);
            for(Asset asrec : assetrecord){
                //	Added by exafort for TS-10717
                assetIdWithValue.put(asrec.id,asrec);
                if(asrec.assetPartShipAddressBook__c != null){
                    addressrecid.add(asrec.assetPartShipAddressBook__c);
                    assetAddressmap.put(asrec.id, asrec.assetPartShipAddressBook__c);
                }
            }
            //	Added by exafort for TS-10717
            addressbookrecord = [select id, name, ab4HourDepot__c,abLastDepotRecalc__c, ab4HourDepot__r.name,ab4HourDepotTsc__c,ab4HourDepotTsc__r.name from AddressBook__c where id IN: addressrecid];
            system.debug('Address Size'+addressbookrecord.size());
            for(Asset asrec : assetrecord){
                for(AddressBook__c abrec : addressbookrecord){
                    if(asrec.assetPartShipAddressBook__c == abrec.id){
                        system.debug('Address ID'+abrec.id);
                        assetrecAddressrecmap.put(asrec.id, abrec);
                    }
                }
            }
        }
        /*START - Added by Exafort(Azar) 
         * Purpose - To update related assets shipment address if addressbook is updated
         * Date - 11th Oct 2017
         * */
        if(Objectapi == 'AddressBook__c' && objectIdList != null && objectIdList.size()>0){
            //	Added by exafort for TS-10717
            abToUpdateAssetsShipmentAddressDepot = [Select id,assetShipmentAddressDepot__c,assetPartShipAddressBook__c,SLA__c,Install_Country__c from Asset where assetPartShipAddressBook__c IN: objectIdList.keySet()];
        }
        /***** START - Added by Azar on 27th Feb 2017 *****/
        /***** PURPOSE - Logics to perform If no depots found within 150 miles radius or country is philippines with unknown issue*****/
        if(Objectapi == 'RMAv2__c' && objectIdList != null && objectIdList.size()>0 ){
            rmaRecord = [select id, rmaDiskShelfAsset__c, rmaOverrideShipmentStreet1__c, rmaOverrideShipmentStreet2__c,rmaOverrideShipmentCity__c,rmaOverrideShipmentState__c,rmaOverrideShipmentPostalCode__c, rmaOverrideShipmentCountry__c, rmaShipmentCountry__c, rmaAddressBook__c, rma4HourDepotOutOfCoverage__c from RMAv2__c where ID IN : objectIdList.keySet()];
            for(RMAv2__c rmaRec : rmaRecord){
                if(rmaRec.rmaDiskShelfAsset__c != null){
                    rmaDiskShelfAsset.add(rmaRec.rmaDiskShelfAsset__c);
                }
                if(rmaRec.rmaAddressBook__c != null){
                    rmaABlist.add(rmaRec.rmaAddressBook__c);
                }
                rmaOverrideShipmentStree1.put(rmaRec.Id, rmaRec.rmaOverrideShipmentStreet1__c);
                rmaOverrideShipmentStree2.put(rmaRec.Id, rmaRec.rmaOverrideShipmentStreet2__c);
                rmaOverrideShipmentCity.put(rmaRec.Id, rmaRec.rmaOverrideShipmentCity__c);
                rmaOverrideShipmentState.put(rmaRec.Id, rmaRec.rmaOverrideShipmentState__c);
                rmaOverrideShipmentPostalCode.put(rmaRec.Id, rmaRec.rmaOverrideShipmentPostalCode__c);
                rmaOverrideShipmentCountry.put(rmaRec.Id, rmaRec.rmaOverrideShipmentCountry__c);
                rmaShipmentCountry.put(rmaRec.Id, rmaRec.rmaShipmentCountry__c);
            }
            rmaAsset = [select id, assetPartShipAddressBook__c, assetLastDepotRecalc__c, assetShipmentAddressDepot__c from Asset where ID IN : rmaDiskShelfAsset];
            for(Asset assetRec : rmaAsset){
                if(assetRec.assetPartShipAddressBook__c != null){
                    rmaAssetAB.add(assetRec.assetPartShipAddressBook__c);
                }
                if(assetRec.assetShipmentAddressDepot__c != null){
                    assetShipmentDepot.add(assetRec.assetShipmentAddressDepot__c);
                }
            }
            rmaAssetABDepot = [select id,abLastDepotRecalc__c, ab4HourDepot__c, ab4HourDepot__r.Name, ab4HourDepot__r.depotProvider__c from AddressBook__c where ID IN : rmaAssetAB];
            depotWithShipmentAddress = [select id, Name, depotProvider__c from depot__c where Name IN : assetShipmentDepot];
            
            for(RMAv2__c rmaRow : rmaRecord){
                for(Asset assetRow : rmaAsset){
                    for(AddressBook__c abRow : rmaAssetABDepot){
                        abDepotIfNotIn150MilesToRMA.put(rmaRow.Id, abRow.ab4HourDepot__c);
                        abDepotIfNotIn150MilesToRMA1.put(rmaRow.Id, abRow.ab4HourDepot__r.Name);
                        abDepotIfNotIn150MilesToRMA2.put(rmaRow.Id, abRow.ab4HourDepot__r.depotProvider__c);
                    }
                }
            }
            rmaABDepotList = [Select id,abLastDepotRecalc__c, ab4HourDepot__c, ab4HourDepot__r.Name, ab4HourDepot__r.depotProvider__c from AddressBook__c where ID IN : rmaABlist AND abCountry__c = 'Philippines'];
            for(RMAv2__c rmaRow : rmaRecord){
                for(AddressBook__c ab : rmaABDepotList){
                    if(ab.ab4HourDepot__c != null){
                        rmaAbDepot.put(rmaRow.id, ab.ab4HourDepot__c);
                        rmaAbDepotName.put(rmaRow.id, ab.ab4HourDepot__r.Name);
                        rmaAbDepotProvider.put(rmaRow.id, ab.ab4HourDepot__r.depotProvider__c);
                    }
                }
                for(depot__c depotInfo : depotWithShipmentAddress){
                    depotWithShipmentAddressDepotMap.put(rmaRow.id, depotInfo.id);
                    depotWithShipmentAddressDepotNameMap.put(rmaRow.id, depotInfo.Name);
                    depotWithShipmentAddressDepotProviderMap.put(rmaRow.id, depotInfo.depotProvider__c);
                }
            }
        }
        list<AddressBook__c> Addressbooklist = new list<AddressBook__c>();
        list<Asset> Assetlists = new list<Asset>();
        list<RMAv2__c> rmalists = new list<RMAv2__c>();
        system.debug('nearbydepots size '+ depot.size());
        system.debug('Object Size'+ objectIdList.size());

        list<depot__c> depotrecinsList = [select id, name, depotProvider__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes'];
        for(depot__c dp : depotrecinsList){
            depotMapObj.put(dp.Id, dp);
        }
         system.debug('objectIdList'+ objectIdList);
        //Loop through each record and map the Nearby depots from google callout
        //	Added By Exafort to capture the AddressBook Recalculation Error message
        list<AddressBook__c> addressBookErrorMsgUpdatelist = new list<AddressBook__c>();
        for(String objectId : objectIdList.keySet())
        {
            Location addressloc = objectIdList.get(objectId);
            list<Location> depotdestloc = new list<Location>();
            list<id> depotsNearBy = new list<id>();
            
            Map<id, Location> depotkeymap = new Map<id, Location>();
            depotkeymap.putAll(depot.get(objectId));
            system.debug('depotkeymap =====>'+ depot);
            system.debug('depotkeymap Depo =====>'+ depot.get(objectId));
            
            //Loop throught the depots that can be Nearby
            for(id depotKey : depotkeymap.keySet()){
                system.debug('depotKey'+ depotKey);
                depotdestloc.add(depotkeymap.get(depotKey));
                depotsNearBy.add(depotKey);
            }
            //	Form the Google distination list
            system.debug('destination  list size' + depotdestloc.size());
            integer i = 1;
            string destination = '';
            for(Location destloc : depotdestloc){
                //destination += destloc.getLatitude() + ',' + destloc.getLongitude();
                //TS-5228 removed to the scientific notation in the location value. eg: Convert 4.077E-4 to 0.0004077 to get the result from Google API 
                destination += Decimal.valueOf(destloc.getLatitude()).toPlainString() + ',' + Decimal.valueOf(destloc.getLongitude()).toPlainString();
                if (depotdestloc.size() > i++){
                    destination += '|';
                }
            }
            try {
                //Callout to Google distance api
                JSONParser responseParser = callGeoLocationApi(objectIdList.get(objectId), destination);
                list<string> depotDistanceTextList = new list<string>();
                list<integer> depotDistanceValueList = new list<integer>();
                list<string> timeduration = new list<string>();
                list<integer> timevalue = new list<integer>();
                map<decimal, decimal> driveDistanceDriveTime = new map<decimal, decimal>();
                map<decimal, string> driveTimeTextValue = new map<decimal, string>();
                map<decimal, string> driveDistanceTextValue = new map<decimal, string>();
                decimal Drivedistanceval = 0;
                decimal Drivetimeval = 0;
                string Drivedistancetext = '';
                string Drivetimetext = '';
                System.debug('nextTokenParser =====>'+responseParser.nextToken());
                //Extracting the Json data
                while(responseParser.nextToken() != null) {
                    System.debug('currentToken =====>'+responseParser.getCurrentToken());
                    System.debug('tokenFieldName =====>'+JSONToken.FIELD_NAME);
                    System.debug('parserText =====>'+responseParser.getText());
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
                    driveDistanceDriveTime.put(Drivedistanceval, Drivetimeval);
                }
                map<id, Decimal> depotwithdistance = new map<id, Decimal>();
                map<id, String> depotwithtimetext = new map<id, String>();
                map<id, String> depotwithdistancetext = new map<id, String>();
                if(depotDistanceValueList.size() == depotsNearby.size()){
                    for(integer j=0; j<depotsNearby.size(); j++){
                        //Map the distance between origin and destination with respected Depot
                        depotwithdistance.put(depotsNearby.get(j) ,  depotDistanceValueList.get(j));
                        depotwithtimetext.put(depotsNearby.get(j) ,  timeduration.get(j));
                        depotwithdistancetext.put(depotsNearby.get(j) ,  depotDistanceTextList.get(j));
                    }
                }
                
                //	Find the closest depot
                id depotid;
                Decimal closestDepotDistance = 0.00;
                decimal currentDepotDistance = 0, shortestDistanceSoFar = 0;
                integer depotIndex = 0, shortestDistanceDepotIndex = 0, depotDistanceFinalValue = 0;
                system.debug('Length of Depots with distance = ' + depotwithdistance.size());
                if(depotwithdistance.size()>0){
                    for(id currentDepotId : depotwithdistance.keySet()){
                        currentDepotDistance = depotwithdistance.get(currentDepotId);
                        system.debug('Comparing Depot ' + currentDepotId + ', distance ' + currentDepotDistance);    
                        if(currentDepotDistance != null){
                            if(depotIndex++ == 0 || currentDepotDistance < closestDepotDistance){
                                closestDepotDistance = currentDepotDistance;
                                depotid = currentDepotId;
                                system.debug('Depot ID Insided Loop '+depotid);
                            }
                        }
                    }
                }
                system.debug('Closest 4 hour depot ' + depotId + ' with distance of ' + Objectapi);
                //Update the addressbook with particular Depot
                if(Objectapi == 'AddressBook__c'){
                    AddressBook__c addressbook = new AddressBook__c();  
                    //	Added by Exafort for SFDC-1444, The calculation message remains stagnant even after the geolocation is successfully completed, so it needs to be cleared during the processing.
                    addressbook.abGeolocationCalculationMessage__c = '';
                    if(depotid != null){ 
                        addressbook.id = objectId;
                        addressbook.ab4HourDepot__c = depotid;
                        //	Added by exafort for TS-10717
                        addressbook.ab4HourDepotTsc__c = addressBookNearestTSCId;
                        addressbook.abDistanceTo4HourDepotInMeters__c = closestDepotDistance;
                        addressbook.abRecalculate_Depot__c = false;
                        addressbook.abDepotCalculationstatus__c = 'Success';
                        addressbook.abDepotCalculationmessage__c = 'Updated Successfully';
                        addressbook.abGeolocation__Latitude__s = addressloc.getLatitude();
                        addressbook.abGeolocation__Longitude__s = addressloc.getLongitude();
                        addressbook.abGeolocationcalculationstatus__c = 'Success';
                        addressbook.abLastDepotRecalc__c = system.now();                        
                        /* Begin TS-7416 */
                        addressbook.ab4HourDepotOutOfCoverage__c = false;
                        addressbook.abGeo_Calculation_Failed__c = '';                        
						/* End TS-7416 */                        
                        /* Added by azar
                         * Purpose - To update related assets shipment address if addressbook is updated
         				 * Date - 11th Oct 2017*/
                        Depot__c assignDepot = [Select id, name from Depot__c where ID =: addressbook.ab4HourDepot__c limit 1]; 
                        //	Added by exafort for TS-10717
                        Depot__c assignTSCDepot = new Depot__c();  
                        if(addressbook.ab4HourDepotTsc__c != null){
                            assignTSCDepot = [Select id, name from Depot__c where ID =: addressbook.ab4HourDepotTsc__c limit 1];  
                        }
                        //Exafort - modified the query location on 24 oct 2019 to fix SOQL 201 issue in addressbookBatchUpdate Batch class - TS-6400
                        if(abToUpdateAssetsShipmentAddressDepot.size() > 0){
                            for(Asset abAssets : abToUpdateAssetsShipmentAddressDepot){
                                if(abAssets.assetPartShipAddressbook__c == addressbook.Id){
                                    //Exafort - modified the query location on 24 oct 2019 to fix SOQL 201 issue in Batch class - TS-6400
                                    //- getting the "assignDepot" value before the for loop
                                    //Depot__c assignDepot = [Select id, name from Depot__c where ID =: addressbook.ab4HourDepot__c limit 1];
                                    if(assignDepot.Name != null)
                                        system.debug('assetToProcess.assetShipmentAddressDepot__c =>>');
                                        //	Added by exafort for TS-10717
                                        abAssets.assetShipmentAddressDepot__c = getDepotName(abAssets.Install_Country__c, abAssets.SLA__c, assignDepot.Name, assignTSCDepot.Name);
                                    Assetlists.add(abAssets);
                                }
                            }
                        }
                        Addressbooklist.add(addressbook);
                    }
                    else{
                        addressbook.id = objectId;
                        addressbook.ab4HourDepot__c = null;
                        addressbook.abRecalculate_Depot__c = false;
                        addressbook.abDepotCalculationstatus__c = 'Failed';
                        addressbook.abDepotCalculationmessage__c = '4 hour depot could not be found';
                        addressbook.abGeolocation__Latitude__s = addressloc.getLatitude();
                        addressbook.abGeolocation__Longitude__s = addressloc.getLongitude();
                        addressbook.abGeolocationcalculationstatus__c = 'Success';
                        addressbook.ab4HourDepotOutOfCoverage__c = TRUE;
						addressbook.abGeo_Calculation_Failed__c = 'Failed at '+ system.now();
                        /* Begin TS-7416 */
                        addressbook.abDistanceTo4HourDepotInMeters__c = null;
						/* End TS-7416 */
                        
                        /***** START - Added by Azar on 28th Feb 2017 *****/
                        /***** PURPOSE - If no depots found within 150 miles radius, Map next nearest depot *****/
                        if(depotmapsNotIn150Radius.get(addressbook.Id) != null){
                            addressbook.ab4HourDepot__c = depotmapsNotIn150Radius.get(addressbook.Id);
                            //	Added by exafort for TS-10717
                            addressbook.ab4HourDepotTsc__c = addressBookNearestTSCId;
                            addressbook.abDepotCalculationstatus__c = 'Success';
                            addressbook.abDepotCalculationmessage__c = 'No depots found within 150 miles radius. Mapped next closest depot';
                            addressbook.abLastDepotRecalc__c = system.now();
                            /* Begin TS-7416 */
                            addressbook.abGeo_Calculation_Failed__c = '';
                            /* End TS-7416 */
                            addressbook.abDepot_Recalculation_Failed__c = 0;
                        }
                        Addressbooklist.add(addressbook);
                    }
                }
                //Update the Asset with particular Depot
                else if(Objectapi == 'Asset'){
                    Asset assetrec = new Asset();
                    AddressBook__c addrsbookrec = assetrecAddressrecmap.get(objectId);
                    system.debug('Asset AB ID'+addrsbookrec.Id);
                    if(depotid != null){
                        //depot__c depotrecins = [select id, name, depotProvider__c from depot__c where id =: depotid];
                        depot__c depotrecins = depotMapObj.get(depotid);
                        Decimal Distanceinmiles = depotwithdistance.get(depotid) * 0.00062137;
                        
                        System.debug('Asset Distance In miles'+Distanceinmiles);
                        
                        assetrec.id = objectId;
                        assetrec.assetNearbyDepot__c = depotid;
                        assetrec.assetInstallAddressChanged__c = false;
                        assetrec.assetDepotStatus__c = 'Updated Successfully';
                        //	Added by Exafort for SFDC-1444, The calculation message remains stagnant even after the geolocation is successfully completed, so it needs to be cleared during the processing.
                        assetrec.assetDepotCalculationMessage__c = '';
                        //Map Shipment depot from Addressbook of the Asset
                        if(addrsbookrec.ab4HourDepot__c != null){
                            //	Added by exafort for TS-10717
                            Asset assetRecCurrentvalue = assetIdWithValue.get(objectId);
                            assetrec.assetClosestShipDepot__c = getDepotID(assetRecCurrentvalue.Install_Country__c, assetRecCurrentvalue.SLA__c, addrsbookrec.ab4HourDepot__c, addrsbookrec.ab4HourDepotTsc__c);                             
                            assetrec.assetShipmentAddressDepot__c = getDepotName(assetRecCurrentvalue.Install_Country__c, assetRecCurrentvalue.SLA__c, addrsbookrec.ab4HourDepot__r.Name, addrsbookrec.ab4HourDepotTsc__r.Name);
                            assetrec.assetShipAddressChanged__c = false;
                        }
                        else{
                            System.debug('addrsbookrec.ab4HourDepot__c  is null****' );
                            assetrec.assetClosestShipDepot__c = null;
                            assetrec.assetShipmentAddressDepot__c = 'Unknown';
                            assetrec.assetShipAddressChanged__c = true;
                        }                                              
                        assetrec.assetDrivingDistanceto4HourDepot__c = depotwithdistancetext.get(depotid);
                        decimal assetDriveTime = driveDistanceDriveTime.get(depotDistanceFinalValue);
                        assetrec.assetDrivingTimeto4HourDepot__c = depotwithtimetext.get(depotid);
                        assetrec.assetInstallAddressDepot__c = depotrecins.Name;
                        assetrec.assetGeolocation__Latitude__s = addressloc.getLatitude();
                        assetrec.assetGeolocation__Longitude__s = addressloc.getLongitude();
                        assetrec.assetGeolocationStatus__c = 'Success';
                        if(Distanceinmiles <= X4HourDepotCalculationSetting__c.getInstance().X4HourDepotSearchRadiusInMiles__c){
                            assetrec.asset4HourDepotOutOfCoverage__c = false;
                        }
                        else{
                            assetrec.asset4HourDepotOutOfCoverage__c = true;
                        }
                        assetrec.assetLastDepotRecalc__c = system.now();
                        Assetlists.add(assetrec);
                    }
                    else{
                        assetrec.id = objectId;
                        assetrec.assetNearbyDepot__c = depotid;
                        assetrec.assetInstallAddressChanged__c = false;
                        if(addrsbookrec.ab4HourDepot__c != null){
                            //	Added by exafort for TS-10717
                            Asset assetRecCurrentvalue = assetIdWithValue.get(objectId);
                            assetrec.assetClosestShipDepot__c = getDepotID(assetRecCurrentvalue.Install_Country__c, assetRecCurrentvalue.SLA__c, addrsbookrec.ab4HourDepot__c, addrsbookrec.ab4HourDepotTsc__c);   
                            assetrec.assetShipmentAddressDepot__c = getDepotName(assetRecCurrentvalue.Install_Country__c, assetRecCurrentvalue.SLA__c, addrsbookrec.ab4HourDepot__r.Name, addrsbookrec.ab4HourDepotTsc__r.Name);
                            assetrec.assetShipAddressChanged__c = false;
                        }
                        else{
                            assetrec.assetShipAddressChanged__c = true;                        
                        }
                        assetrec.assetDrivingDistanceto4HourDepot__c = 'N/A';
                        assetrec.assetDrivingTimeto4HourDepot__c = 'N/A';
                        assetrec.assetInstallAddressDepot__c = 'Unknown';
                        assetrec.asset4HourDepotOutOfCoverage__c = true;
                        assetrec.assetDepotStatus__c = 'Failed';
                        assetrec.assetGeolocation__Latitude__s = addressloc.getLatitude();
                        assetrec.assetGeolocation__Longitude__s = addressloc.getLongitude();
                        assetrec.assetGeolocationStatus__c = 'Success';
                        /***** START - Added by Azar on 28th Feb 2017 *****/
                        /***** PURPOSE - If no depots found within 150 miles radius, Map next nearest depot *****/
                        if(depotmapsNotIn150Radius.get(assetrec.Id) != null){
                            assetrec.assetNearbyDepot__c = depotmapsNotIn150Radius.get(assetrec.Id);
                            assetrec.assetInstallAddressDepot__c = depotRecNotIn150MilesRadiusDepotName.get(assetrec.Id);
                            assetrec.assetDepotStatus__c = 'Success';
                            assetrec.assetDepotCalculationMessage__c = 'No depots found within 150 miles radius. Mapped closest depot';
                            assetrec.assetLastDepotRecalc__c = system.now();
                        }
                        Assetlists.add(assetrec);
                    }
                }
                //Update the RMA with particular Depot
                else if(Objectapi == 'RMAv2__c'){
                    if(depotid != null){
                        depot__c depotrecins = [select id, name, depotProvider__c from depot__c where id =: depotid];
                        Decimal Distanceinmiles = depotwithdistance.get(depotid) * 0.00062137;
                        System.debug('RMA Distance In miles'+Distanceinmiles);
                        System.debug('Standard Distance'+X4HourDepotCalculationSetting__c.getInstance().X4HourDepotSearchRadiusInMiles__c);
                        
                        RMAv2__c rmarec = new RMAv2__c();
                        rmarec.id = objectId;
                        rmarec.rmaNearbyDepot__c = depotid;
                        rmarec.rmaRecalculateNearbyDepot__c = false;
                        system.debug('Order Depot Value in Geolocation Future Method before assigning value'+rmarec.rmaOutgoingShipmentOrderDepot__c);
                        rmarec.rmaOutgoingShipmentOrderDepot__c = depotrecins.Name;
                        system.debug('Order Depot Value in Geolocation Future Method after assigning value'+rmarec.rmaOutgoingShipmentOrderDepot__c);
                        system.debug('Depot Name' + depotrecins.Name);
                        system.debug('Depot Id' + depotid);
                        system.debug('Depot Miles '+closestDepotDistance *  0.00062137);
                        rmarec.rmaOutgoingShipmentOrderProvider__c = depotrecins.depotProvider__c;
                        rmarec.rma4HourDepotDistanceMiles__c = closestDepotDistance *  0.00062137;
                        rmarec.rmaGeolocation__Latitude__s = addressloc.getLatitude();
                        rmarec.rmaGeolocation__Longitude__s = addressloc.getLongitude();
                        rmarec.rmaDepotCalculationStatus__c = 'Success';
                        rmarec.rmaDepotCalculationMessage__c = 'Updated Successfully';
                        if(Distanceinmiles <= X4HourDepotCalculationSetting__c.getInstance().X4HourDepotSearchRadiusInMiles__c){
                            rmarec.rmaOutgoingShipmentOrder4HrDepotFound__c = 'Yes';
                        }
                        else{
                            rmarec.rmaOutgoingShipmentOrder4HrDepotFound__c = 'No';
                        }
                        system.debug('Setting Depot name to '+ rmarec.rmaOutgoingShipmentOrderDepot__c);
                        system.debug('Setting  rmaOutgoingShipmentOrder4HrDepotFound__c to '+ rmarec.rmaOutgoingShipmentOrder4HrDepotFound__c);                        
                        rmalists.add(rmarec);
                    }
                    else{
                        RMAv2__c rmarec = new RMAv2__c();
                        rmarec.id = objectId;
                        rmarec.rmaNearbyDepot__c = depotid;
                        rmarec.rmaRecalculateNearbyDepot__c = false;
                        rmarec.rmaOutgoingShipmentOrderDepot__c = 'Unknown - No Logic Found To Update';
                        //rmarec.rmaOutgoingShipmentOrderDepot__c = 'No Depot available within 150 miles radius';
                        rmarec.rmaOutgoingShipmentOrderProvider__c = 'Unknown';
                        //rmarec.rmaOutgoingShipmentOrder4HrDepotFound__c = 'Unknown';
                        rmarec.rmaOutgoingShipmentOrder4HrDepotFound__c = 'No';
                        rmarec.rmaGeolocation__Latitude__s = addressloc.getLatitude();
                        rmarec.rmaGeolocation__Longitude__s = addressloc.getLongitude();
                        rmarec.rmaDepotCalculationStatus__c = 'Failed';
                        rmarec.rmaDepotCalculationMessage__c = 'Update Failed';
                        rmarec.rma4HourDepotOutOfCoverage__c = TRUE;
                        
                        
                        /***** START - Added by Azar on 24th Feb 2017 *****/
                        /***** PURPOSE - If no depots found within 150 miles radius, Map next nearest depot *****/
                        
                        /***** If no depots found within 150 miles radius and address is NOT overridden address, Map Depot in RMA -> Asset -> AddressBook -> Depot *****/
                        system.debug('@@@ Enhancements started @@@');
                        if(rmaOverrideShipmentStree1.get(rmarec.Id) == null && rmaOverrideShipmentStree2.get(rmarec.Id) == null && rmaOverrideShipmentCity.get(rmarec.Id) == null && rmaOverrideShipmentState.get(rmarec.Id) == null && rmaOverrideShipmentPostalCode.get(rmarec.Id) == null && rmaOverrideShipmentCountry.get(rmarec.Id) == null){
                            system.debug('@@@ Inside Overrideshipment fields @@@');
                            if(abDepotIfNotIn150MilesToRMA.get(rmaRec.Id) != null){
                                rmarec.rmaNearbyDepot__c = abDepotIfNotIn150MilesToRMA.get(rmaRec.Id);
                                rmarec.rmaOutgoingShipmentOrderDepot__c = abDepotIfNotIn150MilesToRMA1.get(rmaRec.Id);
                                rmarec.rmaOutgoingShipmentOrderProvider__c = abDepotIfNotIn150MilesToRMA2.get(rmaRec.Id);
                                rmarec.rmaDepotCalculationStatus__c = 'Success';
                                rmarec.rmaDepotCalculationMessage__c = 'Mapped Depot from AddressBook associated in the Asset';
                            }
                            if(rmaShipmentCountry.get(rmarec.Id) == 'Philippines' && rmarec.rmaOutgoingShipmentOrderDepot__c == 'Unknown - No Logic Found To Update'){
                                if(rmaAbDepot.get(rmarec.Id) != null){
                                    rmarec.rmaNearbyDepot__c = rmaAbDepot.get(rmarec.Id);
                                    rmarec.rmaOutgoingShipmentOrderDepot__c = rmaAbDepotName.get(rmarec.Id);
                                    rmarec.rmaOutgoingShipmentOrderProvider__c = rmaAbDepotProvider.get(rmarec.Id);
                                    rmarec.rmaDepotCalculationStatus__c = 'Success';
                                    rmarec.rmaDepotCalculationMessage__c = 'Mapped depot from Address Book';
                                }
                            }
                        }
                        /***** If no depots found within 150 miles radius and address is overridden address, Map Nearest depot from overridden Address *****/
                        else if(rmaOverrideShipmentStree1.get(rmarec.Id) != null || rmaOverrideShipmentStree2.get(rmarec.Id) != null || rmaOverrideShipmentCity.get(rmarec.Id) != null || rmaOverrideShipmentState.get(rmarec.Id) != null || rmaOverrideShipmentPostalCode.get(rmarec.Id) != null || rmaOverrideShipmentCountry.get(rmarec.Id) != null){
                            system.debug('@@@ shipment is overridden @@@');
                            if(depotmapsNotIn150Radius.get(rmarec.Id) != null){
                                rmarec.rmaNearbyDepot__c = depotmapsNotIn150Radius.get(rmarec.Id);
                                rmarec.rmaOutgoingShipmentOrderDepot__c = depotRecNotIn150MilesRadiusDepotName.get(rmarec.Id);
                                rmarec.rmaOutgoingShipmentOrderProvider__c = depotRecNotIn150MilesRadiusDepotProvider.get(rmarec.Id);
                                rmarec.rmaDepotCalculationStatus__c = 'Success';
                                rmarec.rmaDepotCalculationMessage__c =  'No depots found within 150 miles radius. Mapped next closest depot';
                            }
                            if(rmaShipmentCountry.get(rmarec.Id) == 'Philippines' && rmarec.rmaOutgoingShipmentOrderDepot__c == 'Unknown - No Logic Found To Update'){
                                if(depotWithShipmentAddressDepotMap.get(rmarec.Id) != null){
                                    rmarec.rmaNearbyDepot__c = depotWithShipmentAddressDepotMap.get(rmarec.Id);
                                    rmarec.rmaOutgoingShipmentOrderDepot__c = depotWithShipmentAddressDepotNameMap.get(rmarec.Id);
                                    rmarec.rmaOutgoingShipmentOrderProvider__c = depotWithShipmentAddressDepotProviderMap.get(rmarec.Id);
                                    rmarec.rmaDepotCalculationStatus__c = 'Success';
                                    rmarec.rmaDepotCalculationMessage__c = 'Mapped depot from Asset Shipment Address Depot';
                                }
                            }
                        }                        
                        rmalists.add(rmarec);
                    }
                }              
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR,'Error Geocoding Address - ' + e.getMessage());
                //	Added By Exafort to capture the AddressBook Recalculation Error message
                 if(Objectapi == 'AddressBook__c'){                     
                       addressBookErrorMsgUpdatelist.add(Geolocationaddress.getAddressBookToUpdateErrorMessage(objectId, e.getMessage(), e.getStackTraceString()));
                }
            }
        }
        try{
            if(Addressbooklist.size()>0){
                update Addressbooklist;
            }
            //	Added by Exafort for SFDC-1444: The error was captured at the asset level during the address book process—previously, it was captured in the Address Book under "Geolocation Calculation Message". 
            //	Therefore, it is now handled exclusively at the asset level.
            if (!Assetlists.isEmpty()) {
                Database.SaveResult[] results = Database.update(Assetlists, false);
                
                List<Asset> assetsToUpdateWithError = new List<Asset>();
                
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        Asset failedAsset = new Asset();
                        String errorMessage = '';
                        
                        for (Database.Error err : results[i].getErrors()) {
                            errorMessage += err.getMessage() + ' ';
                            system.debug('errorMessage===='+errorMessage);
                        }
                        failedAsset.id = Assetlists[i].id;
                        failedAsset.assetDepotCalculationMessage__c = errorMessage.trim();
                        failedAsset.assetDepotStatus__c = 'Failed';
                        failedAsset.assetShipAddressChanged__c = true;
                        assetsToUpdateWithError.add(failedAsset);
                    }
                }
                
                // Update the failed assets with error messages
                if (!assetsToUpdateWithError.isEmpty()) {
                    update assetsToUpdateWithError;
                }
            }
            
            if(rmalists.size()>0){
                update rmalists;
            } 
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error Geocoding Address Update - ' + e.getMessage());
            //	Added By Exafort to capture the AddressBook Recalculation Error message
            if(Objectapi == 'AddressBook__c'){
                for(ID AddressBookId : objectIdList.keySet()){
                    addressBookErrorMsgUpdatelist.add(Geolocationaddress.getAddressBookToUpdateErrorMessage(AddressBookId, e.getMessage(), e.getStackTraceString()));
                }
            }
        }
        if (addressBookErrorMsgUpdatelist.size() > 0){
          update addressBookErrorMsgUpdatelist;  
        }
        
    }
    
    /**
     * Added by exafort for TS-5631
     * New parameter added to the method "geocodeAddress" and this method is directly called from "addressbookBatchUpdate,assetBatchUpdate,rmaDepotBatchUpdate"
     * To avoid errors created new method with old paramters
     */
    
    public static void geocodeAddress(Map<id, string> Depot, string Objectapi, Map<id, string> Depotwithoutstreet, Map<id, string> Depotwithcity){
        geocodeAddress(Depot, Objectapi, Depotwithoutstreet, Depotwithcity, null);
    }

    /** 
     * To get Latitute and logitude from the address, Object api, address without street, address with city and country
     * Added new parameter "DepotwithCountry" by exafort for TS-5631 to check depot mapping outside country for United States */
	
    public static void geocodeAddress(Map<id, string> Depot, string Objectapi, Map<id, string> Depotwithoutstreet, Map<id, string> Depotwithcity ,Map<id, string> DepotwithCountry)
    { 
        //Initialisation of list and set for Depot, Addressbook, and Asset
        list<depot__c> depotlists = new list<depot__c>();
        list<AddressBook__c> addresslist = new list<AddressBook__c>();
        list<Asset> assetlist = new list<Asset>();
        list<RMAv2__c> rmarecordlist = new list<RMAv2__c>();
        map<id, Location> addressidLoc = new map<id, Location>();
        
        //	Added by Exafort for SFDC-314 Start
        Map<id,String> depotIdWithAssetSla = new Map<id,String>(); //	Added by Exafort for TS-10717
        if(Objectapi == 'RMAv2__c'){
            for(RMAv2__c rmaRecords : [Select id,rmaCaseNumber__r.Support_Profile__c,rmaCaseNumber__r.Asset.SLA__c from RMAv2__c where id =:Depot.keyset()]){
                depotIdWithAssetSla.put(rmaRecords.id,rmaRecords.rmaCaseNumber__r.Asset.SLA__c); 
            }
        }
        //	Added by Exafort for TS-10717
        else if(Objectapi == 'Asset'){
            for(Asset assetRecords :[Select id,SLA__c from Asset where id =: Depot.keyset()]){
                depotIdWithAssetSla.put(assetRecords.id,assetRecords.SLA__c); 
            }
        }
        // End of SFDC-314 
      
        boolean Objectflag = false;
        if(Depot.size()>1){
            Objectflag = true;
        }
        
        system.debug('ObjectSize' + Depot.size());
        system.debug('objectapi '+ Objectapi);
        //Loop the Map of (Depot Id, Depot Address) or (Address book Id, Address book address)
        //	Added By Exafort to capture the AddressBook Recalculation Error message
        list<AddressBook__c> addressBookErrorMsgUpdatelist = new list<AddressBook__c>();
        for (Id depotId : Depot.keySet()){
            System.debug('Depot Id is ' + depotId);
            depot__c depotrecs = new depot__c();
            AddressBook__c addressrec = new AddressBook__c();
            Asset assetrec = New Asset();
            RMAv2__c rmarecs = new RMAv2__c();
            // Added by Exafort for TS-5631 to get the country
            string depotCountry = null;
            system.debug('DepotwithCountry = '+ DepotwithCountry);
            if(DepotwithCountry != null){
				depotCountry = DepotwithCountry.get(depotId);
            }
            // End of changes for TS-5631
            //encode the string so we can pass it as part of URL
            string geoAddress = Depot.get(depotId);
            string geoAddresswithoutstreet = '';
            string geoAddresswithcity = '';
            if(Depotwithoutstreet != null && Depotwithcity != null){
                geoAddresswithoutstreet = Depotwithoutstreet.get(depotId);
                geoAddresswithcity = Depotwithcity.get(depotId);
            }
            //	Added by exafort for TS-10717
            if(objectapi == 'AddressBook__c' && depotCountry == 'Japan'){
                addressBookNearestTSCId = null;
                AddressBookForTscUtility obj = new AddressBookForTscUtility(geoAddress);
                obj.search();
                addressBookNearestTSCId = (obj.wrapperLstDataList.size() > 0 ? obj.wrapperLstDataList[0].Depotrec.id : null); 
            }
            
            try {
                JSONParser responseParser = callGeolocationApi(geoAddress);
                string status = statusFromJson(responseParser);
                if(status == 'ok'){
                    responseParser = callGeolocationApi(geoAddress);
                }
                else if(status != 'ok' && geoAddresswithoutstreet != null && geoAddresswithoutstreet != ''){
                    responseParser = callGeolocationApi(geoAddresswithoutstreet);
                    status = statusFromJson(responseParser);
                    if(status == 'ok'){
                        responseParser = callGeolocationApi(geoAddresswithoutstreet);
                    }
                    else if(status != 'ok' && geoAddresswithcity != null && geoAddresswithcity != ''){
                        responseParser = callGeolocationApi(geoAddresswithcity);
                        status = statusFromJson(responseParser);
                        responseParser = callGeolocationApi(geoAddresswithcity);
                    }
                }
                //initialize co-ordinates
                double latitude = null;
                double longitude = null;
                while(responseParser.nextToken() != null) {
                    latitude = null;
                    longitude = null;
                    if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'location')) {
                        responseParser.nextToken();
                        while(responseParser.nextToken() != JSONToken.END_OBJECT) {
                            String locationText = responseParser.getText();
                            responseParser.nextToken();
                            if (locationText == 'lat')   
                                latitude = responseParser.getDoubleValue();
                            else if (locationText == 'lng')
                                longitude = responseParser.getDoubleValue();                           
                        }
                    }
                    //	When first one is found break
                    if (latitude != null && longitude != null){
                        break;
                    }
                }
                system.debug('Geolocation found to be, latitude = ' + latitude + ', longitude = ' + longitude);
                //If the call is from Depot batch class or trigger
                if(Objectapi == 'depot__c'){
                    depotrecs.Id = depotId;                    
                    if(latitude != null && longitude != null) {
                        system.debug('ValuesDepot'+latitude+','+longitude);
                        depotrecs.depotLocation__Latitude__s = latitude;
                        depotrecs.depotLocation__Longitude__s = longitude;     
                        depotrecs.depotGeolocationcalculationstatus__c = 'Success';
                        depotrecs.depotGeolocationcalculationmessage__c = 'Geolocation is successfully updated';                        
                    }
                    else{
                        depotrecs.depotLocation__Latitude__s = null;
                        depotrecs.depotLocation__Longitude__s = null;
                        system.debug('Does not have values'+latitude+','+longitude);
                        depotrecs.depotGeolocationcalculationstatus__c = 'Failed';
                        depotrecs.depotGeolocationcalculationmessage__c = 'Geolocation calculation failed';
                        
                    }
                    depotlists.add(depotrecs);
                }
                //If the call is from Address book batch class, update Address book
                else if(Objectapi == 'AddressBook__c'){
                    addressrec.Id = depotId;
                    //	Added by Exafort for SFDC-1444, The calculation message remains stagnant even after the geolocation is successfully completed, so it needs to be cleared during the processing.
                    addressrec.abGeolocationCalculationMessage__c = '';
                    if(latitude != null && longitude != null) {
                        system.debug('ValuesAddress'+latitude+','+longitude);
                        addressrec.abGeolocation__Latitude__s = latitude;
                        addressrec.abGeolocation__Longitude__s = longitude;
                        addressrec.abGeolocationcalculationstatus__c = 'Success';
                        
                        if(Objectflag == false){
                            // Added new parameter "depotCountry" by exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign //
                            depotMapNearby(depotId, Location.newInstance(latitude, longitude), Objectapi, depotCountry);
                        }
                    }
                    else{
                        addressrec.abGeolocation__Latitude__s = null;
                        addressrec.abGeolocation__Longitude__s = null;
                        addressrec.abGeo_Calculation_Failed__c = 'Failed at '+ system.now(); // Added to track the failed count - komathi (eaxfort)
                        system.debug('Doesnot have values'+latitude+','+longitude);
                        addressrec.abGeolocationcalculationstatus__c = 'Failed';
                        if(Objectflag == false){
                            update addressrec;
                        }
                    }
                    addresslist.add(addressrec);
                }
                //If the call is from Asset batch class or trigger
                else if(Objectapi == 'Asset'){
                    assetrec.Id = depotId;
                    string assetId = depotId; //	Added by Exafort for TS-10717
                    if(latitude != null && longitude != null) {
                        system.debug('Values'+latitude+','+longitude);
                        assetrec.assetGeolocation__Latitude__s = latitude;
                        assetrec.assetGeolocation__Longitude__s = longitude;   
                        assetrec.assetInstallAddressChanged__c = true;
                        assetrec.assetGeolocationStatus__c = 'Success';
                        assetrec.assetNearbyDepot__c = null;
                        if(Objectflag == false){
                            // Added new parameter "depotCountry" by exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign //
                            //  depotMapNearby(depotId, Location.newInstance(latitude, longitude), Objectapi, depotCountry); //	Commented by Exafort for TS-10717
                             String assetSla = null;
                            if(depotIdWithAssetSla.containsKey(assetId)){
                                assetSla = depotIdWithAssetSla.get(assetId); 
                            }
                            depotMapNearby(depotId, Location.newInstance(latitude, longitude), Objectapi, depotCountry, assetSla);
                        }
                    }
                    else{
                        assetrec.assetGeolocation__Latitude__s = null;
                        assetrec.assetGeolocation__Longitude__s = null;
                        assetrec.assetNearbyDepot__c = null;
                        assetrec.assetInstallAddressChanged__c = false;
                        assetrec.assetGeolocationStatus__c = 'Failed';
                        system.debug('Does not have values '+latitude+','+longitude);
                        if(Objectflag == false){
                            update assetrec;
                        }
                    }
                    assetlist.add(assetrec);
                }
                //If the call is from RMA batch class or trigger
                else if(Objectapi == 'RMAv2__c'){
                    rmarecs.Id = depotId;
                    string rmaId = depotId;
                    if(latitude != null && longitude != null) {
                        system.debug('Values'+latitude+','+longitude);
                        rmarecs.rmaGeolocation__Latitude__s = latitude;
                        rmarecs.rmaGeolocation__Longitude__s = longitude;
                        rmarecs.rmaRecalculateNearbyDepot__c = true;
                        if(Objectflag == false){
                            // Added new parameter "depotCountry" by exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign 
                            //	Added By exafort for SFDC-314 
                            String assetSla = null;
                            if(depotIdWithAssetSla.containsKey(rmaId)){
                                assetSla = depotIdWithAssetSla.get(rmaId); 
                            }
                            depotMapNearby(rmaId, Location.newInstance(latitude, longitude), Objectapi, depotCountry, assetSla);
                            //	End of SFDC-314
                        }
                    }
                    else{
                        rmarecs.rmaGeolocation__Latitude__s = null;
                        rmarecs.rmaGeolocation__Longitude__s = null;
                        rmarecs.rmaRecalculateNearbyDepot__c = true;
                        system.debug('Doesnot have values'+latitude+','+longitude);
                        if(Objectflag == false){
                            update rmarecs;
                        }
                    }
                    rmarecordlist.add(rmarecs);
                    //update rmaListrec;
                }            
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR,'Error Geocoding Address - ' + e.getMessage());
                //	Added By Exafort to capture the AddressBook Recalculation Error message
                if(Objectapi == 'AddressBook__c'){                     
                       addressBookErrorMsgUpdatelist.add(Geolocationaddress.getAddressBookToUpdateErrorMessage(depotId, e.getMessage(), e.getStackTraceString()));
                }
            }
        }
        try{
            if(depotlists.size()>0){
                update depotlists;
            }
            system.debug('Objectflag'+Objectflag);
            if(addresslist.size()>0 && Objectflag == true){
                update addresslist;
            }
            if(assetlist.size()>0 && Objectflag == true){
                update assetlist;
            }
            if(rmarecordlist.size()>0 && Objectflag == true){
                update rmarecordlist;
            }
        }
        
        catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Error Geocoding Address Update - ' + e.getMessage());
            //	Added By Exafort to capture the AddressBook Recalculation Error message
             if(Objectapi == 'AddressBook__c'){
                for(ID AddressBookId : Depot.keySet()){
                    addressBookErrorMsgUpdatelist.add(Geolocationaddress.getAddressBookToUpdateErrorMessage(AddressBookId, e.getMessage(), e.getStackTraceString()));
                }
            }
        }
        //	Added By Exafort to capture the AddressBook Recalculation Error message
        if (addressBookErrorMsgUpdatelist.size() > 0 && addressBookErrorMsgUpdatelist != null){
            if (!Test.isRunningTest()){
				update addressBookErrorMsgUpdatelist;  
            }
        }
    }
    
    public static string statusFromJson(JSONParser jsonString){
        String Status = '';
        while(jsonString.nextToken() != null) {
            if((jsonString.getCurrentToken() == JSONToken.FIELD_NAME) && (jsonString.getText() == 'status')){
                jsonString.nextToken();
                Status = jsonString.getText();
                system.debug('StatusInside'+Status);
            }
        }
        return Status;
    }
    
    /** Incase of trigger it should be a future call, which calls normal call from this
     * Added by exafort for TS-5631
     * New parameter "DepotwithCountry" to check for "isDepotAndShipToWithinUSAorFullyForeign"
    */
    @future (callout=true)
    public static void geocodeAddressFuture(Map<id, string> Depot, string Objectapi, Map<id, string> Depotwithoutstreet, Map<id, string> Depotwithcity, Map<id, string> DepotwithCountry)
    {
        geocodeAddress(Depot, Objectapi, Depotwithoutstreet, Depotwithcity, DepotwithCountry);
    }
    
    /**
     * Added by exafort for TS-5631
     * New parameter added to the method "geocodeAddressFuture"
     * To avoid errors created new method with old paramters)
     */
    @future (callout=true)
    public static void geocodeAddressFuture(Map<id, string> Depot, string Objectapi, Map<id, string> Depotwithoutstreet, Map<id, string> Depotwithcity)
    {
        geocodeAddress(Depot, Objectapi, Depotwithoutstreet, Depotwithcity, null);
    }
    
    /**
     * Added by exafort for TS-5631
     * New parameter added to the method "depotMapNearby"
     * To avoid errors created new method with old paramters)
     */
	public static void depotMapNearby(String objectId, Location addressloc, String Objectapi){
        depotMapNearby(objectId, addressloc, Objectapi, null);
    }

    public static void depotMapNearby(String objectId, Location addressloc, String Objectapi, String objectCountry){
        depotMapNearby(objectId, addressloc, Objectapi, objectCountry, null);
    }
    
    /**
     * Added by Exafort for TS-5631
     * Added "objectCountry" parameter by Exafort for TS-5631
     * to check depot mapping outside country for "United States" 
	*/
    public static void depotMapNearby(String objectId, Location addressloc, String Objectapi, String objectCountry, String assetSla){
        system.debug('objectCountry = '+ objectCountry);
        system.debug('objectId = '+ objectId);
        map<string, Location> Objectidlist = new map<string, Location>();
        
        //	Commented out SOQL as part of SFDC-314
        //list<depot__c> depotlist = [select id, name,depotLocation__c, depotProvider__c,depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes'];
        //	Added By Exafort for SFDC-314 Start
        //	Added by exafort for TS-10717
        list<depot__c> depotlist = get4HourDepotList(objectCountry, assetSla, Objectapi);
        //	End of SFDC-314
        
        map<id, Location> depotmaps = new map<id, Location>();
        map<id,  map<id, Location>> objectIdDepotLoc = new map<id,  map<id, Location>>();
        map<id, boolean> Objectidbool = new map<id, boolean>();
        decimal searchRadius = X4HourDepotCalculationSetting__c.getInstance().X4HourDepotSearchRadiusInMiles__c;
        system.debug('Search radius is set to be ' + searchRadius);
        /*** Added by azar to catch the next nearest depot if depot is not found within 150 miles radius ***/
        list<Double> depotsNotIn150Radius = new list<Double>();
        map<double, id> depotmapsNotIn150Radius = new map<double, id>();
        Map<id, Location> depotmapsNotIn150Radiuslocations = new Map<id, Location>();
        Map<double, string> depotRecNotIn150MilesRadiusDepotname = new Map<double, string>();
        Map<double, string> depotRecNotIn150MilesRadiusDepotProvider = new Map<double, string>();
        
        system.debug(' depotlist size = '+depotlist.size());
        for(depot__c dp : depotlist){
            Location depotlocation = new location();
			depotlocation = dp.depotLocation__c;
            if(depotlocation != null && addressloc != null){
                double distanceval = depotlocation.getDistance(addressloc, 'mi');
                system.debug(' dp.name '+ dp.name + ' distanceval = ' +distanceval);
                if(distanceval <= searchRadius){
                    // Added by Exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign
                    Boolean addValidDepot = isDepotAndShipToWithinUSAorFullyForeign(objectCountry,dp);
                    if(addValidDepot)
                        depotmaps.put(dp.Id, dp.depotLocation__c);
                    // End of changes for TS-5631
                }
                /*** Added by azar to catch the next nearest depot if depot is not found within 150 miles radius ***/
                else if(distanceval > searchRadius){
                    // Added by Exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign
                    Boolean addValidDepot = isDepotAndShipToWithinUSAorFullyForeign(objectCountry,dp);
                    if(addValidDepot){
                        // End of changes for TS-5631
                        depotsNotIn150Radius.add(distanceval);
                        depotmapsNotIn150Radiuslocations.put(dp.Id, dp.depotLocation__c);
                        depotmapsNotIn150Radius.put(distanceval, dp.Id);
                        depotRecNotIn150MilesRadiusDepotname.put(distanceval, dp.Name);
                        depotRecNotIn150MilesRadiusDepotProvider.put(distanceval, dp.depotProvider__c);
                    }
                }
            }
        }
        
        /*** Added by azar to catch the next nearest depot if depot is not found within 150 miles radius ***/
        Map<id, id> depotRecNotIn150MilesRadius = new Map<id, id>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotNameToRMA = new Map<id, string>();
        Map<id, string> depotRecNotIn150MilesRadiusDepotProviderToRMA = new Map<id, string>();
        
        system.debug('depotsNotIn150Radius = '+depotsNotIn150Radius);
        
        if(depotmaps.size()==0 && depotsNotIn150Radius.size() > 0){
            Double NextNearestDepot = depotsNotIn150Radius.get(0);
            system.debug('NextNearestDepot = '+NextNearestDepot);
            for(Double depotDistance: depotsNotIn150Radius) {
                if(depotDistance < NextNearestDepot) NextNearestDepot = depotDistance;
            }
            if(NextNearestDepot != null){
                depotRecNotIn150MilesRadius.put(objectId, depotmapsNotIn150Radius.get(NextNearestDepot));
                depotRecNotIn150MilesRadiusDepotNameToRMA.put(objectId, depotRecNotIn150MilesRadiusDepotname.get(NextNearestDepot));
                depotRecNotIn150MilesRadiusDepotProviderToRMA.put(objectId, depotRecNotIn150MilesRadiusDepotProvider.get(NextNearestDepot));
            }
        }
        
        objectIdDepotLoc.put(objectId, depotmaps);
        system.debug('Calling geo location method with ' + depotmaps.size() + ' depots in radius');
        system.debug('depot list ' + depotmaps);
        system.debug('@@@ Next Nearest Depot @@@ '+depotRecNotIn150MilesRadius);
        Objectidlist.put(objectId, addressloc);
        Objectidbool.put(objectId, false);
        Geolocationaddress.addressDepotMap(objectIdDepotLoc, Objectidlist, Objectapi, Objectidbool, depotRecNotIn150MilesRadius, depotRecNotIn150MilesRadiusDepotNameToRMA, depotRecNotIn150MilesRadiusDepotProviderToRMA);
    }
    
    /**
     * Method used to find only the same country depot for "United States" using custom settings
     * This assumes X4HourDepotCalculationCountrySynonym__c custom setting only has United States Synonyms for now. 
     * If any other value is added, this method needs to be modified to suppport that change
	**/
    public static Boolean isDepotAndShipToWithinUSAorFullyForeign(String shipToCountry, depot__c depot){
        system.debug('depot.name in check method = ' + depot.name);
        
		Boolean validDepot = false;        
        //	if either ship to country or depot is null, return false, because it is not deterministic
        if (depot == null || shipToCountry == null){
            return false;
        }

        // List to get the "United States" Synonyms from custom settings
        List<X4HourDepotCalculationCountrySynonym__c> CountrySynonymList = X4HourDepotCalculationCountrySynonym__c.getall().values();
        
        /** Map to store all the CountrySynonym Name in lowercase "AssetUtility.USASynonyms"
         * While shipToCountry or depotCountry may return the country name as "UNITED STATES"
         * Instead of adding "UNITED STATES" in custom settings,lowerCase them and get the value from existing "United States"
         * Avoiding duplicate countrySynonym in custom setting "UNITED STATES"
         **/
        if(AssetUtility.USASynonyms.size() <= 0){
            for(X4HourDepotCalculationCountrySynonym__c CountrySynonym : CountrySynonymList){
                string CountrySynonymLwCase = CountrySynonym.Name.toLowerCase();
                AssetUtility.USASynonyms.put(CountrySynonymLwCase,CountrySynonym);
            }
        }
                
        X4HourDepotCalculationCountrySynonym__c shipToCountrySynonym;
        X4HourDepotCalculationCountrySynonym__c depotCountrySynonym;
        if(AssetUtility.USASynonyms != null){
            shipToCountrySynonym = AssetUtility.USASynonyms.get(shipToCountry.toLowerCase());
            //depotCountrySynonym = AssetUtility.USASynonyms.get(depot.depotCountry__c.toLowerCase());
            //	Added By Exafort for SFDC-1444, Included Null check to avoid the Error during Geo calaculation of Addressbook
            depotCountrySynonym = (depot.depotCountry__c != null && AssetUtility.USASynonyms.containsKey(depot.depotCountry__c.toLowerCase()) ? AssetUtility.USASynonyms.get(depot.depotCountry__c.toLowerCase()) : null);
        }
                
        // For 4 hour shipments, between USA and neighbors, it is not possible to meet SLA, so if the depot country and shipto country are different return true
        system.debug('shipToCountrySynonym = ' + shipToCountrySynonym);
        system.debug('depotCountrySynonym = ' + depotCountrySynonym);
        
        if(shipToCountrySynonym != null && depotCountrySynonym != null){
            validDepot = True;
        }
        
        // Synonym is not found so return for both depotCountry and Shipto Country
        else if(shipToCountrySynonym == null && depotCountrySynonym == null){
            validDepot = True;
        }
        system.debug('validDepot = ' + validDepot);
        
        return validDepot;
    }
    
    /*
 	 * Returns 4 Hour depot list. Parameters Country and supportProfile help fine tune the depots in scope
 	 * This caches depot query values based on the country & profile and issues query only once per query type
 	 */ 
    //	Added by Exafort for SFDC-314 and TS-10717.
    public static string getDepotName(string country, string sla, string normalDepot, string tscDepotName ){
       return (sla != null && country != null && sla.Contains('TSC:') && country == 'Japan' ? tscDepotName :  normalDepot); 
    }
    
    public static string getDepotID(string country, string sla, id normalDepot, id tscDepotName ){
       return (sla != null && country != null && sla.Contains('TSC:') && country == 'Japan' ? tscDepotName :  normalDepot); 
    }
    
    //	Added by exafort for TS-10717
    public static list<depot__c> get4HourDepotList(String country, string assetSla, string Objectapi){
        system.debug('inside get4HourDepotList');
		List<depot__c> depotList = new List<depot__c>();

        if(country != null && country == 'Japan' && assetSla != null){
            //	For Japan, specific rules apply
            if(assetSla.Contains('TSC:')) {
                //	For Legacy Nimble Support profile, only TSC support provider to consider                
                if(activeJapanLegacyNimble4HourDepotList == null){
                    activeJapanLegacyNimble4HourDepotList = [select id, name, depotProvider__c, depotLocation__c, depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes' and depotProvider__c = 'TSC'];
                }
                depotList= activeJapanLegacyNimble4HourDepotList;
            }else{
                //	For any profile other than Legacy Nimble Support profile in Japan, exclude TSC support provider
                if(activeJapanNonLegacyNimble4HourDepotList == null){
                    activeJapanNonLegacyNimble4HourDepotList = [select id, name, depotProvider__c, depotLocation__c, depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes' and depotProvider__c != 'TSC'];
                }
				depotList = activeJapanNonLegacyNimble4HourDepotList;
            }
        }else{
            //	All
            if(allActive4HourDepotList == null){
                //	Added by exafort for TS-10717
                if(country != null && country == 'Japan' && Objectapi != null && Objectapi == 'AddressBook__c'){
                    allActive4HourDepotList = [select id, name, depotProvider__c, depotLocation__c, depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes' and depotProvider__c != 'TSC'];
                }
                else{
                    allActive4HourDepotList = [select id, name, depotProvider__c, depotLocation__c, depotCountry__c from depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = 'Yes'];
                }
            }
            depotList = allActive4HourDepotList;
        }
        system.debug('returning get4HourDepotList ' + depotList);
        return depotList;
    }
    //	End of SFDC-314
    //	Added By Exafort to capture the AddressBook Recalculation Error message
    Public Static AddressBook__c getAddressBookToUpdateErrorMessage(ID addressBookId, string msg, string stackTrace){       
        AddressBook__c addressBookToUpdate = new AddressBook__c();
        addressBookToUpdate.id = addressBookId; 
        addressBookToUpdate.abGeolocationCalculationMessage__c =  msg + stackTrace;
        return addressBookToUpdate;       
    }
}