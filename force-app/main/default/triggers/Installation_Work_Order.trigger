trigger Installation_Work_Order on WorkOrder__c (after insert, after update, before insert, 
before update) {
    if( Utility.runWorkOrderTrigger==true){
        new Installation_Work_Order_Trigger_Class().run();
   }
}