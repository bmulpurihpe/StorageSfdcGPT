public with sharing class Case_SpecialInfoController {

    @AuraEnabled(cacheable=true)
    public static CaseWrapper getInitialWrapper(String caseId){

        if(caseId == null){
            return null;
        }
        CaseWrapper CW = new CaseWrapper();
        Case thisCase = [SELECT Id, AssetId, ContactId FROM Case WHERE Id = :caseId];
        CW.assetCount = thisCase.AssetId != null ? getNumCasesAsset(thisCase.AssetId) : 0;
        CW.contactCount = thisCase.ContactId != null ? getNumCasesContact(thisCase.ContactId) : 0;
        CW.caseList = thisCase.AssetId != null ? getOpenCasesWithAsset(thisCase.AssetId) : new List<Case>();
        return CW;
    }

    @AuraEnabled
    public static Integer getNumCasesAsset(Id assetId) {
        return [SELECT COUNT() FROM Case WHERE Status NOT IN ( 'Closed','Closed(Duplicate)') AND AssetId != null AND AssetId = :assetId ];
    }

    @AuraEnabled
    public static Integer getNumCasesContact(Id contactId) {
        return [SELECT COUNT() FROM Case WHERE Status NOT IN( 'Closed','Closed(Duplicate)') AND ContactId != null AND ContactId = :contactId ];
    }

    @AuraEnabled
    public static Boolean getAccountSupportRestriction(Id accountId) {
        Account acc = [SELECT AccountDoNotProvideSupport__c FROM Account WHERE Id = :accountId LIMIT 1];
        return acc.AccountDoNotProvideSupport__c;
    }

    @AuraEnabled
    public static List<Case> getOpenCasesWithAsset(Id assetId) {
        return [SELECT Id, CaseNumber, CreatedDate, Subject, AccountId, Account.Name, ContactId, Contact.Name 
                FROM Case 
                WHERE AssetId = :assetId 
                AND Status NOT IN ( 'Closed','Closed(Duplicate)')
                ORDER BY CreatedDate DESC LIMIT 10000];
    }

    public class CaseWrapper {
        @AuraEnabled
        public Integer assetCount { get; set; }
         @AuraEnabled
        public Integer contactCount { get; set; }
        @AuraEnabled
        public  List<Case> caseList { get; set; }
        public CaseWrapper() {
            this.caseList = new  List<Case>();
        }
    }
}