@isTest(seeAllData=true)
public class Test_NextGenTriggerClass{
  
  static testMethod void myUnitTest() {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        
        
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        
        system.runAs(u){
        
        Product2 pro=new Product2();
        pro.Name='ES3-H210TE';
        Pro.Component_Code__c='210TE';
        pro.ProductCode='ES3-H210TE';
        pro.Asset_Type__c='Expansion Shelves';
        pro.infosight_identifier__c='ES3-H210TE';
        pro.Product_Type_2__c ='Expansion Shelves';
        pro.Family='Expansion Shelves';
        pro.Controller_Code__c = 'ES3-H210TE';
        insert pro;
        
        Product2 pro2=new Product2();
        pro2.Name='AFS3';
        Pro2.Component_Code__c='AFS3';
        pro2.ProductCode='AFS3';
        pro2.Asset_Type__c='AFS3';
        pro2.Family='All Flash Shelf';
        insert pro2;
        
        Product2 pro3=new Product2();
        pro3.Name='C1K';
        Pro3.Component_Code__c='C1K';
        pro3.ProductCode='C1K';
        pro3.Asset_Type__c='CS Hybrid Arrays';
        pro3.Family='Adaptive Flash Array';
        pro3.Infosight_Identifier__c = 'CS1000';
        insert pro3;
       
       
        Product2 pro4=new Product2();
        pro4.Name='ES2-AFS2';
        Pro4.Component_Code__c='ES2-AFS2';
        pro4.ProductCode='ES2-AFS2';
        pro4.Asset_Type__c='Expansion Shelves';
        pro4.Family='Expansion Shelves';
        pro4.Infosight_Identifier__c = 'ES2-AFS2';
        insert pro4;
       
        
        Product2 pro5=new Product2();
        pro5.Name='AFS2-FLC-15T';
        Pro5.Component_Code__c='15360';
        pro5.ProductCode='AFS2-FLC-15T';
        pro5.Asset_Type__c='ES2-AFS2';
        pro5.Family='AFS';
        pro5.Infosight_Identifier__c = 'ES2-AFS2';
        insert pro5;
        
        Product2 pro6=new Product2();
        pro6.Name='AFS2-FLC-8T';
        Pro6.Component_Code__c='7600';
        pro6.ProductCode='AFS2-FLC-8T';
        pro6.Asset_Type__c='ES2-AFS2';
        pro6.Family='AFS';
        pro6.Infosight_Identifier__c = '7680';
        insert pro6;
        
        Product2 pro7=new Product2();
        pro7.Name='AFS-UPGRADE';
        pro7.ProductCode='AFS-UPGRADE';
        pro7.Asset_Type__c='AFS';
        pro7.Family='AFS';
        insert pro7;
        
        Product2 pro8=new Product2();
        pro8.Name='AFS-FLC-4T';
        Pro8.Component_Code__c='3800';
        pro8.ProductCode='AFS-FLC-4T';
        pro8.Asset_Type__c='AFS';
        pro8.Family='AFS';
        pro8.Infosight_Identifier__c = '3840';
        insert pro8;
        
        Product2 pro9=new Product2();
        pro9.Name='AFS-FLC-1200GB';
        Pro9.Component_Code__c='1200';
        pro9.ProductCode='AFS-FLC-1200GB';
        pro9.Asset_Type__c='AFS';
        pro9.Family='AFS';
        pro9.Infosight_Identifier__c = '1280';
        insert pro9;
        
        Product2 pro10=new Product2();
        pro10.Name='AFS3-23T';
        Pro10.Component_Code__c='23040';
        pro10.ProductCode='AFS3-23T';
        pro10.Asset_Type__c='AFS3';
        pro10.Family='All Flash Shelf';
        pro10.Infosight_Identifier__c = '23T';
        insert pro10;
        
        Product2 pro11=new Product2();
        pro11.Name='ES3-FLC-2880GB';
        Pro11.Component_Code__c='2880F';
        pro11.ProductCode='ES3-FLC-2880GB';
        pro11.Asset_Type__c='Expansion Shelf3';
        pro11.Family='Expansion Shelves';
        pro11.Infosight_Identifier__c = '2880';
        insert pro11;
        
        Product2 pro12=new Product2();
        pro12.Name='AFA-AFS2';
        pro12.ProductCode='AFA-AFS2';
        pro12.Family='Expansion Shelves';
        insert pro12;
        
        Product2 pro13=new Product2();
        pro13.Name='AFS2-23T';
        Pro13.Component_Code__c='23040';
        pro13.ProductCode='AFS2-23T';
        pro13.Asset_Type__c='AFA-AFS2';
        pro13.Family='All Flash Shelf';
        pro13.Infosight_Identifier__c = '23T';
        insert pro13;


        Account acc=new Account();
        acc.Name='test acc';
        
        insert acc;
        Contact con= new Contact();
        con.LastName='last';
        con.Email='test@gmail.com';
        
        con.AccountId=acc.Id;
        insert con;
        test.starttest();
        
        Asset as1 =new Asset();
        as1.ContactId=con.Id;
        as1.AccountId=acc.Id;
        as1.Order_Type__c = 'Purchased';
        as1.Name='AF-183592-Test';
        as1.Expansion_Shelf_Base__c='AFS2';
        as1.Product2Id=pro12.id;
        as1.Dynamic_SKU__c='AFS2-23040-1';
        as1.Shelf_Pack_1__c = '23040';
        
        as1.IS_Shelf_Pack_1__c ='23040';
        insert as1;
        
        Asset a =new Asset();
        a.ContactId=con.Id;
        a.AccountId=acc.Id;
        a.Order_Type__c = 'Purchased';
        a.Name='test';
        a.Expansion_Shelf_Base__c='ES3-H210TE';
        a.Product2Id=pro.id;
        a.Dynamic_SKU__c='ES3-H210TE';
        a.Shelf_Pack_1__c = '2880';
        a.Shelf_Pack_2__c = '2880';
        a.HPE_Serial_Number__c = '5UMTestES3';
        a.IS_Shelf_Pack_1B__c='2880';
        
        //Utility.runDupRecTrigger = false;
        //insert a;
        
        Asset a1 =new Asset();
        a1.ContactId=con.Id;
        a1.AccountId=acc.Id;
        a1.Name = 'ES2AFS2Test';
        a1.Product2Id = pro4.Id;
        a1.Dynamic_SKU__c= 'ES2-AFS2-15360-1';
        a1.Expansion_shelf_base__c = 'ES2-AFS2';
        a1.Shelf_Pack_1B__c = '15360';
        a1.Shelf_Pack_2B__c = '7680';
        a1.Shelf_Pack_2B_SKU__c= 'AFS2-FLC-8T';
        a1.Shelf_Pack_3B__c = '7680';
        a1.Shelf_Pack_3B_SKU__c= 'AFS2-FLC-8T';
        a1.Shelf_Pack_4B__c = '7680';
        a1.Shelf_Pack_4B_SKU__c= 'AFS2-FLC-8T';
        a1.Shelf_Pack_5B__c = '7680';
        a1.Shelf_Pack_5B_SKU__c= 'AFS2-FLC-8T';
        a1.Shelf_Pack_6B__c = '7680';
        a1.Shelf_Pack_6B_SKU__c= 'AFS2-FLC-8T';
        a1.IS_Shelf_Pack_1B__c='7680';
        a1.IS_Shelf_Pack_2B__c='7680';
        a1.IS_Shelf_Pack_3B__c='7680';
        a1.IS_Shelf_Pack_4B__c='7680';
        a1.IS_Shelf_Pack_5B__c='7680';
        a1.IS_Shelf_Pack_6B__c='7680';
        a1.HPE_Serial_Number__c = '99000002';
        
        // Utility.runDupRecTrigger = false;
        //insert a1;
        
         Asset a11 =new Asset();
        
        a11.Name='test';
        a11.ContactId=con.Id;
        a11.AccountId=acc.Id;
        a11.Expansion_Shelf_Base__c = 'AFS3';
        a1.Product2Id=pro2.id;
        a1.Dynamic_SKU__c='AFS3-92160-6';
        a11.Shelf_Pack_1__c='3800';
        a11.Shelf_Pack_1_SKU__c= 'AFS3-23T';
        a11.Shelf_Pack_2__c='3800';
        a11.Shelf_Pack_1_SKU__c= 'AFS3-23T';
        a11.Shelf_Pack_3__c='3800';
        a11.Shelf_Pack_1_SKU__c= 'AFS3-23T';
        a11.Shelf_Pack_4__c='3800';
        a11.Shelf_Pack_1_SKU__c= 'AFS3-23T';
        a11.Shelf_Pack_5__c='3800';
        a11.Shelf_Pack_1_SKU__c= 'AFS3-23T';
        a11.Shelf_Pack_6__c='3800';
        a11.Shelf_Pack_1_SKU__c= 'AFS3-23T';
        a11.IS_Shelf_Pack_1__c='23T';
        a11.IS_Shelf_Pack_2__c='23T';
        a11.IS_Shelf_Pack_3__c='23T';
        a11.IS_Shelf_Pack_4__c='23T';
        a11.IS_Shelf_Pack_5__c='23T';
        a11.IS_Shelf_Pack_6__c='23T';
        a11.HPE_Serial_Number__c = '99000003';
        a11.Asset_Type_Build__c = 'AFS3';
       
      // Utility.runDupRecTrigger = false;
       //insert a11;
       
        Asset aobj1 = new Asset();
        aobj1.ContactId = con.Id;
        aobj1.AccountId =  acc.Id;
        aobj1.Name = 'AF-CSHybrid';
        aObj1.Product2ID = pro3.Id;
        aObj1.Dynamic_SKU__c ='CS1000-2T-21T-1440F';
        aObj1.Array_Controller__c = 'CS1000';
        aObj1.Array_Networking__c = '2T';
        aObj1.Array_Capacity__c = '21T';
        aObj1.Array_Cache__c = '1440F';
        aObj1.SSD_Bank_A__c = '1440F';
        aObj1.Is_Array_Controller__c = 'CS1000';
        aobj1.Is_Array_Networking__c = '2T';
        aobj1.IS_Array_Capacity__c = '21T';
        aobj1.IS_Array_Cache__c = '1440F';
        aobj1.IS_SSD_Bank_A__c = '1440F';
        
        
        Asset aobj2 = new Asset();
        aobj2.ContactId = con.Id;
        aobj2.AccountId =  acc.Id;
        aObj2.Product2Id = pro7.Id;
        aobj2.Name = 'AF-UpgradeTest';
        aObj2.Dynamic_SKU__c ='ES1-AFS-20080-6';
        aObj2.IS_Shelf_Pack_1B__c='3800';
        aObj2.Shelf_Pack_1B_Sku__c = 'AFS-FLC-4T';
        aObj2.IS_Shelf_Pack_2B__c='3840';
        aObj2.Shelf_Pack_2B_Sku__c = 'AFS-FLC-4T';
        aObj2.IS_Shelf_Pack_3B__c='1200';
        aObj2.Shelf_Pack_3B_Sku__c = 'AFS-FLC-1200GB';
        aObj2.IS_Shelf_Pack_4B__c='1280';
        aObj2.Shelf_Pack_4B_Sku__c = 'AFS-FLC-1200GB';
        aObj2.IS_Shelf_Pack_5B__c='3800';
        aObj2.Shelf_Pack_5B_Sku__c = 'AFS-FLC-4T';
        aObj2.IS_Shelf_Pack_6B__c='3840';
        aObj2.Shelf_Pack_6B_Sku__c = 'AFS-FLC-4T';
        
        Utility.runDupRecTrigger = false;
        
       //insert a111;
        List<Asset> assetlist = new List<Asset>();
        assetList.add(aobj1);
        system.debug(' asset type ' + a11.asset_type__c);
        assetList.add(a11);
        assetList.add(a1);
        assetList.add(a);
        //assetList.add(as1);
        assetList.add(aObj2);          
        insert assetList;
        
        test.stoptest();
        NextGenTriggerClass.populateIsFields(assetlist);
        
    }
}
 
 static testmethod void myUnitTest2(){
 
     //List<NIC_Data__c> lstCS = [select Id, Nic_1__c,Nic_2__c,Nic_3__c,Comb_Nic_1__c,Comb_Nic_2__c from NIC_Data__c];
     Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p1 = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        
        
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P1.Id);
        
        system.runAs(u){
        
     
     List<Product2> lstproduct = new List<Product2>();
        List<Asset> lstAsset = new List<Asset>();
        test.startTest();
        
        NIC_Data__c n1 = new NIC_Data__c();
        n1.Name = 'n1';
        n1.Nic_1__c = '2P';
        n1.Nic_2__c = '2P';
        n1.Nic_3__c = '2F';
        n1.Comb_Nic_1__c = '4P2F';
        insert n1;
        
        NIC_Data__c n2 = new NIC_Data__c();
        n2.Name = 'n2';
        n2.Nic_1__c = '2P';
        n2.Nic_2__c = '2F';
        n2.Nic_3__c = '2F';
        n2.Comb_Nic_2__c = '2P4F';
        insert n2;
        
        NIC_Data__c n3 = new NIC_Data__c();
        n3.Name = 'n3';
        n3.Nic_1__c = '2P';
        n3.Nic_2__c = '2P';
        n3.Nic_3__c = '2P';
        n3.Comb_Nic_3__c = '6P';
        insert n3;
        
        Product2 pro=new Product2();
        pro.Name='HF20';
        Pro.Component_Code__c='HF20';
        pro.ProductCode='HF20';
        pro.Asset_Type__c='test1';
        pro.infosight_identifier__c='HF20';
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
        Pro2.Component_Code__c='2OBT';
        pro2.ProductCode='PCI-DEFAULTC';
        pro2.Asset_Type__c='HFA';
        pro2.infosight_identifier__c='';
        pro2.HPE_SKU__C='Q8B83B';
        pro2.Family='Hybrid Flash Array';
        lstProduct.add(pro2); 
       //insert pro2;
       
       Product2 pro3=new Product2();
        pro3.Name='C1K';
        Pro3.Component_Code__c='C1K';
        pro3.ProductCode='C1K';
        pro3.Asset_Type__c='test1';
        pro3.infosight_identifier__c='C1K';
        pro3.HPE_SKU__C='Q8B38A';
        pro3.Family='CS Hybrid Arrays';
        lstProduct.add(pro3);
        //insert pro3;
       
       Product2 pro4=new Product2();
        pro4.Name='HEAD-HDD-21TB';
        Pro4.Component_Code__c='HEAD-HDD-21TB';
        pro4.ProductCode='HEAD-HDD-21TB';
        pro4.Asset_Type__c='HFA';
        pro4.infosight_identifier__c='21T';
        pro4.HPE_SKU__C='Q8B68A';
        pro4.Family='CS Hybrid Arrays';
        pro4.Array_Controller__c = 'C1K; C3K; C5K; C7K; SF100';
        lstProduct.add(pro4);
        //insert pro4;
       
       Product2 pro5=new Product2();
        pro5.Name='PCI-DEFAULTC';
        pro5.Component_Code__c='2OBT';
        pro5.ProductCode='PCI-DEFAULTC';
        pro5.Asset_Type__c='HFA';
        pro5.infosight_identifier__c='';
        pro5.HPE_SKU__C='Q8B83A';
        pro5.Family='CS Hybrid Arrays';
        lstProduct.add(pro5);
       //insert pro5;
       
        Product2 pro7=new Product2();
        pro7.Name='HEAD-HDD-210TBEC';
        pro7.Component_Code__c='HEAD-HDD-210TBEC';
        pro7.ProductCode='HEAD-HDD-210TBEC';
        pro7.Asset_Type__c='HFA';
        pro7.infosight_identifier__c='210T';
        pro7.HPE_SKU__C='Q8B57B';
        pro7.Family='Hybrid Flash Array';
        lstProduct.add(pro7); 
       //insert pro7;
        
        Product2 pro8=new Product2();
        pro8.Name='PCI-2T+QFC';
        pro8.Component_Code__c='2TQF';
        pro8.ProductCode='PCI-2T+QFC';
        pro8.Asset_Type__c='HFA';
        pro8.infosight_identifier__c='';
        pro8.HPE_SKU__C='R0N85A';
        pro8.Family='Hybrid Flash Array';
        lstProduct.add(pro8); 
       //insert pro8;
        
        Product2 pro6=new Product2();
        pro6.Name='2PQF';
        pro6.Component_Code__c='2PQF';
        pro6.ProductCode='2PQF';
        pro6.Asset_Type__c='test1';
        pro6.infosight_identifier__c='2PQF';
        pro6.HPE_SKU__C='R0N84A';
        pro6.Family='HFA';
        lstProduct.add(pro6);
        
        
        Product2 pro9=new Product2();
        pro9.Name='HEAD-HDD-84TBC';
        pro9.Component_Code__c='HEAD-HDD-84TBC';
        pro9.ProductCode='HEAD-HDD-84TBC';
        pro9.Asset_Type__c='HFA';
        pro9.infosight_identifier__c='84T';
        pro9.HPE_SKU__C='Q8H75A';
        pro9.Family='HFA';
        lstProduct.add(pro9);
        
        Product2 pro10=new Product2();
        pro10.Name='HEAD-FLC-11520GB-6C';
        pro10.Component_Code__c='M';
        pro10.ProductCode='HEAD-FLC-11520GB-6C';
        pro10.Asset_Type__c='HFA';
        pro10.infosight_identifier__c='11520F';
        pro10.HPE_SKU__C='Q8J31A';
        pro10.Family='Hybrid Flash Array';
        pro10.Array_Controller__c = 'HF40; HF60; HF60C';
        lstProduct.add(pro10);
       
        Product2 pro12=new Product2();
        pro12.Name='AF20Q';
        pro12.Component_Code__c='AF20Q';
        pro12.ProductCode='AF20Q';
        pro12.Asset_Type__c='AFA2';
        pro12.infosight_identifier__c='AF20Q';
        pro12.HPE_SKU__C='Q8H73A';
        pro12.Family='All Flash Array Gen5';
        lstProduct.add(pro12);
        
        
        Product2 pro11=new Product2();
        pro11.Name='PCI-16FCx1C';
        pro11.Component_Code__c='2F';
        pro11.ProductCode='PCI-16FCx1C';
        pro11.Asset_Type__c='AFA2';
        pro11.infosight_identifier__c='';
        pro11.HPE_SKU__C='Q8B90B';
        pro11.Family='All Flash Array Gen5';
        pro11.Array_Controller__c = 'AF40; AF60; AF80; AF20Q; HF20H; HF40; HF20C; HF60; HF20; AF20; HF40C; HF60C';
        lstProduct.add(pro11);
        
        Product2 pro13=new Product2();
        pro13.Name='AFQ-11TXC';
        pro13.Component_Code__c='11T';
        pro13.ProductCode='AFQ-11TXC';
        pro13.Asset_Type__c='AFA2';
        pro13.infosight_identifier__c='11520F';
        pro13.HPE_SKU__C='Q8H79A';
        pro13.Family='All Flash Array Gen5';
        
        lstProduct.add(pro13);
        
        Product2 pro14=new Product2();
        pro14.Name='HF40';
        Pro14.Component_Code__c='HF40';
        pro14.ProductCode='HF40';
        pro14.Asset_Type__c='HFA';
        pro14.infosight_identifier__c='HF40';
        pro14.HPE_SKU__C='Q8H39A';
        pro14.Family='Adaptive Flash Array Gen5';
        //insert pro;
        lstProduct.add(pro14);
        
        Product2 pro15=new Product2();
        pro15.Name='PCI-10SFPx1C';
        Pro15.Component_Code__c='2P';
        pro15.ProductCode='PCI-10SFPx1C';
        pro15.Asset_Type__c='All Flash Array Gen5';
        pro15.infosight_identifier__c='';
        pro15.HPE_SKU__C='Q8H39A';
        pro15.Family='Adaptive Flash Array Gen5';
        pro15.Array_Controller__c = 'AF40; AF60; AF80; AF20Q; HF20H; HF40; HF20C; HF60; HF20; AF20; HF40C; HF60C';
        lstProduct.add(pro15);
        
        Product2 pro16=new Product2();
        pro16.Name='ES3-H21TE';
        Pro16.Component_Code__c='21TE';
        pro16.ProductCode='ES3-H21TE';
        pro16.Asset_Type__c='Expansion Shelf3';
        pro16.infosight_identifier__c='';
        pro16.HPE_SKU__C='Q8H33A';
        pro16.Family='Expansion Shelves';
        lstProduct.add(pro16);
        
        Product2 pro17=new Product2();
        pro17.Name='ES3-FLC-2880GB';
        Pro17.Component_Code__c='480F';
        pro17.ProductCode='ES3-FLC-2880GB';
        pro17.Asset_Type__c='A6000';
        pro17.infosight_identifier__c='2880';
        pro17.HPE_SKU__C='Q8C25B';
        pro17.Family='Expansion Shelves';
        lstProduct.add(pro17);
            
        Product2 pro18=new Product2();
        pro18.Name='ES3-FLC-2880GB';
        Pro18.Component_Code__c='2880F';
        pro18.ProductCode='ES3-FLC-2880GB';
        pro18.Asset_Type__c='A6000';
        pro18.infosight_identifier__c='2880';
        pro18.HPE_SKU__C='Q8C25B';
        pro18.Family='Expansion Shelves';
        pro18.Shelves_Qty_Allowed__c = 1;
        lstProduct.add(pro18);
       
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
        /*Opportunity Opp = new Opportunity(Accountid = Act.id,name ='Test Sudhir Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'OPE-0008891133');
                          
        insert Opp;*/
        
       
        Asset ast1 = new Asset(
            Name = 'testNextGenCLS',
            AccountId = act1.id,
            ContactId = con1.id,
            //Opportunity_Asset__c    = opp.id,            
            Dynamic_SKU__c= 'HF40-4P2F-11T-960F',
            Array_Controller__c = 'HF40',
            Array_Networking__c = '2P',
            Array_Capacity__c = '11T',
            array_Cache__c = '960F',
            SSD_Bank_A__c = '480F',
            SSD_Bank_B__c = '480F',
            status = 'Shipped',
            Order_Type__c = 'Test',
            IS_Array_Controller__c = 'HF40',
            IS_Array_Networking__c = '4P2F',            
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date_Asset__c = system.today() //string.valueof(Date.valueOf('2013-05-05')),
            
        );
        lstAsset.add(ast1);
        
        Asset ast2 = new Asset(
            Name = 'testNextGenCLS',
            AccountId = act1.id,
            ContactId = con1.id,
           // Opportunity_Asset__c    = opp.id,            
            Dynamic_SKU__c= 'HF40-2P4F-11T-960F',
            Array_Controller__c = 'HF40',
            Array_Networking__c = '2P',
            Array_Capacity__c = '11T',
            array_Cache__c = '960F',
            SSD_Bank_A__c = '480F',
            SSD_Bank_B__c = '480F',
            status = 'Shipped',
            Order_Type__c = 'Test',
            IS_Array_Controller__c = 'HF40',
            IS_Array_Networking__c = '2P4F',            
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date_Asset__c = system.today() //string.valueof(Date.valueOf('2013-05-05')),
            
        );
        lstAsset.add(ast2);
        
        Asset ast3 = new Asset(
            Name = 'testNextGenCLS',
            AccountId = act1.id,
            ContactId = con1.id,
            //Opportunity_Asset__c    = opp.id,            
            Dynamic_SKU__c= 'HF40-6P-11T-960F',
            Array_Controller__c = 'HF40',
            Array_Networking__c = '2P',
            Array_Capacity__c = '11T',
            array_Cache__c = '960F',
            SSD_Bank_A__c = '480F',
            SSD_Bank_B__c = '480F',
            status = 'Shipped',
            Order_Type__c = 'Test',
            IS_Array_Controller__c = 'HF40',
            IS_Array_Networking__c = '6P',            
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date_Asset__c = system.today() //string.valueof(Date.valueOf('2013-05-05')),
            
        );
        lstAsset.add(ast3);
        
        Asset ast4 = new Asset(
            Name = 'testNextGenCLS',
            AccountId = act1.id,
            ContactId = con1.id,
            //Opportunity_Asset__c    = opp.id,            
            Dynamic_SKU__c= 'HF20-2P-11T-960F',
            Array_Controller__c = 'HF40',
            Array_Networking__c = '2P',
            Array_Capacity__c = '11T',
            array_Cache__c = '960F',
            SSD_Bank_A__c = '480F',
            SSD_Bank_B__c = '480F',
            status = 'Shipped',
            Order_Type__c = 'Test',
            IS_Array_Controller__c = 'HF40',
            IS_Array_Networking__c = '6P',  
            IS_SSD_Bank_A__c   = '480F',
            IS_SSD_Bank_B__c   = '480F',
          //  a.Timeless_fulfillment__c= true;
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date_Asset__c = system.today() //string.valueof(Date.valueOf('2013-05-05')),
            
        );
        lstAsset.add(ast4);
        Map<string, Product2> AssetTypeProductMap =new Map<string, Product2>();
        Map<String,List<Product2>> mAssetTypeProductMap = new Map<String,List<Product2>>();
        map<string,String> infosightToProdMap = new Map<string, string>();
        map<string,String> pronamecompmap = new Map<String, string>();
        Map<string, Product2> multipicklistAssetTypeMap = new Map<string, Product2>();
        insert lstAsset;
        
       
        
        NextGenTriggerClass.populateIsFields(lstAsset);
        
         
        
        for(Product2 p : lstProduct){
            AssetTypeProductMap.put(p.Component_Code__c+'-'+p.Asset_Type__c, p);
            multipicklistAssetTypeMap.put(p.Component_Code__c, p);
             if(mAssetTypeProductMap.containskey(p.Component_Code__c+'-'+p.Asset_Type__c)){
                List<Product2> plist = mAssetTypeProductMap.get(p.Component_Code__c+'-'+p.Asset_Type__c);
                plist.add(p);
                mAssetTypeProductMap.put(p.Component_Code__c+'-'+p.Asset_Type__c,plist);
            }
            else{
                mAssetTypeProductMap.put(p.Component_Code__c+'-'+p.Asset_Type__c, new List<Product2>{p});
            }
            infosightToProdMap.put(p.infosight_identifier__c, p.ProductCode);
            pronamecompmap.put(p.Component_Code__c,p.ProductCode);

            

        }
        Decimal ssdCount = 0;
        Decimal ssdPack = 0;
        string str = NextGenTriggerClass.calculateSKU('480F',false,'HF20','HFA', AssetTypeProductMap,  mAssetTypeProductMap, infosightToProdMap,  pronamecompmap, multipicklistAssetTypeMap);
        string str1 = NextGenTriggerClass.calculateBANKSKU('2880F',ssdCount,'HF20','A6000',ssdPack, multipicklistAssetTypeMap, AssetTypeProductMap, infosightToProdMap, pronamecompmap, mAssetTypeProductMap);
        string str2 = NextGenTriggerClass.calculateBANKSKU('480F',ssdCount,'HF20','A6000',ssdPack, multipicklistAssetTypeMap, AssetTypeProductMap, infosightToProdMap, pronamecompmap, mAssetTypeProductMap);
        string str3 = NextGenTriggerClass.calculateBANKSKU('HF40',ssdCount,'HF20','A6000',ssdPack, multipicklistAssetTypeMap, AssetTypeProductMap, infosightToProdMap, pronamecompmap, mAssetTypeProductMap);
        test.StopTest();
        }
 }
 
static testmethod void test3(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        
        
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        
        system.runAs(u){
 
        
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 pro11=new Product2();
        pro11.Name='PCI-16FCx1C';
        pro11.Component_Code__c='2F';
        pro11.ProductCode='PCI-16FCx1C';
        pro11.Asset_Type__c='AFA2';
        pro11.infosight_identifier__c='';
        pro11.HPE_SKU__C='Q8B90B';
        pro11.Family='All Flash Array Gen5';
        pro11.Array_Controller__c = 'AF40; AF60; AF80; AF20Q; HF20H; HF40; HF20C; HF60; HF20; AF20; HF40C; HF60C';
        lstProduct.add(pro11);
        
        Product2 pro13=new Product2();
        pro13.Name='PCI-QP';
        pro13.Component_Code__c='QP';
        pro13.ProductCode='PCI-QP';
        pro13.Asset_Type__c='AFA2';
        pro13.infosight_identifier__c='QP';
        pro13.HPE_SKU__C='Q8H79A';
        pro13.Family='All Flash Array Gen5';
        
        lstProduct.add(pro13);
        
        Product2 pro14=new Product2();
        pro14.Name='HF40';
        Pro14.Component_Code__c='HF40';
        pro14.ProductCode='HF40';
        pro14.Asset_Type__c='HFA';
        pro14.infosight_identifier__c='HF40';
        pro14.HPE_SKU__C='Q8H39A';
        pro14.Family='Adaptive Flash Array Gen5';
        //insert pro;
        lstProduct.add(pro14);
        
        Product2 pro15=new Product2();
        pro15.Name='PCI-10SFPx1C';
        Pro15.Component_Code__c='2P';
        pro15.ProductCode='PCI-10SFPx1C';
        pro15.Asset_Type__c='All Flash Array Gen5';
        pro15.infosight_identifier__c='';
        pro15.HPE_SKU__C='Q8H39A';
        pro15.Family='Adaptive Flash Array Gen5';
        pro15.Array_Controller__c = 'AF40; AF60; AF80; AF20Q; HF20H; HF40; HF20C; HF60; HF20; AF20; HF40C; HF60C';
        lstProduct.add(pro15);
         
        Product2 pro16=new Product2();
        pro16.Name='ES3-H21TE';
        Pro16.Component_Code__c='21TE';
        pro16.ProductCode='ES3-H21TE';
        pro16.Asset_Type__c='Expansion Shelf3';
        pro16.infosight_identifier__c='';
        pro16.HPE_SKU__C='Q8H33A';
        pro16.Family='Expansion Shelves';
        lstProduct.add(pro16);
        
        Product2 pro17=new Product2();
        pro17.Name='ES3-FLC-2880GB';
        Pro17.Component_Code__c='2880F';
        pro17.ProductCode='ES3-FLC-2880GB';
        pro17.Asset_Type__c='Expansion Shelf3';
        pro17.infosight_identifier__c='2880';
        pro17.HPE_SKU__C='Q8C25B';
        pro17.Family='Expansion Shelves';
        lstProduct.add(pro17);
        
        Product2 pro18=new Product2();
        pro18.Name='HEAD-HDD-11TBC';
        Pro18.Component_Code__c='2880F';
        pro18.ProductCode='HEAD-HDD-11TBC';
        pro18.Asset_Type__c='Adaptive Flash Array Gen5';
        pro18.infosight_identifier__c='11T';
        pro18.HPE_SKU__C='11T';
        pro18.Family='Adaptive Flash Array Gen5';
        lstProduct.add(pro18);
      
        insert lstProduct;
        //test.startTest();        
        Account Act1 = new Account( Name = 'Test Ac', Datacenter_Care__c = false, ACM_Service_Purchased__c =false);
        insert Act1;
        
        Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'John', email='venkat@ns.com',
                                             AccountId = act1.Id);
        insert con1;
     test.startTest();        
         Asset ast3 = new Asset(
            Name = 'testNextGenCLS',
            AccountId = act1.id,
            ContactId = con1.id,
            //Opportunity_Asset__c    = opp.id,            
            Dynamic_SKU__c= 'HF40-2P-11T-960F',
            Array_Controller__c = 'HF40',
            Array_Networking__c = '2P',
            Array_Capacity__c = '11T',
            array_Cache__c = '960F',
            SSD_Bank_A__c = '480F',
            SSD_Bank_B__c = '480F',
            status = 'Shipped',
            Order_Type__c = 'Test',
            IS_Array_Controller__c = 'HF40',
            IS_Array_Networking__c = '2P2F4QP', 
            IS_Array_Capacity__c = '11T',           
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date_Asset__c = system.today() //string.valueof(Date.valueOf('2013-05-05')),
            
        );
        insert ast3;
        Asset a =new Asset();
        a.ContactId=con1.Id;
        a.AccountId=act1.Id;
        a.Order_Type__c = 'Purchased';
        a.Name='test';
        a.Expansion_Shelf_Base__c='ES3-H21TE';
        a.Product2Id=pro16.id;
        a.Dynamic_SKU__c='ES3-H21TE';
        //a.Shelf_Pack_1__c = '2880';
        //a.Shelf_Pack_2__c = '2880';
        a.HPE_Serial_Number__c = '5UMTestES3';
        a.Parent_Asset__c = ast3.Id;
        //insert a;
     test.STopTEST();
     }
 }
 
 static testmethod void test4(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        
        
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        
        system.runAs(u){
 
        
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 pro11=new Product2();
        pro11.Name='PCI-16FCx1C';
        pro11.Component_Code__c='QT';
        pro11.ProductCode='PCI-16FCx1C';
        pro11.Asset_Type__c='AFA3';
        pro11.infosight_identifier__c='';
        pro11.HPE_SKU__C='Q8B90B';
        pro11.Family='All Flash Array Gen5';
        pro11.Array_Controller__c = 'AF100';
        lstProduct.add(pro11);
        
        Product2 pro13=new Product2();
        pro13.Name='AFQ-11TXC';
        pro13.Component_Code__c='11T';
        pro13.ProductCode='AFQ-11TXC';
        pro13.Asset_Type__c='AFA3';
        pro13.infosight_identifier__c='11520F';
        pro13.HPE_SKU__C='Q8H79A';
        pro13.Family='All Flash Array Gen6';
        
        lstProduct.add(pro13);
        
        Product2 pro14=new Product2();
        pro14.Name='AF100';
        Pro14.Component_Code__c='AF100';
        pro14.ProductCode='AF100';
        pro14.Asset_Type__c='AFA3';
        pro14.infosight_identifier__c= 'AF100';
        pro14.HPE_SKU__C='Q8H39A';
        pro14.Family= 'All Flash Array Gen6';
        //insert pro;
        lstProduct.add(pro14);
        
        Product2 pro15=new Product2();
        pro15.Name='PCI-10SFPx1C';
        Pro15.Component_Code__c='QP';
        pro15.ProductCode='PCI-10SFPx1C';
        pro15.Asset_Type__c='All Flash Array Gen6';
        pro15.infosight_identifier__c='';
        pro15.HPE_SKU__C='Q8H39A';
        pro15.Family='Adaptive Flash Array Gen6';
        pro15.Array_Controller__c = 'AF100';
        lstProduct.add(pro15);
         
        Product2 pro16=new Product2();
        pro16.Name='PCI-10SFPx1C';
        Pro16.Component_Code__c='1SCM';
        pro16.ProductCode='PCI-Z';
        pro16.Asset_Type__c='All Flash Array Gen6';
        pro16.infosight_identifier__c='';
        pro16.HPE_SKU__C='Q8H39A';
        pro16.Family='Adaptive Flash Array Gen6';
        pro16.Array_Controller__c = 'AF100';
        lstProduct.add(pro16);

         
        insert lstProduct;
        //test.startTest();        
        Account Act1 = new Account( Name = 'Test Ac', Datacenter_Care__c = false, ACM_Service_Purchased__c =false);
        insert Act1;
        
        Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'John', email='venkat@ns.com',
                                             AccountId = act1.Id);
        insert con1;
         test.startTest();        
         Asset ast3 = new Asset(
            Name = 'testNextGenCLS',
            AccountId = act1.id,
            ContactId = con1.id,
            //Opportunity_Asset__c    = opp.id,            
            Dynamic_SKU__c= 'AF100-2P-11T-960F',
            Array_Controller__c = 'AF100',
            Array_Networking__c = '2P',
            Array_Capacity__c = '11T',
            array_Cache__c = '960F',
            SSD_Bank_A__c = '480F',
            SSD_Bank_B__c = '480F',
            status = 'Shipped',
            Order_Type__c = 'Test',
            IS_Array_Controller__c = 'HF40',
            IS_Array_Networking__c = '2QP1SCM3QT',  
                      
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date_Asset__c = system.today() //string.valueof(Date.valueOf('2013-05-05')),
            
        );
        insert ast3;
        NextGenTriggerClass.errorText = 'Test error';
        test.STopTEST();
     }
 }
 
 static testmethod void test5(){
       
        
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 pro11=new Product2();
        pro11.Name='PCI-16FCx1C';
        pro11.Component_Code__c='QT';
        pro11.ProductCode='PCI-16FCx1C';
        pro11.Asset_Type__c='AFA3';
        pro11.infosight_identifier__c='';
        pro11.HPE_SKU__C='Q8B90B';
        pro11.Family='All Flash Array Gen5';
        pro11.Array_Controller__c = 'AF100';
        lstProduct.add(pro11);
        
        Product2 pro13=new Product2();
        pro13.Name='AFQ-11TXC';
        pro13.Component_Code__c='11T';
        pro13.ProductCode='AFQ-11TXC';
        pro13.Asset_Type__c='AFA3';
        pro13.infosight_identifier__c='11520F';
        pro13.HPE_SKU__C='Q8H79A';
        pro13.Family='All Flash Array Gen6';
        
        lstProduct.add(pro13);
        
        Product2 pro14=new Product2();
        pro14.Name='AF100';
        Pro14.Component_Code__c='AF100';
        pro14.ProductCode='AF100';
        pro14.Asset_Type__c='AFA3';
        pro14.infosight_identifier__c= 'AF100';
        pro14.HPE_SKU__C='Q8H39A';
        pro14.Family= 'All Flash Array Gen6';
        //insert pro;
        lstProduct.add(pro14);
        
        Product2 pro15=new Product2();
        pro15.Name='PCI-10SFPx1C';
        Pro15.Component_Code__c='QP';
        pro15.ProductCode='PCI-10SFPx1C';
        pro15.Asset_Type__c='All Flash Array Gen6';
        pro15.infosight_identifier__c='';
        pro15.HPE_SKU__C='Q8H39A';
        pro15.Family='Adaptive Flash Array Gen6';
        pro15.Array_Controller__c = 'AF100';
        lstProduct.add(pro15);
         
        Product2 pro16=new Product2();
        pro16.Name='PCI-10SFPx1C';
        Pro16.Component_Code__c='1SCM';
        pro16.ProductCode='PCI-Z';
        pro16.Asset_Type__c='All Flash Array Gen6';
        pro16.infosight_identifier__c='';
        pro16.HPE_SKU__C='Q8H39A';
        pro16.Family='Adaptive Flash Array Gen6';
        pro16.Array_Controller__c = 'AF100';
        lstProduct.add(pro16);

         
        insert lstProduct;
        test.startTest();        
        Account Act1 = new Account( Name = 'Test Ac', Datacenter_Care__c = false, ACM_Service_Purchased__c =false);
        insert Act1;
        
        Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'John', email='venkat@ns.com',
                                             AccountId = act1.Id);
        insert con1;
              
         Asset ast3 = new Asset(
            Name = 'testNextGenCLS',
            AccountId = act1.id,
            ContactId = con1.id,
            //Opportunity_Asset__c    = opp.id,            
            Dynamic_SKU__c= 'AF100-2P-11T-960F',
            Array_Controller__c = 'AF100',
            Array_Networking__c = '2P',
            Array_Capacity__c = '11T',
            array_Cache__c = '960F',
            SSD_Bank_A__c = '480F',
            SSD_Bank_B__c = '480F',
            status = 'Shipped',
            Order_Type__c = 'Test',
            IS_Array_Controller__c = 'HF10',
            IS_Array_Networking__c = '2SCM', 
            IS_SSD_Bank_A__c = '42T', 
            IS_Shelf_Pack_1__c = '1927',
            IS_Shelf_Pack_2__c  = '1927',
            IS_Shelf_Pack_3__c  = '1927',
            IS_Shelf_Pack_4__c  = '1927',
            IS_Shelf_Pack_5__c  = '1927',
            IS_Shelf_Pack_6__c  = '1927',
            IS_Shelf_Pack_1B__c  = '1927',
            IS_Shelf_Pack_2B__c  = '1927',
            IS_Shelf_Pack_3B__c  = '1927',
            IS_Shelf_Pack_4B__c  = '1927',
            IS_Shelf_Pack_5B__c  = '1927',
            IS_Shelf_Pack_6B__c    = '1927',
                               
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date_Asset__c = system.today() //string.valueof(Date.valueOf('2013-05-05')),
            
        );
        insert ast3;
        NextGenTriggerClass.errorText = 'Test error';
        test.STopTEST();
     
 }
 
 }