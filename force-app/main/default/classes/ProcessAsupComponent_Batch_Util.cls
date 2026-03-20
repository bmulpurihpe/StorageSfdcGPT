public class ProcessAsupComponent_Batch_Util
{
    public static List<Component__c> compsToInsert = new List<Component__c>();
    public static List<Component__c> controllerCompUpdate = new List<Component__c>();
    public static List<Asup_Components__c> asupsToUpdate = new List<Asup_Components__c>();
    public static Map<Id,Component__c> compsToUpdate = new Map<Id,Component__c>();
    public static Map<String,String> modelToSRMapMaster = new Map<String,String>();
    public static Map<String,String> modelwithAsstToSRMapMaster = new Map<String,String>();
    public static List<Asup_Components__c> asupCompListMaster = new List<Asup_Components__c>();
    public static List<Component__c> compListMaster = new List<Component__c>();
    public static Map<String,String>  modelWithProductCodeMaster = new Map<String,String>();
    public static   Map<String,String> modelToSRMapProductNameMaster = new Map<String,String>();
    public static Map<String,String> modelToSRMapDynamicSKUMaster = new Map<String,String>();
    
    
    public static void processAsupForAccountOrAsset(List<Asup_Components__c> asupCompList, List<Component__c> compList,
                                                    Map<String,String> modelToSRMap,
                                                    Map<String,String> modelWithProductCode,
                                                    Map<String,String> modelwithAsstToSRMap,
                                                    Map<String,String> modelToSRMapProductName
                                                    ,Map<String,String> modelToSRMapDynamicSKU,Boolean firstRun)
    {
         
        // Added by exafort for TS-8177 on May 13 2021 START
        asupCompListMaster = asupCompList;
        compListMaster = compList;
        modelWithProductCodeMaster = modelWithProductCode;
        modelToSRMapProductNameMaster = modelToSRMapProductName;
        modelToSRMapDynamicSKUMaster = modelToSRMapDynamicSKU;
        modelToSRMapMaster = modelToSRMap;
        modelwithAsstToSRMapMaster= modelwithAsstToSRMap;
        
          // Added by exafort for TS-8177 on May 13 2021 END
          // 
        Map<String,Asup_Components__c> asupComponentMap = new Map<String,Asup_Components__c>();
        Map<String,Component__c> compMap = new Map<String,Component__c>();
        List<Component__c> compWithNoSN = new List<Component__c>();        
        for(Asup_Components__c aComp : asupCompList) //looping list of asup components for an Asset
        {
            if(aComp.asupComponentSN__c != null)
                asupComponentMap.put(aComp.asupComponentSN__c,aComp); // TS-6957 updated the map key from aComp.asupComponentSN__c to SN+Asset to hold unique AsupComponent 
            system.debug('asupComponentMap.put(aComp.asupComponentSN__c,aComp) '+ asupComponentMap.put(aComp.asupComponentSN__c,aComp));
        }
        for(Component__c comp : compList)
        {
            if(comp.componentComponentSN__c != null)             
                compMap.put(comp.componentComponentSN__c,comp); // TS-6957 updated the map key from Comp.asupComponentSN__c to SN+Asset to hold unique Component
            
            else
                compWithNoSN.add(comp);
        } 
        
        system.debug('compWithNoSN '+ compWithNoSN);
        //Iterate the AsupComponent snnumber set to update or insert components
        for(String snum : asupComponentMap.keySet())
        {
            //Construct the component objects to either insert or update
            Asup_Components__c v = asupComponentMap.get(snum);
            string originalAsupcomponentMatchedWithComponent = v.asupcomponentMatchedWithComponent__c; //Added by Exafort for TS-9019
			system.debug('asupcomponentMatchedWithComponent__c = '  + v.asupcomponentMatchedWithComponent__c);
            Component__c c = compMap.get(snum);        	
            system.debug(' c value -->'+c);
            if(c == null)
            {               
                Set<String> compSNSet = compMap.keySet();
                for(String s : compSNSet)
                {                    
                    if(snum.contains(s))
                    {
                        c = compMap.get(s);
                        break;
                    }
                }
            }
            Component__c cr_up_comp = new Component__c();
            populateComponent(v,cr_up_comp);
            system.debug(' c value -->'+c);
            if(c == null)
            {
                if(!firstRun)
                {
                    Boolean upFlag = false;
                    if(compWithNoSN != null && compWithNoSN.size() > 0)
                    {
                        for(Integer i = 0; i < compWithNoSN.size(); i++)
                        {
                            Component__c c1 = compWithNoSN.get(i);
                            
                            /****Added below lines to loop through the Map List to return string to check****/
                           // c1.componentServicePartNumber__c = modelwithAsstToSRMap.get(v.asupComponentDiskModel__c+v.asupComponentAssetType__c);
                            string asupDisKmodel = '';
                            string asupAssetType = '';
                            string asupCompPart = '';
                            
                            if(v.asupComponentDiskModel__c != null)
                                asupDisKmodel = v.asupComponentDiskModel__c.trim();
                            
                            if(v.asupComponentAssetType__c != null)
                                asupAssetType = v.asupComponentAssetType__c.trim();
                            
                            if(v.Component_Part_Number__c != null)
                                asupCompPart = v.Component_Part_Number__c.trim();
                                                                                  
                            if(!upFlag && c1.componentServicePartNumber__c != null && v.asupComponentDiskModel__c != null &&
                               (c1.componentServicePartNumber__c == modelToSRMap.get(v.asupComponentDiskModel__c) ||
                                c1.componentServicePartNumber__c == modelWithProductCode.get(v.asupComponentAssetProductCode__c))){
                                cr_up_comp.Id = c1.Id; 
                                populateStateAndSubState(v,cr_up_comp,c1);
                                compsToUpdate.put(cr_up_comp.Id,cr_up_comp);
                                compWithNoSN.remove(i);
                                upFlag = true;                                
                                v.asupcomponentMatchedWithComponent__c = 'Yes-ModelNumber';                              
                            }
                            
                            if(!upFlag && c1.componentServicePartNumber__c != null && v.asupComponentDiskModel__c != null &&
                               (c1.componentServicePartNumber__c == modelToSRMap.get(v.asupComponentDiskModel__c) ||
                                c1.componentServicePartNumber__c == modelwithAsstToSRMap.get(asupDisKmodel+asupAssetType)))
                                //modelwithAsstToSRMap.get(v.asupComponentDiskModel__c+v.asupComponentAssetType__c
                            {
                                //&& modelWithProductCode.get(v.asupComponentAssetProductCode__c) == null
                                cr_up_comp.Id = c1.Id; 
                                populateStateAndSubState(v,cr_up_comp,c1);
                                compsToUpdate.put(cr_up_comp.Id,cr_up_comp);
                                compWithNoSN.remove(i);
                                upFlag = true;
                                v.asupcomponentMatchedWithComponent__c = 'Yes-ModelNumber';
                              
                            } 
                            /*Controller component update logic* added on 25th Jul 2016 */
                            
                            if(!upFlag && c1.componentType__c == 'Controller' && c1.componentComponentSN__c == null && v.asupComponentType__c =='Controller' && v.asupComponentSN__c != null){
                                populateStateAndSubState(v,cr_up_comp,c1);
                                c1.componentComponentSN__c = v.asupComponentSN__c;                              
                                controllerCompUpdate.add(c1);
                                compWithNoSN.remove(i);
                                upFlag = true;
                                v.asupcomponentMatchedWithComponent__c = 'No-Controller Component Updated';
                            }
                            if(!upFlag && c1.componentType__c == 'PWR(power supply)' 
                               && c1.componentComponentSN__c == null && v.asupComponentType__c =='PSU' && v.asupComponentSN__c != null){
                                //v.asupComponentType__c =='PWR(power supply)'
                                cr_up_comp.Id = c1.Id; 
                                populateStateAndSubState(v,cr_up_comp,c1);
                                compsToUpdate.put(cr_up_comp.Id,cr_up_comp);
                                compWithNoSN.remove(i);
                                upFlag = true;
                                v.asupcomponentMatchedWithComponent__c = 'No-PSU Component Updated';
                            }
                        }          
                    }
                    // Case 4: To create new components if there is no component existing with componentSN  
                    if(!upFlag)
                    {
                        populateStateAndSubState(v,cr_up_comp,null);
                        cr_up_comp.componentAppearAfterInstallation__c = true;
                        system.debug(' Asup Disk Model -->'+v.asupComponentDiskModel__c);
                        system.debug(' Asup Asset type -->'+v.asupComponentAssetType__c);
                        string asupDisKmodel = '';
                        string asupAssetType = '';
                        if(v.asupComponentDiskModel__c != null)
                            asupDisKmodel = v.asupComponentDiskModel__c.trim();
                        
                        if(v.asupComponentAssetType__c != null)
                            asupAssetType = v.asupComponentAssetType__c.trim();
                        
                        //Condition(asupDisKmodel != '' && !string.isEmpty(asupDisKmodel)) added by exafort for TS-8177 on May 13 2021 
                        if( asupDisKmodel != '' && !string.isEmpty(asupDisKmodel) && modelToSRMap.get(asupDisKmodel) != null){
                            system.debug('### into else if 126');
                            system.debug('### into else if 126 1 '+ modelToSRMap.get(v.asupComponentDiskModel__c));
                            cr_up_comp.componentServicePartNumber__c = modelToSRMap.get(v.asupComponentDiskModel__c); 
                            v.asupcomponentMatchedWithComponent__c = 'No';
                        }
                        // else if(modelwithAsstToSRMap.get(v.asupComponentDiskModel__c+v.asupComponentAssetType__c) != null){
                        //cr_up_comp.componentServicePartNumber__c = modelwithAsstToSRMap.get(v.asupComponentDiskModel__c+v.asupComponentAssetType__c);
                        // v.asupcomponentMatchedWithComponent__c = 'No';
                        // }
                        
                       
                        else if(modelwithAsstToSRMap.get(asupDisKmodel+asupAssetType) != null){
                            system.debug('asupDisKmodel+asupAssetType '+ asupDisKmodel+asupAssetType);
                            system.debug('(modelwithAsstToSRMap.get(asupDisKmodel+asupAssetType) '+ modelwithAsstToSRMap.get(asupDisKmodel+asupAssetType));
                            cr_up_comp.componentServicePartNumber__c = modelwithAsstToSRMap.get(asupDisKmodel+asupAssetType);
                            v.asupcomponentMatchedWithComponent__c = 'No';
                            system.debug('### into else if 137');
                            system.debug('### into else if 137 cr_up_comp.componentServicePartNumber__c '+ cr_up_comp);
                        }
                        //v.asupComponentType__c == 'SCM' added for TS-5900
                        else if(modelWithProductCode.get(v.asupComponentAssetProductCode__c) != null && (v.asupComponentType__c == 'SSD' || v.asupComponentType__c == 'SCM')){
                        	system.debug('### into else if 176');
                            system.debug('modelWithProductCode ' + modelWithProductCode);
                            system.debug('v.asupComponentAssetProductCode__c ' + v.asupComponentAssetProductCode__c);
                            system.debug('modelWithProductCode.get(v.asupComponentAssetProductCode__c) '+ modelWithProductCode.get(v.asupComponentAssetProductCode__c));
                            cr_up_comp.componentServicePartNumber__c = modelWithProductCode.get(v.asupComponentAssetProductCode__c); 
                            v.asupcomponentMatchedWithComponent__c = 'No';
                            if(v.asupComponentType__c == 'SCM' && cr_up_comp.componentDiskModel__c == null){
                                cr_up_comp.componentDiskModel__c = 'INTEL SSDPED1K015TA';
                                system.debug('Setting componentDiskModel__c to ' + cr_up_comp.componentDiskModel__c);
                            }
                        } 
                         
                        // Added by exafort for TS-8177 on May 13 2021 START
                         else if(v.Component_Part_Number__c != null && modelToSRMap.get(v.Component_Part_Number__c) != null && v.asupComponentType__c == 'PSU'){                             
                            cr_up_comp.componentServicePartNumber__c = modelToSRMap.get(v.Component_Part_Number__c); 
                            v.asupcomponentMatchedWithComponent__c = 'No';
                        }   // Added by exafort for TS-8177 on May 13 2021 END
                        /*controller insert logic*/
                        else if(modelToSRMap.get(v.asupComponentDiskModel__c) == null && v.asupComponentType__c == 'Controller' && v.asupComponentAsset__c != null){
                            system.debug('### into else if 152');
                            // added by Exafort for TS-8515
                            //controller type component creation with service part number
                            if(cr_up_comp.componentServicePartNumber__c == null && modelToSRMapProductNameMaster.get(v.asupComponentAssetProductCode__c) != null){
                                system.debug('##  Entered into the if condition line - 191');
                                cr_up_comp.componentServicePartNumber__c  = modelToSRMapProductNameMaster.get(v.asupComponentAssetProductCode__c);
                                v.asupcomponentMatchedWithComponent__c = 'No';
                            }
                            //end of TS-8515
                            else if(modelToSRMapProductName.get(v.asupComponentAsset__r.Product_Name__c) != null && !modelToSRMapProductName.get(v.asupComponentAsset__r.Product_Name__c).contains('CS215')){
                                cr_up_comp.componentServicePartNumber__c = modelToSRMapProductName.get(v.asupComponentAsset__r.Product_Name__c);
                                v.asupcomponentMatchedWithComponent__c = 'No-Inserted Component - Product Name is Found';
                            }
                            else if(modelToSRMapProductName != null && modelToSRMapProductName.get(v.asupComponentAsset__r.Product_Name__c) == null &&
                                    v.asupComponentAsset__r.Product_Name__c != null && v.asupComponentAsset__r.Product_Name__c.contains('CS215')){
                                if(v.asupComponentAsset__r.Parent_Asset__c != null && v.asupComponentAsset__r.Parent_Asset__r.Dynamic_SKU__c != null){
                                    string dynamicSKU = v.asupComponentAsset__r.Parent_Asset__r.Dynamic_SKU__c;
                                    string trimmedDynamicSKU = dynamicSKU.substring(0, 8);
                                    if(modelToSRMapDynamicSKU.get(trimmedDynamicSKU) != null){
                                        cr_up_comp.componentServicePartNumber__c = modelToSRMapDynamicSKU.get(trimmedDynamicSKU);
                                        v.asupcomponentMatchedWithComponent__c = 'No-Inserted Component-Dynamic SKU is Found';
                                    }
                                    else{
                                        cr_up_comp.componentServicePartNumber__c = null;
                                        v.asupcomponentMatchedWithComponent__c = 'No-Inserted Component-SR Dynamic SKU is NOT Found';
                                    }
                                }
                                else{
                                    cr_up_comp.componentServicePartNumber__c = null;
                                    v.asupcomponentMatchedWithComponent__c = 'No-Inserted Component-Parent Asset Dynamic Sku is Not Found';
                                }
                            }
                            else if(modelToSRMapProductName!= null && modelToSRMapProductName.get(v.asupComponentAsset__r.Product_Name__c) == null && v.asupComponentAsset__r.Product_Name__c != null && !v.asupComponentAsset__r.Product_Name__c.contains('CS215')){
                                cr_up_comp.componentServicePartNumber__c = null;
                                v.asupcomponentMatchedWithComponent__c = 'No-Inserted Component-Product Name is Not Found';
                            }
                        }                            
                        // added type "FC" by Exafort for TS-6855
                        // added type "NIC" by Exafort for TS-6807
                        else if(modelToSRMapMaster.get(v.Component_Part_Number__c) != null && v.Component_Part_Number__c != null && (v.asupComponentType__c == 'FC' || v.asupComponentType__c == 'NIC')){
                            cr_up_comp.componentServicePartNumber__c = modelToSRMapMaster.get(v.Component_Part_Number__c);
                            v.asupcomponentMatchedWithComponent__c = 'No';                                                        
                        }
                        // End of TS-6855
                        else 
                        {
                            cr_up_comp.componentServicePartNumber__c = null;
                            system.debug('### into final else');
                        }                            
                        compsToInsert.add(cr_up_comp);
                        //v.asupcomponentMatchedWithComponent__c = 'No';
                    }
                }
            }
            else 
            {
                cr_up_comp.Id = c.Id;
                populateStateAndSubState(v,cr_up_comp,c);
               //updateComponentServicePartNumber
                system.debug('### into final SN else');
                //Case 2: Update the existing component with SR number if empty
                compsToUpdate.put(cr_up_comp.Id,cr_up_comp); //Case 1 and 2: Update the existing components with data from ASUPComponent
                v.asupcomponentMatchedWithComponent__c = 'Yes-SeriallNumber';
            }
            //	Update is needed only if the value is different //Added by Exafort for TS-9019
            if (originalAsupcomponentMatchedWithComponent != v.asupcomponentMatchedWithComponent__c){
				asupsToUpdate.add(v);
            }
            
        }
    }
    
    public static void populateComponent(Asup_Components__c v, Component__c cr_up_comp)
    {
        cr_up_comp.componentAccountId__c = v.asupComponentAccount__c;
        cr_up_comp.componentAsset__c= v.asupComponentAsset__c;
        cr_up_comp.componentAssetSN__c = v.asupComponentAssetSN__c;
        cr_up_comp.componentComponentSN__c = v.asupComponentSN__c;      
        cr_up_comp.componentDiskSizeGB__c = v.asupComponentDiskSizeGB__c;
        cr_up_comp.componentDiskModel__c = v.asupComponentDiskModel__c;
        cr_up_comp.componentDisksled__c = v.asupComponentDisksled__c;
        cr_up_comp.componentErrorRate__c = v.asupComponentErrorRate__c;
        cr_up_comp.componentFirstASUP__c = v.asupComponentFirstASUP__c;
        cr_up_comp.componentLastStatusDate__c = v.asupComponentLastStatusDate__c;
        //Commented by vishnu for TS-7717
        //if(v.asupComponentType__c == 'Controller')
        //    cr_up_comp.componentLocation__c = v.asupComponentControllerLocation__c;
        //else
        //cr_up_comp.componentLocation__c = v.asupComponentLocation__c;
        /*Added by vishnu for TS-7717*/
        cr_up_comp.componentLocation__c = v.component_Location__c;
        cr_up_comp.componentPartNumber__c = v.Component_Part_Number__c;
        cr_up_comp.componentBoardPartNumber__c = v.Board_Part_Number__c;
        cr_up_comp.componentMostRecentASUP__c = v.asupComponentMostRecentASUP__c;
        cr_up_comp.componentDiskShelfSlot__c = v.asupComponentDiskShelfSlot__c;
        cr_up_comp.componentDiskPortNumber__c = v.asupComponentDiskPortNumber__c;
        cr_up_comp.componentASUPProcessed__c = true;
        if(v.asupComponentType__c == 'PSU'){
            cr_up_comp.componentType__c = 'PWR(power supply)';
        }else{
            cr_up_comp.componentType__c = v.asupComponentType__c;
        }
    }
    
    // Added by exafort for TS-8177 on May 13 2021 START
    public static string updateComponentServicePartNumber(Asup_Components__c v,Component__c cr_up_comp,Component__c existingComp1)
    {    
        system.debug('Model To SR'+modelToSRMapMaster.get(v.asupComponentDiskModel__c));
        system.debug('modelWithProductCodeMaster' + modelWithProductCodeMaster);
        system.debug('modelToSRMapMaster.get(v.Component_Part_Number__c) '+ modelToSRMapMaster.get(v.Component_Part_Number__c));
        if(modelToSRMapMaster.get(v.asupComponentDiskModel__c) != null){  
            cr_up_comp.componentServicePartNumber__c = modelToSRMapMaster.get(v.asupComponentDiskModel__c);              
        }
        // added type "FC" by Exafort for TS-6855
        // added type "NIC" by Exafort for TS-6807
        else if(modelToSRMapMaster.get(v.Component_Part_Number__c) != null && v.Component_Part_Number__c != null && (v.asupComponentType__c == 'FC' || v.asupComponentType__c == 'NIC')){
            cr_up_comp.componentServicePartNumber__c = modelToSRMapMaster.get(v.Component_Part_Number__c);
        }
        // End of TS-6855
        else if(modelwithAsstToSRMapMaster.get(v.asupComponentDiskModel__c+v.asupComponentAssetType__c) != null){  
            cr_up_comp.componentServicePartNumber__c = modelwithAsstToSRMapMaster.get(v.asupComponentDiskModel__c+v.asupComponentAssetType__c);                        
        }
        //v.asupComponentType__c == 'SCM' added for TS-5900
        else if(modelWithProductCodeMaster.get(v.asupComponentAssetProductCode__c) != null && (v.asupComponentType__c == 'SSD' || v.asupComponentType__c == 'SCM')){
            system.debug('Entered line 292');
            cr_up_comp.componentServicePartNumber__c = modelWithProductCodeMaster.get(v.asupComponentAssetProductCode__c); 
            if(v.asupComponentType__c == 'SCM' && cr_up_comp.componentDiskModel__c == null){
                cr_up_comp.componentDiskModel__c = 'INTEL SSDPED1K015TA';
                system.debug('Setting componentDiskModel__c to ' + cr_up_comp.componentDiskModel__c);
            }
        }
        // Added by exafort for TS-8177 on May 13 2021 - else if
        else if((v.asupComponentType__c == 'Controller' || v.asupComponentType__c == 'PSU') && v.Component_Part_Number__c != null && modelToSRMapMaster.get(v.Component_Part_Number__c) !=null ){
            cr_up_comp.componentServicePartNumber__c = modelToSRMapMaster.get(v.Component_Part_Number__c);
        }
        else if(modelToSRMapMaster.get(v.asupComponentDiskModel__c) == null && v.asupComponentType__c == 'Controller' && v.asupComponentAsset__c != null){ 
            if(modelToSRMapProductNameMaster.get(v.asupComponentAsset__r.Product_Name__c) != null && !modelToSRMapProductNameMaster.get(v.asupComponentAsset__r.Product_Name__c).contains('CS215'))
            {
                string srPartNumber = modelToSRMapProductNameMaster.get(v.asupComponentAsset__r.Product_Name__c);
                if( srPartNumber != null){
                    cr_up_comp.componentServicePartNumber__c = srPartNumber;
                }
                
            }  
            else if(modelToSRMapProductNameMaster != null && modelToSRMapProductNameMaster.get(v.asupComponentAsset__r.Product_Name__c) == null 
                    && v.asupComponentAsset__r.Product_Name__c != null && v.asupComponentAsset__r.Product_Name__c.contains('CS215'))
            {
                if(v.asupComponentAsset__r.Parent_Asset__c != null && v.asupComponentAsset__r.Parent_Asset__r.Dynamic_SKU__c != null){
                    string dynamicSKU = v.asupComponentAsset__r.Parent_Asset__r.Dynamic_SKU__c;
                    string trimmedDynamicSKU = dynamicSKU.substring(0, 8);
                    if(modelToSRMapDynamicSKUMaster.get(trimmedDynamicSKU) != null){
                        string srPartNumber = modelToSRMapDynamicSKUMaster.get(trimmedDynamicSKU);
                        if(srPartNumber != null){
                            cr_up_comp.componentServicePartNumber__c = srPartNumber;
                        }
                    }
                    else{
                        cr_up_comp.componentServicePartNumber__c = null; 
                    }
                }
                else{
                    
                    cr_up_comp.componentServicePartNumber__c = null;  
                }
            }
            
            else if(modelToSRMapProductNameMaster!= null &&
                    modelToSRMapProductNameMaster.get(v.asupComponentAsset__r.Product_Name__c) == null && 
                    v.asupComponentAssetProductCode__c != null && !v.asupComponentAssetProductCode__c.contains('CS215')){
                        string srPartNumber = modelToSRMapProductNameMaster.get(v.asupComponentAsset__r.Product_Name__c);
                        if(srPartNumber != null){
                            cr_up_comp.componentServicePartNumber__c = null;  
                        }
                    }
        }
        
        else 
        {
           
            cr_up_comp.componentServicePartNumber__c = null; 
            
        } 
        
        //For controllers, if SR part not found, a fallback is to find it by asset product code
        if(v.asupComponentType__c == 'Controller' && cr_up_comp.componentServicePartNumber__c == null && modelToSRMapProductNameMaster.get(v.asupComponentAssetProductCode__c) != null){
            string AssetPrdCode = modelToSRMapProductNameMaster.get(v.asupComponentAssetProductCode__c);
            cr_up_comp.componentServicePartNumber__c = AssetPrdCode;
        }
      
        //Return Existing Component service part number TS-8187
        if(cr_up_comp.componentServicePartNumber__c == null){
            if(existingComp1 != null && existingComp1.componentServicePartNumber__c != null){
            string servicepartnumber = existingComp1.componentServicePartNumber__c;
            cr_up_comp.componentServicePartNumber__c = servicepartnumber;
            }
        }
        
        system.debug('Return'+cr_up_comp.componentServicePartNumber__c);
        return  cr_up_comp.componentServicePartNumber__c;
        
    }
    // Added by exafort for TS-8177 on May 13 2021 END
    public static void populateStateAndSubState(Asup_Components__c v, Component__c cr_up_comp, Component__c existingComp)
    {
        system.debug('existingComp---'+existingComp);
        Boolean stateFlag = false;
        
        if(existingComp != null)
        {
            if(existingComp.componentState__c == 'RMA in Progress')
            {
                //make no changes
            }          
            else
            {
                stateFlag = true;
            }
        }
        else
        {
            stateFlag = true;
        }
        /*For SSD and HDD*/
        if(stateFlag && v.asupComponentType__c != 'Controller' && v.asupComponentDiskUsedState__c  != null)
        {
            if(v.asupComponentDiskUsedState__c.equalsIgnoreCase('Valid'))
            {               
                if(existingComp != null && existingComp.componentState__c != 'Shipped')
                    cr_up_comp.componentException__c = 'Valid';
                	cr_up_comp.Sub_State__c = 'Online';
               		cr_up_comp.componentState__c = 'Shipped';
                
                if(existingComp != null )  // Added by exafort for TS-8177 on May 13 2021              
               		cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp,existingComp);
            }
            else if(v.asupComponentDiskUsedState__c.equalsIgnoreCase('In Use'))
            {    
                if(existingComp != null && existingComp.componentState__c != 'Shipped')
                {                  
                    cr_up_comp.componentException__c = 'In Use';                  
                }
             if(existingComp != null )  // Added by exafort for TS-8177 on May 13 2021
               		cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp,existingComp);
             		cr_up_comp.Sub_State__c = 'Online';
                	cr_up_comp.componentState__c = 'Shipped';                                                                                       
            }
            else if(v.asupComponentDiskUsedState__c.equalsIgnoreCase('Foreign'))
            {
                if(existingComp != null && existingComp.componentState__c != 'Shipped')
                    cr_up_comp.componentException__c = 'Foreign';
                	cr_up_comp.Sub_State__c = 'Unknown';
                	cr_up_comp.componentState__c = 'Shipped';
                
                if(existingComp != null )  // Added by exafort for TS-8177 on May 13 2021              
               		cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp,existingComp);
            }
            else if(v.asupComponentDiskUsedState__c.equalsIgnoreCase('Failed'))
            {
                if(existingComp != null && existingComp.componentState__c != 'Shipped')
                    cr_up_comp.componentException__c = 'Failed';
                	cr_up_comp.Sub_State__c = 'Failed';
                	cr_up_comp.componentState__c = 'Shipped';
                
                if(existingComp != null )  // Added by exafort for TS-8177 on May 13 2021             
               		cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp,existingComp);
            }       
        }
        /*For Controller*/
        else if(stateFlag && v.asupComponentType__c == 'Controller')
        {          
            if(v.asupComponentControllerState__c != null)
            {              
                if(existingComp != null && existingComp.componentState__c != 'Shipped')
                cr_up_comp.componentException__c = 'Online';
                cr_up_comp.Sub_State__c = 'Online';
                cr_up_comp.componentState__c = 'Shipped';
                
                if(existingComp != null )  // Added by exafort for TS-8177 on May 13 2021   
                    cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp,existingComp);
             		
            }
            else
            {               
                if(existingComp != null && existingComp.componentState__c != 'Shipped')
                    cr_up_comp.componentException__c = 'Unknown';
                	cr_up_comp.Sub_State__c = 'Unknown';
                	cr_up_comp.componentState__c = 'Shipped';
                
                if(existingComp != null )  // Added by exafort for TS-8177 on May 13 2021              
               		cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp,existingComp);
            }
        }
        /*For PSU Added by exafort for TS-8177 on May 19 2021 */
        else if(stateFlag && v.asupComponentType__c == 'PSU') //v.asupComponentType__c == 'PWR(power supply)'
        {
            // Added by exafort for TS-8177 on May 13 2021            
            if(existingComp != null){
                cr_up_comp.componentException__c = 'In Use';
                cr_up_comp.Sub_State__c = 'Online';
                cr_up_comp.componentState__c = 'Shipped';
                cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp,existingComp);                
            }
                
        }
        //Added by Exafort for TS-5900
        else if(stateFlag && v.asupComponentType__c == 'SCM') 
        {         
            if(existingComp != null){
                cr_up_comp.componentException__c = 'In Use';
                cr_up_comp.Sub_State__c = 'Online';
                cr_up_comp.componentState__c = 'Shipped';
                cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp,existingComp);                
            }
        }
        // added type "FC" by Exafort for TS-6855
        // added type "NIC" by Exafort for TS-6807
        else if(stateFlag && (v.asupComponentType__c == 'FC' || v.asupComponentType__c == 'NIC')) 
        {         
            if(existingComp != null){
                cr_up_comp.componentException__c = 'In Use';
                cr_up_comp.Sub_State__c = 'Online';
                cr_up_comp.componentState__c = 'Shipped';
                cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp,existingComp);                
            }
        }
        // End of TS-6855
        /*For PSU commented by exafort for TS-8177
        else if(stateFlag && v.asupComponentType__c == 'PSU' && v.Component_status__c != null) //v.asupComponentType__c == 'PWR(power supply)'
        {
             // Added by exafort for TS-8177 on May 13 2021
            if(existingComp != null){
                cr_up_comp.componentServicePartNumber__c =  updateComponentServicePartNumber(v,cr_up_comp);                
            }
            
            if(v.Component_status__c.contains('OK')){
				if(v.Component_status__c.equalsIgnoreCase('ok 01') || v.Component_status__c.equalsIgnoreCase('ok  01'))// Added '|| equalsIgnoreCase('ok  01') by exafort for TS-8177 on May 13 2021
                {                        
                    if(existingComp != null && existingComp.componentState__c != 'Shipped')
                        cr_up_comp.componentException__c = 'In Use';
                    cr_up_comp.Sub_State__c = 'Online';
                    cr_up_comp.componentState__c = 'Shipped';
                }
                else if(v.Component_status__c.equalsIgnoreCase('status ok 00h'))
                {
                    if(existingComp != null && existingComp.componentState__c != 'Shipped')              
                        cr_up_comp.componentException__c = 'In Use';
                    cr_up_comp.Sub_State__c = 'Online';
                    cr_up_comp.componentState__c = 'Shipped';
                }
                else if(v.Component_status__c.equalsIgnoreCase('status ok 01h'))
                {               
                    if(existingComp != null && existingComp.componentState__c != 'Shipped')              
                        cr_up_comp.componentException__c = 'In Use';
                    cr_up_comp.Sub_State__c = 'Online';
                    cr_up_comp.componentState__c = 'Shipped';                    
                }
            }
            else if(v.Component_status__c.equalsIgnoreCase('temperature fault or warning 04h'))
            {
                if(existingComp != null && existingComp.componentState__c != 'Shipped')              
                    cr_up_comp.componentException__c = 'TEMPERATURE FAULT OR WARNING';
                cr_up_comp.Sub_State__c = 'Online';
                cr_up_comp.componentState__c = 'Shipped';                
            }
            else if(v.Component_status__c.contains('Failed'))
            {
                if(v.Component_status__c.equalsIgnoreCase('psu present failed 09')){
                    if(existingComp != null && existingComp.componentState__c != 'Shipped')
                        cr_up_comp.componentException__c = 'Valid';
                    cr_up_comp.Sub_State__c = 'Failed';
                    cr_up_comp.componentState__c = 'Shipped';
                }
                else if(v.Component_status__c.equalsIgnoreCase('psu present failed 41')){
                    if(existingComp != null && existingComp.componentState__c != 'Shipped')
                        cr_up_comp.componentException__c = 'Valid';
                    cr_up_comp.Sub_State__c = 'Failed';
                    cr_up_comp.componentState__c = 'Shipped';                    
                }
                else if(v.Component_status__c.equalsIgnoreCase('psu absent failed 00')){
                    if(existingComp != null && existingComp.componentState__c != 'Shipped')
                        cr_up_comp.componentException__c = 'Failed';
                    cr_up_comp.Sub_State__c = 'Failed';
                    cr_up_comp.componentState__c = 'Shipped';
                }
            }
            else if(v.Component_status__c.equalsIgnoreCase('unit is off 48h'))
            {
                if(existingComp != null && existingComp.componentState__c != 'Shipped')
                    cr_up_comp.componentException__c = 'Foreign';
                cr_up_comp.Sub_State__c = 'Unknown';
                cr_up_comp.componentState__c = 'Shipped';
            }
        }*/
    }
}