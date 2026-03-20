/*
	This Class is used as the Utility for DepotmappingTool class common method were stored in this class for reusability
*/ 
public class DepotmappingUtility {
    
    public static JSONParser callGeolocationApi(Location originAddressGeoLoc, string destination ){
        string destinationaddress = '';
        //string originaddress = originAddressGeoLoc.getLatitude() + ',' + originAddressGeoLoc.getLongitude(); 
        //TS-5228 removed to the scientific notation in the location value. eg: Convert 4.077E-4 to 0.0004077 to get the result from Google API      
        string originaddress = Decimal.valueOf(originAddressGeoLoc.getLatitude()).toPlainString() + ',' + Decimal.valueOf(originAddressGeoLoc.getLongitude()).toPlainString();
        originaddress = EncodingUtil.urlEncode(originaddress, 'UTF-8');
        destinationaddress = EncodingUtil.urlEncode(destination, 'UTF-8');        
        string endPoint = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins='+ originaddress +'&destinations=' + destinationaddress ;
        return Geolocationaddress.callGeoLocationApiForEndPoint(endPoint);
    }

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
                HttpResponse response = http.send(request);
                system.debug(response.getBody());
                return JSON.createParser(response.getBody());
            }
        }
        return null;
    }
    
    public static map<depot__c, Location> getListSorted(map<double, depot__c> depotLoc,  List<double> DepotDistance){
        DepotDistance.sort();
        list<depot__c> depotTempList = new list<depot__c>();
        map<depot__c, Location> depotMap = new map<depot__c, Location>();
        integer i = 0;
        for(double dpval : depotLoc.keySet()){
            if(i <= 10){
                depotTempList.add(depotLoc.get(DepotDistance.get(i)));
                i = i+1;
            }
        }
        
        for(depot__c dp : depotTempList){
            depotMap.put(dp, dp.depotLocation__c);
        }
        
        return depotMap;
    }
    
    public static map<double,double> getGeocodes(String Addressstr){
        
        if (Addressstr ==  null || Addressstr == '') return null;
        
        system.debug('getGeocodes Search'+Addressstr);
        map<double,double> addressGeocode = new map<double, double>();
        String geocodingKey = X4HourDepotCalculationSetting__c.getInstance().GoogleServerKey__c;
        //encode the string so we can pass it as part of URL
        string geoAddress = EncodingUtil.urlEncode(Addressstr, 'UTF-8');
        try {
            JSONParser responseParser = DepotmappingUtility.callGeoLocationApiForEndPoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + geoAddress + '&key=' + geocodingKey + '&sensor=false');
            //initialize co-ordinates
            double latitude = null;
            double longitude = null;
            while(responseParser.nextToken() != null) {
                if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'location')) {
                    responseParser.nextToken();
                    while(responseParser.nextToken() != JSONToken.END_OBJECT) {
                        
                        String locationText = responseParser.getText();
                        responseParser.nextToken();
                        if (locationText == 'lat'){
                            latitude = responseParser.getDoubleValue();
                        }
                        else if (locationText == 'lng'){
                            longitude = responseParser.getDoubleValue();
                        }
                    }
                }
                //	Once we find the first one, break and return;
                if(latitude != null && longitude != null){
                    break;                            
                }                
            }
            
            addressGeocode.put(latitude, longitude);
            return addressGeocode;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR,'Error Geocoding Address - ' + e.getMessage());
            return null;
        }
    }
    
}