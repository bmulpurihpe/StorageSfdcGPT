/* Purpose: Test class for ComponentCommentUpdateBatch
* Change Log: Created by Exafort
*/ 
@isTest
public class ComponentCommentUpdateBatchTest 
{    
    static testMethod void testComponentComments()
    {
        createTestData();        
        Test.startTest();
        ComponentCommentUpdateBatch cc = new ComponentCommentUpdateBatch();
        Database.executeBatch(cc);
        Test.stopTest();
        /* Test case1: To check whether the component details are updated based on componentSN for an asset*/
        List<Component__c> testComp1 = [select Id, componentException__c, componentState__c, Sub_State__c, componentDiskSizeGB__c from Component__c 
                                        where componentComponentSN__c = 'TestSN1' ];
    }
    
    static void createTestData()
    {
        asset asst;
        asset asst1;
        asset asst2;
        Account acc = new Account(Name = 'TestAcc');
        Account acc1 = new Account(Name = 'TestAcc2');
        List<Account> acctList = new List<Account>();
        acctList.add(acc);
        acctList.add(acc1);
        insert acctList;
        List<Asset> asstList = new List<Asset>();
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
        insert asst = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                                Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                Asset_Type_Build__c ='Testasupassettype');
        insert asst1 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                                 Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                 Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Asset_Type_Build__c ='Testasupassettype');
        insert asst2 = new Asset(Name = 'TestAsset', AccountId = acc.Id,Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                                 Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                 Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Asset_Type_Build__c ='Testasupassettype');
        
        List<Component__c> compsToCreate = new List<Component__c>();        
        Component__c c1 = new Component__c(componentAsset__c= asst.Id, componentComponentSN__c = 'TestSN1',componentType__c = 'Controller', 
                                           componentServicePartNumber__c = 'TestSPNum');
        Component__c c2 = new Component__c(componentAsset__c= asst.Id, componentServicePartNumber__c = 'TestSPNum1',componentType__c = 'Controller', 
                                           componentState__c = 'Shipped',Sub_State__c='Online');
        Component__c c3 = new Component__c(componentAccountId__c = acc1.Id, componentComponentSN__c = 'TestSN4',componentType__c = 'Controller',
                                           componentServicePartNumber__c = 'TestSPNum');
        Component__c c4 = new Component__c(componentAsset__c = asst2.Id, componentComponentSN__c = null, componentType__c = 'Controller',
                                           componentServicePartNumber__c = 'TestSPNum',componentState__c = 'Shipped',Sub_State__c='Online');
        Component__c c5 = new Component__c(componentAsset__c = asst2.Id, componentComponentSN__c = null, componentType__c = 'Controller',
                                           componentServicePartNumber__c = 'TestSPNum',componentState__c = 'Shipped',Sub_State__c='Online');
        Component__c c6 = new Component__c(componentAsset__c = asst2.Id, componentComponentSN__c = null, componentType__c = 'Controller',
                                           componentServicePartNumber__c = 'TestSPNum',componentState__c = 'Shipped',Sub_State__c='Unknown');
        Component__c c7 = new Component__c(componentAsset__c = asst2.Id, componentComponentSN__c = null, componentType__c = 'Controller',
                                           componentServicePartNumber__c = 'TestSPNum',componentState__c = 'Shipped',Sub_State__c='Unknown');
        Component__c c8 = new Component__c(componentAsset__c = asst.Id, componentComponentSN__c = null, componentType__c = 'Controller',
                                           componentServicePartNumber__c = 'TestSPNum',componentState__c = 'Shipped',Sub_State__c='Unknown');
        Component__c c9 = new Component__c(componentAsset__c = asst.Id, componentComponentSN__c = null, componentType__c = 'Controller',
                                           componentServicePartNumber__c = 'TestSPNum',componentState__c = 'Shipped',Sub_State__c='Unknown');
        Component__c c10 = new Component__c(componentAsset__c = asst.Id, componentComponentSN__c = null, componentType__c = 'Controller',
                                            componentServicePartNumber__c = 'TestSPNum', componentState__c = 'Shipped',Sub_State__c='Online');
        
        compsToCreate.add(c1);
        compsToCreate.add(c2);
        compsToCreate.add(c3);
        compsToCreate.add(c4);
        compsToCreate.add(c5);
        compsToCreate.add(c6);
        compsToCreate.add(c7);
        compsToCreate.add(c8);
        compsToCreate.add(c9);
        compsToCreate.add(c10);
        insert compsToCreate;       
    }
    
}