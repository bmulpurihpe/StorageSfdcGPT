/*******
* Assign team members to Account based on the ST ID
* author:     Yesha Benegal
* createddate: 4/1/2020
* JIRA: ESS-43860
*
*****/
global class assignHPETeam implements Database.Batchable<sObject>{
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    global assignHPETeam(String q){
    
        Query=q; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        set<string> sTID = new Set<String>();
        for(Account act : scope){
            if(!sTID.contains(act.Account_STID__c)){
                sTID.add(act.Account_STID__c);
            }
        }
        List<Account_Teams_HPE__c> actTeamHPELst = [select Id, Active__c, Sales_Territory_ID__c , Employee_ID__c from Account_Teams_HPE__c where Sales_Territory_ID__c  in: sTID and Active__c =: True];
        List<Account_Teams_HPE_Details__c> actTeamDetailLst = new List<Account_Teams_HPE_Details__c>();
        List<Account_Teams_HPE_Details__c> actTeamDetailExistLst = [select Id, Acct_Id__c , Employee_ID__c from Account_Teams_HPE_Details__c where Account_ST_Id__c in: sTID ];
        Set<string> chkId = new set<string>();
        List<Account_Teams_HPE_Details__c> UpdtactTeamDetail = new List<Account_Teams_HPE_Details__c>();
        
        for(Account a : scope){
           // s.put(Field,Value); 
            for(Account_Teams_HPE__c actteam : actTeamHPELst){
                if((actteam.Sales_Territory_ID__c  == a.Account_STID__c)){
                    Account_Teams_HPE_Details__c atd = new Account_Teams_HPE_Details__c();
                    atd.Account__c = a.Id;
                    atd.Account_Teams_HPE__c = actteam.Id;
                    string str = string.valueOf(a.Id) + string.valueOf(actteam.Id);
                    atd.Acct_Id__c = string.valueOf(a.Id) + string.valueOf(actteam.Id);
                    atd.Employee_ID__c = actteam.Employee_ID__c;
                    atd.Non_Member__c =  true;
                    if(!chkId.contains(str)){                       
                        actTeamDetailLst.add(atd);
                        chkId.add(str);
                    }
                }
           }
        }
        
        if(actTeamDetailExistLst.size() > 0){
            for(Account_Teams_HPE_Details__c atd : actTeamDetailExistLst ){
                for(Integer i=0; i<actTeamDetailLst.size(); i++){
                    if(actTeamDetailLst[i].Acct_Id__c == atd.Acct_Id__c){
                        
                        actTeamDetailLst.remove(i);
                    }
                }
            }
        }
        
        if(actTeamDetailLst.size() > 0){
            insert actTeamDetailLst;
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}