trigger caseGSEMClose on Case (after insert,after update) {   
    TriggerSettings__c settings = TriggerSettings__c.getInstance('DCECaseSync');
    String DCEIntAPIUser =Label.DCEIntegration_APIUser;
    String GLCPIntAPIUser=Label.GLCP_Integration_API_User;
    if(UserInfo.getUserId() != DCEIntAPIUser){
   // if(UserInfo.getUserId() != DCEIntAPIUser && UserInfo.getUserId() != GLCPIntAPIUser) {
        if(settings !=null){
            if(!settings.Disable__c ){
                if(Trigger.isAfter && Trigger.isInsert){
                    
                    DceSyncController.getCaserecord(Trigger.new);  
                }  
                if(Trigger.isAfter && Trigger.isUpdate){
                    set<Id> caseIds=new set<Id>();
                    for(case caserec:Trigger.new){
                        case old = Trigger.oldMap.get(caserec.Id);
                        if(caserec.isDuplicate__c==false && caserec.ContactID!=null && caserec.ContactID!=old.ContactId){
                            caseIds.add(caserec.id);
                        }
                    }
                    if(!caseIds.isEmpty()){
                        DceSyncController.caseContactUpdateSync(caseIds);
                    }
                    DceSyncController.caseUpdateSync(trigger.new, trigger.oldMap); 
                }
            }
        }
        if(trigger.isAfter && trigger.IsUpdate){
           caseGSEMCloseHandler.gsemClosePPI(Trigger.newMap, Trigger.OldMap); 
        }
    }
}