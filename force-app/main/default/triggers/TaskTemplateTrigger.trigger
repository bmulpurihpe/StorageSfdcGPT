trigger TaskTemplateTrigger on TaskTemplate__c (after insert,after update,before delete) {
    if(Trigger.isInsert)
    {
        TaskTemplateTriggerHandler.insertTaskTemplate(Trigger.new);
    }
    else if(Trigger.isUpdate)
    {
        TaskTemplateTriggerHandler.updateTaskTemplate(Trigger.newMap,Trigger.oldMap);
    }
    else if(Trigger.isDelete)
    {
        TaskTemplateTriggerHandler.deleteTaskTemplate(Trigger.oldMap);
    }
}