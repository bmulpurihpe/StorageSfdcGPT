@isTest
public class Test_sendEmailTrg {
    
    @TestSetup
    public static void setupData(){
        
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
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.CloseDate = System.Today();
        opp.Type = 'New Business';
        opp.StageName ='Prospect';
        opp.Sales_Region__c = 'NA Central TOLA';
        opp.Sales_Area__c   = 'NA Central';
        opp.Sales_Theater__c = 'NA';
        opp.HPE_Opportunity_ID__c = 'OPE-1234567890';
        opp.AccountId=acc.Id;
        insert opp;       
        
        Asset a =new Asset();
        a.Array_Cache__c='test1-test1';
        a.Array_Capacity__c='test1';
        a.Array_Controller__c='AF3000';
        a.Array_Networking__c='test3';
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Purchased';
        a.Array_Controller__c='test1';
        a.Name='test';
        a.Expansion_Shelf_Base__c='test1';
        a.Array_Networking__c='test1-test1';
        a.Dynamic_SKU__c='ES3-H126';
        a.SSD_Bank_A__c='test1';
        a.SSD_Bank_B__c='test1';
        a.HPE_Serial_Number__c = '5UM910001V';
        a.SerialNumber = 'AF-206646';
        a.Install_Country__c = 'Japan';
        a.ES_API_Call_Completed__c = True;
        a.HPE_Order_Number__c = 'Test Order';
        a.Product2Id=pro.id;
        a.SLA__c = 'Premium';
        a.Support_Start_Date_Asset__c = System.Today();
        a.Support_End_Date__c = System.Today() + 5;
        a.Opportunity_Asset__c = opp.Id;
        
        Asset a1 =new Asset();
        a1.Array_Cache__c='test1-test1';
        a1.Array_Capacity__c='test1';
        a1.Array_Controller__c='AF3000';
        a1.Array_Networking__c='test3';
        a1.ContactId=con.Id;
        a1.AccountId=acc.Id;
        a1.Order_Type__c = 'Purchased';
        a1.Array_Controller__c='test1';
        a1.Name='test';
        a1.Expansion_Shelf_Base__c='test1';
        a1.Array_Networking__c='test1-test1';
        a1.Dynamic_SKU__c='ES3-H126';
        a1.SSD_Bank_A__c='test1';
        a1.SSD_Bank_B__c='test1';
        a1.HPE_Serial_Number__c = '5UM910002V';
        a1.SerialNumber = 'AF-206647';
        a1.Install_Country__c = 'JP';
        a1.HPE_Order_Number__c = 'Test Order';
        a1.Product2Id=pro.id;
        a1.SLA__c = 'Premium';
        a1.Support_Start_Date_Asset__c = System.Today();
        a1.Support_End_Date__c = System.Today() + 5;
        a1.Opportunity_Asset__c = opp.Id;
        
        List<Asset> assets = New List<Asset> {a,a1};
            insert assets; 
    }
    
    @istest
    public static void sendEmailTest(){
     
        
        Asset asset = [Select Id, ES_API_Call_Completed__c, SLA__C, Support_End_Date__c from Asset where ES_API_Call_Completed__c = False LIMIT 1 ];
        asset.ES_API_Call_Completed__c = True;
        asset.SLA__c = 'Premium 4 hour';
        asset.Support_End_Date__c = System.Today() + 20; 
        
       Test.startTest();
        update asset; 
        Test.stopTest();
    }
    
}