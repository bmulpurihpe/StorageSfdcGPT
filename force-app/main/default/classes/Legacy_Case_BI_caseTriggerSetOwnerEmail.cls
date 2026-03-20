/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-20-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger caseTriggerSetOwnerEmail on Case (before insert, before update)
public with sharing class Legacy_Case_BI_caseTriggerSetOwnerEmail implements TriggerAction.BeforeInsert
{     
    //caseUtility.runOnce Added by Exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295 
    public void beforeInsert(List<Case> newList){
    if(caseUtility.runOnce()){
        if(!UserInfo.getUserId().contains('00580000005J7vc') || Test.isRunningTest())
        {
            set<id> caseOwnerIds = new set<id>();
            for(Case triggerCase : newList){
                caseOwnerIds.add(triggerCase.OwnerId);
            }
            Map<id,User> userIdMap = new Map<id,User>([SELECT email from User where id in:caseOwnerIds]);
            
            for (Case triggerCase : newList)
            {
                //List<User> aUser;
                
                if (triggerCase.ownerid == null)
                {
                    triggerCase.caseOwnerEmail__c = null;
                }
                else
                {
                  //  aUser = [SELECT email from User where id = :triggerCase.ownerid];
                    
                    if (userIdMap.containsKey(triggerCase.ownerid))
                    {
                        triggerCase.caseOwnerEmail__c = userIdMap.get(triggerCase.ownerid).email;
                    }
                    else
                    {
                        triggerCase.caseOwnerEmail__c = null;
                    }
                }
            }
        }
    }
}
    
}