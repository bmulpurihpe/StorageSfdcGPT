@isTest(SeeAllData=true)
public class SurveyTrackingTest {
    public static testMethod void caseClosePagetestTATSAValues(){
        
        
        Map<Id, list<string>> surveyCollection = new Map<Id, list<string>>();//TS-7450
        List<string> surveykeyCollection = new List<string>();
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        List<EmailTemplate> surveyEmailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Survey: Support Closed Case 01'];
        insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        
        // Create test contact
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        // Create test asset
       /* insert asset = new Asset(Name = 'TEST-ASSET',
                                 AccountId = account.Id,
                                 ContactId = contact.Id,
                                 SLA__c = 'Premium',
                                 assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku');*/
                 
        // Create test case
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = [select Id from Asset limit 1].id,
                                ContactId = contact.Id,
                                Subject = 'TEST-CASE-SUBJECT',
                                Product_Damage_Symptoms__c = 'Test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId(),
                                Case_closure_time_spent__c = 1);
        
        surveykeyCollection.add(surveyEmailTemplate[0].Id);
        surveykeyCollection.add(aCase.accountId);
        surveykeyCollection.add(aCase.contactId);
        surveykeyCollection.add(aCase.AssetId);                    
        surveyCollection.put(aCase.Id,surveykeyCollection);
        SurveyTracking.createSurveyTrackingRecord('Case',surveyCollection);                        
        
    }   
    
}