@isTest(seeAllData=true)
public class rmav2ExtensionsWithSharingDetailv2Test1 {

    static testMethod void rmaHistory_Tracking(){
        RMAv2__c limitQuery = [SELECT Id, rmaStatus__c,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaFaRequired__c,
                        rmaShipmentAccountName__c,
                        rmaShowReturnSectionsAlways__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,rmaCaseNumber__r.casePachinkoCaseType__c,rmaIsNBDOnsiteRetain__c,rmaIsNBDOverriden__c,rmaFailedPart__c, China_Global_Account_RMA__c
                        FROM   RMAv2__c where rmaType__c ='System/part return' and rmaStatus__c = 'Draft' and rmaShipmentPhone__c != null LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(limitQuery);
        rmav2ExtensionsWithSharingDetailV2 rma1 = new rmav2ExtensionsWithSharingDetailV2(sc);
  
		limitQuery.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        limitQuery.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        limitQuery.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
       	limitQuery.rmaGateKeeperStatus__c = 'Automatic'; 
        update limitQuery;
        system.debug('RMA Id -----> '+limitQuery.id);
        /*List<RMAv2__History> rmaHistory = [select ParentId, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedById, CreatedBy.Name
                 From RMAv2__History where ParentId =: limitQuery.id];
        system.debug('RMA history size ----->'+rmaHistory.size());
        
        system.debug('RMA history  ----->'+rmaHistory);
        system.debug('RMA history  ----->'+rmaHistory[0].ParentId);*/
        RMAv2__History rmaHistory = new RMAv2__History(ParentId = limitQuery.Id, Field = 'rmaOutgoingShipmentStatus__c');
        insert rmaHistory;
        List<RMAv2__History> rmaHistoryList = [select ParentId, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedById, CreatedBy.Name
                 From RMAv2__History where ParentId =: limitQuery.id];
         System.ASSERT(rmaHistoryList.size() > 0);
        rma1.getHistories();
        
    }
    
    static testMethod void rmaHistory_Tracking1(){
        RMAv2__c limitQuery = [SELECT Id, rmaStatus__c,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaFaRequired__c,
                        rmaShipmentAccountName__c,
                        rmaShowReturnSectionsAlways__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,rmaCaseNumber__r.casePachinkoCaseType__c,rmaIsNBDOnsiteRetain__c,rmaIsNBDOverriden__c,rmaFailedPart__c, China_Global_Account_RMA__c
                        FROM   RMAv2__c where rmaType__c ='System/part return' and rmaStatus__c = 'Draft' and rmaShipmentPhone__c != null LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(limitQuery);
        rmav2ExtensionsWithSharingDetail rma1 = new rmav2ExtensionsWithSharingDetail(sc);
  
		limitQuery.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        limitQuery.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        limitQuery.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
       	limitQuery.rmaGateKeeperStatus__c = 'Automatic'; 
        update limitQuery;
        system.debug('RMA Id -----> '+limitQuery.id);
        /*List<RMAv2__History> rmaHistory = [select ParentId, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedById, CreatedBy.Name
                 From RMAv2__History where ParentId =: limitQuery.id];
        system.debug('RMA history size ----->'+rmaHistory.size());
        
        system.debug('RMA history  ----->'+rmaHistory);
        system.debug('RMA history  ----->'+rmaHistory[0].ParentId);*/
        RMAv2__History rmaHistory = new RMAv2__History(ParentId = limitQuery.Id, Field = 'rmaOutgoingShipmentStatus__c');
        insert rmaHistory;
        List<RMAv2__History> rmaHistoryList = [select ParentId, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedById, CreatedBy.Name
                 From RMAv2__History where ParentId =: limitQuery.id];
         System.ASSERT(rmaHistoryList.size() > 0);
        rma1.getHistories();
        
    }
    
    static testMethod void chinaGaRMA(){
        RMAv2__c limitQuery = [SELECT Id, rmaStatus__c,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaFaRequired__c,
                        rmaShipmentAccountName__c,
                        rmaShowReturnSectionsAlways__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,
                        rmaAssetSla__c,rmaCaseNumber__r.casePachinkoCaseType__c,rmaIsNBDOnsiteRetain__c,rmaIsNBDOverriden__c,rmaFailedPart__c, China_Global_Account_RMA__c
                        FROM   RMAv2__c where China_Global_Account_RMA__c = True and rmaStatus__c = 'Draft' and rmaShipmentPhone__c != null order by createddate desc LIMIT 1 ];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(limitQuery);
        rmav2ExtensionsWithSharingDetailV2 rma1 = new rmav2ExtensionsWithSharingDetailV2(sc);
        
        
    }
     static testMethod void depotLabel(){
        RMAv2__c limitQuery = [SELECT Id, rmaStatus__c,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaFaRequired__c,
                        rmaShipmentAccountName__c,
                        rmaShowReturnSectionsAlways__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                        rmaOutgoingShipmentDateTimeOpened__c,
                        rmaShowOnSiteSectionsAlways__c,
                        rmaAssetNrdIsInEffect__c,
                        rmaPartIsAShipOnlyPart__c,rmaOutgoingShipmentDepot__c,
                        rmaAssetSla__c,rmaCaseNumber__r.casePachinkoCaseType__c,rmaIsNBDOnsiteRetain__c,rmaIsNBDOverriden__c,rmaFailedPart__c, China_Global_Account_RMA__c
                        FROM   RMAv2__c where rmaOutgoingShipmentDepot__c != null order by createddate desc LIMIT 1 ];
        
         ApexPages.StandardController sc = new ApexPages.StandardController(limitQuery);
         rmav2ExtensionsWithSharingDetailV2 rma1 = new rmav2ExtensionsWithSharingDetailV2(sc);
         String result = rma1.getDepotLabel();
         rma1.cloneRMA();
         
    }
    static testMethod void deleteRMA(){
        RMAv2__c limitQuery = [SELECT Id, rmaStatus__c,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaFaRequired__c,
                        rmaShipmentAccountName__c,
                        rmaShowReturnSectionsAlways__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                               rmaOutgoingShipmentDateTimeOpened__c,
                               rmaShowOnSiteSectionsAlways__c,
                               rmaAssetNrdIsInEffect__c,
                               rmaPartIsAShipOnlyPart__c,rmaDeliveryDate__c,rmaAssetLocalDateTime__c,
                               rmaAssetSla__c,rmaCaseNumber__r.casePachinkoCaseType__c,rmaIsNBDOnsiteRetain__c,rmaIsNBDOverriden__c,rmaFailedPart__c, China_Global_Account_RMA__c
                               FROM   RMAv2__c where rmaOutgoingShipmentStatus__c != null and rmaOutgoingShipmentStatus__c != 'DRAFT-10: Waiting to order' order by createddate desc LIMIT 1 ];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(limitQuery);
        rmav2ExtensionsWithSharingDetailV2 newRma = new rmav2ExtensionsWithSharingDetailV2(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', limitQuery.Id);
        Test.setCurrentPage(pageRef);
        newRma.cloneRMA();
        newRma.deleteRMA();
        newRma.getOpenShipmentStatus();
        
    }
     static testMethod void rmaDeliveryTime(){
        RMAv2__c limitQuery = [SELECT Id, rmaStatus__c,
                        rmaCaseNumber__c,
                        rmaType__c,
                        rmaLabArray__c,
                        rmaComponent__c,
                        rmaFaRequired__c,
                        rmaShipmentAccountName__c,
                        rmaShowReturnSectionsAlways__c,
                        rmaNimbleOsVersion__c,
                        rmaModel__c,
                        rmaPart__c,
                        rmaQuantity__c,
                        rmaAddressBook__c,
                        rmaReason__c,
                        rmaManufacturer__c,
                        rmaDetailedReason__c,
                        rmaConfigurationDetails__c,
                        rmaUplift__c,
                        rmaOutgoingShipmentStatus__c,
                        rmaReturnShipmentStatus__c,
                               rmaOutgoingShipmentDateTimeOpened__c,
                               rmaShowOnSiteSectionsAlways__c,
                               rmaAssetNrdIsInEffect__c,
                               rmaPartIsAShipOnlyPart__c,rmaDeliveryDate__c,rmaAssetLocalDateTime__c,
                               rmaAssetSla__c,rmaCaseNumber__r.casePachinkoCaseType__c,rmaIsNBDOnsiteRetain__c,rmaIsNBDOverriden__c,rmaFailedPart__c, China_Global_Account_RMA__c
                               FROM   RMAv2__c where rmaDeliveryDate__c != null and rmaAssetLocalDateTime__c != null order by createddate desc LIMIT 1 ];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(limitQuery);
        rmav2ExtensionsWithSharingDetailV2 newRma = new rmav2ExtensionsWithSharingDetailV2(sc);
        
        PageReference pageRef = Page.rmaV2DetailPageV2;
        pageRef.getParameters().put('id', limitQuery.Id);
        Test.setCurrentPage(pageRef);
        newRma.cloneRMA();
        newRma.deleteRMA();
        newRma.getOpenShipmentStatus();
        
    }
}