@isTest
public class createTaskonSurvey_Test {
    static testMethod void createTask(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
         
        contact con = new contact(LastName = 'Test Exafort',
                                  AccountId = acc.Id,
                                  Email='test@gmail.com',
                                  Phone='999999999');
        insert con;
        
        Product2 testProduct = new Product2(Name = 'CS220 Storage Array',
                                            ProductCode='CS220', 
                                            Product_Type__c='Hardware',
                                            Product_Type_2__c='SAN Storage Array',
                                            Controller_Code__c='CS200',
                                            Description='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                            Family='SAN Storage Array');
        insert testProduct;
        
        asset asst = new asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = testProduct.id,HPE_Serial_Number__c = 'HPE123457',
                               Array_Controller__c = 'CS300',Array_Networking__c = '2P',Array_Networking_2__c = '2P',
                               Array_Networking_3__c = '2P',Array_Cache__c = '640F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                               Asset_Type_Build__c ='Testasupassettype');
        insert asst;
        
        CntrbnMdl_TSE__c conTSE = new CntrbnMdl_TSE__c(Organization__c = 'TSE', Team__c = 'HQ');
        insert conTSE;
        
        case cas = new case(AccountId = acc.Id,
                            AssetId   = asst.Id,
                            ContactId = con.Id,
                            Subject = 'TESTING PLEASE IGNORE Do not delete this case1',
                            caseContributionModelTSE__c = conTSE.Id);
        insert cas;
        Test.startTest();
        Survey__c survey = new Survey__c(surveyAccount__c = acc.id,
                                         surveyCase__c = cas.id,
                                         surveyContact__c = con.id);
        insert survey;
        Survey__c survey1 = new Survey__c(surveyAccount__c = acc.id,
                                         surveyCase__c = cas.id,
                                         surveyContact__c = con.id,
                                         surveyOverallSatisfactionText__c = 'Strongly Agree');
        insert survey1;
        Survey__c survey2 = new Survey__c(
                                         surveyCase__c = cas.id,
                                         surveyContact__c = con.id,
                                         surveyTimeTakenToResolveCaseText__c = 'Strongly Agree',
                                         surveyTseCommunicationsText__c  = 'Strongly Agree',
                                         surveyTseHelpText__c = 'Strongly Agree',
                                         surveyTseKnowledgeText__c = 'Strongly Agree',
                                         surveyTseUnderstoodMyIssueText__c = 'Strongly Agree');
        insert survey2;
        test.stopTest();
    }
}