@isTest
public class GeolocationBatchTestClass{
    static testMethod void DepotBatchtestcover(){
        String query = 'Select Id, Name, depotAddress__c FROM depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = \'Yes\' Limit 10';
        list<depot__c> depotslist = new list<depot__c>();
        for(integer i = 0; i<=10; i++){
            depot__c depotrec = new depot__c();
            depotrec.Name = 'Test Depot'+i;
            depotrec.depotProvider__c = 'Flash';
            depotrec.depotStockedFor4Hour__c = 'Yes';
            depotrec.depotLocationDescription__c = 'Test Location'+i;
            depotrec.depotCity__c = 'New York';
            depotrec.depotCountry__c = 'US';
            depotrec.depotIsactive__c = true;
            depotrec.Returns_Carrier__c = 'DHL';
            depotslist.add(depotrec);
        }
        Insert depotslist;
        
        Test.startTest();
        
        X4HourDepotCalculationSetting__c DepotCalculationSetting = new X4HourDepotCalculationSetting__c();
        DepotCalculationSetting.X4HourDepotSearchRadiusInMiles__c = 150.0;
        
        try{
            depotBatchUpdate depotBat = new depotBatchUpdate();
            Database.executeBatch(depotBat);
        }
        catch(exception e){
            system.debug('Error');
        }
        Test.stopTest();
    }
    static testMethod void AddressBatchtestcover(){
        Account account;
        Contact contact;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');            
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        //String query = 'Select Id, Name, depotAddress__c FROM depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = \'Yes\' Limit 10';
        list<depot__c> depotslist = new list<depot__c>();
        for(integer i = 0; i<=10; i++){
            depot__c depotrec = new depot__c();
            depotrec.Name = 'Test Depot'+i;
            depotrec.depotProvider__c = 'Flash';
            depotrec.depotStockedFor4Hour__c = 'Yes';
            depotrec.depotLocationDescription__c = 'Test Location'+i;
            depotrec.depotCity__c = 'New York';
            depotrec.depotCountry__c = 'US';
            depotrec.Returns_Carrier__c = 'DHL';
            depotrec.depotIsactive__c = true;
            depotslist.add(depotrec);
        }
        Insert depotslist;
        
        list<AddressBook__c> abList = new list<AddressBook__c>();
        for(integer j = 0; j<=10; j++){
            AddressBook__c addressBook = new AddressBook__c();
            addressBook.abAccount__c = account.id;
            addressBook.abStreet1__c = 'TEST-ASSET-INSTALL-STREET1'+j;
            addressBook.abStreet2__c = 'TEST-ASSET-INSTALL-STREET2'+j;
            addressBook.abCity__c = 'TEST-ASSET-INSTALL-CITY';
            addressBook.abStateProvince__c ='TEST-ASSET-INSTALL-STATE';
            addressBook.abCountry__c='TEST-ASSET-INSTALL-COUNTRY';
            addressBook.abPostalCode__c='1000';
            addressBook.abDescription__c='Asset Install Address 1';
            addressBook.ab4HourDepot__c = depotslist[j].id;
            
            abList.add(addressBook);
        }
        insert abList;
        
        Test.startTest();
        
        X4HourDepotCalculationSetting__c DepotCalculationSetting = new X4HourDepotCalculationSetting__c();
        DepotCalculationSetting.X4HourDepotSearchRadiusInMiles__c = 150.0;
        insert DepotCalculationSetting;
        
        try{
            addressbookBatchUpdate abBat = new addressbookBatchUpdate('Daily');
            Database.executeBatch(abBat);
        }
        catch(exception e){
            system.debug('Error');
        }
        Test.stopTest();
    }
    static testMethod void AddressBatchtestcoverGeo(){
        Account account;
        Contact contact;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');            
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        //String query = 'Select Id, Name, depotAddress__c FROM depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = \'Yes\' Limit 10';
        list<depot__c> depotslist = new list<depot__c>();
        for(integer i = 0; i<=10; i++){
            depot__c depotrec = new depot__c();
            depotrec.Name = 'Test Depot'+i;
            depotrec.depotProvider__c = 'Flash';
            depotrec.depotStockedFor4Hour__c = 'Yes';
            depotrec.depotLocationDescription__c = 'Test Location'+i;
            depotrec.depotCity__c = 'New York';
            depotrec.depotCountry__c = 'US';
            depotrec.depotIsactive__c = true;
            depotrec.Returns_Carrier__c = 'DHL';
            depotslist.add(depotrec);
        }
        Insert depotslist;
        
        list<AddressBook__c> abList = new list<AddressBook__c>();
        for(integer j = 0; j<=10; j++){
            AddressBook__c addressBook = new AddressBook__c();
            addressBook.abAccount__c = account.id;
            addressBook.abStreet1__c = 'TEST-ASSET-INSTALL-STREET1'+j;
            addressBook.abStreet2__c = 'TEST-ASSET-INSTALL-STREET2'+j;
            addressBook.abCity__c = 'TEST-ASSET-INSTALL-CITY';
            addressBook.abStateProvince__c ='TEST-ASSET-INSTALL-STATE';
            addressBook.abCountry__c='TEST-ASSET-INSTALL-COUNTRY';
            addressBook.abPostalCode__c='1000';
            addressBook.abDescription__c='Asset Install Address 1';
            addressBook.ab4HourDepot__c = depotslist[j].id;
            
            abList.add(addressBook);
        }
        insert abList;
        
        Test.startTest();        
        try{
            addressbookBatchUpdate abBat = new addressbookBatchUpdate('Geolocation');
            Database.executeBatch(abBat);
        }
        catch(exception e){
            system.debug('Error');
        }
        Test.stopTest();
    }
    static testMethod void AssetBatchtestcover(){
        Account account;
        Contact contact;
        Product2 product;
        
        product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SP-DC-PWR-6400W';
        insert product;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');            
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        //String query = 'Select Id, Name, depotAddress__c FROM depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = \'Yes\' Limit 10';
        list<depot__c> depotslist = new list<depot__c>();
        for(integer i = 0; i<=10; i++){
            depot__c depotrec = new depot__c();
            depotrec.Name = 'Test Depot'+i;
            depotrec.depotProvider__c = 'Flash';
            depotrec.depotStockedFor4Hour__c = 'Yes';
            depotrec.depotLocationDescription__c = 'Test Location'+i;
            depotrec.depotCity__c = 'New York';
            depotrec.depotCountry__c = 'US';
            depotrec.Returns_Carrier__c = 'DHL';
            depotrec.depotIsactive__c = true;
            depotslist.add(depotrec);
        }
        Insert depotslist;
        
        list<AddressBook__c> abList = new list<AddressBook__c>();
        for(integer j = 0; j<=10; j++){
            AddressBook__c addressBook = new AddressBook__c();
            addressBook.abAccount__c = account.id;
            addressBook.abStreet1__c = 'TEST-ASSET-INSTALL-STREET1'+j;
            addressBook.abStreet2__c = 'TEST-ASSET-INSTALL-STREET2'+j;
            addressBook.abCity__c = 'TEST-ASSET-INSTALL-CITY';
            addressBook.abStateProvince__c ='TEST-ASSET-INSTALL-STATE';
            addressBook.abCountry__c='TEST-ASSET-INSTALL-COUNTRY';
            addressBook.abPostalCode__c='1000';
            addressBook.abDescription__c='Asset Install Address 1';
            addressBook.ab4HourDepot__c = depotslist[j].id;
            
            abList.add(addressBook);
        }
        insert abList;
        
        
        list<Asset> assetlists = new list<Asset>();
        for(integer k = 0; k<=10; k++){
            Location locins = Location.newInstance(37.2966853, -122.0975973);
            Asset assets = new Asset();
            assets.Name = 'TEST-ASSET';
            assets.AccountId = account.Id;
            assets.ContactId = contact.Id;
            assets.SLA__c = 'Premium 4 Hour';
            assets.assetRmaShi__c = 'Asset RMA SHI';
            assets.assetPartShipAddressBook__c = abList[k].Id;
            assets.assetNearbyDepot__c = depotslist[k].id;
            assets.assetClosestShipDepot__c = depotslist[k].id;
            assets.assetInstallAddressChanged__c = true;
            assets.assetGeolocation__Latitude__s = locins.getLatitude();
            assets.assetGeolocation__Longitude__s = locins.getLongitude();
            assets.HPE_Serial_Number__c = 'AA000000NIM';
            assets.Product2Id = product.id;
            assets.Array_Controller__c = 'AF1000';
            assets.Install_Country__c = 'United states';
            assetlists.add(assets);
        }
        
        insert assetlists;
        Test.startTest();        
        try{
            
            X4HourDepotCalculationSetting__c DepotCalculationSetting = new X4HourDepotCalculationSetting__c();
            DepotCalculationSetting.X4HourDepotSearchRadiusInMiles__c = 150.0;
            insert DepotCalculationSetting;
            
            assetBatchUpdate abBat = new assetBatchUpdate('Daily');
            Database.executeBatch(abBat);
        }
        catch(exception e){
            system.debug('Error');
        }
        Test.stopTest();
    }
    static testMethod void AssetBatchtestcoverGeo(){
        Account account;
        Contact contact;
        Product2 product;
        
        product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SP-DC-PWR-6400W';
        insert product;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');            
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        //String query = 'Select Id, Name, depotAddress__c FROM depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = \'Yes\' Limit 10';
        list<depot__c> depotslist = new list<depot__c>();
        for(integer i = 0; i<=10; i++){
            depot__c depotrec = new depot__c();
            depotrec.Name = 'Test Depot'+i;
            depotrec.depotProvider__c = 'Flash';
            depotrec.depotStockedFor4Hour__c = 'Yes';
            depotrec.depotLocationDescription__c = 'Test Location'+i;
            depotrec.depotCity__c = 'New York';
            depotrec.depotCountry__c = 'US';
            depotrec.depotIsactive__c = true;
            depotrec.Returns_Carrier__c = 'DHL';
            depotslist.add(depotrec);
        }
        Insert depotslist;
        
        list<AddressBook__c> abList = new list<AddressBook__c>();
        for(integer j = 0; j<=10; j++){
            AddressBook__c addressBook = new AddressBook__c();
            addressBook.abAccount__c = account.id;
            addressBook.abStreet1__c = 'TEST-ASSET-INSTALL-STREET1'+j;
            addressBook.abStreet2__c = 'TEST-ASSET-INSTALL-STREET2'+j;
            addressBook.abCity__c = 'TEST-ASSET-INSTALL-CITY';
            addressBook.abStateProvince__c ='TEST-ASSET-INSTALL-STATE';
            addressBook.abCountry__c='TEST-ASSET-INSTALL-COUNTRY';
            addressBook.abPostalCode__c='1000';
            addressBook.abDescription__c='Asset Install Address 1';
            addressBook.ab4HourDepot__c = depotslist[j].id;
            
            abList.add(addressBook);
        }
        insert abList;
        
        
        list<Asset> assetlists = new list<Asset>();
        for(integer k = 0; k<=10; k++){
            Location locins = Location.newInstance(37.2966853, -122.0975973);
            Asset assets = new Asset();
            assets.Name = 'TEST-ASSET';
            assets.AccountId = account.Id;
            assets.ContactId = contact.Id;
            assets.SLA__c = 'Premium 4 Hour';
            assets.assetRmaShi__c = 'Asset RMA SHI';
            assets.assetPartShipAddressBook__c = abList[k].Id;
            assets.assetNearbyDepot__c = depotslist[k].id;
            assets.assetClosestShipDepot__c = depotslist[k].id;
            assets.assetInstallAddressChanged__c = true;
            assets.assetGeolocation__Latitude__s = locins.getLatitude();
            assets.assetGeolocation__Longitude__s = locins.getLongitude();
            assets.HPE_Serial_Number__c = 'AA000000NIM';
            assets.Product2Id = product.id;
            assets.Array_Controller__c = 'AF1000';
            assetlists.add(assets);
        }
        
        insert assetlists;
        Test.startTest();        
        try{
            assetBatchUpdate abBat = new assetBatchUpdate('Geolocation');
            Database.executeBatch(abBat);
        }
        catch(exception e){
            system.debug('Error');
        }
        Test.stopTest();
    }
    static testMethod void AssetBatchtestcoverGeoForNewDepot(){
        Test.startTest();        
        try{
            List<string> depotID = new List<string>();
            depotID.add('Unknown');
            String depotFormationForQuery = String.format( '(\'\'{0}\'\')', 
                                                          new List<String> { String.join( new List<string>(depotID) , '\',\'') });
            string Assetquery = 'Select Id, Name,assetLastDepotRecalc__c, assetGeolocation__c FROM Asset where (SLA__c = \'Premium 4 Hour\' or SLA__c = \'Premium 4 Hour Onsite\' or SLA__c = \'TSC: Premium 4 Hour\' or SLA__c = \'TSC: Premium 4 Hour Onsite\') and (assetInstallAddressDepot__c IN'+depotFormationForQuery+'  or assetShipmentAddressDepot__c IN'+depotFormationForQuery+')';
            string abquery = 'Select Id, Name,abLastDepotRecalc__c, abGeolocation__c,abRecalculate_Depot__c FROM AddressBook__c where ab4HourDepot__r.name IN'+depotFormationForQuery;
            if(system.isBatch() == false && system.isFuture() == false){
                assetBatchUpdate abu = new assetBatchUpdate('New Depot', Assetquery, abquery);
                Database.executeBatch(abu, 1); 
            }
        }
        catch(exception e){
            system.debug('Error');
        }
        Test.stopTest();
    }
    
    static testMethod void RMABatchtestcover(){
        Account account;
        Contact contact;
        Case aCase;
        Component__c testComponent1;
        Product2 product;
        
        product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SP-DC-PWR-6400W';
        insert product;
        
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');            
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        //String query = 'Select Id, Name, depotAddress__c FROM depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = \'Yes\' Limit 10';
        list<depot__c> depotslist = new list<depot__c>();
        for(integer i = 0; i<=10; i++){
            depot__c depotrec = new depot__c();
            depotrec.Name = 'Test Depot'+i;
            depotrec.depotProvider__c = 'Flash';
            depotrec.depotStockedFor4Hour__c = 'Yes';
            depotrec.depotLocationDescription__c = 'Test Location'+i;
            depotrec.depotCity__c = 'New York';
            depotrec.depotCountry__c = 'US';
            depotrec.depotIsactive__c = true;
            depotrec.Returns_Carrier__c = 'DHL';
            depotslist.add(depotrec);
        }
        Insert depotslist;
        
        list<AddressBook__c> abList = new list<AddressBook__c>();
        for(integer j = 0; j<=10; j++){
            AddressBook__c addressBook = new AddressBook__c();
            addressBook.abAccount__c = account.id;
            addressBook.abStreet1__c = 'TEST-ASSET-INSTALL-STREET1'+j;
            addressBook.abStreet2__c = 'TEST-ASSET-INSTALL-STREET2'+j;
            addressBook.abCity__c = 'TEST-ASSET-INSTALL-CITY';
            addressBook.abStateProvince__c ='TEST-ASSET-INSTALL-STATE';
            addressBook.abCountry__c='TEST-ASSET-INSTALL-COUNTRY';
            addressBook.abPostalCode__c='1000';
            addressBook.abDescription__c='Asset Install Address 1';
            addressBook.ab4HourDepot__c = depotslist[j].id;
            
            abList.add(addressBook);
        }
        insert abList;
        
        
        list<Asset> assetlists = new list<Asset>();
        for(integer k = 0; k<=10; k++){
            Asset assets = new Asset();
            assets.Name = 'TEST-ASSET';
            assets.AccountId = account.Id;
            assets.ContactId = contact.Id;
            assets.SLA__c = 'Premium 4 Hour';
            assets.assetRmaShi__c = 'Asset RMA SHI';
            assets.assetPartShipAddressBook__c = abList[k].Id;
            assets.assetNearbyDepot__c = depotslist[k].id;
            assets.assetClosestShipDepot__c = depotslist[k].id;
            assets.assetInstallAddressChanged__c = true;
            assets.HPE_Serial_Number__c = 'AA000000NIM';
            assets.Product2Id = product.id;
            assets.Array_Controller__c = 'AF1000';
            assetlists.add(assets);
        }
        
        insert assetlists;
        
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = assetlists[0].Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        Test.startTest();
        insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                 componentAsset__c = assetlists[0].Id,
                                                 componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                 componentState__c = 'Shipped',
                                                 Sub_State__c='Unknown',
                                                 componentComponentSN__c='123456',
                                                 componentType__c='Chassis',
                                                 componentDescription__c='Chassis');
        
        list<RMAv2__c> rmaList = new list<RMAv2__c>();
        for(integer l = 0; l<=1; l++){
            /*RMAv2__c rma = new RMAv2__c();
rma.rmaCaseNumber__c = aCase.Id;
rma.rmaDiskShelfAsset__c = assetlists[l].Id;
rma.rmaComponentV2__c = testComponent1.Id;
rma.rmaAddressBook__c = abList[l].Id;
rma.rmaSelection__c = 'Component';
rma.rmaFaRequired__c = 'Engineering FA';
rma.rmaOnsiteHddSsdSlot__c = '1';
rma.rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours';
rma.rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site';
rma.rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival';
rma.rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site';      
rma.rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET';
rma.rmaOverrideOnsiteArrivalCity__c = 'TESTCITY';
rma.rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222';
rma.rmaOverrideOnsiteArrivalCountry__c = 'United States'; */
            
            RMAv2__c rma = new RMAv2__c();
            rma.rmaCaseNumber__c = aCase.Id;
            rma.rmaDiskShelfAsset__c = assetlists[l].Id;
            rma.rmaComponentV2__c = testComponent1.Id;
            rma.rmaAddressBook__c = abList[l].Id;
            rma.rmaSelection__c = 'Component';
            rma.rmaRecalculateNearbyDepot__c = true;
            rma.rmaStatus__c = 'Draft';
            rma.rmaOverrideShipmentCountry__c = 'United States';
            rmaList.add(rma);
        }
        
        insert rmaList;
        
        
        try{
            
           X4HourDepotCalculationSetting__c DepotCalculationSetting = new X4HourDepotCalculationSetting__c();
            DepotCalculationSetting.X4HourDepotSearchRadiusInMiles__c = 150.0;
            insert DepotCalculationSetting;
            
            rmaDepotBatchUpdate abBat = new rmaDepotBatchUpdate('Daily');
            Database.executeBatch(abBat);
        }
        catch(exception e){
            system.debug('Error');
        }
        Test.stopTest();
    }
    static testMethod void RMABatchtestcoverGeo(){
        Account account;
        Contact contact;
        Case aCase;
        Product2 product;
        
        product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'SP-DC-PWR-6400W';
        insert product;
        
        Component__c testComponent1;
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');            
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        //String query = 'Select Id, Name, depotAddress__c FROM depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = \'Yes\' Limit 10';
        list<depot__c> depotslist = new list<depot__c>();
        for(integer i = 0; i<=10; i++){
            depot__c depotrec = new depot__c();
            depotrec.Name = 'Test Depot'+i;
            depotrec.depotProvider__c = 'Flash';
            depotrec.depotStockedFor4Hour__c = 'Yes';
            depotrec.depotLocationDescription__c = 'Test Location'+i;
            depotrec.depotCity__c = 'New York';
            depotrec.depotCountry__c = 'US';
            depotrec.depotIsactive__c = true;
            depotrec.Returns_Carrier__c = 'DHL';
            depotslist.add(depotrec);
        }
        Insert depotslist;
        
        list<AddressBook__c> abList = new list<AddressBook__c>();
        for(integer j = 0; j<=10; j++){
            AddressBook__c addressBook = new AddressBook__c();
            addressBook.abAccount__c = account.id;
            addressBook.abStreet1__c = 'TEST-ASSET-INSTALL-STREET1'+j;
            addressBook.abStreet2__c = 'TEST-ASSET-INSTALL-STREET2'+j;
            addressBook.abCity__c = 'TEST-ASSET-INSTALL-CITY';
            addressBook.abStateProvince__c ='TEST-ASSET-INSTALL-STATE';
            addressBook.abCountry__c='TEST-ASSET-INSTALL-COUNTRY';
            addressBook.abPostalCode__c='1000';
            addressBook.abDescription__c='Asset Install Address 1';
            addressBook.ab4HourDepot__c = depotslist[j].id;
            
            abList.add(addressBook);
        }
        insert abList;
        
        
        list<Asset> assetlists = new list<Asset>();
        for(integer k = 0; k<=10; k++){
            Asset assets = new Asset();
            assets.Name = 'TEST-ASSET';
            assets.AccountId = account.Id;
            assets.ContactId = contact.Id;
            assets.SLA__c = 'Premium 4 Hour';
            assets.assetRmaShi__c = 'Asset RMA SHI';
            assets.assetPartShipAddressBook__c = abList[k].Id;
            assets.assetNearbyDepot__c = depotslist[k].id;
            assets.assetClosestShipDepot__c = depotslist[k].id;
            assets.assetInstallAddressChanged__c = true;
            assets.HPE_Serial_Number__c = 'AA000000NIM';
            assets.Product2Id = product.id;
            assets.Array_Controller__c = 'AF1000';
            assetlists.add(assets);
        }
        
        insert assetlists;
        
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = assetlists[0].Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT');
        Test.startTest(); 
        insert testComponent1 = new component__c(componentAccountId__c = account.Id,
                                                 componentAsset__c = assetlists[0].Id,
                                                 componentServicePartNumber__c='SR-CHASSIS-3U-SMC',
                                                 componentState__c = 'Shipped',
                                                 Sub_State__c='Unknown',
                                                 componentComponentSN__c='123456',
                                                 componentType__c='Chassis',
                                                 componentDescription__c='Chassis');
        
        list<RMAv2__c> rmaList = new list<RMAv2__c>();
        for(integer l = 0; l<=1; l++){
            /*RMAv2__c rma = new RMAv2__c();
rma.rmaCaseNumber__c = aCase.Id;
rma.rmaDiskShelfAsset__c = assetlists[l].Id;
rma.rmaComponentV2__c = testComponent1.Id;
rma.rmaAddressBook__c = abList[l].Id;
rma.rmaSelection__c = 'Component';
rma.rmaFaRequired__c = 'Engineering FA';
rma.rmaOnsiteHddSsdSlot__c = '1';
rma.rmaOverrideOnsiteSchedulingCode__c = 'WITHIN-4-HOURS-10: Schedule within the next 4 hours';
rma.rmaOverrideOnsitePartHandoverCode__c = 'MANNED-10: Part courier must leave part with somebody at site';
rma.rmaOverrideOnsiteCheckInCode__c = 'CHECK-IN-10: FE must check in upon arrival';
rma.rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site';      
rma.rmaOverrideOnsiteArrivalStreet1__c = 'TESTSTREET';
rma.rmaOverrideOnsiteArrivalCity__c = 'TESTCITY';
rma.rmaOverrideOnsiteArrivalPostalCode__c = '22222-2222';
rma.rmaOverrideOnsiteArrivalCountry__c = 'United States'; */
            
            RMAv2__c rma = new RMAv2__c();
            rma.rmaCaseNumber__c = aCase.Id;
            rma.rmaDiskShelfAsset__c = assetlists[l].Id;
            rma.rmaComponentV2__c = testComponent1.Id;
            rma.rmaAddressBook__c = abList[l].Id;
            rma.rmaSelection__c = 'Component';
            rma.rmaRecalculateNearbyDepot__c = true;
            rma.rmaStatus__c='Draft';
            rmaList.add(rma);
        }
        
        insert rmaList;
        
        
        try{
            rmaDepotBatchUpdate abBat = new rmaDepotBatchUpdate('Geolocation');
            Database.executeBatch(abBat);
        }
        catch(exception e){
            system.debug('Error');
        }
        Test.stopTest();
    }
    static testMethod void scheduleMethod(){
        Test.StartTest();
        
        insert new X4HourDepotCalculationSetting__c(WeeklyBatchFlag__c = false);
        
        scheduleDepotAddressbook sh1 = new scheduleDepotAddressbook();      
        String sch = '0 0 23 * * ?';
        system.schedule('test_scheduleDepotAddressbook', sch, sh1);
        
        scheduleDepotAddressbookWeekly sh2 = new scheduleDepotAddressbookWeekly();
        String sch1 = '0 0 23 * * ?';
        system.schedule('test_scheduleDepotAddressbookWeekly', sch1, sh2);
        
        scheduleDepotAssetWeekly sh3 = new scheduleDepotAssetWeekly();
        String sch2 = '0 0 23 * * ?';
        system.schedule('test_scheduleDepotAssetWeekly', sch2, sh3);
        Test.stopTest();
    }
    
}