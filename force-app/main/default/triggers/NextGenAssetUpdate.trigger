trigger NextGenAssetUpdate on Asset (before insert, before update, after insert, after update, After delete) {
    
    static Set<Id> acctQueID = new Set<Id>();
    
    Map<String,String> prodContrrefresh= new Map<String,String>(); 
    Map<String,String> prodArrayNetworking= new Map<String,String>();
    Map<String,String> prodArrayNetworkingSKU = new Map<String,String>();
    //NonNimbleProduct__c var = NonNimbleProduct__c.getValues('SSaas');
    public static Map<String, String> cacheString = new Map<String, String >{'5760F' => '6T','11520F' => '11T', '23040F' => '23T', '46080F' => '46T', '92160F' => '92T', '184320F' => '184T', '184344F' => '184T', '92172F' => '92T','368640F' => '368F', '92T'=>'92T','6T'=>'6T',
        '11T'=>'11T', '23T'=>'23T', '46T'=>'46T', '184T'=>'184T','368F'=>'368F'};
            public static Map<String, Integer> decString = new Map<String, Integer >{'5760F' => 6,'11520F' => 11, '23040F' => 23, '46080F' => 46, '92160F' => 92, '184320F' => 184, '11T' => 11, '23T' => 23, '46T' => 46, '92T' => 92 ,'184T' => 184, '6T' => 6, '184344F' => 184 , '368F'=> 368, '368640F' => 368};
                
                //added by venkat-1 june 2018-end
                if(Trigger.IsUpdate && Trigger.isAfter){
                    
                    Map<String, Fields_Changed_Corona_Asset__c> fieldNamesCSMap = Fields_Changed_Corona_Asset__c.getAll();
                    set <string> fieldNames =  fieldNamesCSMap.keyset();
                    Set<ID> idsOfAssetChanged=new set<id>();
                    
                    for (Asset mo : Trigger.new) {
                        Asset old = Trigger.oldMap.get(mo.Id);
                        
                        for (String f : fieldNames) {
                            if (mo.get(f) != old.get(f) && !assetNextGenPreventRecursion.setOfIds.contains(mo.id)
                            && mo.Do_Not_Push_to_Corona__c == false ) {
                                assetNextGenPreventRecursion.setOfIds.add(mo.id);
                                idsOfAssetChanged.add(mo.id);                        
                            }
                            
                        }
                    }
                    List<Id> assetIdList = new List<Id>(idsOfAssetChanged);
                    
                    if(assetIdList.size() > 0){
                        if(!Test.isRunningTest()){
                            if(!System.isBatch() && !System.isFuture()){
                                
                                SendAssetDataRestIntegration1.futureSendAssetData(assetIdList);
                            }
                        }
                    }
                    
                }
    
    if(Trigger.IsInsert && Trigger.IsAfter){   
        set<Id> astID =  trigger.newMap.keyset(); system.debug( ' *** asset id ' + astID);
        if(AssetHPSyncTrgCls.isHPE == false){
            assetTriggerHandler.createAssetStageRecords(astID); 
        }
        
        if(AssetHPSyncTrgCls.isHPE == True ){
            
            assetTriggerHandler.createNECRecord(astID);
        }
        
        
    }
    
    
    if(Utility.runDupRecTrigger)
    {
        Set<string> prodname=new set<string>();
        map<string,String> pronamecompmap=new map<string,string>();
        map<string,String> infosightToProdMap = new map<string,string>();   //added by Unnat: Map Infosight Identifier to Product Code
        //added by venkat march 2018
        @TestVisible Map<string, Product2> AssetTypeProductMap = new Map<String, Product2>();
        @TestVisible Map<String,List<Product2>> mAssetTypeProductMap = new Map<String,List<Product2>>();
        Map<string, Product2> multipicklistAssetTypeMap = new Map<String, Product2>(); //added by venkat april 18 2018
        Map<string, Product2> ProductCodeHPESKUMap = new Map<String, Product2>();
        Map<string, Decimal> ProductCodeSSD_Map = new Map<String, Decimal>();
        Map<string, Product2> HPESKUProductMap = new Map<String, Product2>();
        Map<string, string> SimplivitySKUMap = new Map<string,string>();
        map<string, product2> prdMap = new Map<string, product2>();
        Integer countOfSSDPacks=0;//added by venkat for ssdpack issue-7/3/2018//march 2018
        
        
        set<String> AssetIds = new set<String>();
        map<string,Integer> assetCountMapes1 = new map<string,Integer>();
        map<string,Integer> assetCountMapafs = new map<string,Integer>();
        map<id,string> ParentControllerMap = New map<id,string>();
        boolean HFCache = false;
        boolean NoHFCache = false;
        
        
        if(trigger.isBefore){//added by venkat 1 june 2018-start
            NextGenTriggerClass.populateIsFields(Trigger.New);
        }//added by venkat 1 june 2018-end
        
        if(trigger.isInsert || trigger.isUpdate)
            for(Asset a:trigger.new)
        {    
            if(a.Dynamic_SKU__c == null&& trigger.IsBefore){
                a.Dynamic_SKU__c = a.Package_Product_Code_1__c;
            }
            if(a.Dynamic_SKU__c != a.Package_Product_Code_1__c &&  trigger.IsUpdate && trigger.IsBefore){
                a.Dynamic_SKU__c = a.Package_Product_Code_1__c;
            }
            
            if(a.Asset_Product_Family__c != null &&  trigger.IsUpdate && trigger.IsBefore){
                if(a.Asset_Product_Family__c.contains('Expansion') || a.Asset_Product_Family__c.contains('Shelf')){
                    a.Timeless_Storage__c = false;
                    a.Date_of_Refresh__c  = null;
                    a.Tier_Selected__c = null;
                }
                else if(!a.Asset_Product_Family__c.contains('Expansion') && a.Timeless_Storage__c == True){
                    if(a.Support_Start_Date_Asset__c != null){
                        a.Date_Of_Refresh__c = a.Support_Start_Date_Asset__c.addYears(3);
                    }
                }
            }
            
            if(a.Dynamic_SKU__c != null && Trigger.isBefore){
                String[] splittedArray = a.Dynamic_SKU__c.split('-');
                if(a.Dynamic_SKU__c.startsWithIgnoreCase('HF'))
                    if(a.Dynamic_SKU__c.startsWithIgnoreCase('HF20-') || a.Dynamic_SKU__c.startsWithIgnoreCase('HF40-') || a.Dynamic_SKU__c.startsWithIgnoreCase('HF60-')
                       || a.Dynamic_SKU__c.startsWithIgnoreCase('HF60C-') ){
                           HFCache = True;
                           if(splittedArray.size() > 3 && a.IS_Array_Cache__c == null){
                               string ssdBank = splittedArray[3];
                               a.Array_Cache__c=ssdBank;
                           }
                           else if(a.IS_Array_Cache__c != null){
                               a.Array_Cache__c = a.IS_Array_Cache__c;
                           } 
                           
                       }
                else
                    NoHFCache = True;
                
                list<String> Splitlst = new list<String>();
                
                for(String eachSplittedValue : splittedArray ){
                    Splitlst.add(eachSplittedValue);                       
                }
                if(Splitlst.size() >= 2) {
                    if(a.Asset_Product_Family__c!=null && (a.Asset_Product_Family__c.startsWithIgnoreCase('Expansion Shelf') || a.Asset_Product_Family__c.startsWithIgnoreCase('All Flash Shelf')  || a.Asset_Product_Family__c.startsWithIgnoreCase('Expansion') )) 
                    { 
                        if(a.Dynamic_SKU__c.startsWithIgnoreCase('ES')){
                            a.Expansion_Shelf_Base__c = Splitlst[0] +'-'+Splitlst[1]; 
                            a.Expansion_Shelf_Base__c = a.Expansion_Shelf_Base__c.replace(' Expansion Shelf','');
                        }
                        else if(a.Dynamic_SKU__c.startsWithIgnoreCase('AFS')){
                            a.Expansion_Shelf_Base__c = Splitlst[0];
                        } 
                    }
                    else{
                        a.Expansion_Shelf_Base__c =''; // added on 7-15-2018
                    }
                    
                }
                
                if(a.Asset_Product_Family__c!=null && a.Asset_Product_Family__c.startsWithIgnoreCase('All Flash Shelf') && (a.Dynamic_SKU__c == 'Bluetail'|| a.Dynamic_SKU__c.contains('2140'))){
                    a.Expansion_Shelf_Base__c = '2140';
                }
                if(a.Dynamic_SKU__c == 'AFS3'){
                    a.Expansion_Shelf_Base__c = 'AFS3';
                }
            }
            if(a.Array_Controller__c!=null)
                prodname.add(a.Array_Controller__c);
            if(a.Array_Networking__c!=null)
                prodname.add(a.Array_Networking__c);
            if(a.Array_Networking_2__c!=null)
                prodname.add(a.Array_Networking_2__c);
            if(a.Array_Networking_3__c!=null)
                prodname.add(a.Array_Networking_3__c);
            if(a.Array_Networking_4__c != null)
                prodname.add(a.Array_Networking_4__c);
            if(a.Array_Networking_5__c != null)
                prodname.add(a.Array_Networking_5__c);
            if(a.Array_Networking_6__c != null)
                prodname.add(a.Array_Networking_6__c);
            if(a.Array_Capacity__c!=null)
                prodname.add(a.Array_Capacity__c);
            if(a.SSD_Bank_A__c!=null)
                prodname.add(a.SSD_Bank_A__c);
            if(a.SSD_Bank_B__c!=null)
                prodname.add(a.SSD_Bank_B__c);
            if(a.Shelf_Pack_1__c!=null){
                prodname.add(a.Shelf_Pack_1__c); 
                if(a.Expansion_Shelf_Base__c == '2140'){
                    string shelf1 = a.Shelf_Pack_1__c+'F';
                    prodname.remove(a.Shelf_Pack_1__c);
                    prodname.add(shelf1);
                    
                }
            }
            if(a.Shelf_Pack_2__c!=null){
                prodname.add(a.Shelf_Pack_2__c);
                if(a.Expansion_Shelf_Base__c == '2140'){
                    string shelf2 = a.Shelf_Pack_2__c+'F';
                    prodname.remove(a.Shelf_Pack_2__c);
                    prodname.add(shelf2);
                    
                }
            }
            if(a.Shelf_Pack_3__c!=null)
                prodname.add(a.Shelf_Pack_3__c);
            if(a.Shelf_Pack_4__c!=null)
                prodname.add(a.Shelf_Pack_4__c);
            
            //added by unnat
            if(a.Shelf_Pack_5__c!=null)
                prodname.add(a.Shelf_Pack_5__c);
            if(a.Shelf_Pack_6__c!=null)
                prodname.add(a.Shelf_Pack_6__c);
            if(a.Array_Cache__c!=null)
                prodname.add(a.Array_Cache__c);
            if(a.Shelf_Pack_1B__c!=null)
                prodname.add(a.Shelf_Pack_1B__c);
            if(a.Shelf_Pack_2B__c!=null)
                prodname.add(a.Shelf_Pack_2B__c);
            if(a.Shelf_Pack_3B__c!=null)
                prodname.add(a.Shelf_Pack_3B__c);
            if(a.Shelf_Pack_4B__c!=null)
                prodname.add(a.Shelf_Pack_4B__c);
            if(a.Shelf_Pack_5B__c!=null)
                prodname.add(a.Shelf_Pack_5B__c);
            if(a.Shelf_Pack_6B__c!=null)
                prodname.add(a.Shelf_Pack_6B__c);  
            if(a.Expansion_Shelf_Base__c!=null)            
                prodname.add(a.Expansion_Shelf_Base__c);
            if(a.ProductCode__c!=null)            
                prodname.add(a.ProductCode__c);
            if(a.Controller_Refresh_1__c!=null)            
                prodname.add(a.Controller_Refresh_1__c);
            
            
            // Added by rkodali for AFA chnages
            
            
            if(a.Parent_Asset__c!=null)
                AssetIds.add(a.Parent_Asset__c);
            
            
        }
        // commented by Yesha Benegal on 22/01/2021
        
        if(AssetIds.size() >0){
            for(Asset ax: [select id, name, Array_Controller__c from asset where id in: AssetIds limit: AssetIds.size()]){
                ParentControllerMap.put(ax.id,ax.Array_Controller__c);
            } //end of comment 
        }
        
        List<Product2> lstProduct = new List<Product2>(); 
        //added by venkat march 2018
        for(Product2  pz:[select ProductCode,name,Family, Component_Code__c, asset_Type__c,Array_Controller__c, infosight_identifier__c, 
                          HPE_SKU__C, SSD_Capacity__c, Controller_Refresh_SKU__c,Controller_Refresh_Networking_SKU__c,Product_Type_2__c, 
                          Simplivity_SKU__c, parent_product__c, Storage_Capacity_Raw__c, Shelves_Qty_Allowed__c  from Product2  
                          where (Component_Code__c in:prodname OR Infosight_Identifier__c IN: prodName OR ProductCode in:prodname) ])//added field by venkat on april 18 2018
        {
            ProductCodeHPESKUMap.put(pz.ProductCode,pz); 
            ProductCodeSSD_Map.put(pz.ProductCode,pz.SSD_Capacity__c); 
            prodContrrefresh.put(pz.Name,pz.Controller_Refresh_SKU__c);
            If(pz.Product_Type_2__c == 'Networking'){
                prodArrayNetworking.put(pz.Name,pz.Controller_Refresh_SKU__c);
                prodArrayNetworkingSKU.put(pz.Name, pz.Controller_Refresh_Networking_SKU__c);
            }
            if(pz.parent_product__c != True){
                lstProduct.add(pz);
            }
        }
        
        for(Product2 p: lstProduct)
        {
            HPESKUProductMap.put(p.HPE_SKU__C,p);
            SimplivitySKUMap.put(p.HPE_SKU__c,p.Simplivity_SKU__c);
            if (p.infosight_identifier__c!= null) {
                multipicklistAssetTypeMap.put(p.infosight_identifier__c,p);
            }
            if(p.asset_Type__c != null) {
                //added by venkat asset type changes-april 18 2018-start
                Set<String> multiselectValues = new Set<String>();
                multiSelectValues.addAll(p.asset_Type__c.split(';'));
                for(string assettypestr:multiselectValues){
                    if(p.Array_Controller__c!=null){
                        Set<String> multiselectcontrller = new Set<String>();
                        multiselectcontrller.addAll(p.Array_Controller__c.split(';'));
                        for(string controllerassset:multiselectcontrller){
                            multipicklistAssetTypeMap.put(p.Component_Code__c+'-'+assettypestr, p); 
                        }
                    }
                    
                    
                    multipicklistAssetTypeMap.put(p.Component_Code__c+'-'+assettypestr, p);   
                    
                    
                    
                }
                //added by venkat asset type changes-april 18 2018-end
                if(p.asset_Type__c.contains(';')){
                    Set<String> strAstType = new Set<String>();
                    strAstType.addAll(p.asset_Type__c.split(';'));
                    for(String str1 : strAstType){
                        AssetTypeProductMap.put(p.Component_Code__c+'-'+str1, p);
                    }
                } 
                else{        
                    AssetTypeProductMap.put(p.Component_Code__c+'-'+p.Asset_Type__c, p);
                }
                
                /****/
                if(mAssetTypeProductMap.containskey(p.Component_Code__c+'-'+p.Asset_Type__c)){
                    List<Product2> plist = mAssetTypeProductMap.get(p.Component_Code__c+'-'+p.Asset_Type__c);
                    plist.add(p);
                    mAssetTypeProductMap.put(p.Component_Code__c+'-'+p.Asset_Type__c,plist);
                }
                else{
                    if(p.asset_Type__c.contains(';')){
                        Set<String> strAstType = new Set<String>();
                        strAstType.addAll(p.asset_Type__c.split(';'));
                        for(String str1 : strAstType){
                            mAssetTypeProductMap.put(p.Component_Code__c+'-'+str1,new List<Product2>{p});
                        }
                        
                    }
                    else
                        mAssetTypeProductMap.put(p.Component_Code__c+'-'+p.Asset_Type__c, new List<Product2>{p});
                    
                }
                
                /***/
                
                //CompCode2PrdCodeMap.put(p.Component_Code__c,p.ProductCode);
                if (p.infosight_identifier__c!= null) {
                    Set<String> multiselectValues1 = new Set<String>();
                    multiSelectValues1.addAll(p.asset_Type__c.split(';'));
                    for(string assettypestr:multiselectValues1){
                        
                        if(p.Array_Controller__c!=null){
                            Set<String> multiselectcontrller1 = new Set<String>();
                            multiselectcontrller1.addAll(p.Array_Controller__c.split(';'));
                            for(string controllerassset:multiselectcontrller1){
                                multipicklistAssetTypeMap.put(p.Infosight_Identifier__c+'-'+assettypestr+'-'+controllerassset, p); 
                            }
                        }
                        
                        multipicklistAssetTypeMap.put(p.Infosight_Identifier__c+'-'+assettypestr, p);  
                    }
                    //added by venkat asset type changes-april 18 2018-end
                    AssetTypeProductMap.put(p.Infosight_Identifier__c+'-'+p.Asset_Type__c, p);
                    
                    /****/
                    if(mAssetTypeProductMap.containskey(p.Infosight_Identifier__c+'-'+p.Asset_Type__c)){
                        List<Product2> plist = mAssetTypeProductMap.get(p.Infosight_Identifier__c+'-'+p.Asset_Type__c);
                        plist.add(p);
                        mAssetTypeProductMap.put(p.Infosight_Identifier__c+'-'+p.Asset_Type__c,plist);
                    }
                    else{
                        mAssetTypeProductMap.put(p.Infosight_Identifier__c+'-'+p.Asset_Type__c, new List<Product2>{p});
                    }
                    /****/
                    
                }
                //added by venkat march 2018
                if (p.HPE_SKU__C!= null) {
                    AssetTypeProductMap.put(p.HPE_SKU__C, p);
                    /****/
                    if(mAssetTypeProductMap.containskey(p.HPE_SKU__C)){
                        List<Product2> plist = mAssetTypeProductMap.get(p.HPE_SKU__C);
                        plist.add(p);
                        mAssetTypeProductMap.put(p.HPE_SKU__C,plist);
                    }
                    else{
                        mAssetTypeProductMap.put(p.HPE_SKU__C, new List<Product2>{p});
                    }
                    /***/
                }
            }
            else {
                //multipicklistAssetTypeMap.put(p.Component_Code__c, p);  
                pronamecompmap.put(p.Component_Code__c,p.ProductCode);
                prdMap.put(p.ProductCode, p);
                if (p.infosight_identifier__c!= null) {
                    infosightToProdMap.put(p.infosight_identifier__c, p.ProductCode);
                }
            }
        }
        if(trigger.isBefore )
        {    
            Map<id,Asset> oldMap = new Map<id,Asset>();
            Map<String, Install_Country_ISO_Code__c> installcountryISOmap = new Map<String, Install_Country_ISO_Code__c>();
            for(Install_Country_ISO_Code__c ic: [select name, ISO_Country__c from Install_Country_ISO_Code__c]){
                installcountryISOmap.put(ic.name.tolowercase(), ic);
            }
            for(Asset a:trigger.new)
            {   
                if(a.Install_Country__c!=null && installcountryISOmap.containsKey(a.Install_Country__c.tolowercase()) ){ //added by venkat -Upgrade Automation Project-21 May 2018
                    a.Install_Country_ISO_Code__c=installcountryISOmap.get(a.Install_Country__c.tolowercase()).ISO_Country__c;
                }
                else{
                    a.Install_Country_ISO_Code__c='';
                }
                if(Trigger.isInsert)//Added by Venkat 
                { 
                    a.First_Support_End_Date__c  = a.Support_End_Date__c;
                }
                //11-6-2014 Sundar: update converted_from_eval__c flag when eval unit is purchased
                if(Trigger.isUpdate)//Added by pradeep for test class fix
                {
                    String oldOrdType = trigger.oldMap.get(a.id).Order_Type__c;
                    if(oldOrdType != null && oldOrdType != '' &&  oldOrdType != ' '){    //Added Null check by Venkat GattaManeni 12/15/2017
                        if ( a.Order_Type__c == 'Purchased' && ( oldOrdType.StartsWith('Eval') || oldOrdType.StartsWith ('Demo'))) {
                            a.Converted_From_Eval__c = true;
                        }
                    }
                }
                
                if((a.Asset_Product_Family__c=='Hybrid Flash Array')){//Added by venkat for asset type change on 4/3/2018
                    a.Asset_Type_Build__c = 'HFA';
                }
                else if(a.Asset_Product_Family__c=='All Flash Array Gen5'){ //Added by venkat for asset type change on 4/3/2018
                    a.Asset_Type_Build__c = 'AFA2';   
                }
                else if(a.Asset_Product_Family__c=='All Flash Shelf 2'){//Added by venkat for asset type change on 4/3/2018
                    a.Asset_Type_Build__c = 'AFS3';   
                }
                else if(a.Asset_Product_Family__c=='Expansion Shelf 3'){//Added by venkat for asset type change on 4/3/2018
                    a.Asset_Type_Build__c = 'Expansion Shelf 3';
                    
                }
                IF(a.Expansion_Shelf_Base__c  != null){
                    if(a.Expansion_Shelf_Base__c.startsWithIgnoreCase('ES3')){
                        a.Asset_Type_Build__c = 'Expansion Shelf 3';
                    }else if(a.Dynamic_SKU__c!=null && a.Dynamic_SKU__c.startsWithIgnoreCase('AFS3')){
                        a.Asset_Type_Build__c = 'AFS3';
                    }
                    else if(a.Dynamic_SKU__c != null && a.Dynamic_SKU__c.startsWithIgnoreCase('2140')){
                        a.Asset_Type_Build__c = 'AFS4';
                        
                        
                    }
                    
                }
                if(a.Asset_Type__c=='Expansion Shelf 2' || a.Asset_Type__c=='Expansion Shelf 3' ){
                    a.SSD_Bank_A__c='';
                    a.SSD_Bank_A_SKU__c='';
                }
                
                if(!a.contains_HPESKU__c){
                    // adding new field to calculate sku codes: Component_SKU_Nimble_V2__c
                    
                    a.Component_SKU_Nimble_V2__c = '';
                    if(a.Expansion_Shelf_Base__c !=null && a.Asset_Product_Family__c!=null && (a.Expansion_Shelf_Base__c.startsWithIgnoreCase('ES') 
                        || a.Expansion_Shelf_Base__c.startsWithIgnoreCase('AFS') || a.Expansion_Shelf_Base__c.startsWithIgnoreCase('SF')
                        || a.Expansion_Shelf_Base__c.startsWithIgnoreCase('2140'))){
                           a.Component_SKU_Nimble_V2__c = a.Expansion_Shelf_Base__c;
                           
                        }
                    //Array Controller
                    if(a.Array_Controller__c!= null) {
                        if (multipicklistAssetTypeMap.containsKey(a.Array_Controller__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Controller__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { 
                            a.Array_Controller_SKU__c = multipicklistAssetTypeMap.get(a.Array_Controller__c+'-'+a.Asset_Type__c).ProductCode;
                            a.Product2Id= multipicklistAssetTypeMap.get(a.Array_Controller__c+'-'+a.Asset_Type__c).id;//added by venkat asset type changes-april 18 2018
                        }
                        else{
                            //i.e. Instead of populating AFA on Product, populate it with AF3000 or AF5000 or AF7000
                            if((a.Asset_Product_Family__c == 'All Flash Array' || a.Asset_Product_Family__c == 'Adaptive Flash Array' || a.Asset_Product_Family__c == 'Secondary Flash Array' ||a.Asset_Product_Family__c =='Adaptive Flash Array Gen5' )
                               && prdMap.containsKey(a.Array_Controller__c)){
                                a.Product2Id= prdMap.get(a.Array_Controller__c).id;                              
                            }
                            if(infosightToProdMap.containsKey(a.Array_Controller__c))
                                a.Array_Controller_SKU__c = infosightToProdMap.get(a.Array_Controller__c);
                            else 
                                a.Array_Controller_SKU__c=pronamecompmap.get(a.Array_Controller__c);
                        }
                        if(a.IS_Array_Controller__c != null && a.Asset_Type__c == 'CS Hybrid Arrays' && a.Array_Controller__c != null){
                            if(multipicklistAssetTypeMap.get(a.Array_Controller__c) != null){
                                a.Product2Id = multipicklistAssetTypeMap.get(a.Array_Controller__c).id;
                            }
                           
                        }
                        if(a.IS_Array_Controller__c == 'HF40H'){
                            a.Component_SKU_Nimble_V2__c = a.Array_Controller_SKU__c;
                        }
                        if(a.IS_Array_Controller__c == '5030H'){
                            a.array_controller_SKU__c = '5030H';
                            a.Component_SKU_Nimble_V2__c = 'S1Z75A';
                        }
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.Array_Controller__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Controller__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller__c).Array_Controller__c).contains(a.Array_Controller__c))) { 
                            a.Array_Controller_SKU__c = multipicklistAssetTypeMap.get(a.Array_Controller__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller__c).ProductCode;                    
                        }//added by venkat asset type changes-april 18 2018
                        if(a.Array_Controller_SKU__c==null && multipicklistAssetTypeMap.containskey(a.Array_Controller__c) && multipicklistAssetTypeMap.get(a.Array_Controller__c).ProductCode!=null)
                            a.Array_Controller_SKU__c=multipicklistAssetTypeMap.get(a.Array_Controller__c).ProductCode;
                            
                         if((a.Array_controller__c == '5030' || a.Array_Controller__c == '5050') && a.Controller_Refresh_Date__c == null && Trigger.OldMap != null 
                             && Trigger.oldMap.get(a.Id).Array_Controller__c != '5050'  && Trigger.oldMap.get(a.Id).Array_Controller__c != '5030'
                             && a.Cross_Family_Upgrade__c == True){
                            a.Controller_Refresh_Date__c = system.today();
                        }
                    }
                    //Start->SFDC-1124
                    if(a.Cross_Family_Upgrade__c == True){
                        a.HPE_Product_SKU__c = a.Product2.HPE_SKU__c;
                    }
                    //End->SFDC-1124
                    if(a.Array_Controller_SKU__c != null)
                        a.Component_SKU_Nimble_V2__c = a.Array_Controller_SKU__c;
                    
                    
                    //Array Networking
                    // Story -ESS-94250 - Added by Jana on - 01/23/2023
                    if(a.Array_Networking__c!= null && a.asset_Type__c != 'Legacy'){
                        //2P CS Hybrid Arrays CS5000
                        if (multipicklistAssetTypeMap.containsKey(a.Array_Networking__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { 
                            a.Array_Networking_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking__c+'-'+a.Asset_Type__c).ProductCode;     //added by venkat asset type changes-april 18 2018      
                        }
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Networking__c))
                                a.Array_Networking_SKU__c = infosightToProdMap.get(a.Array_Networking__c);
                            else
                                a.Array_Networking_SKU__c=pronamecompmap.get(a.Array_Networking__c);
                            
                        }
                        
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.Array_Networking__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c))) { 
                            a.Array_Networking_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;                    
                            
                        } //added by venkat asset type changes-april 18 2018
                        
                        if(a.Array_Networking_SKU__c==null && multipicklistAssetTypeMap.containskey(a.Array_Networking__c) && multipicklistAssetTypeMap.get(a.Array_Networking__c).ProductCode!=null){
                            a.Array_Networking_SKU__c=multipicklistAssetTypeMap.get(a.Array_Networking__c).ProductCode;
                        }                        
                    }
                    
                    if(a.Array_Networking_2__c!= null){
                        //2P CS Hybrid Arrays CS5000
                        if (multipicklistAssetTypeMap.containsKey(a.Array_Networking_2__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_2__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { 
                            a.Array_Networking_2_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_2__c+'-'+a.Asset_Type__c).ProductCode;     //added by venkat asset type changes-april 18 2018      
                        }
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Networking_2__c))
                                a.Array_Networking_2_SKU__c = infosightToProdMap.get(a.Array_Networking_2__c);
                            else
                                a.Array_Networking_2_SKU__c=pronamecompmap.get(a.Array_Networking_2__c);
                            
                        }
                        
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.Array_Networking_2__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_2__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c))) { 
                            a.Array_Networking_2_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_2__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;                    
                            
                        } //added by venkat asset type changes-april 18 2018
                        
                        if(a.Array_Networking_2_SKU__c==null && multipicklistAssetTypeMap.containskey(a.Array_Networking_2__c) && multipicklistAssetTypeMap.get(a.Array_Networking_2__c).ProductCode!=null){
                            a.Array_Networking_2_SKU__c=multipicklistAssetTypeMap.get(a.Array_Networking_2__c).ProductCode;
                        }                        
                    }
                    
                    if(a.Array_Networking_3__c!= null){
                        //2P CS Hybrid Arrays CS5000
                        if (multipicklistAssetTypeMap.containsKey(a.Array_Networking_3__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_3__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { 
                            a.Array_Networking_3_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_3__c+'-'+a.Asset_Type__c).ProductCode;     //added by venkat asset type changes-april 18 2018      
                        }
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Networking_3__c))
                                a.Array_Networking_3_SKU__c = infosightToProdMap.get(a.Array_Networking_3__c);
                            else
                                a.Array_Networking_3_SKU__c=pronamecompmap.get(a.Array_Networking_3__c);
                            
                        }
                        
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.Array_Networking_3__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_3__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c))) { 
                            a.Array_Networking_3_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_3__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;                    
                            
                        } //added by venkat asset type changes-april 18 2018
                        
                        if(a.Array_Networking_3_SKU__c==null && multipicklistAssetTypeMap.containskey(a.Array_Networking_3__c) && multipicklistAssetTypeMap.get(a.Array_Networking_3__c).ProductCode!=null){
                            a.Array_Networking_3_SKU__c=multipicklistAssetTypeMap.get(a.Array_Networking_3__c).ProductCode;
                        }                        
                    }
                    /*** changes for bluetail -  Yesha Benegal March-2021****/
                    if(a.Array_Networking_4__c!= null){
                        if (multipicklistAssetTypeMap.containsKey(a.Array_Networking_4__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_4__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { 
                            a.Array_Networking_4_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_4__c+'-'+a.Asset_Type__c).ProductCode;     
                        }
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Networking_4__c))
                                a.Array_Networking_4_SKU__c = infosightToProdMap.get(a.Array_Networking_4__c);
                            else
                                a.Array_Networking_4_SKU__c=pronamecompmap.get(a.Array_Networking_4__c);
                            
                        }
                        
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.Array_Networking_4__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_4__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c))) { 
                            a.Array_Networking_4_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_4__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;                    
                            
                        } 
                        
                        if(a.Array_Networking_4_SKU__c==null && multipicklistAssetTypeMap.containskey(a.Array_Networking_4__c) && multipicklistAssetTypeMap.get(a.Array_Networking_4__c).ProductCode!=null){
                            a.Array_Networking_4_SKU__c=multipicklistAssetTypeMap.get(a.Array_Networking_4__c).ProductCode;
                        }                        
                    }
                    
                    if(a.Array_Networking_5__c!= null){
                        if (multipicklistAssetTypeMap.containsKey(a.Array_Networking_5__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_5__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { 
                            a.Array_Networking_5_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_5__c+'-'+a.Asset_Type__c).ProductCode;        
                        }
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Networking_5__c))
                                a.Array_Networking_5_SKU__c = infosightToProdMap.get(a.Array_Networking_5__c);
                            else
                                a.Array_Networking_5_SKU__c=pronamecompmap.get(a.Array_Networking_5__c);
                            
                        }
                        
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.Array_Networking_5__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_5__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c))) { 
                            a.Array_Networking_5_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_5__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;                    
                            
                        }
                        if(a.Array_Networking_5_SKU__c==null && multipicklistAssetTypeMap.containskey(a.Array_Networking_5__c) && multipicklistAssetTypeMap.get(a.Array_Networking_5__c).ProductCode!=null){
                            a.Array_Networking_5_SKU__c=multipicklistAssetTypeMap.get(a.Array_Networking_5__c).ProductCode;
                        }                        
                    }
                    
                    if(a.Array_Networking_6__c!= null){
                        if (multipicklistAssetTypeMap.containsKey(a.Array_Networking_6__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_6__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { 
                            a.Array_Networking_6_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_6__c+'-'+a.Asset_Type__c).ProductCode;        
                        }
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Networking_6__c))
                                a.Array_Networking_6_SKU__c = infosightToProdMap.get(a.Array_Networking_6__c);
                            else
                                a.Array_Networking_6_SKU__c=pronamecompmap.get(a.Array_Networking_6__c);
                            
                        }
                        
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.Array_Networking_6__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Networking_6__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c))) { 
                            a.Array_Networking_6_SKU__c = multipicklistAssetTypeMap.get(a.Array_Networking_6__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;                    
                            
                        }
                        if(a.Array_Networking_6_SKU__c==null && multipicklistAssetTypeMap.containskey(a.Array_Networking_6__c) && multipicklistAssetTypeMap.get(a.Array_Networking_6__c).ProductCode!=null){
                            a.Array_Networking_6_SKU__c=multipicklistAssetTypeMap.get(a.Array_Networking_6__c).ProductCode;
                        }                        
                    }
                    /*** end of changes for bluetail - Yesha Benegal March-2021 ***/
                    if(a.Array_Networking_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Array_Networking_SKU__c;
                    if(a.Array_Networking_2_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Array_Networking_2_SKU__c;
                    if(a.Array_Networking_3_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Array_Networking_3_SKU__c;
                    if(a.Array_Networking_4_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Array_Networking_4_SKU__c;
                    if(a.Array_Networking_5_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Array_Networking_5_SKU__c;
                    if(a.Array_Networking_6_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Array_Networking_6_SKU__c;
                    
                    a.Total_SSD_Banks_Cache__c = 0;
                    //Array capacity  
                    // Story -ESS-94250 - Added by Jana on - 01/23/2023
                    if(a.Array_Capacity__c!= null && a.asset_Type__c!='Legacy') {
                        
                        if (multipicklistAssetTypeMap.containsKey(a.Array_Capacity__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Capacity__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { 
                            a.Array_Capacity_SKU__c = multipicklistAssetTypeMap.get(a.Array_Capacity__c+'-'+a.Asset_Type__c).ProductCode; 
                            
                        }//added by venkat asset type changes-april 18 2018
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Capacity__c))
                                a.Array_Capacity_SKU__c = infosightToProdMap.get(a.Array_Capacity__c);
                            else
                                a.Array_Capacity_SKU__c=pronamecompmap.get(a.Array_Capacity__c);
                        }
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.Array_Capacity__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) 
                            && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Capacity__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c))) { 
                                a.Array_Capacity_SKU__c = multipicklistAssetTypeMap.get(a.Array_Capacity__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;                    
                                
                            }//added by venkat asset type changes-april 18 2018
                        
                        if(a.Array_Controller__c!=null && a.Array_Capacity_SKU__c==null && multipicklistAssetTypeMap.containsKey(a.Array_Capacity__c) 
                           && multipicklistAssetTypeMap.get(a.Array_Capacity__c).ProductCode!=null 
                           && multipicklistAssetTypeMap.get(a.Array_Capacity__c).Array_Controller__c !=null 
                           && multipicklistAssetTypeMap.get(a.Array_Capacity__c).Array_Controller__c.contains(a.Array_Controller__c)){
                               a.Array_Capacity_SKU__c = multipicklistAssetTypeMap.get(a.Array_Capacity__c).ProductCode;
                               
                           }
                        
                    }
                    
                    if(a.Array_Capacity_SKU__c!=null && a.Array_capacity__c != '22T'){
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Array_Capacity_SKU__c;
                    }
                    else if(a.Array_Capacity__c == '22T' && a.Asset_Type__c == 'CS Hybrid Arrays'){
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c + ',HEAD-HDD-11TB,HEAD-HDD-11TB';
                    }
                    else if(a.Array_Capacity__c == '22T' && a.Asset_Type__c == 'HFA'){
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c + ',HEAD-HDD-11TBC,HEAD-HDD-11TBC';
                    } 
                    else if(a.Asset_Type__c == 'A5000'){
                        if(a.Array_Capacity__c == '44T'){
                            a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c + ',HEAD-HDD-22TB-G6,HEAD-HDD-22TB-G6';
                        }
                        else if(a.Array_Capacity__c == '22T'){
                            a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c + ','+ a.Array_Capacity_SKU__c;
                        }
                    } 
                    // Story -ESS-94250 - Added by Jana on - 01/23/2023
                    if(a.Array_Cache__c!= null && a.asset_Type__c!='Legacy'){ 
                        if(a.Asset_Type__c != 'AFA')
                            
                            if (multipicklistAssetTypeMap.containsKey(a.Array_Cache__c+'-'+a.Asset_Type__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c))) { 
                                a.Array_Cache_SKU__c = multipicklistAssetTypeMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).ProductCode;    //added by venkat asset type changes-april 18 2018                
                                
                            }
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Cache__c))
                                a.Array_Cache_SKU__c = infosightToProdMap.get(a.Array_Cache__c);
                            else
                                a.Array_Cache_SKU__c=pronamecompmap.get(a.Array_Cache__c);  
                            
                        }  
                        
                        else
                            a.Array_Cache_SKU__c='';
                        if (a.Array_Controller__c!=null && (multipicklistAssetTypeMap.containsKey(a.Array_Cache__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c)))) { 
                            a.Array_Cache_SKU__c = multipicklistAssetTypeMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;                    
                        }           //added by venkat asset type changes-april 18 2018      
                        if(a.Array_Cache_SKU__c==null && multipicklistAssetTypeMap.containskey(a.Array_Cache__c) && multipicklistAssetTypeMap.get(a.Array_Cache__c)!=null){
                            if(multipicklistAssetTypeMap.get(a.Array_Cache__c).Asset_Type__c == a.Asset_Type__c)
                                a.Array_Cache_SKU__c=multipicklistAssetTypeMap.get(a.Array_Cache__c).ProductCode;
                            
                        }
                    }
                    
                    if(a.asset_Type__c == 'A5000' && a.IS_array_cache__c == '3840F'){
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +',' +'HEAD-FLC-1920GB-G6,HEAD-FLC-1920GB-G6';
                        
                    }                   
                    else if(a.Asset_Type__c == 'AFA'  || a.Asset_Type__c == 'CS Hybrid Arrays' || a.Asset_Type__c == 'AFA2' || 
                        a.Asset_Type__c == 'Expansion Shelf 3' || a.Asset_Type__c == 'AFS3' || a.HFCacheOnly__c == False || 
                        a.asset_Type__c == 'AFS4' || a.asset_Type__c == 'A5000'){   
                        
                    }
                    
                    else{ 
                        
                        if(a.Array_Cache_SKU__c!=null)
                            a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Array_Cache_SKU__c;
                        if(ProductCodeSSD_Map.get(a.Array_Cache_SKU__c) != null)
                            a.Total_SSD_Banks_Cache__c = ProductCodeSSD_Map.get(a.Array_Cache_SKU__c);
                    }
                    
                    
                    // added by rkodali for AFA chnages
                    //SSD bank A
                    // Story -ESS-94250 - Added by Jana on - 01/23/2023
                    if(a.SSD_Bank_A__c!= null && !HFCache && a.Asset_Type__c != 'A6000' && a.asset_Type__c!='Legacy'){
                        if (multipicklistAssetTypeMap.containsKey(a.SSD_Bank_A__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.SSD_Bank_A__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { //added by venkat asset type changes-april 18 2018
                            a.SSD_Bank_A_SKU__c = multipicklistAssetTypeMap.get(a.SSD_Bank_A__c+'-'+a.Asset_Type__c).ProductCode;   //added by venkat asset type changes-april 18 2018    
                            
                        }
                        else{
                            if(infosightToProdMap.containsKey(a.SSD_Bank_A__c)) {
                                a.SSD_Bank_A_SKU__c = infosightToProdMap.get(a.SSD_Bank_A__c);
                                
                                
                            }else{
                                a.SSD_Bank_A_SKU__c=pronamecompmap.get(a.SSD_Bank_A__c);
                                
                            }
                        }
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.SSD_Bank_A__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.SSD_Bank_A__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c))) { 
                            a.SSD_Bank_A_SKU__c = multipicklistAssetTypeMap.get(a.SSD_Bank_A__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;  
                            
                            
                        }//added by venkat asset type changes-april 18 2018
                        if(a.SSD_Bank_A_SKU__c==null && multipicklistAssetTypeMap.containskey(a.SSD_Bank_A__c) && multipicklistAssetTypeMap.get(a.SSD_Bank_A__c).ProductCode!=null){
                            a.SSD_Bank_A_SKU__c = multipicklistAssetTypeMap.get(a.SSD_Bank_A__c).ProductCode;
                            
                        }
                    }
                    
                    else if(a.Asset_Type__c == 'A6000' && a.SSD_Bank_A__c != null){
                        
                        if(a.IS_SSD_Count__c != null)
                            a.SSD_Bank_A_SKU__c = NextGenTriggerClass.calculateBANKSKU(a.SSD_Bank_A__c,a.IS_SSD_Count__c ,a.Array_Controller__c, a.Asset_Type__c, a.IS_SSD_Packs__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);
                        else{
                            if(a.SSD_Count__c != null){
                                a.SSD_Bank_A_SKU__c = NextGenTriggerClass.calculateBANKSKU(a.SSD_Bank_A__c,a.SSD_Count__c ,a.Array_Controller__c, a.Asset_Type__c, a.SSD_Packs__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);
                            }
                            else{
                                a.SSD_Bank_A_SKU__c = NextGenTriggerClass.calculateBankSKU2(a.SSD_Bank_A__c, a.Asset_Type__c,a.Array_Controller__c, multipicklistAssetTypeMap);                     
                            }
                            
                        }
                        
                    }
                    if(a.SSD_Bank_A_SKU__c!=null){
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.SSD_Bank_A_SKU__c;
                        if(ProductCodeSSD_Map.get(a.SSD_Bank_A_SKU__c) != null)
                            a.Total_SSD_Banks_Cache__c = ProductCodeSSD_Map.get(a.SSD_Bank_A_SKU__c);
                        
                    }
                    
                    //SSD bank B
                    // Story -ESS-94250 - Added by Jana on - 01/23/2023
                    if(a.SSD_Bank_B__c!= null && !HFCache && a.Asset_Type__c != 'A6000' && a.asset_Type__c!='Legacy'){
                        //a.SSD_Bank_B_SKU__c=pronamecompmap.get(a.SSD_Bank_B__c);
                        
                        if (multipicklistAssetTypeMap.containsKey(a.SSD_Bank_B__c+'-'+a.Asset_Type__c) && JSON.serialize(multipicklistAssetTypeMap.get(a.SSD_Bank_B__c+'-'+a.Asset_Type__c).Asset_Type__c).contains(a.Asset_Type__c)) { 
                            a.SSD_Bank_B_SKU__c = multipicklistAssetTypeMap.get(a.SSD_Bank_B__c+'-'+a.Asset_Type__c).ProductCode;  //added by venkat asset type changes-april 18 2018                  
                        }
                        else{
                            //added by venkat march 2018
                            if(infosightToProdMap.containsKey(a.SSD_Bank_B__c)){
                                a.SSD_Bank_B_SKU__c = infosightToProdMap.get(a.SSD_Bank_B__c);
                            }
                            else{
                                a.SSD_Bank_B_SKU__c=pronamecompmap.get(a.SSD_Bank_B__c);
                            }
                        }
                        if (a.Array_Controller__c!=null && multipicklistAssetTypeMap.containsKey(a.SSD_Bank_B__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c) && (JSON.serialize(multipicklistAssetTypeMap.get(a.SSD_Bank_B__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).Array_Controller__c).contains(a.Array_Controller_SKU__c))) { 
                            a.SSD_Bank_B_SKU__c = multipicklistAssetTypeMap.get(a.SSD_Bank_B__c+'-'+a.Asset_Type__c+'-'+a.Array_Controller_SKU__c).ProductCode;                    
                        }//added by venkat asset type changes-april 18 2018
                        if(a.SSD_Bank_B_SKU__c==null && multipicklistAssetTypeMap.containskey(a.SSD_Bank_B__c) && multipicklistAssetTypeMap.get(a.SSD_Bank_B__c).ProductCode!=null)
                            a.SSD_Bank_B_SKU__c = multipicklistAssetTypeMap.get(a.SSD_Bank_B__c).ProductCode;
                    }  
                    
                    else if(a.Asset_Type__c == 'A6000' && a.SSD_Bank_B__c != null){
                        if(a.IS_SSD_Count__c != null)
                            a.SSD_Bank_B_SKU__c = NextGenTriggerClass.calculateBANKSKU(a.SSD_Bank_B__c,a.IS_SSD_Count__c ,a.Array_Controller__c, a.Asset_Type__c, a.IS_SSD_Packs__c, multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);    
                        else{
                            if(a.SSD_Count__c != null){
                                a.SSD_Bank_B_SKU__c = NextGenTriggerClass.calculateBANKSKU(a.SSD_Bank_B__c,a.SSD_Count__c ,a.Array_Controller__c, a.Asset_Type__c, a.SSD_Packs__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);
                            }
                            a.SSD_Bank_B_SKU__c = NextGenTriggerClass.calculateBankSKU2(a.SSD_Bank_B__c, a.Asset_Type__c,a.Array_Controller__c, multipicklistAssetTypeMap);                     
                        }
                    }
                    
                    if(a.SSD_Bank_B_SKU__c!=null){
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.SSD_Bank_B_SKU__c;
                        if(ProductCodeSSD_Map.get(a.SSD_Bank_B_SKU__c) != null)
                            a.Total_SSD_Banks_Cache__c = a.Total_SSD_Banks_Cache__c + ProductCodeSSD_Map.get(a.SSD_Bank_B_SKU__c);
                        
                    }  
                   
                    //Shelf Pack 1
                    if(a.Shelf_Pack_1__c!= null){
                        if(a.Asset_Type_Build__c != 'AFS4'){ 
                            a.Shelf_Pack_1_SKU__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_1__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);
                        
                        }
                        else{
                            string val = a.Shelf_Pack_1__c + 'F';
                            if(a.IS_SSD_Count__c == null && a.Shelf_Pack_2__c == null){
                                
                                a.Shelf_Pack_1_SKU__c = NextGenTriggerClass.calculateBANKSKU(val, 12, a.expansion_shelf_base__c, a.Asset_Type_Build__c,a.Shelf_Quantity__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);    
                                
                            } 
                            else if(a.Shelf_Pack_2__c != null){
                                a.Shelf_Pack_1_SKU__c = NextGenTriggerClass.calculateBANKSKU(val, 24, a.expansion_shelf_base__c, a.Asset_Type_Build__c,2,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);    
                                
                            }                       
                        }
                        
                    }
                    if(a.Shelf_Pack_1_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_1_SKU__c;
                    
                    
                    //Shelf Pack 2
                    if(a.Shelf_Pack_2__c!= null){
                        if(a.Asset_Type_Build__c != 'AFS4'){
                            a.Shelf_Pack_2_SKU__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_2__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);
                        }
                        else{
                            string val = a.Shelf_Pack_2__c + 'F';
                            if(a.IS_SSD_Count__c == null && a.Shelf_Pack_2__c != null){
                                
                                a.Shelf_Pack_2_SKU__c = NextGenTriggerClass.calculateBANKSKU(val, 24, a.expansion_shelf_base__c, a.Asset_Type_Build__c,a.Shelf_Quantity__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);    
                            } 
                            else if(a.Shelf_Pack_1__c != null){
                                a.Shelf_Pack_2_SKU__c = NextGenTriggerClass.calculateBANKSKU(val, 24, a.expansion_shelf_base__c, a.Asset_Type_Build__c,a.Shelf_Quantity__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);    
                            } 
                            
                        }
                    }
                    if(a.Shelf_Pack_2_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_2_SKU__c;
                    
                    
                    //Shelf Pack 3
                    if(a.Shelf_Pack_3__c!= null){
                        a.Shelf_Pack_3_SKU__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_3__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);                                                                                                                   
                        
                    }
                    if(a.Shelf_Pack_3_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_3_SKU__c;
                    
                    
                    //Shelf Pack 4
                    if(a.Shelf_Pack_4__c!= null){
                        a.Shelf_Pack_4_SKU__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_4__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);                                                                                              
                        
                    }
                    if(a.Shelf_Pack_4_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_4_SKU__c;
                    
                    
                    //Shelf Pack 5
                    if(a.Shelf_Pack_5__c!= null){
                        a.Shelf_Pack_5_SKU__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_5__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);                                                                          
                        
                    }
                    if(a.Shelf_Pack_5_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_5_SKU__c;
                    
                    
                    //Shelf Pack 6
                    if(a.Shelf_Pack_6__c!= null){
                        
                        a.Shelf_Pack_6__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_6__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);                                                      
                        
                    }
                    if(a.Shelf_Pack_6_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_6_SKU__c;
                    
                    
                    //Shelf Pack 7
                    if(a.Shelf_Pack_1B__c!= null){
                        a.Shelf_Pack_1B__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_1B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);
                        
                    }
                    if(a.Shelf_Pack_1B_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_1B_SKU__c;
                    
                    
                    //Shelf Pack 8
                    if(a.Shelf_Pack_2B__c!= null){
                        a.Shelf_Pack_2B__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_2B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);                   
                        
                    }
                    if(a.Shelf_Pack_2B_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_2B_SKU__c;
                    
                    
                    //Shelf Pack 9
                    if(a.Shelf_Pack_3B__c!= null){
                        a.Shelf_Pack_3B__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_3B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);                   
                        
                    }
                    if(a.Shelf_Pack_3B_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_3B_SKU__c;
                    
                    
                    //Shelf Pack 10
                    if(a.Shelf_Pack_4B__c!= null){
                        a.Shelf_Pack_4B__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_4B__c, a.Asset_Type__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);                                      
                        
                    }
                    if(a.Shelf_Pack_4B_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_4B_SKU__c;
                    
                    //Shelf Pack 11
                    if(a.Shelf_Pack_5B__c!= null){
                        a.Shelf_Pack_5B__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_5B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);                                      
                        
                    }
                    if(a.Shelf_Pack_5B_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_5B_SKU__c;
                    
                    
                    //Shelf Pack 12
                    if(a.Shelf_Pack_6B__c!= null){
                        a.Shelf_Pack_6B__c = NextGenTriggerClass.calculateShelfSKU(a.Shelf_Pack_6B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);                                                      
                        
                    }
                    if(a.Shelf_Pack_6B_SKU__c!=null)
                        a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c +','+ a.Shelf_Pack_6B_SKU__c;
                    if(a.Component_SKU_Nimble_V2__c != null){
                        a.Component_SKU_Nimble_V2__c =a.Component_SKU_Nimble_V2__c.removeStartIgnoreCase(',');
                        a.Component_SKU_Nimble_V2__c =a.Component_SKU_Nimble_V2__c.removeEndIgnoreCase(',');
                        a.Component_SKU_Nimble_V2__c =a.Component_SKU_Nimble_V2__c.removeEndIgnoreCase(',null');
                    }  
                }
                
                //END OF Legacy code      
                
                //added by venkat march 2018
                //Venkat Added
                a.Component_SKU_HPE__c='';
                //added by venkat on 7/3/2018-start
                //Asset Type Logic // added Mar/07/2018    
              
                string componentSKU = '';
                
                //added by venkat march 2018
                if(a.Expansion_Shelf_Base__c !=null && a.Asset_Product_Family__c!=null && (a.Asset_Product_Family__c.startsWithIgnoreCase('Expansion Shelf') || a.Asset_Product_Family__c.startsWithIgnoreCase('All Flash Shelf')  || a.Asset_Product_Family__c.startsWithIgnoreCase('Expansion')) ) {
                    
                    if(ProductCodeHPESKUMap.get(a.Expansion_Shelf_Base__c) != null){ 
                        if(ProductCodeHPESKUMap.get(a.Expansion_Shelf_Base__c).HPE_SKU__C != null && a.Simplivity_Chk__c == False)
                        {                           
                            a.Component_SKU_HPE__c = ProductCodeHPESKUMap.get(a.Expansion_Shelf_Base__c).HPE_SKU__C ;                            
                            componentSKU = a.Expansion_Shelf_Base__c;
                        }
                        
                        else if(ProductCodeHPESKUMap.get(a.Expansion_Shelf_Base__c).Simplivity_SKU__c != null && a.Simplivity_Chk__c == True)
                        {                           
                            a.Component_SKU_HPE__c = ProductCodeHPESKUMap.get(a.Expansion_Shelf_Base__c).Simplivity_SKU__c;                            
                            componentSKU = a.Expansion_Shelf_Base__c;
                        }
                   }    
                    
                    else{
                        if(a.Expansion_Shelf_Base__c != null)
                            a.Component_SKU_HPE__c = a.Expansion_Shelf_Base__c;
                        componentSKU = a.Expansion_Shelf_Base__c;
                    }
                    
                }                 
                //added by venkat on 7/3/2018-end
                //Array Controller
                String AstProductCode = a.ProductCode__c ; 
                          
                if(a.asset_type__c =='Legacy' && AstProductCode != null){
                    a.Component_SKU_HPE__c = ProductCodeHPESKUMap.get(AstProductCode).HPE_SKU__C ;
                    componentSKU = a.Expansion_Shelf_Base__c;
                    
                }               
               else if(a.asset_type__c != null && a.Asset_Product_Name__c != null && Label.non_Legacy_Type.contains(a.asset_type__c) &&  
                       ProductCodeHPESKUMap.get(a.Asset_Product_Name__c) != null && ProductCodeHPESKUMap.get(a.Asset_Product_Name__c).Product_Type_2__c == 'Uber SKU'){
                    if(a.Simplivity_Chk__c == true){
                        a.component_SKU_HPE__c = ProductCodeHPESKUMap.get(a.Asset_Product_Name__c)?.Simplivity_SKU__c;
                    }else{
                        a.component_SKU_HPE__c = ProductCodeHPESKUMap.get(a.Asset_Product_Name__c)?.HPE_SKU__c;
                    }
                }   
                if(a.Array_Controller__c!= null) {
                    if (a.Array_Controller__c != 'HF40H' && AssetTypeProductMap.containsKey(a.Array_Controller__c+'-'+a.Asset_Type__c) && a.Asset_Type__c == AssetTypeProductMap.get(a.Array_Controller__c+'-'+a.Asset_Type__c).Asset_Type__c) { 
                        a.Product2Id= AssetTypeProductMap.get(a.Array_Controller__c+'-'+a.Asset_Type__c).id;  
                    }else{
                        //September 2: If the asset contains controller SKU, update the Asset Product field with Controller id instead of Head Array Id
                        //i.e. Instead of populating AFA on Product, populate it with AF3000 or AF5000 or AF7000
                        //03/06/2018 Adding - All Flash Array Gen5
                        if((a.Asset_Product_Family__c == 'All Flash Array' || a.Asset_Product_Family__c == 'All Flash Array Gen5' || a.Asset_Product_Family__c == 'Adaptive Flash Array' || a.Asset_Product_Family__c == 'Secondary Flash Array' )  && prdMap.containsKey(a.Array_Controller__c) && prdMap.get(a.Array_Controller__c).id!=null){
                            a.Product2Id= prdMap.get(a.Array_Controller__c).id; 
                        }else{
                            // This below Condition handled for Cross family Upgrade
                            if(a.IS_Array_Controller__c!=null && a.Array_Controller__c != null && a.IS_Array_Controller__c== a.Array_Controller__c &&
                                multipicklistAssetTypeMap.get(a.Array_Controller__c) != null) {
                                 a.Product2Id= multipicklistAssetTypeMap.get(a.Array_Controller__c).id;
                                  
                            }
                        }
                    }
                    //VX Code - 03/06
                    if(a.Array_Controller_SKU__c == null && ProductCodeHPESKUMap.get(a.Array_Controller__c) !=null){//added for HFA issue on March 6th 2018-venkat
                        a.Array_Controller_SKU__c= ProductCodeHPESKUMap.get(a.Array_Controller__c).Component_code__c ;
                    }
                    /*** code added for JIRA#ESS-48005 by Yesha Benegal 06/17/2020 CR#2893 ***/
                    
                    if(a.Array_Controller__c != a.Array_Controller_SKU__c && ProductCodeHPESKUMap.get(a.Array_Controller__c) != null ){
                        a.Array_Controller_SKU__c= ProductCodeHPESKUMap.get(a.Array_Controller__c).Component_code__c ;
                        
                    }/** end of change ***/
                    if(a.Product2Id == null){
                        if(ProductCodeHPESKUMap.get(a.Array_Controller_SKU__c).id!=null &&  ProductCodeHPESKUMap.containsKey(a.Array_Controller_SKU__c))
                            a.Product2Id= ProductCodeHPESKUMap.get(a.Array_Controller_SKU__c).id;
                    }
                    
                    if((a.Array_controller__c == '5030' || a.Array_Controller__c == '5050') && a.Controller_Refresh_Date__c == null && Trigger.Oldmap != null
                         && Trigger.oldMap.get(a.Id).Array_Controller__c != '5050'  && Trigger.oldMap.get(a.Id).Array_Controller__c != '5030'
                         && a.Cross_Family_Upgrade__c == True){
                        a.Controller_Refresh_Date__c = system.today();
                    }
                    //VX Component_SKU_HPE__c code change
                    // Story ESS-117149 - Added on 08/28/2024 by Yamini
                    if((a.asset_Type__c == 'Block Storage' || a.asset_Type__c == 'File Storage') && AstProductCode != null){
                        a.Component_SKU_HPE__c = ProductCodeHPESKUMap.get(AstProductCode).HPE_SKU__C ;
                        componentSKU = AstProductCode;
                    }
                    if(ProductCodeHPESKUMap.get(a.Array_Controller_SKU__c) != null){
                        String hpeSKU = ProductCodeHPESKUMap.get(a.Array_Controller_SKU__c)?.HPE_SKU__C;
                        String simplivitySKU = ProductCodeHPESKUMap.get(a.Array_Controller_SKU__c)?.Simplivity_SKU__c;
                        if (hpeSKU != null && a.Simplivity_Chk__c == false) {
                            a.Component_SKU_HPE__c = String.isNotBlank(a.Component_SKU_HPE__c)? a.Component_SKU_HPE__c + ',' + hpeSKU : hpeSKU;
                            componentSKU = String.isNotBlank(componentSKU)? componentSKU + ',' + a.Array_Controller_SKU__c : a.Array_Controller_SKU__c;
                        }
                        // Check for Simplivity SKU and Simplivity checked
                        else if (simplivitySKU != null && a.Simplivity_Chk__c == true) {
                            a.Component_SKU_HPE__c = String.isNotBlank(a.Component_SKU_HPE__c)? a.Component_SKU_HPE__c + ',' + simplivitySKU : simplivitySKU;
                            componentSKU = String.isNotBlank(componentSKU)? componentSKU + ',' + a.Array_Controller_SKU__c : a.Array_Controller_SKU__c;
                        }
                        else if(a.IS_Array_Controller__c == 'HF40H'){
                            a.array_Controller_SKU__c = 'HF40H';
                            componentSKU = 'HF40H';
                        }
                        else if(a.IS_Array_Controller__c == '5030H'){
                            a.array_Controller_SKU__c = '5030H';
                            componentSKU = 'S1Z75A';
                        }
                    }      
                    
                    
                    if(NextGenTriggerClass.errorText != null && NextGenTriggerClass.errorText.contains('Array Controller not found')){
                        a.Array_Controller__c = a.IS_Array_Controller__c;
                    }
                }
                //Start->SFDC-1124
                if(a.Cross_Family_Upgrade__c == True ){
                    a.HPE_Product_SKU__c = ProductCodeHPESKUMap.get(AstProductCode).HPE_SKU__C; system.debug(' *** line 1118 hpe Product sku ' + a.HPE_Product_SKU__c + ' *** ' + a.Cross_Family_Upgrade__c);
                }
                    //End->SFDC-1124
                //ESS-117099 -Start
                if(a.Parent_Asset_Controller_SKU__c!=null){
                     a.HPE_Product_SKU__c =  a.Component_SKU_HPE__c;
                }else{
                    a.HPE_Product_SKU__c = a.HPE_Product_SKU__c;
                }                
                  //ESS-117099 -End
                //added by venkat march 2018
                //Array Networking
                // Story -ESS-94250 - Added by Jana on - 01/23/2023
                if(a.Array_Networking__c!= null && a.asset_Type__c!='Legacy'){
                    boolean hasValue = false;
                    if(a.Array_Networking_SKU__c == null) 
                        a.Array_Networking_SKU__c = NextGenTriggerClass.calculateSKU (a.Array_Networking__c,false ,a.Array_Controller_SKU__c, a.Asset_Type__c,  AssetTypeProductMap,mAssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);
                    
                    if(ProductCodeHPESKUMap.get(a.Array_Networking_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Array_Networking_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Array_Networking_SKU__c).HPE_SKU__C ;
                            
                            componentSKU = componentSKU + ','+a.Array_Networking_SKU__c;
                        }
                        
                    }
                    if(NextGenTriggerClass.errorText != null && NextGenTriggerClass.errorText.contains('Array networking not found')){
                        a.Array_Networking__c = a.IS_Array_Networking__c;
                    }
                }
                if(a.Array_Networking_2__c!= null){
                    boolean hasValue = false;
                    if(a.Array_Networking_2_SKU__c == null) 
                        a.Array_Networking_2_SKU__c = NextGenTriggerClass.calculateSKU (a.Array_Networking_2__c,false ,a.Array_Controller_SKU__c, a.Asset_Type__c,  AssetTypeProductMap,mAssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);
                    
                    if(ProductCodeHPESKUMap.get(a.Array_Networking_2_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Array_Networking_2_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Array_Networking_2_SKU__c).HPE_SKU__C ;
                            
                            componentSKU = componentSKU + ','+a.Array_Networking_2_SKU__c;
                        }
                    }
                    if(NextGenTriggerClass.errorText != null && NextGenTriggerClass.errorText.contains('Array networking not found')){
                        a.Array_Networking_2__c = a.IS_Array_Networking_2__c;
                    }
                }
                if(a.Array_Networking_3__c!= null){
                    boolean hasValue = false;
                    if(a.Array_Networking_3_SKU__c == null) 
                        
                        a.Array_Networking_3_SKU__c = NextGenTriggerClass.calculateSKU (a.Array_Networking_3__c,false,a.Array_Controller_SKU__c, a.Asset_Type__c,  AssetTypeProductMap,mAssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);
                    if(ProductCodeHPESKUMap.get(a.Array_Networking_3_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Array_Networking_3_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Array_Networking_3_SKU__c).HPE_SKU__C ;
                            
                            componentSKU = componentSKU + ','+a.Array_Networking_3_SKU__c;
                        }
                        
                        
                    }
                    if(NextGenTriggerClass.errorText != null && NextGenTriggerClass.errorText.contains('Array networking not found')){
                        a.Array_Networking_3__c = a.IS_Array_Networking_3__c;
                    }
                }
                
                /** code changes for bluetail  - Yesha Benegal March-2021 **/
                if(a.Array_Networking_4__c!= null){
                    boolean hasValue = false;
                    if(a.Array_Networking_4_SKU__c == null) 
                        a.Array_Networking_4_SKU__c = NextGenTriggerClass.calculateSKU (a.Array_Networking_4__c,false,a.Array_Controller_SKU__c, a.Asset_Type__c,  AssetTypeProductMap,mAssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);
                    
                    if(ProductCodeHPESKUMap.get(a.Array_Networking_4_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Array_Networking_4_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Array_Networking_4_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+a.Array_Networking_4_SKU__c;
                        }
                    }
                }
                
                if(a.Array_Networking_5__c!= null){
                    boolean hasValue = false;
                    if(a.Array_Networking_5_SKU__c == null) 
                        a.Array_Networking_5_SKU__c =  NextGenTriggerClass.calculateSKU (a.Array_Networking_5__c,false,a.Array_Controller_SKU__c, a.Asset_Type__c,  AssetTypeProductMap,mAssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);
                    
                    if(ProductCodeHPESKUMap.get(a.Array_Networking_5_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Array_Networking_5_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Array_Networking_5_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+a.Array_Networking_5_SKU__c;
                        }
                    }
                }
                if(a.Array_Networking_6__c!= null){
                    boolean hasValue = false;
                    if(a.Array_Networking_6_SKU__c == null) 
                        a.Array_Networking_6_SKU__c = NextGenTriggerClass.calculateSKU (a.Array_Networking_6__c,false,a.Array_Controller_SKU__c, a.Asset_Type__c,  AssetTypeProductMap,mAssetTypeProductMap, infosightToProdMap, pronamecompmap, multipicklistAssetTypeMap);
                    if(ProductCodeHPESKUMap.get(a.Array_Networking_6_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Array_Networking_6_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Array_Networking_6_SKU__c).HPE_SKU__C ;
                            
                            componentSKU = componentSKU + ','+a.Array_Networking_6_SKU__c;
                        }
                    }
                }
                /** end of code changes for bluetail - Yesha Benegal March-2021 **/
                
                //Array capacity
                // Story -ESS-94250 - Added by Jana on - 01/23/2023
                if(a.Array_Capacity__c!= null && a.asset_Type__c!='Legacy') {
                    if(a.Array_Capacity_SKU__c==null){
                        if (AssetTypeProductMap.containsKey(a.Array_Capacity__c+'-'+a.Asset_Type__c) && a.Asset_Type__c == AssetTypeProductMap.get(a.Array_Capacity__c+'-'+a.Asset_Type__c).Asset_Type__c) { 
                            if(AssetTypeProductMap.containsKey(a.Array_Capacity__c+'-'+a.Asset_Type__c) && AssetTypeProductMap.get(a.Array_Capacity__c+'-'+a.Asset_Type__c).ProductCode!=null)
                                a.Array_Capacity_SKU__c = AssetTypeProductMap.get(a.Array_Capacity__c+'-'+a.Asset_Type__c).ProductCode; 
                                
                        }
                        
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Capacity__c))
                                a.Array_Capacity_SKU__c = infosightToProdMap.get(a.Array_Capacity__c);
                            else
                                a.Array_Capacity_SKU__c=pronamecompmap.get(a.Array_Capacity__c);
                        }
                    }
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Array_Capacity_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Array_Capacity_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Array_Capacity_SKU__c).HPE_SKU__C ;
                            
                            componentSKU = componentSKU + ','+a.Array_Capacity_SKU__c;
                        }
                        
                    }
                     
                    if(a.Array_Capacity__c == '22T' && a.Asset_Type__c == 'CS Hybrid Arrays'){
                        a.Component_SKU_HPE__c = a.Component_SKU_HPE__c + ',Q8B67A,Q8B67A';
                        componentSKU = componentSKU + ','+'HEAD-HDD-11TB,HEAD-HDD-11TB';
                        if(a.Array_Capacity_SKU__c == null){
                            a.Array_Capacity_SKU__c = 'HEAD-HDD-11TB';
                        }
                        
                        
                    }
                    if(a.Array_Capacity__c == '22T' && a.Asset_Type__c == 'HFA'){
                        a.Component_SKU_HPE__c = a.Component_SKU_HPE__c + ',Q8B67B,Q8B67B';
                        componentSKU = componentSKU + ','+ 'HEAD-HDD-11TBC,HEAD-HDD-11TBC';
                        if(a.Array_Capacity_SKU__c == null){
                            a.Array_Capacity_SKU__c = 'HEAD-HDD-11TBC';
                        }
                    } 
                    if(a.Asset_Type__c == 'A5000'){
                        if(a.Array_Capacity__c == '44T'){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c + ',S0U34A,S0U34A';
                            componentSKU = componentSKU + ','+ 'HEAD-HDD-22TB-G6,HEAD-HDD-22TB-G6';
                            a.Array_Capacity_SKU__c = 'HEAD-HDD-22TB-G6,HEAD-HDD-22TB-G6';
                        }
                    } 
                    
                    if(NextGenTriggerClass.errorText != null && NextGenTriggerClass.errorText.contains('Array capacity not found')){
                        a.Array_Capacity__c = a.IS_Array_Capacity__c;                        
                    }
                } 
                a.Total_SSD_Banks_Cache__c = 0;
                //added by venkat march 2018
                //Array cache
                // Story -ESS-94250 - Added by Jana on - 01/23/2023
                if(a.Array_Cache__c!= null && a.asset_Type__c!='Legacy'){ 
                    if(a.Asset_Type__c == 'AFA'  || a.Asset_Type__c == 'CS Hybrid Arrays' || a.Asset_Type__c == 'AFA2'||
                         a.Asset_Type__c == 'Expansion Shelf 3' || a.Asset_Type__c == 'AFS3' || a.Asset_Type__c == 'AFS4'  ||
                         a.Asset_Type__c == 'A5000' ){   
                        
                        a.Array_Cache_SKU__c = '';// we dont waht SKU for the above types
                        
                    }
                    else 
                        if(a.Dynamic_SKU__c != null && (a.Dynamic_SKU__c.startsWithIgnoreCase('HF20H-') || a.Dynamic_SKU__c.startsWithIgnoreCase('HF20C-') || a.Dynamic_SKU__c.startsWithIgnoreCase('HF40C-')))
                        {
                            a.Array_Cache_SKU__c = '';
                            
                        }
                    else{
                        
                        //string arraycachestr = a.Array_Cache__c+'-'+a.Asset_Type__c;
                        
                        if (AssetTypeProductMap.containsKey(a.Array_Cache__c+'-'+a.Asset_Type__c)) {
                            string arrayCTLR = AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).Asset_Type__c;
                            
                            if(arrayCTLR.contains(a.Asset_Type__c)){
                                boolean foundVal = false;                                                      
                                //str =  AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).Array_Controller__c;                         
                                if(AssetTypeProductMap.containsKey(a.Array_Cache__c+'-'+a.Asset_Type__c) && AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).ProductCode!=null){                                    
                                    Set<String>  arrayCTLRstr = new set<String>();
                                    
                                    if(AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).Array_Controller__c != null){
                                        arrayCTLRstr.addAll(AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).Array_Controller__c.split(';'));                   
                                        
                                        if(arrayCTLRstr.contains(a.Array_Controller__c)){//(a.Array_Controller__c == AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).Array_Controller__c)                                                
                                            if(a.asset_type__c != null && a.asset_Type__c == 'A6000'){
                                                if(a.SSD_Bank_A__c != null && a.SSD_Bank_B__c != null && a.SSD_Bank_A__c == a.SSD_Bank_B__c){
                                                    if(AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).Storage_Capacity_Raw__c == 24){
                                                        
                                                        a.Array_Cache_SKU__c = AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).ProductCode;
                                                        foundVal = true;
                                                    }
                                                }
                                                else{
                                                    a.Array_Cache_SKU__c = AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).ProductCode;
                                                    foundVal = true;
                                                }
                                            }
                                            else{
                                                
                                                a.Array_Cache_SKU__c = AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).ProductCode;   
                                                foundVal = true;
                                            }
                                        } 
                                    }  
                                } 
                                if(foundVal== false){
                                    
                                    if(mAssetTypeProductMap.containsKey(a.Array_Cache__c+'-'+a.Asset_Type__c)){
                                        
                                        List<Product2> plst = mAssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c);
                                        
                                        for(Product2 p :plst){ 
                                            if(p.ProductCode != null){
                                                Set<String>  arrayCTLRstr = new set<String>();
                                                if(p.Array_Controller__c != null){
                                                    arrayCTLRstr.addAll(p.Array_Controller__c.split(';')); 
                                                    
                                                    if(arrayCTLRstr.contains(a.Array_Controller__c)){//(a.Array_Controller__c == AssetTypeProductMap.get(a.Array_Cache__c+'-'+a.Asset_Type__c).Array_Controller__c)                                                
                                                        if(a.asset_type__c != null && a.asset_Type__c == 'A6000'){
                                                            if(a.SSD_Bank_A__c != null && a.SSD_Bank_B__c != null && a.SSD_Bank_A__c == a.SSD_Bank_B__c){
                                                                if(p.Storage_Capacity_Raw__c == 24){
                                                                    
                                                                    a.Array_Cache_SKU__c = p.ProductCode;
                                                                }
                                                            }
                                                            else{
                                                                a.Array_Cache_SKU__c = p.ProductCode;
                                                            }
                                                        }
                                                        else{
                                                            a.Array_Cache_SKU__c = p.ProductCode;
                                                        }
                                                    } 
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                        else{
                            if(infosightToProdMap.containsKey(a.Array_Cache__c)){
                                a.Array_Cache_SKU__c = infosightToProdMap.get(a.Array_Cache__c); 
                                
                            }                          
                            else{
                                if(a.Array_Cache_SKU__c == null)
                                    a.Array_Cache_SKU__c=pronamecompmap.get(a.Array_Cache__c);  
                            }
                        } 
                        //else
                        //a.Array_Cache_SKU__c=''; 
                        //VX code change       
                        
                        if(ProductCodeHPESKUMap.get(a.Array_Cache_SKU__c) != null){
                            if(ProductCodeHPESKUMap.get(a.Array_Cache_SKU__c).HPE_SKU__C != null && a.asset_Type__c != 'A6000'){
                                a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Array_Cache_SKU__c).HPE_SKU__C ; 
                                componentSKU = componentSKU + ','+ a.Array_Cache_SKU__c ;                                
                                
                            }
                            
                            if(ProductCodeHPESKUMap.get(a.Array_Cache_SKU__c).HPE_SKU__C != null && a.asset_Type__c == 'A6000'){
                                if(a.SSD_Bank_A__c == a.SSD_Bank_B__c && a.SSD_Bank_B__c != null){
                                    a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Array_Cache_SKU__c).HPE_SKU__C ; 
                                    componentSKU = componentSKU + ','+ a.Array_Cache_SKU__c ; 
                                    
                                }
                            }
                        }
                    } 
                    if(a.Asset_Type__c != null && a.Asset_Product_Family__c != null){
                        if(a.Asset_Type__c == 'AFS3' || a.Asset_Product_Family__c.contains('Expansion') || a.Asset_Type__c == 'AFS4' ){
                            a.Array_Cache__c = null;
                            a.Array_Cache_SKU__c = null;
                            
                        }
                    }
                    
                    if(NextGenTriggerClass.errorText != null && NextGenTriggerClass.errorText.contains('Array cache not found')){
                        a.array_Cache__c = a.IS_Array_Cache__c;
                    }
                } 
                
                if(a.IS_Array_Cache__c == '3840F' && a.asset_Type__c == 'A5000'){
                        a.Component_SKU_HPE__c += ',S0U36A,S0U36A';
                }
                
                if( a.Array_Cache_SKU__c != null && ProductCodeSSD_Map.get(a.Array_Cache_SKU__c) != null)
                    a.Total_SSD_Banks_Cache__c = ProductCodeSSD_Map.get(a.Array_Cache_SKU__c);
                
                
                If(a.Asset_Product_Family__c != 'Virtual Array' && a.ProductCode__c !=null){
                    If((a.ProductCode__c == 'AFS3' || a.ProductCode__c.contains('ES3') || a.ProductCode__c == '2140') && a.HPE_Opportunity_ID__c != null && a.ProductCode__c != null){
                        a.Array_Cache__c = '';           
                    }
                }
                
                if(a.Shelf_Pack_1__c!= null){
                    if(a.Shelf_Pack_1_SKU__c== null){
                        if(a.Asset_Type_Build__c != 'AFS4') {                      
                            a.Shelf_Pack_1_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_1__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                            
                        }
                        else{
                            string val = a.Shelf_Pack_1__c + 'F'; 
                            if(a.IS_SSD_Count__c == null && a.Shelf_Pack_2__c == null){
                                a.Shelf_Pack_1_SKU__c = NextGenTriggerClass.calculateBANKSKU(val, 24, a.expansion_shelf_base__c, a.Asset_Type_Build__c,a.Shelf_Quantity__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);    
                            } 
                            else if(a.IS_SSD_Count__c != null && a.IS_SSD_Packs__c != null){
                                
                                a.Shelf_Pack_1_SKU__c = NextGenTriggerClass.calculateBANKSKU(val, a.IS_SSD_Count__c, a.expansion_shelf_base__c, a.Asset_Type_Build__c,a.IS_SSD_Packs__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);    
                                
                            }                       
                        }
                    }
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_1_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_1_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_1_SKU__c).HPE_SKU__C ;
                            
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_1_SKU__c ;
                        }
                        
                    }
                    
                }
                
                //added by venkat march 2018
                //Shelf Pack 2
                if(a.Shelf_Pack_2__c!= null){
                    if(a.Shelf_Pack_2_SKU__c==null){
                        if(a.Asset_Type_Build__c != 'AFS4'){
                            a.Shelf_Pack_2_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_2__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                        }
                        else{
                            string val = a.Shelf_Pack_2__c + 'F';
                            if(a.IS_SSD_Count__c == null && a.Shelf_Pack_2__c == null){
                                
                                a.Shelf_Pack_2_SKU__c = NextGenTriggerClass.calculateBANKSKU(val, 12, a.expansion_shelf_base__c, a.Asset_Type_Build__c,a.SSD_Packs__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);    
                            } 
                            else if(a.IS_SSD_Count__c != null && a.IS_SSD_Packs__c != null){
                                
                                a.Shelf_Pack_2_SKU__c = NextGenTriggerClass.calculateBANKSKU(val, a.IS_SSD_Count__c, a.expansion_shelf_base__c, a.Asset_Type_Build__c,a.IS_SSD_Packs__c,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);    
                            } 
                        }
                    }
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_2_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_2_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_2_SKU__c).HPE_SKU__C ;
                            
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_2_SKU__c ;
                        }    
                        
                    }
                    
                }
                //Shelf Pack 3
                if(a.Shelf_Pack_3__c!= null){
                    if(a.Shelf_Pack_3_SKU__c==null)
                        a.Shelf_Pack_3_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_3__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_3_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_3_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_3_SKU__c).HPE_SKU__C ;
                            
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_3_SKU__c ;
                        }
                        
                    }
                    
                }
                //added by venkat march 2018
                //Shelf Pack 4
                if(a.Shelf_Pack_4__c!= null){
                    if(a.Shelf_Pack_4_SKU__c==null)
                        a.Shelf_Pack_4_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_4__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_4_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_4_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_4_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_4_SKU__c ;
                        }
                        
                    }
                    
                }
                
                //Shelf Pack 5
                if(a.Shelf_Pack_5__c!= null){
                    if(a.Shelf_Pack_5_SKU__c==null)
                        a.Shelf_Pack_5_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_5__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_5_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_5_SKU__c).HPE_SKU__C != null){
                            
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_5_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_5_SKU__c ;
                        }
                        
                    }
                    
                }
                
                //Shelf Pack 6
                
                if(a.Shelf_Pack_6__c!= null){
                    if(a.Shelf_Pack_6_SKU__c==null)
                        a.Shelf_Pack_6_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_6__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_6_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_6_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_6_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_6_SKU__c ;
                        }
                        
                    }
                    
                }
                
                //Shelf Pack 7
                if(a.Shelf_Pack_1B__c!= null){
                    if(a.Shelf_Pack_1B_SKU__c==null)
                        a.Shelf_Pack_1B_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_1B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_1B_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_1B_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_1B_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_1B_SKU__c ;
                        }
                        
                    }
                    
                }
                
                //Shelf Pack 8
                if(a.Shelf_Pack_2B__c!= null){
                    if(a.Shelf_Pack_2B_SKU__c==null)
                        a.Shelf_Pack_2B_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_2B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_2B_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_2B_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_2B_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_2B_SKU__c ;
                        }
                        
                    }
                    
                }
                
                //Shelf Pack 9
                if(a.Shelf_Pack_3B__c!= null){
                    if(a.Shelf_Pack_3B_SKU__c==null)
                        a.Shelf_Pack_3B_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_3B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_3B_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_3B_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_3B_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_3B_SKU__c ;
                        }
                        
                    }
                    
                }
                
                //Shelf Pack 10
                if(a.Shelf_Pack_4B__c!= null){
                    if(a.Shelf_Pack_4B_SKU__c==null)
                        a.Shelf_Pack_4B_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_4B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_4B_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_4B_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_4B_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_4B_SKU__c ;
                        }
                        
                    }
                    
                }
                
                //Shelf Pack 11
                if(a.Shelf_Pack_5B__c!= null){
                    if(a.Shelf_Pack_5B_SKU__c==null)
                        a.Shelf_Pack_5B_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_5B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_5B_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_5B_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_5B_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_5B_SKU__c ;
                        }
                        
                    }
                    
                }
                
                //Shelf Pack 12
                if(a.Shelf_Pack_6B__c!= null){
                    if(a.Shelf_Pack_6B_SKU__c==null)
                        a.Shelf_Pack_6B_SKU__c = NextGenTriggerClass.calculateShelfSKU (a.Shelf_Pack_6B__c, a.Asset_Type_Build__c, AssetTypeProductMap, infosightToProdMap, pronamecompmap, null);
                    
                    //VX code change
                    if(ProductCodeHPESKUMap.get(a.Shelf_Pack_6B_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.Shelf_Pack_6B_SKU__c).HPE_SKU__C != null){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.Shelf_Pack_6B_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.Shelf_Pack_6B_SKU__c ;
                        }
                        
                    }
                    
                }
                //added by venkat asset type changes-april 18 2018 : added by venkat march 2018 :added by venkat for AFA chnages
                //SSD bank A
                
                Set<String>  arrayCTLR = new set<String>();   
                decimal ssdCount;
                decimal ssdpacks;
                if(a.IS_SSD_Count__c == null || a.IS_SSD_Count__c == 0){
                    if(a.SSD_Count__c != null){
                        ssdCount = a.SSD_Count__c; 
                    }
                    else if(a.SSD_Bank_A__c != null && a.SSD_Bank_B__c == null){
                        ssdCount = 12;
                    } 
                    else if(a.SSD_Bank_A__c != null && a.SSD_Bank_B__c != null){
                        ssdCount = 24; 
                    }
                }else{
                    ssdCount = a.IS_SSD_Count__c;
                }
                if(a.SSD_Packs__c == null || a.SSD_Packs__c == 0){
                    
                    ssdpacks = 1;
                }
                else{
                    if(a.IS_SSD_Packs__c != null){
                        ssdpacks = a.IS_SSD_Packs__c;
                    }
                    else
                        ssdpacks = a.SSD_Packs__c;
                } 
                // Story -ESS-94250 - Added by Jana on - 01/23/2023
                if(a.SSD_Bank_A__c!= null && a.HFCacheOnly__c == False && a.Asset_Type_Build__c != 'A6000' && a.asset_Type__c!='Legacy' ){  
                    a.SSD_Bank_A_SKU__c = NextGenTriggerClass.calculateSKU ( a.SSD_Bank_A__c,a.HFCacheOnly__c ,a.Array_Controller_SKU__c, a.Asset_Type_Build__c , AssetTypeProductMap, mAssetTypeProductMap,infosightToProdMap,  pronamecompmap, multipicklistAssetTypeMap);
                    
                    
                    
                    //VX code change - ComponentSKU
                    if(ProductCodeHPESKUMap.get(a.SSD_Bank_A_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.SSD_Bank_A_SKU__c).HPE_SKU__C != null && a.asset_type_build__c != 'SFA'){
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.SSD_Bank_A_SKU__c).HPE_SKU__C ;                                
                            componentSKU = componentSKU + ','+ a.SSD_Bank_A_SKU__c ;
                        }
                        
                    }
                    
                }
                // Story -ESS-94250 - Added by Jana on - 01/23/2023
                else if(a.SSD_Bank_A__c!= null  && a.Asset_Type_Build__c == 'A6000' && a.asset_Type__c!='Legacy'){ 
                    
                    if((a.SSD_Bank_B__c == null || a.SSD_Bank_A__c != a.SSD_Bank_B__c) && (a.IS_SSD_Count__c != null)){
                        a.SSD_Bank_A_SKU__c = NextGenTriggerClass.calculateBANKSKU(a.SSD_Bank_A__c,ssdCount,a.Array_Controller__c, a.Asset_Type_Build__c,ssdpacks,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);
                        
                    }
                    
                    else{
                        //a.SSD_Bank_A_SKU__c = NextGenTriggerClass.calculateBankSKU2(a.SSD_Bank_A__c, a.Asset_Type_Build__c,a.Array_Controller__c, multipicklistAssetTypeMap);                     
                        a.SSD_Bank_A_SKU__c = NextGenTriggerClass.calculateBANKSKU(a.SSD_Bank_A__c,ssdCount,a.Array_Controller__c, a.Asset_Type_Build__c,ssdpacks,  multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);
                        
                    }
                    
                    //VX code change - ComponentSKU
                    if(ProductCodeHPESKUMap.get(a.SSD_Bank_A_SKU__c) != null){ 
                        if(ProductCodeHPESKUMap.get(a.SSD_Bank_A_SKU__c).HPE_SKU__C != null && a.Asset_Type_Build__c == 'A6000'){
                            if((a.SSD_Bank_A__c != a.SSD_Bank_B__c && a.SSD_Bank_B__c != null ) || (cacheString.get(a.SSD_Bank_A__c) == a.Array_Cache__c && a.ssd_Bank_B__c == null)){
                                a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.SSD_Bank_A_SKU__c).HPE_SKU__C ;                                
                                componentSKU = componentSKU + ','+ a.SSD_Bank_A_SKU__c ;
                                
                            }
                            else if(a.SSD_Bank_A__c != null && a.Array_Cache__c == null){
                                a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.SSD_Bank_A_SKU__c).HPE_SKU__C ;                                
                                componentSKU = componentSKU + ','+ a.SSD_Bank_A_SKU__c ;
                                
                            }
                        }
                        
                    }
                    
                }
                
                else{
                    a.SSD_Bank_A_SKU__c = '';
                    
                }        
                
                if(a.SSD_Bank_A_SKU__c != null && ProductCodeSSD_Map.get(a.SSD_Bank_A_SKU__c) != null){
                    
                    if(ProductCodeSSD_Map.get(a.SSD_Bank_A_SKU__c)>0)
                        a.Total_SSD_Banks_Cache__c = ProductCodeSSD_Map.get(a.SSD_Bank_A_SKU__c);
                }
                
                
                //SSD bank B
                // Story -ESS-94250 - Added by Jana on - 01/23/2023
                if(a.SSD_Bank_B__c!= null && a.HFCacheOnly__c == False  && a.Asset_Type_Build__c != 'A6000' && a.asset_Type__c!='Legacy' ){ // && !HFCache
                    a.SSD_Bank_B_SKU__c = NextGenTriggerClass.calculateSKU ( a.SSD_Bank_B__c,a.HFCacheOnly__c ,a.Array_Controller_SKU__c, a.Asset_Type__c , AssetTypeProductMap, mAssetTypeProductMap,infosightToProdMap,  pronamecompmap, multipicklistAssetTypeMap); //added by Yesha Benegal Oct 20 2021
                    
                    //added by venkat march 2018
                    //VX code change
                    
                    if(ProductCodeHPESKUMap.get(a.SSD_Bank_B_SKU__c) != null){ 
                        if(ProductCodeHPESKUMap.get(a.SSD_Bank_B_SKU__c).HPE_SKU__C != null ){ 
                            a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.SSD_Bank_B_SKU__c).HPE_SKU__C ;
                            componentSKU = componentSKU + ','+ a.SSD_Bank_B_SKU__c ;
                        }
                    }
                    
                }
                // Story -ESS-94250 - Added by Jana on - 01/23/2023
                else if(a.SSD_Bank_B__c!= null  && a.Asset_Type_Build__c == 'A6000' && a.asset_Type__c!='Legacy'){ // added by Yesha Benegal Oct-20-2021
                    
                    if(a.SSD_Bank_A__c != a.SSD_Bank_B__c && a.IS_SSD_Count__c != null){
                        
                        a.SSD_Bank_B_SKU__c = NextGenTriggerClass.calculateBANKSKU(a.SSD_Bank_B__c,ssdCount ,a.Array_Controller__c, a.Asset_Type__c,ssdpacks, multipicklistAssetTypeMap , AssetTypeProductMap,  infosightToProdMap,  pronamecompmap,  mAssetTypeProductMap);
                        
                    }
                    else{
                        a.SSD_Bank_B_SKU__c = NextGenTriggerClass.calculateBankSKU2(a.SSD_Bank_B__c, a.Asset_Type__c,a.Array_Controller__c, multipicklistAssetTypeMap);                     
                        
                    }
                    //VX code change - ComponentSKU
                    if(ProductCodeHPESKUMap.get(a.SSD_Bank_B_SKU__c) != null){
                        if(ProductCodeHPESKUMap.get(a.SSD_Bank_B_SKU__c).HPE_SKU__C != null){
                            if(a.SSD_Bank_A__c != a.SSD_Bank_B__c && a.SSD_Bank_B__c != null ) {
                                a.Component_SKU_HPE__c = a.Component_SKU_HPE__c +','+ ProductCodeHPESKUMap.get(a.SSD_Bank_B_SKU__c).HPE_SKU__C ;                                
                                componentSKU = componentSKU + ','+ a.SSD_Bank_B_SKU__c ;
                                
                            }
                        }
                        
                    }
                    
                }
                
                else{
                    a.SSD_Bank_B_SKU__c = '';
                }
                
                if(a.SSD_Bank_B_SKU__c != null && a.SSD_Bank_B_SKU__c != '' ){
                    
                    if(ProductCodeSSD_Map.get(a.SSD_Bank_B_SKU__c) != null)
                        a.Total_SSD_Banks_Cache__c = a.Total_SSD_Banks_Cache__c + ProductCodeSSD_Map.get(a.SSD_Bank_B_SKU__c);
                    
                }
                if(a.Asset_Type__c == 'A6000'){    
                    string bankA = cacheString.get(a.SSD_Bank_A__c);
                    
                    if((a.SSD_Bank_A__c != a.SSD_Bank_B__c && a.SSD_Bank_B__c != null) || (bankA == a.Array_cache__c && a.SSD_Bank_B__c == null) ){
                        
                        if(a.array_cache_sku__c != null && a.Component_SKU_Nimble_V2__c != null){
                            a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c.remove(','+ a.array_cache_sku__c ); 
                            if(a.SSD_Bank_A_SKU__c != null && !a.Component_SKU_Nimble_V2__c.contains(a.SSD_Bank_A_SKU__c)){
                                a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c + a.SSD_Bank_A_SKU__c;
                            }
                            if(a.SSD_Bank_B_SKU__c != null && !a.Component_SKU_Nimble_V2__c.contains(a.SSD_Bank_B_SKU__c)){
                                a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c + a.SSD_Bank_B_SKU__c;
                            }
                        }
                        a.array_cache_sku__c = ''; 
                        
                    }
                    
                    else if(a.SSD_Bank_A__c == a.SSD_Bank_B__c && a.SSD_Bank_B__c != null && a.Asset_Type__c == 'A6000' ){
                        if(a.SSD_Bank_A_SKU__c != null && a.Component_SKU_Nimble_V2__c != null)   
                            a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c.remove(','+ a.SSD_Bank_A_SKU__c);
                        if (a.SSD_Bank_B_SKU__c != null && a.Component_SKU_Nimble_V2__c != null)
                            a.Component_SKU_Nimble_V2__c = a.Component_SKU_Nimble_V2__c.remove(',' +a.SSD_Bank_B_SKU__c );
                        if(a.array_cache_sku__c != null && a.Component_SKU_Nimble_V2__c != null){
                            if(!a.Component_SKU_Nimble_V2__c.contains(a.array_cache_sku__c) ){
                                a.Component_SKU_Nimble_V2__c += ',' + a.array_cache_sku__c;
                            }
                        }                   
                        a.SSD_Bank_A_SKU__c = '';
                        a.SSD_Bank_B_SKU__c = '';
                        
                        
                    }
                    else if(a.Array_cache__c == null && a.SSD_Bank_A__c != null){
                        a.Component_SKU_Nimble_V2__c += ','+ a.SSD_Bank_A_SKU__c;
                        system.debug(' **** line 1800 ' + a.Component_SKU_Nimble_V2__c);
                    }
                    
                }
                
                if(a.SSD_Bank_A__c!= null  )
                    countOfSSDPacks=countOfSSDPacks+1;//added by venkat-7/3/2018
                if(a.SSD_Bank_B__c!= null  )
                    countOfSSDPacks=countOfSSDPacks+1;//added by venkat-7/3/2018
                a.SSD_Packs__c=countOfSSDPacks;// added by venkat-7/3/2018
                countOfSSDPacks=0;//added by Srujan 04/08/2019
                if(a.Component_SKU_HPE__c != null){
                    a.Component_SKU_HPE__c =a.Component_SKU_HPE__c.removeStartIgnoreCase(',');
                    a.Component_SKU_HPE__c =a.Component_SKU_HPE__c.removeEndIgnoreCase(',');
                    a.Component_SKU_HPE__c =a.Component_SKU_HPE__c.removeEndIgnoreCase(',null');
                }
                if(a.Array_Controller__c =='AF7000' || a.Array_Controller__c =='AF9000' ){
                    a.Component_SKU_HPE__c= a.Component_SKU_HPE__c.replaceAll('Q8B73A','Q8G43A');
                }
                if(a.Array_Controller__c =='AF1000' || a.Array_Controller__c =='AF3000' || a.Array_Controller__c =='AF5000'){
                    a.Component_SKU_HPE__c= a.Component_SKU_HPE__c.replaceAll('Q8B71A','Q8B72A');
                }
                if(a.Array_Controller__c =='AF3000' || a.Array_Controller__c =='AF5000'){
                    a.Component_SKU_HPE__c= a.Component_SKU_HPE__c.replaceAll('Q8B74A','Q8G44A');
                }
                if(a.Array_Controller__c =='AF5000' || a.Array_Controller__c =='AF7000' || a.Array_Controller__c =='AF9000'){
                    a.Component_SKU_HPE__c= a.Component_SKU_HPE__c.replaceAll('Q8B58A','Q8G61A');
                }
                if(a.Array_Controller__c =='AF5000' || a.Array_Controller__c =='AF7000' || a.Array_Controller__c =='AF9000'){
                    a.Component_SKU_HPE__c= a.Component_SKU_HPE__c.replaceAll('Q8G62A','Q8G62A');
                }
                if(ParentControllerMap.get(a.Parent_Asset__c) != null){
                    if(ParentControllerMap.get(a.Parent_Asset__c) =='CS5000' || ParentControllerMap.get(a.Parent_Asset__c) =='CS7000' ){
                        a.Component_SKU_HPE__c= a.Component_SKU_HPE__c.replaceAll('Q8B51A','Q8G47A');
                    }
                    if(ParentControllerMap.get(a.Parent_Asset__c) =='CS5000' || ParentControllerMap.get(a.Parent_Asset__c) =='CS7000' ){
                        a.Component_SKU_HPE__c= a.Component_SKU_HPE__c.replaceAll('Q8B52A','Q8G48A');
                    }
                }
                if((a.contains_HPESKU__c == true  || a.HPE_Opportunity_ID__c != null )&& componentSKU != null){
                    a.Component_SKU_Nimble_V2__c = componentSKU;
                    system.debug( '*** line 1811 component sku nimble v2 is ' + a.Component_SKU_Nimble_V2__c);
                }
                if( a.Asset_type__c == 'AFA2' && a.Timeless_Storage__c == True){
                    if(a.SSD_Bank_A__c != null && a.Controller_Refresh_Shelf_Count__c == null && decString.get(a.SSD_Bank_A__c) != null){
                        a.Controller_Refresh_Shelf_Count__c = Decimal.valueOF(decString.get(a.SSD_Bank_A__c));
                        if(a.SSD_Bank_B__c != null && decString.get(a.SSD_Bank_B__c) != null){
                            a.Controller_Refresh_Shelf_Count__c = a.Controller_Refresh_Shelf_Count__c + Decimal.valueOf(decString.get(a.SSD_Bank_B__c));
                        }
                    }
                    else if(a.SSD_Bank_A__c == null && a.SSD_Bank_B__c != null && decString.get(a.SSD_Bank_B__c) != null){
                        a.Controller_Refresh_Shelf_Count__c =  Decimal.valueOf(decString.get(a.SSD_Bank_B__c));
                    }
                    
                }
                
            }
            
        }
        
        /****** DataCenter Care flag update ********/
        /****************added to roll up total ext shelves and total flash drives******************/
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate) && AssetIds.size()>0)
        {
            AggregateResult[] groupedResults=[Select count(id) noOfRec,Parent_Asset__c Passest from Asset where Parent_Asset__c in :AssetIds Group by Parent_Asset__c];
            
            for(AggregateResult agg:groupedResults)
            {
                assetCountMapes1.put(String.valueof(agg.get('Passest')),Integer.valueOf(agg.get('noOfRec')));
            }
            
            list<Asset> assetToUpdate = new list<Asset>();
            
            for(Asset a:[select Total_Shelvess__c,Total_External_Shelves__c,Total_Flash_Drives__c from Asset where id in :AssetIds])
            {
                if(assetCountMapes1.containskey(a.id))
                {
                    a.Total_Shelvess__c=assetCountMapes1.get(a.id);
                }
                
                assetToUpdate.add(a);
            }
            Utility.runDupRecTrigger=false;
            
            if(assetToUpdate.size()>0)
                update assetToUpdate;
        }
        if(trigger.isafter && trigger.isDelete)
        {
            AssetIds.clear();
            assetCountMapes1.clear();
            assetCountMapafs.clear();
            for(Asset a:trigger.old)
            {
                if(a.Parent_Asset__c!=null)
                    AssetIds.add(a.Parent_Asset__c);
            }
            AggregateResult[] groupedResults=[Select count(id) noOfRec,Parent_Asset__c Passest from Asset where Parent_Asset__c in :AssetIds Group by Parent_Asset__c];
            
            for(AggregateResult agg:groupedResults)
            {
                assetCountMapes1.put(String.valueof(agg.get('Passest')),Integer.valueOf(agg.get('noOfRec')));
            }
            
            list<Asset> assetToUpdate = new list<Asset>();
            for(Asset a:[select Total_Shelvess__c,Total_External_Shelves__c,Total_Flash_Drives__c from Asset where id in :AssetIds])
            {
                //a.Total_Shelvess__c=0;
                if(assetCountMapes1.containskey(a.id))
                {
                    a.Total_Shelvess__c=assetCountMapes1.get(a.id);
                    assetToUpdate.add(a);
                }               
                
                
            }
            for(Asset a:[select Total_Shelvess__c from asset where id in :AssetIds and id not in:assetCountMapes1.keyset()])
            {
                a.Total_Shelvess__c=0;
                assetToUpdate.add(a);
            }
            Utility.runDupRecTrigger=false;
            
            if(assetToUpdate.size()>0)
                update assetToUpdate;
        }
        /****************added to roll up total ext shelves and total flash drives - end******************/
        //added by venkat-1 june 2018-start
        if(Trigger.isBefore){
            
            Map<id,Integer> toProcessForOfferCodeSku=new Map<id,Integer>();
            list<string> slaList=new list<string>();
            list<string> slaTSCList=new list<string>();
            list<asset> assetToProcess=new list<asset>();
            list<asset> assetToUpdate=new list<asset>();
            Map<String,list<Nimble_Offer_Code__c>> nimblecodesDescrMap=new Map<String,list<Nimble_Offer_Code__c>> ();
            Map<String,list<Nimble_Offer_Code__c>> tscnimblecodesDescrMap=new Map<String,list<Nimble_Offer_Code__c>> ();
            list<Nimble_Offer_Code__c> nimbleoffercodesList=new list<Nimble_Offer_Code__c>();/* Added jana  ESS-98920 */
            list<Nimble_Offer_Code__c> nimbleoffercodesObjList=new list<Nimble_Offer_Code__c>();
            list<Nimble_Offer_Code__c> nimbleoffercodesObjTSCList=new list<Nimble_Offer_Code__c>();
            set<String> strH3C = new set<String>();
            Map<ID,String> mStr = new Map<Id,String>();
            for(Asset assetObj:Trigger.new){
                if(!assetObj.ES_API_Call_Completed__c )
                    if(String.isBlank(assetObj.HPE_Support_SKU__c) && assetObj.SLA__c!=null){
                        //if(assetObj.SLA__c!=null)
                        Integer noOfYearsdiff =0;
                        if(assetObj.Support_Start_Date_Asset__c!=null && assetObj.Support_End_Date__c!=null){
                            noOfYearsdiff = (assetObj.Support_Start_Date_Asset__c.daysBetween(assetObj.Support_End_Date__c));
                            integer noOfYearsdiff1;         system.debug('yrs'+noOfYearsdiff);
                            noOfYearsdiff1=noOfYearsdiff/365;
                            decimal monthsbetween=(Math.Mod(noOfYearsdiff ,365));
                            
                            if(monthsbetween == 0){
                                noOfYearsdiff = noOfYearsdiff1;
                            }
                            if(monthsbetween>0)
                                noOfYearsdiff=noOfYearsdiff1+1;
                            if(noOfYearsdiff==2){noOfYearsdiff=3;}
                            if(noOfYearsdiff>5){noOfYearsdiff=5;}
                            assetObj.No_of_Support_years__c=string.valueof(noOfYearsdiff)+'Y';
                            
                        }
                        toProcessForOfferCodeSku.put(assetObj.id,noOfYearsdiff);
                        assetToProcess.add(assetObj);
                        if(!assetObj.SLA__c.contains('TSC'))
                            slaList.add(assetObj.SLA__c);
                        if(assetObj.SLA__c.contains('TSC')){slaTSCList.add(assetObj.SLA__c);}
                        string chkStr =  null;
                        chkStr = assetObj.SLA__c;
                        if(chkStr.contains('H3C') && !strH3C.contains(assetObj.SLA__c.removeStart('H3C: '))){
                            strH3C.add(assetObj.SLA__c.removeStart('H3C: '));
                            mStr.put(assetObj.Id,assetObj.SLA__c.removeStart('H3C: '));
                        }
                    }
            }

           /*  Commented on Jan 12 2024 
            /* Added jana   ESS-98920  Start */
             if((slaList!=null && slaList.size()>0) || (slaTSCList!=null && slaTSCList.size()>0) || (strH3C!=null && strH3C.size()>0) )
             nimbleoffercodesList=[select id,Nimble_Support_Offers__c, Nimble_NDR__c, CDMR__c,TSC_Nimble_Support_Offers__c, HPE_Support_Package_SKU_Description__c,HPE_Support_Package_SKU__c,Controller_Refresh_Level__c,Nimble_Timeless_Storage__c,Equivalent_Standard_Support_SKU__c from Nimble_Offer_Code__c where (Nimble_Support_Offers__c in:slaList OR TSC_Nimble_Support_Offers__c in:slaTSCList OR Nimble_Support_Offers__c in: strH3C) ];


            if(nimbleoffercodesList!=null && nimbleoffercodesList.size()>0){
                for(Nimble_Offer_Code__c noc:nimbleoffercodesList){
                    if (strH3C.contains(noc.Nimble_Support_Offers__c) || slaList.contains(noc.Nimble_Support_Offers__c)){
                        nimbleoffercodesObjList.add(noc);
                    }
                    if (slaTSCList.contains(noc.TSC_Nimble_Support_Offers__c)){
                        nimbleoffercodesObjTSCList.add(noc);
                     }
                 }
            }
             /* Added jana   ESS-98920  End */
            
            if(nimbleoffercodesObjList!=null && nimbleoffercodesObjList.size()>0){
                for(Nimble_Offer_Code__c nimbleofferobj:nimbleoffercodesObjList){
                    
                    if(nimblecodesDescrMap.containsKey(nimbleofferobj.Nimble_Support_Offers__c)) {
                        List<Nimble_Offer_Code__c> nimbleofferdescList = nimblecodesDescrMap.get(nimbleofferobj.Nimble_Support_Offers__c);
                        nimbleofferdescList.add(nimbleofferobj);
                        nimblecodesDescrMap.put(nimbleofferobj.Nimble_Support_Offers__c, nimbleofferdescList);
                    } else {
                        nimblecodesDescrMap.put(nimbleofferobj.Nimble_Support_Offers__c,new List<Nimble_Offer_Code__c> { nimbleofferobj });
                    }
                }
                if(assetToProcess!=null && assetToProcess.size()>0){
                    for(Asset assetObj:assetToProcess){
                        
                        if(nimblecodesDescrMap!=null && nimblecodesDescrMap.size()>0 && nimblecodesDescrMap.containsKey(assetObj.SLA__c) && nimblecodesDescrMap.get(assetObj.SLA__c)!=null){
                            
                            list<Nimble_Offer_Code__c> nimbleofferList= nimblecodesDescrMap.get(assetObj.SLA__c);
                            for(Nimble_Offer_Code__c nimbleofferstring:nimbleofferList){
                                
                                if(toProcessForOfferCodeSku!=null && toProcessForOfferCodeSku.size()>0 && toProcessForOfferCodeSku.get(assetObj.id)!=null 
                                   && nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase(toProcessForOfferCodeSku.get(assetObj.id)+'Y')){
                                       
                                       If(assetObj.No_of_Support_years__c != '3Y' || (assetObj.No_of_Support_years__c == '3Y' && (nimbleofferstring.HPE_Support_Package_SKU__c.startswith('HU2')
                                          && assetObj.timeless_storage__c) ||  nimbleofferstring.HPE_Support_Package_SKU__c.startswith('HU4') || !assetObj.timeless_storage__c )){ 
                                                                                                                                      
                                          If((assetObj.Asset_Product_Family__c  == 'Alletra 6000' && nimbleofferstring.HPE_Support_Package_SKU__c.startswith('HU4')) || (!nimbleofferstring.HPE_Support_Package_SKU__c.startswith('HU4')
                                            && assetObj.Asset_Product_Family__c  != 'Alletra 6000' && assetObj.timeless_storage__c == nimbleofferstring.Nimble_Timeless_Storage__c && ((nimbleofferstring.Nimble_Timeless_Storage__c 
                                            && nimbleofferstring.Controller_Refresh_Level__c == 'L2')||!nimbleofferstring.Nimble_Timeless_Storage__c))) { 
                                                
                                                If(assetObj.assetNrdEndDate__c != null && assetObj.assetNrdStartDate__c != null && nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase('DMR')&& !nimbleofferstring.CDMR__c){
                                                    
                                                    assetObj.HPE_Support_SKU__c = nimbleofferstring.HPE_Support_Package_SKU__c;
                                                    break;                                                     
                                                    
                                                }else If(assetObj.CDMR_Start_Date__c != null && assetObj.CDMR_End_Date__c != null && nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase('CDMR') && nimbleofferstring.CDMR__c){
                                                    
                                                    assetObj.HPE_Support_SKU__c = nimbleofferstring.HPE_Support_Package_SKU__c;
                                                    break;                                                     
                                                    
                                                }else If(!nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase('DMR') && !nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase('CDMR') ){
                                                    
                                                    assetObj.HPE_Support_SKU__c=nimbleofferstring.HPE_Support_Package_SKU__c;
                                                    
                                                } 
                                                
                                                                                                                                                                                       } 
                                          }  
                                   }                    
                            }
                        }
                        else if(assetObj.SLA__c.contains('H3C')){
                            if(nimblecodesDescrMap!=null && nimblecodesDescrMap.size()>0 && nimblecodesDescrMap.containsKey(assetObj.SLA__c.removeStart('H3C: ')) 
                               && nimblecodesDescrMap.get(assetObj.SLA__c.removeStart('H3C: '))!=null  ){
                                   
                                   list<Nimble_Offer_Code__c> nimbleofferList= nimblecodesDescrMap.get(assetObj.SLA__c.removeStart('H3C: '));
                                   for(Nimble_Offer_Code__c nimbleofferstring:nimbleofferList){
                                       if(toProcessForOfferCodeSku!=null && toProcessForOfferCodeSku.size()>0 && toProcessForOfferCodeSku.get(assetObj.id)!=null 
                                          &&nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase(toProcessForOfferCodeSku.get(assetObj.id)+'Y') && assetObj.Timeless_Storage__c == nimbleofferstring.Nimble_Timeless_Storage__c){
                                              assetObj.HPE_Support_SKU__c=nimbleofferstring.HPE_Support_Package_SKU__c;
                                              break;
                                          }
                                   }
                               }
                        }
                    }
                    
                } 
            }
            //start again
            if(nimbleoffercodesObjTSCList!=null && nimbleoffercodesObjTSCList.size()>0){
                for(Nimble_Offer_Code__c nimbleofferobj:nimbleoffercodesObjTSCList){
                    
                    if(tscnimblecodesDescrMap.containsKey(nimbleofferobj.TSC_Nimble_Support_Offers__c)) {
                        List<Nimble_Offer_Code__c> nimbleofferdescList = tscnimblecodesDescrMap.get(nimbleofferobj.TSC_Nimble_Support_Offers__c);
                        nimbleofferdescList.add(nimbleofferobj);
                        tscnimblecodesDescrMap.put(nimbleofferobj.TSC_Nimble_Support_Offers__c, nimbleofferdescList);
                    } else {
                        tscnimblecodesDescrMap.put(nimbleofferobj.TSC_Nimble_Support_Offers__c,new List<Nimble_Offer_Code__c> { nimbleofferobj });
                    }
                }
                if(assetToProcess!=null && assetToProcess.size()>0){
                    for(Asset assetObj:assetToProcess){
                        if(tscnimblecodesDescrMap!=null && tscnimblecodesDescrMap.size()>0 && tscnimblecodesDescrMap.containsKey(assetObj.SLA__c) && tscnimblecodesDescrMap.get(assetObj.SLA__c)!=null){
                            list<Nimble_Offer_Code__c> nimbleofferList= tscnimblecodesDescrMap.get(assetObj.SLA__c);
                            for(Nimble_Offer_Code__c nimbleofferstring:nimbleofferList){
                                
                                if(toProcessForOfferCodeSku!=null && toProcessForOfferCodeSku.size()>0 && toProcessForOfferCodeSku.get(assetObj.id)!=null 
                                   && nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase(toProcessForOfferCodeSku.get(assetObj.id)+'Y')){
                                       
                                       If(assetObj.No_of_Support_years__c != '3Y' || (assetObj.No_of_Support_years__c == '3Y' && (nimbleofferstring.HPE_Support_Package_SKU__c.startswith('HU2') 
                                                                                                                                  && assetObj.timeless_storage__c) ||  nimbleofferstring.HPE_Support_Package_SKU__c.startswith('HU4') || !assetObj.timeless_storage__c )){ 
                                                                                                                                      
                                                                                                                                      If((assetObj.Asset_Product_Family__c  == 'Alletra 6000' && nimbleofferstring.HPE_Support_Package_SKU__c.startswith('HU4')) || 
                                                                                                                                         (!nimbleofferstring.HPE_Support_Package_SKU__c.startswith('HU4') && assetObj.Asset_Product_Family__c  != 'Alletra 6000' 
                                                                                                                                          && assetObj.timeless_storage__c == nimbleofferstring.Nimble_Timeless_Storage__c && ((nimbleofferstring.Nimble_Timeless_Storage__c && nimbleofferstring.Controller_Refresh_Level__c == 'L2') 
                                                                                                                                                                                                                              ||!nimbleofferstring.Nimble_Timeless_Storage__c))) { 
                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                  If(assetObj.assetNrdEndDate__c != null && assetObj.assetNrdStartDate__c != null && nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase('DMR')&& !nimbleofferstring.CDMR__c){
                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                      assetObj.HPE_Support_SKU__c = nimbleofferstring.HPE_Support_Package_SKU__c;
                                                                                                                                                                                                                                      break;                                                     
                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                  }else If(assetObj.CDMR_Start_Date__c != null && assetObj.CDMR_End_Date__c != null && nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase('CDMR') && nimbleofferstring.CDMR__c){
                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                      assetObj.HPE_Support_SKU__c = nimbleofferstring.HPE_Support_Package_SKU__c;
                                                                                                                                                                                                                                      break;                                                     
                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                  }else If(!nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase('DMR') && !nimbleofferstring.HPE_Support_Package_SKU_Description__c.containsIgnoreCase('CDMR') ){
                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                      assetObj.HPE_Support_SKU__c=nimbleofferstring.HPE_Support_Package_SKU__c;
                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                  } 
                                                                                                                                                                                                                                  
                                                                                                                                                                                                                              } 
                                                                                                                                  }  
                                   }                    
                            }
                        }
                    }
                    
                    
                }
                
            }
            
            // Added by Srujan on 03/21/2022 JIRA# ESS-77823--Start
            Map<String, String> expansionShelfMap = new Map<String, String>();
            // Added by Jana on 03/15/2023 JIRA# ESS-97043-
            Map<String, boolean> cdmrCheckMap = new Map<String, boolean>();
            for(Nimble_Offer_Code__c nimbleOffer : [Select HPE_Support_Package_SKU__c,CDMR__c, Equivalent_Standard_Support_SKU__c from  Nimble_Offer_Code__c]){             
                expansionShelfMap.put(nimbleOffer.HPE_Support_Package_SKU__c, nimbleOffer.Equivalent_Standard_Support_SKU__c);
               
                if(nimbleOffer.CDMR__c == true){
                    cdmrCheckMap.put(nimbleOffer.HPE_Support_Package_SKU__c,nimbleOffer.CDMR__c);   
                }
            }
            
            for(Asset assetObj : Trigger.New){
                //Support Profile added Jira - SFDC-754
                assetObj.HPE_Support_SKU__c = (((assetObj.Support_Profile__c!=null && assetObj.Support_Profile__c.contains('Alletra MP'))
                                                ||assetObj.Asset_Product_Family__c  == 'Expansion Shelves' || assetObj.Asset_Product_Family__c  == 'All Flash Shelf'
                                                || !assetObj.Timeless_Storage__c || assetObj.Timeless_fulfillment__c) &&
                                               expansionShelfMap.containsKey(assetObj.HPE_Support_SKU__c)) ? expansionShelfMap.get(assetObj.HPE_Support_SKU__c) :
                                               assetObj.HPE_Support_SKU__c;
                If( cdmrCheckMap.get(assetObj.HPE_Support_SKU__c)== TRUE){ 
                    if(assetObj.CDMR_Start_Date__c ==null){
                    assetObj.CDMR_Start_Date__c =assetObj.Support_Start_Date_Asset__c;
                    }
                    assetObj.CDMR_End_Date__c =assetObj.Support_End_Date__c;
                }
            }
            // Added by Srujan JIRA # ESS-77823---End
        }       
    }
    // Added by Srujan 12/12/2019
    
    if(Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate )){
        // Added by Srujan 6/05/2021     
        if(NextGenAssetUpdateHandler.isFirstRun){
            NextGenAssetUpdateHandler.isFirstRun = False;
            NextGenAssetUpdateHandler.updateAssets(Trigger.New, prodContrrefresh,  prodArrayNetworking, prodArrayNetworkingSKU);
        }
    }  
}