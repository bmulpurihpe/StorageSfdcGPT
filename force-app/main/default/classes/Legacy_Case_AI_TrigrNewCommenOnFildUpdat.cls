/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-20-2024   Nagalaxmi Telkar   Initial Version
**/
//Trigger caseTriggerNewCommentOnFieldUpdates on Case (after insert, after update)
public with sharing class Legacy_Case_AI_TrigrNewCommenOnFildUpdat implements TriggerAction.AfterInsert
{
    /* 
        This trigger is used to create a new Case Comment when the value of certain Case fields change.  The fields tracked are:
           - Current Status
           - Plan Of Action
    */
      List<CaseComment> newCaseComments = new List<CaseComment>();
        
       List<CaseComment> additionalCaseComments = new List<CaseComment>();

        Map<Id, String> caseIdwithAccName = new Map <id, String>();
        Map<Id, String> caseIdwithAccNameRunOnce = new Map <id, String>();
    public void afterInsert(List<Case> newList) {
        caseIdwithAccNameRunOnce = RecursiveTriggerRestrictiion.caseIdwithAccName;
        if(caseIdwithAccNameRunOnce != null && caseIdwithAccNameRunOnce.size() > 0) {
            caseIdwithAccName = caseIdwithAccNameRunOnce;
        } else {
            caseIdwithAccName = RecursiveTriggerRestrictiion.getCaseIdwithAccName(Trigger.newMap.keySet());
        }
        
        for (Case newCase : newList)
        {
            // Clear out variables for this iteration
            
            Boolean caseCurrentStatusUpdated = false;
            Boolean casePlanOfActionUpdated  = false;
            Boolean newCaseCommentNeeded     = false;
            String  newCaseCommentBody       = '';
            
            // Evaluate fields, and see if any were updated.
            // For inserts, this means checking to see if they have a value.
            // For updates, this means comparing the old value to the new one.
            // If any were updated, a new Case Comment will be needed.
            
            //if (Trigger.isInsert) {
                if (!String.isBlank(newCase.caseCurrentStatus__c)) { 
                    caseCurrentStatusUpdated = true;
                    newCaseCommentNeeded     = true;
                }
                
                if (!String.isBlank(newCase.casePlanOfAction__c)) {
                    casePlanOfActionUpdated = true;
                    newCaseCommentNeeded    = true;
                }
                
            //}
           
            
            // If a new Case Comment is needed, create it, and populate it
            // with the values of the fields.
            
            if (newCaseCommentNeeded) {
                    newCaseCommentBody =  '*** CASE FIELDS UPDATED ***\n\n';
                    newCaseCommentBody += 'New Values:\n\n';
                    
                    if (caseCurrentStatusUpdated) {
                        newCaseCommentBody += 'Current Status: ' + newCase.caseCurrentStatus__c + '\n\n';
                    }
                    
                    if (casePlanOfActionUpdated) {
                        newCaseCommentBody += 'Plan Of Action: ' + newCase.casePlanOfAction__c + '\n';
                    }
                    
                    newCaseComments.add(new CaseComment (ParentId    = newCase.Id,
                                                         IsPublished = false,
                                                         CommentBody = newCaseCommentBody));
               }
        }
        
        // Insert any new Case Comments that were created.
        if(newCaseComments.size() > 0){
            System.debug('MW:Inserting new comment: ' + newCaseComments[0].CommentBody);
            insert newCaseComments;
        } 
    }
}