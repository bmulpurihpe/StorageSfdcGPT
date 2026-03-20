/*******
* Assign team members to Account based on the zip Code
* author:     Yesha Benegal
* createddate: 4/3/2020
* JIRA: ESS-43860
*
*****/

global class assignHPETeamZipCode implements Database.Batchable<sObject>{
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    global assignHPETeamZipCode (String q){
        
        Query=q; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug(' *** ' +query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        Set<string> sIdZipCode = new Set<string>();
        Set<string> sSTID = new Set<string>();
        Set<string> chkId = new set<string>();
        set<string> sZipC = new set<String>();
        set<string> empID = new set<string>();
        List<Account_Teams_HPE_Details__c> actTeamDetailLst = new List<Account_Teams_HPE_Details__c>();
        
        
        for(Account act : scope){
            if(act.BillingPostalCode != null){
            
                if(act.BillingPostalCode.contains('-') && act.BillingPostalCode.length() > 2){ system.debug(' in if ****');
                    String[] ZC = act.BillingPostalCode.split('-');
                    
                    if(!sZipC.contains(ZC[0])){
                        sZipC.add(ZC[0]);
                    }
                }
                else{ 
                    if(!sZipC.contains(act.BillingPostalCode)){
                        sZipC.add(act.BillingPostalCode);
                    }
                }
            }
        }
        List<Account_Teams_Zipcode_HPE__c> actTeamZipCodeLst = [select Id,ST_ID__c, Zipcode__c  from Account_Teams_Zipcode_HPE__c where ST_ID__c != null and Zipcode__c  in: sZipC];
        
        for(Account_Teams_Zipcode_HPE__c ac : actTeamZipCodeLst ){
            if(!sIdZipCode.contains(ac.ST_ID__c )){
                sSTID.add(ac.ST_ID__c);
                sIdZipCode.add(ac.Zipcode__c);
            }
        
        }
        List<Account_Teams_HPE__c> actTeamHPELst = [select Id, Active__c, Sales_Territory_ID__c,Employee_ID__c  from Account_Teams_HPE__c where Active__c =: True and Sales_Territory_ID__c in: sSTID];
        
        for(Account act : scope){
           
            if(act.BillingPostalCode != null){
                
                String str1 = act.BillingPostalCode;
                if(str1.contains('-')){
                    str1 = str1.left(5);
                }
                
                if( sIdZipCode.contains(str1)){ //act.Account_STID__c == null &&
                    if(actTeamHPELst.size() > 0){
                        for(Account_Teams_Zipcode_HPE__c  actZC : actTeamZipCodeLst){
                            for(Account_Teams_HPE__c actteam : actTeamHPELst){
                                
                                
                                if(actteam.Sales_Territory_ID__c == actZC.ST_ID__c &&  str1 == actZC.Zipcode__c){ // && act.Account_STID__c == null
                                    Account_Teams_HPE_Details__c atd = new Account_Teams_HPE_Details__c();
                                    atd.Account__c = act.Id;
                                    atd.Account_Teams_HPE__c = actteam.Id;
                                    string str = string.valueOf(act.Id) + string.valueOf(actteam.Id);
                                    atd.Acct_Id__c = string.valueOf(act.Id) + string.valueOf(actteam.Id);
                                    atd.Non_Member__c  = false;
                                    atd.Employee_ID__c = actteam.Employee_ID__c;
                                    if(!chkId.contains(str)){                       
                                        actTeamDetailLst.add(atd);
                                        chkId.add(str);
                                        empID.add(act.Id);
                                    }                                
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        
        /*for(Account a : scope){
           // s.put(Field,Value); 
            for(Account_Teams_HPE__c actteam : actTeamHPELst){
                if((actteam.MDCP_Id__c == a.Account_STID__c  || actteam.MDCP_Id__c == a.Account_ST_ID__c )){
                    Account_Teams_HPE_Details__c atd = new Account_Teams_HPE_Details__c();
                    atd.Account__c = a.Id;
                    atd.Account_Teams_HPE__c = actteam.Id;
                    string str = string.valueOf(a.Id) + string.valueOf(actteam.Id);
                    atd.Acct_Id__c = string.valueOf(a.Id) + string.valueOf(actteam.Id);
                    if(!chkId.contains(str)){                       
                        actTeamDetailLst.add(atd);
                        chkId.add(str);
                    }
                }
           }
        }*/
        
        List<Account_Teams_HPE_Details__c> updtLst = new List<Account_Teams_HPE_Details__c>();
        
        if(actTeamDetailLst.size() > 0){
            List<Account_Teams_HPE_Details__c> actTeamDetailExistLst = [select Id, Acct_Id__c, Account__c ,Non_Member__c ,Employee_ID__c from Account_Teams_HPE_Details__c where (Acct_Id__c IN: chkId OR Account__c IN: empID)];
            system.debug(' **** ' + actTeamDetailExistLst.size() + ' *** '+ chkId);
            if(actTeamDetailExistLst.size() > 0){
                for(Account_Teams_HPE_Details__c atd : actTeamDetailExistLst ){
                    for(Integer i=0; i<actTeamDetailLst.size(); i++){
                    
                        if(actTeamDetailLst[i].Acct_Id__c == atd.Acct_Id__c || (actTeamDetailLst[i].Account__c == atd.Account__c && actTeamDetailLst[i].Employee_ID__c == atd.Employee_ID__c)){
                            actTeamDetailLst.remove(i);
                            if(atd.Non_Member__c  ==  True){
                                atd.Non_Member__c  = false;
                                updtLst.add(atd);
                            }
                        }
                    }
                }
            }
        }
       
        if(actTeamDetailLst.size() > 0){
            insert actTeamDetailLst;
        }
        if(updtLst.size() > 0){
            update updtLst;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}