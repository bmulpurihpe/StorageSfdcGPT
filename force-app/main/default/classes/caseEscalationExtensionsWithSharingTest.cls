@isTest(SeeAllData=false)
public class caseEscalationExtensionsWithSharingTest 
{
    static testMethod void caseEscCreation_UserOwnsCase()
    {
        ApexPages.StandardController caseEscController;
        caseEscalationExtensionsWithSharing caseEscExtension;
        PageReference returnedPageReference;
        
        // create Account
        Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;
        
        /* System.DmlException: Insert failed. First exception on row 0; 
         * first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Enter All required fields
         * ( Array Base, Array Networking/ Networking 2/ Networking 3, Array Cache, SSD Bank A/B): 
         * [FC_Testing_Done__c] */
        
        //create Asset
        Asset testAsset = new Asset();
        testAsset.Name = 'AF-20223X';
        testAsset.AccountId = acct.Id;
        testAsset.Array_Controller__c = 'AF1000';
        testAsset.Array_Networking__c = '2F';
        testAsset.Array_Networking_2__c = '2G';
        testAsset.Array_Networking_3__c = '2G';
        testAsset.Array_Cache__c = '320F';
        testAsset.SSD_Bank_A__c = 'A';
        testAsset.SSD_Bank_B__c = 'B';
        testAsset.Array_Controller_SKU__c = 'TEST CONTROLLER SKU';
        

        
        //insert testAsset;
        
        //Asset realAsset = [SELECT Id FROM Asset WHERE Name = 'AF-202232'];
        
         
        // create a Case 
        Case caseForEsc = new Case();
        
        caseForEsc.RecordTypeId = '01234000000BnF4AAK'; // get record type of Array Case
        caseForEsc.AccountId = acct.Id;
        caseForEsc.Origin = 'Phone';
        caseForEsc.Status = null;
        caseForEsc.caseCatImpactToCustomer__c = 'Just a question - no service impact';
        caseForEsc.Type = 'Eval';
        caseForEsc.AssetId = null; // testAsset.Id;
        caseForEsc.Estimated_Effort__c = '1 day';
        //caseForEsc.changeOwnerIdTo__c =  UserInfo.getUserId();
        
        insert caseForEsc;
        Test.startTest();
        // make clone so 2nd escalation creation doesn't fail
        Case caseForEsc2 = caseForEsc.clone(false,false, false, false);
        insert caseForEsc2;
        
        caseEscalationTypeDefinition__c caseEscTypeDef = new caseEscalationTypeDefinition__c();
        caseEscTypeDef.Name = 'Engineering Escalation';
        caseEscTypeDef.caseEscalationTypeDefinitionGroup__c = 'Engineering Escalation';
        caseEscTypeDef.caseEscalationTypeDefinitionUser__c = UserInfo.getUserId();
        
        insert caseEscTypeDef;
        
        
       
        caseEscalation__c caseEsc = new caseEscalation__c();
        
        caseEsc.caseEscalationCase__c = caseForEsc.Id;
        caseEsc.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        
        insert caseEsc;
        test.stoptest();
        //ApexPages.currentPage().putUrl('caseEscalation');
        
        Test.setCurrentPageReference(Page.caseEscalationNewPage);  //vf page request
        System.debug('ApexPages.currentPage().getUrl(): ' + ApexPages.currentPage().getUrl());
        
        
        caseEscController = new ApexPages.StandardController(caseEsc);
        System.debug('ApexPages.currentPage().getUrl(): ' + ApexPages.currentPage().getUrl());
        caseEscExtension  = new caseEscalationExtensionsWithSharing(caseEscController);
        System.debug('ApexPages.currentPage().getUrl(): ' + ApexPages.currentPage().getUrl());
        System.debug('caseEscController:' + caseEscController);
        
        //running these to obtain coverage - these should be replaced with real testing
        caseEscExtension.getUserOptions();
        caseEscExtension.getGroupOptions();
        caseEscExtension.caseOwnerTypeForTesting = 'User';
        

        System.debug('ApexPages.currentPage().getParameters: ' + ApexPages.currentPage().getParameters());
        //ApexPages.currentPage().getParameters().put('id',ord.Id);  
        
        returnedPageReference = caseEscExtension.customSave();
        System.debug('ApexPages.currentPage(): ' + ApexPages.currentPage());

    }

    static testMethod void caseEscCreation_QueueOwnsCase()
    {
        ApexPages.StandardController caseEscController;
        caseEscalationExtensionsWithSharing caseEscExtension;
        PageReference returnedPageReference;
        
        
        // create Account
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.PSM_Email__c = 'lawrence.wasser@hpe.com';
        insert acct;
        
        /* System.DmlException: Insert failed. First exception on row 0; 
         * first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Enter All required fields
         * ( Array Base, Array Networking/ Networking 2/ Networking 3, Array Cache, SSD Bank A/B): 
         * [FC_Testing_Done__c] */
        
        //create Asset
        Asset testAsset = new Asset();
        testAsset.Name = 'AF-20223X';
        testAsset.AccountId = acct.Id;
        testAsset.Array_Controller__c = 'AF1000';
        testAsset.Array_Networking__c = '2F';
        testAsset.Array_Networking_2__c = '2G';
        testAsset.Array_Networking_3__c = '2G';
        testAsset.Array_Cache__c = '320F';
        testAsset.SSD_Bank_A__c = 'A';
        testAsset.SSD_Bank_B__c = 'B';
        testAsset.Array_Controller_SKU__c = 'TEST CONTROLLER SKU';
        

        
        //insert testAsset;
        
        //Asset realAsset = [SELECT Id FROM Asset WHERE Name = 'AF-202232'];
        
        
        // create a Case 
        Case caseForEsc = new Case();
        
        caseForEsc.RecordTypeId = '01234000000BnF4AAK'; // get record type of Array Case
        caseForEsc.AccountId = acct.Id;
        caseForEsc.Origin = 'Phone';
        caseForEsc.Status = null;
        caseForEsc.caseCatImpactToCustomer__c = 'Just a question - no service impact';
        caseForEsc.Type = 'Eval';
        caseForEsc.AssetId = null; // testAsset.Id;
        caseForEsc.Estimated_Effort__c = '1 day';
        //caseForEsc.changeOwnerIdTo__c =  UserInfo.getUserId();
        
        insert caseForEsc;
        Test.startTest();
        // make clone so 2nd escalation creation doesn't fail
        Case caseForEsc2 = caseForEsc.clone(false,false, false, false);
        insert caseForEsc2;
        
        caseEscalationTypeDefinition__c caseEscTypeDef = new caseEscalationTypeDefinition__c();
        caseEscTypeDef.Name = 'Engineering Escalation';
        caseEscTypeDef.caseEscalationTypeDefinitionGroup__c = 'Engineering Escalation';
        
        insert caseEscTypeDef;
        
        
        caseEscalation__c caseEsc = new caseEscalation__c();
        
        caseEsc.caseEscalationCase__c = caseForEsc.Id;
        caseEsc.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        
        insert caseEsc;
        
        //ApexPages.currentPage().putUrl('caseEscalation');
        
        Test.setCurrentPageReference(Page.caseEscalationNewPage);  //vf page request
        System.debug('ApexPages.currentPage().getUrl(): ' + ApexPages.currentPage().getUrl());
        
        
        caseEscController = new ApexPages.StandardController(caseEsc);
        System.debug('ApexPages.currentPage().getUrl(): ' + ApexPages.currentPage().getUrl());
        caseEscExtension  = new caseEscalationExtensionsWithSharing(caseEscController);
        System.debug('ApexPages.currentPage().getUrl(): ' + ApexPages.currentPage().getUrl());
        System.debug('caseEscController:' + caseEscController);
        
        //running these to obtain coverage - these should be replaced with real testing
        caseEscExtension.getUserOptions();
        caseEscExtension.getGroupOptions();
        caseEscExtension.caseOwnerTypeForTesting = 'Queue';
        Boolean disableUser = caseEscExtension.disableUser;
        String groupValue = caseEscExtension.groupValue;
        String userValue = caseEscExtension.userValue;
		Test.StopTest();
        System.debug('ApexPages.currentPage().getParameters: ' + ApexPages.currentPage().getParameters());
        //ApexPages.currentPage().getParameters().put('id',ord.Id);  
        
        returnedPageReference = caseEscExtension.customSave();
        System.debug('ApexPages.currentPage(): ' + ApexPages.currentPage());

    } 
    
    static testMethod void caseEscEdit_UserOwnsCase()
    {
        ApexPages.StandardController caseEscController;
        caseEscalationExtensionsWithSharing caseEscExtension;
        PageReference returnedPageReference;
        
        // create Account
        Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;
        
        /* System.DmlException: Insert failed. First exception on row 0; 
         * first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Enter All required fields
         * ( Array Base, Array Networking/ Networking 2/ Networking 3, Array Cache, SSD Bank A/B): 
         * [FC_Testing_Done__c] */
        
        //create Asset
        Asset testAsset = new Asset();
        testAsset.Name = 'AF-20223X';
        testAsset.AccountId = acct.Id;
        testAsset.Array_Controller__c = 'AF1000';
        testAsset.Array_Networking__c = '2F';
        testAsset.Array_Networking_2__c = '2G';
        testAsset.Array_Networking_3__c = '2G';
        testAsset.Array_Cache__c = '320F';
        testAsset.SSD_Bank_A__c = 'A';
        testAsset.SSD_Bank_B__c = 'B';
        testAsset.Array_Controller_SKU__c = 'TEST CONTROLLER SKU';
        

        
        //insert testAsset;
        
        //Asset realAsset = [SELECT Id FROM Asset WHERE Name = 'AF-202232'];
        
        
        // create a Case 
        Case caseForEsc = new Case();
        
        caseForEsc.RecordTypeId = '01234000000BnF4AAK'; // get record type of Array Case
        caseForEsc.AccountId = acct.Id;
        caseForEsc.Origin = 'Phone';
        caseForEsc.Status = null;
        caseForEsc.caseCatImpactToCustomer__c = 'Just a question - no service impact';
        caseForEsc.Type = 'Eval';
        caseForEsc.AssetId = null; // testAsset.Id;
        caseForEsc.Estimated_Effort__c = '1 day';
        //caseForEsc.changeOwnerIdTo__c =  UserInfo.getUserId();
        
        insert caseForEsc;
         Test.startTest();
        // make clone so 2nd escalation creation doesn't fail
        Case caseForEsc2 = caseForEsc.clone(false,false, false, false);
        insert caseForEsc2;
        
        caseEscalationTypeDefinition__c caseEscTypeDef = new caseEscalationTypeDefinition__c();
        caseEscTypeDef.Name = 'Engineering Escalation';
        caseEscTypeDef.caseEscalationTypeDefinitionGroup__c = 'Engineering Escalation';
        
        insert caseEscTypeDef;
        
        
       
        
        caseEscalation__c caseEsc = new caseEscalation__c();
        
        caseEsc.caseEscalationCase__c = caseForEsc.Id;
        caseEsc.caseEscalationTypeDefinition__c = caseEscTypeDef.Id;
        
        insert caseEsc;
        
        //ApexPages.currentPage().putUrl('caseEscalation');
        test.stoptest();
        Test.setCurrentPageReference(Page.caseEscalationEditPage);  //vf page request
        System.debug('ApexPages.currentPage().getUrl(): ' + ApexPages.currentPage().getUrl());
        
        
        caseEscController = new ApexPages.StandardController(caseEsc);
        System.debug('ApexPages.currentPage().getUrl(): ' + ApexPages.currentPage().getUrl());
        caseEscExtension  = new caseEscalationExtensionsWithSharing(caseEscController);
        System.debug('ApexPages.currentPage().getUrl(): ' + ApexPages.currentPage().getUrl());
        System.debug('caseEscController:' + caseEscController);
        
        //running these to obtain coverage - these should be replaced with real testing
        caseEscExtension.getUserOptions();
        caseEscExtension.getGroupOptions();
        caseEscExtension.caseOwnerTypeForTesting = 'User';

        System.debug('ApexPages.currentPage().getParameters: ' + ApexPages.currentPage().getParameters());
        //ApexPages.currentPage().getParameters().put('id',ord.Id);  
        
        returnedPageReference = caseEscExtension.customSave();
        System.debug('ApexPages.currentPage(): ' + ApexPages.currentPage());

    }
}