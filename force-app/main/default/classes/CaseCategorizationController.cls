public  with sharing class CaseCategorizationController {
     @AuraEnabled(cacheable=true)
    public static case getCaseDetails(Id caseId) {
        // Asset_Product_Family__c field added by Exafort for TS-10308
        case caseDetail =[Select id,CaseNumber,Subject,Severity__c,caseCatImpactToCustomer__c,Technology_Area__c,Sub_Technology_Area__c,caseSpecificDetails__c,Type,Is_this_a_Storage_issue__c,casCatClosureRootCause__c,Origin,
                          casePachinkoCaseType__c,Auto_Close__c,Auto_Open__c,CreatedDate,ClosedDate,Age_Days__c,Peak_Area__c,Escalation_Rotation__c,Support_Profile__c,
                          caseBlacklistReason__c,Notify_Account_Team__c,US_Support__c,CreatedBy.Name,Data_Unavailability__c,Data_Loss__c,Data_Inconsistency__c,caseClosureArrayDowntimeMinutes__c,caseClosureEnvironmentDowntimeMinutes__c,
                          caseClosureBusinessImpact__c,Estimated_Effort__c,Case_Owner_Time_Effort__c,Non_Case_Owner_Time_Effort__c,Case_Effort_Summary_Total__c,CreatedBYId,Outage__c,Outage_Duration_Days__c,Outage_Duration_Hours__c,Outage_Duration_Minutes__c,Asset_Product_Family__c from case where id =:caseId];
        return caseDetail;
    }
}