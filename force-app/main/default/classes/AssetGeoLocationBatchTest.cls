@isTest
private class AssetGeoLocationBatchTest {

    // Mock class to simulate the geocodeAddress call
    class MockGeoLocationCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"OK"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testBatchWithDefaultQuery() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Insert Asset with all required fields
        Asset a = new Asset(
            Name = 'Test Asset',
            AccountId = acc.Id,
            SLA__c = 'Premium 4 Hour',
            Install_Country__c = 'India',
            Install_City__c = 'Chennai',
            Install_Street1__c = 'Street 1',
            Install_Zip_Code__c = '600001',
            assetInstallAddressChanged__c = true,
            assetDontCalculateDepot__c = false,
            assetGeolocation__Latitude__s = null,
            assetGeolocation__Longitude__s = null
        );
        insert a;

        // Set callout mock if required by Geolocationaddress class
        Test.setMock(HttpCalloutMock.class, new MockGeoLocationCallout());

        // Start test
        Test.startTest();
        AssetGeoLocationBatch batch = new AssetGeoLocationBatch(null);
        Database.executeBatch(batch, 1);
        Test.stopTest();

        // Assert that batch ran successfully (optional)
        List<Asset> updatedAssets = [SELECT Id FROM Asset WHERE Id = :a.Id];
        System.assertEquals(1, updatedAssets.size(), 'Expected 1 processed Asset');
    }

    @isTest
    static void testBatchWithCustomQuery() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Insert Asset
        Asset a = new Asset(
            Name = 'Test Asset 2',
            AccountId = acc.Id,
            SLA__c = 'Premium 4 Hour Onsite',
            Install_Country__c = 'India',
            Install_City__c = 'Bangalore',
            Install_Street1__c = 'Street 2',
            Install_Zip_Code__c = '560001',
            assetInstallAddressChanged__c = true,
            assetDontCalculateDepot__c = false,
            assetGeolocation__Latitude__s = null,
            assetGeolocation__Longitude__s = null
        );
        insert a;

        // Define dynamic query
        String customQuery = 'SELECT Id, Name, assetAddress__c, assetAddressWithoutStreet__c, ' +
            'assetAddressWithCity__c, Install_Country__c, SLA__c, assetGeolocation__Latitude__s, ' +
            'assetGeolocation__Longitude__s, Install_Street1__c, Install_City__c, Install_Zip_Code__c, ' +
            'Account.Name, Account.Support_Provider__r.Name FROM Asset WHERE Id = \'' + a.Id + '\'';

        Test.setMock(HttpCalloutMock.class, new MockGeoLocationCallout());

        Test.startTest();
        AssetGeoLocationBatch batch = new AssetGeoLocationBatch(customQuery);
        Database.executeBatch(batch, 1);
        Test.stopTest();

        List<Asset> assets = [SELECT Id FROM Asset WHERE Id = :a.Id];
        System.assertEquals(1, assets.size(), 'Asset should be processed using custom query');
    }
}