@isTest
public class DM7ComponentBatch_Test {
    static testMethod void testAsupComponentToComponents01(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc; 
         
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
         Asset asst = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Test');
        
        insert asst;
        
        DM7_Component__c asup = new DM7_Component__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,asupComponentSN__c = 'SR12345',UPD_TYPE__c = 'I',
                                                         asupComponentType__c = 'SSD',asupComponentAssetSN__c = 'TestAsset',asupComponentControllerState__c = 'Test',asupComponentDiskModel__c = 'TestModel',
                                                         Component_Part_Number__c = '1234',asupComponentDiskSizeGB__c = '100');
        insert asup;
        
         SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum12',srmetadataIsValid__c = True,srAssetType__c = 'Test', Is_In_Prod__c = True,
                                                 srProductCode__c = 'SSD123',srProduct_Name__c = 'Test',srType__c = 'Controller');
        insert sr;
        
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD',componentServicePartNumber__c = 'TestSPNum12',componentState__c = 'Test');
        insert c1;
        
         Test.startTest();
        DM7ComponentBatch pb = new DM7ComponentBatch();
        Database.executeBatch(pb);
        Test.stopTest();
    }
    
    static testMethod void testAsupComponentToComponents02(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc; 
         
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
         Asset asst = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Test 1');
        
        insert asst;
        
        DM7_Component__c asup = new DM7_Component__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,asupComponentSN__c = 'SR12345',UPD_TYPE__c = 'I',
                                                         asupComponentType__c = 'PSU',asupComponentAssetSN__c = 'TestAsset',asupComponentControllerState__c = 'Test',asupComponentDiskModel__c = 'TestModel',
                                                         Component_Part_Number__c = '1234',asupComponentDiskSizeGB__c = '100');
        insert asup;
        
         SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum12',srmetadataIsValid__c = True,srAssetType__c = 'Test 1',Is_In_Prod__c = True,
                                                 srProductCode__c = 'SSD123', srProduct_Name__c = 'Test,test2',srType__c = 'Controller');
        insert sr;
        
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='PSU',componentServicePartNumber__c = 'TestSPNum12',componentState__c = 'Test');
        insert c1;
        c1.componentServicePartNumber__c ='TestSPNum3';
        update c1;
        
         Test.startTest();
        DM7ComponentBatch pb = new DM7ComponentBatch();
        Database.executeBatch(pb);
        Test.stopTest();
    }
    static testMethod void testAsupComponentToComponents03(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc; 
         
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
         Asset asst = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Test 1');
        
        insert asst;
        
        DM7_Component__c asup = new DM7_Component__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,asupComponentSN__c = 'SR12345',UPD_TYPE__c = 'I',
                                                         asupComponentType__c = 'PSU',asupComponentAssetSN__c = 'TestAsset',asupComponentControllerState__c = 'Test',asupComponentDiskModel__c = 'TestModel',
                                                         Component_Part_Number__c = '1234',asupComponentDiskSizeGB__c = '100');
        insert asup;
        
         SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum12',srmetadataIsValid__c = True,srAssetType__c = 'Test 1',Is_In_Prod__c = True,
                                                 srProductCode__c = 'SSD123',srModelNumbers__c = '1234,12345', srProduct_Name__c = 'Test',srType__c = 'Controller');
        insert sr;
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum123',srmetadataIsValid__c = True,Is_In_Prod__c = True,srModelNumbers__c = '1234');
        insert sr1;
        
     
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='PSU',componentServicePartNumber__c = 'TestSPNum12',componentState__c = 'Test',
                                          componentComponentSN__c = '12345');
        insert c1;
        c1.componentServicePartNumber__c ='TestSPNum3';
        update c1;
        
         Test.startTest();
        DM7ComponentBatch pb = new DM7ComponentBatch();
        Database.executeBatch(pb);
        Test.stopTest();
    }
    static testMethod void testAsupComponentToComponents04(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc; 
         
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
         Asset asst = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Test 1');
        
        insert asst;
        
        DM7_Component__c asup = new DM7_Component__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,asupComponentSN__c = 'SR12345',UPD_TYPE__c = 'I',
                                                         asupComponentType__c = 'PSU',asupComponentAssetSN__c = 'TestAsset',asupComponentControllerState__c = 'Test',asupComponentDiskModel__c = 'TestModel',
                                                         Component_Part_Number__c = '1234',asupComponentDiskSizeGB__c = '100');
        insert asup;
        
         SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum12',srmetadataIsValid__c = True,srAssetType__c = 'Test 1',Is_In_Prod__c = True,
                                                 srProductCode__c = 'SSD123',srModelNumbers__c = '1234,12345', srProduct_Name__c = 'Test',srType__c = 'Controller');
        insert sr;
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum123',srmetadataIsValid__c = True,Is_In_Prod__c = True,srModelNumbers__c = '1234');
        insert sr1;
        SR_Meta_Data__c sr2 = new SR_Meta_Data__c(srPart__c='TestSPNum124',srmetadataIsValid__c = True,srAssetType__c = 'Test 1',Is_In_Prod__c = True,
                                                 srProductCode__c = 'SSD1234',srModelNumbers__c = '1234,12345,12345Test 1', srProduct_Name__c = 'Test',srType__c = 'Controller');
        insert sr2;
        
     
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='PSU',componentServicePartNumber__c = 'TestSPNum12',componentState__c = 'Test',
                                          componentComponentSN__c = '12345');
        insert c1;
        c1.componentServicePartNumber__c ='TestSPNum3';
        update c1;
        
         Test.startTest();
        DM7ComponentBatch pb = new DM7ComponentBatch();
        Database.executeBatch(pb);
        Test.stopTest();
    }
    static testMethod void testAsupComponentToComponents05(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc; 
         
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
         Asset asst = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Test 1');
        
        insert asst;
        
        DM7_Component__c asup = new DM7_Component__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,asupComponentSN__c = 'SR12345',UPD_TYPE__c = 'I',
                                                         asupComponentType__c = 'PSU',asupComponentAssetSN__c = 'TestAsset',asupComponentControllerState__c = 'Test',asupComponentDiskModel__c = 'TestModel',
                                                         Component_Part_Number__c = '1234',asupComponentDiskSizeGB__c = '100',asupcomponentMatchedWithComponent__c = 'Yes-SerialNumber-NoSRPart');
        insert asup;
        
         SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum12',srmetadataIsValid__c = True,srAssetType__c = 'Test 1',Is_In_Prod__c = True,
                                                 srProductCode__c = 'SSD123',srModelNumbers__c = '1234,12345', srProduct_Name__c = 'Test',srType__c = 'Controller');
        insert sr;
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum123',srmetadataIsValid__c = True,Is_In_Prod__c = True,srModelNumbers__c = '1234');
        insert sr1;
        SR_Meta_Data__c sr2 = new SR_Meta_Data__c(srPart__c='TestSPNum124',srmetadataIsValid__c = True,srAssetType__c = 'Test 1',Is_In_Prod__c = True,
                                                 srProductCode__c = 'SSD1234',srModelNumbers__c = '1234,12345,12345Test 1', srProduct_Name__c = 'Test',srType__c = 'Controller');
        insert sr2;
        
     
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='PSU',componentServicePartNumber__c = 'TestSPNum12',componentState__c = 'Test',
                                          componentComponentSN__c = 'SR12345');
        insert c1;
        c1.componentServicePartNumber__c ='TestSPNum3';
        update c1;
        
         Test.startTest();
        DM7ComponentBatch pb = new DM7ComponentBatch();
        Database.executeBatch(pb);
        Test.stopTest();
    }
    static testMethod void testAsupComponentToComponentsMemory(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc; 
         
        Product2 testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                             ProductCode='CS220', 
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS200',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        
         Asset asst = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Test 1');
        
        insert asst;
        
        DM7_Component__c asup = new DM7_Component__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,asupComponentSN__c = 'SR12345',UPD_TYPE__c = 'I',
                                                         asupComponentType__c = 'Memory',asupComponentAssetSN__c = 'TestAsset',asupComponentControllerState__c = 'Test',asupComponentDiskModel__c = 'TestModel',
                                                         Component_Part_Number__c = '1234',asupComponentDiskSizeGB__c = '100',asupcomponentMatchedWithComponent__c = 'Yes-SerialNumber-NoSRPart');
        insert asup;
        
         SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum12',srmetadataIsValid__c = True,srAssetType__c = 'Test 1',Is_In_Prod__c = True,
                                                 srProductCode__c = 'SSD123',srModelNumbers__c = '1234,12345', srProduct_Name__c = 'Test',srType__c = 'Controller');
        insert sr;
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum123',srmetadataIsValid__c = True,Is_In_Prod__c = True,srModelNumbers__c = '1234');
        insert sr1;
        SR_Meta_Data__c sr2 = new SR_Meta_Data__c(srPart__c='TestSPNum124',srmetadataIsValid__c = True,srAssetType__c = 'Test 1',Is_In_Prod__c = True,
                                                 srProductCode__c = 'SSD1234',srModelNumbers__c = '1234,12345,12345Test 1', srProduct_Name__c = 'Test',srType__c = 'Controller');
        insert sr2;
        
     
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Memory',componentServicePartNumber__c = 'TestSPNum12',componentState__c = 'Test',
                                          componentComponentSN__c = 'SR12345');
        insert c1;
        c1.componentServicePartNumber__c ='TestSPNum3';
        update c1;
        
         Test.startTest();
        DM7ComponentBatch pb = new DM7ComponentBatch();
        Database.executeBatch(pb);
        Test.stopTest();
    }
}