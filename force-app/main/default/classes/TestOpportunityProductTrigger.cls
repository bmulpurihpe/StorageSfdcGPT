/* Test method for the opportunityproduct trigger
* testMergedCodeCopy() methods tests the functionality of copying the 
* dynamic SKU to merged product code 
* SeeAllData = true to access the standard price book
*/
@istest(SeeAllData=false)
public class TestOpportunityProductTrigger 
{
    
    static testMethod void testMergedCodeCopy(){
        
        Account acc = createAccount();  
        Contact con = createContact('test@gmail.com', acc);
        
        String PROD_CODE = 'ES1-H25';
        List<Product2> productList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Name = 'TestProd 1';
        prod.ProductCode = PROD_CODE;
        prod.parent_product__c=true;
        productList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Name = 'TestProd 2';
        prod1.ProductCode = PROD_CODE;
        prod1.parent_product__c=false;
        prod1.Legacy_product__c=true;
        prod1.Product_Type_2__c='Capacity';
        productList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Name = 'TestProd 3';
        prod2.ProductCode = PROD_CODE;
        prod2.parent_product__c=false;
        prod2.Product_Type_2__c='Networking';
        prod2.Product_Sub_Type__c='FC';
        prod2.Family = 'Expansion Shelves';
        productList.add(prod2);
        
        Product2 prod3 = new Product2();
        prod3.Name = 'TestProd 4';
        prod3.ProductCode = PROD_CODE;
        prod3.parent_product__c=true;
        prod3.Product_Type_2__c='Networking';
        prod3.Product_Sub_Type__c='FC';
        prod3.Legacy_product__c=true;
        productList.add(prod3);
        
        insert productList;
        
        List<PriceBookentry> pbList = new List<PriceBookentry>();
        PriceBookentry pB = new PriceBookEntry();
        pB.IsActive = True;
        pB.CurrencyIsoCode = 'USD';
        pB.Pricebook2Id = Test.getStandardPricebookId();
        pB.UnitPrice = 10;
        pB.Product2Id = prod.Id;
        pbList.add(pB);
        
        PriceBookentry pB1 = new PriceBookEntry();
        pB1.IsActive = True;
        pB1.CurrencyIsoCode = 'USD';
        pB1.Pricebook2Id = Test.getStandardPricebookId();
        pB1.UnitPrice = 10;
        pB1.Product2Id = prod1.Id;
        pbList.add(pB1);
        
        PriceBookentry pB2 = new PriceBookEntry();
        pB2.IsActive = True;
        pB2.CurrencyIsoCode = 'USD';
        pB2.Pricebook2Id = Test.getStandardPricebookId();
        pB2.UnitPrice = 10;
        pB2.Product2Id = prod2.Id;
        pbList.add(pB2);
        
        PriceBookentry pB3 = new PriceBookEntry();
        pB3.IsActive = True;
        pB3.CurrencyIsoCode = 'USD';
        pB3.Pricebook2Id = Test.getStandardPricebookId();
        pB3.UnitPrice = 10;
        pB3.Product2Id = prod3.Id;
        pbList.add(pB3);
        
        insert pbList;
        
        Opportunity opp = createOpportunity(acc,con); 
        
        opp.SBQQ__QuotePricebookId__c = pB.Pricebook2Id;   
        opp.CurrencyIsoCode = pB.CurrencyIsoCode;
        opp.StageName = '2-Qualified';
        opp.Amount = 1000;
        update opp;
        
        
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Opportunity2__c = opp.Id;
        q.SBQQ__Primary__c=true;
        insert q;
        
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qL = new SBQQ__QuoteLine__c();
        qL.SBQQ__Quote__c = q.Id;
        qL.SBQQ__Product__c = prod.Id;
        qL.SBQQ__Quantity__c=1;
        qL.SBQQ__BundledQuantity__c=1;
        qL.SBQQ__ListPrice__c=1000;
        qL.SBQQ__Incomplete__c=true;
        qL.SBQQ__PackageProductCode__c = 'HEAD-FLC-1200GB-A';
        quoteLineItems.add(qL);
        
        SBQQ__QuoteLine__c qL1 = new SBQQ__QuoteLine__c();
        qL1.SBQQ__Quote__c = q.Id;
        qL1.SBQQ__RequiredBy__c=ql.id;
        qL1.SBQQ__Product__c = prod1.Id;
        qL1.SBQQ__Quantity__c=1;
        qL1.SBQQ__BundledQuantity__c=1;
        qL1.SBQQ__ListPrice__c=1000;
        qL1.SBQQ__Incomplete__c=true;
        quoteLineItems.add(qL1);
        
        SBQQ__QuoteLine__c qL2 = new SBQQ__QuoteLine__c();
        qL2.SBQQ__Quote__c = q.Id;
        qL2.SBQQ__RequiredBy__c=ql1.id;
        qL2.SBQQ__Product__c = prod2.Id;
        qL2.SBQQ__Quantity__c=1;
        qL2.SBQQ__BundledQuantity__c=1;
        qL2.SBQQ__ListPrice__c=1000;
        qL2.SBQQ__Incomplete__c=true;
        quoteLineItems.add(qL2);
        
        SBQQ__QuoteLine__c qL3 = new SBQQ__QuoteLine__c();
        qL3.SBQQ__Quote__c=q.Id;
        qL3.SBQQ__Product__c=prod3.Id;
        qL3.SBQQ__Quantity__c=1;
        qL3.SBQQ__BundledQuantity__c=1;
        qL3.SBQQ__ListPrice__c=1000;
        qL3.SBQQ__Incomplete__c=true;
        qL3.SBQQ__PackageProductCode__c='HEAD-FLC-1201GB';
        quoteLineItems.add(qL3);
        
        insert quoteLineItems;
        Test.startTest();
        // SBQQ__QuoteLine__c qL3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id,SBQQ__RequiredBy__c=ql1.id, SBQQ__Product__c = prod.Id);
        // insert qL3;
        list<OpportunityLineItem> opplist_Update=new list<OpportunityLineItem>();     
        /* Test case with product code starting with ES1 */       
        OpportunityLineItem oppLineItem = new OpportunityLineItem();    
        opplineitem.SBQQ__QuoteLine__c=qL1.Id;
        opplineitem.OpportunityId=opp.Id;
        opplineitem.Quantity=20;
        opplineitem.TotalPrice=1000;
        opplineitem.PriceBookEntryId=pB1.Id;
        opplist_Update.add(oppLineItem);
        //insert oppLineItem;
        //lI = [select Id, Merged_Product_Code_2__c, Product_Name_Dynamic__c from OpportunityLineItem where id =: oppLineItem.Id];
        // System.assertEquals(PROD_CODE.substring(0, 7),lI.Merged_Product_Code_2__c);
        
        /* Test case with product code starting with CS2 */
        PROD_CODE = 'CS210';
        prod.ProductCode = PROD_CODE;
        update prod;
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem();       
        opplineitem1.SBQQ__QuoteLine__c=qL2.Id;
        opplineitem1.OpportunityId=opp.Id;
        opplineitem1.Quantity=20;
        opplineitem1.TotalPrice=1000;
        opplineitem1.PriceBookEntryId=pB2.Id;
        opplineitem1.Product_Type_2__c='Networking';
        opplist_Update.add(oppLineItem1);
        
        //insert oppLineItem;
        // lI = [select Id, Merged_Product_Code_2__c, Product_Name_Dynamic__c from OpportunityLineItem where id =: oppLineItem.Id];
        // System.assertEquals(PROD_CODE.substring(0, 5),lI.Merged_Product_Code_2__c);
        
        /* Test case with product code starting with CS700- */
        PROD_CODE = 'CS700-3T-90T-111111';
        prod.ProductCode = PROD_CODE;
        update prod;
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem();      
        oppLineItem2.SBQQ__QuoteLine__c=qL3.Id;
        oppLineItem2.OpportunityId=opp.Id;
        oppLineItem2.Quantity=20;
        oppLineItem2.TotalPrice=1000;
        oppLineItem2.PriceBookEntryId=pB3.Id;
        opplist_Update.add(oppLineItem2);
        //  lI = [select Id, Merged_Product_Code_2__c, Product_Name_Dynamic__c from OpportunityLineItem where id =: oppLineItem.Id];
        // System.assertEquals(PROD_CODE.substring(0, 5) + PROD_CODE.substring(8,12),lI.Merged_Product_Code_2__c);
        
        /* Test case with product code starting with CS700 */ 
        PROD_CODE = 'CS700';
        prod.ProductCode = PROD_CODE;
        update prod;
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(); 
        oppLineItem3.SBQQ__QuoteLine__c=qL2.Id;
        oppLineItem3.OpportunityId=opp.Id;
        oppLineItem3.Quantity=20;
        oppLineItem3.TotalPrice=1000;
        oppLineItem3.PriceBookEntryId=pB2.Id;
        opplist_Update.add(oppLineItem3);
        
        //insert oppLineItem;
        // lI = [select Id, Merged_Product_Code_2__c, Product_Name_Dynamic__c from OpportunityLineItem where id =: oppLineItem.Id];
        //  System.assertEquals(PROD_CODE.substring(0, 5),lI.Merged_Product_Code_2__c);
        
        /* Test case with no product code */
        PROD_CODE = null;
        prod.ProductCode = PROD_CODE;
        update prod;     
        OpportunityLineItem oppLineItem4 = new OpportunityLineItem();  
        oppLineItem4.SBQQ__QuoteLine__c=qL.Id;
        oppLineItem4.OpportunityId=opp.Id;
        oppLineItem4.Quantity=20;
        oppLineItem4.TotalPrice=1000;
        oppLineItem4.PriceBookEntryId=pB.Id;
        opplist_Update.add(oppLineItem4);
        // Utility.runOppproducttrigger=true;
        Insert opplist_Update;
        //insert oppLineItem;
        //  lI = [select Id, Merged_Product_Code_2__c, Product_Name_Dynamic__c from OpportunityLineItem where id =: oppLineItem.Id];
        // System.assertEquals(null,lI.Merged_Product_Code_2__c);
        Test.stopTest();
    }
    
   
    
    private Static Account createAccount(){
        Account acc = new Account() ;
        acc.name = 'name';
        acc.CurrencyIsoCode = 'USD';
        insert acc;
        return acc;
    }
    
    private Static Contact createContact(String email, Account acc){
        Contact con = new Contact();
        con.lastname='lastname';
        con.email=email;
        con.Account = acc;
        insert con;
        return con;
    }
    private Static Opportunity createOpportunity(Account acc, Contact con){        
        Opportunity oppy = new Opportunity();
        oppy.name = 'name';
        oppy.Account = acc;
        oppy.Type = 'Existing Business';
        oppy.Sales_Area__c ='NA West North';
        oppy.First_Meeting_Date__c = System.today();
        oppy.CloseDate = System.today();
        oppy.First_Meeting_Results__c = 'Near-Team Opportunity (1-6 months)';
        oppy.First_Meeting_Set_By__c = 'Inside Sales';
        oppy.First_Meeting_Notes__c = 'Notes for inside sales';
        oppy.First_Meeting_Source__c = 'Self Prospected by Sales / Cold Call';
        // oppy.First_Meeting_Awareness_Level__c = 'Don’t Know / No Answer';
        oppy.First_Meeting_Score__c = '1 - Poor but acceptable';
        oppy.First_Meeting_Type__c = 'WebEx';
        oppy.First_Meeting_Network_Environment__c = 'ISCSI';
        oppy.StageName = '1-Prequalified';
        Oppy.Sales_Forecast_Category__c = 'Pipeline';
        Oppy.CurrencyIsoCode = 'USD';
        Oppy.Sales_Region__c= 'NA West';
        oppy.HPE_Opportunity_ID__c = 'OPE-1234567890';        
        insert oppy;
        return oppy;
    }
    
}