@isTest
public class assetTriggerHandlerBatchApexTest {
    
    @isTest static void differentAssetLocation(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(FirstName='Test', LastName='Name', AccountId=acc.Id);
        insert con;
        Product2 pro=new Product2();
        pro.Name='HF60';
        Pro.Component_Code__c='HF60';
        pro.ProductCode='HF60';
        pro.Asset_Type__c='HF60';
        pro.infosight_identifier__c='HF60';
        pro.Family='HF60';
        pro.asset_Type__c='HF60';
        pro.Product_Type_2__c='Networking';
        pro.Product_Type__c = 'Hardware';
        insert pro;
        Asset newAsset = new Asset(Name                                      = 'AA-111111',
                                   AccountId                                 = acc.Id,
                                   ContactId                                 = con.Id,
                                   SLA__c                                    = 'Premium',
                                   Install_Street1__c                        = '123 Main Street',
                                   Install_Street2__c                        = 'Suite 100',
                                   Install_City__c                           = 'San Jose',
                                   Install_State_Province__c                 = 'CA',
                                   Install_Zip_Code__c                       = '95151',
                                   Install_Country__c                        = 'United States',
                                   Ship_Date__c                              = Date.today().addDays(-180),
                                   assetPartShipLastValidatedDatetime__c     = Date.today(),
                                   HPE_Serial_Number__c                      = 'Abc12234',
                                   assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                                   
                                   Array_Cache__c='3840',
                                   Array_Capacity__c='3840',
                                   Array_Controller__c ='HF60',
                                   
                                   Array_Networking__c='3840',
                                   HPE_Support_SKU__c = 'HPE123456',
                                   Order_Type__c = 'Eval Unit',
                                   
                                   
                                   Product2Id=pro.id,
                                   SSD_Bank_A__c='3840',
                                   SSD_Bank_B__c='3840',
                                   Asset_Type_Build__c='3840',
                                   //HPE_Serial_Number__c= 'test1';
                                   Date_of_Refresh__c = System.Today(),
                                   Support_Start_Date_Asset__c = System.Today(),
                                   NDU_Required__c = false,
                                   Timeless_fulfillment__c = True,
                                   Controller_Refresh_1__c = 'HF60',
                                   Controller_Refresh_Networking_SKU__c='4P',
                                   
                                   //Order_Type__c = 'Purchased',
                                   Timeless_Storage__c = True,
                                   Controller_Refresh_1_SKU__c = 'R4A13A');
        insert newAsset;
        newAsset.Install_City__c = 'City';
        update newAsset;
        
        List<Id> newAssetID = new List<Id>();
        newAssetID.add(newAsset.Id);
        List<ID> oldAssetID = new List<ID>();
        oldAssetID.add(newAsset.Id);
        Map<Id, string> oldInstallStreet1 = new Map<Id, string>();
        Map<Id, string> oldInstallStreet2 = new Map<Id, string>();
        Map<Id, string> oldInstallCity = new Map<Id, string>();
        oldInstallCity.put(newAsset.id, 'US');
        Map<Id, string> oldInstallStateProvince = new Map<Id, string>();
        Map<Id, string> oldInstallZipCode = new Map<Id, string>();
        Map<Id, string> oldInstallCountry = new Map<Id, string>();
        Map<Id, DateTime> oldPartShipLastValidatedDatetime = new Map<Id, DateTime>();
        Map<Id, string> oldPartShipLastValidatedByInfo = new Map<Id, string>();
        Map<Id, Id> oldAssetIDfromNewAsset = new Map<Id, Id>();
        
        assetTriggerHandlerBatchApex batchapex = new assetTriggerHandlerBatchApex(newAssetID, oldAssetID, oldInstallStreet1, oldInstallStreet2, oldInstallCity, oldInstallStateProvince, oldInstallZipCode, oldInstallCountry, oldPartShipLastValidatedDatetime, oldPartShipLastValidatedByInfo, oldAssetIDfromNewAsset);
        Database.executeBatch(batchapex);
    }
}