public class generateComponentSNCatchUpProcess {
    
    //###################################################################################################### generateComponentSNFromShipmentFlexFlow
    public generateComponentSNCatchUpProcess()
    {
        
    }
    //###################################################################################################### getComponentMapByAssetName
    public Map<String,List<Component__c>> getComponentMapByAssetName(Set<String> assetName)
    {
        Map<String,List<Component__c>> componentMap = new Map<String,List<Component__c>>();
        
        for(Component__c component: [Select Id,componentDiskModel__c,componentState__c,Sub_State__c,componentAsset__c,componentTransaction__c,componentLocation__c,componentAssetStatus__c,componentServicePartNumber__c,componentAssetName__c,componentComponentSN__c,componentType__c,componentItem__c,ComponentCreatedFromInformation__c, componentStatus__c from Component__c where componentAssetName__c IN: assetName AND ComponentCreatedFromInformation__c = 'Added from BOM Items' AND componentStatus__c = 'Shipped-Unknown'])
        {
            List<Component__c> lstCurrentComponent = new List<Component__c>();
            lstCurrentComponent.add(component);
            
            if(componentMap.containsKey(component.componentAssetName__c))
            {
                List<Component__c> lstExistingComponent = componentMap.get(component.componentAssetName__c);
                lstExistingComponent.add(component);
                componentMap.put(component.componentAssetName__c,lstExistingComponent);
            }
            else
            {
                componentMap.put(component.componentAssetName__c,lstCurrentComponent);               
            }
            
        }
        
        return componentMap;
    }
    
    
    //###################################################################################################### getShipmentFlexFlowMap
    public Map<String,List<Shipment_Flexflow__c>>  getShipmentFlexFlowMap(Set<String> sAssetNames)
    {
        
        Map<String,List<Shipment_Flexflow__c>> shipmentFlexFlowMap = new  Map<String,List<Shipment_Flexflow__c>>();
        
        for(Shipment_Flexflow__c shipmentFlexFlow: [Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c, shipmentFlexflowChildLotNumber__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c  IN: sAssetNames AND shipmentFlexflowFlexProcessed__c = null  ORDER BY shipmentFlexflowUnitSerialNumber__c])
        {
            List<Shipment_Flexflow__c> lstCurrentShipmentFlexFlow = new List<Shipment_Flexflow__c>();
            lstCurrentShipmentFlexFlow.add(shipmentFlexFlow);
            
            if(shipmentFlexFlowMap.containsKey(shipmentFlexFlow.shipmentFlexflowUnitSerialNumber__c))
            {
                List<Shipment_Flexflow__c> lstExistingShipmentFlexFlow = shipmentFlexFlowMap.get(shipmentFlexFlow.shipmentFlexflowUnitSerialNumber__c);
                lstExistingShipmentFlexFlow.add(shipmentFlexFlow);
                shipmentFlexFlowMap.put(shipmentFlexFlow.shipmentFlexflowUnitSerialNumber__c,lstExistingShipmentFlexFlow);
            }
            else
            {
                shipmentFlexFlowMap.put(shipmentFlexFlow.shipmentFlexflowUnitSerialNumber__c,lstCurrentShipmentFlexFlow);               
            } 
        }
        
        return shipmentFlexFlowMap;
    }
    //###################################################################################################### ShipmentFlexFlowWrapper
    public Class ShipmentFlexFlowWrapper
    {
        public String srPart;
        public String srLocation;
        public String srItem;
        public Boolean matchingComponentFound;
        public Shipment_Flexflow__c shipmentFlexFlowLine;
        
        public ShipmentFlexFlowWrapper(Shipment_Flexflow__c shipmentFlexFlowData,String srPartProcessed,String srPartLocation,String srChildItem)
        {
            srPart = srPartProcessed;
            srLocation = srPartLocation;
            srItem = srChildItem;
            matchingComponentFound = false;
            shipmentFlexFlowLine = shipmentFlexFlowData;
            
        }
        
    }
    //###################################################################################################### getChildPnFromFlexFlowToQueryArenaWhereUsedObject
    public Map<String,String> queryArenaWhereUsedObjectUsingChildPn(List<Shipment_Flexflow__c> assetShipmentFlexFlowDatas,ArenaPLMCallouts arenaPLMCallouts,Map<String,String> arenaWhereUsedItemMapCache, List<Asset> assetErrorResponse)
    {
        Set<String> childPnFromFlexFlow = new Set<String>();
        
        if(assetShipmentFlexFlowDatas.size() > 0)
        {
            for(Shipment_Flexflow__c assetShipmentFlexFlowData: assetShipmentFlexFlowDatas){
                if(assetShipmentFlexFlowData.shipmentFlexflowChildPn__c.contains('NMB-'))
                {
                    string nimbleChildPn = assetShipmentFlexFlowData.shipmentFlexflowChildPn__c.replace('NMB-','');
                    childPnFromFlexFlow.add(nimbleChildPn);
                }
                
            }
        }
        
        for(string itemNumberToProcess : childPnFromFlexFlow)
        {
            if(!arenaWhereUsedItemMapCache.containsKey(itemNumberToProcess))  
            {
                System.debug('+++++++++itemNumberToProcess+++++++++++++++' + itemNumberToProcess);
                Map<String,String> arenaProcessedSrPartMap = arenaPLMCallouts.getWhereUsedItemFromArena(itemNumberToProcess, assetErrorResponse);
                if(arenaProcessedSrPartMap.size() > 0)
                    arenaWhereUsedItemMapCache.putAll(arenaProcessedSrPartMap);
            }
        }
        
        return arenaWhereUsedItemMapCache;
        
    }
    //###################################################################################################### processShipmentFlewFlowData
    public List<ShipmentFlexFlowWrapper> processShipmentFlewFlowData(List<Shipment_Flexflow__c> assetShipmentFlexFlowDatas,List<Component__c> componetsToInsert,Map<String,String> arenaWhereUsedItemMap)
    {
        List<ShipmentFlexFlowWrapper> processedShipmentFlexFlowList = new List<ShipmentFlexFlowWrapper>();
        Set<string> rmaInvolvedAssets = new Set<string>();
        set<string> caseInvolvedAssets = new set<string>();
        List<RMAv2__c> rmaAssets = [Select rmaDiskShelfAsset__c, rmaDiskShelfAsset__r.Name, rmaDiskShelfAsset__r.Status, rmaCaseNumber__r.AssetId, rmaCaseNumber__r.Asset.Name, rmaCaseNumber__r.Asset.Status from RMAv2__c];
        for(RMAv2__c rmas: rmaAssets)
        {
            if(rmas.rmaDiskShelfAsset__r.Status == 'Shipped'){
                rmaInvolvedAssets.add(rmas.rmaDiskShelfAsset__r.Name);
            } 
            if(rmas.rmaCaseNumber__r.Asset.Status == 'Shipped'){
                caseInvolvedAssets.add(rmas.rmaCaseNumber__r.Asset.Name);
            }                     
        }
        system.debug('**** case Involved asset ****'+caseInvolvedAssets);
        
        for(Shipment_Flexflow__c assetShipmentFlexFlowData: assetShipmentFlexFlowDatas){
            
            String srPart=null;
            String srLocation=null;
            String srItem=null;
            assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c = 'Success';
            assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = null; 
            
            System.debug('+++++++ Child PN from Flex Flow ++++++' + assetShipmentFlexFlowData.shipmentFlexflowChildPn__c);
            
            if(!rmaInvolvedAssets.contains(assetShipmentFlexFlowData.shipmentFlexflowUnitSerialNumber__c)){
                if(!caseInvolvedAssets.contains(assetShipmentFlexFlowData.shipmentFlexflowUnitSerialNumber__c)){
                    
                    /*if(componetsToInsert.size() == 0){
assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = 'No components found for the Asset';
system.debug('**** (IF conditon if components is 0)updated with message*****');
}*/
                    if(assetShipmentFlexFlowData.shipmentFlexflowItem__c.contains('SR-'))
                    {
                        System.debug('+++++++ Shipment Flex Flow Item Contains (SR-) ++++++');
                        if(assetShipmentFlexFlowData.shipmentFlexflowItem__c.StartsWith('NMB-'))
                        {
                            srPart = assetShipmentFlexFlowData.shipmentFlexflowItem__c.replace('NMB-','');
                            srItem = 'NMB-';
                            System.debug('+++++++ Replace Flex Flow Item With NMB-, then Current Part is ++++++' + srPart);
                        }
                        else if(assetShipmentFlexFlowData.shipmentFlexflowItem__c.StartsWith('NMBR-'))
                        {
                            srPart = assetShipmentFlexFlowData.shipmentFlexflowItem__c.replace('NMBR-','');
                            srItem = 'NMBR-';
                            System.debug('+++++++ Replace Flex Flow Item With NMBR-, then Current Part is ++++++' + srPart);
                        }
                        else
                        {
                            assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c = 'Error';
                            assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = 'Item with SR- found but Item does not contain NMB- or NMBR- Keywords';
                        }
                    }
                    else if(assetShipmentFlexFlowData.shipmentFlexflowChildPn__c.StartsWith('NMB-'))
                    {
                        if(assetShipmentFlexFlowData.shipmentFlexflowChildSn__c != null)
                        {
                            
                            System.debug('+++++++ Replace Flex Flow Child Part Number Contains (NMB-) ++++++++++');
                            string nimbleChildPn = assetShipmentFlexFlowData.shipmentFlexflowChildPn__c.replace('NMB-','');
                            System.debug('+++++++ nimbleChildPn ++++++++++' + nimbleChildPn);
                            string arenaWhereUsedResults = arenaWhereUsedItemMap.get(nimbleChildPn);
                            System.debug('+++++++ SR After Looking in Arena ++++++++++' + srPart);
                            
                            if(arenaWhereUsedResults != null)
                            {
                                if(arenaWhereUsedResults.contains('Does not Exist'))
                                {
                                    assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c = 'Error';
                                    assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = nimbleChildPn + ' does not have SR- part in Arena Where Used Object';
                                }
                                else
                                {
                                    srPart = arenaWhereUsedResults;  
                                    srItem = 'NMB-';
                                }
                                
                            }
                            else
                            {
                                assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c = 'Server Error';
                                assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = 'Server Error Occured in Arena Where Used Object';
                            }
                            
                        }
                    }
                    else
                    {
                        if(assetShipmentFlexFlowData.shipmentFlexflowChildPn__c == 'Power Supply')
                        {
                            //**************Added condition for new part under power supply SR-PWR-1200W-R2 using unique child lot number***************/
                            if(assetShipmentFlexFlowData.shipmentFlexflowChildLotNumber__c == 'PWS-1K21P-1R')
                            {
                                System.debug('+++++++ Flex Flow child Part with child lot number PWS-1K21P-1R' + assetShipmentFlexFlowData.shipmentFlexflowChildLotNumber__c);
                                srPart = 'SR-PWR-1200W';                        
                            }
                            else if(assetShipmentFlexFlowData.shipmentFlexflowChildLotNumber__c == 'PWS-1K23A-1R')
                            {
                                System.debug('+++++++ Flex Flow child Part with child lot number ' + assetShipmentFlexFlowData.shipmentFlexflowChildLotNumber__c);
                                srPart = 'SR-PWR-1200W-R2';                       
                            }
                            else 
                            {
                                assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c = 'Error';
                                assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = 'Algorithm for Power Supply does not found for the Child Lot Number ' + assetShipmentFlexFlowData.shipmentFlexflowChildLotNumber__c;
                            }
                            
                            srLocation = 'unknown';
                        }
                        else if(assetShipmentFlexFlowData.shipmentFlexflowChildPn__c == '207-0001-001')
                        {
                            System.debug('+++++++ Flex Flow child Part is ' + assetShipmentFlexFlowData.shipmentFlexflowChildPn__c);
                            srPart = 'SR-PWR-1200W';
                            srLocation = 'unknown';
                        }
                        else if(assetShipmentFlexFlowData.shipmentFlexflowChildPn__c == '207-0003-001')
                        {
                            System.debug('+++++++ Flex Flow child Part is ' + assetShipmentFlexFlowData.shipmentFlexflowChildPn__c);
                            srPart = 'SR-PWR-1200W-R2';
                            srLocation = 'unknown';
                        }
                        else if(assetShipmentFlexFlowData.shipmentFlexflowChildPn__c == 'LEFT PSU')
                        {
                            System.debug('+++++++ Flex Flow child Part is LEFT PSU +++++++++++');
                            srPart = 'SR-PWR-1200W';
                            srLocation = 'left side';
                        }
                        else if(assetShipmentFlexFlowData.shipmentFlexflowChildPn__c == 'RIGHT PSU')
                        {
                            System.debug('+++++++ Flex Flow child Part is RIGHT PSU +++++++++++');
                            srPart = 'SR-PWR-1200W';
                            srLocation = 'right side';
                        }
                        else if(assetShipmentFlexFlowData.shipmentFlexflowChildPn__c == 'Controller  Vendor S/N' || assetShipmentFlexFlowData.shipmentFlexflowChildPn__c == 'Controller Vendor S/N')
                        {
                            System.debug('+++++++ Flex Flow child Part is Controller  Vendor S/N +++++++++++');
                            for(Component__c component: componetsToInsert){
                                if(component.componentServicePartNumber__c != null)
                                {
                                    if(component.componentServicePartNumber__c.StartsWith('SR-CONT'))
                                    {
                                        System.debug('+++++++ SR-CONT Part Found in Component ++++++');
                                        srPart = component.componentServicePartNumber__c;
                                        break;
                                    }
                                }
                            }
                            
                            if(srPart == null)
                            {
                                assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c = 'Error';
                                assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = 'Part Number starting with SR-CONT not found in Component';
                            }
                        }
                        else
                        {
                            assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c = 'Error';
                            assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = 'Algorithm does not have information to handle Child part number ' + assetShipmentFlexFlowData.shipmentFlexflowChildPn__c;
                        }
                    }
                }
                system.debug('*****shipment flex flow unit serial number*****'+assetShipmentFlexFlowData.shipmentFlexflowUnitSerialNumber__c);
                if(assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c == 'Success' && caseInvolvedAssets.contains(assetShipmentFlexFlowData.shipmentFlexflowUnitSerialNumber__c)){
                    assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = 'Asset Involved in Case, so no update';
                }
            }
            //Error message if RMA exists for Asset
            system.debug('*****shipment flex flow unit serial number*****'+assetShipmentFlexFlowData.shipmentFlexflowUnitSerialNumber__c);
            if(assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c == 'Success' && rmaInvolvedAssets.contains(assetShipmentFlexFlowData.shipmentFlexflowUnitSerialNumber__c)){
                assetShipmentFlexFlowData.shipmentFlexflowProcessedMessage__c = 'RMA exists for the Asset, so no update';
            }    
            
            if(srPart != null && assetShipmentFlexFlowData.shipmentFlexflowFlexProcessed__c == 'Success')
            {               
                ShipmentFlexFlowWrapper shipmentFlexFlowWrapper = new ShipmentFlexFlowWrapper(assetShipmentFlexFlowData,srPart,srLocation,srItem);
                processedShipmentFlexFlowList.add(shipmentFlexFlowWrapper);
            }
        }
        
        
        System.debug('+++++++ processedShipmentFlexFlowList ++++++' + processedShipmentFlexFlowList);       
        update assetShipmentFlexFlowDatas;
        return processedShipmentFlexFlowList;
    }
    
    //###################################################################################################### assignSerialNumberToComponents
    public List<Component__c>  assignSerialNumberToComponents(List<ShipmentFlexFlowWrapper> processedShipmentFlexFlowList,List<Component__c> componentsToInsert,Asset assetsToProcess, set<id> rmaInvolvedAssets, set<Id> caseInvolvedAssets)
    {        
        set<string> exclueTypes = new set<string>{'HDD','SSD','Controller'};//if auto support is received for asset then don't update these types
            List<Shipment_Flexflow__c> updateWithNoMatchMessage = new List<Shipment_Flexflow__c>();  
        List<Shipment_Flexflow__c> parentAssetContainsRMA = new List<Shipment_Flexflow__c>();
        List<Shipment_Flexflow__c> getUnMatched = new List<Shipment_Flexflow__c>(); //to add unmatched shipment line and display message
        List<Shipment_Flexflow__c> getDuplicateSN = new List<Shipment_Flexflow__c>();//to add flex flows serial numbers that is already present in component serial numbers 
        List<Shipment_Flexflow__c> getComponentType = new List<Shipment_Flexflow__c>();
        List<Shipment_Flexflow__c> getComponentType1 = new List<Shipment_Flexflow__c>();
        List<Shipment_Flexflow__c> caseAsset = new List<Shipment_Flexflow__c>();
        for(ShipmentFlexFlowWrapper ShipmentFlexFlowData: processedShipmentFlexFlowList)
        {      
            system.debug('***** asset name (assetsToProcess.Name)****'+assetsToProcess.Name);               
            if(!rmaInvolvedAssets.contains(assetsToProcess.Id)){  
                if(!rmaInvolvedAssets.contains(assetsToProcess.Parent_Asset__c)){
                    
                    if(!caseInvolvedAssets.contains(assetsToProcess.Id)){
                        system.debug('***** asset name (assetsToProcess.Name)****'+assetsToProcess.Name);               
                        system.debug('***** asset name (assetsToProcess.ID)****'+assetsToProcess.id);               
                        if(ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowFlexProcessed__c == 'Success' && ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowChildSn__c != null)
                        {           
                            String srPart = ShipmentFlexFlowData.srPart;
                            
                            System.debug('++++++++++ SR Part From Flex Flow ++++++++++' + srPart);
                            
                            for(Component__c component:componentsToInsert)
                            {
                                System.debug('++++++++++  Component Part Number in Component ++++++++++ ' + component.componentServicePartNumber__c);                     
                                
                                if(assetsToProcess.Autosupport_Last_Received__c != null || assetsToProcess.Parent_Asset__r.Autosupport_Last_Received__c != null){                           
                                    if(ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowChildSn__c == component.componentComponentSN__c)
                                    {
                                        //component = setComponentFieldsWhenNull(component,ShipmentFlexFlowData,srPart);
                                        ShipmentFlexFlowData.matchingComponentFound = true;
                                        ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowProcessedMessage__c = 'Duplicate data, serial number already found';
                                        getDuplicateSN.add(ShipmentFlexFlowData.shipmentFlexFlowLine);
                                        /*for(Shipment_Flexflow__c shipmentDuplicateSN : getDuplicateSN){
shipmentDuplicateSN.shipmentFlexflowProcessedMessage__c = 'Duplicate data, serial number already found';
}*/
                                        break;
                                    }
                                    else if(srPart.startsWith('SR-CONT') && component.componentServicePartNumber__c.startsWith('SR-CONT') && component.componentComponentSN__c == null && !exclueTypes.contains(component.componentType__c))
                                    {
                                        //System.debug('++++++++++  Match Found for Flex Flow Part : ' + srPart + ' ++++++++++  with Component Part Number ' + component.componentServicePartNumber__c);                           
                                        ShipmentFlexFlowData.matchingComponentFound = true;                                              
                                        component = setComponentFieldsWhenNull(component,ShipmentFlexFlowData,srPart);                            
                                        break;
                                    }
                                    else if(component.componentServicePartNumber__c == srPart && component.componentComponentSN__c == null && !exclueTypes.contains(component.componentType__c))
                                    {                                 
                                        //System.debug('++++++++++  Match Found for Flex Flow Part : ' + srPart + ' ++++++++++  with Component Part Number ' + component.componentServicePartNumber__c);
                                        ShipmentFlexFlowData.matchingComponentFound = true;                                       
                                        component = setComponentFieldsWhenNull(component,ShipmentFlexFlowData,srPart);                                     
                                        break;
                                    } 
                                    //If Asup is received and component type is HDD/SSD/Controller then update the flex processed message
                                    else if(srPart.startsWith('SR-CONT') && component.componentServicePartNumber__c.startsWith('SR-CONT') && component.componentComponentSN__c == null){
                                        ShipmentFlexFlowData.matchingComponentFound = true;
                                        if(exclueTypes.contains(component.componentType__c)){
                                            ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowProcessedMessage__c ='ASUP found for Asset with component type '+component.componentType__c+', so no update';
                                            getComponentType.add(ShipmentFlexFlowData.shipmentFlexFlowLine);
                                        }                                   
                                        break;
                                    }
                                    else if(component.componentServicePartNumber__c == srPart && component.componentComponentSN__c == null){
                                        ShipmentFlexFlowData.matchingComponentFound = true;
                                        if(exclueTypes.contains(component.componentType__c)){
                                            ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowProcessedMessage__c ='ASUP found for Asset with component type '+component.componentType__c+', so no update';
                                            getComponentType1.add(ShipmentFlexFlowData.shipmentFlexFlowLine);
                                        }                                                                       
                                        break;
                                    }
                                }
                                else if(assetsToProcess.Autosupport_Last_Received__c == null && (assetsToProcess.Parent_Asset__r == null || assetsToProcess.Parent_Asset__r.Autosupport_Last_Received__c == null)){
                                    
                                    if(ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowChildSn__c == component.componentComponentSN__c)
                                    {
                                        //component = setComponentFieldsWhenNull(component,ShipmentFlexFlowData,srPart);
                                        ShipmentFlexFlowData.matchingComponentFound = true;
                                        ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowProcessedMessage__c = 'Duplicate data, serial number already found';
                                        getDuplicateSN.add(ShipmentFlexFlowData.shipmentFlexFlowLine);
                                        /*for(Shipment_Flexflow__c shipmentDuplicateSN : getDuplicateSN){
shipmentDuplicateSN.shipmentFlexflowProcessedMessage__c = 'Duplicate data, serial number already found';
}*/
                                        break;
                                    }
                                    else if(srPart.startsWith('SR-CONT') && component.componentServicePartNumber__c.startsWith('SR-CONT') && component.componentComponentSN__c == null) 
                                    {
                                        System.debug('++++++++++  Match Found for Flex Flow Part : ' + srPart + ' ++++++++++  with Component Part Number ' + component.componentServicePartNumber__c);                           
                                        ShipmentFlexFlowData.matchingComponentFound = true;                                              
                                        component = setComponentFieldsWhenNull(component,ShipmentFlexFlowData,srPart);                            
                                        break;
                                    }
                                    else if(component.componentServicePartNumber__c == srPart && component.componentComponentSN__c == null)
                                    {
                                        System.debug('++++++++++  Match Found for Flex Flow Part : ' + srPart + ' ++++++++++  with Component Part Number ' + component.componentServicePartNumber__c);
                                        ShipmentFlexFlowData.matchingComponentFound = true; 
                                        component = setComponentFieldsWhenNull(component,ShipmentFlexFlowData,srPart); 
                                        break;
                                    } 
                                }                                                
                            }                  
                            //System.debug('++++++++++ Matching component Found? ++++++++++ ' +  ShipmentFlexFlowData.matchingComponentFound);
                            
                            if(ShipmentFlexFlowData.matchingComponentFound == false)
                            {
                                ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowProcessedMessage__c = 'No Matching Component found for the Asset with empty serial number, so no update';
                                getUnMatched.add(ShipmentFlexFlowData.shipmentFlexFlowLine);
                                //for(Shipment_Flexflow__c notfound : getUnMatched){
                                //system.debug('****shipment flex line****'+notfound);
                                //if(assetsToProcess.Autosupport_Last_Received__c == null && (assetsToProcess.Parent_Asset__r == null || assetsToProcess.Parent_Asset__r.Autosupport_Last_Received__c == null)){
                                //notfound.shipmentFlexflowProcessedMessage__c = 'No Matching Component found for the Asset with empty serial number, so no update';
                                //}else{
                                //notfound.shipmentFlexflowProcessedMessage__c = 'ASUP found for Asset, so no update';
                                //}
                                // updateWithNoMatchMessage.add(notfound);                            
                                //}                                                                      
                            }
                        }
                    }
                    else if(caseInvolvedAssets.contains(assetsToProcess.Id)){
                        ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowProcessedMessage__c = 'Asset Involved in Case, so no update';
                        caseAsset.add(ShipmentFlexFlowData.shipmentFlexFlowLine);
                    }
                }
                else if(rmaInvolvedAssets.contains(assetsToProcess.Parent_Asset__c)){
                    parentAssetContainsRMA.add(ShipmentFlexFlowData.shipmentFlexFlowLine);
                    for(Shipment_Flexflow__c parentAssetRMA : parentAssetContainsRMA){
                        parentAssetRMA.shipmentFlexflowProcessedMessage__c = 'RMA exists for Parent Asset, so no update';
                    }
                }
            }
            else if(rmaInvolvedAssets.contains(assetsToProcess.Id)){ 
                //system.debug('**** asset contains RMA *** '+assetsToProcess.Name);
                break;
            }            
        }
        if(getUnMatched.size() > 0){
            update getUnMatched;
        }        
        if(getDuplicateSN.size() > 0){
            update getDuplicateSN;
        }        
        if(getComponentType.size() > 0){
            update getComponentType;
        }     
        if(getComponentType1.size() > 0){
            update getComponentType1;
        } 
        if(parentAssetContainsRMA.size() > 0){
            update parentAssetContainsRMA;
        }        
        if(caseAsset.size() > 0){
            update caseAsset;
        }
        return componentsToInsert;
    }
    
    public Component__c setComponentFieldsWhenNull(Component__c component,ShipmentFlexFlowWrapper ShipmentFlexFlowData,string srPart)
    {
        if(component.componentServicePartNumber__c == null)
        {
            component.componentServicePartNumber__c = srPart;
        }
        
        if(component.componentComponentSN__c == null)
        {
            component.componentComponentSN__c = ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowChildSn__c;
        }
        
        if(component.componentLocation__c == null)
        {
            component.componentLocation__c = ShipmentFlexFlowData.srLocation;
        }
        
        if(component.componentItem__c == null)
        {
            component.componentItem__c = ShipmentFlexFlowData.srItem;
        }
        
        if(component.componentTransaction__c == null)
        {
            component.componentTransaction__c = ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowReferenceA__c;
        }
        
        if(AssetComponentPopulationFromArena.srcomponentTypeConversionMap.containsKey(srPart))
        {
            if(component.componentType__c == null)
            {
                component.componentType__c = AssetComponentPopulationFromArena.srcomponentTypeConversionMap.get(srPart).srType__c;
            }
            
            if(component.componentDescription__c == null)
            {
                component.componentDescription__c = AssetComponentPopulationFromArena.srcomponentTypeConversionMap.get(srPart).srDescription__c;
            }
            
            /*if(component.componentDiskModel__c == null)
{
component.componentDiskModel__c = AssetComponentPopulationFromArena.srcomponentTypeConversionMap.get(srPart).srModelNumbers__c;
}*/
        }
        
        component.componentProcessedByFLEX__c = true;
        
        return component;
    }
    
    
}