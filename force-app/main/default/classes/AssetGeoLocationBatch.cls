global class AssetGeoLocationBatch implements Database.Batchable<Asset>, Database.AllowsCallouts {
    
    private String customQuery;
    
    // Constructor with optional query string
    global AssetGeoLocationBatch(String queryStr) {
        this.customQuery = queryStr;
    }
    global AssetGeoLocationBatch() {

    }
    
    global Iterable<Asset> start(Database.BatchableContext BC) {
        if (String.isBlank(customQuery)) {
            return [
                SELECT Id, Name,
                assetAddress__c,
                assetAddressWithoutStreet__c,
                assetAddressWithCity__c,
                Install_Country__c,
                SLA__c,
                assetGeolocation__Latitude__s,
                assetGeolocation__Longitude__s,
                Install_Street1__c,
                Install_City__c,
                Install_Zip_Code__c,
                Account.Name,
                Account.Support_Provider__r.Name
                FROM Asset
                WHERE (assetInstallAddressChanged__c = true OR assetShipAddressChanged__c = true)
                AND SLA__c IN (
                    'Premium 4 Hour',
                    'Premium 4 Hour Onsite',
                    'TSC: Premium 4 Hour',
                    'TSC: Premium 4 Hour Onsite'
                )
                AND assetDontCalculateDepot__c = false
                AND Install_Country__c != 'South Korea'
                AND assetGeolocation__Latitude__s = null
                AND assetGeolocation__Longitude__s = null
                AND Install_Street1__c != null
                AND Install_City__c != null
                AND Install_Country__c != null
                AND Install_Zip_Code__c != null
                AND (Account.Name = null OR (NOT Account.Name LIKE '%H3C%'))
                AND (Account.Support_Provider__r.Name = null OR (NOT Account.Support_Provider__r.Name LIKE '%H3C%'))
                ORDER BY CreatedDate DESC
            ];
        } else {
            // Execute dynamic query using Database.query
            return (List<Asset>) Database.query(customQuery);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        Map<Id, String> assetsWithFullAddress = new Map<Id, String>();
        Map<Id, String> assetsWithoutStreet   = new Map<Id, String>();
        Map<Id, String> assetsWithCity        = new Map<Id, String>();
        Map<Id, String> assetsWithCountry     = new Map<Id, String>();
        
        for (Asset asset : scope) {
            Id assetId = asset.Id;
            assetsWithFullAddress.put(assetId, asset.assetAddress__c);
            assetsWithoutStreet.put(assetId, asset.assetAddressWithoutStreet__c);
            assetsWithCity.put(assetId, asset.assetAddressWithCity__c);
            assetsWithCountry.put(assetId, asset.Install_Country__c);
        }
        
        if (!assetsWithFullAddress.isEmpty()) {
            try {
                Geolocationaddress.geocodeAddress(
                    assetsWithFullAddress,
                    'Asset',
                    assetsWithoutStreet,
                    assetsWithCity,
                    assetsWithCountry
                );
            } catch (Exception e) {
                System.debug('Error in geocoding batch: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}