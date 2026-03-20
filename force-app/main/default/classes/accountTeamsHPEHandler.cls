public class accountTeamsHPEHandler{
    public static boolean avoidRecursion = true;

    
    public static void updateRecords(Set<Id> aIds){
        avoidRecursion = false;
        List<Account_Teams_HPE__c> lst = [select Id, MDCP_Id__c, Active__c , Account__c from Account_Teams_HPE__c where Id in: aIds];
        set<string> acctId = new set<string>();
        for(Account_Teams_HPE__c act : lst){
            if(!acctId.contains(act.MDCP_Id__c)){
                acctId.add(act.MDCP_Id__c);
            }
        }
        system.debug( ' *** account team ids ' + aIds);
        system.debug(' *** mdcp id' + acctId);
        List<Account> lstAccount = [select Id, Account_STID__c, Account_ST_ID__c from Account where Account_STID__c in: acctId or Account_ST_ID__c in: acctId];
        List<Account_Teams_HPE__c> updtLst = new List<Account_Teams_HPE__c>();
        for(Account_Teams_HPE__c act : lst){
            for(Account a: lstAccount){
                if((act.MDCP_Id__c == a.Account_STID__c  || act.MDCP_Id__c == a.Account_ST_ID__c )&& act.Active__c == True){
                    act.Account__c = a.Id;
                }
                else if((act.MDCP_Id__c == a.Account_STID__c  || act.MDCP_Id__c == a.Account_ST_ID__c ) && act.Active__c == False){
                    act.Account__c = null;
                }
            }
            updtLst.add(act);
        }
        system.debug(' *** udpate lst ' + updtLst);
        if(updtLst.size() >0){
            update updtLst;
           
        }
    }
}