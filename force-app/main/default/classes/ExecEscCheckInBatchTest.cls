@isTest(SeeAllData=false)
public class ExecEscCheckInBatchTest 
{
    static testMethod void createExecEscCheckInBatch()
    {
        Test.startTest();
        
        // create Account
        Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;
        
        //create Asset
        Asset testAsset = new Asset();
        testAsset.Name = 'AF-20223X';
        testAsset.AccountId = acct.Id;
        testAsset.Array_Controller__c = 'AF1000';
        testAsset.Array_Networking__c = '2F';
        testAsset.Array_Controller_SKU__c = 'TEST CONTROLLER SKU';
        
        //insert testAsset;
        
        //Asset realAsset = [SELECT Id FROM Asset WHERE Name = 'AF-202232'];
        
        //Asset clonedAsset = realAsset.clone(false,false,false,false);
        //clonedAsset.Name = 'AF-20223X';
        //clonedAsset.AccountId = acct.Id;
        //clonedAsset.Array_Controller__c = 'AF1000';
        //clonedAsset.Array_Networking__c = '2F';
        //clonedAsset.Array_Controller_SKU__c = 'TEST CONTROLLER SKU';
        //insert clonedAsset;
        
        // create a Case 
        Case caseForEsc = new Case();
        
        caseForEsc.RecordTypeId = '01234000000BnF4AAK'; // get record type of Array Case
        caseForEsc.AccountId = acct.Id;
        caseForEsc.Origin = 'Phone';
        caseForEsc.Status = 'New';
        caseForEsc.caseCatImpactToCustomer__c = 'Just a question - no service impact';
        caseForEsc.Type = 'Eval';
        caseForEsc.AssetId = testAsset.Id;
        caseForEsc.Estimated_Effort__c = '1 day';
        
        insert caseForEsc;
        
        // make clone so 2nd escalation creation doesn't fail
        Case caseForEsc2 = caseForEsc.clone(false,false, false, false);
        insert caseForEsc2;
        
        // make clone so 2nd escalation creation doesn't fail
        Case caseForEsc3 = caseForEsc.clone(false,false, false, false);
        //insert caseForEsc3;
        
        caseEscalationTypeDefinition__c caseEscTypeDef = new caseEscalationTypeDefinition__c();
        caseEscTypeDef.Name = 'Executive Escalation';
        caseEscTypeDef.caseEscalationTypeDefinitionGroup__c = 'Executive Escalation';
        
        insert caseEscTypeDef;

        
        
        //caseEscalationTypeDefinition__c execEscTypeDef = [SELECT Id FROM caseEscalationTypeDefinition__c WHERE Name = 'Executive Escalation'];
        
        // get user
        User testUser = [SELECT Id FROM User WHERE Email = 'lawrence.wasser@hpe.com'];
        
        // create a Case Escalation Record which will trip within 30 mins
        caseEscalation__c execEscWithinCadence = new caseEscalation__c();
        
        execEscWithinCadence.caseEscalationCase__c = caseForEsc.Id;
        execEscWithinCadence.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        execEscWithinCadence.Escalation_Closure_Status__c = 'Open';
        execEscWithinCadence.Situational_Assessment__c = 'Evolving';
        execEscWithinCadence.Compact_Problem_Title__c = 'Problem Title for Test Class - Within Cadence';
        execEscWithinCadence.Escalation_Check_In_Cadence__c = '15 MINUTES';
        execEscWithinCadence.Case_Owner__c = testUser.Id;
        execEscWithinCadence.Current_Escalation_Owner__c = testUser.Id;
        execEscWithinCadence.Escalation_PSM__c = testUser.Id;
        execEscWithinCadence.Static_Escalation_Owner__c = testUser.Id;
        execEscWithinCadence.Static_Escalation_Owner_Override__c = testUser.Id;
        
        
        
        
        
        // create a Case Escalation record which has already expired
        caseEscalation__c execEscOutsideCadence = new caseEscalation__c();
        
        execEscOutsideCadence.caseEscalationCase__c = caseForEsc2.Id;
        execEscOutsideCadence.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        execEscOutsideCadence.Escalation_Closure_Status__c = 'Open';
        execEscOutsideCadence.Situational_Assessment__c = 'Evolving';
        execEscOutsideCadence.Compact_Problem_Title__c = 'Problem Title for Test Class - Outside Cadence';
        execEscOutsideCadence.Escalation_Check_In_Cadence__c = '4 Hours';
        execEscOutsideCadence.Case_Owner__c = testUser.Id;
        execEscOutsideCadence.Current_Escalation_Owner__c = testUser.Id;
        execEscOutsideCadence.Escalation_PSM__c = testUser.Id;
        execEscOutsideCadence.Static_Escalation_Owner__c = testUser.Id;
        execEscOutsideCadence.Static_Escalation_Owner_Override__c = testUser.Id;
        
        // force a cadence expiration
        DateTime rightNow = System.now();
        execEscOutsideCadence.Last_Escalation_Check_In__c = System.now()-1;
        System.debug('rightNow: ' + rightNow);
        System.debug('Last_Escalation_Check_In__c: ' + execEscOutsideCadence.Last_Escalation_Check_In__c);
        
        // create a Case Escalation record which has already expired
        caseEscalation__c execEscOutsideCadence2 = new caseEscalation__c();
        
        execEscOutsideCadence2.caseEscalationCase__c = caseForEsc3.Id;
        execEscOutsideCadence2.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        execEscOutsideCadence2.Escalation_Closure_Status__c = 'Open';
        execEscOutsideCadence2.Situational_Assessment__c = 'Evolving';
        execEscOutsideCadence2.Compact_Problem_Title__c = 'Problem Title for Test Class - Outside Cadence';
        execEscOutsideCadence2.Escalation_Check_In_Cadence__c = '4 Hours';
        //execEscOutsideCadence2.Case_Owner__c = testUser.Id;
        //execEscOutsideCadence2.Current_Escalation_Owner__c = testUser.Id;
        //execEscOutsideCadence2.Escalation_PSM__c = testUser.Id;
        //execEscOutsideCadence2.Static_Escalation_Owner__c = testUser.Id;
        //execEscOutsideCadence2.Static_Escalation_Owner_Override__c = testUser.Id;
        
        // force a cadence expiration
        //DateTime rightNow = System.now();
        execEscOutsideCadence2.Last_Escalation_Check_In__c = System.now()-1;
        System.debug('rightNow: ' + rightNow);
        System.debug('Last_Escalation_Check_In__c: ' + execEscOutsideCadence2.Last_Escalation_Check_In__c);
        
        try
        {
            insert execEscWithinCadence;
            insert execEscOutsideCadence;
            //insert execEscOutsideCadence2;
        }
        catch(Exception e)
        {
            System.debug('DML Exception: ' + e);
        }
        
        // force out of cadence by shortening the cadence
        execEscOutsideCadence = [SELECT Id, Escalation_Check_In_Cadence__c FROM caseEscalation__c WHERE Id =:execEscOutsideCadence.Id];
        execEscOutsideCadence.Escalation_Check_In_Cadence__c = '1 MINUTE';
        update execEscOutsideCadence;
        
        ExecEscCheckInBatch execEscBatch = new ExecEscCheckInBatch();      
        Database.executebatch(execEscBatch);
        
        Test.stopTest();
        
        return;
    }
    
    static testMethod void createExecEscCheckInBatch2()
    {
        Test.startTest();
        
        // create Account
        Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;
        
        //create Asset
        Asset testAsset = new Asset();
        testAsset.Name = 'AF-20223X';
        testAsset.AccountId = acct.Id;
        testAsset.Array_Controller__c = 'AF1000';
        testAsset.Array_Networking__c = '2F';
        testAsset.Array_Controller_SKU__c = 'TEST CONTROLLER SKU';
        
        //insert testAsset;
        
        //Asset realAsset = [SELECT Id FROM Asset WHERE Name = 'AF-202232'];
        
        //Asset clonedAsset = realAsset.clone(false,false,false,false);
        //clonedAsset.Name = 'AF-20223X';
        //clonedAsset.AccountId = acct.Id;
        //clonedAsset.Array_Controller__c = 'AF1000';
        //clonedAsset.Array_Networking__c = '2F';
        //clonedAsset.Array_Controller_SKU__c = 'TEST CONTROLLER SKU';
        //insert clonedAsset;
        
        // create a Case 
        Case caseForEsc = new Case();
        
        caseForEsc.RecordTypeId = '01234000000BnF4AAK'; // get record type of Array Case
        caseForEsc.AccountId = acct.Id;
        caseForEsc.Origin = 'Phone';
        caseForEsc.Status = 'New';
        caseForEsc.caseCatImpactToCustomer__c = 'Just a question - no service impact';
        caseForEsc.Type = 'Eval';
        caseForEsc.AssetId = testAsset.Id;
        caseForEsc.Estimated_Effort__c = '1 day';
        
        insert caseForEsc;
        
        // make clone so 2nd escalation creation doesn't fail
        Case caseForEsc2 = caseForEsc.clone(false,false, false, false);
        //insert caseForEsc2;
        
        // make clone so 2nd escalation creation doesn't fail
        Case caseForEsc3 = caseForEsc.clone(false,false, false, false);
        insert caseForEsc3;
        
        caseEscalationTypeDefinition__c caseEscTypeDef = new caseEscalationTypeDefinition__c();
        caseEscTypeDef.Name = 'Executive Escalation';
        caseEscTypeDef.caseEscalationTypeDefinitionGroup__c = 'Executive Escalation';
        
        insert caseEscTypeDef;

        
        
        //caseEscalationTypeDefinition__c execEscTypeDef = [SELECT Id FROM caseEscalationTypeDefinition__c WHERE Name = 'Executive Escalation'];
        
        // get user
        User testUser = [SELECT Id FROM User WHERE Email = 'lawrence.wasser@hpe.com'];
        
        // create a Case Escalation Record which will trip within 30 mins
        caseEscalation__c execEscWithinCadence = new caseEscalation__c();
        
        execEscWithinCadence.caseEscalationCase__c = caseForEsc.Id;
        execEscWithinCadence.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        execEscWithinCadence.Escalation_Closure_Status__c = 'Open';
        execEscWithinCadence.Situational_Assessment__c = 'Evolving';
        execEscWithinCadence.Compact_Problem_Title__c = 'Problem Title for Test Class - Within Cadence';
        execEscWithinCadence.Escalation_Check_In_Cadence__c = '15 MINUTES';
        execEscWithinCadence.Case_Owner__c = testUser.Id;
        execEscWithinCadence.Current_Escalation_Owner__c = testUser.Id;
        execEscWithinCadence.Escalation_PSM__c = testUser.Id;
        execEscWithinCadence.Static_Escalation_Owner__c = testUser.Id;
        execEscWithinCadence.Static_Escalation_Owner_Override__c = testUser.Id;
        
        
        
        
        
        // create a Case Escalation record which has already expired
        caseEscalation__c execEscOutsideCadence = new caseEscalation__c();
        
        execEscOutsideCadence.caseEscalationCase__c = caseForEsc2.Id;
        execEscOutsideCadence.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        execEscOutsideCadence.Escalation_Closure_Status__c = 'Open';
        execEscOutsideCadence.Situational_Assessment__c = 'Evolving';
        execEscOutsideCadence.Compact_Problem_Title__c = 'Problem Title for Test Class - Outside Cadence';
        execEscOutsideCadence.Escalation_Check_In_Cadence__c = '4 Hours';
        execEscOutsideCadence.Case_Owner__c = testUser.Id;
        execEscOutsideCadence.Current_Escalation_Owner__c = testUser.Id;
        execEscOutsideCadence.Escalation_PSM__c = testUser.Id;
        execEscOutsideCadence.Static_Escalation_Owner__c = testUser.Id;
        execEscOutsideCadence.Static_Escalation_Owner_Override__c = testUser.Id;
        
        // force a cadence expiration
        DateTime rightNow = System.now();
        execEscOutsideCadence.Last_Escalation_Check_In__c = System.now()-1;
        System.debug('rightNow: ' + rightNow);
        System.debug('Last_Escalation_Check_In__c: ' + execEscOutsideCadence.Last_Escalation_Check_In__c);
        
        // create a Case Escalation record which has already expired
        caseEscalation__c execEscOutsideCadence2 = new caseEscalation__c();
        
        execEscOutsideCadence2.caseEscalationCase__c = caseForEsc3.Id;
        execEscOutsideCadence2.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        execEscOutsideCadence2.Escalation_Closure_Status__c = 'Open';
        execEscOutsideCadence2.Situational_Assessment__c = 'Evolving';
        execEscOutsideCadence2.Compact_Problem_Title__c = 'Problem Title for Test Class - Outside Cadence';
        execEscOutsideCadence2.Escalation_Check_In_Cadence__c = '4 Hours';
        //execEscOutsideCadence2.Case_Owner__c = testUser.Id;
        //execEscOutsideCadence2.Current_Escalation_Owner__c = testUser.Id;
        //execEscOutsideCadence2.Escalation_PSM__c = testUser.Id;
        //execEscOutsideCadence2.Static_Escalation_Owner__c = testUser.Id;
        //execEscOutsideCadence2.Static_Escalation_Owner_Override__c = testUser.Id;
        
        // force a cadence expiration
        //DateTime rightNow = System.now();
        execEscOutsideCadence2.Last_Escalation_Check_In__c = System.now()-1;
        System.debug('rightNow: ' + rightNow);
        System.debug('Last_Escalation_Check_In__c: ' + execEscOutsideCadence2.Last_Escalation_Check_In__c);
        
        try
        {
            //insert execEscWithinCadence;
            //insert execEscOutsideCadence;
            insert execEscOutsideCadence2;
        }
        catch(Exception e)
        {
            System.debug('DML Exception: ' + e);
        }
        
        // force out of cadence by shortening the cadence
        execEscOutsideCadence2 = [SELECT Id, Escalation_Check_In_Cadence__c, Last_Escalation_Check_In__c, Current_Escalation_Owner__c, Static_Escalation_Owner__c  FROM caseEscalation__c WHERE Id =:execEscOutsideCadence2.Id];
        execEscOutsideCadence2.Escalation_Check_In_Cadence__c = '1 MINUTE';
        execEscOutsideCadence2.Current_Escalation_Owner__c = null;

        System.debug('Last_Escalation_Check_In__c: ' + execEscOutsideCadence2.Last_Escalation_Check_In__c);
        update execEscOutsideCadence2;
        
        ExecEscCheckInBatch execEscBatch = new ExecEscCheckInBatch();      
        Database.executebatch(execEscBatch);
        
        Test.stopTest();
        
        return;
    }



}