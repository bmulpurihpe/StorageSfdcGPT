public without sharing class ChatFeedbackController {
    public string feedbackName {get;set;}
    public string personName {get;set;}
    public string parentId {get;set;}
    public Survey__c feedback {get;set;}
    public String liveAgentName {get;set;} 
    public String caseNumber {get;set;}
    public boolean hideFeedback {get;set;}
    
    public ChatFeedbackController(){
        hidefeedback = false;
        feedback = new Survey__c();
        parentId = ApexPages.currentPage().getParameters().get('attachedRecords');
        String chatDetails = ApexPages.currentPage().getParameters().get('chatDetails');
        system.debug('Chat Details :'+chatDetails);
        fromJSON objCls = new fromJSON();
        ChatFeedbackController.fromJSON res= objCls.parse(chatDetails);
        system.debug('res : '+res.agent);
        liveAgentName = res.agent.agentName;
        system.debug('parent Id : '+parentId);        
        List<String> lst = parentId.split(',');
        List<String> caseDetails = lst[0].replaceAll('}','').split(':');
        system.debug('Case Id : '+caseDetails[1].replaceAll('"',''));
        Case cs = [select Id,CaseNumber from case where Id =: caseDetails[1].replaceAll('"','')];
        caseNumber = cs.caseNumber;
    }
    
    public List<SelectOption> getpicklist1() {   
        List<SelectOption> selectOptions = new List<SelectOption>();
        Schema.DescribeFieldResult describeResult = Survey__c.How_would_you_rate_your_chat_consultant__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntries = describeResult.getPicklistValues();
        selectOptions.add(new SelectOption('', 'Please select'));       
        for( Schema.PicklistEntry eachEntry : pickListEntries) {
            selectOptions.add(new SelectOption(eachEntry.getLabel(), eachEntry.getValue()));    
        }
        return selectOptions;
    }
    public List<SelectOption> getpicklist5() {   
        List<SelectOption> selectOptions = new List<SelectOption>();
        Schema.DescribeFieldResult describeResult = Survey__c.Was_your_question_resolved_by_the_consul__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntries = describeResult.getPicklistValues();
        selectOptions.add(new SelectOption('', 'Please select'));       
        for( Schema.PicklistEntry eachEntry : pickListEntries) {
            selectOptions.add(new SelectOption(eachEntry.getLabel(), eachEntry.getValue()));    
        }
        return selectOptions;
    }
    
    public void createFeedback(){
        system.debug('Click on Submit ');
        try{
            Survey__c  newfeedback = new Survey__c ();
           // newfeedback.Name = 'Chat Customer Feedback'+parentId;
            newfeedback.How_would_you_rate_your_chat_consultant__c = feedback.How_would_you_rate_your_chat_consultant__c;            
            newfeedback.Was_your_question_resolved_by_the_consul__c = feedback.Was_your_question_resolved_by_the_consul__c;
            newfeedback.surveyCustomerComments__c = feedback.surveyCustomerComments__c;
            
            //sList<String> caseId = parentId.split(':');
            hidefeedback = true; 
            insert newfeedback;
            
        }catch(Exception ex){
            system.debug('Exception :'+ex.getMessage());
            system.debug('Line number : '+ex.getLineNumber());
        }
    }
    
    public void closeChat(){
        hidefeedback = true;
    }
    public pageReference startNewChat(){
        pageReference pr = new pageReference('/apex/Prechat_Form?endpoint=https%3A%2F%2F17yu.la1-c1cs-iad.salesforceliveagent.com%2Fcontent%2Fs%2Fchat%3Flanguage%3Den_US%26org_id%3D00Dg0000006UNYM%26deployment_id%3D572g00000008Or5%26sid%3D0e27735d-ce9a-47f8-94fb-6fca8eb6178e%23deployment_id%3D572g00000008Or5%26org_id%3D00Dg0000006UNYM%26button_id%3D573g00000008PXw%26session_id%3D0e27735d-ce9a-47f8-94fb-6fca8eb6178e');
    	pr.setRedirect(true);
        return pr;
    }
    
    public class fromJSON{
        public cls_prechatDetails[] prechatDetails;
        public cls_geoLocation geoLocation;
        public String visitorId;	//0e27735d-ce9a-47f8-94fb-6fca8eb6178e
        public cls_customDetails[] customDetails;
        public cls_agent agent;
        
        public  fromJSON parse(String json){
            return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
        }
        
        /*static testMethod void testParse() {
String json=		'{"prechatDetails":[{"label":"ContactPhone","value":"989898","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":false},{"label":"CaseRecordType","value":"0122H000000GJYeQAO","entityMaps":[],"transcriptFields":[],"displayToAgent":"false","doKnowledgeSearch":false},{"label":"CaseStatus","value":"New","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":false},{"label":"ContactEmail","value":"demo@tet.com","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":false},{"label":"CaseSubject","value":"Configure and Quote","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":true},{"label":"ContactFirstName","value":"Test","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":false},{"label":"CaseOrigin","value":"Web","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":false},{"label":"ContactLastName","value":"test2","entityMaps":[],"transcriptFields":[],"displayToAgent":"true","doKnowledgeSearch":false}],"geoLocation":{"organization":"Comcast Cable","region":"CA","city":"Fremont","countryName":"United States","latitude":37.5483,"countryCode":"US","longitude":-121.9886},"visitorId":"0e27735d-ce9a-47f8-94fb-6fca8eb6178e","customDetails":[],"agent":{"userId":"005g0000007EX0z","agentName":"Abdul K","transfer":0}}'+
'';
fromJSON obj = parse(json);
System.assert(obj != null);
}*/
    }
    public class cls_prechatDetails {
        public String label;	//ContactPhone
        public String value;	//989898
        public cls_entityMaps[] entityMaps;
        public cls_transcriptFields[] transcriptFields;
        public String displayToAgent;	//true
        public boolean doKnowledgeSearch;
    }
    public class cls_entityMaps {
    }
    public class cls_transcriptFields {
    }
    
    public class cls_geoLocation {
        public String organization;	//Comcast Cable
        public String region;	//CA
        public String city;	//Fremont
        public String countryName;	//United States
        public Double latitude;	//37.5483
        public String countryCode;	//US
        public Double longitude;	//-121.9886
    }
    public class cls_customDetails {
    }
    public class cls_agent {
        public String userId;	//005g0000007EX0z
        public String agentName;	//Abdul K
        public Integer transfer;	//0
    }
    
}