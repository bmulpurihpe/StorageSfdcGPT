/* Purpose: A batch class to process the asup components daily to 
*           create/update the components for an asset
* Change Log: Created by Pradeep Aitha
*/ 
public class ProcessAsupComponent_Batch implements Database.Batchable<sObject>{  
    String query; 
    Boolean firstRun;	// Set this to false when calling. This was used during the first ever run to be true.
    
    public ProcessAsupComponent_Batch(String query, Boolean firstRun)
    {
        this.query = query;
        this.firstRun = firstRun;
    }
    
    public ProcessAsupComponent_Batch(Boolean firstRun)
    {
        //	Current user id
        string userId = UserInfo.getUserId();
        //	If Custom setting for user id is available, use that
        if (ASUP_Processing__c.getInstance().User_Id__c != null && ASUP_Processing__c.getInstance().User_Id__c.length() > 0){
            userId = ASUP_Processing__c.getInstance().User_Id__c;
        }
        this.firstRun = firstRun;
        
        //	Query the asup components last modified today and yesterday.
        // Also ignores updates made by the user running the batch, because if nothing is updated since last run, no need process that record
        // asupComponentSN__c != \'Unknown\' Added by Exafort for SFDC-652
        query = 'select asupComponentAccount__c,asupcomponentDiskSled__c, asupComponentAsset__c, asupComponentAsset__r.Product_Name__c, '+
            'asupComponentAsset__r.Parent_Asset__c,asupComponentAsset__r.Parent_Asset__r.Product_Name__c , asupComponentAsset__r.Parent_Asset__r.Dynamic_SKU__c,'+
            'asupComponentAsset__r.Dynamic_SKU__c,asupComponentAssetSN__c, asupComponentSN__c,asupComponentDiskModel__c,asupComponentDiskSizeGB__c,'+
            'asupComponentErrorRate__c,asupComponentFirstASUP__c,asupComponentLastStatusDate__c,asupComponentLocation__c,asupComponentMostRecentASUP__c,'+ 
            'asupComponentDiskShelfSlot__c, asupComponentDiskPortNumber__c, asupComponentControllerState__c, asupComponentType__c,'+ 
            'component_Location__c, Component_Part_Number__c, Board_Part_Number__c, Component_status__c,'+
            'asupComponentDiskUsedState__c, asupComponentControllerLocation__c, asupComponentAssetType__c , asupComponentAssetProductCode__c, asupcomponentMatchedWithComponent__c '+
            'from Asup_Components__c where asupComponentAsset__r.Status = \'Shipped\' and LastModifiedDate = LAST_N_DAYS:1  and '+
            ' lastmodifiedbyid != \'' + userId  + '\' and  ' +
            // Added order by condition for TS-9019
        	//Added ASUP type 'NIC' for TS-6807
        	' (asupComponentType__c in (\'SSD\',\'HDD\',\'Controller\',\'SCM\',\'FC\',\'NIC\') Or (asupComponentType__c in (\'PSU\') AND  asupComponentSN__c != \'Unknown\') ) order by asupComponentAssetSN__c,asupComponentType__c,asupComponentDiskModel__c,asupComponentSN__c,asupComponentMostRecentASUP__c';
        
        //asupComponentType__c != \'NIC\''; TS-6159 modified the filter
        //query += ' and asupComponentType__c = \'Controller\'';
        System.debug('#@ query' + query);
        //query += ' and asupComponentAsset__r.name = \'AF-224265\'';
        //Query the asup components last modified today
        //query = 'select asupComponentAccount__c,asupcomponentDiskSled__c, asupComponentAsset__c, asupComponentAsset__r.Product_Name__c, asupComponentAsset__r.Parent_Asset__c,asupComponentAsset__r.Parent_Asset__r.Product_Name__c , asupComponentAsset__r.Parent_Asset__r.Dynamic_SKU__c,asupComponentAsset__r.Dynamic_SKU__c,asupComponentAssetSN__c, asupComponentSN__c,asupComponentDiskModel__c,asupComponentDiskSizeGB__c,asupComponentErrorRate__c,asupComponentFirstASUP__c,asupComponentLastStatusDate__c,asupComponentLocation__c,asupComponentMostRecentASUP__c, asupComponentDiskShelfSlot__c, asupComponentDiskPortNumber__c, asupComponentControllerState__c, asupComponentType__c, asupComponentDiskUsedState__c, asupComponentControllerLocation__c, asupComponentAssetType__c , asupComponentAssetProductCode__c from Asup_Components__c where asupComponentAsset__r.Status = \'Shipped\' and LastModifiedDate = TODAY  and asupComponentType__c != \'NIC\'';
        //query = 'select asupComponentAccount__c,asupcomponentDiskSled__c, asupComponentAsset__c, asupComponentAssetSN__c, asupComponentSN__c,asupComponentDiskModel__c,asupComponentDiskSizeGB__c,asupComponentErrorRate__c,asupComponentFirstASUP__c,asupComponentLastStatusDate__c,asupComponentLocation__c,asupComponentMostRecentASUP__c, asupComponentDiskShelfSlot__c, asupComponentDiskPortNumber__c, asupComponentControllerState__c, asupComponentType__c, asupComponentDiskUsedState__c, asupComponentControllerLocation__c, asupComponentAssetType__c, asupComponentAsset__r.Product_Name__c, asupComponentAsset__r.Parent_Asset__c, asupComponentAsset__r.Parent_Asset__r.Dynamic_SKU__c, asupComponentAssetProductCode__c from Asup_Components__c where asupComponentAsset__r.Status = \'Shipped\' and LastModifiedDate = TODAY and asupComponentType__c != \'NIC\'';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('#@ scope' + scope);
        List<Asup_Components__c> asupComponentRecords = scope;     
        Map<String,String> modelToSRMap = new Map<String,String>();    
        //Map<String,String> modelwithAsstToSRMap = new Map<String,String>();
        Map<String,List<String>> modelwithAsstToSRMap = new Map<String,List<String>>();
        Map<string, string> modelWithAssetTypeSRMapFinal = new Map<string, string>();
        Map<String,String> modelWithProductCode = new Map<String,String>();
        Map<String,String> modelToSRMapProductName = new Map<String,String>();
        Map<String,String> modelToSRMapDynamicSKU = new Map<String,String>();
        Map<Id,List<Asup_Components__c>> asstWithAsupComp = new Map<Id,List<Asup_Components__c>>();
        // Map<Id,List<Asup_Components__c>> acctWithAsupComp = new Map<Id,List<Asup_Components__c>>();
        Map<Id,List<Component__c>> asstWithComp = new Map<Id,List<Component__c>>();
        Map<Id,List<Component__c>> acctWithComp = new Map<Id,List<Component__c>>();
        Set<Id> acctIds = new Set<Id>();
        Map<Id,Id> asstToAcct = new Map<Id,Id>();
        List<String> srProductName = new List<String>(); //list to add sr product names
        
        for(Asup_Components__c ac : asupComponentRecords)
        {
            if(ac.asupComponentAsset__c != null)
            {
                List<Asup_Components__c> asupCompList = asstWithAsupComp.get(ac.asupComponentAsset__c);
                if(asupCompList == null)
                    asupCompList = new List<Asup_Components__c>();
                asupCompList.add(ac);
                asstWithAsupComp.put(ac.asupComponentAsset__c,asupCompList); 
                
            }
            if(ac.asupComponentAccount__c != null)
            {
                acctIds.add(ac.asupComponentAccount__c);
                asstToAcct.put(ac.asupComponentAsset__c,ac.asupComponentAccount__c);
                /* List<Asup_Components__c> asupCompList = acctWithAsupComp.get(ac.asupComponentAccount__c);
                if(asupCompList == null)
                asupCompList = new List<Asup_Components__c>();
                asupCompList.add(ac);
                acctWithAsupComp.put(ac.asupComponentAccount__c,asupCompList);  */           
            }
        }
        
        //Query the existing components fro the assets
        //Added componentType__c type 'FC','NIC' and 'NIC_CARD' for TS-6855
        ////Added componentType__c 'SFP' for TS-6807
        List<Asset> asstList = [select Id, AccountId, Product_Name__c,ProductCode__c, Parent_Asset__c, Parent_Asset__r.Product_Name__c,Parent_Asset__r.Dynamic_SKU__c, (select Id, componentComponentSN__c, componentServicePartNumber__c, componentDiskModel__c, componentAsset__c, componentProcessedByFLEX__c, componentState__c, componentType__c from Components__r where componentType__c in ('SCM','SSD','HDD','Controller','Other','PWR(power supply)','NIC','NIC_CARD','FC','SFP')) from Asset where Id in :asstWithAsupComp.keySet()];
        
        for(Asset a : asstList)
        {
            List<Component__c> compList = a.Components__r;
            
            asstWithComp.put(a.Id,compList);  // List of components for incoming asup asset id
        }
        system.debug('#@ asstWithComp'+ asstWithComp);
        //Query the existing components fro the accounts
        //Added componentType__c type 'FC','NIC' and 'NIC_CARD' for TS-6855
        //Added componentType__c 'SFP' for TS-6807
        List<Account> acctList = [select Id, (select Id, componentComponentSN__c, componentServicePartNumber__c, componentDiskModel__c, componentAsset__c, componentProcessedByFLEX__c, componentState__c, componentType__c from Components__r where componentType__c in ('SCM','SSD','HDD','Controller','Other','PWR(power supply)','NIC','NIC_CARD','FC','SFP') and componentAsset__c = null) from Account where Id in :acctIds];
        for(Account a : acctList)
        {
            List<Component__c> compList = a.Components__r;
            acctWithComp.put(a.Id,compList); // List of components for incoming asup account id
        }   
        //Query object to get the SR numbers from the components with the modelnums     
        
        List<SR_Meta_Data__c> metaDataList = [select Id, srModelNumbers__c, srPart__c, srAssetType__c, srProduct_Name__c, srDynamicSKU__c, srProductCode__c, srType__c from SR_Meta_Data__c where srPart__c != null AND srmetadataIsValid__c = true];
        
        
        Map<String,List<String>> modelwithAsstToSRMapHelper = new Map<String,List<String>>();
        Map<string, string> modelNumberWithAssetTypeValue = new Map<string, string>();
        string temp;
        
        for(SR_Meta_Data__c md : metaDataList)
        {
            
            if(md.srModelNumbers__c != null)
            {
                List<String> mNums = new List<String>();
                if(md.srModelNumbers__c.contains(',')){
                    mNums = md.srModelNumbers__c.split(',');
                }
                else{
                    mNums.add(md.srModelNumbers__c);
                    system.debug('mNums --> ' + mNums);
                }
                // }
                List<String> aTypes = new List<String>();
                if(md.srAssetType__c != null){
                    aTypes = md.srAssetType__c.split(',');
                }
                for(String m : mNums)
                {
                    m = m.trim();
                    system.debug('m --> ' + m);
                    //Check whether the incoming key is already exist in map or not.
                    //If Exist, the key is repeating and we should add it to repeatedMap(modelwithAsstToSRMap),
                    //Else, the key is unique one.
                    if(modelToSRMap.containsKey(m)){
                        system.debug('Entered into contains');
                        // In this block, we know the key is not unique
                        
                        // We can't remove the repeated value yet; otherwise, the next time(third time)
                        //   the same key comes up, we'll think it's unique again.
                        String val = modelToSRMap.get(m); //take the value from previously inserted key
                        
                        string assetTypeOfUnique = modelNumberWithAssetTypeValue.get(m); //take asset type from the previously inserted key to loop through Asset type to form ModelNumber+AssetType key
                        
                        List<String> splittedAssetTypes = new List<String>();  //to hold the splitted asset types from the previous key
                        if(assetTypeOfUnique != null && assetTypeOfUnique.contains(',')){
                            splittedAssetTypes = assetTypeOfUnique.split(',');
                        }
                        else if(assetTypeOfUnique != null && !assetTypeOfUnique.contains(',')){
                            splittedAssetTypes.add(assetTypeOfUnique);
                        }
                        
                        for(String assetTy : splittedAssetTypes){
                            assetTy=assetTy.trim();
                            modelwithAsstToSRMap.put(m+assetTy, new List<String>{val});  //insert the previous key with assettype and its value in the repeated map.
                        	system.debug('Asset to SR Map'+modelwithAsstToSRMap.put(m+assetTy, new List<String>{val}));
                        }
                        // We only want to put the value for the key we now know is not unique
                        //   into repeatedMap's list of values once.
                        // Probably the simplest way to do that is to add the value from the UniqueMap(modelToSRMap)
                        //   when we first add the key to repeatedMap
                        
                        /****below lines are used to remove the repeated keys from Unique Map*/
                        if(!modelwithAsstToSRMapHelper.containsKey(m)){
                            
                            modelwithAsstToSRMapHelper.put(m, new List<String>{md.srPart__c});
                        }
                        modelwithAsstToSRMapHelper.get(m).add(md.srPart__c);
                        /*********/
                        
                        for(String a: aTypes){
                            a=a.trim();
                            if(!modelwithAsstToSRMap.containsKey(m+a)){
                                
                                modelwithAsstToSRMap.put(m+a, new List<String>{val});
                                system.debug('Line 172'+modelwithAsstToSRMap.put(m+a, new List<String>{val}));
                            }
                            modelwithAsstToSRMap.get(m+a).add(md.srPart__c);
                            system.debug('Line 175'+modelwithAsstToSRMap.get(m+a).add(md.srPart__c));
                            //modelwithAsstToSRMap.put(m+a, new List<String>{md.srPart__c});
                        }
                        
                        
                    }else{
                        // Nothing else to do for now but assume that the key is unique
                        modelToSRMap.put(m, md.srPart__c);
                        modelNumberWithAssetTypeValue.put(m, md.srAssetType__c); //helper repeated map to remove the keys from unique map.
                    }
                    if(md.srProductCode__c != null){
                        List<String> aProductCode = md.srProductCode__c.split(',');
                        for(String codes : aProductCode){
                            modelWithProductCode.put(codes, md.srPart__c);
                        }
                    }
                    /*if(md.srType__c == 'NIC'){
                         modelToSRMap.put(m, md.srPart__c);
                    }*/
                }
            }
            
            /*Controller update logic with product name */
            else if(md.srModelNumbers__c == null){
                if(md.srProduct_Name__c != null && md.srProduct_Name__c != '' && md.srType__c == 'Controller'){
                    srProductName = new list<string>();// Added by exafort on June 8 2021 for TS-8187
                    
                    if(md.srProduct_Name__c.contains(',')){
                        
                        srProductName = md.srProduct_Name__c.split(',');
                        system.debug('split sr metadata prd name'+md.srProduct_Name__c.split(','));
                        
                    }
                    else{
                        
                        srProductName.add(md.srProduct_Name__c);
                    }
                    system.debug('srProductName'+srProductName);
                    for(String mProductName : srProductName)
                    {
                        if(md.srDynamicSKU__c == null){
                             system.debug('srProductName 123'+srProductName);
                            modelToSRMapProductName.put(mProductName.trim(), md.srPart__c);
                            system.debug('modelToSRMapProductName'+ modelToSRMapProductName.put(mProductName.trim(), md.srPart__c));
                            
                        }                
                        else if(md.srDynamicSKU__c != null){
                            modelToSRMapDynamicSKU.put(md.srDynamicSKU__c, md.srPart__c);
                        }
                    }
                } 
            }
        }
        // map.keySet() returns a set containing all of the keys of the map 
        // Sets have a removeAll() method that removes all items in the set passed 
        //   as a parameter from the set that called the method.
        // Removing items from a map's keyset removes both the key and the value from the map
        modelToSRMap.keySet().removeAll(modelwithAsstToSRMapHelper.keySet());
        
        for(string s: modelToSRMap.keySet()){
            system.debug('@@@@ '+s+'=>'+modelToSRMap.get(s));
        }
        for(string s: modelwithAsstToSRMap.keySet()){
            system.debug('#### '+s+'=>'+modelwithAsstToSRMap.get(s));
        }
        for(string s:modelWithProductCode.keySet()){
            system.debug('$$$$ '+s+'=>'+modelWithProductCode.get(s));
        }
        
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
        /* END --- */
        
        for(string s:modelWithAssetTypeSRMapFinal.keySet()){
            system.debug('~~~~modelWithAssetTypeSRMapFinal '+s+'=>'+modelWithAssetTypeSRMapFinal.get(s));
        }
        
        for(Id asstid : asstWithAsupComp.keySet()) //looping with incoming asup Asset ID's
        {
            List<Asup_Components__c> asupCompList = asstWithAsupComp.get(asstid); //returns list of asup components for an asset
            List<Component__c> compList = asstWithComp.get(asstid); //returns list of components for an asset
            //Pradeep 6/21
            Set<Id> compIds = new Set<Id>();
            for(Component__c c : compList)
            {
                compIds.add(c.Id);
            }
            Id acctId = asstToAcct.get(asstid); //returns account for an asset
            if(acctId != null)
            {
                List<Component__c> compListForAcct = acctWithComp.get(acctId); //returns list of components for an Account
                //Pradeep 6/21
                for(Integer i = 0; i < compListForAcct.size(); i++)
                {
                    Component__c cA = compListForAcct.get(i);
                    if(compIds.contains(cA.Id))
                        compListForAcct.remove(i);
                }
                compList.addAll(compListForAcct);
            }
            system.debug('#@ asupCompList ==>' +asupCompList );
            system.debug('#@ asupCompList Size ==>' +asupCompList.size());
            system.debug('#@ compList ==>' +compList );
            system.debug('#@ compList Size ==>' +compList.size());
            system.debug('#@ modelToSRMap ==>' +modelToSRMap );
            system.debug('#@ modelToSRMap Size ==>' +modelToSRMap.size());
            system.debug('#@ modelWithProductCode ==>' +modelWithProductCode );
            system.debug('#@ modelWithProductCode Size ==>' +modelWithProductCode.size());
            system.debug('#@ firstRun ==>' +firstRun);
            ProcessAsupComponent_Batch_Util.processAsupForAccountOrAsset(asupCompList,compList,modelToSRMap,modelWithProductCode,modelWithAssetTypeSRMapFinal,modelToSRMapProductName,modelToSRMapDynamicSKU,firstRun);        
        }
        
        /* for(Id acctid : acctWithAsupComp.keySet())
        {
        List<Asup_Components__c> asupCompList = acctWithAsupComp.get(acctid);
        List<Component__c> compList = acctWithComp.get(acctid);
        ProcessAsupComponent_Batch_Util.processAsupForAccountOrAsset(asupCompList,compList,modelToSRMap,firstRun);        
        }*/
        
        List<Component__c> compsToInsert = ProcessAsupComponent_Batch_Util.compsToInsert;
        List<Component__c> controllerCompUpdate = ProcessAsupComponent_Batch_Util.controllerCompUpdate;
        List<Component__c> compsToUpdate = ProcessAsupComponent_Batch_Util.compsToUpdate.values();
        List<Asup_Components__c> asupsToUpdate =  ProcessAsupComponent_Batch_Util.asupsToUpdate;
        
        system.debug('#@ compsToInsert.size()==' + compsToInsert.size() + compsToInsert);
        system.debug('#@ compsToUpdate.size()==' + compsToUpdate.size() + compsToUpdate);
        if(compsToInsert.size() > 0)
            insert compsToInsert;
        
        if(controllerCompUpdate.size() >0)
            update controllerCompUpdate;
        
        if(compsToUpdate.size() > 0)
            update compsToUpdate;
        
        if(asupsToUpdate.size() > 0)
            update asupsToUpdate;
    }
    
    public void finish(Database.BatchableContext BC){
        // Batch finished
        // Exclude_From_Unlinking__c added for TS-9121
        // componentAsset__r.Support_Profile__c = 'Legacy Nimble' Added by Exafort for TS-10050
       boolean runUnlinking = ASUP_Processing__c.getInstance().Run_Component_Unlinking_Logic__c; //Added for TS-9121
        if(runUnlinking){
            //string query = 'select id, componentState__c, Sub_State__c, componentAsset__c, componentAsset_ASUP_Last_Received__c,componentMostRecentASUP__c,componentNoOfDaysBetweenAssetAndComp__c  from component__c where componentNoOfDaysBetweenAssetAndComp__c > 8 and componentAsset__r.Exclude_From_Unlinking__c = false';
            string query ='select id, componentState__c, Sub_State__c, componentAsset__c, componentAsset_ASUP_Last_Received__c,componentMostRecentASUP__c,'+
                'componentNoOfDaysBetweenAssetAndComp__c  from component__c ' + 
                'where componentNoOfDaysBetweenAssetAndComp__c > 8 and componentAsset__r.Exclude_From_Unlinking__c = false and componentAsset__r.Support_Profile__c = \'Legacy Nimble\'';
                ComponentStatusAndAssetUnlinkUpdateBatch component = new ComponentStatusAndAssetUnlinkUpdateBatch(query);
            system.debug('calling unlinking with SOQL ' + query);
            Database.executeBatch(component, 10);
        }
    }
}