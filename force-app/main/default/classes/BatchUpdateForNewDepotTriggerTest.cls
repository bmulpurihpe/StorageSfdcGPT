@isTest
//(seeAllData = true)
public class BatchUpdateForNewDepotTriggerTest {

   Static TestMethod void getDepotsWithin375MilesRadius(){
       /*List<Depot__c> depotList = [select id, name,depotLocation__c,depotLocation__Latitude__s,depotLocation__Longitude__s,Returns_Carrier__c,depotNewDepot__c from depot__c where id = 'a2G3400000CU2y8'];
       Test.startTest();  
       depotList[0].depotProvider__c = 'Flash';
         depotList[0].depotStockedFor4Hour__c = 'Yes';
       depotList[0].depotStockedFor4HourEta__c = system.today();
       Update depotList;
        Test.stopTest();*/
       List<Depot__c> depotlist = New List<Depot__c>();
       Depot__c depot = new Depot__c();
       depot.Name = 'Depot - Test';
       depot.depotIsactive__c = True;
       depot.depotStockedFor4Hour__c = 'Yes';
       depot.depotStreet1__c = 'Test Street 1';
       depot.depotStreet2__c = 'Test Street 2';
       depot.depotCity__c = 'Test City';
       depot.depotState__c = 'Test State';
       depot.depotPostalCode__c = '123456';
       depot.depotCountry__c = 'Test Country';
       depot.depotProvider__c = 'Flash';
       depot.depotLocationDescription__c = 'Test Street 1, Test Street 2, Test City, Test State, 123456, Test Country';
       depot.Returns_Carrier__c = 'DHL';
       depot.depotLocation__Latitude__s = 11.343345;
       depot.depotLocation__Longitude__s = 121.34532231;
       depot.depotNewDepot__c = true;
       insert depot;             
      depotlist.add(depot);
       	depot.depotProvider__c = 'Nimble';  
     
      	update depot ;
       Depot__c depot1 = new Depot__c();
       depot1.Name = 'Depot - Test1';
       depot1.depotIsactive__c = True;
       depot1.depotStockedFor4Hour__c = 'Yes';
       depot1.depotStreet1__c = 'Test Street 1';
       depot1.depotStreet2__c = 'Test Street 2';
       depot1.depotCity__c = 'Test City';
       depot1.depotState__c = 'Test State';
       depot1.depotPostalCode__c = '123456';
       depot1.depotCountry__c = 'Test Country';
       depot1.depotProvider__c = 'Flash';
       depot1.depotLocationDescription__c = 'Test Street 1, Test Street 2, Test City, Test State, 123456, Test Country';
       depot1.Returns_Carrier__c = 'DHL';
       depot1.depotLocation__Latitude__s = 11.343345;
       depot1.depotLocation__Longitude__s = 121.34532231;
       depot1.depotNewDepot__c = true;
       insert depot1;  
       	depot1.depotProvider__c = 'Nimble';  
      	update depot1 ;
       
    }
}