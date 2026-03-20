/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 10-30-2023
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   10-27-2023   Nagalaxmi Telkar   Initial Version
**/
/**Created by Exafort on 09/07/2020   
Purpose : Trigger is used for insert the case and case comment related details to Case_Effort_Tracking__c object.
TS-3370

Modification log : TS-8035 / Nagalaxmi Telkar / 3-13-2023
*/
trigger caseCommentTimeTracking on CaseComment (after insert) {
    
    /*commented by exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295
    //Added by Exafort on 09/07/2020  - START 
    User u = [SELECT Email, Name, ContactId from User where Id = :user];
    //string userType = UserInfo.getUserType();
    boolean isPortalUser = false;       
   if (u.ContactId != null) { isPortalUser = true; }*/
    
    /*string user = UserInfo.getUserId();
    Case css;
    List<Case> clearFlagCases = new List<Case>();
    if(CaseUtility.isStandardUser()){//caseUtility.isStandardUser Added by Exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295
        System.debug('Am I comig here 1');
        list<Case_Effort_Tracking__c> commentTrackingCollection = new list<Case_Effort_Tracking__c>();                       
        for(CaseComment cc : Trigger.new) {    
            System.debug('Am I comig here 2 : '+CaseCommentTimeTrackingVariable.caseCommentSpentTime +':'+CaseCommentTimeTrackingVariable.caseCommentActivity);        
            if(CaseCommentTimeTrackingVariable.caseCommentSpentTime !=null && CaseCommentTimeTrackingVariable.caseCommentActivity !=null){          
                css = [select caseAttnReq__c, id,Owner.Id,Owner.Name,Owner.Type,Estimated_Effort__c,Case_Effort_Summary_Total__c,caseClosureEstimatedEffort__c from case where Id = :cc.ParentId];
                Case_Effort_Tracking__c commentTracking = new Case_Effort_Tracking__c();
                System.debug('Am I comig here 3');
                //css.caseAttnReq__c = false;
                //clearFlagCases.add(css);
                commentTracking.CaseId__c = cc.ParentId;
                if(css.Owner.Type == 'Queue')
                  commentTracking.Effort_Queue__c = css.Owner.Name;
                 else
                  commentTracking.Effort_Owner__c = css.Owner.Id;
                System.debug('Am I comig here 4 : '+css.Estimated_Effort__c+': css.Case_Effort_Summary_Total__c : ' +css.Case_Effort_Summary_Total__c);
                if(css.Estimated_Effort__c != null && css.Estimated_Effort__c != 'none' && css.Estimated_Effort__c != 'N/A' && css.Case_Effort_Summary_Total__c == 0){
                    String formattedStr = css.Estimated_Effort__c;
                    String[] strArr = formattedStr.split(' ');
                    if(strArr.size() == 1){
                        if(strArr[0].isNumeric())
                            commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]); 
                        else{
                            String numberOnly = strArr[0].replaceAll('[^0-9]', '');
                            commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(numberOnly);
                        }
                    }else if(strArr.size() == 2){
                        if(formattedStr.contains('minutes') || formattedStr.contains('min'))
                            commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]);
                        else if(formattedStr.contains('hour') || formattedStr.contains('hours') || formattedStr.contains('hr'))
                            commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]) * 60;
                        else if(formattedStr.contains('day'))
                            commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]) * 24 * 60;
                        else if(formattedStr.equals('one hour'))
                            commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]) * 60;

                    }else if(strArr.size() == 4){
                        String numberOnly = formattedStr.replaceAll('[^0-9]', '');
                        if(formattedStr.contains('min'))
                            commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(numberOnly);
                        else if(formattedStr.contains('hour'))
                            commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(numberOnly) * 60;
                        else if(formattedStr.contains('day'))
                            commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(numberOnly) * 24 * 60;
                    }
                }else
                    commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime;                            
                commentTracking.Effort_Origin__c = 'Case';
                commentTracking.Effort_Timestamp__c = cc.CreatedDate;
                commentTracking.Effort_Type__c = CaseCommentTimeTrackingVariable.caseCommentActivity;
                commentTracking.Effort_User__c = user;     
                commentTracking.Effort_Identifier__c = cc.id;                    
                commentTrackingCollection.add(commentTracking);
            }                                                                            
        }
        if(commentTrackingCollection.size() > 0){
            upsert commentTrackingCollection;
            case caseToUpdate = [select id, Case_Effort_Summary_Total__c,caseClosureEstimatedEffort__c from case where Id = :css.Id];
            caseToUpdate.caseClosureEstimatedEffort__c = String.valueOf(caseToUpdate.Case_Effort_Summary_Total__c);
            update caseToUpdate;
        }

        /*if(clearFlagCases.size()>0){
            System.debug('Am I comig here');
            update clearFlagCases;
        }*/
            
        
   //}
    //Added by Exafort on 09/07/2020  - END
    
}