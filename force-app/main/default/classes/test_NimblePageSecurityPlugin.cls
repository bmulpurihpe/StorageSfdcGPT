@isTest
private class test_NimblePageSecurityPlugin {

    static testMethod void myUnitTest() {
    
        System.debug('###### '+ [Select Profile.Name from User where Id =: userInfo.getUserId()].Profile.Name);
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',HPE_Opportunity_Id__C ='OPE-0000001234',CloseDate=System.today().addMonths(1));
        opp.Type='New Business';
        insert opp;
        
        Product2 p = new Product2(Name='Test',IsActive=true,Productcode='Test');
        p.ProductCode='pro';
        p.BOM_Level__c=1;
        p.Separate_Order_Line_Per_Unit__c=false;
        insert p;
        
        Product2 slaProd = new Product2(IsActive=true,Name='SLA-4ON-AFA',ProductCode='SLA-4ON-AFA', Product_Type_2__c='Support', Family ='Support', SBQQ__SubscriptionPercent__c=0.205);
        insert slaProd;
        
        List<Data_Reduction_Promise__c> drpList = NMBL_TestUtil.createDRP('test',1,opp,true);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=false,SBQQ__Status__c='Rejected');
        insert quote;
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.SBQQ__NetPrice__c=1000;
        line.SBQQ__RequiredBy__c=null;
        line.BOM_Line_Number__c='1';
        line.SBQQ__Quantity__c = 11;
        line.SBQQ__PackageProductCode__c='AF5000-20BT-42T-1';
        line.SBQQ__ProductOption__c=null;
        line.SBQQ__Renewal__c=true;
        line.SBQQ__OptionType__c='Component';
        line.SBQQ__ComponentDiscountedByPackage__c=true;
        line.Distributor_Discount__c=10;
        insert line;
        
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,BOM_Line_Number__c='2',SBQQ__Number__c=14,SBQQ__Product__c=slaProd.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500, SBQQ__SubscriptionPricing__c= 'Percent Of Total');
        
        
        NimblePageSecurityPlugin secPlugin = new NimblePageSecurityPlugin();
        boolean retval = secPlugin.isFieldEditable('EditLines',SBQQ__QuoteLine__c.SBQQ__Quantity__c);
        boolean retval2 = secPlugin.isFieldEditable('EditLines',SBQQ__QuoteLine__c.SBQQ__Quantity__c,line);
        boolean retval3 = secPlugin.isFieldVisible('EditLines',SBQQ__QuoteLine__c.SBQQ__Quantity__c);
        boolean retval4 = secPlugin.isFieldVisible('EditLines',SBQQ__QuoteLine__c.Distributor_Discount__c,line);
        boolean retval5 = secPlugin.isFieldEditable('EditLines',SBQQ__QuoteLine__c.Discount_Manual_Override__c,line);
        boolean retval6 = secPlugin.isFieldVisible('EditLines',SBQQ__QuoteLine__c.Discount_Manual_Override__c,line);
        boolean retval7 = secPlugin.isFieldVisible('EditLines',SBQQ__QuoteLine__c.DRP__c,line);
        boolean retval8 = secPlugin.isFieldVisible('EditLines',SBQQ__QuoteLine__c.DRP__c,line2);
    }
}