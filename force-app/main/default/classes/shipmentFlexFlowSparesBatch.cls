global class shipmentFlexFlowSparesBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    
    global final String Query;
    global Integer batchProcessedCount = 0; //Indicator for current record in progress
    global String batchArenaSessionId; //Arena PLM Login Session Id
    
    //To overcome the limitation in Arena PLM Rest API and to Reduce the callout to ArenaPLM, Memory caching used with the map. It acts the memory collection, if the Item number exist in Memory collection, it make of it else query the Arena PLM using Rest API   
    global Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByGuidMapCache = new Map<String,ArenaPLMItemObjectWrapper.Results>(); // Arena Item Object collection Cache
    global Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByNumberMapCache = new Map<String,ArenaPLMItemObjectWrapper.Results>(); // Arena Item Object collection Cache
    global Map<String,String> arenaWhereUsedItemMapCache = new Map<String,String>(); // Arena Where Used Object Collection Cache
    
    global shipmentFlexFlowSparesBatch(string q){
        Query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //return Database.getQueryLocator('Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c where (NOT shipmentFlexflowUnitSerialNumber__c LIKE \'%A%\') and shipmentFlexflowChildSn__c != null Limit 5000');
        //return Database.getQueryLocator('Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c where Id =\'a3je0000000CBZL\'');
        //return Database.getQueryLocator('Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c where shipmentFlexflowUnitSerialNumber__c=\'AF-108532\' or shipmentFlexflowUnitSerialNumber__c=\'AF-109474\'');
        //return Database.getQueryLocator('Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where (NOT shipmentFlexflowUnitSerialNumber__c LIKE \'%A%\') and shipmentFlexflowChildSn__c != null and  shipmentFlexflowReferenceA__c!=null');
        //return Database.getQueryLocator('Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where (NOT shipmentFlexflowUnitSerialNumber__c LIKE \'%A%\') and shipmentFlexflowChildSn__c != null and  shipmentFlexflowReferenceA__c!=null');
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Shipment_Flexflow__c>  shipmentFlexFlow)
    {
        
        //******Arena PLM Bulk**********
        //If a batch contains, 100 records, it is processed 1 by 1. 
        //For the 1st record (alone) in the set of 100, Connects to Arena PLM using Rest Call
        //Puts all the Item object record from Arena PLM to memory collection and make use of it from there on instead of quering all the time.
        
        ArenaPLMCallouts arenaCallouts= null;
        List<Asset> assetErrorRecord = new List<Asset>();
        if(!Test.isRunningTest())
        {
            
            arenaCallouts = new ArenaPLMCallouts(batchProcessedCount,arenaItemByGuidMapCache,arenaItemByNumberMapCache,batchArenaSessionId, assetErrorRecord);
            arenaItemByGuidMapCache = arenaCallouts.getArenaItemsByGuidMap();
            arenaItemByNumberMapCache = arenaCallouts.getArenaItemsByNumberMap();
            batchArenaSessionId = arenaCallouts.getArenaSessionId();
        }
        
        //****** Memory Collection Debug logs**********
        System.debug('++++++++++++++++arenaItemByGuidMapCache++++++++++++++++' + arenaItemByGuidMapCache.size());
        System.debug('++++++++++++++++arenaItemByNumberMapCache++++++++++++++++' + arenaItemByNumberMapCache.size());
        System.debug('++++++++++++++++batchArenaSessionId++++++++++++++++' + batchArenaSessionId);        
        System.debug('++++++++++++++++arenaWhereUsedItemMapCache+++++++++++++++++++++++++++++++++++++++' + arenaWhereUsedItemMapCache.size());
        System.debug('++++++++++++++++arenaWhereUsedItemMapCache Records+++++++++++++++++++++++++++++++++++++++' + arenaWhereUsedItemMapCache);
        
        //Flow 1
        List<Shipment_Flexflow__c> shipmentFlexFlowLinesToQueryWhereUsed = new List<Shipment_Flexflow__c>();        
        List<Shipment_Flexflow__c> shipmentFlexFlowSOToProcess= new List<Shipment_Flexflow__c>();
        Set<String> soNumbers = new Set<String>();
        Map<String,Sales_Order__c> soOppAccoundIdBySoNameMap = new Map<String,Sales_Order__c>();      
        Set<String> componentSerialNumbers = new Set<String>();
        Map<String,Component__c> existingComponentSNMap = new Map<String,Component__c>();  
       
        
        //Flow 2
        List<Shipment_Flexflow__c> shipmentFlexFlowAssetRecords = new List<Shipment_Flexflow__c>();
        Set<String> assetNames = new Set<String>();
        Map<String,Asset> assetMapByAssetName = new Map<String,Asset>();
        Map<String,List<Component__c>> componentMapByAssetName = new  Map<String,List<Component__c>>();
        
        for(Shipment_Flexflow__c shipmentFlexFlowLine: shipmentFlexFlow){ 
            
            if(shipmentFlexFlowLine.shipmentFlexflowUnitSerialNumber__c != null)
            {
                if(!shipmentFlexFlowLine.shipmentFlexflowUnitSerialNumber__c.startsWith('A'))
                {
                    //First Flow
                    shipmentFlexFlowSOToProcess.add(shipmentFlexFlowLine);
                    
                    if(shipmentFlexFlowLine.shipmentFlexflowReferenceA__c != null)
                    {
                        soNumbers.add(shipmentFlexFlowLine.shipmentFlexflowReferenceA__c);
                    }
                }
                else
                {
                    //Second Flow
                    shipmentFlexFlowAssetRecords.add(shipmentFlexFlowLine);
                    
                    if(shipmentFlexFlowLine.shipmentFlexflowUnitSerialNumber__c != null)
                    {
                        assetNames.add(shipmentFlexFlowLine.shipmentFlexflowUnitSerialNumber__c);
                    }
                }
                
                shipmentFlexFlowLinesToQueryWhereUsed.add(shipmentFlexFlowLine);
                
                if(shipmentFlexFlowLine.shipmentFlexflowChildSn__c != null)
                {
                    componentSerialNumbers.add(shipmentFlexFlowLine.shipmentFlexflowChildSn__c);
                }
            }
        }
        
        //Common
        GenerateComponentSNFromShipmentFlexFlow generateComponentSN = new GenerateComponentSNFromShipmentFlexFlow();
        Map<String,String> arenaProcessedSrPartMap = generateComponentSN.queryArenaWhereUsedObjectUsingChildPn(shipmentFlexFlowLinesToQueryWhereUsed,arenaCallouts,arenaWhereUsedItemMapCache, assetErrorRecord);
        if(arenaProcessedSrPartMap.size() > 0)
            arenaWhereUsedItemMapCache.putAll(arenaProcessedSrPartMap);
        System.debug('+++++++++++++++++arenaWhereUsedItemMapCache++++++++++++++++++' + arenaWhereUsedItemMapCache.size());
        System.debug('+++++++++++++++++arenaWhereUsedItemMapCache++++++++++++++++++' + arenaWhereUsedItemMapCache);
        System.debug('+++++++++++++++++componentSerialNumbers++++++++++++++++++' + componentSerialNumbers);
        
        //First Flow
        AssetComponentPopulationFromArena assetComponentPopulationArena = new AssetComponentPopulationFromArena();
        existingComponentSNMap = assetComponentPopulationArena.getExistingComponentSerialNumbers(componentSerialNumbers,existingComponentSNMap);
        System.debug('+++++++++++++++++existingComponentSNMap++++++++++++++++++' + existingComponentSNMap);
        System.debug('+++++++++++++++++existingComponentSNMap size++++++++++++++++++' + existingComponentSNMap.size());
        soOppAccoundIdBySoNameMap = getSORecords(soNumbers,soOppAccoundIdBySoNameMap);
        System.debug('+++++++++++++++++soOppAccoundIdBySoNameMap++++++++++++++++++' + soOppAccoundIdBySoNameMap);
        System.debug('+++++++++++++++++soOppAccoundIdBySoNameMap size++++++++++++++++++' + soOppAccoundIdBySoNameMap.size());
        
        List<Component__c> upsertComponentWithSerialNumber = new List<Component__c>();
        List<GenerateComponentSNFromShipmentFlexFlow.ShipmentFlexFlowWrapper> processedShipmentFlexFlowSoList = generateComponentSN.processShipmentFlewFlowData(shipmentFlexFlowSOToProcess,upsertComponentWithSerialNumber,arenaWhereUsedItemMapCache);
        System.debug('+++++++++++++++++processedShipmentFlexFlowSoList++++++++++++++++++' + processedShipmentFlexFlowSoList);
        System.debug('+++++++++++++++++processedShipmentFlexFlowSoList size++++++++++++++++++' + processedShipmentFlexFlowSoList.size());
        
        processSoFlexFlowLines(processedShipmentFlexFlowSoList,upsertComponentWithSerialNumber,soOppAccoundIdBySoNameMap,existingComponentSNMap,generateComponentSN);
        
        
        //Second Flow
        assetMapByAssetName = getAssetRecords(assetNames,assetMapByAssetName);
        System.debug('+++++++++++++++++assetMapByAssetName++++++++++++++++++' + assetMapByAssetName);
        System.debug('+++++++++++++++++assetMapByAssetName size++++++++++++++++++' + assetMapByAssetName.size());
        
        componentMapByAssetName = assetComponentPopulationArena.getComponentMapByAssetName(assetNames);
        System.debug('+++++++++++++++++componentMapByAssetName++++++++++++++++++' + componentMapByAssetName);
        System.debug('+++++++++++++++++componentMapByAssetName size++++++++++++++++++' + componentMapByAssetName.size());
        
        List<Component__c> upsertComponentsForAllAssets = new List<Component__c>();
        
        for(String assetName:assetNames)
        {
            System.debug('++++++++++ assetNames +++++++++++' + assetNames);
            System.debug('++++++++++ Processing assetName +++++++++++' + assetName);
            System.debug('++++++++++ shipmentFlexFlowAssetRecords +++++++++++' + shipmentFlexFlowAssetRecords);
            System.debug('++++++++++ shipmentFlexFlowAssetRecords+++++++++++' + shipmentFlexFlowAssetRecords.size());
            
            List<Component__c> componentsForAsset = new List<Component__c>();
            Asset assetToProcess = new Asset();
            List<GenerateComponentSNFromShipmentFlexFlow.ShipmentFlexFlowWrapper> processedShipmentFlexFlowAssetList = new List<GenerateComponentSNFromShipmentFlexFlow.ShipmentFlexFlowWrapper>();
            List<Shipment_Flexflow__c> shipmentFlexFlowAssetRecordLines = new List<Shipment_Flexflow__c>();
            
            for(Shipment_Flexflow__c shipmentFlexFlowAssetRecord: shipmentFlexFlowAssetRecords) 
            {
                if(shipmentFlexFlowAssetRecord.shipmentFlexflowUnitSerialNumber__c == assetName)
                {
                    shipmentFlexFlowAssetRecordLines.add(shipmentFlexFlowAssetRecord);
                }  
            }
            
            System.debug('+++++++++++++++++shipmentFlexFlowAssetRecordLines 1++++++++++++++++++' + shipmentFlexFlowAssetRecordLines);
            System.debug('+++++++++++++++++shipmentFlexFlowAssetRecordLines  1 size++++++++++++++++++' + shipmentFlexFlowAssetRecordLines.size());
            
            componentsForAsset = componentMapByAssetName.get(assetName);
            System.debug('+++++++++++++++++componentsForAsset++++++++++++++++++' + componentsForAsset);
            
            if(componentsForAsset == null)
            {
                componentsForAsset = new List<Component__c>();
            }

            assetToProcess = assetMapByAssetName.get(assetName);
            System.debug('+++++++++++++++++assetToProcess++++++++++++++++++' + assetToProcess);
            
            if(assetToProcess != null)
            {
                processedShipmentFlexFlowAssetList = generateComponentSN.processShipmentFlewFlowData(shipmentFlexFlowAssetRecordLines,componentsForAsset,arenaWhereUsedItemMapCache); 
                List<Component__c> upsertComponentsForAsset = generateComponentSN.assignSerialNumberToComponents(processedShipmentFlexFlowAssetList,componentsForAsset,assetToProcess);  
                System.debug('+++++++++++++++++upsertComponentsForAsset++++++++++++++++++' + upsertComponentsForAsset);
                
                upsertComponentsForAllAssets.addAll(upsertComponentsForAsset);
            }
            
            
        }
        
        upsert upsertComponentsForAllAssets;
        System.debug('+++++++++++++++++upsertComponentsForAllAssets++++++++++++++++++' + upsertComponentsForAllAssets.size());
        batchProcessedCount = batchProcessedCount + 1;
        
    }
    
    public Map<String,Sales_Order__c> getSORecords(Set<String> soNumbers, Map<String,Sales_Order__c> soOppAccoundIdBySoNameMap)
    {
        for(Sales_Order__c so: [Select SO_Number__c,Opportunity__c,Opportunity__r.Account.Id from Sales_Order__c where SO_Number__c IN:soNumbers])
        {
            if(so.SO_Number__c != null)
            {
            	soOppAccoundIdBySoNameMap.put(so.SO_Number__c,so);
            }
        }
        
        return soOppAccoundIdBySoNameMap;
    }
    
    public void processSoFlexFlowLines(List<GenerateComponentSNFromShipmentFlexFlow.ShipmentFlexFlowWrapper> processedShipmentFlexFlowSoList,List<Component__c> upsertComponentWithSerialNumber,Map<String,Sales_Order__c> soOppAccoundIdBySoNameMap, Map<String,Component__c> existingComponentSNMap,GenerateComponentSNFromShipmentFlexFlow generateComponentSN)
    {
        Set<String> setIsComponentSNPresent = new Set<String>();
        for(GenerateComponentSNFromShipmentFlexFlow.ShipmentFlexFlowWrapper ShipmentFlexFlowData: processedShipmentFlexFlowSoList)
        {
            if(ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowFlexProcessed__c == 'Success' && ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowChildSn__c != null)
            {  
                Sales_Order__c soOppRecord = soOppAccoundIdBySoNameMap.get(ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowReferenceA__c);
                
                if(soOppRecord != null)
                {
                    if(soOppRecord.Opportunity__c != null)
                    {
                        if(soOppRecord.Opportunity__r.Account != null)
                        {
                            String srPart = ShipmentFlexFlowData.srPart;
                            
                            System.debug('++++++++++++++++ srPart +++++++++++++++++++' + srPart);
                            
                            if(ShipmentFlexFlowData.matchingComponentFound == false)
                            { 
                                System.debug('++++++++++++++++ matchingComponentFound +++++++++++++++++++' + ShipmentFlexFlowData.matchingComponentFound);
                                
                                Component__c componentRecord;
                                
                                if(existingComponentSNMap.containsKey(ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowChildSn__c))
                                {
                                    componentRecord = new Component__c(Id=existingComponentSNMap.get(ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowChildSn__c).Id);
                                }
                                else
                                {
                                    componentRecord = new Component__c();
                                    componentRecord.componentState__c ='Shipped';
                                    componentRecord.Sub_State__c = 'Unknown';
                                }
                                componentRecord.componentAccountId__c = soOppRecord.Opportunity__r.Account.Id;
                                componentRecord.ComponentCreatedFromInformation__c = 'Spares/Upgrades';
                                componentRecord.componentServicePartNumber__c = srPart;
                                
                                
                                componentRecord = generateComponentSN.setComponentFieldsWhenNull(componentRecord,ShipmentFlexFlowData,srPart);
                                ShipmentFlexFlowData.matchingComponentFound = true;
                                
                                if(!setIsComponentSNPresent.contains(ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowChildSn__c))
                                {
                                	upsertComponentWithSerialNumber.add(componentRecord);
                                    setIsComponentSNPresent.add(ShipmentFlexFlowData.shipmentFlexFlowLine.shipmentFlexflowChildSn__c);
                                }
                                
                            }
                        }
                    }
                }
            }            
        }
        
        upsert upsertComponentWithSerialNumber;
    }
    
    public Map<String,Asset> getAssetRecords(Set<String> assetNames, Map<String,Asset> assetByAssetNameMap)
    {
        for(Asset asset: [Select Name,Asset.AccountId,Asset_Type__c,Asset_Product_Code__c,Component_SKUs__c,System_Capacity_GB__c,SerialNumber from Asset where Name IN:assetNames and Status ='Shipped'])
        {
            assetByAssetNameMap.put(asset.Name,asset);
        }
        
        return assetByAssetNameMap;
    }
    
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}