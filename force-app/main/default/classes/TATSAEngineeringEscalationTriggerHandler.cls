public class TATSAEngineeringEscalationTriggerHandler {
    public static void supportProfileValidation(list<TA_TSA_Engineering_Escalation__c> newTATSaEscalation,Map<id,String> oldTATSAEscalation){
        
        set<id> technicalSubAreaIdSet = new set<id>(); 
        map<id,string> tsaIdSupportProfileMap = new map<id,string>(); 
        string soqlWhereClause = '';
        List<string> deduplicatedSoqlList = new List<string>();
        
        //Technical subarea ID is collected to verify if the 'TATSA Engineering Escalation' support profile is valid
        //The SOQL WHERE clause is made to retrieve the TATSA Engineering Escalation record to check for duplicates.
        for(TA_TSA_Engineering_Escalation__c taTsaEngineeringEscalation : newTATSaEscalation){
            technicalSubAreaIdSet.add(taTsaEngineeringEscalation.TechnicalSubArea_Mapping__c);
            string technicalSubAreaId = taTsaEngineeringEscalation.TechnicalSubArea_Mapping__c; 
            string engineeringEscalationId = taTsaEngineeringEscalation.Engineering_Escalation_Mapping__c;
            string keyVal = technicalSubAreaId + engineeringEscalationId;
            
            if(!deduplicatedSoqlList.contains(keyVal)){
                soqlWhereClause = soqlWhereClause + '( TechnicalSubArea_Mapping__c =\'' + taTsaEngineeringEscalation.TechnicalSubArea_Mapping__c + '\' AND Engineering_Escalation_Mapping__c = \'' + taTsaEngineeringEscalation.Engineering_Escalation_Mapping__c +  '\' ) OR';
                deduplicatedSoqlList.add(keyVal);
            }
        }
        
        //Technical subarea support profile collection.
        for(TechnicalSubArea_Mappings__c technicalSubArea : [select id,Support_Profile__c from TechnicalSubArea_Mappings__c where id=:technicalSubAreaIdSet]){
            if(technicalSubArea.Support_Profile__c != null)
                tsaIdSupportProfileMap.put(technicalSubArea.Id,technicalSubArea.Support_Profile__c);
        }
        
        string trimmedSoqlWhereClause =  soqlWhereClause.removeEnd('OR');
        
        
        List<TA_TSA_Engineering_Escalation__c> taTsaEngineeringEscalationList = Database.query('SELECT Id,Engineering_Escalation_Mapping__c,TechnicalSubArea_Mapping__c,Support_Profile__c FROM TA_TSA_Engineering_Escalation__c WHERE ' + trimmedSoqlWhereClause );
        system.debug('sobjList ==>' + taTsaEngineeringEscalationList);
        Map<string,String> tsaEscalationWithSupportProfileMap = new Map<string,String>();
        
        //TATSA Engineering escalation collection.
        if(taTsaEngineeringEscalationList.size() > 0){
            for(TA_TSA_Engineering_Escalation__c taTsaEngineeringEscalation : taTsaEngineeringEscalationList){
                string technicalSubAreaId = taTsaEngineeringEscalation.TechnicalSubArea_Mapping__c; 
                string engineeringEscalationId = taTsaEngineeringEscalation.Engineering_Escalation_Mapping__c;
                string keyVal = technicalSubAreaId + engineeringEscalationId;
                if(tsaEscalationWithSupportProfileMap.containsKey(keyVal)){
                    string modifiedSupportProfile = tsaEscalationWithSupportProfileMap.get(keyVal) + ';' + taTsaEngineeringEscalation.Support_Profile__c;
                    tsaEscalationWithSupportProfileMap.put(keyVal,modifiedSupportProfile);
                }
                else{
                    tsaEscalationWithSupportProfileMap.put(keyVal, taTsaEngineeringEscalation.Support_Profile__c);  
                }
            }
        }
        
        //The below logic checks whether the user has entered a valid support profile for the respective Technical Subarea; otherwise, an error will be triggered.
        //The below logic also checks the TATSA engineering escalation duplicates
        for(TA_TSA_Engineering_Escalation__c taTsaEngineeringEscalation : newTATSaEscalation){
            string tsaSupportProfile = null;
            
            if(tsaIdSupportProfileMap.containsKey(taTsaEngineeringEscalation.TechnicalSubArea_Mapping__c)){
                tsaSupportProfile = tsaIdSupportProfileMap.get(taTsaEngineeringEscalation.TechnicalSubArea_Mapping__c);
            }
            
            list<string> taTsaEscalationSupporProfile = new list<string>();
            
            if(taTsaEngineeringEscalation.Support_Profile__c != null){
                taTsaEscalationSupporProfile = taTsaEngineeringEscalation.Support_Profile__c.split(';');  
            }
            
            if(taTsaEscalationSupporProfile.size() > 0 && tsaSupportProfile != null){
                for(String currentSupportProfile : taTsaEscalationSupporProfile){
                    if(!tsaSupportProfile.contains(currentSupportProfile)){
                        string trimmedSupportProfile = tsaSupportProfile.replace(';', ' , ');
                        taTsaEngineeringEscalation.Support_Profile__c.addError('Entered Technical Subarea Mapping supports only "'  + trimmedSupportProfile + '"');
                       
                    }               
                }
            }
            system.debug('tsaSupportProfile =>'+tsaSupportProfile);
            system.debug('taTsaEngineeringEscalation.Support_Profile__c =>'+taTsaEngineeringEscalation.Support_Profile__c);
            
            if(tsaSupportProfile != null && taTsaEngineeringEscalation.Support_Profile__c == null){
                string trimmedSupportProfile = tsaSupportProfile.replace(';', ' , ');
                taTsaEngineeringEscalation.Support_Profile__c.addError('Entered Technical Subarea Mapping supports only "' + trimmedSupportProfile + '"');
               
            }
            
            if((tsaSupportProfile == null && taTsaEngineeringEscalation.Support_Profile__c == null) || ((tsaSupportProfile == null && taTsaEngineeringEscalation.Support_Profile__c != null))){
                taTsaEngineeringEscalation.Support_Profile__c.addError('Entered Technical Subarea Mapping does not have any support profile associated');
               
            }
            
            string technicalSubAreaId = taTsaEngineeringEscalation.TechnicalSubArea_Mapping__c; 
            string engineeringEscalationId = taTsaEngineeringEscalation.Engineering_Escalation_Mapping__c;
            string keyVal = technicalSubAreaId + engineeringEscalationId;
            system.debug('keyVal=>' + keyVal);
            system.debug('tsaEscalationWithSupportProfileMap==>'+tsaEscalationWithSupportProfileMap);
            system.debug('taTsaEscalationSupporProfile==>'+taTsaEscalationSupporProfile);
            if(tsaEscalationWithSupportProfileMap.containsKey(keyVal) && taTsaEscalationSupporProfile != null){
                for(String currentSupportProfile : taTsaEscalationSupporProfile){
                    if(oldTATSAEscalation != null){
                        if(oldTATSAEscalation.get(taTsaEngineeringEscalation.id).contains(currentSupportProfile)){
                            continue;
                        }
                    }
                    string supportProfile = tsaEscalationWithSupportProfileMap.get(keyVal);
                    system.debug('currentSupportProfile==>'+currentSupportProfile);
                    if(supportProfile != null){
                        if(tsaEscalationWithSupportProfileMap.get(keyVal).contains(currentSupportProfile)){
                            string trimmedSupportProfile = tsaEscalationWithSupportProfileMap.get(keyVal).replace(';', ' , ');
                            string trimmedSupportProfile1 = trimmedSupportProfile.replace('null ,', '');
                            // taTsaEngineeringEscalation.Support_Profile__c.addError('Entered Support Profile Combination "' + trimmedSupportProfile + '" already exists'); 
                            taTsaEngineeringEscalation.Support_Profile__c.addError('TA/TSA + Engneering Escalation + Support profile combination already exist');
                           
                        }
                    }
                }
            }
          
        }  
    }
}