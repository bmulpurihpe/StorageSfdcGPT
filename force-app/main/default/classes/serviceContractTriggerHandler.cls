public class serviceContractTriggerHandler {
 public static void updateAccountSubscriptionDates(List<ServiceContract> sContractList) {
        Set<Id> accountIds = new Set<Id>();
        for(ServiceContract scon : sContractList){
            if(scon.AccountId != null){
                accountIds.add(scon.AccountId);
            }
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>([
            SELECT Id, Subscription_Start_Date__c, Subscription_End_Date__c
            FROM Account WHERE Id IN :accountIds]);
        
        List<Account> accountsToUpdate = new List<Account>();
        for(ServiceContract  scontract : sContractList){
            if(scontract.AccountId != null && accountsMap.containsKey(scontract.AccountId)){
                Account acc = accountsMap.get(scontract.AccountId);
                Boolean isUpdated = false;

                if(scontract.EndDate != null){
                    if(acc.Subscription_End_Date__c == null || scontract.EndDate > acc.Subscription_End_Date__c){
                        System.debug('====Endate ==='+scontract.EndDate+'===StartDate===='+scontract.StartDate);
                        acc.Subscription_End_Date__c = scontract.EndDate;
                        acc.Subscription_Start_Date__c = scontract.StartDate;
                        isUpdated = true;
                    }
                }
              /*  if(scontract.StartDate != null){
                    if(acc.Subscription_Start_Date__c == null || scontract.StartDate > acc.Subscription_Start_Date__c){
                        acc.Subscription_Start_Date__c = scontract.StartDate;
                        isUpdated = true;
                    }
                }
                if(scontract.EndDate != null){
                    if(acc.Subscription_End_Date__c == null || scontract.EndDate > acc.Subscription_End_Date__c){
                        acc.Subscription_End_Date__c = scontract.EndDate;
                        isUpdated = true;
                    }
                }*/
                if(isUpdated){
                    accountsToUpdate.add(acc);
                }
            }
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
}