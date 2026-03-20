@isTest(SeeAllData=true)
private class NCVTrigger_Test {
    @isTest static void testMethod1() {
        string key = 'test';
        List<Account> accList = NMBL_TestUtil.createAccount(key,1, true);
        List<Contact> contList = NMBL_TestUtil.createContact(accList.get(0),1,true);
        List<Nimble_Cloud_Volume__c> ncvList = NMBL_TestUtil.createNCV(accList.get(0), contList.get(0),1, true);
    
     
        Nimble_Cloud_Volume__c ncv = [select id, Volume_name__c from Nimble_Cloud_Volume__c where id = :ncvList.get(0).id];  
        
        Test.startTest();
         ncv.Volume_name__c = 'test1';
         checkRecursive.resetRunOnceFlag();
         update ncv;  
        Test.stopTest();
     
    } 
}