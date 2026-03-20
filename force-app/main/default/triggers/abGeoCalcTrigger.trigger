trigger abGeoCalcTrigger on AddressBook__c (before insert,before update,after insert,after update) {
    string address = ''; //Holds address of Address book
    id addressid; //Holds Id of address book
    string Objectapi = 'AddressBook__c';
    String ObjectapiRMA = 'RMAv2__c';
    //String ObjectapiAsset = ''
    String addressrma = '';
    String addressasset = '';
    String rmaIdrec = '';
    
    //Map of RMA Id, RMA address
    map<id, string> rmaMap = new map<id,string>();
    map<id, string> rmaMapwithouStreet = new map<id,string>();
    map<id, string> rmaMapwithCity = new map<id,string>();
    // Added by Exafort for TS-5613, map holds the RMAv2 id and RMAv2 shipmentCountry
    Map<Id, String> rmaMapwithCountry = New Map<Id,String>();
    
    //Map of Asset Id, asset address
    map<id, string> rmaAsset = new map<id,string>();
    map<id, string> rmaAssetwithouStreet = new map<id,string>();
    map<id, string> rmaAssetwithCity = new map<id,string>();
    // Added by Exafort for TS-5613, map holds the RMAv2.asset id and asset.install country
    Map<Id, String> rmaAssetwithCountry = New Map<Id,String>();
    
    //Map of Address books Id, address books address
    Map<id, String> addressmap = new Map<id, String>();
    Map<id, String> addressmapwithoutstreet = new Map<id, String>();
    Map<id, String> addressmapwithcity = new Map<id, String>();
    // Added by Exafort for TS-5613, map holds the addressbook id and addressbook country
    Map<Id, String> addressmapwithCountry = New Map<Id,String>();
    list<AddressBook__c> addressList = new list<AddressBook__c>();
    list<AddressBook__c> addressListForDepotCalc = new list<AddressBook__c>();
    
    //TS-6902
    List<depot__c> koreanActiveDepot = new List<depot__c> ();
    List<CountryAliases__mdt> koreaCountryList_mt = [Select Id,MasterLabel from CountryAliases__mdt];
    List<String> koreaCountryList = new List<String>();
    for(CountryAliases__mdt countryName: koreaCountryList_mt){
        koreaCountryList.add(countryName.MasterLabel);
    }
    system.debug('$$$$ Korean country List size ===>'+koreaCountryList.size());
    //TS-6902
    if(koreaCountryList.size() > 0)
        koreanActiveDepot = [Select Id,
                             depotCountry__c,
                             depotIsactive__c
                             From depot__c 
                             where depotCountry__c IN : koreaCountryList 
                             AND depotIsactive__c = true];     
    
    system.debug('$$$$ Korean Active depot List size ===>'+koreanActiveDepot.size());
    
    //Trigger block for After Update
    if(Trigger.IsUpdate && Trigger.IsAfter){
        for (AddressBook__c addressnew : Trigger.new) {
            // Access the "old" record by its ID in Trigger.oldMap
            AddressBook__c addressold = Trigger.oldMap.get(addressnew.Id);
            //Checks if there is a change in Address && recalculation is marked as true
            if(((addressold.abCity__c != addressnew.abCity__c) || (addressold.abStreet1__c != addressnew.abStreet1__c) || (addressold.abStreet2__c != addressnew.abStreet2__c) || 
                (addressold.abCountry__c != addressnew.abCountry__c) || (addressold.abStateProvince__c != addressnew.abStateProvince__c) || 
                (addressold.abPostalCode__c != addressnew.abPostalCode__c)) && addressnew.abCountry__c != 'South Korea' && addressnew.abDontCalculateDepot__c == false || 
               (addressold.abRecalculate_Depot__c != addressnew.abRecalculate_Depot__c && addressnew.abRecalculate_Depot__c) ){
                   address =  addressnew.abAddressLine__c;
                   addressid = addressnew.Id;
                   addressmap.put(addressid, address);
                   addressmapwithoutstreet.put(addressid, addressnew.abAddresswithoutstreet__c);
                   addressmapwithcity.put(addressid, addressnew.abAddresswithCity__c);
                   // Added by Exafort for TS-5613
                   addressmapwithCountry.put(addressid, addressnew.abCountry__c);
                   addressList.add(addressnew);
               }                       
        }
    }
    
    //Trigger block for After Insert
    if(Trigger.IsInsert && Trigger.IsAfter){
        for (AddressBook__c addressnewins : Trigger.new) {
            if(addressnewins.abCountry__c != 'South Korea' && addressnewins.abDontCalculateDepot__c == false){
                address =  addressnewins.abAddressLine__c;
                addressid = addressnewins.Id;
                addressmap.put(addressid, address);
                addressmapwithoutstreet.put(addressid, addressnewins.abAddresswithoutstreet__c);
                addressmapwithcity.put(addressid, addressnewins.abAddresswithCity__c);
                // Added by Exafort for TS-5613
                addressmapwithCountry.put(addressid, addressnewins.abCountry__c);
                //addressList.add(addressnewins);
            }
        }
    }
    
    //Trigger block for Before Insert
    if(Trigger.IsInsert && Trigger.IsBefore){
        for (AddressBook__c addressnewins : Trigger.new) {
            if(addressnewins.abCountry__c != 'South Korea' && addressnewins.abDontCalculateDepot__c == false){
                addressnewins.abGeolocationcalculationstatus__c = 'To be calculated';
                addressnewins.abDepotCalculationstatus__c = 'To be calculated';
                addressnewins.abDepotCalculationmessage__c = 'To be calculated';
                addressnewins.abGeolocation__Latitude__s = null;
                addressnewins.abGeolocation__Longitude__s = null;
                addressnewins.abRecalculate_Depot__c = true;
                addressnewins.ab4HourDepot__c = null;
                addressnewins.abDistanceTo4HourDepotInMeters__c = null;
                addressnewins.ab4HourDepotOutOfCoverage__c = false;                
            }
            //TS-6902
            else if(addressnewins.abCountry__c != '' 
                    //&& koreaCountryList.contains(addressnewins.abCountry__c)
                    && (!koreaCountryList.isEmpty() && addressnewins.abCountry__c != null) ? koreaCountryList.contains(addressnewins.abCountry__c) : false
                    && koreanActiveDepot.size() > 0 ){
                        addressnewins.abGeolocationcalculationstatus__c = 'Success';
                        addressnewins.abDepotCalculationstatus__c = 'Success';
                        addressnewins.abDepotCalculationmessage__c = 'South Korea depot defaults to an active near by depot';
                        addressnewins.abGeolocation__Latitude__s = null;
                        addressnewins.abGeolocation__Longitude__s = null;
                        addressnewins.abRecalculate_Depot__c = false;
                        addressnewins.ab4HourDepot__c = koreanActiveDepot.size() >= 1 ? koreanActiveDepot[0].Id: null;
                        addressnewins.abDistanceTo4HourDepotInMeters__c = null;
                        addressnewins.ab4HourDepotOutOfCoverage__c = false;
                        addressnewins.abDontCalculateDepot__c = true;
                    }
        }
    }
    
    //Trigger block for Before Update
    if(Trigger.IsUpdate && Trigger.IsBefore){
        for (AddressBook__c addressnew : Trigger.new) {
            AddressBook__c addressold = Trigger.oldMap.get(addressnew.Id);
            //Checks if there is a change in Address && recalculation is marked as true
            system.debug('Ab country ---> '+addressnew.abCountry__c);
            if(((addressold.abCity__c != addressnew.abCity__c) || (addressold.abStreet1__c != addressnew.abStreet1__c) || (addressold.abStreet2__c != addressnew.abStreet2__c) || 
                (addressold.abCountry__c != addressnew.abCountry__c) || (addressold.abStateProvince__c != addressnew.abStateProvince__c) || 
                (addressold.abPostalCode__c != addressnew.abPostalCode__c)) && addressnew.abCountry__c != 'South Korea' && addressnew.abDontCalculateDepot__c == false || 
               (addressold.abRecalculate_Depot__c != addressnew.abRecalculate_Depot__c && addressnew.abRecalculate_Depot__c) ){
                   addressnew.abGeolocationcalculationstatus__c = 'To be calculated';
                   addressnew.abDepotCalculationstatus__c = 'To be calculated';
                   addressnew.abDepotCalculationmessage__c = 'To be calculated';
                   addressnew.abDistanceTo4HourDepotInMeters__c = null;
                   addressnew.abGeolocation__Latitude__s = null;
                   addressnew.abGeolocation__Longitude__s = null;
                   addressnew.abRecalculate_Depot__c = true;
                   addressnew.ab4HourDepot__c = null;
                   addressnew.ab4HourDepotOutOfCoverage__c = false;
                   addressList.add(addressnew);
               } 
            //TS-6902
            else if(addressnew.abCountry__c != '' 
                    //&& koreaCountryList.contains(addressnew.abCountry__c)
                    && (!koreaCountryList.isEmpty() && addressnew.abCountry__c != null) ? koreaCountryList.contains(addressnew.abCountry__c) : false
                    && koreanActiveDepot.size() > 0){
                        addressnew.abGeolocationcalculationstatus__c = 'Success';
                        addressnew.abDepotCalculationstatus__c = 'Success';
                        addressnew.abDepotCalculationmessage__c = 'South Korea depot defaults to an active near by depot';
                        addressnew.abGeolocation__Latitude__s = null;
                        addressnew.abGeolocation__Longitude__s = null;
                        addressnew.abRecalculate_Depot__c = false;
                        addressnew.ab4HourDepot__c = koreanActiveDepot.size() >= 1 ? koreanActiveDepot[0].Id: null;
                        addressnew.abDistanceTo4HourDepotInMeters__c = null;
                        addressnew.ab4HourDepotOutOfCoverage__c = false;
                        addressnew.abDontCalculateDepot__c = true;
                    }
        }
    }
    
    //To update Geolocation of that Addressbook
    if(addressmap.size()>0){
        if(System.IsBatch() == false && System.isFuture() == false){
            // Added new parameter "addressmapwithCountry" by exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign //
            Geolocationaddress.geocodeAddressFuture(addressmap, Objectapi, addressmapwithoutstreet, addressmapwithcity, addressmapwithCountry);  
        }
    }
    
    //To Recalculate the Depot and Geolocation of the RMA's which has this address book, Updating a checkbox in that RMA
    if(addresslist.size()>0){             
        list<RMAv2__c> rmaListChange = [select id, name, rmaRecalculateNearbyDepot__c,rmaShipmentAddressDetail__c,rmaGeolocation__c,rmaShipmentStreet1__c,rmaShipmentStreet2__c,rmaShipmentAddresswithCity__c,rmaShipmentCountry__c from RMAv2__c where (rmaAddressBook__c IN: addressList) and (rmaStatus__c = 'Draft') and (rmaAssetSla__c like '%4%' or rmaShipmentSla__c like '%4%')];
        list<RMAv2__c> rmaUpdate = new list<RMAv2__c>();
        list<Asset> assetListChange = [select id, name, assetShipAddressChanged__c,assetAddress__c,assetAddressWithoutStreet__c,assetAddressWithCity__c,SLA__c,Install_Country__c from Asset where assetPartShipAddressBook__c IN: addressList and (SLA__c = 'Premium 4 Hour' or SLA__c = 'Premium 4 Hour Onsite' or SLA__c = 'TSC: Premium 4 Hour' or SLA__c = 'TSC: Premium 4 Hour Onsite')];
        list<Asset> assetUpdate = new list<Asset>();
        if(rmaListChange.size()>0){
            for(RMAv2__c rmaid : rmaListChange){
                addressrma = '';
                addressrma += rmaid.rmaShipmentStreet1__c;
                addressrma += rmaid.rmaShipmentStreet2__c;
                addressrma += rmaid.rmaShipmentAddressDetail__c;
                rmaMap.put(rmaid.Id, addressrma);
                rmaMapwithouStreet.put(rmaid.Id, rmaid.rmaShipmentAddressDetail__c);
                rmaMapwithCity.put(rmaid.Id, rmaid.rmaShipmentAddresswithCity__c);
                //Added by Exafort TS-5631
                rmaMapwithCountry.put(rmaid.Id, rmaid.rmaShipmentCountry__c);
            }
        }
        if(!rmaMap.isEmpty()){
            //Passing the map of RMA id and address, Object api('RMA'), map of RMA id and address without street, map of RMA id and address with city and country
            if(System.IsBatch() == false && System.isFuture() == false){
                 // Added new parameter "rmaMapwithCountry" by exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign //
                Geolocationaddress.geocodeAddressFuture(rmaMap, ObjectapiRMA, rmaMapwithouStreet, rmaMapwithCity, rmaMapwithCountry);
            }
        }
        if(assetListChange.size()>0){
            for(Asset assetid : assetListChange){
                addressasset = '';
                addressasset += assetid.assetAddress__c;
                rmaAsset.put(assetid.Id, addressasset);
                rmaAssetwithouStreet.put(assetid.Id, assetid.assetAddressWithoutStreet__c);
                rmaAssetwithCity.put(assetid.Id, assetid.assetAddressWithCity__c);
                //Added by Exafort for TS-5631
                rmaAssetwithCountry.put(assetid.Id, assetid.Install_Country__c);
            }
        }
        if(!rmaAsset.isEmpty()){
            //Passing the map of Asset id and address, Object api('Asset'), map of Asset id and address without street, map of Asset id and address with city and country
            if(System.IsBatch() == false && System.isFuture() == false){
               // Added new parameter "rmaAssetwithCountry" by exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign //
                Geolocationaddress.geocodeAddressFuture(rmaAsset, 'Asset', rmaAssetwithouStreet, rmaAssetwithCity, rmaAssetwithCountry);
            }
        }
    }
}