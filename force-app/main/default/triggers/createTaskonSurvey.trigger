//Created by Exafort for TS-9179
trigger createTaskonSurvey on Survey__c (after insert) {
    try{ 
        for(Survey__c surveyRec : Trigger.New){
            id caseId = surveyRec.surveyCase__c;
            id surveyAccId = surveyRec.surveyAccount__c;
            Account acc;
            Case caseRec;
            if(surveyAccId != null){
                acc = [SELECT id,name FROM Account where Id =:surveyAccId limit 1];                
            }
            if(caseId != null){
                caseRec = [SELECT id,caseContributionModelTSE__c, caseContributionModelTSE__r.TSE_Manager__c
                           //caseContributionModelTSE__r.Manager__c
                           FROM Case
                           WHERE Id = :caseId limit 1];
            }
            if(surveyRec.surveyOverallSatisfaction__c != null  && (surveyRec.surveyOverallSatisfaction__c < 4 || surveyRec.Case_Survey_Cumulative_Score__c < 4.5) && 
               Schema.getGlobalDescribe().get('Survey__c').getDescribe().getRecordTypeInfosById().get(surveyRec.RecordTypeId).getName() =='Support Closed Case 01'){
                   Task t = new Task(); 
                   if(surveyRec.surveyOverallSatisfaction__c < 4 && surveyRec.Case_Survey_Cumulative_Score__c >= 4.5){
                       t.Subject = 'Survey overall satisfaction below 4';                
                   }
                   if(surveyRec.surveyOverallSatisfaction__c >= 4 && surveyRec.Case_Survey_Cumulative_Score__c < 4.5){
                       t.Subject = 'Survey cumulative score below 4.5';                 
                   }
                   if(surveyRec.surveyOverallSatisfaction__c < 4 && surveyRec.Case_Survey_Cumulative_Score__c < 4.5){
                       t.Subject = 'Survey overall satisfaction below 4 and Survey cumulative score below 4.5';
                   }
                   
                   t.Survey__c = surveyRec.Id;
                   t.WhoId = surveyRec.surveyContact__c;
                   
                   //	Check if the 'surveyManagerComments__c' field has a non-blank value.
                   //	If it does, assign it to 'managerComment'; otherwise, assign an empty string.
                   String managerComment = String.isNotBlank(surveyRec.surveyManagerComments__c) ? surveyRec.surveyManagerComments__c : '';
                   
                   if(surveyAccId != null){
                       t.Description = 'Customer Name - ' +  acc.name + '\n'+ 'Survey Name - ' + surveyRec.Name + '\n' + '\n' +
                           'Manager Comments in Survey:' + '\n' + managerComment;
                   }else{
                       t.Description = 'Customer Name - ' +   + '\n'+ 'Survey Name - ' + surveyRec.Name + '\n' + '\n' +
                           'Manager Comments in Survey:' + '\n' + managerComment;
                   }
                   if(caseId != null){
                       if(caseRec.caseContributionModelTSE__r.TSE_Manager__c != null){
                           //t.OwnerId = caseRec.caseContributionModelTSE__r.Manager__c;
                           // Added by Exafort for TS-9551 
                           user userRec = [select id,Name from user where Name =: caseRec.caseContributionModelTSE__r.TSE_Manager__c limit 1];
                           if(userRec != null){
                               t.OwnerId = userRec.id;  
                           }
                           // Added End
                       }else{
                           t.OwnerId = User_Profile_id__c.getInstance().Survery_Task_Default_Manager_Id__c;
                       }
                   }
                   else{
                       t.OwnerId = User_Profile_id__c.getInstance().Survery_Task_Default_Manager_Id__c;
                   }
                   insert t;
                   //After a task is inserted, an email notification is sent via the flow - "CSATLowScoreTaskEmailAlert"-TS-9491
                   
               }
        }
    }catch(Exception e){
        system.debug('Error on survey task creation '+e.getMessage());
    } 
    
}