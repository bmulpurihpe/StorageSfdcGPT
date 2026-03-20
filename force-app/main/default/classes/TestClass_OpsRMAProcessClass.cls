@isTest(SeeAllData=true)
public class TestClass_OpsRMAProcessClass {
    
    public static User Usr = TestSupportDataRecord_Util.getRunningUser();
    public static testMethod void OpsRMAProcess() {
        System.runAs(Usr){
            List<Account> acList                      =   TestSupportDataRecord_Util.createAccountRecords(3,Usr);
            List<Asset> assetList                     =   TestSupportDataRecord_Util.createAssetRecords(acList,Usr,3);
            Test.startTest();
            List<Case> caseList                       =   TestSupportDataRecord_Util.createCaseRecords(assetList,Usr,2,acList[0].id);
            List<caseEscalationTypeDefinition__c> ceTypeList =   TestSupportDataRecord_Util.createCaseEscalationTypeRecords(Usr,2);
            Test.stopTest();
            List<caseEscalation__c> csEscalationList  =   TestSupportDataRecord_Util.createCaseEscalationRecords(caseList,ceTypeList,Usr,2);
            
        }
    }
    public static testMethod void OpsRMAProcessRecords() {
        System.runAs(Usr){
            List<Account> acList                      =   TestSupportDataRecord_Util.createAccountRecords(3,Usr);
            
            //List<Asset> assetList                     =   TestSupportDataRecord_Util.createAssetRecords(acList,Usr,3);
            //List<Case> caseList                       =   TestSupportDataRecord_Util.createCaseRecords(assetList,Usr,2,acList[0].id);
            
            List<Case> caseList  = [select id from case where Subject = 'TESTING PLEASE IGNORE Do not delete this case1'];
            Test.startTest();
            List<Bug__c> BugList                      =   TestSupportDataRecord_Util.createBugRecords(caseList,Usr,1);
            List<AddressBook__c>  abList              =   TestSupportDataRecord_Util.createAddressBookRecords(acList,Usr,1);
            
            List<RMAv2__c> RMAList                    =   TestSupportDataRecord_Util.createRMARecords(caseList,Usr,1);
            Test.stopTest();
            List<RMAv2__c> UpdateRMAList              =   TestSupportDataRecord_Util.updateRMARecords(RMAList,Usr,1);
            
            List<Ops_RMA__c> UpdateOpsRMAList              =   TestSupportDataRecord_Util.updateOpsRMARecords(UpdateRMAList,Usr,1);
            
        }  
    }     
    
}