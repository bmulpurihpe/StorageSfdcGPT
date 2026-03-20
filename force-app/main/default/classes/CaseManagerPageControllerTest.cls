/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 12-01-2022
 * @last modified by  : Nagalaxmi Telkar 
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   12-01-2022   Nagalaxmi Telkar   Initial Version
**/

@isTest
public class CaseManagerPageControllerTest {
    @testSetup 
    static void setUp() {
        
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;//SSaaSS
        
        Product2    product; 
        //Create case velocity records
        pachinko_case_type__c ct1 = new pachinko_case_type__c();
        ct1.Monthly_Threshold__c = 3;
        ct1.Pachinko_Case_Type__c = 'Type1';
        ct1.Recommendation_Text__c = 'Type1 rec text';
        ct1.Threshold_Applies_To__c = 'Account';
        ct1.Leave_Case_Open__c = true;
        ct1.Enabled__c = true;
        
        pachinko_case_type__c ct2 = new pachinko_case_type__c();
        ct2.Monthly_Threshold__c = 3;
        ct2.Pachinko_Case_Type__c = 'Type2';
        ct2.Recommendation_Text__c = 'Type2 rec text';
        ct2.Threshold_Applies_To__c = 'Array';
        ct2.Enabled__c = true;
        
        Map<String,pachinko_case_type__c> pMap = new Map<String,pachinko_case_type__c>();
        pMap.put('Type1',ct1);
        pMap.put('Type2',ct2);        
        insert pMap.values();
        
        //create custom setting
        Threshold_limit__c t1 = new Threshold_limit__c();
        t1.Name = 'limit';
        t1.Number_of_Months__c = 1;
        insert t1;
        
        QualifiedHandling__c qha = new QualifiedHandling__c(Name='Test-CaseNewEdit', qhLabel__c = 'Testing',qhDescription__c='This is a simple test on CaseNewEditController' );
        insert qha;
        //create accounts
        test.startTest();
        account = new Account(Name = 'Test Account1', accountQualifiedHandling__c = qha.Id);
        insert account;
        
        insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                     AccountId = account.Id,
                                     Email='test@gmail.com',
                                     Phone='999999999');
        
        //create product
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        
        //create asset
        asset = new Asset(Name = 'Test Asset1', Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                          AccountId = account.Id,Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                          Array_Controller_SKU__c = 'SD-Test',
                          ContactId = contact.Id); 
        
        insert asset;
        
        TechnicalSubArea_Mappings__c tsm = new TechnicalSubArea_Mappings__c(Case_Types__c = 'SSaaS',Technical_SubArea__c='TestArea', Technical_Area__c='TestArea', Peak_Area__c = 'Test Area' );
        insert tsm;
        
        CustomerImpactMapping__c cim = new CustomerImpactMapping__c(Customer_Impact__c= 'Test Impact' ,
                                                                    Esc_Rotation__c='Test rotation',
                                                                    PEAK_Area__c = 'Test Area');
        
        insert cim;
        
        TechnicalSubArea_Mappings__c tsamapping = new TechnicalSubArea_Mappings__c();
        tsamapping.Technical_Area__c ='Array Hardware';
        tsamapping.Technical_SubArea__c = 'Damaged in shipping';
        tsamapping.IsDeleted__c = false;
        tsamapping.Case_Types__c = 'Array Case';
        insert tsamapping;
        
        String recordTypeidSSaaSCase = Schema.SObjectType.Case.getRecordTypeInfosByName ().get ('SSaaS').getRecordTypeId (); 
        Category_Notes__c cat = new Category_Notes__c(Category__c = 'TEST_Category',
                                                      Sub_Category__c = 'Test_Sub_Category');
        
        insert cat;
        test.stopTest();
        insert aCase = new Case(AccountId = account.Id,
                                AssetId   = asset.Id,
                                ContactId = contact.Id,
                                Subject = 'TEST-NewOrEditCase-SUBJECT_A',
                                RecordTypeId = recordTypeidSSaaSCase,
                                Technology_Area__c = 'TestArea',
                                Sub_Technology_Area__c = 'TestArea',
                                Product_Damage_Symptoms__c = 'Carton Damage',
                                Case_closure_time_spent__c = 20,
                                Current_comment_activity__c = null,
                                Description = 'Test Description');
        
    }
    
    public static testMethod void test_controller(){
        
        Case aCase = [SELECT Id,RecordTypeId, RecordType.Name FROM Case WHERE Subject = 'TEST-NewOrEditCase-SUBJECT_A'];
        
        System.assertEquals('SSaaS',aCase.RecordType.Name);
        PageReference pageRef = Page.CaseManagerPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        ApexPages.currentPage().getParameters().put('RecordType', aCase.RecordTypeId);
        CaseManagerPageController newCase = new CaseManagerPageController(sc);
        newCase.getRecordId();
        newCase.getRecordPage();
        newCase.getShowCollaborationLinks();
        
    }
}