trigger OpportunityTrigger on Opportunity (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    if(Utility.runDupRecTrigger==true)
    {
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
        if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);
        }  
    }
    //Perform Operations on Insert/Update/Undelete Events   
    if((Trigger.isInsert || Trigger.isUndelete || Trigger.isUpdate) && Trigger.isAfter) {
          OpportunityTriggerHelper.rollUpChannelsCallBlitz(trigger.new,trigger.oldMap);
    }
  
   //Perform Operations on Delete Event,first parameter is Trigger.old 
   // because trigger.new is null for Delete Event
    if(Trigger.isAfter && Trigger.isDelete) {
         OpportunityTriggerHelper.rollUpChannelsCallBlitz(trigger.old,trigger.oldMap);
    }

      
}