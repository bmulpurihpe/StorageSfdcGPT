public class ManagementEscalationTriggerHandler {
    
    public void meOwnerUpdate(list<Management_Escalation__c> newList,set<id> caseSet,set<string> regions){
        Map<String,Id> regionWithManager = new Map<String,Id>();
        for(Escalation_Manager_Region_Mapping__c eMRegionMapping :[select id,Escalation_Manager__c,Region__c,Support_Profile__c from Escalation_Manager_Region_Mapping__c where Region__c =:regions]){
            string regionWithSupportProfile = eMRegionMapping.Region__c + eMRegionMapping.Support_Profile__c;
            regionWithManager.put(regionWithSupportProfile,eMRegionMapping.Escalation_Manager__c);
        }
        map<id,Case> idWithCase = new map<id,Case>([Select id,Support_Profile__c from Case where id =:caseSet]);
        
        for(Management_Escalation__c managementEscalation : newList){
            case parentCase = idWithCase.containsKey(managementEscalation.Case__c) ? idWithCase.get(managementEscalation.Case__c) : null; 
            if(parentCase != null && parentCase.Support_Profile__c != null && managementEscalation.Region__c != null){
                string regionWithSupportProfile = managementEscalation.Region__c + parentCase.Support_Profile__c;
                managementEscalation.ME_Owner__c = regionWithManager.containsKey(regionWithSupportProfile) ? regionWithManager.get(regionWithSupportProfile) : null;
                
            }
        }
    }
    
    public static void updateHighestSeverityOnAccount(Set<Id> accountIds) {
        if (accountIds.isEmpty()) {
            return;
        }
        
        // Map to store the highest severity for each Account
        Map<Id, String> highestSeverityMap = new Map<Id, String>();
        
        // Query all related Management_Escalation__c records for affected accounts
        List<Management_Escalation__c> managementEscalations = [
            SELECT Account__c, Severity__c 
            FROM Management_Escalation__c 
            WHERE Account__c IN :accountIds and Status__c != 'Closed'
        ];
        
        
        
        // Determine the highest severity per account
        if(managementEscalations != null){
            // Define severity order for comparison
            Map<String, Integer> severityOrder = new Map<String, Integer>{
                'Red' => 1,
                    'Yellow' => 2,
                    'Green' => 3
                    };
                        for (Management_Escalation__c esc : managementEscalations) {
                            if(isHighestSeverityFound(esc,esc.Account__c,highestSeverityMap,severityOrder)){
                                highestSeverityMap.put(esc.Account__c, esc.Severity__c);
                            }
                            
                        }
        }
        
        // Prepare Account updates
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Id accountId : accountIds) {
            accountsToUpdate.add(new Account(
                Id = accountId, 
                Management_Escalation_Severity__c = highestSeverityMap != null && highestSeverityMap.containsKey(accountId) ? highestSeverityMap.get(accountId) : ''
            ));
        }
        
        // Perform bulk update
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    public static void updateHighestSeverityOnCase(Set<Id> caseIds) {
        if (caseIds.isEmpty()) {
            return;
        }
        
        // Map to store the highest severity for each case
        Map<Id, String> highestSeverityMap = new Map<Id, String>();
        
        // Query all related Management_Escalation__c records for affected Cases
        List<Management_Escalation__c> managementEscalations = [
            SELECT Account__c, Severity__c,Case__c 
            FROM Management_Escalation__c 
            WHERE Case__c IN :caseIds and Status__c != 'Closed'
        ];
        
        
        
        // Determine the highest severity per Case
        if(managementEscalations != null){
            // Define severity order for comparison
            Map<String, Integer> severityOrder = new Map<String, Integer>{
                'Red' => 1,
                    'Yellow' => 2,
                    'Green' => 3
                    };
                        for (Management_Escalation__c esc : managementEscalations) { 
                            if(isHighestSeverityFound(esc,esc.Case__c,highestSeverityMap,severityOrder)){
                                highestSeverityMap.put(esc.Case__c, esc.Severity__c); 
                            }
                        }
        }
        
        // Prepare Case updates
        List<Case> caseToUpdate = new List<Case>();
        
        for (Id caseId : caseIds) {
            caseToUpdate.add(new Case(
                Id = caseId, 
                Management_Escalation_Severity__c = highestSeverityMap != null && highestSeverityMap.containsKey(caseId) ? highestSeverityMap.get(caseId) : ''
            ));
        }
        
        // Perform bulk update
        if (!caseToUpdate.isEmpty()) {
            update caseToUpdate;
        }
    }
    
    public static String getFieldLabel(String objectName, String fieldName) {
        // Get the object's schema dynamically
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        if (objType != null) {
            // Get the field's schema dynamically
            Schema.DescribeFieldResult fieldDescribe = objType.getDescribe().fields.getMap().get(fieldName).getDescribe();
            return fieldDescribe.getLabel();
        }
        
        return '';
    }
    
    public static String getErrorMessageForClosedStatus(Management_Escalation__c managementEscalation){
        string errorMessage = 'Management Escalation cannot be closed as the following required fields are missing: ';
        
        if(managementEscalation.Customer_Deliverable__c == null){
            errorMessage = errorMessage + ' ' + ManagementEscalationTriggerHandler.getFieldLabel('Management_Escalation__c' , 'Customer_Deliverable__c') + ',';  
        } 
        if(managementEscalation.Engagement_Level__c == null){
            errorMessage = errorMessage + ' ' + ManagementEscalationTriggerHandler.getFieldLabel('Management_Escalation__c' , 'Engagement_Level__c') + ',';  
        }  
        if(managementEscalation.Escalated_By__c == null){
            errorMessage = errorMessage + ' ' + ManagementEscalationTriggerHandler.getFieldLabel('Management_Escalation__c' , 'Escalated_By__c') + ',';  
        }  
        if(managementEscalation.Root_Cause__c == null){
            errorMessage = errorMessage + ' ' + ManagementEscalationTriggerHandler.getFieldLabel('Management_Escalation__c' , 'Root_Cause__c') + ',';  
        } 
        errorMessage = errorMessage.substring(0, errorMessage.length() - 1);
        return errorMessage;
    }
    
    public Static Boolean isHighestSeverityFound(Management_Escalation__c esc,string escParentId,  Map<Id, String> highestSeverityMap, Map<String, Integer> severityOrder){
        if (escParentId != null && esc.Severity__c != null) {
            if (!highestSeverityMap.containsKey(escParentId) || 
                severityOrder.get(esc.Severity__c) < severityOrder.get(highestSeverityMap.get(escParentId))) {
                    return true;
                }
        }
        return false; 
    }
    
    //This is a fix for Jira SFDC-1188 by Ntelkar
    public static void updateCaseEscalationType(Set<Id> caseIds) {
        List<Case> listOfCasesToUpdate = [SELECT Id, IsEscalated, caseEscalationType__c FROM Case WHERE Id IN :caseIds];
        if(listOfCasesToUpdate.size() > 0 && !listOfCasesToUpdate.isEmpty()) {
            for(Case c : listOfCasesToUpdate){
                if(c.caseEscalationType__c.contains('Not Escalated')){
                    c.caseEscalationType__c = 'Management Escalation';
                    c.IsEscalated = true;
                }
                else if(!c.caseEscalationType__c.contains('Management Escalation') ){
                    String caseEscTypes = c.caseEscalationType__c;
                    caseEscTypes = caseEscTypes+';'+'Management Escalation';
                    c.caseEscalationType__c = caseEscTypes;
                }
            }
            update listOfCasesToUpdate;
        }
    }


    //This is a fix for Jira SFDC-1188 by Ntelkar
    public static void updateCaseEscalationTypeRemoveME(Set<Id> caseIds) {
        List<Case> listOfCasesToUpdate = [SELECT Id, IsEscalated, caseEscalationType__c FROM Case WHERE Id IN :caseIds];
        if(listOfCasesToUpdate.size() > 0 && !listOfCasesToUpdate.isEmpty()) {
            for(Case c : listOfCasesToUpdate){
                if(c.caseEscalationType__c.contains('Management Escalation')){
                    String caseEscTypes = c.caseEscalationType__c;
                    if(c.caseEscalationType__c.remove('Management Escalation')==''){
                        c.caseEscalationType__c = 'Not Escalated';
                        c.IsEscalated = false;
                    }else
                        c.caseEscalationType__c = c.caseEscalationType__c.remove('Management Escalation');
                }
            }
            update listOfCasesToUpdate;
        }
    }
}