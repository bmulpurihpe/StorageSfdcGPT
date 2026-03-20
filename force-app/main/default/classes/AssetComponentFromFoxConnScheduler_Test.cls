@isTest
public class AssetComponentFromFoxConnScheduler_Test {
    static testMethod void testAssetComponenFromFoxConnScheduler()
    {
        test.starttest();
        AssetComponentFromFoxConnBatchScheduler myClass = new AssetComponentFromFoxConnBatchScheduler ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}