public with sharing class TrainingTaskController 
{
    public String CurrentUser { get; private set; }
    public String UserPath { get; private set; }
    public Boolean IsTrainingAdmin { get; private set; }    
    public TrainingTaskController() 
    {
        initCurrentUser();
        initUserPath();
        initIsTrainingAdmin();      
    } 

    @RemoteAction
    public static List<TrainingMessage__c> getMessageByDivision(String division)
    {        
        return [select Message__c from TrainingMessage__c 
                where (ForAllDivisions__c = true or Division__c = :division) and ExpiryDate__c >= :Date.today()
                order by ExpiryDate__c];
    }

    @RemoteAction
    public static List<TrainingTaskWrapper> getTasksByUser(String userId) 
    {
        Map<String, List<TrainingTask__c>> tab2TasksMap = getTaskTab2TasksMap(userId);        
        List<TrainingTaskWrapper> results = new List<TrainingTaskWrapper>();
        List<String> taskTemplateTabs = getTabsFromFieldDescribe();
        User u = [select Employment_Start_Date__c, CreatedDate from User where Id = :userId];
        Integer daysOnJob = getDaysOnJob(u);
        Map<String, Integer> activeTabMap = new Map<String, Integer>{'Week1'=>7, '< 30 Days'=>30, '< 60 Days'=>60, '< 90 Days'=>90, 'Elevate'=>120};
        for(String tab : taskTemplateTabs)
        {            
            TrainingTaskWrapper wrapper = new TrainingTaskWrapper(tab);
            if(daysOnJob < activeTabMap.get(tab))
            {
                wrapper.ClassName = 'status-gray';
            }
            if(tab2TasksMap.containsKey(tab))
            {
                setTaskWrapperPerTab(wrapper, tab2TasksMap.get(tab));                
            }          
            results.add(wrapper);
        }
        return results;
    }

    @RemoteAction
    public static List<TeamTaskSummary> getTeamTaskSummary(String userRoleId)
    {
        Map<Id, List<Id>> subRoleMapping =  getSubRoleMapping();                           
        List<User> subordinates = getDirectSubordinateUsers(userRoleId, subRoleMapping);

        subordinates = [select Id, Name, CreatedDate, Employment_Start_Date__c, UserRoleId
                                   from User 
                                   where Id in :subordinates
                                   order by Name];

        if(subordinates.isEmpty())
        {
            return null;
        }
        List<TeamTaskSummary> summaries = new List<TeamTaskSummary>();
        Map<String, List<TrainingTask__c>> user2TasksMap = getUser2TasksMap(subordinates);        
        Integer daysOnJob = 0;
        for(User u : subordinates)
        {
            daysOnJob = getDaysOnJob(u);
            TeamTaskSummary summary;           
            if(user2TasksMap.containsKey(u.Id))
            {
                summary = new TeamTaskSummary(u.Id, u.Name, daysOnJob, true);
                calculateCompleteProgress(summary, user2TasksMap.get(u.Id));
            }
            else{
                summary = new TeamTaskSummary(u.Id, u.Name, daysOnJob, false);
                calculateCompleteProgress(summary, new List<TrainingTask__c>());
            }
            
            summaries.add(summary);
        }
        return summaries;       
    }    

    @RemoteAction
    public static void closeTask(String recordId)
    {
        TrainingTask__c t = [select Status__c, CompletedDate__c from TrainingTask__c where Id = :recordId];
        t.Status__c = 'Complete';
        t.CompletedDate__c = Date.today();
        update t;
    }
    
    public class TrainingTaskWrapper
    {
        public String Tab { get; private set; }        
        public List<TrainingTask> Tasks { get; private set; }
        public Integer TotalOpened { get; private set; }
        public Integer TotalCompleted { get; private set; }
        public Integer Progress { get; private set; }
        public String ClassName { get; private set; }

        public TrainingTaskWrapper(String tab)
        {
            this.Tab = tab;
            this.Progress = 100;
            this.ClassName = 'status-success';
            this.TotalOpened = 0;
            this.TotalCompleted = 0;
            this.Tasks = new List<TrainingTask>();            
        }
    }

    public class TeamTaskSummary
    {
        public String UserId { get; private set; }
        public String UserName { get; private set; }
        public Integer OverallCompleteRate { get; private set; }
        public Integer ProductCompleteRate { get; private set; }
        public Integer SellingCompleteRate { get; private set; }
        public Integer ToolCompleteRate { get; private set; }
        public Integer DaysOnJob { get; private set; }
        public Boolean HasTask { get; private set; }
        
        public TeamTaskSummary(String userId, String userName, Integer daysOnJob, Boolean hasTask)
        {
            this.UserId = userId;
            this.UserName = userName;
            this.DaysOnJob = daysOnJob;
            this.HasTask = hasTask;
        }
    }

    public class HierarchyNode
    {
        public String UserName { get; private set; }
        public String UserId { get; private set; }
    }

    private static Integer getDaysOnJob(User user)
    {
        if(user.Employment_Start_Date__c != null)
        {
            return user.Employment_Start_Date__c.daysBetween(Date.today());
        }
        else
        {
            return user.CreatedDate.date().daysBetween(Date.today());
        }
    }

    private static void calculateCompleteProgress(TeamTaskSummary summary, List<TrainingTask__c> tasks)
    {
        Integer overallOpen = 0;
        Integer overallComplete = 0;        
        Integer productOpen = 0;
        Integer productComplete = 0;
        Integer sellingOpen = 0;
        Integer sellingComplete = 0;
        Integer toolOpen = 0;
        Integer toolComplete = 0;
        for(TrainingTask__c t : tasks)
        {
            if(t.IsClosed__c)
            {
                overallComplete++;
                if(t.Category__c == 'Product')
                {
                    productComplete++;
                }
                else if(t.Category__c == 'Selling')
                {
                    sellingComplete++;
                }
                else if(t.Category__c == 'Tool')
                {
                    toolComplete++;
                }
            }
            else
            {
                overallOpen++;
                if(t.Category__c == 'Product')
                {
                    productOpen++;
                }
                else if(t.Category__c == 'Selling')
                {
                    sellingOpen++;
                }
                else if(t.Category__c == 'Tool')
                {
                    toolOpen++;
                }
            }
        }
        summary.OverallCompleteRate = calculateProgress(overallOpen, overallComplete);
        summary.ProductCompleteRate = calculateProgress(productOpen, productComplete);
        summary.SellingCompleteRate = calculateProgress(sellingOpen, sellingComplete);
        summary.ToolCompleteRate = calculateProgress(toolOpen, toolComplete);        
    }

    private static Map<String, List<TrainingTask__c>> getTaskTab2TasksMap(String userId)
    {
        Map<String, List<TrainingTask__c>> results = new Map<String, List<TrainingTask__c>>();
        for(TrainingTask__c t : [select Name, Description__c, Status__c, IsClosed__c, DueDate__c, Tab__c,
                                        Category__c, AttachmentName__c, AttachmentUrl__c, 
                                        CompletedDate__c, SeatTime__c
                                 from TrainingTask__c 
                                 where OwnerId = :userId
                                 order by Tab__c, TaskTemplate__r.Sort__c NULLS FIRST, Status__c, DueDate__c])
        {
            if(!results.containsKey(t.Tab__c))
            {
                results.put(t.Tab__c, new List<TrainingTask__c>());
            }
            results.get(t.Tab__c).add(t);
        }
        return results;
    }

    private static TrainingTask generateTrainingTask(TrainingTask__c t)
    {
        String activityDate = t.DueDate__c == null ? '' : t.DueDate__c.format();
        Boolean isDue = (!t.IsClosed__c && t.DueDate__c < Date.today());
        String filter = 'Open';
        if(t.IsClosed__c)
        {
            filter = 'Completed';
        } 
        return new TrainingTask(t.Id, 
                                t.Name, 
                                t.Description__c, 
                                t.Status__c, 
                                t.IsClosed__c, 
                                filter, 
                                activityDate, 
                                isDue, 
                                t.Tab__c, 
                                t.Category__c,
                                t.AttachmentName__c,
                                t.AttachmentUrl__c,
                                t.SeatTime__c);
    }

    private static List<String> getTabsFromFieldDescribe()
    {
        Schema.DescribeFieldResult dfr = Schema.SObjectType.TaskTemplate__c.fields.Tab__c;
        List<String> results = new List<String>();
        for(Schema.PicklistEntry entry : dfr.getPicklistValues())
        {
            results.add(entry.getValue());
        }
        return results;
    }

    private static void setTaskWrapperPerTab(TrainingTaskWrapper wrapper, List<TrainingTask__c> tasks)
    {        
        for(TrainingTask__c t : tasks)
        {
            wrapper.Tasks.add(generateTrainingTask(t));
            if(t.IsClosed__c)
            {
                wrapper.TotalCompleted++;
            }
            else
            {
                wrapper.TotalOpened++;
                if(wrapper.ClassName != 'status-gray')
                {
                    if(t.DueDate__c < Date.today())
                    {
                        wrapper.ClassName = 'status-danger';
                    }
                    else if(wrapper.ClassName != 'status-danger')
                    {
                        wrapper.ClassName = 'status-warning';
                    }
                }
                
            }
        }
        wrapper.Progress = calculateProgress(wrapper.TotalOpened, wrapper.TotalCompleted);
    }

    private static Integer calculateProgress(Integer totalOpened, Integer totalCompleted)
    {
        if(totalOpened == 0)
        {
            return 100;
        }
        return 100 * totalCompleted / (totalOpened + totalCompleted);
    }

    private static Map<String, List<TrainingTask__c>> getUser2TasksMap(List<User> users)
    {        
        Map<String, List<TrainingTask__c>> results = new Map<String, List<TrainingTask__c>>();
        for(TrainingTask__c t : [select OwnerId, IsClosed__c, DueDate__c, Category__c 
                                 from TrainingTask__c where OwnerId in :users])
        {
            if(!results.containsKey(t.OwnerId))
            {
                results.put(t.OwnerId, new List<TrainingTask__c>());
            }
            results.get(t.OwnerId).add(t);
        }
        return results;
    }

    private void initCurrentUser()
    {
        String userId = ApexPages.currentPage().getParameters().get('uid');
        if(String.isBlank(userId))
        {
            userId = UserInfo.getUserId();            
        }        
        List<User> users = [select Id, Name, TrainingDivision__c, UserRoleId from User where Id = :userId];        
        if(users.size() > 0)
        {
            CurrentUser = JSON.serialize(users[0]);
        }
    }

    private void initUserPath()
    {
        String path = ApexPages.currentPage().getParameters().get('path');
        if(String.isNotBlank(path))
        {
            List<String> userIds = path.split('/');
            List<User> queryUsers = [select Id, Name from User where Id in :userIds];
            List<User> users = new List<User>();
            for(String userId :userIds)
            {
                for(User user :queryUsers)
                {
                    if(String.isNotBlank(userId) && user.Id == userId)
                    {
                        users.add(user);
                    }
                }
            }
            UserPath = JSON.serialize(users);
        }
        else
        {
            UserPath = '[]';
        }
    }

    private void initIsTrainingAdmin()
    {
        List<PermissionSetAssignment> assignments = 
            [select Id from PermissionSetAssignment where AssigneeId = :UserInfo.getUserId() and PermissionSet.Name = 'TrainingAdminUsers'];
        IsTrainingAdmin = assignments.size() > 0;
    }

    private static List<User> getDirectSubordinateUsers(Id roleId, Map<Id, List<Id>> subRoleMapping)
    {
        List<User> results = new List<User>();
        if(subRoleMapping.containsKey(roleId))
        {
            List<Id> roleIds = subRoleMapping.get(roleId);
            if(!roleIds.isEmpty())
            {
                for(Id rId : roleIds)
                {
                    List<User> users = [select Id from User where UserRoleId = :rId and IsActive = true and TrainingEnabled__c = true];   
                    if(!users.isEmpty())
                    {
                        results.addAll(users);
                    }
                    else
                    {
                        results.addAll(getDirectSubordinateUsers(rId, subRoleMapping));
                    }
                }
            }
        }
        return results;
    }

    private static Map<Id, List<Id>> getSubRoleMapping()
    {

        Map<Id, List<Id>> subRoleMapping = new Map<Id, List<Id>>();
        for(UserRole role :[select Id, ParentRoleId from UserRole where PortalType = 'None'])
        {
            if(!subRoleMapping.containsKey(role.ParentRoleId))
            {
                subRoleMapping.put(role.ParentRoleId, new List<Id>());
            }
            subRoleMapping.get(role.ParentRoleId).add(role.Id);
        }
        return subRoleMapping;
    }
}