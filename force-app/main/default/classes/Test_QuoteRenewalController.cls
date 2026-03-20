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
@isTest(SeeAllData=true)
private class Test_QuoteRenewalController {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Pricebook2 spb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        
        Pricebook2 spb1 = new Pricebook2(Is_Toshiba__c = true, Name='Test Price Book', CurrencyIsoCode='USD', IsActive = true );
        insert spb1;
        
        Account acct = new Account(Name='Test');
        insert acct;
        
        Product2 hw = new Product2(Name='Array',IsActive=true,ProductCode='CS9999',SBQQ__SubscriptionCategory__c='CS2XX', Controller_Code__c = 'ES1-AFS-H65');
        Product2 sla = new Product2(Name='SLA',IsActive=true,ProductCode='SLA-NBD-CS9999',SBQQ__SubscriptionCategory__c='CS2XX',SBQQ__SubscriptionPercent__c=5, Controller_Code__c = 'ES1-AFS-H65');
        insert new Product2[]{hw,sla};
        

        Asset asset = new Asset(Name='Test', HPE_Serial_Number__c='abcd333dd3', SLA__c ='Premium 4 Hour',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1), assetNrdStartDate__c = System.Today());
        insert asset;
        
        Asset assetNBD = new Asset(Name='Test', HPE_Serial_Number__c='abcd33d333', SLA__c ='Premium',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1), assetNrdStartDate__c = System.Today());
        //insert assetNBD;
        
        /*Asset asset4ON = new Asset(Name='Test', SLA__c ='Premium 4 Hour Onsite',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1), assetNrdStartDate__c = System.Today());
        insert asset4ON;
        
        Asset assetNBO = new Asset(Name='Test', SLA__c ='TSC: Premium Onsite',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1), assetNrdStartDate__c = System.Today());
        insert assetNBO;
        */
        insert new PricebookEntry(Pricebook2Id=spb.Id,Product2Id=hw.Id,UnitPrice=1000,IsActive=true);
        insert new PricebookEntry(Pricebook2Id=spb1.Id,Product2Id=hw.Id,UnitPrice=1000,IsActive=true);
        
        Opportunity opp = new Opportunity(Name='Test',AccountId=acct.Id,Pricebook2Id=spb1.Id,StageName='Prospecting',CloseDate=System.today(),HPE_Opportunity_ID__c='OPE-1234567899');
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id);
        insert quote;
        
        test.starttest();
        //Asset support Level is 4HR
        QuoteRenewalController target = new QuoteRenewalController(new ApexPages.StandardController(quote));
        //System.assertEquals(1, target.assets.size());
        target.selectedAssetId = target.assets[0].Id;
        target.onSelectToRenew();
        target.supportLevel = '4HR';
        target.supportTerm = 36;
        target.NRDTerm = 36;
        target.viewNRD = true;
        target.viewSupport = true;
        target.onUpgradeRenew();
        
        //Asset support Level is NBD
        QuoteRenewalController target1 = new QuoteRenewalController(new ApexPages.StandardController(quote));
        //System.assertEquals(1, target1.assets.size());
        target1.selectedAssetId = target1.assets[0].Id;
        target1.onSelectToUpgrade();
        target1.supportLevel = '4HR';
        target1.supportTerm = 36;
        target1.NRDTerm = 36;
        target1.viewNRD = true;
        target1.viewSupport = true;
        target1.onUpgradeRenew();
        
        target1 = new QuoteRenewalController(new ApexPages.StandardController(quote));
        //System.assertEquals(1, target1.assets.size());
        target1.selectedAssetId = target1.assets[0].Id;
        target1.onSelectToUpgrade();
        target1.supportLevel = '4HR';
        target1.supportTerm = 36;
        target1.onCancel();
        test.stoptest();
    }
    
    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        
        Pricebook2 spb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        
        Pricebook2 spb1 = new Pricebook2(Is_Toshiba__c = true, Name='Test Price Book', CurrencyIsoCode='USD', IsActive = true );
        insert spb1;
        
        Account acct = new Account(Name='Test', ACM_End_Date__c=System.today(), ACM_Service_Purchased__c=true, ACM_Service_Purchased_Quantity__c = 4);
        insert acct;
        
        Product2 hw = new Product2(Name='Array',IsActive=true,ProductCode='CS9999',SBQQ__SubscriptionCategory__c='CS2XX', Controller_Code__c = 'ES1-AFS-H65');
        Product2 sla = new Product2(Name='SLA',IsActive=true,ProductCode='SLA-NBD-CS9999',SBQQ__SubscriptionCategory__c='CS2XX',SBQQ__SubscriptionPercent__c=5, Controller_Code__c = 'ES1-AFS-H65');
        insert new Product2[]{hw,sla};
        

        Asset asset = new Asset(Name='Test', HPE_Serial_Number__c='abcd333dd',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1), assetNrdStartDate__c = System.Today());
        insert asset;
        
        insert new PricebookEntry(Pricebook2Id=spb.Id,Product2Id=hw.Id,UnitPrice=1000,IsActive=true);
        insert new PricebookEntry(Pricebook2Id=spb1.Id,Product2Id=hw.Id,UnitPrice=1000,IsActive=true);
        
        Opportunity opp = new Opportunity(Name='Test',AccountId=acct.Id,Pricebook2Id=spb1.Id,StageName='Prospecting',CloseDate=System.today(),HPE_Opportunity_ID__c='OPE-2345678901');
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id);
        insert quote;
        test.starttest();
        QuoteRenewalController target = new QuoteRenewalController(new ApexPages.StandardController(quote));
        target.selectedQuoteLineId = quote.Id;
        System.assertEquals(1, target.assets.size());
        target.selectedAssetId = target.assets[0].Id;
        target.onSelectCM();
        target.supportTermCM = String.valueOf('16');
        target.CMQuantity = Decimal.valueOf('6');
        target.onRenewCM();
        test.stoptest();
    }
    
    
    static testMethod void myUnitTest3() {
        // TO DO: implement unit test
        
        Pricebook2 spb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        
        Pricebook2 spb1 = new Pricebook2(Is_Toshiba__c = true, Name='Test Price Book', CurrencyIsoCode='USD', IsActive = true );
        insert spb1;
        
        Account acct = new Account(Name='Test');
        insert acct;
        
        Product2 hw = new Product2(Name='Array',IsActive=true,ProductCode='CS9999',SBQQ__SubscriptionCategory__c='CS2XX', Controller_Code__c = 'ES1-AFS-H65');
        Product2 sla = new Product2(Name='SLA',IsActive=true,ProductCode='SLA-NBD-CS9999',SBQQ__SubscriptionCategory__c='CS2XX',SBQQ__SubscriptionPercent__c=5, Controller_Code__c = 'ES1-AFS-H65');
        insert new Product2[]{hw,sla};
        

        Asset asset4ON = new Asset(Name='Test', HPE_Serial_Number__c='abcd33d', SLA__c ='Premium 4 Hour Onsite',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1), assetNrdStartDate__c = System.Today());
        insert asset4ON;
        
        Asset assetNBO = new Asset(Name='Test', HPE_Serial_Number__c='abcd333',SLA__c ='TSC: Premium Onsite',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1), assetNrdStartDate__c = System.Today());
        //insert assetNBO;
        
        insert new PricebookEntry(Pricebook2Id=spb.Id,Product2Id=hw.Id,UnitPrice=1000,IsActive=true);
        insert new PricebookEntry(Pricebook2Id=spb1.Id,Product2Id=hw.Id,UnitPrice=1000,IsActive=true);
        
        Opportunity opp = new Opportunity(Name='Test',AccountId=acct.Id,Pricebook2Id=spb1.Id,StageName='Prospecting',CloseDate=System.today(),HPE_Opportunity_ID__c='OPE-3456789012');
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id);
        insert quote;
        
        test.starttest();
        //Asset support Level is 4HR
        QuoteRenewalController target = new QuoteRenewalController(new ApexPages.StandardController(quote));
        //System.assertEquals(1, target.assets.size());
        target.selectedAssetId = target.assets[0].Id;
        target.onSelectToRenew();
        target.supportLevel = '4HR';
        target.supportTerm = 36;
        target.NRDTerm = 36;
        target.viewNRD = true;
        target.viewSupport = true;
        target.onUpgradeRenew();
        
        //Asset support Level is NBD
        QuoteRenewalController target1 = new QuoteRenewalController(new ApexPages.StandardController(quote));
        //System.assertEquals(1, target1.assets.size());
        target1.selectedAssetId = target1.assets[0].Id;
        target1.onSelectToUpgrade();
        target1.supportLevel = '4HR';
        target1.supportTerm = 36;
        target1.NRDTerm = 36;
        target1.viewNRD = true;
        target1.viewSupport = true;
        target1.onUpgradeRenew();
        test.stoptest();
        
    }
    //Non-Toshiba quotes
    static testMethod void myUnitTest4() {
        // TO DO: implement unit test
        
        Pricebook2 spb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        
        Account acct = new Account(Name='Test');
        insert acct;
        
        Product2 hw = new Product2(Name='Array',IsActive=true,ProductCode='CS9999',SBQQ__SubscriptionCategory__c='CS2XX', Controller_Code__c = 'ES1-AFS-H65');
        Product2 sla = new Product2(Name='SLA',IsActive=true,ProductCode='SLA-NBD-CS9999',SBQQ__SubscriptionCategory__c='CS2XX',SBQQ__SubscriptionPercent__c=5, Controller_Code__c = 'ES1-AFS-H65');
        insert new Product2[]{hw,sla};
        
        Asset assetNBD = new Asset(Name='Test',HPE_Serial_Number__c='abcd334', SLA__c ='Premium',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1), assetNrdStartDate__c = System.Today());
        insert assetNBD;
        
        Asset asset4ON = new Asset(Name='Test', HPE_Serial_Number__c='abcd333', SLA__c ='Premium 4 Hour Onsite',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1), assetNrdStartDate__c = System.Today());
        //insert asset4ON;
        
        insert new PricebookEntry(Pricebook2Id=spb.Id,Product2Id=hw.Id,UnitPrice=1000,IsActive=true);
        
        Opportunity opp = new Opportunity(Name='Test',AccountId=acct.Id,Pricebook2Id=spb.Id,StageName='Prospecting',CloseDate=System.today(),HPE_Opportunity_ID__c='OPE-1234556789');
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id);
        insert quote;
        
        test.starttest();
        //Asset support Level is 4HR
        QuoteRenewalController target = new QuoteRenewalController(new ApexPages.StandardController(quote));
        //System.assertEquals(1, target.assets.size());
        target.selectedAssetId = target.assets[0].Id;
        target.onSelectToRenew();
        target.supportLevel = '4HR';
        target.supportTerm = 36;
        target.NRDTerm = 36;
        target.viewNRD = true;
        target.viewSupport = true;
        target.onUpgradeRenew();
        
        //Asset support Level is NBD
        QuoteRenewalController target1 = new QuoteRenewalController(new ApexPages.StandardController(quote));
        //System.assertEquals(1, target1.assets.size());
        target1.selectedAssetId = target1.assets[0].Id;
        target1.onSelectToUpgrade();
        target1.supportLevel = '4HR';
        target1.supportTerm = 36;
        target1.NRDTerm = 36;
        target1.viewNRD = true;
        target1.viewSupport = true;
        target1.onUpgradeRenew();
        test.stoptest();
    }
}