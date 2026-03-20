@isTest
public class ShareFeedbackControllerTest {
    
     static testMethod void test(){
        ShareFeedbackController cls = new ShareFeedbackController();
        ApexPages.currentPage().getParameters().put('rating','Good');
        cls.createFeedback();
    }
}