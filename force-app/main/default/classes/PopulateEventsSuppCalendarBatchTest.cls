/* Apex test class: PopulateEventsSuppCalendarBatchTest
* This is the test class with unit test methods to achieve minimum code coverage for the "PopulateEventsFromSupportcalendarBatch" batch class.
* Author: Exafort(Vishnu)
* Date: 9th July 2018
*/

@istest(SeeAllData=true)
public class PopulateEventsSuppCalendarBatchTest {
    class TestData {
        CntrbnMdl_TSE__c contTSE;
        Event leaveEvent_allDay;
        User userRecord;
        
        TestData(){
            Profile profileRecord = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)']; 
            
            userRecord = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
                          TimeZoneSidKey, UserName from user where id =: '00580000003xTOl'];
            
            
            system.runAs(userRecord){
                contTSE = [select id from CntrbnMdl_TSE__c where Employee_Name__c = '00580000003xTOl'];
                
                
                insert leaveEvent_allDay = new Event(Subject = 'Test Subject',
                                                     IsAllDayEvent = true,
                                                     eventType__c = 'Leave',
                                                     eventSubType__c = 'PTO',
                                                     StartDateTime = DateTime.now(),
                                                     EndDateTime = DateTime.now() ,
                                                     Description = 'Test Description',
                                                     IsCancelled__c = false,
                                                     Related_Contribution_Model_TSE__c = contTSE.Id,
                                                     WhatId =  contTSE.Id,
                                                     OwnerId = userRecord.Id);
            }
        }
    }
    
    static testMethod void tseEventScheduler(){
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        TSEEventScheduler TseEventNew=new TSEEventScheduler();
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, TseEventNew);
        Test.stopTest();
    } 
    
    static testMethod void eventsFromSupportcalendarBatch(){
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        Database.executeBatch(new PopulateEventsFromSupportcalendarBatch());
        Test.stopTest();
    }
    
    static testMethod void eventsFromCalendarAllEmployees(){
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        Database.executeBatch(new PopulateEventsFromCalendarAllEmployees());
        Test.stopTest();
    }
    
}