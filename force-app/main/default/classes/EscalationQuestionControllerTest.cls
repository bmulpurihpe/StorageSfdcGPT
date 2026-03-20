/*
    This test class uses data from the CM_Collaboration_Question__c, CM_Escalation_Collaboration_Question__c,
    CM_Escalation_Rotation_Question_Detail__c objects. For these tests to run successfully data needs to be in 
    all 3 objects. CSV files with data is attached to Jira Ticket TS-9560
*/
@IsTest(SeeAllData=true)
public with sharing class EscalationQuestionControllerTest {
    static testMethod void getPeakMappings_ForSupportConsult() {
        List<EscalationQuestionController.PeakOrRotationResponse> peakResp = 
                            EscalationQuestionController.getPeakOrRotationMappings('Support Consult');
        System.assert(peakResp.size() > 0, 'At least 1 Peak Mapping is required');
    }
    static testMethod void getPeakMappings_ForEnggEscalation() {
        List<EscalationQuestionController.PeakOrRotationResponse> peakResp = 
                            EscalationQuestionController.getPeakOrRotationMappings('Engineering Escalation');
        System.assert(peakResp.size() > 0, 'At least 1 Escalation Rotation Mapping is required');
    }
    static testMethod void getQuestionDetails_For_Perf_SupportConsult() {
        List<EscalationQuestionController.QuestionDetails> qDetails = 
                            EscalationQuestionController.getQuestionDetails('Perf', 'Support Consult');
        System.assert(qDetails.size() > 0, 'At least 1 Question Detail is required');
    }
    static testMethod void getQuestionDetails_For_HWPlat_EnggEsc() {
        List<EscalationQuestionController.QuestionDetails> qDetails = 
                            EscalationQuestionController.getQuestionDetails('Plat', 'Engineering Escalation');
        System.assert(qDetails.size() > 0, 'At least 1 Question Detail is required');
    }
    static testMethod void getQuestionDetails_For_Exec_ExecEsc() {
        List<EscalationQuestionController.QuestionDetails> qDetails = 
                            EscalationQuestionController.getQuestionDetails('Exec', 'Executive Escalation');
        System.assert(qDetails.size() > 0, 'At least 1 Question Detail is required');
    }

}