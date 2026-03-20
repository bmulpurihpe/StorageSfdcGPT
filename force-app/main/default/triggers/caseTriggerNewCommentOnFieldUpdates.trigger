Trigger caseTriggerNewCommentOnFieldUpdates on Case (after insert, after update)
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
        caseIdwithAccNameRunOnce = RecursiveTriggerRestrictiion.caseIdwithAccName;
        if(caseIdwithAccNameRunOnce != null && caseIdwithAccNameRunOnce.size() > 0) {
            caseIdwithAccName = caseIdwithAccNameRunOnce;
        } else {
            caseIdwithAccName = RecursiveTriggerRestrictiion.getCaseIdwithAccName(Trigger.newMap.keySet());
        }
        
        for (Case newCase : Trigger.new)
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
            
            if (Trigger.isInsert) {
                if (!String.isBlank(newCase.caseCurrentStatus__c)) { 
                    caseCurrentStatusUpdated = true;
                    newCaseCommentNeeded     = true;
                }
                
                if (!String.isBlank(newCase.casePlanOfAction__c)) {
                    casePlanOfActionUpdated = true;
                    newCaseCommentNeeded    = true;
                }
                
            }
            else if (Trigger.isUpdate)
            {                
                Case oldCase = Trigger.oldMap.get(newCase.Id);
                System.debug('MW:RecursiveTriggerRestrictiion.currentCaseStatus Before: ' + RecursiveTriggerRestrictiion.currentCaseStatus);
                if (oldCase.caseCurrentStatus__c != newCase.caseCurrentStatus__c 
                        && RecursiveTriggerRestrictiion.currentCaseStatus != newCase.caseCurrentStatus__c) {
                    RecursiveTriggerRestrictiion.currentCaseStatus = newCase.caseCurrentStatus__c;
                    System.debug('MW:RecursiveTriggerRestrictiion.currentCaseStatus After: ' + RecursiveTriggerRestrictiion.currentCaseStatus);
                    caseCurrentStatusUpdated = true;
                    newCaseCommentNeeded     = true;
                }
                
                System.debug('MW:RecursiveTriggerRestrictiion.currentPlanOfAction Before: ' + RecursiveTriggerRestrictiion.currentPlanOfAction);
                if (oldCase.casePlanOfAction__c != newCase.casePlanOfAction__c
                        && RecursiveTriggerRestrictiion.currentPlanOfAction != newCase.casePlanOfAction__c) {
                    RecursiveTriggerRestrictiion.currentPlanOfAction = newCase.casePlanOfAction__c;
                    System.debug('MW:RecursiveTriggerRestrictiion.currentPlanOfAction After: ' + RecursiveTriggerRestrictiion.currentPlanOfAction);
                    casePlanOfActionUpdated = true;
                    newCaseCommentNeeded    = true;
                }
                
                // Added by Exafort for TS-10288                
                // Check if the case record type is 'InfoSight Portal' AND status is 'Resolved' AND casePortalResolutionNotes__c field is updated            
                id infoSightId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('InfoSight Portal').getRecordTypeId();
                if(newCase.RecordTypeId == infoSightId && oldCase.casePortalResolutionNotes__c != newCase.casePortalResolutionNotes__c 
                   && newCase.casePortalResolutionNotes__c != null && newCase.status == 'Resolved'){
                       String accountName = caseIdwithAccName.get(newCase.Id) != null ? caseIdwithAccName.get(newCase.Id) : null;
                       CaseComment publicComment = new CaseComment();
                       publicComment.ParentId    = newCase.Id;
                       publicComment.IsPublished = true;
                       publicComment.CommentBody  = '[Account:' + newCase.AccountId + '(' + accountName + ')]' + '\n'
                                                  + '[user:internal(' + newCase.ContactEmail+')]' + '\n'
                                                  + newCase.casePortalResolutionNotes__c;
                       newCaseComments.add(publicComment);
                   }
                // End of TS-10288
            }
            
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