@isTest(seeAllData=false)
private class test_B2BOrderSalesOrder {


     static testMethod void myUnitTest2()
    {
        TestUtils.enable_isRunningTest = true;
        Account a = new Account(Name='Test');
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        opp.Type='New Business';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        
        insert opp;
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='SLA-NBD');
        p.ProductCode='SLA-NBD';
        p.BOM_Level__c=1;
        p.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert p;
        
        /*Product2 p1 = new Product2(Name='Test1',IsActive=true,Productcode='Test1');
        p1.ProductCode='pro1';
        p1.BOM_Level__c=2;
        p1.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert p1;*/
        
       /* Product2 p2 = new Product2(Name='ADFA',IsActive=true,Productcode='ADFA');
        p1.ProductCode='ADFA';
        p1.BOM_Level__c=1;
        p1.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert p2;*/

        RecordType recty = [select name from RecordType where name ='Internal Quote'];
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        quote.RecordTypeId=recty.id;
               quote.SBQQ__Type__c='Change Order';
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert quote;
        
        quote = [select id, name from SBQQ__Quote__c where id=:quote.id];
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.SBQQ__NetPrice__c=100;
        line.SBQQ__RequiredBy__c=null;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 10;
        line.SBQQ__PackageProductCode__c='pro';
        line.SBQQ__ProductOption__c=null;
        line.SBQQ__Renewal__c=true;
        line.SBQQ__OptionType__c='Component';
        line.SBQQ__Existing__c=false;
        //line.BOM_Level__c=1;
        //line.SBQQ__NetTotal__c=1000;
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line;
        
      /*  SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 1000;
        line1.SBQQ__RequiredBy__c=line.id;
        line1.SBQQ__NetPrice__c=100;
        line1.BOM_Line_Number__c='2';
        line1.SBQQ__Quantity__c = 10;
        line1.SBQQ__PackageProductCode__c='pro1';
        line1.SBQQ__ProductOption__c=null;
        line1.SBQQ__Renewal__c=true;
        line1.SBQQ__OptionType__c='Component';
        line1.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line1;
        
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p2.Id);
        line2.SBQQ__ListPrice__c = 1000;
        line2.SBQQ__RequiredBy__c=line1.id;
        line2.SBQQ__NetPrice__c=100;
        line2.BOM_Line_Number__c='3';
        line2.SBQQ__Quantity__c = 10;
        line2.SBQQ__PackageProductCode__c='ADFA';
        line2.SBQQ__ProductOption__c=null;
        line2.SBQQ__Renewal__c=true;
        line2.SBQQ__OptionType__c='Accessory';
        line2.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line2;*/
        
        B2B_Partner__c b2bpart = new B2B_Partner__c();
        b2bpart.B2B_Partner_Id__c='123456';
        b2bpart.B2B_Partner_Name__c='test partner';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bpart;
        Test.startTest();
        B2B_Order__c b2border = new B2B_Order__c();
        b2border.B2B_Partner__c=b2bpart.id;
        b2border.B2B_NMBL_Quote_Number__c = quote.name;
        b2border.B2B_Partner_Purchase_Order__c='test';
        b2border.B2B_Partner_Purchase_Order_Date__c=date.today();
        b2border.B2B_Partner_Purchase_Order_Amount__c=100;
        b2border.B2B_Order_Type__c='';
        b2border.Bill_To_Contact_Name__c=null;
        b2border.Bill_To_Address_1__c=null;
        b2border.Bill_To_City__c=null;
        b2border.Bill_To_Zip_Postal_Code__c=null;
        b2border.Bill_To_State__c=null;
        b2border.Bill_To_Company__c='test';
        b2border.Bill_To_Contact_Email__c='test@test.com';
        b2border.Ship_To_Contact_Name__c='test';
        b2border.Ship_To_Address_1__c='';
        b2border.Ship_To_City__c='';
        b2border.Ship_To_Zip_Postal_Code__c='';
        b2border.Ship_To_State__c='';
        b2border.Ship_To_Contact_Email__c='test@test.com';
        b2border.End_Customer_Contact_Name__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.End_Customer_City__c='test';
        b2border.End_Customer_Zip_Postal_Code__c='123456';
        b2border.End_Customer_State__c='test';
        b2border.Shipment_Service_Level__c='';
        b2border.End_Customer_Company__c='test';
        b2border.Install_Location__c='test';
        b2border.Currency__c='USD';
        b2border.Requested_Ship_Date__c=date.today();
        b2border.Planned_Install_Date__c=date.today();
        b2border.Total_Lines_Received__c=1;
        b2border.B2B_Order_Status__c='Validation Success';
        b2border.Ship_To_Company__c='test';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2border;
       
       
        
        /*quote.SBQQ__Primary__c=true;
        quote.SBQQ__Status__c='Approved';
        utility.runDupRecTrigger=false;
        update quote;*/
        
        B2B_Order_Line__c b2bline = new B2B_Order_Line__c();
        b2bline.B2B_Order__c=b2border.id;
        b2bline.B2B_Order_Line__c='3456';
        b2bline.B2B_Order_Line_Status__c='Validation Success';
        b2bline.B2B_Order_Line_Error_Messages__c='';
        b2bline.B2B_Quote_Line__c=string.valueof(line.id).substring(0,15);
        b2bline.Part_Number__c='pro';
        b2bline.Quantity__c=10;
        b2bline.Net_Price__c=1000;
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bline;
        
        B2B_Order_Line__c b2bline1 = new B2B_Order_Line__c();
        b2bline1.B2B_Order__c=b2border.id;
        b2bline1.B2B_Order_Line__c='3456';
        b2bline1.B2B_Order_Line_Status__c='Validation Success';
        b2bline1.B2B_Order_Line_Error_Messages__c='';
        b2bline1.B2B_Quote_Line__c=string.valueof(line.id).substring(0,15);
        b2bline1.Part_Number__c='pro1';
        b2bline1.Quantity__c=10;
        b2bline1.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bline1;
        
        B2B_Order_Line__c b2bline2 = new B2B_Order_Line__c();
        b2bline2.B2B_Order__c=b2border.id;
        b2bline2.B2B_Order_Line__c='3456';
        b2bline2.B2B_Order_Line_Status__c='Validation Success';
        b2bline2.B2B_Order_Line_Error_Messages__c='';
        b2bline2.B2B_Quote_Line__c=string.valueof(line.id).substring(0,15);
        b2bline2.Part_Number__c='pro1';
        b2bline2.Quantity__c=10;
        b2bline2.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bline2;
        
        b2border.B2B_Order_Status__c='New';
        b2border.B2B_Order_Type__c='Revenue';
        b2border.Bill_To_Address_1__c='test';
        b2border.Ship_To_Address_1__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.Total_Lines_Received__c=3;
        b2border.B2B_Partner_Purchase_Order_Amount__c=1000;
        utility.runDupRecTrigger=true;
        recursviveClass.recursiveTestCls = false;
        update b2border;
         /*p.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        update p;

       list<SBQQ__QuoteLine__c> qllist = new list<SBQQ__QuoteLine__c>();
        line.SBQQ__OptionType__c='Accessory';
        qllist.add(line);
        line1.SBQQ__OptionType__c='Accessory';
        qllist.add(line1);
        line2.SBQQ__OptionType__c='Accessory';
       
        qllist.add(line2);
         utility.runDupRecTrigger=false;
        update qllist;
        b2border.B2B_Order_Status__c='New';
        utility.runDupRecTrigger=false;
        update b2border;*/
        Test.stopTest();
    }
    
    static testmethod void myunittest3(){
     
        Account a = new Account(Name='Test');
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        opp.Type='Support Renewal';
        opp.Prebuild_Status__c ='Approved';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert opp;
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test');
        p.ProductCode='pro';
        p.BOM_Level__c=1;
        p.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert p;
        
        /*Product2 p2 = new Product2(Name='Test2',IsActive=true,Productcode='Test2');
        p2.ProductCode='pro2';
        p2.BOM_Level__c=3;
        p2.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        insert p2;*/
        
        Product2 p1 = new Product2(Name='Test1',IsActive=true,Productcode='Test1');
        p1.ProductCode='pro1';
        p1.BOM_Level__c=2;
        p1.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert p1;
        
        RecordType recty = [select name from RecordType where name ='Internal Quote'];
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        quote.RecordTypeId=recty.id;
        //utility.runDupRecTrigger=false;
               quote.SBQQ__Type__c='Change Order';
               utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert quote;
        
        quote = [select id, name from SBQQ__Quote__c where id=:quote.id];
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.SBQQ__NetPrice__c=100;
        line.SBQQ__RequiredBy__c=null;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 10;
        line.SBQQ__PackageProductCode__c='pro';
        line.SBQQ__ProductOption__c=null;
        line.SBQQ__Renewal__c=true;
        line.SBQQ__OptionType__c='Accessory';
        line.SBQQ__Existing__c=false;
        //line.BOM_Level__c=1;
        //line.SBQQ__NetTotal__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line;
        
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 1000;
        line1.SBQQ__RequiredBy__c=line.id;
        line1.SBQQ__NetPrice__c=100;
        line1.BOM_Line_Number__c='2';
        line1.SBQQ__Quantity__c = 10;
        line1.SBQQ__PackageProductCode__c='pro1';
        line1.SBQQ__ProductOption__c=null;
        line1.SBQQ__Renewal__c=true;
        line1.SBQQ__OptionType__c='Accessory';
        line1.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line1;
        
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line2.SBQQ__ListPrice__c = 1000;
        line2.SBQQ__RequiredBy__c=line1.id;
        line2.SBQQ__NetPrice__c=100;
        line2.BOM_Line_Number__c='3';
        line2.SBQQ__Quantity__c = 1;
        line2.SBQQ__PackageProductCode__c='pro1';
        line2.SBQQ__ProductOption__c=null;
        line2.SBQQ__Renewal__c=true;
        line2.SBQQ__OptionType__c='Accessory';
        line2.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line2;
        
        B2B_Partner__c b2bpart = new B2B_Partner__c();
        b2bpart.B2B_Partner_Id__c='123456';
        b2bpart.B2B_Partner_Name__c='test partner';
        utility.runDupRecTrigger=false;
        insert b2bpart;
        Test.startTest();
        B2B_Order__c b2border = new B2B_Order__c();
        b2border.B2B_Partner__c=b2bpart.id;
        b2border.B2B_NMBL_Quote_Number__c=''+string.valueof(quote.name);
        b2border.B2B_Partner_Purchase_Order__c='test';
        b2border.B2B_Partner_Purchase_Order_Date__c=date.today();
        b2border.B2B_Partner_Purchase_Order_Amount__c=100;
        b2border.B2B_Order_Type__c='';
        b2border.Bill_To_Contact_Name__c='test';
        b2border.Bill_To_Address_1__c='';
        b2border.Bill_To_City__c='test';
        b2border.Bill_To_Zip_Postal_Code__c='123456';
        b2border.Bill_To_State__c='test';
        b2border.Bill_To_Company__c='test';
        b2border.Bill_To_Contact_Email__c='test@test.com';
        b2border.Ship_To_Contact_Name__c='test';
        b2border.Ship_To_Address_1__c='';
        b2border.Ship_To_City__c='test';
        b2border.Ship_To_Zip_Postal_Code__c='123456';
        b2border.Ship_To_State__c='test';
        b2border.Ship_To_Contact_Email__c='test@test.com';
        b2border.End_Customer_Contact_Name__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.End_Customer_City__c='test';
        b2border.End_Customer_Zip_Postal_Code__c='123456';
        b2border.End_Customer_State__c='test';
        b2border.Shipment_Service_Level__c='';
        b2border.End_Customer_Company__c='test';
        b2border.Install_Location__c='test';
        b2border.Currency__c='USD';
        b2border.Requested_Ship_Date__c=date.today();
        b2border.Planned_Install_Date__c=date.today();
        b2border.Total_Lines_Received__c=1;
        b2border.B2B_Order_Status__c='Validation Success';
        b2border.Ship_To_Company__c='test';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2border;
               
        quote.SBQQ__Primary__c=true;
        quote.SBQQ__Status__c='Approved';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        update quote;
        
         Sales_Order__c Sales_Orderobj = new Sales_Order__c(Type__c='Revenue',Opportunity__c=opp.id,B2B_Order__c=b2border.id);
            utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert Sales_Orderobj;
        Sales_Order_Line__c soline = new Sales_Order_Line__c(Sales_Order__c=Sales_Orderobj.id,Quote_Line__c=line.id,BOM_Line_Number__c='1',Product__c=p.Id);
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert soline;
        
        B2B_Order_Line__c b2bline = new B2B_Order_Line__c();
        b2bline.B2B_Order__c=b2border.id;
        b2bline.B2B_Order_Line__c='3456';
        b2bline.B2B_Order_Line_Status__c='Validation Success';
        b2bline.B2B_Order_Line_Error_Messages__c='';
        b2bline.B2B_Quote_Line__c=string.valueof(line.id).substring(0,15);
        b2bline.Part_Number__c='Test';
        b2bline.Quantity__c=10;
        b2bline.Net_Price__c=1000;
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bline;
        
        B2B_Order_Line__c b2bline1 = new B2B_Order_Line__c();
        b2bline1.B2B_Order__c=b2border.id;
        b2bline1.B2B_Order_Line__c='3456';
        b2bline1.B2B_Order_Line_Status__c='Validation Success';
        b2bline1.B2B_Order_Line_Error_Messages__c='';
        b2bline1.B2B_Quote_Line__c=string.valueof(line1.id).substring(0,15);
        b2bline1.Part_Number__c='Test1';
        b2bline1.Quantity__c=10;
        b2bline1.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bline1;
        
        B2B_Order_Line__c b2bline2 = new B2B_Order_Line__c();
        b2bline2.B2B_Order__c=b2border.id;
        b2bline2.B2B_Order_Line__c='3456';
        b2bline2.B2B_Order_Line_Status__c='Validation Success';
        b2bline2.B2B_Order_Line_Error_Messages__c='';
        b2bline2.B2B_Quote_Line__c=string.valueof(line2.id).substring(0,15);
        b2bline2.Part_Number__c='test2';
        b2bline2.Quantity__c=10;
        b2bline2.Net_Price__c=1000;
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bline2;
        
        b2border.B2B_Order_Status__c='New';
        b2border.B2B_Order_Type__c='Revenue';
        b2border.Bill_To_Address_1__c='test';
        b2border.Ship_To_Address_1__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.Total_Lines_Received__c=3;
        b2border.B2B_Partner_Purchase_Order_Amount__c=1000;
        utility.runDupRecTrigger=true;
        recursviveClass.recursiveTestCls = false;
        update b2border;
        
        /*b2bline.Part_Number__c='test';
        b2bline1.Part_Number__c='test1';
        b2bline2.Part_Number__c='test2';
        update b2bline;
        update b2bline1;
        update b2bline2;
        b2border.Bill_To_Address_1__c='test';
        update b2border;*/
    Test.stopTest();
    }

    static testMethod void myUnitTest4()
    {
        TestUtils.enable_isRunningTest = false;
        Account a = new Account(Name='Test');
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        opp.Type='New Business';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        
        insert opp;
        
        
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test');
        p.ProductCode='pro';
        p.BOM_Level__c=1;
        p.Separate_Order_Line_Per_Unit__c=false;
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert p;
        
        Product2 p1 = new Product2(Name='Test1',IsActive=true,Productcode='Test1');
        p1.ProductCode='pro1';
        p1.BOM_Level__c=2;
        p1.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert p1;
        
        RecordType recty = [select name from RecordType where name ='Internal Quote'];
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        quote.RecordTypeId=recty.id;
       // utility.runDupRecTrigger=false;
       quote.SBQQ__Type__c='Change Order';
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert quote;
        
        quote = [select id, name from SBQQ__Quote__c where id=:quote.id];
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.SBQQ__NetPrice__c=100;
        line.SBQQ__RequiredBy__c=null;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 10;
        line.SBQQ__PackageProductCode__c='pro';
        line.SBQQ__ProductOption__c=null;
        line.SBQQ__Renewal__c=true;
        line.SBQQ__OptionType__c='Accessory';
        line.SBQQ__Existing__c=false;
        //line.BOM_Level__c=1;
        //line.SBQQ__NetTotal__c=1000;
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line;
        
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 1000;
        line1.SBQQ__RequiredBy__c=line.id;
        line1.SBQQ__NetPrice__c=100;
        line1.BOM_Line_Number__c='1.1';
        line1.SBQQ__Quantity__c = 10;
        line1.SBQQ__PackageProductCode__c='pro1';
        line1.SBQQ__ProductOption__c=null;
        line1.SBQQ__Renewal__c=true;
        line1.SBQQ__OptionType__c='Accessory';
        line1.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line1;
        
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line2.SBQQ__ListPrice__c = 1000;
        line2.SBQQ__RequiredBy__c=line1.id;
        line2.SBQQ__NetPrice__c=100;
        line2.BOM_Line_Number__c='1.1.1';
        line2.SBQQ__Quantity__c = 10;
        line2.SBQQ__PackageProductCode__c='pro1';
        line2.SBQQ__ProductOption__c=null;
        line2.SBQQ__Renewal__c=true;
        line2.SBQQ__OptionType__c='Accessory';
        line2.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line2;
        
        B2B_Partner__c b2bpart = new B2B_Partner__c();
        b2bpart.B2B_Partner_Id__c='123456';
        b2bpart.B2B_Partner_Name__c='test partner';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bpart;
        Test.startTest();
        B2B_Order__c b2border = new B2B_Order__c();
        b2border.B2B_Partner__c=b2bpart.id;
        b2border.B2B_NMBL_Quote_Number__c=''+string.valueof(quote.name);
        b2border.B2B_Partner_Purchase_Order__c='test';
        b2border.B2B_Partner_Purchase_Order_Date__c=date.today();
        b2border.B2B_Partner_Purchase_Order_Amount__c=100;
        b2border.B2B_Order_Type__c='';
        b2border.Bill_To_Contact_Name__c='test';
        b2border.Bill_To_Address_1__c='';
        b2border.Bill_To_City__c='test';
        b2border.Bill_To_Zip_Postal_Code__c='123456';
        b2border.Bill_To_State__c='test';
        b2border.Bill_To_Company__c='test';
        b2border.Bill_To_Contact_Email__c='test@test.com';
        b2border.Ship_To_Contact_Name__c='test';
        b2border.Ship_To_Address_1__c='';
        b2border.Ship_To_City__c='test';
        b2border.Ship_To_Zip_Postal_Code__c='123456';
        b2border.Ship_To_State__c='test';
        b2border.Ship_To_Contact_Email__c='test@test.com';
        b2border.End_Customer_Contact_Name__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.End_Customer_City__c='test';
        b2border.End_Customer_Zip_Postal_Code__c='123456';
        b2border.End_Customer_State__c='test';
        b2border.Shipment_Service_Level__c='';
        b2border.End_Customer_Company__c='test';
        b2border.Install_Location__c='test';
        b2border.Currency__c='AUD';
        b2border.Requested_Ship_Date__c=date.today();
        b2border.Planned_Install_Date__c=date.today();
        b2border.Total_Lines_Received__c=1;
        b2border.B2B_Order_Status__c='Validation Success';
        b2border.Ship_To_Company__c='test';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2border;
       
       
        
        quote.SBQQ__Primary__c=false;
        //quote.SBQQ__Status__c='Approved';
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        update quote;
        
        B2B_Order_Line__c b2bline = new B2B_Order_Line__c();
        b2bline.B2B_Order__c=b2border.id;
        b2bline.B2B_Order_Line__c='3456';
        b2bline.B2B_Order_Line_Status__c='Validation Success';
        b2bline.B2B_Order_Line_Error_Messages__c='';
        b2bline.B2B_Quote_Line__c=string.valueof(line.id).substring(0,15);
        b2bline.Part_Number__c='pro';
        b2bline.Quantity__c=11;
        b2bline.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bline;
        
        B2B_Order_Line__c b2bline1 = new B2B_Order_Line__c();
        b2bline1.B2B_Order__c=b2border.id;
        b2bline1.B2B_Order_Line__c='3456';
        b2bline1.B2B_Order_Line_Status__c='Validation Success';
        b2bline1.B2B_Order_Line_Error_Messages__c='';
        b2bline1.B2B_Quote_Line__c=string.valueof(line1.id).substring(0,15);
        b2bline1.Part_Number__c='pro1';
        b2bline1.Quantity__c=11;
        b2bline1.Net_Price__c=1000;
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bline1;
        
        B2B_Order_Line__c b2bline2 = new B2B_Order_Line__c();
        b2bline2.B2B_Order__c=b2border.id;
        b2bline2.B2B_Order_Line__c='3456';
        b2bline2.B2B_Order_Line_Status__c='Validation Success';
        b2bline2.B2B_Order_Line_Error_Messages__c='';
        b2bline2.B2B_Quote_Line__c=string.valueof(line2.id).substring(0,15);
        b2bline2.Part_Number__c='pro1';
        b2bline2.Quantity__c=9;
        b2bline2.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bline2;
        
        b2border.B2B_Order_Status__c='New';
        b2border.B2B_Order_Type__c=null;
        b2border.Bill_To_Address_1__c='test';
        b2border.Ship_To_Address_1__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.Total_Lines_Received__c=3;
        b2border.B2B_Partner_Purchase_Order_Amount__c=1000;
         utility.runDupRecTrigger=true;
        recursviveClass.recursiveTestCls = false;
        update b2border;
        p.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        update p;

        /*list<SBQQ__QuoteLine__c> qllist = new list<SBQQ__QuoteLine__c>();
        line.SBQQ__OptionType__c='Accessory';
        qllist.add(line);
        line1.SBQQ__OptionType__c='Accessory';
        qllist.add(line1);
        line2.SBQQ__OptionType__c='Accessory';
       
        qllist.add(line2);*/
        // utility.runDupRecTrigger=false;
        //update qllist;
       /* b2border.B2B_Order_Status__c='New';
        utility.runDupRecTrigger=false;
        update b2border;
        delete b2bline;
        delete b2bline1;
        delete b2bline2;
        b2border.B2B_Order_Status__c='';
            update b2border;*/
        Test.stopTest();
    }
      static testMethod void myUnitTest9s()
    {
        TestUtils.enable_isRunningTest = true;
        Account a = new Account(Name='Test');
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        opp.Type='New Business';
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        
        insert opp;
        
        
        Product2 p1 = new Product2(Name='Test1',IsActive=true,Productcode='Test1');
        p1.ProductCode='pro1';
        p1.BOM_Level__c=2;
        p1.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert p1;
        
       

        RecordType recty = [select name from RecordType where name ='Internal Quote'];
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        quote.RecordTypeId=recty.id;
               quote.SBQQ__Type__c='Change Order';
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert quote;
        
        quote = [select id, name from SBQQ__Quote__c where id=:quote.id];
        
       
        Test.startTest();
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 1000;
        //line1.SBQQ__RequiredBy__c=line.id;
        line1.SBQQ__NetPrice__c=100;
        line1.BOM_Line_Number__c='2';
        line1.SBQQ__Quantity__c = 10;
        line1.SBQQ__PackageProductCode__c='pro1';
        line1.SBQQ__ProductOption__c=null;
        line1.SBQQ__Renewal__c=true;
        line1.SBQQ__OptionType__c='Component';
        line1.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert line1;
        
        
        
        B2B_Partner__c b2bpart = new B2B_Partner__c();
        b2bpart.B2B_Partner_Id__c='123456';
        b2bpart.B2B_Partner_Name__c='test partner';
       utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2bpart;
        
        B2B_Order__c b2border = new B2B_Order__c();
        b2border.B2B_Partner__c=b2bpart.id;
        b2border.B2B_NMBL_Quote_Number__c = quote.name;
        b2border.B2B_Partner_Purchase_Order__c='test';
        b2border.B2B_Partner_Purchase_Order_Date__c=date.today();
        b2border.B2B_Partner_Purchase_Order_Amount__c=100;
        b2border.B2B_Order_Type__c='';
        b2border.Bill_To_Contact_Name__c=null;
        b2border.Bill_To_Address_1__c=null;
        b2border.Bill_To_City__c=null;
        b2border.Bill_To_Zip_Postal_Code__c=null;
        b2border.Bill_To_State__c=null;
        b2border.Bill_To_Company__c='test';
        b2border.Bill_To_Contact_Email__c='test@test.com';
        b2border.Ship_To_Contact_Name__c='test';
        b2border.Ship_To_Address_1__c='';
        b2border.Ship_To_City__c='';
        b2border.Ship_To_Zip_Postal_Code__c='';
        b2border.Ship_To_State__c='';
        b2border.Ship_To_Contact_Email__c='test@test.com';
        b2border.End_Customer_Contact_Name__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.End_Customer_City__c='test';
        b2border.End_Customer_Zip_Postal_Code__c='123456';
        b2border.End_Customer_State__c='test';
        b2border.Shipment_Service_Level__c='';
        b2border.End_Customer_Company__c='test';
        b2border.Install_Location__c='test';
        b2border.Currency__c='USD';
        b2border.Requested_Ship_Date__c=date.today();
        b2border.Planned_Install_Date__c=date.today();
        b2border.Total_Lines_Received__c=1;
        b2border.B2B_Order_Status__c='Validation Success';
        b2border.Ship_To_Company__c='test';
        utility.runDupRecTrigger=false;
        recursviveClass.recursiveTestCls = false;
        insert b2border;
       

        

        
        b2border.B2B_Order_Status__c='New';
        b2border.B2B_Order_Type__c='Revenue';
        b2border.Bill_To_Address_1__c='test';
        b2border.Ship_To_Address_1__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.Total_Lines_Received__c=3;
        b2border.B2B_Partner_Purchase_Order_Amount__c=1000;
         utility.runDupRecTrigger=true;
        recursviveClass.recursiveTestCls = false;
        update b2border;

        Test.stopTest();
    }
    
    static testMethod void myUnitTest2s()
    {
        TestUtils.enable_isRunningTest = true;
        Account a = new Account(Name='Test');
        utility.runDupRecTrigger=false;
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        opp.Type='New Business';
        utility.runDupRecTrigger=false;
        
        insert opp;
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='SLA-NBD');
        p.ProductCode='SLA-NBD';
        p.BOM_Level__c=1;
        p.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        insert p;
        
        Product2 p1 = new Product2(Name='Test1',IsActive=true,Productcode='Test1');
        p1.ProductCode='pro1';
        p1.BOM_Level__c=2;
        p1.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        insert p1;
        
        Product2 p2 = new Product2(Name='ADFA',IsActive=true,Productcode='ADFA');
        p1.ProductCode='ADFA';
        p1.BOM_Level__c=1;
        p1.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        //insert p2;

        RecordType recty = [select name from RecordType where name ='Internal Quote'];
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        quote.RecordTypeId=recty.id;
               quote.SBQQ__Type__c='Change Order';
       // utility.runDupRecTrigger=false;
        insert quote;
        
        quote = [select id, name from SBQQ__Quote__c where id=:quote.id];
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.SBQQ__NetPrice__c=100;
        line.SBQQ__RequiredBy__c=null;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 10;
        line.SBQQ__PackageProductCode__c='pro';
        line.SBQQ__ProductOption__c=null;
        line.SBQQ__Renewal__c=true;
        line.SBQQ__OptionType__c='Component';
        line.SBQQ__Existing__c=false;
        //line.BOM_Level__c=1;
        //line.SBQQ__NetTotal__c=1000;
       // utility.runDupRecTrigger=false;
        insert line;
        
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 1000;
        line1.SBQQ__RequiredBy__c=line.id;
        line1.SBQQ__NetPrice__c=100;
        line1.BOM_Line_Number__c='2';
        line1.SBQQ__Quantity__c = 10;
        line1.SBQQ__PackageProductCode__c='pro1';
        line1.SBQQ__ProductOption__c=null;
        line1.SBQQ__Renewal__c=true;
        line1.SBQQ__OptionType__c='Component';
        line1.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        //utility.runDupRecTrigger=false;
        insert line1;
        
        
        B2B_Partner__c b2bpart = new B2B_Partner__c();
        b2bpart.B2B_Partner_Id__c='123456';
        b2bpart.B2B_Partner_Name__c='test partner';
        utility.runDupRecTrigger=false;
        insert b2bpart;
        Test.startTest();
        B2B_Order__c b2border = new B2B_Order__c();
        b2border.B2B_Partner__c=b2bpart.id;
        b2border.B2B_NMBL_Quote_Number__c = quote.name;
        b2border.B2B_Partner_Purchase_Order__c='test';
        b2border.B2B_Partner_Purchase_Order_Date__c=date.today();
        b2border.B2B_Partner_Purchase_Order_Amount__c=100;
        b2border.B2B_Order_Type__c='';
        b2border.Bill_To_Contact_Name__c=null;
        b2border.Bill_To_Address_1__c=null;
        b2border.Bill_To_City__c=null;
        b2border.Bill_To_Zip_Postal_Code__c=null;
        b2border.Bill_To_State__c=null;
        b2border.Bill_To_Company__c='test';
        b2border.Bill_To_Contact_Email__c='test@test.com';
        b2border.Ship_To_Contact_Name__c='test';
        b2border.Ship_To_Address_1__c='';
        b2border.Ship_To_City__c='';
        b2border.Ship_To_Zip_Postal_Code__c='';
        b2border.Ship_To_State__c='';
        b2border.Ship_To_Contact_Email__c='test@test.com';
        b2border.End_Customer_Contact_Name__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.End_Customer_City__c='test';
        b2border.End_Customer_Zip_Postal_Code__c='123456';
        b2border.End_Customer_State__c='test';
        b2border.Shipment_Service_Level__c='';
        b2border.End_Customer_Company__c='test';
        b2border.Install_Location__c='test';
        b2border.Currency__c='USD';
        b2border.Requested_Ship_Date__c=date.today();
        b2border.Planned_Install_Date__c=date.today();
        b2border.Total_Lines_Received__c=1;
        b2border.B2B_Order_Status__c='Validation Success';
        b2border.Ship_To_Company__c='test';
        utility.runDupRecTrigger=false;
        insert b2border;
       
       
        
        /*quote.SBQQ__Primary__c=true;
        quote.SBQQ__Status__c='Approved';
        utility.runDupRecTrigger=false;
        update quote;*/
        
        B2B_Order_Line__c b2bline = new B2B_Order_Line__c();
        b2bline.B2B_Order__c=b2border.id;
        b2bline.B2B_Order_Line__c='3456';
        b2bline.B2B_Order_Line_Status__c='Validation Success';
        b2bline.B2B_Order_Line_Error_Messages__c='';
        b2bline.B2B_Quote_Line__c=string.valueof(line.id).substring(0,15);
        b2bline.Part_Number__c='pro';
        b2bline.Quantity__c=10;
        b2bline.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        insert b2bline;
        
        B2B_Order_Line__c b2bline1 = new B2B_Order_Line__c();
        b2bline1.B2B_Order__c=b2border.id;
        b2bline1.B2B_Order_Line__c='3456';
        b2bline1.B2B_Order_Line_Status__c='Validation Success';
        b2bline1.B2B_Order_Line_Error_Messages__c='';
        b2bline1.B2B_Quote_Line__c=string.valueof(line1.id).substring(0,15);
        b2bline1.Part_Number__c='pro1';
        b2bline1.Quantity__c=10;
        b2bline1.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        insert b2bline1;
        
        
        
        b2border.B2B_Order_Status__c='New';
        b2border.B2B_Order_Type__c='Revenue';
        b2border.Bill_To_Address_1__c='test';
        b2border.Ship_To_Address_1__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.Total_Lines_Received__c=3;
        b2border.B2B_Partner_Purchase_Order_Amount__c=1000;
         utility.runDupRecTrigger=true;
        update b2border;
         /*p.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        update p;

       list<SBQQ__QuoteLine__c> qllist = new list<SBQQ__QuoteLine__c>();
        line.SBQQ__OptionType__c='Accessory';
        qllist.add(line);
        line1.SBQQ__OptionType__c='Accessory';
        qllist.add(line1);
        line2.SBQQ__OptionType__c='Accessory';
       
        qllist.add(line2);
         utility.runDupRecTrigger=false;
        update qllist;
        b2border.B2B_Order_Status__c='New';
        utility.runDupRecTrigger=false;
        update b2border;*/
        Test.stopTest();
    }
    
   
    static testMethod void myUnitTest4s()
    {
        TestUtils.enable_isRunningTest = false;
        Account a = new Account(Name='Test');
        utility.runDupRecTrigger=false;
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        opp.Type='New Business';
        utility.runDupRecTrigger=false;
        
        insert opp;
        
        
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test');
        p.ProductCode='pro';
        p.BOM_Level__c=1;
        p.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        insert p;
        
        Product2 p1 = new Product2(Name='Test1',IsActive=true,Productcode='Test1');
        p1.ProductCode='pro1';
        p1.BOM_Level__c=2;
        p1.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        insert p1;
        
        RecordType recty = [select name from RecordType where name ='Internal Quote'];
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        quote.RecordTypeId=recty.id;
       // utility.runDupRecTrigger=false;
       quote.SBQQ__Type__c='Change Order';
        insert quote;
        
        quote = [select id, name from SBQQ__Quote__c where id=:quote.id];
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.SBQQ__NetPrice__c=100;
        line.SBQQ__RequiredBy__c=null;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 10;
        line.SBQQ__PackageProductCode__c='pro';
        line.SBQQ__ProductOption__c=null;
        line.SBQQ__Renewal__c=true;
        line.SBQQ__OptionType__c='Accessory';
        line.SBQQ__Existing__c=false;
        //line.BOM_Level__c=1;
        //line.SBQQ__NetTotal__c=1000;
       // utility.runDupRecTrigger=false;
        insert line;
        
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 1000;
        line1.SBQQ__RequiredBy__c=line.id;
        line1.SBQQ__NetPrice__c=100;
        line1.BOM_Line_Number__c='1.1';
        line1.SBQQ__Quantity__c = 10;
        line1.SBQQ__PackageProductCode__c='pro1';
        line1.SBQQ__ProductOption__c=null;
        line1.SBQQ__Renewal__c=true;
        line1.SBQQ__OptionType__c='Accessory';
        line1.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        //utility.runDupRecTrigger=false;
        insert line1;
        
        
        
        B2B_Partner__c b2bpart = new B2B_Partner__c();
        b2bpart.B2B_Partner_Id__c='123456';
        b2bpart.B2B_Partner_Name__c='test partner';
        utility.runDupRecTrigger=false;
        insert b2bpart;
        Test.startTest();
        B2B_Order__c b2border = new B2B_Order__c();
        b2border.B2B_Partner__c=b2bpart.id;
        b2border.B2B_NMBL_Quote_Number__c=''+string.valueof(quote.name);
        b2border.B2B_Partner_Purchase_Order__c='test';
        b2border.B2B_Partner_Purchase_Order_Date__c=date.today();
        b2border.B2B_Partner_Purchase_Order_Amount__c=100;
        b2border.B2B_Order_Type__c='';
        b2border.Bill_To_Contact_Name__c='test';
        b2border.Bill_To_Address_1__c='';
        b2border.Bill_To_City__c='test';
        b2border.Bill_To_Zip_Postal_Code__c='123456';
        b2border.Bill_To_State__c='test';
        b2border.Bill_To_Company__c='test';
        b2border.Bill_To_Contact_Email__c='test@test.com';
        b2border.Ship_To_Contact_Name__c='test';
        b2border.Ship_To_Address_1__c='';
        b2border.Ship_To_City__c='test';
        b2border.Ship_To_Zip_Postal_Code__c='123456';
        b2border.Ship_To_State__c='test';
        b2border.Ship_To_Contact_Email__c='test@test.com';
        b2border.End_Customer_Contact_Name__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.End_Customer_City__c='test';
        b2border.End_Customer_Zip_Postal_Code__c='123456';
        b2border.End_Customer_State__c='test';
        b2border.Shipment_Service_Level__c='';
        b2border.End_Customer_Company__c='test';
        b2border.Install_Location__c='test';
        b2border.Currency__c='AUD';
        b2border.Requested_Ship_Date__c=date.today();
        b2border.Planned_Install_Date__c=date.today();
        b2border.Total_Lines_Received__c=1;
        b2border.B2B_Order_Status__c='Validation Success';
        b2border.Ship_To_Company__c='test';
        utility.runDupRecTrigger=false;
        insert b2border;
       
       
        
        quote.SBQQ__Primary__c=false;
        //quote.SBQQ__Status__c='Approved';
        utility.runDupRecTrigger=false;
        update quote;
        
        B2B_Order_Line__c b2bline = new B2B_Order_Line__c();
        b2bline.B2B_Order__c=b2border.id;
        b2bline.B2B_Order_Line__c='3456';
        b2bline.B2B_Order_Line_Status__c='Validation Success';
        b2bline.B2B_Order_Line_Error_Messages__c='';
        b2bline.B2B_Quote_Line__c=string.valueof(line.id).substring(0,15);
        b2bline.Part_Number__c='pro';
        b2bline.Quantity__c=11;
        b2bline.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        insert b2bline;
        
        B2B_Order_Line__c b2bline1 = new B2B_Order_Line__c();
        b2bline1.B2B_Order__c=b2border.id;
        b2bline1.B2B_Order_Line__c='3456';
        b2bline1.B2B_Order_Line_Status__c='Validation Success';
        b2bline1.B2B_Order_Line_Error_Messages__c='';
        b2bline1.B2B_Quote_Line__c=string.valueof(line1.id).substring(0,15);
        b2bline1.Part_Number__c='pro1';
        b2bline1.Quantity__c=11;
        b2bline1.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        insert b2bline1;
        
        
        
        b2border.B2B_Order_Status__c='New';
        b2border.B2B_Order_Type__c=null;
        b2border.Bill_To_Address_1__c='test';
        b2border.Ship_To_Address_1__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.Total_Lines_Received__c=3;
        b2border.B2B_Partner_Purchase_Order_Amount__c=1000;
         utility.runDupRecTrigger=true;
        update b2border;
        p.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        update p;

        /*list<SBQQ__QuoteLine__c> qllist = new list<SBQQ__QuoteLine__c>();
        line.SBQQ__OptionType__c='Accessory';
        qllist.add(line);
        line1.SBQQ__OptionType__c='Accessory';
        qllist.add(line1);
        line2.SBQQ__OptionType__c='Accessory';
       
        qllist.add(line2);*/
         utility.runDupRecTrigger=false;
        //update qllist;
        b2border.B2B_Order_Status__c='New';
        utility.runDupRecTrigger=false;
        update b2border;
        delete b2bline;
        delete b2bline1;
        //delete b2bline2;
        b2border.B2B_Order_Status__c='';
            update b2border;
        Test.stopTest();
    }
      static testMethod void myUnitTest8s()
    {
        TestUtils.enable_isRunningTest = true;
        Account a = new Account(Name='Test');
        utility.runDupRecTrigger=false;
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        opp.Type='New Business';
        utility.runDupRecTrigger=false;
        
        insert opp;
        
        
        Product2 p1 = new Product2(Name='Test1',IsActive=true,Productcode='Test1');
        p1.ProductCode='pro1';
        p1.BOM_Level__c=2;
        p1.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        insert p1;
        
       

        RecordType recty = [select name from RecordType where name ='Internal Quote'];
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        quote.RecordTypeId=recty.id;
               quote.SBQQ__Type__c='Change Order';
       // utility.runDupRecTrigger=false;
        insert quote;
        
        quote = [select id, name from SBQQ__Quote__c where id=:quote.id];
        
       
        
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 1000;
        //line1.SBQQ__RequiredBy__c=line.id;
        line1.SBQQ__NetPrice__c=100;
        line1.BOM_Line_Number__c='2';
        line1.SBQQ__Quantity__c = 10;
        line1.SBQQ__PackageProductCode__c='pro1';
        line1.SBQQ__ProductOption__c=null;
        line1.SBQQ__Renewal__c=true;
        line1.SBQQ__OptionType__c='Component';
        line1.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        //utility.runDupRecTrigger=false;
        insert line1;
        
        
        
        B2B_Partner__c b2bpart = new B2B_Partner__c();
        b2bpart.B2B_Partner_Id__c='123456';
        b2bpart.B2B_Partner_Name__c='test partner';
        utility.runDupRecTrigger=false;
        insert b2bpart;
        B2B_Order__c b2border = new B2B_Order__c();
        b2border.B2B_Partner__c=b2bpart.id;
        b2border.B2B_NMBL_Quote_Number__c = quote.name;
        b2border.B2B_Partner_Purchase_Order__c='test';
        b2border.B2B_Partner_Purchase_Order_Date__c=date.today();
        b2border.B2B_Partner_Purchase_Order_Amount__c=100;
        b2border.B2B_Order_Type__c='';
        b2border.Bill_To_Contact_Name__c=null;
        b2border.Bill_To_Address_1__c=null;
        b2border.Bill_To_City__c=null;
        b2border.Bill_To_Zip_Postal_Code__c=null;
        b2border.Bill_To_State__c=null;
        b2border.Bill_To_Company__c='test';
        b2border.Bill_To_Contact_Email__c='test@test.com';
        b2border.Ship_To_Contact_Name__c='test';
        b2border.Ship_To_Address_1__c='';
        b2border.Ship_To_City__c='';
        b2border.Ship_To_Zip_Postal_Code__c='';
        b2border.Ship_To_State__c='';
        b2border.Ship_To_Contact_Email__c='test@test.com';
        b2border.End_Customer_Contact_Name__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.End_Customer_City__c='test';
        b2border.End_Customer_Zip_Postal_Code__c='123456';
        b2border.End_Customer_State__c='test';
        b2border.Shipment_Service_Level__c='';
        b2border.End_Customer_Company__c='test';
        b2border.Install_Location__c='test';
        b2border.Currency__c='USD';
        b2border.Requested_Ship_Date__c=date.today();
        b2border.Planned_Install_Date__c=date.today();
        b2border.Total_Lines_Received__c=1;
        b2border.B2B_Order_Status__c='Validation Success';
        b2border.Ship_To_Company__c='test';
        utility.runDupRecTrigger=false;
        insert b2border;
       
       
        
        quote.SBQQ__Primary__c=true;
        quote.SBQQ__Status__c='Approved';
        utility.runDupRecTrigger=false;
        update quote;
        
       
                Test.startTest();

        B2B_Order_Line__c b2bline1 = new B2B_Order_Line__c();
        b2bline1.B2B_Order__c=b2border.id;
        b2bline1.B2B_Order_Line__c='3456';
        b2bline1.B2B_Order_Line_Status__c='Validation Success';
        b2bline1.B2B_Order_Line_Error_Messages__c='';
        b2bline1.B2B_Quote_Line__c=string.valueof(line1.id).substring(0,15);
        b2bline1.Part_Number__c='pro1';
        b2bline1.Quantity__c=10;
        b2bline1.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        insert b2bline1;
        

        
        b2border.B2B_Order_Status__c='New';
        b2border.B2B_Order_Type__c='Revenue';
        b2border.Bill_To_Address_1__c='test';
        b2border.Ship_To_Address_1__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.Total_Lines_Received__c=3;
        b2border.B2B_Partner_Purchase_Order_Amount__c=1000;
         utility.runDupRecTrigger=true;
        update b2border;
        //p.Separate_Order_Line_Per_Unit__c=false;
        //utility.runDupRecTrigger=false;
        //update p;

        list<SBQQ__QuoteLine__c> qllist = new list<SBQQ__QuoteLine__c>();
        //line.SBQQ__OptionType__c='Accessory';
        //qllist.add(line);
        line1.SBQQ__OptionType__c='Accessory';
        qllist.add(line1);
        //line2.SBQQ__OptionType__c='Accessory';
       
        //qllist.add(line2);
         utility.runDupRecTrigger=false;
        update qllist;
        b2border.B2B_Order_Status__c='New';
        utility.runDupRecTrigger=false;
        update b2border;
        Test.stopTest();
    }
    
    static testMethod void myUnitTest2ss()
    {
        TestUtils.enable_isRunningTest = true;
        Account a = new Account(Name='Test');
        utility.runDupRecTrigger=false;
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        opp.Type='New Business';
        utility.runDupRecTrigger=false;
        insert opp;
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='SLA-NBD');
        p.ProductCode='SLA-NBD';
        p.BOM_Level__c=1;
        p.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        insert p;
        
        Product2 p1 = new Product2(Name='Test1',IsActive=true,Productcode='Test1');
        p1.ProductCode='pro1';
        p1.BOM_Level__c=2;
        p1.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        insert p1;
        
        Product2 p2 = new Product2(Name='ADFA',IsActive=true,Productcode='ADFA');
        p1.ProductCode='ADFA';
        p1.BOM_Level__c=1;
        p1.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        //insert p2;

        RecordType recty = [select name from RecordType where name ='Internal Quote'];
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        quote.RecordTypeId=recty.id;
               quote.SBQQ__Type__c='Change Order';
       // utility.runDupRecTrigger=false;
        insert quote;
        
        quote = [select id, name from SBQQ__Quote__c where id=:quote.id];
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.SBQQ__NetPrice__c=100;
        line.SBQQ__RequiredBy__c=null;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 10;
        line.SBQQ__PackageProductCode__c='pro';
        line.SBQQ__ProductOption__c=null;
        line.SBQQ__Renewal__c=true;
        line.SBQQ__OptionType__c='Accessory';
        line.SBQQ__Existing__c=false;
        //line.BOM_Level__c=1;
        //line.SBQQ__NetTotal__c=1000;
       // utility.runDupRecTrigger=false;
        insert line;
        
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 1000;
        line1.SBQQ__RequiredBy__c=line.id;
        line1.SBQQ__NetPrice__c=100;
        line1.BOM_Line_Number__c='2';
        line1.SBQQ__Quantity__c = 10;
        line1.SBQQ__PackageProductCode__c='pro1';
        line1.SBQQ__ProductOption__c=null;
        line1.SBQQ__Renewal__c=true;
        line1.SBQQ__OptionType__c='Accessory';
        line1.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        //utility.runDupRecTrigger=false;
        insert line1;

        
        
        B2B_Partner__c b2bpart = new B2B_Partner__c();
        b2bpart.B2B_Partner_Id__c='123456';
        b2bpart.B2B_Partner_Name__c='test partner';
        utility.runDupRecTrigger=false;
        insert b2bpart;
        Test.startTest();
        B2B_Order__c b2border = new B2B_Order__c();
        b2border.B2B_Partner__c=b2bpart.id;
        b2border.B2B_NMBL_Quote_Number__c = quote.name;
        b2border.B2B_Partner_Purchase_Order__c='test';
        b2border.B2B_Partner_Purchase_Order_Date__c=date.today();
        b2border.B2B_Partner_Purchase_Order_Amount__c=100;
        b2border.B2B_Order_Type__c='';
        b2border.Bill_To_Contact_Name__c=null;
        b2border.Bill_To_Address_1__c=null;
        b2border.Bill_To_City__c=null;
        b2border.Bill_To_Zip_Postal_Code__c=null;
        b2border.Bill_To_State__c=null;
        b2border.Bill_To_Company__c='test';
        b2border.Bill_To_Contact_Email__c='test@test.com';
        b2border.Ship_To_Contact_Name__c='test';
        b2border.Ship_To_Address_1__c='';
        b2border.Ship_To_City__c='';
        b2border.Ship_To_Zip_Postal_Code__c='';
        b2border.Ship_To_State__c='';
        b2border.Ship_To_Contact_Email__c='test@test.com';
        b2border.End_Customer_Contact_Name__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.End_Customer_City__c='test';
        b2border.End_Customer_Zip_Postal_Code__c='123456';
        b2border.End_Customer_State__c='test';
        b2border.Shipment_Service_Level__c='';
        b2border.End_Customer_Company__c='test';
        b2border.Install_Location__c='test';
        b2border.Currency__c='USD';
        b2border.Requested_Ship_Date__c=date.today();
        b2border.Planned_Install_Date__c=date.today();
        b2border.Total_Lines_Received__c=1;
        b2border.B2B_Order_Status__c='Validation Success';
        b2border.Ship_To_Company__c='test';
        utility.runDupRecTrigger=false;
        insert b2border;
       
       
        
        /*quote.SBQQ__Primary__c=true;
        quote.SBQQ__Status__c='Approved';
        utility.runDupRecTrigger=false;
        update quote;*/
        
        B2B_Order_Line__c b2bline = new B2B_Order_Line__c();
        b2bline.B2B_Order__c=b2border.id;
        b2bline.B2B_Order_Line__c='3456';
        b2bline.B2B_Order_Line_Status__c='Validation Success';
        b2bline.B2B_Order_Line_Error_Messages__c='';
        b2bline.B2B_Quote_Line__c=string.valueof(line.id).substring(0,15);
        b2bline.Part_Number__c='pro';
        b2bline.Quantity__c=10;
        b2bline.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        insert b2bline;
        
        B2B_Order_Line__c b2bline1 = new B2B_Order_Line__c();
        b2bline1.B2B_Order__c=b2border.id;
        b2bline1.B2B_Order_Line__c='3456';
        b2bline1.B2B_Order_Line_Status__c='Validation Success';
        b2bline1.B2B_Order_Line_Error_Messages__c='';
        b2bline1.B2B_Quote_Line__c=string.valueof(line1.id).substring(0,15);
        b2bline1.Part_Number__c='pro1';
        b2bline1.Quantity__c=10;
        b2bline1.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        insert b2bline1;
        
        
        
        b2border.B2B_Order_Status__c='New';
        b2border.B2B_Order_Type__c='Revenue';
        b2border.Bill_To_Address_1__c='test';
        b2border.Ship_To_Address_1__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.Total_Lines_Received__c=3;
        b2border.B2B_Partner_Purchase_Order_Amount__c=1000;
         utility.runDupRecTrigger=true;
        update b2border;
         /*p.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        update p;

       list<SBQQ__QuoteLine__c> qllist = new list<SBQQ__QuoteLine__c>();
        line.SBQQ__OptionType__c='Accessory';
        qllist.add(line);
        line1.SBQQ__OptionType__c='Accessory';
        qllist.add(line1);
        line2.SBQQ__OptionType__c='Accessory';
       
        qllist.add(line2);
         utility.runDupRecTrigger=false;
        update qllist;
        b2border.B2B_Order_Status__c='New';
        utility.runDupRecTrigger=false;
        update b2border;*/
        Test.stopTest();
    }
    
    static testMethod void myUnitTest2sss()
    {
          TestUtils.enable_isRunningTest = true;
        Account a = new Account(Name='Test');
        utility.runDupRecTrigger=false;
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        opp.Type='Support Renewal';
        utility.runDupRecTrigger=false;
        insert opp;
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='SLA-NBD');
        p.ProductCode='SLA-NBD';
        p.BOM_Level__c=1;
        p.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        insert p;
        
        Product2 p1 = new Product2(Name='Test1',IsActive=true,Productcode='Test1');
        p1.ProductCode='pro1';
        p1.BOM_Level__c=2;
        p1.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        insert p1;
        
        Product2 p2 = new Product2(Name='ADFA',IsActive=true,Productcode='ADFA');
        p1.ProductCode='ADFA';
        p1.BOM_Level__c=1;
        p1.Separate_Order_Line_Per_Unit__c=true;
        utility.runDupRecTrigger=false;
        //insert p2;

        RecordType recty = [select name from RecordType where name ='Internal Quote'];
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        quote.RecordTypeId=recty.id;
               quote.SBQQ__Type__c='Change Order';
       // utility.runDupRecTrigger=false;
        insert quote;
        
        quote = [select id, name from SBQQ__Quote__c where id=:quote.id];
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.SBQQ__NetPrice__c=100;
        line.SBQQ__RequiredBy__c=null;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 10;
        line.SBQQ__PackageProductCode__c='pro';
        line.SBQQ__ProductOption__c=null;
        line.SBQQ__Renewal__c=true;
        line.SBQQ__OptionType__c='Component';
        line.SBQQ__Existing__c=false;
        //line.BOM_Level__c=1;
        //line.SBQQ__NetTotal__c=1000;
       // utility.runDupRecTrigger=false;
        insert line;
        
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 1000;
        line1.SBQQ__RequiredBy__c=line.id;
        line1.SBQQ__NetPrice__c=100;
        line1.BOM_Line_Number__c='2';
        line1.SBQQ__Quantity__c = 10;
        line1.SBQQ__PackageProductCode__c='pro1';
        line1.SBQQ__ProductOption__c=null;
        line1.SBQQ__Renewal__c=true;
        line1.SBQQ__OptionType__c='Component';
        line1.SBQQ__Existing__c=false;
        //line1.BOM_Level__c=2;
        //line1.SBQQ__NetTotal__c=1000;
        //utility.runDupRecTrigger=false;
        insert line1;

        
        
        B2B_Partner__c b2bpart = new B2B_Partner__c();
        b2bpart.B2B_Partner_Id__c='123456';
        b2bpart.B2B_Partner_Name__c='test partner';
        utility.runDupRecTrigger=false;
        insert b2bpart;
        Test.startTest();
        B2B_Order__c b2border = new B2B_Order__c();
        b2border.B2B_Partner__c=b2bpart.id;
        b2border.B2B_NMBL_Quote_Number__c = quote.name;
        b2border.B2B_Partner_Purchase_Order__c='test';
        b2border.B2B_Partner_Purchase_Order_Date__c=date.today();
        b2border.B2B_Partner_Purchase_Order_Amount__c=100;
        b2border.B2B_Order_Type__c='';
        b2border.Bill_To_Contact_Name__c=null;
        b2border.Bill_To_Address_1__c=null;
        b2border.Bill_To_City__c=null;
        b2border.Bill_To_Zip_Postal_Code__c=null;
        b2border.Bill_To_State__c=null;
        b2border.Bill_To_Company__c='test';
        b2border.Bill_To_Contact_Email__c='test@test.com';
        b2border.Ship_To_Contact_Name__c='test';
        b2border.Ship_To_Address_1__c='';
        b2border.Ship_To_City__c='';
        b2border.Ship_To_Zip_Postal_Code__c='';
        b2border.Ship_To_State__c='';
        b2border.Ship_To_Contact_Email__c='test@test.com';
        b2border.End_Customer_Contact_Name__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.End_Customer_City__c='test';
        b2border.End_Customer_Zip_Postal_Code__c='123456';
        b2border.End_Customer_State__c='test';
        b2border.Shipment_Service_Level__c='';
        b2border.End_Customer_Company__c='test';
        b2border.Install_Location__c='test';
        b2border.Currency__c='USD';
        b2border.Requested_Ship_Date__c=date.today();
        b2border.Planned_Install_Date__c=date.today();
        b2border.Total_Lines_Received__c=1;
        b2border.B2B_Order_Status__c='Validation Success';
        b2border.Ship_To_Company__c='test';
        utility.runDupRecTrigger=false;
        insert b2border;
       
       
        
        /*quote.SBQQ__Primary__c=true;
        quote.SBQQ__Status__c='Approved';
        utility.runDupRecTrigger=false;
        update quote;*/
        
        B2B_Order_Line__c b2bline = new B2B_Order_Line__c();
        b2bline.B2B_Order__c=b2border.id;
        b2bline.B2B_Order_Line__c='3456';
        b2bline.B2B_Order_Line_Status__c='Validation Success';
        b2bline.B2B_Order_Line_Error_Messages__c='';
        b2bline.B2B_Quote_Line__c=string.valueof(line.id).substring(0,15);
        b2bline.Part_Number__c='pro';
        b2bline.Quantity__c=10;
        b2bline.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        insert b2bline;
        
        B2B_Order_Line__c b2bline1 = new B2B_Order_Line__c();
        b2bline1.B2B_Order__c=b2border.id;
        b2bline1.B2B_Order_Line__c='3456';
        b2bline1.B2B_Order_Line_Status__c='Validation Success';
        b2bline1.B2B_Order_Line_Error_Messages__c='';
        b2bline1.B2B_Quote_Line__c=string.valueof(line1.id).substring(0,15);
        b2bline1.Part_Number__c='pro1';
        b2bline1.Quantity__c=10;
        b2bline1.Net_Price__c=1000;
        utility.runDupRecTrigger=false;
        insert b2bline1;
        
        
        
        b2border.B2B_Order_Status__c='New';
        b2border.B2B_Order_Type__c='Revenue';
        b2border.Bill_To_Address_1__c='test';
        b2border.Ship_To_Address_1__c='test';
        b2border.End_Customer_Address_1__c='';
        b2border.Total_Lines_Received__c=3;
        b2border.B2B_Partner_Purchase_Order_Amount__c=1000;
         utility.runDupRecTrigger=true;
        update b2border;
         /*p.Separate_Order_Line_Per_Unit__c=false;
        utility.runDupRecTrigger=false;
        update p;

       list<SBQQ__QuoteLine__c> qllist = new list<SBQQ__QuoteLine__c>();
        line.SBQQ__OptionType__c='Accessory';
        qllist.add(line);
        line1.SBQQ__OptionType__c='Accessory';
        qllist.add(line1);
        line2.SBQQ__OptionType__c='Accessory';
       
        qllist.add(line2);
         utility.runDupRecTrigger=false;
        update qllist;
        b2border.B2B_Order_Status__c='New';
        utility.runDupRecTrigger=false;
        update b2border;*/
        Test.stopTest();
    }
}