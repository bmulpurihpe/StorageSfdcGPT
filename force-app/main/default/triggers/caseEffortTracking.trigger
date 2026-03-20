/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 03-13-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   03-13-2024   Nagalaxmi Telkar   Initial Version
**/
//Added by Exafort on 09/07/2020  - START TS-3370
//Purpose : CaseCommentTimeTrackingVariable class used in caseCommentTimeTracking trigger
trigger caseEffortTracking on Case (after Update) {
    set<Id> caseId = new set<Id>(); 
    // Added by Exafort for TS-8034 
    for (Case triggerCase : trigger.new){
        if(triggerCase.Current_comment_time_spent__c !=null && triggerCase.Current_comment_time_spent__c < 0)
            triggerCase.addError('You cannot enter a negative value in field - ADD minutes to “Current comment time spent (Mins)”');
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
            if (triggerCase.OwnerId != trigger.oldMap.get(triggerCase.Id).OwnerId){
                caseId.add(triggerCase.Id);
            }
        }
    }
    if(caseId.size() > 0){
        caseTrackingOwnerUpdation.updateCaseEffortOwner(caseId);
    }               
}