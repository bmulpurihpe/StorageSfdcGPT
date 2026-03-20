// Belowed variables are used in caseTriggerSetOwnerEmail and caseCommentTimeTracking trigger.
// Added by Exafort on 09/07/2020
// Purpose : To capture the Current comment activity and Current comment time spent (Mins) field values from case.
// TS-3370
public class CaseCommentTimeTrackingVariable {
    
    public static Decimal caseCommentSpentTime;
    public static string caseCommentActivity;
     Public static Boolean isFirstTime=false;
    public CaseCommentTimeTrackingVariable(){
        
    }

}