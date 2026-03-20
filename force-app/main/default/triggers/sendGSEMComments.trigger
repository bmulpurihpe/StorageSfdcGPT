trigger sendGSEMComments on CaseComment (after Insert,after update) {
    if(Trigger.IsInsert && Trigger.Isafter){      
        sendGSEMCommentHandler.gsemPPI(Trigger.newMap);
         DCESyncCaseCommentController.insertCaseCommentsAndUpdateCaseDetails(trigger.new);
    }
    TriggerSettings__c settings = TriggerSettings__c.getInstance('DceSyncUpdate');
    String DCEIntAPIUser =Label.DCEIntegration_APIUser;
    if(settings !=null){
        if(!settings.Disable__c  && UserInfo.getUserId() != DCEIntAPIUser){
            if(Trigger.isAfter && Trigger.isInsert){
                DCESyncCaseCommentController.caseCommentInsertDceSync(trigger.new); 
            }  
            if(Trigger.isAfter && Trigger.isUpdate){
                DCESyncCaseCommentController.caseCommentUpdateDceSync(trigger.new, trigger.oldMap);  
            }
        }
    }
    
}