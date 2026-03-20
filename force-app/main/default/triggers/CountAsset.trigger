trigger CountAsset on Asset (after insert, after update, after delete) {
  Set<Id> AccountIds = new Set<Id>();
    
        if(Trigger.isUpdate && CountAssetPreventRecursive.runOnce() || Trigger.isInsert){
            for ( Asset cc : Trigger.new ) {
                AccountIds.add(cc.AccountId);
            }
        }else if(Trigger.isDelete){
            for ( Asset cc : Trigger.old) {
                AccountIds.add(cc.AccountId);
            }
        }
       
        if (!accountIds.isEmpty()) {
           // System.enqueueJob(new CountAssetQueueable(accountIds));
            List<Account> accountsToUpdate = [SELECT Id FROM Account WHERE Id IN :accountIds];
            Database.update(accountsToUpdate, false); 
        }
    
}