trigger createassetrecord on Opportunity (after insert, after update) {
    Set<String> hpeOpptyId = new Set<String>();
    if(trigger.isAfter && (trigger.IsInsert || trigger.isUpdate)){
        for(Opportunity o : trigger.new){
            if(o.HPE_Opportunity_ID__c != null){
                if(trigger.isUpdate){
                     Opportunity oldOpp = Trigger.oldMap.get(o.Id);
                     if(o.HPE_Opportunity_ID__c != oldOpp.HPE_Opportunity_ID__c){
                         if(!hpeOpptyId.contains(o.HPE_Opportunity_ID__c)){
                             hpeOpptyId.add(o.HPE_Opportunity_ID__c);
                         }
                     }
                }
                else{
                    if(!hpeOpptyId.contains(o.HPE_Opportunity_ID__c)){
                         hpeOpptyId.add(o.HPE_Opportunity_ID__c);
                     }
                }
                
            }
        }
        
        if(hpeOpptyId.size() >0){
            assetRecordCreation.assetCreate(hpeOpptyId);
        }
    }



}