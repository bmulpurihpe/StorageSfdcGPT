/**
* @description       : 
* @author            : Nagalaxmi Telkar
* @group             : 
* @last modified on  : 09-16-2025
* @last modified by  : Nagalaxmi Telkar
* Modifications Log
* Ver   Date         Author             Modification
* 1.0   03-13-2024   Nagalaxmi Telkar   Initial Version
**/
//Added by Exafort on 09/07/2020  - START TS-3370
//Purpose : CaseCommentTimeTrackingVariable class used in caseCommentTimeTracking trigger
//trigger caseEffortTracking on Case (after Update) {
public with sharing class Legacy_Case_AU_CaseEffortTracking implements TriggerAction.AfterUpdate{
    public void afterUpdate(List<Case> newList, List<Case> oldList){
        set<Id> caseId = new set<Id>(); 
        Map<Id,Case> oldMap = new Map<Id,Case>(oldList);  
        if(!(UserInfo.getName() == 'GSEM API User' || UserInfo.getName() == 'Nimble Support' || UserInfo.getName() == 'DCE Informatica' || UserInfo.getName() == 'DCE Integration API User' || UserInfo.getName() == 'DCE File Sync API User')) {
            for (Case triggerCase : newList){
                if(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(triggerCase.RecordTypeId).getName() == 'Array Case' || Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(triggerCase.RecordTypeId).getName() == 'SSaaS'){
                    if(triggerCase.Current_comment_time_spent__c !=null && triggerCase.Current_comment_time_spent__c <= 0)
                        triggerCase.addError('You cannot enter Zero or a Negative Value the in field - “Current comment time spent (Mins)”');
                    else{
                        if(triggerCase.Current_comment_time_spent__c !=null && triggerCase.Current_comment_activity__c !=null && triggerCase.Current_comment_time_spent__c > 0 && CaseUtility.caseUpdateRunOnce()){            
                            CaseCommentTimeTrackingVariable.caseCommentSpentTime  = triggerCase.Current_comment_time_spent__c;
                            CaseCommentTimeTrackingVariable.caseCommentActivity  = triggerCase.Current_comment_activity__c;
                            CaseUtility.createCaseEffortTrackingRecord(triggerCase);
                        } 
                        if(triggerCase.Current_comment_time_spent__c !=null && triggerCase.Current_comment_activity__c == null  && triggerCase.Current_comment_time_spent__c > 0 && CaseUtility.caseUpdateRunOnce()){         
                            CaseCommentTimeTrackingVariable.caseCommentSpentTime  = triggerCase.Current_comment_time_spent__c;
                            CaseCommentTimeTrackingVariable.caseCommentActivity  = 'General Case Work';
                            CaseUtility.createCaseEffortTrackingRecord(triggerCase);
                        }
                        if (triggerCase.OwnerId != oldMap.get(triggerCase.Id).OwnerId){
                            caseId.add(triggerCase.Id);
                        }
                    }
                }
            }
            if(caseId.size() > 0){
                caseTrackingOwnerUpdation.updateCaseEffortOwner(caseId);
            }
        }
    }               
}