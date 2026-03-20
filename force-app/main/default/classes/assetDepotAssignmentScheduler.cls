global class assetDepotAssignmentScheduler implements Schedulable{
     global void execute(SchedulableContext sc) {
            string Query='Select assetPartShipAddressBook__c,assetParentSLA__c,Install_Country__c,Install_State_Province__c,Install_Zip_Code__c,assetPartShipAddressBook__r.abCountry__c,assetPartShipAddressBook__r.abStateProvince__c,assetPartShipAddressBook__r.abPostalCode__c,assetInstallAddressDepot__c,assetShipmentAddressDepot__c FROM Asset';
			Database.executeBatch(new assetDepotAssignmentsBatch(Query),50);
     }
  }