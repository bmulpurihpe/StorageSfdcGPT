global class depotBatchUpdate implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String query = 'SELECT Id,Name,depotAddress__c FROM depot__c where id in(\'a2G8A0000002dC3\', \'a2G8A0000002dC4\', \'a2G8A0000002dC5\', \'a2G8A0000002dC6\', \'a2G8A0000002dC7\', \'a2G8A0000002dC8\', \'a2G8A0000002dC9\', \'a2G8A0000002dCA\', \'a2G8A0000002dCB\')';
        String query = 'Select Id, Name, depotAddress__c,depotCity__c,depotCountry__c,depotState__c,depotWithoutStreet__c,depotWithCity__c FROM depot__c where depotIsactive__c = true and depotStockedFor4Hour__c = \'Yes\'';
            return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<depot__c> scope) {
        //Map of Depot Id, and Depot Address
        map<id, string> depotmaps = new map<id, string>();
        map<id, string> depotmapswithouStreet = new map<id, string>();
        map<id, string> depotmapswithCity = new map<id, string>();
        string depotstring = 'depot__c';
         for(depot__c a : scope)
         {
             /*string AddreswithoutSt = '';
             AddreswithoutSt += a.depotCity__c;
             AddreswithoutSt += a.depotState__c;
             AddreswithoutSt += a.depotCountry__c;
             
             string Addresswithcity = '';
             Addresswithcity += a.depotCity__c;
             Addresswithcity += a.depotCountry__c;*/
             if(a.depotAddress__c != null){
                 depotmaps.put(a.Id, a.depotAddress__c);
             }
             if(a.depotWithoutStreet__c != null){
                 depotmapswithouStreet.put(a.Id, a.depotWithoutStreet__c);
             }
             if(a.depotWithCity__c != null){
                 depotmapswithCity.put(a.Id, a.depotWithCity__c);
             }
             
            /* depotmapswithouStreet.put(a.Id, AddreswithoutSt);
                 depotmapswithCity.put(a.Id, Addresswithcity);*/
         }
       // If(!Test.isRunningTest())
        if(depotmaps.size() > 0 && depotmapswithouStreet.size() > 0 && depotmapswithCity.size() > 0){
            Geolocationaddress.geocodeAddress(depotmaps, depotstring, depotmapswithouStreet, depotmapswithCity); 
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}