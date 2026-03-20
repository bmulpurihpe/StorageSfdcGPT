public class AssetComponentPopulationFromArena {
    
    public static set<String> assetLowerSerialItems = new set<String>();
    public static set<String> assetHigherSerialItems = new set<String>();
    public static Map<string, SR_Meta_Data__c> srcomponentTypeConversionMap = new Map<string, SR_Meta_Data__c>();
    
    //###################################################################################################### assetComponentPopulationFromArena
    public assetComponentPopulationFromArena()
    {
        initializeAssetSnCutOffLists();
    }
    
    //###################################################################################################### initializeAssetSnCutOffLists
    private void initializeAssetSnCutOffLists()
    {
        
        //Asset Type: Legacy - Arena BOM Creation 
        //Following set of HDD or SDD should be picked for asset <105000, skipping the below listed parts for higher Serial Numbers
        assetLowerSerialItems.add('SR-HDD-1TB');
        assetLowerSerialItems.add('SR-HDD-H25');
        assetLowerSerialItems.add('SR-HDD-2TB');
        assetLowerSerialItems.add('SR-HDD-H45');
        assetLowerSerialItems.add('SR-HDD-3TB');
        assetLowerSerialItems.add('SR-SSD-80GB');
        assetLowerSerialItems.add('SR-SSD-160GB');
        assetLowerSerialItems.add('SR-SSD-300GB');
        assetLowerSerialItems.add('SR-SSD-600GB');
        
        //Asset Type: Legacy - Arena BOM Creation 
        //Following set of HDD or SDD should be picked for asset >105000, skipping the below listed parts for lower Serial Number
        assetHigherSerialItems.add('SR-HDD-1TB-SAS');
        assetHigherSerialItems.add('SR-HDD-2TB-SAS');
        assetHigherSerialItems.add('SR-HDD-3TB-SAS');
        assetHigherSerialItems.add('SR-SSD-3500-80GB');
        assetHigherSerialItems.add('SR-SSD-3500-160GB');
        assetHigherSerialItems.add('SR-SSD-3500-300GB');
        assetHigherSerialItems.add('SR-SSD-3500-600GB');
        
        for(SR_Meta_Data__c srMetaData:[Select srPart__c,srShippingProvider__c,srType__c,srDescription__c,srModelNumbers__c from SR_Meta_Data__c])
        {
            srcomponentTypeConversionMap.put(srMetaData.srPart__c, srMetaData);
        } 
        
    }
    
    //###################################################################################################### getComponentMapByAssetName
    public Map<String,List<Component__c>> getComponentMapByAssetName(Set<String> assetName)
    {
        Map<String,List<Component__c>> componentMap = new Map<String,List<Component__c>>();
        
        for(Component__c component: [Select Id,componentDiskModel__c,componentState__c,Sub_State__c,componentAsset__c,componentTransaction__c,componentLocation__c,componentAssetStatus__c,componentServicePartNumber__c,componentAssetName__c,componentComponentSN__c,componentType__c,componentItem__c,ComponentCreatedFromInformation__c from Component__c where componentAssetName__c IN: assetName])
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
    
    
    //###################################################################################################### getExistingComponentSerialNumbers
    public Map<String,Component__c> getExistingComponentSerialNumbers(Set<String> serialNumberToQueryComponent,Map<String,Component__c> existingComponentSNMap)
    {
        for(Component__c component: [Select Id,componentDiskModel__c,componentState__c,Sub_State__c,componentAsset__c,componentTransaction__c,componentLocation__c,componentAssetStatus__c,componentServicePartNumber__c,componentAssetName__c,componentComponentSN__c,componentType__c,componentItem__c,ComponentCreatedFromInformation__c from Component__c where componentComponentSN__c IN: serialNumberToQueryComponent])
        {
            existingComponentSNMap.put(component.componentComponentSN__c,component);
        }
        
        return existingComponentSNMap;
    }
    
    
    //###################################################################################################### createComponents
    public List<Component__c> createComponents(Asset  asset,List<arenaPLMCallouts.ArenaItemWrapper> bomOfItemRecords)
    {
        List<Component__c> createdComponentList = new List<Component__c>();
        
        for(arenaPLMCallouts.ArenaItemWrapper bomItemInformation:bomOfItemRecords)
        {
            // BOM returns the Quanity of Each Item, based on the Quantity, create component accordingly
            // For example: If a BOM child Item has 12 quantity, 12 component records are created
            for(Integer i=1; i<=Integer.valueOf(bomItemInformation.ArenaQuantity);i++)
            {
                Component__c newComponentRecord = new Component__c();
                newComponentRecord.componentAccountId__c = asset.AccountId;
                newComponentRecord.componentAsset__c = asset.Id;
                newComponentRecord.ComponentCreatedFromInformation__c = 'Added from BOM Items';
                newComponentRecord.componentState__c ='Shipped';
                newComponentRecord.Sub_State__c = 'Unknown';
                
                
                Boolean  IsSkipPart = determineIsPartNeedToBeProcessedBasedOnAssetSN(asset.Name,bomItemInformation.ArenaChildItemNumber);
                if(IsSkipPart == true)
                {
                    break;
                }
                else
                {
                    newComponentRecord.componentServicePartNumber__c = bomItemInformation.ArenaChildItemNumber;
                    if(srcomponentTypeConversionMap.containsKey(bomItemInformation.ArenaChildItemNumber))
                    {
                        newComponentRecord.componentType__c = srcomponentTypeConversionMap.get(bomItemInformation.ArenaChildItemNumber).srType__c;
                        newComponentRecord.componentDescription__c = srcomponentTypeConversionMap.get(bomItemInformation.ArenaChildItemNumber).srDescription__c;
                        //newComponentRecord.componentDiskModel__c = srcomponentTypeConversionMap.get(bomItemInformation.ArenaChildItemNumber).srModelNumbers__c;
                    }
                }
                
                
                createdComponentList.add(newComponentRecord); 
            }
        }
        
        return createdComponentList;  
    }
    
    //###################################################################################################### determineIsPartNeedToBeProcessedBasedOnAssetSN
    public Boolean determineIsPartNeedToBeProcessedBasedOnAssetSN(string assetName,string arenaChildItemNumber)
    {
        //If exist - Take the serial part form Asset. Ex: AA-100000, pick numerial part alone 100000
        Integer assetSnNumberOnly        = 1;
        Pattern patternAssetSnNumberOnly = Pattern.compile('.*?([0-9]{6})');
        Matcher matcherAssetSnNumberOnly;
        Boolean IsSkipPart = false;
        
        matcherAssetSnNumberOnly = patternAssetSnNumberOnly.matcher(assetName);
        
        if (matcherAssetSnNumberOnly.matches())
        {
            AssetSnNumberOnly = integer.valueof(matcherAssetSnNumberOnly.group(1));
        }
        
        if(assetSnNumberOnly >= 105000)
        {
            if(assetLowerSerialItems.contains(arenaChildItemNumber))
            {
                IsSkipPart = true;
            }
        }
        else
        {
            if(assetHigherSerialItems.contains(arenaChildItemNumber))
            {
                IsSkipPart = true;
            }
        }
        
        return IsSkipPart;
    }

}