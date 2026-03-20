global class AssetFlexFlowCatchUpProcessbatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{

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
    global Set<Id> caseInvolvedAssets = new Set<Id>();
    global List<RMAv2__c> rmasList = new List<RMAv2__c>();
    
    global AssetFlexFlowCatchUpProcessbatch(string q){        
        Query = q;
    }
    //###################################################################################################### start
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(Query);
    }
    
    //###################################################################################################### execute
    global void execute(Database.BatchableContext BC, List<Shipment_Flexflow__c>  ShipmentFlexFlowData)
    {                  
        system.debug(logginglevel.DEBUG,'***This is execute method***');
        List<Asset> assetErrorRecord = new List<Asset>();
            //******Arena PLM Bulk**********
            //If a batch contains, 100 records, it is processed 1 by 1. 
            //For the 1st record (alone) in the set of 100, Connects to Arena PLM using Rest Call
            //Puts all the Item object record from Arena PLM to memory collection and make use of it from there on instead of quering all the time.
            ArenaPLMCallouts arenaCallouts = new ArenaPLMCallouts(batchProcessedCount,arenaItemByGuidMapCache,arenaItemByNumberMapCache,batchArenaSessionId, assetErrorRecord);
            arenaItemByGuidMapCache = arenaCallouts.getArenaItemsByGuidMap();
            arenaItemByNumberMapCache = arenaCallouts.getArenaItemsByNumberMap();
            batchArenaSessionId = arenaCallouts.getArenaSessionId();
            
            //****** Memory Collection Debug logs**********
            /*System.debug('++++++++++++++++arenaItemByGuidMapCache Size++++++++++++++++' + arenaItemByGuidMapCache.size());
            System.debug('++++++++++++++++arenaItemByNumberMapCache Size++++++++++++++++' + arenaItemByNumberMapCache.size());
            System.debug('++++++++++++++++batchArenaSessionId++++++++++++++++' + batchArenaSessionId);        
            System.debug('++++++++++++++++arenaItemOfBomMapCache Size+++++++++++++++++++++++++++++++++++++++' + arenaItemOfBomMapCache.size());
            System.debug('++++++++++++++++arenaWhereUsedItemMapCache Size+++++++++++++++++++++++++++++++++++++++' + arenaWhereUsedItemMapCache.size());
            System.debug('++++++++++++++++arenaItemOfBomMapCache Records+++++++++++++++++++++++++++++++++++++++' + arenaItemOfBomMapCache);
            System.debug('++++++++++++++++arenaWhereUsedItemMapCache Records+++++++++++++++++++++++++++++++++++++++' + arenaWhereUsedItemMapCache);*/
        
            Set<string> incomingAssetNames = new Set<string>();
            Map<String,List<Component__c>> componentMapByAssetName = new Map<String,List<Component__c>>();
            for(Shipment_Flexflow__c shipmentToProcess: ShipmentFlexFlowData){ 
                //system.debug('*******shipment flex flow data asset*****'+shipmentToProcess.shipmentFlexflowUnitSerialNumber__c);
                incomingAssetNames.add(shipmentToProcess.shipmentFlexflowUnitSerialNumber__c);
            }
            //AssetComponentPopulationFromArena assetComponentPopulationArena = new AssetComponentPopulationFromArena();
            generateComponentSNCatchUpProcess generateComponentSN = new generateComponentSNCatchUpProcess();
            componentMapByAssetName = generateComponentSN.getComponentMapByAssetName(incomingAssetNames);  //Query Component object with the collected asset Id's to verify the asset already exist in component
            //System.debug('+++++++++++++componentMapByAssetName+++++++++++++++++' + componentMapByAssetName);
            
            //****** Find the Actual Asset records to Process **********
            List<Asset>  assetsToQueryArenaWhereUsed = new List<Asset>();
            Set<String> arenaItemNumber = new Set<String>();
            Set<String> assetNames = new Set<String>();
        
            integer i=0;
         
        	
            List<Id> lstMap = new List<Id>();
            rmasList = [Select rmaDiskShelfAsset__c, rmaDiskShelfAsset__r.Name, rmaDiskShelfAsset__r.Status, rmaCaseNumber__r.AssetId, rmaCaseNumber__r.Asset.Status  from RMAv2__c];
            //for(RMAv2__c rmas: rmasList)
            
            for(i = 0; i<rmasList.size(); i++)
            {
               // i=i+1;
                if(rmasList[i].rmaDiskShelfAsset__r.Status == 'Shipped'){
                    rmaInvolvedAssets.add(rmasList[i].rmaDiskShelfAsset__c);
                }                
                if(rmasList[i].rmaCaseNumber__r.Asset.Status == 'Shipped'){
                    caseInvolvedAssets.add(rmasList[i].rmaCaseNumber__r.AssetId);
                }
                
                //find if there are any duplicates and add that id to the list               
                //system.debug('**** rma involved asset ****'+rmasList[i].rmaDiskShelfAsset__r.Name+'**** count ****'+i);
            }
        //system.debug('**** case Involved asset ****'+caseInvolvedAssets);
        //system.assertEquals(true, caseInvolvedAssets.contains('02i8A000002JBkbQAG'));
            List<Shipment_Flexflow__c> updateShipmentIfNoComp = new List<Shipment_Flexflow__c>(); //If no components found for the asset then update flex flow with message
            List<Asset> assets = [Select Id,Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,assetNextGenBaseNetworking__c,System_Capacity_GB__c,SerialNumber, Autosupport_Last_Received__c,Parent_Asset__c, Parent_Asset__r.Autosupport_Last_Received__c from Asset where Name =: incomingAssetNames AND Status = 'Shipped'];
             for(Asset assetToProcess: assets){ 
                if(componentMapByAssetName.containsKey(assetToProcess.Name)) //Here elimate the Asset already exist in Component object by using collected component set
                {
                    assetsToQueryArenaWhereUsed.add(assetToProcess);
                    assetNames.add(assetToProcess.Name);
                }
                //If no components found for the asset then update flex flow with message
                else{
                    for(Shipment_Flexflow__c updateIfNoComponents : ShipmentFlexFlowData){
                        updateIfNoComponents.shipmentFlexflowProcessedMessage__c = 'No Components found for the Asset';
                        updateIfNoComponents.shipmentFlexflowFlexProcessed__c = 'Success';
                        updateShipmentIfNoComp.add(updateIfNoComponents);
                    }
                }
            } 
        if(updateShipmentIfNoComp.size() > 0){
            update updateShipmentIfNoComp;
        }
        
            //****** Query Arena PLM BOM object as bulk and store it in memory cache **********
            Map<String,List<arenaPLMCallouts.ArenaItemWrapper>> arenaItemOfBOMMapProcessed = arenaCallouts.getArenaBomOfItemsByItemNumber(arenaItemNumber,arenaItemOfBomMapCache,AssetComponentPopulationFromArena.assetLowerSerialItems, assetErrorRecord);
            if(arenaItemOfBOMMapProcessed.size() > 0)
                arenaItemOfBomMapCache.putAll(arenaItemOfBOMMapProcessed); //Store the result from Arena BOM object to Cache Map, Utilized in the upcoming process, if it exist
            //System.debug('+++++++++++++++++arenaItemOfBomMapCache++++++++++++++++++' + arenaItemOfBomMapCache);
            
            //****** Query Arena PLM Where object as bulk and store it in memory cache   **********
            //generateComponentSNCatchUpProcess generateComponentSN = new generateComponentSNCatchUpProcess();
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
                    processAssetRecord(assetToProcess,componentMapByAssetName.get(assetToProcess.Name),generateComponentSN,shipmentFlexFlowMap.get(assetToProcess.Name),rmaInvolvedAssets,caseInvolvedAssets);
                }
            }
            batchProcessedCount = batchProcessedCount + 1; 
    }
    public void processAssetRecord(Asset assetToProcess,List<Component__c> componentsToProcess,generateComponentSNCatchUpProcess generateComponentSN,List<Shipment_Flexflow__c> shipmentFlexFlowLines,set<Id> rmaInvolvedAssets, set<Id> caseInvolvedAssets)
    {
        List<generateComponentSNCatchUpProcess.ShipmentFlexFlowWrapper> processedShipmentFlexFlowMap = new List<generateComponentSNCatchUpProcess.ShipmentFlexFlowWrapper>();

        if(shipmentFlexFlowLines != null)
        {            
            //Process/Transform the Shipment flex flow data
            processedShipmentFlexFlowMap = generateComponentSN.processShipmentFlewFlowData(shipmentFlexFlowLines,componentsToProcess,arenaWhereUsedItemMapCache);

            //Assign appropriate Serial numbers to the created components by looking in Shipment Flex Flow in SFDC
            List<Component__c> upsertComponentWithSerials = generateComponentSN.assignSerialNumberToComponents(processedShipmentFlexFlowMap,componentsToProcess,assetToProcess,rmaInvolvedAssets,caseInvolvedAssets);  
            update upsertComponentWithSerials;
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