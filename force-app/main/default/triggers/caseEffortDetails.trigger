/*Created by Exafort on 09/07/2020  - START TS-3370
Purpose : If the Effort user and case owner both are same.Then Update the "Effort is Owner" field in the Case Effort Tracking object. 
This class is called from 'caseEffortTracking' case trigger
TestClass : caseCommentTimeTrackingTest*/
trigger caseEffortDetails on Case_Effort_Tracking__c (after insert) {
     
        set<Id> caseId = new set<Id>();
        for(Case_Effort_Tracking__c effortTracking : Trigger.New){
            caseId.add(effortTracking.CaseId__c);        
        }
        
        if(caseId.size() > 0)
            caseTrackingOwnerUpdation.updateCaseEffortOwner(caseId);
  
  
}