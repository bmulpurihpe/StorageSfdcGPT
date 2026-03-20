trigger NMBL_Asset_ProcessTrigger on Asset (after insert,after update, after delete) {

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-11-2015
    Functionality      : This Trigger on Asset contains below mentioned functionality 
    
    1. update Nimble version on Work Order Lines           
    ***************************************************************************************************************/
    List<Asset> AsstList = new  List<Asset>();
    List<Asset> OldAsstList = new  List<Asset>();
    List<Asset> AsstCountList = new  List<Asset>();
    List<Asset> AssetList = new List<Asset>();
    if(Trigger.isAfter){
        if(Trigger.new != null)
        for(Asset a : Trigger.new){
            if(Trigger.IsInsert ||  (Trigger.IsUpdate && Trigger.oldMap.get(a.Id).Nimble_Version__c != a.Nimble_Version__c)){
               if(a.Nimble_Version__c != null)
                   AsstList.add(a);
            
            }
            
            if(Trigger.IsInsert || Trigger.IsUpdate){
                AsstCountList.add(a);
                if(!assetExpansionShelvesCount.assetIDs.contains(a.Id)){
                    assetExpansionShelvesCount.assetIDs.add(a.Id);
                    AssetList.add(a);
                }
            }
        }
        if(Trigger.old != null)
        for(Asset a1 : Trigger.old){
            
                AsstCountList.add(a1);
            
        }
         
    }  
    
          
    if(AsstList.size() > 0)
        AssetProcessClass.UpdateWorkOrderLineFields(AsstList);
    if(AssetList.size() > 0){
        assetExpansionShelvesCount.UpdateAssetCount(AssetList);
    }
    
    
}