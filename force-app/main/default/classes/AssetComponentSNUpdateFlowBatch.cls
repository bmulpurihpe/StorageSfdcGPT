global class AssetComponentSNUpdateFlowBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    
    global final String Query; //Batch Query
    global Set<String> sAssetNames = new Set<String>(); //Incoming Assets Names for processing
    global Integer batchProcessedCount = 0; //Indicator for current record in progress
    global String batchArenaSessionId; //Arena PLM Login Session Id
    
    //To overcome the limitation in Arena PLM Rest API and to Reduce the callout to ArenaPLM, Memory caching used with the map. It acts the memory collection, if the Item number exist in Memory collection, it make of it else query the Arena PLM using Rest API
    global Map<String,List<arenaPLMCallouts.ArenaItemWrapper>> arenaItemOfBomMapCache = new Map<String,List<arenaPLMCallouts.ArenaItemWrapper>>(); // Arena BOM Object collection Cache
    global Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByGuidMapCache = new Map<String,ArenaPLMItemObjectWrapper.Results>(); // Arena Item Object collection Cache
    global Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByNumberMapCache = new Map<String,ArenaPLMItemObjectWrapper.Results>(); // Arena Item Object collection Cache
    global Map<String,String> arenaWhereUsedItemMapCache = new Map<String,String>(); // Arena Where Used Object Collection Cache
    global Set<Id> rmaInvolvedAssets = new Set<Id>();
    global List<RMAv2__c> rmasList = new List<RMAv2__c>();
    
    global AssetComponentSNUpdateFlowBatch(string q){        
        Query = q;
    }
    //###################################################################################################### start
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(Query);
    }
    
    //###################################################################################################### execute
    global void execute(Database.BatchableContext BC, List<Shipment_Flexflow__c>  ShipmentFlexFlowData)
    {       
       
        //******Arena PLM Bulk**********
        //If a batch contains, 100 records, it is processed 1 by 1. 
        //For the 1st record (alone) in the set of 100, Connects to Arena PLM using Rest Call
        //Puts all the Item object record from Arena PLM to memory collection and make use of it from there on instead of quering all the time.
        List<Asset> assetErrorRecord = new List<Asset>();
        ArenaPLMCallouts arenaCallouts = new ArenaPLMCallouts(batchProcessedCount,arenaItemByGuidMapCache,arenaItemByNumberMapCache,batchArenaSessionId, assetErrorRecord);
        arenaItemByGuidMapCache = arenaCallouts.getArenaItemsByGuidMap();
        arenaItemByNumberMapCache = arenaCallouts.getArenaItemsByNumberMap();
        batchArenaSessionId = arenaCallouts.getArenaSessionId();
        
        Set<string> incomingAssetNames = new Set<string>();
        Map<String,List<Component__c>> componentMapByAssetName = new Map<String,List<Component__c>>();
        for(Shipment_Flexflow__c shipmentToProcess: ShipmentFlexFlowData){ 
            //system.debug('*******shipment flex flow data asset*****'+shipmentToProcess.shipmentFlexflowUnitSerialNumber__c);
            incomingAssetNames.add(shipmentToProcess.shipmentFlexflowUnitSerialNumber__c);
        }
        
        AssetComponentSNUpdateFlow generateComponentSN = new AssetComponentSNUpdateFlow();
        componentMapByAssetName = generateComponentSN.getComponentMapByAssetName(incomingAssetNames); 
        
        List<Asset>  assetsToQueryArenaWhereUsed = new List<Asset>();
        Set<String> arenaItemNumber = new Set<String>();
        Set<String> assetNames = new Set<String>();
        
        List<Asset> assets = [Select Id,Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,assetNextGenBaseNetworking__c,System_Capacity_GB__c,SerialNumber, Autosupport_Last_Received__c,Parent_Asset__c, Parent_Asset__r.Autosupport_Last_Received__c from Asset where Name =: incomingAssetNames AND Status = 'Shipped'];
        for(Asset assetToProcess: assets){ 
            if(componentMapByAssetName.containsKey(assetToProcess.Name)) //Here elimate the Asset already exist in Component object by using collected component set
            {
                assetsToQueryArenaWhereUsed.add(assetToProcess);
                assetNames.add(assetToProcess.Name);
            }
        }
        //****** Query Arena PLM BOM object as bulk and store it in memory cache **********
        Map<String,List<arenaPLMCallouts.ArenaItemWrapper>> arenaItemOfBOMMapProcessed = arenaCallouts.getArenaBomOfItemsByItemNumber(arenaItemNumber,arenaItemOfBomMapCache,AssetComponentPopulationFromArena.assetLowerSerialItems, assetErrorRecord);
        if(arenaItemOfBOMMapProcessed.size() > 0)
            arenaItemOfBomMapCache.putAll(arenaItemOfBOMMapProcessed); //Store the result from Arena BOM object to Cache Map, Utilized in the upcoming process, if it exist
        //System.debug('+++++++++++++++++arenaItemOfBomMapCache++++++++++++++++++' + arenaItemOfBomMapCache);
        
        //****** Query Arena PLM Where object as bulk and store it in memory cache   **********
        
        Map<String,List<Shipment_Flexflow__c>> shipmentFlexFlowMap = generateComponentSN.getShipmentFlexFlowMap(assetNames);
        
        for(Asset assetToProcess: assetsToQueryArenaWhereUsed)
        {
            List<Shipment_Flexflow__c> shipmentFlexFlowLines = new  List<Shipment_Flexflow__c>();
            shipmentFlexFlowLines = shipmentFlexFlowMap.get(assetToProcess.Name);
            system.debug(logginglevel.WARN,'****TEST shipment lines count****'+shipmentFlexFlowLines);
            if(shipmentFlexFlowLines != null)
            {            
                Map<String,String> arenaProcessedSrPartMap = generateComponentSN.queryArenaWhereUsedObjectUsingChildPn(shipmentFlexFlowLines,arenaCallouts,arenaWhereUsedItemMapCache, assetErrorRecord);
                if(arenaProcessedSrPartMap.size() > 0)
                    arenaWhereUsedItemMapCache.putAll(arenaProcessedSrPartMap); //Store the result from Arena Where Used object to Cache Map, Utilized in the upcoming process, if it exist
                //System.debug('+++++++++++++++++arenaWhereUsedItemMapCache++++++++++++++++++' + arenaWhereUsedItemMapCache.size());
            }
        }
        for(Asset assetToProcess: assets){
            if(componentMapByAssetName.containsKey(assetToProcess.Name)){
                processAssetRecord(assetToProcess,componentMapByAssetName.get(assetToProcess.Name),generateComponentSN,shipmentFlexFlowMap.get(assetToProcess.Name));
            }
        }
        batchProcessedCount = batchProcessedCount + 1; 
    }
    
    public void processAssetRecord(Asset assetToProcess,List<Component__c> componentsToProcess,AssetComponentSNUpdateFlow generateComponentSN,List<Shipment_Flexflow__c> shipmentFlexFlowLines)
    {
        List<AssetComponentSNUpdateFlow.ShipmentFlexFlowWrapper> processedShipmentFlexFlowMap = new List<AssetComponentSNUpdateFlow.ShipmentFlexFlowWrapper>();
        
        if(shipmentFlexFlowLines != null)
        {            
            //Process/Transform the Shipment flex flow data
            processedShipmentFlexFlowMap = generateComponentSN.processShipmentFlewFlowData(shipmentFlexFlowLines,componentsToProcess,arenaWhereUsedItemMapCache);
            
            //Assign appropriate Serial numbers to the created components by looking in Shipment Flex Flow in SFDC
            List<Component__c> upsertComponentWithSerials = generateComponentSN.assignSerialNumberToComponents(processedShipmentFlexFlowMap,componentsToProcess,assetToProcess);  
            upsert upsertComponentWithSerials;
        }
        else
        {
            //upsert componentsToProcess;
        }
        
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }
}