trigger AccountTeam on Account_Team__c (before insert, before update) {
    
    Set<String> ActmMdcpIds = new Set<String>();
    for(Account_team__c actm : Trigger.new){
        
        ActmMdcpIds.add(actm.MDCP_ID__c);
               
    }
List<Account> ActWithMdcpid = [select id,mdcp_org_id__C from Account where mdcp_org_id__C IN:ActmMdcpIds limit 50000];
Map<String,Account> actMap = new Map<String,Account>();
for(Account a : ActWithMdcpid)
{
    actMap.put(a.mdcp_org_id__C, a);
}
 
        for (Account_Team__c actm :trigger.new ){
       Account act = actMap.get(actm.MDCP_ID__c);
       if(act != null)
                actm.account__c = act.id;
            
        }     
}