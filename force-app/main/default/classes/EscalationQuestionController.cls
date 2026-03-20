public with sharing class EscalationQuestionController {

    @AuraEnabled(cacheable=true)
    public static List<PeakOrRotationResponse> getPeakOrRotationMappings(String escalationType) {
        List<PeakOrRotationResponse> response = new List<PeakOrRotationResponse>();
        if(escalationType.equals('Support Consult')) {
            for(Peak_Mapping__c peakMapping: [SELECT Id, Peak_Area_Code__c,  Draft_Description_Detail__c, 
                                                     Old_Description_Detail__c, PEAK_Area_RAS_Functional_Area__c
                                              FROM Peak_Mapping__c
                                              WHERE Inactive_PEAK_area__c = FALSE
                                              ORDER BY Peak_Area_Code__c]) {
                PeakOrRotationResponse peakResp = new PeakOrRotationResponse();
                peakResp.label = peakMapping.Peak_Area_Code__c;
                peakResp.value = peakMapping.Peak_Area_Code__c;
                peakResp.param1 = peakMapping.Old_Description_Detail__c;
                peakResp.param2 = peakMapping.Draft_Description_Detail__c;
                response.add(peakResp);
            }
        } else {
            for(Engineering_Escalation_Mapping__c rotationMapping: [SELECT Id, Rot_Code__c, Rotation_Email_Alias__c, 
                                                                            CC_List__c, Description__c
                                                                    FROM Engineering_Escalation_Mapping__c
                                                                    WHERE IsActive__c = TRUE
                                                                    ORDER BY Rot_Code__c]) {
                PeakOrRotationResponse peakResp = new PeakOrRotationResponse();
                peakResp.label = rotationMapping.Rot_Code__c;
                peakResp.value = rotationMapping.Rot_Code__c;
                peakResp.param1 = rotationMapping.Description__c;
                peakResp.param2 = rotationMapping.Rotation_Email_Alias__c;
                peakResp.param3 = rotationMapping.CC_List__c;
                response.add(peakResp);
            }
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static List<QuestionDetails> getQuestionDetails(String component, String escalationType) {
        List<QuestionDetails> escalationQs = new List<QuestionDetails>();
        if(escalationType.equals('Support Consult')) {
            for(CM_Escalation_Rotation_Question_Detail__c escQs : 
                            [SELECT Id, Options__c, Is_Required__c, Response_Type__c,
                                    Display_Order__c, Max_Length__c,
                                    cm_escalation_collaboration_question__r.cm_collaboration_question__r.Name, 
                                    cm_escalation_collaboration_question__r.cm_collaboration_question__r.Description__c 
                            FROM cm_escalation_rotation_question_detail__c 
                            WHERE peak_mapping__r.Peak_Area_Code__c = :component
                                AND cm_escalation_collaboration_question__r.Case_Consult_Type_Definition__c = :escalationType
                                AND Is_Active__c = true
                            ORDER BY Display_Order__c]) {
                QuestionDetails qDetails = new QuestionDetails();
                qDetails.name = escQs.cm_escalation_collaboration_question__r.cm_collaboration_question__r.Name;
                qDetails.description = escQs.cm_escalation_collaboration_question__r.cm_collaboration_question__r.Description__c;
                qDetails.required = escQs.Is_Required__c;
                qDetails.responseType = escQs.Response_Type__c;
                qDetails.options = escQs.Options__c;
                qDetails.maxLength = escQs.Max_Length__c;
                escalationQs.add(qDetails);
            }
        } else {
            for(CM_Escalation_Rotation_Question_Detail__c escQs : 
                            [SELECT Id, Options__c, Is_Required__c, Response_Type__c,
                                Display_Order__c, Max_Length__c,
                                cm_escalation_collaboration_question__r.cm_collaboration_question__r.Name, 
                                cm_escalation_collaboration_question__r.cm_collaboration_question__r.Description__c 
                            FROM cm_escalation_rotation_question_detail__c 
                            WHERE engineering_escalation_mapping__r.rot_code__c = :component 
                                AND cm_escalation_collaboration_question__r.Case_Escalation_Type_Definition__r.Name = 
                                            :escalationType
                                AND Is_Active__c = true
                            ORDER BY Display_Order__c]) {
                QuestionDetails qDetails = new QuestionDetails();
                qDetails.name = escQs.cm_escalation_collaboration_question__r.cm_collaboration_question__r.Name;
                qDetails.description = escQs.cm_escalation_collaboration_question__r.cm_collaboration_question__r.Description__c;
                qDetails.required = escQs.Is_Required__c;
                qDetails.responseType = escQs.Response_Type__c;
                qDetails.options = escQs.Options__c;
                qDetails.maxLength = escQs.Max_Length__c;
                escalationQs.add(qDetails);
            }
        }
        return escalationQs;
    }

    public class JiraResponse {
        @InvocableVariable
        public String jiraId;

        @InvocableVariable
        public String jiraKey;

        @InvocableVariable
        public String jiraBrowseUrl;
    
    }

    public class PeakOrRotationResponse {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String param1;
        @AuraEnabled
        public String param2;
        @AuraEnabled
        public String param3;
    }

    public class QuestionDetails {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public String options;
        @AuraEnabled
        public String responseType;
        @AuraEnabled
        public Decimal maxLength;
    }
    
}