/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        May 13, 2016
Purpose             :        Test class for QuoteLine Triggers and classes. This test class covers the following:
                             
                             Trigger:
                             1) QuoteLineBeforeCustom.trigger
                              
                             Apex Class:
                             1) QuoteLineTriggerHandler
                             2) QuoteLineTriggerHelper
                            

**************************************************************************************************************************************/
@isTest(seeAllData=true)
private class QuoteLineTriggerTest {
    private testMethod static void TestMethod1(){
        string key = 'test';
        List<Account> accList = NMBL_testUtil.createAccount(key,1,true);
        List<Opportunity> oppList = NMBL_testUtil.createOpportunity(key,1, accList.get(0),true);
        List<Product2> prdList = NMBL_TestUtil.createProduct2('AFA', 1, 'AFA', 'All Flash Array','', null, true);
        List<SBQQ__Quote__c> quoteList = NMBL_TestUtil.createQuote(key, 1, oppList.get(0), true);
        
        
        Product2 nga = new Product2(IsActive=true,Name='NGA',ProductCode='NGA-CS300');
        Product2 afs = new Product2(IsActive=true,Name='AFS',ProductCode='AFS',Family='AFS');
        Product2 afa = new Product2(IsActive = true, Name = 'AFA', ProductCode = 'AFA', Family = 'All Flash Array', Product_Type_2__c ='All Flash Array', parent_product__c= true);
        Product2 afassd = new Product2(IsActive = true, Name = 'AF-SSD', ProductCode = 'AF-SSD', Family = 'All Flash Array');
        Product2 afassd1 = new Product2(IsActive = true, Name = 'AF-SSD1', ProductCode = 'AF-16T', Family = 'All Flash Array');
        Product2 Cache = new Product2(IsActive=true,Name='Cache',ProductCode='Cache',Family='Cache');
        Product2 afsFlc = new Product2(IsActive=true,Name='AFS-FLC-9999',ProductCode='AFS-FLC-9999',SSD_Capacity__c=9999);
        Product2 es1 = new Product2(IsActive=true,Name='ES1',ProductCode='ES1-',Family='Expansion Shelves');
        Product2 m2 = new Product2(IsActive=true,Name='ES1CBLG2-1M',ProductCode='ES1CBLG2-1M');
        Product2 m1 = new Product2(IsActive=true,Name='CS210',ProductCode='CS210');
        Product2 afaAFS2 = new Product2(IsActive =true, Name='AFA=AFS2', ProductCode = 'AFA-AFS2', Product_Type_2__c='AFS', Product_sub_type__c='Shelf 1');
        Product2 afa3000 = new Product2(IsActive =true, Name='AF3000', ProductCode = 'AF3000', Product_Type_2__c='Controller', Product_sub_type__c='Shelf 1');
        Product2 afs2_11T = new Product2(IsActive=true,Name='AFS2-11T',ProductCode='AFS2-11T',SSD_Capacity__c=11, Product_Type_2__c='AFS');
        Product2 af_11T = new Product2(IsActive=true,Name='AF-11T',ProductCode='AF-11T',SSD_Capacity__c=11520, Product_Type_2__c='SSD Capacity');
        insert new Product2[]{nga,afs,afsFlc,es1,m2,m1, afa, afassd, afassd1, afaAFS2, afa3000,afs2_11T,af_11T};
    
        Asset[] assetList = new Asset[0];
        assetList.add(new Asset(Name='Test Asset', AccountId = accList[0].id, Product2id = nga.id));
        assetList.add(new Asset(Name='Test Asset2', AccountId = accList[0].id, Product2id = afa.id));
        insert assetList;
        
        test.startTest();
        SBQQ__QuoteLine__c[] lines = new SBQQ__QuoteLine__c[0];
        
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=1,SBQQ__Product__c=nga.Id,SBQQ__Quantity__c=1,SBQQ__ListPrice__c=10000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=2,SBQQ__Product__c=afs.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=3,SBQQ__Product__c=afsFlc.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=100,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=4,SBQQ__Product__c=es1.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=100,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=5,SBQQ__Product__c=m1.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=100,SBQQ__Incomplete__c=true,SBQQ__SubscriptionPricing__c='Percent Of Total'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=6,SBQQ__Product__c=m2.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=100,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=7,SBQQ__Product__c=afa.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true, SBQQ__UpgradedAsset__c = assetList[1].id, Support_Term__c = '12'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=8,SBQQ__Product__c=afassd.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true, SBQQ__OptionLevel__c=1));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=9,SBQQ__Product__c=afassd1.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true, SBQQ__OptionLevel__c=2));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=10,SBQQ__Product__c=afaAFS2.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true, Support_Term__c='12'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=11,SBQQ__Product__c=afa3000.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true, SBQQ__OptionLevel__c=1,SBQQ__PackageProductCode__c ='AF3000-20BT-21T-2'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=12,SBQQ__Product__c=afs2_11T.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true, SBQQ__OptionLevel__c=2));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteList[0].Id,SBQQ__Number__c=13,SBQQ__Product__c=af_11T.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true,SBQQ__OptionLevel__c=2));
        utility.runDupRecTrigger=false;
        insert lines;
        
        lines[1].SBQQ__RequiredBy__c = lines[0].Id;
        lines[2].SBQQ__RequiredBy__c = lines[1].Id;
        lines[3].SBQQ__RequiredBy__c = lines[2].Id;
        lines[4].SBQQ__RequiredBy__c = lines[1].Id;
        lines[5].SBQQ__RequiredBy__c = lines[1].Id;
        //lines[6].SBQQ__RequiredBy__c = lines[0].Id;
        lines[7].SBQQ__RequiredBy__c = lines[6].Id;
        lines[8].SBQQ__RequiredBy__c = lines[7].Id;
        lines[9].SBQQ__RequiredBy__c = lines[6].Id;    //added by Unnat
        lines[10].SBQQ__RequiredBy__c = lines[6].Id;
        lines[11].SBQQ__RequiredBy__c = lines[9].Id;
        lines[12].SBQQ__RequiredBy__c = lines[6].Id;
        
        lines[0].SBQQ__Incomplete__c = false;
        lines[1].SBQQ__Incomplete__c = false;
        lines[2].SBQQ__Incomplete__c = false;
        lines[3].SBQQ__Incomplete__c = false;
        lines[4].SBQQ__Incomplete__c = false;
        lines[5].SBQQ__Incomplete__c = false;
        lines[6].SBQQ__Incomplete__c = false;
        lines[7].SBQQ__Incomplete__c = false;
        lines[8].SBQQ__Incomplete__c = false;
        lines[9].SBQQ__Incomplete__c = false;    //added by unnat
        lines[10].SBQQ__Incomplete__c = false;
        lines[11].SBQQ__Incomplete__c = false;
        lines[12].SBQQ__Incomplete__c = false;
        
        //lines[6].SBQQ__Incomplete__c = false;
        lines[2].SBQQ__ComponentDiscountedByPackage__c = true;
        lines[6].SBQQ__ComponentDiscountedByPackage__c = true;
        lines[1].SBQQ__Discount__c = 10;
        lines[1].Component_Description__c = 'Test';
        lines[2].SBQQ__AdditionalDiscountAmount__c = 10;
        lines[1].SBQQ__RegularPrice__c = 1000;    //added by unnat
        lines[1].Distributor_Discount__c=20;
        lines[1].Distributor_uplift__c=5;
        lines[1].reseller_Discount__c = 10;
        lines[1].prior_reseller_Discount__c =0;
        
        utility.runDupRecTrigger=false;
        update lines;
    
        QuoteLineTriggerHandler handler= new QuoteLineTriggerHandler (null, lines);
        
        QuoteLineTriggerHelper helper= new QuoteLineTriggerHelper ();
        helper.restructureFormulaFields(lines);
    
    test.stopTest();
    
    }

    //Test Deal Guidance part
    private testMethod static void TestMethod2(){
  
        List<SBQQ__QuoteLine__c> quoteLine_List=new List<SBQQ__QuoteLine__c>();
        Account a = new Account(Name='Test');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true);
        insert quote;
    
        Product2[] prdList = new Product2[0];
        prdList.add(new Product2(Name='C1K',IsActive=true,Productcode='C1K',SBQQ__OptionLayout__c='Tabs'));
        prdList.add(new Product2(Name='AF5000',IsActive=true,Productcode='AF5000',SBQQ__OptionLayout__c='Tabs'));
        prdList.add(new Product2(Name='AF9000',IsActive=true,Productcode='AF9000',SBQQ__OptionLayout__c='Tabs'));
        prdList.add(new Product2(Name='UPGD-AF-6T',IsActive=true,Productcode='UPGD-AF-6T',Family='Upgrade', Product_Type_2__c='Cache'));
        
        insert prdList;
        
        SBQQ__QuoteLine__c[] qliList = new SBQQ__QuoteLine__c[0];
        qliList.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=prdList[0].Id, SBQQ__PackageProductCode__c ='C1K-20BT-84T-EF',
                                         SBQQ__ListPrice__c = 1000,BOM_Line_Number__c='1',SBQQ__Quantity__c = 1,SBQQ__NetPrice__c =100,
                                         SBQQ__UnitCost__c=25,Adjusted_Margin_Percent_N__c =67
                                         ));
        qliList.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=prdList[1].Id, SBQQ__PackageProductCode__c ='AF5000-20BT-42T-1',
                                         SBQQ__ListPrice__c = 1000,BOM_Line_Number__c='1',SBQQ__Quantity__c = 1,SBQQ__NetPrice__c =100,
                                         SBQQ__UnitCost__c=25,Adjusted_Margin_Percent_N__c =67
                                         ));
        qliList.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=prdList[2].Id, SBQQ__PackageProductCode__c ='AF9000',
                                         SBQQ__ListPrice__c = 1000,BOM_Line_Number__c='1',SBQQ__Quantity__c = 1,SBQQ__NetPrice__c =100,
                                         SBQQ__UnitCost__c=25,Adjusted_Margin_Percent_N__c =67
                                         ));
        qliList.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=prdList[3].Id, SBQQ__PackageProductCode__c ='UPGD-AF-6T',
                                         SBQQ__ListPrice__c = 1000,BOM_Line_Number__c='1',SBQQ__Quantity__c = 1,SBQQ__NetPrice__c =100,
                                         SBQQ__UnitCost__c=25,Adjusted_Margin_Percent_N__c =67
                                         ));
        insert qliList;
        
        QuoteLineTriggerHelper helper= new QuoteLineTriggerHelper ();
        helper.restructureFormulaFields(quoteLine_List);
        
        
    }
}