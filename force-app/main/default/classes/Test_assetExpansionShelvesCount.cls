@isTest
public class Test_assetExpansionShelvesCount{
  
    static testmethod void test6(){ 

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        PermissionSet p = [select Id from PermissionSet where Name='ByPassAssetsValidation'];
        
        User u = new User();
        u.LastName ='JohnTest';
        u.alias ='JDoeTest';
        u.email= 'Test@J.com';
        u.username='jdoe@hpe.test.com';
        u.CommunityNickname = 'jdoe';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey='en_US';
        u.EmailEncodingKey='UTF-8';
        u.ProfileId= profileId.Id;
        u.LanguageLocaleKey='en_US';
        insert u;
        
       
        
        
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = P.Id);
        List<Product2> lst = new list<Product2>();
        List<Asset> assetList = new List<Asset>();
        system.runAs(u){
            Product2 pro1=new Product2();
            pro1.Name='AFS3';
            pro1.Component_Code__c='AFS3';
            pro1.ProductCode='AFS3';
            pro1.Asset_Type__c='AFS3';
            pro1.Family='All Flash Shelf';
            lst.add(pro1);
            
            Product2 pro2=new Product2();
            pro2.Name='AFS3-23T';
            pro2.Component_Code__c='23040';
            pro2.ProductCode='AFS3-23T';
            pro2.Asset_Type__c='AFS3';
            pro2.Family='All Flash Shelf';
            pro2.Infosight_Identifier__c = '23T';
            lst.add(pro2);
            
            Product2 pro3=new Product2();
            pro3.Name='AF60';
            pro3.Component_Code__c='HF40';
            pro3.ProductCode='HF40';
            pro3.Asset_Type__c='HFA';
            pro3.infosight_identifier__c='HF40';
            pro3.HPE_SKU__C='Q8H39A';
            pro3.Family='All Flash Array';
            //insert pro;
            lst.add(pro3);
             
            insert lst;
            
            
            Account acc=new Account();
            acc.Name='test acc';
            acc.Datacenter_Care__c = false;
            acc.ACM_Service_Purchased__c =false;
            insert acc;
            
            
            Contact con= new Contact();
            con.LastName='last';
            con.Email='test@gmail.com';
            
            con.AccountId=acc.Id;
            insert con;
    
            test.starttest();
            Asset ast3 = new Asset(
            Name = 'testNextGenCLS',
            //AccountId = acc.id,
            ContactId = con.id,
            //Opportunity_Asset__c    = opp.id,
            Product2Id = pro3.id,
            Dynamic_SKU__c= 'AF80-2P-23040F-1',
            Array_Controller__c = 'AF80',
            Array_Networking__c = '2P',
            array_Cache__c = '23040F',
            SSD_Bank_A__c = '23040F',
            status = 'Shipped',
            Order_Type__c = 'Test',
            IS_Array_Controller__c = 'AF80',
            IS_Array_Networking__c = '2P2F4QP', 
            IS_Array_Capacity__c = '23T',           
            Support_End_Date__c = system.today()+365, 
            SLA__c = 'Premium 4 Hour Onsite',
            serialnumber = 'testNextGenCLS',
            Support_Start_Date_Asset__c = system.today());
            
            insert ast3;
            
            Asset a =new Asset();
            a.ContactId=con.Id;
            //a.AccountId=acc.Id;
            a.Order_Type__c = 'Purchased';
            a.Name='test';
            a.Product2Id=pro1.id;
            a.Dynamic_SKU__c='AFS3-46080-2';
            a.Shelf_Pack_1__c = '23040';
            a.Shelf_Pack_2__c ='23040';
            a.HPE_Serial_Number__c = 'AFS3Test';
            a.Parent_Asset__c = ast3.Id;
            a.SLA__c = 'Premium 4 Hour Onsite';
            a.serialnumber='AFS3Test';
            assetList.add(a);
            
            Asset a1 =new Asset();
            a1.ContactId=con.Id;
            //a.AccountId=acc.Id;
            a1.Order_Type__c = 'Purchased';
            a1.Name='test';
            a1.Product2Id=pro1.id;
            a1.Dynamic_SKU__c='AFS3-46080-2';
            a1.Shelf_Pack_1__c = '23040';
            a1.Shelf_Pack_2__c ='23040';
            a1.HPE_Serial_Number__c = 'AFS3Test1';
            a1.Parent_Asset__c = ast3.Id;
            a1.SLA__c = 'Premium 4 Hour Onsite';
            a1.serialnumber='AFS3Test1';
            
            assetList.add(a1);
            
            insert assetList;
            
            test.stoptest();
        }
    }
}