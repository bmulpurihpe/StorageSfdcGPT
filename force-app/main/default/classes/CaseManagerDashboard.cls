public with sharing class CaseManagerDashboard {
    private static final Set<String> SUPPORTED_SUPPORT_PROFILES =
        new Set<String>{ 'Alletra MP Block', 'Alletra MP File' };
    @AuraEnabled()
    public static List<CaseEscalations> getEscalations(String caseId){
        List<CaseEscalations> caseEscalations = new List<CaseEscalations>();
        for(caseEscalation__c engineerEsc : [SELECT Id, Name, caseEscalationJIRALink__c, 
                                                    caseEscalationJIRAId__c, Jira_Assignee__c, Jira_Status__c
                                             FROM caseEscalation__c
                                             WHERE caseEscalationCase__c = :caseId 
                                                AND caseEscalationJIRAId__c != null
                                                AND Case_Escalation_Type_Definition_Name__c <> 'Executive Escalation']) {
            CaseEscalations caseEsc = new CaseEscalations();
            caseEsc.Id = engineerEsc.caseEscalationJIRAId__c;
            caseEsc.Name = engineerEsc.caseEscalationJIRAId__c;
            caseEsc.Status = engineerEsc.Jira_Status__c;
            caseEsc.Assignee = engineerEsc.Jira_Assignee__c;
            caseEsc.Url = engineerEsc.caseEscalationJIRALink__c;    
            caseEsc.EscalationType = 'Engineering Escalation';     
            caseEscalations.add(caseEsc);                                   
        }
        for(Management_Escalation__c mgmtEsc : [SELECT Id, Name, Status__c, ME_Owner__r.Name
                                                FROM Management_Escalation__c
                                                WHERE Case__c = :caseId]) {
            CaseEscalations caseEsc = new CaseEscalations();
            caseEsc.Id = mgmtEsc.Id;
            caseEsc.Name = mgmtEsc.Name;
            caseEsc.Status = mgmtEsc.Status__c;
            caseEsc.Assignee = mgmtEsc.ME_Owner__r.Name;
            caseEsc.Url = mgmtEsc.Name;
            caseEsc.EscalationType = 'Management Escalation';
            caseEscalations.add(caseEsc);
        }
        return caseEscalations;
    }

    @AuraEnabled()
    public static List<CaseConsults> getConsultsBugs(String caseId){
        List<CaseConsults> caseConsultsList = new List<CaseConsults>();
        for(Bug__c caseConsultsBug : [SELECT Id, Name, BugID__c, Bugzilla__c
                               FROM Bug__c
                               WHERE Case__c = :caseId AND BugID__c like 'CONS%']) {
            CaseConsults caseBug = new CaseConsults();
            caseBug.Id = caseConsultsBug.Id;
            caseBug.Name = caseConsultsBug.BugID__c;
            caseBug.Url = caseConsultsBug.Bugzilla__c;
            caseConsultsList.add(caseBug);                                   
        }
        for(ESCA_Consult__c caseconsult : [SELECT Id, Name, Case__c, Action_Type__c, Comments__c, OTC_Number__c, OTC_URL__c, Priority__c, Status__c, Subject__c 
                    FROM ESCA_Consult__c 
                    WHERE Case__c = :caseId AND Case__r.Support_Profile__c IN :SUPPORTED_SUPPORT_PROFILES]) {
            CaseConsults caseESCAConsult = new CaseConsults();
            caseESCAConsult.Id = caseConsult.Id;
            caseESCAConsult.Name = caseConsult.OTC_Number__c;
            caseESCAConsult.Url = caseConsult.OTC_URL__c;
            caseConsultsList.add(caseESCAConsult);                                   
        }
        return caseConsultsList;
    }

    @AuraEnabled()
    public static List<GSEM__c> getTransfers(String caseId){
        List<GSEM__c> caseTransfers = new List<GSEM__c>();
            caseTransfers = [SELECT Id, Name 
                               FROM GSEM__c
                               WHERE GSEM__c = :caseId];
        return caseTransfers;
    }

    public class CaseEscalations {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String Assignee;
        @AuraEnabled
        public String Url;
        @AuraEnabled
        public String EscalationType;
    }
    public class CaseConsults {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Url;
    }
}