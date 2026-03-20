/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        March 16, 2016
Purpose             :        Helper class for FindingsTrigger
                             Roll up the findings field (datatype:string) from findings object (child) to OpsRMA (parent object)

**************************************************************************************************************************************/

@isTest
private class FindingsTriggerTest {
    static testMethod void method1() {
        string key = 'test';
        List<Account> accList = NMBL_testUtil.createResellerAccount(key,1,true);
        List<SR_Meta_Data__c> srMetaDataList = NMBL_testUtil.createSRMetaData(key,1,true);
        List<AddressBook__c> addressBookList = NMBL_testUtil.createaddressBook(key,1,accList.get(0),true);
        List<Case> caseList = NMBL_testUtil.createCase(key,1,true);
        List<RMAv2__c> RMAv2List = NMBL_testUtil.createRMAv2(key,1,caseList.get(0), addressBookList.get(0), srMetaDataList.get(0), true);
        List<Ops_RMA__c> opsRMAList = NMBL_testUtil.createOpsRMA(key, 1, RMAv2List.get(0), true);
        List<Findings__c> findingsList = NMBL_testUtil.createFindings(key, 2, opsRMAList.get(0), true);
        System.assertNotEquals(opsRMAList.get(0).Operations_RMA_Findings__c, null);
    }
}