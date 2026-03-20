/*Created by Exafort on 9/18/2020 - START TS-3370
Purpose : If the Effort user and case owner both are same.Then Update the "Effort is Owner" field in the Case Effort Tracking object. 
This class is called from 'caseEffortTracking' case trigger
TestClass : caseCommentTimeTrackingTest
*/

public class caseTrackingOwnerUpdation {
        
    public static void updateCaseEffortOwner(set<Id> caseId){           
        list<Case_Effort_Tracking__c> caseEffortMaster = new list<Case_Effort_Tracking__c>();
        list<Case_Effort_Tracking__c> caseEffortDetails = new list<Case_Effort_Tracking__c>();
        map<id,string> caseOwnerDetails = new map<id,string>();
        list<case> caseDetails = [select id,Owner.Id,(select id,CaseId__c,Effort_User__c,Effort_is_Owner__c from Case_Comment_Time_Trackings__r ) from case where Id = :caseId];
        for(Case caseOwner : caseDetails){
            if(caseOwner.Case_Comment_Time_Trackings__r.size() > 0){
                for(Case_Effort_Tracking__c ct : caseOwner.Case_Comment_Time_Trackings__r){
                    if(ct.Effort_User__c == caseOwner.Owner.Id)
                        ct.Effort_is_Owner__c = true;                        
                    else
                        ct.Effort_is_Owner__c = false;
                    
                    caseEffortMaster.add(ct);
                }    
            }                  
        }        
        if(caseEffortMaster.size() > 0){
            CaseCommentTimeTrackingVariable.isFirstTime = true;
            database.upsert(caseEffortMaster,false);
        }                         
    }

}