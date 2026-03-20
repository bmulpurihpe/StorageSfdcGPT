/*                              <<<< === Test Class for NEC_DefinitionSortOrder_Update apex trigger === >>>>
================================================================================================================================
 Name                    : NEC_DefinitionSortOrder_Update_Test
 Description             : To verify the minimum test coverage for the logic in the NEC_DefinitionSortOrder_Update trigger.
 Created Date            : 15th December 2021
 Author                  : Guru Dev(Exafort)
 Version                 : 1.0
 Modification History    : Initial Version
================================================================================================================================
*/

@isTest
Public class NEC_DefinitionSortOrder_Update_Test {
    static testmethod void NEC_DefinitionSortOrder_Update_01(){
        
        NEC_Definition__c NECDef;
        insert NECDef = new NEC_Definition__c(Name = 'ForText',necSortOrder__c = 10,necFieldType__c= 'Text',necGroup__c ='Dark Site',
                                          necDescription__c='SDesc', necLabel__c='SDesc');
        NECDef.necDescription__c = 'Testing';
        Update NECDef;

    }
}