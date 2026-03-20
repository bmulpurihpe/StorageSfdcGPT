@isTest
private class TestDynamicCaseValues {
    static testMethod void testPage() {
        Product2 testProduct1;
        PageReference pageRef = Page.NumCasesAsset;
        Test.setCurrentPageReference(pageRef);
        insert new Contact(Email = 'supportforce@nimblestorage.com', LastName = 'Support');  
        insert new Account(Name = 'testAccount');
        insert testProduct1 = new Product2(Name = 'CS220 Storage Array',
                                               ProductCode='CS220',
                                               Product_Type__c='Hardware',
                                               Product_Type_2__c='SAN Storage Array',
                                               Controller_Code__c='CS200',
                                               Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                               Family='SAN Storage Array');
        insert new Asset(Name = 'AA-TEST1', 
                         Array_Controller__c 						= 'CS300',
                         Array_Networking__c 						= '2P',Array_Networking_2__c = '2P',
                         Array_Networking_3__c 					= '2P',
                         Array_Cache__c 							= '640F',
                         SSD_Bank_A__c 							= '480F',
                         SSD_Bank_B__c 							= '480F',
                         Expansion_Shelf_Base__c 					= 'AFS2',
                         Array_Capacity__c 						= '11T',
                         Product2Id								= testProduct1.Id,
                         AccountId = [select Id from Account limit 1].Id);
        Test.startTest();
        Case myCase = new Case(ContactId = [select Id from Contact limit 1].Id, AssetId = [select Id from Asset limit 1].Id, Status = 'Open');
        insert myCase;
        
        ApexPages.StandardController sc = new ApexPages.standardController(myCase);       
        ApexPages.currentPage().getParameters().put('id', myCase.Id);
        DynamicCaseValues myPageCase = new DynamicCaseValues(sc);
        integer numAsset = myPageCase.getNumCasesAsset();
        integer numContact = myPageCase.getNumCasesContact();
        List<Case> selectMultipeList = myPageCase.listOpenCasesWithAsset;
        Test.StopTest();
    }
    
}