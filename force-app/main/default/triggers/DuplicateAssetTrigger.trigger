/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        August 4, 2016
Purpose             :        Trigger for Duplicate Asset object
                             1) DuplicateAssetTrigger.trigger
                             
                             Whenever duplicate asset is created with Matched Asset field populated, update the existing asset values with 
                             the duplicate Asset and then delete the duplicate Asset record.
                            

**************************************************************************************************************************************/


trigger DuplicateAssetTrigger on Duplicate_Asset__c (after insert, after update) {
    set<id> AssetIds = new set<id>();
    set<id> dupAssetIds = new set<id>();
    Map<Id, Asset> assetMap;
    
    Boolean isActivated = ActivateTrigger__c.getInstance().DuplicateAssetTrigger__c;
    if(Test.isRunningTest())
        isActivated = true;
        
    if (isActivated){
        for (Duplicate_Asset__c dupAsset : trigger.new) {
            if (dupAsset.Matched_Asset__c != null){
                System.debug(LoggingLevel.INFO, 'Matched Asset found. Value :: '+ dupAsset.Matched_Asset__c);
                AssetIds.add(dupAsset.Matched_Asset__c);
                dupAssetIds.add(dupAsset.id);
            }
        }
        
        if (AssetIds.size()>0)
            assetMap = new Map<Id, Asset>([Select id,AccountId,ContactId, Name, CurrencyIsoCode, Product2Id, SerialNumber, Status, Opportunity_Asset__c,Order_Type__c,
                                                  Sales_Order_Line_Id__c, Shelf_Pack_1__c, Shelf_Pack_2__c, Shelf_Pack_3__c, Shelf_Pack_4__c, 
                                                  Array_Cache__c, Array_Capacity__c, Array_Controller__c, Array_Networking__c, SSD_Packs__c, SSD_Bank_A__c, 
                                                  SSD_Bank_B__c, Sales_Order__c, Ship_Date__c, PurchaseDate, SLA__c, Support_End_Date__c, support_start_date_Asset__c,
                                                  assetNRDStartDate__c, assetNRDEndDate__c, Install_Street1__c, Install_Street2__c, Install_City__c, 
                                                  Install_state_Province__c, Install_Zip_Code__c, Install_Country__c 
                                             FROM Asset 
                                            WHERE id IN: AssetIds ]);
            
        for (Duplicate_Asset__c dupAsset: Trigger.new){
            if (assetMap.size() >0){
                if (assetMap.containsKey(dupAsset.Matched_Asset__c)){
                    assetMap.get(dupAsset.Matched_Asset__c).AccountId = dupAsset.Account__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Contactid = dupAsset.Contact__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Name = dupAsset.Asset_Name__c;
                    assetMap.get(dupAsset.Matched_Asset__c).CurrencyIsoCode = dupAsset.Asset_Currency__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Product2id = dupAsset.Product__c;
                    assetMap.get(dupAsset.Matched_Asset__c).SerialNumber = dupAsset.Serial_Number__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Status = dupAsset.Status__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Opportunity_Asset__c = dupAsset.Opportunity__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Order_Type__c = dupAsset.Order_Type__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Sales_Order_Line_ID__c = dupAsset.Sales_Order_Line_ID__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Shelf_Pack_1__c = dupAsset.Shelf_Pack_1__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Shelf_Pack_2__c = dupAsset.Shelf_Pack_2__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Shelf_Pack_3__c = dupAsset.Shelf_Pack_3__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Shelf_Pack_4__c = dupAsset.Shelf_Pack_4__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Array_Cache__c = dupAsset.Array_Cache__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Array_Capacity__c = dupAsset.Array_Capacity__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Array_Controller__c = dupAsset.Array_Controller__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Array_Networking__c = dupAsset.Array_Networking__c;
                    assetMap.get(dupAsset.Matched_Asset__c).SSD_Packs__c = dupAsset.SSD_Packs__c;
                    assetMap.get(dupAsset.Matched_Asset__c).SSD_Bank_A__c = dupAsset.SSD_Bank_A__c;
                    assetMap.get(dupAsset.Matched_Asset__c).SSD_Bank_B__c = dupAsset.SSD_Bank_B__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Sales_Order__c = dupAsset.Sales_Order__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Ship_Date__c = dupAsset.Shipping_Date__c;
                    assetMap.get(dupAsset.Matched_Asset__c).PurchaseDate = dupAsset.Purchase_Date__c;
                    assetMap.get(dupAsset.Matched_Asset__c).SLA__c = dupAsset.SLA__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Support_End_Date__c = dupAsset.Support_End_Date__c;
                    assetMap.get(dupAsset.Matched_Asset__c).support_start_date_Asset__c = dupAsset.Support_Start_Date__c;
                    assetMap.get(dupAsset.Matched_Asset__c).assetNrdStartDate__c = dupAsset.assetNrdStartDate__c;
                    assetMap.get(dupAsset.Matched_Asset__c).assetNrdEndDate__c = dupAsset.assetNrdEndDate__c;         
                    assetMap.get(dupAsset.Matched_Asset__c).Install_Street1__c = dupAsset.Install_Street1__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Install_Street2__c = dupAsset.Install_Street2__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Install_City__c = dupAsset.Install_City__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Install_State_Province__c = dupAsset.Install_State_Province__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Install_Zip_Code__c = dupAsset.Install_Zip_Code__c;
                    assetMap.get(dupAsset.Matched_Asset__c).Install_Country__c = dupAsset.Install_Country__c;
                }
            }
        }
        if(assetMap.size()>0) {
            update assetMap.values();
            List<Duplicate_Asset__c> dupAssetList = [Select id from Duplicate_Asset__c where Id IN: dupAssetIds];   
            delete dupAssetList;
        }
    }
}