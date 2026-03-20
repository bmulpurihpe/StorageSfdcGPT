public class NextGenAssetUpdateHandler {
    Public Static Boolean isFirstRun = True;
    
    Public Static void  updateAssets(List<Asset> assets, Map<String,String> prodContrrefresh, Map<String, String> prodArrayNetworking, Map<String, String> prodArrayNetworkingSKU){
        
        List<String> SupportSKU = new List<String>();
        Map<String, Nimble_Offer_Code__c > skuLevelMap = new Map<String, Nimble_Offer_Code__c>();
        Map<string, Refresh_Bank_B__mdt> refreshBankBMap = new Map<string, Refresh_Bank_B__mdt>();
        for(Refresh_Bank_B__mdt rbb : [Select key__c, Refresh_Bank_B_SKU__c, Refresh_Bank_B_Cache__c from Refresh_Bank_B__mdt]){
            refreshBankBMap.put(rbb.key__c, rbb);
            
        }
        
        for(Asset asstRecord : assets){
            if(String.isNotBlank(asstRecord.HPE_Support_SKU__c)){
                SupportSKU.add(asstRecord.HPE_Support_SKU__c);
            }
        }
        
        for(Nimble_Offer_Code__c noc : [Select HPE_Support_Package_SKU__c, Controller_Refresh_Level__c, Equivalent_Standard_Support_SKU__c from Nimble_Offer_Code__c where HPE_Support_Package_SKU__c IN: SupportSKU ]){
 
            skuLevelMap.put(noc.HPE_Support_Package_SKU__c, noc);
        }
        Set<String> timelessstatus = new Set<String>{'Opted Out','Decommissioned'};
        for(Asset asstRecord  :assets){
        
            If(asstRecord.Timeless_Status__c == 'Refresh Ready Override' && asstRecord.Timeless_Storage__c  ){ 
                asstRecord.Refresh_Ready__c = true;     
            }   
            //Added by Yesha Benegal on 11/23/2021 ESS-75531
            else if(asstRecord.Timeless_Status__c == 'Not Refresh Ready' && asstRecord.Timeless_Storage__c){
                asstRecord.Refresh_Ready__c = false;         
            }       
            
            //Added by Srujan 09/24/2020         
           else If(asstRecord.Date_of_Refresh__c  <= system.today() && asstRecord.Timeless_Storage__c  && !timelessstatus.contains(asstRecord.Timeless_Status__c) ){
                
                asstRecord.Refresh_Ready__c = true;
            }
            else{
                asstRecord.Refresh_Ready__c = false;
            }
                        
            If(asstRecord.HPE_Support_SKU__c != null && skuLevelMap.containsKey(asstRecord.HPE_Support_SKU__c) && (asstRecord.Timeless_Storage__c || asstRecord.Timeless_fulfillment__c )){
                //asstRecord.level_selected__C = skuLevelMap.get(asstRecord.HPE_Support_SKU__c).Controller_Refresh_Level__c;
                asstRecord.Non_Timeless_Support_SKU__c = skuLevelMap.get(asstRecord.HPE_Support_SKU__c).Equivalent_Standard_Support_SKU__c;
            }
            
            else{
                //asstRecord.level_selected__C =  null;
                asstRecord.Non_Timeless_Support_SKU__c = null; 
            }
            
            
            if(!prodContrrefresh.isEmpty() &&  asstRecord.Controller_Refresh_1__c!=null && prodContrrefresh.containsKey(asstRecord.Controller_Refresh_1__c) && asstRecord.Timeless_Storage__c  == true ){
                asstRecord.Controller_Refresh_1_SKU__c=prodContrrefresh.get(asstRecord.Controller_Refresh_1__c); 
                asstrecord.Refresh_Component_SKU_HPE__c= asstRecord.Controller_Refresh_1_SKU__c;              
            } 
            If ( !asstRecord.Timeless_Storage__c ) {
                asstRecord.Controller_Refresh_1_SKU__c = '';
            }
            If (asstRecord.Asset_Type__c != 'HFA' && asstRecord.Asset_Type__c != 'A5000'){ // Added By Srujan on 01/06/2022 ESS-77002  and ESS-119189
           
                if(!prodArrayNetworking.isEmpty() &&  asstRecord.Array_Networking_SKU__c!=null && prodArrayNetworking.containsKey(asstRecord.Array_Networking_SKU__c) && asstRecord.Timeless_Storage__c  == true){
                    if(prodArrayNetworking.get(asstRecord.Array_Networking_SKU__c) != null)    
                        asstRecord.Controller_Refresh_Networking_SKU__c=prodArrayNetworking.get(asstRecord.Array_Networking_SKU__c);
                    if(prodArrayNetworkingSKU.get(asstRecord.Array_Networking_SKU__c) != null)
                        asstRecord.Controller_Refresh_Networking__c = prodArrayNetworkingSKU.get(asstRecord.Array_Networking_SKU__c);
                }
                if(!prodArrayNetworking.isEmpty() &&  asstRecord.Array_Networking_2_SKU__c!=null && prodArrayNetworking.containsKey(asstRecord.Array_Networking_2_SKU__c) && asstRecord.Timeless_Storage__c  == true){
                    if(prodArrayNetworking.get(asstRecord.Array_Networking_2_SKU__c) != null)    
                        asstRecord.Controller_Refresh_Networking_SKU__c += ',' + prodArrayNetworking.get(asstRecord.Array_Networking_2_SKU__c);
                    if(prodArrayNetworkingSKU.get(asstRecord.Array_Networking_2_SKU__c) != null)
                        asstRecord.Controller_Refresh_Networking__c += ',' + prodArrayNetworkingSKU.get(asstRecord.Array_Networking_2_SKU__c);
                    
                }
                if(!prodArrayNetworking.isEmpty() &&  asstRecord.Array_Networking_3_SKU__c!=null && prodArrayNetworking.containsKey(asstRecord.Array_Networking_3_SKU__c) && asstRecord.Timeless_Storage__c  == true){
                    if(prodArrayNetworking.get(asstRecord.Array_Networking_3_SKU__c) != null)    
                        asstRecord.Controller_Refresh_Networking_SKU__c += ',' + prodArrayNetworking.get(asstRecord.Array_Networking_3_SKU__c);
                    if(prodArrayNetworkingSKU.get(asstRecord.Array_Networking_3_SKU__c) != null)
                        asstRecord.Controller_Refresh_Networking__c += ',' + prodArrayNetworkingSKU.get(asstRecord.Array_Networking_3_SKU__c);
                }
            }
            
            If ( asstRecord.Timeless_Storage__c  != true) {
                asstRecord.Controller_Refresh_Networking_SKU__c= '';
                asstRecord.Controller_Refresh_Networking__c ='';
            }
            
            system.debug(' *** line 83 assettype  '+      asstRecord.Asset_Type__c + ' ***  ' + asstRecord.Controller_Refresh_Networking_SKU__c);          
            if (asstRecord.Controller_Refresh_1_SKU__c != null && asstRecord.Timeless_Storage__c  == true && asstRecord.Asset_Type__c != 'HFA' && asstRecord.Asset_Type__c != 'A5000'){            
                if (asstRecord.Controller_Refresh_Networking_SKU__c!= null && asstRecord.NDU_SKU__c == null ){
                    asstrecord.Refresh_Component_SKU_HPE__c += ','+asstRecord.Controller_Refresh_Networking_SKU__c;
                } else if (asstRecord.Controller_Refresh_Networking_SKU__c!= null  && asstRecord.NDU_SKU__c!= null){
                    asstrecord.Refresh_Component_SKU_HPE__c += ','+asstRecord.Controller_Refresh_Networking_SKU__c+','+asstRecord.NDU_SKU__c;
                } else if (asstRecord.Controller_Refresh_Networking_SKU__c == null &&asstRecord.NDU_SKU__c!= null) {
                    asstrecord.Refresh_Component_SKU_HPE__c += ','+asstRecord.NDU_SKU__c;
                }  
            } else  If (asstRecord.Controller_Refresh_1_SKU__c == null && asstRecord.Timeless_Storage__c  == true && asstRecord.Asset_Type__c != 'HFA' && asstRecord.Asset_Type__c != 'A5000'){
                if (asstRecord.Controller_Refresh_Networking_SKU__c!= null && asstRecord.NDU_SKU__c == null){
                    asstrecord.Refresh_Component_SKU_HPE__c = asstRecord.Controller_Refresh_Networking_SKU__c;
                }else if (asstRecord.Controller_Refresh_Networking_SKU__c!= null && asstRecord.NDU_SKU__c!= null){
                    asstrecord.Refresh_Component_SKU_HPE__c = asstRecord.Controller_Refresh_Networking_SKU__c+','+asstRecord.NDU_SKU__c;
                } else if(asstRecord.Controller_Refresh_Networking_SKU__c == null  && asstRecord.NDU_SKU__c!= null){ 
                    asstrecord.Refresh_Component_SKU_HPE__c = asstRecord.NDU_SKU__c;
                }
                else if (asstRecord.Controller_Refresh_Networking_SKU__c == null && asstRecord.NDU_SKU__c == null){
                    asstrecord.Refresh_Component_SKU_HPE__c = '';
                }               
            }
            else if (!asstRecord.Timeless_Storage__c){
                asstrecord.Refresh_Component_SKU_HPE__c = '';
            }
            
            if(asstrecord.Controller_Refresh_SW__c != null){
               if(asstrecord.Refresh_Component_SKU_HPE__c!= null && !asstrecord.Refresh_Component_SKU_HPE__c.contains(asstrecord.Controller_Refresh_SW__c))
                   asstrecord.Refresh_Component_SKU_HPE__c +=  ',' +asstrecord.Controller_Refresh_SW__c;
               else
                   asstrecord.Refresh_Component_SKU_HPE__c = asstrecord.Controller_Refresh_SW__c;
            }
            
            
            if(asstrecord.Controller_Refresh_Head_SSD__c != null){
                if(asstrecord.Refresh_Component_SKU_HPE__c != null && !asstrecord.Refresh_Component_SKU_HPE__c.contains(asstrecord.Controller_Refresh_Head_SSD__c))
                    asstrecord.Refresh_Component_SKU_HPE__c += ',' + asstrecord.Controller_Refresh_Head_SSD__c;
                else
                    asstrecord.Refresh_Component_SKU_HPE__c = asstrecord.Controller_Refresh_Head_SSD__c;
            }
            
            if(asstrecord.Controller_Refresh_PSU__c != null){ 
                if(asstrecord.Refresh_Component_SKU_HPE__c != null && !asstrecord.Refresh_Component_SKU_HPE__c.contains(asstrecord.Controller_Refresh_PSU__c))                
                    asstrecord.Refresh_Component_SKU_HPE__c += ',' + asstrecord.Controller_Refresh_PSU__c;
                else
                    asstrecord.Refresh_Component_SKU_HPE__c = asstrecord.Controller_Refresh_PSU__c;
            }
            
            
            // Added by Srujan on 11/18/2020        
            If (asstRecord.Timeless_fulfillment__c ){ 
                asstRecord.Timeless_Storage__c = false;
                asstRecord.Refresh_Ready__c = false;
            }
            
            //Added by Srujan 10/08/2020       
            if(String.isNotBlank(asstRecord.Controller_Refresh_1__c)){
                String key = asstRecord.Controller_Refresh_1__c;
                key += (asstRecord.Controller_Refresh_1__c).Left(2) == 'AF' ? '' : asstRecord.Array_Capacity__c;
                key += String.isNotBlank(asstRecord.SSD_Bank_A__c) ? asstRecord.SSD_Bank_A__c: '';
                key += String.isNotBlank(asstRecord.SSD_Bank_B__c) ? asstRecord.SSD_Bank_B__c: '';
                if(refreshBankBMap.containsKey(key)){
                    asstRecord.Refresh_Bank_B_Cache__c = refreshBankBMap.get(key).Refresh_Bank_B_Cache__c   ;
                    //asstRecord.Refresh_Bank_B_Cache_SKU__c = refreshBankBMap.get(key).Refresh_Bank_B_SKU__c;
                }
            }
        }   
    } 
}