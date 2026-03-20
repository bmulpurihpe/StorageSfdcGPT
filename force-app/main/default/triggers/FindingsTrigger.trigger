/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        March 16, 2016
Purpose             :        Trigger for Findings object
                             The purpose of this trigger is to rollup the findings field (String datatype) from Findings object to the 
                             parent object, opsRMA.

**************************************************************************************************************************************/

trigger FindingsTrigger on Findings__c (after insert, after update) {
    FindingsTriggerHelper fHelper = new FindingsTriggerHelper();
    fHelper.rollupFindingsToOpsRMA(trigger.new);
}