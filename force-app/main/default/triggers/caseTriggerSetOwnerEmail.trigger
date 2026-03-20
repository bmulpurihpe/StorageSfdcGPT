trigger caseTriggerSetOwnerEmail on Case (before insert, before update)
{     
    //caseUtility.runOnce Added by Exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295 
    if(caseUtility.runOnce()){
        if(!UserInfo.getUserId().contains('00580000005J7vc') || Test.isRunningTest())
        {
            set<id> caseOwnerIds = new set<id>();
            for(Case triggerCase : trigger.new){
                caseOwnerIds.add(triggerCase.OwnerId);
            }
            Map<id,User> userIdMap = new Map<id,User>([SELECT email from User where id in:caseOwnerIds]);
            
            for (Case triggerCase : trigger.new)
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