@isTest
public class ProcessAsupComponent_BatchTest 
{
    static testMethod void testAsupComponentToComponents(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
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
        Product2 testProduct2 = new Product2(Name = 'SSD Storage Array',
                                             ProductCode='SSD1233',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage ArraySd',
                                             Controller_Code__c='CS2001',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array1');
        insert testProduct2;
        
        
        
        Asset asst = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
        
        Asset asst1 = new Asset(Name = 'TestAsset1', AccountId = acc.Id, Product2Id = testProduct2.id,HPE_Serial_Number__c = 'HPE123457',
                                Array_Controller__c = 'CS3001',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F');
        
        insert asst1;
        
        
        
        Asup_Components__c asup = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                         asupComponentType__c = 'SSD',
                                                         asupComponentDiskSizeGB__c = '100');
        insert asup;
        
        Asup_Components__c asup1 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst1.Id, 
                                                          asupComponentSN__c = 'TestSN1', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SSD', asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentDiskSizeGB__c = '100');
        insert asup1;
         Asup_Components__c asup2 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN12', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SSD', asupComponentDiskUsedState__c = 'In Use',
                                                          asupComponentDiskSizeGB__c = '100');
        Insert asup2;
        Asup_Components__c asup3 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN123', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SSD', asupComponentDiskUsedState__c = 'Foreign',
                                                          asupComponentDiskSizeGB__c = '100');
        Insert asup3;
        Asup_Components__c asup4 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN123456', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SSD', asupComponentDiskUsedState__c = 'Failed',
                                                          asupComponentDiskSizeGB__c = '100');
        insert asup4;
        Asup_Components__c asup5 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN1234CON', asupComponentDiskModel__c = 'TestModelCON',
                                                          asupComponentType__c = 'Controller',
                                                          asupComponentDiskSizeGB__c = '100',asupComponentControllerState__c ='Test');
        insert asup5;
        Asup_Components__c asup6 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN1234', asupComponentDiskModel__c = 'TestModel11',
                                                          asupComponentType__c = 'SSD',
                                                          asupComponentDiskSizeGB__c = '100');
        
        insert asup6;
        
        Asup_Components__c asup7 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN12345', asupComponentDiskModel__c = 'TestModel1123',
                                                          asupComponentType__c = 'PSU',
                                                          asupComponentDiskSizeGB__c = '100');
        Insert asup7;
        
        Asup_Components__c asup8 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestCompSN12345', asupComponentDiskModel__c = 'TestModel1123',
                                                          asupComponentType__c = 'Controller',
                                                          asupComponentDiskSizeGB__c = '100');
        Insert asup8;
        
        Asup_Components__c asup9 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,
                                                          asupComponentType__c = 'SSD');
        Insert asup9;
        
        Asup_Components__c asup10 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                           asupComponentSN__c = 'TestSN1234CON9', asupComponentDiskModel__c = 'TestModelCON9',
                                                           asupComponentType__c = 'Controller',
                                                           asupComponentDiskSizeGB__c = '100');
        insert asup10;
        
        Asup_Components__c asup11 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                           asupComponentSN__c = 'TestSN1234CON11', asupComponentDiskModel__c = 'TestModelCON11',
                                                           asupComponentType__c = 'Controller',
                                                           asupComponentDiskSizeGB__c = '100',Component_Part_Number__c = 'TestPart');
        insert asup11;
                
        Asup_Components__c asup12 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                           asupComponentSN__c = 'TestSN1234CON11', asupComponentDiskModel__c = 'TestModelCON13');
        insert asup12;
        Asup_Components__c asup13 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                           asupComponentSN__c = 'TestSN1234CON11', asupComponentType__c = 'SCM',asupComponentDiskModel__c = 'TestModelCON13');
        insert asup13;
        Asup_Components__c asup14 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                           asupComponentSN__c = 'Test1', asupComponentDiskModel__c = 'TestModelCON11',
                                                           asupComponentType__c = 'PSU',
                                                           asupComponentDiskSizeGB__c = '100',Component_Part_Number__c = null);
        insert asup14;
        
        
        Map<String,String> modelToSRMap = new Map<String,String>();  
        
        SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum12',srmetadataIsValid__c = True,
                                                 srProductCode__c = 'SSD123');
        insert sr;
        
        
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum1',srModelNumbers__c='TestModel,Testmodel1', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
        insert sr1;
        modelToSRMap.put(sr1.srModelNumbers__c,sr1.srPart__c);
        SR_Meta_Data__c sr11 = new SR_Meta_Data__c(srPart__c='TestSPNum123', srModelNumbers__c='TestModelCON11',srmetadataIsValid__c = True,
                                                   srProductCode__c = 'SSD1234');
        insert sr11;
        
        
        
        SR_Meta_Data__c sr2 = new SR_Meta_Data__c(srPart__c='TestSPNum2',srModelNumbers__c='TestModel,Testmodel2', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
        insert sr2;
        
        
        SR_Meta_Data__c sr3 = new SR_Meta_Data__c(srPart__c='TestSPNum3',srModelNumbers__c='TestModelCON', srmetadataIsValid__c = True,srProduct_Name__c = 'CS210 Storage Array', srDynamicSKU__c = 'CS215-2G',srProductCode__c = 'CS210,CS215',srAssetType__c = 'Legacy,TestAssetType2');
        insert sr3;
        
        SR_Meta_Data__c sr4 = new SR_Meta_Data__c(srPart__c='TestSPNum4',srModelNumbers__c= null,srmetadataIsValid__c = True, srProduct_Name__c = 'CS210 Storage Array', srDynamicSKU__c = 'CS215-2G',srProductCode__c = 'CS210,CS215',srAssetType__c = 'Legacy,TestAssetType2');
        insert sr4;
        
        SR_Meta_Data__c sr5 = new SR_Meta_Data__c(srPart__c='TestModelsrpart',srModelNumbers__c= 'TestModel11',srmetadataIsValid__c = True, srProduct_Name__c = 'CS210 Storage Array', srDynamicSKU__c = 'CS215-2G',srProductCode__c = 'CS210,CS215',srAssetType__c = 'Legacy,TestAssetType2');
        insert sr5;
        
        SR_Meta_Data__c sr6 = new SR_Meta_Data__c(srPart__c='TestModelsrpart1',srmetadataIsValid__c = True, srProduct_Name__c = 'CS210 Storage Array',srType__c = 'Controller');
        insert sr6;
        SR_Meta_Data__c sr7 = new SR_Meta_Data__c(srPart__c='TestServicePart',srmetadataIsValid__c = True,srModelNumbers__c='TestModelCON13');
        insert sr7;
        SR_Meta_Data__c sr8 = new SR_Meta_Data__c(srPart__c='TestModelsrpart21',srmetadataIsValid__c = True, srProduct_Name__c = 'CS2102 Storage Array',srType__c = 'SCM');
        insert sr8;
        SR_Meta_Data__c sr9 = new SR_Meta_Data__c(srPart__c='TestSN1234CON121',srModelNumbers__c = 'Test1,test11',srmetadataIsValid__c = True, srProduct_Name__c = 'CS2102 Storage Array',srType__c = 'PSU');
        insert sr9;
        SR_Meta_Data__c sr10 = new SR_Meta_Data__c(srPart__c='TestModelsrpart213',srmetadataIsValid__c = True, srProduct_Name__c = 'CS21 Storage Array',srType__c = 'SSD');
        insert sr10;
        
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD',componentServicePartNumber__c = 'TestModelsrpart');
        insert c1;
        Component__c c2 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD', componentServicePartNumber__c = 'TestSPNum1');
        insert c2;
        Component__c c3 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller', componentServicePartNumber__c = 'TestSPNum145');
        insert c3;
        c3.componentServicePartNumber__c ='TestSPNum3';
        update c3;
        
        Component__c c4 = new Component__c(componentAsset__c= asst.Id,componentType__c ='PWR(power supply)');
        insert c4;
        
        Component__c c5 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller');
        insert c5;
        
        Component__c c6 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller',componentServicePartNumber__c = 'TestServicePart');
        insert c6;
        Component__c c7 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SCM',componentServicePartNumber__c = 'TestModelsrpart21');
        insert c7;
        Component__c c8 = new Component__c(componentAsset__c= asst.Id,componentType__c ='PSU',componentServicePartNumber__c = 'TestSN1234CON121');
        insert c8;
        
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
    }
    static testMethod void testAsupComponentToComponents1(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
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
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
        //Asset asst1 = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
        //                     Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
        //                   Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
        //                 Asset_Type_Build__c ='Next Gen');
        
        //insert asst1;
        Asset asst1 = new Asset(Name = 'TestAsset1', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                                Array_Controller__c = 'CS3001',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F');
        
        insert asst1;
     
        Asup_Components__c asup = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                         asupComponentType__c = 'PSU',
                                                         asupComponentDiskSizeGB__c = '100',Component_Part_Number__c = 'test123');
        insert asup;
         Asup_Components__c asup1 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                         asupComponentType__c = 'SCM');
        insert asup1;
         Asup_Components__c asup2 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst1.Id, 
                                                         asupComponentType__c = 'SSD');
        insert asup2;
        SR_Meta_Data__c sr10 = new SR_Meta_Data__c(srmetadataIsValid__c = True, srModelNumbers__c = 'test123',srPart__c = 'srparts123');
        insert sr10;
        SR_Meta_Data__c sr11 = new SR_Meta_Data__c(srmetadataIsValid__c = True, srProductCode__c = 'test1234',srPart__c = 'srparts122');
        insert sr11;
        Component__c c = new Component__c(componentAsset__c= asst.Id,componentType__c ='PSU',componentServicePartNumber__c = 'srparts123');
        insert c;
        Component__c c8 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SCM',componentDiskModel__c = 'srparts123');
        insert c8;
         Component__c c1 = new Component__c(componentAsset__c= asst1.Id,componentType__c ='SSD',componentDiskModel__c = 'srparts122');
        insert c1;
        
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
        
    }
    static testMethod void testAsupComponentToComponents2(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
        Account acc = new Account(Name = 'TestAcc');
        insert acc; 
         Product2 testProduct1 = new Product2(Name = 'CS22001',
                                             ProductCode='CS220012s',
                                             Product_Type__c='Hardware',
                                             Product_Type_2__c='SAN Storage Array',
                                             Controller_Code__c='CS20001',
                                             Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family='SAN Storage Array');
        insert testProduct1;
        Asset asst = new Asset(Name = 'TestAsset12', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                                Array_Controller__c = 'CS3001',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F');
        
        insert asst;
        //Asset asst = new Asset(Name = 'TestAsset1', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE1234571',
        //                       Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
        //                       Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
        //                       Asset_Type_Build__c ='Next Gen',Package_Product_Code_Build__c = 'CS22001',Dynamic_SKU__c='CS22001');
        
        //insert asst;
        Asup_Components__c asup = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                         asupComponentType__c = 'SCM',
                                                         asupComponentDiskSizeGB__c = '100',Component_Part_Number__c = 'testComp6781');
        insert asup;
         Asup_Components__c asup2 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                         asupComponentType__c = 'SSD');
        insert asup2;
        Asup_Components__c asup3 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                         asupComponentType__c = 'PSU',Component_Part_Number__c = 'parttest123');
        insert asup3;
        
         SR_Meta_Data__c sr11 = new SR_Meta_Data__c(srmetadataIsValid__c = True, srType__c = 'SCM',srProductCode__c = 'CS22001',srPart__c = 'srparttest963');
        insert sr11;
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srmetadataIsValid__c = True, srModelNumbers__c = 'parttest123,parttest1245',srPart__c = 'psupart');
        insert sr1;
         
         Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SCM',componentDiskModel__c = 'testcompdisk0',componentServicePartNumber__c = 'srparttest963');
        insert c1;
        
        Component__c c2 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD',componentDiskModel__c = 'srparts122');
        insert c2;
        
         Component__c c3 = new Component__c(componentAsset__c= asst.Id,componentServicePartNumber__c = 'psupart');
        insert c3;
        
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
        
    }
    static testMethod void testAsupComponentToComponents3(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
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
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
         Asup_Components__c asup4 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN123456', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SSD', asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentDiskSizeGB__c = '100');
        insert asup4;
        Asup_Components__c asup5 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN1234CON', asupComponentDiskModel__c = 'TestModelCON',
                                                          asupComponentType__c = 'Controller',
                                                          asupComponentDiskSizeGB__c = '100',asupComponentControllerState__c ='Test');
        insert asup5;
        Asup_Components__c asup6 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN1234', asupComponentDiskModel__c = 'TestModel11',
                                                          asupComponentType__c = 'SSD',asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentDiskSizeGB__c = '100');
        
        insert asup6;
        
        Asup_Components__c asup7 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN12345', asupComponentDiskModel__c = 'TestModel1123',
                                                          asupComponentType__c = 'PSU',asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentDiskSizeGB__c = '100');
        Insert asup7;
        
        Asup_Components__c asup8 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestCompSN12345', asupComponentDiskModel__c = 'TestModel1123',
                                                          asupComponentType__c = 'Controller',
                                                          asupComponentDiskSizeGB__c = '100');
        Insert asup8;
        
        Asup_Components__c asup9 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentType__c = 'SSD');
        Insert asup9;
        Asup_Components__c asup10 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentType__c = 'FC',Component_Part_Number__c='testspart');
        Insert asup10;
        Asup_Components__c asup11 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentType__c = 'SCM',Component_Part_Number__c='testspart45');
        Insert asup11;
        Asup_Components__c asup12 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,
                                                          asupComponentSN__c = 'TestSN123s', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SCM', asupComponentDiskUsedState__c = 'Failed',
                                                          asupComponentDiskSizeGB__c = '100',Component_Part_Number__c='testspart');
        insert asup12;
        SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum123g',srModelNumbers__c='testspartg', srmetadataIsValid__c = True);
        insert sr;
       
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum1',srModelNumbers__c='TestModel,Testmodel1', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
        insert sr1;
        SR_Meta_Data__c sr11 = new SR_Meta_Data__c(srPart__c='TestSPNum123', srModelNumbers__c='TestModelCON11',srmetadataIsValid__c = True,
                                                   srProductCode__c = 'SSD1234');
        insert sr11;
        
        
        
        SR_Meta_Data__c sr2 = new SR_Meta_Data__c(srPart__c='TestSPNum2',srModelNumbers__c='TestModel,Testmodel2', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
        insert sr2;
        
        
        SR_Meta_Data__c sr3 = new SR_Meta_Data__c(srPart__c='TestSPNum3',srModelNumbers__c='TestModelCON', srmetadataIsValid__c = True,srProduct_Name__c = 'CS210 Storage Array', srDynamicSKU__c = 'CS215-2G',srProductCode__c = 'CS210,CS215',srAssetType__c = 'Legacy,TestAssetType2');
        insert sr3;
        
        SR_Meta_Data__c sr4 = new SR_Meta_Data__c(srPart__c='TestSPNum4',srModelNumbers__c= null,srmetadataIsValid__c = True, srProduct_Name__c = 'CS210 Storage Array', srDynamicSKU__c = 'CS215-2G',srProductCode__c = 'CS210,CS215',srAssetType__c = 'Legacy,TestAssetType2');
        insert sr4;
        
        SR_Meta_Data__c sr5 = new SR_Meta_Data__c(srPart__c='TestModelsrpart',srModelNumbers__c= 'TestModel11',srmetadataIsValid__c = True, srProduct_Name__c = 'CS210 Storage Array', srDynamicSKU__c = 'CS215-2G',srProductCode__c = 'CS210,CS215',srAssetType__c = 'Legacy,TestAssetType2');
        insert sr5;
        
        SR_Meta_Data__c sr6 = new SR_Meta_Data__c(srPart__c='TestModelsrpart1',srmetadataIsValid__c = True, srProduct_Name__c = 'CS210 Storage Array',srType__c = 'Controller');
        insert sr6;
        SR_Meta_Data__c sr7 = new SR_Meta_Data__c(srProductCode__c='CS220',srPart__c='TestSPNum1456d',srType__c = 'SCM', srModelNumbers__c='testspart', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2');
        insert sr7;
        Component__c c = new Component__c(componentAsset__c= asst.Id,componentType__c ='FC',componentServicePartNumber__c = 'TestModelsrpartdfh');
        insert c;
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD',componentServicePartNumber__c = 'TestModelsrpart');
        insert c1;
        Component__c c2 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD', componentServicePartNumber__c = 'TestSPNum1');
        insert c2;
        Component__c c3 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller', componentServicePartNumber__c = 'TestSPNum145');
        insert c3;
        c3.componentServicePartNumber__c ='TestSPNum3';
        update c3;
        
        Component__c c4 = new Component__c(componentAsset__c= asst.Id,componentType__c ='PWR(power supply)');
        insert c4;
        
        Component__c c5 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller');
        insert c5;
        
        Component__c c6 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller',componentServicePartNumber__c = 'TestServicePart');
        insert c6;
        Component__c c7 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SCM',componentDiskModel__c = null);
        insert c7;
        
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
    }
    static testMethod void testAsupComponentToComponents4(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
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
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
         Asup_Components__c asup4 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN123456', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'FC', asupComponentDiskUsedState__c = 'Failed',
                                                          asupComponentDiskSizeGB__c = '100',Component_Part_Number__c='testpart');
        insert asup4;
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum145',srType__c = 'FC', srModelNumbers__c='testpart', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
        insert sr1;
         Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='FC',componentServicePartNumber__c = 'TestSPNum145');
        insert c1;
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
    }
    static testMethod void testAsupComponentToComponents5(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
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
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
         Asup_Components__c asup4 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN123s456', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'FC', asupComponentDiskUsedState__c = 'Failed',
                                                          asupComponentDiskSizeGB__c = '100',Component_Part_Number__c='testspart');
        insert asup4;
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum145',srType__c = 'FC', srModelNumbers__c='testspart', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
        insert sr1;
         Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='FC',componentServicePartNumber__c = 'TestSPNum1445');
        insert c1;
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest(); 
    }  
    static testMethod void testAsupComponentToComponents6(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
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
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
        Asup_Components__c asup4 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,
                                                          asupComponentSN__c = 'TestSN123s456', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SSD', asupComponentDiskUsedState__c = 'Failed',
                                                          asupComponentDiskSizeGB__c = '100',Component_Part_Number__c='testspart');
        insert asup4;
        Asup_Components__c asup5 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,
                                                          asupComponentSN__c = 'TestSN123s', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SCM', asupComponentDiskUsedState__c = 'Failed',
                                                          asupComponentDiskSizeGB__c = '100',Component_Part_Number__c='testspart');
        insert asup5;
        
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srProductCode__c='CS220',srPart__c='TestSPNum145d',srType__c = 'SSD', srModelNumbers__c='testspart', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2');
        insert sr1;
        SR_Meta_Data__c sr2 = new SR_Meta_Data__c(srProductCode__c='CS220',srPart__c='TestSPNum1456d',srType__c = 'SCM', srModelNumbers__c='testspart', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2');
        insert sr2;
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD');
        insert c1;
        Component__c c2 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SCM',componentDiskModel__c = null);
        insert c2;
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
    }
    static testMethod void testAsupComponentToComponents7(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
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
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
        Asup_Components__c asup4 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,
                                                          asupComponentSN__c = 'TestSN123s456', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'Controller', asupComponentDiskUsedState__c = 'Failed',
                                                          asupComponentDiskSizeGB__c = '100',Component_Part_Number__c='testspart');
        insert asup4;
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srProductCode__c='CS220',srPart__c='TestSPNum145d',srType__c = 'SSD', srModelNumbers__c='testspart', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2');
        insert sr1;
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller');
        insert c1;
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
    }
    static testMethod void testAsupComponentToComponents8(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
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
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
         Asup_Components__c asup4 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN123456', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SSD', asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentDiskSizeGB__c = '100');
        insert asup4;
        Asup_Components__c asup5 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN1234CON', asupComponentDiskModel__c = 'TestModelCON',
                                                          asupComponentType__c = 'Controller',
                                                          asupComponentDiskSizeGB__c = '100',asupComponentControllerState__c ='Test');
        insert asup5;
        Asup_Components__c asup6 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN1234', asupComponentDiskModel__c = 'TestModel11',
                                                          asupComponentType__c = 'SSD',asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentDiskSizeGB__c = '100');
        
        insert asup6;
        
        Asup_Components__c asup7 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN12345', asupComponentDiskModel__c = 'TestModel1123',
                                                          asupComponentType__c = 'PSU',asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentDiskSizeGB__c = '100');
        Insert asup7;
        
        Asup_Components__c asup8 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestCompSN12345', asupComponentDiskModel__c = 'TestModel1123',
                                                          asupComponentType__c = 'Controller',
                                                          asupComponentDiskSizeGB__c = '100');
        Insert asup8;
        
        Asup_Components__c asup9 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentType__c = 'SSD');
        Insert asup9;
        Asup_Components__c asup10 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentType__c = 'FC',Component_Part_Number__c='testspart');
        Insert asup10;
        Asup_Components__c asup11 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentType__c = 'SCM',Component_Part_Number__c='testspart45');
        Insert asup11;
        Asup_Components__c asup12 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id,
                                                          asupComponentSN__c = 'TestSN123s', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'SCM', asupComponentDiskUsedState__c = 'Failed',
                                                          asupComponentDiskSizeGB__c = '100',Component_Part_Number__c='testspart');
        insert asup12;
        SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum123g',srModelNumbers__c='testspartg', srmetadataIsValid__c = True);
        insert sr;
       
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum1',srModelNumbers__c='TestModel,Testmodel1', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
        insert sr1;
        SR_Meta_Data__c sr11 = new SR_Meta_Data__c(srPart__c='TestSPNum123', srModelNumbers__c='TestModelCON11',srmetadataIsValid__c = True,
                                                   srProductCode__c = 'SSD1234');
        insert sr11;
        
        
        
        SR_Meta_Data__c sr2 = new SR_Meta_Data__c(srPart__c='TestSPNum2',srModelNumbers__c='TestModel,Testmodel2', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
        insert sr2;
        
        
        SR_Meta_Data__c sr3 = new SR_Meta_Data__c(srPart__c='TestSPNum3',srModelNumbers__c='TestModelCON', srmetadataIsValid__c = True,srProduct_Name__c = 'CS210 Storage Array', srDynamicSKU__c = 'CS215-2G',srProductCode__c = 'CS210,CS215',srAssetType__c = 'Legacy,TestAssetType2');
        insert sr3;
        
        SR_Meta_Data__c sr4 = new SR_Meta_Data__c(srPart__c='TestSPNum4',srModelNumbers__c= null,srmetadataIsValid__c = True, srProduct_Name__c = 'CS210 Storage Array', srDynamicSKU__c = 'CS215-2G',srProductCode__c = 'CS210,CS215',srAssetType__c = 'Legacy,TestAssetType2');
        insert sr4;
        
        SR_Meta_Data__c sr5 = new SR_Meta_Data__c(srPart__c='TestModelsrpart',srModelNumbers__c= 'TestModel11',srmetadataIsValid__c = True, srProduct_Name__c = 'CS210 Storage Array', srDynamicSKU__c = 'CS215-2G',srProductCode__c = 'CS210,CS215',srAssetType__c = 'Legacy,TestAssetType2');
        insert sr5;
        
        SR_Meta_Data__c sr6 = new SR_Meta_Data__c(srPart__c='TestModelsrpart1',srmetadataIsValid__c = True, srProduct_Name__c = 'CS210 Storage Array',srType__c = 'Controller');
        insert sr6;
        SR_Meta_Data__c sr7 = new SR_Meta_Data__c(srProductCode__c='CS220',srPart__c='TestSPNum1456d',srType__c = 'SCM', srModelNumbers__c='testspart', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2');
        insert sr7;
        Component__c c = new Component__c(componentAsset__c= asst.Id,componentType__c ='FC',componentServicePartNumber__c = 'TestModelsrpartdfh');
        insert c;
        Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD',componentServicePartNumber__c = 'TestModelsrpart');
        insert c1;
        Component__c c2 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SSD', componentServicePartNumber__c = 'TestSPNum1');
        insert c2;
        Component__c c3 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller', componentServicePartNumber__c = 'TestSPNum145');
        insert c3;
        c3.componentServicePartNumber__c ='TestSPNum3';
        update c3;
        
        Component__c c4 = new Component__c(componentAsset__c= asst.Id,componentType__c ='PWR(power supply)');
        insert c4;
        
        Component__c c5 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller');
        insert c5;
        
        Component__c c6 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller',componentServicePartNumber__c = 'TestServicePart');
        insert c6;
        Component__c c7 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SCM',componentDiskModel__c = null);
        insert c7;
        
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
    }
     static testMethod void testAsupComponentToComponents9(){
         
         ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
         
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
                               Asset_Type_Build__c ='Testasupassettype');
        
         insert asst;
          Asup_Components__c asup4 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN123456', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'Controller', asupComponentDiskUsedState__c = 'Valid',
                                                          asupComponentDiskSizeGB__c = '100');
        insert asup4;
         SR_Meta_Data__c sr = new SR_Meta_Data__c(srPart__c='TestSPNum123g',srModelNumbers__c='testspart123', srmetadataIsValid__c = True);
        insert sr;
          Component__c c6 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller',componentServicePartNumber__c = 'TestServicePart');
        insert c6;
        Component__c c7 = new Component__c(componentAsset__c= asst.Id,componentType__c ='Controller',componentDiskModel__c = null);
        insert c7;
        
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
     }
  static testMethod void testAsupComponentToComponents10(){
      
      ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
      
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
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
        //Asset asst1 = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
        //                     Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
        //                   Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
        //                 Asset_Type_Build__c ='Next Gen');
        
        //insert asst1;
        Asset asst1 = new Asset(Name = 'TestAsset1', AccountId = acc.Id, Product2Id = testProduct1.id,HPE_Serial_Number__c = 'HPE123457',
                                Array_Controller__c = 'CS3001',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                                Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F');
        
        insert asst1;
     
        Asup_Components__c asup = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                         asupComponentType__c = 'PSU',asupComponentSN__c = '1233',
                                                         asupComponentDiskSizeGB__c = '100',Component_Part_Number__c = 'test123');
        insert asup;
         Asup_Components__c asup1 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                         asupComponentType__c = 'SCM',asupComponentSN__c = '12334');
        insert asup1;
         Asup_Components__c asup2 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst1.Id, 
                                                         asupComponentType__c = 'SSD',asupComponentSN__c = '12335');
        insert asup2;
        SR_Meta_Data__c sr10 = new SR_Meta_Data__c(srmetadataIsValid__c = True, srModelNumbers__c = 'test123',srPart__c = 'srparts123');
        insert sr10;
        SR_Meta_Data__c sr11 = new SR_Meta_Data__c(srmetadataIsValid__c = True, srProductCode__c = 'test1234',srPart__c = 'srparts122');
        insert sr11;
        Component__c c = new Component__c(componentAsset__c= asst.Id,componentType__c ='PSU',componentServicePartNumber__c = 'srparts123',componentComponentSN__c = '1233');
        insert c;
        Component__c c8 = new Component__c(componentAsset__c= asst.Id,componentType__c ='SCM',componentDiskModel__c = 'srparts123',componentComponentSN__c = '12334');
        insert c8;
         Component__c c1 = new Component__c(componentAsset__c= asst1.Id,componentType__c ='SSD',componentDiskModel__c = 'srparts122',componentComponentSN__c = '12335');
        insert c1;
        
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest();
        
    }
    static testMethod void testAsupComponentToComponents11(){
        
        ASUP_Processing__c setting = new ASUP_Processing__c();
        setting.User_Id__c = '005D5000004GbvkIAC';
        insert setting;
        
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
                               Asset_Type_Build__c ='Testasupassettype');
        
        insert asst;
         Asup_Components__c asup4 = new Asup_Components__c(asupComponentAccount__c = acc.Id, asupComponentAsset__c = asst.Id, 
                                                          asupComponentSN__c = 'TestSN123s456', asupComponentDiskModel__c = 'TestModel',
                                                          asupComponentType__c = 'NIC', asupComponentDiskUsedState__c = 'Failed',
                                                          asupComponentDiskSizeGB__c = '100',Component_Part_Number__c='testspart');
        insert asup4;
        SR_Meta_Data__c sr1 = new SR_Meta_Data__c(srPart__c='TestSPNum145',srType__c = 'NIC', srModelNumbers__c='testspart', srmetadataIsValid__c = True,srAssetType__c = 'Legacy,TestAssetType2',srProductCode__c = 'CS210,CS215');
        insert sr1;
         Component__c c1 = new Component__c(componentAsset__c= asst.Id,componentType__c ='NIC',componentServicePartNumber__c = 'TestSPNum1445');
        insert c1;
        Test.startTest();
        ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
        Database.executeBatch(pb);
        Test.stopTest(); 
    }  
    
}