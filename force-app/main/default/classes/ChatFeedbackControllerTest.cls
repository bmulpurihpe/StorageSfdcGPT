@isTest
public class ChatFeedbackControllerTest {
    
    static testMethod void test(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Origin = 'Community';
        cs.Status = 'New';
        insert cs;
        String jsnStr = '{"CaseId":"'+cs.Id+'"}';
        String chatDetails = '{"prechatDetails":[{"label":"CaseRecordType","value":"0122H000000GJXvQAO","entityMaps":[],"transcriptFields":[],"displayToAgent":"false","doKnowledgeSearch":false},{"label":"CaseStatus","value":"New","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":false},{"label":"referencenumber","value":"","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":false},{"label":"CaseSubject","value":"Chat","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":true},{"label":"CaseOrigin","value":"Web","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":false}],"geoLocation":{"organization":"Comcast Cable","region":"CA","city":"Fremont","countryName":"United States","latitude":37.5483,"countryCode":"US","longitude":-121.9886},"visitorId":"b98da1e8-9deb-4cbf-a277-7446dc4b87c7","customDetails":[],"agent":{"userId":"005g0000007EX0z","agentName":"Abdul K","transfer":0}}';        
        ApexPages.currentPage().getParameters().put('chatDetails',chatDetails);
        ApexPages.currentPage().getParameters().put('attachedRecords',jsnStr);
        ChatFeedbackController cls = new ChatFeedbackController();
        cls.getpicklist1();
        cls.getpicklist5();
        cls.createFeedback();
        cls.closeChat();
        cls.startNewChat();
    }
}