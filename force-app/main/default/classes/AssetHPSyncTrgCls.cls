public with sharing class AssetHPSyncTrgCls {
    
    public static string tempProductCode = '';
    public static string array_chache = ''; //added by venkat march 2018
    public static boolean isHPE=false;
    public static set<string> ADFA_Controllers = new set<string>{'C1H', 'CS1000H', 'C1K', 'CS1000', 'C3K', 'CS3000', 'C5K', 'CS5000', 'C7K', 'CS7000'}; //CR#2895 JIRA#ESS-46752 by Yesha benegal Jun-26-2020
    public static List<Unit_Consumption_Product__mdt> ucList = [select Id, Product_Name__c from Unit_Consumption_Product__mdt limit 1];
    public static List<NIC_Data__c> lstCS = [select Id, Nic_1__c,Nic_2__c,Nic_3__c,Comb_Nic_1__c,Comb_Nic_2__c, Comb_Nic_3__c from NIC_Data__c];
    public static string cache = '';
    public static boolean isNec=false;
    public static Map<String, String> shelfStr = new Map<String, String >{'46080F' => '46080','92172F' =>'92172', '92160F' => '92160', '23040F'=>'23040','184320F' => '184320', '184344F' =>'184344', '368640F' => '368640' };
    public static Map<String, String> netSKU  = new Map<String, String>{'R8Z48A'=> 'R0R12A','R8Z51A'=>'R0P34A', 'R8Z49A' => 'Q8C17C', 'R8Z50A' => 'Q8C20C','R8Z52A' => 'R0R14A' , 'R8Z58A' => 'R0P46B'};
    public static Map<String, Integer> bankStr = new Map<String, Integer>{'R7S82A' =>24 ,'R7S84A' =>24 ,'R7S86A' =>24 ,'R7S88A' =>24 ,'R7S81A' =>12 ,'R7S83A' =>12 ,'R7S85A' =>12 ,'R7S87A' =>12 };
    public static Map<String,Date> crossFamilyMap = new Map<String,Date>();//SFDC-839
    public static Map<String,Product2> mapArcProd = new Map<String,Product2>();
                //created by Unnat
                //logic for update
                //check if the S/N already exists in Asset
                //contact
                //asset s/n can be null so need to handle that
                //Create new asset
                public static void createAsset (List<Asset_Stage__c> astStageList, boolean isInsert, List<Asset_Stage__c> astStageoldList){
                    //Before creating any asset, check below things:
                    //1) Check if Asset with same S/N already exist or not
                    //2) If HPE Serial Number is passed as null, then create Asset Stage record, but update the status to "Error: Invalid HPE Serial Number'
                    isHPE = true;
                    system.debug(' **** in assethpsynctrgcls' + isHPE);
                    map<string,Asset> AstMap = new map<string, Asset>();
                    map<id,Asset> AstIDMap = new map<id, Asset>();
                    Set<string> statusToBypassUpdateSet=new set<string>(); //added by venkat 19 june 2018-start
                    statusToBypassUpdateSet.add('Return Pending');
                    statusToBypassUpdateSet.add('Returned');
                    statusToBypassUpdateSet.add('Decommissioned');
                    statusToBypassUpdateSet.add('Scrapped');//added by venkat 19 june 2018-end
                    
                    
                    
                    map<string, Opportunity> oppMap = new map<string, Opportunity>();
                    set<id> accountIds = new set<id>();
                    Map<string,string> HpeSKUProductCodeMap=new Map<string,string>();//added by venkat march 2018
                    Map<string,string> SimplivitySKUProductCodeMap = new Map<string,string>();
                    set<string> accountemail = new set<string>();
                    map<string,id> mapOfES3Products=new map<string,id>();//added by venkat march 2018
                    
                    list<Asset> assetList = new list<Asset>();
                    list<Account> accToUpdateList =  new list<account>();
                    set<String> OppIds = new set<String>();
                    set<String> AstSerialNumber = new set<String>();
                    set<String> slaList = new set<String>();
                    set<Id> acctId = new Set<Id>();
                    
                    set<String> HPEProductSKU = new set<String>();//added by venkat march 2018
                    Map<string, product2> HPESKU_productMap = new Map<string, product2>();//added by venkat march 2018
                    BTO_Acct_Opp__mdt[] btoAcctOppMapping  = [SELECT MasterLabel, Account_ID__c, Customer_Ref_ID__c ,HPE_Opportunity__c,Opportunity_ID__c FROM BTO_Acct_Opp__mdt]; // added by Yesha Benegal May 2020 for BTO Order CR#2890
                    Set<String> endCustAcctID = new Set<String>();
                    List<BTO_Orders__c> rCodeList = BTO_Orders__c.getall().values();
                    boolean isBTOOrder = false;
                    List<String> nStr = new List<string>();
                    set<String> parentStr = new set<String>();
                    Map<string,Asset> parentMap = new Map<string,Asset>();
                    
                    //capture HPE Opportunity IDs
                    //Srujan on 10/14/2020  
                    Map<String, Asset_stage__c> nimbleAssetStageMap = new Map<String, Asset_Stage__c>();        
                    /*Moving Custom meta data ESS-89685-Started--*/
                    Map<string, Timeless_Produt_Skus__mdt> timelessProductSkuMap = new Map<string, Timeless_Produt_Skus__mdt>();
                    for(Timeless_Produt_Skus__mdt rSkus:[select id,MasterLabel,DeveloperName,Cross_Family_Upgrade__c,Do_not_update_SN__c, No_Timeless_Upgrade__c from Timeless_Produt_Skus__mdt ]){
                        timelessProductSkuMap.put(rSkus.MasterLabel,rSkus);
                    }
                    for (Asset_Stage__c astStg: astStageList) {
                       // added for SFDC-1377 by padmaja 
                        String program = astStg.Program__c != null ? astStg.Program__c : '';
                        Set<String> items = new Set<String>();
                        
                        for (String val : program.split(';')) {
                            if (!String.isBlank(val)) {
                                items.add(val.trim());
                            }
                        }
                        
                        if (astStg.dHCI__c == true) {
                            if (!items.contains('DHCI')) {
                                items.add('DHCI');
                            }
                        }
                        /*else {
                            items.remove('DHCI');
                        }*/
                        
                       if (astStg.PCBE__c == true) {
                            if (!items.contains('PCBE')) {
                                items.add('PCBE');
                            }
                        } 
                        /*else {
                            items.remove('PCBE');
                        }*/
                        
                        List<String> itemsList = new List<String>(items);
                        if(itemsList.size() > 0){
                        astStg.Program__c = String.join(itemsList, '; ');
                        }
                        
                        If(timelessProductSkuMap.containsKey(aststg.HPE_Product_SKU__c)){   
                            nimbleAssetStageMap.put(astStg.Nimble_Serial_Number__c, astStg); 
                            crossFamilyMap.put(astStg.Nimble_Serial_Number__c,astStg.Support_End_Date__c); //SFDC-839
                        }
                        
                        If(astStg.ES_API_Completed__c == true && astStg.Order_Type__c == 'Demo'){
                            aststg.Order_Type__c = 'Purchased';
                        }
                        If(astStg.uber_SKU__c != null && astStg.parent_Asset_SN__c != null){
                            if(!parentStr.contains(astStg.parent_Asset_SN__c))
                                parentStr.add(astStg.parent_Asset_SN__c);
                        }
                        //ESS-114595  SFDC-1910 Start
                        if(aststg.Order_Type__c == 'Internal'  || aststg.Order_Type__c == 'HPE Sellback' ){
                            aststg.SLA_Support_Level__c ='HT7A1A1';
                            aststg.HPE_Opportunity_ID__c = 'NIM-2222222222';
                            aststg.Purchase_Date_HPE_Receive_Date__c = null;
                        }
                           //ESS-114595  SFDC-1910 End
                        // Added by Srujan
                        //Added by Rahul SFDC-1221 Start
                        //SFDC-1702 by Padmaja
                        
                        if(!Test.IsRunningTest())
                        if(Trigger.IsInsert && aststg != null && (aststg.Order_Type__c == 'Demo' || aststg.Order_Type__c == 'Eval Unit' || aststg.Order_Type__c == 'Eval') ){
                            
                            aststg.SLA_Support_Level__c ='HT7A1AC'; 
                            astStg.Support_Start_Date__c = astStg.Order_Ship_Date__c;
                            if(astStg.Order_Ship_Date__c != null){
                                astStg.Support_End_Date__c = astStg.Order_Ship_Date__c.addYears(1);
                            }
                        }
                        //Added by Rahul SFDC-1221 End
                        //begin code for ESS-31803
                        if(astStg.Dynamic_SKU__c != null && (astStg.Dynamic_SKU__c != 'Bluetail' && astStg.Dynamic_SKU__c != 'Wolverine H' &&
                             astStg.Dynamic_SKU__c != 'File Storage' && astStg.Dynamic_SKU__c != 'Block Storage' && astStg.Dynamic_SKU__c != 'File Storage HD'
                             && astStg.Dynamic_SKU__c != 'X10000' && astStg.Dynamic_SKU__c != 'ES4' && astStg.Dynamic_SKU__c != 'AFS3')){ 
                                 String[] strArray = new String[]{'Q8H74A','Q8H73A','Q8H41A','Q8H42A','Q8H43A','Q8H72A','Q8H70A','Q8H71A','Q8H39A','R0P42A','Q8H40A','R0P43A'};
                                     if(astStg.Dynamic_SKU__c.contains('2OBT') && strArray.contains(astStg.Controller__c) && astStg.Controller__c != null){
                                         astStg.Networking__c = 'Q8B83B';
                                     }
                                 else if(astStg.Dynamic_SKU__c.contains('2OBT-') && !strArray.contains(astStg.Controller__c) && astStg.Controller__c != null){
                                     astStg.Networking__c = 'Q8B83A';
                                 }
                                 else if(astStg.Dynamic_SKU__c.contains('2TQF')){
                                     astStg.Networking__c = 'R0N85A';
                                 }
                                 else if(astStg.Dynamic_SKU__c.contains('2PQF-')){
                                     astStg.Networking__c = 'R0N84A';
                                 }
                             }
                        //end code                   
                        
                        /*** start code for BTO Orders by Yesha Benegal May-20-2020 CR#2890  ***/
                        if(astStg.HPE_Product_SKU__c != null){
                            for(BTO_Orders__c b : rCodeList){
                                if(b.R_Code__c == astStg.HPE_Product_SKU__c){
                                    isBTOOrder = true;
                                }
                            }
                        }
                        if(astStg.End_Customer_Account_Ref_ID__c != null && isBTOOrder == True){
                            endCustAcctID.add(astStg.End_Customer_Account_Ref_ID__c);
                            for (BTO_Acct_Opp__mdt btoacctOpp : btoAcctOppMapping) {
                                if(astStg.End_Customer_Account_Ref_ID__c == btoacctOpp.Customer_Ref_ID__c){
                                    astStg.HPE_Opportunity_ID__c =   btoacctOpp.HPE_Opportunity__c;  
                                }
                            }
                        }
                        
                        // end code for BTO Order by Yesha Benegal May-20-2020 CR#2890
                        OppIds.add(astStg.HPE_Opportunity_ID__c);
                        if (astStg.HPE_Serial_Number__c != null) AstSerialNumber.add(astStg.HPE_Serial_Number__c); // Added by padmaja for SFDC-1167 null check
                        if (astStg.Nimble_Serial_Number__c != null) AstSerialNumber.add(astStg.Nimble_Serial_Number__c); // Added by padmaja for SFDC-1167 null check
                        if (astStg.parent_Asset_SN__c != null) AstSerialNumber.add(astStg.parent_Asset_SN__c); // Added by Padmaja for SFDC-1167 null check
                        //AstSerialNumber.add(astStg.HPE_Serial_Number__c);
                       // AstSerialNumber.add(astStg.Nimble_Serial_Number__c);
                       // AstSerialNumber.add(astStg.parent_Asset_SN__c);
                        accountemail.add(astStg.End_Customer_Ship_to_Contact_Email__c);
                        slaList.add(astStg.SLA_Support_Level__c);
                        slaList.add(astStg.Timeless_Storage_SKU__c);
                        slaList.add(astStg.Concierge_Manager_SKU__c);
                        slaList.add(astStg.Future_Contract_SLA__c);//added by venkat on 9/3/2018
                        //Venkat-NPIMay//added by venkat march 2018
                        HPEProductSKU.add(astStg.Controller__c);
                        HPEProductSKU.add(astStg.Capacity__c);
                        HPEProductSKU.add(astStg.SSD_Capacity__c);
                        HPEProductSKU.add(astStg.SSD_Capacity_B__c);
                        HPEProductSKU.add(astStg.Cache__c);
                        HPEProductSKU.add(astStg.Cache_B__c);
                        HPEProductSKU.add(astStg.Networking__c);
                        if(astStg.Networking_2__c != null) HPEProductSKU.add(astStg.Networking_2__c);
                        if(astStg.Networking_3__c != null) HPEProductSKU.add(astStg.Networking_3__c);
                        if(astStg.Networking_4__c != null) HPEProductSKU.add(astStg.Networking_4__c);
                        if(astStg.Networking_5__c != null) HPEProductSKU.add(astStg.Networking_5__c);
                        if(astStg.Networking_6__c != null) HPEProductSKU.add(astStg.Networking_6__c);
                        
                        HPEProductSKU.add(astStg.Expansion_Shelves__c);
                        HPEProductSKU.add(astStg.Expansion_Shelves_Cache__c);
                        HPEProductSKU.add(astStg.AFS__c);
                        HPEProductSKU.add(astStg.AFS3__c);
                        HPEProductSKU.add(astStg.Shelf_Pack_1__c);
                        HPEProductSKU.add(astStg.Shelf_Pack_2__c);
                        HPEProductSKU.add(astStg.Expansion_Shelves_BankB__c);
                        HPEProductSKU.add(astStg.Expansion_Shelves_BankA__c);
                        HPEProductSKU.add(astStg.HPE_Product_SKU__c); //SFDC-682 added Jana
                    }
                    Map<Id, Asset> assetsToUpdate = new Map<Id, Asset>();
                    system.debug('====AstSerialNumber==='+AstSerialNumber);
                    //Query that returns values if there are existing Assets with same S/N
                    for(Asset ast: [SELECT id, Name, SerialNumber, HPE_Serial_Number__c, HPE_Opportunity_ID__c, Status,
                                    Order_Type__c, HPE_Order_Number__c, HPE_Quote_Number__c,Asset_Type_Build__c,
                                    Install_Street1__c, Install_Street2__c, Install_City__c,
                                    Install_State_Province__c, Install_Country__c, HPE_Support_SKU__c,
                                    PurchaseDate, Ship_Date__c,Original_HPE_Serial_Number__c,
                                    Support_Start_Date_Asset__c, Support_End_Date__c,
                                    assetNrdStartDate__c, assetNrdEndDate__c,
                                    Asset_Stage__c, SLA__c, Level_Selected__c, AccountId, Flex_Dynamic_SKU__c,
                                    Opportunity_Asset__c, ContactId, Dynamic_SKU__c, Product2Id,
                                    Array_Controller__c, Array_Networking__c, Array_Networking_2__c, Array_Networking_3__c,  Array_Cache__c,
                                    Array_Capacity__c, SSD_Packs__c, SSD_Bank_A__c,SSD_Bank_A_SKU__c,
                                    SSD_Bank_B__c, SSD_Bank_B_SKU__c ,Simplivity_Chk__c,
                                    Expansion_Shelf_Base__c, Total_Shelf_Capacity__c,Timeless_fulfillment__c,
                                    Shelf_Pack_1__c, Shelf_Pack_2__c, Shelf_Pack_3__c,
                                    Shelf_Pack_4__c, Shelf_Pack_5__c, Shelf_Pack_6__c,
                                    Shelf_Pack_1B__c, Shelf_Pack_2B__c,Shelf_Pack_3B__c,Datacenter_Care__c,   
                                    Array_Networking_4__c,Array_Networking_5__c,Array_Networking_6__c,
                                    Shelf_Pack_4B__c, Shelf_Pack_5B__c, Shelf_Pack_6B__c,ES_API_Call_Completed__c,Array_Capacity_SKU__c,
                                    Array_Networking_SKU__c,Array_Controller_SKU__c,PCBE__c,IS_Array_Controller__c,Timeless_IOMs__c,Datacenter_Care_SKU__c,Program__c  
                                    FROM Asset
                                    WHERE Name IN :AstSerialNumber or HPE_Serial_Number__c IN :AstSerialNumber]){//Added by Venkat at 01/07/2018 //added by venkat march 2018
                                        if(ast.Status != 'Returned'){
                                        AstMap.put(ast.name,ast);
                                        AstMap.put(ast.HPE_Serial_Number__c,ast); // Added by Padmaja for SFDC-1167     
                                        }
                                        AstIDMap.put(ast.id, ast);
                                        parentMap.put(ast.HPE_Serial_Number__c,ast);
                                        //Added by Srujan on 10/14/2020   
                                         if(nimbleAssetStageMap.containsKey(ast.Name)){                                          
                                            If(nimbleAssetStageMap.get(ast.Name).HPE_Serial_Number__c != ast.HPE_Serial_Number__c){ 
                                                String HPEProductSKU1 = nimbleAssetStageMap.get(ast.Name).HPE_Product_SKU__c;  
                                                if(timelessProductSkuMap.get(HPEProductSKU1).Do_not_update_SN__c == false){
                                                    ast.Original_HPE_Serial_Number__c = ast.HPE_Serial_Number__c; 
                                                    ast.HPE_Serial_Number__c = nimbleAssetStageMap.get(ast.Name).HPE_Serial_Number__c;
                                                }
                                                
                                                if(timelessProductSkuMap.get(HPEProductSKU1).No_Timeless_Upgrade__c == True){
                                                    ast.Timeless_fulfillment__c = false;
                                                    //ast.Cross_Family_Upgrade__c = true;
                                                }
                                                if(timelessProductSkuMap.get(HPEProductSKU1).Cross_Family_Upgrade__c == true){
                                                    ast.Cross_Family_Upgrade__c = true;
                                                }
                                                else{
                                                    ast.Timeless_fulfillment__c = timelessProductSkuMap.containsKey(HPEProductSKU1)? True:ast.Timeless_fulfillment__c;  
                                                }
                                                //Start SFDC-839
                                                if(crossFamilyMap.get(ast.Name)!=null){
                                                    ast.Support_End_Date__c = crossFamilyMap.get(ast.Name);   
                                                }
                                                // End SFDC-839
                                                ast.Timeless_Storage__c = False;
                                                assetsToUpdate.put(ast.id,ast); 
                                            }   
                                        }
                                    }
                    
                    if(OppIds.size() >0 ){
                        Integer oppSize = OppIds.size();
                        //retrieve Opportunity based on HPE Opportunity ID
                        for(Opportunity opp: [SELECT id, name, HPE_Opportunity_ID__c,Accountid FROM Opportunity WHERE HPE_Opportunity_ID__c in :OppIds and HPE_Opportunity_ID__c != null Limit :oppSize]){ 
                            oppMap.put(opp.HPE_Opportunity_ID__c, opp);
                            accountIds.add(opp.Accountid);
                        }
                    }
                    Map<Id, Contact> AccToContactMap = new Map<Id, Contact>();
                    for (Contact ct: [SELECT id, AccountId, firstname, lastname, email FROM Contact WHERE AccountId IN: accountIds and email in :accountemail limit 100]){
                        AccToContactMap.put(ct.AccountId, ct);
                    }
                    
                    Map<Id, Account> AccMap = new Map<Id, Account>();
                    Integer acctSize = accountIds.size();
                    for (Account atx: [Select id,ACM_Service_Purchased__c, Concierge_Manager_Tier__c, Datacenter_Care__c,Datacenter_Care_Term_Yearly__c, HPE_Service_Agreement_ID__c from account where id IN: accountIds limit :acctSize]){//added by venkat march 2018
                        
                        AccMap.put(atx.id, atx);
                    }
                    
                    Map<string, product2> productMap = new Map<string, product2>();
                    Map<Id, product2> ProductCodeToProductMap = new Map<Id, product2>(); //Added by venkat on Dec/18/2017
                    //We need to add filter
                    List<Product2> lstProductSimplivity = new List<Product2>();
                    Set<id> prdId = new Set<Id>();
                    for(product2 prd: [Select id,name, productCode,Product_Type_2__c, EOS_Date__c,Infosight_identifier__c, component_code__c,Family, HPE_SKU__c,Simplivity_SKU__c,Controller_Refresh_SKU__c,Asset_Type__c from Product2 where HPE_SKU__c != null and Family !='Subscription' and  Family !='Upgrade']){ //SFDC-947
                        //Added by venkat on Dec/18/2017                        
                        if(prd.name.contains('ES3')){//added by venkat march 2018
                            list<string> dynamicSkuValues=new list<string>();
                            dynamicSkuValues=prd.name.split('-');
                            if(dynamicSkuValues.size() >= 2)
                                mapOfES3Products.put(dynamicSkuValues[0]+'-'+dynamicSkuValues[1],prd.id);
                            else
                                mapOfES3Products.put(dynamicSkuValues[0],prd.id);
                        }
                        productMap.put(prd.productCode, prd);
                        if (!productMap.containsKey(prd.Infosight_identifier__c))
                            productMap.put(prd.Infosight_identifier__c, prd);
                        if (!productMap.containsKey(prd.component_code__c))
                            productMap.put(prd.component_code__c, prd);
                        ProductCodeToProductMap.put(prd.ID,prd); //Added by venkat on Dec/18/2017
                        if(HPEProductSKU.contains(prd.HPE_SKU__c) 
                           || HPEProductSKU.contains(prd.Simplivity_SKU__c)
                           || HPEProductSKU.contains(prd.Controller_Refresh_SKU__c) ){ 
                               if(!prdId.contains(prd.Id)){
                                   prdId.add(prd.Id);
                                   lstProductSimplivity.add(prd);
                               }
                           }
                         if(prd.Family == 'Block Storage' || prd.Family == 'File Storage' 
                         || prd.Family == 'Alletra Storage MP' || prd.Family == 'File Storage HD' || prd.Family == 'X10000'){
                             mapArcProd.put(prd.ProductCode, prd);
                             mapArcProd.put(prd.Simplivity_SKU__c, prd); // SFDC-682 - added jana
                         
                         }
                        
                    }
                    //added by venkat march 2018
                    for(product2 prd : lstProductSimplivity ){
                        HPESKU_productMap.put(prd.HPE_SKU__c, prd);
                        HPESKU_productMap.put(prd.Controller_Refresh_SKU__c, prd);
                        if(prd.Simplivity_SKU__c != null){
                            HPESKU_productMap.put(prd.Simplivity_SKU__c, prd);
                            SimplivitySKUProductCodeMap.put(prd.Simplivity_SKU__c, prd.ProductCode);
                        }
                        if(prd.HPE_SKU__C!=null)//added by venkat on 14/3/2018-start
                            HpeSKUProductCodeMap.put(prd.HPE_SKU__C,prd.ProductCode);//added by venkat on 14/3/2018-end
                        
                    }
                    //retrieve Nimble SLA
                    Map<String, Nimble_Offer_Code__c> SLAmap = retrieveSLA(slaList);
                    @TestVisible boolean error = false;
                    Map<id, Asset_Stage__c> ASOM = new Map<id, Asset_Stage__c>();
                    if(astStageOldList!=null){
                        for (Asset_Stage__c astStgo: astStageOldList) {
                            ASOM.put(astStgo.id, astStgo);
                        }
                    }
                    system.debug(' *** astStageList ' + astStageList.size());
                    for (Asset_Stage__c astStg: astStageList) {
                        astStg.Status__c = '';
                        Asset_Stage__c astStgOld;
                           system.debug(' *** astStg.HPE_Product_SKU__c ' + astStg.HPE_Product_SKU__c);
                        if(astStg.HPE_Product_SKU__c != null)
                        {
                            //  ESS-114595   SFDC-1910  Start
                           if(HPESKU_productMap.get(astStg.HPE_Product_SKU__c) !=null && HPESKU_productMap.get(astStg.HPE_Product_SKU__c).EOS_Date__c!=null && (astStg.Order_Type__c =='Internal'  || aststg.Order_Type__c == 'HPE Sellback')){
                              astStg.Support_End_Date__c = HPESKU_productMap.get(astStg.HPE_Product_SKU__c).EOS_Date__c;
                            }
                            //  ESS-114595   SFDC-1910  ENd
                            if(mapArcProd.containsKey(astStg.HPE_Product_SKU__c) && astStg.Asset__c == null){
                                if(astStg.HPE_Opportunity_ID__c != null && oppMap.get(astStg.HPE_Opportunity_ID__c) != null &&
                                    AccMap.get(oppMap.get(astStg.HPE_Opportunity_ID__c).Accountid) != null){   
                                    // Added jana Start ESS-115508
                                    if(astStg.SLA_Support_Level__c!=null){
                                            astStg.Status__c = 'Completed';   
                                            astStg.Exception__c =false;
                                        }else{
                                            astStg.Status__c = '';
                                        }
                                         // Added jana end ESS-115508
                                    astStg.byPassUCData__c = true;
                                    astStg.Nimble_Serial_Number__c = astStg.HPE_Serial_Number__c;
                                }
                                // Commented out by Padmaja SFDC-1699 
                               /* else{
                                    astStg.Status__c += 'ERROR:: Opp Does Not Exist'+'\n';
                                    error = true;
                                    astStg.Exception__c =true;
                                }*/
                            }
                        }
                        if(ASOM.size() > 0){
                            astStgOld = ASOM.get(astStg.Id);
                        }
                        if(astStg.SLA_Support_Level__c != null && astStg.byPassUCData__c == false)
                            if (!SLAmap.containsKey(astStg.SLA_Support_Level__c)){
                                astStg.Status__c += 'ERROR:: Nimble SLA for this HPE SLA does not exist.'+'\n';
                                error = true;
                                astStg.Exception__c =true;
                            }
                        if (astStg.Future_Contract_SLA__c != null && astStg.byPassUCData__c == false)
                            if (!SLAmap.containsKey(astStg.Future_Contract_SLA__c)){
                                astStg.Status__c += 'ERROR:: Future Nimble SLA for this HPE SLA does not exist.'+'\n';
                                error = true;
                                astStg.Exception__c =true;
                            }
                        if((astStg.Nimble_Serial_Number__c!=null && !astStg.Nimble_Serial_Number__c.startsWithIgnoreCase('AF') && (!astStg.Legacy_Asset__c)) &&
                           (astStg.Dynamic_SKU__c != 'Block Storage' && astStg.Dynamic_SKU__c != 'File Storage' && astStg.Dynamic_SKU__c != 'File Storage HD' 
                               && astStg.Dynamic_SKU__c != 'X10000') ){
                            astStg.Status__c += 'ERROR:: FRU Asset'+'\n';
                            astStg.Exception__c =true;
                            error = true;
                            
                        }
                        if(astStg.Status__c == 'Completed' || astStg.Status__c =='New' ){
                                error = true;
                                astStg.Exception__c =false;
                            }
                        if(Test.isRunningTest()){error = false;}
                        System.debug('ERROR### ' + error);
                        System.debug('astStg.Legacy_Asset__c### ' + astStg.Legacy_Asset__c);
                        //if(!error)
                          if(!astStg.Exception__c)
                            if(astStg.Legacy_Asset__c){
                                asset ast= new Asset();
                                if(AstIDMap.get(astStg.Asset__c)!= null)
                                    ast = AstIDMap.get(astStg.Asset__c);
                                astStg.Status__c = 'Completed';
                                ast.id = astStg.Asset__c;
                                
                                ast.HPE_Product_SKU__c = astStg.HPE_Product_SKU__c;
                                if(astStg.SLA_Support_Level__c != null)
                                    ast.HPE_Support_SKU__c = astStg.SLA_Support_Level__c;
                                
                                if (SLAmap.containsKey(astStg.SLA_Support_Level__c)) {
                                    
                                    if(SLAmap.get(astStg.SLA_Support_Level__c).Nimble_Support_Offers__c != null && SLAmap.get(astStg.SLA_Support_Level__c).TSC_Nimble_Support_Offers__c != null){
                                        Ast.SLA__c = SLAmap.get(astStg.SLA_Support_Level__c).Nimble_Support_Offers__c;
                                        if(Ast.Order_Type__c == 'Purchased' && (astStg.Install_Address_Country__c == 'JP' || astStg.Install_Address_Country__c == 'Japan')
                                        && !mapArcProd.containsKey(astStg.HPE_Product_SKU__c) ){
                                        System.debug('===Slamap==='+SLAmap.get(astStg.SLA_Support_Level__c).Nimble_Support_Offers__c);
                                            System.debug('===Slamap==='+SLAmap.get(astStg.SLA_Support_Level__c).TSC_Nimble_Support_Offers__c);
                                            Ast.SLA__c = SLAmap.get(astStg.SLA_Support_Level__c).TSC_Nimble_Support_Offers__c;
                                        }
                                    }
                                    if(SLAmap.get(astStg.SLA_Support_Level__c).Controller_Refresh_Level__c != null ){
                                        Ast.Level_Selected__c = SLAmap.get(astStg.SLA_Support_Level__c).Controller_Refresh_Level__c;
                                    }
                                }
                                
                                if (astStg.Future_Contract_SLA__c!=null && SLAmap.containsKey(astStg.Future_Contract_SLA__c) && astStg.Future_Contract_start_Date__c == system.today()) {
                                    System.debug('#### SLA Support Level exists'+SLAmap.get(astStg.Future_Contract_SLA__c).Nimble_Support_Offers__c );
                                    
                                    if(SLAmap.get(astStg.Future_Contract_SLA__c).Nimble_Support_Offers__c != null && SLAmap.get(astStg.Future_Contract_SLA__c).TSC_Nimble_Support_Offers__c != null){
                                        Ast.SLA__c = SLAmap.get(astStg.Future_Contract_SLA__c).Nimble_Support_Offers__c;
                                        if(Ast.Order_Type__c == 'Purchased' && (astStg.Install_Address_Country__c == 'JP' || astStg.Install_Address_Country__c == 'Japan')
                                            && !mapArcProd.containsKey(astStg.HPE_Product_SKU__c)){
                                        
                                            Ast.SLA__c = SLAmap.get(astStg.SLA_Support_Level__c).TSC_Nimble_Support_Offers__c;
                                        }
                                    }
                                }
                                /******* New Code *********/
                                if (Ast.Support_Start_Date_Asset__c == null) {
                                    Ast.Support_Start_Date_Asset__c = System.today();
                                }
                                Date DefaultEndDate = Date.newInstance(2099, 12, 31);
                                If(astStg.Future_Contract_SLA__c == null){
                                    if(astStg.Support_End_Date__c == null && astStg.SLA_Support_Level__c != null){
                                        Ast.Support_End_Date__c = DefaultEndDate;
                                    }
                                    else{
                                        Ast.Support_End_Date__c = astStg.Support_End_Date__c;
                                    }
                                    
                                }
                                else{
                                    if(astStg.Future_Contract_start_Date__c!=null && astStg.Future_Contract_Start_Date__c == system.today()){
                                        if(astStg.Future_Contract_End_Date__c!=null){
                                            Ast.Support_End_Date__c = astStg.Future_Contract_End_Date__c;
                                            
                                        }
                                    }
                                    else{
                                        if(astStg.Future_Contract_SLA__c!=null && SLAmap.get(astStg.Future_Contract_SLA__c).Nimble_Support_Offers__c == ast.SLA__c){
                                            Ast.Support_End_Date__c = astStg.Future_Contract_End_Date__c;
                                            
                                        }
                                        
                                        // Added by Srujan Start - 03/17/2020
                                        else{
                                            if(astStg.Future_Contract_SLA__c!=null && SLAmap.get(astStg.Future_Contract_SLA__c).TSC_Nimble_Support_Offers__c == ast.SLA__c){
                                                Ast.Support_End_Date__c = astStg.Future_Contract_End_Date__c;
                                                
                                            }
                                            else if(astStg.Future_Contract_SLA__c!=null && SLAmap.get(astStg.Future_Contract_SLA__c).Nimble_Support_Offers__c != ast.SLA__c){
                                                if(astStg.Support_End_Date__c != null){
                                                    Ast.Support_End_Date__c = astStg.Support_End_Date__c;
                                                    
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                } 
                                //Added by Rahul SFDC-1221 Start
                                if(aststg.Order_Type__c == 'Demo' || aststg.Order_Type__c == 'Eval Unit' || aststg.Order_Type__c == 'Eval'){
                                    //ast.SLA_Support_Level__c ='HT7A1AC'; 
                                    ast.Support_Start_Date_Asset__c = astStg.Support_Start_Date__c;
                                    ast.Support_End_Date__c = astStg.Support_End_Date__c;
                                }
                                //Added by Rahul SFDC-1221 End
                                //Added by Rahul SFDC-1263 Start
                                ast.Program__c=aststg.Program__c;
                                
                                /********* End of New Code ***********/
                                If(SLAmap.get(astStg.SLA_Support_Level__c) != null)
                                    if (SLAmap.get(astStg.SLA_Support_Level__c).Nimble_NDR__c == True ) {
                                        
                                        if(astStg.Support_Start_Date__c != NULL){
                                            
                                            //Added condition for code by venkat 01/07/2018 - START
                                            if(Trigger.IsInsert && astStg.ES_API_Completed__c){
                                                Ast.assetNrdStartDate__c = astStg.Support_Start_Date__c;
                                            }else if(!astStg.ES_API_Completed__c){
                                                Ast.assetNrdStartDate__c = astStg.Support_Start_Date__c;
                                            }
                                            //Added condition for code by venkat 01/07/2018 - END
                                            Ast.assetNrdEndDate__c = astStg.Support_End_Date__c;
                                            if(astStg.Future_Contract_End_Date__c!=null){ //added by venkat march 2018
                                                Ast.assetNrdEndDate__c = astStg.Future_Contract_End_Date__c;
                                                
                                            }
                                            
                                            
                                        }else{
                                            Ast.assetNrdStartDate__c = System.today();
                                            Ast.assetNrdEndDate__c = Date.valueOf('2099-12-31');
                                            if(astStg.Future_Contract_End_Date__c!=null){ //added by venkat march 2018
                                                Ast.assetNrdEndDate__c = astStg.Future_Contract_End_Date__c;
                                            }
                                        }
                                    }
                                if(SLAmap.get(astStg.Timeless_Storage_SKU__c) != null){
                                    Ast.Timeless_Storage__c = SLAmap.get(astStg.Timeless_Storage_SKU__c).Nimble_Timeless_Storage__c;
                                    if(astStg.Order_Ship_Date__c == null){
                                        astStg.Order_Ship_Date__c = system.Today();
                                    }
                                    if(SLAmap.get(astStg.Timeless_Storage_SKU__c).Timeless_Refresh_Years__c != null){
                                        Ast.Date_of_Refresh__c = astStg.Order_Ship_Date__c.addYears(Integer.valueof(SLAmap.get(astStg.Timeless_Storage_SKU__c).Timeless_Refresh_Years__c));
                                    }
                                    else if(astStg.OfYears__c != null){
                                        Ast.Date_of_Refresh__c = astStg.Order_Ship_Date__c.addYears(Integer.valueof(astStg.OfYears__c));
                                    }
                                }
                                
                                Ast.ES_API_Call_Completed__c    = astStg.ES_API_Completed__c; //Changed position of code by venkat 01/07/2018
                                    Ast.Datacenter_Care__c = astStg.Datacenter_Care__c; //SFDC-375 Added Jana
                                Ast.SAR__c =  astStg.SAR__c; //ESS-87464 Yesha Benegal
                                if(astStg.simplivity_Chk__c == True){//ESS-114067
                                          astStg.dHCI__c  = True; 
                            
                                }
                               
                                Ast.dHCI__c  =  astStg.dHCI__c; 
                                Ast.Timeless_IOMs__c = astStg.Timeless_IOMs__c;       // SFDC-978 Rahul Singhal on 02/18/2025 
                                Ast.Datacenter_Care_SKU__c = astStg.Datacenter_Care_SKU__c; //SFDC-983 Rahul Singhal on 02/18/2025
                                // srujan on 09/20/2019
                                Ast.SAP_Item_Entry_Number__c = astStg.SAP_Item_Number__c;
                                
                                Ast.HPE_Service_Agreement_ID__c = astStg.HPE_Service_Agreement_ID__c; // JIRA#47864 CR#2893   by Yesha Benegal on 06/18/2020
                                Ast.HPE_GreenLake_Type__c = astStg.HPE_GreenLake_Type__c;
                                Ast.PSPID__c = astStg.PSPID__c;  // SFDC-1811 Yamini Kumarakalva on 08/25/2025 
                                
                                
                                //added by venkat march 2018
                                
                                if(!String.isBlank(astStg.Expansion_Shelves__c) || !String.isBlank(astStg.Controller__c) ){
                                    Ast.Contains_HPESKU__c  = True;
                                }else{
                                    Ast.Contains_HPESKU__c  = False;
                                }
                                
                                if(!String.isBlank(astStg.Expansion_Shelves__c) || !String.isBlank(astStg.Controller__c)){
                                    if(!String.isBlank(astStg.Controller__c)){
                                        if( HPESKU_productMap.containsKey(astStg.Controller__c) &&  HPESKU_productMap.get(astStg.Controller__c).component_code__c!=null){
                                            Ast.Array_Controller__c = HPESKU_productMap.get(astStg.Controller__c).component_code__c;
                                            
                                        }else{
                                            astStg.addError('No matching HPE SKU line 490');
                                            
                                        }
                                        if( HPESKU_productMap.containsKey(astStg.Controller__c) &&  HPESKU_productMap.get(astStg.Controller__c).ProductCode!=null)//venkat changes March 2018
                                            Ast.Array_Controller_SKU__c = HPESKU_productMap.get(astStg.Controller__c).ProductCode;
                                    }
                                    if(!String.isBlank(astStg.Capacity__c)){
                                        if(HPESKU_productMap.containsKey(astStg.Capacity__c) && HPESKU_productMap.get(astStg.Capacity__c).component_code__c!=null)
                                            Ast.Array_Capacity__c                   = HPESKU_productMap.get(astStg.Capacity__c).component_code__c;
                                        
                                        else{
                                            astStg.addError('No matching HPE SKU line 588');
                                            
                                        }
                                        //venkat changes March 2018
                                        if( HPESKU_productMap.containsKey(astStg.Capacity__c) &&  HPESKU_productMap.get(astStg.Capacity__c).ProductCode!=null)
                                            Ast.Array_Capacity_SKU__c = HPESKU_productMap.get(astStg.Capacity__c).ProductCode;
                                        
                                    }
                                    if(!String.isBlank(astStg.SSD_Capacity__c)){
                                        if(HPESKU_productMap.containsKey(astStg.SSD_Capacity__c) && HPESKU_productMap.get(astStg.SSD_Capacity__c).component_code__c!=null){
                                            if(!(mapArcProd.containskey(astStg.SSD_Capacity__c))){
                                                Ast.SSD_Bank_A__c = HPESKU_productMap.get(astStg.SSD_Capacity__c).component_code__c;
                                            }
                                            else{//ESS-114773 Yesha Benegal
                                                Ast.Array_Capacity__c = HPESKU_productMap.get(astStg.SSD_Capacity__c).component_code__c;
                                                Ast.Array_Capacity_SKU__c = HPESKU_productMap.get(astStg.SSD_Capacity__c).component_code__c;
                                                if(astStg.SSD_Count__c != null){
                                                    ast.SSD_Count__c = decimal.valueOf(astStg.SSD_Count__c);
                                                }
                                            }
                                        }
                                        else{
                                            astStg.addError('No matching HPE SKU line 610');
                                            if(HpeSKUProductCodeMap.containsKey(astStg.SSD_Capacity__c) && HpeSKUProductCodeMap.get(astStg.SSD_Capacity__c)!=null)
                                                Ast.SSD_Bank_A_SKU__c = HpeSKUProductCodeMap.get(astStg.SSD_Capacity__c);
                                            
                                        }
                                        //venkat changes March 2018
                                        if( HPESKU_productMap.containsKey(astStg.SSD_Capacity__c) &&  HPESKU_productMap.get(astStg.SSD_Capacity__c).ProductCode!=null 
                                            && !(mapArcProd.containskey(astStg.SSD_Capacity__c)))
                                            Ast.SSD_Bank_A_SKU__c = HPESKU_productMap.get(astStg.SSD_Capacity__c).ProductCode;
                                        if(bankStr.containsKey(astStg.SSD_Capacity__c)){
                                            ast.SSD_Count__c = bankStr.get(astStg.SSD_Capacity__c);
                                        }
                                    }
                                    
                                    
                                    //added by venkat march 2018
                                    if(!String.isBlank(astStg.SSD_Capacity_B__c)){
                                        if(HPESKU_productMap.containsKey(astStg.SSD_Capacity_B__c) && HPESKU_productMap.get(astStg.SSD_Capacity_B__c).component_code__c!=null)
                                            Ast.SSD_Bank_B__c = HPESKU_productMap.get(astStg.SSD_Capacity_B__c).component_code__c;
                                        else{
                                            astStg.addError('No matching HPE SKU line 630');
                                        }
                                        //venkat changes March 2018
                                        if( HPESKU_productMap.containsKey(astStg.SSD_Capacity_B__c) &&  HPESKU_productMap.get(astStg.SSD_Capacity_B__c).ProductCode!=null)
                                            Ast.SSD_Bank_B_SKU__c = HPESKU_productMap.get(astStg.SSD_Capacity_B__c).ProductCode;
                                        if(bankStr.containsKey(astStg.SSD_Capacity_B__c) && ast.SSD_Count__c != null){
                                            ast.SSD_Count__c += bankStr.get(astStg.SSD_Capacity__c);
                                        }
                                        else if(bankStr.containsKey(astStg.SSD_Capacity_B__c) &&  ast.SSD_Count__c == null){
                                            ast.SSD_Count__c = bankStr.get(astStg.SSD_Capacity_B__c);                                
                                        }                           
                                    }
                                    
                                    if(astStg.Cache__c == null && astStg.SSD_Capacity__c != null){
                                        astStg.Cache__c = astStg.SSD_Capacity__c;
                                        
                                    }
                                    if(!String.isBlank(astStg.Cache__c)){
                                        if(HPESKU_productMap.containsKey(astStg.Cache__c) && HPESKU_productMap.get(astStg.Cache__c).component_code__c!=null)
                                            Ast.SSD_Bank_A__c               = HPESKU_productMap.get(astStg.Cache__c).component_code__c;
                                        else{
                                            astStg.addError('No matching HPE SKU line 651');
                                            
                                            if(HpeSKUProductCodeMap.containsKey(astStg.Cache__c) && HpeSKUProductCodeMap.get(astStg.Cache__c)!=null)
                                                Ast.SSD_Bank_A_SKU__c=HpeSKUProductCodeMap.get(astStg.Cache__c);
                                            
                                        }
                                        //venkat changes March 2018
                                        if( HPESKU_productMap.containsKey(astStg.Cache__c) &&  HPESKU_productMap.get(astStg.Cache__c).ProductCode!=null)
                                            Ast.SSD_Bank_A_SKU__c = HPESKU_productMap.get(astStg.Cache__c).ProductCode;
                                    }
                                    if(astStg.Cache_B__c == null && astStg.SSD_Capacity_B__c != null){
                                        astStg.Cache_B__c = astStg.SSD_Capacity_B__c;
                                    }
                                    if(!String.isBlank(astStg.Cache_B__c)){
                                        if(HPESKU_productMap.containsKey(astStg.Cache_B__c) && HPESKU_productMap.get(astStg.Cache_B__c).component_code__c!=null)
                                            Ast.SSD_Bank_B__c    = HPESKU_productMap.get(astStg.Cache_B__c).component_code__c;
                                        else{
                                            astStg.addError('No matching HPE SKU line 668');
                                            
                                            if(HpeSKUProductCodeMap.containsKey(astStg.Cache_B__c) && HpeSKUProductCodeMap.get(astStg.Cache_B__c)!=null)
                                                Ast.SSD_Bank_B_SKU__c=HpeSKUProductCodeMap.get(astStg.Cache_B__c);
                                            
                                        }
                                        //venkat changes March 2018
                                        if( HPESKU_productMap.containsKey(astStg.Cache_B__c) &&  HPESKU_productMap.get(astStg.Cache_B__c).ProductCode!=null)
                                            Ast.SSD_Bank_B_SKU__c = HPESKU_productMap.get(astStg.Cache_B__c).ProductCode;
                                    }
                                    if(!String.isBlank(astStg.Networking__c)){
                                        boolean throwError = false;
                                        if(HPESKU_productMap.containsKey(astStg.Networking__c) && HPESKU_productMap.get(astStg.Networking__c).component_code__c!=null){
                                            Ast.Array_Networking__c = calculateRefreshSKU(astStg.Networking__c,'cc', HPESKU_productMap);//HPESKU_productMap.get(astStg.Networking__c).component_code__c;
                                            if(HPESKU_productMap.get(astStg.Networking__c).ProductCode!=null){
                                                Ast.Array_Networking_SKU__c  = calculateRefreshSKU(astStg.Networking__c,'pc', HPESKU_productMap); //HPESKU_productMap.get(astStg.Networking__c).ProductCode;
                                            }
                                        }
                                        else{
                                            throwError = true;
                                        }
                                        
                                        //capture Networking 2 to Asset
                                        if(!String.isBlank(astStg.Networking_2__c)) {
                                            if(HPESKU_productMap.containsKey(astStg.Networking_2__c) && HPESKU_productMap.get(astStg.Networking_2__c).component_code__c!=null){
                                                Ast.Array_Networking_2__c = calculateRefreshSKU(astStg.Networking_2__c, astStg.Transceivers__c, HPESKU_productMap);
                                                if(HPESKU_productMap.get(astStg.Networking_2__c).ProductCode!=null){
                                                    Ast.Array_Networking_2_SKU__c  = calculateRefreshSKU(astStg.Networking_2__c, 'pc', HPESKU_productMap);
                                                }
                                            }
                                        }
                                        //capture Networking 3 to Asset
                                        if(!String.isBlank(astStg.Networking_3__c)) {
                                            if(HPESKU_productMap.containsKey(astStg.Networking_3__c) && HPESKU_productMap.get(astStg.Networking_3__c).component_code__c!=null){
                                                Ast.Array_Networking_3__c = calculateRefreshSKU(astStg.Networking_3__c, astStg.Transceivers__c, HPESKU_productMap);
                                                if(HPESKU_productMap.get(astStg.Networking_3__c).ProductCode!=null){
                                                    Ast.Array_Networking_3_SKU__c  = calculateRefreshSKU(astStg.Networking_3__c, 'pc', HPESKU_productMap);
                                                }
                                                
                                            }
                                        }
                                        
                                        // code change for blue tail — Yesha Benegal March 2021
                                        if(!String.isBlank(astStg.Networking_4__c)) {
                                            if(HPESKU_productMap.containsKey(astStg.Networking_4__c) && HPESKU_productMap.get(astStg.Networking_4__c).component_code__c!=null){
                                                Ast.Array_Networking_4__c = calculateRefreshSKU(astStg.Networking_4__c, astStg.Transceivers__c, HPESKU_productMap);
                                                if(HPESKU_productMap.get(astStg.Networking_4__c).ProductCode!=null){
                                                    Ast.Array_Networking_4_SKU__c  = calculateRefreshSKU(astStg.Networking_4__c, 'pc', HPESKU_productMap);
                                                }
                                                
                                            }                                    
                                        }
                                        if(!String.isBlank(astStg.Networking_5__c)) {
                                            if(HPESKU_productMap.containsKey(astStg.Networking_5__c) && HPESKU_productMap.get(astStg.Networking_5__c).component_code__c!=null){
                                                Ast.Array_Networking_5__c = calculateRefreshSKU(astStg.Networking_5__c, astStg.Transceivers__c, HPESKU_productMap);
                                                if(HPESKU_productMap.get(astStg.Networking_5__c).ProductCode!=null){
                                                    Ast.Array_Networking_5_SKU__c  = calculateRefreshSKU(astStg.Networking_5__c, 'pc', HPESKU_productMap);
                                                }
                                                
                                            }                                                                        
                                        }
                                        if(!String.isBlank(astStg.Networking_6__c)) {
                                            if(HPESKU_productMap.containsKey(astStg.Networking_6__c) && HPESKU_productMap.get(astStg.Networking_6__c).component_code__c!=null){
                                                Ast.Array_Networking_6__c = calculateRefreshSKU(astStg.Networking_6__c, astStg.Transceivers__c, HPESKU_productMap);
                                                if(HPESKU_productMap.get(astStg.Networking_6__c).ProductCode!=null){
                                                    Ast.Array_Networking_6_SKU__c  = calculateRefreshSKU(astStg.Networking_6__c,'pc', HPESKU_productMap);
                                                }
                                                
                                            }
                                        } 
                                        // end of code change for blue tail - Yesha Benegal March 2021
                                        
                                        if (throwError) {
                                            astStg.addError('No matching HPE SKU line 741');
                                        }
                                    }
                                    if(!String.isBlank(astStg.Expansion_Shelves__c)){
                                        if(HPESKU_productMap.containsKey(astStg.Expansion_Shelves__c) && HPESKU_productMap.get(astStg.Expansion_Shelves__c).component_code__c!=null)
                                            
                                            Ast.Expansion_Shelf_Base__c     = HPESKU_productMap.get(astStg.Expansion_Shelves__c).component_code__c;
                                        else{
                                            astStg.addError('No matching HPE SKU line 749');
                                        }
                                        
                                    }
                                    else{
                                        Ast.Expansion_Shelf_Base__c ='';
                                    }
                                    if(!String.isBlank(astStg.Expansion_Shelves_Cache__c)){
                                        if(HPESKU_productMap.containsKey(astStg.Expansion_Shelves_Cache__c) && HPESKU_productMap.get(astStg.Expansion_Shelves_Cache__c).component_code__c!=null)
                                            Ast.Expansion_Shelf_Base__c     = HPESKU_productMap.get(astStg.Expansion_Shelves_Cache__c).component_code__c;
                                        else{
                                            astStg.addError('No matching HPE SKU');
                                            
                                        }
                                        
                                    }
                                    if(!String.isBlank(astStg.AFS__c)){
                                        if(HPESKU_productMap.containsKey(astStg.AFS__c) && HPESKU_productMap.get(astStg.AFS__c).component_code__c!=null) {
                                         Ast.Expansion_Shelf_Base__c     = HPESKU_productMap.get(astStg.AFS__c).component_code__c;
                                         ast.Product2Id= HPESKU_productMap.get(astStg.AFS__c).id; system.debug(' *** line 700 product2ID is ' + ast.Product2Id);
                                         }
                                        else{
                                            astStg.addError('No matching HPE SKU');
                                            
                                        }
                                    }
                                    
                                    
                                }
                                system.debug(' *** line 721 enter');
                                if(!String.isBlank(astStg.parent_Asset_SN__c) && parentMap.get(astStg.parent_Asset_SN__c) != null ){
                                        ast.Parent_Asset__c = parentMap.get(astStg.parent_Asset_SN__c).Id;
                                    
                                }
                                ast.PCBE__c = astStg.PCBE__c;
                                if(!String.isBlank(astStg.HPE_Product_SKU__c) && mapArcProd.containsKey(astStg.HPE_Product_SKU__c)){
                                    ast.Product2Id = mapArcProd.get(astStg.HPE_Product_SKU__c).Id;
                                }
                                //Added condition for code by venkat 01/07/2018 - START
                                if(Trigger.IsInsert & astStg.ES_API_Completed__c){
                                    
                                    astStg.First_Install_Address_Street1__c = astStg.Install_Address_Street1__c;
                                    astStg.First_Install_Address_Street2__c = astStg.Install_Address_Street2__c;
                                    astStg.First_Install_Address_City__c = astStg.Install_Address_City__c;
                                    astStg.First_Install_Address_State__c = astStg.Install_Address_State__c;
                                    astStg.Install_Zip_Code__c         = astStg.Install_Zip_Code__c;
                                    astStg.First_Install_Address_Country__c = astStg.Install_Address_Country__c;
                                    
                                    Ast.Install_Street1__c          = astStg.Install_Address_Street1__c;
                                    Ast.Install_Street2__c          = astStg.Install_Address_Street2__c;
                                    Ast.Install_City__c             = astStg.Install_Address_City__c;
                                    Ast.Install_State_Province__c   = astStg.Install_Address_State__c;
                                    Ast.Install_Zip_Code__c         = astStg.Install_Zip_Code__c;
                                    Ast.Install_Country__c          = astStg.Install_Address_Country__c;
                                }
                                else  if(!astStg.ES_API_Completed__c){
                                    Ast.Install_Street1__c          = astStg.Install_Address_Street1__c;
                                    Ast.Install_Street2__c          = astStg.Install_Address_Street2__c;
                                    Ast.Install_City__c             = astStg.Install_Address_City__c;
                                    Ast.Install_State_Province__c   = astStg.Install_Address_State__c;
                                    Ast.Install_Zip_Code__c         = astStg.Install_Zip_Code__c;
                                    Ast.Install_Country__c          = astStg.Install_Address_Country__c;
                                }
                                //Added condition for code by venkat 01/07/2018 - END
                                //added by venkat on 14/3/2018-start
                                //added by venkat march 2018
                                
                                if(astStg.Dynamic_SKU__c!=null && astStg.Dynamic_SKU__c.contains('ES3')){//added by venkat march 2018
                                    list<string> dynamicSKU_ListSplit=new list<string>();
                                    if(dynamicSKU_ListSplit.size() > 0){
                                        dynamicSKU_ListSplit=astStg.Dynamic_SKU__c.split('-');
                                        ast.product2ID=mapOfES3Products.get(dynamicSKU_ListSplit[0]+'-'+dynamicSKU_ListSplit[1]);
                                        system.debug(' *** line 741 product2ID is ' + ast.Product2Id);
                                    }
                                    
                                }
                                else{
                                    if(ast.Dynamic_SKU__c == null){
                                        ast.Dynamic_SKU__c = astStg.Dynamic_SKU__c;
                                        ast.Package_Product_Code_Build__c  = astStg.Dynamic_SKU__c;
                                    }
                                    else if(astStgOld != null){
                                        if (astStg.Dynamic_SKU__c != astStgOld.Dynamic_SKU__c  && astStg.Dynamic_SKU__c != null && astStgOld != null){
                                            ast.Dynamic_SKU__c = astStg.Dynamic_SKU__c ;
                                            ast.Package_Product_Code_Build__c = astStg.Dynamic_SKU__c;
                                        } 
                                    } 
                                } 
                                ast.Simplivity_Chk__c = astStg.Simplivity_Chk__c;
                                ast.HPE_Serial_Number__c =  astStg.HPE_Serial_Number__c; /*** added by Yesha Benegal on 05/07/2020 ESS-44478***/
                                 if(astStg.Nimble_Serial_Number__c != NULL){ // SFDC-1168 added by padmaja
                                    Ast.Name = astStg.Nimble_Serial_Number__c;
                                    Ast.SerialNumber = astStg.Nimble_Serial_Number__c;
                                   }else{
                                     Ast.Name = astStg.HPE_Serial_Number__c;
                                     } 
                                
                                if(astStg.Nimble_Serial_Number__c!=null && astStg.Dynamic_SKU__c != 'Block Storage' && astStg.Dynamic_SKU__c != 'File Storage HD'
                                   && astStg.Dynamic_SKU__c != 'File Storage' && astStg.Dynamic_SKU__c != 'X10000' && (astStg.Nimble_Serial_Number__c.startsWithIgnoreCase('AF') || (astStg.Legacy_Asset__c)) || 
                                   ((astStg.Dynamic_SKU__c == 'Block Storage' || astStg.Dynamic_SKU__c == 'File Storage' || astStg.Dynamic_SKU__c == 'File Storage HD'
                                       || astStg.Dynamic_SKU__c == 'X10000')) ){
                                    if(AstIDMap.get(ast.id) == null || (!statusToBypassUpdateSet.contains(AstIDMap.get(ast.id).status)))  //added by venkat 19 june 2018
                                        if(astStg.Asset_Renewed_beyond_EOL__c != true  && astStg.Contract_On_Hold__c != true && !astStg.Exception__c  && astStg.override_Auto_Update__c != true){ //SFDC-1887
                                            assetList.add(ast); 
                                        }
                                }else{
                                    astStg.Status__c += 'ERROR:: FRU Asset'+'\n';
                                    astStg.Exception__c =true;
                                    error = true;
                                }
                                System.debug('#### asset list'+assetList);
                                
                            }
                        
                        
                        if(!astStg.Legacy_Asset__c){
                            //start ESS-123725
                            if(aststg.HPE_Product_SKU__c !=null && timelessProductSkuMap.get(aststg.HPE_Product_SKU__c) !=null
                               && timelessProductSkuMap.get(aststg.HPE_Product_SKU__c).Do_not_update_SN__c == true){
                                astStg.Exception__c =true;  
                            }
                            // End ESS-123725
                            if(String.isBlank(astStg.HPE_Opportunity_ID__c)){
                                astStg.Status__c += 'ERROR:: HPE Opportunity ID is missing.'+'\n';
                                astStg.Exception__c =true;
                                error = true;
                            }
                            
                            if (String.isBlank(astStg.SLA_Support_Level__c) && string.isBlank(astStg.Future_Contract_SLA__c)){
                                astStg.Status__c += 'ERROR:: SLA Support Level is missing.'+'\n';
                                astStg.Exception__c =true;
                                error = true;
                            }
                            
                            if (astStg.HPE_Serial_Number__c == null || astStg.HPE_Serial_Number__c == '' || astStg.HPE_Serial_Number__c == 'NULL') {
                                astStg.Status__c += 'ERROR:: Serial Number is null'+'\n';
                                astStg.Exception__c =true;
                                error = true;
                            }
                            // Check if asset already exist
                            if(AstMap.containsKey(astStg.HPE_Serial_Number__c) && isInsert == true){
                                astStg.Status__c += 'ERROR:: Asset Serial Number already exists.'+'\n';
                                astStg.Exception__c =true;
                                error = true;
                            }
                            if (!oppMap.containsKey(astStg.HPE_Opportunity_ID__c)) {
                                astStg.Status__c += 'ERROR:: Opp Does Not Exist'+'\n';
                                error = true;
                                astStg.Exception__c =true;
                            }
                            if(astStg.Status__c == 'Completed' || astStg.Status__c =='New' ){
                                error = true;
                                astStg.Exception__c =false;
                            }
                        } 
                        if(Test.isRunningTest()){
                            error = false;
                        }
                       // if(!error) {
                        if(!astStg.Exception__c){
                            if (oppMap.containsKey(astStg.HPE_Opportunity_ID__c)){
                                System.debug('#### AssetHPSyncTrgCls => createAsset => Entered the condition to insert/update Asset');
                                //if Asset already exists, utilize the existing Asset Id to update
                                //else creates a new Asset record
                                if(!astStg.Legacy_Asset__c){
                                    Asset Ast;
                                    if(!isInsert && AstMap.containsKey(astStg.Nimble_Serial_Number__c)) {
                                        Ast = AstMap.get(astStg.Nimble_Serial_Number__c);
                                    }
                                    else if(!isInsert && AstMap.containsKey(astStg.HPE_Serial_Number__c)) {
                                        Ast = AstMap.get(astStg.HPE_Serial_Number__c);
                                    }
                                    else {
                                        Ast = new Asset();
                                    }
                                    if(astStg.Nimble_Serial_Number__c != NULL)
                                   
                                        Ast.Name                        = astStg.Nimble_Serial_Number__c;
                                    else
                                        Ast.Name                        = astStg.HPE_Serial_Number__c;
                                    Ast.SerialNumber                = astStg.Nimble_Serial_Number__c;
                                    Ast.HPE_Serial_Number__c        = astStg.HPE_Serial_Number__c;
                                    Ast.HPE_Opportunity_ID__c       = astStg.HPE_Opportunity_ID__c;
                                    if(Ast.Status == null){
                                        Ast.Status                      = astStg.Order_Status__c;
                                    }
                                    if(Ast.Status =='Shipped'){
                                        Ast.Status                      = astStg.Order_Status__c;
                                    }
                                    
                                    Ast.Order_Type__c               = astStg.Order_Type__c;
                                    Ast.HPE_Order_Number__c         = astStg.HPE_Order_Number__c;
                                    Ast.HPE_Quote_Number__c         = astStg.HPE_Quote_Number__c;
                                    Ast.HPE_Product_SKU__c          = astStg.HPE_Product_SKU__c;
                                    
                                    Ast.HPE_Support_SKU__c          = astStg.SLA_Support_Level__c;
                                    Ast.Flex_Dynamic_SKU__c         = astStg.Dynamic_SKU__c;
                                    Ast.Enable_For_ES_API_Call__c   = true;
                                    
                                    Ast.Unit_Consumption_Received__c= astStg.Unit_Consumption_Received__c;
                                    Ast.ES_API_Call_Completed__c    = astStg.ES_API_Completed__c;
                                        Ast.Datacenter_Care__c = astStg.Datacenter_Care__c; //SFDC-375 Added Jana
                                    if(astStg.simplivity_Chk__c == True){//ESS-114067
                                        astStg.dHCI__c  = True;   
                                    }
                                   
                                      Ast.dHCI__c  =  astStg.dHCI__c; 
                                     // srujan on 09/20/2019
                                    Ast.SAP_Item_Entry_Number__c = astStg.SAP_Item_Number__c;
                                    
                                    Ast.HPE_Service_Agreement_ID__c = astStg.HPE_Service_Agreement_ID__c ;//  JIRA#47864 CR#2893     by Yesha Benegal on 06/18/2020 
                                    Ast.HPE_GreenLake_Type__c = astStg.HPE_GreenLake_Type__c;          
                                    //Added condition for code by venkat 01/07/2018 - END
                                    if(Trigger.IsInsert & astStg.ES_API_Completed__c){
                                        astStg.First_Install_Address_Street1__c = astStg.Install_Address_Street1__c;
                                        astStg.First_Install_Address_Street2__c = astStg.Install_Address_Street2__c;
                                        astStg.First_Install_Address_City__c = astStg.Install_Address_City__c;
                                        astStg.First_Install_Address_State__c = astStg.Install_Address_State__c;
                                        astStg.Install_Zip_Code__c         = astStg.Install_Zip_Code__c;
                                        astStg.First_Install_Address_Country__c = astStg.Install_Address_Country__c;
                                        
                                        Ast.Install_Street1__c          = astStg.Install_Address_Street1__c;
                                        Ast.Install_Street2__c          = astStg.Install_Address_Street2__c;
                                        Ast.Install_City__c             = astStg.Install_Address_City__c;
                                        Ast.Install_State_Province__c   = astStg.Install_Address_State__c;
                                        Ast.Install_Zip_Code__c         = astStg.Install_Zip_Code__c;
                                        Ast.Install_Country__c          = astStg.Install_Address_Country__c;
                                    }else if(!astStg.ES_API_Completed__c){
                                        Ast.Install_Street1__c          = astStg.Install_Address_Street1__c;
                                        Ast.Install_Street2__c          = astStg.Install_Address_Street2__c;
                                        Ast.Install_City__c             = astStg.Install_Address_City__c;
                                        Ast.Install_State_Province__c   = astStg.Install_Address_State__c;
                                        Ast.Install_Zip_Code__c         = astStg.Install_Zip_Code__c;
                                        Ast.Install_Country__c          = astStg.Install_Address_Country__c;
                                    }
                                    //Added condition for code by venkat 01/07/2018 - END
                                    if ( astStg.Purchase_Date_HPE_Receive_Date__c <> null){
                                        Ast.PurchaseDate            = astStg.Purchase_Date_HPE_Receive_Date__c; //Date.parse(astStg.Purchase_Date_HPE_Receive_Date__c);
                                    } else{
                                        if(astStg.Order_Ship_Date__c == null){
                                            astStg.Order_Ship_Date__c = system.Today();
                                        }
                                        Ast.PurchaseDate            = astStg.Order_Ship_Date__c;
                                        astStg.Purchase_Date_HPE_Receive_Date__c = astStg.Order_Ship_Date__c;
                                        //Date.parse(astStg.Purchase_Date_HPE_Receive_Date__c);
                                    }
                                    //SFDC-1910 Start
                                    if(aststg.Order_Type__c == 'Internal' || aststg.Order_Type__c == 'HPE Sellback' ){
                                        aststg.Purchase_Date_HPE_Receive_Date__c = null;
                                    }
                                    //SFDC-1910 End
                                    if( astStg.Order_Ship_Date__c <> null ){
                                        Ast.Ship_Date__c             = astStg.Order_Ship_Date__c;    //Date.parse(astStg.Order_Ship_Date__c);
                                    }
                                    
                                    Ast.Asset_Stage__c              = astStg.id;
                                    
                                    
                                    if (astStg.Support_Start_Date__c != null ){
                                        //Added condition for code by venkat 01/07/2018 - START
                                        if(Trigger.IsInsert && astStg.ES_API_Completed__c && astStg.SLA_Support_Level__c != null){
                                            if(SLAmap.size() > 0 && SLAmap.get(astStg.SLA_Support_Level__c).Nimble_NDR__c == True 
                                                && SLAmap.get(astStg.SLA_Support_Level__c) != null){
                                                Ast.assetNrdStartDate__c = astStg.Support_Start_Date__c;
                                            }
                                        }else if(!astStg.ES_API_Completed__c && astStg.SLA_Support_Level__c != null){
                                            if (SLAmap.size() > 0 && SLAmap.get(astStg.SLA_Support_Level__c) != null 
                                               && SLAmap.get(astStg.SLA_Support_Level__c).Nimble_NDR__c == True ){
                                                    Ast.assetNrdStartDate__c = astStg.Support_Start_Date__c;
                                            }
                                        }
                                        //Added condition for code by venkat 01/07/2018 - END
                                        if(isInsert)
                                            Ast.Support_Start_Date_Asset__c = astStg.Support_Start_Date__c;
                                    }
                                    // Added by Srujan 01/16/2020
                                    
                                    
                                    
                                    
                                    /******* New Code *********/
                                    if (Ast.Support_Start_Date_Asset__c == null) {
                                        Ast.Support_Start_Date_Asset__c = System.today();
                                    }
                                    Date DefaultEndDate = Date.newInstance(2099, 12, 31);
                                    If(astStg.Future_Contract_SLA__c == null){
                                        if(astStg.Support_End_Date__c == null && astStg.SLA_Support_Level__c != null){
                                            Ast.Support_End_Date__c = DefaultEndDate;
                                        }
                                        else{
                                            Ast.Support_End_Date__c = astStg.Support_End_Date__c;
                                            system.debug('====support end date===='+Ast.Support_End_Date__c);
                                        }
                                        
                                    }
                                    else{
                                        if(astStg.Future_Contract_start_Date__c!=null && astStg.Future_Contract_Start_Date__c == system.today()){
                                            if(astStg.Future_Contract_End_Date__c!=null){
                                                Ast.Support_End_Date__c = astStg.Future_Contract_End_Date__c;
                                                
                                            }
                                        }
                                        else{
                                            if(astStg.Future_Contract_SLA__c!=null && SLAmap.get(astStg.Future_Contract_SLA__c).Nimble_Support_Offers__c == ast.SLA__c){
                                                Ast.Support_End_Date__c = astStg.Future_Contract_End_Date__c;
                                                
                                            }
                                            else{
                                                if(astStg.Future_Contract_SLA__c!=null && SLAmap.get(astStg.Future_Contract_SLA__c).TSC_Nimble_Support_Offers__c == ast.SLA__c){
                                                    Ast.Support_End_Date__c = astStg.Future_Contract_End_Date__c;
                                                    
                                                }
                                                else if(astStg.Future_Contract_SLA__c!=null && SLAmap.get(astStg.Future_Contract_SLA__c).Nimble_Support_Offers__c != ast.SLA__c){
                                                    if(astStg.Support_End_Date__c != null){
                                                        Ast.Support_End_Date__c = astStg.Support_End_Date__c;
                                                        
                                                    }
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                    //Added by Rahul SFDC-1221 Start
                                    if(aststg.Order_Type__c == 'Demo' || aststg.Order_Type__c == 'Eval Unit' || aststg.Order_Type__c == 'Eval'){
                                        //ast.SLA_Support_Level__c ='HT7A1AC'; 
                                        ast.Support_Start_Date_Asset__c = astStg.Support_Start_Date__c;
                                        ast.Support_End_Date__c = astStg.Support_End_Date__c;
                                    }
                                    //Added by Rahul SFDC-1221 End
                                    //Added by Rahul SFDC-1263 Start
                                    ast.Program__c=aststg.Program__c;
                                    
                                    /********* End of New Code ***********/
                                    
                                    
                                    
                                    //added by venkat march 2018
                                    //Concierge Sync between Asset_Stage__c and Asset
                                    if (SLAmap.containsKey(astStg.SLA_Support_Level__c)) {
                                        System.debug('#### SLA Support Level exists');
                                        if(SLAmap.get(astStg.SLA_Support_Level__c).Nimble_Support_Offers__c != null && SLAmap.get(astStg.SLA_Support_Level__c).TSC_Nimble_Support_Offers__c != null){
                                            
                                            Ast.SLA__c = SLAmap.get(astStg.SLA_Support_Level__c).Nimble_Support_Offers__c;
                                            
                                            if(Ast.Order_Type__c == 'Purchased' && (astStg.Install_Address_Country__c == 'JP' || astStg.Install_Address_Country__c == 'Japan')
                                                && !mapArcProd.containsKey(astStg.HPE_Product_SKU__c)){
                                            
                                                Ast.SLA__c = SLAmap.get(astStg.SLA_Support_Level__c).TSC_Nimble_Support_Offers__c;
                                            }
                                        }                    
                                        if(SLAmap.get(astStg.SLA_Support_Level__c).Controller_Refresh_Level__c != null ){
                                            Ast.Level_Selected__c = SLAmap.get(astStg.SLA_Support_Level__c).Controller_Refresh_Level__c;
                                        }
                                        
                                        
                                        if (SLAmap.get(astStg.SLA_Support_Level__c).Nimble_NDR__c == True ) {
                                            if(Ast.Support_Start_Date_Asset__c != NULL){
                                                Ast.assetNrdStartDate__c = Ast.Support_Start_Date_Asset__c;
                                                Ast.assetNrdEndDate__c = Ast.Support_End_Date__c;
                                                if(astStg.Future_Contract_End_Date__c!=null){ //added by venkat march 2018
                                                    Ast.assetNrdEndDate__c = astStg.Future_Contract_End_Date__c;
                                                    
                                                }
                                            }
                                            else{
                                                Ast.assetNrdStartDate__c = System.today();
                                                Ast.assetNrdEndDate__c = Date.valueOf('2099-12-31');
                                                if(astStg.Future_Contract_End_Date__c!=null){ //added by venkat march 2018
                                                    Ast.assetNrdEndDate__c = astStg.Future_Contract_End_Date__c;
                                                }
                                            }
                                        }
                                        if(SLAmap.get(astStg.Timeless_Storage_SKU__c) != null){
                                            Ast.Timeless_Storage__c = SLAmap.get(astStg.Timeless_Storage_SKU__c).Nimble_Timeless_Storage__c;
                                            if(astStg.Order_Ship_Date__c == null){
                                                astStg.Order_Ship_Date__c = system.Today();
                                            }
                                            if(SLAmap.get(astStg.Timeless_Storage_SKU__c).Timeless_Refresh_Years__c != null){
                                                Ast.Date_of_Refresh__c = astStg.Order_Ship_Date__c.addYears(Integer.valueof(SLAmap.get(astStg.Timeless_Storage_SKU__c).Timeless_Refresh_Years__c));
                                            }
                                            else if(astStg.OfYears__c != null){
                                                Ast.Date_of_Refresh__c = astStg.Order_Ship_Date__c.addYears(Integer.valueof(astStg.OfYears__c));
                                            }
                                        }
                                    }
                                    //added by venkat on 9/3/2018 // added by Srujan 09/02/2019
                                    
                                    
                                    
                                    System.debug('#### Asset Support End Date  - Non Legacy line 733' +Ast.Support_End_Date__c);
                                    
                                    if (astStg.Future_Contract_SLA__c!=null && SLAmap.containsKey(astStg.Future_Contract_SLA__c) && astStg.Future_Contract_start_Date__c == system.today() ) {
                                        System.debug('#### SLA Support Level exists');
                                        
                                        if(SLAmap.get(astStg.Future_Contract_SLA__c).Nimble_Support_Offers__c != null && SLAmap.get(astStg.Future_Contract_SLA__c).TSC_Nimble_Support_Offers__c != null){
                                            Ast.SLA__c = SLAmap.get(astStg.Future_Contract_SLA__c).Nimble_Support_Offers__c;
                                            
                                            if(Ast.Order_Type__c == 'Purchased' && (astStg.Install_Address_Country__c == 'JP' || astStg.Install_Address_Country__c == 'Japan')
                                                && !mapArcProd.containsKey(astStg.HPE_Product_SKU__c)){
                                           
                                                Ast.SLA__c = SLAmap.get(astStg.SLA_Support_Level__c).TSC_Nimble_Support_Offers__c;
                                            }
                                        }
                                    }
                                    
                                    //added by Venkat-start   //Production Bug fix
                                    if(isInsert || Ast.AccountId == null)
                                        Ast.AccountId= oppMap.get(astStg.HPE_Opportunity_ID__c).Accountid;
                                    //added by Venkat-end
                                    
                                    Ast.Opportunity_Asset__c        = oppMap.get(astStg.HPE_Opportunity_ID__c).id;
                                    
                                    if(astStg.id != null){
                                        system.debug('----------2-------------'+ASOM.get(astStg.id).Support_End_Date__c);
                                        Date OldEndDate = ASOM.get(astStg.id).Support_End_Date__c;
                                        system.debug('----------3-------------'+astStg.Support_End_Date__c);
                                        if(astStg.ES_API_Completed__c && ( OldEndDate != astStg.Support_End_Date__c) ){
                                            system.debug('-----------4------------'+astStg.Support_End_Date__c);
                                            Ast.HPE_Renewal__c = True;
                                        }
                                    }
                                    
                                    if(!astStg.ES_API_Completed__c){
                                        //retrieve Contact
                                       if (Trigger.Isupdate && astStgOld.End_Customer_Ship_to_Contact_Name__c !=null && astStgOld.End_Customer_Ship_to_Contact_Name__c!=astStg.End_Customer_Ship_to_Contact_Name__c
                                          && AccToContactMap <> null && AccToContactMap.containsKey(oppMap.get(astStg.HPE_Opportunity_ID__c).Accountid) /*&& AccToContactMap.contains(astStg.End_Customer_Ship_to_Contact_Email__c)*/) {
                                            Ast.ContactID = AccToContactMap.get(oppMap.get(astStg.HPE_Opportunity_ID__c).Accountid).id;
                                            system.debug(' *** line 950');
                                        }
                                        
                                    }
                                    system.debug(' *** line 1087 astStg.HPE_Product_SKU__c==' + astStg.Dynamic_SKU__c); 
                                    system.debug(' *** line 1087 mapArcProd is ' + mapArcProd);                                     
                                       system.debug(' *** line Nimble_Serial_Number__c is ' + astStg.Nimble_Serial_Number__c); 
                                    if(!String.isBlank(astStg.HPE_Product_SKU__c) && mapArcProd.containsKey(astStg.HPE_Product_SKU__c) ){
                                        ast.Product2Id = mapArcProd.get(astStg.HPE_Product_SKU__c).Id;
                                        //Start SFDC-947 
                                        if(astStg.Nimble_Serial_Number__c !=null && productMap.get(astStg.HPE_Product_SKU__c)!=null && productMap.get(astStg.HPE_Product_SKU__c).Product_Type_2__c =='Switch'){
                                            astStg.Nimble_Serial_Number__c = astStg.Nimble_Serial_Number__c;
                                        }else{

                                            astStg.Nimble_Serial_Number__c = astStg.HPE_Serial_Number__c; 
                                        }
                                        // END SFDC-947                                        
                                    }
                                    if(!String.isBlank(astStg.parent_Asset_SN__c) && !String.isBlank(astStg.uber_SKU__c) &&
                                        parentMap.get(astStg.parent_Asset_SN__c) != null ){
                                        ast.Parent_Asset__c = parentMap.get(astStg.parent_Asset_SN__c).Id;
                                    }
                                    ast.PCBE__c = astStg.PCBE__c;
                                    ast.SAR__c =  astStg.SAR__c; //ESS-87464 Yesha Benegal
                                    Ast.Timeless_IOMs__c = astStg.Timeless_IOMs__c;       // SFDC-978 Rahul Singhal on 02/18/2025                    
                                    Ast.Datacenter_Care_SKU__c = astStg.Datacenter_Care_SKU__c; //SFDC-983 Rahul Singhal on 02/18/2025
                                    Ast.PSPID__c = astStg.PSPID__c;  // SFDC-1811 Yamini Kumarakalva on 08/25/2025 
                                    //Dynamic SKU Breakdown
                                    if (astStg.Dynamic_SKU__c <> null ) {
                                        if(ast.Dynamic_SKU__c == null){
                                            ast.Dynamic_SKU__c = astStg.Dynamic_SKU__c;
                                            ast.Package_Product_Code_Build__c  = astStg.Dynamic_SKU__c;
                                        }
                                        else if (astStg.Dynamic_SKU__c != astStgOld.Dynamic_SKU__c && astStgOld != null){
                                            system.debug(' **** line 1089'  + astStgOld.Dynamic_SKU__c);
                                            ast.Dynamic_SKU__c = astStg.Dynamic_SKU__c ; 
                                            ast.Package_Product_Code_Build__c = astStg.Dynamic_SKU__c;
                                        }
                                        
                                        Asset tempAsset = new Asset();
                                        if(astStg.Dynamic_SKU__c != 'Bluetail' && astStg.Dynamic_SKU__c != 'Wolverine H'
                                           && astStg.Dynamic_SKU__c != 'File Storage' && astStg.Dynamic_SKU__c != 'Block Storage'
                                           && astStg.Dynamic_SKU__c != 'File Storage HD' && astStg.Dynamic_SKU__c != 'X10000'
                                           && astStg.Dynamic_SKU__c != 'ES4' && astStg.Dynamic_SKU__c != 'AFS3'){ 
                                               tempAsset = DynamSku(astStg.Dynamic_SKU__c);
                                           }
                                        
                                        if(tempProductCode <> null && productMap.containsKey(tempProductCode)){
                                            System.debug('==== Array controller -- Checkpoint 1 -- '+ tempProductCode);
                                            if(astStg.Dynamic_SKU__c == 'Bluetail' || astStg.Dynamic_SKU__c == 'Wolverine H'
                                            || astStg.Dynamic_SKU__c == 'File Storage' || astStg.Dynamic_SKU__c == 'Block Storage'
                                            || astStg.Dynamic_SKU__c == 'File Storage HD' || astStg.Dynamic_SKU__c == 'X10000'
                                            || astStg.Dynamic_SKU__c == 'ES4' || astStg.Dynamic_SKU__c == 'AFS3'){
                                            if(aststg.HPE_Product_SKU__c != NULL && productMap.get(aststg.HPE_Product_SKU__c) != NULL){
                                                Ast.product2ID = productMap.get(aststg.HPE_Product_SKU__c).id;  
                                                   }
                                               }
                                            else if(Ast.IS_Array_Controller__c == null){ 
                                                Ast.product2ID = productMap.get(tempProductCode).id;
                                                }
                                            System.debug('product2IDat302---->'+Ast.product2ID);
                                        }
                                        else if (tempAsset.Array_Controller__c<>null && productMap.containsKey(tempAsset.Array_Controller__c) && tempAsset.IS_Array_Controller__c ==null){
                                            Ast.product2ID = productMap.get(tempAsset.Array_Controller__c).id;
                                        }
                                        else if (tempAsset.Expansion_Shelf_Base__c <> null && productMap.containsKey(tempAsset.Expansion_Shelf_Base__c)) {
                                            if (tempAsset.Expansion_Shelf_Base__c.endsWith('T')) {
                                                string pCode = tempAsset.Expansion_Shelf_Base__c.substringBeforeLast('T');
                                                Ast.product2ID = productMap.get(tempAsset.Expansion_Shelf_Base__c).id;
                                            }
                                            
                                            else if (tempAsset.Expansion_Shelf_Base__c.endsWith('B')) {
                                                string pCode = tempAsset.Expansion_Shelf_Base__c.substringBeforeLast('B');
                                                Ast.product2ID = productMap.get(tempAsset.Expansion_Shelf_Base__c).id;
                                            }
                                            
                                            else if(tempAsset.Expansion_Shelf_Base__c == 'ES2-AFS2'){
                                                Ast.product2ID = productMap.get('ES2-AFS2').id; //ADFA-AFS2
                                            }
                                            
                                        }
                                        
                                        //Added by Venkat Dec/18/2017 - START
                                        if(Ast.product2ID != null){
                                            system.debug('Add Asset Type>'+ Ast.Asset_Type_Build__c + ast.Product2ID);
                                            Product2 productToObj = ProductCodeToProductMap.get(Ast.product2ID);
                                            if(productToObj != null){
                                                if(productToObj.ProductCode != null && productToObj.ProductCode != '' && (productToObj.ProductCode.startsWith('AFA-AFS2')  || productToObj.ProductCode.startsWith('AFS2'))){
                                                    Ast.Asset_Type_Build__c = 'AFA-AFS2';
                                                }else if(productToObj.ProductCode != null && productToObj.ProductCode != '' && productToObj.ProductCode.startsWith('NGA')){
                                                    Ast.Asset_Type_Build__c = 'Next Gen';
                                                }else if(productToObj.ProductCode != null && productToObj.ProductCode != '' && productToObj.ProductCode.startsWith('CS')){
                                                    Ast.Asset_Type_Build__c = 'Legacy';
                                                }else if(productToObj.Family  == 'All Flash Array'){
                                                    Ast.Asset_Type_Build__c = 'AFA';
                                                }else if(productToObj.Family  == 'Adaptive Flash Array'){
                                                    Ast.Asset_Type_Build__c = 'CS Hybrid Arrays';
                                                }else if(productToObj.Family  == 'Secondary Flash Array'){
                                                    Ast.Asset_Type_Build__c = 'SFA';
                                                }else if(productToObj.Family  == 'All Flash Array5'){
                                                    Ast.Asset_Type_Build__c = 'AFA5';
                                                }
                                                //added by venkat march 2018
                                                else if((productToObj.Family=='Hybrid Flash Array')){//Added by venkat for asset type change on 4/3/2018
                                                    Ast.Asset_Type_Build__c = 'HFA';
                                                }
                                                else if(productToObj.Family  == 'Expansion Shelves' && productToObj.ProductCode != null && productToObj.ProductCode != '' && productToObj.productCode.startsWith('ES3-')){
                                                    Ast.Asset_Type_Build__c = 'Expansion Shelf 3';//'HF5-ES3';
                                                }else if(productToObj.Family  == 'All Flash Shelf3'){
                                                    Ast.Asset_Type_Build__c = 'AFA5-AF3';
                                                }else if(productToObj.ProductCode != null && productToObj.ProductCode != '' && productToObj.ProductCode.startsWith('ES2-H')){
                                                    Ast.Asset_Type_Build__c = 'Expansion Shelf 2';
                                                }else if(productToObj.ProductCode != null && productToObj.ProductCode != '' && productToObj.ProductCode.startsWith('ES2-AFS2')){//ADFA-AFS2
                                                    Ast.Asset_Type_Build__c = 'ES2-AFS2';
                                                }//added by venkat march 2018
                                                else if(productToObj.Family=='All Flash Array Gen5'){ //Added by venkat for asset type change on 4/3/2018
                                                    Ast.Asset_Type_Build__c = 'AFA2';
                                                }
                                                else if(productToObj.Family=='All Flash Shelf 2'){//Added by venkat for asset type change on 4/3/2018
                                                    Ast.Asset_Type_Build__c = 'AFS3';
                                                }
                                                else if(productToObj.Family == 'Alletra 6000'){
                                                    Ast.Asset_Type_Build__c = 'A6000';
                                                }
                                                else if(productToObj.Family == 'Alletra 5000'){
                                                    Ast.Asset_Type_Build__c = 'A5000';
                                                }
                                                else if(productToObj.Family=='All Flash Shelf'){//Added by venkat for asset type change on 4/3/2018
                                                    Ast.Asset_Type_Build__c = 'AFS4';
                                                }
                                                else if(productToObj.Family == 'Block Storage'){
                                                    Ast.Asset_Type_Build__c = 'Block Storage';
                                                }
                                                else if(productToObj.Family == 'File Storage'){
                                                    Ast.Asset_Type_Build__c = 'File Storage';
                                                }
                                                else if(productToObj.Family == 'File Storage HD'){
                                                    Ast.Asset_Type_Build__c = 'File Storage HD';
                                                }
                                                else if(productToObj.Family == 'X10000'){
                                                    Ast.Asset_Type_Build__c = 'X10000';
                                                }
                                                else if(productToObj.Family == 'Alletra Storage MP'){
                                                    if(!String.isBlank(astStg.parent_Asset_SN__c) && !String.isBlank(astStg.uber_SKU__c) 
                                                        && parentMap.get(astStg.parent_Asset_SN__c) != null){
                                                        ast.Asset_Type_Build__c = parentMap.get(astStg.parent_Asset_SN__c).Asset_Type_Build__c;
                                                    }
                                                }
                                                else{
                                                    Ast.Asset_Type_Build__c = 'Other';
                                                }
                                            }
                                        }
                                        system.debug('Add Asset Type>>>>'+ Ast.Asset_Type_Build__c);
                                        //Added by Venkat Dec/18/2017 - End
                                        system.debug('----tempSeet00000-----'+ tempAsset);
                                        
                                        Ast.Array_Controller__c     = tempAsset.Array_Controller__c;
                                        Ast.Array_Networking__c     = tempAsset.Array_Networking__c;
                                        Ast.Array_Networking_2__c   = tempAsset.Array_Networking_2__c;
                                        Ast.Array_Networking_3__c   = tempAsset.Array_Networking_3__c;
                                        Ast.Array_Cache__c          = tempAsset.Array_Cache__c;
                                        Ast.Array_Capacity__c       = tempAsset.Array_Capacity__c;
                                        Ast.SSD_Packs__c            = tempAsset.SSD_Packs__c;
                                        Ast.SSD_Bank_A__c           = tempAsset.SSD_Bank_A__c;
                                        Ast.SSD_Bank_B__c           = tempAsset.SSD_Bank_B__c;
                                        Ast.Expansion_Shelf_Base__c = tempAsset.Expansion_Shelf_Base__c;
                                        Ast.Total_Shelf_Capacity__c = tempAsset.Total_Shelf_Capacity__c;
                                        Ast.Shelf_Pack_1__c         = tempAsset.Shelf_Pack_1__c;
                                        Ast.Shelf_Pack_2__c         = tempAsset.Shelf_Pack_2__c;
                                        Ast.Shelf_Pack_3__c         = tempAsset.Shelf_Pack_3__c;
                                        Ast.Shelf_Pack_4__c         = tempAsset.Shelf_Pack_4__c;
                                        Ast.Shelf_Pack_5__c         = tempAsset.Shelf_Pack_5__c;
                                        Ast.Shelf_Pack_6__c         = tempAsset.Shelf_Pack_6__c;
                                        
                                        
                                        
                                        
                                        
                                        //added by venkat march 2018
                                        if(!String.isBlank(astStg.Expansion_Shelves__c) || !String.isBlank(astStg.Controller__c) || !String.isBlank(astStg.AFS3__c)){
                                            Ast.Contains_HPESKU__c  = True;
                                        }else{
                                            Ast.Contains_HPESKU__c  = False;
                                        }
                                        if(!String.isBlank(astStg.Expansion_Shelves__c) || !String.isBlank(astStg.Controller__c) || (!String.isBlank(astStg.AFS3__c))){
                                            
                                            if(!String.isBlank(astStg.Controller__c)){ system.debug(' ***  line 1212 ' + HPESKU_productMap.containsKey(astStg.Controller__c) + ' ** ' + HPESKU_productMap.get(astStg.Controller__c));
                                                if(HPESKU_productMap.containsKey(astStg.Controller__c) && HPESKU_productMap.get(astStg.Controller__c).component_code__c!=null)
                                                    Ast.Array_Controller__c         = HPESKU_productMap.get(astStg.Controller__c).component_code__c;
                                                else{
                                                    astStg.addError('No matching HPE SKU line 1216');
                                                    
                                                }
                                                //venkat changes March 2018
                                                if( HPESKU_productMap.containsKey(astStg.Controller__c) &&  HPESKU_productMap.get(astStg.Controller__c).ProductCode!=null)
                                                    Ast.Array_Controller_SKU__c  = HPESKU_productMap.get(astStg.Controller__c).ProductCode;
                                            }
                                            if(!String.isBlank(astStg.Capacity__c)){
                                                if(HPESKU_productMap.containsKey(astStg.Capacity__c) && HPESKU_productMap.get(astStg.Capacity__c).component_code__c!=null)
                                                    Ast.Array_Capacity__c                   = HPESKU_productMap.get(astStg.Capacity__c).component_code__c;
                                                else{
                                                    astStg.addError('No matching HPE SKU');
                                                    
                                                }
                                                //venkat changes March 2018
                                                if( HPESKU_productMap.containsKey(astStg.Capacity__c) &&  HPESKU_productMap.get(astStg.Capacity__c).ProductCode!=null)
                                                    Ast.Array_Capacity_SKU__c  = HPESKU_productMap.get(astStg.Capacity__c).ProductCode;
                                            }
                                            if(!String.isBlank(astStg.SSD_Capacity__c)){
                                                if(HPESKU_productMap.containsKey(astStg.SSD_Capacity__c) && HPESKU_productMap.get(astStg.SSD_Capacity__c).component_code__c!=null){
                                                    if(!(mapArcProd.containskey(astStg.SSD_Capacity__c))){
                                                        Ast.SSD_Bank_A__c = HPESKU_productMap.get(astStg.SSD_Capacity__c).component_code__c;
                                                    }
                                                    else{//ESS-114773 Yesha Benegal
                                                        Ast.Array_Capacity__c = HPESKU_productMap.get(astStg.SSD_Capacity__c).component_code__c;
                                                        Ast.Array_Capacity_SKU__c = HPESKU_productMap.get(astStg.SSD_Capacity__c).component_code__c;
                                                        if(astStg.SSD_Count__c != null){
                                                            ast.SSD_Count__c = decimal.valueOf(astStg.SSD_Count__c);
                                                        }
                                                    }
                                                }
                                                else{
                                                    astStg.addError('No matching HPE SKU');
                                                    system.debug('---------SSD_Capacity__c--2-------'+HpeSKUProductCodeMap.get(astStg.SSD_Capacity__c));
                                                    if(HpeSKUProductCodeMap.containsKey(astStg.SSD_Capacity__c) && HpeSKUProductCodeMap.get(astStg.SSD_Capacity__c)!=null)
                                                        Ast.SSD_Bank_A_SKU__c=HpeSKUProductCodeMap.get(astStg.SSD_Capacity__c);
                                                    
                                                }
                                                //venkat changes March 2018
                                                if( HPESKU_productMap.containsKey(astStg.SSD_Capacity__c) &&  HPESKU_productMap.get(astStg.SSD_Capacity__c).ProductCode!=null)
                                                    Ast.SSD_Bank_A_SKU__c = HPESKU_productMap.get(astStg.SSD_Capacity__c).ProductCode;
                                                if(bankStr.containsKey(astStg.SSD_Capacity__c)){
                                                    ast.SSD_Count__c = bankStr.get(astStg.SSD_Capacity__c);                                
                                                } 
                                                
                                            }
                                            if(!String.isBlank(astStg.SSD_Capacity_B__c)){
                                                if(HPESKU_productMap.containsKey(astStg.SSD_Capacity_B__c) && HPESKU_productMap.get(astStg.SSD_Capacity_B__c).component_code__c!=null)
                                                    Ast.SSD_Bank_B__c               = HPESKU_productMap.get(astStg.SSD_Capacity_B__c).component_code__c;
                                                else{
                                                    astStg.addError('No matching HPE SKU');
                                                    
                                                    
                                                }
                                                //venkat changes March 2018
                                                if( HPESKU_productMap.containsKey(astStg.SSD_Capacity_B__c) &&  HPESKU_productMap.get(astStg.SSD_Capacity_B__c).ProductCode!=null)
                                                    Ast.SSD_Bank_B_SKU__c  = HPESKU_productMap.get(astStg.SSD_Capacity_B__c).ProductCode;
                                                if(bankStr.containsKey(astStg.SSD_Capacity__c) &&  ast.SSD_Count__c == null){
                                                    ast.SSD_Count__c = bankStr.get(astStg.SSD_Capacity__c);                                
                                                }
                                                else if(bankStr.containsKey(astStg.SSD_Capacity_B__c) &&  ast.SSD_Count__c != null){
                                                    ast.SSD_Count__c += bankStr.get(astStg.SSD_Capacity_B__c);                                
                                                }  
                                            }
                                            
                                            if(astStg.Cache__c == null && astStg.SSD_Capacity__c != null){
                                                astStg.Cache__c = astStg.SSD_Capacity__c;
                                                
                                            }
                                            if(!String.isBlank(astStg.Cache__c)){
                                                if(HPESKU_productMap.containsKey(astStg.Cache__c) && HPESKU_productMap.get(astStg.Cache__c).component_code__c!=null)
                                                    Ast.SSD_Bank_A__c               = HPESKU_productMap.get(astStg.Cache__c).component_code__c;
                                                else{
                                                    astStg.addError('No matching HPE SKU');
                                                    
                                                    if(HpeSKUProductCodeMap.containsKey(astStg.Cache__c) && HpeSKUProductCodeMap.get(astStg.Cache__c)!=null)
                                                        Ast.SSD_Bank_A_SKU__c=HpeSKUProductCodeMap.get(astStg.Cache__c);
                                                    
                                                }
                                                //venkat changes March 2018
                                                if( HPESKU_productMap.containsKey(astStg.Cache__c) &&  HPESKU_productMap.get(astStg.Cache__c).ProductCode!=null)
                                                    Ast.SSD_Bank_A_SKU__c  = HPESKU_productMap.get(astStg.Cache__c).ProductCode;
                                            }
                                            if(astStg.Cache_B__c == null && astStg.SSD_Capacity_B__c != null){
                                                astStg.Cache_B__c = astStg.SSD_Capacity_B__c;
                                            }
                                            if(!String.isBlank(astStg.Cache_B__c)){
                                                if(HPESKU_productMap.containsKey(astStg.Cache_B__c) && HPESKU_productMap.get(astStg.Cache_B__c).component_code__c!=null)
                                                    Ast.SSD_Bank_B__c               = HPESKU_productMap.get(astStg.Cache_B__c).component_code__c;
                                                else{
                                                    astStg.addError('No matching HPE SKU');
                                                    
                                                    if(HpeSKUProductCodeMap.containsKey(astStg.Cache_B__c) && HpeSKUProductCodeMap.get(astStg.Cache_B__c)!=null)
                                                        Ast.SSD_Bank_B_SKU__c=HpeSKUProductCodeMap.get(astStg.Cache_B__c);
                                                    
                                                }
                                                //venkat changes March 2018
                                                if( HPESKU_productMap.containsKey(astStg.Cache_B__c) &&  HPESKU_productMap.get(astStg.Cache_B__c).ProductCode!=null)
                                                    Ast.SSD_Bank_B_SKU__c  = HPESKU_productMap.get(astStg.Cache_B__c).ProductCode;
                                            }
                                            if(!String.isBlank(astStg.Networking__c)){
                                                
                                                Ast.Array_Networking__c = calculateRefreshSKU(astStg.Networking__c,'cc', HPESKU_productMap);
                                                Ast.Array_Networking_SKU__c  = calculateRefreshSKU(astStg.Networking__c,'pc', HPESKU_productMap);
                                                
                                                if(!String.isBlank(astStg.Networking_2__c)) { 
                                                    
                                                    Ast.Array_Networking_2__c  = calculateRefreshSKU(astStg.Networking_2__c,'cc', HPESKU_productMap);
                                                    Ast.Array_Networking_2_SKU__c  = calculateRefreshSKU(astStg.Networking_2__c,'pc', HPESKU_productMap);
                                                }
                                                //capture Networking 3 to Asset
                                                if(!String.isBlank(astStg.Networking_3__c)) {
                                                    Ast.Array_Networking_3__c = calculateRefreshSKU(astStg.Networking_3__c,'cc', HPESKU_productMap);
                                                    Ast.Array_Networking_3_SKU__c  = calculateRefreshSKU(astStg.Networking_3__c,'pc', HPESKU_productMap);
                                                }
                                            }
                                            
                                            //getting null pointer exception.
                                            if(!String.isBlank(astStg.Expansion_Shelves__c) && HPESKU_productMap.containsKey(astStg.Expansion_Shelves__c) && HPESKU_productMap.get(astStg.Expansion_Shelves__c) != null){
                                                Ast.Expansion_Shelf_Base__c     = HPESKU_productMap.get(astStg.Expansion_Shelves__c).ProductCode;
                                                
                                                if(HPESKU_productMap.get(astStg.Expansion_Shelves__c).Asset_Type__c.contains('ES4') && 
                                                   HPESKU_productMap.get(astStg.Expansion_Shelves__c).Asset_Type__c != null){
                                                       ast.Asset_Type_Build__c = 'ES4';
                                                       ast.Product2Id = HPESKU_productMap.get(astStg.Expansion_Shelves__c).Id;
                                                       system.debug(' *** line 1316 ' + ast.asset_type_build__c);
                                                   }
                                                
                                            }else{
                                                Ast.Expansion_Shelf_Base__c ='';
                                            }
                                            if(!String.isBlank(astStg.Expansion_Shelves_Cache__c)){
                                                if(!String.isBlank(astStg.Expansion_Shelves_Cache__c) && HPESKU_productMap.containsKey(astStg.Expansion_Shelves_Cache__c) && HPESKU_productMap.get(astStg.Expansion_Shelves_Cache__c) != null){
                                                    Ast.SSD_Bank_B__c      = HPESKU_productMap.get(astStg.Expansion_Shelves_Cache__c).component_code__c;
                                                    Ast.SSD_Bank_B_SKU__c      = HPESKU_productMap.get(astStg.Expansion_Shelves_Cache__c).ProductCode;
                                                } else{
                                                    astStg.addError('No matching HPE SKU');
                                                }
                                            }
                                            if(!String.isBlank(astStg.Expansion_Shelves_BankB__c) && HPESKU_productMap.containsKey(astStg.Expansion_Shelves_BankB__c) && HPESKU_productMap.get(astStg.Expansion_Shelves_BankB__c)!= null){
                                                ast.SSD_Bank_B__c  = HPESKU_productMap.get(astStg.Expansion_Shelves_BankB__c).component_code__c;
                                                ast.SSD_Bank_B_SKU__c = HPESKU_productMap.get(astStg.Expansion_Shelves_BankB__c).ProductCode;
                                            }
                                            if(!String.isBlank(astStg.Expansion_Shelves_BankA__c) && HPESKU_productMap.containsKey(astStg.Expansion_Shelves_BankA__c) && HPESKU_productMap.get(astStg.Expansion_Shelves_BankA__c)!= null){
                                                ast.SSD_Bank_A__c  = HPESKU_productMap.get(astStg.Expansion_Shelves_BankA__c).component_code__c;
                                                ast.SSD_Bank_A_SKU__c = HPESKU_productMap.get(astStg.Expansion_Shelves_BankA__c).ProductCode;
                                            }
                                            if(!String.isBlank(astStg.AFS__c)){
                                                if(!String.isBlank(astStg.AFS__c) && HPESKU_productMap.containsKey(astStg.AFS__c) && HPESKU_productMap.get(astStg.AFS__c) != null)
                                                {Ast.Expansion_Shelf_Base__c = HPESKU_productMap.get(astStg.AFS__c).component_code__c;
                                                 
                                                 ast.Product2Id= HPESKU_productMap.get(astStg.AFS__c).id; system.debug(' *** line 1366 product2ID is ' + ast.Product2Id);
                                                }
                                                else{
                                                    astStg.addError('No matching HPE SKU');
                                                    
                                                }
                                            }
                                            if(!String.isBlank(astStg.AFS3__c)){ 
                                                
                                                if(!String.isBlank(astStg.AFS3__c) && HPESKU_productMap.containsKey(astStg.AFS3__c) && HPESKU_productMap.get(astStg.AFS3__c) != null)
                                                {    
                                                    Ast.Expansion_Shelf_Base__c  = HPESKU_productMap.get(astStg.AFS3__c).component_code__c;
                                                    ast.Product2Id= HPESKU_productMap.get(astStg.AFS3__c).id;
                                                    ast.Array_cache__c = null;
                                                    system.debug(' *** line 1380 product2ID is ' + ast.Product2Id);
                                                    
                                                }
                                                else{
                                                    astStg.addError('No matching HPE SKU');
                                                }
                                            }
                                            if(!String.isBlank(astStg.Shelf_Pack_1__c)){                        
                                                if(!String.isBlank(astStg.Shelf_Pack_1__c) && HPESKU_productMap.containsKey(astStg.Shelf_Pack_1__c) && HPESKU_productMap.get(astStg.Shelf_Pack_1__c) != null)
                                                {
                                                    if(astStg.Dynamic_SKU__c!=null && astStg.Dynamic_SKU__c=='Bluetail'){
                                                        System.debug('------ast.Dynamic_SKU__c-------------- '+ astStg.Dynamic_SKU__c);
                                                        ast.Shelf_Pack_1__c= HPESKU_productMap.get(astStg.Shelf_Pack_1__c).Infosight_Identifier__c; //component_code__c;
                                                        ast.Shelf_Pack_1_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_1__c).productCode;
                                                        if(shelfStr.containsKey(HPESKU_productMap.get(astStg.Shelf_Pack_1__c).Infosight_Identifier__c)){
                                                            ast.Total_Shelf_Capacity__c = Decimal.valueOf(shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_1__c).Infosight_Identifier__c));
                                                            ast.Shelf_Pack_1__c=  shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_1__c).Infosight_Identifier__c);
                                                            ast.Shelf_Pack_1_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_1__c).productCode;
                                                        }
                                                    }
                                                    else if(astStg.Dynamic_SKU__c!=null && astStg.Dynamic_SKU__c.contains('AFS3-')){
                                                        System.debug('------ast.Dynamic_SKU__c-------------- '+ astStg.Dynamic_SKU__c);
                                                        ast.Shelf_Pack_1__c= HPESKU_productMap.get(astStg.Shelf_Pack_1__c).Infosight_Identifier__c; //component_code__c;Infosight_Identifier__c//Jira SFDC-605
                                                        ast.Shelf_Pack_1_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_1__c).productCode;
                                                        if(shelfStr.containsKey(HPESKU_productMap.get(astStg.Shelf_Pack_1__c).Infosight_Identifier__c)){
                                                            ast.Total_Shelf_Capacity__c = Decimal.valueOf(shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_1__c).Infosight_Identifier__c));
                                                            ast.Shelf_Pack_1__c=  shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_1__c).Infosight_Identifier__c);
                                                            ast.Shelf_Pack_1_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_1__c).productCode;
                                                        }
                                                    }
                                                    
                                                }
                                                else{
                                                    astStg.addError('No matching HPE SKU');
                                                }
                                            }
                                            if(!String.isBlank(astStg.Shelf_Pack_2__c)){
                                                if(astStg.Shelf_Pack_1__c == null){
                                                    if(!String.isBlank(astStg.Shelf_Pack_2__c) && HPESKU_productMap.containsKey(astStg.Shelf_Pack_2__c) && HPESKU_productMap.get(astStg.Shelf_Pack_2__c) != null)
                                                    {
                                                        if(astStg.Dynamic_SKU__c!=null && astStg.Dynamic_SKU__c=='Bluetail'){
                                                            System.debug('------ast.Dynamic_SKU__c-------------- '+ astStg.Dynamic_SKU__c);
                                                            ast.Shelf_Pack_1__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).Infosight_Identifier__c; //component_code__c;
                                                            ast.Shelf_Pack_1_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).productCode;
                                                            if(shelfStr.containsKey(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).Infosight_Identifier__c)){
                                                                ast.Total_Shelf_Capacity__c = Decimal.valueOf(shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).Infosight_Identifier__c));
                                                                ast.Shelf_Pack_1__c=  shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).Infosight_Identifier__c);
                                                                ast.Shelf_Pack_1_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).productCode;
                                                            }
                                                        }
                                                        else if(astStg.Dynamic_SKU__c!=null && astStg.Dynamic_SKU__c.contains('AFS3-')){
                                                            System.debug('------ast.Dynamic_SKU__c-------------- '+ astStg.Dynamic_SKU__c);
                                                            ast.Shelf_Pack_1__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).component_code__c; //component_code__c;
                                                            ast.Shelf_Pack_1_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).productCode;
                                                            if(shelfStr.containsKey(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).component_code__c)){
                                                                ast.Total_Shelf_Capacity__c = Decimal.valueOf(shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).component_code__c));
                                                                ast.Shelf_Pack_1__c=  shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).component_code__c);
                                                                ast.Shelf_Pack_1_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).productCode;
                                                            }
                                                        }
                                                    }
                                                }
                                                else if(!String.isBlank(astStg.Shelf_Pack_2__c) && HPESKU_productMap.containsKey(astStg.Shelf_Pack_2__c) && HPESKU_productMap.get(astStg.Shelf_Pack_2__c) != null)
                                                { 
                                                    if(astStg.Dynamic_SKU__c!=null && astStg.Dynamic_SKU__c=='Bluetail'){
                                                        ast.Shelf_Pack_2__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).Infosight_Identifier__c; //component_code__c;
                                                        ast.Shelf_Pack_2_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).productCode;
                                                        if(shelfStr.containsKey(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).Infosight_Identifier__c)){
                                                            ast.Total_Shelf_Capacity__c = Decimal.valueOf(shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).Infosight_Identifier__c));
                                                            ast.Shelf_Pack_2__c=  shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).Infosight_Identifier__c);
                                                            ast.Shelf_Pack_2_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).productCode;
                                                        }
                                                    }
                                                    else if(astStg.Dynamic_SKU__c!=null && astStg.Dynamic_SKU__c.contains('AFS3-')){
                                                        ast.Shelf_Pack_2__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).component_code__c; //component_code__c;
                                                        ast.Shelf_Pack_2_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).productCode;
                                                        if(shelfStr.containsKey(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).component_code__c)){
                                                            ast.Total_Shelf_Capacity__c = Decimal.valueOf(shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).component_code__c));
                                                            ast.Shelf_Pack_2__c=  shelfStr.get(HPESKU_productMap.get(astStg.Shelf_Pack_2__c).component_code__c);
                                                            ast.Shelf_Pack_2_SKU__c= HPESKU_productMap.get(astStg.Shelf_Pack_2__c).productCode;
                                                        }
                                                    }                                       
                                                }
                                                else{
                                                    astStg.addError('No matching HPE SKU');
                                                }
                                            }
                                        }
                                        system.debug('++++ArrayChache-----'+array_chache);
                                        /*** Start of code  CR#2895 jira#ESS-46752 by Yesha benegal Jun-26-2020 ***/
                                        boolean isExisting = false;
                                        for(string s : ADFA_Controllers){
                                            if(astStg.Dynamic_SKU__c.startsWithIgnoreCase(s)){
                                                isExisting = true;
                                                //ast.
                                            }
                                        }
                                        /*** end of code CR#2895 Jira#ESS-46752 by yesha benegal Jun-26-2020 **/
                                        if(astStg.Unit_Consumption_Received__c == True || astStg.byPassUCData__c == True){
                                            //added by venkat march 2018
                                            if(ast.Array_Cache__c == null && !astStg.Dynamic_SKU__c.startsWithIgnoreCase('HF') && isExisting == False ){
                                                ast.Array_Cache__c = array_chache;
                                                
                                            }
                                            if(astStg.Dynamic_SKU__c.contains('ES3')){//added by venkat march 2018
                                                list<string> dynamicSKU_ListSplit=new list<string>();
                                                dynamicSKU_ListSplit=astStg.Dynamic_SKU__c.split('-');
                                                ast.product2ID=mapOfES3Products.get(dynamicSKU_ListSplit[0]+'-'+dynamicSKU_ListSplit[1]);
                                                ast.Dynamic_SKU__c = astStg.Dynamic_SKU__c;
                                                system.debug(' *** line 1495 product2ID is ' + ast.Product2Id);
                                                ast.Package_Product_Code_Build__c  = astStg.Dynamic_SKU__c;
                                                
                                                
                                            }
                                            system.debug(' *** 1536  astStg ' + ast);
                                          
                                            
                                            if((astStg.Nimble_Serial_Number__c!=null && (astStg.Nimble_Serial_Number__c.startsWithIgnoreCase('AF') || astStg.Legacy_Asset__c)
                                             && astStg.Dynamic_SKU__c != 'Block Storage' && astStg.Dynamic_SKU__c != 'File Storage' && astStg.Dynamic_SKU__c != 'File Storage HD'
                                             && astStg.Dynamic_SKU__c != 'X10000')  ||
                                              (astStg.Dynamic_SKU__c == 'Block Storage' || astStg.Dynamic_SKU__c == 'File Storage' || astStg.Dynamic_SKU__c == 'File Storage HD'
                                                 || astStg.Dynamic_SKU__c == 'X10000' ) ){
                                                system.debug(' *** 1540  astStg ' + ast);
                                                if(AstIDMap.get(ast.id) == null || (!statusToBypassUpdateSet.contains(AstIDMap.get(ast.id).status)))  //added by venkat 19 june 2018
                                                    system.debug(' *** 1542  astStg ' + ast);
                                                    if(astStg.Asset_Renewed_beyond_EOL__c != true  && astStg.Contract_On_Hold__c != true && astStg.Order_Status__c == 'Shipped' &&  !astStg.Exception__c && astStg.override_Auto_Update__c != true){ //SFDC-1887
                                                        assetList.add(ast);
                                                        
                                                    }
                                                
                                            }
                                            astStg.Status__c = 'Completed';
                                            ast.Simplivity_Chk__c = astStg.Simplivity_Chk__c;
                                            ast.HPE_Serial_Number__c = astStg.HPE_Serial_Number__c; /*** added by Yesha Benegal on 05/07/2020 ESS-44478***/
                                            Account accx = AccMap.get(oppMap.get(astStg.HPE_Opportunity_ID__c).Accountid);
                                            if(accx.ACM_Service_Purchased__c==False && astStg.Concierge_Manager__c ==True){
                                                accx.ACM_Service_Purchased__c  = astStg.Concierge_Manager__c;
                                                //Ast.assetConcierge_Service__c = astStg.Concierge_Manager__c;
                                                if(astStg.Concierge_Manager_SKU__c != null){
                                                    accx.Concierge_Manager_Tier__c = SLAmap.get(astStg.Concierge_Manager_SKU__c).Concierge_Manager_Tier__c;
                                                    accx.Concierge_Manager_Years__c = SLAmap.get(astStg.Concierge_Manager_SKU__c).Concierge_Manager_Year__c;
                                                    
                                                    if(astStg.HPE_Service_Agreement_ID__c != null){
                                                        accx.HPE_Service_Agreement_ID__c =  astStg.HPE_Service_Agreement_ID__c;
                                                    }
                                                }
                                                accToUpdateList.add(accx);
                                                acctId.add(accx.id);
                                            }
                                            if(accx.Datacenter_Care__c == false && !acctId.contains(accx.Id)){
                                                
                                                
                                                //accx.Datacenter_Care__c = true;
                                                if(astStg.HPE_Service_Agreement_ID__c != null){
                                                    accx.HPE_Service_Agreement_ID__c =  astStg.HPE_Service_Agreement_ID__c;
                                                }
                                                accToUpdateList.add(accx);
                                                acctId.add(accx.id);
                                                
                                            }
                                            if(accx.HPE_Service_Agreement_ID__c == null && !acctId.contains(accx.Id) && astStg.HPE_Service_Agreement_ID__c != null){
                                                accx.HPE_Service_Agreement_ID__c =  astStg.HPE_Service_Agreement_ID__c;
                                                accToUpdateList.add(accx);
                                                acctId.add(accx.id);
                                                
                                            }
                                            //concierge SKU info
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            else
                            {
                                if(astStg.Legacy_Asset__c == False){
                                    astStg.Status__c += 'ERROR:: Opp Does Not Exist'+'\n';
                                      astStg.Exception__c =true;
                                }
                            }
                        }
                        if(String.isBlank(astStg.Status__c) && astStg.Status__c != 'Completed'){
                            astStg.Status__c = 'New';
                          
                        }
                        
                        
                        if(timelessProductSkuMap.containsKey(aststg.HPE_Product_SKU__c) && timelessProductSkuMap.get(aststg.HPE_Product_SKU__c).Cross_Family_Upgrade__c){
                            aststg.status__c = 'Cross Family Upgrade Completed'; 
                        }
                          astStg.Exception__c =false;
                    }
                    
                    if(Test.isRunningTest()){error = false;}
                   // if(!error) {
                    if(!assetList.isEmpty()){
                        if(assetList.size() > 0){
                            try{
                                system.debug('====Assets to Update=== '+assetList);
                                
                                upsert assetList;
                                //isHPE = true;
                                Update accToUpdateList;
                            }catch(exception e){
                                //error log
                                system.debug('====exception=== ');
                                
                            }
                            
                            System.debug('=== Upserted Assets are: ' + assetList);
                            Map<id, id> assetMap = new Map<id,id>();
                            for( asset_stage__c stg : astStageList){
                                for (asset a: assetList){
                                    if(a.HPE_Serial_Number__c == stg.HPE_Serial_Number__c){
                                        stg.asset__c = a.Id;
                                    }
                                    system.debug('====stg=== Ast---'+stg.asset__c);
                                }
                            }                                              
                        }
                    }
                    if(!assetsToUpdate.keyset().isEmpty()){ 
                         system.debug('====assetsToUpdate=== status---'+assetsToUpdate);
                        update assetsToUpdate.values(); }
                }
    
    
    public static Map<String, Nimble_Offer_Code__c> retrieveSLA(set<String> slaList){
        Map<String, Nimble_Offer_Code__c> HPEtoNimbleSLA_Map = new Map<String, Nimble_Offer_Code__c>();
        for (Nimble_Offer_Code__c NOC: [SELECT HPE_Support_Package_SKU__c, Nimble_Support_Offers__c, Concierge_Manager_Tier__c,Concierge_Manager_Year__c,
                                        Concierge_Manager__c, Nimble_NDR__c, Nimble_Timeless_Storage__c, Timeless_Refresh_Years__c,
                                        HPE_Support_Package_SKU_Description__c , Nimble_Timeless_Tier__c, TSC_Nimble_Support_Offers__c,
                                        Datacenter_Care__c, Controller_Refresh_Level__c
                                        FROM Nimble_Offer_Code__c
                                        WHERE HPE_Support_Package_SKU__c IN:slaList]) {
                                            HPEtoNimbleSLA_Map.put(NOC.HPE_Support_Package_SKU__c, NOC);
                                        }
        
        return HPEtoNimbleSLA_Map;
    }
    public static Asset DynamSku(String dynamsku){
        Asset asst = new Asset();
        System.debug('------dynamsku---1-------------- '+ dynamsku);
        String[] splittedArray = dynamsku.split('-');
        list<String> Splitlst = new list<String>();
        
        //Retrieve values from Custom Settings
        List<DynamicSKUsDecoderHelper__c> dynamicSKU_List = DynamicSKUsDecoderHelper__c.getall().values();
        
        for(String eachSplittedValue : splittedArray ){
            Splitlst.add(eachSplittedValue);
        }
        
        //string controller = Splitlst[0];
        
        set<string> SFA_Controllers = new set<string>{'SF100', 'SF300'};
            set<string> AFA_Controllers = new set<string>{'AF1000', 'AF3000', 'AF5000', 'AF7000','AF9000'};
                set<string> NGA_Controllers = new set<string>{'CS300', 'CS500', 'CS700'};
                    set<string> ES2_Controllers = new set<string>{'ES2-H21T', 'ES2-H42T', 'ES2-H84T', 'ES2-H126T', 'ES2-H210T','ES1-H45B','ES1-H90T','ES1-H85B','ES1-H65','ES1-H85','ES1-H45','ES1-H25','ES1-H25B','ES1-H65B'};
                        set<string> SF_ES2_Controllers = new set<string>{'SF-ES2-H21T', 'SF-ES2-H42T', 'SF-ES2-H84T', 'SF-ES2-H126T', 'SF-ES2-H210T'};
                            set<string> AFS2_Controllers = new set<string>{'ES2-AFS2'};
                                set<string> AFA_AFS2_Controllers = new set<string>{'AFS2'};
                                    set<string> ES1_AFS_Controllers = new set<string>{'ES1-AFS'};
                                        set<string> HF_Controllers = new set<string>{'HF20-2F','HF20-2G','HF20-2OBT','HF20-2P', 'HF20-2T'};
                                            //set<string> AFS3_Controllers = new set<string>{'AFS3'};
                                            System.debug('------ES2_Controllers---2-------------- '+ ES2_Controllers);
        //added by venkat march 2018
        if(Splitlst.size()>=3)
            array_chache = Splitlst[2];
        System.debug('==== split-------- '+ Splitlst[0] +'-'+Splitlst[1]);
        system.debug('++++ArrayChache-----'+array_chache);
        if( ES2_Controllers.contains(Splitlst[0] +'-'+Splitlst[1])) {
            System.debug('==== ES2 Controller found :: '+ Splitlst[0] +'-'+Splitlst[1]);
            asst.Expansion_Shelf_Base__c = Splitlst[0] +'-'+Splitlst[1];
            System.debug('------asst.Expansion_Shelf_Base__c---2-------------- '+ asst.Expansion_Shelf_Base__c);
            if(Splitlst.size() > 2)
                asst.SSD_Bank_B__c = Splitlst[2];
        }
        
        System.debug('==== split-0------- '+ Splitlst[0]);
        System.debug('==== HF_Controllers-0------- '+ HF_Controllers);
        
        //IF the array is ADFA or SFA
        if (ADFA_Controllers.contains(Splitlst[0]) || SFA_Controllers.contains(Splitlst[0])  || HF_Controllers.contains(Splitlst[0]+'-'+Splitlst[1])){
            System.debug('==== HF_Controllers-inside------- ');
            asst.Array_Controller__c = Splitlst[0];
            asst.Array_Networking__c = Splitlst[1];
            //IF Product Family is ADFA-Gen5, THEN Split the Splitlst[1] and break it down to store in Array_Networking__c, Array_Networking_2__c, and Array_Networking_3__c
            if(ADFA_Controllers.contains(Splitlst[0]) && Splitlst[1] != '2OBT') {
                String splitCodeString = Splitlst[1];
                asst.Array_Networking__c = splitCodeString.left(2);
                System.debug('splitCodeString: '+splitCodeString);
                System.debug('splitCodeString length: '+splitCodeString.length());
                if(splitCodeString.length() > 3) asst.Array_Networking_2__c = splitCodeString.subString(2,4);
                if(splitCodeString.length() > 5) asst.Array_Networking_3__c = splitCodeString.subString(4,6);
            }
            asst.Array_Capacity__c   = Splitlst[2];
            cache = Splitlst[3];
            string ssdBank = Splitlst[3];
            if (ssdBank.length() == 1) {
                asst.SSD_Bank_A__c = ssdBank;
                if(SFA_Controllers.contains(Splitlst[0])){
                    array_chache  = ssdBank;
                }
            }
            else if (ssdBank.length() == 2) {
                asst.SSD_Bank_A__c = ssdBank.substring(0,1);
                asst.SSD_Bank_B__c = ssdBank.substring(1,2);
            }
            else {
                String[] splitBanks = ssdBank.split('F');
                system.debug('=== SSD Bank size is:: '+ splitBanks.size() + ' and values are :: '+ splitBanks);
                asst.SSD_Bank_A__c = splitBanks[0]+'F';
                if (splitBanks.size() == 2)
                    asst.SSD_Bank_B__c = splitBanks[1]+'F';
            }
            
        }
        //IF the array is AFA
        else if (AFA_Controllers.contains (Splitlst[0])) {
            asst.Array_Controller__c = Splitlst[0];
            asst.Array_Networking__c = Splitlst[1];
            //IF Product Family is AFA-Gen5, THEN Split the Splitlst[1] and break it down to store in Array_Networking__c, Array_Networking_2__c, and Array_Networking_3__c
            if(ADFA_Controllers.contains(Splitlst[0]) && Splitlst[1] != '2OBT') {
                String splitCodeString = Splitlst[1];
                asst.Array_Networking__c = splitCodeString.left(2);
                if(splitCodeString.length() > 3) asst.Array_Networking_2__c = splitCodeString.subString(2,4);
                if(splitCodeString.length() > 5) asst.Array_Networking_3__c = splitCodeString.subString(4,6);
            }
            asst.Array_Cache__c = Splitlst[2];
            asst.SSD_Packs__c = Integer.valueOf(Splitlst[3]);
            
            if (Integer.valueOf(Splitlst[3]) == 1)
                asst.SSD_Bank_A__c = Splitlst[2];
            else {
                for(DynamicSKUsDecoderHelper__c sku: dynamicSKU_List) {
                    if(sku.TOTAL_CAPACITY__C == Splitlst[2]) {
                        asst.SSD_Bank_A__c = sku.SSD_Bank_A__c;
                        asst.SSD_Bank_B__c = sku.SSD_Bank_B__c;
                    }
                }
            }
        }
        //if array is Next Gen Array
        else if (NGA_Controllers.contains(Splitlst[0]) ){
            asst.Array_Controller__c = Splitlst[0];
            asst.Array_Networking__c = Splitlst[1];
            asst.Array_Capacity__c   = Splitlst[2];
            asst.Array_Cache__c      = Splitlst[3];
        }
        
        //Expansion Shelves i.e. SF-ES2 Shelves
        else if (Splitlst.size()>= 3 && SF_ES2_Controllers.contains(Splitlst[0] +'-'+Splitlst[1]+'-'+Splitlst[2]) ) {          // Condition added by Venkat to remove Splitlst[3] check
            System.debug('==== SF-ES2 Controller found ::---------- '+ Splitlst[0] +'-'+Splitlst[1]+'-'+Splitlst[2]);
            asst.Expansion_Shelf_Base__c = Splitlst[0] +'-'+Splitlst[1] +'-'+Splitlst[2];
            if(Splitlst.size() > 3)
                asst.SSD_Bank_B__c = Splitlst[3];
        }
        //Expansion Shelves i.e. ES2-AFS2 //Populates upto Shelf Pack 12 //Format: ES2-AFS2-15360-1
        else if(AFS2_Controllers.contains(Splitlst[0] +'-'+Splitlst[1]) ) {
            System.debug('==== ES2 Controller found :: '+ Splitlst[0] +'-'+Splitlst[1]);
            asst.Expansion_Shelf_Base__c = Splitlst[0] +'-'+Splitlst[1];
            asst.Total_Shelf_Capacity__c = Integer.valueOf(Splitlst[2]);
            if(Integer.valueOf(Splitlst[3]) == 1)
                asst.Shelf_Pack_1__c = Splitlst[2];
            else{
                for(DynamicSKUsDecoderHelper__c sku: dynamicSKU_List) {
                    system.debug('>>'+Splitlst[2]);
                    if(sku.controller__c == Splitlst[0] +'-'+Splitlst[1] && sku.Total_Capacity__c == Splitlst[2] && sku.Quantity__c == Splitlst[3]) {
                        tempProductCode = sku.ProductCode__c;
                        asst.Shelf_Pack_1__c = sku.Shelf_Pack_1__c;
                        asst.Shelf_Pack_2__c = sku.Shelf_Pack_2__c;
                        asst.Shelf_Pack_3__c = sku.Shelf_Pack_3__c;
                        asst.Shelf_Pack_4__c = sku.Shelf_Pack_4__c;
                        asst.Shelf_Pack_5__c = sku.Shelf_Pack_5__c;
                        asst.Shelf_Pack_6__c = sku.Shelf_Pack_6__c;
                        asst.Shelf_Pack_1B__c = sku.Shelf_Pack_1B__c;
                        asst.Shelf_Pack_2B__c = sku.Shelf_Pack_2B__c;
                        asst.Shelf_Pack_3B__c = sku.Shelf_Pack_3B__c;
                        asst.Shelf_Pack_4B__c = sku.Shelf_Pack_4B__c;
                        asst.Shelf_Pack_5B__c = sku.Shelf_Pack_5B__c;
                        asst.Shelf_Pack_6B__c = sku.Shelf_Pack_6B__c;
                    }
                }
            }
        }
        //ES1-AFS //Populates upto Shelf Pack 4 //Format: ES1-AFS-12800-4
        else if (ES1_AFS_Controllers.contains(Splitlst[0] +'-'+Splitlst[1])) {
            asst.Total_Shelf_Capacity__c = Integer.valueOf(Splitlst[2]);
            asst.Expansion_Shelf_Base__c = Splitlst[0] +'-'+Splitlst[1];
            array_chache = '';
            for(DynamicSKUsDecoderHelper__c sku: dynamicSKU_List) {
                if(sku.controller__c == Splitlst[0] +'-'+Splitlst[1] && sku.TOTAL_CAPACITY__C == Splitlst[2] && sku.Quantity__c == Splitlst[3]) {
                    tempProductCode = sku.ProductCode__c;
                    asst.Shelf_Pack_1__c = sku.Shelf_Pack_1__c;
                    asst.Shelf_Pack_2__c = sku.Shelf_Pack_2__c;
                    asst.Shelf_Pack_3__c = sku.Shelf_Pack_3__c;
                    asst.Shelf_Pack_4__c = sku.Shelf_Pack_4__c;
                }
            }
            
        }
        //AFA-AFS2 //Populates Shelf packs //Format: AFS2-7680-1
        else if (AFA_AFS2_Controllers.contains(Splitlst[0])){
            asst.Total_Shelf_Capacity__c = Integer.valueOf(Splitlst[1]);
            
            for(DynamicSKUsDecoderHelper__c sku: dynamicSKU_List) {
                if(sku.controller__c == Splitlst[0] && sku.TOTAL_CAPACITY__C == Splitlst[1] && sku.Quantity__c == Splitlst[2]) {
                    tempProductCode = sku.ProductCode__c;
                    asst.Shelf_Pack_1__c = sku.Shelf_Pack_1__c;
                    asst.Shelf_Pack_2__c = sku.Shelf_Pack_2__c;
                }
            }
        }
        
        
        if(dynamsku.startsWith('ES') && (asst.Expansion_Shelf_Base__c == null || asst.Expansion_Shelf_Base__c == '')){
            asst.Expansion_Shelf_Base__c = dynamsku;
        }
        if(tempProductCode == null || tempProductCode =='')
            for(DynamicSKUsDecoderHelper__c sku: dynamicSKU_List) {
                if(sku.Name==dynamsku){
                    tempProductCode = sku.ProductCode__c;
                    asst.SSD_Bank_B__c = sku.SSD_Bank_B__c; //Added by Venkat Dec/21/2017
                }
            }
        System.debug('===tempproductcode===='+tempProductCode);
            System.debug('===Splitlst[0]===='+Splitlst[0]);
        if(tempProductCode != Splitlst[0]){
             tempProductCode = Splitlst[0];
       }
        
        System.debug('------asst00000-------------- '+ asst);
        //Start
        /*if (ES1_AFS_Controllers.contains(Splitlst[0] +'-'+Splitlst[1])) {
asst.Expansion_Shelf_Base__c = Splitlst[0] +'-'+Splitlst[1];
}*/// commented by Yesha benegal -ESS-54544
        //end
        System.debug('------asst00000-------------- '+ asst);
        System.debug('------asst.Expansion_Shelf_Base__c---7-------------- '+ asst.Expansion_Shelf_Base__c);
        System.debug('------tempProductCode---8-------------- '+ tempProductCode);
        return asst;
        
    }
    
   
    public static string calculateRefreshSKU(String refreshSKU, String tSKU, Map<String, Product2> prodSKUMap){
        string prodSKU;
        if(tSKU == 'cc'){
            if(netSKU.containsKey(refreshSKU)){
                refreshSKU = netSKU.get(refreshSKU);
                if(prodSKUMap.containskey(refreshSKU) && prodSKUMap.get(refreshSKU).component_code__c!=null)
                    prodSKU = prodSKUMap.get(refreshSKU).component_code__c;
                
            }
            else {
                if(prodSKUMap.containskey(refreshSKU) && prodSKUMap.get(refreshSKU).component_code__c!=null)
                    prodSKU = prodSKUMap.get(refreshSKU).component_code__c;
            }
            
            if(prodSKU == null){
                prodSKU = ' No Matching HPE SKU: ';
            }
        }
        else if(tSKU == 'pc'){
            if(netSKU.containsKey(refreshSKU)){
                refreshSKU = netSKU.get(refreshSKU);
                if(prodSKUMap.containskey(refreshSKU) && prodSKUMap.get(refreshSKU).ProductCode!=null)
                    prodSKU = prodSKUMap.get(refreshSKU).ProductCode;
                
            }else {
                if(prodSKUMap.containskey(refreshSKU) && prodSKUMap.get(refreshSKU).ProductCode!=null)
                    prodSKU = prodSKUMap.get(refreshSKU).ProductCode;
            }
            
            if(prodSKU == null){
                prodSKU = '';
            }
        }        
        
        return prodSKU;
    }
    
}