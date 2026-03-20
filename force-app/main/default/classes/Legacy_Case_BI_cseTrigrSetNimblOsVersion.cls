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
    public with sharing class Legacy_Case_BI_cseTrigrSetNimblOsVersion implements TriggerAction.BeforeInsert{
        public void beforeInsert(List<Case> newList) {
        if(CaseUtility.CASETRIGGER_FLAG )
        {
          new caseSetNimbleOsVersionHandler().run();
          }
        }
    }