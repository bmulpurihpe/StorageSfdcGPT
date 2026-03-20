@isTest
public class CaseTriggerTest{
 
    static testMethod void testCaseCommentCatandSubCat()
    {
        //Create category notes
        List<Category_Notes__c> notesList = new List<Category_Notes__c>();
        Category_Notes__c n1 = new Category_Notes__c();
        n1.Category__c='Backup Integration';
        n1.Sub_Category__c='CommVault'; 
        n1.Notes__c='1.Question';
        notesList.add(n1);
        Category_Notes__c n2 = new Category_Notes__c();
        n2.Category__c='Cisco UCS Integration';
        n2.Sub_Category__c='Boot from SAN';
        n2.Notes__c='1.Question';
        notesList.add(n2);
        insert notesList;
        //Create a new case 
        
        Case c = new Case(casecatCategory__c='Backup Integration',caseIsThisCaseRelatedToANimbleProduct__c='yes', caseSubCategory__c='CommVault',casePlanOfAction__c = 'Test Plan');
        insert c;
        CaseComment cc = [select Id,CommentBody from CaseComment where ParentId=:c.Id AND CommentBody LIKE '%1.Question%' LIMIT 1];
        System.assertEquals(n1.Notes__c,cc.CommentBody);
        Case uCase = [select Id, LatestCommentId__c from Case where Id =: c.Id];
        System.assertEquals(cc.Id,uCase.LatestCommentId__c);
        Test.startTest();
        //Update a case
        c.casecatCategory__c = 'Cisco UCS Integration';
        c.caseSubCategory__c = 'Boot from SAN';
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        update c;
        CaseComment cc1 = [select Id,CommentBody from CaseComment where ParentId=:c.Id  AND CommentBody LIKE '%1.Question%' LIMIT 1];
        System.assertEquals(n2.Notes__c,cc1.CommentBody);
        Case uCase1 = [select Id, LatestCommentId__c from Case where Id =: c.Id];
        System.assertEquals(cc1.Id,uCase1.LatestCommentId__c);
        Test.stopTest();
    }
 
    static testMethod void DuplicateCase(){
        Case c1 = new Case(Status = 'New', Origin = 'Phone');
        insert c1;
        Case c2 = new Case(Status = 'New', Origin = 'Phone');
        Test.startTest();
        insert c2;
        //Test.startTest();
        assetPreventRecursive.run = true;
        CountAssetPreventRecursive.run = true;
        c2.Status = 'Closed(Duplicate)';
        c2.Duplicate_Case__c = c1.Id;
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        Try{
        update c2;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }
    static testMethod void TestDcesyncCase(){
        //UserInfo.getName() == 'DCE Integration API User';
        User u=[Select Id From User Where name ='DCE Integration API User' Limit 1];
        System.runAs(u)
        {
            Case c1 = new Case(Status = 'New', Origin = 'Phone', DCE_Sync__c = True);
            insert c1;
            Test.startTest();
            case c2 = c1.Clone(false, false, false, false);
            c2.DCE_Sync__c = False;
            insert c2;
            Test.StopTest();
        }
    }
    static testMethod void CaseOutagetoP1(){
        Test.startTest();
        
        TriggerSettings__c ts = new TriggerSettings__c(Name = 'DCECaseSync', Disable__c = false);
        insert ts;
        
        Case c1 = new Case(Status = 'New', Origin = 'Web', Priority='P2', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId(), outage__c = True);
        insert c1;
        c1.Status = 'Waiting on Customer';
        //c1.Sub_Status__c = 'Approve Case Closure';
        RecursiveTriggerRestrictiion.run = true;
        
        
        
        //CaseUtility.caseUpdateRun = true;
        update c1;
        Test.stopTest();
      }
    static testMethod void CaseOutagetoP2(){
        Test.startTest();
        
        TriggerSettings__c ts = new TriggerSettings__c(Name = 'DCECaseSync', Disable__c = false);
        insert ts;
        
        Support_Profile_Version__c softwareVersion = new Support_Profile_Version__c(Support_Profile__c = 'Legacy Nimble', Version__c = '1.2.3.4');
        insert softwareVersion;
        
        Support_Profile_Version__c softwareVersion1 = new Support_Profile_Version__c(Support_Profile__c = 'Legacy Nimble', Version__c = 'Unknown');
        insert softwareVersion1;
        
        Case c1 = new Case(Status = 'New',Nimble_Version__c = '1.2.3.4', Origin = 'Web', Priority='P2', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId(), outage__c = True);
        insert c1;
        c1.Status = 'Waiting on Customer';
        //c1.Sub_Status__c = 'Approve Case Closure';
        c1.Nimble_Version__c = 'Unknown';
        RecursiveTriggerRestrictiion.run = true;
        
        
        
        //CaseUtility.caseUpdateRun = true;
        update c1;
        Test.stopTest();
      }
    static testMethod void P1AlertTextingInsert(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Phone', Priority='P1',Current_comment_time_spent__c = 2);
        insert c1;
        Test.stopTest();
    }
    
    
    static testMethod void P1AlertTextingUpdate(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Phone', Priority='P2',Current_comment_time_spent__c = 2);
        insert c1;
        c1.Priority = 'P1';
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        update c1;
        Test.stopTest();
    }
     static testMethod void P1AlertTextingUpdate2(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Phone', Priority='P2',Current_comment_time_spent__c = 2);
        insert c1;
        c1.Priority = 'P1';
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        c1.Current_comment_time_spent__c = 0;
         try{
        update c1;
         }
         catch(Exception e){
            System.debug('Exception:'+e); 
         }
        Test.stopTest();
    }
    static testMethod void P1AlertTextingUpdate3(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Phone', Priority='P2',Current_comment_time_spent__c = 2,Current_comment_activity__c='Customer Call');
        insert c1;
        c1.Priority = 'P1';
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        c1.Current_comment_time_spent__c = 0;
         try{
        update c1;
         }
         catch(Exception e){
            System.debug('Exception:'+e); 
         }
        Test.stopTest();
    }
    
    static testMethod void SeverityCritical(){
        Test.startTest();
        Case c2 = new Case(Status = 'New', Origin = 'Web', Severity__c='Critical',RecordTypeId=Schema.SObjectType.case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId());
        insert c2;
        Case_Docket__c cDocket;
        //inserting new case Docket
        insert cDocket = new Case_Docket__c(Name = 'TEST-ASSET',cdCasePriority__c='P1',cdDescription__c ='TEST-DESCRIPTION',cdLabel__c='TEST-ASSET',
                                            cdDocketType__c = 'Request',cdHideOnPortal__c = FALSE,cdUnderlyingObject__c = 'Asset',cdResponsibleBUTeam__c='Renewals');
        Case c1 = new Case(Status = 'New', Origin = 'Web', 
                           Severity__c='Critical',
                           CaseDocket__c = cDocket.Id,RecordTypeId=Schema.SObjectType.case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                           CaseMapping__c = c2.id);
        insert c1;
       
        Test.stopTest();
    }
    static testMethod void SeverityCriticalDegraded(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Web', Severity__c='Critical - Degraded');
        insert c1;
        Test.stopTest();
    }
    static testMethod void SeverityLowPriority(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Web', Severity__c='Low Priority');
        insert c1;
        Test.stopTest();
    }
    static testMethod void Priority3(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Web', Priority='P3');
        insert c1;
        Test.stopTest();
    }
    static testMethod void engageNCVBillingTest(){
        Case c1 = new Case(Status = 'New', Origin = 'Phone', Priority='P2', caseEngageNCVBilling__c = false);
        insert c1;
        Test.startTest();
        assetPreventRecursive.run = true;
        CountAssetPreventRecursive.run = true;
        c1.caseEngageNCVBilling__c = true;
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        update c1;
        Test.stopTest();
    }
    static testMethod void attnreqTest(){
        
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2', caseAttnReq__c = true,caseAttnReqDateTime__c= system.now());
        insert c1;
        Test.startTest();
        assetPreventRecursive.run = true;
        CountAssetPreventRecursive.run = true;
        c1.AttnSnoozeIntervalInHours__c = '2';
        c1.caseAttnReqSnoozeReason__c = 'test';
        c1.caseAttnReqDateTimeHelper__c = System.now();
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        update c1;
        Test.stopTest();
    }
    static testMethod void attnreqTest1(){
        
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2', caseAttnReq__c = true,caseAttnReqDateTime__c= system.now(), AttnSnoozeIntervalInHours__c = '2');
        insert c1;
        Test.startTest();
        assetPreventRecursive.run = true;
        CountAssetPreventRecursive.run = true;
        c1.AttnSnoozeIntervalInHours__c = '3';
        c1.caseAttnReqSnoozeReason__c = 'test';
        c1.caseAttnReqDateTimeHelper__c = System.now();
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        update c1;
        Test.stopTest();
    }
 
    //@isTest(seeAllData = true)
    static testMethod void slaExpiryOwnerUpdateP1() {
        User u = [SELECT Id FROM User WHERE Alias = 'NSForce' LIMIT 1];
        
        System.runAs(u) {
            // Setup test queue
            Group testGroup = new Group(Name = 'test group', Type = 'Queue');
            insert testGroup;
            
            QueueSObject testQueue = new QueueSObject(QueueId = testGroup.Id, SObjectType = 'Case');
            insert testQueue;
            
            
            // Create case with record type
            Case c1 = new Case(
                Status = 'New',
                Origin = 'Email',
                Priority = 'P1',
                OwnerId = testGroup.Id
            );
            insert c1;
            
            Test.startTest();
            c1.OwnerId = UserInfo.getUserId();
            c1.Sub_Status__c = 'Assigned';
            RecursiveTriggerRestrictiion.run = true;
            //update c1;
            Test.stopTest();
        }
    }

    static testMethod void slaExpiryOwnerUpdateP2(){
        User u=[Select Id From User Where Alias ='NSForce' Limit 1];
        System.runAs(u)
        {
        Group testGroup = new Group(Name='test group', type='Queue');
        insert testGroup;
        //System.runAs(new User(Id=UserInfo.getUserId()))
        //{
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
        //}
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2', OwnerId = testGroup.id);
        insert c1;
        system.debug('Owner Id after Insert'+c1.OwnerId);
        c1.OwnerId = userinfo.getUserId(); //'00580000005J7vc';//
        //c1.SLAWhenOwnerChanged__c = '1 hours 59 minutes';
        //c1.caseOwnerChanged__c = true;
        Test.startTest();
        c1.Sub_Status__c = 'Assigned';
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        //update c1;
        //CaseComment slaCommentforp2 = new CaseComment(CommentBody = 'Willie Sarazin took ownership (priority:P2, age(days): 0.00, sla: 2 hours, status: 1 hours 59 minutes>0, ‘met’ : yes)',IsPublished = False,ParentId = c1.Id);
        //insert slaCommentforp2;
        Test.stopTest();
        }
    }
    static testMethod void slaExpiryOwnerUpdateP3(){
        User u=[Select Id From User Where Alias ='NSForce' Limit 1];
        System.runAs(u)
        {
        Group testGroup = new Group(Name='test group', type='Queue');
        insert testGroup;
        //System.runAs(new User(Id=UserInfo.getUserId()))
        //{
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
        //}
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P3', OwnerId = testGroup.id);
        insert c1;
        c1.OwnerId =userinfo.getUserId();// '00580000005J7vc';//
        //c1.SLAWhenOwnerChanged__c = '1 hours 59 minutes';
        //c1.caseOwnerChanged__c = true;
        c1.Sub_Status__c = 'Assigned';
        Test.startTest();
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
       // update c1;
        //CaseComment slaCommentforp3 = new CaseComment(CommentBody = 'Willie Sarazin took ownership (priority:P2, age(days): 0.00, sla: 2 hours, status: 1 hours 59 minutes>0, ‘met’ : yes)',IsPublished = False,ParentId = c1.Id);
        //insert slaCommentforp3;
        Test.stopTest();
        }
    }
    static testMethod void slaExpiryOwnerUpdateP3V1(){
        User user = [select Id from User where Name = 'Nimble Support' and isActive = true limit 1];
        System.runAs(user) 
        {
            
            //System.runAs(new User(Id=UserInfo.getUserId()))
            //{
           
            //}
            
            Case c1 = new Case(Status = 'New' , Origin = 'Email', Priority='P3', ChangeOwnerIdTo__c ='',Auto_Open__c = true);
            insert c1;
            c1.OwnerId =userinfo.getUserId();// '00580000005J7vc';//
            //c1.SLAWhenOwnerChanged__c = '1 hours 59 minutes';
            //c1.caseOwnerChanged__c = true;
            c1.Sub_Status__c = 'Assigned';
            Test.startTest();
            //RecursiveTriggerRestrictiion.run = true;
            //CaseUtility.caseUpdateRun = true;
            //update c1;
            //CaseComment slaCommentforp3 = new CaseComment(CommentBody = 'Willie Sarazin took ownership (priority:P2, age(days): 0.00, sla: 2 hours, status: 1 hours 59 minutes>0, ‘met’ : yes)',IsPublished = False,ParentId = c1.Id);
            //insert slaCommentforp3;
            Test.stopTest();
        }
    }

    static testMethod void slaExpiryOwnerUpdateP4(){
        User u=[Select Id From User Where Alias ='NSForce' Limit 1];
        System.runAs(u)
        {
        Group testGroup = new Group(Name='test group', type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
        }
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];

        Case c1 = new Case(Status = 'New', Origin = 'Email',RecordTypeId =recordTypearraycase.Id, Priority='P4', OwnerId = testGroup.id);
        insert c1;
        c1.OwnerId = userinfo.getUserId(); //'00580000005J7vc';//
        //c1.SLAWhenOwnerChanged__c = '1 hours 59 minutes';
        //c1.caseOwnerChanged__c = true;
        c1.Sub_Status__c = 'Assigned';
        Test.startTest();
        //RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
       // update c1;
        //CaseComment slaCommentforp4 = new CaseComment(CommentBody = 'Willie Sarazin took ownership (priority:P2, age(days): 0.00, sla: 2 hours, status: 1 hours 59 minutes>0, ‘met’ : yes)',IsPublished = False,ParentId = c1.Id);
        //insert slaCommentforp4;
        Test.stopTest();
        }
    }
    static testMethod void CaseEscalationType(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',caseEscalationType__c='Not Escalated');
        insert c1;
        Test.stopTest();
    }
    /*static testMethod void CaseOwnerChange(){
        User u=[Select Id From User Where Alias ='NSForce' Limit 1];
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',OwnerId=u.Id);
        insert c1;
        Test.startTest();
        c1.OwnerId = userinfo.getUserId();
        update c1;
        Test.stopTest();
    }*/
    
   static testMethod void CaseCloseTest(){ 
        Case c1 = new Case(Status = 'New',Technology_Area__c = 'test1',Sub_Technology_Area__c='test1',Origin = 'Email', Priority='P2');
        insert c1;
        Test.startTest();
        c1.Technology_Area__c = 'Test';
        c1.Sub_Technology_Area__c ='Test';
        c1.Status ='Closed';
        c1.Technology_Area__c = '3rd Party Apps';
        c1.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        try{
            update c1;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    static testMethod void CaseEscalationType2(){
        Id aCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId();
        Case c1 = new Case(Status='New',
                              Origin ='TEST.e2r',
                              RecordTypeId = aCaseRecordTypeId,
                              SuppliedName = 'Ramireddy Vishnu',
                              SuppliedEmail ='vishnu.ramireddy@hpe.com',
                              Subject = 'E2R for NS Ops case Request..!',
                              Description = 'E2R for NS Ops case Request');
        insert c1;
        
        Case_Docket__c cDocket = new Case_Docket__c(Name = 'TEST-ASSET',cdCasePriority__c='P1',cdDescription__c ='TEST-DESCRIPTION',cdLabel__c='TEST-ASSET',
                                                    cdDocketType__c = 'Request',cdHideOnPortal__c = FALSE,cdUnderlyingObject__c = 'Asset',cdResponsibleBUTeam__c='Renewals');
        insert cDocket;
        
        
        Test.startTest();
        
       
        
        case aCase = new Case(Status='New',
                              Origin ='TEST.e2r',
                              RecordTypeId = aCaseRecordTypeId,
                              SuppliedName = 'Ramireddy Vishnu',
                              SuppliedEmail ='vishnu.ramireddy@hpe.com',
                              Subject = 'E2R for NS Ops case Request..!',
                              Description = 'E2R for NS Ops case Request',
                              Technology_Area__c = 'test1',
                              Sub_Technology_Area__c='test1');
        insert aCase;
        case acaseUpdate = new Case();
        acaseUpdate.id = aCase.id;
        acaseUpdate.Status = 'Closed';
        acaseUpdate.CaseMapping__c = c1.id;
        acaseUpdate.CaseDocket__c = cDocket.id;
        // begin: added by Larry
        RecursiveTriggerRestrictiion.run = true;
        // end: added by Larry
        update acaseUpdate;
        
        Test.stopTest();
    }
    
    static testMethod void CaseIgnoreSubjects00(){
        try  
        {
            Account acct = new Account(Name = 'HPEaccount');
            insert acct;
            
            Case c1 = new Case(AccountId = acct.Id, Status = 'New', Origin = 'Email', Priority='P2',Subject='Out of office');
            insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects01(){
        try  
        {
            Account acct = new Account(Name = 'HPEaccount');
            insert acct;
           Case c1 = new Case(AccountId = acct.Id, Status = 'New', Origin = 'Email', Priority='P2',Subject='Automatisch antwoord');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects02(){
        try  
        {   
            Account acct = new Account(Name = 'HPEaccount');
            insert acct;
           Case c1 = new Case(AccountId = acct.Id, Status = 'New', Origin = 'Email', Priority='P2',Subject='Automatisch');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects03(){
        try  
        {
            Account acct = new Account(Name = 'HPEaccount');
            insert acct;
           Case c1 = new Case(AccountId = acct.Id, Status = 'New', Origin = 'Email', Priority='P2',Subject='Absence Re');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects04(){
        try  
        {
            Account acct = new Account(Name = 'HPEaccount');
            insert acct;
           Case c1 = new Case(AccountId = acct.Id,Status = 'New', Origin = 'Email', Priority='P2',Subject='Automatische Antwort');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects05(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Réponse Automatique');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects06(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Autosvar');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects07(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='außer haus');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects08(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Absence du bureau');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects09(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='OOO');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects10(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='out of the office');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects11(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Auto Reply');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects12(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Auto Response');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects13(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='[Auto-Reply]');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects14(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='[Out of office]');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects15(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Out-of-office');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects16(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='auto-response');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects18(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='[Out-of-office]');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects19(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='autoresponse RE');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects20(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='autoreply');
           //insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects21(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='autoresponse');
          // insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    
     static testMethod void testGSEM()
    {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GSEM());
        Test.setMock(HttpCalloutMock.class, new MockHttpOEMResponseGenerator());
        
        //Create category notes
        List<Category_Notes__c> notesList = new List<Category_Notes__c>();
        Category_Notes__c n1 = new Category_Notes__c();
        n1.Category__c='Backup Integration';
        n1.Sub_Category__c='CommVault';
        n1.Notes__c='1.Question';
        notesList.add(n1);
        Category_Notes__c n2 = new Category_Notes__c();
        n2.Category__c='Cisco UCS Integration';
        n2.Sub_Category__c='Boot from SAN';
        n2.Notes__c='1.Question';
        notesList.add(n2);
        insert notesList;
        //Create a new case 
        Case c = new Case(Status='Open',casecatCategory__c='Backup Integration',caseSubCategory__c='CommVault');
        insert c;
       
        Test.startTest();

        //Update a case
        GSEM__c gv = new GSEM__c();
        gv.Company_Name__c = 'Test Account One';
        gv.Problem_Title__c = 'TEST TESTTEST TEST TEST TEST';
        gv.Contact_Last_Name__c = 'Test';
        gv.ContactFirstName__c = 'TestF';
        gv.Contact_Phone__c  = '(408) 000-8840';
        gv.System_Serial_No__c ='CS500TESTNIM';
        gv.Contact_Email__c = 'roy@exafort.com';
        gv.Cust_ticket__c='03439818';
        gv.SLA__c= 'Premium';
        gv.City__c= 'Tampa';
        gv.Zipcode__c = '90000';
        gv.State__c = 'FL';
        gv.Country__c= 'US';
        gv.Resolution_Code_Text__c = 'Test Resolution';   
        gv.RecordTypeId = [select Id, Name from RecordType where Name = 'Nimble to PN'][0].Id;
        gv.Current_GSEM_State__c = 'SENDING TO POINTNEXT (PENDING)';
        gv.GSEM_Flow_Type__c = 'GSEM Requester Flow (Nimble Originated)';
        
        
        //gv.Requester_Id__c = 'GSM-';
        gv.Provider_ID__c = '555555555';
        gv.GSEM__c = c.Id;
        
        insert gv;
        
        
        
        CaseUtility.GSEMrun = true;
        
        c.casecatCategory__c = 'Cisco UCS Integration';
        c.caseSubCategory__c = 'Boot from SAN';
        c.Status = 'Closed';
        c.Technology_Area__c = '3rd Party Apps';
        c.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        try{
        update c;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
         
        Test.stopTest();
    } 
   
    static void caseSurveyCode() {
        // === Setup test data ===
        Account account = new Account(Name = 'TEST-ACCOUNT');
        insert account;
        
        Product2 testProduct = new Product2(
            Name = 'CS220 Storage Array',
            ProductCode = 'S0S38A',
            Product_Type__c = 'Hardware',
            Product_Type_2__c = 'File Storage',
            Controller_Code__c = 'CS200',
            Description = '12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
            Family = 'File Storage'
        );
        insert testProduct;
        
        Asset asset = new Asset(
            Name = 'AA-111112',
            AccountId = account.Id,
            Product2Id = testProduct.Id,
            HPE_Serial_Number__c = 'AFTestM10',
            Array_Controller__c = 'CS300',
            Array_Networking__c = '2P',
            Array_Networking_2__c = '2P',
            Array_Networking_3__c = '2P',
            Array_Cache__c = '640F',
            assetPartShipLastValidatedDatetime__c = DateTime.newInstance(2023, 2, 5, 8, 30, 12),
            SSD_Bank_A__c = '480F',
            SSD_Bank_B__c = '480F',
            Asset_Type_Build__c = 'File Storage',
            Status = 'Shipped',
            Component_SKU_HPE__c = 'R4U28A',
            Component_SKU_Nimble_V2__c = '6010',
            Expansion_Shelf_Base__c = 'AFS2',
            Array_Capacity__c = '11T'
        );
        insert asset;
        
        Contact contact = new Contact(
            LastName = 'TEST-CONTACT',
            AccountId = account.Id,
            Email = 'test@example.com',
            contactLastSurveySentDate__c = System.today().addDays(-63)
        );
        insert contact;
        
        List<Category_Notes__c> notesList = new List<Category_Notes__c>{
            new Category_Notes__c(Category__c = 'Backup Integration', Sub_Category__c = 'CommVault', Notes__c = '1.Question'),
                new Category_Notes__c(Category__c = 'Cisco UCS Integration', Sub_Category__c = 'Boot from SAN', Notes__c = '1.Question')
                };
                    insert notesList;
        
        insert new Threshold_limit__c(Name = 'limit', Number_of_Months__c = 1);
        insert new PachinkoCaseTypes__c(Name = 'Test 1234', Code__c = 'Test 1234');
        
        // === Disable heavy logic if flags are available ===
       
        CaseUtility.GSEMrun = true;
        RecursiveTriggerRestrictiion.run = true;
        
        // === Create Case ===
        Case testCase = new Case(
            Status = 'Open',
            AccountId = account.Id,
            ContactId = contact.Id,
            AssetId = asset.Id,
            casecatCategory__c = 'Backup Integration',
            caseSubCategory__c = 'CommVault',
            casePachinkoCaseType__c = 'Test 1234'
        );
        insert testCase;
        
        // === Update Case to simulate closure ===
        testCase.casecatCategory__c = 'Cisco UCS Integration';
        testCase.caseSubCategory__c = 'Boot from SAN';
        testCase.Status = 'Closed';
        testCase.Technology_Area__c = '3rd Party Apps';
        testCase.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        
        Test.startTest();
        try {
            update testCase;
        } catch (DmlException e) {
            System.debug('Update failed: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    static testMethod void caseE2rForOps()
    {
        pachinko_case_type__c pctype;
        Threshold_limit__c thresholdlmt;
        Case aCase;
        Case_Docket__c cDocket;
        CaseDocketFieldDefinition__c cdfd;  
        
        pctype = new pachinko_case_type__c(Monthly_Threshold__c = 3,
                                           Pachinko_Case_Type__c = 'TEST.e2r',
                                           Recommendation_Text__c = 'Type1 rec text',
                                           Threshold_Applies_To__c = 'Case',
                                           Leave_Case_Open__c = false,
                                           Enabled__c = true);
        insert pctype;
        
        thresholdlmt = new Threshold_limit__c(Name = 'limit',Number_of_Months__c = 1);
        insert thresholdlmt;
        
        cDocket = new Case_Docket__c(Name = 'TEST.e2r',cdCasePriority__c='P4',
                                     cdDescription__c ='TEST-DESCRIPTION',cdLabel__c='TEST E2r Docket',
                                     cdHideOnPortal__c = FALSE,cdResponsibleBUTeam__c='OPSBOT',cdDocketType__c = 'Request');
        insert cDocket;
         
         
        Id aCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId();
        
        aCase = new Case(Status='New',
                         Origin ='TEST.e2r',
                         RecordTypeId = aCaseRecordTypeId,
                         SuppliedName = 'Ramireddy Vishnu',
                         SuppliedEmail ='vishnu.ramireddy@hpe.com',
                         Subject = 'E2R for NS Ops case Request..!',
                         Description = 'E2R for NS Ops case Request');
        insert aCase;           
    }
    
    static testMethod void caseOwnerValidationAfterUpdate_UserToUser()
    {
        
        
        
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        
        Id aCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId();
             
        Case aCase = new Case(AccountId = acct.Id,
                              caseCatImpactToCustomer__c = 'Just a question - no service impact',
                              Case_Type__c = 'Internal',
                              AssetId = null,
                              OwnerId = '0052H00000BzCiQQAV' ); // Mike Carter
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        aCase.setOptions(dmo);
                
        insert aCase;
        Test.startTest();
        caseEscalationTypeDefinition__c caseEscTypeDef = new caseEscalationTypeDefinition__c();
        caseEscTypeDef.Name = 'Executive Escalation';
        caseEscTypeDef.caseEscalationTypeDefinitionGroup__c = 'Executive Escalation';
        
        insert caseEscTypeDef;
        
        caseEscalation__c execEsc = new caseEscalation__c();
        
        execEsc.caseEscalationCase__c = aCase.Id;  
        execEsc.Case_Owner__c = aCase.OwnerId; // Mike Carter
        execEsc.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        insert execEsc;
        
        // re-assign case
        aCase = [SELECT OwnerId FROM Case WHERE Id=:aCase.Id];
        aCase.OwnerId =  '0052H00000DPuL7QAL'; //Peter Landry
        aCase.setOptions(dmo);
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        update aCase;
        
        execEsc = [SELECT Id, Name, Case_Owner__c, Current_Escalation_Owner__c, Static_Escalation_Owner__c, Escalation_PSM__c FROM caseEscalation__c WHERE Id=:execEsc.Id AND Case_Owner__c =:aCase.OwnerId];
        
        Test.stopTest();

            

    }
    
    static testMethod void caseOwnerValidationAfterUpdate_UserToQueue()
    {
        System.debug('TEST ENTRY: caseOwnerValidationAfterUpdate_UserToQueue - execEsc');
        
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        
        Id aCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId();
        
        
        
        Case aCase = new Case(AccountId = acct.Id,
                              caseCatImpactToCustomer__c = 'Just a question - no service impact',
                              Case_Type__c = 'Internal',
                              AssetId = null,
                              OwnerId = '0052H00000BzCiQQAV' ); // Mike Carter
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        aCase.setOptions(dmo);
        
        insert aCase;
        
        caseEscalationTypeDefinition__c caseEscTypeDef = new caseEscalationTypeDefinition__c();
        caseEscTypeDef.Name = 'Executive Escalation';
        caseEscTypeDef.caseEscalationTypeDefinitionGroup__c = 'Executive Escalation';
        
        insert caseEscTypeDef;
        Test.startTest();
        caseEscalation__c execEsc = new caseEscalation__c();
        
        execEsc.caseEscalationCase__c = aCase.Id;  
        execEsc.Case_Owner__c = '0052H00000BzCiQQAV'; // Mike Carter
        execEsc.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        insert execEsc;
        
        System.debug('setup - execEsc.Case_Owner__c:  ' + execEsc.Case_Owner__c);
        System.debug('setup - execEsc.Current_Escalation_Owner__c:  ' + execEsc.Current_Escalation_Owner__c);
        System.debug('setup - execEsc.Static_Escalation_Owner__c:  ' + execEsc.Static_Escalation_Owner__c);
        System.debug('setup - execEsc.Escalation_PSM__c:  ' + execEsc.Escalation_PSM__c);
      
        
        
        // re-assign case
        aCase = [SELECT OwnerId FROM Case WHERE Id=:aCase.Id];
        aCase.OwnerId = '00G80000001ucU1'; //Support Queue - General
        aCase.setOptions(dmo);
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        update aCase;
        
        Test.stopTest();

    }
    
    static testMethod void caseOwnerValidationAfterUpdate_QueueToUser()
    {
       
        
        Account acct = new Account(Name = 'Test Account', PSM_Email__c = 'lawrence.wasser@hpe.com');
        insert acct;
        
        Id aCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId();
        
        
        
        Case aCase = new Case(AccountId = acct.Id,
                              caseCatImpactToCustomer__c = 'Just a question - no service impact',
                              Status = 'New',
                              Sub_Status__c = null,
                              Case_Type__c = 'Internal',
                              AssetId = null,
                              OwnerId = '00G80000001ucU1' ); // Support Queue - General
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        aCase.setOptions(dmo);
        
        insert aCase;
        
        caseEscalationTypeDefinition__c caseEscTypeDef = new caseEscalationTypeDefinition__c();
        caseEscTypeDef.Name = 'Executive Escalation';
        caseEscTypeDef.caseEscalationTypeDefinitionGroup__c = 'Executive Escalation';
        
        insert caseEscTypeDef;
        Test.startTest();
        caseEscalation__c execEsc = new caseEscalation__c();
        
        execEsc.caseEscalationCase__c = aCase.Id;  
        execEsc.Case_Owner__c = null; 
        execEsc.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        insert execEsc;
        
        /* re-assign case
        aCase = [SELECT OwnerId,Sub_Status__c FROM Case WHERE Id=:aCase.Id];
        aCase.Sub_Status__c = 'Assigned';
        aCase.OwnerId = '0052H00000DPuL7QAL'; //Peter Landry
        aCase.setOptions(dmo);
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        update aCase;*/
        
        execEsc = [SELECT Id, Name, Case_Owner__c, Current_Escalation_Owner__c, Static_Escalation_Owner__c, Escalation_PSM__c FROM caseEscalation__c WHERE Id=:execEsc.Id];
        
        
        Test.stopTest();


    }
    static testMethod void testPSMAlert(){
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;

        Account acc = new Account(Name = 'Test Account', ACM_Start_Date__c = Date.today(),Primary_PSM__c = u.Id, ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true,CS_PSM__c=true,Primary_CS_PSM__c = u.Id);
        insert acc;


        Product2 testProduct = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S3211A',
                                             Product_Type__c    ='Hardware',
                                             Product_Type_2__c  ='Array Type',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='Array Type');
        
        insert testProduct;
        Asset asst = new Asset(Name                        = 'AA-111122', 
                               AccountId                    = acc.Id, 
                               Product2Id                   = testProduct.id,
                               HPE_Serial_Number__c         = 'AFTestM11',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Asset_Type_Build__c          = 'Array Type',
                               Status                       = 'Shipped',
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T',
                               assetConcierge_Service__c = true);
        insert asst;
        
        Contact contact1 = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = acc.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact1;

        Contact alternateContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
        AccountId = acc.Id,
        Email='test1@gmail.com',
        Phone='999999999');
        insert alternateContact;

        Id recordTypeForCase = [select Id, Name from RecordType where Name = 'Array Case' LIMIT 1].Id;
       
        Test.startTest();
        Case c2 = new Case(Status = 'New',
                            Sub_Status__c = 'Assigned', 
                           Origin = 'Web', 
                           Priority='P2', 
                           Alternate_Contact_Name__c = alternateContact.Id, 
                           ContactId = contact1.Id,
                           AssetId = asst.Id,
                           AccountId = acc.Id,
                           Subject = 'Testing',
                           Case_Type__c = 'External',
                           caseDontSendCaseOpenEmail__c = false,
                           RecordTypeId = recordTypeForCase
                           ); 
        insert c2;
        Test.stopTest();
    }

    static testMethod void testCSPSMAlert(){
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        Product_Support_Profile__c psp = new Product_Support_Profile__c(Name = 'Alletra MP File');
        insert psp;
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;

        Account acc = new Account(Name = 'Test Account', CS_PSM__c = true,Primary_CS_PSM__c = u.Id);
        insert acc;

        Contact contact1 = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = acc.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact1;
        //Account acc = new Account(Name = 'Test Account',);
        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             Product_Type__c    ='Hardware',
                                             Product_Type_2__c  ='File Storage',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='File Storage',
                                             Support_Profile__c = psp.id,
                                             Support_Profile_Name__c = 'Alletra MP File');
        insert testProduct1;
        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = acc.Id, 
                               Product2Id                   = testProduct1.id,
                               HPE_Serial_Number__c         = 'AFTestM10',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Asset_Type_Build__c          = 'File Storage',
                               Status                       = 'Shipped',
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Program__c = 'PCAI',
                               Array_Capacity__c            = '11T');
        insert asst;
        String assetType = [Select Asset_Type__c From Asset Where Id =: asst.Id].Asset_Type__c;
        System.assertEquals(assetType,'File Storage');

        Id recordTypeForCase = [select Id, Name from RecordType where Name = 'Array Case' LIMIT 1].Id;
        Test.startTest();
        Case c1 = new Case(Status = 'New', 
                           Origin = 'Web', 
                           Priority='P1', 
                           ContactId = contact1.Id,
                           AssetId = asst.Id,
                           AccountId = acc.Id,
                           Subject = 'Testing',
                           Case_Type__c = 'External',
                           caseDontSendCaseOpenEmail__c = false,
                           changeOwnerIdTo__c = '00G80000001ucU1EAI',
                           RecordTypeId = recordTypeForCase,
                           Technology_Area__c = '3rd Party Apps',
                           Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)'
                           ); 
        insert c1;
        Test.stopTest();
    }
    
    static testMethod void testNonPSM(){
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact contact1 = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = acc.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact1;
        //Account acc = new Account(Name = 'Test Account',);
        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             Product_Type__c    ='Hardware',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='Adaptive Flash Array Gen5'
                                   );
        insert testProduct1;
        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = acc.Id, 
                               Product2Id                   = testProduct1.id,
                               HPE_Serial_Number__c         = 'AFTestM10',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Status                       = 'Shipped',
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        String assetType = [Select Asset_Type__c From Asset Where Id =: asst.Id].Asset_Type__c;
        //System.assertEquals(assetType,'File Storage');

        Id recordTypeForCase = [select Id, Name from RecordType where Name = 'Array Case' LIMIT 1].Id;
        Test.startTest();
        Case c1 = new Case(Status = 'New', 
                           Origin = 'Web', 
                           Priority='P1', 
                           ContactId = contact1.Id,
                           AssetId = asst.Id,
                           AccountId = acc.Id,
                           Subject = 'Testing',
                           Case_Type__c = 'External',
                           caseDontSendCaseOpenEmail__c = false,
                           RecordTypeId = recordTypeForCase,
                           Technology_Area__c = '3rd Party Apps',
                           Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)'
                           ); 
        insert c1;
        Test.stopTest();
    }
    
    static testMethod void testNonPSMFileStorage(){
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;
        
        Product_Support_Profile__c psp = new Product_Support_Profile__c(Name = 'Alletra MP Block');
        insert psp;
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact contact1 = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = acc.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact1;
        //Account acc = new Account(Name = 'Test Account',);
        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             Product_Type__c    ='Hardware',
                                             Product_Type_2__c  ='BlockStorage',
                                             Controller_Code__c ='CS200',
                                             Support_Profile__c = psp.id,
                                             Support_Profile_Name__c = 'Alletra MP Block',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='Block Storage');
        insert testProduct1;
        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = acc.Id, 
                               Product2Id                   = testProduct1.id,
                               HPE_Serial_Number__c         = 'AFTestM10',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Asset_Type_Build__c          = 'Block Storage',
                               Status                       = 'Shipped',
                               Component_SKU_HPE__c         = 'R4U28A',
                               dHCI__c = true,
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        String assetType = [Select Asset_Type__c From Asset Where Id =: asst.Id].Asset_Type__c;
        System.assertEquals(assetType,'Block Storage');

        Id recordTypeForCase = [select Id, Name from RecordType where Name = 'Array Case' LIMIT 1].Id;
        Test.startTest();
        Case c1 = new Case(Status = 'New', 
                           Origin = 'Web', 
                           Priority='P1', 
                           ContactId = contact1.Id,
                           AssetId = asst.Id,
                           AccountId = acc.Id,
                           Subject = 'Testing',
                           Case_Type__c = 'External',
                           caseDontSendCaseOpenEmail__c = false,
                           RecordTypeId = recordTypeForCase,
                           Technology_Area__c = '3rd Party Apps',
                           Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)'
                           ); 
        insert c1;
        Test.stopTest();
    }
   static testMethod void UpdateBonusContactOnCase(){
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
       insert u;
       string supportProvider = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Provider').getRecordTypeId();
       Account acc1 = new Account(Name = 'Test Account', RecordTypeId = supportProvider, Send_Emails_to_Contact__c = true,AllowUseOfBonusContacts__c = true);
       insert acc1;
       Account acc = new Account(Name = 'Test Account',Support_Provider__c = acc1.Id,AllowUseOfBonusContacts__c = true);
       insert acc;
       
       Contact contact1 = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = acc.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact1;
        Contact contact2 = new Contact(LastName = 'TEST-CONTACT-LAST-NAME for Secondary Contact',
                                        AccountId = acc.Id,
                                      Email='test123@gmail.com',
                                      Phone='999999999');
        insert contact2;
        //Account acc = new Account(Name = 'Test Account',);
        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             Product_Type__c    ='Hardware',
                                             Product_Type_2__c  ='File Storage',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='File Storage');
        insert testProduct1;
        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = acc.Id, 
                               Product2Id                   = testProduct1.id,
                               HPE_Serial_Number__c         = 'AFTestM10',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               ContactSecondary__c          =  contact1.id ,
                               ContactTertiary__c          =   contact2.id,
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Asset_Type_Build__c          = 'File Storage',
                               Status                       = 'Shipped',
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        String assetType = [Select Asset_Type__c From Asset Where Id =: asst.Id].Asset_Type__c;
        System.assertEquals(assetType,'File Storage');

        Id recordTypeForCase = [select Id, Name from RecordType where Name = 'Array Case' LIMIT 1].Id;
       Test.startTest();
       
       Case c1 = new Case(Status = 'New', 
                           Origin = 'Web', 
                           Priority='P1', 
                           ContactId = contact1.Id,
                           AssetId = asst.Id,
                           AccountId = acc.Id,
                           Subject = 'Testing',
                           Case_Type__c = 'External',
                           caseDontSendCaseOpenEmail__c = false,
                           RecordTypeId = recordTypeForCase,
                           Technology_Area__c = '3rd Party Apps',
                           Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)'
                           ); 
        insert c1;
        Test.stopTest();
    }
    //Added by Exafort 
     static testMethod void TestMethod1(){
            Case_Docket__c cDocket;
            insert cDocket = new Case_Docket__c(Name = 'TEST-ASSET',cdCasePriority__c='P1',cdDescription__c ='TEST-DESCRIPTION',cdLabel__c='TEST-ASSET',
            cdDocketType__c  = 'Request',cdHideOnPortal__c = FALSE,cdUnderlyingObject__c = 'Case',cdResponsibleBUTeam__c='Renewals', cddonotupdateparentcase__c = false);

            Account account = new Account();
            account.Name = 'test corp';
            account.phone= '01123123';
            account.billingcity='London';
            account.billingpostalcode='SW1635HJ';
            account.billingcountry='United Kingdom';
            account.billingstreet='address 1';
            insert account;
            
            //Insert contact for Account
            Contact c = new Contact();
            c.AccountId = account.ID;
            c.FirstName = 'test';
            c.LastName = 'test';
            c.email = 'test@gmail.com';
            c.birthdate = Date.newInstance(1992, 04, 12);
            insert c;
        
            RecordType recordTypeOPScase = [select id,Name from RecordType where SobjectType='case' and Name='OPS Case' Limit 1];
            Case cas= new Case();
            cas.Subject= 'testsubject';
            cas.Status ='Closed';
            cas.Technology_Area__c = '3rd Party Apps';
            cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
            cas.Origin = 'phone';
            cas.Auto_Close__c = true;
            cas.ContactId = c.Id;
            cas.RecordTypeId = recordTypeOPScase.id;
         try{
             insert cas;
         }
         catch(DmlException e) {
             System.debug('The following exception has occurred: ' + e.getMessage());
         }

            Case cas1= new Case();
            cas1.Subject= 'testsubject';
            cas1.Status ='Closed';
            cas1.Technology_Area__c = '3rd Party Apps';
            cas1.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
            cas1.Origin = 'phone';
            cas1.Auto_Close__c = true;
            cas1.ContactId = c.Id;
            cas1.CaseDocket__c = cDocket.Id; 
            cas1.CaseMapping__c = cas.Id;
            cas1.RecordTypeId = recordTypeOPScase.id;
         try{
            insert cas1;
         }
         catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
         test.startTest(); 

            cas.caseAttnReq__c = True;
            cas.caseAttnReqDateTime__c = DateTime.now();
            cas.CaseDocket__c = cDocket.Id; 
            cas.CaseMapping__c = cas1.Id;
            cas.Current_comment_time_spent__c = 15;
            cas.Status = 'Closed(Duplicate)';
            cas.Alternate_Contact_Name__c = c.id;
            update cas;

            cas.Current_comment_activity__c = 'General Case Work';
            update cas;

            
              CaseComment   tComment = new CaseComment();
              tComment.ParentId = cas.Id;
              tComment.CommentBody = 'Test class comment';   
              tComment.IsPublished = True;
              
              insert tComment;
            test.stopTest(); 
        }
    @IsTest//(SeeAllData=true)
    static  void SupportQueueAutomaticCase(){
        
        Group supportQueueAutomatic = [Select id from group where name ='Support Queue - Automatic'];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = supportQueueAutomatic.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm;
        }
        
        Case c1 = new Case(Status = 'New', Origin = 'Phone', Priority='P2',Current_comment_time_spent__c = 2,Auto_Close__c = true,OwnerId = supportQueueAutomatic.id,casePlanOfAction__c = 'Test Plan');
        insert c1;
        Test.startTest();
        c1.Priority = 'P3';
        //c1.OwnerId = supportQueueAutomatic.id;
       // c1.Auto_Close__c = true;
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
        //Id NCVId = [select Id, Name from RecordType where Name = 'NCV Case' LIMIT 1].Id;
        Id SDOEId = [select Id, Name from RecordType where Name = 'SDOE' LIMIT 1].Id;
        //NCV Case is not in use, deactivated in SFDC-1594, hence removing the below code.
       /*Case c2 = new Case(Status = 'New', Origin = 'Phone', Priority='P2',
                          Current_comment_time_spent__c = 2,Auto_Close__c = true,OwnerId = supportQueueAutomatic.id,
                          RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NCV Case').getRecordTypeId(),casePlanOfAction__c = 'Test Plan');
        insert c2;*/
        Case c3 = new Case(Status = 'New', Origin = 'Phone', Priority='P2',Current_comment_time_spent__c = 2,
                           Auto_Close__c = true,OwnerId = supportQueueAutomatic.id,
                           RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SDOE').getRecordTypeId(),casePlanOfAction__c = 'Test Plan');
        insert c3;
         
        //update c1;
         
        Test.stopTest();
    }
    ////NCV Case is not in use, deactivated in SFDC-1594, hence removing the below code.
    /*@IsTest//(SeeAllData=true)
    static  void SupportQueueAutomaticCaseNCV(){
        
        Group supportQueueAutomatic = [Select id from group where name ='Support Queue - Automatic'];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = supportQueueAutomatic.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm;
        }
        Test.startTest();
       
        //c1.OwnerId = supportQueueAutomatic.id;
       // c1.Auto_Close__c = true;
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;

       Case c2 = new Case(Status = 'New', Origin = 'Phone', Priority='P2',Current_comment_time_spent__c = 2,
                          Auto_Close__c = true,OwnerId = supportQueueAutomatic.id,
                          RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NCV Case').getRecordTypeId(),casePlanOfAction__c = 'Test Plan');
        insert c2;
       
         
        //update c1;
         
        Test.stopTest();
    }*/
    @IsTest//(SeeAllData=true)
    static  void SupportQueueAutomaticCaseSDOE(){
        
        Group supportQueueAutomatic = [Select id from group where name ='Support Queue - Automatic'];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = supportQueueAutomatic.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm;
        }
        
        
        Test.startTest();
       
        //c1.OwnerId = supportQueueAutomatic.id;
       // c1.Auto_Close__c = true;
        RecursiveTriggerRestrictiion.run = true;
        //CaseUtility.caseUpdateRun = true;
         
        Case c3 = new Case(Status = 'New', Origin = 'Phone', Priority='P2',
                           Current_comment_time_spent__c = 2,Auto_Close__c = true,OwnerId = supportQueueAutomatic.id,
                           RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SDOE').getRecordTypeId(),casePlanOfAction__c = 'Test Plan');
        insert c3;
         
        //update c1;
         
        Test.stopTest();
    }
     @IsTest//(SeeAllData=true)
    static  void managementEscalationUpdate(){
        Account account = new Account(Name = 'TEST-ACCOUNT');
        insert account;
        Management_Escalation__c managerEscalationInsert = new Management_Escalation__c();
        managerEscalationInsert.Severity__c = 'Red';
        managerEscalationInsert.Region__c = 'AMS';
        managerEscalationInsert.Customer_Temp__c = 'Test';  
        managerEscalationInsert.Executive_Visibility__c = 'Yes';
        managerEscalationInsert.Account__c = account.id;
        insert managerEscalationInsert;
        Case c1 = new Case(Status = 'New', Origin = 'Phone' ,AccountId = account.Id);
        insert c1;
        case c2 = new case();
        c2.id = c1.Id;
        c2.Status = 'Closed';
        Update c2;
    }
    
    
    public static testMethod void test01(){
        
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimble');
        
        insert psp;

        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test2@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        
        insert u;

        
        User u1 = new User(Alias = 'testMe', Email='standardusertest@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', 
                           ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles',
                           TrainingEnabled__c = false,
                           pilot_user__c = false,
                           UserName=uniqueUserName1);
        
        insert u1;

        Account account = new Account(Name = 'Test Account', Primary_CS_PSM__c = u1.Id,ACM_Start_Date__c = Date.today(),Primary_PSM__c = u.Id, ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
        insert account;
 
        Contact c1 = new Contact();
        c1.AccountId = account.ID;
        c1.FirstName = 'test1';
        c1.LastName = 'test1';
        c1.email = 'test1@gmail.com';
        insert c1;

        //Insert contact for Account
        
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;

        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             Product_Type__c    ='Hardware',
                                             Support_Profile__c = psp.Id,
                                             Support_Profile_Name__c = 'Legacy Nimble',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='Adaptive Flash Array Gen5'
                                             
                                            );
        
        insert testProduct1;
        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = account.Id, 
                               Product2Id                   = testProduct1.id,
                               HPE_Serial_Number__c         = 'AFTestM10',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Status                       = 'New',
                               assetConcierge_Service__c = true,
                               CS_PSM__c=true,
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        
        insert asst;
 
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        Case cas= new Case();
        cas.Subject= 'testsubject';
        cas.Status ='Closed';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.Alternate_Contact_Name__c = c1.Id;
        cas.ContactId = c.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        test.starttest();
        insert cas;
        test.stoptest();
        
    }

    public static testMethod void test01A(){
        Product_Support_Profile__c psp = new Product_Support_Profile__c(name = 'Legacy Nimble');
        insert psp;

        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test2@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        
        insert u;

        Account account = new Account(Name = 'Test Account', Primary_CS_PSM__c = u.Id,ACM_Start_Date__c = Date.today(),Primary_PSM__c = u.Id, ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
        insert account;

        Contact c1 = new Contact();
        c1.AccountId = account.ID;
        c1.FirstName = 'test1';
        c1.LastName = 'test1';
        c1.email = 'test1@gmail.com';
        insert c1;

        //Insert contact for Account
        
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@gmail.com';
        c.birthdate = Date.newInstance(1992, 04, 12);
        insert c;
        
        
        
        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             
                                             Product_Type__c    ='Hardware',
                                             
                                             Support_Profile__c = psp.Id,
                                             
                                             Support_Profile_Name__c = 'Legacy Nimble',
                                             
                                             Controller_Code__c ='CS200',
                                             
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             
                                             Family             ='Adaptive Flash Array Gen5'
                                             
                                            );
        
        insert testProduct1;
        
        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = account.Id, 
                               Product2Id                   = testProduct1.id,
                               HPE_Serial_Number__c         = 'AFTestM10',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Status                       = 'Shipped',
                               assetConcierge_Service__c = true,
                               CS_PSM__c=true,
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        
        insert asst;
        
        RecordType recordTypearraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
        
        Case cas= new Case();
        
        cas.Subject= 'testsubject';
        cas.Status ='New';
        cas.AssetId = asst.Id;
        cas.AccountId = account.Id;
        cas.Alternate_Contact_Name__c = c1.Id;
        cas.ContactId = c.Id;
        cas.Origin = 'phone';
        cas.Auto_Close__c = true;
        cas.ContactId = c.Id;
        cas.Technology_Area__c = '3rd Party Apps';
        cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
        cas.RecordTypeId = recordTypearraycase.id;
        test.starttest();
        insert cas;
        test.stoptest();
        
    }
}