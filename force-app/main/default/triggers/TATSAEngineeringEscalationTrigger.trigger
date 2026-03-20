trigger TATSAEngineeringEscalationTrigger on TA_TSA_Engineering_Escalation__c (before insert,before update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        //The below method will check whether the support profile user entered is valid or not
        TATSAEngineeringEscalationTriggerHandler.supportProfileValidation(trigger.new,null);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        List<TA_TSA_Engineering_Escalation__c> taTsaEscalationList = new List<TA_TSA_Engineering_Escalation__c>(); 
        map<id,String> taTSAEscalationOldListwithSupportProfile = new map<id,String>();
        // The below logic will check whether the field values TechnicalSubArea, Engineering Escalation, and Support Profile have been changed.
        //  If any of these fields are changed, the record will be validated through Support Profile Validation
        for(TA_TSA_Engineering_Escalation__c taTsaEscalation : trigger.new){
            TA_TSA_Engineering_Escalation__c oldTaTsaEscalation = trigger.oldmap.get(taTsaEscalation.id); 
            if((taTsaEscalation.TechnicalSubArea_Mapping__c != oldTaTsaEscalation.TechnicalSubArea_Mapping__c) || (taTsaEscalation.Engineering_Escalation_Mapping__c != oldTaTsaEscalation.Engineering_Escalation_Mapping__c)
               || (taTsaEscalation.Support_Profile__c != oldTaTsaEscalation.Support_Profile__c)){
                   taTSAEscalationOldListwithSupportProfile.put(taTsaEscalation.id,oldTaTsaEscalation.Support_Profile__c);
                   taTsaEscalationList.add(taTsaEscalation);
               }
            
        }
        if(taTsaEscalationList.size()>0){
            //The below method will check whether the support profile user entered is valid or not
            TATSAEngineeringEscalationTriggerHandler.supportProfileValidation(taTsaEscalationList,taTSAEscalationOldListwithSupportProfile);
        }
    }
}