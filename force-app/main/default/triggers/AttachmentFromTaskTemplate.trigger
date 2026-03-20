trigger AttachmentFromTaskTemplate on Attachment (after insert,before delete) {
	if(Trigger.isInsert)
	{
		AttachmentFromTaskTemplateHandler.insertTaskAttachment(Trigger.new);
	}
	else if(Trigger.isDelete)
	{
       System.debug('Trigger Delete!!!'); 
		AttachmentFromTaskTemplateHandler.deleteTaskAttachment(Trigger.old);
	}
}