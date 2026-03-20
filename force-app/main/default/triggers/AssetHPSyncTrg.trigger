trigger AssetHPSyncTrg on Asset_Stage__c (Before Insert, After Insert, Before Update) {

    if(trigger.isBefore && trigger.isInsert) {
        AssetHPSyncTrgCls.createAsset(Trigger.new, TRUE, NULL);  
    }
    if(trigger.isUpdate){
        AssetHPSyncTrgCls.createAsset(Trigger.new, FALSE, Trigger.old);     
    }
}