/**
    * Test Class Name: UpdateAssetContactBatchTest
    * Created By: Jana Reddy
    * Created Date: 10/09/2023 
    *
    * Description:
    * This Salesforce Apex test class is used to test the UpdateAssetContactBatch and UpdateAssetContactBatchSchedule classes.
    * It inserts test records, sets created dates, and schedules the batch job for testing.
    *
    * Usage:
    * - Use this test class to validate the functionality of UpdateAssetContactBatch and UpdateAssetContactBatchSchedule.
*/
@isTest
public class UpdateAssetContactBatchTest {
    @isTest
    static void testBatchExecution() {
        Product2 pro4=new Product2();
        pro4.Name='ES2-AFS2';
        Pro4.Component_Code__c='ES2-AFS2';
        pro4.ProductCode='ES2-AFS2';
        pro4.Asset_Type__c='Expansion Shelves';
        pro4.Family='Expansion Shelves';
        pro4.Infosight_Identifier__c = 'ES2-AFS2';
        insert pro4;
        Account Act = new Account( Name = 'Test Sudhir Ac');
        insert Act;
        Contact con1 = new Contact(LastName  = 'Doe',
                                   FirstName = 'John', email='venkat@ns.com',
                                   AccountId = act.Id);
        insert con1;
        Contact con2 = new Contact(LastName  = 'Doe1',
                                   FirstName = 'John2', email='johnDoe1@ns.com'
                                   );
        insert con2;
        Opportunity Opp = new Opportunity(Accountid = Act.id,name ='Test Sudhir Opp',
                                          CloseDate= system.today(),
                                          Type='New Business',
                                          Sales_Area__c='NA COM West NorCal',
                                          StageName='Sales Forecast Category',
                                          HPE_Opportunity_ID__c = 'OPE-0009044466');
        
        insert Opp;  
        Asset a1 =new Asset();       
        a1.AccountId=Act.Id;
        a1.Name = 'ES2AFS2Test';
        a1.Asset_Type_Build__c ='Legacy';
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
        a1.Shelf_Pack_1__c ='7680';
        a1.Shelf_Pack_2__c='7680';
        a1.Shelf_Pack_3__c='7680';
        a1.Shelf_Pack_4__c='7680';
        a1.Shelf_Pack_5__c='7680';
        a1.Shelf_Pack_6__c='7680';
        a1.HPE_Serial_Number__c = '99000002';
        a1.Expansion_Shelf_Base__c ='ES2-AFS2';
        a1.HPE_Opportunity_ID__c = Opp.HPE_Opportunity_ID__c;
        Insert a1;
        Asset_Stage__c Ast = new Asset_Stage__c(  
            Dynamic_SKU__c = 'CS700-4F-36T-3200F',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'venkat@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'Test Samarth',
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
        
        insert Ast;
        a1.Asset_Stage__c =ast.id;
        update a1;
        Asset a2 =new Asset();       
        a2.AccountId=Act.Id;
        a2.Name = 'ES2AFS2Test';
        a2.Asset_Type_Build__c ='Legacy';
        a2.Product2Id = pro4.Id;
        a2.Dynamic_SKU__c= 'ES2-AFS2-15360-1';
        a2.Expansion_shelf_base__c = 'ES2-AFS2';
        a2.Shelf_Pack_1B__c = '15360';
        a2.Shelf_Pack_2B__c = '7680';
        a2.Shelf_Pack_2B_SKU__c= 'AFS2-FLC-8T';
        a2.Shelf_Pack_3B__c = '7680';
        a2.Shelf_Pack_3B_SKU__c= 'AFS2-FLC-8T';
        a2.Shelf_Pack_4B__c = '7680';
        a2.Shelf_Pack_4B_SKU__c= 'AFS2-FLC-8T';
        a2.Shelf_Pack_5B__c = '7680';
        a2.Shelf_Pack_5B_SKU__c= 'AFS2-FLC-8T';
        a2.Shelf_Pack_6B__c = '7680';
        a2.Shelf_Pack_6B_SKU__c= 'AFS2-FLC-8T';
        a2.IS_Shelf_Pack_1B__c='7680';
        a2.IS_Shelf_Pack_2B__c='7680';
        a2.IS_Shelf_Pack_3B__c='7680';
        a2.IS_Shelf_Pack_4B__c='7680';
        a2.IS_Shelf_Pack_5B__c='7680';
        a2.IS_Shelf_Pack_6B__c='7680';
        a2.Shelf_Pack_1__c ='7680';
        a2.Shelf_Pack_2__c='7680';
        a2.Shelf_Pack_3__c='7680';
        a2.Shelf_Pack_4__c='7680';
        a2.Shelf_Pack_5__c='7680';
        a2.Shelf_Pack_6__c='7680';
        a2.HPE_Serial_Number__c = '99000002';
        a2.Expansion_Shelf_Base__c ='ES2-AFS2';
        a2.HPE_Opportunity_ID__c =Opp.HPE_Opportunity_ID__c;
        Insert a2;
        Asset_Stage__c Ast2 = new Asset_Stage__c(  
            Dynamic_SKU__c = 'CS700-4F-36T-3200F',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'johnDoe1@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'John Doe',
            ES_API_Completed__c = true,
            HPE_Opportunity_ID__c = Opp.HPE_Opportunity_ID__c,
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
        
        insert Ast2;
        a2.Asset_Stage__c =Ast2.id;
        update a2;
        Asset a3 =new Asset();       
        a3.AccountId=Act.Id;
        a3.Name = 'ES2AFS2Test';
        a3.Asset_Type_Build__c ='Legacy';
        a3.Product2Id = pro4.Id;
        a3.Dynamic_SKU__c= 'ES2-AFS2-15360-1';
        a3.Expansion_shelf_base__c = 'ES2-AFS2';
        a3.Shelf_Pack_1B__c = '15360';
        a3.Shelf_Pack_2B__c = '7680';
        a3.Shelf_Pack_2B_SKU__c= 'AFS2-FLC-8T';
        a3.Shelf_Pack_3B__c = '7680';
        a3.Shelf_Pack_3B_SKU__c= 'AFS2-FLC-8T';
        a3.Shelf_Pack_4B__c = '7680';
        a3.Shelf_Pack_4B_SKU__c= 'AFS2-FLC-8T';
        a3.Shelf_Pack_5B__c = '7680';
        a3.Shelf_Pack_5B_SKU__c= 'AFS2-FLC-8T';
        a3.Shelf_Pack_6B__c = '7680';
        a3.Shelf_Pack_6B_SKU__c= 'AFS2-FLC-8T';
        a3.IS_Shelf_Pack_1B__c='7680';
        a3.IS_Shelf_Pack_2B__c='7680';
        a3.IS_Shelf_Pack_3B__c='7680';
        a3.IS_Shelf_Pack_4B__c='7680';
        a3.IS_Shelf_Pack_5B__c='7680';
        a3.IS_Shelf_Pack_6B__c='7680';
        a3.Shelf_Pack_1__c ='7680';
        a3.Shelf_Pack_2__c='7680';
        a3.Shelf_Pack_3__c='7680';
        a3.Shelf_Pack_4__c='7680';
        a3.Shelf_Pack_5__c='7680';
        a3.Shelf_Pack_6__c='7680';
        a3.HPE_Serial_Number__c = '99000002';
        a3.Expansion_Shelf_Base__c ='ES2-AFS2';
        
        Insert a3;
        Asset_Stage__c Ast3 = new Asset_Stage__c(  
            Dynamic_SKU__c = 'CS700-4F-36T-3200F',
            End_Customer_Account_Name__c = 'Test',
            End_Customer_Account_Ref_ID__c = 'Test',
            End_Customer_Ship_to_Contact_Email__c = 'johnDoe1@ns.com',
            End_Customer_Ship_to_Contact_Name__c = 'John',
            ES_API_Completed__c = true,
            HPE_Opportunity_ID__c = Opp.HPE_Opportunity_ID__c,
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
        
        insert Ast3;
        a3.Asset_Stage__c =Ast3.id;
        update a3;
        Test.startTest();
         UpdateAssetContactBatchSchedule  batchJob = new UpdateAssetContactBatchSchedule();
        String sch='0 0 4 * * ?';
        System.schedule('UpdateAssetContactBatch',sch,batchJob);
        Test.stopTest();
        
    }
    
}