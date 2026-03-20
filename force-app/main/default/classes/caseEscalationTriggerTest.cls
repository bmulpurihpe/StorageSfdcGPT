@isTest
private class caseEscalationTriggerTest
  {
    @TestSetup
    static void setupTestData(){
        Test.startTest();
        //Setup case data
        Account testAcct = new Account(
            Name = 'Test Account for Testing'
        );
        insert testAcct;  
        Contact testContact = new Contact(
            AccountId = testAcct.id,
            FirstName = 'Test',
            LastName = 'Contact'
        );
        insert testContact;
        Case testCase = new Case(
            AccountId = testAcct.id,
            ContactId = testContact.id,
            AssetId = null,
            Status = 'New',
            caseCatImpactToCustomer__c = 'No Impact - Initial Installation',
            Type = 'Production',
            Estimated_Effort__c = '30 minutes',
            Subject = 'TEST-CASE-SUBJECT',
            Description = 'Test Description',
            Technology_Area__c = 'Sizing (for Performance)',
            Sub_Technology_Area__c = 'CPU / Controller'
        );
        insert testCase;

        //Setup Escalations
        caseEscalationTypeDefinition__c enggEscTypeDef = new caseEscalationTypeDefinition__c(
            Name = 'Engineering Escalation',
            caseEscalationTypeDefinitionGroup__c = 'Engineering Escalation'
        );
        insert enggEscTypeDef;
        caseEscalation__c caseEsc = new caseEscalation__c(
            caseEscalationCase__c = testCase.id,
            caseEscalationTypeDefinition__c = enggEscTypeDef.id,
            caseEscalationJIRAId__c = 'ESC-10000'
        );
        insert caseEsc;
        Test.stopTest();
    }

   
   static testMethod void test_InsertEngineeringEscalation(){
      List<Case> testCases;
      Id testCaseId;
      
      Test.startTest();
      testCases = [SELECT Id,
                          Subject
                   FROM   Case
                   WHERE  Subject = 'TEST-CASE-SUBJECT'];

      testCaseId = testCases[0].id;

      List<caseEscalationTypeDefinition__c> caseEscTypeDefs = [Select Id, 
                                                                      Name, 
                                                                      caseEscalationTypeDefinitionGroup__c 
                                                               FROM caseEscalationTypeDefinition__c
                                                               WHERE Name = 'Engineering Escalation'];

      List<caseEscalation__c> caseEscalations;

      caseEscalations = [SELECT Id,
                                caseEscalationCase__c,
                                caseEscalationTypeDefinition__c
                         FROM   caseEscalation__c];

      System.assertEquals(1,                                  caseEscalations.size());
      System.assertEquals(testCaseId,                         caseEscalations[0].caseEscalationCase__c);
      System.assertEquals(caseEscTypeDefs[0].Id, caseEscalations[0].caseEscalationTypeDefinition__c);

      testCases = [SELECT Id,
                          caseEscalationType__c,
                          IsEscalated
                   FROM   Case
                   WHERE  Id = :testCaseId];

      System.assertEquals('Engineering Escalation', testCases[0].caseEscalationType__c);
      System.assertEquals(true, testCases[0].IsEscalated);
      Test.stopTest();
    }

    static testMethod void test_DuplicateEscalation(){
      List<Case> testCases;
      Id testCaseId;
      
      Test.startTest();
      testCases = [SELECT Id,
                          Subject
                   FROM   Case
                   WHERE  Subject = 'TEST-CASE-SUBJECT'];

      testCaseId = testCases[0].id;

      List<caseEscalationTypeDefinition__c> caseEscTypeDefs = [Select Id, 
                                                                      Name, 
                                                                      caseEscalationTypeDefinitionGroup__c 
                                                               FROM caseEscalationTypeDefinition__c
                                                               WHERE Name = 'Engineering Escalation'];

      List<caseEscalation__c> caseEscalations;

      caseEscalations = [SELECT Id,
                                caseEscalationCase__c,
                                caseEscalationTypeDefinition__c
                         FROM   caseEscalation__c];
      // ===== Create duplicate test Case Escalation
      caseEscalation__c testCaseEscalation2;
      List<caseEscalation__c> caseEscalations2;
      Exception dmlException;

      testCaseEscalation2 = new caseEscalation__c(caseEscalationCase__c           = testCaseId,
                                                  caseEscalationTypeDefinition__c = caseEscTypeDefs[0].Id);

      try
        {
          insert(testCaseEscalation2);
        }
      catch(Exception ex)
        {
          dmlException = ex;
        }

      System.assertNotEquals(null, dmlException);
      System.assert(dmlException instanceOf system.Dmlexception);
      System.assert(dmlException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
      System.assert(dmlException.getMessage().contains('ERROR: There is already a Case Escalation with this Case Number and Escalation Type (Group/User).'));
      Test.stopTest();
    }

    static testMethod void test_DeleteEngineeringEscalation(){
      List<Case> testCases;
      Id testCaseId;
      
      Test.startTest();
      testCases = [SELECT Id,
                          Subject
                   FROM   Case
                   WHERE  Subject = 'TEST-CASE-SUBJECT'];

      testCaseId = testCases[0].id;

      List<caseEscalationTypeDefinition__c> caseEscTypeDefs = [Select Id, 
                                                                      Name, 
                                                                      caseEscalationTypeDefinitionGroup__c 
                                                               FROM caseEscalationTypeDefinition__c
                                                               WHERE Name = 'Engineering Escalation'];

      List<caseEscalation__c> caseEscalations;

      caseEscalations = [SELECT Id,
                                caseEscalationCase__c,
                                caseEscalationTypeDefinition__c
                         FROM   caseEscalation__c];

      delete(caseEscalations[0]);

      testCases = [SELECT Id,
                          caseEscalationType__c,
                          IsEscalated
                   FROM   Case
                   WHERE  Id = :testCaseId];

      System.assertEquals('Not Escalated', testCases[0].caseEscalationType__c);
      System.assertEquals(false, testCases[0].IsEscalated);
      Test.stopTest();
    }
  }