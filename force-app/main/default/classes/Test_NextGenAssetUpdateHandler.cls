@isTest(seeAllData=false)
private class Test_NextGenAssetUpdateHandler {
    
    static testMethod void myUnitTest() {
        
        
        
        Product2 pro=new Product2();
        pro.Name='HF60';
        Pro.Component_Code__c='HF60';
        pro.ProductCode='HF60';
        pro.Asset_Type__c='HF60';
        pro.infosight_identifier__c='HF60';
        pro.Family='Adaptive Flash Array Gen5';
        pro.asset_Type__c='HFA';
        pro.Product_Type_2__c='Controller';
        pro.Product_Type__c = 'Hardware';
        pro.Controller_Refresh_SKU__c = 'R4A13A';
        pro.IsActive = true;
        insert pro;
        
        Product2 proNet=new Product2();
        proNet.Name='PCI-10SFPx1C';
        proNet.Component_Code__c='2P';
        proNet.ProductCode='PCI-10SFPx1C';
        proNet.Merged_Product_Code__c = 'PCI-10SFPx1C';
        proNet.infosight_identifier__c='2P';
        proNet.Family='All Flash Array Gen5';
        proNet.asset_Type__c='AFA2;HFA;HFA2';
        proNet.Product_Type_2__c='Networking';
        proNet.Product_Type__c = 'Hardware';
        proNet.Controller_Refresh_SKU__c = 'R8Z48A,R8Z53A,R8Z53A';
        proNet.Controller_Refresh_Networking_SKU__c ='2P';
        proNet.Array_Controller__c = 'AFA2;HFA';
        proNet.IsActive = true;
        insert proNet;
        
        Account acc=new Account();
        acc.Name='test acc';
        
        insert acc;
        Contact con= new Contact();
        con.LastName='last';
        con.Email='test@gmail.com';
        
        con.AccountId=acc.Id;
        insert con;
        
        Nimble_Offer_Code__c  noc = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123456',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456'
                                    );
      insert noc;
        
        Asset a =new Asset();
        a.Array_Cache__c='46T';
        a.Array_Controller__c = 'HF60';
        a.Array_Capacity__c='46080F';
        a.Array_Networking__c='2P';
        a.HPE_Support_SKU__c = 'HPE123456';
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        a.Name='test';
        a.Array_Networking__c='2P';
        a.Array_Networking_2__c='2P';
        a.Array_Networking_3__c='2P'  ;
        a.Array_Networking_SKU__c = 'PCI-10SFPx1C';
        a.Array_Networking_2_SKU__c = 'PCI-10SFPx1C';
        a.Array_Networking_3_SKU__c ='PCI-10SFPx1C';  
        a.Product2Id=pro.id;
        a.SSD_Bank_A__c='46080F';
        a.SSD_Bank_B__c='46080F';
        a.Asset_Type_Build__c='3840';
        a.HPE_Serial_Number__c= 'HF60test4';
        a.Date_of_Refresh__c = System.Today();
        a.Support_Start_Date_Asset__c = System.Today();
        a.NDU_Required__c = false;
        a.Timeless_fulfillment__c = True;
        a.Controller_Refresh_1__c = '6010';
        a.Controller_Refresh_Networking_SKU__c='4P';
        a.Timeless_Storage__c = True;
        a.Timeless_Status__c = 'Refresh Ready Override';
        a.Controller_Refresh_PSU__c='R9T04A';
        insert a;
              
        a.Order_Type__c = 'Purchased';
        a.Timeless_Storage__c = True;
        a.Controller_Refresh_1_SKU__c = 'R4A13A';
        test.StartTest();
        update a;
        test.StopTest();
    }
    
    static testMethod void myUnitTest1() {
        
        Product2 pro=new Product2();
        pro.Name='HF60';
        Pro.Component_Code__c='HF60';
        pro.ProductCode='HF60';
        pro.Asset_Type__c='HF60';
        pro.infosight_identifier__c='HF60';
        pro.Family='Adaptive Flash Array Gen5';
        pro.asset_Type__c='HFA';
        pro.Product_Type_2__c='Controller';
        pro.Product_Type__c = 'Hardware';
        pro.IsActive = true;
        insert pro;
        
        product2 proAFA=new product2();
        proAFA.Name='AF60';
        proAFA.Component_Code__c='AF60';
        proAFA.productCode='AF60';
        proAFA.Asset_Type__c='AFA2';
        proAFA.infosight_identifier__c='AF60';
        proAFA.Family='All Flash Array Gen5';
        proAFA.asset_Type__c='AFA2';
        proAFA.product_Type_2__c='Controller';
        proAFA.Controller_Refresh_SKU__c = 'R4A13A';
        proAFA.IsActive = true;
        insert proAFA;
        
        Product2 proNet=new Product2();
        proNet.Name='PCI-10SFPx1C';
        proNet.Component_Code__c='2P';
        proNet.ProductCode='PCI-10SFPx1C';
        proNet.Merged_Product_Code__c = 'PCI-10SFPx1C';
        proNet.infosight_identifier__c='2P';
        proNet.Family='All Flash Array Gen5';
        proNet.asset_Type__c='AFA2;HFA;HFA2';
        proNet.Product_Type_2__c='Networking';
        proNet.Product_Type__c = 'Hardware';
        proNet.Controller_Refresh_SKU__c = 'R8Z48A,R8Z53A,R8Z53A';
        proNet.Controller_Refresh_Networking_SKU__c ='2P';
        proNet.Array_Controller__c = 'AFA2;HFA';
        proNet.IsActive = true;
        insert proNet;
        
        Account acc=new Account();
        acc.Name='test acc';
        
        insert acc;
        Contact con= new Contact();
        con.LastName='last';
        con.Email='test@gmail.com';
        
        con.AccountId=acc.Id;
        insert con;
        
        Nimble_Offer_Code__c  noc = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123456',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456'
                                    );
      insert noc;
        
        List<Asset> assets = new List<Asset>();
      
        Asset asst =new Asset();
        asst.Array_Cache__c='138T';
        asst.Array_Controller__c = 'AF60';
        asst.HPE_Support_SKU__c = 'HPE123456';
        asst.ContactId=con.Id;
        asst.AccountId=acc.Id;
        asst.Order_Type__c = 'Eval Unit';
        asst.Name='AF60test1';
        asst.Array_Networking__c='2P';
        asst.Array_Networking_2__c='2P';
        asst.Array_Networking_3__c='2P'  ;
        asst.Array_Networking_SKU__c = 'PCI-10SFPx1C';
        asst.Array_Networking_2_SKU__c = 'PCI-10SFPx1C';
        asst.Array_Networking_3_SKU__c ='PCI-10SFPx1C';      
        asst.Product2Id=proAFA.id;
        asst.SSD_Bank_A__c='46080F';
        asst.SSD_Bank_B__c='46080F';
        asst.Asset_Type_Build__c='AFA2';
        asst.HPE_Serial_Number__c= 'AF60test1';
        asst.Date_of_Refresh__c = System.Today() -2;
        asst.Support_Start_Date_Asset__c = System.Today() - 2;
        asst.NDU_Required__c = false;
        asst.Controller_Refresh_1__c = '6010';
        asst.Controller_Refresh_1_SKU__c = 'R4A13A';
        asst.dHCI__c = true;
        asst.Controller_Refresh_Shelf_Count__c = 17;
        asst.Timeless_Storage__c = true;
        assets.add(asst);
        
                Asset a =new Asset();
        a.Array_Cache__c='3840';
        a.Array_Controller__c='AF60';
        a.HPE_Support_SKU__c = 'HPE12345';
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Eval Unit';
        a.Name='AF60test2';
        a.Array_Networking__c='2P';
        a.Array_Networking_2__c='2P';
        a.Array_Networking_3__c='2P'  ;
        a.Array_Networking_SKU__c = 'PCI-10SFPx1C';
        a.Array_Networking_2_SKU__c = 'PCI-10SFPx1C';
        a.Array_Networking_3_SKU__c ='PCI-10SFPx1C';
        a.Product2Id=pro.id;
        a.Asset_Type_Build__c='AFA2';
        a.HPE_Serial_Number__c= 'AF60test2';
        a.Date_of_Refresh__c = System.Today();
        a.Support_Start_Date_Asset__c = System.Today();
        a.NDU_Required__c = true;
        a.Timeless_fulfillment__c = True;
        a.Controller_Refresh_1__c = '6010';
        a.Controller_Refresh_Networking_SKU__c='4P';
        a.SSD_Bank_A__c='46080F';
        a.SSD_Bank_B__c='46080F';
        a.Asset_Type_Build__c='AFA2';
        a.Controller_Refresh_1__c = '6010';
        a.Controller_Refresh_1_SKU__c = 'R4A13A';
        a.dHCI__c = true;
        a.Controller_Refresh_Shelf_Count__c = 17;
        a.Timeless_Storage__c = true;
        assets.add(a);
        
        
        Asset a1 =new Asset();
        a1.Array_Cache__c='3840';
        a1.Array_Controller__c='AF60';
        a1.HPE_Support_SKU__c = 'HPE12345';
        a1.ContactId=con.Id;
        a1.AccountId=acc.Id;
        a1.Order_Type__c = 'Eval Unit';
        a1.Name='AF60test3';
        a1.Array_Networking__c='2P';
        a1.Array_Networking_2__c='2P';
        a1.Array_Networking_3__c='2P'  ;
        a1.Array_Networking_SKU__c = 'PCI-10SFPx1C';
        a1.Array_Networking_2_SKU__c = 'PCI-10SFPx1C';
        a1.Array_Networking_3_SKU__c ='PCI-10SFPx1C';
        a1.Product2Id=pro.id;
        a1.Asset_Type_Build__c='AFA2';
        a1.HPE_Serial_Number__c= 'AF60test3';
        a1.Date_of_Refresh__c = System.Today();
        a1.Support_Start_Date_Asset__c = System.Today();
        a1.NDU_Required__c = true;
        a1.Timeless_fulfillment__c = True;
        a1.Controller_Refresh_1__c = '6010';
        a1.SSD_Bank_A__c='46080F';
        a1.SSD_Bank_B__c='46080F';
        a1.Asset_Type_Build__c='AFA2';
        a1.Controller_Refresh_1__c = '6010';
        a1.Controller_Refresh_1_SKU__c = 'R4A13A';
        a1.dHCI__c = true;
        a1.Controller_Refresh_Shelf_Count__c = 17;
        a1.Timeless_Storage__c = true;
        assets.add(a1);
        
        
        Asset a2 =new Asset();
        a2.Array_Cache__c='3840';
        a2.Array_Controller__c='AF60';
        a2.HPE_Support_SKU__c = 'HPE12345';
        a2.ContactId=con.Id;
        a2.AccountId=acc.Id;
        a2.Order_Type__c = 'Eval Unit';
        a2.Name='AF60test4';
        a2.Array_Networking__c='5P';
        a2.Product2Id=pro.id;
        a2.Asset_Type_Build__c='AFA2';
        a2.HPE_Serial_Number__c= 'AF60test4';
        a2.Date_of_Refresh__c = System.Today();
        a2.Support_Start_Date_Asset__c = System.Today();
        a2.NDU_Required__c = true;
        a2.Timeless_fulfillment__c = True;
        a2.Controller_Refresh_1__c = '6010';
        a2.SSD_Bank_A__c='46080F';
        a2.SSD_Bank_B__c='46080F';
        a2.Asset_Type_Build__c='AFA2';
        a2.Controller_Refresh_1__c = '6010';
        a2.Controller_Refresh_1_SKU__c = 'R4A13A';
        a2.dHCI__c = true;
        a2.Controller_Refresh_Shelf_Count__c = 17;
        a2.Timeless_Storage__c = true;
        assets.add(a2);
        
        Asset a5 =new Asset();
        a5.Array_Cache__c='3840';
        a5.Array_Controller__c='AF60';
        a5.HPE_Support_SKU__c = 'HPE12345';
        a5.ContactId=con.Id;
        a5.AccountId=acc.Id;
        a5.Order_Type__c = 'Eval Unit';
        a5.Name='AF60test5';
        a5.Array_Networking__c='5P';
        a5.Product2Id=pro.id;
        a5.Asset_Type_Build__c='AFA2';
        a5.HPE_Serial_Number__c= 'AF60test5';
        a5.Date_of_Refresh__c = System.Today();
        a5.Support_Start_Date_Asset__c = System.Today();
        a5.NDU_Required__c = false;
        a5.Timeless_fulfillment__c = True;
        a5.Controller_Refresh_1__c = '6010';
        a5.SSD_Bank_A__c='46080F';
        a5.SSD_Bank_B__c='46080F';
        a5.Asset_Type_Build__c='AFA2';
        a5.Controller_Refresh_1__c = '6010';
        a5.Controller_Refresh_1_SKU__c = 'R4A13A';
        a5.dHCI__c = true;
        a5.Controller_Refresh_Shelf_Count__c = 17;
        a5.Timeless_Storage__c = true;
        assets.add(a5);
        
        Asset a6 =new Asset();
        a6.Array_Cache__c='3840';
        a6.Array_Controller__c='AF60';
        a6.HPE_Support_SKU__c = 'HPE12345';
        a6.ContactId=con.Id;
        a6.AccountId=acc.Id;
        a6.Order_Type__c = 'Eval Unit';
        a6.Name='AF60test6';
        a6.Array_Networking__c='5P';
        a6.Product2Id=pro.id;
        a6.Asset_Type_Build__c='AFA2';
        a6.HPE_Serial_Number__c= 'AF60test6';
        a6.Date_of_Refresh__c = System.Today();
        a6.Support_Start_Date_Asset__c = System.Today();
        a6.NDU_Required__c = false;
        a6.Timeless_fulfillment__c = True;
        a6.Controller_Refresh_1__c = '6010';
        a6.SSD_Bank_A__c='46080F';
        a6.SSD_Bank_B__c='46080F';
        a6.Asset_Type_Build__c='AFA2';
        a6.Controller_Refresh_1__c = '6010';
        a6.dHCI__c = true;
        a6.Controller_Refresh_Shelf_Count__c = 17;
        a6.Timeless_Storage__c = true;
        assets.add(a6);
        
        Asset a7 =new Asset();
        a7.Array_Cache__c='3840';
        a7.Array_Controller__c='AF60';
        a7.HPE_Support_SKU__c = 'HPE12345';
        a7.ContactId=con.Id;
        a7.AccountId=acc.Id;
        a7.Order_Type__c = 'Eval Unit';
        a7.Name='AF60test7';
        a7.Array_Networking__c='5P';
        a7.Product2Id=pro.id;
        a7.Asset_Type_Build__c='AFA2';
        a7.HPE_Serial_Number__c= 'AF60test7';
        a7.Date_of_Refresh__c = System.Today();
        a7.Support_Start_Date_Asset__c = System.Today();
        a7.NDU_Required__c = true;
        a7.Timeless_fulfillment__c = True;
        a7.Controller_Refresh_1__c = '6010';
        a7.SSD_Bank_A__c='46080F';
        a7.SSD_Bank_B__c='46080F';
        a7.Asset_Type_Build__c='AFA2';
        a7.Controller_Refresh_1__c = '6010';
        a7.dHCI__c = true;
        a7.Controller_Refresh_Shelf_Count__c = 17;
        a7.Timeless_Storage__c = true;
        assets.add(a7);
        
                Asset a8 =new Asset();
        a8.Array_Cache__c='3840';
        a8.Array_Controller__c='AF60';
        a8.HPE_Support_SKU__c = 'HPE12345';
        a8.ContactId=con.Id;
        a8.AccountId=acc.Id;
        a8.Order_Type__c = 'Eval Unit';
        a8.Name='AF60test8';
        a8.Array_Networking__c='2P';
        a8.Array_Networking_2__c='2P';
        a8.Array_Networking_3__c='2P'  ;
        a8.Array_Networking_SKU__c = 'PCI-10SFPx1C';
        a8.Array_Networking_2_SKU__c = 'PCI-10SFPx1C';
        a8.Array_Networking_3_SKU__c ='PCI-10SFPx1C';
        a8.Product2Id=pro.id;
        a8.Asset_Type_Build__c='AFA2';
        a8.HPE_Serial_Number__c= 'AF60test8';
        a8.Date_of_Refresh__c = System.Today();
        a8.Support_Start_Date_Asset__c = System.Today();
        a8.NDU_Required__c = true;
        a8.Timeless_fulfillment__c = True;
        a8.Controller_Refresh_1__c = '6010';
        a8.SSD_Bank_A__c='46080F';
        a8.SSD_Bank_B__c='46080F';
        a8.Asset_Type_Build__c='AFA2';
        a8.Controller_Refresh_1__c = '6010';
        a8.dHCI__c = true;
        a8.Controller_Refresh_Shelf_Count__c = 17;
        a8.Timeless_Storage__c = true;
        
                Asset a9 =new Asset();
        a9.Array_Cache__c='3840';
        a9.Array_Controller__c='AF60';
        a9.HPE_Support_SKU__c = 'HPE12345';
        a9.ContactId=con.Id;
        a9.AccountId=acc.Id;
        a9.Order_Type__c = 'Eval Unit';
        a9.Name='AF60test9';
        a9.Array_Networking__c='2P';
        a9.Array_Networking_2__c='2P';
        a9.Array_Networking_3__c='2P'  ;
        a9.Array_Networking_SKU__c = 'PCI-10SFPx1C';
        a9.Array_Networking_2_SKU__c = 'PCI-10SFPx1C';
        a9.Array_Networking_3_SKU__c ='PCI-10SFPx1C';
        a9.Product2Id=pro.id;
        a9.Asset_Type_Build__c='AFA2';
        a9.HPE_Serial_Number__c= 'AF60test9';
        a9.Date_of_Refresh__c = System.Today();
        a9.Support_Start_Date_Asset__c = System.Today();
        a9.NDU_Required__c = false;
        a9.Timeless_fulfillment__c = True;
        a9.Controller_Refresh_1__c = '6010';
        a9.SSD_Bank_A__c='46080F';
        a9.SSD_Bank_B__c='46080F';
        a9.Asset_Type_Build__c='AFA2';
        a9.Controller_Refresh_1__c = '6010';
        a9.dHCI__c = true;
        a9.Controller_Refresh_Shelf_Count__c = 17;
        a9.Timeless_Storage__c = true;
        
        assets.add(a9);
        
        assets.add(a8);
        
        insert assets;
        Test.startTest();
       
        List<Asset> lstAst = [select Id, Controller_Refresh_1_SKU__c from Asset where HPE_Serial_Number__c like 'AF60test%' limit 1];
        for(asset ast : lstAst){
            ast.Date_of_Refresh__c = Date.newInstance(2022, 2, 17);
        }       
        update lstAst;
        
        Test.StopTest();    }
}