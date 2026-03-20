/*
* Created by Exafort for the JIRA TS-9711
* Utility class to create component records from the given FoxConnFactoryUCData
* Batch class pass the list of Asset thats queried
* Utility class takes all the FoxConnFactoryUCData related to queried asset
* The batch class logic, when the field "Child PN" [Child_PN__c] from "FoxConnFactoryUCData" object matches with the field "Model Numbers" [srModelNumbers__c] from the "SR MetaData" object, 
* then creates the SRMetaData's "SR Part" [srPart__c] as the Component Service Part Number.
* Test Class - AssetComponentFromFoxConnDataBatch_Test
*/
public class FoxConnComponentDataUtil{
    // map to get the SR Metadata
    public Map<string, SR_Meta_Data__c> srcomponentTypeConversionMap = new Map<string, SR_Meta_Data__c>();
    public Map<string, list<SR_Meta_Data__c>> eachModelwithSRMap = new Map<string, list<SR_Meta_Data__c>>();
    public Map<Id,String> assetIdWithStatusMessage = new Map<Id,String>();
    public list<Component__c> upsertComponentList = new list<Component__c>(); 
    public list<FoxConnFactoryUCData__c> updateFoxConnRecList = new list<FoxConnFactoryUCData__c>();
    public integer successCount;
    public integer errorCount;
    
    public void processData(list<string> assetList,Map<string,string> asstWithCompSN,Map<string,map<string,id>> assetWithCompId, String fieldType){
        Map<string,list<FoxConnFactoryUCData__c>> assetWithFoxConnMap = new Map<string,list<FoxConnFactoryUCData__c>>(); 
        Map<string,Asset> assetMap = new Map<string,asset>();
        set<string> childPNCollection = new set<string>(); 
        system.debug('asstWithCompSN : ' + asstWithCompSN);
        system.debug('assetWithCompId : ' + assetWithCompId);
        
        // Get processed asset record in a Map
        if (fieldType == 'assetName'){
            for(Asset assetRecList : [Select id,name, accountId from asset where name =: assetList]){
                assetMap.put(assetRecList.name, assetRecList);
            }
        } else if (fieldType == 'hpeSerialNumber'){
            for(Asset assetRecList : [Select id,name, accountId, HPE_Serial_Number__c from asset where HPE_Serial_Number__c =: assetList]){
                assetMap.put(assetRecList.HPE_Serial_Number__c, assetRecList);
                system.debug('hpeSerialNumber');
            }
        }
        
        // Get all the sr Metadata record with its model number
        getSrMetadata();
        system.debug('srcomponentTypeConversionMap : ' + srcomponentTypeConversionMap.size());
        system.debug('eachModelwithSRMap : ' + eachModelwithSRMap.size());
        
        Map<string,FoxConnFactoryUCData__c> uberWithFoxConnMap = new Map<string,FoxConnFactoryUCData__c>(); 
        
        // Get only the FoxConn records that is related to the asset processed
        for(FoxConnFactoryUCData__c foxConnRecords : [select
                                                      id,name,Child_PN__c,Item__c,Unit_Serial_Number__c,Child_SN__c,FoxConn_Processed_Message__c,
                                                      UberSerialNumber__c,UberSKU__c,UberSKUDesc__c 
                                                      from FoxConnFactoryUCData__c 
                                                      where Child_PN__c != null and Unit_Serial_Number__c =: assetList and FoxConn_Proccessed__c != 'Success']
           ){
               string trimmedChildPN = foxConnRecords.Child_PN__c;
               childPNCollection.add(trimmedChildPN.replace('NMB-',''));
               
               // Stores the Foxconn records based on Asset in a Map
               if (assetWithFoxConnMap.containsKey(foxConnRecords.Unit_Serial_Number__c)) {
                   assetWithFoxConnMap.get(foxConnRecords.Unit_Serial_Number__c).add(foxConnRecords);
               } else {
                   List<FoxConnFactoryUCData__c> itemList = new List<FoxConnFactoryUCData__c>{foxConnRecords};
                       assetWithFoxConnMap.put(foxConnRecords.Unit_Serial_Number__c, itemList);
               }
               
               if(!uberWithFoxConnMap.containsKey(foxConnRecords.Unit_Serial_Number__c)){
                   uberWithFoxConnMap.put(foxConnRecords.Unit_Serial_Number__c, foxConnRecords);
               }
           }
        
        system.debug('uberWithFoxConnMap : ' + uberWithFoxConnMap);
        system.debug('uberWithFoxConnMap Size : ' + uberWithFoxConnMap.size());
        
        upsertComponentList = new list<Component__c>();
        updateFoxConnRecList = new list<FoxConnFactoryUCData__c>();
        
        // Loop the incoming asset records
        for(string allAssets : assetWithFoxConnMap.keySet()){
            successCount = 0;
            errorCount = 0;
            System.debug('allAssets : '+allAssets);
            
            id assetId = assetMap.get(allAssets).id;
            // Loops all FoxConn Records of each asset
            for(FoxConnFactoryUCData__c foxConnFactoryRec : assetWithFoxConnMap.get(allAssets)){ 
                System.debug('foxConnFactory : '+ foxConnFactoryRec.Name);
                string childPN = foxConnFactoryRec.Child_PN__c;
                string ChildSN = foxConnFactoryRec.Child_SN__c;
                
                system.debug('ChildSN : ' + ChildSN);
                system.debug('asstWithCompSN.get(allAssets) : ' + asstWithCompSN.get(allAssets));
                
                
                Boolean existingComponentFound = ( asstWithCompSN.containsKey(allAssets) && asstWithCompSN.get(allAssets) != null ? (asstWithCompSN.get(allAssets).contains(ChildSN) ? true : false) : false);
                system.debug('existingComponentFound : ' + existingComponentFound);
                // Added by Exafort for TS-10398
                // Checks if the Component with SN already already found on the Asset [existingComponentFound return false if existing component found]
                // If existing component record found enters into the if condition, if no existing component record found enter into the else condition
                if(!existingComponentFound){
                    populateComponent(eachModelwithSRMap,childPN,foxConnFactoryRec,assetMap,srcomponentTypeConversionMap,allAssets,null);
                }
                else{
                    Id compId = assetWithCompId.get(allAssets).get(ChildSN);
                    if(compId != null){
                        populateComponent(eachModelwithSRMap,childPN,foxConnFactoryRec,assetMap,srcomponentTypeConversionMap,allAssets,compId);
                    }
                    System.debug('Duplicate component found : '+ assetWithCompId.get(allAssets).get(ChildSN));
                }
                // End of TS-10398
                system.debug('successCount :'+successCount);
            }
            
            getAssetIdWithStatus(assetId,successCount,errorCount);
        }
        
        list<Asset> updateAssetList = new list<Asset>();
        for(Asset assetRecList : [Select id,name, accountId, assetComponentCreatedStatus__c from asset where name =: assetList]){
            if(uberWithFoxConnMap.containskey(assetRecList.Name)){
                system.debug('Component Status : ' + assetRecList.assetComponentCreatedStatus__c);
                // Success - if all foxconn matches with the given SR MetaData
                if(assetIdWithStatusMessage.get(assetRecList.id) == 'Success'){
                    assetRecList.assetComponentCreatedStatus__c = 'Success';
                    assetRecList.assetComponentProcessedMessage__c = null;
                }
                // Error - if no foxconn matches with the given SR MetaData
                else if(assetRecList.assetComponentCreatedStatus__c != 'Partial Success' && assetIdWithStatusMessage.get(assetRecList.id) == 'Error'){
                    assetRecList.assetComponentCreatedStatus__c = 'Error';
                    assetRecList.assetComponentProcessedMessage__c = 'No Match found for the given FoxConn records';
                }
                // Partial Success - Only few foxconnmatches with the given SR MetaData
                else{
                    assetRecList.assetComponentCreatedStatus__c = 'Partial Success';
                    assetRecList.assetComponentProcessedMessage__c = 'Only few matches found for the given FoxConn records';
                }
                
                updateAssetList.add(assetRecList);
            }
        }
        
        // Update Asset Record 
        if(updateAssetList.size() > 0){
            update updateAssetList;
        }
        // Upsert Component record
        if(upsertComponentList.size() > 0){
            upsert upsertComponentList;
        }
        
        // Update FoxConn Processed Mesage
        if(updateFoxConnRecList.size() > 0){
            update updateFoxConnRecList;
        }
    }
    
    // Check the status of component creation
    public void  getAssetIdWithStatus(Id assetId,Integer successCount,Integer errorCount){
        
        if(successCount > 0 && errorCount == 0){
            assetIdWithStatusMessage.put(assetId,'Success');
        }
        else if(errorCount > 0 && successCount == 0){
            assetIdWithStatusMessage.put(assetId,'Error');
        }
        else{
            assetIdWithStatusMessage.put(assetId,'Partial Success');
        }
        
    }
    
    // Get the SR MetaData values and store on the map
    public void getSrMetadata(){
        //for(SR_Meta_Data__c srMetaData : [Select srPart__c,srShippingProvider__c,srType__c,srDescription__c,srModelNumbers__c from SR_Meta_Data__c where srModelNumbers__c != null])
        for(SR_Meta_Data__c srMetaData : [Select srPart__c,srShippingProvider__c,srType__c,srDescription__c,srModelNumbers__c from SR_Meta_Data__c])   
        {
            // srMetaData.srModelNumbers__c != null Added by Exafort for SFDC-508
            if(srMetaData.srModelNumbers__c != null){
                srcomponentTypeConversionMap.put(srMetaData.srPart__c, srMetaData);
                list<string> srModelNumber =  srMetaData.srModelNumbers__c.split(',');
                for(string eachModelNumber : srModelNumber){
                    // Store values on map to get the model number
                    eachModelwithSRMap.put(eachModelNumber,new list<SR_Meta_Data__c> {srMetaData});
                }
            }
        }
    }
    
    // Added by Exafort for TS-10398
    public void populateComponent(Map<string, list<SR_Meta_Data__c>> eachModelwithSRMap,string childPN,FoxConnFactoryUCData__c foxConnFactoryRec,Map<string,Asset> assetMap,Map<string, 
                                  SR_Meta_Data__c> srcomponentTypeConversionMap,string allAssets,id CompId)
    {
        if(eachModelwithSRMap.get(childPN.replace('NMB-', '')) != null) { 
            
            system.debug('Found child pn on PBOM where used : ' + childPN);
            FoxConnFactoryUCData__c foxConnSuccessUpdate = new FoxConnFactoryUCData__c();
            foxConnSuccessUpdate.Id = foxConnFactoryRec.Id;
            foxConnSuccessUpdate.FoxConn_Proccessed__c = 'Success';
            foxConnSuccessUpdate.FoxConn_Processed_Message__c = null;
            updateFoxConnRecList.add(foxConnSuccessUpdate);
            
            // count of foxconn record that match with sr Metadata
            successCount = successCount + 1;
            system.debug('populateComponent successCount=>'+successCount);
            for(SR_Meta_Data__c srMetaDataRecord : eachModelwithSRMap.get(childPN.replace('NMB-', ''))){
                
                // Checks if the component created from ArcusBatch have the same service Part Number
                // If same service part number not found it inserts an new component record from the FoxConnFactoryUCData
                
                Component__c component = new Component__c();
                if(CompId != null){
                    component.id = CompId;
                    System.debug('CompId ==>'+CompId);
                }
                component.componentAccountId__c = assetMap.get(allAssets).accountId;
                component.componentAsset__c = assetMap.get(allAssets).id;
                component.componentServicePartNumber__c = srMetaDataRecord.srPart__c;
                component.componentComponentSN__c = foxConnFactoryRec.Child_SN__c;
                if(CompId == null){
                    component.ComponentCreatedFromInformation__c = 'Added from FoxConnFactoryUCData (SFDC)';
                }
                component.componentState__c = 'Shipped';
                component.Sub_State__c = 'Unknown';
                component.componentProcessedByFLEX__c = true;
                if(srcomponentTypeConversionMap.containsKey(srMetaDataRecord.srPart__c)){
                    system.debug('Component Type : ' + srcomponentTypeConversionMap.get(srMetaDataRecord.srPart__c).srType__c);
                    component.componentType__c = srcomponentTypeConversionMap.get(srMetaDataRecord.srPart__c).srType__c;
                    component.componentDescription__c = srcomponentTypeConversionMap.get(srMetaDataRecord.srPart__c).srDescription__c;
                }
                upsertComponentList.add(component);
                
            }                        
            
            
        } 
        // Else update the error message in FoxConn record PLM WhereUsed not found
        else{
            
            // count of foxconn record that doesnot match with sr Metadata
            errorCount = errorCount + 1;
            
            FoxConnFactoryUCData__c foxConnErrorUpdate = new FoxConnFactoryUCData__c();
            foxConnErrorUpdate.Id = foxConnFactoryRec.Id;
            foxConnErrorUpdate.FoxConn_Proccessed__c = 'Error';
            foxConnErrorUpdate.FoxConn_Processed_Message__c = childPN + ' Not found';
            updateFoxConnRecList.add(foxConnErrorUpdate);
        }
    }
    // End of TS-10398
}