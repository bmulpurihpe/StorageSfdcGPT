/*Created by Exafort on 10/12/2020 - START TS-7450
Purpose :  This class is helps to capture survey sent history details of the case / RMA.
TestClass : SurveyTrackingTest*/

public class SurveyTracking {
    
    public static boolean isAvoidRecursive = true;
    
    public static void createSurveyTrackingRecord(string objName,Map<Id,list<string>> surveyData){
         list<Survey_Sent_History__c> surveyMaster = new list<Survey_Sent_History__c>();
        if(surveyData.size() > 0){            
            for(Id key : surveyData.keySet()){                                
                Survey_Sent_History__c ssh = new Survey_Sent_History__c();              
                ssh.Email_Template_Id__c = surveyData.get(key)[0];
                ssh.Account__c = surveyData.get(key)[1];
                ssh.Contact__c = surveyData.get(key)[2];
               ssh.Asset__c = surveyData.get(key)[3];                                
                ssh.Record_ID__c = key;
                ssh.Survey_Type__c = objName == 'Case' ? 'Support_Closed_Case_01' : 'RMA_FE';
                ssh.Time_Sent__c = Datetime.now();
                surveyMaster.add(ssh);                
            }                        
        }                        
        if(surveyMaster.size() > 0)
            Database.insert(surveyMaster,false);                
    }
    
}