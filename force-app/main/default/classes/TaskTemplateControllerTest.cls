@isTest
private class TaskTemplateControllerTest 
{   
    @isTest static void testTaskTemplateController() 
    {
        List<User> testUsers = TestDataFactory.createTestUsers();
        system.runAs(testUsers[0])
        {
            /* Message and TaskTemplate are not created yet */
            Test.startTest();
            TaskTemplateController controller = new TaskTemplateController();
            String divisionOptions = controller.DivisionOptions;
            String messages = controller.Messages;
            String taskTemplates = controller.TaskTemplates;
            system.assertEquals('[]', messages);
            system.assertEquals('[]', taskTemplates);        
       
            TrainingMessage message = new TrainingMessage();
            message.Division = 'Field Sales';
            message.Message = 'Test Message';
            message.ExpiryDate = Date.today().addMonths(1).format();
            message.ForAllDivisions = false;
            TaskTemplateController.saveMessage(message);

            // For All Messages
            TrainingMessage messageForAll = new TrainingMessage();
            messageForAll.Message = 'Message for All';
            messageForAll.ExpiryDate = Date.today().addMonths(1).format();
            messageForAll.ForAllDivisions = true;
            TaskTemplateController.saveMessage(messageForAll);

            TaskTemplate template = new TaskTemplate();
            template.Tab = 'Week1';
            template.Category = 'Tool';
            template.Subject = 'Test Template';
            template.EffectiveDate = Date.today().format();
            template.Description = 'Test Template';
            template.Division = 'Field Sales';
            template.ForAllDivisions = false;
            template.ExistingUsersWillReceiveThisTask = true;
            String templateId = TaskTemplateController.saveTemplate(template);

            template.SortOrder = 1;
            TaskTemplateController.changeSortOrder(templateId, 1);

            TaskTemplate__c tt = [select Sort__c from TaskTemplate__c where Id = :templateId];
            System.assertEquals(tt.Sort__c, 1);

            TaskTemplate templateForAll = new TaskTemplate();
            templateForAll.Tab = 'Week1';
            templateForAll.Category = 'Tool';
            templateForAll.Subject = 'Template for All';
            templateForAll.EffectiveDate = Date.today().format();
            templateForAll.Description = 'Template for All';
            templateForAll.ForAllDivisions = true;
            templateForAll.ExistingUsersWillReceiveThisTask = true;
            templateId = TaskTemplateController.saveTemplate(templateForAll);

            TaskTemplateController.uploadFile(templateId, 'Test.pdf', 'Test', '');

            messages = controller.Messages;
            taskTemplates = controller.TaskTemplates;
            
            TaskTemplateController.deleteRecord(templateId);
            Test.stopTest();
        }        
    }
}