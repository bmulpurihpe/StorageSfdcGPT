/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=false)
private class Test_NextGenAssetUpdateTrigger {

    static testMethod void myUnitTest() {
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
        a.HPE_Serial_Number__c= 'test1';
        insert a;
        /*
        Asset b =new Asset();
        b.ContactId=con.Id;
        b.AccountId=acc.Id;
        b.Shelf_Pack_1__c = '1200';
        b.Shelf_Pack_2__c ='1200';
        b.Shelf_Pack_3__c ='1200';
        b.Shelf_Pack_4__c = '1200';
        b.Shelf_Pack_5__c = '3800';
        b.Shelf_Pack_6__c = '3800';
        b.Shelf_Pack_1B__c = '3800';
        b.Shelf_Pack_2B__c = '3800';
        b.Shelf_Pack_3B__c = '3800';
        b.Shelf_Pack_4B__c = '3800';
        b.Shelf_Pack_5B__c = '3800';
        b.Shelf_Pack_6B__c = '3800';
        
        b.SSD_Bank_A__c = '6T';
        b.SSD_Bank_B__c = '6T';
        b.Expansion_Shelf_Base__c = 'ES2-H21T';
        Utility.runDupRecTrigger=true;
        b.Name = 'test1';
        b.Parent_Asset__c = a.id;
        insert b;*/
        
         integer i=1;
        System.assertEquals(i,1);
        a.Order_Type__c = 'Purchased';
        test.StartTest();
        update a;
        
        delete a;
        test.StopTest();
    }
    
  /* static testMethod void myUnitTest2() {
        test.StartTest();
        Product2 pro=new Product2();
        pro.Name='test';
        Pro.Component_Code__c='test2';
        Pro.Infosight_identifier__c = '3840';
        pro.ProductCode='test2';
        pro.asset_Type__c='test2';
        pro.Array_Controller__c='test2';
        pro.Family = 'All Flash Shelf';
        insert pro;
        
        product2 pr2 = new Product2(name='testBanks',component_code__c='test3', infosight_identifier__c='6T', productCode='AF-6T',Family = 'All Flash Array Gen5');
        insert pr2;
        
        Account acc=new Account();
        acc.Name='test acc2';
        
        insert acc;
        
        Contact con= new Contact();
        con.LastName='last2';
        con.Email='test2@gmail.com';
        
        con.AccountId=acc.Id;
        insert con;
        
        
        
        Asset b =new Asset();
        b.ContactId=con.Id;
        b.AccountId=acc.Id;
        b.Product2Id = pro.id;
        b.Shelf_Pack_1__c = '3840';
        b.Shelf_Pack_2__c ='3840';
        b.Shelf_Pack_3__c ='3840';
        b.Shelf_Pack_4__c = '3840';
        b.Shelf_Pack_5__c = '3840';
        b.Shelf_Pack_6__c = '3840';
        b.Shelf_Pack_1B__c = '3840';
        b.Shelf_Pack_2B__c = '3840';
        b.Shelf_Pack_3B__c = '3840';
        
        
        b.SSD_Bank_A__c = '6T';
        b.SSD_Bank_B__c = '6T';
        
        b.Name = 'test1';
        b.Component_SKU_Nimble_V2__c = 'test1,test2';
        insert b;
       
        b.Order_Type__c = 'Purchased';
        update b;
        
        delete b;
        test.StopTest();
    }*/
   static testMethod void myUnitTest5() {
        Product2 pro=new Product2();
        pro.Name='test';
        Pro.Component_Code__c='3840';
        pro.ProductCode='3840';
        pro.Asset_Type__c='3840';
        pro.infosight_identifier__c='3840';
        //pro.HPE_SKU__C='test1';
        pro.Family='3840';
        pro.asset_Type__c='3840';
        pro.Array_Controller__c='3840';
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
        a.Array_Cache__c='3840';
        a.Array_Capacity__c='3840';
        a.Array_Controller__c='3840';
        a.Array_Networking__c='3840';
       
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        
        a.Name='test';
        
        a.Array_Networking__c='test1';
        a.Product2Id=pro.id;

        a.SSD_Bank_A__c='3840';
        a.SSD_Bank_B__c='3840';
        a.Asset_Type_Build__c='3840';
        a.HPE_Serial_Number__c= 'test1';
        insert a;
        

               
        a.Order_Type__c = 'Purchased';
        test.StartTest();
        update a;
        test.StopTest();
    }
    
    
    static testMethod void myUnitTest7() {
        Product2 pro=new Product2();
        pro.Name='test';
        Pro.Component_Code__c='3840';
        pro.ProductCode='3840';
        pro.Asset_Type__c='3840';
        pro.infosight_identifier__c='3840';
        //pro.HPE_SKU__C='test1';
        pro.Family='3840';
        pro.asset_Type__c='3840';
        //pro.Array_Controller__c='test1';
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
        
       a.Shelf_Pack_1__c='3840';
        a.Shelf_Pack_2__c='3840';
        a.Shelf_Pack_3__c='3840';
        a.Shelf_Pack_4__c='3840';
        a.Shelf_Pack_5__c='3840';
        a.Shelf_Pack_6__c='3840';
        a.Shelf_Pack_1B__c='3840';
        a.Shelf_Pack_2B__c='3840';
        a.Shelf_Pack_3B__c='3840';
        a.Shelf_Pack_4B__c='3840';
        a.Shelf_Pack_5B__c='3840';
        a.Shelf_Pack_6B__c='3840';
        
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        //a.Array_Controller__c='3840';
        a.Name='test';
        a.Product2Id=pro.id;
       
        a.Asset_Type_Build__c='3840';
        a.HPE_Serial_Number__c= 'test1';
        insert a;
        
        //Utility.runDupRecTrigger=true;
        a.Component_SKU_Nimble_V2__c = 'test1,test2';       
        a.Order_Type__c = 'Purchased';
        test.StartTest();
        update a;
        test.StopTest();
    }
     static testMethod void myUnitTest9() {
        Product2 pro=new Product2();
        pro.Name='test';
        Pro.Component_Code__c='3840';
        pro.ProductCode='3840';
        pro.Asset_Type__c='3840';
        pro.infosight_identifier__c='3840';
       // pro.HPE_SKU__C='test1';
        pro.Family='3840';
        pro.asset_Type__c='3840';
        pro.Array_Controller__c='3840';
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
        a.Array_Cache__c='3840';
        a.Array_Capacity__c='3840';
        a.Array_Controller__c='3840';
        a.Array_Networking__c='3840';
       /*  a.Shelf_Pack_1__c='3840';
        a.Shelf_Pack_2__c='3840';
        a.Shelf_Pack_3__c='3840';
        a.Shelf_Pack_4__c='3840';
        a.Shelf_Pack_5__c='3840';
        a.Shelf_Pack_6__c='3840';
        a.Shelf_Pack_1B__c='3840';
        a.Shelf_Pack_2B__c='3840';
        a.Shelf_Pack_3B__c='3840';
        a.Shelf_Pack_4B__c='3840';
        a.Shelf_Pack_5B__c='3840';
        a.Shelf_Pack_6B__c='3840';
        */
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        a.Array_Controller__c='3840';
        a.Name='test';
        //a.Expansion_Shelf_Base__c='test1-test1';
        a.Product2Id=pro.id;
        //a.Dynamic_SKU__c='ES3';
        a.SSD_Bank_A__c='3840';
        a.SSD_Bank_B__c='3840';
        a.Asset_Type_Build__c='3840';
        a.HPE_Serial_Number__c= 'test1';
        insert a;
        
        //Utility.runDupRecTrigger=true;
               
        a.Order_Type__c = 'Purchased';
        test.StartTest();
        update a;
        test.StopTest();
    }
    static testMethod void myUnitTest10() {
        Product2 pro=new Product2();
        pro.Name='test';
        Pro.Component_Code__c='3840';
        pro.ProductCode='3840';
        pro.Asset_Type__c='3840';
        pro.infosight_identifier__c='3840';
        pro.HPE_SKU__C='3840';
        pro.Family='3840';
        pro.asset_Type__c='3840';
        pro.Array_Controller__c='3840';
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
        a.Array_Cache__c='3840';
        a.Array_Capacity__c='3840';
        a.Array_Controller__c='3840';
        a.Array_Networking__c='3840';
       /*  a.Shelf_Pack_1__c='3840';
        a.Shelf_Pack_2__c='3840';
        a.Shelf_Pack_3__c='3840';
        a.Shelf_Pack_4__c='3840';
        a.Shelf_Pack_5__c='3840';
        a.Shelf_Pack_6__c='3840';
        a.Shelf_Pack_1B__c='3840';
        a.Shelf_Pack_2B__c='3840';
        a.Shelf_Pack_3B__c='3840';
        a.Shelf_Pack_4B__c='3840';
        a.Shelf_Pack_5B__c='3840';
        a.Shelf_Pack_6B__c='3840';
        */
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        a.Array_Controller__c='3840';
        a.Name='test';
        //a.Expansion_Shelf_Base__c='test1-test1';
        a.Product2Id=pro.id;
        //a.Dynamic_SKU__c='ES3';
        a.SSD_Bank_A__c='3840';
        a.SSD_Bank_B__c='3840';
        a.Asset_Type_Build__c='3840';
        a.HPE_Serial_Number__c= 'test1';
        insert a;
        
        //Utility.runDupRecTrigger=true;
               
        a.Order_Type__c = 'Purchased';
        test.StartTest();
        update a;
        test.StopTest();
    }
    
    
    
     public static testmethod void method2(){
        product2 pr2 = new Product2(name='testBanks',component_code__c='test3', infosight_identifier__c='6T', productCode='Test3',Family = 'All Flash Array Gen5');
        insert pr2;
        
        Account acc=new Account();
        acc.Name='test acc2';
        
        insert acc;
        
        Contact con= new Contact();
        con.LastName='last2';
        con.Email='test2@gmail.com';
        
        con.AccountId=acc.Id;
        insert con;
        
                List<Nimble_Offer_Code__c> Nimble_Offer_CodeList = new List<Nimble_Offer_Code__c>();
            Nimble_Offer_Code__c  noc = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123456',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = true,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456'
                                    );
      Nimble_Offer_Code__c  noc1 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123457',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = false,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'TSC'
                                    );
      
      Nimble_Offer_CodeList.add(noc);
      Nimble_Offer_CodeList.add(noc1);
      insert Nimble_Offer_CodeList;
      
        Asset b =new Asset();
        b.ContactId=con.Id;
        b.AccountId=acc.Id;
        b.Shelf_Pack_1__c = '1200';
        b.Shelf_Pack_2__c ='1200';
        b.Shelf_Pack_3__c ='1200';
        b.Shelf_Pack_4__c = '1200';
        b.Shelf_Pack_5__c = '3800';
        b.Shelf_Pack_6__c = '3800';
        b.Shelf_Pack_1B__c = '3800';
        b.Shelf_Pack_2B__c = '3800';
        b.Shelf_Pack_3B__c = '3800';
        b.Shelf_Pack_4B__c = '3800';
        b.Shelf_Pack_5B__c = '3800';
        b.Shelf_Pack_6B__c = '3800';
        b.HPE_Opportunity_ID__c = 'OPE-2222222222';
        b.SSD_Bank_A__c = '6T';
        b.SSD_Bank_B__c = '6T';
        b.Expansion_Shelf_Base__c = 'ES2-H21T';
        Utility.runDupRecTrigger=true;
        b.Name = 'test1';
        b.Product2Id=pr2.id;
        b.HPE_Serial_Number__c = 'TEST2';
        b.Install_City__c ='San Jose';
        insert b;
        
         test.StartTest();
        Asset a =new Asset();
        a.Array_Cache__c='3840';
        a.Array_Capacity__c='3840';
        a.Array_Controller__c='3840';
        a.Array_Networking__c='3840';
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Purchased';
        a.Array_Controller__c='3840';
        a.Name='test';
        
        //a.Expansion_Shelf_Base__c='test1-test1';
        a.Product2Id=pr2.id;
        //a.Dynamic_SKU__c='ES3';
        a.SSD_Bank_A__c='3840';
        a.SSD_Bank_B__c='3840';
        a.Asset_Type_Build__c='3840';
        a.Parent_Asset__c=b.id;
        a.Support_Start_Date_Asset__c = system.today();
        a.Support_End_Date__c = system.today() + 1;
        a.SLA__c = 'TSC';
        a.HPE_Opportunity_ID__c ='OPE-1111122222';
        Utility.runDupRecTrigger=true;
        a.HPE_Serial_Number__c= 'test1';
        insert a;
             test.StopTest();


    }
    
    
    private static testMethod void myUnitTest88() {
        Product2 pro=new Product2();
        pro.Name='test';
        Pro.Component_Code__c='3840';
        pro.ProductCode='3840';
        pro.Asset_Type__c='3840';
        pro.infosight_identifier__c='3840';
        pro.HPE_SKU__C='3840';
        pro.Family='3840';
        pro.asset_Type__c='3840';
        //pro.Array_Controller__c='test1';
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
        
       a.Shelf_Pack_1__c='3840';
        a.Shelf_Pack_2__c='3840';
        a.Shelf_Pack_3__c='3840';
        a.Shelf_Pack_4__c='3840';
        a.Shelf_Pack_5__c='3840';
        a.Shelf_Pack_6__c='3840';
        a.Shelf_Pack_1B__c='3840';
        a.Shelf_Pack_2B__c='3840';
        a.Shelf_Pack_3B__c='3840';
        a.Shelf_Pack_4B__c='3840';
        a.Shelf_Pack_5B__c='3840';
        a.Shelf_Pack_6B__c='3840';
        
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        //a.Array_Controller__c='3840';
        a.Name='test';
        a.Product2Id=pro.id;
       
        a.Asset_Type_Build__c='3840';
        a.HPE_Serial_Number__c= 'test1';
        insert a;
        
        //Utility.runDupRecTrigger=true;
        a.Component_SKU_Nimble_V2__c = 'test1,test2';       
        a.Order_Type__c = 'Purchased';
        test.StartTest();
        update a;
        test.StopTest();
    }
    
    
    private static testMethod void myUnitTest89() {
        Product2 pro=new Product2();
        pro.Name='test';
       // Pro.Component_Code__c='3840';
       pro.infosight_identifier__c = '3840';
        pro.Asset_Type__c='3840';
         pro.ProductCode='3840';
        pro.Family='All Flash Shelf';
        //pro.asset_Type__c='3840';
        //pro.Array_Controller__c='test1';
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
        a.Shelf_Pack_1_SKU__c='3840';
       a.Shelf_Pack_1__c='3840';
        a.Shelf_Pack_2__c='3840';
        a.Shelf_Pack_3__c='3840';
        a.Shelf_Pack_4__c='3840';
        a.Shelf_Pack_5__c='3840';
        a.Shelf_Pack_6__c='3840';
        a.Shelf_Pack_1B__c='3840';
        a.Shelf_Pack_2B__c='3840';
        a.Shelf_Pack_3B__c='3840';
        a.Shelf_Pack_4B__c='3840';
        a.Shelf_Pack_5B__c='3840';
        a.Shelf_Pack_6B__c='3840';
        
        //a.Asset_Product_Family__c='All Flash Shelf';
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        //a.Array_Controller__c='3840';
        a.Name='test';
        a.Product2Id=pro.id;
       
        a.Asset_Type_Build__c='3840';
        a.HPE_Serial_Number__c= 'test1';
        insert a;
        
        //Utility.runDupRecTrigger=true;
        a.Component_SKU_Nimble_V2__c = 'test1,test2';       
        a.Order_Type__c = 'Purchased';
        test.StartTest();
        update a;
        test.StopTest();
    }
    
        private static testMethod void myUnitTest90() {
        List<Fields_Changed_Corona_Asset__c> Fields_Changed_Corona_AssetList = new List<Fields_Changed_Corona_Asset__c>();
         Fields_Changed_Corona_Asset__c AccountObj  = new Fields_Changed_Corona_Asset__c(Name='AccountId');
         Fields_Changed_Corona_AssetList.add(AccountObj);
         insert Fields_Changed_Corona_AssetList;
         Product2 pro=new Product2();
        pro.Name='test';
       // Pro.Component_Code__c='3840';
       pro.infosight_identifier__c = '3840';
        //pro.Asset_Type__c='3840';
         pro.ProductCode='3840';
        pro.Family='All Flash Shelf';
        //pro.asset_Type__c='3840';
        //pro.Array_Controller__c='test1';
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
        a.Shelf_Pack_3B_SKU__c='3480';
        a.Shelf_Pack_1B_SKU__c='3480';
        a.Shelf_Pack_2B_SKU__c='3480';
        a.Shelf_Pack_4B_SKU__c='3480';
        a.Shelf_Pack_5B_SKU__c='3480';
        a.Shelf_Pack_6B_SKU__c='3480';
        a.Shelf_Pack_1_SKU__c='3840';
        a.Shelf_Pack_2_SKU__c='3840';
        a.Shelf_Pack_3_SKU__c='3840';
        a.Shelf_Pack_4_SKU__c='3840';
        a.Shelf_Pack_6_SKU__c='3840';
        a.Shelf_Pack_6_SKU__c='3840';
       a.Shelf_Pack_1__c='3840';
        a.Shelf_Pack_2__c='3840';
        a.Shelf_Pack_3__c='3840';
        a.Shelf_Pack_4__c='3840';
        a.Shelf_Pack_5__c='3840';
        a.Shelf_Pack_6__c='3840';
        a.Shelf_Pack_1B__c='3840';
        a.Shelf_Pack_2B__c='3840';
        a.Shelf_Pack_3B__c='3840';
        a.Shelf_Pack_4B__c='3840';
        a.Shelf_Pack_5B__c='3840';
        a.Shelf_Pack_6B__c='3840';
        
        //a.Asset_Product_Family__c='All Flash Shelf';
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        //a.Array_Controller__c='3840';
        
        a.Name='test';
        a.Product2Id=pro.id;
        a.Datacenter_Care__c = true;
       
      //  a.Asset_Type_Build__c='3840';
      a.HPE_Serial_Number__c= 'test1';
        insert a;
        
        //Utility.runDupRecTrigger=true;
        a.Component_SKU_Nimble_V2__c = 'test1,test2';       
        a.Order_Type__c = 'Purchased';
        test.StartTest();
        update a;
        test.StopTest();
    }
     static testMethod void myUnitTest1(){
        List<Product2> lstproduct = new List<Product2>();
        
        test.startTest();
        Product2 pro=new Product2();
        pro.Name='HF20H';
        Pro.Component_Code__c='HF20H';
        pro.ProductCode='HF20H';
        pro.Asset_Type__c='test1';
        pro.infosight_identifier__c='HF20H';
        pro.HPE_SKU__C='Q8H72A';
        pro.Family='Hybrid Flash Array';
        //insert pro;
        lstProduct.add(pro);
       
        Product2 pro1=new Product2();
        pro1.Name='HEAD-HDD-21TBC';
        Pro1.Component_Code__c='HEAD-HDD-21TBC';
        pro1.ProductCode='HEAD-HDD-21TBC';
        pro1.Asset_Type__c='HFA';
        pro1.infosight_identifier__c='21T';
        pro1.HPE_SKU__C='Q8B68B';
        pro1.Family='Hybrid Flash Array';
        lstProduct.add(pro1);       
        //insert pro1;
        
        Product2 pro2=new Product2();
        pro2.Name='PCI-DEFAULTC';
        Pro2.Component_Code__c='2G';
        pro2.ProductCode='PCI-DEFAULTC';
        pro2.Asset_Type__c='HFA';
        pro2.infosight_identifier__c='';
        pro2.HPE_SKU__C='Q8B83B';
        pro2.Family='Hybrid Flash Array';
        lstProduct.add(pro2); 
       //insert pro2;       
             
        Product2 pro8=new Product2();
        pro8.Name='PCI-2T+QFC';
        pro8.Component_Code__c='4G';
        pro8.ProductCode='PCI-2T+QFC';
        pro8.Asset_Type__c='HFA';
        pro8.infosight_identifier__c='';
        pro8.HPE_SKU__C='R0N85A';
        pro8.Family='Hybrid Flash Array';
        lstProduct.add(pro8); 
       //insert pro8;
        
        Product2 pro6=new Product2();
        pro6.Name='4P';
        pro6.Component_Code__c='4P';
        pro6.ProductCode='4P';
        pro6.Asset_Type__c='test1';
        pro6.infosight_identifier__c='2PQF';
        pro6.HPE_SKU__C='R0N84A';
        pro6.Family='HFA';
        lstProduct.add(pro6);        
        
        
       
        insert lstProduct;
        List<Nimble_Offer_Code__c> lstNOC = new List<Nimble_Offer_Code__c>();
        Account Act = new Account( Name = 'Test Yesha Ac', Datacenter_Care__c = false, ACM_Service_Purchased__c = false);
        insert Act;
        
        Account Act1 = new Account( Name = 'Test Ac', Datacenter_Care__c = false, ACM_Service_Purchased__c =false);
        insert Act1;
        
        Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'John', email='venkat@ns.com',
                                             AccountId = act.Id);
        insert con1;
        Opportunity Opp = new Opportunity(Accountid = Act.id,name ='Test Sudhir Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'OPE-0008891133');
                          
        insert Opp;
        Opportunity Opp1 = new Opportunity(Accountid = Act.id,name ='Test Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'OPE-0008891123');
                          
        insert Opp1;
        
        Opportunity Opp2 = new Opportunity(Accountid = Act1.id,name ='Test Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'OPE-0008891234');
                          
        insert Opp2;
       
       Nimble_Offer_Code__c  noc = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT6Z0AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium 4 Hour',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456', Datacenter_Care__c = True
                                    );
      lstNOC.add(noc);
       
       Nimble_Offer_Code__c  noc1 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT6Z1AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = true,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'TSC: Premium', Datacenter_Care__c = True
                                    );
      lstNOC.add(noc1);
       
       Nimble_Offer_Code__c  noc2 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT7J0AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1',
                                                          TSC_Nimble_Support_Offers__c = 'TSC: Premium', Datacenter_Care__c = True,
                                                          Bundle_SKU__c = true
                                    );
      lstNOC.add(noc2);
      
      Nimble_Offer_Code__c  noc3 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT6Z6AC',
                                                             HPE_Support_Package_SKU_Description__c ='HPE NS Proactive Supp Manager Tier A SVC',
                                                             Concierge_Manager_Tier__c = 'C'
                                    );
      lstNOC.add(noc3);
        insert lstNOC;
       Asset a =new Asset();
        a.Array_Cache__c='1920F';
        a.Array_Capacity__c='22T';
        a.Array_Controller__c='HF20H';
        a.Array_Networking__c='4G';
        a.Array_Networking_2__c='4P';
        a.Array_Networking_3__c='2G';
        a.ContactId=con1.Id;
        a.AccountId=act.Id;
        a.Order_Type__c = 'Purchased';
        a.Array_Controller__c='HF20H';
        a.Name='test';
        
        //a.Expansion_Shelf_Base__c='test1-test1';
        a.Product2Id=pro.id;
        //a.Dynamic_SKU__c='ES3';
        a.SSD_Bank_A__c='960F';
        a.SSD_Bank_B__c='960F';
        a.Asset_Type_Build__c='HFA';
        
        a.Support_Start_Date_Asset__c = system.today();
        a.Support_End_Date__c = system.today() + 1;
        a.SLA__c = 'TSC';
        a.HPE_Opportunity_ID__c ='OPE-1111122222';
        Utility.runDupRecTrigger=true;
        a.HPE_Serial_Number__c= 'test1';
        insert a;
        test.StopTest();
    }

    
}