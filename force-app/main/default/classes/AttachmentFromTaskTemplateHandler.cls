public with sharing class AttachmentFromTaskTemplateHandler {

    public static void insertTaskAttachment(List<Attachment> newAtts)
    {   
        List<Attachment> existingAttachments = new List<Attachment>();
        List<TrainingTask__c> existingTasks = new List<TrainingTask__c>();
        Set<String> taskTemplateIds = existingCommonTaskTemplate(newAtts);
        if(!taskTemplateIds.isEmpty())
        {
            existingAttachments = [select Id, Name, ParentId from Attachment where ParentId in :taskTemplateIds];
            if(!existingAttachments.isEmpty())
            {
                existingTasks = [select Id, TaskTemplate__c, AttachmentUrl__c, AttachmentName__c from TrainingTask__c where IsClosed__c != true and TaskTemplate__c in :taskTemplateIds];
                if(!existingTasks.isEmpty())
                {                    
                    for(Attachment att : existingAttachments)
                    {                      
                        for(TrainingTask__c task : existingTasks)
                        {
                            if(task.TaskTemplate__c == att.ParentId)
                            {
                                task.AttachmentUrl__c = '/servlet/servlet.FileDownload?file=' + att.Id;
                                task.AttachmentName__c = att.Name;
                            }
                        }
                    }
                    try
                    {
                        update existingTasks;
                    }
                    catch(DmlException ex)
                    {
                        System.debug(ex);
                    }
                }
            }
        }   
        
    }

    public Static void deleteTaskAttachment(List<Attachment> oldAtts)
    {
        List<Attachment> existingAttachments = new List<Attachment>();
        List<TrainingTask__c> existingTasks = new List<TrainingTask__c>();
        Set<String> taskTemplateIds = existingCommonTaskTemplate(oldAtts);
        if(!taskTemplateIds.isEmpty())
        {
            existingAttachments = [select Id, ParentId from Attachment where ParentId in :taskTemplateIds];
            if(!existingAttachments.isEmpty())
            {
                existingTasks = [select Id, TaskTemplate__c, AttachmentName__c, AttachmentUrl__c from TrainingTask__c where TaskTemplate__c in :taskTemplateIds];
                if(!existingTasks.isEmpty())
                {
                    for(Attachment att : existingAttachments)
                    {
                        for(TrainingTask__c task : existingTasks)
                        {
                            if(task.TaskTemplate__c == att.ParentId)
                            {
                                task.AttachmentName__c = '';
                                task.AttachmentUrl__c = '';
                            }
                        }
                    }
                    try
                    {
                        update existingTasks;
                    }
                    catch(DmlException ex)
                    {
                        System.debug(ex);
                    }
                }
            }
        }   
    }
    
    public static Set<String> existingCommonTaskTemplate(List<Attachment> attachments)
    {
        Set<String> keyIds = new Set<String>();
        Set<String> taskTemplateIds = new Set<String>();
        for(Attachment att : attachments)
        {
            keyIds.add(att.ParentId);
        }
        if(!keyIds.isEmpty())
        {
            List<TaskTemplate__c> existingTaskTemplates = [select Id from TaskTemplate__c where Id in :keyIds];
            if(!existingTaskTemplates.isEmpty())
            {
                for(TaskTemplate__c tt : existingTaskTemplates)
                {
                    taskTemplateIds.add(tt.Id);
                }
            }
        }
        return taskTemplateIds;
    }
    /*
    public static List<Attachment> existingAttachments(set<String> taskTemplateIds)
    {
        return [select Id from Attachment where ParentId in :taskTemplateIds];
    }

    public static List<Task> existingTasks (Set<String> taskTemplateIds)
    {
        return [select Id, RelatedAttachment__c from Task where Status != 'Cancelled' and TaskTemplate__c in :taskTemplateIds and RelatedAttachment__c != ''];
    }
    */
    /*
    public Static void insertTaskAttachment(List<Attachment> newAtts)
    {
        Set<String>  keyIds = new Set<String>();
        Set<String> taskTemplateIds = new Set<String>();
        List<Attachment> createAttachments = new List<Attachment>();
        for(Attachment att : newAtts)
        {
            keyIds.add(att.ParentId);
        }
        if(!keyIds.isEmpty())       
        {
            for(TaskTemplate__c tt : [select Id from TaskTemplate__c where Id In :keyIds])
            {
                taskTemplateIds.add(tt.Id);
            }
            if(!taskTemplateIds.isEmpty())
            {
                List<Task> existingTasks = [select Id, OwnerId from Task where Status != 'Cancelled' and TaskTemplate__c in :taskTemplateIds];
                if(!existingTasks.isEmpty())
                {
                    for(Attachment att : [select Id, Name, Description, Body, ContentType, ParentId, IsPrivate from Attachment where ParentId in :taskTemplateIds])
                    {
                        for(Task task : existingTasks)
                        {
                            createAttachments.add(new Attachment(Name = att.Name, Body = att.Body, ContentType = att.ContentType, IsPrivate = att.IsPrivate, Description = att.Description, ParentId = task.Id, OwnerId = task.OwnerId));
                        }
                    }
                }
            }
        }
        if(!createAttachments.isEmpty())
        {
            try
            {
                insert createAttachments;
            }
            catch (DmlException ex)
            {
                System.debug(ex);
            }
        }
    }

    public static void updateTaskAttachment(Map<Id,Attachment> oldAttMaps,Map<Id,Attachment> newAttMaps)
    {
        List<Attachment> updateAttachments = new List<Attachment>();
        Attachment oldAtt;
        Attachment newAtt;

        Set<String> keyIds = new Set<String>();
        Set<String> taskTemplateIds = new Set<String>();
        List<Attachment> existingAttachments = new List<Attachment>();
        List<Task> existingTasks = new List<Task>();
        for(Attachment att : newAttMaps.values())
        {
            keyIds.add(att.ParentId);
        }
        if(!keyIds.isEmpty())
        {
            for(TaskTemplate__c existingTaskTemplate :[select Id from TaskTemplate__c where Id in :keyIds])
            {
                taskTemplateIds.add(existingTaskTemplate.Id);
            }

            if(!taskTemplateIds.isEmpty())
            {
                existingAttachments = [select Id, Name, Description, IsPrivate from Attachment where Id In :taskTemplateIds];               
                if(!existingAttachments.isEmpty())
                {
                    existingTasks = [select Id from Task where Status != 'Cancelled' and TaskTemplate__c in : taskTemplateIds];
                    for(Attachment att : existingAttachments)
                    {
                        oldAtt = oldAttMaps.get(att.Id);
                        newAtt = newAttMaps.get(att.Id);
                        if(oldAtt.Name != newAtt.Name || oldAtt.IsPrivate != newAtt.IsPrivate || oldAtt.Description != newAtt.Description)
                        {

                        }
                    }
                }
            }
        }       
    }

    public static void deleteTaskAttachment(Map<Id,Attachment> oldAttMaps)
    {
        Set<String> taskTemplateIds = new Set<String>();
        Set<String> keyIds = new Set<String>();
        Set<String> taskIds = new Set<String>();
        List<Attachment> deleteAttachments = new List<Attachment>();
        for(Attachment att : oldAttMaps.values())
        {
            keyIds.add(att.ParentId);
        }
        if(!keyIds.isEmpty())
        {
            List<TaskTemplate__c> existingTaskTemplates = [select Id, OwnerId from TaskTemplate__c where Id In :keyIds]; 
            if(!existingTaskTemplates.isEmpty())
            {
                for(TaskTemplate__c tt : existingTaskTemplates)
                {
                    taskTemplateIds.add(tt.Id);
                }
                List<Task> existingTasks = [select Id from Task where Status != 'Cancelled' and TaskTemplate__c In :taskTemplateIds];
                if(!existingTasks.isEmpty())
                {
                    for(Task task : existingTasks)
                    {
                        taskIds.add(task.Id);
                    }
                    if(!taskIds.isEmpty())
                    {
                        deleteAttachments = [select Id from Attachment where ParentId in :taskIds];
                    }
                }
            }
        }
        if(!deleteAttachments.isEmpty())
        {
            try
            {
                delete deleteAttachments;
            }
            catch(DmlException ex)
            {
                System.debug(ex);
            }
        }
    }
    */

}