public class DuplicateAssetTriggerHandler extends triggerhandler {
    
    public Map<Id, Duplicate_Asset__c> oldDupsAsset;
    public Map<Id, Duplicate_Asset__c> newDupsAsset;
    public Set<Id> duplicateAssetIds;
    public String batchQuery ;
    
     public DuplicateAssetTriggerHandler(Map<Id,Duplicate_Asset__c> newDuplicateAssetMap ,
                                        Map<Id,Duplicate_Asset__c> oldDuplicateAssetMap) {
        newDupsAsset = newDuplicateAssetMap;
        oldDupsAsset = oldDuplicateAssetMap;
        batchQuery   = 'select Account__c, Array_Cache__c, Array_Capacity__c, Array_Controller__c, Array_Networking__c, Array_Networking_2__c, Array_Networking_3__c, Asset_Currency__c, Asset_Name__c, assetNrdEndDate__c, '+
                        'Contact__c, CreatedById, CreatedDate, CurrencyIsoCode, Dup_Asset_Trigger_Error__c, Expansion_Shelf_Base__c, Id, Install_City__c, assetNrdStartDate__c, Install_Country__c, '+
                        'Install_State_Province__c, Install_Street1__c, Install_Street2__c, Install_Zip_Code__c, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, '+
                        'LastReferencedDate, LastViewedDate, Matched_Asset__c, Name, Opportunity__c, Order_Type__c, OwnerId, Product__c, Purchase_Date__c, Sales_Order__c, '+
                        'Sales_Order_Line__c, Sales_Order_Line_ID__c, Serial_Number__c, Shelf_Pack_1__c, Shelf_Pack_1B__c, Shelf_Pack_2__c, Shelf_Pack_2B__c, Shelf_Pack_3__c, '+
                        'Shelf_Pack_3B__c, Shelf_Pack_4__c, Shelf_Pack_4B__c, Shelf_Pack_5__c, Shelf_Pack_5B__c, Shelf_Pack_6__c, Shelf_Pack_6B__c, Shipping_Date__c, '+
                        'SLA__c, SSD_Bank_A__c, SSD_Bank_B__c, SSD_Packs__c, Status__c, Support_End_Date__c, Support_Start_Date__c, SystemModstamp, TSC_Asset_Support__c from Duplicate_Asset__c';
     }
    
     public override void beforeInsert() {
     
     }
     
     public override void beforeupdate() {
     
     }
     
     public override void afterInsert() {
            invokeDupAssetBatch();
     }
     
     public override void afterUpdate() {  
          invokeDupAssetBatch();
     } 
     
     
     public void invokeDupAssetBatch() {
          duplicateAssetIds = new Set<Id>();
          duplicateAssetIds = newDupsAsset.KeySet();
          
          List<String> dAssetIdList = new List<String>();
          
          for(Id dassetId : duplicateAssetIds){
              dAssetIdList.add(dassetId);
          }
          
          batchQuery += ' where Id in ( ' ;
          
          for(Integer i=0 ; i < dAssetIdList.size() ; i++) {
              if(i == dAssetIdList.size() - 1) {
               batchQuery += '\''+dAssetIdList[i]+'\'';
              }
              else {
              batchQuery += '\''+dAssetIdList[i]+'\',';
              } 
          }  
          
          batchQuery += ' )';
          
          System.debug('batchQuery @@@ '+batchQuery);
             
         // BatchDuplicateAssetRecord bcDupAssets = new BatchDuplicateAssetRecord();
          //bcDupAssets.query = batchQuery ;
          //database.executebatch(bcDupAssets,5);     
     }
}