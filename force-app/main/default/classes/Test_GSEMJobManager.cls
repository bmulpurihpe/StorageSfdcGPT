@isTest
public class Test_GSEMJobManager {

    static testMethod void testRequesterFlow()
    {

        Integer pollingPeriodInMins = 3;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GSEM());
        
        Test.StartTest();
        

        GSEMJobManager.getGSEMRequesterJobs();
        GSEMJobManager.stopGSEMRequesterJobs();
        GSEMJObManager.startGSEMRequesterJobs(pollingPeriodInMins);
        GSEMJobManager.getGSEMRequesterJobs();
        GSEMJobManager.stopGSEMRequesterJobs();
        
        Test.StopTest();


    }
    
    static testMethod void testOEMProviderFlow()
    {

        Integer pollingPeriodInMins = 3;
        
       	Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        
        Test.StartTest();
        
        GSEMJobManager.getGSEMOEMProviderJobs();
        GSEMJobManager.stopGSEMOEMProviderJobs();
        GSEMJObManager.startGSEMOEMProviderJobs(pollingPeriodInMins);
        GSEMJobManager.getGSEMOEMProviderJobs();
        GSEMJobManager.stopGSEMOEMProviderJobs();
        
        Test.StopTest();

    }
    
    static testMethod void testCollectiveJobs()
    {

        Integer pollingPeriodInMins = 3;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GSEM());
       	Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        
        Test.StartTest();
        
        GSEMJObManager.stopAllGSEMJobs();
        GSEMJobManager.getAllGSEMJobs();
        GSEMJObManager.startAllGSEMJobs(pollingPeriodInMins);
        GSEMJobManager.getAllGSEMJobs();
        GSEMJObManager.stopAllGSEMJobs();
        
        Test.StopTest();


    }
  
}