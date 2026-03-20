/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-20-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger caseTriggerSetNimbleOsVersion on Case (before insert, before update) {
public with sharing class Legacy_Case_BU_cseTrigrSetNimblOsVersion implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        if(CaseUtility.CASETRIGGER_FLAG )
            new caseSetNimbleOsVersionHandler().run();
    }
}