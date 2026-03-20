@isTest(seeAllData =false)
public class  AssetHPSyncTrgClsTest{
  @istest
  public static void AssetHPSyncTrgClsTest1(){
    try{
    List<DynamicSKUsDecoderHelper__c> DynamicSKUsDecoderHelperList = new List<DynamicSKUsDecoderHelper__c>();
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj = new DynamicSKUsDecoderHelper__c(Name='AFA-103T',Controller__c='AFA',ProductCode__c='AFA',Quantity__c='2',Shelf_Pack_1__c='11520',Shelf_Pack_1B__c='',Shelf_Pack_2__c='92160',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='92T',SSD_Bank_B__c='11T',Total_Capacity__c='103T' );
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj1 = new DynamicSKUsDecoderHelper__c(Name='AFS2-103680-2',Controller__c='AFS2',ProductCode__c='AFA-AFS2',Quantity__c='',Shelf_Pack_1__c='',Shelf_Pack_1B__c='',Shelf_Pack_2__c='',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='',Total_Capacity__c='103680' );
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj2 = new DynamicSKUsDecoderHelper__c(Name='SF-ES2-H42T-2880F',Controller__c='',ProductCode__c='ES2-H42',Quantity__c='',Shelf_Pack_1__c='',Shelf_Pack_1B__c='',Shelf_Pack_2__c='',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='2880F',Total_Capacity__c='' );
    
   
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj1);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj2);
   
   insert DynamicSKUsDecoderHelperList;
        test.starttest();
        
      Account Act = new Account( Name = 'Test Sudhir Ac');
      insert Act;
      
     Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'John', email='venkat@ns.com',
                                             AccountId = act.Id);
      insert con1;
      Opportunity Opp = new Opportunity(Accountid = Act.id,name ='Test Sudhir Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'HPE00634000017clSn');
                          
      insert Opp;  

      Asset a1 = new Asset(Name = 'HPE123456', AccountId  = Act.id, contactid =con1.id,  Opportunity_Asset__c = opp.id,
      SerialNumber ='NM123456' , HPE_Serial_Number__c='HPE123456',ES_API_Call_Completed__c = true

                      );     
      Insert a1;  
     
    Nimble_Offer_Code__c  noc = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123456',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456'
                                    );
      insert noc;
      Nimble_Offer_Code__c  noc1 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123457',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456'
                                    );
      insert noc1;

     // AssetHPSyncTrgCls.createContact(act.id, 'vnekat1@ns.com', 'vgatt');
      list<Asset_Stage__c> assetstageList=new list<Asset_Stage__c>();
      Asset_Stage__c Ast = new Asset_Stage__c(  
     // Name = 'abc',
        Dynamic_SKU__c = 'CS700-4F-36T-3200F',
        End_Customer_Account_Name__c = 'Test',
        End_Customer_Account_Ref_ID__c = 'Test',
        End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
        End_Customer_Ship_to_Contact_Name__c = 'Samarth',
        ES_API_Completed__c = true,
        //Hardware__c = 'Test',
        HPE_Opportunity_ID__c = 'HPE00634000017clSn',
        HPE_Order_Number__c = 'OTest',
        HPE_Product_SKU__c = 'Test',
        HPE_Quote_Number__c = 'QTest',
        HPE_Serial_Number__c = 'HPE123456',
        Timeless_Storage_SKU__c  = 'HPE123457',
        Install_Address_City__c = 'Test',
        //Install_Address_Country__c = 'Test',
        Install_Address_State__c = 'Test',
        Install_Address_Street1__c = 'Test',
        Install_Address_Street2__c = 'Test',
        Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        Order_Status__c = null,
        Order_Type__c = 'Test',
        Product_Line__c = 'Test',
        Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        //SLA_Support_Level__c = 'HPE123456',
        Status__c = 'New',
        Unit_Consumption_Received__c=true,
        Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
        Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        Support_Term__c = null );
         
        
        insert Ast;
        //assetstageList.add(Ast);
              
      Asset_Stage__c Ast2 = new Asset_Stage__c(  
        Dynamic_SKU__c = 'CS700-4F-36T-3200F',
        End_Customer_Account_Name__c = 'Test',
        End_Customer_Account_Ref_ID__c = 'Test',
        End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
        End_Customer_Ship_to_Contact_Name__c = 'Samarth',
        //Hardware__c = 'Test',
        HPE_Opportunity_ID__c = 'HPE00634000017clSn',
        HPE_Order_Number__c = 'OTest',
        HPE_Product_SKU__c = 'Test',
        HPE_Quote_Number__c = 'QTest',
        HPE_Serial_Number__c = 'HPE123457',
        Timeless_Storage_SKU__c  = 'HPE123456',
        Install_Address_City__c = 'Test',
        Install_Address_Country__c = 'Test',
        ES_API_Completed__c = True,
        Install_Address_State__c = 'Test',
        Install_Address_Street1__c = 'Test',
        Install_Address_Street2__c = 'Test',
        Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        Order_Status__c = 'Shipped',
        Order_Type__c = 'Demo',
        Product_Line__c = 'Test',
        Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        SLA_Support_Level__c = 'HPE123456',
        Status__c = 'New',
        Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
        Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        Support_Term__c = null,
        Legacy_Asset__c = false
         );

        insert Ast2;
                assetstageList.add(Ast2);

        //Update ast2;
        AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-SF100-AF1000-CS300-ES2-H21T-SF-ES2-H21T-ES2-AFS2-AFS2-ES1-AFS');
        AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-C1K-CS1000');
        AssetHPSyncTrgCls.Dynamsku('SF100-SF300-2-3-34-342');
      AssetHPSyncTrgCls.Dynamsku('AF1000-AF3000-323-232');
        AssetHPSyncTrgCls.Dynamsku('CS300-CS500-CS700-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-H21T-ES2-H42T-ES2-H84T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('SF-ES2-H21T-SF-ES2-H42T-SF-ES2-H210T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES1-AFS-12-13-15');
        set<string> slasupportlist=new set<string>();
        slasupportlist.add('HPE123456');
        AssetHPSyncTrgCls.retrieveSLA(slasupportlist);
          AssetHPSyncTrgCls.createAsset(assetstageList,true,assetstageList);
          test.stoptest();
     }
     catch(Exception e){
         system.debug('Exception >> '+e.getmessage());
     }
   }  
    @istest
    public static void AssetHPSyncTrgClsTest21(){
        try{
   
        test.starttest();
     AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-SF100-AF1000-CS300-ES2-H21T-SF-ES2-H21T-ES2-AFS2-AFS2-ES1-AFS');
        AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-C1K-CS1000');
        AssetHPSyncTrgCls.Dynamsku('SF100-SF300-2-3-34-342');
      AssetHPSyncTrgCls.Dynamsku('AF1000-AF3000-323-232');
        AssetHPSyncTrgCls.Dynamsku('CS300-CS500-CS700-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-H21T-ES2-H42T-ES2-H84T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('SF-ES2-H21T-SF-ES2-H42T-SF-ES2-H210T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES1-AFS-12-13-15');
         list<Asset_Stage__c> assetstageList=new list<Asset_Stage__c>();

    
      Account Act = new Account( Name = 'Test Sudhir Ac');
      insert Act;
      
     Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'John', email='venkat@ns.com',
                                             AccountId = act.Id);
      insert con1;
      Opportunity Opp = new Opportunity(Accountid = Act.id,name ='Test Sudhir Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'HPE00634000017clSn');
                          
      insert Opp;  

      Asset a1 = new Asset(Name = 'HPE123456', AccountId  = Act.id, contactid =con1.id,  Opportunity_Asset__c = opp.id,
      SerialNumber ='NM123456' , HPE_Serial_Number__c='HPE123456'

                      );     
      Insert a1;  
      Asset a2 = new Asset(Name = 'NM123456', AccountId  = Act.id, contactid =con1.id, Opportunity_Asset__c = opp.id,
      SerialNumber ='' , HPE_Serial_Number__c='HPE123458'

                      );     
      Insert a2;                               
      
    Nimble_Offer_Code__c  noc = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123456',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456'
                                    );
      insert noc;
      Nimble_Offer_Code__c  noc3 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123457',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456'
                                    );
      insert noc3;

    //  AssetHPSyncTrgCls.createContact(act.id, 'vnekat2@ns.com', 'vgatt');
        AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-SF100-AF1000-CS300-ES2-H21T-SF-ES2-H21T-ES2-AFS2-AFS2-ES1-AFS');
        AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-C1K-CS1000');
        AssetHPSyncTrgCls.Dynamsku('SF100-SF300-2-3-34-342');
        AssetHPSyncTrgCls.Dynamsku('AF1000-AF3000-323-232');
        AssetHPSyncTrgCls.Dynamsku('CS300-CS500-CS700-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-H21T-ES2-H42T-ES2-H84T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('SF-ES2-H21T-SF-ES2-H42T-SF-ES2-H210T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES1-AFS-12-13-15');
      
      
      Asset_Stage__c Ast = new Asset_Stage__c(  
        Dynamic_SKU__c = 'CS700-4F-36T-3200F',
        End_Customer_Account_Name__c = 'Test',
        End_Customer_Account_Ref_ID__c = 'Test',
        End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
        End_Customer_Ship_to_Contact_Name__c = 'Samarth',
        //Hardware__c = 'Test',
        ES_API_Completed__c = true,
        HPE_Opportunity_ID__c = 'HPE00634000017clSn',
        HPE_Order_Number__c = 'OTest',
        HPE_Product_SKU__c = 'R7C75A',
        HPE_Quote_Number__c = 'QTest',
        HPE_Serial_Number__c = 'HPE123457',
        Install_Address_City__c = 'tok',
        Install_Address_Country__c = 'JP',
        Install_Address_State__c = 'tokyo',
        Install_Address_Street1__c = '45 shin st',
        Install_Address_Street2__c = '45apt',
        Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        
        Order_Type__c = 'Demo',
        Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        SLA_Support_Level__c = 'HPE123456',
        Status__c = 'New',
        Support_End_Date__c = System.today() + 365, 
        Support_Start_Date__c = system.today() );
         
                        assetstageList.add(Ast);

        insert Ast;
        Update ast;


      
      Asset_Stage__c Ast2 = new Asset_Stage__c(  
        Dynamic_SKU__c = 'CS700-4F-36T-3200F',
        End_Customer_Account_Name__c = 'Test',
        End_Customer_Account_Ref_ID__c = 'Test',
        End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
        End_Customer_Ship_to_Contact_Name__c = 'Samarth',
        //Hardware__c = 'Test',
        HPE_Opportunity_ID__c = 'HPE00634000017clSn',
        HPE_Order_Number__c = 'OTest',
        HPE_Product_SKU__c = 'Test',
        HPE_Quote_Number__c = 'QTest',
        HPE_Serial_Number__c = 'HPE123456',
        Install_Address_City__c = 'Test',
        Install_Address_Country__c = 'Test',
        Install_Address_State__c = 'Test',
        Install_Address_Street1__c = 'Test',
        Install_Address_Street2__c = 'Test',
        ES_API_Completed__c = false,
        Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        Order_Status__c = null,
        Order_Type__c = 'Test',
        Product_Line__c = 'Test',
        Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
        SLA_Support_Level__c = 'Test',
        Status__c = 'New',
        Support_End_Date__c = null, //string.valueof(Date.valueOf('2013-05-05')),
        Support_Start_Date__c = null, //string.valueof(Date.valueOf('2013-05-05')),
        Support_Term__c = null,
        Legacy_Asset__c = True
         );

        insert Ast2;
        Update ast2;
        assetstageList.add(ast2);
        
        AssetHPSyncTrgCls.createAsset(assetstageList,true,assetstageList);

     test.stoptest();
     }
     catch(Exception e){
     
     }
   }  
     @istest
  public static void AssetHPSyncTrgClsTest2(){
  try{
    List<DynamicSKUsDecoderHelper__c> DynamicSKUsDecoderHelperList = new List<DynamicSKUsDecoderHelper__c>();
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj = new DynamicSKUsDecoderHelper__c(Name='AFA-103T',Controller__c='AFA',ProductCode__c='AFA',Quantity__c='2',Shelf_Pack_1__c='11520',Shelf_Pack_1B__c='',Shelf_Pack_2__c='92160',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='92T',SSD_Bank_B__c='11T',Total_Capacity__c='103T' );
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj1 = new DynamicSKUsDecoderHelper__c(Name='AFS2-103680-2',Controller__c='AFS2',ProductCode__c='AFA-AFS2',Quantity__c='',Shelf_Pack_1__c='',Shelf_Pack_1B__c='',Shelf_Pack_2__c='',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='',Total_Capacity__c='103680' );
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj2 = new DynamicSKUsDecoderHelper__c(Name='SF-ES2-H42T-2880F',Controller__c='',ProductCode__c='ES2-H42',Quantity__c='',Shelf_Pack_1__c='',Shelf_Pack_1B__c='',Shelf_Pack_2__c='',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='2880F',Total_Capacity__c='' );
    
    DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj);
    DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj1);
    DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj2);
    
        insert DynamicSKUsDecoderHelperList;
        test.starttest();
        AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-SF100-AF1000-CS300-ES2-H21T-SF-ES2-H21T-ES2-AFS2-AFS2-ES1-AFS');
        AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-C1K-CS1000');
        AssetHPSyncTrgCls.Dynamsku('SF100-SF300-2-3-34-342');
        AssetHPSyncTrgCls.Dynamsku('AF1000-AF3000-323-232');
        AssetHPSyncTrgCls.Dynamsku('CS300-CS500-CS700-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-H21T-ES2-H42T-ES2-H84T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('SF-ES2-H21T-SF-ES2-H42T-SF-ES2-H210T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES1-AFS-12-13-15');
        list<Asset_Stage__c> assetstageList=new list<Asset_Stage__c>();
        
      Asset_Stage__c Ast = new Asset_Stage__c(  
        Dynamic_SKU__c = 'Bluetail',
        End_Customer_Account_Name__c = 'Test',
        End_Customer_Account_Ref_ID__c = 'Test',
        End_Customer_Ship_to_Contact_Email__c = 'Test@samarth.com',
        End_Customer_Ship_to_Contact_Name__c = 'Samarth',
        HPE_Opportunity_ID__c = 'OPE-0008883419',
        HPE_Order_Number__c = '7101143999',
        HPE_Product_SKU__c = 'R7C75A',
        HPE_Quote_Number__c = 'NQ05458588-03',
        HPE_Serial_Number__c = 'AF-TestJul14',
        Uber_SKU__c='S0B84A',
        Install_Address_City__c = 'San Jose',
        Install_Address_Country__c = 'US',
        Install_Address_State__c = 'CA',
        Install_Address_Street1__c = 'UNIT A 53 LARGY ROAD',
        Order_Ship_Date__c = system.today(),
        Order_Type__c = 'Demo',
        ES_API_Completed__c = True,
        Purchase_Date_HPE_Receive_Date__c = system.today(),
        SLA_Support_Level__c = 'HT7A1AC',
        Status__c = 'New',
        Timeless_Storage_SKU__c  = 'HPE123456',
        Support_End_Date__c = null,
        Support_Start_Date__c = null,
        Support_Term__c = null );
        
        insert Ast;
                                assetstageList.add(ast);

                    AssetHPSyncTrgCls.createAsset(assetstageList,true,assetstageList);

list<Asset_Stage__c> assetoldstageList=new list<Asset_Stage__c>();
Asset_Stage__c Ast1 = new Asset_Stage__c(id=assetstageList[0].id,Timeless_Storage_SKU__c = 'HPE123456',Legacy_Asset__c=true,ES_API_Completed__c=true);
update ast1;
assetoldstageList.add(ast1);
                    AssetHPSyncTrgCls.createAsset(assetstageList,false,assetoldstageList);
                    //myUnitTest();
     test.stoptest();
     }
     catch(Exception e){
     
     }
   
   }   
  
  
  
  @istest
  public static void AssetHPSyncTrgClsTest3(){
        List<DynamicSKUsDecoderHelper__c> DynamicSKUsDecoderHelperList = new List<DynamicSKUsDecoderHelper__c>();
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj = new DynamicSKUsDecoderHelper__c(Name='AFA-103T',Controller__c='AFA',ProductCode__c='AFA',Quantity__c='2',Shelf_Pack_1__c='11520',Shelf_Pack_1B__c='',Shelf_Pack_2__c='92160',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='92T',SSD_Bank_B__c='11T',Total_Capacity__c='103T' );
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj1 = new DynamicSKUsDecoderHelper__c(Name='AFS2-103680-2',Controller__c='AFS2',ProductCode__c='AFA-AFS2',Quantity__c='',Shelf_Pack_1__c='',Shelf_Pack_1B__c='',Shelf_Pack_2__c='',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='',Total_Capacity__c='103680' );
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj2 = new DynamicSKUsDecoderHelper__c(Name='SF-ES2-H42T-2880F',Controller__c='',ProductCode__c='ES2-H42',Quantity__c='',Shelf_Pack_1__c='',Shelf_Pack_1B__c='',Shelf_Pack_2__c='',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='2880F',Total_Capacity__c='' );
    
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj3 = new DynamicSKUsDecoderHelper__c(Name='ES2-AFS2-FLC-15T',Controller__c='ES2-AFS2',ProductCode__c='ES2-AFS2',Quantity__c='12',Shelf_Pack_1__c='15360',Shelf_Pack_1B__c='15360',Shelf_Pack_2__c='15360',Shelf_Pack_2B__c='15360',Shelf_Pack_3__c='3840',Shelf_Pack_3B__c='3840',Shelf_Pack_4__c='3840',Shelf_Pack_4B__c='3840',Shelf_Pack_5__c='3840',Shelf_Pack_5B__c='3840',Shelf_Pack_6__c='3840',Shelf_Pack_6B__c='',SSD_Bank_A__c='3840',SSD_Bank_B__c='11520F',Total_Capacity__c='92160' );
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj4 = new DynamicSKUsDecoderHelper__c(Name='ES1-AFS-AFS-FLC-3200GB',Controller__c='ES1-AFS',ProductCode__c='ES1-AFS',Quantity__c='4',Shelf_Pack_1__c='3200',Shelf_Pack_1B__c='',Shelf_Pack_2__c='3200',Shelf_Pack_2B__c='',Shelf_Pack_3__c='3200',Shelf_Pack_3B__c='',Shelf_Pack_4__c='3200',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='',Total_Capacity__c='12800' );
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj5 = new DynamicSKUsDecoderHelper__c(Name='AFS2-7680-1',Controller__c='AFS2',ProductCode__c='AFS2',Quantity__c='1',Shelf_Pack_1__c='3840',Shelf_Pack_1B__c='',Shelf_Pack_2__c='3840',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='',Total_Capacity__c='7680' );
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj6 = new DynamicSKUsDecoderHelper__c(Name='AFS2ABCD',Controller__c='AFS2',ProductCode__c='ABCD',Quantity__c='1',Shelf_Pack_1__c='3840',Shelf_Pack_1B__c='',Shelf_Pack_2__c='3840',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='',Total_Capacity__c='7680' );
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj7 = new DynamicSKUsDecoderHelper__c(Name='ES2-AFS2-15360-1',Controller__c='ES2-AFS2',ProductCode__c='ABCD',Quantity__c='1',Shelf_Pack_1__c='15360',Shelf_Pack_1B__c='',Shelf_Pack_2__c='',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='',Total_Capacity__c='15360' );
    DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj8 = new DynamicSKUsDecoderHelper__c(Name='AFS3-92160-1-1',Controller__c='AFS3',ProductCode__c='AFA-GEN5-AFS3',Quantity__c='1',Shelf_Pack_1__c='92160',Shelf_Pack_1B__c='',Shelf_Pack_2__c='',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='',Total_Capacity__c='92160' );
    
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj1);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj2);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj3);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj4);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj5);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj6);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj7);
   DynamicSKUsDecoderHelperList.add(DynamicSKUsDecoderHelperObj8);
   
   insert DynamicSKUsDecoderHelperList;
  test.starttest();
   Account Act = new Account( Name = 'Test Sudhir Ac');
      insert Act;
      
     Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'John', email='venkat@ns.com',
                                             AccountId = act.Id);
      insert con1;
      Opportunity Opp = new Opportunity(Accountid = Act.id,name ='Test Sudhir Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'OPE-1234567890');
                          
      insert Opp;  
      
      Product2 prod1=new Product2();
        prod1.Name='HF20';
        prod1.Component_Code__c='HF20';
        prod1.ProductCode='HF20';
        prod1.Asset_Type__c='test1';
        prod1.infosight_identifier__c='HF20';
        prod1.HPE_SKU__C='Q8H72A';
        prod1.Family='Hybrid Flash Array';
        insert prod1;

      Asset a1 = new Asset(Name = 'HPE123456', AccountId  = Act.id, contactid =con1.id,  Opportunity_Asset__c = opp.id,
      SerialNumber ='NM123456' , HPE_Serial_Number__c='HPE123456',ES_API_Call_Completed__c = true, Product2id = prod1.id,
      Array_Cache__c='test1-test1',Array_Capacity__c='test1',Array_Controller__c='test2',Array_Networking__c='test3',
      Expansion_Shelf_Base__c='test1', SSD_Bank_A__c='test1',SSD_Bank_B__c='test1'
      

                      );     
      Insert a1;  
                            
      
    Nimble_Offer_Code__c  noc = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123456',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456'
                                    );
      insert noc;
      Nimble_Offer_Code__c  noc1 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HPE123457',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456'
                                    );
      insert noc1;

    //  AssetHPSyncTrgCls.createContact(act.id, 'vnekat1@ns.com', 'vgatt');
      AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-SF100-AF1000-CS300-ES2-H21T-SF-ES2-H21T-ES2-AFS2-AFS2-ES1-AFS');
        AssetHPSyncTrgCls.Dynamsku('C1H-CS1000H-C1K-CS1000');
        AssetHPSyncTrgCls.Dynamsku('SF100-SF300-2-3-34-342');
        AssetHPSyncTrgCls.Dynamsku('AF1000-AF3000-323-232');
        AssetHPSyncTrgCls.Dynamsku('CS300-CS500-CS700-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-H21T-ES2-H42T-ES2-H84T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('SF-ES2-H21T-SF-ES2-H42T-SF-ES2-H210T-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('AFS2-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES1-AFS-12-13-15');
        AssetHPSyncTrgCls.Dynamsku('ES2-AFS2-92160-12');
        AssetHPSyncTrgCls.Dynamsku('ES1-AFS-12800-4');
        AssetHPSyncTrgCls.Dynamsku('AFS2-7680-1');
        AssetHPSyncTrgCls.Dynamsku('ABCD-234-1');
        AssetHPSyncTrgCls.Dynamsku('ES2-AFS2-15360-1');
        AssetHPSyncTrgCls.Dynamsku('AFS3-92160-1-1');
        list<Asset_Stage__c> assetstageList=new list<Asset_Stage__c>();

      Asset_Stage__c Ast = new Asset_Stage__c(  
        Dynamic_SKU__c = 'C1H-CS1000H-C1K-CS1000',
        End_Customer_Account_Name__c = 'Test',
        End_Customer_Account_Ref_ID__c = 'Test',
        End_Customer_Ship_to_Contact_Email__c = 'Test@samarth.com',
        End_Customer_Ship_to_Contact_Name__c = 'Samarth',
        HPE_Opportunity_ID__c = null,
        HPE_Order_Number__c = 'OTest',
        HPE_Product_SKU__c = 'Test',
        HPE_Quote_Number__c = 'QTest',
        HPE_Serial_Number__c = 'HPE123457',
        Install_Address_City__c = 'Test',
        Install_Address_Country__c = 'Test',
        Install_Address_State__c = 'Test',
        Install_Address_Street1__c = 'Test',
        Install_Address_Street2__c = 'Test',
        Order_Ship_Date__c = system.today(),
        Order_Status__c = null,
        Order_Type__c = 'Test',
        Product_Line__c = 'Test',
        Purchase_Date_HPE_Receive_Date__c = system.today(),
        SLA_Support_Level__c = 'Test',
        Status__c = 'New',
        ES_API_Completed__c = true,
        Support_End_Date__c = null,
        Support_Start_Date__c = null,
        Support_Term__c = null );
        
        insert Ast;
        
        
        Asset_Stage__c Ast2 = new Asset_Stage__c(  
        Dynamic_SKU__c = 'C1H-CS1000H-C1K-CS1000',
        End_Customer_Account_Name__c = 'Test',
        End_Customer_Account_Ref_ID__c = 'Test',
        End_Customer_Ship_to_Contact_Email__c = 'Test@samarth.com',
        End_Customer_Ship_to_Contact_Name__c = 'Samarth',
        HPE_Opportunity_ID__c = null,
        HPE_Order_Number__c = 'OTest',
        HPE_Product_SKU__c = 'Test',
        HPE_Quote_Number__c = 'QTest',
        HPE_Serial_Number__c = 'HPE123457',
        Install_Address_City__c = 'Test',
        Install_Address_Country__c = 'Test',
        Install_Address_State__c = 'Test',
        Install_Address_Street1__c = 'Test',
        Install_Address_Street2__c = 'Test',
        Order_Ship_Date__c = system.today(),
        Order_Status__c = null,
        Order_Type__c = 'Test',
        Product_Line__c = 'Test',
        Purchase_Date_HPE_Receive_Date__c = system.today(),
        SLA_Support_Level__c = 'Test',
        Status__c = 'New',
        ES_API_Completed__c = true,
        Support_End_Date__c = null,
        Support_Start_Date__c = null,
        Support_Term__c = null,
        Future_Contract_SLA__c = 'iuui09' );
        
        insert Ast2;

              // update ast;
        assetstageList.add(ast);
        assetstageList.add(Ast2);         
        AssetHPSyncTrgCls.createAsset(assetstageList,true,assetstageList);
                                          

        list<Asset_Stage__c> assetoldstageList=new list<Asset_Stage__c>();
        Asset_Stage__c Ast1 = new Asset_Stage__c(id=assetstageList[0].id,Timeless_Storage_SKU__c = 'HPE123456',Legacy_Asset__c=true,ES_API_Completed__c=true,Asset__c=A1.id);
        update ast1;
        assetoldstageList.add(ast1);
        AssetHPSyncTrgCls.createAsset(assetstageList,false,assetoldstageList);
     test.stoptest();
     AssetHPSyncTrgCls assetHpCls=new AssetHPSyncTrgCls();
     //assetHpCls.boostermethod();
   
   }   
  
    static testMethod void myUnitTest1(){
        List<Product2> lstproduct = new List<Product2>();
        List<Asset_Stage__c> lstAsset = new List<Asset_Stage__c>();
        test.startTest();
        Product2 pro=new Product2();
        pro.Name='HF20';
        Pro.Component_Code__c='HF20';
        pro.ProductCode='HF20';
        pro.Asset_Type__c='test1';
        pro.infosight_identifier__c='HF20';
        pro.HPE_SKU__C='Q8H72A';
        pro.Family='Hybrid Flash Array';
        pro.IsActive = true;
        pro.Simplivity_SKU__c='R4S81A';
        pro.Controller_Refresh_SKU__c = 'R4A12A';
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
        pro1.IsActive = true;
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
        pro2.IsActive = true;
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
        pro3.IsActive = true;
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
        pro4.IsActive = true;
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
        pro5.IsActive = true;
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
        pro7.IsActive = true;
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
        pro8.IsActive = true;
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
        pro6.IsActive = true;
        lstProduct.add(pro6);
        
        
        Product2 pro9=new Product2();
        pro9.Name='HEAD-HDD-84TBC';
        pro9.Component_Code__c='84T';
        pro9.ProductCode='HEAD-HDD-84TBC';
        pro9.Asset_Type__c='HFA';
        pro9.infosight_identifier__c='84T';
        pro9.HPE_SKU__C='Q8H75A';
        pro9.Family='HFA';
        pro9.IsActive = true;
        lstProduct.add(pro9);
        
        Product2 pro10=new Product2();
        pro10.Name='HEAD-FLC-11520GB-6C';
        pro10.Component_Code__c='M';
        pro10.ProductCode='HEAD-FLC-11520GB-6C';
        pro10.Asset_Type__c='HFA';
        pro10.infosight_identifier__c='11520F';
        pro10.HPE_SKU__C='Q8J31A';
        pro10.Family='Hybrid Flash Array';
        pro10.Array_Controller__c = 'HF40;HF60;HF60C';
        pro10.IsActive = true;
        lstProduct.add(pro10);
       
        Product2 pro12=new Product2();
        pro12.Name='AF20Q';
        pro12.Component_Code__c='AF20Q';
        pro12.ProductCode='AF20Q';
        pro12.Asset_Type__c='AFA2';
        pro12.infosight_identifier__c='AF20Q';
        pro12.HPE_SKU__C='Q8H73A';
        pro12.Family='All Flash Array Gen5';
        pro12.IsActive = true;
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
        pro11.IsActive = true;
        lstProduct.add(pro11);
        
        Product2 pro13=new Product2();
        pro13.Name='AFQ-11TXC';
        pro13.Component_Code__c='11T';
        pro13.ProductCode='AFQ-11TXC';
        pro13.Asset_Type__c='AFA2';
        pro13.infosight_identifier__c='11520F';
        pro13.HPE_SKU__C='Q8H79A';
        pro13.Family='All Flash Array Gen5';
        pro13.IsActive = true;
        pro13.array_controller__c = 'AF20Q';
        lstProduct.add(pro13);
        
        Product2 pro14=new Product2();
        pro14.Name='HF40';
        Pro14.Component_Code__c='HF40';
        pro14.ProductCode='HF40';
        pro14.Asset_Type__c='HFA';
        pro14.infosight_identifier__c='HF40';
        pro14.HPE_SKU__C='Q8H39A';
        pro14.Family='Adaptive Flash Array Gen5';
        pro14.IsActive = true;
        pro14.Simplivity_SKU__c='R4S84A';
        pro14.Controller_Refresh_SKU__c = 'R4A13A';
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
        pro15.IsActive = true;
        lstProduct.add(pro15);
        
        
        Product2 pro16=new Product2();
        pro16.Name='ES3-H21TE';
        Pro16.Component_Code__c='21TE';
        pro16.ProductCode='ES3-H21TE';
        pro16.Asset_Type__c='Expansion Shelf3';
        pro16.infosight_identifier__c='';
        pro16.HPE_SKU__C='Q8H33A';
        pro16.Family='Expansion Shelves';
        pro16.IsActive = true;
        lstProduct.add(pro16);
        
        Product2 pro17=new Product2();
        pro17.Name='ES3-FLC-2880GB';
        Pro17.Component_Code__c='2880F';
        pro17.ProductCode='ES3-FLC-2880GB';
        pro17.Asset_Type__c='Expansion Shelf3';
        pro17.infosight_identifier__c='2880';
        pro17.HPE_SKU__C='Q8C25B';
        pro17.Family='Expansion Shelves';
        pro17.IsActive = true;
        lstProduct.add(pro17);
       
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
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456', Datacenter_Care__c = True,
                                                          Controller_Refresh_Level__c = 'L1'
                                                          
                                    );
      lstNOC.add(noc);
       
       Nimble_Offer_Code__c  noc1 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT6Z1AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = true,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'TSC: Premium', Datacenter_Care__c = True,
                                                          Controller_Refresh_Level__c='L2'
                                    );
      lstNOC.add(noc1);
       
       Nimble_Offer_Code__c  noc2 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT7J0AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1',
                                                          TSC_Nimble_Support_Offers__c = 'TSC: Premium', Datacenter_Care__c = True,
                                                          Bundle_SKU__c = true, Controller_Refresh_Level__c = 'L3'
                                    );
      lstNOC.add(noc2);
      
      Nimble_Offer_Code__c  noc3 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT6Z6AC',
                                                             HPE_Support_Package_SKU_Description__c ='HPE NS Proactive Supp Manager Tier A SVC',
                                                             Concierge_Manager_Tier__c = 'C', Controller_Refresh_Level__c ='L1'
                                    );
      lstNOC.add(noc3);
        insert lstNOC;
        Asset_Stage__c ast1 = new Asset_Stage__c(
            Dynamic_SKU__c= 'AF20Q-2F-11T-1',
            Controller__c = 'Q8H73A',
            Networking__c  = 'Q8B90B',
            Networking_2__c  = 'Q8B90B',
            Networking_3__c  = 'Q8B90B',
            Networking_4__c  = 'Q8B90B',
            Networking_5__c  = 'Q8B90B',
            Networking_6__c  = 'Q8B90B',
            Capacity__c = 'Q8H79A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H73A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Japan',
            ES_API_Completed__c = true,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            //Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = 'Shipped',
            Order_Type__c = 'Purchased',
            Product_Line__c = 'Test',
            SLA_Support_Level__c = 'HT6Z6AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_SLA__c = 'HT6Z6AC',
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),            
            Concierge_Manager__c  = True,
            concierge_Manager_SKU__c = 'HT6Z6AC',
            Datacenter_Care__c = True,
            Legacy_Asset__c = false
        );
        lstAsset.add(ast1);
        Asset_Stage__c ast2 = new Asset_Stage__c(
            Dynamic_SKU__c= 'AF20Q-2F-11T-1',
            Controller__c = 'Q8H73A',
            Networking__c  = 'Q8B90B',
            Networking_2__c  = 'Q8B90B',
            Networking_3__c  = 'Q8B90B',
            Networking_4__c  = 'Q8B90B',
            Networking_5__c  = 'Q8B90B',
            Networking_6__c  = 'Q8B90B',
            SSD_Capacity__c = 'Q8H79A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H73A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'JP',
            ES_API_Completed__c = true,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Status__c = 'Shipped',
            Order_Type__c = 'Purchased',
            Product_Line__c = 'Test',
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Datacenter_Care__c = True,
            Future_Contract_SLA__c = 'HT6Z0AC',
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),
            Legacy_Asset__c = true
        );
        lstAsset.add(ast2);
        Asset_Stage__c ast3 = new Asset_Stage__c(
            Dynamic_SKU__c= 'AF20Q-2F-11T-1',
            Controller__c = 'Q8H73A',
            Networking__c  = 'Q8B90B',
            Networking_2__c  = 'Q8B90B',
            Networking_3__c  = 'Q8B90B',
            Networking_4__c  = 'Q8B90B',
            Networking_5__c  = 'Q8B90B',
            Networking_6__c  = 'Q8B90B',
            Capacity__c = 'Q8H79A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H73A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Japan',
            //ES_API_Completed__c = true,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            //Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = 'Shipped',
            Order_Type__c = 'Purchased',
            Product_Line__c = 'Test',
            //Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_SLA__c = 'HT6Z0AC',
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),
            HPE_Service_Agreement_ID__c = 'YB-87yioo',
            Legacy_Asset__c = false
        );
        lstAsset.add(ast3);
        
        Asset_Stage__c ast4 = new Asset_Stage__c(
            Dynamic_SKU__c= 'AF20Q-2F-11T-1',
            Controller__c = 'Q8H73A',
            Networking__c  = 'Q8B90B',
            Networking_2__c  = 'Q8B90B',
            Networking_3__c  = 'Q8B90B',
            Networking_4__c  = 'Q8B90B',
            Networking_5__c  = 'Q8B90B',
            Networking_6__c  = 'Q8B90B',
            SSD_Capacity__c = 'Q8H79A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H73A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'JP',
            
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            
            Order_Status__c = 'Shipped',
            Order_Type__c = 'Purchased',
            Product_Line__c = 'Test',
            
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_SLA__c = 'HT6Z0AC',
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),
            SSD_Capacity_B__c  = 'Q8H79A',
            HPE_Service_Agreement_ID__c = 'YB-1234',
            Concierge_Manager_SKU__c = 'HT6Z6AC',
            Legacy_Asset__c = true
        );
        lstAsset.add(ast4);
        Asset_Stage__c ast5 = new Asset_Stage__c(
            Dynamic_SKU__c= 'HF40-2P-84T-M',
            Controller__c = 'Q8H39A',//'Q8B88B',
            SSD_Capacity__c = 'Q8H75A',//'Q8B55B',
            cache__c = 'Q8J31A',
            Networking__c  = 'Q8B90B',
            Networking_2__c  = 'Q8B90B',
            Networking_3__c  = 'Q8B90B',
            Networking_4__c  = 'Q8B90B',
            Networking_5__c  = 'Q8B90B',
            Networking_6__c  = 'Q8B90B',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H39A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_SLA__c = 'HT6Z1AC',
            Future_Contract_Start_Date__c = system.today(),
            Future_Contract_End_Date__c = system.today()+365,
            HPE_Service_Agreement_ID__c = 'YB-79879',
            Legacy_Asset__c = false
        );
        lstAsset.add(ast5);
        
        
        Asset_Stage__c ast6 = new Asset_Stage__c(
            Dynamic_SKU__c= 'ES3-H21TE-2880F',
            Expansion_Shelves__c = 'Q8H33A',
            Expansion_Shelves_BankB__c   = 'Q8C25B',            
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',            
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            HPE_Product_SKU__c ='Q8H33A',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            //Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = 'Shipped',
            Order_Type__c = 'Purchased',
            Product_Line__c = 'Test',
            //Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_SLA__c = 'HT6Z0AC',
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),
            HPE_Service_Agreement_ID__c = 'YB-23333',
            Legacy_Asset__c = false
        );
        lstAsset.add(ast6);
        
        Asset_Stage__c ast7 = new Asset_Stage__c(
            Dynamic_SKU__c= 'HF40-2P-84T-M',
            Controller__c = 'Q8H39A',//'Q8B88B',
            Capacity__c = 'Q8H75A',//'Q8B55B',
            cache__c = 'Q8J31A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H39A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'test',
            ES_API_Completed__c = true,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z1AC',
            Status__c = 'New',
            Timeless_Storage_SKU__c = 'HT6Z1AC',
            //Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            //Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            
            HPE_Service_Agreement_ID__c = 'YB-2222',
            Legacy_Asset__c = false
        );
        lstAsset.add(ast7);
        
        Asset_Stage__c ast8 = new Asset_Stage__c(
            Dynamic_SKU__c= 'HF40-2P-84T-M',
            Controller__c = 'R4A13A',//'Q8B88B',
            Capacity__c = 'Q8H75A',//'Q8B55B',
            cache__c = 'Q8J31A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891234',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'R4A13A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'YB-123487',
            Nimble_Serial_Number__c = 'YB-23444',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z1AC',
            Status__c = 'New',
            Timeless_Storage_SKU__c = 'HT6Z1AC',
            //Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            //Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            
            HPE_Service_Agreement_ID__c = 'YB-1234',
            Concierge_Manager_SKU__c = 'HT6Z6AC',
            Legacy_Asset__c = false
        );
        lstAsset.add(ast8);
        
        insert lstAsset;
        test.stopTest();
    }

   
   static testMethod void myUnitTest2OBT(){
       List<Product2> lstProduct = new List<Product2>();
   test.starttest();
        Product2 pro=new Product2();
        pro.Name='HF20';
        Pro.Component_Code__c='HF20';
        pro.ProductCode='HF20';
        pro.Asset_Type__c='test1';
        pro.infosight_identifier__c='HF20';
        pro.HPE_SKU__C='Q8H72A';
        pro.Family='Hybrid Flash Array';
        pro.IsActive = true;
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
        pro1.IsActive = true;
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
        pro2.IsActive = true;
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
        pro3.IsActive = true;
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
        pro4.IsActive = true;
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
        pro5.IsActive = true;
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
        pro7.IsActive = true;
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
        pro8.IsActive = true;
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
        pro6.IsActive = true;
        pro6.Array_Controller__c= 'HF20';
        lstProduct.add(pro6);
        
        
        Product2 pro9=new Product2();
        pro9.Name='HEAD-HDD-84TBC';
        pro9.Component_Code__c='84T';
        pro9.ProductCode='HEAD-HDD-84TBC';
        pro9.Asset_Type__c='HFA';
        pro9.infosight_identifier__c='84T';
        pro9.HPE_SKU__C='Q8H75A';
        pro9.Family='HFA';
        pro9.IsActive = true;
        pro9.Array_Controller__c= 'HF20';
        lstProduct.add(pro9);
        
        Product2 pro10=new Product2();
        pro10.Name='HEAD-FLC-11520GB-6C';
        pro10.Component_Code__c='M';
        pro10.ProductCode='HEAD-FLC-11520GB-6C';
        pro10.Asset_Type__c='HFA';
        pro10.infosight_identifier__c='11520F';
        pro10.HPE_SKU__C='Q8J31A';
        pro10.Family='Hybrid Flash Array';
        pro10.IsActive = true;
        pro10.Array_Controller__c= 'HF20';
        lstProduct.add(pro10);
       
        Product2 pro12=new Product2();
        pro12.Name='AF20Q';
        pro12.Component_Code__c='AF20Q';
        pro12.ProductCode='AF20Q';
        pro12.Asset_Type__c='AFA2';
        pro12.infosight_identifier__c='AF20Q';
        pro12.HPE_SKU__C='Q8H73A';
        pro12.Family='All Flash Array Gen5';
        pro12.IsActive = true;
        
        lstProduct.add(pro12);
        
        
        Product2 pro11=new Product2();
        pro11.Name='PCI-16FCx1C';
        pro11.Component_Code__c='2F';
        pro11.ProductCode='PCI-16FCx1C';
        pro11.Asset_Type__c='AFA2';
        pro11.infosight_identifier__c='';
        pro11.HPE_SKU__C='Q8B90B';
        pro11.Family='All Flash Array Gen5';
        pro11.IsActive = true;
        pro11.Array_Controller__c= 'HF20; AF20Q';
        lstProduct.add(pro11);
        
        Product2 pro13=new Product2();
        pro13.Name='AFQ-11TXC';
        pro13.Component_Code__c='11T';
        pro13.ProductCode='AFQ-11TXC';
        pro13.Asset_Type__c='AFA2';
        pro13.infosight_identifier__c='11520F';
        pro13.HPE_SKU__C='Q8H79A';
        pro13.Family='All Flash Array Gen5';
        pro13.IsActive = true;
        lstProduct.add(pro13);
       
        insert lstProduct;
        
        Account Act = new Account( Name = 'Test Sudhir Ac', Datacenter_Care__c = false);
        insert Act;
      
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
       
       Nimble_Offer_Code__c  noc = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT6Z0AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium 4 Hour',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456', Datacenter_Care__c = True
                                    );
      insert noc;
       
       Nimble_Offer_Code__c  noc1 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT6Z1AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'TSC: Premium', Datacenter_Care__c = True
                                    );
      insert noc1;
       
       Nimble_Offer_Code__c  noc2 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT7J0AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1',
                                                          TSC_Nimble_Support_Offers__c = 'TSC: Premium', Datacenter_Care__c = True,
                                                          Bundle_SKU__c = true
                                    );
      insert noc2;

        Asset_Stage__c ast3 = new Asset_Stage__c(
            Dynamic_SKU__c= 'HF20-2OBT-21T-1440F',
            Controller__c = 'Q8H72A',
            Capacity__c = 'Q8B68B',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891133',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H72A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123457',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Timeless_Storage_SKU__c = 'HT6Z0AC',
            Timeless_Storage__c = True,
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Legacy_Asset__c = false
        );
        insert ast3;
       
        
            
        Asset_Stage__c ast4 = new Asset_Stage__c(
            Dynamic_SKU__c= 'C1K-2OBT-21T-21T',
            Controller__c = 'Q8B38A',
            Capacity__c = 'Q8B68A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8B38A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Legacy_Asset__c = false
        );
        insert ast4;
       
       Asset_Stage__c ast5 = new Asset_Stage__c(
            Dynamic_SKU__c= 'HF20-2TQF-210T-23040F',
            Controller__c = 'Q8H72A',
            Capacity__c = 'Q8B57B',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8B38A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Legacy_Asset__c = false
        );
        insert ast5;
       
        Asset_Stage__c ast6 = new Asset_Stage__c(
            Dynamic_SKU__c= 'HF20-2PQF-84T-M',
            Controller__c = 'Q8H72A',
            Capacity__c = 'Q8H75A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H72A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Legacy_Asset__c = false
        );
        insert ast6;  
       Asset_Stage__c ast7 = new Asset_Stage__c(
            Dynamic_SKU__c= 'HF20-2PQF-84T-M',
            Controller__c = 'Q8H72A',
            Capacity__c = 'Q8H75A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H72A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_SLA__c = 'HT6Z1AC',
            Future_Contract_Start_Date__c = system.today(),
            Future_Contract_End_Date__c = system.today()+365,
            Legacy_Asset__c = true
        );
        insert ast7;
       Asset_Stage__c ast8 = new Asset_Stage__c(
            Dynamic_SKU__c= 'HF20-2PQF-84T-M',
            Controller__c = 'Q8H72A',
            Capacity__c = 'Q8H75A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H72A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z1AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_Start_Date__c = system.today(),
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),
            Legacy_Asset__c = true
        );
        insert ast8; 
       
       Asset_Stage__c ast9 = new Asset_Stage__c(
            Dynamic_SKU__c= 'HF20-2PQF-84T-M',
            Controller__c = 'Q8H72A',
            Capacity__c = 'Q8H75A',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Samarth',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',
            HPE_Product_SKU__c = 'Q8H72A',
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = 'AF-123487',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Test',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'Test',
            Install_Address_Street1__c = 'Test',
            Install_Address_Street2__c = 'Test',
            //Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = null,
            Order_Type__c = 'Test',
            Product_Line__c = 'Test',
            Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT7J0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Timeless_Storage_SKU__c = 'HT7J0AC',
            ofyears__c = 3,
            Future_Contract_SLA__c = 'HT7J0AC',
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),
            HPE_Service_Agreement_ID__c = 'Test HPE 123',
            Legacy_Asset__c = true
        );
        insert ast9;
       
        
        
        test.stoptest();
   }
    
    static testmethod void myUnitTest3(){
        Test.startTest();
        List<DynamicSKUsDecoderHelper__c> DynamicSKUsDecoderHelperList = new List<DynamicSKUsDecoderHelper__c>();    
        List<Product2> lstProduct = new List<Product2>();
        List<Asset_Stage__c> lstAsset = new List<Asset_Stage__c>();
        DynamicSKUsDecoderHelper__c DynamicSKUsDecoderHelperObj = new DynamicSKUsDecoderHelper__c(Name='AFS2-46080-1',Controller__c='',ProductCode__c='',Quantity__c='1',Shelf_Pack_1__c='46080',Shelf_Pack_1B__c='',Shelf_Pack_2__c='',Shelf_Pack_2B__c='',Shelf_Pack_3__c='',Shelf_Pack_3B__c='',Shelf_Pack_4__c='',Shelf_Pack_4B__c='',Shelf_Pack_5__c='',Shelf_Pack_5B__c='',Shelf_Pack_6__c='',Shelf_Pack_6B__c='',SSD_Bank_A__c='',SSD_Bank_B__c='',Total_Capacity__c='46080' );
        Product2 pro1=new Product2();
        pro1.Name='AFA-AFS2';
        pro1.Component_Code__c='';
        pro1.ProductCode='AFA-AFS2';
        pro1.Asset_Type__c='';
        pro1.infosight_identifier__c='';
        pro1.HPE_SKU__C='';
        pro1.Family='Expansion Shelves';
        pro1.IsActive = true;
        lstProduct.add(pro1);
        
        Product2 pro2=new Product2();
        pro2.Name='AFS2';
        pro2.Component_Code__c='';
        pro2.ProductCode='AFS2';
        pro2.Asset_Type__c='';
        pro2.infosight_identifier__c='';
        pro2.HPE_SKU__C='Q8B53A';
        pro2.Family='All Flash Shelf';
        pro2.IsActive = true;
        lstProduct.add(pro2);
        
        Product2 pro3=new Product2();
        pro3.Name='AFS3';
        pro3.Component_Code__c='';
        pro3.ProductCode='AFS3';
        pro3.Asset_Type__c='';
        pro3.infosight_identifier__c='';
        pro3.HPE_SKU__C='Q8B53B';
        pro3.Family='All Flash Shelf';
        pro3.IsActive = true;
        lstProduct.add(pro3);
        
        Product2 pro4=new Product2();
        pro4.Name='AFS3-23T';
        pro4.Component_Code__c='23040';
        pro4.ProductCode='AFS3-23T';
        pro4.Asset_Type__c='';
        pro4.infosight_identifier__c='23040F';
        pro4.HPE_SKU__C='Q8C31B';
        pro4.Family='All Flash Shelf';
        pro4.IsActive = true;
        lstProduct.add(pro4);
        
        BTO_Orders__c b = new BTO_Orders__c();
        b.Name = 'R3S71A';
        b.R_Code__c = 'R3S71A';
        insert b;
        
        
        
        Account Act = new Account( Name = 'Test   yesha',Datacenter_Care__c = false);
        insert Act;
        
        Account Act1 = new Account( Name = 'Test Ac', Datacenter_Care__c = false);
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
        
        /*Opp__BTO_Acct_mdt obto = new Opp__BTO_Acct_mdt();
        Name = 'Test';
        Account_ID__c = act1.id;
        Customer_Ref_ID__c = '0008891133';
        HPE_Opportunity__c = 'OPE-0008891133';
        Opportunity_ID__c = opp.id;
        insert obto;*/
       
       Nimble_Offer_Code__c  noc = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT6Z0AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium 4 Hour',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'HPE123456', Datacenter_Care__c = True,
                                                          Controller_Refresh_Level__c = 'L3'
                                    );
      insert noc;
       
       Nimble_Offer_Code__c  noc1 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT6Z1AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = true,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1', Timeless_Refresh_Years__c = 2, 
                                                          TSC_Nimble_Support_Offers__c = 'TSC: Premium', Datacenter_Care__c = True,
                                                          Controller_Refresh_Level__c = 'L1'
                                    );
      insert noc1;
       
       Nimble_Offer_Code__c  noc2 = new Nimble_Offer_Code__c (Concierge_Manager__c  = true,HPE_Support_Package_SKU__c ='HT7J0AC',
                                                          HPE_Support_Package_SKU_Description__c ='desp', Nimble_NDR__c  = True,
                                                          Nimble_Support_Offers__c ='Premium',Nimble_Timeless_Storage__c =True,
                                                          Nimble_Timeless_Tier__c  = 'Tier 1',
                                                          TSC_Nimble_Support_Offers__c = 'TSC: Premium', Datacenter_Care__c = True,
                                                          Bundle_SKU__c = true, Controller_Refresh_Level__c = 'L2'
                                    );
      insert noc2;
        
        insert lstProduct;
        Asset_Stage__c ast1 = new Asset_Stage__c(
            Dynamic_SKU__c= 'AFS2-46080-1',
            HPE_Product_SKU__c = 'R3S71A',                        
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = '0700784606',
            End_Customer_Ship_to_Contact_Email__c = 'yesha@test.com',
            End_Customer_Ship_to_Contact_Name__c = 'yesha',
            //HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',            
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = '5UMTest2',
            Nimble_Serial_Number__c = 'AF-TestJul1',
            Install_Address_City__c = 'Belmont',
            Install_Address_Country__c = 'JP',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'CA',
            Install_Address_Street1__c = 'H St',
            Install_Address_Street2__c = '345',
            //Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = 'Shipped',
            Order_Type__c = 'Purchased',
            Product_Line__c = 'Test',
            Timeless_Storage_SKU__c = 'HT6Z0AC',
            Timeless_Storage__c = True,
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'Completed',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            
            Legacy_Asset__c = false
        );
        lstAsset.add(ast1);
        Asset_Stage__c ast2 = new Asset_Stage__c(
            Dynamic_SKU__c= 'AFS3-69120-2',
            HPE_Product_SKU__c = 'Q8B53B',                        
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'yesha@test.com',
            End_Customer_Ship_to_Contact_Name__c = 'yesha',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',            
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = '5UMTest1',
            Nimble_Serial_Number__c = 'AF-Jul2',
            Install_Address_City__c = 'Test',
            Install_Address_Country__c = 'Japan',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'San Mateo',
            Install_Address_Street1__c = '78 laurel st',
            Install_Address_Street2__c = 'apt 5',
            //Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = 'Shipped',
            Order_Type__c = 'Purchased',
            Product_Line__c = 'H6',
            //Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_SLA__c = 'HT6Z0AC',
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),
            AFS3__c = 'Q8B53B',
              Networking_4__c='R3Q00A',
            Shelf_Pack_1__c = 'Q8C31B',
            Shelf_Pack_2__c = 'Q8C31B',
            Legacy_Asset__c = false
        );
        lstAsset.add(ast2);
        Asset_Stage__c ast3 = new Asset_Stage__c(
            Dynamic_SKU__c= 'AFS3-69120-2',
            HPE_Product_SKU__c = 'Q8B53B',                        
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'yesha@test.com',
            End_Customer_Ship_to_Contact_Name__c = 'yesha',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',            
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = '5UMTest3',
            Nimble_Serial_Number__c='AF-TestJul3',
            Install_Address_City__c = 'Lexington',
            Install_Address_Country__c = 'US',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'MA',
            Install_Address_Street1__c = '23 School St',
            
            Order_Status__c = 'Shipped',
            Order_Type__c = 'Purchased',
            Product_Line__c = 'Test',
            //Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_SLA__c = 'HT6Z0AC',
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),
            AFS3__c = 'Q8B53B',
            Networking_3__c='R3Q00A',
            //Shelf_Pack_1__c = 'Q8C31B',
            Shelf_Pack_2__c = 'Q8C31B',
            Legacy_Asset__c = false
        );
        lstAsset.add(ast3);  
        Asset_Stage__c ast4 = new Asset_Stage__c(
            Dynamic_SKU__c= 'Bluetail',
            HPE_Product_SKU__c = 'Q8B53B',                        
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'yesha@test.com',
            End_Customer_Ship_to_Contact_Name__c = 'yesha',
            HPE_Opportunity_ID__c = 'OPE-0008891123',
            HPE_Order_Number__c = 'OTest1',            
            HPE_Quote_Number__c = 'QTest1',
            HPE_Serial_Number__c = '5UMTest4',
            Nimble_Serial_Number__c = 'AF-TestJul4',
            Install_Address_City__c = 'Belmont',
            Install_Address_Country__c = 'US',
            ES_API_Completed__c = false,
            Install_Address_State__c = 'MA',
            Install_Address_Street1__c = 'Brighton St',
            Install_Address_Street2__c = '234',
            //Order_Ship_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Order_Status__c = 'Shipped',
            Order_Type__c = 'Purchased',
            Product_Line__c = 'Test',
            //Purchase_Date_HPE_Receive_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            SLA_Support_Level__c = 'HT6Z0AC',
            Status__c = 'New',
            Support_End_Date__c = system.today()+365, //string.valueof(Date.valueOf('2013-05-05')),
            Support_Start_Date__c = system.today(), //string.valueof(Date.valueOf('2013-05-05')),
            Support_Term__c = null,
            Future_Contract_SLA__c = 'HT6Z0AC',
            Future_Contract_End_Date__c = Date.valueOf('1900-01-01'),
            AFS__c = 'Q8B53B',
            Networking_2__c='R0R12A',
            Shelf_Pack_1__c = 'Q8C31B',
            //Shelf_Pack_2__c = 'Q8G49B',
            Legacy_Asset__c = false
        );
        lstAsset.add(ast4);
        
        Asset_Stage__c Ast = new Asset_Stage__c(  
        Dynamic_SKU__c = null,
        End_Customer_Account_Name__c = 'Test',
        End_Customer_Account_Ref_ID__c = 'Test',
        End_Customer_Ship_to_Contact_Email__c = 'Yesha@hpe.com',
        End_Customer_Ship_to_Contact_Name__c = 'yeshab',
        HPE_Opportunity_ID__c = 'OPE-0008891123',
        HPE_Order_Number__c = '7101143999',
        HPE_Product_SKU__c = 'S0B84A',
        HPE_Quote_Number__c = 'NQ05458588-03',
        HPE_Serial_Number__c = 'CZ232208QX',
        Nimble_Serial_Number__c = 'CZ232208QX',
        Install_Address_City__c = 'San Jose',
        Install_Address_Country__c = 'US',
        Install_Address_State__c = 'CA',
        Install_Address_Street1__c = 'UNIT A 53 LARGY ROAD',
        Order_Ship_Date__c = system.today(),
        Order_Status__c = 'Shipped',
        Order_Type__c = 'Purchased',
        Purchase_Date_HPE_Receive_Date__c = system.today(),
        SLA_Support_Level__c = 'HT7A1AC',
        Status__c = 'New',
        Timeless_Storage_SKU__c  = 'HPE123456',
        Support_End_Date__c = system.today(),
        Support_Start_Date__c = system.today() +365,
        Support_Term__c = null );
        lstAsset.add(Ast);
        
        
        
        
        
        insert lstAsset;
        
        
        Asset_Stage__c AstStg = new Asset_Stage__c(  
        Dynamic_SKU__c = null,
        End_Customer_Account_Name__c = 'Test',
        End_Customer_Account_Ref_ID__c = 'Test',
        End_Customer_Ship_to_Contact_Email__c = 'yesha@hpe.com',
        End_Customer_Ship_to_Contact_Name__c = 'Yeshab',
        HPE_Opportunity_ID__c = 'OPE-0008891123',
        HPE_Order_Number__c = '7101143999',
        HPE_Product_SKU__c = 'R4A11A',
        HPE_Quote_Number__c = 'NQ05458588-03',
        HPE_Serial_Number__c = 'CZ232208RE',
        Nimble_Serial_Number__c = 'CZ232208QX',
        Install_Address_City__c = 'San Jose',
        Install_Address_Country__c = 'US',
        Install_Address_State__c = 'CA',
        Install_Address_Street1__c = 'UNIT A 53 LARGY ROAD',
        Order_Ship_Date__c = system.today(),
        Order_Status__c = 'Shipped',
        Order_Type__c = 'Purchased',
        Purchase_Date_HPE_Receive_Date__c = system.today(),
        SLA_Support_Level__c = 'HT7A1AC',
        Status__c = 'New',
        Timeless_Storage_SKU__c  = 'HPE123456',
        Support_End_Date__c = system.today(),
        Support_Start_Date__c = system.today() +365,
        Support_Term__c = null );
        insert AstStg;
        
        
        Test.stopTest();
    }

       
 }