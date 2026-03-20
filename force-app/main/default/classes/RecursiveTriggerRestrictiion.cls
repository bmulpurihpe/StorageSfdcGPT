public class RecursiveTriggerRestrictiion {
    public static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }

    public static String currentCaseStatus;
    public static String currentPlanOfAction;

    public static Map<String, Id> caseTeamRolesMap; 
    public static Map<String, Id> getCaseTeamRolesMap() {
        caseTeamRolesMap = new Map<String, Id>();
        for(CaseTeamRole ctr : [SELECT Id,Name from CaseTeamRole 
                                WHERE Name IN ('Alternate Contact Name','Proactive Support Manager')]){
            caseTeamRolesMap.put(ctr.Name, ctr.Id);
        }
        return caseTeamRolesMap;
    }

    public static Map<Id, String> caseIdwithAccName;
    public static Map<Id, String> getCaseIdwithAccName(Set<Id> caseIds) {
        caseIdwithAccName = new Map <id, String>();
        for (Case caseRecord : [SELECT Id, AccountId, Account.name from Case  WHERE Id IN :caseIds]) {
            caseIdwithAccName.put(caseRecord.Id,caseRecord.Account.name);
        }
        return caseIdwithAccName;
    }
}