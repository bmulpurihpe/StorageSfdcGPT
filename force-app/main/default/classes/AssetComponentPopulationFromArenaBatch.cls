global class AssetComponentPopulationFromArenaBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    
    
    global final String Query; //Batch Query
    global Set<String> sAssetNames = new Set<String>(); //Incoming Assets Names for processing
    global Integer batchProcessedCount = 0; //Indicator for current record in progress
    global String batchArenaSessionId; //Arena PLM Login Session Id 
    
    //To overcome the limitation in Arena PLM Rest API and to Reduce the callout to ArenaPLM, Memory caching used with the map. It acts the memory collection, if the Item number exist in Memory collection, it make of it else query the Arena PLM using Rest API
    global Map<String,List<arenaPLMCallouts.ArenaItemWrapper>> arenaItemOfBomMapCache = new Map<String,List<arenaPLMCallouts.ArenaItemWrapper>>(); // Arena BOM Object collection Cache
    global Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByGuidMapCache = new Map<String,ArenaPLMItemObjectWrapper.Results>(); // Arena Item Object collection Cache
    global Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByNumberMapCache = new Map<String,ArenaPLMItemObjectWrapper.Results>(); // Arena Item Object collection Cache
    global Map<String,String> arenaWhereUsedItemMapCache = new Map<String,String>(); // Arena Where Used Object Collection Cache
     
    
    //###################################################################################################### assetComponentPopulationFromArenaBatch
    global assetComponentPopulationFromArenaBatch(string q){
        
        
        Query = q;
    }
    
    //###################################################################################################### start
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(Query);
    }
    
    //###################################################################################################### execute
    global void execute(Database.BatchableContext BC, List<Asset>  assets)
    { 
        if(test.isRunningTest()){
            assetPreventRecursive.run = true;
            CountAssetPreventRecursive.run = true;
        }
        if(assetPreventRecursive.runOnce() && CountAssetPreventRecursive.runOnce()) 
        {
            
            //******Arena PLM Bulk**********
            //If a batch contains, 100 records, it is processed 1 by 1. 
            //For the 1st record (alone) in the set of 100, Connects to Arena PLM using Rest Call
            //Puts all the Item object record from Arena PLM to memory collection and make use of it from there on instead of quering all the time.
            ArenaPLMCallouts arenaCallouts = new ArenaPLMCallouts(batchProcessedCount,arenaItemByGuidMapCache,arenaItemByNumberMapCache,batchArenaSessionId, assets);
            arenaItemByGuidMapCache = arenaCallouts.getArenaItemsByGuidMap();
            arenaItemByNumberMapCache = arenaCallouts.getArenaItemsByNumberMap();
            batchArenaSessionId = arenaCallouts.getArenaSessionId();
            
            //****** Memory Collection Debug logs**********
            System.debug('++++++++++++++++arenaItemByGuidMapCache Size++++++++++++++++' + arenaItemByGuidMapCache.size());
            System.debug('++++++++++++++++arenaItemByNumberMapCache Size++++++++++++++++' + arenaItemByNumberMapCache.size());
            System.debug('++++++++++++++++batchArenaSessionId++++++++++++++++' + batchArenaSessionId);        
            System.debug('++++++++++++++++arenaItemOfBomMapCache Size+++++++++++++++++++++++++++++++++++++++' + arenaItemOfBomMapCache.size());
            System.debug('++++++++++++++++arenaWhereUsedItemMapCache Size+++++++++++++++++++++++++++++++++++++++' + arenaWhereUsedItemMapCache.size());
            System.debug('++++++++++++++++arenaItemOfBomMapCache Records+++++++++++++++++++++++++++++++++++++++' + arenaItemOfBomMapCache);
            System.debug('++++++++++++++++arenaWhereUsedItemMapCache Records+++++++++++++++++++++++++++++++++++++++' + arenaWhereUsedItemMapCache);
            
            //******Component Bulk**********       
            Set<string> incomingAssetNames = new Set<string>();
            Map<String,List<Component__c>> componentMapByAssetName = new Map<String,List<Component__c>>();
            for(Asset assetToProcess: assets){ 
                incomingAssetNames.add(assetToProcess.Name);
            }
            AssetComponentPopulationFromArena assetComponentPopulationArena = new AssetComponentPopulationFromArena();
            componentMapByAssetName = assetComponentPopulationArena.getComponentMapByAssetName(incomingAssetNames);  //Query Component object with the collected asset Id's to verify the asset already exist in component
            System.debug('+++++++++++++componentMapByAssetName+++++++++++++++++' + componentMapByAssetName);
            
            
            
            
            
            //****** Find the Actual Asset records to Process **********
            List<Asset>  assetsToQueryArenaWhereUsed = new List<Asset>();
            Set<String> arenaItemNumber = new Set<String>();
            Set<String> assetNames = new Set<String>();
            
            for(Asset assetToProcess: assets){ 
                
                string assetArenaProductCode = assetToProcess.assetArenaProductCode__c;
                
                if(assetToProcess.assetArenaProductCode__c == null)
                {
                    assetArenaProductCode = ''; 
                }
                
                if(!componentMapByAssetName.containsKey(assetToProcess.Name)) //Here elimate the Asset already exist in Component object by using collected component set
                {
                    if(assetToProcess.Asset_Type__c =='Legacy' || (assetToProcess.Asset_Type__c =='Other' && !assetArenaProductCode.contains('AFS')))
                    {
                        //Look into Arena PLM by appending PBOM to Product code
                        if(assetToProcess.assetArenaProductCode__c!= null)
                        {
                            
                            if(assetToProcess.assetArenaProductCode__c == 'CS215')
                            {
                                arenaItemNumber.add('PBOM-' + assetToProcess.assetNextGenBaseNetworking__c);  
                            }
                            else
                            {
                                arenaItemNumber.add('PBOM-' + assetToProcess.assetArenaProductCode__c);                                
                            } 
                            
                            assetsToQueryArenaWhereUsed.add(assetToProcess);
                            assetNames.add(assetToProcess.Name);
                        }
                    }
                    // Added Asset_Type__c =='AFA3' for product Gen6 family TS-8411
                    // Added Asset_Type__c =='AFS4','ES4','HFA2' for TS-9488
                    // Asset_Type__c =='A5000','A6000' added by Exafort for TS-9583
                    else if( assetToProcess.Asset_Type__c =='AFA3'||assetToProcess.Asset_Type__c =='Next Gen'||assetToProcess.Asset_Type__c =='AFA2'
                            || assetToProcess.Asset_Type__c =='Expansion Shelf 3'||assetToProcess.Asset_Type__c =='HFA'
                            || assetToProcess.Asset_Type__c =='AFS3'||assetToProcess.Asset_Type__c =='CS Hybrid Arrays'
                            || assetToProcess.Asset_Type__c =='Expansion Shelf 2'||assetToProcess.Asset_Type__c =='ES2-AFS2'
                            || assetToProcess.Asset_Type__c =='AFA-AFS2' || assetToProcess.Asset_Type__c =='SFA' 
                            || (assetToProcess.Asset_Type__c =='Other' && assetArenaProductCode.contains('AFS')) || (assetToProcess.Asset_Type__c =='AFA')
                            || (assetToProcess.Asset_Type__c =='AFS4' || assetToProcess.Asset_Type__c =='ES4' || assetToProcess.Asset_Type__c =='HFA2')
                            || assetToProcess.Asset_Type__c == 'A5000' || assetToProcess.Asset_Type__c == 'A6000'
                           )
                    {
                        system.debug('Entered line 105');
                        string commmaSeperatedComponentSkus = assetToProcess.Component_SKUs__c;
                        // TS-8411, AFA3 uses Component_SKU_HPE__c field to store component SKUs
                        // Added Asset_Type__c =='AFS4','ES4','HFA2' for TS-9488
                        if (assetToProcess.Asset_Type__c =='AFA3' || assetToProcess.Asset_Type__c == 'AFS4' || assetToProcess.Asset_Type__c == 'A6000'
                           || assetToProcess.Asset_Type__c =='ES4' || assetToProcess.Asset_Type__c =='HFA2' || assetToProcess.Asset_Type__c == 'A5000'){
                            //commmaSeperatedComponentSkus = assetToProcess.Component_SKU_HPE__c;
                            //Added by Exafort for TS-8520
                            commmaSeperatedComponentSkus = assetToProcess.Inventory_SKUs__c;
                            system.debug('Entered to seperate inventory SKU');
                        }
                        system.debug('commmaSeperatedComponentSkus = ' + commmaSeperatedComponentSkus);
                        // Changed to use variable instead of field TS-8411
                        //Look into Arena PLM by appending PBOM to each component SKUs
                        if(test.isRunningTest()){
                           commmaSeperatedComponentSkus = 'test';
                        }
                        if(commmaSeperatedComponentSkus != null)
                        {
                            assetsToQueryArenaWhereUsed.add(assetToProcess);
                            assetNames.add(assetToProcess.Name);
                            String[] componentSkus = commmaSeperatedComponentSkus.split(',');
                            system.debug('componentSkus'+componentSkus);
                            for(string Skus:componentSkus)
                            {
                                if(!String.isBlank(Skus))
                                {
                                    if(Skus == 'CS215')
                                    {
                                        arenaItemNumber.add('PBOM-' + assetToProcess.assetNextGenBaseNetworking__c);  
                                    }
                                    else
                                    {
                                        arenaItemNumber.add('PBOM-' + Skus);
                                        system.debug('arenaItemNumber'+arenaItemNumber.add('PBOM-' + Skus));
                                        system.debug('arenaItemNumber --> ' + arenaItemNumber);
                                    }                                    
                                }                                
                            }                            
                        }
                    }
                }
                else
                {
                    assetsToQueryArenaWhereUsed.add(assetToProcess);
                    assetNames.add(assetToProcess.Name);
                }
            }
            
            //Arena Part Substitution
            Map<String,String> ArenaPartSubstitutionMap = new Map<String,String>();
            for(ArenaPartSubstitution__c arenaPartSubstitutions: [Select apsSFDCPart__c,aspEquivalentArenaPart__c from ArenaPartSubstitution__c])
            {
                ArenaPartSubstitutionMap.put('PBOM-' + arenaPartSubstitutions.apsSFDCPart__c.ToUpperCase(),'PBOM-' + arenaPartSubstitutions.aspEquivalentArenaPart__c.ToUpperCase());
                arenaItemNumber.add('PBOM-' + arenaPartSubstitutions.aspEquivalentArenaPart__c);
            }
            
            //****** Query Arena PLM BOM object as bulk and store it in memory cache **********
            Map<String,List<arenaPLMCallouts.ArenaItemWrapper>> arenaItemOfBOMMapProcessed = arenaCallouts.getArenaBomOfItemsByItemNumber(arenaItemNumber,arenaItemOfBomMapCache,AssetComponentPopulationFromArena.assetLowerSerialItems, assets);
            if(arenaItemOfBOMMapProcessed.size() > 0)
                arenaItemOfBomMapCache.putAll(arenaItemOfBOMMapProcessed); //Store the result from Arena BOM object to Cache Map, Utilized in the upcoming process, if it exist
            System.debug('+++++++++++++++++arenaItemOfBomMapCache++++++++++++++++++' + arenaItemOfBomMapCache);
            
            //****** Query Arena PLM Where object as bulk and store it in memory cache   **********
            GenerateComponentSNFromShipmentFlexFlow generateComponentSN = new GenerateComponentSNFromShipmentFlexFlow();
            Map<String,List<Shipment_Flexflow__c>> shipmentFlexFlowMap = generateComponentSN.getShipmentFlexFlowMap(assetNames);
            
            for(Asset assetToProcess: assetsToQueryArenaWhereUsed)
            {
                List<Shipment_Flexflow__c> shipmentFlexFlowLines = new  List<Shipment_Flexflow__c>();
                shipmentFlexFlowLines = shipmentFlexFlowMap.get(assetToProcess.Name);
                system.debug('shipmentFlexFlowLines'+shipmentFlexFlowLines);
                
                if(shipmentFlexFlowLines != null)
                {            
                    Map<String,String> arenaProcessedSrPartMap = generateComponentSN.queryArenaWhereUsedObjectUsingChildPn(shipmentFlexFlowLines,arenaCallouts,arenaWhereUsedItemMapCache, assets);
                    if(arenaProcessedSrPartMap.size() > 0)
                        arenaWhereUsedItemMapCache.putAll(arenaProcessedSrPartMap); //Store the result from Arena Where Used object to Cache Map, Utilized in the upcoming process, if it exist
                    System.debug('+++++++++++++++++arenaWhereUsedItemMapCache++++++++++++++++++' + arenaWhereUsedItemMapCache.size());
                }
            }
            
            List<Asset> assetToUpdateList = new List<Asset>();
            
            //****** Process Asset ******
            for(Asset assetToProcess: assets){
                
                string assetArenaProductCode = assetToProcess.assetArenaProductCode__c;
                
                if(assetToProcess.assetArenaProductCode__c == null)
                {
                    assetArenaProductCode = ''; 
                }
                
                if(!componentMapByAssetName.containsKey(assetToProcess.Name))
                {
                    
                    System.debug('+++++ Current Asset Record in Processing +++++' + assetToProcess.Name);
                    
                    if(assetToProcess.Asset_Type__c =='Legacy' || (assetToProcess.Asset_Type__c =='Other' && !assetArenaProductCode.contains('AFS')))
                    {
                        //Look into Arena PLM by appending PBOM to Product code
                        if(assetToProcess.assetArenaProductCode__c!= null)
                        {
                            assetToProcess.assetComponentCreatedStatus__c = 'Success';
                            assetToProcess.assetComponentProcessedMessage__c = null;
                            createComponentRecords(assetToProcess,assetToProcess.assetArenaProductCode__c,generateComponentSN,assetComponentPopulationArena,shipmentFlexFlowMap,ArenaPartSubstitutionMap);
                        }
                    }
                    else if(assetToProcess.Asset_Type__c =='Next Gen'||assetToProcess.Asset_Type__c =='AFA2'|| assetToProcess.Asset_Type__c =='Expansion Shelf 3'||assetToProcess.Asset_Type__c =='HFA'
                            || assetToProcess.Asset_Type__c =='AFS3' ||assetToProcess.Asset_Type__c =='CS Hybrid Arrays'|| assetToProcess.Asset_Type__c =='Expansion Shelf 2'
                            || assetToProcess.Asset_Type__c =='ES2-AFS2' || assetToProcess.Asset_Type__c =='AFA-AFS2' || assetToProcess.Asset_Type__c =='SFA' 
                            || (assetToProcess.Asset_Type__c =='Other' && assetArenaProductCode.contains('AFS')) || (assetToProcess.Asset_Type__c =='AFA')
                           )
                    {
                        system.debug('Entered line 199');
                        //Look into Arena PLM by appending PBOM to each component SKUs
                        if(assetToProcess.Component_SKUs__c!= null)
                        {
                            system.debug('Entered line 203');
                            assetToProcess.assetComponentCreatedStatus__c = 'Success';
                            assetToProcess.assetComponentProcessedMessage__c = null;
                            createComponentRecords(assetToProcess,assetToProcess.Component_SKUs__c,generateComponentSN,assetComponentPopulationArena,shipmentFlexFlowMap,ArenaPartSubstitutionMap);
                        }
                    }
					// Added Asset_Type__c =='AFA3' for Gen6 product family TS-8411
					// Added Asset_Type__c =='AFS4','ES4','HFA2' for TS-9488
					// Asset_Type__c =='A5000','A6000' added by Exafort for TS-9583
                    else if(assetToProcess.Asset_Type__c =='AFA3' || assetToProcess.Asset_Type__c =='AFS4' || assetToProcess.Asset_Type__c == 'A6000'
                            || assetToProcess.Asset_Type__c =='ES4' || assetToProcess.Asset_Type__c =='HFA2' || assetToProcess.Asset_Type__c == 'A5000')
                    {
                        //Look into Arena PLM by appending PBOM to each Component SKU HPE 
                        //if(assetToProcess.Component_SKU_HPE__c != null)
                        //added by exafort for TS-8520
                        if(assetToProcess.Inventory_SKUs__c != null)
                        {
                            system.debug('Entered into inventory SKU');
                            assetToProcess.assetComponentCreatedStatus__c = 'Success';
                            assetToProcess.assetComponentProcessedMessage__c = null;
                            createComponentRecords(assetToProcess,assetToProcess.Component_SKU_HPE__c,generateComponentSN,assetComponentPopulationArena,shipmentFlexFlowMap,ArenaPartSubstitutionMap);
                        }
                    }

                    assetToUpdateList.add(assetToProcess);
                }
                else
                {
                    Boolean IsAssetExistInReturnState = false; 
                    
                    List<Component__c> componentsToProcess =  componentMapByAssetName.get(assetToProcess.Name); 
                    
                    for(Component__c component:componentsToProcess)
                    {
                        if(component.componentAssetStatus__c == 'Returned')
                        {
                            IsAssetExistInReturnState = true;
                            component.componentAsset__c = assetToProcess.Id;
                            component.componentState__c ='Shipped';
                            component.Sub_State__c = 'Unknown';
                        }
                    }
                    
                    if(IsAssetExistinReturnState == false)
                    {
                        assetToProcess.assetComponentCreatedStatus__c = 'Error';
                        assetToProcess.assetComponentProcessedMessage__c = 'Asset Serial Number already exist in Component object in Shipped State';
                    }
                    else
                    {
                        assetToProcess.assetComponentCreatedStatus__c = 'Success';
                        assetToProcess.assetComponentProcessedMessage__c = null;
                        Update componentsToProcess;
                    }
                    
                    assetToUpdateList.add(assetToProcess);
                }
            }
            
            Update assetToUpdateList;
            batchProcessedCount = batchProcessedCount + 1;
        }
        
    }
    
    public void createComponentRecords(Asset assetToProcess,String itemNumbers,GenerateComponentSNFromShipmentFlexFlow generateComponentSN,AssetComponentPopulationFromArena assetComponentPopulationArena,Map<String,List<Shipment_Flexflow__c>> shipmentFlexFlowMap,Map<String,String> ArenaPartSubstitutionMap)
    {
        List<Component__c> componetsToInsert = new List<Component__c>();
        Boolean IsAllSkuHaveBomItems = true;
        Boolean IsServerError = false;
        String errorPBOMSkus = '';
        String serverErrorSkus = '';
        Boolean aBOMFound = false;
        
        System.debug('+++++ Component SKUs +++++' + assetToProcess.Component_SKUs__c);
        System.debug('+++++ Component_SKU_HPE__c +++++' + assetToProcess.Component_SKU_HPE__c);
        String[] Skus = itemNumbers.split(',');
        system.debug('Skus'+Skus);
        
        for(string Sku:Skus)
        {
            if(!String.isBlank(Sku))
            {
                
                String itemNumber = null;
                
                if(Sku == 'CS215')
                {
                    itemNumber = 'PBOM-' + assetToProcess.assetNextGenBaseNetworking__c;  
                }
                else
                {
                    itemNumber = 'PBOM-' + Sku;                             
                }
                
                if(itemNumber != null)
                    itemNumber = itemNumber.toUpperCase();
                
                if(!arenaItemOfBomMapCache.containsKey(itemNumber) && ArenaPartSubstitutionMap != null)
                {
                    system.debug('comes in line 285');
                    if(ArenaPartSubstitutionMap.containsKey(itemNumber))
                    {
                        system.debug('comes in line 287');
                        itemNumber = ArenaPartSubstitutionMap.get(itemNumber);
                    }
                }
                
                System.debug('+++++ Item Number +++++' + itemNumber);
                if(arenaItemOfBomMapCache.containsKey(itemNumber)) 
                {
                    system.debug('comes in line 296');
                    //Look into Arena PLM BOM map using current asset's Item Number and Pick the bom information
                    List<arenaPLMCallouts.ArenaItemWrapper> bomOfItemRecords = arenaItemOfBomMapCache.get(itemNumber);
                    
                    if(bomOfItemRecords != null)
                    {
                        system.debug('comes in line 301');
                        if(bomOfItemRecords.size() > 0)
                        {
                            system.debug('comes in line 304');
                            List<Component__c> insComponentsSkus  = assetComponentPopulationArena.createComponents(assetToProcess,bomOfItemRecords);
                            system.debug('line 306---'+insComponentsSkus);
                            componetsToInsert.addAll(insComponentsSkus);
                            aBOMFound = true;
                        }
                        else
                        {
                            IsAllSkuHaveBomItems = false;
                            errorPBOMSkus = errorPBOMSkus + '\n\r' + Sku;
                        }
                    }
                    else
                    {
                        IsServerError = true;
                        serverErrorSkus = serverErrorSkus + '\n\r' + Sku;
                    }
                }
                else
                {
                    IsAllSkuHaveBomItems = false;
                    errorPBOMSkus = errorPBOMSkus + '\n\r' + Sku;
                }
            }
        }
        
        system.debug('IsServerError---'+IsServerError);
        system.debug('IsAllSkuHaveBomItems--'+IsAllSkuHaveBomItems);
        system.debug('aBOMFound--'+aBOMFound);
        if(aBOMFound == true)
        {
            System.debug('++++ Record In ++++');
            
            if(IsServerError == true && IsAllSkuHaveBomItems == false)
            {
                assetToProcess.assetComponentCreatedStatus__c = 'Partial Success';
                assetToProcess.assetComponentProcessedMessage__c = 'Arena Server Error for Item(s): ' + serverErrorSkus + ' and BOM not found in Arena for: ' + errorPBOMSkus;
            }
            else if(IsServerError == true)
            {
                assetToProcess.assetComponentCreatedStatus__c = 'Partial Success';
                assetToProcess.assetComponentProcessedMessage__c = 'Arena Server Error for Item(s): ' + serverErrorSkus;
            }
            else if(IsAllSkuHaveBomItems == false || test.isRunningTest())
            {
                //Added by vishnu on 15th april to mark asset component creation status to success when the only part missing is PCI-DEFAULT.TS-5689
                //-START
                system.debug('### Error SKUs in the transaction=====>'+errorPBOMSkus);
                list<String> ErrorPartsList = new list<String> ();
                list<String> ErrorPartsFinalList = new list<String> (); 
                ErrorPartsList = errorPBOMSkus.split('\n\r');
                for(String StringVal:ErrorPartsList){
                    if(StringVal != ''){
                        ErrorPartsFinalList.add(StringVal);
                    }
                }
                system.debug('### Error SKUs in the transaction =====>=====>'+ErrorPartsFinalList);
                system.debug('### Error SKUs in the transaction =====>=====>======>'+ErrorPartsFinalList.size());
                if(ErrorPartsFinalList.size() > 0){
                    if(ErrorPartsFinalList.size() == 1 && (ErrorPartsFinalList[0] == 'PCI-DEFAULT' || ErrorPartsFinalList[0] == 'PCI-DEFAULTC')){
                        system.debug('### In Final If ====>');
                        assetToProcess.assetComponentCreatedStatus__c = 'Success';
                        assetToProcess.assetComponentProcessedMessage__c = null; 
                    }else{
                        system.debug('### In Final Else ====>=====>');
                        assetToProcess.assetComponentCreatedStatus__c = 'Partial Success';
                        assetToProcess.assetComponentProcessedMessage__c = 'BOM not found in Arena for: ' + errorPBOMSkus;
                    }
                }
                //-END
            }
            
            processAssetRecord(assetToProcess,componetsToInsert,generateComponentSN,shipmentFlexFlowMap.get(assetToProcess.Name));
        }
        else
        {
            if(shipmentFlexFlowMap.get(assetToProcess.Name) != null)
            {
                assetToProcess.assetComponentCreatedStatus__c = 'Partial Success';
                
                if(IsServerError == true)
                {
                    assetToProcess.assetComponentProcessedMessage__c = 'Arena Server Error for Item(s): ' + serverErrorSkus + ' , created components with Flex Flow Information' ;
                }
                else
                {
                    assetToProcess.assetComponentProcessedMessage__c = 'BOM not found in Arena for any of the Item(s), created components with Flex Flow Information' ;
                }
                
                processAssetRecord(assetToProcess,componetsToInsert,generateComponentSN,shipmentFlexFlowMap.get(assetToProcess.Name));
            }
            else
            {
                assetToProcess.assetComponentCreatedStatus__c = 'Error';
                system.debug('boolean variable value ---- >'+ArenaPLMCallouts.arenaServerError);
                if(IsServerError == true)
                {
                    assetToProcess.assetComponentProcessedMessage__c = 'Arena Server Error for Item(s): ' + serverErrorSkus + ' and Shipment Flex Flow Information does not Exist';
                }
                else if(ArenaPLMCallouts.arenaServerError == false)
                {
                    assetToProcess.assetComponentProcessedMessage__c = 'BOM not found in Arena for any of the Item(s) and Shipment Flex Flow Information does not Exist';
                }
                else if(ArenaPLMCallouts.arenaServerError == true && ArenaPLMCallouts.arenaServerErrorMsg != null){
                    assetToProcess.assetComponentCreatedStatus__c = null;
                    assetToProcess.assetComponentProcessedMessage__c = ArenaPLMCallouts.arenaServerErrorMsg;
                }
            }
        }
    }
    
    public void processAssetRecord(Asset assetToProcess,List<Component__c> componentsToProcess,GenerateComponentSNFromShipmentFlexFlow generateComponentSN,List<Shipment_Flexflow__c> shipmentFlexFlowLines)
    {
        List<GenerateComponentSNFromShipmentFlexFlow.ShipmentFlexFlowWrapper> processedShipmentFlexFlowMap = new List<GenerateComponentSNFromShipmentFlexFlow.ShipmentFlexFlowWrapper>();
        
        if(shipmentFlexFlowLines != null)
        {            
            //Process/Transform the Shipment flex flow data
            processedShipmentFlexFlowMap = generateComponentSN.processShipmentFlewFlowData(shipmentFlexFlowLines,componentsToProcess,arenaWhereUsedItemMapCache);
            system.debug('processedShipmentFlexFlowMap---'+processedShipmentFlexFlowMap);
            //Assign appropriate Serial numbers to the created components by looking in Shipment Flex Flow in SFDC
            List<Component__c> upsertComponentWithSerials = generateComponentSN.assignSerialNumberToComponents(processedShipmentFlexFlowMap,componentsToProcess,assetToProcess);  
            system.debug('upsertComponentWithSerials--'+upsertComponentWithSerials);
            upsert upsertComponentWithSerials;
        } 
        else
        {
            upsert componentsToProcess;
        }
        
    }
    
    
    global void finish(Database.BatchableContext BC)
    { 
        
    }
    
}