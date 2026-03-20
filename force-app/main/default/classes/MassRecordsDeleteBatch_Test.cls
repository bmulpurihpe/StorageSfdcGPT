/*                              <<<< === Test Class for MassRecordsDeleteBatch Apex batch class === >>>>
    =============================================================================================================
        Name                    : MassRecordsDeleteBatch_Test
        Description             : To verify the minimum test coverage for the logic in the MassRecordsDeleteBatch class.
        Created Date            : 3rd April 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
@isTest
public class MassRecordsDeleteBatch_Test {
    Static testmethod void Test_MassRecordDeleteBatch(){
        Test.startTest();
        Account a = new Account(Name='Test Account');
        insert a;
        MassRecordsDeleteBatch RunMassDeleteBatch = new MassRecordsDeleteBatch();
        RunMassDeleteBatch.query= 'SELECT Id FROM Account where name=\'Test Account\' LIMIT 1';
        Database.executeBatch(RunMassDeleteBatch,1);
        Test.stopTest();
    }
}