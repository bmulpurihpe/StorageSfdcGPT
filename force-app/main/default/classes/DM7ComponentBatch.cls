/*
* Created by Exafort for the JIRA TS-9712
* Batch class to process DM7 component records to insert/update component records
* Batch class passes all the processing DM7 component records into the utility class "DM7ComponentBatchUtil"
* Test Class - DM7ComponentBatch_Test

Description :
	1) Queries DM7 Component Data
	2) Queries Assets related to data from step 1
	3) If DM7 components serial number is found as component under the Asset
				Update component
		else
				Insert Component
*/

Public class DM7ComponentBatch implements Database.Batchable<sObject>{
    String query; 
    
    public DM7ComponentBatch(String query)
    { 
        this.query = query;
    } 
    
    public DM7ComponentBatch()
    {
        //	CreatedDate = last_n_days:30 Updated by Exafort for SFDC-1176
        query = 'select id, asupComponentAccount__c,asupcomponentDiskSled__c, asupComponentAsset__c, asupComponentAsset__r.Product_Name__c,asupComponentUberSN__c, '+
            'asupComponentAsset__r.Parent_Asset__c,asupComponentAsset__r.Parent_Asset__r.Product_Name__c , asupComponentAsset__r.Parent_Asset__r.Dynamic_SKU__c,'+
            'asupComponentAsset__r.Dynamic_SKU__c,asupComponentAssetSN__c, asupComponentSN__c,asupComponentDiskModel__c,asupComponentDiskSizeGB__c,VALID_FROM_DATE__c,VALID_TO_DATE__c,'+
            'asupComponentErrorRate__c,asupComponentFirstASUP__c,asupComponentLastStatusDate__c,asupComponentLocation__c,asupComponentMostRecentASUP__c,'+ 
            'asupComponentDiskShelfSlot__c, asupComponentDiskPortNumber__c, asupComponentControllerState__c, asupComponentType__c,'+ 
            'component_Location__c, Component_Part_Number__c, Board_Part_Number__c, Component_status__c,UPD_TYPE__c,CreatedDate,'+
            'asupComponentDiskUsedState__c, asupComponentControllerLocation__c, asupComponentAssetType__c , asupComponentAssetProductCode__c, asupcomponentMatchedWithComponent__c '+
            'from DM7_Component__c where asupComponentSN__c != null and asupComponentAssetSN__c != null and ' + 
            'CreatedDate = last_n_days:90 and ' +
            'asupComponentType__c in (\'CDM\',\'PSU\',\'IOM\',\'Memory\',\'BootDevice\',\'SSD\',\'Chassis\',\'FC\',\'NIC\',\'SFP\',\'PWR(power supply)\') ' +
            //' and asupComponentAssetSN__c  = \'CZ2333032Y\' ' +
            'order by asupComponentAssetSN__c,asupComponentSN__c,createddate asc, name asc';        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('Scope ' + scope);
        
        // List stores all the DM7 Component record to be processed from the above query
        List<DM7_Component__c> dm7ComponentRecords = scope;
        
        // Map stores the asupComponentAssetSN__c with the DM7 list
        Map<String,List<DM7_Component__c>> asstWithDM7Comp = new Map<String,List<DM7_Component__c>>();
        Set<Id> acctIds = new Set<Id>();
        Map<String,Id> asstToAcct = new Map<String,Id>();
        
        // Map with component list based on asset and account
        Map<String,List<Component__c>> asstWithComp = new Map<String,List<Component__c>>();
        Map<Id,List<Component__c>> acctWithComp = new Map<Id,List<Component__c>>();
        
        // Map with SR MetaData field values
        Map<String,String> modelToSRMap = new Map<String,String>();
        Map<String,List<String>> modelwithAsstToSRMap = new Map<String,List<String>>();
        Map<String,String> modelWithProductCode = new Map<String,String>();
        Map<string, string> modelWithAssetTypeSRMapFinal = new Map<string, string>();
        Map<String,String> modelToSRMapProductName = new Map<String,String>();
        Map<String,String> modelToSRMapDynamicSKU = new Map<String,String>();
        
        // Added by Exafort for SFDC-525
        Set<String> dm7ComponentSNs = new Set<String>();
        for (DM7_Component__c dm7Component : dm7ComponentRecords) {
            if (dm7Component.asupComponentAssetSN__c != null) {
                dm7ComponentSNs.add(dm7Component.asupComponentAssetSN__c);
            }
        }
        
        Set<String> shippedAssetSNs = new Set<String>();
        for (Asset assetRecords : [ SELECT id, Name FROM Asset WHERE Status = 'Shipped' AND Name IN :dm7ComponentSNs ]) {
            shippedAssetSNs.add(assetRecords.Name);
        }
        // End of SFDC-525
        
        for(DM7_Component__c dm7Component : dm7ComponentRecords){
            // Get the list of Asset SN for the processing DM7 Component records
            // Added by Exafort for SFDC-525
            // Condition checks if the processing DM7 Components related asset status is "Shipped"
            if(shippedAssetSNs.contains(dm7Component.asupComponentAssetSN__c)){
                if(dm7Component.asupComponentAssetSN__c != null){
                    List<DM7_Component__c> dm7CompList = asstWithDM7Comp.get(dm7Component.asupComponentAssetSN__c);
                    if(dm7CompList == null)
                        dm7CompList = new List<DM7_Component__c>();
                    dm7CompList.add(dm7Component);
                    asstWithDM7Comp.put(dm7Component.asupComponentAssetSN__c,dm7CompList); 
                }
                
                // Get the processing DM7 component records Asset SN and its account id in a map
                if(dm7Component.asupComponentAccount__c != null){
                    acctIds.add(dm7Component.asupComponentAccount__c);
                    asstToAcct.put(dm7Component.asupComponentAssetSN__c,dm7Component.asupComponentAccount__c);
                }
            }
        }
        system.debug('asstWithDM7Comp --> ' + asstWithDM7Comp);
        system.debug('acctIds --> ' + acctIds);
        system.debug('asstToAcct --> ' + asstToAcct);
        
        // Query the existing created Component based on the processing DM7's Asset
        List<Asset> asstList = [select Id,name, AccountId, Product_Name__c,ProductCode__c, Parent_Asset__c, Parent_Asset__r.Product_Name__c,Parent_Asset__r.Dynamic_SKU__c, 
                                (select Id, componentComponentSN__c, componentServicePartNumber__c, componentDiskModel__c, componentAsset__c, componentProcessedByFLEX__c, 
                                 componentState__c, componentType__c from Components__r 
                                 where componentType__c in ('CDM','PSU','IOM','Memory','BootDevice','SSD','Chassis','FC','NIC','SFP','PWR(power supply)')) 
                                from Asset where name in :asstWithDM7Comp.keySet()];
        
        system.debug('asstList size : ' + asstList.size());
        if(asstList.size() > 0){
            for(Asset assetRecord : asstList){
                List<Component__c> compList = assetRecord.Components__r;
                asstWithComp.put(assetRecord.name,compList);
            }
            system.debug('asstWithComp --> ' + asstWithComp);
            system.debug('asstWithComp Size --> ' + asstWithComp.size());
            
            // Query the Component records based on Account Id's
            List<Account> acctList = [select Id, (select Id, componentComponentSN__c, componentServicePartNumber__c, componentDiskModel__c, componentAsset__c, componentProcessedByFLEX__c, 
                                                  componentState__c, componentType__c from Components__r 
                                                  where componentType__c in ('CDM','PSU','IOM','Memory','BootDevice','SSD','Chassis','FC','NIC','SFP','PWR(power supply)') and componentAsset__c = null) 
                                      from Account where Id in :acctIds];
            
            for(Account accountRecord : acctList){
                List<Component__c> compList = accountRecord.Components__r;
                acctWithComp.put(accountRecord.Id,compList);
                system.debug('Comp List Size --> ' + compList);
            }
            
            system.debug('acctWithComp --> ' + acctWithComp);
            system.debug('acctWithComp Size --> ' + acctWithComp.size());
            
            // Utility class to process SR MetaData
            // Populates all the necessory map values for the SR Metadata
            SrMetaDataUtil.PrepareSRMetaData();
            modelToSRMap = SrMetaDataUtil.modelToSRMap;
            modelWithProductCode = SrMetaDataUtil.modelWithProductCode;
            modelWithAssetTypeSRMapFinal = SrMetaDataUtil.modelWithAssetTypeSRMapFinal;
            modelToSRMapProductName = SrMetaDataUtil.modelToSRMapProductName;
            modelToSRMapDynamicSKU = SrMetaDataUtil.modelToSRMapDynamicSKU;
            
            system.debug('modelToSRMap Size --> ' + modelToSRMap.size());
            system.debug('modelToSmodelWithProductCodeRMap Size --> ' + modelWithProductCode.size());
            system.debug('modelWithAssetTypeSRMapFinal Size --> ' + modelWithAssetTypeSRMapFinal.size());
            system.debug('modelToSRMapProductName Size --> ' + modelToSRMapProductName.size());
            system.debug('modelToSRMapDynamicSKU Size --> ' + modelToSRMapDynamicSKU.size());
            
            //looping with incoming asup Asset ID's
            for(String asstid : asstWithDM7Comp.keySet()){ 
                system.debug('Entred into for loop');
                //returns list of asup components for an asset
                List<DM7_Component__c> dm7CompList = asstWithDM7Comp.get(asstid); 
                system.debug('dm7CompList --> ' + dm7CompList);
                //returns list of components for an asset
                system.debug(' asstWithComp.get(asstid) : ' +  asstWithComp.get(asstid));
                if(asstWithComp.get(asstid) != null){
                    List<Component__c> compList = asstWithComp.get(asstid);
                    system.debug('compList --> ' + compList + 'SIZE ' + compList.size());
                    Set<Id> compIds = new Set<Id>();
                    
                    
                    for(Component__c component : compList)
                    {
                        compIds.add(component.Id);
                    }
                    
                    //returns account for an asset
                    Id acctId = asstToAcct.get(asstid); 
                    if(acctId != null){
                        //returns list of components for an Account
                        List<Component__c> compListForAcct = acctWithComp.get(acctId); 
                        system.debug('compListForAcct.size() + ' + compListForAcct.size());
                        for(Integer i = 0; i < compListForAcct.size(); i++){
                            Component__c cA = compListForAcct.get(i);
                            if(compIds.contains(cA.Id))
                                compListForAcct.remove(i);
                        }
                        compList.addAll(compListForAcct);
                    }
                    system.debug('dm7CompList ==>' + dm7CompList );
                    system.debug('dm7CompList Size ==>' + dm7CompList.size());
                    system.debug('compList ==>' + compList );
                    system.debug('compList Size ==>' + compList.size());
                    system.debug('modelToSRMap ==>' + modelToSRMap );
                    system.debug('modelToSRMap Size ==>' + modelToSRMap.size());
                    system.debug('modelWithProductCode ==>' + modelWithProductCode );
                    system.debug('modelWithProductCode Size ==>' + modelWithProductCode.size());
                    
                    // Utility class to insert/update Component
                    DM7ComponentBatchUtil.processDM7ForAccountOrAsset(dm7CompList,compList,modelToSRMap,modelWithProductCode,modelWithAssetTypeSRMapFinal,
                                                                        modelToSRMapProductName,modelToSRMapDynamicSKU);
                }
            }
        }        
        List<Component__c> compsToInsert = DM7ComponentBatchUtil.compsToInsert;
        List<Component__c> compsToUpdate = DM7ComponentBatchUtil.updateCompRecord.values();
        List<DM7_Component__c> dm7ToUpdate =  DM7ComponentBatchUtil.dm7ToUpdate;
        
        system.debug('compsToInsert --> ' + compsToInsert + ' Size ' + compsToInsert.size());
        system.debug('compsToUpdate --> ' + compsToUpdate);
        system.debug('dm7ToUpdate --> ' + dm7ToUpdate);
        
        // Insert new component records
        if(compsToInsert.size() > 0)
            insert compsToInsert;
        
        // update existing component records
        if(compsToUpdate.size() > 0)
            system.debug('Enetered to updated Component records util class');
            update compsToUpdate;
        
        // Update the processed the DM7 records
        if(dm7ToUpdate.size() > 0)
            update dm7ToUpdate;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}