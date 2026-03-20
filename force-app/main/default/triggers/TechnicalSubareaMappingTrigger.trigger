trigger TechnicalSubareaMappingTrigger on TechnicalSubArea_Mappings__c (before Update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        set<id> tsaIdset = new set<id>();
        map<id,String> tsaWithChangedProfile = new map<id,String>();
        
        //Collecting the values that is removed from the support profile
        for(TechnicalSubArea_Mappings__c technicalSubarea :Trigger.new){
            TechnicalSubArea_Mappings__c oldTechnicalSubarea = trigger.oldMap.get(technicalSubarea.id);
            if(technicalSubarea.Support_Profile__c != oldTechnicalSubarea.Support_Profile__c && 
               ( (technicalSubarea.Support_Profile__c != null && oldTechnicalSubarea.Support_Profile__c != null) || 
                (technicalSubarea.Support_Profile__c == null && oldTechnicalSubarea.Support_Profile__c != null) ) ) {
                    tsaIdset.add(technicalSubarea.id);
                    for(string supportProfile : oldTechnicalSubarea.Support_Profile__c.split(';')){
                        if(technicalSubarea.Support_Profile__c != null){
                            if(!technicalSubarea.Support_Profile__c.contains(supportProfile)){
                                if(tsaWithChangedProfile.containsKey(technicalSubarea.id)){
                                    string modifiedSupportProfile = tsaWithChangedProfile.get(technicalSubarea.id) + ';' + supportProfile;
                                    tsaWithChangedProfile.put(technicalSubarea.id,modifiedSupportProfile);
                                }
                                else{
                                    tsaWithChangedProfile.put(technicalSubarea.id,supportProfile);
                                }
                            }
                        }
                        else{
                            if(tsaWithChangedProfile.containsKey(technicalSubarea.id)){
                                string modifiedSupportProfile = tsaWithChangedProfile.get(technicalSubarea.id) + ';' + supportProfile;
                                tsaWithChangedProfile.put(technicalSubarea.id,modifiedSupportProfile);
                            }
                            else{
                                tsaWithChangedProfile.put(technicalSubarea.id,supportProfile);
                            }
                            
                        }
                    }
                    
                }  
        }
        system.debug('tsaWithChangedProfile'+tsaWithChangedProfile);
        map<id,String> tsaWithSupportProfile = new map<id,String>(); 
        map<id,String> tsaWithTATSAName = new map<id,String>();
        //Searching taTSaEngineering escalation record for the removed support profile
        if(tsaIdset.size()>0){
            for(TA_TSA_Engineering_Escalation__c tsaEscalation :[select id,Name,Support_Profile__c,TechnicalSubArea_Mapping__c from TA_TSA_Engineering_Escalation__c where TechnicalSubArea_Mapping__c =: tsaIdset and Support_Profile__c != null]){
                if(tsaWithSupportProfile.containsKey(tsaEscalation.TechnicalSubArea_Mapping__c)){
                    string modifiedSupportProfile = tsaWithSupportProfile.get(tsaEscalation.TechnicalSubArea_Mapping__c).contains(tsaEscalation.Support_Profile__c) ? tsaWithSupportProfile.get(tsaEscalation.TechnicalSubArea_Mapping__c) : tsaWithSupportProfile.get(tsaEscalation.TechnicalSubArea_Mapping__c) + ';' + tsaEscalation.Support_Profile__c;
                    tsaWithSupportProfile.put(tsaEscalation.TechnicalSubArea_Mapping__c,modifiedSupportProfile);
                    string modifiedTATSANames = tsaWithTATSAName.get(tsaEscalation.TechnicalSubArea_Mapping__c).contains(tsaEscalation.Name) ? tsaWithTATSAName.get(tsaEscalation.TechnicalSubArea_Mapping__c) : tsaWithTATSAName.get(tsaEscalation.TechnicalSubArea_Mapping__c) + ';' + tsaEscalation.Name;
                    tsaWithTATSAName.put(tsaEscalation.TechnicalSubArea_Mapping__c,modifiedTATSANames);
                }
                else{
                    tsaWithSupportProfile.put(tsaEscalation.TechnicalSubArea_Mapping__c,tsaEscalation.Support_Profile__c);   
                    tsaWithTATSAName.put(tsaEscalation.TechnicalSubArea_Mapping__c,tsaEscalation.Name);
                }
            }
        }
        
        system.debug('tsaWithSupportProfile'+tsaWithSupportProfile);
        
        // The below logic will trigger the error if try to remove the support profile that has related taTSA-Escalation
        for(TechnicalSubArea_Mappings__c technicalSubarea :Trigger.new){
            if(tsaWithChangedProfile.containsKey(technicalSubarea.id) && tsaWithSupportProfile.containsKey(technicalSubarea.id)){
                for(string changedSupportProfile : tsaWithChangedProfile.get(technicalSubarea.id).split(';')){
                    string tsaSupportProfile = tsaWithSupportProfile.get(technicalSubarea.id);
                    if(tsaSupportProfile != null){
                        if(tsaWithSupportProfile.get(technicalSubarea.id).contains(changedSupportProfile)){
                            string SupportProfile = tsaWithSupportProfile.get(technicalSubarea.id).replace(';', ' , ');
                            string TATSANameList = tsaWithTATSAName.get(technicalSubarea.id).replace(';', ' , ');
                            technicalSubarea.Support_Profile__c.addError(technicalSubarea.Name + ' Support Profile [' + SupportProfile + '] is currently associated with TATSAEngineering records [' + TATSANameList + ']. Please modify or remove these associations before attempting to change the support profile.'); 
                        }
                    }
                }
            } 
        }
        
    }
}