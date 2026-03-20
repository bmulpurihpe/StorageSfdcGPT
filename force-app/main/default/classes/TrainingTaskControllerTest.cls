@isTest
private class TrainingTaskControllerTest 
{	
    
    @isTest static void testTrainingTaskController()
    {
        List<User> testUsers = TestDataFactory.createTestUsers();
        User runningUser;
        if(testUsers == null)
        {
            runningUser = TestDataFactory.updateCurrentUser();
        }
        else
        {
            runningUser = testUsers[0];
        }
System.debug(runningUser.Id);        
        system.runAs(runningUser)
        {
            /* Create Messages */
            TrainingMessage__c message = new TrainingMessage__c();
            message.Division__c = 'Field Sales';
            message.Message__c = 'Test Message';
            message.ExpiryDate__c = Date.today().addMonths(1);
            message.ForAllDivisions__c = false;

            // For All Messages
            TrainingMessage__c messageForAll = new TrainingMessage__c();
            messageForAll.Message__c = 'Message for All';
            messageForAll.ExpiryDate__c = Date.today().addMonths(1);
            messageForAll.ForAllDivisions__c = true;

            TrainingMessage__c[] messages = new TrainingMessage__c[]{message, messageForAll};
            insert messages;

            /* Create Task Template */
            TaskTemplate__c template = new TaskTemplate__c();
            template.Tab__c = 'Week1';
            template.Category__c = 'Tool';
            template.Subject__c = 'Test Template';
            template.Effective_Date__c = Date.today();
            template.Description__c = 'Test Template';
            template.Division__c = 'Field Sales';
            template.ForAllDivisions__c = false;
            template.ExistingUsersWillReceiveThisTask__c = true;

            TaskTemplate__c templateForAll = new TaskTemplate__c();
            templateForAll.Tab__c = 'Week1';
            templateForAll.Category__c = 'Tool';
            templateForAll.Subject__c = 'Template for All';
            templateForAll.Effective_Date__c = Date.today();
            templateForAll.Description__c = 'Template for All';
            templateForAll.ForAllDivisions__c = true;
            templateForAll.ExistingUsersWillReceiveThisTask__c = true;
            TaskTemplate__c[] templates = new TaskTemplate__c[]{template, templateForAll};
            insert templates;

            Test.startTest();
            TrainingTaskController controller = new TrainingTaskController();
            List<TrainingMessage__c> messagesByDivision = TrainingTaskController.getMessageByDivision('Field Sales');
            system.assertNotEquals(0, messagesByDivision.size());

            TrainingTaskController.getTasksByUser(runningUser.Id);

            List<TrainingTaskController.TeamTaskSummary> summary = TrainingTaskController.getTeamTaskSummary(runningUser.UserRoleId);

            List<TrainingTask__c> tasks = [select Id from TrainingTask__c where OwnerId = :runningUser.Id];
            for(TrainingTask__c t : tasks)
            {
                TrainingTaskController.closeTask(t.Id);
            }
            Test.stopTest();
        }        
    }   
}