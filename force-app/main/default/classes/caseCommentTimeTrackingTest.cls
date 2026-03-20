@isTest
public class caseCommentTimeTrackingTest {
    static testMethod void createTestData()
    {
        Account          account;
        Contact          contact;
        Asset            asset;
        Case             aCase;
        List<Account>          accounts;
        List<Contact>          contacts;
        List<Asset>            assets;
        List<Case>             cases;
        ID testAccountId;
        ID testContactId;
        ID testAssetId;
        ID testCaseId;
        
        // Create test account
        account = new Account(Name = 'TEST-ACCOUNT');
        insert account;
        accounts = [SELECT Id,
                    Name
                    FROM   Account
                    WHERE  Name = 'TEST-ACCOUNT'];
        
        System.assertEquals(1,              accounts.size());
        System.assertEquals('TEST-ACCOUNT', accounts[0].Name);
        testAccountId = accounts[0].id;
        
        // Create test contact
        contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                              AccountId = testAccountId);
        insert contact;
        contacts = [SELECT Id,
                    LastName,
                    AccountId
                    FROM   Contact
                    WHERE  LastName = 'TEST-CONTACT-LAST-NAME'];
        
        System.assertEquals(1,                        contacts.size());
        System.assertEquals('TEST-CONTACT-LAST-NAME', contacts[0].LastName);
        System.assertEquals(testAccountId,            contacts[0].AccountId);
        testContactId = contacts[0].id;
        
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = testAccountId ,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst;
        
        test.startTest();
        
        // Create test case
        aCase = new Case(AccountId = testAccountId,
                         AssetId   = testAssetId,
                         ContactId = testContactId,
                         Current_comment_time_spent__c = 10,
                         Subject = 'TEST-CASE-SUBJECT',
                         Estimated_Effort__c = 'less than 5 minutes');
        insert aCase;
        cases = [SELECT Id,
                 AccountId,
                 AssetId,
                 ContactId,
                 Subject
                 FROM   Case
                 WHERE  Subject = 'TEST-CASE-SUBJECT'];
        
        CaseComment   tComment = new CaseComment();
        tComment.ParentId = aCase.Id;
        tComment.CommentBody = 'Test class comment';          
        insert tComment;  
        CaseCommentTimeTrackingVariable vb= new CaseCommentTimeTrackingVariable();
        set<Id> caseId = new set<Id>();  
        caseId.add(aCase.Id); 
        caseTrackingOwnerUpdation.updateCaseEffortOwner(caseId);
        test.stopTest();     
        
    }   
    
     static testMethod void testCaseEffortTracking(){
        Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
        insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        test.startTest();
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c='Flag',AssetId = asst1.Id, Status = 'Open', Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30 minutes');
        
        insert aCase;
        
        CaseComment tComment = new CaseComment();
        tComment.ParentId = aCase.Id;
        tComment.CommentBody = 'Test class comment';          
        insert tComment;  
        test.stopTest();     
    }  
    static testMethod void testCaseEffortTracking1(){
        Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
        insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        test.startTest();
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open', Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '2 hours');
        
        insert aCase;
        
        CaseComment tComment = new CaseComment();
        tComment.ParentId = aCase.Id;
        tComment.CommentBody = 'Test class comment';          
        insert tComment;  
        test.stopTest();     
    }   
    
    static testMethod void testCaseEffortTracking2(){
        Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
        insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        test.startTest();
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open', Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '2 days');
        
        insert aCase;
        
        CaseComment tComment = new CaseComment();
        tComment.ParentId = aCase.Id;
        tComment.CommentBody = 'Test class comment';          
        insert tComment;  
        test.stopTest();     
    } 
    
    static testMethod void testCaseEffortTracking3(){
        Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
        insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        test.startTest();
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open', Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '5 hours or less');
        
        insert aCase;
        
        CaseComment tComment = new CaseComment();
        tComment.ParentId = aCase.Id;
        tComment.CommentBody = 'Test class comment';          
        insert tComment;  
        test.stopTest();     
    } 

    static testMethod void testCaseEffortTracking4(){
        Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
        insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        test.startTest();
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open', Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '1 day or less');
        
        insert aCase;
        
        CaseComment tComment = new CaseComment();
        tComment.ParentId = aCase.Id;
        tComment.CommentBody = 'Test class comment';          
        insert tComment;  
        test.stopTest();     
    } 
    
    static testMethod void testCaseEffortTracking5(){
        Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
        insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        test.startTest();
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open', Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30');
        
        insert aCase;
        
        CaseComment tComment = new CaseComment();
        tComment.ParentId = aCase.Id;
        tComment.CommentBody = 'Test class comment';          
        insert tComment;  
        test.stopTest();     
    } 
    
    static testMethod void testCaseEffortTracking6(){
        Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
        insert acc1;
         
         //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Array_Controller_SKU__c = 'SD-Test'); 
                               
        insert asst1;
        test.startTest();
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open', Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30m');
        
        insert aCase;
        
        CaseComment tComment = new CaseComment();
        tComment.ParentId = aCase.Id;
        tComment.CommentBody = 'Test class comment';          
        insert tComment;  
        test.stopTest();     
    } 
    //Added by exafort for Legacy_CaseComment_AU_sendGSEMComments,Legacy_CaseComment_AI_EmalCasComenToOwnr,Legacy_CaseComment_BU_VerifNotificatonSP, and Legacy_CaseComment_AI_InsertOnParentCase
    @isTest(SeeAllData=true)
    static void testCaseEffortTracking_update(){
        
        user sv = [SELECT Id,Email, Name, ContactId from User where Isactive = true and id =:System.label.DCEIntegration_APIUser limit 1];//DCEIntegration_APIUser	 
        System.runAs(sv){
        
        Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
        insert acc1;
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                Array_Controller_SKU__c = 'SD-Test'); 
        
        insert asst1;
        //	test.startTest();
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open', Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30m');
        
        insert aCase;
        
        test.startTest();
//        user sv = [SELECT Id,Email, Name, ContactId from User where Isactive = true and id =:System.label.DCEIntegration_APIUser limit 1];//DCEIntegration_APIUser	 
//        System.runAs(sv){
            ActivateTrigger__c setting = new ActivateTrigger__c();
            setting.EmailCaseCommentsTrigger__c = true; setting.EmailCaseCommentsToOwnerTrigger__c = true;setting.SetupOwnerId = sv.id;        
            insert setting;
            
            CaseComment tComment = new CaseComment();
            tComment.ParentId = aCase.Id;
            tComment.CommentBody = 'Test class comment';          
            insert tComment; 
        	test.stopTest();
        }
        
        //test.stopTest();     
    } 
    
    @isTest(SeeAllData=true)
    static void testCaseEffortTracking_update1(){
        user sv = [SELECT Email, Name, ContactId,id from User where Isactive = true and id =:System.label.DCEIntegration_APIUser limit 1];//DCEIntegration_APIUser	         
        System.runAs(sv){
        Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
        insert acc1;
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                Array_Controller_SKU__c = 'SD-Test'); 
        
        insert asst1;
        
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open',
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                              Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30m',caseAttnReq__c = true);
        
        insert aCase;
        test.startTest();
        Case aCase1 = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open',
                               RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                               Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30m',caseAttnReq__c = true);
        
        insert aCase1;
        
        aCase.CaseMapping__c = aCase1.id;
        update acase;
//        user sv = [SELECT Email, Name, ContactId,id from User where Isactive = true and id =:System.label.DCEIntegration_APIUser limit 1];//DCEIntegration_APIUser	 
        
//        System.runAs(sv){
            ActivateTrigger__c setting = new ActivateTrigger__c();
            setting.EmailCaseCommentsTrigger__c = true; setting.EmailCaseCommentsToOwnerTrigger__c = true; setting.SetupOwnerId = sv.id;        
            insert setting;
            RecursiveCheck.runOnce = true;
            CaseComment tComment = new CaseComment();
            tComment.ParentId = aCase.Id;
            tComment.CommentBody = 'Test class comment';          
            insert tComment;
            tComment.CommentBody = 'Test class commen1t';
            update tComment;
        	test.stopTest();            
        }
    }
    
    static testMethod void testCaseEffortTracking_update2(){
         Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
         insert acc1;
         
         //create product
         Product2  p1 = new Product2();
         p1.Name = 'Test Product';
         p1.ProductCode = 'SD-Test';
         insert p1;
         
         //create asset
         Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test'); 
         
         insert asst1;
         test.startTest();
         
         // Create test case
         Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open',
                               RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                               Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30m',caseAttnReq__c = true);
         
         insert aCase;
         
         Case aCase1 = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                                Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30m',caseAttnReq__c = true);
         
         insert aCase1; test.stopTest();   
         aCase.CaseMapping__c = aCase1.id;
         update acase;
         
         TriggerSettings__c setting = new TriggerSettings__c();
         setting.Name = 'DceSyncUpdate';  
         insert setting;
         RecursiveCheck.runOnce = true;
         CaseComment tComment = new CaseComment();
         tComment.ParentId = aCase.Id;
         tComment.CommentBody = 'Test class comment';          
         insert tComment;
         tComment.CommentBody = 'Test class commen1t';
         update tComment;
       
    }
   
    //END
    @isTest(SeeAllData=true)
    static void testCaseEffortTracking_update3(){
        
        User Usr =[Select id,Name From User where Email in ('supportforce@nimblestorage.com.invalid','supportforce@nimblestorage.com') Limit 1];
        
        system.runAs(Usr){
            Account acc1 = new Account(Name = 'Test Account1');//, Support_Provider__c = supportProvider.Id);
            insert acc1;
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        Asset asst1 = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                AccountId = acc1.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                Array_Controller_SKU__c = 'SD-Test'); 
        
        insert asst1;
        test.startTest();
        
        // Create test case
        Case aCase = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open',
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                              Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30m',caseAttnReq__c = true);
        
        insert aCase;
        
        Case aCase1 = new Case(AccountId = acc1.Id, Current_comment_time_spent__c = 10, Current_comment_activity__c=null,AssetId = asst1.Id, Status = 'Open',
                               RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                               Subject = 'TEST-CASE-SUBJECT',Estimated_Effort__c = '30m',caseAttnReq__c = true);
        
        insert aCase1; test.stopTest();   
        
            
            ActivateTrigger__c act = New ActivateTrigger__c();
            act.EmailCaseCommentsTrigger__c = True;
           // upsert act;
            
            CaseComment tComment = new CaseComment();
            tComment.ParentId = aCase.Id;
            tComment.CommentBody = 'Test class comment'; 
            insert tComment;
            
        }
        

    }
}