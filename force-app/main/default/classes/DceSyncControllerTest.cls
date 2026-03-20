/**
    * Test Class Name: DCESyncControllerTest
    * Created By: Jana Reddy
    * Created Date: 3/23/2023
    *
    * Description:
    * This Salesforce Apex test class is used to test the DCESyncController class.
    * It inserts test records, sets created dates, and schedules the batch job for testing.
    *
    * Usage:
    * - Use this test class to validate the functionality of DCESyncController class.
*/
@istest(SeeAllData=true)
public class DceSyncControllerTest {
    static testMethod void ContactInsert() {
        String DceSynUser = System.Label.DCESyncUser;  
        user myTestUser = [Select Id from User where id=:DceSynUser];  
        System.runAs(myTestUser) {
          //  test.startTest();
            system.debug('---myTestUser----'+myTestUser);
            List<Contact> conlist=new list<Contact>();
            Product2 pro=new Product2();
            pro.Name='test';
            Pro.Component_Code__c='test1';
            pro.ProductCode='test1';
            pro.Asset_Type__c='test1';
            pro.infosight_identifier__c='test1';
            //pro.HPE_SKU__C='test1';
            pro.Family='Hybrid Flash Array';
            pro.asset_Type__c='test1';
            pro.Array_Controller__c='test1';
            insert pro;
            Account acc=new Account();
            acc.Name='test acc';
            insert acc;
            Contact con= new Contact();
            con.LastName='last';
            con.Email='test@gmail.com';
            con.AccountId=acc.Id;
            con.DCE_Onboarded__c=true;
            insert con;
            conlist.add(con);
            Asset a =new Asset();
            a.Array_Cache__c='test1-test1';
            a.Array_Capacity__c='test1';
            a.Array_Controller__c='AF3000';
            a.Array_Networking__c='test3';
            a.ContactId=con.Id;
            a.AccountId=acc.Id;
            a.Order_Type__c = 'Eval Unit';
            a.Array_Controller__c='test1';
            a.Name='test';
            a.Expansion_Shelf_Base__c='test1';
            a.Array_Networking__c='test1-test1';
            a.Product2Id=pro.id;
            a.Dynamic_SKU__c='ES3';
            a.SSD_Bank_A__c='test1';
            a.SSD_Bank_B__c='test1';
            a.HPE_Serial_Number__c= 'test1';
            insert a;
            case aCase = new Case(AccountId = acc.id,
                                  AssetId   = a.id,
                                  ContactId = con.id,
                                  status='New',
                                  Description='Testcase',
                                  Current_comment_time_spent__c = 10,
                                  DCE_Sync__c=false,
                                  isP2NCase__c =false,
                                  Subject = 'TEST-CASE-SUBJECT');
            insert aCase;  
            test.startTest();
            CaseComment cm=new CaseComment();
            cm.IsPublished=true;
            cm.CommentBody='Testing';
            cm.IsNotificationSelected=true;
            cm.ParentId=aCase.id;
            cm.IsPublished = true;
            Insert cm;
           /* DCE_Case_Sync__c testDceSync = new DCE_Case_Sync__c(
                Case__c = aCase.Id,
                RecordTypeId = Schema.SObjectType.DCE_Case_Sync__c.getRecordTypeInfosByName().get('CaseComments').getRecordTypeId(),
                CaseComment_ID__c = cm.Id,
                DCE_Sync__c = 'Create Pending',
                Subject__c = JSON.serialize(cm.Parent.Subject),
                Description__c = JSON.serialize(cm.Parent.Description),
                Comments__c = JSON.serialize(cm.CommentBody),
                commentCreatedAt__c = cm.CreatedDate
            );
            insert testDceSync;*/
            // DceSyncController.contactInsertDceSync(conlist);
            test.stopTest();
            
        }
    }
    static testMethod void contactupdate() {
        String DceSynUser = System.Label.DCESyncUser;  
        user myTestUser = [Select Id from User where id=:DceSynUser];  
        System.runAs(myTestUser) {
            system.debug('---myTestUser----'+myTestUser);
            List<Contact> conlist=new List<Contact>();
            Product2 pro=new Product2();
            pro.Name='test';
            Pro.Component_Code__c='test1';
            pro.ProductCode='test1';
            pro.Asset_Type__c='test1';
            pro.infosight_identifier__c='test1';
            //pro.HPE_SKU__C='test1';
            pro.Family='Hybrid Flash Array';
            pro.asset_Type__c='test1';
            pro.Array_Controller__c='test1';
            insert pro;
            Account acc=new Account();
            acc.Name='test acc';
            insert acc;
            Contact con= new Contact();
            con.LastName='last';
            con.Email='test@gmail.com';
            con.AccountId=acc.Id;
            con.DCE_Onboarded__c=false;
            insert con;
            Asset a =new Asset();
            a.Array_Cache__c='test1-test1';
            a.Array_Capacity__c='test1';
            a.Array_Controller__c='AF3000';
            a.Array_Networking__c='test3';
            a.ContactId=con.Id;
            a.AccountId=acc.Id;
            a.Order_Type__c = 'Eval Unit';
            a.Array_Controller__c='test1';
            a.Name='test';
            a.Expansion_Shelf_Base__c='test1';
            a.Array_Networking__c='test1-test1';
            a.Product2Id=pro.id;
            a.Dynamic_SKU__c='ES3';
            a.SSD_Bank_A__c='test1';
            a.SSD_Bank_B__c='test1';
            a.HPE_Support_SKU__c='HT6Z0AC';
            a.HPE_Service_Agreement_ID__c='108708226254';
            a.HPE_Serial_Number__c= 'test1';
            insert a;
            case aCase = new Case(AccountId = acc.id,
                                  AssetId   = a.id,
                                  ContactId = con.id,
                                  Severity__c='Critical',
                                  Current_comment_time_spent__c = 10,
                                  DCE_Sync__c=false,
                                  Status='New',
                                  
                                  Subject = 'TEST-CASE-SUBJECT');
            insert aCase;
            Contact cont=[select id,name,DCE_Onboarded__c,LastModifiedById from Contact where Id=:con.ID];
            cont.DCE_Onboarded__c=true;
            update cont;
            Map<Id,Contact> oldmap=new Map<Id,Contact>();
            oldmap.put(con.id,con);
            conlist.add(cont);
            test.startTest();

            CaseComment cm=new CaseComment();
            cm.IsPublished=true;
            cm.CommentBody='Testing';
            cm.IsNotificationSelected=true;
            cm.ParentId=aCase.id;
            Insert cm;
            DceSyncController.contactUpdateDceSync(conlist,oldmap);
            test.stopTest();
        }
    }
}