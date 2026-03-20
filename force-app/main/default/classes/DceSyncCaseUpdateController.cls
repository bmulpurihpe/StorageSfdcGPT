public class DceSyncCaseUpdateController {
    
    public static void dceSyncCaseUpdate(List<DCE_Case_Sync__c> newList,Map<Id,DCE_Case_Sync__c> oldMap){
        set<Id> parentIds=new set<Id>();
        List<Case> updateCaseList =new List<case>();
        for(DCE_Case_Sync__c dce:newList){
            if(dce.DCE_Sync__c!=oldMap.get(dce.id).DCE_Sync__c && dce.DCE_Sync__c =='Success' ){
                parentIds.add(dce.Case__c);  system.debug(' *** line 8 case ids ' + parentIds);
            }
        }
        List<case> caselist=[select id,DCE_Sync__c from case where ID IN:parentIds];
        for(case caserec:caselist){
            if(caserec.DCE_Sync__c == false){
                caserec.DCE_Sync__c = true;
            }
            updateCaseList.add(caserec);
        }
        if(!updateCaseList.isempty()){
            update updateCaseList;
        }
    }
}