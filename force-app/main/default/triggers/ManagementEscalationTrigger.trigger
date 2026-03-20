trigger ManagementEscalationTrigger on Management_Escalation__c (before insert,before update,after insert,after update,after undelete,after delete) {
    // Variable Initialisation
    set<string> regions = new set<string>(); 
    set<id> caseSet = new set<id>();
    list<Management_Escalation__c> newList = new list<Management_Escalation__c>(); 
    
    // Set to store affected Account IDs and Case IDs
    Set<Id> accountIds = new Set<Id>();
    Set<Id> caseIds = new Set<Id>();
    
    // Instantiate the handler class
    ManagementEscalationTriggerHandler handler = new ManagementEscalationTriggerHandler();
    
    if(trigger.isBefore && trigger.isInsert){
        //	Update record Collection
        for(Management_Escalation__c managementEscalation : trigger.new){
            if(managementEscalation.Case__c != null && managementEscalation.Region__c != null && managementEscalation.ME_Owner__c == null){
                caseSet.add(managementEscalation.Case__c);  
                regions.add(managementEscalation.Region__c);
                newList.add(managementEscalation);
            }
            
            //	SFDC-1033 Add error message when escalation record is closed with required fields
            if(managementEscalation.Status__c == 'Closed' && 
               (managementEscalation.Customer_Deliverable__c == null || managementEscalation.Engagement_Level__c == null 
                || managementEscalation.Escalated_By__c == null || managementEscalation.Root_Cause__c == null)){
                    managementEscalation.addError(ManagementEscalationTriggerHandler.getErrorMessageForClosedStatus(managementEscalation));
                } 
        }
        if(newList.size() > 0){
            handler.meOwnerUpdate(newList,caseSet,regions);
        }
        
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        //	Update record Collection
        for(Management_Escalation__c managementEscalation : trigger.new){
            Management_Escalation__c oldManagementEscalation = trigger.oldMap.get(managementEscalation.id);
            if(managementEscalation.Region__c != oldManagementEscalation.Region__c && managementEscalation.Region__c != null){
                caseSet.add(managementEscalation.Case__c);  
                regions.add(managementEscalation.Region__c);
                newList.add(managementEscalation); 
            }
            
            //	SFDC-1033 Add error message when escalation record is closed with required fields
            if(oldManagementEscalation.Status__c != managementEscalation.Status__c && managementEscalation.Status__c == 'Closed' && 
               (managementEscalation.Customer_Deliverable__c == null || managementEscalation.Engagement_Level__c == null 
                || managementEscalation.Escalated_By__c == null || managementEscalation.Root_Cause__c == null)){
                    managementEscalation.addError(ManagementEscalationTriggerHandler.getErrorMessageForClosedStatus(managementEscalation));
                }
            
        }
        if(newList.size() > 0){
            handler.meOwnerUpdate(newList,caseSet,regions);
        }
    }
    if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
        
        
        // Collect related Account IDs from inserted/updated Management Escalation records
        for (Management_Escalation__c mangementEscalation : Trigger.new) {
            if (mangementEscalation.Account__c != null) {
                accountIds.add(mangementEscalation.Account__c);
            }
            if (mangementEscalation.Case__c != null) {
                caseIds.add(mangementEscalation.Case__c);
            }
        }
        
        if (!accountIds.isEmpty()) {
            ManagementEscalationTriggerHandler.updateHighestSeverityOnAccount(accountIds);
        }
        if (!caseIds.isEmpty()) {
            ManagementEscalationTriggerHandler.updateHighestSeverityOnCase(caseIds);
            //This is a fix for Jira SFDC-1188 by Ntelkar
            ManagementEscalationTriggerHandler.updateCaseEscalationType(caseIds);
        }
        
    }
    
    if(trigger.isAfter &&  trigger.isDelete){
        
        // Collect related Account IDs from inserted/updated Management Escalation records
        for (Management_Escalation__c mangementEscalation : Trigger.old) {
            if (mangementEscalation.Account__c != null) {
                accountIds.add(mangementEscalation.Account__c);
            }
            if (mangementEscalation.Case__c != null) {
                caseIds.add(mangementEscalation.Case__c);
            }
        }
        
        if (!accountIds.isEmpty()) {
            ManagementEscalationTriggerHandler.updateHighestSeverityOnAccount(accountIds);
        }
        if (!caseIds.isEmpty()) {
            ManagementEscalationTriggerHandler.updateHighestSeverityOnCase(caseIds);
            //This is a fix for Jira SFDC-1188 by Ntelkar
            ManagementEscalationTriggerHandler.updateCaseEscalationTypeRemoveME(caseIds);
        }
        
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        
        // Collect related Account IDs from inserted/updated Management Escalation records
        for (Management_Escalation__c mangementEscalation : Trigger.new) {
            Management_Escalation__c oldMangementEscalation = trigger.oldmap.get(mangementEscalation.id); 
            if ( mangementEscalation.Account__c != oldMangementEscalation.Account__c || mangementEscalation.Severity__c != oldMangementEscalation.Severity__c
                || (mangementEscalation.Status__c != oldMangementEscalation.Status__c) && (mangementEscalation.Status__c == 'Closed' || oldMangementEscalation.Status__c == 'Closed')) {
                    
                    if(mangementEscalation.Account__c != null)
                        accountIds.add(mangementEscalation.Account__c);
                    
                    if(oldMangementEscalation.Account__c != null)
                        accountIds.add(oldMangementEscalation.Account__c);
                }
            if ( mangementEscalation.Case__c != oldMangementEscalation.Case__c || mangementEscalation.Severity__c != oldMangementEscalation.Severity__c
                || (mangementEscalation.Status__c != oldMangementEscalation.Status__c) && (mangementEscalation.Status__c == 'Closed' || oldMangementEscalation.Status__c == 'Closed')) {
                    
                    if(mangementEscalation.Case__c != null)
                        caseIds.add(mangementEscalation.Case__c);
                    
                    if(oldMangementEscalation.Case__c != null)
                        caseIds.add(oldMangementEscalation.Case__c);
                }
            
        }
        
        if (!accountIds.isEmpty()) {
            ManagementEscalationTriggerHandler.updateHighestSeverityOnAccount(accountIds);
        }
        if (!caseIds.isEmpty()) {
            ManagementEscalationTriggerHandler.updateHighestSeverityOnCase(caseIds);
        }
    }
}