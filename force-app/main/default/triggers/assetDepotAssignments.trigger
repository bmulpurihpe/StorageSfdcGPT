trigger assetDepotAssignments on Asset (after Insert,after Update) {
    /*Added assetNearbyDepot__r.Name,assetPartShipAddressBook__r.ab4HourDepot__c,
	* assetPartShipAddressBook__r.ab4HourDepot__r.Name in the Query- By Vishnu on 9 April 2020 for TS-6902*/
    if(assetPreventRecursive.runOnce())
    {
        //	Added ab4HourDepotTsc__c field in the query by exafort for TS-10717
        List<Asset> assetToProcess = [Select 
                                      assetPartShipAddressBook__c,
                                      assetParentSLA__c,
                                      Install_Country__c,
                                      Install_State_Province__c,
                                      Install_Zip_Code__c,
                                      assetNearbyDepot__r.Name,
                                      assetPartShipAddressBook__r.abCountry__c,
                                      assetPartShipAddressBook__r.abStateProvince__c,
                                      assetPartShipAddressBook__r.abPostalCode__c,
                                      assetPartShipAddressBook__r.ab4HourDepot__c,
                                      assetPartShipAddressBook__r.ab4HourDepot__r.Name,
                                      assetInstallAddressDepot__c,
                                      assetShipmentAddressDepot__c,
                                      SLA__c, 
                                      Account.Name, 
                                      Account.Support_Provider__c, 
                                      Account.Support_Provider__r.Name, 
                                      assetPartShipAddressBook__r.ab4HourDepotTsc__c,
                                      assetPartShipAddressBook__r.ab4HourDepotTsc__r.Name
                                      FROM Asset 
                                      where Id IN: Trigger.newMap.keySet()];  
        assetDepotAssignments depotAssignments = new assetDepotAssignments(assetToProcess);
        depotAssignments.assetDepotMain();
    }
}