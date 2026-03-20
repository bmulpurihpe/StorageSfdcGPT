@isTest
public class test_scheduledOEMCallOut  {
    @isTest static void testmethod1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
       
        Test.StartTest();
        
        Integer qPollingPeriodInMins = 3;
         
        scheduledOEMCallOut.SchedulerMethod(qPollingPeriodInMins);
        
        Test.StopTest();
    
    }

}