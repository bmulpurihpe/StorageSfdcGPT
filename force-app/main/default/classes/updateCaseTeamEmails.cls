Global class updateCaseTeamEmails {
    @InvocableMethod(label='Update Case Teams Emails From Apex')
    Global static void updateCaseTeamsEmailIds(List<FlowInputs> requests) {
        for(FlowInputs reqRec:requests){
            if(requests.size()> 0){
               processFlowRequest(reqRec.userListFromFlow,reqRec.caseIdFromFlow);  
            }
        }
    }
    Global static void processFlowRequest(List<user> getallUsers,String CaseId){
        system.debug('CaseId---->'+CaseId);
       	system.debug('user List---->'+getallUsers);
        system.debug('user List Size ---->'+getallUsers.size());

        string UserEmails='';
        List<String> additionalEmails = new List<String>();
        for (User UserRec : getallUsers) {
            if(UserRec.Email != null)additionalEmails.add(UserRec.Email.trim());
        }
        if(additionalEmails.size() > 1){
            UserEmails = String.join(additionalEmails, ',');
        }else if(additionalEmails.size() == 1){
            UserEmails = String.valueOf(additionalEmails[0]);
        }else{
            UserEmails = null;   
        }
        if(UserEmails != null && CaseId != null){
            Case caseToUpdate = new Case(Id = caseId,Additional_CC_PSM__c=UserEmails);
            update caseToUpdate;
        }
    }
    //input details that comes to apex from flow
    Global class FlowInputs{
        
        @InvocableVariable
        Global List<User> userListFromFlow;
        
        @InvocableVariable
        Global String caseIdFromFlow;
        
    }
    
    //output details which goes from apex to flow
    Global class FlowOutputs{
        
        @InvocableVariable
        Global String DMLResult;
    }
}