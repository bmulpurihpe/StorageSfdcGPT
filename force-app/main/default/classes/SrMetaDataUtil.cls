/*
 * Created by Exafort for the JIRA TS-9712
 * Utlity class to process SR Metadata values
 * Test Class - DM7ComponentBatch_Test
*/ 
public class SrMetaDataUtil {
    public static Map<String,String> modelToSRMap;
    public static Map<String,String> modelWithProductCode;
    public static Map<string, string> modelWithAssetTypeSRMapFinal;
    public static Map<String,String> modelToSRMapProductName;
    public static Map<String,String> modelToSRMapDynamicSKU;
    
    public static void PrepareSRMetaData(){
        //Query all the valid srMetadata records
        List<SR_Meta_Data__c> metaDataList = [select Id, srModelNumbers__c, srPart__c, srAssetType__c, srProduct_Name__c, srDynamicSKU__c, srProductCode__c, srType__c 
                                              from SR_Meta_Data__c 
                                              where srPart__c != null AND srmetadataIsValid__c = true AND Is_In_Prod__c = true];
        Map<String,List<String>> modelwithAsstToSRMapHelper = new Map<String,List<String>>();
        Map<string, string> modelNumberWithAssetTypeValue = new Map<string, string>();
        modelToSRMap = new  Map<String,String>();
        Map<String,List<String>> modelwithAsstToSRMap = new Map<String,List<String>>();
        modelWithProductCode = new Map<String,String>();
        modelToSRMapProductName = new Map<String,String>();
        modelToSRMapDynamicSKU = new Map<String,String>();
        List<String> srProductName = new List<String>();
        modelWithAssetTypeSRMapFinal = new Map<string, string>();
        
        // Process all the SR Metadata values and store it on the Map
        for(SR_Meta_Data__c metaData : metaDataList){
            
            if(metaData.srModelNumbers__c != null)
            {
                List<String> mNums = new List<String>();
                if(metaData.srModelNumbers__c.contains(',')){
                    mNums = metaData.srModelNumbers__c.split(',');
                }
                else{
                    mNums.add(metaData.srModelNumbers__c);
                    system.debug('mNums --> ' + mNums);
                }
                // }
                List<String> aTypes = new List<String>();
                if(metaData.srAssetType__c != null){
                    aTypes = metaData.srAssetType__c.split(',');
                }
                for(String modelNumber : mNums)
                {
                    modelNumber = modelNumber.trim();
                    system.debug('modelNumber --> ' + modelNumber);
                    //Check whether the incoming key is already exist in map or not.
                    //If Exist, the key is repeating and we should add it to repeatedMap(modelwithAsstToSRMap),
                    //Else, the key is unique one.
                    if(modelToSRMap.containsKey(modelNumber)){
                        system.debug('Entered into contains');
                        // In this block, we know the key is not unique
                        
                        // We can't remove the repeated value yet; otherwise, the next time(third time)
                        //   the same key comes up, we'll think it's unique again.
                        String val = modelToSRMap.get(modelNumber); //take the value from previously inserted key
                        
                        string assetTypeOfUnique = modelNumberWithAssetTypeValue.get(modelNumber); //take asset type from the previously inserted key to loop through Asset type to form ModelNumber+AssetType key
                        
                        List<String> splittedAssetTypes = new List<String>();  //to hold the splitted asset types from the previous key
                        if(assetTypeOfUnique != null && assetTypeOfUnique.contains(',')){
                            splittedAssetTypes = assetTypeOfUnique.split(',');
                        }
                        else if(assetTypeOfUnique != null && !assetTypeOfUnique.contains(',')){
                            splittedAssetTypes.add(assetTypeOfUnique);
                        }
                        
                        for(String assetTy : splittedAssetTypes){
                            assetTy = assetTy.trim();
                            modelwithAsstToSRMap.put(modelNumber+assetTy, new List<String>{val});  //insert the previous key with assettype and its value in the repeated map.
                            system.debug('Asset to SR Map'+modelwithAsstToSRMap.put(modelNumber+assetTy, new List<String>{val}));
                        }
                        // We only want to put the value for the key we now know is not unique
                        // into repeatedMap's list of values once.
                        // Probably the simplest way to do that is to add the value from the UniqueMap(modelToSRMap)
                        // when we first add the key to repeatedMap
                        
                        /****below lines are used to remove the repeated keys from Unique Map*/
                        if(!modelwithAsstToSRMapHelper.containsKey(modelNumber)){
                            
                            modelwithAsstToSRMapHelper.put(modelNumber, new List<String>{metaData.srPart__c});
                        }
                        modelwithAsstToSRMapHelper.get(modelNumber).add(metaData.srPart__c);
                                               
                        for(String assetType : aTypes){
                            assetType = assetType.trim();
                            if(!modelwithAsstToSRMap.containsKey(modelNumber+assetType)){
                                
                                modelwithAsstToSRMap.put(modelNumber+assetType, new List<String>{val});
                                system.debug('Line 172'+modelwithAsstToSRMap.put(modelNumber+assetType, new List<String>{val}));
                            }
                            modelwithAsstToSRMap.get(modelNumber+assetType).add(metaData.srPart__c);
                            system.debug('Line 175'+modelwithAsstToSRMap.get(modelNumber+assetType).add(metaData.srPart__c));
                            //modelwithAsstToSRMap.put(m+a, new List<String>{md.srPart__c});
                        }
                        
                        
                    }else{
                        // Nothing else to do for now but assume that the key is unique
                        // Added by Exafort for SFDC-361
                        for(string assetTypes : aTypes){
                             modelToSRMap.put(modelNumber+assetTypes, metaData.srPart__c);
                        }
                       
                        modelNumberWithAssetTypeValue.put(modelNumber, metaData.srAssetType__c); //helper repeated map to remove the keys from unique map.
                    }
                    if(metaData.srProductCode__c != null){
                        List<String> aProductCode = metaData.srProductCode__c.split(',');
                        for(String codes : aProductCode){
                            modelWithProductCode.put(codes, metaData.srPart__c);
                        }
                    }
                }
            }
            
            /*Controller update logic with product name */
            else if(metaData.srModelNumbers__c == null){
                if(metaData.srProduct_Name__c != null && metaData.srProduct_Name__c != '' && metaData.srType__c == 'Controller'){
                    srProductName = new list<string>();
                    
                    if(metaData.srProduct_Name__c.contains(',')){
                        
                        srProductName = metaData.srProduct_Name__c.split(',');
                        system.debug('split sr metadata prd name'+metaData.srProduct_Name__c.split(','));
                        
                    }
                    else{
                        
                        srProductName.add(metaData.srProduct_Name__c);
                    }
                    system.debug('srProductName'+srProductName);
                    for(String mProductName : srProductName)
                    {
                        if(metaData.srDynamicSKU__c == null){
                            system.debug('srProductName 123'+srProductName);
                            modelToSRMapProductName.put(mProductName.trim(), metaData.srPart__c);
                            system.debug('modelToSRMapProductName'+ modelToSRMapProductName.put(mProductName.trim(), metaData.srPart__c));
                            
                        }                
                        else if(metaData.srDynamicSKU__c != null){
                            modelToSRMapDynamicSKU.put(metaData.srDynamicSKU__c, metaData.srPart__c);
                        }
                    }
                } 
            }
        }
        // map.keySet() returns a set containing all of the keys of the map 
        // Sets have a removeAll() method that removes all items in the set passed 
        // as a parameter from the set that called the method.
        // Removing items from a map's keyset removes both the key and the value from the map
        
        modelToSRMap.keySet().removeAll(modelwithAsstToSRMapHelper.keySet());
        
        /* START --- Filter the modelwithAsstToSRMap map to have its actual value for the key */
        for(string modelWithAssetType : modelwithAsstToSRMap.keySet()){
            List<string> getListOfSRPartsFromModels = modelwithAsstToSRMap.get(modelWithAssetType);
            string lastValueForModel;
            if(getListOfSRPartsFromModels.size() > 1){
                for(string getLastvalue : getListOfSRPartsFromModels){
                    lastValueForModel = getLastvalue;
                }
                if(lastValueForModel != null)
                    modelWithAssetTypeSRMapFinal.put(modelWithAssetType, lastValueForModel);
            }
            else if(getListOfSRPartsFromModels.size() == 1){
                for(string getOnevalue : getListOfSRPartsFromModels){
                    modelWithAssetTypeSRMapFinal.put(modelWithAssetType, getOnevalue);
                }
                
            }
        }
    }
}