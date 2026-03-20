@isTest
private class caseTriggerNewCommentOnFieldUpdatesTest
  {// ==================================================================================== createNewCaseWithNullFields
   static testMethod void createNewCaseWithNullFields()
     {Case       aCase;
      List<Case> cases;

      // Create test case
      aCase = new Case(Subject = 'TEST-CASE-SUBJECT');

      insert aCase;

      cases = [SELECT Id,
                      Subject
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      System.assertEquals(1,                   cases.size());
      System.assertEquals('TEST-CASE-SUBJECT', cases[0].Subject);
     }

   // ==================================================================================== createNewCaseWithNonNullFields
   static testMethod void createNewCaseWithNonNullFields()
     {Case       aCase;
      List<Case> cases;

      // Create test case
      aCase = new Case(Subject              = 'TEST-CASE-SUBJECT',
                       caseCurrentStatus__c = 'CS-1',
                       casePlanOfAction__c  = 'PoA-1');

      insert aCase;

      cases = [SELECT Id,
                      Subject,
                      caseCurrentStatus__c,
                      casePlanOfAction__c
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      System.assertEquals(1,                   cases.size());
      System.assertEquals('TEST-CASE-SUBJECT', cases[0].Subject);
      System.assertEquals('CS-1',              cases[0].caseCurrentStatus__c);
      System.assertEquals('PoA-1',             cases[0].casePlanOfAction__c);
     }

   // ==================================================================================== testNewCaseWithNullFields
   static testMethod void testNewCaseWithNullFields()
     {List<Case>        cases;
      List<CaseComment> caseComments;
      ID                testCaseId;

      createNewCaseWithNullFields();

      cases = [SELECT Id,
                      caseCurrentStatus__c,
                      casePlanOfAction__c,
                      Subject
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      testCaseId = cases[0].Id;

      caseComments = [SELECT Id,
                             ParentId
                      FROM   CaseComment
                      WHERE  ParentId = :testCaseId];

      //System.assertEquals(0, caseComments.size());
     }

   // ==================================================================================== testNewCaseWithNonNullFields
   static testMethod void testNewCaseWithNonNullFields()
     {List<Case>        cases;
      List<CaseComment> caseComments;
      ID                testCaseId;

      createNewCaseWithNonNullFields();

      cases = [SELECT Id,
                      caseCurrentStatus__c,
                      casePlanOfAction__c,
                      Subject
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      testCaseId = cases[0].Id;

      caseComments = [SELECT Id,
                             ParentId,
                             CommentBody
                      FROM   CaseComment
                      WHERE  ParentId = :testCaseId];

      //System.assertEquals(1, caseComments.size());
      //System.assert(caseComments[0].CommentBody.contains('Current Status: CS-1'));
      //system.assert(caseComments[0].CommentBody.contains('Plan Of Action: PoA-1'));
     }

   // ==================================================================================== testUpdates
   static testMethod void testUpdates()
     {List<Case>        cases;
      List<CaseComment> caseComments;
      ID                testCaseId;

      createNewCaseWithNonNullFields();

      cases = [SELECT Id,
                      caseCurrentStatus__c,
                      casePlanOfAction__c,
                      Subject
               FROM   Case
               WHERE  Subject = 'TEST-CASE-SUBJECT'];

      testCaseId = cases[0].Id;

      cases[0].caseCurrentStatus__c = 'CS-2';
      cases[0].casePlanOfAction__c  = 'PoA-2';

      update cases[0];

      caseComments = [SELECT   Id,
                               ParentId,
                               CommentBody,
                               CreatedDate
                      FROM     CaseComment
                      WHERE    ParentId = :testCaseId
                      ORDER BY CreatedDate];

      /*System.assertEquals(2, caseComments.size());
      System.assert(caseComments[1].CommentBody.contains('Current Status: CS-2'));
      system.assert(caseComments[1].CommentBody.contains('Plan Of Action: PoA-2'));*/
     }
   // ==================================================================================//
      /*static testMethod void testUpdates1(){
          
      
     	Account account; 
        Contact contact;
        Asset   asset;
        Case aCase;
        Case aCase1;
        Case aCase2;
        AddressBook__c addressbook;
        rmav2__c rmas;
          
        insert account = new Account(Name = 'Nimble service portal - Production',accountRmaShi__c='Account RMA SHI');
        System.assertNotEquals(null,              account.Id);
        System.assertEquals('Nimble service portal - Production', account.Name);
        System.assertEquals('Account RMA SHI',    account.accountRmaShi__c);
        
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        System.assertNotEquals(null,                        contact.Id);
        System.assertEquals('TEST-CONTACT-LAST-NAME', contact.LastName);
        System.assertEquals(account.Id,            contact.AccountId);
        System.assertEquals('test@gmail.com',            contact.Email);
        System.assertEquals('999999999',            contact.Phone);
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Create test asset
        insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                 Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                 Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                 Array_Controller_SKU__c = 'SD-Test');
        
        
        
        
        System.assertNotEquals(null,                      asset.Id);
        System.assertEquals('TEST-ASSET',                  asset.Name);
        System.assertEquals(account.Id,                 asset.AccountId);
        System.assertEquals(contact.Id,                 asset.ContactId);
        System.assertEquals('Premium',                     asset.SLA__c);
        System.assertEquals('Asset RMA SHI',    asset.assetRmaShi__c);
        
        Test.startTest();
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT',
                                Product_Damage_Symptoms__c = 'Test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId(),
                                Case_closure_time_spent__c = 1);
        insert addressbook = new AddressBook__c(abAccount__c= account.Id,
                                                abStreet1__c = 'STREET1',
                                                abStreet2__c = 'STREET2',
                                                abCity__c='CITY',
                                                abCountry__c='India',
                                                abPostalCode__c = '600000',
                                                abStateProvince__c='STATE',
                                                abDescription__c = 'TEST DESCRIPTION');
          insert rmas = new rmav2__c(rmaType__c = 'Advance replcement',
                                   rmaFaRequired__c ='No FA Required',
                                   rmaCaseNumber__c = aCase.id,
                                   rmaDetailedReason__c ='test rma',
                                   rmaAddressBook__c =addressbook.id,
                                   rmaUplift__c ='No: Do not uplift',
                                   rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order',
                                   rmaReturnShipmentStatus__c ='DRAFT-10: Waiting to order');
          Test.stopTest();
           insert aCase1 = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT',
                                Product_Damage_Symptoms__c = 'Test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                                Case_closure_time_spent__c = 1,
                                RMAmapped__c = rmas.id);
          
          insert aCase2 = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT1',
                                Product_Damage_Symptoms__c = 'Test1',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                                Case_closure_time_spent__c = 1,
                                   caseCurrentStatus__c = 'test',
                                RMAmapped__c = rmas.id);
          aCase2.status = 'Closed';
          update aCase2;
           
          
      }*/

      static testMethod void testInsertNewComment() {
        List<Case>        cases;
        ID                testCaseId;
        CaseComment newCaseComment;
        Boolean testCaseSuccess = false;

        createNewCaseWithNonNullFields();

        cases = [SELECT Id,
                        caseCurrentStatus__c,
                        casePlanOfAction__c,
                        Subject
                FROM   Case
                WHERE  Subject = 'TEST-CASE-SUBJECT'];

        testCaseId = cases[0].Id;

        newCaseComment = new CaseComment(
                                          CommentBody = 'New Case Comment',
                                          ParentId = testCaseId
                                        );

        insert newCaseComment;

        for(CaseComment caseComments: [SELECT   Id,
                                                ParentId,
                                                CommentBody,
                                                CreatedDate
                                        FROM     CaseComment
                                        WHERE    ParentId = :testCaseId
                                        ORDER BY CreatedDate]) {
            if(caseComments.CommentBody.contains(newCaseComment.commentBody)) {
              testCaseSuccess = true;
            }
        }
        System.assertEquals(true, testCaseSuccess);
     }

     static testMethod void testInsertNewCommentWithCaseUpdate() {
      List<Case>        cases;
      ID                testCaseId;
      CaseComment newCaseComment;
      Boolean newCommentSuccess = false;
      Boolean caseUpdateSuccess = false;

      createNewCaseWithNonNullFields();

      cases = [SELECT Id,
                      caseCurrentStatus__c,
                      casePlanOfAction__c,
                      Subject
              FROM   Case
              WHERE  Subject = 'TEST-CASE-SUBJECT'];

      testCaseId = cases[0].Id;

      String updatedCurrentStatus = 'CS-2';
      String updatedPlanOfAction = 'PoA-2';

      cases[0].caseCurrentStatus__c = updatedCurrentStatus;
      cases[0].casePlanOfAction__c  = updatedPlanOfAction;

      update cases[0];

      newCaseComment = new CaseComment(
                                        CommentBody = 'New Case Comment',
                                        ParentId = testCaseId
                                      );

      insert newCaseComment;

      for(CaseComment caseComments: [SELECT   Id,
                                              ParentId,
                                              CommentBody,
                                              CreatedDate
                                      FROM     CaseComment
                                      WHERE    ParentId = :testCaseId
                                      ORDER BY CreatedDate]) {
          if(caseComments.CommentBody.contains(newCaseComment.commentBody)) {
            newCommentSuccess = true;
          }
          if(caseComments.CommentBody.contains(updatedCurrentStatus) 
              && caseComments.CommentBody.contains(updatedPlanOfAction)) {
                caseUpdateSuccess = true;
              }
      }
      System.assertEquals(true, newCommentSuccess && caseUpdateSuccess);
   }

    static testMethod void testInsertNewCommentWithSameMultipleCaseUpdates() {
      List<Case>        cases;
      ID                testCaseId;
      CaseComment newCaseComment;
      Boolean newCommentSuccess = false;
      Integer caseUpdateSuccessCount = 0;

      createNewCaseWithNonNullFields();

      cases = [SELECT Id,
                      caseCurrentStatus__c,
                      casePlanOfAction__c,
                      Subject
              FROM   Case
              WHERE  Subject = 'TEST-CASE-SUBJECT'];

      testCaseId = cases[0].Id;

      String updatedCurrentStatus = 'CS-2';
      String updatedPlanOfAction = 'PoA-2';

      cases[0].caseCurrentStatus__c = updatedCurrentStatus;
      cases[0].casePlanOfAction__c  = updatedPlanOfAction;

      update cases[0];

      newCaseComment = new CaseComment(
                                        CommentBody = 'New Case Comment',
                                        ParentId = testCaseId
                                      );

      insert newCaseComment;

      updatedCurrentStatus = 'CS-2';
      updatedPlanOfAction = 'PoA-2';

      cases[0].caseCurrentStatus__c = updatedCurrentStatus;
      cases[0].casePlanOfAction__c  = updatedPlanOfAction;

      update cases[0];

      for(CaseComment caseComments: [SELECT   Id,
                                              ParentId,
                                              CommentBody,
                                              CreatedDate
                                      FROM     CaseComment
                                      WHERE    ParentId = :testCaseId
                                      ORDER BY CreatedDate]) {
          if(caseComments.CommentBody.contains(newCaseComment.commentBody)) {
            newCommentSuccess = true;
          }
          if(caseComments.CommentBody.contains(updatedCurrentStatus) 
              && caseComments.CommentBody.contains(updatedPlanOfAction)) {
                caseUpdateSuccessCount += 1;
              }
      }
      System.assertEquals(true, newCommentSuccess && caseUpdateSuccessCount == 1);
    }

    static testMethod void testInsertNewCommentWithDifferentMultipleCaseUpdates() {
      List<Case>        cases;
      ID                testCaseId;
      CaseComment newCaseComment;
      Boolean newCommentSuccess = false;
      Integer caseUpdateSuccessCount = 0;

      createNewCaseWithNonNullFields();

      cases = [SELECT Id,
                      caseCurrentStatus__c,
                      casePlanOfAction__c,
                      Subject
              FROM   Case
              WHERE  Subject = 'TEST-CASE-SUBJECT'];

      testCaseId = cases[0].Id;

      String updatedCurrentStatus2 = 'CS-2';
      String updatedPlanOfAction2 = 'PoA-2';

      cases[0].caseCurrentStatus__c = updatedCurrentStatus2;
      cases[0].casePlanOfAction__c  = updatedPlanOfAction2;

      update cases[0];

      newCaseComment = new CaseComment(
                                        CommentBody = 'New Case Comment',
                                        ParentId = testCaseId
                                      );

      insert newCaseComment;

      String updatedCurrentStatus3 = 'CS-3';
      String updatedPlanOfAction3 = 'PoA-3';

      cases[0].caseCurrentStatus__c = updatedCurrentStatus3;
      cases[0].casePlanOfAction__c  = updatedPlanOfAction3;

      update cases[0];

      for(CaseComment caseComments: [SELECT   Id,
                                              ParentId,
                                              CommentBody,
                                              CreatedDate
                                      FROM     CaseComment
                                      WHERE    ParentId = :testCaseId
                                      ORDER BY CreatedDate]) {
          if(caseComments.CommentBody.contains(newCaseComment.commentBody)) {
            newCommentSuccess = true;
          }
          if(caseComments.CommentBody.contains(updatedCurrentStatus2) 
                && caseComments.CommentBody.contains(updatedPlanOfAction2)) {
                caseUpdateSuccessCount += 1;
          }
          if(caseComments.CommentBody.contains(updatedCurrentStatus3) 
              && caseComments.CommentBody.contains(updatedPlanOfAction3)) {
              caseUpdateSuccessCount += 1;
          }
      }
      System.assertEquals(true, newCommentSuccess && caseUpdateSuccessCount == 2);
    }
}