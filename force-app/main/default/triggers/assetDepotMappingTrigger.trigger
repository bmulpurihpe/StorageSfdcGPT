trigger assetDepotMappingTrigger on Asset (before insert,after insert, after update, before update) {
    string address = '';
    string assetid = '';
    string Objectapi = 'Asset';
    
    //Map of Asset Id, Asset Address
    Map<id, String> Assets = new Map<id, String>();
    Map<id, String> AssetswithoutStreet = new Map<id, String>();
    Map<id, String> AssetswithCity = new Map<id, String>();
    // Added by Exafort for TS-5613, map holds the asset id and install country
    Map<id, String> AssetswithCountry = New Map<id, String>();
    list<Asset> assetList = new list<Asset>();
    Map<Id,Account> assetAccount = new Map<Id,Account>(); // Added by Exafort for TS-9109    
    
    
    set<ID> accId = new set<ID>();
    for(Asset assetRec : Trigger.new){
        if(assetRec.AccountId != null)
            accId.add(assetRec.AccountId);
    }
    system.debug('accId --> ' + accId);
    
    //Added by Exafort for TS-9109
     Map<Id,Account> assetAcc = new Map<Id,Account>();
    
    boolean isIdChanged = !AssetUtility.accountRecordIds.equals(accId);
    system.debug('isIdChanged --> ' + isIdChanged);
    system.debug('AssetUtility.accountRecordIds --> ' + AssetUtility.accountRecordIds);
    
    //	If new IDs are found, dont use Cached values, clear cache
    if(isIdChanged){
        AssetUtility.accountRecordIds.clear();
        AssetUtility.accountRecordIds.addall(accId);
        AssetUtility.restrictAccountList = false;
    }
    
    system.debug('accId size --> ' + accId.size());
    if(accId.size() > 0 && !AssetUtility.restrictAccountList){
		system.debug('assetDepotMappingTrigger Querying asset account information');        
        AssetUtility.assetAccountList = new Map<Id,Account>([Select Name, Id, Support_Provider__r.Name from Account where ID =: accId]);
        AssetUtility.restrictAccountList = true;        
    }
    assetAcc = AssetUtility.assetAccountList;
    
    
    system.debug('assetDepotMappingTrigger assetAcc --> ' + assetAcc);
    system.debug('assetDepotMappingTrigger assetAcc.size() --> ' + assetAcc.size());
	// End of TS-9109
    
    //Map<Id,Account> assetAcc = new Map<Id,Account>([Select Name, Id, Support_Provider__r.Name from Account where ID =: accId]);
    //system.debug('assetAcc --> ' + assetAcc.size());
    //Trigger block for After Update
    if(Trigger.IsUpdate && Trigger.IsAfter){
        system.debug('IsUpdate');
        if(assetGeocalPreventRecursive.runOnce()){
            for (Asset assetnew : Trigger.new) {
                string AssetSLA = '';
                string AssetSLAOld = '';
                if(assetnew.SLA__c != null)
                    AssetSLA = assetnew.SLA__c;
                
                //if(assetnew.SLA__c == 'Premium 4 Hour' || assetnew.SLA__c == 'Premium 4 Hour Onsite' || assetnew.SLA__c == 'TSC: Premium 4 Hour' || assetnew.SLA__c == 'TSC: Premium 4 Hour Onsite'){
                //Only SLA's with 4 hour are considered 
                if (AssetSLA.contains('4 Hour')){
                    system.debug('Inside For Asset 4Hour');
                    // Access the "old" record by its ID in Trigger.oldMap
                    Asset assetold = Trigger.oldMap.get(assetnew.Id);
                    boolean isH3CAccount = false;
                    if(assetAcc.get(assetnew.AccountId) != null && assetAcc.get(assetnew.AccountId).Support_Provider__c != null && assetAcc.get(assetnew.AccountId).Support_Provider__r.Name != null && assetAcc.get(assetnew.AccountId).Support_Provider__r.Name.contains('H3C')){
                        isH3CAccount = true;
                    }
                    
                    if(assetold.SLA__c != null)
                        AssetSLAOld = assetold.SLA__c;
                    //Check if there is a change in Address
                    if(((AssetSLA != AssetSLAOld) || (assetold.Install_Zip_Code__c != assetnew.Install_Zip_Code__c) || (assetold.Install_City__c != assetnew.Install_City__c) || (assetold.Install_Street1__c != assetnew.Install_Street1__c) || (assetold.Install_Street2__c != assetnew.Install_Street2__c) || (assetold.Install_Country__c != assetnew.Install_Country__c) || (assetold.Install_State_Province__c != assetnew.Install_State_Province__c)) && assetnew.Install_Country__c != 'South Korea' && assetnew.assetDontCalculateDepot__c == false && (assetAcc.get(assetnew.AccountId) != null && assetAcc.get(assetnew.AccountId).Name != null && !assetAcc.get(assetnew.AccountId).Name.contains('H3C')) && isH3CAccount == false){
                        address =  assetnew.assetAddress__c;
                        assetid = assetnew.Id;
                        Assets.put(assetid, address);
                        AssetswithoutStreet.put(assetid, assetnew.assetAddressWithoutStreet__c);
                        AssetswithCity.put(assetid, assetnew.assetAddressWithCity__c);
                        // Added by Exafort for TS-5631
                        AssetswithCountry.put(assetid, assetnew.Install_Country__c);
                    }
                }
            }
        }   
    }
    
    //Trigger block for Before Update
    if(Trigger.IsUpdate && Trigger.IsBefore){
        for (Asset assetnew : Trigger.new) {
            string AssetSLA = '';
            if(assetnew.SLA__c != null)
                AssetSLA = assetnew.SLA__c;
            if (AssetSLA.contains('4 Hour')){
                //if(assetnew.SLA__c == 'Premium 4 Hour' || assetnew.SLA__c == 'Premium 4 Hour Onsite' || assetnew.SLA__c == 'TSC: Premium 4 Hour' || assetnew.SLA__c == 'TSC: Premium 4 Hour Onsite'){
                Asset assetold = Trigger.oldMap.get(assetnew.Id);
                if (assetnew.assetPartShipAddressBook__c != assetold.assetPartShipAddressBook__c){
                    assetnew.assetShipAddressChanged__c = true;
                }      
            }
        }
    }
    
    
    //Trigger block for Insert
    if(Trigger.IsInsert && Trigger.IsAfter){
        /*** Disable Depot Calculation for H3C and its customer accounts ***/
        /*** Date: 01/16/2018
         *   Author: Exafort(Azar)
         * **/
        /*set<ID> accId = new set<ID>();
        for(Asset assetRec : Trigger.new){
            accId.add(assetRec.AccountId);
        }
        Map<Id,Account> assetAcc = new Map<Id,Account>([Select Name, Id, Support_Provider__r.Name from Account where ID =: accId]);*/
        
        for (Asset assetnew : Trigger.new) {
            boolean isH3CAccount = false;
            if(assetAcc.get(assetnew.AccountId) != null && assetAcc.get(assetnew.AccountId).Support_Provider__c != null && assetAcc.get(assetnew.AccountId).Support_Provider__r.Name != null && assetAcc.get(assetnew.AccountId).Support_Provider__r.Name.contains('H3C')){
                isH3CAccount = true;
            }
            //REMOVED - IT IS WORKING NOW
            // && (!assetAcc.get(assetnew.AccountId).Name.contains('H3C')) && (assetAcc.get(assetnew.AccountId).Support_Provider__c != null && !assetAcc.get(assetnew.AccountId).Support_Provider__r.Name.contains('H3C'))
            if((assetnew.SLA__c == 'Premium 4 Hour' || assetnew.SLA__c == 'Premium 4 Hour Onsite' || assetnew.SLA__c == 'TSC: Premium 4 Hour' || assetnew.SLA__c == 'TSC: Premium 4 Hour Onsite') && assetnew.Install_Country__c != 'South Korea' && assetnew.assetDontCalculateDepot__c == false && (assetAcc.get(assetnew.AccountId) != null && assetAcc.get(assetnew.AccountId).Name != null && !assetAcc.get(assetnew.AccountId).Name.contains('H3C')) && isH3CAccount == false){
                
                address =  assetnew.assetAddress__c;
                assetid = assetnew.Id;
                Assets.put(assetid, address);
                AssetswithoutStreet.put(assetid, assetnew.assetAddressWithoutStreet__c);
                AssetswithCity.put(assetid, assetnew.assetAddressWithCity__c);
                // Added by Exafort for TS-5631
                AssetswithCountry.put(assetid, assetnew.Install_Country__c);
            }
        }
    }
    
    
    if(Trigger.isInsert && Trigger.isBefore){
        /*** Update Unknown for H3C Aseets  ***/
        /*** Date: 01/16/2018
        *   Author: Exafort(Azar)
        * ***/
        for(Asset assetRec : Trigger.new){
            if((assetRec.SLA__c != null && assetRec.SLA__c.contains('H3C')) || (assetAcc.get(assetRec.AccountId) != null && assetAcc.get(assetRec.AccountId).Name != null && assetAcc.get(assetRec.AccountId).Name.contains('H3C')) || (assetAcc.get(assetRec.AccountId) != null && assetAcc.get(assetRec.AccountId).Support_Provider__c !=null && assetAcc.get(assetRec.AccountId).Support_Provider__r.Name != null && assetAcc.get(assetRec.AccountId).Support_Provider__r.Name.contains('H3C'))){
                assetRec.assetInstallAddressDepot__c = 'Unknown';
                assetRec.assetShipmentAddressDepot__c = 'Unknown';
            }
        }
    }
    
    if(!Assets.isEmpty()){
        //Passing the map of Asset id and address, Object api('Asset'), map of Asset id and address without street, map of Asset id and address with city and country
        if(System.IsBatch() == false && System.isFuture() == false){
            // Added new parameter "AssetswithCountry" by exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign //
            Geolocationaddress.geocodeAddressFuture(Assets, Objectapi, AssetswithoutStreet, AssetswithCity, AssetswithCountry);
        }
    }
}