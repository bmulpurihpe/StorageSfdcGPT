@isTest(seeAllData =true)
private class test_salesOrderController {

    static testMethod void myUnitTest() 
    {
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        Account a = new Account(Name='Test', BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c='OPE-0123456789');
        insert opp;
        
        Product2 p = new Product2(Name='AF5000',IsActive=true,Productcode='Test',Separate_Order_Line_Per_Unit__c=TRUE,Product_Type_2__c = 'Hardware');
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        /****/
        Product2 p1 = new Product2(Name='ES3-H42',IsActive=true,Productcode='ES3-H42',Separate_Order_Line_Per_Unit__c=TRUE,Family='Expansion Shelves',Product_Type_2__c = 'Hardware');
        insert p1;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p1.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe;
        /****/
        Product2 p2 = new Product2(Name='SP-PCORD-US-G5',IsActive=true,Productcode='SP-PCORD-US-G5',Separate_Order_Line_Per_Unit__c=TRUE, Family= 'Other (parts, spares, etc)',Product_Type_2__c = 'Power Cords');
        insert p2;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p2.Id, UnitPrice = 20000, IsActive = true, UseStandardPrice = false);
        insert pbe1;
        /*****/
        Product2 p3 = new Product2(Name='SLA-4HR-ES3',IsActive=true,Productcode='SLA-4HR-ES3',Family='Support', Separate_Order_Line_Per_Unit__c=TRUE,Product_Type_2__c = 'Support');
        insert p3;
        
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p3.Id, UnitPrice = 160000, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        /*****/
        test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true);
        insert quote;
        
        quote.SBQQ__Status__c='Approved';
        quote.SBQQ__Opportunity2__c=opp.Id;
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 1;
        insert line; //
        
        SBQQ__QuoteLine__c cline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        cline.SBQQ__RequiredBy__c=line.Id;
        cline.SBQQ__Bundled__c=true;
        cline.SBQQ__BundledQuantity__c=4;
        cline.SBQQ__ListPrice__c = 100;
        cline.BOM_Line_Number__c='1';
        cline.SBQQ__OptionType__c = 'Component';
        cline.SBQQ__Quantity__c = 6;
        //cline.Discount_Category__c='Hardware';
      //  insert cline;  //
        
        list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c cline4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p2.Id);
        cline4.SBQQ__RequiredBy__c=line.Id;
        cline4.SBQQ__Bundled__c=true;
        cline4.SBQQ__BundledQuantity__c=5;
        cline4.SBQQ__ListPrice__c = 1000;
        cline4.BOM_Line_Number__c='1';
        cline4.SBQQ__OptionType__c = 'Component';
        cline4.SBQQ__Quantity__c = 7;
       // insert cline4; //
        listQl.add(cline4);//
        
        SBQQ__QuoteLine__c cline5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p3.Id);
        cline5.SBQQ__RequiredBy__c=line.Id;
        cline5.SBQQ__Bundled__c=true;
        cline5.SBQQ__BundledQuantity__c=7;
        cline5.SBQQ__ListPrice__c = 1000;
        cline5.BOM_Line_Number__c='1';
        cline5.SBQQ__OptionType__c = 'Component';
        cline5.SBQQ__Quantity__c = 9;
       // insert cline4; //
        listQl.add(cline5);//
        
        SBQQ__QuoteLine__c cline6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline6.SBQQ__RequiredBy__c=line.Id;
        cline6.SBQQ__Bundled__c=true;
        cline6.SBQQ__BundledQuantity__c=9;
        cline6.SBQQ__ListPrice__c = 1000;
        cline6.BOM_Line_Number__c='1';
        cline6.SBQQ__OptionType__c = 'Component';
        cline6.SBQQ__Quantity__c = 10;
      //  insert cline4;//
        listQl.add(cline6);//
        
        SBQQ__QuoteLine__c cline9 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        cline9.SBQQ__RequiredBy__c=line.Id;
        cline9.SBQQ__Bundled__c=true;
        cline9.SBQQ__BundledQuantity__c=7;
        cline9.SBQQ__ListPrice__c = 1000;
        cline9.BOM_Line_Number__c='1';
        cline9.SBQQ__OptionType__c = 'Component';
        cline9.SBQQ__Quantity__c = 9;
      //  insert cline4;//
        listQl.add(cline9);//
        
        SBQQ__QuoteLine__c cline10 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p2.Id);
        cline10.SBQQ__RequiredBy__c=line.Id;
        cline10.SBQQ__Bundled__c=true;
        cline10.SBQQ__BundledQuantity__c=9;
        cline10.SBQQ__ListPrice__c = 1000;
        cline10.BOM_Line_Number__c='1';
        cline10.SBQQ__OptionType__c = 'Component';
        cline10.SBQQ__Quantity__c = 10;
    //  insert cline4; //
        listQl.add(cline10);//
        
        SBQQ__QuoteLine__c cline11 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p3.Id);
        cline11.SBQQ__RequiredBy__c=line.Id;
        cline11.SBQQ__Bundled__c=true;
        cline11.SBQQ__BundledQuantity__c=9;
        cline11.SBQQ__ListPrice__c = 1000;
        cline11.BOM_Line_Number__c='1';
        cline11.SBQQ__OptionType__c = 'Component';
        cline11.SBQQ__Quantity__c = 10;
     //   insert cline4;//
        listQl.add(cline11);//
        
        SBQQ__QuoteLine__c cline2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline2.SBQQ__RequiredBy__c=line.Id;
        cline2.SBQQ__Bundled__c=true;
        cline2.SBQQ__BundledQuantity__c=5;
        cline2.SBQQ__ListPrice__c = 1000;
        cline2.BOM_Line_Number__c='1.1';
        cline2.SBQQ__OptionType__c = 'Component';
        cline2.SBQQ__Quantity__c = 7;
      //  insert cline2;//
        listQl.add(cline2);//
        
        SBQQ__QuoteLine__c cline3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline3.SBQQ__RequiredBy__c=line.Id;
        cline3.SBQQ__Bundled__c=true;
        cline3.SBQQ__BundledQuantity__c=5;
        cline3.SBQQ__ListPrice__c = 1000;
        cline3.BOM_Line_Number__c='1.1';
        cline3.SBQQ__OptionType__c = 'Component';
        cline3.SBQQ__Quantity__c = 7;
        listQl.add(cline3);//
        
        SBQQ__QuoteLine__c cline7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline7.SBQQ__RequiredBy__c=line.Id;
        cline7.SBQQ__Bundled__c=true;
        cline7.SBQQ__BundledQuantity__c=5;
        cline7.SBQQ__ListPrice__c = 1000;
        cline7.BOM_Line_Number__c='1.1';
        cline7.SBQQ__OptionType__c = 'Component';
        cline7.SBQQ__Quantity__c = 7;
        listQl.add(cline7);//
        
        SBQQ__QuoteLine__c cline8 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline8.SBQQ__RequiredBy__c=line.Id;
        cline8.SBQQ__Bundled__c=true;
        cline8.SBQQ__BundledQuantity__c=5;
        cline8.SBQQ__ListPrice__c = 1000;
        cline8.BOM_Line_Number__c='1.1';
        cline8.SBQQ__OptionType__c = 'Component';
        cline8.SBQQ__Quantity__c = 7;
        listQl.add(cline8);//
        
        SBQQ__QuoteLine__c cline12 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline12.SBQQ__RequiredBy__c=line.Id;
        cline12.SBQQ__Bundled__c=true;
        cline12.SBQQ__BundledQuantity__c=5;
        cline12.SBQQ__ListPrice__c = 1000;
        cline12.BOM_Line_Number__c='1.1';
        cline12.SBQQ__OptionType__c = 'Component';
        cline12.SBQQ__Quantity__c = 7;
        listQl.add(cline12);//
        
        SBQQ__QuoteLine__c cline13 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline13.SBQQ__RequiredBy__c=line.Id;
        cline13.SBQQ__Bundled__c=true;
        cline13.SBQQ__BundledQuantity__c=5;
        cline13.SBQQ__ListPrice__c = 1000;
        cline13.BOM_Line_Number__c='1.1';
        cline13.SBQQ__OptionType__c = 'Component';
        cline13.SBQQ__Quantity__c = 7;
        listQl.add(cline13);//
        
        SBQQ__QuoteLine__c cline14 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline14.SBQQ__RequiredBy__c=line.Id;
        cline14.SBQQ__Bundled__c=true;
        cline14.SBQQ__BundledQuantity__c=5;
        cline14.SBQQ__ListPrice__c = 1000;
        cline14.BOM_Line_Number__c='1.1';
        cline14.SBQQ__OptionType__c = 'Component';
        cline14.SBQQ__Quantity__c = 7;
        listQl.add(cline14);//
        
        
        //insert listQl;
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
        //System.assertEquals(1, ApexPages.getMessages().size());
        
        quote.SBQQ__Status__c = 'Approved';
        update quote;
        PageReference pref = target.onOverrideNew();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assert(pref.getUrl().startsWith('/' + Sales_Order__c.sObjectType.getDescribe().getKeyPrefix() + '/e'));
        
        so.Opportunity__c = opp.Id;
        insert so;
        test.stopTest();
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
        target = new SalesOrderController(new ApexPages.StandardController(so));
        System.assert(target.lineItemRows != null); 
        System.assertEquals(1, target.lineItemRows.size());
        target.lineItemRows[0].selected = true;
        //target.lineItemRows[0].selected=true;
        pref = target.onAddLinesAFA();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assertEquals('/' + so.Id, pref.getUrl());
      //  System.assertEquals(0, [SELECT count() FROM Sales_Order_Line__c WHERE Sales_Order__c = :so.Id]);
        
    }
    

    static testMethod void myUnitTest1() 
    {
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        
        
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567891');
        insert opp;
        
        Product2 p = new Product2(Name='ADFA Gen5',IsActive=true,Productcode='ADFA-GEN5',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        
        
        List<Product2> lstproduct = new List<Product2>();
        
       
      //  test.startTest();
       
        Product2 pro=new Product2();
        pro.Name='HF20';
        Pro.Component_Code__c='HF20';
        pro.ProductCode='HF20';
        pro.Asset_Type__c='test1';
        pro.infosight_identifier__c='HF20';
        pro.HPE_SKU__C='Q8H72A';
        pro.Family='Hybrid Flash Array';
        insert pro;
        //lstProduct.add(pro);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe;
       
        Product2 pro1=new Product2();
        pro1.Name='HEAD-HDD-21TBC';
        Pro1.Component_Code__c='HEAD-HDD-21TBC';
        pro1.ProductCode='HEAD-HDD-21TBC';
        pro1.Asset_Type__c='HFA';
        pro1.infosight_identifier__c='21T';
        pro1.HPE_SKU__C='Q8B68B';
        pro1.Family='Hybrid Flash Array';
        //lstProduct.add(pro1);       
        insert pro1;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro1.Id, UnitPrice = 20000, IsActive = true, UseStandardPrice = false);
        insert pbe1;
        
        Product2 pro2=new Product2();
        pro2.Name='PCI-DEFAULTC';
        Pro2.Component_Code__c='2OBT';
        pro2.ProductCode='PCI-DEFAULTC';
        pro2.Asset_Type__c='HFA';
        pro2.infosight_identifier__c='';
        pro2.HPE_SKU__C='Q8B83B';
        pro2.Family='Hybrid Flash Array';
        //lstProduct.add(pro2); 
        insert pro2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro2.Id, UnitPrice = 160000, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        
        Product2 pro10=new Product2();
        pro10.Name='HEAD-FLC-11520GB-6C';
        pro10.Component_Code__c='M';
        pro10.ProductCode='HEAD-FLC-11520GB-6C';
        pro10.Asset_Type__c='HFA';
        pro10.infosight_identifier__c='11520F';
        pro10.HPE_SKU__C='Q8J31A';
        pro10.Family='Hybrid Flash Array';
        pro10.Array_Controller__c = 'HF40; HF60; HF60C';
        insert pro10;
        
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro10.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe3;
        
        //insert lstProduct;
        Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        quote.SBQQ__Status__c='Approved';
        quote.SBQQ__Opportunity2__c=opp.Id;
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        system.assertEquals(opp.SBQQ__PrimaryQuote__c, quote.Id);
        
        system.assertEquals('Approved',quote.SBQQ__Status__c);
       
        //system.assertEquals('Approved', opp.SBQQ__PrimaryQuote__r.sbqq__Status__c);
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 0;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 4;
        line.SBQQ__PricebookEntryId__c = pb.Id;
        line.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line.Default_Factory__c ='FGI-FLEX-M';
        insert line; //
        
        SBQQ__QuoteLine__c cline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cline.SBQQ__RequiredBy__c=line.Id;
        cline.SBQQ__Bundled__c=false;
        cline.SBQQ__BundledQuantity__c=1;
        cline.SBQQ__ListPrice__c = 186000;
        cline.BOM_Line_Number__c='1.1';
        cline.SBQQ__OptionType__c = 'Component';
        cline.SBQQ__Quantity__c = 4;
        cline.SBQQ__PricebookEntryId__c = pbe.Id;
        cline.Default_Factory__c ='FGI-FLEX-M';
        insert cline;
        
        list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c cline4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cline4.SBQQ__RequiredBy__c=line.Id;
        cline4.SBQQ__Bundled__c=false;
        cline4.SBQQ__BundledQuantity__c=1;
        cline4.SBQQ__ListPrice__c = 20000;
        cline4.BOM_Line_Number__c='1.2';
        cline4.SBQQ__OptionType__c = 'Component';
        cline4.SBQQ__Quantity__c = 4;
        cline4.SBQQ__PricebookEntryId__c = pbe1.Id;
        cline4.Default_Factory__c ='FGI-FLEX-M';
        insert cline4;           
        //listQl.add(cline4);
        
                
        SBQQ__QuoteLine__c cline5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cline5.SBQQ__RequiredBy__c=line.Id;
        cline5.SBQQ__Bundled__c=false;
        cline5.SBQQ__BundledQuantity__c=1;
        cline5.SBQQ__ListPrice__c = 160000;
        cline5.BOM_Line_Number__c='1.3';
        cline5.SBQQ__OptionType__c = 'Component';
        cline5.SBQQ__Quantity__c = 4;
        cline5.SBQQ__PricebookEntryId__c = pbe2.Id;
        cline5.Default_Factory__c ='FGI-FLEX-M';
        insert cline5; //
        //listQl.add(cline5);//
        
        SBQQ__QuoteLine__c cline6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro10.Id);
        cline6.SBQQ__RequiredBy__c=line.Id;
        cline6.SBQQ__Bundled__c=false;
        cline6.SBQQ__BundledQuantity__c=1;
        cline6.SBQQ__ListPrice__c = 152000;
        cline6.BOM_Line_Number__c='1.4';
        cline6.SBQQ__OptionType__c = 'Component';
        cline6.SBQQ__Quantity__c = 4;
        cline6.SBQQ__PricebookEntryId__c = pbe3.Id;
        cline6.Default_Factory__c ='FGI-FLEX-M';
        insert cline6;//
        //listQl.add(cline6);//
        
        SBQQ__QuoteLine__c cline9 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline9.SBQQ__RequiredBy__c=line.Id;
        cline9.SBQQ__Bundled__c=true;
        cline9.SBQQ__BundledQuantity__c=7;
        cline9.SBQQ__ListPrice__c = 1000;
        cline9.BOM_Line_Number__c='1';
        cline9.SBQQ__OptionType__c = 'Component';
        cline9.SBQQ__Quantity__c = 9;
      //  insert cline4;//
        listQl.add(cline9);//
        
        SBQQ__QuoteLine__c cline10 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline10.SBQQ__RequiredBy__c=line.Id;
        cline10.SBQQ__Bundled__c=true;
        cline10.SBQQ__BundledQuantity__c=9;
        cline10.SBQQ__ListPrice__c = 1000;
        cline10.BOM_Line_Number__c='1';
        cline10.SBQQ__OptionType__c = 'Component';
        cline10.SBQQ__Quantity__c = 10;
    //  insert cline4; //
        listQl.add(cline10);//
        
        SBQQ__QuoteLine__c cline11 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline11.SBQQ__RequiredBy__c=line.Id;
        cline11.SBQQ__Bundled__c=true;
        cline11.SBQQ__BundledQuantity__c=9;
        cline11.SBQQ__ListPrice__c = 1000;
        cline11.BOM_Line_Number__c='1';
        cline11.SBQQ__OptionType__c = 'Component';
        cline11.SBQQ__Quantity__c = 10;
     //   insert cline4;//
        listQl.add(cline11);//
        
        SBQQ__QuoteLine__c cline2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline2.SBQQ__RequiredBy__c=line.Id;
        cline2.SBQQ__Bundled__c=true;
        cline2.SBQQ__BundledQuantity__c=5;
        cline2.SBQQ__ListPrice__c = 1000;
        cline2.BOM_Line_Number__c='1.1';
        cline2.SBQQ__OptionType__c = 'Component';
        cline2.SBQQ__Quantity__c = 7;
      //  insert cline2;//
        listQl.add(cline2);//
        
        SBQQ__QuoteLine__c cline3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline3.SBQQ__RequiredBy__c=line.Id;
        cline3.SBQQ__Bundled__c=true;
        cline3.SBQQ__BundledQuantity__c=5;
        cline3.SBQQ__ListPrice__c = 1000;
        cline3.BOM_Line_Number__c='1.1';
        cline3.SBQQ__OptionType__c = 'Component';
        cline3.SBQQ__Quantity__c = 7;
        listQl.add(cline3);//
        
        SBQQ__QuoteLine__c cline7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline7.SBQQ__RequiredBy__c=line.Id;
        cline7.SBQQ__Bundled__c=true;
        cline7.SBQQ__BundledQuantity__c=5;
        cline7.SBQQ__ListPrice__c = 1000;
        cline7.BOM_Line_Number__c='1.1';
        cline7.SBQQ__OptionType__c = 'Component';
        cline7.SBQQ__Quantity__c = 7;
        listQl.add(cline7);//
        
        SBQQ__QuoteLine__c cline8 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline8.SBQQ__RequiredBy__c=line.Id;
        cline8.SBQQ__Bundled__c=true;
        cline8.SBQQ__BundledQuantity__c=5;
        cline8.SBQQ__ListPrice__c = 1000;
        cline8.BOM_Line_Number__c='1.1';
        cline8.SBQQ__OptionType__c = 'Component';
        cline8.SBQQ__Quantity__c = 7;
        listQl.add(cline8);//
        
        SBQQ__QuoteLine__c cline12 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline12.SBQQ__RequiredBy__c=line.Id;
        cline12.SBQQ__Bundled__c=true;
        cline12.SBQQ__BundledQuantity__c=5;
        cline12.SBQQ__ListPrice__c = 1000;
        cline12.BOM_Line_Number__c='1.1';
        cline12.SBQQ__OptionType__c = 'Component';
        cline12.SBQQ__Quantity__c = 7;
        listQl.add(cline12);//
        
        SBQQ__QuoteLine__c cline13 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline13.SBQQ__RequiredBy__c=line.Id;
        cline13.SBQQ__Bundled__c=true;
        cline13.SBQQ__BundledQuantity__c=5;
        cline13.SBQQ__ListPrice__c = 1000;
        cline13.BOM_Line_Number__c='1.1';
        cline13.SBQQ__OptionType__c = 'Component';
        cline13.SBQQ__Quantity__c = 7;
        listQl.add(cline13);//
        
        SBQQ__QuoteLine__c cline14 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        cline14.SBQQ__RequiredBy__c=line.Id;
        cline14.SBQQ__Bundled__c=true;
        cline14.SBQQ__BundledQuantity__c=5;
        cline14.SBQQ__ListPrice__c = 1000;
        cline14.BOM_Line_Number__c='1.1';
        cline14.SBQQ__OptionType__c = 'Component';
        cline14.SBQQ__Quantity__c = 7;
        listQl.add(cline14);//
        
        
        
       // insert listQl;
       
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        SalesOrderController.isOther = true;
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
        //System.assertEquals(1, ApexPages.getMessages().size());
        
       // quote.SBQQ__Status__c = 'Approved';
       // update quote;
        PageReference pref = target.onOverrideNew();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assert(pref.getUrl().startsWith('/' + Sales_Order__c.sObjectType.getDescribe().getKeyPrefix() + '/e'));
        
        so.Opportunity__c = opp.Id;
        insert so;
        test.stopTest();
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
        //System.assertEquals(so.Id,'a1m34000002UpXM');
        
        
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assert(target.lineItemRows != null); 
        system.assert(target.lineItemRows.size()!= null);
        System.assertEquals(4, target.lineItemRows.size());
        target.lineItemRows[0].selected = true;
        target.lineItemRows[1].selected=true;
        target.lineItemRows[2].selected=true;
        target.lineItemRows[3].selected=true;
        pref = target.onAddLinesAFA();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assertEquals('/' + so.Id, pref.getUrl());
      //  System.assertEquals(0, [SELECT count() FROM Sales_Order_Line__c WHERE Sales_Order__c = :so.Id]);
        
    }
    
    
       static testMethod void myUnitTest2() 
    {
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        
        
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567892');
        insert opp;
        
        Product2 p = new Product2(Name='All Flash Array Gen5',IsActive=true,Productcode='AFA-GEN5',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        
        
        List<Product2> lstproduct = new List<Product2>();
        
        test.startTest();
        Product2 pro=new Product2();
        pro.Name='AF20';
        Pro.Component_Code__c='AF20';
        pro.ProductCode='AF20';
        pro.Asset_Type__c='AFA2';
        pro.infosight_identifier__c='AF20';
        pro.HPE_SKU__C='Q8H72A';
        pro.Family='All Flash Array Gen5';
        insert pro;
        //lstProduct.add(pro);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe;
       
        Product2 pro1=new Product2();
        pro1.Name='AF2-SSD';
        Pro1.Component_Code__c='AF';
        pro1.ProductCode='AF2-SSD';
        pro1.Asset_Type__c='AFA2';        
        pro1.HPE_SKU__C='Q8B68B';
        pro1.Family='All Flash Array Gen5';
        //lstProduct.add(pro1);       
        insert pro1;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro1.Id, UnitPrice = 20000, IsActive = true, UseStandardPrice = false);
        insert pbe1;
        
        Product2 pro2=new Product2();
        pro2.Name='PCI-DEFAULTC';
        Pro2.Component_Code__c='2OBT';
        pro2.ProductCode='PCI-DEFAULTC';
        pro2.Asset_Type__c='AFA2';
        pro2.infosight_identifier__c='';
        pro2.HPE_SKU__C='Q8B83B';
        pro2.Family='All Flash Array Gen5';
        //lstProduct.add(pro2); 
        insert pro2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro2.Id, UnitPrice = 160000, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        
        Product2 pro10=new Product2();
        pro10.Name='AF-6TC';
        pro10.Component_Code__c='6T';
        pro10.ProductCode='AF-6T';
        pro10.Asset_Type__c='HFA';
        pro10.infosight_identifier__c='5760F';
        pro10.HPE_SKU__C='Q8J31A';
        pro10.Family='All Flash Array Gen5';
        pro10.Array_Controller__c = 'AF20';
        insert pro10;
        
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro10.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe3;
        
        Product2 pro3=new Product2();
        pro3.Name='AF-11TXC';
        pro3.Component_Code__c='11T';
        pro3.ProductCode='AF-11T';
        pro3.Asset_Type__c='AFA2';
        pro3.infosight_identifier__c='11520F';
        pro3.HPE_SKU__C='Q8J31A';
        pro3.Family='All Flash Array Gen5';
        pro3.Array_Controller__c = 'AF20';
        insert pro3;
        
        PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro3.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe4;
        
        
        //insert lstProduct;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        quote.SBQQ__Status__c='Approved';
        quote.SBQQ__Opportunity2__c=opp.Id;
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        system.assertEquals(opp.SBQQ__PrimaryQuote__c, quote.Id);
        
        system.assertEquals('Approved',quote.SBQQ__Status__c);
       
        //system.assertEquals('Approved', opp.SBQQ__PrimaryQuote__r.sbqq__Status__c);
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 0;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 4;
        line.SBQQ__PricebookEntryId__c = pb.Id;
        line.SBQQ__PackageProductCode__c = 'AF20-2OBT-17T-2';
        line.Default_Factory__c='FGI-FLEX-A';
        insert line; //
        
        SBQQ__QuoteLine__c cline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cline.SBQQ__RequiredBy__c=line.Id;
        cline.SBQQ__Bundled__c=false;
        cline.SBQQ__BundledQuantity__c=1;
        cline.SBQQ__ListPrice__c = 186000;
        cline.BOM_Line_Number__c='1.1';
        cline.SBQQ__OptionType__c = 'Component';
        cline.SBQQ__Quantity__c = 4;
        cline.SBQQ__PricebookEntryId__c = pbe.Id;
        cline.Default_Factory__c='FGI-FLEX-A';
        insert cline;
        
        list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c cline4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cline4.SBQQ__RequiredBy__c=line.Id;
        cline4.SBQQ__Bundled__c=false;
        cline4.SBQQ__BundledQuantity__c=1;
        cline4.SBQQ__ListPrice__c = 20000;
        cline4.BOM_Line_Number__c='1.2';
        cline4.SBQQ__OptionType__c = 'Component';
        cline4.SBQQ__Quantity__c = 4;
        cline4.SBQQ__PricebookEntryId__c = pbe1.Id;
        cline4.Default_Factory__c='FGI-FLEX-A';
        insert cline4;           
        //listQl.add(cline4);
        
                
        SBQQ__QuoteLine__c cline5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cline5.SBQQ__RequiredBy__c=line.Id;
        cline5.SBQQ__Bundled__c=false;
        cline5.SBQQ__BundledQuantity__c=1;
        cline5.SBQQ__ListPrice__c = 160000;
        cline5.BOM_Line_Number__c='1.3';
        cline5.SBQQ__OptionType__c = 'Component';
        cline5.SBQQ__Quantity__c = 4;
        cline5.SBQQ__PricebookEntryId__c = pbe2.Id;
        cline5.Default_Factory__c='FGI-FLEX-A';
        insert cline5; //
        //listQl.add(cline5);//
        
        SBQQ__QuoteLine__c cline6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro10.Id);
        cline6.SBQQ__RequiredBy__c=line.Id;
        cline6.SBQQ__Bundled__c=false;
        cline6.SBQQ__BundledQuantity__c=1;
        cline6.SBQQ__ListPrice__c = 152000;
        cline6.BOM_Line_Number__c='1.4';
        cline6.SBQQ__OptionType__c = 'Component';
        cline6.SBQQ__Quantity__c = 4;
        cline6.SBQQ__PricebookEntryId__c = pbe3.Id;
        cline6.Default_Factory__c='FGI-FLEX-A';
        insert cline6;//
        //listQl.add(cline6);//
        
       
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        SalesOrderController.isCamilian = true;       
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
        //System.assertEquals(1, ApexPages.getMessages().size());
        
       // quote.SBQQ__Status__c = 'Approved';
       // update quote;
        PageReference pref = target.onOverrideNew();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assert(pref.getUrl().startsWith('/' + Sales_Order__c.sObjectType.getDescribe().getKeyPrefix() + '/e'));
        
        so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
       
        
        test.stopTest();
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assert(target.lineItemRows != null); 
        system.assert(target.lineItemRows.size()!= null);
        System.assertEquals(4, target.lineItemRows.size());
        target.lineItemRows[0].selected = true;
        target.lineItemRows[1].selected=true;
        target.lineItemRows[2].selected=true;
        target.lineItemRows[3].selected=true;
        pref = target.onAddLinesAFA();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assertEquals('/' + so.Id, pref.getUrl());
      //  System.assertEquals(0, [SELECT count() FROM Sales_Order_Line__c WHERE Sales_Order__c = :so.Id]);
        
    }
static testMethod void myUnitTest3() 
    {
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        TriggerSettings__c settings = TriggerSettings__c.getInstance('OppUpdateFromSalesOrder');
        settings.Disable__c= true;
        
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',Product_List_Verified_On__c =system.today(), Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567893');
        insert opp;
        
        Product2 p = new Product2(Name='Storage Array Upgrade',IsActive=true,Productcode='NGA-UPG',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        
        
        List<Product2> lstproduct = new List<Product2>();
        
        test.startTest();
        Product2 pro=new Product2();
        pro.Name='ES1CBLG2-1M';
        Pro.Component_Code__c='';
        pro.ProductCode='ES1CBLG2-1M';
        pro.Asset_Type__c='';
        pro.infosight_identifier__c='';
        pro.HPE_SKU__C='';
        pro.Family='Other (parts, spares, etc)';
        insert pro;
        //lstProduct.add(pro);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe;
       
        Product2 pro1=new Product2();
        pro1.Name='AFS-UPGRADE';
        Pro1.Component_Code__c='';
        pro1.ProductCode='AFS-UPGRADE';
        pro1.Asset_Type__c='';        
        pro1.HPE_SKU__C='';
        pro1.Family='All Flash Shelf';
        //lstProduct.add(pro1);       
        insert pro1;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro1.Id, UnitPrice = 20000, IsActive = true, UseStandardPrice = false);
        insert pbe1;
        
        Product2 pro2=new Product2();
        pro2.Name='ES1-AFS';
        Pro2.Component_Code__c='';
        pro2.ProductCode='ES1-AFS';
        pro2.Asset_Type__c='';
        pro2.infosight_identifier__c='';
        pro2.HPE_SKU__C='';
        pro2.Family='All Flash Shelf';
        //lstProduct.add(pro2); 
        insert pro2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro2.Id, UnitPrice = 160000, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        
        Product2 pro10=new Product2();
        pro10.Name='AFS-FLC-3200GB';
        pro10.Component_Code__c='3200';
        pro10.ProductCode='AFS-FLC-3200GB';
        pro10.Asset_Type__c='HFA';
        pro10.infosight_identifier__c='';
        pro10.HPE_SKU__C='';
        pro10.Family='AFS';
        pro10.Array_Controller__c = '';
        insert pro10;
        
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro10.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe3;
        
        Product2 pro3=new Product2();
        pro3.Name='SLA-4HR-AFS';
        pro3.Component_Code__c='';
        pro3.ProductCode='SLA-4HR-AFS';
        pro3.Asset_Type__c='';
        pro3.infosight_identifier__c='';
        pro3.HPE_SKU__C='';
        pro3.Family='Support';
        pro3.Array_Controller__c = '';
        insert pro3;
        
        PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro3.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe4;
        
        
        //insert lstProduct;
        
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        quote.SBQQ__Status__c='Approved';
        quote.SBQQ__Opportunity2__c=opp.Id;
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        system.assertEquals(opp.SBQQ__PrimaryQuote__c, quote.Id);
        
        system.assertEquals('Approved',quote.SBQQ__Status__c);
       
        //system.assertEquals('Approved', opp.SBQQ__PrimaryQuote__r.sbqq__Status__c);
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 0;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 1;
        line.SBQQ__PricebookEntryId__c = pb.Id;
        line.SBQQ__PackageProductCode__c = 'NGA-UPG ';
        insert line; //
        
        SBQQ__QuoteLine__c cline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cline.SBQQ__RequiredBy__c=line.Id;
        cline.SBQQ__Bundled__c=false;
        cline.SBQQ__BundledQuantity__c=1;
        cline.SBQQ__ListPrice__c = 186000;
        cline.BOM_Line_Number__c='2';
        cline.SBQQ__OptionType__c = 'Component';
        cline.SBQQ__Quantity__c = 1;
        cline.SBQQ__PricebookEntryId__c = pbe.Id;
        insert cline;
        
        list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c cline4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cline4.SBQQ__RequiredBy__c=line.Id;
        cline4.SBQQ__Bundled__c=false;
        cline4.SBQQ__BundledQuantity__c=1;
        cline4.SBQQ__ListPrice__c = 20000;
        cline4.BOM_Line_Number__c='3';
        cline4.SBQQ__OptionType__c = 'Component';
        cline4.SBQQ__Quantity__c = 1;
        cline4.SBQQ__PricebookEntryId__c = pbe1.Id;
        insert cline4;           
        //listQl.add(cline4);
        
                
        SBQQ__QuoteLine__c cline5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cline5.SBQQ__RequiredBy__c=line.Id;
        cline5.SBQQ__Bundled__c=false;
        cline5.SBQQ__BundledQuantity__c=1;
        cline5.SBQQ__ListPrice__c = 160000;
        cline5.BOM_Line_Number__c='3.1';
        cline5.SBQQ__OptionType__c = 'Component';
        cline5.SBQQ__Quantity__c = 1;
        cline5.SBQQ__PricebookEntryId__c = pbe2.Id;
        insert cline5; //
        //listQl.add(cline5);//
        
        SBQQ__QuoteLine__c cline6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro10.Id);
        cline6.SBQQ__RequiredBy__c=line.Id;
        cline6.SBQQ__Bundled__c=false;
        cline6.SBQQ__BundledQuantity__c=1;
        cline6.SBQQ__ListPrice__c = 152000;
        cline6.BOM_Line_Number__c='3.2';
        cline6.SBQQ__OptionType__c = 'Component';
        cline6.SBQQ__Quantity__c = 4;
        cline6.SBQQ__PricebookEntryId__c = pbe3.Id;
        insert cline6;//
        //listQl.add(cline6);//
        
        SBQQ__QuoteLine__c cline7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro3.Id);
        cline7.SBQQ__RequiredBy__c=line.Id;
        cline7.SBQQ__Bundled__c=false;
        cline7.SBQQ__BundledQuantity__c=1;
        cline7.SBQQ__ListPrice__c = 152000;
        cline7.BOM_Line_Number__c='4';
        cline7.SBQQ__OptionType__c = 'Component';
        cline7.SBQQ__Quantity__c = 4;
        cline7.SBQQ__PricebookEntryId__c = pbe3.Id;
        insert cline7;//
        
       test.stopTest();
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        salesOrderController.isBlankFactory = true;
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
       
        PageReference pref = target.onOverrideNew();
        
        
        so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
       
        
        
        
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assert(target.lineItemRows != null); 
        system.assert(target.lineItemRows.size()!= null);
        System.assertEquals(1, target.lineItemRows.size());
        target.lineItemRows[0].selected = true;
        
        
        pref = target.onAddLinesAFA();
        
        }
        
        
        
static testMethod void myUnitTest4() 
    {
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        
        test.startTest();
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567894');
        insert opp;
        
        Product2 p = new Product2(Name='Storage Array Upgrade',IsActive=true,Productcode='NGA-UPG',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        //insert lstProduct;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
        so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
       
        
        test.stopTest();
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assertEquals(0, target.lineItemRows.size());
        //target.lineItemRows[0].selected = true;
        
    }
    
    static testMethod void myUnitTest5() 
    {
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        Test.startTest();
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        //Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567895');
        //insert opp;
        
        Product2 p = new Product2(Name='Storage Array Upgrade',IsActive=true,Productcode='NGA-UPG',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        //insert lstProduct;
        
        //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        //insert quote;
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf('01t800000037C6z'));
        target.onOverrideNew();
        //so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
       
        
        test.stopTest();
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        
        
    }
    
    static testMethod void myUnitTest6() 
    {
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        test.StartTest();
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567896');
        insert opp;
        
        Product2 p = new Product2(Name='HPE Cloud Volumes - Pre-Pay',IsActive=true,Productcode='NCV',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        //insert lstProduct;
        
        Product2 pro=new Product2();
        pro.Name='NCV-BP-RTU-BDL';
        Pro.Component_Code__c='';
        pro.ProductCode='NCV-BP-RTU-BDL';
        pro.Asset_Type__c='';
        pro.infosight_identifier__c='';
        pro.HPE_SKU__C='';
        pro.Family='Services';
        insert pro;
        //lstProduct.add(pro);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe;
        
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        quote.SBQQ__Status__c='Approved';
        quote.SBQQ__Opportunity2__c=opp.Id;
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        system.assertEquals(opp.SBQQ__PrimaryQuote__c, quote.Id);
        
        system.assertEquals('Approved',quote.SBQQ__Status__c);
       
        //system.assertEquals('Approved', opp.SBQQ__PrimaryQuote__r.sbqq__Status__c);
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 0;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 1;
        line.SBQQ__PricebookEntryId__c = pb.Id;
        line.SBQQ__PackageProductCode__c = 'NCV';
        insert line; //
        
        SBQQ__QuoteLine__c cline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cline.SBQQ__RequiredBy__c=line.Id;
        cline.SBQQ__Bundled__c=false;
        cline.SBQQ__BundledQuantity__c=1;
        cline.SBQQ__ListPrice__c = 186000;
        cline.BOM_Line_Number__c='2';
        cline.SBQQ__OptionType__c = 'Component';
        cline.SBQQ__Quantity__c = 1;
        cline.SBQQ__PricebookEntryId__c = pbe.Id;
        insert cline;
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        salesOrderController.isBlankFactory = true;
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
       
        PageReference pref = target.onOverrideNew();
        
        
        so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
       
        
        test.stopTest();
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assert(target.lineItemRows != null); 
        system.assert(target.lineItemRows.size()!= null);
        System.assertEquals(1, target.lineItemRows.size());
        target.lineItemRows[0].selected = true;
        
        
        pref = target.onAddLinesAFA();
       
        
    }
    
    
    static testMethod void myUnitTest7(){ 
    
        User adminUser=[Select ID from User where Profile.Name='System Administrator II (pw never expires)' and isActive=True and UserRoleID!=null limit 1];
        User user = new User();    
          
        System.runAs(adminUser){
    
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        
        
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567897');
        insert opp;
        
        Product2 p = new Product2(Name='ADFA Gen5',IsActive=true,Productcode='ADFA-GEN5',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        
        
        List<Product2> lstproduct = new List<Product2>();
        
       
        test.startTest();
       
        Product2 pro1=new Product2();
        pro1.Name='HF20';
        Pro1.Component_Code__c='HF20';
        pro1.ProductCode='HF20';
        pro1.Asset_Type__c='test1';
        pro1.infosight_identifier__c='HF20';
        pro1.HPE_SKU__C='Q8H72A';
        pro1.Family='Hybrid Flash Array';
        insert pro1;
        //lstProduct.add(pro);
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro1.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe1;
       
        Product2 pro2=new Product2();
        pro2.Name='HEAD-HDD-21TBC';
        Pro2.Component_Code__c='HEAD-HDD-21TBC';
        pro2.ProductCode='HEAD-HDD-21TBC';
        pro2.Asset_Type__c='HFA';
        pro2.infosight_identifier__c='21T';
        pro2.HPE_SKU__C='Q8B68B';
        pro2.Family='Hybrid Flash Array';
        //lstProduct.add(pro1);       
        insert pro2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro2.Id, UnitPrice = 20000, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        
        Product2 pro3=new Product2();
        pro3.Name='PCI-DEFAULTC';
        Pro3.Component_Code__c='2OBT';
        pro3.ProductCode='PCI-DEFAULTC';
        pro3.Asset_Type__c='HFA';
        pro3.infosight_identifier__c='';
        pro3.HPE_SKU__C='Q8B83B';
        pro3.Family='Hybrid Flash Array';
        //lstProduct.add(pro2); 
        insert pro3;
        
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro3.Id, UnitPrice = 160000, IsActive = true, UseStandardPrice = false);
        insert pbe3;
        
        Product2 pro4=new Product2();
        pro4.Name='HEAD-FLC-11520GB-6C';
        pro4.Component_Code__c='M';
        pro4.ProductCode='HEAD-FLC-11520GB-6C';
        pro4.Asset_Type__c='HFA';
        pro4.infosight_identifier__c='11520F';
        pro4.HPE_SKU__C='Q8J31A';
        pro4.Family='Hybrid Flash Array';
        pro4.Array_Controller__c = 'HF40; HF60; HF60C';
        insert pro4;
        
        PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro4.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe4;
        
        //insert lstProduct;
       // Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        quote.SBQQ__Status__c='Approved';
        quote.SBQQ__Opportunity2__c=opp.Id;
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        system.assertEquals(opp.SBQQ__PrimaryQuote__c, quote.Id);
        
        system.assertEquals('Approved',quote.SBQQ__Status__c);
       
        //system.assertEquals('Approved', opp.SBQQ__PrimaryQuote__r.sbqq__Status__c);
        
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line1.SBQQ__ListPrice__c = 0;
        line1.BOM_Line_Number__c='1';
        line1.SBQQ__Quantity__c = 4;
        line1.SBQQ__PricebookEntryId__c = pb.Id;
        line1.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line1.Default_Factory__c ='FGI-FLEX-M';
        insert line1; //
        
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line2.SBQQ__ListPrice__c = 0;
        line2.BOM_Line_Number__c='1';
        line2.SBQQ__Quantity__c = 4;
        line2.SBQQ__PricebookEntryId__c = pb.Id;
        line2.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line2.Default_Factory__c ='FGI-FLEX-M';
        insert line2;
        
        SBQQ__QuoteLine__c line3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line3.SBQQ__ListPrice__c = 0;
        line3.BOM_Line_Number__c='1';
        line3.SBQQ__Quantity__c = 4;
        line3.SBQQ__PricebookEntryId__c = pb.Id;
        line3.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line3.Default_Factory__c ='FGI-FLEX-M';
        insert line3;
        
        
        SBQQ__QuoteLine__c line4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line4.SBQQ__ListPrice__c = 0;
        line4.BOM_Line_Number__c='1';
        line4.SBQQ__Quantity__c = 4;
        line4.SBQQ__PricebookEntryId__c = pb.Id;
        line4.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line4.Default_Factory__c ='FGI-FLEX-M';
        insert line4;
        
        SBQQ__QuoteLine__c line5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line5.SBQQ__ListPrice__c = 0;
        line5.BOM_Line_Number__c='1';
        line5.SBQQ__Quantity__c = 4;
        line5.SBQQ__PricebookEntryId__c = pb.Id;
        line5.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line5.Default_Factory__c ='FGI-FLEX-M';
        insert line5;
        
        
        SBQQ__QuoteLine__c line6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line6.SBQQ__ListPrice__c = 0;
        line6.BOM_Line_Number__c='1';
        line6.SBQQ__Quantity__c = 4;
        line6.SBQQ__PricebookEntryId__c = pb.Id;
        line6.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line6.Default_Factory__c ='FGI-FLEX-M';
        insert line6;
        
        SBQQ__QuoteLine__c line7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line7.SBQQ__ListPrice__c = 0;
        line7.BOM_Line_Number__c='1';
        line7.SBQQ__Quantity__c = 4;
        line7.SBQQ__PricebookEntryId__c = pb.Id;
        line7.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line7.Default_Factory__c ='FGI-FLEX-M';
        insert line7;
        
        SBQQ__QuoteLine__c line8 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line8.SBQQ__ListPrice__c = 0;
        line8.BOM_Line_Number__c='1';
        line8.SBQQ__Quantity__c = 4;
        line8.SBQQ__PricebookEntryId__c = pb.Id;
        line8.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line8.Default_Factory__c ='FGI-FLEX-M';
        insert line8;
        
        SBQQ__QuoteLine__c line9= new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line9.SBQQ__ListPrice__c = 0;
        line9.BOM_Line_Number__c='1';
        line9.SBQQ__Quantity__c = 4;
        line9.SBQQ__PricebookEntryId__c = pb.Id;
        line9.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line9.Default_Factory__c ='FGI-FLEX-M';
        insert line9;
        
        list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
        
        /******/
        
        /**** 1st set of ql ****/

        SBQQ__QuoteLine__c cline1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cline1.SBQQ__RequiredBy__c = line1.id;
        cline1.SBQQ__Bundled__c = false;
        cline1.SBQQ__BundledQuantity__c = 1;
        cline1.SBQQ__ListPrice__c = 0;
        cline1.BOM_Line_Number__c='1';
        cline1.SBQQ__Quantity__c = 4;
        cline1.SBQQ__PricebookEntryId__c = pbe1.Id;
        cline1.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline1.Default_Factory__c ='FGI-FLEX-A';
        //insert cline1; //
        listQl.add(cline1);
        
        SBQQ__QuoteLine__c cline2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cline2.SBQQ__RequiredBy__c = line1.id;
        cline2.SBQQ__Bundled__c = false;
        cline2.SBQQ__BundledQuantity__c = 1;
        cline2.SBQQ__ListPrice__c = 0;
        cline2.BOM_Line_Number__c='1';
        cline2.SBQQ__Quantity__c = 4;
        cline2.SBQQ__PricebookEntryId__c = pbe2.Id;
        cline2.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline2.Default_Factory__c ='FGI-FLEX-A';
        //insert cline2;
        listQl.add(cline2);
        
        SBQQ__QuoteLine__c cline3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro3.Id);
        cline3.SBQQ__RequiredBy__c = line1.id;
        cline3.SBQQ__Bundled__c = false;
        cline3.SBQQ__BundledQuantity__c = 1;
        cline3.SBQQ__ListPrice__c = 0;
        cline3.BOM_Line_Number__c='1';
        cline3.SBQQ__Quantity__c = 4;
        cline3.SBQQ__PricebookEntryId__c = pbe3.Id;
        cline3.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline3.Default_Factory__c ='FGI-FLEX-A';
        //insert cline3;
        listQl.add(cline3);
        
        SBQQ__QuoteLine__c cline4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro4.Id);
        cline4.SBQQ__RequiredBy__c = line1.id;
        cline4.SBQQ__Bundled__c = false;
        cline4.SBQQ__BundledQuantity__c = 1;
        cline4.SBQQ__ListPrice__c = 0;
        cline4.BOM_Line_Number__c='1';
        cline4.SBQQ__Quantity__c = 4;
        cline4.SBQQ__PricebookEntryId__c = pbe4.Id;
        cline4.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline4.Default_Factory__c ='FGI-FLEX-A';
        //insert cline4;
        listQl.add(cline4);
        
/****end****/
        
       /**** 2nd set of ql ****/

        SBQQ__QuoteLine__c cline5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cline5.SBQQ__RequiredBy__c = line2.id;
        cline5.SBQQ__Bundled__c = false;
        cline5.SBQQ__BundledQuantity__c = 1;
        cline5.SBQQ__ListPrice__c = 0;
        cline5.BOM_Line_Number__c='1';
        cline5.SBQQ__Quantity__c = 4;
        cline5.SBQQ__PricebookEntryId__c = pbe1.Id;
        cline5.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline5.Default_Factory__c ='FGI-FLEX-A';
        //insert cline5; //
        listQl.add(cline5);
        
        SBQQ__QuoteLine__c cline6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cline6.SBQQ__RequiredBy__c = line2.id;
        cline6.SBQQ__Bundled__c = false;
        cline6.SBQQ__BundledQuantity__c = 1;
        cline6.SBQQ__ListPrice__c = 0;
        cline6.BOM_Line_Number__c='1';
        cline6.SBQQ__Quantity__c = 4;
        cline6.SBQQ__PricebookEntryId__c = pbe2.Id;
        cline6.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline6.Default_Factory__c ='FGI-FLEX-A';
        //insert cline6;
        listQl.add(cline6);
        
        SBQQ__QuoteLine__c cline7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro3.Id);
        cline7.SBQQ__RequiredBy__c = line2.id;
        cline7.SBQQ__Bundled__c = false;
        cline7.SBQQ__BundledQuantity__c = 1;
        cline7.SBQQ__ListPrice__c = 0;
        cline7.BOM_Line_Number__c='1';
        cline7.SBQQ__Quantity__c = 4;
        cline7.SBQQ__PricebookEntryId__c = pbe3.Id;
        cline7.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline7.Default_Factory__c ='FGI-FLEX-A';
        //insert cline7;
        listQl.add(cline7);
        
        SBQQ__QuoteLine__c cline8 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro4.Id);
        cline8.SBQQ__RequiredBy__c = line2.id;
        cline8.SBQQ__Bundled__c = false;
        cline8.SBQQ__BundledQuantity__c = 1;
        cline8.SBQQ__ListPrice__c = 0;
        cline8.BOM_Line_Number__c='1';
        cline8.SBQQ__Quantity__c = 4;
        cline8.SBQQ__PricebookEntryId__c = pbe4.Id;
        cline8.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline8.Default_Factory__c ='FGI-FLEX-A';
        //insert cline8;
        listQl.add(cline8);
        
/****end****/

/**** 3rd set of ql ****/

        SBQQ__QuoteLine__c cline9 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cline9.SBQQ__RequiredBy__c = line3.id;
        cline9.SBQQ__Bundled__c = false;
        cline9.SBQQ__BundledQuantity__c = 1;
        cline9.SBQQ__ListPrice__c = 0;
        cline9.BOM_Line_Number__c='1';
        cline9.SBQQ__Quantity__c = 4;
        cline9.SBQQ__PricebookEntryId__c = pbe1.Id;
        cline9.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline9.Default_Factory__c ='FGI-FLEX-A';
        //insert cline9; //
        
        listQl.add(cline9);
        
        SBQQ__QuoteLine__c cline10 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cline10.SBQQ__RequiredBy__c = line3.id;
        cline10.SBQQ__Bundled__c = false;
        cline10.SBQQ__BundledQuantity__c = 1;
        cline10.SBQQ__ListPrice__c = 0;
        cline10.BOM_Line_Number__c='1';
        cline10.SBQQ__Quantity__c = 4;
        cline10.SBQQ__PricebookEntryId__c = pbe2.Id;
        cline10.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline10.Default_Factory__c ='FGI-FLEX-A';
       // insert cline10;
        listQl.add(cline10);
        
        SBQQ__QuoteLine__c cline11 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro3.Id);
        cline11.SBQQ__RequiredBy__c = line3.id;
        cline11.SBQQ__Bundled__c = false;
        cline11.SBQQ__BundledQuantity__c = 1;
        cline11.SBQQ__ListPrice__c = 0;
        cline11.BOM_Line_Number__c='1';
        cline11.SBQQ__Quantity__c = 4;
        cline11.SBQQ__PricebookEntryId__c = pbe3.Id;
        cline11.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline11.Default_Factory__c ='FGI-FLEX-A';
        //insert cline11;
        listQl.add(cline11);
        
        SBQQ__QuoteLine__c cline12 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro4.Id);
        cline12.SBQQ__RequiredBy__c = line3.id;
        cline12.SBQQ__Bundled__c = false;
        cline12.SBQQ__BundledQuantity__c = 1;
        cline12.SBQQ__ListPrice__c = 0;
        cline12.BOM_Line_Number__c='1';
        cline12.SBQQ__Quantity__c = 4;
        cline12.SBQQ__PricebookEntryId__c = pbe4.Id;
        cline12.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline12.Default_Factory__c ='FGI-FLEX-A';
       // insert cline12;
        listQl.add(cline12);
        
/****end****/
/**** 4th set of ql ****/

        SBQQ__QuoteLine__c cline13 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cline13.SBQQ__RequiredBy__c = line4.id;
        cline13.SBQQ__Bundled__c = false;
        cline13.SBQQ__BundledQuantity__c = 1;
        cline13.SBQQ__ListPrice__c = 0;
        cline13.BOM_Line_Number__c='1';
        cline13.SBQQ__Quantity__c = 4;
        cline13.SBQQ__PricebookEntryId__c = pbe1.Id;
        cline13.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline13.Default_Factory__c ='FGI-FLEX-A';
        //insert cline13; //
        listQl.add(cline13);
        
        SBQQ__QuoteLine__c cline14 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cline14.SBQQ__RequiredBy__c = line4.id;
        cline14.SBQQ__Bundled__c = false;
        cline14.SBQQ__BundledQuantity__c = 1;
        cline14.SBQQ__ListPrice__c = 0;
        cline14.BOM_Line_Number__c='1';
        cline14.SBQQ__Quantity__c = 4;
        cline14.SBQQ__PricebookEntryId__c = pbe2.Id;
        cline14.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline14.Default_Factory__c ='FGI-FLEX-A';
        //insert cline14;
        listQl.add(cline14);
        
        SBQQ__QuoteLine__c cline15 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro3.Id);
        cline15.SBQQ__RequiredBy__c = line4.id;
        cline15.SBQQ__Bundled__c = false;
        cline15.SBQQ__BundledQuantity__c = 1;
        cline15.SBQQ__ListPrice__c = 0;
        cline15.BOM_Line_Number__c='1';
        cline15.SBQQ__Quantity__c = 4;
        cline15.SBQQ__PricebookEntryId__c = pbe3.Id;
        cline15.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline15.Default_Factory__c ='FGI-FLEX-A';
        //insert cline15;
        listQl.add(cline15);
        
        SBQQ__QuoteLine__c cline16 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro4.Id);
        cline16.SBQQ__RequiredBy__c = line4.id;
        cline16.SBQQ__Bundled__c = false;
        cline16.SBQQ__BundledQuantity__c = 1;
        cline16.SBQQ__ListPrice__c = 0;
        cline16.BOM_Line_Number__c='1';
        cline16.SBQQ__Quantity__c = 4;
        cline16.SBQQ__PricebookEntryId__c = pbe4.Id;
        cline16.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline16.Default_Factory__c ='FGI-FLEX-A';
        //insert cline16;
        listQl.add(cline16);
        
/****end****/

/**** 5th set of ql ****/

        SBQQ__QuoteLine__c cline17 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cline17.SBQQ__RequiredBy__c = line5.id;
        cline17.SBQQ__Bundled__c = false;
        cline17.SBQQ__BundledQuantity__c = 1;
        cline17.SBQQ__ListPrice__c = 0;
        cline17.BOM_Line_Number__c='1';
        cline17.SBQQ__Quantity__c = 4;
        cline17.SBQQ__PricebookEntryId__c = pbe1.Id;
        cline17.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline17.Default_Factory__c ='FGI-FLEX-A';
        //insert cline17; //
        listQl.add(cline17);
        
        SBQQ__QuoteLine__c cline18 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cline18.SBQQ__RequiredBy__c = line5.id;
        cline18.SBQQ__Bundled__c = false;
        cline18.SBQQ__BundledQuantity__c = 1;
        cline18.SBQQ__ListPrice__c = 0;
        cline18.BOM_Line_Number__c='1';
        cline18.SBQQ__Quantity__c = 4;
        cline18.SBQQ__PricebookEntryId__c = pbe2.Id;
        cline18.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline18.Default_Factory__c ='FGI-FLEX-A';
        //insert cline18;
        listQl.add(cline18);
        
        SBQQ__QuoteLine__c cline19 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro3.Id);
        cline19.SBQQ__RequiredBy__c = line5.id;
        cline19.SBQQ__Bundled__c = false;
        cline19.SBQQ__BundledQuantity__c = 1;
        cline19.SBQQ__ListPrice__c = 0;
        cline19.BOM_Line_Number__c='1';
        cline19.SBQQ__Quantity__c = 4;
        cline19.SBQQ__PricebookEntryId__c = pbe3.Id;
        cline19.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline19.Default_Factory__c ='FGI-FLEX-A';
        //insert cline19;
        listQl.add(cline19);
        
        SBQQ__QuoteLine__c cline20 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro4.Id);
        cline20.SBQQ__RequiredBy__c = line5.id;
        cline20.SBQQ__Bundled__c = false;
        cline20.SBQQ__BundledQuantity__c = 1;
        cline20.SBQQ__ListPrice__c = 0;
        cline20.BOM_Line_Number__c='1';
        cline20.SBQQ__Quantity__c = 4;
        cline20.SBQQ__PricebookEntryId__c = pbe4.Id;
        cline20.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        cline20.Default_Factory__c ='FGI-FLEX-A';
        //insert cline20;
        listQl.add(cline20);
        
/****end****/
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        SalesOrderController.isOther = true;
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
        
        PageReference pref = target.onOverrideNew();
        
        so.Type__c = 'Revenue';
        so.Opportunity__c = opp.Id;
        insert so;
        test.stopTest();
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
        
        
        
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assert(target.lineItemRows != null); 
        system.assert(target.lineItemRows.size()!= null);
        System.assertEquals(36, target.lineItemRows.size());
        
        for(integer i=0; i< target.lineItemRows.size(); i++){
            target.lineItemRows[i].selected = true;
        }       
        pref = target.onAddLinesAFA();
    }
    }
    
    
    static testMethod void myUnitTest8(){ 
        
    Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        
        
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567899');
        insert opp;
        
        Product2 p = new Product2(Name='All Flash Array Gen5',IsActive=true,Productcode='AFA-GEN5',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        
        
        List<Product2> lstproduct = new List<Product2>();
        
        test.startTest();
        Product2 pro=new Product2();
        pro.Name='AF20';
        Pro.Component_Code__c='AF20';
        pro.ProductCode='AF20';
        pro.Asset_Type__c='AFA2';
        pro.infosight_identifier__c='AF20';
        pro.HPE_SKU__C='Q8H72A';
        pro.Family='All Flash Array Gen5';
        insert pro;
        //lstProduct.add(pro);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe;
       
        Product2 pro1=new Product2();
        pro1.Name='AF2-SSD';
        Pro1.Component_Code__c='AF';
        pro1.ProductCode='AF2-SSD';
        pro1.Asset_Type__c='AFA2';        
        pro1.HPE_SKU__C='Q8B68B';
        pro1.Family='All Flash Array Gen5';
        //lstProduct.add(pro1);       
        insert pro1;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro1.Id, UnitPrice = 20000, IsActive = true, UseStandardPrice = false);
        insert pbe1;
        
        Product2 pro2=new Product2();
        pro2.Name='PCI-DEFAULTC';
        Pro2.Component_Code__c='2OBT';
        pro2.ProductCode='PCI-DEFAULTC';
        pro2.Asset_Type__c='AFA2';
        pro2.infosight_identifier__c='';
        pro2.HPE_SKU__C='Q8B83B';
        pro2.Family='All Flash Array Gen5';
        //lstProduct.add(pro2); 
        insert pro2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro2.Id, UnitPrice = 160000, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        
        Product2 pro10=new Product2();
        pro10.Name='AF-6TC';
        pro10.Component_Code__c='6T';
        pro10.ProductCode='AF-6T';
        pro10.Asset_Type__c='HFA';
        pro10.infosight_identifier__c='5760F';
        pro10.HPE_SKU__C='Q8J31A';
        pro10.Family='All Flash Array Gen5';
        pro10.Array_Controller__c = 'AF20';
        insert pro10;
        
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro10.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe3;
        
        Product2 pro3=new Product2();
        pro3.Name='AF-11TXC';
        pro3.Component_Code__c='11T';
        pro3.ProductCode='AF-11T';
        pro3.Asset_Type__c='AFA2';
        pro3.infosight_identifier__c='11520F';
        pro3.HPE_SKU__C='Q8J31A';
        pro3.Family='All Flash Array Gen5';
        pro3.Array_Controller__c = 'AF20';
        insert pro3;
        
        PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro3.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe4;
        
        
        //insert lstProduct;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        quote.SBQQ__Status__c='Approved';
        quote.SBQQ__Opportunity2__c=opp.Id;
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        system.assertEquals(opp.SBQQ__PrimaryQuote__c, quote.Id);
        
        system.assertEquals('Approved',quote.SBQQ__Status__c);
       
        //system.assertEquals('Approved', opp.SBQQ__PrimaryQuote__r.sbqq__Status__c);
        
        SBQQ__QuoteLine__c pline1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        pline1.SBQQ__ListPrice__c = 0;
        pline1.BOM_Line_Number__c='1';
        pline1.SBQQ__Quantity__c = 4;
        pline1.SBQQ__PricebookEntryId__c = pb.Id;
        pline1.SBQQ__PackageProductCode__c = 'AF20-2OBT-17T-2';
        pline1.Default_Factory__c='FGI-FLEX-A';
        insert pline1; //
        
        SBQQ__QuoteLine__c pline2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        pline2.SBQQ__ListPrice__c = 0;
        pline2.BOM_Line_Number__c='1';
        pline2.SBQQ__Quantity__c = 4;
        pline2.SBQQ__PricebookEntryId__c = pb.Id;
        pline2.SBQQ__PackageProductCode__c = 'AF20-2OBT-17T-2';
        pline2.Default_Factory__c='FGI-FLEX-A';
        insert pline2; 
        
        SBQQ__QuoteLine__c pline3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        pline3.SBQQ__ListPrice__c = 0;
        pline3.BOM_Line_Number__c='1';
        pline3.SBQQ__Quantity__c = 4;
        pline3.SBQQ__PricebookEntryId__c = pb.Id;
        pline3.SBQQ__PackageProductCode__c = 'AF20-2OBT-17T-2';
        pline3.Default_Factory__c='FGI-FLEX-A';
        insert pline3; //
        
        SBQQ__QuoteLine__c pline4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        pline4.SBQQ__ListPrice__c = 0;
        pline4.BOM_Line_Number__c='1';
        pline4.SBQQ__Quantity__c = 4;
        pline4.SBQQ__PricebookEntryId__c = pb.Id;
        pline4.SBQQ__PackageProductCode__c = 'AF20-2OBT-17T-2';
        pline4.Default_Factory__c='FGI-FLEX-A';
        insert pline4; 
        /*******/
        
       /***** 1st set ****/
        SBQQ__Quoteline__c cpline11 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cpline11.SBQQ__RequiredBy__c=pline1.Id;
        cpline11.SBQQ__Bundled__c=false;
        cpline11.SBQQ__BundledQuantity__c=1;
        cpline11.SBQQ__ListPrice__c = 186000;
        cpline11.BOM_line_Number__c='1';
        cpline11.SBQQ__OptionType__c = 'Component';
        cpline11.SBQQ__Quantity__c = 4;
        cpline11.SBQQ__PricebookEntryId__c = pbe.Id;
        cpline11.Default_Factory__c='FGI-FLEX-A';
        insert cpline11;
        
        list<SBQQ__Quoteline__c> listQl = new list<SBQQ__Quoteline__c>();
        
        SBQQ__Quoteline__c cpline12 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cpline12.SBQQ__RequiredBy__c=pline1.Id;
        cpline12.SBQQ__Bundled__c=false;
        cpline12.SBQQ__BundledQuantity__c=1;
        cpline12.SBQQ__ListPrice__c = 20000;
        cpline12.BOM_line_Number__c='1';
        cpline12.SBQQ__OptionType__c = 'Component';
        cpline12.SBQQ__Quantity__c = 4;
        cpline12.SBQQ__PricebookEntryId__c = pbe1.Id;
        cpline12.Default_Factory__c='FGI-FLEX-A';
        //insert cpline12;           
        listQl.add(cpline12);
        
                
        SBQQ__Quoteline__c cpline13 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cpline13.SBQQ__RequiredBy__c=pline1.Id;
        cpline13.SBQQ__Bundled__c=false;
        cpline13.SBQQ__BundledQuantity__c=1;
        cpline13.SBQQ__ListPrice__c = 160000;
        cpline13.BOM_line_Number__c='1';
        cpline13.SBQQ__OptionType__c = 'Component';
        cpline13.SBQQ__Quantity__c = 4;
        cpline13.SBQQ__PricebookEntryId__c = pbe2.Id;
        cpline13.Default_Factory__c='FGI-FLEX-A';
        //insert cpline13; //
        listQl.add(cpline13);//
        
        SBQQ__Quoteline__c cpline14 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro10.Id);
        cpline14.SBQQ__RequiredBy__c=pline1.Id;
        cpline14.SBQQ__Bundled__c=false;
        cpline14.SBQQ__BundledQuantity__c=1;
        cpline14.SBQQ__ListPrice__c = 152000;
        cpline14.BOM_line_Number__c='1';
        cpline14.SBQQ__OptionType__c = 'Component';
        cpline14.SBQQ__Quantity__c = 4;
        cpline14.SBQQ__PricebookEntryId__c = pbe3.Id;
        cpline14.Default_Factory__c='FGI-FLEX-A';
        //insert cpline14;//
        listQl.add(cpline14);
        
/*** end ***/

/***** 2nd set ****/
        SBQQ__Quoteline__c cline1 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cline1.SBQQ__RequiredBy__c=pline2.Id;
        cline1.SBQQ__Bundled__c=false;
        cline1.SBQQ__BundledQuantity__c=1;
        cline1.SBQQ__ListPrice__c = 186000;
        cline1.BOM_line_Number__c='1';
        cline1.SBQQ__OptionType__c = 'Component';
        cline1.SBQQ__Quantity__c = 4;
        cline1.SBQQ__PricebookEntryId__c = pbe.Id;
        cline1.Default_Factory__c='FGI-FLEX-A';
        insert cline1;
        
       // list<SBQQ__Quotepline1__c> listQl = new list<SBQQ__Quotepline1__c>();
        
        SBQQ__Quoteline__c cline2 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cline2.SBQQ__RequiredBy__c=pline2.Id;
        cline2.SBQQ__Bundled__c=false;
        cline2.SBQQ__BundledQuantity__c=1;
        cline2.SBQQ__ListPrice__c = 20000;
        cline2.BOM_line_Number__c='1';
        cline2.SBQQ__OptionType__c = 'Component';
        cline2.SBQQ__Quantity__c = 4;
        cline2.SBQQ__PricebookEntryId__c = pbe1.Id;
        cline2.Default_Factory__c='FGI-FLEX-A';
        //insert cline2;           
        listQl.add(cline2);
        
                
        SBQQ__Quoteline__c cline3 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cline3.SBQQ__RequiredBy__c=pline2.Id;
        cline3.SBQQ__Bundled__c=false;
        cline3.SBQQ__BundledQuantity__c=1;
        cline3.SBQQ__ListPrice__c = 160000;
        cline3.BOM_line_Number__c='1';
        cline3.SBQQ__OptionType__c = 'Component';
        cline3.SBQQ__Quantity__c = 4;
        cline3.SBQQ__PricebookEntryId__c = pbe2.Id;
        cline3.Default_Factory__c='FGI-FLEX-A';
        //insert cline3; //
        listQl.add(cline3);//
        
        SBQQ__Quoteline__c cline4 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro10.Id);
        cline4.SBQQ__RequiredBy__c=pline2.Id;
        cline4.SBQQ__Bundled__c=false;
        cline4.SBQQ__BundledQuantity__c=1;
        cline4.SBQQ__ListPrice__c = 152000;
        cline4.BOM_line_Number__c='1';
        cline4.SBQQ__OptionType__c = 'Component';
        cline4.SBQQ__Quantity__c = 4;
        cline4.SBQQ__PricebookEntryId__c = pbe3.Id;
        cline4.Default_Factory__c='FGI-FLEX-A';
        //insert cline4;//
        listQl.add(cline4);
        
/*** end ***/
        
       /***** 3rd set ****/
        SBQQ__Quoteline__c cpline21 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cpline21.SBQQ__RequiredBy__c=pline3.Id;
        cpline21.SBQQ__Bundled__c=false;
        cpline21.SBQQ__BundledQuantity__c=1;
        cpline21.SBQQ__ListPrice__c = 186000;
        cpline21.BOM_line_Number__c='1';
        cpline21.SBQQ__OptionType__c = 'Component';
        cpline21.SBQQ__Quantity__c = 4;
        cpline21.SBQQ__PricebookEntryId__c = pbe.Id;
        cpline21.Default_Factory__c='FGI-FLEX-A';
        insert cpline21;
        
        
        
        SBQQ__Quoteline__c cpline22 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cpline22.SBQQ__RequiredBy__c=pline3.Id;
        cpline22.SBQQ__Bundled__c=false;
        cpline22.SBQQ__BundledQuantity__c=1;
        cpline22.SBQQ__ListPrice__c = 20000;
        cpline22.BOM_line_Number__c='1';
        cpline22.SBQQ__OptionType__c = 'Component';
        cpline22.SBQQ__Quantity__c = 4;
        cpline22.SBQQ__PricebookEntryId__c = pbe1.Id;
        cpline22.Default_Factory__c='FGI-FLEX-A';
        //insert cpline22;           
        listQl.add(cpline22);
        
                
        SBQQ__Quoteline__c cpline23 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cpline23.SBQQ__RequiredBy__c=pline3.Id;
        cpline23.SBQQ__Bundled__c=false;
        cpline23.SBQQ__BundledQuantity__c=1;
        cpline23.SBQQ__ListPrice__c = 160000;
        cpline23.BOM_line_Number__c='1';
        cpline23.SBQQ__OptionType__c = 'Component';
        cpline23.SBQQ__Quantity__c = 4;
        cpline23.SBQQ__PricebookEntryId__c = pbe2.Id;
        cpline23.Default_Factory__c='FGI-FLEX-A';
        //insert cpline23; //
        listQl.add(cpline23);//
        
        SBQQ__Quoteline__c cpline24 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro10.Id);
        cpline24.SBQQ__RequiredBy__c=pline3.Id;
        cpline24.SBQQ__Bundled__c=false;
        cpline24.SBQQ__BundledQuantity__c=1;
        cpline24.SBQQ__ListPrice__c = 152000;
        cpline24.BOM_line_Number__c='1';
        cpline24.SBQQ__OptionType__c = 'Component';
        cpline24.SBQQ__Quantity__c = 4;
        cpline24.SBQQ__PricebookEntryId__c = pbe3.Id;
        cpline24.Default_Factory__c='FGI-FLEX-A';
        //insert cpline24;//
        listQl.add(cpline24);
        
/*** end ***/

/***** 4th set ****/
        SBQQ__Quoteline__c cpline31 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cpline31.SBQQ__RequiredBy__c=pline4.Id;
        cpline31.SBQQ__Bundled__c=false;
        cpline31.SBQQ__BundledQuantity__c=1;
        cpline31.SBQQ__ListPrice__c = 186000;
        cpline31.BOM_line_Number__c='1';
        cpline31.SBQQ__OptionType__c = 'Component';
        cpline31.SBQQ__Quantity__c = 4;
        cpline31.SBQQ__PricebookEntryId__c = pbe.Id;
        cpline31.Default_Factory__c='FGI-FLEX-A';
        insert cpline31;
        
        
        
        SBQQ__Quoteline__c cpline32 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cpline32.SBQQ__RequiredBy__c=pline4.Id;
        cpline32.SBQQ__Bundled__c=false;
        cpline32.SBQQ__BundledQuantity__c=1;
        cpline32.SBQQ__ListPrice__c = 20000;
        cpline32.BOM_line_Number__c='1';
        cpline32.SBQQ__OptionType__c = 'Component';
        cpline32.SBQQ__Quantity__c = 4;
        cpline32.SBQQ__PricebookEntryId__c = pbe1.Id;
        cpline32.Default_Factory__c='FGI-FLEX-A';
        //insert cpline32;           
        listQl.add(cpline32);
        
                
        SBQQ__Quoteline__c cpline33 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cpline33.SBQQ__RequiredBy__c=pline4.Id;
        cpline33.SBQQ__Bundled__c=false;
        cpline33.SBQQ__BundledQuantity__c=1;
        cpline33.SBQQ__ListPrice__c = 160000;
        cpline33.BOM_line_Number__c='1';
        cpline33.SBQQ__OptionType__c = 'Component';
        cpline33.SBQQ__Quantity__c = 4;
        cpline33.SBQQ__PricebookEntryId__c = pbe2.Id;
        cpline33.Default_Factory__c='FGI-FLEX-A';
        //insert cpline33; //
        listQl.add(cpline33);//
        
        SBQQ__Quoteline__c cpline34 = new SBQQ__Quoteline__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro10.Id);
        cpline34.SBQQ__RequiredBy__c=pline4.Id;
        cpline34.SBQQ__Bundled__c=false;
        cpline34.SBQQ__BundledQuantity__c=1;
        cpline34.SBQQ__ListPrice__c = 152000;
        cpline34.BOM_line_Number__c='1';
        cpline34.SBQQ__OptionType__c = 'Component';
        cpline34.SBQQ__Quantity__c = 4;
        cpline34.SBQQ__PricebookEntryId__c = pbe3.Id;
        cpline34.Default_Factory__c='FGI-FLEX-A';
        //insert cpline34;//
        listQl.add(cpline34);
        
/*** end ***/
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        SalesOrderController.isCamilian = true;       
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
        //System.assertEquals(1, ApexPages.getMessages().size());
        
       // quote.SBQQ__Status__c = 'Approved';
       // update quote;
        PageReference pref = target.onOverrideNew();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assert(pref.getUrl().startsWith('/' + Sales_Order__c.sObjectType.getDescribe().getKeyPrefix() + '/e'));
        
        so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
       
        
        test.stopTest();
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assert(target.lineItemRows != null); 
        system.assert(target.lineItemRows.size()!= null);
        System.assertEquals(16, target.lineItemRows.size());
        
        for( integer i=0; i< target.lineItemRows.size(); i++){
            target.lineItemRows[i].selected = true;
        
        }
        /*target.lineItemRows[1].selected=true;
        target.lineItemRows[2].selected=true;
        target.lineItemRows[3].selected=true;*/
        pref = target.onAddLinesAFA();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assertEquals('/' + so.Id, pref.getUrl());
      //  System.assertEquals(0, [SELECT count() FROM Sales_Order_Line__c WHERE Sales_Order__c = :so.Id]);
        
    }
    
    
    static testmethod void myUnittest9(){
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        
        
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567898');
        insert opp;
        
        Product2 p = new Product2(Name='All Flash Array Gen5',IsActive=true,Productcode='AFA-GEN5',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        
        
        List<Product2> lstproduct = new List<Product2>();
        
        test.startTest();
        Product2 pro=new Product2();
        pro.Name='SLA-4HR-AFA';
        Pro.Component_Code__c='';
        pro.ProductCode='SLA-4HR-AFA';
        pro.Asset_Type__c='AFA2';
        pro.infosight_identifier__c='';
        pro.HPE_SKU__C='';
        pro.Family='Support';
        insert pro;
        //lstProduct.add(pro);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe;
       
        Product2 pro1=new Product2();
        pro1.Name='SLA-4HR-DISK-AFA';
        Pro1.Component_Code__c='';
        pro1.ProductCode='SLA-4HR-DISK-AFA';
        pro1.Asset_Type__c='';        
        pro1.HPE_SKU__C='';
        pro1.Family='Support';
        pro1.Product_Type_2__c = 'Power Cord';
        //lstProduct.add(pro1);       
        insert pro1;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro1.Id, UnitPrice = 20000, IsActive = true, UseStandardPrice = false);
        insert pbe1;
        
        Product2 pro2=new Product2();
        pro2.Name='SLA-4HR-HW-AFA   ';
        Pro2.Component_Code__c='';
        pro2.ProductCode='SLA-4HR-HW-AFA';
        pro2.Asset_Type__c='';
        pro2.infosight_identifier__c='';
        pro2.HPE_SKU__C='';
        pro2.Family='Support';
        pro2.Product_Type_2__c = 'Power Cord';
        //lstProduct.add(pro2); 
        insert pro2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro2.Id, UnitPrice = 160000, IsActive = true, UseStandardPrice = false);
        insert pbe2;
        
        Product2 pro10=new Product2();
        pro10.Name='AF-6TC';
        pro10.Component_Code__c='6T';
        pro10.ProductCode='AF-6T';
        pro10.Asset_Type__c='HFA';
        pro10.infosight_identifier__c='5760F';
        pro10.HPE_SKU__C='Q8J31A';
        pro10.Family='All Flash Array Gen5';
        pro10.Array_Controller__c = 'AF20';
        pro10.Product_Type_2__c = 'Power Cord';
        insert pro10;
        
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro10.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe3;
        
        Product2 pro3=new Product2();
        pro3.Name='SLA-NBD-AFA  ';
        pro3.Component_Code__c='';
        pro3.ProductCode='SLA-NBD-AFA';
        pro3.Asset_Type__c='AFA2';
        pro3.infosight_identifier__c='';
        pro3.HPE_SKU__C='';
        pro3.Family='Support';
        pro3.Array_Controller__c = '';
        insert pro3;
        
        PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro3.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe4;


        
        //insert lstProduct;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        quote.SBQQ__Status__c='Approved';
        quote.SBQQ__Opportunity2__c=opp.Id;
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        system.assertEquals(opp.SBQQ__PrimaryQuote__c, quote.Id);
        
        system.assertEquals('Approved',quote.SBQQ__Status__c);
       
        //system.assertEquals('Approved', opp.SBQQ__PrimaryQuote__r.sbqq__Status__c);
        
        SBQQ__QuoteLine__c pline1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        pline1.SBQQ__ListPrice__c = 0;
        pline1.BOM_Line_Number__c='1';
        pline1.SBQQ__Quantity__c = 4;
        pline1.SBQQ__PricebookEntryId__c = pb.Id;
        pline1.SBQQ__PackageProductCode__c = 'AF20-2OBT-17T-2';
        pline1.Default_Factory__c='FGI-FLEX-A';
        insert pline1; //
        
        
        /*******/
        
       /***** 1st set ****/
        SBQQ__QuoteLine__c cpline11 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cpline11.SBQQ__RequiredBy__c=pline1.Id;
        cpline11.SBQQ__Bundled__c=false;
        cpline11.SBQQ__BundledQuantity__c=1;
        cpline11.SBQQ__ListPrice__c = 186000;
        cpline11.BOM_line_Number__c='1';
        cpline11.SBQQ__OptionType__c = 'Component';
        cpline11.SBQQ__Quantity__c = 4;
        cpline11.SBQQ__PricebookEntryId__c = pbe.Id;
        cpline11.Default_Factory__c='FGI-FLEX-A';
        insert cpline11;
        
        list<SBQQ__QuoteLine__c> listQl = new list<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c cpline12 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro1.Id);
        cpline12.SBQQ__RequiredBy__c=pline1.Id;
        cpline12.SBQQ__Bundled__c=false;
        cpline12.SBQQ__BundledQuantity__c=1;
        cpline12.SBQQ__ListPrice__c = 20000;
        cpline12.BOM_line_Number__c='1';
        cpline12.SBQQ__OptionType__c = 'Component';
        cpline12.SBQQ__Quantity__c = 4;
        cpline12.SBQQ__PricebookEntryId__c = pbe1.Id;
        cpline12.Default_Factory__c='FGI-FLEX-A';
        //insert cpline12;           
        listQl.add(cpline12);
        
                
        SBQQ__QuoteLine__c  cpline13 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro2.Id);
        cpline13.SBQQ__RequiredBy__c=pline1.Id;
        cpline13.SBQQ__Bundled__c=false;
        cpline13.SBQQ__BundledQuantity__c=1;
        cpline13.SBQQ__ListPrice__c = 160000;
        cpline13.BOM_line_Number__c='1';
        cpline13.SBQQ__OptionType__c = 'Component';
        cpline13.SBQQ__Quantity__c = 4;
        cpline13.SBQQ__PricebookEntryId__c = pbe2.Id;
        cpline13.Default_Factory__c='FGI-FLEX-A';
        //insert cpline13; //
        listQl.add(cpline13);//
        
        SBQQ__QuoteLine__c  cpline14 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro10.Id);
        cpline14.SBQQ__RequiredBy__c=pline1.Id;
        cpline14.SBQQ__Bundled__c=false;
        cpline14.SBQQ__BundledQuantity__c=1;
        cpline14.SBQQ__ListPrice__c = 152000;
        cpline14.BOM_line_Number__c='1';
        cpline14.SBQQ__OptionType__c = 'Component';
        cpline14.SBQQ__Quantity__c = 4;
        cpline14.SBQQ__PricebookEntryId__c = pbe3.Id;
        cpline14.Default_Factory__c='FGI-FLEX-A';
        //insert cpline14;//
        listQl.add(cpline14);
        
/*** end ***/


        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        SalesOrderController.isCamilian = true;       
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
        //System.assertEquals(1, ApexPages.getMessages().size());
        
       // quote.SBQQ__Status__c = 'Approved';
       // update quote;
        PageReference pref = target.onOverrideNew();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assert(pref.getUrl().startsWith('/' + Sales_Order__c.sObjectType.getDescribe().getKeyPrefix() + '/e'));
        
        so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
       
        
        test.stopTest();
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assert(target.lineItemRows != null); 
        system.assert(target.lineItemRows.size()!= null);
        System.assertEquals(4, target.lineItemRows.size());
        target.lineItemRows[0].selected = true;
        target.lineItemRows[1].selected=true;
        target.lineItemRows[2].selected=true;
        target.lineItemRows[3].selected=true;
        pref = target.onAddLinesAFA();
        //System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        //System.assertEquals('/' + so.Id, pref.getUrl());
      //  System.assertEquals(0, [SELECT count() FROM Sales_Order_Line__c WHERE Sales_Order__c = :so.Id]);
        
    }
   static testMethod void myUnitTest10() 
    {
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        
        test.startTest();
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567811');
        insert opp;
        
        Product2 p = new Product2(Name='Storage Array Upgrade',IsActive=true,Productcode='NGA-UPG',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        //insert lstProduct;
        
         Product2 pro=new Product2();
        pro.Name='ES1CBLG2-1M';
        Pro.Component_Code__c='';
        pro.ProductCode='ES1CBLG2-1M';
        pro.Asset_Type__c='';
        pro.infosight_identifier__c='';
        pro.HPE_SKU__C='';
        pro.Family='Other (parts, spares, etc)';
        insert pro;
        //lstProduct.add(pro);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe;
       
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        quote.SBQQ__Status__c = 'Approved';
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
         SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 0;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 1;
        line.SBQQ__PricebookEntryId__c = pb.Id;
        line.SBQQ__PackageProductCode__c = 'NGA-UPG ';
        insert line; //
        
        SBQQ__QuoteLine__c cline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cline.SBQQ__RequiredBy__c=line.Id;
        cline.SBQQ__Bundled__c=false;
        cline.SBQQ__BundledQuantity__c=1;
        cline.SBQQ__ListPrice__c = 186000;
        cline.BOM_Line_Number__c='2';
        cline.SBQQ__OptionType__c = 'Component';
        cline.SBQQ__Quantity__c = 1;
        cline.SBQQ__PricebookEntryId__c = pbe.Id;
        insert cline;
        
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        SalesOrderController.isCamilian = true;
        SalesOrderController.isOther = true;
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
        
        PageReference pref = target.onOverrideNew();
        
        so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
       
        
        test.stopTest();
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assertEquals(1, target.lineItemRows.size());
        target.lineItemRows[0].selected = true;
        pref = target.onAddLinesAFA();
    } 
    
static testmethod void myUnitTest11(){
    Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='USD';
        
        insert pb2;
        
        test.StartTest();
        
        Account a = new Account(Name='Test',BillingStreet='213 cherry street',BillingCity='San Jose',BillingState='CA',BillingCountry='US');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test', Pricebook2 = pb2 ,StageName='Prospecting',CloseDate=System.today().addMonths(1), HPE_Opportunity_ID__c = 'OPE-1234567896');
        insert opp;
        
        Product2 p = new Product2(Name='HPE Cloud Volumes - Pre-Pay',IsActive=true,Productcode='NCV',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p;
        
        insert new PriceBookEntry(Product2Id=p.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb;
        //insert lstProduct;
        
        Product2 pro=new Product2();
        pro.Name='NCV-BP-RTU-BDL';
        Pro.Component_Code__c='';
        pro.ProductCode='NCV-BP-RTU-BDL';
        pro.Asset_Type__c='';
        pro.infosight_identifier__c='';
        pro.HPE_SKU__C='';
        pro.Family='Services';
        insert pro;
        //lstProduct.add(pro);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe;
        
        /****/
                Product2 p1 = new Product2(Name='ADFA Gen5',IsActive=true,Productcode='ADFA-GEN5',Separate_Order_Line_Per_Unit__c=false, parent_product__c = true);
        insert p1;
        
        insert new PriceBookEntry(Product2Id=p1.Id, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);

        
        PricebookEntry pb1 = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = p1.Id, UnitPrice = 0, IsActive = true, UseStandardPrice = false);
        insert pb1;
        
        
       
       
        Product2 pro10=new Product2();
        pro10.Name='HF20';
        pro10.Component_Code__c='HF20';
        pro10.ProductCode='HF20';
        pro10.Asset_Type__c='test1';
        pro10.infosight_identifier__c='HF20';
        pro10.HPE_SKU__C='Q8H72A';
        pro10.Family='Hybrid Flash Array';
        insert pro10;
        //lstProduct.add(pro);
        
        PricebookEntry pbe10 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro10.Id, UnitPrice = 186000, IsActive = true, UseStandardPrice = false);
        insert pbe10;
       
        Product2 pro20=new Product2();
        pro20.Name='HEAD-HDD-21TBC';
        pro20.Component_Code__c='HEAD-HDD-21TBC';
        pro20.ProductCode='HEAD-HDD-21TBC';
        pro20.Asset_Type__c='HFA';
        pro20.infosight_identifier__c='21T';
        pro20.HPE_SKU__C='Q8B68B';
        pro20.Family='Hybrid Flash Array';
        //lstProduct.add(pro1);       
        insert pro20;
        
        PricebookEntry pbe20 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro20.Id, UnitPrice = 20000, IsActive = true, UseStandardPrice = false);
        insert pbe20;
        
        Product2 pro30=new Product2();
        pro30.Name='PCI-DEFAULTC';
        pro30.Component_Code__c='2OBT';
        pro30.ProductCode='PCI-DEFAULTC';
        pro30.Asset_Type__c='HFA';
        pro30.infosight_identifier__c='';
        pro30.HPE_SKU__C='Q8B83B';
        pro30.Family='Hybrid Flash Array';
        //lstProduct.add(pro2); 
        insert pro30;
        
        PricebookEntry pbe30 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro30.Id, UnitPrice = 160000, IsActive = true, UseStandardPrice = false);
        insert pbe30;
        
        Product2 pro40=new Product2();
        pro40.Name='HEAD-FLC-11520GB-6C';
        pro40.Component_Code__c='M';
        pro40.ProductCode='HEAD-FLC-11520GB-6C';
        pro40.Asset_Type__c='HFA';
        pro40.infosight_identifier__c='11520F';
        pro40.HPE_SKU__C='Q8J31A';
        pro40.Family='Hybrid Flash Array';
        pro40.Array_Controller__c = 'HF40; HF60; HF60C';
        insert pro40;
        
        PricebookEntry pbe40 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro40.Id, UnitPrice = 152000, IsActive = true, UseStandardPrice = false);
        insert pbe40;
        
        
        
        
        
        /****/
        
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true, SBQQ__PriceBook__c=pb2.Id);
        insert quote;
        
        quote.SBQQ__Status__c='Approved';
        quote.SBQQ__Opportunity2__c=opp.Id;
        update quote;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        system.assertEquals(opp.SBQQ__PrimaryQuote__c, quote.Id);
        
        system.assertEquals('Approved',quote.SBQQ__Status__c);
       
        //system.assertEquals('Approved', opp.SBQQ__PrimaryQuote__r.sbqq__Status__c);
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 0;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 1;
        line.SBQQ__PricebookEntryId__c = pb.Id;
        line.SBQQ__PackageProductCode__c = 'NCV';
        insert line; //
        
        SBQQ__QuoteLine__c cline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro.Id);
        cline.SBQQ__RequiredBy__c=line.Id;
        cline.SBQQ__Bundled__c=false;
        cline.SBQQ__BundledQuantity__c=1;
        cline.SBQQ__ListPrice__c = 186000;
        cline.BOM_Line_Number__c='2';
        cline.SBQQ__OptionType__c = 'Component';
        cline.SBQQ__Quantity__c = 1;
        cline.SBQQ__PricebookEntryId__c = pbe.Id;
        insert cline;
        
        /*****/
        
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p1.Id);
        line1.SBQQ__ListPrice__c = 0;
        line1.BOM_Line_Number__c='1';
        line1.SBQQ__Quantity__c = 4;
        line1.SBQQ__PricebookEntryId__c = pb1.Id;
        line1.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line1.Default_Factory__c ='FGI-FLEX-A';
        insert line1; //
        
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro10.Id);
        line2.SBQQ__RequiredBy__c=line1.Id;
        line2.SBQQ__Bundled__c=false;
        line2.SBQQ__BundledQuantity__c=1;
        line2.SBQQ__ListPrice__c = 0;
        line2.BOM_Line_Number__c='1';
        line2.SBQQ__Quantity__c = 4;
        line2.SBQQ__PricebookEntryId__c = pbe10.Id;
        line2.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line2.Default_Factory__c ='FGI-FLEX-A';
        insert line2;
        
        SBQQ__QuoteLine__c line3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro20.Id);
        line3.SBQQ__RequiredBy__c=line1.Id;
        line3.SBQQ__Bundled__c=false;
        line3.SBQQ__BundledQuantity__c=1;
        line3.SBQQ__ListPrice__c = 0;
        line3.SBQQ__ListPrice__c = 0;
        line3.BOM_Line_Number__c='1';
        line3.SBQQ__Quantity__c = 4;
        line3.SBQQ__PricebookEntryId__c = pbe20.Id;
        line3.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line3.Default_Factory__c ='FGI-FLEX-A';
        insert line3;
        
        
        SBQQ__QuoteLine__c line4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=pro30.Id);
        line4.SBQQ__RequiredBy__c=line1.Id;
        line4.SBQQ__Bundled__c=false;
        line4.SBQQ__BundledQuantity__c=1;
        line4.SBQQ__ListPrice__c = 0;
        line4.SBQQ__ListPrice__c = 0;
        line4.BOM_Line_Number__c='1';
        line4.SBQQ__Quantity__c = 4;
        line4.SBQQ__PricebookEntryId__c = pbe30.Id;
        line4.SBQQ__PackageProductCode__c = 'HF20-2OBT-21T-M';
        line4.Default_Factory__c ='FGI-FLEX-A';
        insert line4;
        
        
        /****/
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        salesOrderController.isBlankFactory = true;
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
       
        PageReference pref = target.onOverrideNew();
        
        
        so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
       
        
        test.stopTest();
        target = new SalesOrderController(new ApexPages.StandardController(so));
        
        System.assert(target.lineItemRows != null); 
        system.assert(target.lineItemRows.size()!= null);
        System.assertEquals(17, target.lineItemRows.size());
        
        for(Integer i=0; i< target.lineItemRows.size(); i++){
            target.lineItemRows[i].selected = true;
        
        }
        pref = target.onAddLinesAFA();
       
        
    }

    } // end of class