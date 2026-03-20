@isTest
class TestCaseTrigger
{
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
        Case c = new Case(casecatCategory__c='Backup Integration',caseSubCategory__c='CommVault');
        insert c;
        CaseComment cc = [select Id,CommentBody from CaseComment where ParentId=:c.Id AND CommentBody LIKE '%1.Question%' LIMIT 1];
        System.assertEquals(n1.Notes__c,cc.CommentBody);
        Case uCase = [select Id, LatestCommentId__c from Case where Id =: c.Id];
        System.assertEquals(cc.Id,uCase.LatestCommentId__c);
        Test.startTest();
        //Update a case
        c.casecatCategory__c = 'Cisco UCS Integration';
        c.caseSubCategory__c = 'Boot from SAN';
        update c;
        CaseComment cc1 = [select Id,CommentBody from CaseComment where ParentId=:c.Id  AND CommentBody LIKE '%1.Question%' LIMIT 1];
        System.assertEquals(n2.Notes__c,cc1.CommentBody);
        Case uCase1 = [select Id, LatestCommentId__c from Case where Id =: c.Id];
        System.assertEquals(cc1.Id,uCase1.LatestCommentId__c);
        Test.stopTest();
    }
/*static testMethod void testOOOLoop()
{
Case c = new Case(Subject = 'Out Of Office');
try
{
insert c;
}
catch(Exception e)
{

}
}*/
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
        update c2;
        Test.stopTest();
    }
    static testMethod void P1AlertTextingInsert(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Phone', Priority='P1');
        insert c1;
        Test.stopTest();
    }
    static testMethod void P1AlertTextingUpdate(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Phone', Priority='P2');
        insert c1;
        c1.Priority = 'P1';
        update c1;
        Test.stopTest();
    }
    static testMethod void engageNCVBillingTest(){
        Case c1 = new Case(Status = 'New', Origin = 'Phone', Priority='P2', caseEngageNCVBilling__c = false);
        insert c1;
        Test.startTest();
        assetPreventRecursive.run = true;
        CountAssetPreventRecursive.run = true;
        c1.caseEngageNCVBilling__c = true;
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
        update c1;
        Test.stopTest();
    }
    static testMethod void addCaseCommentForExpiredAssetAddress(){
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'contact';
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        PachinkoCaseTypes__c pachinkoCode = new PachinkoCaseTypes__c();
        pachinkoCode.Name = 'testcaseType';
        pachinkoCode.Code__c = 'testcaseType';
        insert pachinkoCode;
        Threshold_limit__c t1 = new Threshold_limit__c();
        t1.Name = 'limit';
        t1.Number_of_Months__c = 10;
        insert t1;
         Product2 aProduct = new Product2(Name = 'CS220 Storage Array',
                                                 ProductCode='CS220', 
                                                 Product_Type__c='Hardware',
                                                 Product_Type_2__c='SAN Storage Array',
                                                 Controller_Code__c='CS200',
                                                 Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                                 Family='SAN Storage Array');  
        insert aProduct;
        
        Asset assetRec = new Asset();
        assetRec.Name = 'testAsset';
        assetRec.AccountId = acc.Id;
        assetRec.Dynamic_SKU__c = 'CS700-4F-36T-3200F';
        assetRec.Product2Id = aProduct.Id;
        assetRec.HPE_Serial_Number__c ='testAssetNIM';
        assetRec.assetPartShipLastValidatedDatetime__c = System.now().addDays(-190);
        
        insert assetRec;
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2', casePachinkoCaseType__c = 'testcaseType', AssetId=assetRec.Id, ContactId = con.Id);
        insert c1;
        Test.stopTest();
    }
    //@isTest(seeAllData = true)
    static testMethod void slaExpiryOwnerUpdateP1(){
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
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P1', OwnerId = testGroup.id);
        insert c1;
        c1.OwnerId = userinfo.getUserId();
        //c1.SLAWhenOwnerChanged__c = '1 hours 59 minutes';
        //c1.caseOwnerChanged__c = true;
        update c1;
        //CaseComment slaCommentforp1 = new CaseComment(CommentBody = 'Willie Sarazin took ownership (priority:P2, age(days): 0.00, sla: 2 hours, status: 1 hours 59 minutes>0, ‘met’ : yes)',IsPublished = False,ParentId = c1.Id);
        //insert slaCommentforp1;
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
        c1.OwnerId = '00580000005J7vc';//userinfo.getUserId();
        //c1.SLAWhenOwnerChanged__c = '1 hours 59 minutes';
        //c1.caseOwnerChanged__c = true;
        update c1;
        //CaseComment slaCommentforp2 = new CaseComment(CommentBody = 'Willie Sarazin took ownership (priority:P2, age(days): 0.00, sla: 2 hours, status: 1 hours 59 minutes>0, ‘met’ : yes)',IsPublished = False,ParentId = c1.Id);
        //insert slaCommentforp2;
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
        c1.OwnerId = '00580000005J7vc';//userinfo.getUserId();
        //c1.SLAWhenOwnerChanged__c = '1 hours 59 minutes';
        //c1.caseOwnerChanged__c = true;
        update c1;
        //CaseComment slaCommentforp3 = new CaseComment(CommentBody = 'Willie Sarazin took ownership (priority:P2, age(days): 0.00, sla: 2 hours, status: 1 hours 59 minutes>0, ‘met’ : yes)',IsPublished = False,ParentId = c1.Id);
        //insert slaCommentforp3;
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
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P4', OwnerId = testGroup.id);
        insert c1;
        c1.OwnerId = '00580000005J7vc';//userinfo.getUserId();
        //c1.SLAWhenOwnerChanged__c = '1 hours 59 minutes';
        //c1.caseOwnerChanged__c = true;
        update c1;
        //CaseComment slaCommentforp4 = new CaseComment(CommentBody = 'Willie Sarazin took ownership (priority:P2, age(days): 0.00, sla: 2 hours, status: 1 hours 59 minutes>0, ‘met’ : yes)',IsPublished = False,ParentId = c1.Id);
        //insert slaCommentforp4;
        }
    }
    static testMethod void CaseEscalationType(){
        Test.startTest();
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',caseEscalationType__c='Not Escalated');
        insert c1;
        Test.stopTest();
    }
    static testMethod void CaseOwnerChange(){
        User u=[Select Id From User Where Alias ='NSForce' Limit 1];
        Case c1  = new Case(Status = 'New', Origin = 'Email', Priority='P2');
        //Added by exafort for TriggerAction - Start*/
        System.runAs(u) {
        insert c1;
        }
        //Added by exafort for TriggerAction - End*/
        Test.startTest();
        system.debug('Origin :'+c1.Origin);
        c1.OwnerId = userinfo.getUserId();
        update c1; 
        Test.stopTest();
    }
    static testMethod void CaseCloseTest(){ 
        Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2');
        insert c1;
        Test.startTest();
        c1.Technology_Area__c = 'Test';
        c1.Sub_Technology_Area__c ='Test';
        c1.Status ='Closed';
        update c1;
        Test.stopTest();
    }
    static testMethod void CaseIgnoreSubjects00(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Out of office');
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
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Automatisch antwoord');
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
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Automatisch');
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
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Absence Re');
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
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Automatische Antwort');
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
           insert c1;
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
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects22(){
        
        try  
        {
            Account acc = new Account();
            acc.Name = 'testAccount';
            insert acc;
            Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Vacation',AccountId=acc.Id);
            insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects23(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='auto response');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects24(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Out of Office');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects25(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Automatic reply');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects26(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Delivery delayed:');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects27(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Delivery delayed:New case comment notification.');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects28(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='Undeliverable');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    static testMethod void CaseIgnoreSubjects29(){
        try  
        {
           Case c1 = new Case(Status = 'New', Origin = 'Email', Priority='P2',Subject='[알림] 휴가로 인한 부재');
           insert c1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Out-of-office type subjects are not allowed to create new cases.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }   
}