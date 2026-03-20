public class ShareFeedbackController {
    public ShareFeedbackController(){
        
    }
    public pageReference createFeedback(){
        String rating = ApexPages.currentPage().getParameters().get('rating');
        system.debug('rating : '+rating);
        Survey__c  newfeedback = new Survey__c ();
        newfeedback.surveyTseHelpText__c = rating;
		insert newfeedback;  
        pageReference pr = new pageReference('/apex/Prechat_Form?endpoint=https%3A%2F%2F17yu.la1-c1cs-iad.salesforceliveagent.com%2Fcontent%2Fs%2Fchat%3Flanguage%3Den_US%26org_id%3D00Dg0000006UNYM%26deployment_id%3D572g00000008Or5%26sid%3D0e27735d-ce9a-47f8-94fb-6fca8eb6178e%23deployment_id%3D572g00000008Or5%26org_id%3D00Dg0000006UNYM%26button_id%3D573g00000008PXw%26session_id%3D0e27735d-ce9a-47f8-94fb-6fca8eb6178e');
    	pr.setRedirect(true);
        return pr;
    }
}