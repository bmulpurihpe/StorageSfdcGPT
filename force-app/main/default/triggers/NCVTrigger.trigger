/****************************************************************************************************************************
Created By      : Sudhir N
Created Date    : 1/7/2017
Purpose         : Trigger on NCV object

****************************************************************************************************************************/


trigger NCVTrigger on Nimble_Cloud_Volume__c (After Insert, After Update) {
     if(checkRecursive.runOnce()) { 
        if(updation.isfutureupdate!=true){
            new NCVTriggerHandler(trigger.new).run();
        }
     }
}