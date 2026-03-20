public with sharing class NextGenTriggerClass{
    
   public static string errorText;
    public static List<NIC_Data__c> lstCS = new List<NIC_Data__c>(); // Added by exafort for TS-9109
    public static List<Gen6_NIC__c> lstCSGen6 = new List<Gen6_NIC__c>(); // Added by exafort for TS-9109 
    public static List<Product2> product2List = new List<Product2>(); // Added by exafort for TS-9109
    
    public static void populateIsFields(List<Asset> assetsList){
        //List<NIC_Data__c> lstCS = new List<NIC_Data__c>();
        /*** begin code changes for JIRA:  ESS-43859      added by Yesha Benegal on 04/15/2020
        *** Parse NIC card information from Infosight fields to Asset fields
        ****/
        map<string,String> infosightToProdMap = new map<string,string>();
        system.debug('lstCS.size() ---> +' + lstCS.size());
        
        /** Added by exafort for TS-9109 ***/
        /* Caching mechanism added to reduce the number of queries */
        /*  Begin  */
        if(lstCS.size() == 0){
            system.debug('Querying for NIC_Data__c');
            lstCS = [select Id, Nic_1__c,Nic_2__c,Nic_3__c,Comb_Nic_1__c,Comb_Nic_2__c from NIC_Data__c];
        }
        system.debug('lstCSGen6.size() ---> +' + lstCSGen6.size());
        if(lstCSGen6.size() == 0){
            system.debug('Querying for Gen6_NIC__c');
            lstCSGen6 = [select Id, Name, count__c, Name__c from Gen6_NIC__c]; //Bluetail changes May 2021 by Yesha Benegal
        }
        
        if (product2List.size() == 0){
            system.debug('Querying for Product2');
            product2List = [select ProductCode,name,Family, Component_Code__c, asset_Type__c,Array_Controller__c, infosight_identifier__c, HPE_SKU__C from Product2  where parent_product__c != TRUE];
        }
        /*  End  */
        /** Added by exafort for TS-9109 ***/
        
        Map<string, Decimal> mNIC = new Map<string, Decimal>();
        set<string> gPick = new set<string>();
        List<string> nicSet = new List<string> {'QF', 'QT', 'QP', 'QY', 'QG'};
            Schema.DescribeFieldResult F = Asset.Array_Networking__c.getDescribe();
        Schema.sObjectField T = F.getSObjectField();
        List<PicklistEntry> entries = T.getDescribe().getPickListValues();
        
        for(PicklistEntry pe : entries){
            gPick.add(pe.getvalue());
        }
        
        /*** end of changes***/
        set<string> ComponentCodeSet = new set<string>();
        

        for(Product2  p:product2List) // Added by Exafort for TS-9109
        {
            ComponentCodeSet.add(p.Component_Code__c);  
            if (p.infosight_identifier__c!= null) {
                infosightToProdMap.put(p.infosight_identifier__c,p.Component_Code__c);
            }
        }
        List<String> g6Nic = new List<String>(); 
        for(Gen6_NIC__c g : lstCSGen6){
            mNIC.put(g.Name__c, g.count__c);
            g6Nic.add(g.Name);
        }
        
        for(Asset assetObj:assetsList){
            assetObj.InfoSight_Update_Error__c='';
            List<String> nStr = new List<string>();
            if(assetObj.IS_Array_Controller__c!=null)
            {               
                if(ComponentCodeSet.contains(assetObj.IS_Array_Controller__c))
                    assetObj.Array_Controller__c=assetObj.IS_Array_Controller__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Array_Controller__c))
                    assetObj.Array_Controller__c=assetObj.IS_Array_Controller__c;
                else if(assetObj.IS_Array_Controller__c == '5030H' && assetObj.asset_Type__c == 'A5000'){
                    assetObj.Array_Controller_SKU__c=assetObj.IS_Array_Controller__c;
                }
                else
                    assetObj.InfoSight_Update_Error__c='Array Controller not found';
            }
            if(assetObj.IS_Array_Controller__c!=null && assetObj.Controller_Refresh_1__c == assetObj.IS_Array_Controller__c
                && assetObj.Controller_Refresh_Date__c == null && assetObj.Controller_Refresh_1__c != null){
                assetObj.Controller_Refresh_Date__c = system.today();
            }
            if(assetObj.IS_Array_Networking__c!=null)
            {    
                // if(assetObj.Asset_Product_Family__c!= null && assetObj.Asset_Product_Family__c.contains('Gen5')  ){
                assetObj.Array_Networking_SKU__c = null;
                assetObj.Array_Networking_2__c =null;
                assetObj.Array_Networking_3__c=null;
                assetObj.Array_Networking_2_SKU__c = null;
                assetObj.Array_Networking_3_SKU__c =  null;
                assetObj.Array_Networking_4__c =null;
                assetObj.Array_Networking_4_SKU__c =  null;
                assetObj.Array_Networking_5__c =null;
                assetObj.Array_Networking_5_SKU__c =  null;
                assetObj.Array_Networking_6__c =null;
                assetObj.Array_Networking_6_SKU__c =  null;
                
                

                /*** begin code changes for JIRA:  ESS-43859      added by Yesha Benegal on 04/15/2020 ****/ 
   
                if (assetObj.Asset_Product_Family__c!= null && (assetObj.Asset_Product_Family__c.contains('Alletra') 
                    || assetObj.Asset_Product_Family__c.contains('Gen5'))   ){
                    string nc = assetObj.IS_Array_Networking__c;
                    boolean hasSCM = false;
                    Set<string> nicStr = new Set<String>();
                    if(nc.contains('1SCM') || nc.contains('Z')){
                        assetObj.Array_Networking__c = 'Z';
                        nc = nc.remove('1SCM');
                        hasSCM = true;
                    }
                    
                    for(Integer i=0; i<g6Nic.size(); i++){
                        if(nc.contains(g6Nic[i])){
                            nicStr.add(g6Nic[i]);
                            nc = nc.remove(g6Nic[i]);
                        }
                    }
                    
                    if(nc!= null) {
                        for(Integer i=0; i<nicSet.size(); i++){
                            if(nc.contains(nicSet.get(i))){
                                string aST = nicSet.get(i);
                                aST = '1'+aST;
                                nicStr.add(aST);
                                nc.remove(nicSet.get(i));
                            }
                        }
                    }
                    
                    system.debug(' *** line 109 ' +nicStr);
                    
                    String[] neCards = new List<String>();
                    for(String s : nicStr){
                        for(Gen6_NIC__c n : lstCSGen6){
                            if(n.Name == s){
                                for(Integer i =0; i< n.count__c; i++){
                                    neCards.add(n.name__c);
                                    system.debug(' *** nec ' + neCards[i] + ' ** '+ n.count__c);
                                }
                            }
                        }
                    }
                    
                    for(Integer i=0; i<neCards.size(); + i++){
                        if(hasSCM == true){
                            if( i== 0)
                                assetObj.Array_Networking_2__c = neCards[i];
                            if( i== 1)
                                assetObj.Array_Networking_3__c = neCards[i];
                            if( i== 2)
                                assetObj.Array_Networking_4__c = neCards[i];
                            if( i== 3)
                                assetObj.Array_Networking_5__c = neCards[i];
                            if( i== 4)
                                assetObj.Array_Networking_6__c = neCards[i];
                            
                        }
                        else{
                            if( i== 0)
                                assetObj.Array_Networking__c = neCards[i];
                            if( i== 1)
                                assetObj.Array_Networking_2__c = neCards[i];
                            if( i== 2)
                                assetObj.Array_Networking_3__c = neCards[i];
                            if( i== 3)
                                assetObj.Array_Networking_4__c = neCards[i];
                            if( i== 4)
                                assetObj.Array_Networking_5__c = neCards[i];
                            if( i== 5)
                                assetObj.Array_Networking_6__c = neCards[i];
                            
                        }
                        
                    }
                    
                }
                else{
                    if(ComponentCodeSet.contains(assetObj.IS_Array_Networking__c)){
                        assetObj.Array_Networking__c=assetObj.IS_Array_Networking__c;
                        
                    }
                    else if(infosightToProdMap.containsKey(assetObj.IS_Array_Networking__c)){
                        assetObj.Array_Networking__c=assetObj.IS_Array_Networking__c;
                    }
                    else
                        assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+' Array networking not found';
                }
                
                
                
                
                
            }
           
            
            /***end of Code change ***/
            if(assetObj.IS_Array_Capacity__c!=null)
            {
                
                if(ComponentCodeSet.contains(assetObj.IS_Array_Capacity__c))
                    assetObj.Array_Capacity__c=assetObj.IS_Array_Capacity__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Array_Capacity__c))
                    assetObj.Array_Capacity__c=assetObj.IS_Array_Capacity__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Array capacity not found';
            }
            if(assetObj.IS_Array_Cache__c!=null)
            {
                
                if(ComponentCodeSet.contains(assetObj.IS_Array_Cache__c))
                    assetObj.Array_Cache__c=assetObj.IS_Array_Cache__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Array_Cache__c))
                    assetObj.Array_Cache__c=assetObj.IS_Array_Cache__c;
                else if(assetObj.IS_Array_Cache__c == '369T')
                    assetObj.Array_Cache__c = '368F';
                else{
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Array cache not found';
                    if(assetObj.Asset_Product_Family__c!= null && assetObj.Asset_Product_Family__c.contains('Gen5')){
                        assetObj.Array_Cache__c=assetObj.IS_Array_Cache__c;
                    }
                }
            }
            if(assetObj.IS_SSD_Bank_A__c!=null)
            {    
                assetObj.SSD_Bank_A__c = null;
                assetObj.SSD_Bank_B__c = null;
                if(ComponentCodeSet.contains(assetObj.IS_SSD_Bank_A__c)){
                    assetObj.SSD_Bank_A__c=assetObj.IS_SSD_Bank_A__c;
                    system.debug(' *** line 237 ' + assetObj.SSD_Bank_A__c);
                }
                else if(infosightToProdMap.containsKey(assetObj.IS_SSD_Bank_A__c)){
                    assetObj.SSD_Bank_A__c=assetObj.IS_SSD_Bank_A__c;
                    system.debug(' *** line 241 ' + assetObj.SSD_Bank_A__c);
                }
                else {
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'SSD Bank A not found';
                }
            }
            if(assetObj.IS_SSD_Bank_B__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_SSD_Bank_B__c))
                    assetObj.SSD_Bank_B__c=assetObj.IS_SSD_Bank_B__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_SSD_Bank_B__c))
                    assetObj.SSD_Bank_B__c=assetObj.IS_SSD_Bank_B__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'SSD Bank B not found';
            }
            if(assetObj.IS_Shelf_Pack_1__c!=null)
            {
                assetObj.Shelf_Pack_1__c = null;
                assetObj.Shelf_Pack_2__c = null;
                assetObj.Shelf_Pack_3__c = null;
                assetObj.Shelf_Pack_4__c = null;
                assetObj.Shelf_Pack_5__c = null;
                assetObj.Shelf_Pack_6__c = null;
                assetObj.Shelf_Pack_1_SKU__c = null;
                assetObj.Shelf_Pack_2_SKU__c = null;
                assetObj.Shelf_Pack_3_SKU__c = null;
                assetObj.Shelf_Pack_4_SKU__c = null;
                assetObj.Shelf_Pack_5_SKU__c = null;
                assetObj.Shelf_Pack_6_SKU__c = null;
                
                
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_1__c)){
                    assetObj.Shelf_Pack_1__c=assetObj.IS_Shelf_Pack_1__c;
                    
                }
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_1__c)){
                    assetObj.Shelf_Pack_1__c=assetObj.IS_Shelf_Pack_1__c;
                    
                    
                }
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 1 not found';
            }
            if(assetObj.IS_Shelf_Pack_2__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_2__c))
                    assetObj.Shelf_Pack_2__c=assetObj.IS_Shelf_Pack_2__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_2__c))
                    assetObj.Shelf_Pack_2__c=assetObj.IS_Shelf_Pack_2__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 2 not found';
            }
            if(assetObj.IS_Shelf_Pack_3__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_3__c))
                    assetObj.Shelf_Pack_3__c=assetObj.IS_Shelf_Pack_3__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_3__c))
                    assetObj.Shelf_Pack_3__c=assetObj.IS_Shelf_Pack_3__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 3 not found';
            }
            if(assetObj.IS_Shelf_Pack_4__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_4__c))
                    assetObj.Shelf_Pack_4__c=assetObj.IS_Shelf_Pack_4__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_4__c))
                    assetObj.Shelf_Pack_4__c=assetObj.IS_Shelf_Pack_4__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 4 not found';
            }
            if(assetObj.IS_Shelf_Pack_5__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_5__c))
                    assetObj.Shelf_Pack_5__c=assetObj.IS_Shelf_Pack_5__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_5__c))
                    assetObj.Shelf_Pack_5__c=assetObj.IS_Shelf_Pack_5__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 5 not found';
            }
            if(assetObj.IS_Shelf_Pack_6__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_6__c))
                    assetObj.Shelf_Pack_6__c=assetObj.IS_Shelf_Pack_6__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_6__c))
                    assetObj.Shelf_Pack_6__c=assetObj.IS_Shelf_Pack_6__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 6 not found';
            }
            if(assetObj.IS_Shelf_Pack_1B__c!=null)
            {    
                assetObj.Shelf_Pack_1B__c = null;
                assetObj.Shelf_Pack_2B__c= null;
                assetObj.Shelf_Pack_3B__c= null;
                assetObj.Shelf_Pack_4B__c= null;
                assetObj.Shelf_Pack_5B__c= null;
                assetObj.Shelf_Pack_6B__c= null;
                assetObj.Shelf_Pack_1B_SKU__c = null;
                assetObj.Shelf_Pack_2B_SKU__c = null;
                assetObj.Shelf_Pack_3B_SKU__c = null;
                assetObj.Shelf_Pack_4B_SKU__c = null;
                assetObj.Shelf_Pack_5B_SKU__c = null;
                assetObj.Shelf_Pack_6B_SKU__c = null;
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_1B__c)){
                    assetObj.Shelf_Pack_1B__c=assetObj.IS_Shelf_Pack_1B__c;
                    
                    
                }else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_1B__c)){
                    assetObj.Shelf_Pack_1B__c=assetObj.IS_Shelf_Pack_1B__c;
                }else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 1B not found';
            }
            if(assetObj.IS_Shelf_Pack_2B__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_2B__c))
                    assetObj.Shelf_Pack_2B__c=assetObj.IS_Shelf_Pack_2B__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_2B__c))
                    assetObj.Shelf_Pack_2B__c=assetObj.IS_Shelf_Pack_2B__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 2B not found';
            }
            if(assetObj.IS_Shelf_Pack_3B__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_3B__c))
                    assetObj.Shelf_Pack_3B__c=assetObj.IS_Shelf_Pack_3B__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_3B__c))
                    assetObj.Shelf_Pack_3B__c=assetObj.IS_Shelf_Pack_3B__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 3B not found';
            }
            if(assetObj.IS_Shelf_Pack_4B__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_4B__c))
                    assetObj.Shelf_Pack_4B__c=assetObj.IS_Shelf_Pack_4B__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_4B__c))
                    assetObj.Shelf_Pack_4B__c=assetObj.IS_Shelf_Pack_4B__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 4B not found';
            }
            if(assetObj.IS_Shelf_Pack_5B__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_5B__c))
                    assetObj.Shelf_Pack_5B__c=assetObj.IS_Shelf_Pack_5B__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_5B__c))
                    assetObj.Shelf_Pack_5B__c=assetObj.IS_Shelf_Pack_5B__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 5B not found';
            }
            if(assetObj.IS_Shelf_Pack_6B__c!=null)
            {
                if(ComponentCodeSet.contains(assetObj.IS_Shelf_Pack_6B__c))
                    assetObj.Shelf_Pack_6B__c=assetObj.IS_Shelf_Pack_6B__c;
                else if(infosightToProdMap.containsKey(assetObj.IS_Shelf_Pack_6B__c))
                    assetObj.Shelf_Pack_6B__c=assetObj.IS_Shelf_Pack_6B__c;
                else
                    assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c+';'+'Shelf Pack 6B not found';
            }
            assetObj.InfoSight_Update_Error__c=assetObj.InfoSight_Update_Error__c.removestart(',');
            errorText = assetObj.Infosight_Update_Error__c;
        }
        integer k=0;
         
    }
    //CR#2912 JIRA#ESS-51088 by Yesha Benegal Sept-09-2020
    public static string calculateSKU( string value1,boolean HFCacheOnly ,string arrayCTLR, string assetType, 
                                Map<string, Product2> AssetTypeProductMap, Map<String,List<Product2>> mAssetTypeProductMap,
                                map<string,String> infosightToProdMap, map<string,String> pronamecompmap,Map<string, Product2> multipicklistAssetTypeMap){
         system.debug(' *** line 318 ' + value1 + ' ** '+ assetType + ' ** ' + HFCacheOnly);
         string valueToReturn;
         Set<String>  arrayCTLRSet = new set<String>();           
         boolean foundVal = false;

         if(value1!= null && HFCacheOnly == False){ 
                    if(AssetTypeProductMap.containskey(value1+'-'+assetType)){ 
                        system.debug(' *** line 400 ');
                        string assetTypeSupported = AssetTypeProductMap.get(value1+'-'+assetType).Asset_Type__c;
                    if (AssetTypeProductMap.containsKey(value1 +'-'+assetType) && assetTypeSupported.contains(assetType)
                        && arrayCTLR != null) { 
                        
                        if(AssetTypeProductMap.containsKey(value1+'-'+assetType) && AssetTypeProductMap.get(value1+'-'+assetType).ProductCode!=null)
                            
                            if(AssetTypeProductMap.get(value1+'-'+assetType).Array_Controller__c != null){
                                arrayCTLRSet.addAll(AssetTypeProductMap.get(value1+'-'+assetType).Array_Controller__c.split(';'));                   
                                
                                if(arrayCTLRSet.contains(arrayCTLR)){
                                    valueToReturn = AssetTypeProductMap.get(value1 +'-'+assetType).ProductCode;   
                                    foundVal = true;
                                    
                                } 
                            }
                            if(foundVal== false){
                                
                                if(mAssetTypeProductMap.containsKey(value1+'-'+assetType)){
                                    
                                    List<Product2> plst = mAssetTypeProductMap.get(value1+'-'+assetType);
                                    
                                        for(Product2 p :plst){ 
                                            if(p.ProductCode != null){
                                                Set<String>  arrayCTLRstr = new set<String>();
                                                
                                                if(p.Array_Controller__c != null){
                                                    arrayCTLRstr.addAll(p.Array_Controller__c.split(';'));
                                                    if(arrayCTLRstr.contains(arrayCTLR)){
                                                        valueToReturn = p.ProductCode;
                                                        
                                                        foundVal = true;
                                                    } 
                                               }
                                            }
                                        }
                                    
                                }
                            }
                            
                            if(foundVal == false){
                            
                                if ( multipicklistAssetTypeMap.containsKey(value1+'-'+assetType+'-'+arrayCTLR) && (JSON.serialize(multipicklistAssetTypeMap.get(value1+'-'+assetType+'-'+arrayCTLR).Array_Controller__c).contains(arrayCTLR))) { 
                                    valueToReturn = multipicklistAssetTypeMap.get(value1+'-'+assetType+'-'+arrayCTLR).ProductCode;  
                                    system.debug(' *** line 443 valueToReturn ' + valueToReturn);                                                                                
                                }
                           } 
                           
                            
             
                    }
                    else if(arrayCTLR == null){
                        if (AssetTypeProductMap.containsKey(value1+'-'+assetType) && assetType == AssetTypeProductMap.get(value1+'-'+assetType).Asset_Type__c) { 
                        if(AssetTypeProductMap.containsKey(value1+'-'+assetType) && AssetTypeProductMap.get(value1+'-'+assetType).ProductCode!=null)
                            valueToReturn = AssetTypeProductMap.get(value1+'-'+assetType).ProductCode;                    
                            system.debug(' *** line 454 valueToReturn ' + valueToReturn);                          
                        }
                    }
                    else if (arrayCTLR!=null && multipicklistAssetTypeMap.containsKey(value1+'-'+assetType+'-'+arrayCTLR) && (JSON.serialize(multipicklistAssetTypeMap.get(value1+'-'+assetType+'-'+arrayCTLR).Array_Controller__c).contains(arrayCTLR))) { 
                            valueToReturn = multipicklistAssetTypeMap.get(value1 +'-'+ assetType +'-'+arrayCTLR).ProductCode; 
                            system.debug(' *** line 459 valueToReturn ' + valueToReturn);
                        
                        }//added by venkat asset type changes-april 18 2018
                        
                    
                    else{
                        if(infosightToProdMap.containsKey(value1)){
                            valueToReturn = infosightToProdMap.get(value1);

                        }else{
                            valueToReturn = pronamecompmap.get(value1);
                            
                            
                        }
                    }
            }
        }
        
        if(valueToReturn == null){
             if (arrayCTLR !=null && 
                 multipicklistAssetTypeMap.containsKey(value1+'-'+assetType+'-'+arrayCTLR) 
                 && (JSON.serialize(multipicklistAssetTypeMap.get(value1 +'-'+assetType+'-'+arrayCTLR).Array_Controller__c).contains(arrayCTLR))) { 
                        valueToReturn = multipicklistAssetTypeMap.get(value1+'-'+assetType+'-'+arrayCTLR).ProductCode;  
                        
                                           
            }
        }                         
        system.debug( ' *** line 482 ' + valueToReturn);
        return valueToReturn;
    }
    
    // moving code from NextgenAssetUpdate
    public static string calculateShelfSKU(string value1, string assetType, Map<string, Product2> AssetTypeProductMap, map<string,String> infosightToProdMap, map<string,String> pronamecompmap, Map<string, Product2> multipicklistAssetTypeMap ){
        string valueToReturn;
        boolean valuefound = false;
        system.debug(' *** line 491 nextgentriggerclass ' + assetType +  ' shelf value ' + value1);
        if(multipicklistAssetTypeMap != null){
            if (multipicklistAssetTypeMap.containsKey(value1+'-'+assetType) && JSON.serialize(multipicklistAssetTypeMap.get(value1+'-'+assetType).Asset_Type__c).contains(assetType)) { 
                valueToReturn = multipicklistAssetTypeMap.get(value1 +'-'+ assetType).ProductCode;  //added by venkat asset type changes-april 18 2018                  
                valuefound = true;
            }
        }
        if(valuefound == false) {
            if (AssetTypeProductMap.containsKey(value1+'-'+assetType) && assetType == AssetTypeProductMap.get(value1+'-'+assetType).Asset_Type__c) { 
                if(AssetTypeProductMap.containsKey(value1+'-'+assetType) && AssetTypeProductMap.get(value1+'-'+assetType).ProductCode!=null)
                    valueToReturn = AssetTypeProductMap.get(value1+'-'+assetType).ProductCode;    
             system.debug('========valueToReturn513====='+valueToReturn);                 
            }          
            else{
                if(infosightToProdMap.containsKey(value1))
                    valueToReturn = infosightToProdMap.get(value1);
             
                else
                    valueToReturn = pronamecompmap.get(value1);
            }
            valuefound = true;// Added Jana SFDC-368
              
        }
        if(valuefound == false){
            
            for(Product2 p : AssetTypeProductMap.values()){
                if(p.Infosight_Identifier__c == value1 ){ //&& assetType == p.Asset_type__c
                    valueToReturn = p.ProductCode;
                    system.debug('========valueToReturn====='+valueToReturn);
                }
            }
        }
    
        return valueToReturn;
    }
    
    //AFA3 SSD_Bank_A_SKU and SSD_Bank_B_SKU calculation
    
    public static string calculateBANKSKU( string value1,Decimal ssdCount ,string arrayCTLR, string assetType, Decimal ssdPack,Map<string, Product2> multipicklistAssetTypeMap ,Map<string, Product2> AssetTypeProductMap, map<string,String> infosightToProdMap, map<string,String> pronamecompmap, Map<String,List<Product2>> mAssetTypeProductMap){
        String valueToReturn;
        boolean valueFound = false;
        if(ssdPack == 0 || ssdPack == null){
            ssdPack = 1;
        }
        if(ssdCount == 0 || ssdCount == null){
            ssdCount = 1;
        }
        Decimal count = ssdCount / ssdPack;
        system.debug(' *** line 520  value 1 is ' + value1);
        system.debug( ' *** line 509 ssdcount is ' + ssdCount +' ** count is ' + count + ' ***  pack is ' + ssdpack + ' is  '+ multipicklistAssetTypeMap.get(value1)); //multipicklistAssetTypeMap.get(value1).Storage_Capacity_Raw__c );
        if(multipicklistAssetTypeMap.get(value1)!= null){

      
            for(Product2 p : multipicklistAssetTypeMap.values()){
                
                if((p.Infosight_Identifier__c == value1 || p.Component_Code__c == value1) && p.Shelves_Qty_Allowed__c == count && p.Shelves_Qty_Allowed__c != null) {
                    valueToReturn = p.ProductCode; 
                    valueFound = true;
                }
            }
            system.debug( ' *** line 519 valuetoreturn ' +valueToReturn );
            
        }
        if(valuefound == false) {
            if (AssetTypeProductMap.containsKey(value1+'-'+assetType) && assetType == AssetTypeProductMap.get(value1+'-'+assetType).Asset_Type__c) { 
                if(AssetTypeProductMap.containsKey(value1+'-'+assetType) && AssetTypeProductMap.get(value1+'-'+assetType).ProductCode!=null)
                    valueToReturn = AssetTypeProductMap.get(value1+'-'+assetType).ProductCode;                    
                
            }            
            else{
                if(infosightToProdMap.containsKey(value1))
                    valueToReturn = infosightToProdMap.get(value1);
                else
                    valueToReturn = pronamecompmap.get(value1);
            }
        }
    return valueToReturn;
    }
    public static string calculateBankSKU2(string value1, string assetType,string ctrl, Map<string, Product2> multipicklistAssetTypeMap)
    {   
        string valueToReturn;
        if (multipicklistAssetTypeMap.containsKey(value1+'-'+assetType) && JSON.serialize(multipicklistAssetTypeMap.get(value1+'-'+assetType).Asset_Type__c).contains(assetType)) { 
            valueToReturn = multipicklistAssetTypeMap.get(value1+'-'+assetType).ProductCode; 
                              
        }
        if (ctrl!=null && multipicklistAssetTypeMap.containsKey(value1+'-'+assetType+'-'+ctrl) && (JSON.serialize(multipicklistAssetTypeMap.get(value1+'-'+assetType+'-'+ctrl).Array_Controller__c).contains(ctrl))) { 
            valueToReturn = multipicklistAssetTypeMap.get(value1+'-'+assetType+'-'+ctrl).ProductCode;  
                           
        }
        if(valueToReturn == null && multipicklistAssetTypeMap.containskey(value1) && multipicklistAssetTypeMap.get(value1).ProductCode!=null){
            valueToReturn = multipicklistAssetTypeMap.get(value1).ProductCode;
            
        }
        return valueToReturn;
    }
    
    public static string calculateNetworkingSKU (string value1, string arrayCTLR, string assetType, Map<string, Product2> AssetTypeProductMap, map<string,String> infosightToProdMap, map<string,String> pronamecompmap){
        String valueToReturn;
        
        if (AssetTypeProductMap.containsKey(value1+'-'+assetType) &&  AssetTypeProductMap.get(value1+'-'+assetType).Asset_Type__c.contains(assetType)){
            
            if(AssetTypeProductMap.containsKey(value1+'-'+assetType) && AssetTypeProductMap.get(value1+'-'+assetType).ProductCode!=null 
               && AssetTypeProductMap.get(value1+'-'+assetType).Array_Controller__c != null && AssetTypeProductMap.get(value1+'-'+assetType).Array_Controller__c.contains(arrayCTLR) ){

                valueToReturn = AssetTypeProductMap.get(value1+'-'+assetType).ProductCode; 
            }
        }                   
        else{
            if(infosightToProdMap.containsKey(value1))
                valueToReturn = infosightToProdMap.get(value1);
            else
                valueToReturn =pronamecompmap.get(value1);
        
        }
        return valueToReturn;
    }
}