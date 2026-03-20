public with sharing class TaskTemplateUtils {

    public static Date getDueDate(String decimalTab,User user)
    {
        Date dateTab;
        if( user.Employment_Start_Date__c != null && user.Employment_Start_Date__c > System.today())
        {
            dateTab = convertTabToDate(decimalTab,user,user.Employment_Start_Date__c);
        }
        else
        { 
            dateTab = convertTabToDate(decimalTab,user,System.today());
        }
        return dateTab;
    }

    public static Date convertTabToDate(String decimalTab,User user,Date convertDate)
    {
        Date dateTab;
        if(decimalTab == 'Week1')
        {
            dateTab = convertDate.addDays(7);
        }
        else if (decimalTab == '< 30 Days')
        {
            dateTab = convertDate.addDays(30);
        }
        else if (decimalTab == '< 60 Days')
        {
            dateTab = convertDate.addDays(60);
        }
        else if(decimalTab == '< 90 Days')
        {
            dateTab = convertDate.addDays(90);
        }
        else if(decimalTab == 'Elevate')
        {
            Date newElevate;
            if(user.Employment_Start_Date__c != null)
            {
                newElevate = user.Employment_Start_Date__c;
            }
            else
            {
                newElevate = Date.newInstance(user.CreatedDate.Year(), user.CreatedDate.month(), user.CreatedDate.day());
            }

            if(newElevate.daysBetween(Date.today()) >= 90) 
            {
                dateTab = convertDate.addDays(30);
            }
            else
            {
                dateTab = convertDate.addDays(120);
            }           
        }
        else
        {
            dateTab = convertDate;
        }
        return dateTab;
    }
    
    public static Map<String,Attachment> getExistingAttachmentMaps(List<TaskTemplate__c> taskTemplates)
    {
        Map<String,Attachment> existingMaps = new Map<String,Attachment>();
        Set<String> ttKeys = new Set<String>();
        for(TaskTemplate__c tt : taskTemplates)
        {
            ttKeys.add(tt.Id);
        }
        for(Attachment attachment : [select Id, Name, ParentId from Attachment where ParentId in :ttKeys])
        {
            existingMaps.put(attachment.ParentId, attachment);
        }
        return existingMaps;
    }

    public static Map<String,Set<String>> getExistingCompletedTaskMaps(List<TaskTemplate__c> taskTemplates)
    {
        Map<String,Set<String>> existingMaps = new Map<String,Set<String>>();
        Set<String> ttKeys = new Set<String>();
        for(TaskTemplate__c tt : taskTemplates)
        {
            ttKeys.add(tt.Id);
        }
        for(TrainingTask__c task : [select Id, OwnerId , TaskTemplate__c from TrainingTask__c where TaskTemplate__c in :ttKeys and IsClosed__c = true])
        {
            if(existingMaps.containsKey(task.OwnerId))
            {
                existingMaps.get(task.OwnerId).add(task.TaskTemplate__c);
            }
            else
            {
                existingMaps.put(task.OwnerId,new Set<String>{task.TaskTemplate__c});
            }
        }
        return existingMaps;
    }
    /*
    public static Map<String,Map<String,TrainingTask__c>> getExistingTaskMaps(List<TrainingTask__c> tasks)
    {
        Map<String,Map<String,TrainingTask__c>> existingMaps = new Map<String,Map<String,TrainingTask__c>>();
        if(tasks.isEmpty())
        {
            return null;
        }
        else
        {
            for(TrainingTask__c task : tasks)
            {
                if(existingMaps.containsKey(task.OwnerId))
                {
                    existingMaps.get(task.OwnerId).put(task.TaskTemplate__c,task);
                }
                else
                {
                    Map<String,TrainingTask__c> taskMap = new Map<String,TrainingTask__c>();
                    taskMap.put(task.TaskTemplate__c,task);
                    existingMaps.put(task.OwnerId,taskMap);
                }
            }
        }        
        return existingMaps;
    }*/
}