@isTest(seeAllData=false)
private class Test_assetNextGenPreventRecursion{
    static testmethod void mytest1(){
        
        Product2 pro=new Product2();
        pro.Name='test';
        Pro.Component_Code__c='test1';
        pro.ProductCode='test1';
        pro.Asset_Type__c='test1';
        pro.infosight_identifier__c='test1';
        //pro.HPE_SKU__C='test1';
        pro.Family='Hybrid Flash Array';
        pro.asset_Type__c='test1';
        pro.Array_Controller__c='test1';
        insert pro;
        
        Account acc=new Account();
        acc.Name='test acc';
        
        insert acc;
        Contact con= new Contact();
        con.LastName='last';
        con.Email='test@gmail.com';
        
        con.AccountId=acc.Id;
        insert con;
        
        Asset a =new Asset();
        a.Array_Cache__c='test1-test1';
        a.Array_Capacity__c='test1';
        a.Array_Controller__c='AF3000';
        a.Array_Networking__c='test3';
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        a.Array_Controller__c='test1';
        a.Name='test';
        a.Expansion_Shelf_Base__c='test1';
        a.Array_Networking__c='test1-test1';
        a.Product2Id=pro.id;
        a.Dynamic_SKU__c='ES3';
        a.SSD_Bank_A__c='test1';
        a.SSD_Bank_B__c='test1';
        a.HPE_Serial_Number__c = '5UM910001V';
        a.SerialNumber = 'AF-206646';
        insert a;
        
        test.StartTest();
            assetNextGenPreventRecursion.setOfIds.add (a.Id);
        test.StopTest();
    }
}