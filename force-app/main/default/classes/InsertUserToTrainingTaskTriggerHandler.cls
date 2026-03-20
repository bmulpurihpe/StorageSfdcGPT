public with sharing class InsertUserToTrainingTaskTriggerHandler
{   
    public static Boolean skipInsert = true;
    public static void insertTrainingTask(List<User> insertUsers)
    {   
        if(skipInsert)
        {
            Set<String> createUsers = new Set<String>();
            Set<String> divisions = new Set<String>();
            for(User user : insertUsers)
            {
                if(user.TrainingEnabled__c)
                {
                    if (String.isNotBlank(user.TrainingDivision__c))
                    {
                        createUsers.add(user.id);
                        divisions.add(user.TrainingDivision__c);
                    }   
                }
            }
            if(createUsers.size() > 0){                  
                createTrainingTask(createUsers,divisions);
            }
        }
    }

    public  static void updateTrainingTask(Map<Id,User> oldUserMap,Map<Id,User> newUserMap)
    {
        Set<String> createUsers = new Set<String>();
        Set<String> cancelUsers = new Set<String>();
        Set<String> divisions = new Set<String>();
        User oldUser;

        for(User newUser : newUserMap.values())
        {
            oldUser = oldUserMap.get(newUser.Id);
            // new TrainingEnabled not equals old TrainingEnabled 
            if(newUser.TrainingEnabled__c != oldUser.TrainingEnabled__c)
            {
                //false to true
                if(newUser.TrainingEnabled__c)
                {
                    if(String.isNotBlank(newUser.TrainingDivision__c))
                    {
                        createUsers.add(newUser.Id);
                        divisions.add(newUser.TrainingDivision__c);
                    }                           
                }
                else   
                {
                    cancelUsers.add(newUser.Id);//true to false
                }   
            }
            else
            {
                // old TrainingEnabled = true and new TrainingEnabled = true
                if(newUser.TrainingEnabled__c)
                {
                    if(oldUser.TrainingDivision__c != newUser.TrainingDivision__c)
                    {
                        if(String.isNotBlank(oldUser.TrainingDivision__c))
                        {
                            cancelUsers.add(newUser.Id);    
                        }
                        if(String.isNotBlank(newUser.TrainingDivision__c))
                        {
                            createUsers.add(newUser.Id);
                            divisions.add(newUser.TrainingDivision__c);
                        }
                    }
                   
                }
            }
        }

        if(cancelUsers.size() > 0)
        {
            cancelTrainingTask(cancelUsers);    
        }
        if(createUsers.size() > 0)
        {
            createTrainingTask(createUsers, divisions);    
        }
    }
    
    @future
    static void createTrainingTask(Set<String> userIds,Set<String> divisions)
    {
        List<TrainingTask__c> createTasks = new List<TrainingTask__c>();
        List<TaskTemplate__c> taskTemplates = [select Id, Tab__c, Subject__c, Division__c, Description__c,Effective_Date__c,ForAllDivisions__c from TaskTemplate__c where Division__c in :divisions or ForAllDivisions__c = true];    
        List<User> users = [select Id, TrainingDivision__c,Employment_Start_Date__c, CreatedDate from User where IsActive = true and Id in :userIds ];
        if(!taskTemplates.isEmpty())
        {
            Map<String,Attachment> existingAttachmentMaps = TaskTemplateUtils.getExistingAttachmentMaps(taskTemplates);          
            for(User user : users)
            {
                for(TaskTemplate__c tt : taskTemplates)
                {
                    if(user.TrainingDivision__c == tt.Division__c || tt.ForAllDivisions__c == true)
                    {    
                        Date startDate = user.Employment_Start_Date__c == null ? user.CreatedDate.Date() : user.Employment_Start_Date__c;
                        
                        if(tt.Effective_Date__c <= System.today() && tt.Effective_Date__c <= startDate)
                        {
                            createTasks.add(new TrainingTask__c(OwnerId = user.Id,Name = tt.Subject__c, Description__c = tt.Description__c, DueDate__c = TaskTemplateUtils.getDueDate(tt.Tab__c, user), TaskTemplate__c = tt.Id, AttachmentName__c = existingAttachmentMaps.keySet().contains(tt.Id) ? existingAttachmentMaps.get(tt.Id).Name : '', AttachmentUrl__c = existingAttachmentMaps.keySet().contains(tt.Id) ? '/servlet/servlet.FileDownload?file=' + existingAttachmentMaps.get(tt.Id).Id : ''));       
                        }
                    }
                    
                }       
            }   
               
        }
     
        try{
            if(!createTasks.isEmpty())
            {
                insert createTasks;     
            }               
        }
        catch (DMLException e)
        {
            System.debug(e);
        }
        
    }
    @future
    public static void cancelTrainingTask(Set<String> userIds)
    {
        List<TrainingTask__c> cancelTasks = [select Id from TrainingTask__c where OwnerId in :userIds and IsClosed__c = false and TaskTemplate__c != ''];       
        try{
            if(!cancelTasks.isEmpty())
            {
                delete cancelTasks;
            }               
        }
        catch (DMLException e)
        {
            new ExceptionHandler(e.getMessage());          
        }    
    }
}