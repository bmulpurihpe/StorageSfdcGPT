/*                              <<<< === Test Class for for Sobject Records Mass Delete === >>>>
    =============================================================================================================
        Name                    : MassDelete_Test
        Description             : To verify the minimum test coverage for the logic in the MassDeleteBatch and MassDeleteVFController class.
        Created Date            : 3rd April 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
@isTest
public class MassDelete_Test {
    
    Static testmethod void Test_MassDeleteBatch(){
        string objectString = 'Shipment_Flexflow__c';    
        MassDeleteBatch RunMassDeleteBatch = new MassDeleteBatch(objectString);
        Database.executeBatch(RunMassDeleteBatch,1);
    }
     Static testmethod void Test_MassDeleteVFController_getoptions(){
         String optionSelected = 'Shipment_Flexflow__c';
         MassDeleteVFController massDelete = new MassDeleteVFController();
         list<SelectOption> options = massDelete.getoptions();
         System.assertEquals(options.get(0).getValue(),'Shipment_Flexflow__c');
    }
    Static testmethod void Test_MassDeleteVFControlle_callBatch(){
        MassDeleteVFController massDelete = new MassDeleteVFController();
        massDelete.optionSelected = 'Shipment_Flexflow__c';
        massDelete.callBatch();
    }
}