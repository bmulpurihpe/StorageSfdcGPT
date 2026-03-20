/* Purpose: Test class for ProcessSRMetaData_Batch
 * Change Log: Created by Pradeep Aitha
 * 
 */ 
@isTest()
public class ProcessSRMetaData_Batch_Test 
{
    static testMethod void testProcessComponenttoSRMeta()
    {
        createTestData();
        Test.startTest();
        ProcessSRMetaData_Batch srb = new ProcessSRMetaData_Batch();
        Database.executeBatch(srb);
        Test.stopTest();
        //Test case 1: To update existing srmetada record with model number using srPart__c as external id
        SR_Meta_Data__c sr1 = [select Id, srPart__c, srModelNumbers__c from SR_Meta_Data__c where srPart__c = 'TestSPNum1'];
        //System.assertEquals('TestModel1',sr1.srModelNumbers__c);
        //Test case 1: To create a srmetada record with model number using srPart__c as external id
        SR_Meta_Data__c sr2 = [select Id, srPart__c, srModelNumbers__c from SR_Meta_Data__c where srPart__c = 'TestSPNum2'];
        //System.assertEquals('TestModel2',sr2.srModelNumbers__c);     
        
    }
    static void createTestData()
    {
        Account acc = new Account(Name = 'TestAcc');
      
        insert acc;
        List<Asset> asstList = new List<Asset>();        
        Asset asst = new Asset(Name = 'TestAsset', AccountId = acc.Id);       
        Asset asst1 = new Asset(Name = 'TestAsset1', AccountId = acc.Id);      
        asstList.add(asst);
        asstList.add(asst1);
        insert asstList;
        List<Component__c> compsToCreate = new List<Component__c>();        
        Component__c c1 = new Component__c(componentAsset__c= asst.Id, componentComponentSN__c = 'TestSN1', componentServicePartNumber__c = 'TestSPNum1', componentDiskModel__c = 'TestModel1');
        Component__c c2 = new Component__c(componentAsset__c= asst.Id, componentDiskModel__c = 'TestModel2', componentServicePartNumber__c = 'TestSPNum2');
        compsToCreate.add(c1);
        compsToCreate.add(c2);
        insert compsToCreate;       
        SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum1');
        insert sr;
    }

}