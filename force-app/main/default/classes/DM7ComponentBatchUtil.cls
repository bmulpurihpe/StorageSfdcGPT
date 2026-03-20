/*
*
	Created by Exafort for the JIRA TS-9712
    Utility class to insert/update component records from processing DM7 component records
    Logic - 
		Checks if a component with the incoming DM7's serial number already exists
			If found, update the existing component record with DM7 data and the matching Service Part Number
			If not found, insert a new component record with the Service Part Number
		The Service Part Number is determined by matching the DM7 field "Component Part Number + Asset Type" (Component_Part_Number__c + Asset_Type__c) 
		with the SR Metadata field "Model Numbers + Asset Type" (srModelNumbers__c + srAssetType__c). If a match is found, 
		the corresponding SR Metadata's SR Part is returned as the Component's Service Part Number
	Test Class - DM7ComponentBatch_Test
*/
public class DM7ComponentBatchUtil
{
    public static List<Component__c> compsToInsert = new List<Component__c>();
    public static List<DM7_Component__c> dm7ToUpdate = new List<DM7_Component__c>();
    public static Map<Id,Component__c> compsToUpdateImmediately = new Map<Id,Component__c>();
    public static Map<String,String> modelToSRMapMaster = new Map<String,String>();
    public static Map<String,String> modelwithAsstToSRMapMaster = new Map<String,String>();
    public static List<DM7_Component__c> dm7CompListMaster = new List<DM7_Component__c>();
    public static List<Component__c> compListMaster = new List<Component__c>();
    public static Map<String,String>  modelWithProductCodeMaster = new Map<String,String>();
    public static   Map<String,String> modelToSRMapProductNameMaster = new Map<String,String>();
    public static Map<String,String> modelToSRMapDynamicSKUMaster = new Map<String,String>();
    public static Map<Id,Component__c> updateCompRecord = new Map<Id,Component__c>();    
    
    public static void processDM7ForAccountOrAsset(List<DM7_Component__c> dm7CompList, List<Component__c> compList,
                                                   Map<String,String> modelToSRMap,
                                                   Map<String,String> modelWithProductCode,
                                                   Map<String,String> modelwithAsstToSRMap,
                                                   Map<String,String> modelToSRMapProductName,
                                                   Map<String,String> modelToSRMapDynamicSKU)
    {
        
        dm7CompListMaster = dm7CompList;
        compListMaster = compList; 
        modelWithProductCodeMaster = modelWithProductCode;
        modelToSRMapProductNameMaster = modelToSRMapProductName;
        modelToSRMapDynamicSKUMaster = modelToSRMapDynamicSKU;
        modelToSRMapMaster = modelToSRMap;
        modelwithAsstToSRMapMaster= modelwithAsstToSRMap;
        
        // Map<String,DM7_Component__c> dm7ComponentMap = new Map<String,DM7_Component__c>();
        Map<String, List<DM7_Component__c>> dm7ComponentMap = new Map<String, List<DM7_Component__c>>();
        Map<String,Component__c> componentMap = new Map<String,Component__c>();
        List<Component__c> compWithNoSN = new List<Component__c>(); 
        Set<string> compWithAssetSN = new Set<string>();
        //	Added by Exafort for SFDC-1176
        Set<String> processedSNSet = new Set<String>();
        Map<String,List<DM7_Component__c>> dm7ComponentList = new Map<String,List<DM7_Component__c>>();
        //	Group by Dm7 Serial number
        for (DM7_Component__c dm7Component : dm7CompList) {
            if (dm7Component.asupComponentSN__c != null) {
                if (!dm7ComponentList.containsKey(dm7Component.asupComponentSN__c)) {
                    dm7ComponentList.put(dm7Component.asupComponentSN__c, new List<DM7_Component__c>());
                }
                dm7ComponentList.get(dm7Component.asupComponentSN__c).add(dm7Component);
            }
            
            if (dm7Component.asupComponentAssetSN__c != null) {
                compWithAssetSN.add(dm7Component.asupComponentAssetSN__c);
            }
        }

		//	For a given serial number, finding only the last processed dm7 record and all unprocessed dm7 records
        for (String sn : dm7ComponentList.keySet()) {
            List<DM7_Component__c> components = dm7ComponentList.get(sn);
            List<DM7_Component__c> unmatchedComponents = new List<DM7_Component__c>();
            
            Boolean allMatched = true;
            //	Find if there are unprocessed dm7 components for the serial number
            for (DM7_Component__c comp : components) {                
                if (comp.asupcomponentMatchedWithComponent__c == null) {
                    unmatchedComponents.add(comp);
                    allMatched = false;
                }
            }
            
            DM7_Component__c selected;

            if (allMatched) {
                //	All are matched take the last one
                DM7_Component__c lastMatched = components[components.size() - 1];
                dm7ComponentMap.put(sn, new List<DM7_Component__c>{ lastMatched });
                
            } else {
                dm7ComponentMap.put(sn, unmatchedComponents);
            }
        }
        //	End of SFDC-1176
        
        //	Added by Exafort for TS-10398
        //	Getting asset info
        Map<string,Asset> assetListWithId = new Map<string,Asset>();
        for(Asset AssetList : [Select id,name,AccountId,Asset_Type__c from Asset where name =: compWithAssetSN]){
            assetListWithId.put(AssetList.name,AssetList);
        }
        //	End of TS-10398
        
        //	Seperate components with serial number and without serial number
        for(Component__c component : compList)
        {
            if(component.componentComponentSN__c != null)             
                componentMap.put(component.componentComponentSN__c,component);
            else
                compWithNoSN.add(component);
        } 
        
        system.debug('compWithNoSN '+ compWithNoSN);
        system.debug('dm7ComponentMap : ' + dm7ComponentMap.size());
        system.debug('dm7ComponentMap : ' + dm7ComponentMap);
        
        if(dm7ComponentMap.size() > 0){
        	//	Iterate the DM7 component serial number set to update or insert components            
            for(String snum : dm7ComponentMap.keySet())
            {
                Boolean newComponentInsert = false;
                List<DM7_Component__c> dm7ComponentListPerSN = dm7ComponentMap.get(snum);
                //	Get the count of DM7 record with Same Serail Number
                Integer duplicateSNCount = dm7ComponentMap.containsKey(snum) ? dm7ComponentMap.get(snum).size() : 0;
                Boolean isDuplicateSN = false;
                //	Construct the component objects to either insert or update
                for (DM7_Component__c dm7Component : dm7ComponentListPerSN) {
                    string originalAsupcomponentMatchedWithComponent = dm7Component.asupcomponentMatchedWithComponent__c; 
                    system.debug('asupcomponentMatchedWithComponent__c = '  + dm7Component.asupcomponentMatchedWithComponent__c);
                    Component__c componentRec = componentMap.get(snum);
                    system.debug(' componentRec value -->' + componentRec);
                    /*
                     * Added by Exafort for SFDC-2060
                     * This block runs only when no exact match for the component SN (componentRec == null)
                     * Tries to find a match based on the last 8 characters of the serial number
                     * If last 8 characters of the serial number is found, then that component record will get updated
                     */ 
                    //	Check if component not found, try to find last 8-char match
                    if(dm7Component.asupComponentType__c == 'Memory'){
                        if (componentRec == null) {
                            Set<String> compSNSet = componentMap.keySet();
                            if (compSNSet != null) {
                                for (String compSN : compSNSet) {
                                    String compLast8 = (compSN.length() >= 8 ? compSN.substring(compSN.length() - 8) : compSN);
                                    // If incoming DM7 SN matches last 8 characters of component SN
                                    if (compLast8 == snum) {
                                        componentRec = componentMap.get(compSN);
                                        if(componentRec != null){
                                            isDuplicateSN = True;
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                        /*
                         * Added by Exafort for SFDC-2060
                         * Find exact Serail Number match in the map
                         * Check for a longer SN in the map that ends with the same short SN
                         * If found:  
                         * 		Update the long SN component  
                         * 		Unlink the short SN component 
                         */ 
                        if (componentMap.containsKey(snum)) {
                            Component__c exactMatchComp = componentMap.get(snum);
                            for (String compSN : componentMap.keySet()) {
                                
                                if (compSN != snum && compSN.endsWith(snum)) {
                                    Component__c longSNComp = componentMap.get(compSN);
                                    
                                    //	Update long SN component
                                    componentRec = longSNComp;
                                    if(componentRec != null){
                                        isDuplicateSN = True;
                                    }
                                    
                                    //	Unlink short SN component
                                    if (exactMatchComp != null) {
                                        unlinkComponent(exactMatchComp);
                                        compsToUpdateImmediately.put(exactMatchComp.Id, exactMatchComp);
                                    }
                                    break;
                                }
                            }
                        }
                    }
                    
                    //	Check if a Component record already exists for the current DM7 record's Serial Number
                    /* if(componentRec == null)
                    {               
                        Set<String> compSNSet = componentMap.keySet();
                        if(compSNSet != null){
                            for(String s : compSNSet)
                            {                    
                                if(snum.contains(s))
                                {
                                    componentRec = componentMap.get(s);
                                    break;
                                }
                            }
                        }
                    } */
                    Component__c component = new Component__c();
                    populateComponent(dm7Component,component,assetListWithId,isDuplicateSN);
                    system.debug(' componentRec value -->' + componentRec);
                    Asset matchingAsset = assetListWithId.get(dm7Component.asupComponentAssetSN__c);
                    //	No existing component record found, insert new component record
                    if(componentRec == null)
                    {
                        Boolean upFlag = false;
                        if(!upFlag)
                        {
                            populateStateAndSubState(dm7Component,component,null,null);
                            component.componentAppearAfterInstallation__c = true;
                            system.debug(' Asup Disk Model -->'+dm7Component.asupComponentDiskModel__c);
                            system.debug(' Asup Asset type -->'+dm7Component.asupComponentAssetType__c);
                            string asupDisKmodel = '';
                            string asupAssetType = '';
                            if(dm7Component.asupComponentDiskModel__c != null)
                                asupDisKmodel = dm7Component.asupComponentDiskModel__c.trim();
                            
                            if(dm7Component.asupComponentAssetType__c != null)
                                asupAssetType = dm7Component.asupComponentAssetType__c.trim();
                            
                            //	Added by Exafort for SFDC-525
                            dm7Component.AsupComponentAccount__c = matchingAsset.AccountId;
                            dm7Component.AsupComponentAsset__c = matchingAsset.id;
                            //	End of SFDC-525
                            /* 
                                Component Part Number [Component_Part_Number__c + Asset_Type__c] matches with SR Metadata field  Model Numbers [srModelNumbers__c + srAssetType__c], 
                                then insert the component records with the Service Part Number.
                                If condition updated by Exafort for SFDC-361
							*/
                            if(dm7Component.Component_Part_Number__c != null && modelToSRMap.get(dm7Component.Component_Part_Number__c + matchingAsset.Asset_Type__c) != null && dm7Component.asupComponentType__c == 'PSU'){                             
                                component.componentServicePartNumber__c = modelToSRMap.get(dm7Component.Component_Part_Number__c + matchingAsset.Asset_Type__c);
                                component.ComponentCreatedFromInformation__c = 'Added from DM7 Component (SFDC)';
                                dm7Component.asupcomponentMatchedWithComponent__c = 'Yes-SeriallNumber';
                            }                        
                            else if(modelToSRMapMaster.get(dm7Component.Component_Part_Number__c + matchingAsset.Asset_Type__c) != null && dm7Component.Component_Part_Number__c != null &&
                                    isComponentOfInterest (dm7Component.asupComponentType__c)){
                                        component.componentServicePartNumber__c = modelToSRMapMaster.get(dm7Component.Component_Part_Number__c + matchingAsset.Asset_Type__c);
                                        component.ComponentCreatedFromInformation__c = 'Added from DM7 Component (SFDC)';
                                        dm7Component.asupcomponentMatchedWithComponent__c = 'Yes-SeriallNumber';                                                        
                                    }
                            //	No match found, insert component record with Service Part Number as Null
                            else 
                            {
                                component.componentServicePartNumber__c = null;
                                component.ComponentCreatedFromInformation__c = 'Added from DM7 Component (SFDC)';
                                dm7Component.asupcomponentMatchedWithComponent__c = 'Yes-SerialNumber-NoSRPart';
                                system.debug('### into final else');
                            }                            
                            compsToInsert.add(component);
                            newComponentInsert = true;
                            //v.asupcomponentMatchedWithComponent__c = 'No';
                        }
                        
                    }
                    //	Existing Component record found for the given Serial Number – update the Component with data from the corresponding DM7 record
                    else 
                    {
                        component.Id = componentRec.Id;
                        populateStateAndSubState(dm7Component,component,componentRec,matchingAsset.Asset_Type__c);
                        // updateComponentServicePartNumber
                        system.debug('### into final SN else');
                        //	If multiple DM7 record exists for the Serial Number, update the component record immediately otherwise they are updated once at the end
                        if(duplicateSNCount == 1){
                            updateCompRecord.put(component.Id,component);
                        } 
                        else{
                            compsToUpdateImmediately.put(component.Id,component);
                        }
                        
                        //	Added by Exafort for SFDC-525
                        dm7Component.AsupComponentAccount__c = matchingAsset.AccountId;
                        dm7Component.AsupComponentAsset__c = matchingAsset.id;
                        //	End of SFDC-525
                        
                        //	Update the DM7 component field MatchedWithComponent based on whether a matching Component's Service Part Number is found or not
                        if(component.componentServicePartNumber__c != null){
                            dm7Component.asupcomponentMatchedWithComponent__c = 'Yes-SeriallNumber';
                        }else {
                            dm7Component.asupcomponentMatchedWithComponent__c = 'Yes-SerialNumber-NoSRPart'; 
                        }
                    }
                    //	Update is needed only if the value is different 
                    if (originalAsupcomponentMatchedWithComponent != dm7Component.asupcomponentMatchedWithComponent__c){
                        if(newComponentInsert == true){
                            dm7ToUpdate.add(dm7Component);
                            break;
                        }else{
                            dm7ToUpdate.add(dm7Component);
                        }
                    }
                    if (!compsToUpdateImmediately.isEmpty()) {
                        updateComponents(compsToUpdateImmediately);
                        compsToUpdateImmediately.clear();
                    }
                }
            }
        }
    }
    
    //	Update the component records if the compsToUpdate map is not null or empty
    public static void updateComponents(Map<Id, Component__c> compsToUpdate) {
        if (compsToUpdate != null && !compsToUpdate.isEmpty()) {
            update compsToUpdate.values();
        }
    }
    
    
    // Populate component record field value from the given DM7 fields
    public static void populateComponent(DM7_Component__c dm7Component, Component__c component, Map<string,Asset> assetListWithId, Boolean isDuplicateSN)
    {
        // Added by Exafort for SFDC-525
        Asset matchingAsset = assetListWithId.get(dm7Component.asupComponentAssetSN__c);
        component.componentAccountId__c = matchingAsset.AccountId;
        component.componentAsset__c = matchingAsset.Id;
        // End of SFDC-525
        
        system.debug('assetListWithId.get(dm7Component.asupComponentAssetSN__c) : ' + assetListWithId.get(dm7Component.asupComponentAssetSN__c));
        //component.componentAsset__c= dm7Component.asupComponentAsset__c; //assetListWithId
        component.componentAssetSN__c = dm7Component.asupComponentAssetSN__c;
        if(isDuplicateSN == false){
            component.componentComponentSN__c = dm7Component.asupComponentSN__c; 
        }
        component.componentDiskSizeGB__c = dm7Component.asupComponentDiskSizeGB__c;
        component.componentDiskModel__c = dm7Component.asupComponentDiskModel__c;
        component.componentDisksled__c = dm7Component.asupComponentDisksled__c;
        component.componentErrorRate__c = dm7Component.asupComponentErrorRate__c;
        component.componentFirstASUP__c = dm7Component.asupComponentFirstASUP__c;
        component.componentLastStatusDate__c = dm7Component.asupComponentLastStatusDate__c;
        component.componentLocation__c = dm7Component.component_Location__c;
        component.componentPartNumber__c = dm7Component.Component_Part_Number__c;
        component.componentBoardPartNumber__c = dm7Component.Board_Part_Number__c;
        component.ComponentUber_SN__c = dm7Component.asupComponentUberSN__c;
        component.componentMostRecentASUP__c = dm7Component.asupComponentMostRecentASUP__c;
        component.componentDiskShelfSlot__c = dm7Component.asupComponentDiskShelfSlot__c;
        component.componentDiskPortNumber__c = dm7Component.asupComponentDiskPortNumber__c;
        component.componentASUPProcessed__c = true;
        component.Valid_To_Date__c = dm7Component.VALID_TO_DATE__c;
        component.Valid_From_Date__c = dm7Component.VALID_FROM_DATE__c;
        if(dm7Component.asupComponentType__c == 'PSU'){
            component.componentType__c = 'PWR(power supply)';
        }else{
            component.componentType__c = dm7Component.asupComponentType__c;
        }
    }
    
    //	Updated Component Records Service Part Number
    public static string updateComponentServicePartNumber(DM7_Component__c dm7Component,Component__c component,Component__c existingComponent, string assetType)
    { 
        system.debug('modelToSRMapMaster : ' + modelToSRMapMaster);
        system.debug('modelWithProductCodeMaster' + modelWithProductCodeMaster);
        system.debug('modelToSRMapMaster.get(dm7Component.Component_Part_Number__c) '+ modelToSRMapMaster.get(dm7Component.Component_Part_Number__c + assetType));
        
        // If condition updated by Exafort for SFDC-361
        if(modelToSRMapMaster.get(dm7Component.Component_Part_Number__c + assetType) != null && dm7Component.Component_Part_Number__c != null && isComponentOfInterest (dm7Component.asupComponentType__c)){
            component.componentServicePartNumber__c = modelToSRMapMaster.get(dm7Component.Component_Part_Number__c + assetType);
        }
        else if(dm7Component.asupComponentType__c == 'PSU' && dm7Component.Component_Part_Number__c != null && modelToSRMapMaster.get(dm7Component.Component_Part_Number__c + assetType) !=null ){
            component.componentServicePartNumber__c = modelToSRMapMaster.get(dm7Component.Component_Part_Number__c + assetType);
        }
        else 
        {
            
            component.componentServicePartNumber__c = null; 
            
        } 
        
        //	Return Existing Component service part number
        if(component.componentServicePartNumber__c == null){
            if(existingComponent != null && existingComponent.componentServicePartNumber__c != null){
                string servicepartnumber = existingComponent.componentServicePartNumber__c;
                component.componentServicePartNumber__c = servicepartnumber;
            }
        }
        
        system.debug('Return'+component.componentServicePartNumber__c);
        return  component.componentServicePartNumber__c;
        
    }
    
    //	Populate Component Status based on DM7 component field "UPD TYPE"
    public static void populateStateAndSubState(DM7_Component__c dm7Component, Component__c component, Component__c existingComponent, string assetType)
    {
        system.debug('existingComponent---' + existingComponent);
        Boolean stateFlag = false;
        
        if(existingComponent != null)
        {
            if(existingComponent.componentState__c == 'RMA in Progress')
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
        
        
        if(stateFlag && isComponentOfInterest (dm7Component.asupComponentType__c))
        {
            //	if DM7 component UPD TYPE field value is "I", updated the status to "Shipped Online"
            if(dm7Component.UPD_TYPE__c == 'I'){
                if(dm7Component.asupComponentControllerState__c != null)
                {              
                    if(existingComponent != null && existingComponent.componentState__c != 'Shipped'){
                        component.componentException__c = 'Online';
                    }
                    component.Sub_State__c = 'Online';
                    component.componentState__c = 'Shipped';
                    
                    if(existingComponent != null ){
                        component.componentServicePartNumber__c =  updateComponentServicePartNumber(dm7Component,component,existingComponent, assetType);                        
                    }                    
                }
                else
                {               
                    if(existingComponent != null && existingComponent.componentState__c != 'Shipped'){
                        component.componentException__c = 'Unknown';
                    }
                    component.Sub_State__c = 'Online';
                    component.componentState__c = 'Shipped';
                    
                    if(existingComponent != null){
                        component.componentServicePartNumber__c =  updateComponentServicePartNumber(dm7Component,component,existingComponent, assetType);
                    }
                }
            }
            //	if DM7 component UPD TYPE field value is "D", updated the status to "Shipped deleted"
            if(dm7Component.UPD_TYPE__c == 'D'){
                component.componentState__c = 'Shipped';
                component.Sub_State__c = 'Deleted';
                //	Added by Exafort for SFDC-1176
                if(existingComponent != null ){
                    component.componentServicePartNumber__c =  updateComponentServicePartNumber(dm7Component,component,existingComponent, assetType);
                }
            }
        }
    }
    
    // return true if the following component type is found
    public static boolean isComponentOfInterest(string componentType){
        return (componentType == 'BootDevice' || componentType == 'Memory' || componentType == 'SSD' || 
                componentType == 'CDM' || componentType == 'PSU' || componentType == 'IOM' || componentType == 'Chassis' ||
                componentType == 'NIC' || componentType == 'FC' || componentType == 'SFP' || componentType == 'PWR(power supply)');
    }
    
    //	Added by Exafort for SFDC-2060
    private static void unlinkComponent(Component__c comp) {
        comp.componentAsset__c = null;
        comp.componentAccountId__c = null;
        comp.componentState__c = 'Shipped';
        comp.Sub_State__c = 'Unknown';
    }
    //	End of SFDC-2060
    
}