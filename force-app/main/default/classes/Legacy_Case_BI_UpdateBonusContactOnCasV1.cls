public with sharing class Legacy_Case_BI_UpdateBonusContactOnCasV1 implements TriggerAction.BeforeInsert{
    public void beforeInsert(List<Case> newList){      
        set<Id> relatedAccountId = new set<Id>();
        set<Id> relatedAssetId = new set<Id>();
        
        //Asset and Account Id collection
        for (Case caseToProcess : newList) {
            if(!caseToProcess.caseDontSendCaseCloseEmail__c && (caseToProcess.Case_Type__c == 'External' || caseToProcess.Case_Type__c == null)){
                relatedAccountId.add(caseToProcess.AccountId);
                relatedAssetId.add(caseToProcess.AssetId);
            }
        }
        
        //Related Account Query
        Map<id,Boolean> accountIdWithSendEmailToContact = new Map<id,Boolean>(); 
        if(relatedAccountId.size() > 0){
            for(Account eachAccount : [Select id,Support_Provider__c,Support_Provider__r.Name,Support_Provider__r.Send_Emails_to_Contact__c from Account where id =: relatedAccountId ] ){
                if(eachAccount.Support_Provider__c != null){
                    accountIdWithSendEmailToContact.put(eachAccount.id,eachAccount.Support_Provider__r.Send_Emails_to_Contact__c); 
                }
            }
        }
        
        //Related Asset Query
        Map<id,string> assetIdWithSecondaryContactEmail = new Map<id,string>();
        Map<id,string> assetIdWithTertiaryContactEmail = new Map<id,string>();
        if(relatedAssetId.size() > 0){
            for(Asset eachAsset :[Select id,ContactSecondary__c,ContactTertiary__c,ContactSecondary__r.Email,ContactTertiary__r.Email from Asset where id=: relatedAssetId]){
                if(eachAsset.ContactSecondary__c != null)
                    assetIdWithSecondaryContactEmail.put(eachAsset.Id,eachAsset.ContactSecondary__r.Email);               
                if(eachAsset.ContactTertiary__c != null )
                    assetIdWithTertiaryContactEmail.put(eachAsset.Id,eachAsset.ContactTertiary__r.Email);     
            } 
        }
        
        //Value Assignment for assetSecondaryContact__c and assetTertiaryContact__c
        for(Case eachCase : newList){
            if(accountIdWithSendEmailToContact.size() > 0 && accountIdWithSendEmailToContact.containsKey(eachCase.AccountId)){
                if(accountIdWithSendEmailToContact.get(eachCase.AccountId)){
                    eachCase.assetSecondaryContact__c = assetIdWithSecondaryContactEmail.size() > 0 && assetIdWithSecondaryContactEmail.containsKey(eachCase.AssetId) ? assetIdWithSecondaryContactEmail.get(eachCase.AssetId) : '';
                    eachCase.assetTertiaryContact__c = assetIdWithTertiaryContactEmail.size() > 0 && assetIdWithTertiaryContactEmail.containsKey(eachCase.AssetId) ? assetIdWithTertiaryContactEmail.get(eachCase.AssetId) : '';
                }
            }
        }
    }
}