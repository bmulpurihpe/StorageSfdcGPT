@isTest
public class test_scheduledWebCallOut  {
    @isTest static void testmethod1() {
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GSEM());
        
        Test.StartTest();
        
        Integer qPollingPeriodInMins = 3;

        scheduledWebCallOut.SchedulerMethod(qPollingPeriodInMins);
        
        Test.StopTest();
        
    }
    
}