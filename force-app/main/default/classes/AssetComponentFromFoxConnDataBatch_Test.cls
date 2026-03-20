@isTest
public class AssetComponentFromFoxConnDataBatch_Test {
    static testMethod void componentPopulation(){
        
        Product2 productRecord = new Product2();
        productRecord.Name = 'AF1000';
        productRecord.Component_Code__c = 'test1';
        productRecord.ProductCode = 'AF1000';
        productRecord.Asset_Type__c = 'test1';
        productRecord.infosight_identifier__c = 'test1';
        productRecord.HPE_SKU__C = 'R4U28A';
        productRecord.Family = 'Hybrid Flash Array';
        productRecord.asset_Type__c = 'test1';
        productRecord.Array_Controller__c = 'test1';
        insert productRecord;
        
        Account accountRecord = new Account();
        accountRecord.Name = 'test acc';
        insert accountRecord;
        
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'last';
        contactRecord.Email = 'test@gmail.com';
        contactRecord.AccountId = accountRecord.Id;
        insert contactRecord;
        
        Asset assetRecord = new Asset();
        assetRecord.Array_Cache__c = 'test1-test1';
        assetRecord.Array_Capacity__c = 'test1';
        assetRecord.Array_Controller__c = 'AF3000';
        assetRecord.Array_Networking__c = 'test3';
        assetRecord.ContactId = contactRecord.Id;
        assetRecord.AccountId = accountRecord.Id;
        assetRecord.Order_Type__c = 'Eval Unit';
        assetRecord.Array_Controller__c = 'AF1000';
        assetRecord.Name = 'CZ1234';
        assetRecord.Expansion_Shelf_Base__c = 'R4U28A';
        assetRecord.Array_Networking__c = 'test1-test1';
        assetRecord.Product2Id = productRecord.id;
        assetRecord.Dynamic_SKU__c = 'ES3';
        assetRecord.SSD_Bank_A__c = 'test1';
        assetRecord.SSD_Bank_B__c = 'test1';
        assetRecord.HPE_Serial_Number__c = '5UM910001V';
        assetRecord.SerialNumber = 'AF-206646';
        insert assetRecord;
        
        
        SR_Meta_Data__c srMetaData = new SR_Meta_Data__c(srPart__c = 'TestSPNum12',srmetadataIsValid__c = True,
                                                 srProductCode__c = 'SSD123',srModelNumbers__c = '620-0003-002');
        insert srMetaData;
        
        SR_Meta_Data__c srMetaData1 = new SR_Meta_Data__c(srPart__c = 'TestSPNum123',srmetadataIsValid__c = True,
                                                  srProductCode__c = 'SSD1237',srModelNumbers__c = '620-0003-003');
        insert srMetaData1;
        
        
        
        FoxConnFactoryUCData__c foxConn = new FoxConnFactoryUCData__c();
        foxConn.Child_PN__c = 'NMB-620-0003-002';
        foxConn.Unit_Serial_Number__c = 'CZ1234';
        foxConn.Child_SN__c = '123456';
        foxConn.FoxConn_Proccessed__c = null;
        insert foxConn;
        
       
        
        
        
        Component__c component = new Component__c();
        component.componentAsset__c = assetRecord.id;
        component.componentType__c = 'CDM';
        component.componentComponentSN__c = '12345';
        upsert component;
        
        test.startTest();
        AssetComponentFromFoxConnDataBatch execute = new AssetComponentFromFoxConnDataBatch();
        Database.executeBatch(execute);
        test.stopTest();
    }
    static testMethod void componentPopulation1(){
        
        Product2 productRecord = new Product2();
        productRecord.Name = 'AF1000';
        productRecord.Component_Code__c = 'test1';
        productRecord.ProductCode = 'AF1000';
        productRecord.Asset_Type__c = 'test1';
        productRecord.infosight_identifier__c = 'test1';
        productRecord.HPE_SKU__C = 'R4U28A';
        productRecord.Family = 'Hybrid Flash Array';
        productRecord.asset_Type__c = 'test1';
        productRecord.Array_Controller__c = 'test1';
        insert productRecord;
        
        Account accountRecord = new Account();
        accountRecord.Name = 'test acc';
        insert accountRecord;
        
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'last';
        contactRecord.Email = 'test@gmail.com';
        contactRecord.AccountId = accountRecord.Id;
        insert contactRecord;
        
        Asset assetRecord = new Asset();
        assetRecord.Array_Cache__c = 'test1-test1';
        assetRecord.Array_Capacity__c = 'test1';
        assetRecord.Array_Controller__c = 'AF3000';
        assetRecord.Array_Networking__c = 'test3';
        assetRecord.ContactId = contactRecord.Id;
        assetRecord.AccountId = accountRecord.Id;
        assetRecord.Order_Type__c = 'Eval Unit';
        assetRecord.Array_Controller__c = 'AF1000';
        assetRecord.Name = 'CZ12345';
        assetRecord.Expansion_Shelf_Base__c = 'R4U28A';
        assetRecord.Array_Networking__c = 'test1-test1';
        assetRecord.Product2Id = productRecord.id;
        assetRecord.Dynamic_SKU__c = 'ES3';
        assetRecord.SSD_Bank_A__c = 'test1';
        assetRecord.SSD_Bank_B__c = 'test1';
        assetRecord.HPE_Serial_Number__c = '5UM910001V';
        assetRecord.SerialNumber = 'AF-206646';
        insert assetRecord;
        
        
        
        SR_Meta_Data__c srMetaData = new SR_Meta_Data__c(srPart__c = 'TestSPNum12',srmetadataIsValid__c = True,
                                                 srProductCode__c = 'SSD123',srModelNumbers__c = '620-0003-3323');
        insert srMetaData;
        
        SR_Meta_Data__c srMetaData1 = new SR_Meta_Data__c(srPart__c = 'TestSPNum123',srmetadataIsValid__c = True,
                                                  srProductCode__c = 'SSD1237',srModelNumbers__c = '620-0003-3324');
        insert srMetaData1;
        
        FoxConnFactoryUCData__c foxConn1 = new FoxConnFactoryUCData__c();
        foxConn1.Child_PN__c = 'NMB-620-0003-3323';
        foxConn1.Unit_Serial_Number__c = 'CZ12345';
        foxConn1.FoxConn_Proccessed__c = null;
        insert foxConn1;
        
        test.startTest();
        AssetComponentFromFoxConnDataBatch execute = new AssetComponentFromFoxConnDataBatch();
        Database.executeBatch(execute);
        test.stopTest();        
    }
    static testMethod void componentPopulation2(){
        
        Product2 productRecord = new Product2();
        productRecord.Name = 'AF1000';
        productRecord.Component_Code__c = 'test1';
        productRecord.ProductCode = 'AF1000';
        productRecord.Asset_Type__c = 'test1';
        productRecord.infosight_identifier__c = 'test1';
        productRecord.HPE_SKU__C = 'R4U28A';
        productRecord.Family = 'Hybrid Flash Array';
        productRecord.asset_Type__c = 'test1';
        productRecord.Array_Controller__c = 'test1';
        insert productRecord;
        
        Account accountRecord = new Account();
        accountRecord.Name = 'test acc';
        insert accountRecord;
        
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'last';
        contactRecord.Email = 'test@gmail.com';
        contactRecord.AccountId = accountRecord.Id;
        insert contactRecord;
        
        Asset assetRecord = new Asset();
        assetRecord.Array_Cache__c = 'test1-test1';
        assetRecord.Array_Capacity__c = 'test1';
        assetRecord.Array_Controller__c = 'AF3000';
        assetRecord.Array_Networking__c = 'test3';
        assetRecord.ContactId = contactRecord.Id;
        assetRecord.AccountId = accountRecord.Id;
        assetRecord.Order_Type__c = 'Eval Unit';
        assetRecord.Array_Controller__c = 'AF1000';
        assetRecord.Name = 'CZ12345';
        assetRecord.Expansion_Shelf_Base__c = 'R4U28A';
        assetRecord.Array_Networking__c = 'test1-test1';
        assetRecord.Product2Id = productRecord.id;
        assetRecord.Dynamic_SKU__c = 'ES3';
        assetRecord.SSD_Bank_A__c = 'test1';
        assetRecord.SSD_Bank_B__c = 'test1';
        assetRecord.HPE_Serial_Number__c = '5UM910001V';
        assetRecord.SerialNumber = 'AF-206646';
        insert assetRecord;
        
        
        
        SR_Meta_Data__c srMetaData = new SR_Meta_Data__c(srPart__c = 'TestSPNum12',srmetadataIsValid__c = True,
                                                 srProductCode__c = 'SSD123',srModelNumbers__c = '620-0003-3323');
        insert srMetaData;
        
        SR_Meta_Data__c srMetaData1 = new SR_Meta_Data__c(srPart__c = 'TestSPNum123',srmetadataIsValid__c = True,
                                                  srProductCode__c = 'SSD1237',srModelNumbers__c = '620-0003-3324');
        insert srMetaData1;
        
        FoxConnFactoryUCData__c foxConn1 = new FoxConnFactoryUCData__c();
        foxConn1.Child_PN__c = 'NMB-620-0003-33238';
        foxConn1.Unit_Serial_Number__c = 'CZ12345';
        foxConn1.FoxConn_Proccessed__c = null;
        insert foxConn1;
        
        test.startTest();
        AssetComponentFromFoxConnDataBatch e = new AssetComponentFromFoxConnDataBatch();
        Database.executeBatch(e);
        test.stopTest();        
    }
}