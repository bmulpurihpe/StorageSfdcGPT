@isTest(seeAllData = True)
public class calendarEventTest {
    class testData{
        User testUser;
        CntrbnMdl_TSE__c testModelTSE;
        Event leaveEvent_allDay;
        testData(){
            Profile fetchProfile = [Select Id, Name from Profile where Name = 'System Administrator' LIMIT 1];
            
            testUser = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
                      TimeZoneSidKey, UserName from user where id =: '00580000003xTOl'];
            
            testModelTSE = [select id,Employee_Name__c,Organization__c,Team__c from CntrbnMdl_TSE__c where Employee_Name__c =: testUser.Id];
            /*testUser = new User();
            testUser.FirstName = 'test First Name';
            testUser.LastName = 'test Last Name';
            testUser.Username = 'testuser54653167@gmail.com';
            testUser.Email = 'testuser@gmail.com';
            testUser.ProfileId = fetchProfile.Id;
            testUser.Alias = 'testA';
            testUser.TimeZoneSidKey = 'America/Los_Angeles';
            testUser.LocaleSidKey = 'en_US';
            testUser.EmailEncodingKey = 'UTF-8';
            testUser.LanguageLocaleKey = 'en_US';
            insert testUser;
            
            testModelTSE = new CntrbnMdl_TSE__c();
            testModelTSE.Employee_Name__c = testUser.Id;
            testModelTSE.Organization__c = 'TSE';
            //testModelTSE.Team__c ='Minnesota';
            testModelTSE.OwnerId = testUser.Id;
            insert testModelTSE;*/
            
            leaveEvent_allDay = new Event();
            leaveEvent_allDay.Subject = 'Test Subject';
            leaveEvent_allDay.IsAllDayEvent = true;
            leaveEvent_allDay.eventType__c = 'Leave';
            leaveEvent_allDay.eventSubType__c = 'PTO';
            leaveEvent_allDay.StartDateTime = DateTime.now();
            leaveEvent_allDay.EndDateTime = DateTime.now() + 1;
            leaveEvent_allDay.Description = 'Test Description';
            leaveEvent_allDay.Related_Contribution_Model_TSE__c = testModelTSE.Id;
            leaveEvent_allDay.OwnerId = testUser.Id;
            insert leaveEvent_allDay;
            
        }
    }
    static testMethod void test01_calendarEvent_Controller(){
        test.startTest();
        testData td = new testData();
        calendarEvent_Controller testEventController = new calendarEvent_Controller();
        testEventController.tempEventDate = '2018-03-01';
        testEventController.changeDate();
        testEventController.tempEventId = String.valueOf(td.leaveEvent_allDay.Id);
        testEventController.editEvent();
        testEventController.getTeamList();
        testEventController.getOrganizationList();
        testEventController.getTeamListValues();
        testEventController.getOrganizationListValues();
        List<String> teamsList = new List<String>();
        teamsList.add('RTP');
        teamsList.add('Minnesota');
        teamsList.add('HQ');
        teamsList.add('APAC');
        teamsList.add('EMEA');
        teamsList.add('Weekend');
        teamsList.add('Other');
        testEventController.teams = teamsList;
        testEventController.setTeamListValues(teamsList);
        List<String> organizationList = new List<String>();
        organizationList.add('TSE');
        organizationList.add('PEAK');
        organizationList.add('Other');
        testEventController.organizations = organizationList;
        testEventController.setOrganizationListValues(organizationList);
        testEventController.pageLoad();
        testEventController.toggleTeamOrgEvents();
        Event getNewEvent = new Event();
        getNewEvent.Subject = 'Test Subject';
        getNewEvent.IsAllDayEvent = true;
        getNewEvent.eventType__c = 'Leave';
        getNewEvent.eventSubType__c = 'PTO';
        getNewEvent.StartDateTime = DateTime.now();
        getNewEvent.EndDateTime = DateTime.now() + 1;
        getNewEvent.Description = 'Test Description';
        getNewEvent.Related_Contribution_Model_TSE__c = td.testModelTSE.Id;
        getNewEvent.OwnerId = td.testUser.Id;
        testEventController.newEvent = getNewEvent;
        testEventController.new_allDayStartDateInString = '3/7/2018';
        testEventController.new_allDayEndDateInString = '3/8/2018';
        testEventController.new_allDayStartDateTimeInString = '02/14/2019 01:33 PM';
        testEventController.new_allDayEndDateTimeInString = '02/15/2019 01:33 PM';
        testEventController.saveNewEvent();
        testEventController.editEventDetails = td.leaveEvent_allDay;
        testEventController.saveEditEvent();
        test.stopTest();
    }
    static testMethod void test02_calendarEvent_Controller(){
        test.startTest();
        testData td = new testData();
        calendarEvent_Controller testEventController = new calendarEvent_Controller();
        testEventController.tempEventDate = '2018-03-01';
        testEventController.changeDate();
        testEventController.tempEventId = String.valueOf(td.leaveEvent_allDay.Id);
        testEventController.tempviewEventId = String.valueOf(td.leaveEvent_allDay.Id);
        testEventController.editEvent();
        testEventController.getTeamList();
        testEventController.getOrganizationList();
        testEventController.getTeamListValues();
        testEventController.getOrganizationListValues();
        List<String> teamsList = new List<String>();
        teamsList.add('RTP');
        teamsList.add('Minnesota');
        teamsList.add('HQ');
        teamsList.add('APAC');
        teamsList.add('EMEA');
        teamsList.add('Weekend');
        teamsList.add('Other');
        testEventController.teams = teamsList;
        testEventController.setTeamListValues(teamsList);
        List<String> organizationList = new List<String>();
        organizationList.add('TSE');
        organizationList.add('PEAK');
        organizationList.add('Other');
        testEventController.organizations = organizationList;
        testEventController.setOrganizationListValues(organizationList);
        testEventController.pageLoad();
        testEventController.firstTimePageLoad();
        testEventController.toggleTeamOrgEvents();
        Event getNewEvent = new Event();
        getNewEvent.Subject = 'Test Subject';
        getNewEvent.IsAllDayEvent = true;
        getNewEvent.eventType__c = 'Leave';
        getNewEvent.eventSubType__c = 'PTO';
        getNewEvent.StartDateTime = DateTime.now();
        getNewEvent.EndDateTime = DateTime.now() + 1;
        getNewEvent.Description = 'Test Description';
        getNewEvent.Related_Contribution_Model_TSE__c = td.testModelTSE.Id;
        getNewEvent.OwnerId = td.testUser.Id;
        testEventController.newEvent = getNewEvent;
        testEventController.new_allDayStartDateInString = '3/7/2018';
        testEventController.new_allDayEndDateInString = '3/8/2018';
        testEventController.new_allDayStartDateTimeInString = '02/14/2019 01:33 PM';
        testEventController.new_allDayEndDateTimeInString = '02/15/2019 01:33 PM';
        testEventController.saveNewEvent();
        testEventController.editEventDetails = td.leaveEvent_allDay;
        testEventController.saveEditEvent();
        testEventController.viewEventDetails = td.leaveEvent_allDay;
        testEventController.viewEvent();
        test.stopTest();
    }
    static testMethod void test03_calendarEvent_Controller(){
        test.startTest();
        testData td = new testData();
        calendarEvent_Controller testEventController = new calendarEvent_Controller();
        testEventController.tempEventDate = '2018-03-01';
        testEventController.changeDate();
        testEventController.tempEventId = String.valueOf(td.leaveEvent_allDay.Id);
        testEventController.tempviewEventId = String.valueOf(td.leaveEvent_allDay.Id);
        testEventController.editEvent();
        testEventController.getTeamList();
        testEventController.getOrganizationList();
        testEventController.getTeamListValues();
        testEventController.getOrganizationListValues();
        List<String> teamsList = new List<String>();
        teamsList.add('RTP');
        teamsList.add('Minnesota');
        teamsList.add('HQ');
        teamsList.add('APAC');
        teamsList.add('EMEA');
        teamsList.add('Weekend');
        teamsList.add('Other');
        testEventController.teams = teamsList;
        testEventController.setTeamListValues(teamsList);
        List<String> organizationList = new List<String>();
        organizationList.add('TSE');
        organizationList.add('PEAK');
        organizationList.add('Other');
        testEventController.organizations = organizationList;
        testEventController.setOrganizationListValues(organizationList);
        testEventController.pageLoad();
        testEventController.firstTimePageLoad();
        testEventController.toggleTeamOrgEvents();
        Event getNewEvent = new Event();
        getNewEvent.Subject = 'Test Subject';
        getNewEvent.IsAllDayEvent = true;
        getNewEvent.eventType__c = 'Leave';
        getNewEvent.eventSubType__c = 'PTO';
        getNewEvent.StartDateTime = DateTime.now();
        getNewEvent.EndDateTime = DateTime.now() + 1;
        getNewEvent.Description = 'Test Description';
        getNewEvent.Related_Contribution_Model_TSE__c = td.testModelTSE.Id;
        try{
            getNewEvent.OwnerId = null;
        }
        catch(Exception e){}
        testEventController.newEvent = getNewEvent;
        testEventController.new_allDayStartDateInString = '3/7/2018';
        testEventController.new_allDayEndDateInString = '3/8/2018';
        testEventController.new_allDayStartDateTimeInString = '02/14/2019 01:33 PM';
        testEventController.new_allDayEndDateTimeInString = '02/15/2019 01:33 PM';
        testEventController.saveNewEvent();
        testEventController.editEventDetails = td.leaveEvent_allDay;
        testEventController.saveEditEvent();
        testEventController.viewEventDetails = td.leaveEvent_allDay;
        testEventController.viewEvent();
        test.stopTest();
    }
    static testMethod void test04_calendarEvent_Controller(){
        test.startTest();
        testData td = new testData();
        calendarEvent_Controller testEventController = new calendarEvent_Controller();
        testEventController.tempEventDate = '2018-03-01';
        testEventController.changeDate();
        testEventController.tempEventId = String.valueOf(td.leaveEvent_allDay.Id);
        testEventController.tempviewEventId = String.valueOf(td.leaveEvent_allDay.Id);
        testEventController.editEvent();
        testEventController.getTeamList();
        testEventController.getOrganizationList();
        testEventController.getTeamListValues();
        testEventController.getOrganizationListValues();
        List<String> teamsList = new List<String>();
        teamsList.add('RTP');
        teamsList.add('Minnesota');
        teamsList.add('HQ');
        teamsList.add('APAC');
        teamsList.add('EMEA');
        teamsList.add('Weekend');
        teamsList.add('Other');
        testEventController.teams = teamsList;
        testEventController.setTeamListValues(teamsList);
        List<String> organizationList = new List<String>();
        organizationList.add('TSE');
        organizationList.add('PEAK');
        organizationList.add('Other');
        testEventController.organizations = organizationList;
        testEventController.setOrganizationListValues(organizationList);
        testEventController.pageLoad();
        testEventController.firstTimePageLoad();
        testEventController.toggleTeamOrgEvents();
        Event getNewEvent = new Event();
        getNewEvent.OwnerId =  td.testUser.Id;
        try{
            getNewEvent.Subject = null;
        }
        catch(Exception e){}
        //getNewEvent.Subject = 'Test Subject';
        getNewEvent.IsAllDayEvent = true;
        //getNewEvent.eventType__c = 'Leave';
        getNewEvent.eventSubType__c = 'PTO';
        getNewEvent.StartDateTime = DateTime.now();
        getNewEvent.EndDateTime = DateTime.now() + 1;
        getNewEvent.Description = 'Test Description';
        getNewEvent.Related_Contribution_Model_TSE__c = td.testModelTSE.Id;
        try{
            getNewEvent.eventType__c = null;
        }
        catch(Exception e){}
        testEventController.newEvent = getNewEvent;
        testEventController.new_allDayStartDateInString = '3/7/2018';
        testEventController.new_allDayEndDateInString = '3/8/2018';
        testEventController.new_allDayStartDateTimeInString = '02/14/2019 01:33 PM';
        testEventController.new_allDayEndDateTimeInString = '02/15/2019 01:33 PM';
        testEventController.saveNewEvent();
        test.stopTest();
    }
    static testMethod void test05_calendarEvent_Controller(){
        test.startTest();
        testData td = new testData();
        calendarEvent_Controller testEventController = new calendarEvent_Controller();
        testEventController.tempEventDate = '2018-03-01';
        testEventController.changeDate();
        testEventController.tempEventId = String.valueOf(td.leaveEvent_allDay.Id);
        testEventController.tempviewEventId = String.valueOf(td.leaveEvent_allDay.Id);
        testEventController.editEvent();
         testEventController.selectedname='REGION';
        testEventController.getTeamList();
        testEventController.getOrganizationList();
        testEventController.getTeamListValues();
        testEventController.getOrganizationListValues();
        List<String> teamsList = new List<String>();
        teamsList.add('RTP');
        teamsList.add('Minnesota');
        teamsList.add('HQ');
        teamsList.add('APAC');
        teamsList.add('EMEA');
        teamsList.add('Weekend');
        teamsList.add('Other');
        testEventController.teams = teamsList;
        testEventController.setTeamListValues(teamsList);
        List<String> organizationList = new List<String>();
        organizationList.add('TSE');
        organizationList.add('PEAK');
        organizationList.add('Other');
        testEventController.organizations = organizationList;
        testEventController.setOrganizationListValues(organizationList);
        testEventController.pageLoad();
        testEventController.firstTimePageLoad();
        testEventController.toggleTeamOrgEvents();
        Event getNewEvent = new Event();
        getNewEvent.OwnerId =  td.testUser.Id;
        getNewEvent.Subject = 'Test Subject';
        getNewEvent.eventType__c = 'Leave';
        getNewEvent.eventSubType__c = 'PTO';
        getNewEvent.StartDateTime = DateTime.now();
        getNewEvent.EndDateTime = DateTime.now() + 1;
        getNewEvent.Description = 'Test Description';
        getNewEvent.Related_Contribution_Model_TSE__c = td.testModelTSE.Id;
        getNewEvent.IsAllDayEvent = false;
        try{
            
            getNewEvent.StartDateTime = null;
            //getNewEvent.EndDateTime = DateTime.now() + 1;
        }
        catch(Exception e){}
        try{
            //getNewEvent.IsAllDayEvent = false;
            //getNewEvent.StartDateTime = DateTime.now();
            getNewEvent.EndDateTime = null;
        }
        catch(Exception e){}
        testEventController.newEvent = getNewEvent;
        testEventController.new_allDayStartDateInString = '3/7/2018';
        testEventController.new_allDayEndDateInString = '3/8/2018';
        testEventController.new_allDayStartDateTimeInString = '02/14/2019 01:33 PM';
        testEventController.new_allDayEndDateTimeInString = '02/15/2019 01:33 PM';
        testEventController.saveNewEvent();
        test.stopTest();
    }
    static testMethod void test06_calendarEvent_Controller(){
        test.startTest();
        //testData td = new testData();
        //CVreating test data for a test user with a different timezone and locale.
        User testUser;
        CntrbnMdl_TSE__c testModelTSE;
        Event leaveEvent_allDay;
            Profile fetchProfile = [Select Id, Name from Profile where Name = 'Support: Management' LIMIT 1];
        
          testUser = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
                      TimeZoneSidKey, UserName from user where id =: '00580000003xTOl'];
            
            testModelTSE = [select id from CntrbnMdl_TSE__c where Employee_Name__c =: testUser.id];
        
            /*testUser = new User();
            testUser.FirstName = 'test First Name_e';
            testUser.LastName = 'test Last Name_e';
            testUser.Username = 'testuser54670670953167@gmail.com';
            testUser.Email = 'testuser572657@gmail.com';
            testUser.ProfileId = fetchProfile.Id;
            testUser.Alias = 'test13';
            testUser.TimeZoneSidKey = 'Asia/Singapore';
            testUser.LocaleSidKey = 'en_IE';
            testUser.EmailEncodingKey = 'UTF-8';
            testUser.LanguageLocaleKey = 'en_US';
            insert testUser;
            
            testModelTSE = new CntrbnMdl_TSE__c();
            testModelTSE.Employee_Name__c = testUser.Id;
            testModelTSE.Organization__c = 'TSE';
            //testModelTSE.Team__c ='Minnesota';
            testModelTSE.OwnerId = testUser.Id;
            insert testModelTSE;*/
            
            leaveEvent_allDay = new Event();
            leaveEvent_allDay.Subject = 'Test Subject';
            leaveEvent_allDay.IsAllDayEvent = true;
            leaveEvent_allDay.eventType__c = 'Leave';
            leaveEvent_allDay.eventSubType__c = 'PTO';
            leaveEvent_allDay.StartDateTime = DateTime.now();
            leaveEvent_allDay.EndDateTime = DateTime.now() + 1;
            leaveEvent_allDay.Description = 'Test Description';
            leaveEvent_allDay.Related_Contribution_Model_TSE__c = testModelTSE.Id;
            leaveEvent_allDay.OwnerId = testUser.Id;
            insert leaveEvent_allDay;
        //Test data end
        system.runAs(testUser){
            
            calendarEvent_Controller testEventController = new calendarEvent_Controller();
            testEventController.tempEventDate = '2018-03-01';
            testEventController.changeDate();
            testEventController.getTeamList();
            testEventController.getItems();/// 
            testEventController.getOrganizationList();
            testEventController.getTeamListValues();
            testEventController.getOrganizationListValues();
            List<String> teamsList = new List<String>();
            teamsList.add('RTP');
            teamsList.add('Minnesota');
            teamsList.add('HQ');
            teamsList.add('APAC');
            teamsList.add('EMEA');
            teamsList.add('Weekend');
            teamsList.add('Other');
            testEventController.teams = teamsList;
            testEventController.setTeamListValues(teamsList);
            List<String> organizationList = new List<String>();
            organizationList.add('TSE');
            organizationList.add('PEAK');
            organizationList.add('Other');
            testEventController.organizations = organizationList;
            testEventController.setOrganizationListValues(organizationList);
            testEventController.pageLoad();
            testEventController.toggleTeamOrgEvents();        
            //New event
            Event getNewEvent1 = new Event();
            getNewEvent1.OwnerId = testUser.Id;
            getNewEvent1.IsAllDayEvent = false;
            getNewEvent1.eventType__c = 'Leave';
            getNewEvent1.eventSubType__c = 'PTO';
            getNewEvent1.StartDateTime = DateTime.now();
            getNewEvent1.EndDateTime = DateTime.now() + 1;
            getNewEvent1.Description = 'Test Description';
            getNewEvent1.Related_Contribution_Model_TSE__c = testModelTSE.Id;
            getNewEvent1.Subject = null;
            //try{
            //    getNewEvent1.Subject = null;
            //}
            //catch(Exception e){}
            testEventController.newEvent = getNewEvent1;
            testEventController.new_allDayStartDateInString = '3/7/2018';
            testEventController.new_allDayEndDateInString = '3/8/2018'; 
            testEventController.new_allDayStartDateTimeInString = '02/13/2020 01:13 PM';
            testEventController.new_allDayEndDateTimeInString = '02/13/2020 07:13 PM';
            testEventController.edit_allDayStartDateTimeInString = '10/03/2020 01:13 PM';
            testEventController.edit_allDayEndDateTimeInString = '10/03/2020 07:13 PM';
            testEventController.selectedname='USER';          
            testEventController.saveNewEvent();
            testEventController.editEventDetails = getNewEvent1;
            //testEventController.tempEventId = String.valueOf(getNewEvent1.Id);
            //testEventController.editEvent();
            testEventController.saveEditEvent();
            //testEventController.viewEvent(); 
        }       
        test.stopTest();          
    }
        static testMethod void test07_calendarEvent_Controller(){
        test.startTest();
        //testData td = new testData();
        //CVreating test data for a test user with a different timezone and locale.
        User testUser;
        CntrbnMdl_TSE__c testModelTSE;
        Event leaveEvent_allDay;
            Profile fetchProfile = [Select Id, Name from Profile where Name = 'Support: Management' LIMIT 1];
        
          testUser = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
                      TimeZoneSidKey, UserName from user where id =: '00580000003xTOl'];
            
            testModelTSE = [select id from CntrbnMdl_TSE__c where Employee_Name__c =: testUser.id];
        
            /*testUser = new User();
            testUser.FirstName = 'test First Name_e';
            testUser.LastName = 'test Last Name_e';
            testUser.Username = 'testuser54670670953167@gmail.com';
            testUser.Email = 'testuser572657@gmail.com';
            testUser.ProfileId = fetchProfile.Id;
            testUser.Alias = 'test13';
            testUser.TimeZoneSidKey = 'Asia/Singapore';
            testUser.LocaleSidKey = 'en_IE';
            testUser.EmailEncodingKey = 'UTF-8';
            testUser.LanguageLocaleKey = 'en_US';
            insert testUser;
            
            testModelTSE = new CntrbnMdl_TSE__c();
            testModelTSE.Employee_Name__c = testUser.Id;
            testModelTSE.Organization__c = 'TSE';
            //testModelTSE.Team__c ='Minnesota';
            testModelTSE.OwnerId = testUser.Id;
            insert testModelTSE;*/
            
            leaveEvent_allDay = new Event();
            leaveEvent_allDay.Subject = 'Test Subject';
            leaveEvent_allDay.IsAllDayEvent = true;
            leaveEvent_allDay.eventType__c = 'Leave';
            leaveEvent_allDay.eventSubType__c = 'PTO';
            leaveEvent_allDay.StartDateTime = DateTime.now();
            leaveEvent_allDay.EndDateTime = DateTime.now() + 1;
            leaveEvent_allDay.Description = 'Test Description';
            leaveEvent_allDay.Related_Contribution_Model_TSE__c = testModelTSE.Id;
            leaveEvent_allDay.OwnerId = testUser.Id;
            insert leaveEvent_allDay;
        //Test data end
        system.runAs(testUser){
            
            calendarEvent_Controller testEventController = new calendarEvent_Controller();
            testEventController.tempEventDate = '2018-03-01';
            testEventController.changeDate();
            testEventController.getTeamList();
            testEventController.getItems();/// 
            testEventController.getOrganizationList();
            testEventController.getTeamListValues();
            testEventController.getOrganizationListValues();
            List<String> teamsList = new List<String>();
            teamsList.add('RTP');
            teamsList.add('Minnesota');
            teamsList.add('HQ');
            teamsList.add('APAC');
            teamsList.add('EMEA');
            teamsList.add('Weekend');
            teamsList.add('Other');
            testEventController.teams = teamsList;
            testEventController.setTeamListValues(teamsList);
            List<String> organizationList = new List<String>();
            organizationList.add('TSE');
            organizationList.add('PEAK');
            organizationList.add('Other');
            testEventController.organizations = organizationList;
            testEventController.setOrganizationListValues(organizationList);
            testEventController.pageLoad();
            testEventController.toggleTeamOrgEvents();        
            //New event
            Event getNewEvent1 = new Event();
            getNewEvent1.OwnerId = testUser.Id;
            getNewEvent1.IsAllDayEvent = true;
            getNewEvent1.eventType__c = 'Leave';
            getNewEvent1.eventSubType__c = 'PTO';
            getNewEvent1.StartDateTime = DateTime.now();
            getNewEvent1.EndDateTime = DateTime.now() + 1;
            getNewEvent1.Description = 'Test Description';
            getNewEvent1.Assigned_To_Region__c='APAC';
            getNewEvent1.Related_Contribution_Model_TSE__c = testModelTSE.Id;
            getNewEvent1.Subject = null;
            //try{
            //    getNewEvent1.Subject = null;
            //}
            //catch(Exception e){}
            testEventController.newEvent = getNewEvent1;
            testEventController.new_allDayStartDateInString = '3/7/2018';
            testEventController.new_allDayEndDateInString = '3/8/2018'; // 
            testEventController.new_allDayStartDateTimeInString = '02/13/2020 01:13 PM';
            testEventController.new_allDayEndDateTimeInString = '02/13/2020 07:13 PM';
            testEventController.edit_allDayStartDateTimeInString = '10/03/2020 01:13 PM';
            testEventController.edit_allDayEndDateTimeInString = '10/03/2020 07:13 PM';
            testEventController.selectedname='REGION';/// 
            
            testEventController.saveNewEvent();
            testEventController.editEventDetails = getNewEvent1;
            //testEventController.tempEventId = String.valueOf(getNewEvent1.Id);
            //testEventController.editEvent();
           // testEventController.saveEditEvent();
            //testEventController.viewEvent(); 
        }       
        test.stopTest();          
    }
      static testMethod void test08_calendarEvent_Controller(){
        test.startTest();
        //testData td = new testData();
        //CVreating test data for a test user with a different timezone and locale.
        User testUser;
        CntrbnMdl_TSE__c testModelTSE;
        Event leaveEvent_allDay;
            Profile fetchProfile = [Select Id, Name from Profile where Name = 'Support: Management' LIMIT 1];
        
          testUser = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
                      TimeZoneSidKey, UserName from user where id =: '00580000003xTOl'];
            
            testModelTSE = [select id from CntrbnMdl_TSE__c where Employee_Name__c =: testUser.id];
        
            /*testUser = new User();
            testUser.FirstName = 'test First Name_e';
            testUser.LastName = 'test Last Name_e';
            testUser.Username = 'testuser54670670953167@gmail.com';
            testUser.Email = 'testuser572657@gmail.com';
            testUser.ProfileId = fetchProfile.Id;
            testUser.Alias = 'test13';
            testUser.TimeZoneSidKey = 'Asia/Singapore';
            testUser.LocaleSidKey = 'en_IE';
            testUser.EmailEncodingKey = 'UTF-8';
            testUser.LanguageLocaleKey = 'en_US';
            insert testUser;
            
            testModelTSE = new CntrbnMdl_TSE__c();
            testModelTSE.Employee_Name__c = testUser.Id;
            testModelTSE.Organization__c = 'TSE';
            //testModelTSE.Team__c ='Minnesota';
            testModelTSE.OwnerId = testUser.Id;
            insert testModelTSE;*/
            
            leaveEvent_allDay = new Event();
            leaveEvent_allDay.Subject = 'Test Subject';
            leaveEvent_allDay.IsAllDayEvent = true;
            leaveEvent_allDay.eventType__c = 'Leave';
            leaveEvent_allDay.eventSubType__c = 'PTO';
            leaveEvent_allDay.StartDateTime = DateTime.now();
            leaveEvent_allDay.EndDateTime = DateTime.now() + 1;
            leaveEvent_allDay.Description = 'Test Description';
            leaveEvent_allDay.Related_Contribution_Model_TSE__c = testModelTSE.Id;
            leaveEvent_allDay.OwnerId = testUser.Id;
            insert leaveEvent_allDay;
        //Test data end
        system.runAs(testUser){
            
            calendarEvent_Controller testEventController = new calendarEvent_Controller();
            testEventController.tempEventDate = '2018-03-01';
            testEventController.changeDate();
            testEventController.getTeamList();
            testEventController.getItems();/// 
            testEventController.getOrganizationList();
            testEventController.getTeamListValues();
            testEventController.getOrganizationListValues();
            List<String> teamsList = new List<String>();
            teamsList.add('RTP');
            teamsList.add('Minnesota');
            teamsList.add('HQ');
            teamsList.add('APAC');
            teamsList.add('EMEA');
            teamsList.add('Weekend');
            teamsList.add('Other');
            testEventController.teams = teamsList;
            testEventController.setTeamListValues(teamsList);
            List<String> organizationList = new List<String>();
            organizationList.add('TSE');
            organizationList.add('PEAK');
            organizationList.add('Other');
            testEventController.organizations = organizationList;
            testEventController.setOrganizationListValues(organizationList);
            testEventController.pageLoad();
            testEventController.toggleTeamOrgEvents();        
            //New event
            Event getNewEvent1 = new Event();
            getNewEvent1.OwnerId = testUser.Id;
            getNewEvent1.IsAllDayEvent = true;
            getNewEvent1.eventType__c = 'Leave';
            getNewEvent1.eventSubType__c = 'PTO';
            getNewEvent1.StartDateTime = DateTime.now();
            getNewEvent1.EndDateTime = DateTime.now() + 1;
            getNewEvent1.Description = 'Test Description';
            getNewEvent1.Assigned_To_Region__c='APAC';
            getNewEvent1.Related_Contribution_Model_TSE__c = testModelTSE.Id;
            getNewEvent1.Subject = null;
            //try{
            //    getNewEvent1.Subject = null;
            //}
            //catch(Exception e){}
            testEventController.newEvent = getNewEvent1;
            testEventController.new_allDayStartDateInString = '3/7/2018';
            testEventController.new_allDayEndDateInString = '3/8/2018'; // 
            testEventController.new_allDayStartDateTimeInString = '02/13/2020 21:13 PM';
            testEventController.new_allDayEndDateTimeInString = '02/13/2020 07:13 PM';
            testEventController.edit_allDayStartDateTimeInString = '10/03/2020 01:13 PM';
            testEventController.edit_allDayEndDateTimeInString = '10/03/2020 07:13 PM';
            testEventController.selectedname='REGION';/// 
            
            testEventController.saveNewEvent();
            testEventController.editEventDetails = getNewEvent1;
            //testEventController.tempEventId = String.valueOf(getNewEvent1.Id);
            //testEventController.editEvent();
           // testEventController.saveEditEvent();
            //testEventController.viewEvent(); 
        }       
        test.stopTest();          
    }
}