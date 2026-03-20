@isTest(SeeAllData=True)
public class OpportunityProductsProcessTestClass {
    static testMethod void ExpansionShelves(){
		    
		List<Account> accList = NMBL_TestUtil.createAccount('OppAccTest', 1, true);
    
		List<Opportunity> oppList= NMBL_TestUtil.createOpportunity('OppProdTest', 1, accList[0], true);
    
		List<SBQQ__Quote__c> quoteList = NMBL_TestUtil.createQuote('qoute-Test', 1, oppList[0], true);
    
		List<Product2> productList  = NMBL_TestUtil.createProduct2('product-Test', 2, 'Test-product', 'Controller', null, 10, true);
           
		List<SBQQ__QuoteLine__c> quoteLineList= NMBL_TestUtil.createQuoteLine('quotelistTest', 1, quoteList[0], productList[0], true);    
        
        Pricebook2 spb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        
        insert new PricebookEntry(Pricebook2Id=spb.Id,Product2Id=productList[0].Id,UnitPrice=1000,IsActive=true);
        
        List<PricebookEntry> pbook= [select id from PricebookEntry where Pricebook2Id =: spb.Id and Product2Id=: productList[0].Id]; 
         
        for(Product2 op:productList ){
    		op.Family = 'Expansion Shelves';
            update op;
                    }
     List< OpportunityLineItem > oliList = new List< OpportunityLineItem >();
        
            OpportunityLineItem oli = new OpportunityLineItem();

            oli.OpportunityId = oppList[0].id;
            oli.SBQQ__QuoteLine__c = quoteLineList[0].id;
            oli.quantity = 10;
            oli.TotalPrice = 1000;
            oli.priceBookEntryId = pbook[0].id;
            
            oliList.add(oli);
            insert oliList;
        
     set<id> oppLineid = new set<id>();
        oppLineid.add(oliList[0].id);
        OpportunityProductsProcessClass.UpdateOpportunityProducts(oppLineid);
		
    }
     /*static testMethod void nonExpansionShelves(){
		    
		List<Account> accList = NMBL_TestUtil.createAccount('OppAccTest', 1, true);
    
		List<Opportunity> oppList= NMBL_TestUtil.createOpportunity('OppProdTest', 1, accList[0], true);
    
		List<SBQQ__Quote__c> quoteList = NMBL_TestUtil.createQuote('qouteTest', 1, oppList[0], true);
    
		List<Product2> productList  = NMBL_TestUtil.createProduct2('productTest', 2, 'Test-product', 'Controller', null, 1, true);
        
           for(Product2 op:productList ){
    		op.parent_product__c = true;
            update op;
                    }
    
		List<SBQQ__QuoteLine__c> quoteLineList= NMBL_TestUtil.createQuoteLine('quotelistTest', 1, quoteList[0], productList[0], true);    
        
        Pricebook2 spb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true limit 1];
        
        insert new PricebookEntry(Pricebook2Id=spb.Id,Product2Id=productList[0].Id,UnitPrice=1000,IsActive=true);
        
        List<PricebookEntry> pbook= [select id from PricebookEntry where Pricebook2Id =: spb.Id and Product2Id=: productList[0].Id]; 
         
        List< OpportunityLineItem > oliList = new List< OpportunityLineItem >();
        
       
            OpportunityLineItem oli = new OpportunityLineItem();

            oli.OpportunityId = oppList[0].id;
            oli.SBQQ__QuoteLine__c = quoteLineList[0].id;
            oli.quantity = 10;
            oli.TotalPrice = 1000;
            oli.priceBookEntryId = pbook[0].id;
            
            oliList.add(oli);  
     
            insert oliList;
          set<id> oppLineid = new set<id>();
        oppLineid.add(oliList[0].id);
        //OpportunityProductsProcessClass.UpdateOpportunityProducts(oppLineid);
    }*/
      static testMethod void parentProductTrue(){
		    
		List<Account> accList = NMBL_TestUtil.createAccount('OppAccTest', 1, true);
    
		List<Opportunity> oppList= NMBL_TestUtil.createOpportunity('OppProdTest', 1, accList[0], true);
    
		List<SBQQ__Quote__c> quoteList = NMBL_TestUtil.createQuote('qouteTest', 1, oppList[0], true);
    
		List<Product2> productList  = NMBL_TestUtil.createProduct2('productTest', 2, 'Test-product', 'Controller', null, 10, true);
        
    
		List<SBQQ__QuoteLine__c> quoteLineList= NMBL_TestUtil.createQuoteLine('quotelistTest', 1, quoteList[0], productList[0], true);    
        
        Pricebook2 spb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        
        insert new PricebookEntry(Pricebook2Id=spb.Id,Product2Id=productList[0].Id,UnitPrice=1000,IsActive=true);
        
        List<PricebookEntry> pbook= [select id from PricebookEntry where Pricebook2Id =: spb.Id and Product2Id=: productList[0].Id]; 
         
        List< OpportunityLineItem > oliList = new List< OpportunityLineItem >();
        
       
            OpportunityLineItem oli = new OpportunityLineItem();

            oli.OpportunityId = oppList[0].id;
            oli.SBQQ__QuoteLine__c = quoteLineList[0].id;
            oli.quantity = 10;
            oli.TotalPrice = 1000;
            oli.priceBookEntryId = pbook[0].id;
            
            oliList.add(oli);  
     
            insert oliList;
           set<id> oppLineid = new set<id>();
        oppLineid.add(oliList[0].id);
      OpportunityProductsProcessClass.UpdateOpportunityProducts(oppLineid);
    } 
}