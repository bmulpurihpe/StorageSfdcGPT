@isTest
public class rmaTriggerGoodPostalCodeTests {
    private static List<Id> testDepotIds = new List<Id>();
    class TestData
    {
        Account                         testAccount;
        Contact                         testContact;
        Asset                           testAsset;
        Case                            testCase;
        Depot__c                        testDepot;
        DepotMapNbdNd__c                testDepotMapNbdNd;
        depotMap4Hour__c				testdepotMap4Hour;
        RMAv2__c                        testRma;
        ActivateTrigger__c 			 	activateTriggerCustomSetting;
        
        TestData()
        {
            //check the custom setting value set for the rma trigger to run.
            insert activateTriggerCustomSetting = new ActivateTrigger__c(RMATrigger__c = True);
            
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation');
            
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                                 ProductCode='SSD123',
                                                 Product_Type__c='Hardware',
                                                 Product_Type_2__c='SAN Storage ArrayS',
                                                 Controller_Code__c='CS2001',
                                                 Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                 Family='SAN Storage Array');
            insert testProduct2;
            // Create test Asset
            insert testAsset = new Asset(Name                      = 'AA-100400',
                                         AccountId                 = testAccount.Id,
                                         ContactId                 = testContact.Id,
                                         SLA__c                    = 'Premium',
                                         HPE_Serial_Number__c 	   = 'AA000000NIM',
                                         Install_Street1__c        = '123 Main Street',
                                         Install_Street2__c        = 'Suite 100',
                                         Install_City__c           = 'San Jose',
                                         Install_State_Province__c = 'CA',
                                         Install_Zip_Code__c       = '95151',
                                         Install_Country__c        = 'United States',Array_Controller__c = 'CS300',Product2Id = testProduct2.id,
                                         Ship_Date__c              = Date.today().addDays(-180));
            
            // Create test Case
            insert testCase = new Case(AccountId = testAccount.Id,
                                       AssetId   = testAsset.Id,
                                       ContactId = testContact.Id,
                                       Subject   = 'TEST-CASE-SUBJECT', Technology_Area__c = '3rd Party Apps', Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)');
            
        }
        //Create Depot 
        void createDepot()
        {
            
            depot__c depot;
            List<depot__c>  insdepot = new List<depot__c>();
            Map<String,depot__c> mapExpectedDepot= new Map<String,depot__c>();  
            
            // Create test depot 001
            depot = new depot__c(Name                        = 'TEST-001',
                                 depotProvider__c            = 'Flash',
                                 depotStockedFor4Hour__c     = 'Yes',
                                 depotLocationDescription__c = 'Test depot 001',
                                 Returns_Carrier__c          = 'DHL');
            insdepot.add(depot);
            mapExpectedDepot.put(depot.Name,depot);
            
            // Create test depot 002
            depot = new depot__c(Name                        = 'TEST-002',
                                 depotProvider__c            = 'Flash',
                                 depotStockedFor4Hour__c     = 'Yes',
                                 depotLocationDescription__c = 'Test depot 002',
                                 Returns_Carrier__c          = 'DHL');
            insdepot.add(depot);
            mapExpectedDepot.put(depot.Name,depot);
            
            
            // Create test depot 003
            depot = new depot__c(Name                        = 'TEST-003',
                                 depotProvider__c            = 'Flash',
                                 depotStockedFor4Hour__c     = 'Yes',
                                 depotLocationDescription__c = 'Test depot 003',
                                 Returns_Carrier__c          = 'DHL');
            insdepot.add(depot);
            mapExpectedDepot.put(depot.Name,depot);
            
            
            // Create test depot 004
            depot = new depot__c(Name                        = 'TEST-004',
                                 depotProvider__c            = 'Flash',
                                 depotStockedFor4Hour__c     = 'No',
                                 depotLocationDescription__c = 'Test depot 004',
                                 Returns_Carrier__c          = 'DHL');
            insdepot.add(depot);
            mapExpectedDepot.put(depot.Name,depot);
            
            // Create test depot 005
            depot = new depot__c(Name                        = 'TEST-005',
                                 depotProvider__c            = 'Flash',
                                 depotStockedFor4Hour__c     = 'No',
                                 depotLocationDescription__c = 'Test depot 005',
                                 Returns_Carrier__c          = 'DHL');
            insdepot.add(depot);
            mapExpectedDepot.put(depot.Name,depot);
            
            insert insdepot;
            
            
            List<depot__c>   depots = [SELECT Id,
                                       Name,
                                       depotProvider__c,
                                       depotStockedFor4Hour__c,
                                       depotLocationDescription__c
                                       FROM   depot__c];
            
            System.assertEquals(insdepot.size(),              depots.size());
            
            
            for(Integer i=0;i<depots.size();i++)
            {
                if(mapExpectedDepot.containsKey(depots[i].Name))
                    depot = mapExpectedDepot.get(depots[i].Name);
                
                System.assertEquals(depot.Name , depots[i].Name,'Depot Name - ' + depots[i].Name);
                System.assertEquals(depot.depotProvider__c, depots[i].depotProvider__c,'Depot Name - ' + depots[i].Name);
                System.assertEquals(depot.depotStockedFor4Hour__c, depots[i].depotStockedFor4Hour__c,'Depot Name - ' + depots[i].Name);
                System.assertEquals(depot.depotLocationDescription__c, depots[i].depotLocationDescription__c,'Depot Name - ' + depots[i].Name);
                testDepotIds.add(depots[i].Id);
            }     
        }
        // Create the NBD/ND map entries 
        void createNBDNDEntries()
        {
            depotMapNbdNd__c depotMapNbdNd;
            List<depotMapNbdNd__c>  insdepotNbdNdMap = new List<depotMapNbdNd__c>();
            Map<String,depotMapNbdNd__c> mapExpectedNbdNdDepot= new Map<String,depotMapNbdNd__c>(); 
            
            //NBD/ND Depot- United States
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United States',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[3],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[4]);
            
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- United Kindom
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United Kingdom',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[3],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[4]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- United Kindom with State
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United Kingdom',
                                                 depotMapNbdNdState__c     = 'Isle of Man',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[3],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[4]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Australia
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Australia',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Austria
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Austria',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Belgium
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Belgium',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Bermuda
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Bermuda',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[1],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[1]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Canada
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Canada',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[1],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[1]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- China   
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'China',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Denmark 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Denmark',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Finland 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Finland',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- France 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'France',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Germany 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Germany',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Hong Kong 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Hong Kong',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- India 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'India',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Indonesia 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Indonesia',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Ireland 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Ireland',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Japan 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Japan',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Malaysia 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Malaysia',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Netherlands 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Netherlands',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[2],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[2]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- New Zealand 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'New Zealand',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Norway 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Norway',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Philippines 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Philippines',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Singapore 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Singapore',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[2],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[2]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- South Africa 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'South Africa',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- South Korea 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'South Korea',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Sweden 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Sweden',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Spain 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Spain',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            
            
            //NBD/ND Depot- Switzerland 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Switzerland',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);      
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- Taiwan 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'Taiwan',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            //NBD/ND Depot- United Arab Emirates 
            depotMapNbdNd = new depotMapNbdNd__c(depotMapNbdNdCountry__c   = 'United Arab Emirates',
                                                 depotMapNbdNdState__c     = 'N/A',
                                                 depotMapNbdNd_NbdDepot__c = testDepotIds[0],
                                                 depotMapNbdNd_NdDepot__c  = testDepotIds[0]);
            insdepotNbdNdMap.add(depotMapNbdNd);       
            mapExpectedNbdNdDepot.put('__' + depotMapNbdNd.depotMapNbdNdCountry__c +'__'+depotMapNbdNd.depotMapNbdNdState__c+'__',depotMapNbdNd);
            
            
            insert insdepotNbdNdMap;
            
            List<depotMapNbdNd__c>  depotMapNbdNds = [SELECT Id,
                                                      Name,
                                                      depotMapNbdNdCountry__c,
                                                      depotMapNbdNdState__c,
                                                      depotMapNbdNd_NbdDepot__c,
                                                      depotMapNbdNd_NdDepot__c
                                                      FROM   depotMapNbdNd__c];
            
            System.assertEquals(insdepotNbdNdMap.size(),    depotMapNbdNds.size());
            
            for(Integer i=0;i<depotMapNbdNds.size();i++)
            {
                string keyFormation = '__' + depotMapNbdNds[i].depotMapNbdNdCountry__c +'__'+depotMapNbdNds[i].depotMapNbdNdState__c+'__';
                if(mapExpectedNbdNdDepot.containsKey(keyFormation))
                    depotMapNbdNd = mapExpectedNbdNdDepot.get(keyFormation);
                
                System.assertEquals(depotMapNbdNd.depotMapNbdNdCountry__c,          depotMapNbdNds[i].depotMapNbdNdCountry__c,'DepotNbdNd Name' + depotMapNbdNds[i].Name);
                System.assertEquals(depotMapNbdNd.depotMapNbdNdState__c,              depotMapNbdNds[i].depotMapNbdNdState__c,'DepotNbdNd Name' + depotMapNbdNds[i].Name);
                System.assertEquals(depotMapNbdNd.depotMapNbdNd_NbdDepot__c,     depotMapNbdNds[i].depotMapNbdNd_NbdDepot__c,'DepotNbdNd Name' + depotMapNbdNds[i].Name);
                System.assertEquals(depotMapNbdNd.depotMapNbdNd_NdDepot__c,     depotMapNbdNds[i].depotMapNbdNd_NdDepot__c,'DepotNbdNd Name' + depotMapNbdNds[i].Name);
            } 
        }
        void create4HourEntries()
        {
            depotMap4Hour__c depotMap4Hour;
            List<depotMap4Hour__c>  insdepotMap4Hour = new List<depotMap4Hour__c>();
            Map<String,depotMap4Hour__c> mapExpected4HourDepot= new Map<String,depotMap4Hour__c>(); 
            
            depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                                 depotMap4HourPostalCode__c  = '11111',
                                                 depotMap4Hour_4HourDepot__c = testDepotIds[0],
                                                 depotMap4HourDriveTime__c   = 10.5);
            insdepotMap4Hour.add(depotMap4Hour);
            mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                                      '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                                      '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                                      depotMap4Hour);
            
            
            depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                                 depotMap4HourPostalCode__c  = '22222',
                                                 depotMap4Hour_4HourDepot__c = testDepotIds[1],
                                                 depotMap4HourDriveTime__c   = 20.5);
            insdepotMap4Hour.add(depotMap4Hour);
            mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                                      '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                                      '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                                      depotMap4Hour);
            
            
            
            depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United States',
                                                 depotMap4HourPostalCode__c  = '22222',
                                                 depotMap4Hour_4HourDepot__c = testDepotIds[2],
                                                 depotMap4HourDriveTime__c   = 30.5);
            insdepotMap4Hour.add(depotMap4Hour);
            mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                                      '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                                      '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                                      depotMap4Hour);
            
            
            
            depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United Kingdom',
                                                 depotMap4HourPostalCode__c  = 'BS3',
                                                 depotMap4Hour_4HourDepot__c = testDepotIds[0],
                                                 depotMap4HourDriveTime__c   = 10.5);
            insdepotMap4Hour.add(depotMap4Hour);
            mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                                      '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                                      '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                                      depotMap4Hour);
            
            
            depotMap4Hour = new depotMap4Hour__c(depotMap4HourCountry__c     = 'United Kingdom',
                                                 depotMap4HourPostalCode__c  = 'BS3A',
                                                 depotMap4Hour_4HourDepot__c = testDepotIds[1],
                                                 depotMap4HourDriveTime__c   = 20.5);
            insdepotMap4Hour.add(depotMap4Hour);
            mapExpected4HourDepot.put('__' + depotMap4Hour.depotMap4HourCountry__c + 
                                      '__' + depotMap4Hour.depotMap4HourPostalCode__c + 
                                      '__' + depotMap4Hour.depotMap4Hour_4HourDepot__c + '__', 
                                      depotMap4Hour);
            
            insert insdepotMap4Hour;  
            
            List<depotMap4Hour__c> depotMap4Hours = [SELECT Id,
                                                     Name,
                                                     depotMap4HourCountry__c,
                                                     depotMap4HourPostalCode__c,
                                                     depotMap4Hour_4HourDepot__c,
                                                     depotMap4HourDrivetime__c
                                                     FROM   depotMap4Hour__c];
            
            System.assertEquals(insdepotMap4Hour.size(),    depotMap4Hours.size());
            
            for(Integer i=0;i<depotMap4Hours.size();i++)
            {
                depotMap4Hour = mapExpected4HourDepot.get('__' + depotMap4Hours[i].depotMap4HourCountry__c + 
                                                          '__' + depotMap4Hours[i].depotMap4HourPostalCode__c + 
                                                          '__' + depotMap4Hours[i].depotMap4Hour_4HourDepot__c + '__');
                
                System.assertEquals(depotMap4Hour.depotMap4HourCountry__c, depotMap4Hours[i].depotMap4HourCountry__c,'Depot4Hour Name' + depotMap4Hours[i].Name);
                System.assertEquals(depotMap4Hour.depotMap4HourPostalCode__c, depotMap4Hours[i].depotMap4HourPostalCode__c,'Depot4Hour Name' + depotMap4Hours[i].Name);
                System.assertEquals(depotMap4Hour.depotMap4Hour_4HourDepot__c, depotMap4Hours[i].depotMap4Hour_4HourDepot__c,'Depot4Hour Name' + depotMap4Hours[i].Name);
                System.assertEquals(depotMap4Hour.depotMap4HourDriveTime__c, depotMap4Hours[i].depotMap4HourDriveTime__c,'Depot4Hour Name' + depotMap4Hours[i].Name);
            }   
        }
        void insertRMAHdd210()
        {
            // Create test RMA
            insert testRma = new RMAv2__c(rmaCaseNumber__c                 = testCase.Id,
                                          rmaType__c                       = 'Advance replacement',
                                          rmaFaRequired__c                 = 'No FA Required',
                                          rmaLabArray__c                   = 'No',
                                          rmaComponent__c                  = 'HDD',
                                          rmaNimbleOsVersion__c            = 'HDD: N/A',
                                          rmaModel__c                      = 'HDD: CS210/220/420',
                                          rmaPart__c                       = 'HDD: 1TB - save RMA to compute exact part',
                                          rmaQuantity__c                   = '1',
                                          rmaManufacturer__c               = 'HDD: Seagate',
                                          rmaHddSsdSerialNumber__c         = 'ABC123',
                                          rmaReason__c                     = 'HDD: Starting to fail (proactive replacement)',
                                          rmaDetailedReason__c             = 'Detailed reason text',
                                          rmaShipmentAddressSelector__c    = 'Asset install address',
                                          rmaOverrideShipmentAttn__c       = 'John Doe',
                                          rmaOverrideShipmentPhone__c      = '408-555-1234',
                                          rmaOverrideShipmentEmail__c      = 'john.doe@nimblestorage.com',
                                          rmaUplift__c                     = 'No: Do not uplift',
                                          rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                          rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                          rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                          rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                          rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order');
        } 
        //Create PostalCode
        void createPostalCode()
        {
            PostalCode__c pc;
            List<PostalCode__c>  insPc = new List<PostalCode__c>();
            Map<String,PostalCode__c> mapExpectedPc= new Map<String,PostalCode__c>();  
            
            // Create test PostalCode 001
            pc = new PostalCode__c(pcCountry__c  = 'Australia',
                                   pcFormatInRegex__c = '^([0-9]{4})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Australia\'s "9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 002
            pc = new PostalCode__c(pcCountry__c  = 'Austria',
                                   pcFormatInRegex__c = '^([0-9]{4})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Austria\'s "9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 003
            pc = new PostalCode__c(pcCountry__c  = 'Belgium',
                                   pcFormatInRegex__c = '^([0-9]{4})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Belgium\'s "9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 004
            pc = new PostalCode__c(pcCountry__c  = 'Bermuda',
                                   pcFormatInRegex__c = '^([A-Z][A-Z]) [0-9][0-9]$',
                                   pcDummyPostalCode__c     = 'AA 99',                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Bermuda\'s "AA 99" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 005
            pc = new PostalCode__c(pcCountry__c  = 'Canada',
                                   pcFormatInRegex__c = '^([A-Z][0-9][A-Z]) [0-9][A-Z][0-9]$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Canada\'s "A9A 9A9" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 006
            pc = new PostalCode__c(pcCountry__c  = 'China',
                                   pcFormatInRegex__c = '^([0-9]{6})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to China\'s "999999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 007
            pc = new PostalCode__c(pcCountry__c  = 'Denmark',
                                   pcFormatInRegex__c = '^([0-9]{4})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Denmark\'s "9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 008
            pc = new PostalCode__c(pcCountry__c  = 'Finland',
                                   pcFormatInRegex__c = '^([0-9]{5})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Finland\'s "99999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 009
            pc = new PostalCode__c(pcCountry__c  = 'France',
                                   pcFormatInRegex__c = '^([0-9]{5})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to France\'s "99999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 010
            pc = new PostalCode__c(pcCountry__c  = 'Germany',
                                   pcFormatInRegex__c = '^([0-9]{5})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Germany\'s "99999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 011
            pc = new PostalCode__c(pcCountry__c  = 'Hong Kong',
                                   pcFormatInRegex__c = '^([0-9]{6})$',
                                   pcDummyPostalCode__c     = '999077',                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Hong Kong\'s "999999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 012
            pc = new PostalCode__c(pcCountry__c  = 'India',
                                   pcFormatInRegex__c = '^([0-9]{6})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to India\'s "999999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 013
            pc = new PostalCode__c(pcCountry__c  = 'Indonesia',
                                   pcFormatInRegex__c = '^([0-9]{5})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Indonesia\'s "99999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 014
            pc = new PostalCode__c(pcCountry__c  = 'Ireland',
                                   pcFormatInRegex__c = '^([A-Z][0-9]{2}) [A-Z][0-9][A-Z]{2}$',
                                   pcDummyPostalCode__c     = 'A99 A9AA',                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Ireland\'s "A99 A9AA" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 015
            pc = new PostalCode__c(pcCountry__c  = 'Japan',
                                   pcFormatInRegex__c = '^([0-9]{3}-[0-9]{2})[0-9]{2}$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Japan\'s "999-9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 016
            pc = new PostalCode__c(pcCountry__c  = 'Malaysia',
                                   pcFormatInRegex__c = '^([0-9]{5})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Malaysia\'s "99999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 017
            pc = new PostalCode__c(pcCountry__c  = 'Netherlands',
                                   pcFormatInRegex__c = '^([0-9]{4}) [A-Z]{2}$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Netherlands\' "9999 AA" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 018
            pc = new PostalCode__c(pcCountry__c  = 'New Zealand',
                                   pcFormatInRegex__c = '^([0-9]{4})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to New Zealand\'s "9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 019
            pc = new PostalCode__c(pcCountry__c  = 'Norway',
                                   pcFormatInRegex__c = '^([0-9]{4})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Norway\'s "9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 020
            pc = new PostalCode__c(pcCountry__c  = 'Philippines',
                                   pcFormatInRegex__c = '^([0-9]{4})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Philippines\' "9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 021
            pc = new PostalCode__c(pcCountry__c  = 'Singapore',
                                   pcFormatInRegex__c = '^([0-9]{2})[0-9]{4}$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Singapore\'s "999999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 022
            pc = new PostalCode__c(pcCountry__c  = 'South Africa',
                                   pcFormatInRegex__c = '^([0-9]{4})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to South Africa\'s "9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 023
            pc = new PostalCode__c(pcCountry__c  = 'South Korea',
                                   pcFormatInRegex__c = '^([0-9]{3}-[0-9]{3})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to South Korea\'s "999-999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 024
            pc = new PostalCode__c(pcCountry__c  = 'Spain',
                                   pcFormatInRegex__c = '^([0-9]{5})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Spain\'s "99999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 025
            pc = new PostalCode__c(pcCountry__c  = 'Sweden',
                                   pcFormatInRegex__c = '^([0-9]{5})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Sweden\'s "99999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 026
            pc = new PostalCode__c(pcCountry__c  = 'Switzerland',
                                   pcFormatInRegex__c = '^([0-9]{4})$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Switzerland\'s "9999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 027
            pc = new PostalCode__c(pcCountry__c  = 'Taiwan',
                                   pcFormatInRegex__c = '^([0-9]{3})[0-9]{2}$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to Taiwan\'s "99999" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 028
            pc = new PostalCode__c(pcCountry__c  = 'United Arab Emirates',
                                   pcFormatInRegex__c = '^([A-Z]{3})$',
                                   pcDummyPostalCode__c     = 'AAA',                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to United Arab Emirates\' "AAA" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 029
            pc = new PostalCode__c(pcCountry__c  = 'United States',
                                   pcFormatInRegex__c = '^([0-9]{5})(-[0-9]{4})?$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to United States\' "99999(-9999)" format.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 030
            pc = new PostalCode__c(pcCountry__c  = 'United Kingdom',
                                   pcFormatInRegex__c = '^([A-Z]{1,2}[0-9]{1,2}) [0-9][A-Z]{2}$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to one of United Kingdom\'s six formats.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            // Create test PostalCode 031
            pc = new PostalCode__c(pcCountry__c  = 'United Kingdom',
                                   pcFormatInRegex__c = '^([A-Z]{1,2}[0-9][A-Z]) [0-9][A-Z]{2}$',
                                   pcDummyPostalCode__c     = null,                           
                                   pcErrorMessage__c='"Shipment Postal Code" will not conform to one of United Kingdom\'s six formats.  Override it if needed to provide a valid value.');
            insPc.add(pc);
            mapExpectedPc.put(pc.pcCountry__c + '__' +pc.pcFormatInRegex__c,pc);
            
            
            insert insPC;
            
            /*List<PostalCode__c>   pcs = [SELECT Id,
pcCountry__c,
pcFormatInRegex__c,
pcDummyPostalCode__c 
FROM   PostalCode__c];

System.assertEquals(insPc.size(),              pcs.size());*/
            
            
            for(Integer i=0;i<insPC.size();i++)
            {
                pc = mapExpectedPc.get(insPC[i].pcCountry__c + '__' + insPC[i].pcFormatInRegex__c);
                
                System.assertEquals(pc.pcCountry__c , insPC[i].pcCountry__c,'Country Name - ' + insPC[i].pcCountry__c);
                System.assertEquals(pc.pcFormatInRegex__c, insPC[i].pcFormatInRegex__c,'Country Name - ' + insPC[i].pcCountry__c);
                System.assertEquals(pc.pcDummyPostalCode__c, insPC[i].pcDummyPostalCode__c,'Country Name - ' + insPC[i].pcCountry__c);
            }
        }
    }
    
    // ==================================================================================== testGoodPostalCodeAustralia
    @isTest static void testGoodPostalCodeAustralia()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.createDepot();
        testData.createNBDNDEntries();
        Test.startTest();
        testData.insertRMAHdd210();
        testData.createPostalCode();
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
        rmas[0].rmaOverrideShipmentCountry__c    = 'Australia';
        update rmas[0];
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        Test.stopTest();
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
        System.assertEquals('1234',                   rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('Australia',              rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeAustria
    static testMethod void testGoodPostalCodeAustria()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.createDepot();
        testData.createNBDNDEntries();
        Test.startTest();
        testData.insertRMAHdd210();
        testData.createPostalCode();
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
        rmas[0].rmaOverrideShipmentCountry__c    = 'Austria';
        update rmas[0];
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        Test.stopTest();
        System.assertEquals(1,                   rmas.size());
        System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
        System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('Austria',           rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
}
    // ==================================================================================== testGoodPostalCodeBelgium
    static testMethod void testGoodPostalCodeBelgium()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.createDepot();
        testData.createNBDNDEntries();
        Test.startTest();
        testData.insertRMAHdd210();
        testData.createPostalCode();
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
        rmas[0].rmaOverrideShipmentCountry__c    = 'Belgium';
        update rmas[0];
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        Test.stopTest();
        System.assertEquals(1,                   rmas.size());
        System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
        System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('Belgium',           rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== testGoodPostalCodeBermuda
    static testMethod void testGoodPostalCodeBermuda()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.createDepot();
        testData.createNBDNDEntries();
        Test.startTest();
        testData.insertRMAHdd210();
        testData.createPostalCode();
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = 'zy 35';
        rmas[0].rmaOverrideShipmentCountry__c    = 'Bermuda';
        update rmas[0];
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        Test.stopTest();
        System.assertEquals(1,                   rmas.size());
        System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
        System.assertEquals('zy 35',             rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('Bermuda',           rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-002',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== testGoodPostalCodeCanada
    static testMethod void testGoodPostalCodeCanada()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.createDepot();
        testData.createNBDNDEntries();
        Test.startTest();
        testData.insertRMAHdd210();
        testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = 'z8y 3g5';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Canada';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
     System.assertEquals('z8y 3g5',                rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Canada',                 rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-002',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeChina
    static testMethod void testGoodPostalCodeChina()
    {
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.createDepot();
        testData.createNBDNDEntries();
        Test.startTest();
        testData.insertRMAHdd210();
        testData.createPostalCode();
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = '123456';
        rmas[0].rmaOverrideShipmentCountry__c    = 'China';
        update rmas[0];
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        Test.stopTest();
        System.assertEquals(1,                        rmas.size());
        System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
        System.assertEquals('123456',                 rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('China',                  rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== testGoodPostalCodeDenmark
    static testMethod void testGoodPostalCodeDenmark()
    {  TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Denmark';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Denmark',           rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeFinland
    static testMethod void testGoodPostalCodeFinland()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Finland';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('12345',             rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Finland',           rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeFrance
    static testMethod void testGoodPostalCodeFrance()
    {	
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.createDepot();
        testData.createNBDNDEntries();
        Test.startTest();
        testData.insertRMAHdd210();
        testData.createPostalCode();
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
        rmas[0].rmaOverrideShipmentCountry__c    = 'France';
        update rmas[0];
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        Test.stopTest();
        System.assertEquals(1,                   rmas.size());
        System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
        System.assertEquals('12345',             rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('France',            rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== testGoodPostalCodeGermany
    static testMethod void testGoodPostalCodeGermany()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Germany';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('12345',             rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Germany',           rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeHongKong
    static testMethod void testGoodPostalCodeHongKong()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '123456';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Hong Kong';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('123456',            rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Hong Kong',         rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeIndia
    static testMethod void testGoodPostalCodeIndia()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '123456';
     rmas[0].rmaOverrideShipmentCountry__c    = 'India';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
     System.assertEquals('123456',                 rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('India',                  rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeIndonesia
    static testMethod void testGoodPostalCodeIndonesia()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Indonesia';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
     System.assertEquals('12345',                  rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Indonesia',              rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeIreland
    static testMethod void testGoodPostalCodeIreland()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = 'a89 z5cd';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Ireland';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
     System.assertEquals('a89 z5cd',               rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Ireland',                rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeJapan
    static testMethod void testGoodPostalCodeJapan()
    {	
        TestData testData;
        List<RMAv2__c> rmas;
        
        testData = new TestData();
        testData.createDepot();
        testData.createNBDNDEntries();
        Test.startTest();
        testData.insertRMAHdd210();
        testData.createPostalCode();
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c
                FROM   RMAv2__c];
        
        System.assertEquals(1, rmas.size());
        
        rmas[0].rmaUplift__c                     = 'No: Do not uplift';
        rmas[0].rmaOverrideShipmentPostalCode__c = '123-4567';
        rmas[0].rmaOverrideShipmentCountry__c    = 'Japan';
        update rmas[0];
        
        
        rmas = [SELECT Id,
                rmaUplift__c,
                rmaOverrideShipmentPostalCode__c,
                rmaOverrideShipmentCountry__c,
                rmaOutgoingShipmentOrderProvider__c,
                rmaOutgoingShipmentOrderDepot__c
                FROM   RMAv2__c];
        Test.stopTest();
        System.assertEquals(1,                   rmas.size());
        System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
        System.assertEquals('123-4567',          rmas[0].rmaOverrideShipmentPostalCode__c);
        System.assertEquals('Japan',             rmas[0].rmaOverrideShipmentCountry__c);
        System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
        System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
        
    }
    // ==================================================================================== testGoodPostalCodeMalaysia
    static testMethod void testGoodPostalCodeMalaysia()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Malaysia';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('12345',             rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Malaysia',          rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeNetherlands
    static testMethod void testGoodPostalCodeNetherlands()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '9876 gg';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Netherlands';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
     System.assertEquals('9876 gg',                rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Netherlands',            rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-003',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeNewZealand
    static testMethod void testGoodPostalCodeNewZealand()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
     rmas[0].rmaOverrideShipmentCountry__c    = 'New Zealand';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('New Zealand',       rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
     
    }
    // ==================================================================================== testGoodPostalCodeNorway
    static testMethod void testGoodPostalCodeNorway()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Norway';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Norway',            rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodePhilippines
    static testMethod void testGoodPostalCodePhilippines()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Philippines';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Philippines',       rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeSingapore
    static testMethod void testGoodPostalCodeSingapore()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '559999';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Singapore';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stoptest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('559999',            rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Singapore',         rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-003',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeSouthAfrica
    static testMethod void testGoodPostalCodeSouthAfrica()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
     rmas[0].rmaOverrideShipmentCountry__c    = 'South Africa';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('South Africa',      rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeSouthKorea
    static testMethod void testGoodPostalCodeSouthKorea()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '123-456';
     rmas[0].rmaOverrideShipmentCountry__c    = 'South Korea';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
     System.assertEquals('123-456',                rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('South Korea',            rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeSpain
    static testMethod void testGoodPostalCodeSpain()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Spain';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
     System.assertEquals('12345',                  rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Spain',                  rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeSweden
    static testMethod void testGoodPostalCodeSweden()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '12345';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Sweden';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('No: Do not uplift',      rmas[0].rmaUplift__c);
     System.assertEquals('12345',                  rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Sweden',                 rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeSwitzerland
    static testMethod void testGoodPostalCodeSwitzerland()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '1234';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Switzerland';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('1234',              rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Switzerland',       rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeTaiwan
    static testMethod void testGoodPostalCodeTaiwan()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = '55599';
     rmas[0].rmaOverrideShipmentCountry__c    = 'Taiwan';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                   rmas.size());
     System.assertEquals('No: Do not uplift', rmas[0].rmaUplift__c);
     System.assertEquals('55599',             rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('Taiwan',            rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',             rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',          rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeUnitedArabEmirates
    static testMethod void testGoodPostalCodeUnitedArabEmirates()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'No: Do not uplift';
     rmas[0].rmaOverrideShipmentPostalCode__c = 'abc';
     rmas[0].rmaOverrideShipmentCountry__c    = 'United Arab Emirates';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                      rmas.size());
     System.assertEquals('No: Do not uplift',    rmas[0].rmaUplift__c);
     System.assertEquals('abc',                  rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('United Arab Emirates', rmas[0].rmaOverrideShipmentCountry__c);
     System.assertEquals('Flash',                rmas[0].rmaOutgoingShipmentOrderProvider__c);
     System.assertEquals('TEST-001',             rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeUnitedKingdom1
    static testMethod void testGoodPostalCodeUnitedKingdom1()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
     rmas[0].rmaOverrideShipmentPostalCode__c = 'BS3 9ZZ';
     rmas[0].rmaOverrideShipmentCountry__c    = 'United Kingdom';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
     System.assertEquals('BS3 9ZZ',                rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('United Kingdom',         rmas[0].rmaOverrideShipmentCountry__c);
     //System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     //System.assertEquals('TEST-001',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    // ==================================================================================== testGoodPostalCodeUnitedKingdom2
    static testMethod void testGoodPostalCodeUnitedKingdom2()
    {TestData testData;
     List<RMAv2__c> rmas;
     
     testData = new TestData();
     testData.createDepot();
     testData.createNBDNDEntries();
     Test.startTest();
     testData.insertRMAHdd210();
     testData.createPostalCode();
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c
             FROM   RMAv2__c];
     
     System.assertEquals(1, rmas.size());
     
     rmas[0].rmaUplift__c                     = 'Yes: Uplift to 4-Hour';
     rmas[0].rmaOverrideShipmentPostalCode__c = 'BS3A 9ZZ';
     rmas[0].rmaOverrideShipmentCountry__c    = 'United Kingdom';
     update rmas[0];
     
     
     rmas = [SELECT Id,
             rmaUplift__c,
             rmaOverrideShipmentPostalCode__c,
             rmaOverrideShipmentCountry__c,
             rmaOutgoingShipmentOrderProvider__c,
             rmaOutgoingShipmentOrderDepot__c
             FROM   RMAv2__c];
     Test.stopTest();
     System.assertEquals(1,                        rmas.size());
     System.assertEquals('Yes: Uplift to 4-Hour',  rmas[0].rmaUplift__c);
     System.assertEquals('BS3A 9ZZ',               rmas[0].rmaOverrideShipmentPostalCode__c);
     System.assertEquals('United Kingdom',         rmas[0].rmaOverrideShipmentCountry__c);
     //System.assertEquals('Flash',                  rmas[0].rmaOutgoingShipmentOrderProvider__c);
     //System.assertEquals('TEST-002',               rmas[0].rmaOutgoingShipmentOrderDepot__c);
    }
    
}