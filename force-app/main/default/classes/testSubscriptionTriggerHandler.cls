@isTest(seeAllData =false)
public class testSubscriptionTriggerHandler{
    @isTest
    public static void testmethod1(){
        

        List<Product2> lstProduct = new List<Product2>();
        
        Product2 pro=new Product2();
        pro.Name='HF20';
        Pro.Component_Code__c='HF20';
        pro.ProductCode='HF20';
        pro.Asset_Type__c='test1';
        pro.infosight_identifier__c='HF20';
        pro.HPE_SKU__C='Q8H72A';
        pro.Family='Hybrid Flash Array';
        pro.IsActive = true;
        insert pro;
        
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
        
        insert lstProduct;
        
        Account Act = new Account( Name = 'Test Yesha Ac', Datacenter_Care__c = false, ACM_Service_Purchased__c = false);
        insert Act;
        
        
        Contact con1 = new Contact(LastName  = 'Doe',
                                             FirstName = 'John', email='venkat@ns.com',
                                             AccountId = act.Id);
        insert con1;
        Opportunity Opp = new Opportunity(Accountid = Act.id,name ='Test Sudhir Opp',CloseDate= system.today(),
                          Type='New Business', Sales_Area__c='NA COM West NorCal', StageName='Sales Forecast Category',
                          HPE_Opportunity_ID__c = 'OPE-0008891133');
                          
        insert Opp;
        
        Asset as1 = new Asset (Name = 'AF-Test', SerialNumber = 'AF-Test', accountId = act.Id, Opportunity_Asset__c = opp.Id,
                            contactId = con1.id,Array_Cache__c = '21T', Array_Capacity__c = '21T', SSD_Bank_A__c = '21T',SSD_Bank_B__c = '21T',
                            Array_Networking__c = '2OBT', Array_Controller__c = 'HF20', Product2Id = pro.Id);
        insert as1;
        
        test.startTest();
        Subscription__c s = new Subscription__c(Name='TestSub', CurrencyIsoCode = 'USD', Asset_SN__c = 'AF-Test');
        
        insert s;
        List<Subscription__c> lst = [select Id from Subscription__c];
        system.debug(' *** line 67 subscription ' + lst.size());            
        test.stopTest();
    }
}