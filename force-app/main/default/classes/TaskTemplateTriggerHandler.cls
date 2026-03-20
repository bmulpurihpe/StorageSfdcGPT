public with sharing class TaskTemplateTriggerHandler 
{
    public static void insertTaskTemplate(List<TaskTemplate__c> taskTemplates)
    {
        Set<String> divisions = new Set<String>();
        Boolean forAllDivision = false;
        for(TaskTemplate__c template : taskTemplates)
        {
            if(template.ForAllDivisions__c)
            {
                forAllDivision = true;
                break;
            }
            else
            {
                divisions.add(template.Division__c);
            }
        }
        List<User> users = new List<User>();
        if(forAllDivision)
        {
            users = [select Id, CreatedDate, TrainingDivision__c, TrainingEnabled__c, Employment_Start_Date__c from User where TrainingEnabled__c = true and IsActive = true];
        }
        else
        {
            users = [select Id, CreatedDate, TrainingDivision__c, TrainingEnabled__c, Employment_Start_Date__c from User where TrainingEnabled__c = true and IsActive = true and TrainingDivision__c in :divisions];
        }
        if(users.size() > 0)
        {
            createUserTasks(taskTemplates,users);           
        }   
    }
    
    public static void updateTaskTemplate(Map<Id,TaskTemplate__c> newTaskTemplateMap,Map<Id,TaskTemplate__c> oldTaskTemplateMap)
    {
        List<TrainingTask__c> existingTasks = [select Name, Description__c, DueDate__c, TaskTemplate__c, OwnerId, IsClosed__c,AttachmentName__c, AttachmentUrl__c from TrainingTask__c where TaskTemplate__c in :oldTaskTemplateMap.keySet()];
        List<TrainingTask__c> deleteTasks = new List<TrainingTask__c>();
        List<TrainingTask__c> updateTasks = new List<TrainingTask__c>();
        Map<String,TrainingTask__c> taskMap = new Map<String,TrainingTask__c>();
        
        TaskTemplate__c newTaskTemplate;
        for(TrainingTask__c task : existingTasks)
        {         
            if(task.IsClosed__c)
            {
                newTaskTemplate = newTaskTemplateMap.get(task.TaskTemplate__c);
                if(task.Name != newTaskTemplate.Subject__c || task.Description__c != newTaskTemplate.Description__c)
                {
                    task.Name = newTaskTemplate.Subject__c;
                    task.Description__c = newTaskTemplate.Description__c;
                    updateTasks.add(task);
                }               
            }
            else
            {
                taskMap.put(task.TaskTemplate__c+':'+task.OwnerId,task);
                deleteTasks.add(task);
            }
        }
        //System.debug('DeletetTasks :' + deleteTasks);
        Savepoint sp = Database.setSavepoint();
        try{
            insertTaskTemplate(newTaskTemplateMap.values());
            System.debug([select Name, Description__c, DueDate__c, TaskTemplate__c, OwnerId, IsClosed__c, AttachmentName__c, AttachmentUrl__c from TrainingTask__c where TaskTemplate__c in :newTaskTemplateMap.keySet()]);
            for(TrainingTask__c createTask :[select Name, Description__c, DueDate__c, TaskTemplate__c, OwnerId, IsClosed__c, AttachmentName__c, AttachmentUrl__c from TrainingTask__c where TaskTemplate__c in :newTaskTemplateMap.keySet() and IsClosed__c = false])
            {
                String keyStr = createTask.TaskTemplate__c + ':' + createTask.OwnerId;
                if(taskMap.containsKey(keyStr))
                {
                    TrainingTask__c oldTask = taskMap.get(keyStr);
                    createTask.DueDate__c = oldTask.DueDate__c;
                    updateTasks.add(createTask);
                }
            }
            if(!updateTasks.isEmpty())
            {
                update updateTasks;
            }
            
            if(!deleteTasks.isEmpty())
            {
                delete deleteTasks;
            }          
        }catch(Exception e)
        {
            System.debug('Exception Messages :' + e.getMessage());
            Database.rollback(sp);
        }
    }
    
    
    //after delete Trigger
    public static void deleteTaskTemplate(Map<Id,TaskTemplate__c> oldTaskTemplateMap)
    {
        List<TrainingTask__c> cancelTasks = [select Id from TrainingTask__c where IsClosed__c != true and TaskTemplate__c in :oldTaskTemplateMap.keySet()];
        if(! cancelTasks.isEmpty())
        {
            delete cancelTasks;
        }
    }
    
    //after insert Trigger method
    public static void createUserTasks(List<TaskTemplate__c> taskTemplates,List<User> userTasks)
    {
        List<TrainingTask__c> createTasks = new List<TrainingTask__c>();
        Map<String,Attachment> existingAttachmentMaps = TaskTemplateUtils.getExistingAttachmentMaps(taskTemplates);
        Map<String,Set<String>> existingCompletedTasks = TaskTemplateUtils.getExistingCompletedTaskMaps(taskTemplates);
        for(TaskTemplate__c tt : taskTemplates)
        {   
            if(tt.Effective_Date__c <= System.today())
            {
                if(tt.ForAllDivisions__c)
                {
                    if(tt.ExistingUsersWillReceiveThisTask__c)
                    {
                        for(User user : userTasks)
                        {              
                            if(!(existingCompletedTasks.containsKey(user.Id) && existingCompletedTasks.get(user.Id).contains(tt.Id)))
                            {
                                //createTasks.add(New Task(OwnerId = user.Id,Subject = tt.Subject__c, Description = tt.Description__c, ActivityDate = TaskTemplateUtils.convertTabToDate(tt.Tab__c,user),TaskTemplate__c = tt.Id, AttachmentName__c = existingAttachmentMaps.keySet().contains(tt.Id) ? existingAttachmentMaps.get(tt.Id).Name : '', AttachmentUrl__c = existingAttachmentMaps.keySet().contains(tt.Id) ? '/servlet/servlet.FileDownload?file=' + existingAttachmentMaps.get(tt.Id) : ''));                     
                                createTasks.add(new TrainingTask__c(OwnerId = user.Id,Name = tt.Subject__c, Description__c = tt.Description__c, DueDate__c = TaskTemplateUtils.getDueDate(tt.Tab__c, user), TaskTemplate__c = tt.Id, AttachmentName__c = existingAttachmentMaps.keySet().contains(tt.Id) ? existingAttachmentMaps.get(tt.Id).Name : '', AttachmentUrl__c = existingAttachmentMaps.keySet().contains(tt.Id) ? '/servlet/servlet.FileDownload?file=' + existingAttachmentMaps.get(tt.Id).Id : ''));
                            }
                        }
                    }
                    else{
                        for(User user : userTasks)
                        {
                            if(!(existingCompletedTasks.containsKey(user.Id) && existingCompletedTasks.get(user.Id).contains(tt.Id)))
                            {
                                if(user.Employment_Start_Date__c != null && user.Employment_Start_Date__c >= tt.Effective_Date__c)
                                {
                                    createTasks.add(new TrainingTask__c(OwnerId = user.Id,Name = tt.Subject__c, Description__c = tt.Description__c, DueDate__c = TaskTemplateUtils.getDueDate(tt.Tab__c, user), TaskTemplate__c = tt.Id, AttachmentName__c = existingAttachmentMaps.keySet().contains(tt.Id) ? existingAttachmentMaps.get(tt.Id).Name : '', AttachmentUrl__c = existingAttachmentMaps.keySet().contains(tt.Id) ? '/servlet/servlet.FileDownload?file=' + existingAttachmentMaps.get(tt.Id).Id : ''));
                                }
                                else if(user.Employment_Start_Date__c == null && user.CreatedDate >= tt.Effective_Date__c)
                                {
                                    createTasks.add(new TrainingTask__c(OwnerId = user.Id,Name = tt.Subject__c, Description__c = tt.Description__c, DueDate__c = TaskTemplateUtils.getDueDate(tt.Tab__c, user), TaskTemplate__c = tt.Id, AttachmentName__c = existingAttachmentMaps.keySet().contains(tt.Id) ? existingAttachmentMaps.get(tt.Id).Name : '', AttachmentUrl__c = existingAttachmentMaps.keySet().contains(tt.Id) ? '/servlet/servlet.FileDownload?file=' + existingAttachmentMaps.get(tt.Id).Id : ''));
                                }
                            }
                        }   
                    }   
                }
                else
                {
                    if(tt.ExistingUsersWillReceiveThisTask__c)
                    {
                        for (User user : userTasks)
                        {
                            if(user.TrainingDivision__c == tt.Division__c)
                            {
                                if(!(existingCompletedTasks.containsKey(user.Id) && existingCompletedTasks.get(user.Id).contains(tt.Id)))
                                {   
                                    createTasks.add(new TrainingTask__c(OwnerId = user.Id,Name = tt.Subject__c, Description__c = tt.Description__c, DueDate__c = TaskTemplateUtils.getDueDate(tt.Tab__c, user), TaskTemplate__c = tt.Id, AttachmentName__c = existingAttachmentMaps.keySet().contains(tt.Id) ? existingAttachmentMaps.get(tt.Id).Name : '', AttachmentUrl__c = existingAttachmentMaps.keySet().contains(tt.Id) ? '/servlet/servlet.FileDownload?file=' + existingAttachmentMaps.get(tt.Id).Id : ''));
                                }
                            }
                        }
                    }
                    else
                    {
                        for(User user : userTasks)
                        {
                            if(user.TrainingDivision__c == tt.Division__c)
                            {   
                                if(!(existingCompletedTasks.containsKey(user.Id) && existingCompletedTasks.get(user.Id).contains(tt.Id)))
                                {                   
                                    if(user.Employment_Start_Date__c != null && user.Employment_Start_Date__c >= tt.Effective_Date__c)
                                    {
                                        createTasks.add(new TrainingTask__c(OwnerId = user.Id,Name = tt.Subject__c, Description__c = tt.Description__c, DueDate__c = TaskTemplateUtils.getDueDate(tt.Tab__c, user), TaskTemplate__c = tt.Id, AttachmentName__c = existingAttachmentMaps.keySet().contains(tt.Id) ? existingAttachmentMaps.get(tt.Id).Name : '', AttachmentUrl__c = existingAttachmentMaps.keySet().contains(tt.Id) ? '/servlet/servlet.FileDownload?file=' + existingAttachmentMaps.get(tt.Id).Id : ''));
                                    }
                                    else if(user.Employment_Start_Date__c == null && user.CreatedDate >= tt.Effective_Date__c)
                                    {
                                        createTasks.add(new TrainingTask__c(OwnerId = user.Id,Name = tt.Subject__c, Description__c = tt.Description__c, DueDate__c = TaskTemplateUtils.getDueDate(tt.Tab__c, user), TaskTemplate__c = tt.Id, AttachmentName__c = existingAttachmentMaps.keySet().contains(tt.Id) ? existingAttachmentMaps.get(tt.Id).Name : '', AttachmentUrl__c = existingAttachmentMaps.keySet().contains(tt.Id) ? '/servlet/servlet.FileDownload?file=' + existingAttachmentMaps.get(tt.Id).Id : ''));
                                    }
                                }
                            }
                        }   
                    }
                }
            }
        }
        if(createTasks.size() > 0)
        {
            insert createTasks;
        }
    }
}