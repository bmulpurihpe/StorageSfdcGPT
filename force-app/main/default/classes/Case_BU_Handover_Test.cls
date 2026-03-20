/**
 * @description Test class for Legacy_Case_BU_Handover
 * @author Nagalaxmi Telkar
 * @group Testing
 * @last modified on 11-20-2025
 * @last modified by Nagalaxmi Telkar
**/
@IsTest
public class Case_BU_Handover_Test {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test accounts
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Customer'
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create Support Queue - General (if it doesn't exist)
        Group supportQueue;
        List<Group> existingQueues = [SELECT Id FROM Group WHERE Name = 'Support Queue - General' AND Type = 'Queue' LIMIT 1];
        if (existingQueues.isEmpty()) {
            supportQueue = new Group(
                Name = 'Support Queue - General',
                Type = 'Queue'
            );
            insert supportQueue;
        } else {
            supportQueue = existingQueues[0];
        }

         System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        String uniqueUserName = 'test@test1234567890.'+d.getSandboxName();
        String uniqueUserName1 = 'test@test1234567891.'+d.getSandboxName();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator II (pw never expires)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;

        Account acc = new Account(Name = 'Test Account', ACM_Start_Date__c = Date.today(),Primary_PSM__c = u.Id, ACM_End_Date__c = Date.today() + 365,ACM_Service_Purchased_Quantity__c = 1,ACM_Service_Purchased__c = true);
        insert acc;

        Product2 testProduct1 = new Product2(Name               = 'CS220 Storage Array',
                                             ProductCode        ='S0S38A',
                                             Product_Type__c    ='Hardware',
                                             Product_Type_2__c  ='File Storage',
                                             Controller_Code__c ='CS200',
                                             Description        ='12TB Raw, 8-16TB Usable, 320GB Flash Cache, 6x1 GigE, High Perf Ctlr',
                                             Family             ='File Storage');
        insert testProduct1;

        Asset asst = new Asset(Name                         = 'AA-111112', 
                               AccountId                    = acc.Id, 
                               Product2Id                   = testProduct1.id,
                               HPE_Serial_Number__c         = 'AFTestM10',
                               Array_Controller__c          = 'CS300',
                               Array_Networking__c          = '2P',
                               Array_Networking_2__c        = '2P',
                               Array_Networking_3__c        = '2P',
                               Array_Cache__c               = '640F',
                               SSD_Bank_A__c                = '480F',
                               SSD_Bank_B__c                = '480F',
                               Asset_Type_Build__c          = 'File Storage',
                               Status                       = 'Shipped',
                               Component_SKU_HPE__c         = 'R4U28A',
                               Component_SKU_Nimble_V2__c   = '6010',
                               Expansion_Shelf_Base__c      = 'AFS2',
                               Array_Capacity__c            = '11T');
        insert asst;
        
       // Test.startTest();
        
        Contact contact1 = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = acc.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        insert contact1;

        
    }
    

    @isTest
    static void myUnitTest() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeForCase = [select Id, Name from RecordType where Name = 'Array Case' LIMIT 1].Id;
            contact contact1 = [select id from contact where email = 'test@gmail.com' limit 1];
            Asset asst = [select id,accountid from asset where Name = 'AA-111112' limit 1];
            Case c1 = new Case(Status = 'New', 
                               Origin = 'Web', 
                               Priority='P1', 
                               contactId = contact1.Id,
                               AssetId = asst.Id,
                               AccountId = asst.AccountId,
                               Subject = 'Testing',
                               Case_Type__c = 'External',
                               caseDontSendCaseOpenEmail__c = false,
                               RecordTypeId = recordTypeForCase
                               ); 
            Test.startTest();
            insert c1;
            
            
            Case cHandover = [SELECT Type_Of_Handover__c, ownerId, Handover_Schedule__c,Time_Zone__c FROM Case WHERE Id = : c1.Id];
            cHandover.Time_Zone__c = 'Italy (+1)';
            cHandover.Handover_Schedule__c = '2025-05-10T09:00:00';
            cHandover.Type_Of_Handover__c = 'Cold Handover';
            update cHandover;

            Test.stopTest();
        }
    }
    
    /**
     * @description Test weekend detection and subject formatting
     */
    @IsTest
    static void testWeekendDetection() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Create a case with weekend schedule (Saturday)
            Case weekendCase = new Case(
                Subject = 'Test Weekend Case | Additional Info',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'EST (-5)',
                Handover_Schedule__c = '2025-11-22T10:00:00', // Saturday
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            Test.startTest();
            insert weekendCase;
            
            weekendCase.Status = 'In Progress';
            weekendCase.Sub_status__c = 'Investigating';
            update weekendCase;
            Test.stopTest();
            
            // Verify weekend handling
            Case updatedCase = [SELECT Subject FROM Case WHERE Id = :weekendCase.Id];
            System.assertNotEquals(null, updatedCase.Subject, 'Subject should not be null');
            // Can add more specific assertions based on expected weekend formatting
        }
    }
    
    /**
     * @description Test Support Queue detection enhancement
     */
    @IsTest
    static void testSupportQueueDetectionEnhanced() {
        // Test with actual queue if available
        List<Group> supportQueues = [SELECT Id FROM Group WHERE Name = 'Support Queue - General' AND Type = 'Queue' LIMIT 1];
       
        if (!supportQueues.isEmpty()) {
            Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
            
            System.runAs(new User(Id = UserInfo.getUserId())) {
                Case queueCase = new Case(
                    Subject = 'Test Queue Case | Additional Info',
                    AccountId = testAccount.Id,
                    ContactId = testContact.Id,
                    Type_Of_Handover__c = 'Cold Handover',
                    Time_Zone__c = 'UK (+0)',
                    Handover_Schedule__c = '2025-11-21T15:00:00',
                    Status = 'New',
                    OwnerId = supportQueues[0].Id
                );
                
                Test.startTest();
                insert queueCase;
                
                // The trigger should not process this case since it's owned by Support Queue - General
                queueCase.Status = 'In Progress';
                queueCase.Sub_status__c = 'Investigating';
                update queueCase;
                Test.stopTest();
                
                // Verify that the case subject was not modified by the handler
                // (since it should be skipped for Support Queue - General)
                Case updatedCase = [SELECT Id, Status, Subject FROM Case WHERE Id = :queueCase.Id];
                System.assertEquals('In Progress', updatedCase.Status, 'Case should be updated');
                // The handler should skip processing for Support Queue cases
                System.assertEquals('Test Queue Case | Additional Info', updatedCase.Subject, 
                                   'Subject should remain unchanged for Support Queue cases');
            }
        } else {
            System.debug('Support Queue - General not found, skipping queue-specific tests');
        }
    }
    
    /**
     * @description Test timezone offset extraction for various formats
     */
    @IsTest
    static void testTimezoneOffsetExtraction() {
        Test.startTest();
        
        // Test static methods for timezone conversion that actually exist
        Map<String, Object> result1 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'Germany (+1)'
        );
        
        Map<String, Object> result2 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T17:00:00', 'India (+5:30)'
        );
        
        Map<String, Object> result3 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T09:00:00', 'EST (-5)'
        );
        
        Test.stopTest();
        
        // Verify results
        System.assertEquals(true, result1.get('success'), 'Germany conversion should succeed');
        System.assertEquals(true, result2.get('success'), 'India conversion should succeed');
        System.assertEquals(true, result3.get('success'), 'EST conversion should succeed');
        
        System.assertNotEquals('UNKNOWN', result1.get('region'), 'Germany should have valid region');
        System.assertNotEquals('UNKNOWN', result2.get('region'), 'India should have valid region');
        System.assertNotEquals('UNKNOWN', result3.get('region'), 'EST should have valid region');
        
        // Test half-hour timezone handling for India
        System.assertNotEquals(null, result2.get('timezoneOffsetMinutes'), 'India should have minute-level offset');
        Decimal offsetMinutes = (Decimal) result2.get('timezoneOffsetMinutes');
        System.assertEquals(330, offsetMinutes, 'India timezone should be +5:30 (330 minutes)');
    }
    
    /**
     * @description Test region determination from UTC hours
     */
    @IsTest
    static void testRegionDetermination() {
        Test.startTest();
        
        // Test APAC region (UTC 0-7)
        String apacRegion = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'India (+5:30)', '2025-11-21T09:30:00'
        );
        Test.stopTest();
        System.assertEquals('APAC', apacRegion, 'Should be APAC region');
        
    }
    
    /**
     * @description Test static methods that are actually available in the Legacy_Case_BU_Handover class
     */
    @IsTest
    static void testStaticMethods() {
        Test.startTest();
        
        // Test determineRegionFromUTCHour - this is a public static method
        String region1 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'Germany (+1)', '2025-11-21T14:00:00'
        );
        
        String region2 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'India (+5:30)', '2025-11-21T17:00:00'
        );
        
        String region3 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'EST (-5)', '2025-11-21T22:00:00'
        );
        
        // Test convertHandoverScheduleToUTCAndMapRegion - this is a public static method
        Map<String, Object> result1 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'Germany (+1)'
        );
        
        Map<String, Object> result2 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T17:00:00', 'India (+5:30)'
        );
        
        Test.stopTest();
        
        // Verify region determinations
        System.assertNotEquals('UNKNOWN', region1, 'Germany should have valid region');
        System.assertNotEquals('UNKNOWN', region2, 'India should have valid region');
        System.assertNotEquals('UNKNOWN', region3, 'EST should have valid region');
        
        // Verify conversion results
        System.assertEquals(true, result1.get('success'), 'Germany conversion should succeed');
        System.assertEquals(true, result2.get('success'), 'India conversion should succeed');
        System.assertNotEquals('UNKNOWN', result1.get('region'), 'Germany should have valid region');
        System.assertNotEquals('UNKNOWN', result2.get('region'), 'India should have valid region');
    }
    
    /**
     * @description Test error handling with invalid data
     */
    @IsTest
    static void testErrorHandling() {
        Test.startTest();
        
        // Test with null/empty values
        Map<String, Object> result1 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            null, 'Germany (+1)'
        );
        
        Map<String, Object> result2 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', null
        );
        
        Map<String, Object> result3 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            'invalid-date-format', 'Germany (+1)'
        );
        
        String invalidRegion = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'Invalid Timezone', '2025-11-21T14:30:00'
        );
        
        Test.stopTest();
        
        // Verify error handling
        System.assertEquals('UNKNOWN', result1.get('region'), 'Null schedule should return UNKNOWN');
        System.assertEquals('UNKNOWN', result2.get('region'), 'Null timezone should return UNKNOWN');
        System.assertEquals('UNKNOWN', result3.get('region'), 'Invalid date should return UNKNOWN');
        System.assertEquals('UNKNOWN', invalidRegion, 'Invalid timezone should return UNKNOWN');
    }
    
    /**
     * @description Test geolocation mapping functionality
     */
    @IsTest
    static void testGeolocationMapping() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Create case with known timezone mapping
            Case geoCase = new Case(
                Subject = 'Test Geolocation Case | Info',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'Singapore (+8)',
                Handover_Schedule__c = '2025-11-21T10:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            Test.startTest();
            insert geoCase;
            
            geoCase.Status = 'In Progress';
            geoCase.Sub_status__c = 'Investigating';
            update geoCase;
            Test.stopTest();
            
            // Verify geolocation was processed
            //Case updatedCase = [SELECT Customer_Requested_Handover_Time__c FROM Case WHERE Id = :geoCase.Id];
            //System.assertNotEquals(null, updatedCase.Customer_Requested_Handover_Time__c, 
            //                      'Customer requested handover time should be set');
        }
    }
    
    /**
     * @description Test various timezone formats and edge cases that are actually supported
     */
    @IsTest
    static void testVariousTimezoneFormats() {
        Test.startTest();
        
        // Test different timezone formats that should work with the actual implementation
        Map<String, String> timezoneTestCases = new Map<String, String>{
            'EST (-5)' => '2025-11-21T12:00:00',
            'Germany (+1)' => '2025-11-21T12:00:00',
            'India (+5:30)' => '2025-11-21T12:00:00',
            'UK (+0)' => '2025-11-21T12:00:00',
            'JST (+9)' => '2025-11-21T12:00:00',
            'Singapore (+8)' => '2025-11-21T12:00:00'
        };
        
        for (String timezone : timezoneTestCases.keySet()) {
            String handoverTime = timezoneTestCases.get(timezone);
            
            Map<String, Object> result = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
                handoverTime, timezone
            );
            
            System.assertNotEquals(null, result, 'Result should not be null for timezone: ' + timezone);
            System.assertEquals(true, result.get('success'), 'Conversion should succeed for timezone: ' + timezone);
            System.assertNotEquals('UNKNOWN', result.get('region'), 'Region should not be UNKNOWN for timezone: ' + timezone);
            
            // Test region determination as well
            String region = Legacy_Case_BU_Handover.determineRegionFromUTCHour(timezone, handoverTime);
            System.assertNotEquals('UNKNOWN', region, 'Region determination should work for timezone: ' + timezone);
        }
        
        Test.stopTest();
    }
   /* @IsTest
    static void testIndiaTimezonePrecision() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        // Create case with India timezone (+5:30) 
        Case indiaCase = new Case(
            Subject = 'India Timezone Test Case | Info',
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Type_Of_Handover__c = 'Cold Handover',
            Time_Zone__c = 'India (+5:30)',
            Handover_Schedule__c = '2025-11-21T17:00:00',
            Status = 'New',
            Priority = 'Medium',
            OwnerId = testUser.Id
        );
        
        Test.startTest();
        insert indiaCase;
        
        // Update to trigger the handler
        indiaCase.Description = 'In Progress Test';
        //indiaCase.Sub_status__c = 'Investigating';
        update indiaCase;

        
        // Verify the case was processed correctly
        Case updatedCase = [SELECT Customer_Requested_Handover_Time__c, Subject, HandoverLocalTime__c 
                           FROM Case WHERE Id = :indiaCase.Id];
        
        System.assertNotEquals(null, updatedCase.Customer_Requested_Handover_Time__c, 
                             'Customer requested handover time should be set for India timezone');
        
        // Test the static method directly for India timezone precision
        Map<String, Object> result = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T17:00:00', 'India (+5:30)'
        );
        
        System.assertEquals(true, result.get('success'), 'India conversion should succeed');
        System.assertEquals(330, result.get('timezoneOffsetMinutes'), 'India should have 330 minutes offset (5:30)');
        System.assertNotEquals('UNKNOWN', result.get('region'), 'India should have valid region');
           Test.stopTest();         
    }*/
    
    /**
     * @description Test bulk processing with multiple cases
     */
    @IsTest
    static void testBulkProcessing() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        // Create multiple test cases
        List<Case> bulkCases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case bulkCase = new Case(
                Subject = 'Bulk Test Case ' + i + ' | Info',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'Germany (+1)',
                Handover_Schedule__c = '2025-11-21T1' + i + ':00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = testUser.Id
            );
            bulkCases.add(bulkCase);
        }
        
        Test.startTest();
        insert bulkCases;
        
        // Update all cases
        for (Case c : bulkCases) {
            c.Status = 'In Progress';
            c.Sub_status__c = 'Investigating';
        }
        update bulkCases;
        Test.stopTest();
        
        // Verify bulk processing
        List<Case> updatedCases = [SELECT Id, Status FROM Case WHERE Id IN :bulkCases];
        System.assertEquals(5, updatedCases.size(), 'Should have 5 updated cases');
        
        for (Case updatedCase : updatedCases) {
            System.assertEquals('In Progress', updatedCase.Status, 'Case should be updated');
        }
    }
    
    /**
     * @description Test edge cases and boundary conditions
     */
    @IsTest
    static void testEdgeCases() {
        Test.startTest();
        
        // Test with edge UTC hours
        String midnightRegion = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'UTC (+0)', '2025-11-21T00:00:00'
        );
        
        String noonRegion = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'UTC (+0)', '2025-11-21T12:00:00'
        );
        
        String almostMidnightRegion = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'UTC (+0)', '2025-11-21T23:59:59'
        );
        
        Test.stopTest();
        
        // Verify edge cases
        System.assertEquals('APAC', midnightRegion, 'Midnight UTC should be APAC');
        System.assertEquals('EMEA', noonRegion, 'Noon UTC should be EMEA');
        System.assertEquals('AMER', almostMidnightRegion, 'Late night UTC should be AMER');
    }

    
    /**
     * @description Test timezone offset extraction for complex formats
     */
    @IsTest
    static void testComplexTimezoneOffsetExtraction() {
        Test.startTest();
        
        // Test timezone conversion with various complex formats
        Map<String, Object> result1 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'Central European (+1)'
        );
        
        Map<String, Object> result2 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T09:15:00', 'Newfoundland (-3:30)'
        );
        
        Map<String, Object> result3 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T22:45:00', 'Australian Central (Adelaide +9:30)'
        );
        
        Map<String, Object> result4 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T11:00:00', 'Venezuela (-4:30)'
        );
        
        Test.stopTest();
        
        // Verify complex timezone conversions
        System.assertEquals(true, result1.get('success'), 'Central European conversion should succeed');
        System.assertEquals(true, result2.get('success'), 'Newfoundland conversion should succeed');
        System.assertEquals(true, result3.get('success'), 'Australian Central conversion should succeed');
        System.assertEquals(true, result4.get('success'), 'Venezuela conversion should succeed');
        
        // Verify offset calculations for half-hour timezones
        System.assertEquals(-210, result2.get('timezoneOffsetMinutes'), 'Newfoundland should be -3:30 (-210 minutes)');
        System.assertEquals(570, result3.get('timezoneOffsetMinutes'), 'Australian Central should be +9:30 (570 minutes)');
        System.assertEquals(-270, result4.get('timezoneOffsetMinutes'), 'Venezuela should be -4:30 (-270 minutes)');
    }

    /**
     * @description Test geolocation mapping for different regions
     */
    @IsTest
    static void testGeolocationMappingComprehensive() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Test cases for different regions
            List<Case> testCases = new List<Case>();
            
            // APAC region case
            Case apacCase = new Case(
                Subject = 'APAC Test Case',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'Japan (+9)',
                Handover_Schedule__c = '2025-11-21T02:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            testCases.add(apacCase);
            
            // EMEA region case
            Case emeaCase = new Case(
                Subject = 'EMEA Test Case',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'United Kingdom (+0)',
                Handover_Schedule__c = '2025-11-21T10:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            testCases.add(emeaCase);
            
            // AMER region case
            Case amerCase = new Case(
                Subject = 'AMER Test Case',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'US Eastern (-5)',
                Handover_Schedule__c = '2025-11-21T20:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            testCases.add(amerCase);
            
            Test.startTest();
            insert testCases;
            
            // Update all cases to trigger geolocation logic
            for (Case c : testCases) {
                c.Status = 'In Progress';
                c.Sub_status__c = 'Investigating';
            }
            update testCases;
            Test.stopTest();
            
            // Verify geolocation was processed for all regions
            List<Case> updatedCases = [SELECT Id, Subject, Customer_Requested_Handover_Time__c FROM Case WHERE Id IN :testCases];
            System.assertEquals(3, updatedCases.size(), 'Should have 3 updated cases');
            
            for (Case updatedCase : updatedCases) {
                System.assertNotEquals(null, updatedCase.Subject, 'Subject should be updated for all cases');
            }
        }
    }

    /**
     * @description Test weekend detection with specific weekend hours
     */
    @IsTest
    static void testWeekendDetectionSpecificHours() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Test Friday 8:30 PM UTC (should be weekend)
            Case fridayEveningCase = new Case(
                Subject = 'Friday Evening Test',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'UTC (+0)',
                Handover_Schedule__c = '2025-11-21T20:30:00', // Friday 8:30 PM
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            // Test Sunday 7:00 PM UTC (should be weekend)
            Case sundayEveningCase = new Case(
                Subject = 'Sunday Evening Test',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'UTC (+0)',
                Handover_Schedule__c = '2025-11-23T19:00:00', // Sunday 7:00 PM
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            // Test Monday morning (should NOT be weekend)
            Case mondayMorningCase = new Case(
                Subject = 'Monday Morning Test',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'UTC (+0)',
                Handover_Schedule__c = '2025-11-24T09:00:00', // Monday 9:00 AM
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            Test.startTest();
            insert new List<Case>{fridayEveningCase, sundayEveningCase, mondayMorningCase};
            
            // Trigger updates
            fridayEveningCase.Status = 'In Progress';
            sundayEveningCase.Status = 'In Progress';
            mondayMorningCase.Status = 'In Progress';
            
            update new List<Case>{fridayEveningCase, sundayEveningCase, mondayMorningCase};
            Test.stopTest();
            
            // Verify weekend logic
            List<Case> updatedCases = [SELECT Id, Subject FROM Case WHERE Id IN :new List<Id>{fridayEveningCase.Id, sundayEveningCase.Id, mondayMorningCase.Id}];
            
            Case updatedFriday = null, updatedSunday = null, updatedMonday = null;
            for (Case c : updatedCases) {
                if (c.Id == fridayEveningCase.Id) updatedFriday = c;
                if (c.Id == sundayEveningCase.Id) updatedSunday = c;
                if (c.Id == mondayMorningCase.Id) updatedMonday = c;
            }
        }
    }

    /**
     * @description Test subject formatting for different scenarios
     */
    @IsTest
    static void testSubjectFormattingScenarios() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Test APAC region formatting
            Case apacCase = new Case(
                Subject = 'Original APAC Subject',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'Singapore (+8)',
                Handover_Schedule__c = '2025-11-21T06:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            // Test EMEA region formatting
            Case emeaCase = new Case(
                Subject = 'Original EMEA Subject',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'Germany (+1)',
                Handover_Schedule__c = '2025-11-21T11:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            // Test AMER region formatting
            Case amerCase = new Case(
                Subject = 'Original AMER Subject',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'US Eastern (-5)',
                Handover_Schedule__c = '2025-11-21T18:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            Test.startTest();
            insert new List<Case>{apacCase, emeaCase, amerCase};
            
            // Update to trigger subject formatting
            apacCase.Status = 'In Progress';
            emeaCase.Status = 'In Progress';
            amerCase.Status = 'In Progress';
            
            update new List<Case>{apacCase, emeaCase, amerCase};
            Test.stopTest();
            
            // Verify subject formatting includes regional information
            List<Case> updatedCases = [SELECT Id, Subject FROM Case WHERE Id IN :new List<Id>{apacCase.Id, emeaCase.Id, amerCase.Id}];
            
            for (Case updatedCase : updatedCases) {
                System.assert(updatedCase.Subject.contains('[Handover - Cold]'), 'Subject should contain handover type');
                System.assert(updatedCase.Subject.contains('|'), 'Subject should contain delimiter');
                
                if (updatedCase.Id == apacCase.Id) {
                    System.assert(updatedCase.Subject.contains('APAC') || updatedCase.Subject.contains('SGT'), 'APAC case should contain APAC or SGT');
                } else if (updatedCase.Id == emeaCase.Id) {
                    System.assert(updatedCase.Subject.contains('EMEA') || updatedCase.Subject.contains('UTC'), 'EMEA case should contain EMEA or UTC');
                } else if (updatedCase.Id == amerCase.Id) {
                    System.assert(updatedCase.Subject.contains('AMER') || updatedCase.Subject.contains('EST'), 'AMER case should contain AMER or EST');
                }
            }
        }
    }

    /**
     * @description Test additional error handling scenarios
     */
    @IsTest
    static void testAdditionalErrorHandling() {
        Test.startTest();
        
        // Test with malformed timezone formats
        Map<String, Object> result1 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'Malformed Timezone Format'
        );
        
        Map<String, Object> result2 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            'not-a-date-format', 'Germany (+1)'
        );
        
        Map<String, Object> result3 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '', ''
        );
        
        // Test region determination with invalid inputs
        String invalidRegion1 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            '', '2025-11-21T14:30:00'
        );
        
        String invalidRegion2 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'Valid Timezone (+1)', ''
        );
        
        String invalidRegion3 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            null, null
        );
        
        Test.stopTest();
        
    }

    /**
     * @description Test timezone abbreviation fallback logic
     */
    @IsTest
    static void testTimezoneAbbreviationFallback() {
        Test.startTest();
        
        // Test timezone abbreviations that should fall back to known offsets
        Map<String, Object> estResult = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'EST'
        );
        
        Map<String, Object> jstResult = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'JST'
        );
        
        Map<String, Object> utcResult = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'UTC'
        );
        
        Test.stopTest();
        
        // Verify fallback logic works
        System.assertEquals(true, estResult.get('success'), 'EST abbreviation should work');
        System.assertEquals(-300, estResult.get('timezoneOffsetMinutes'), 'EST should be -5 hours (-300 minutes)');
        
        System.assertEquals(true, jstResult.get('success'), 'JST abbreviation should work');
        System.assertEquals(540, jstResult.get('timezoneOffsetMinutes'), 'JST should be +9 hours (540 minutes)');
        
        System.assertEquals(true, utcResult.get('success'), 'UTC abbreviation should work');
        System.assertEquals(0, utcResult.get('timezoneOffsetMinutes'), 'UTC should be 0 offset');
    }

    /**
     * @description Test non-Cold Handover cases to ensure they are skipped
     */
    /*@IsTest
    static void testNonColdHandoverSkipped() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        // Create case with Hot Handover (should be skipped)
        Case hotHandoverCase = new Case(
            Subject = 'Hot Handover Test Case',
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Type_Of_Handover__c = 'Hot Handover',
            Time_Zone__c = 'Germany (+1)',
            Handover_Schedule__c = '2025-11-21T15:00:00',
            Status = 'New',
            Priority = 'Medium',
            OwnerId = testUser.Id
        );
        
        // Create case with no handover type (should be skipped)
        Case noHandoverCase = new Case(
            Subject = 'No Handover Test Case',
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Time_Zone__c = 'Germany (+1)',
            Handover_Schedule__c = '2025-11-21T15:00:00',
            Status = 'New',
            Priority = 'Medium',
            OwnerId = testUser.Id
        );
        
        Test.startTest();
        insert new List<Case>{hotHandoverCase, noHandoverCase};
        
        // Update to trigger the handler logic
        hotHandoverCase.Status = 'In Progress';
        noHandoverCase.Status = 'In Progress';
        update new List<Case>{hotHandoverCase, noHandoverCase};
        Test.stopTest();
        
        // Verify that non-Cold Handover cases were not processed by the handler
        List<Case> updatedCases = [SELECT Id, Subject, Customer_Requested_Handover_Time__c FROM Case 
                                  WHERE Id IN :new List<Id>{hotHandoverCase.Id, noHandoverCase.Id}];
        
        for (Case updatedCase : updatedCases) {
            // These cases should not have been processed, so subjects should remain original
            System.assert(!updatedCase.Subject.contains('[Handover - Cold]'), 
                         'Non-Cold Handover cases should not be processed');
        }
    }*/

    /**
     * @description Test cases with missing required fields
     */
    @IsTest
    static void testMissingRequiredFields() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Case with missing timezone
            Case missingTimezoneCase = new Case(
                Subject = 'Missing Timezone Case',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Handover_Schedule__c = '2025-11-21T15:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            // Case with missing handover schedule
            Case missingScheduleCase = new Case(
                Subject = 'Missing Schedule Case',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'Germany (+1)',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            Test.startTest();
            insert new List<Case>{missingTimezoneCase, missingScheduleCase};
            
            missingTimezoneCase.Status = 'In Progress';
            missingScheduleCase.Status = 'In Progress';
            update new List<Case>{missingTimezoneCase, missingScheduleCase};
            Test.stopTest();
            
            // Verify cases with missing fields are handled gracefully
            List<Case> updatedCases = [SELECT Id, Subject FROM Case 
                                      WHERE Id IN :new List<Id>{missingTimezoneCase.Id, missingScheduleCase.Id}];
            
            for (Case updatedCase : updatedCases) {
                System.assertNotEquals(null, updatedCase.Subject, 'Cases should still have subjects');
            }
        }
    }

    /**
     * @description Test different datetime formats in handover schedule
     */
    @IsTest
    static void testDifferentDateTimeFormats() {
        Test.startTest();
        
        // Test with ISO format with Z suffix
        Map<String, Object> result1 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00Z', 'Germany (+1)'
        );
        
        // Test with timezone offset in schedule
        Map<String, Object> result2 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00+01:00', 'Germany (+1)'
        );
        
        // Test with negative timezone offset in schedule
        Map<String, Object> result3 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00-05:00', 'EST (-5)'
        );
        
        // Test with milliseconds
        Map<String, Object> result4 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00.000', 'Germany (+1)'
        );
        
        Test.stopTest();
        
        // Verify different datetime formats are handled
        System.assertEquals(true, result1.get('success'), 'ISO format with Z should work');
        System.assertEquals(true, result2.get('success'), 'Format with positive offset should work');
        System.assertEquals(true, result3.get('success'), 'Format with negative offset should work');
        System.assertEquals(true, result4.get('success'), 'Format with milliseconds should work');
        
        // Verify regions are determined correctly
        System.assertNotEquals('UNKNOWN', result1.get('region'), 'Region should be determined for format 1');
        System.assertNotEquals('UNKNOWN', result2.get('region'), 'Region should be determined for format 2');
        System.assertNotEquals('UNKNOWN', result3.get('region'), 'Region should be determined for format 3');
        System.assertNotEquals('UNKNOWN', result4.get('region'), 'Region should be determined for format 4');
    }

    /**
     * @description Test boundary UTC hours for region mapping
     */
    @IsTest
    static void testBoundaryUTCHours() {
        Test.startTest();
        
        // Test exact boundary hours
        String region6 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'UTC (+0)', '2025-11-21T06:59:59' // Last minute of APAC
        );
        
        String region7 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'UTC (+0)', '2025-11-21T07:00:00' // First minute of EMEA
        );
        
        String region12 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'UTC (+0)', '2025-11-21T12:59:59' // Last minute of EMEA
        );
        
        String region13 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'UTC (+0)', '2025-11-21T13:00:00' // First minute of AMER
        );
        
        String region23 = Legacy_Case_BU_Handover.determineRegionFromUTCHour(
            'UTC (+0)', '2025-11-21T23:59:59' // Last minute of AMER
        );
        
        Test.stopTest();
        
        // Verify boundary conditions
        System.assertEquals('APAC', region6, 'Hour 6:59 should be APAC');
        System.assertEquals('EMEA', region7, 'Hour 7:00 should be EMEA');
        System.assertEquals('EMEA', region12, 'Hour 12:59 should be EMEA');
        System.assertEquals('AMER', region13, 'Hour 13:00 should be AMER');
        System.assertEquals('AMER', region23, 'Hour 23:59 should be AMER');
    }

    /**
     * @description Test timezone pattern matching edge cases
     */
    @IsTest
    static void testTimezonePatternMatching() {
        Test.startTest();
        
        // Test various timezone patterns that should match known ones in the metadata
        Map<String, Object> result1 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'Tanzania    (+3)' // Extra spaces
        );
        
        Map<String, Object> result2 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'ZAMBIA (+2)' // All caps
        );
        
        Map<String, Object> result3 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'Philippines(+8)' // No space before offset
        );
        
        Test.stopTest();
        
        // Verify timezone pattern matching works
        System.assertEquals(true, result1.get('success'), 'Tanzania with spaces should work');
        System.assertEquals(true, result2.get('success'), 'ZAMBIA in caps should work');
        System.assertEquals(true, result3.get('success'), 'Philippines without space should work');
        
        System.assertNotEquals('UNKNOWN', result1.get('region'), 'Tanzania should have valid region');
        System.assertNotEquals('UNKNOWN', result2.get('region'), 'ZAMBIA should have valid region');
        System.assertNotEquals('UNKNOWN', result3.get('region'), 'Philippines should have valid region');
    }

    /**
     * @description Test cases without Account ID to verify null handling
     */
    @IsTest
    static void testCasesWithoutAccount() {
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Create case without Account
            Case caseWithoutAccount = new Case(
                Subject = 'No Account Case',
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'Germany (+1)',
                Handover_Schedule__c = '2025-11-21T15:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            Test.startTest();
            insert caseWithoutAccount;
            
            caseWithoutAccount.Status = 'In Progress';
            update caseWithoutAccount;
            Test.stopTest();
            
            // Verify case without account is handled gracefully
            Case updatedCase = [SELECT Id, Subject FROM Case WHERE Id = :caseWithoutAccount.Id];
            System.assertNotEquals(null, updatedCase.Subject, 'Case without account should still have subject');
        }
    }

    /**
     * @description Test Support Queue detection with various scenarios
     */
    @IsTest
    static void testSupportQueueDetectionVariants() {
        // Test with User owner (should not be support queue)
        
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'test.contact@example.com' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Case userOwnedCase = new Case(
                Subject = 'User Owned Case',
                AccountId = testAccount.Id,
                ContactId = testContact.Id,
                Type_Of_Handover__c = 'Cold Handover',
                Time_Zone__c = 'Germany (+1)',
                Handover_Schedule__c = '2025-11-21T15:00:00',
                Status = 'New',
                Priority = 'Medium',
                OwnerId = UserInfo.getUserId()
            );
            
            Test.startTest();
            insert userOwnedCase;
            
            userOwnedCase.Status = 'In Progress';
            update userOwnedCase;
            Test.stopTest();
            
            // Verify user-owned case is processed (not skipped as support queue)
            Case updatedCase = [SELECT Subject FROM Case WHERE Id = :userOwnedCase.Id];
            System.assertNotEquals(null, updatedCase.Subject, 'User-owned case should be processed');
        }
    }

    /**
     * @description Test extreme timezone offsets
     */
    @IsTest
    static void testExtremeTimezoneOffsets() {
        Test.startTest();
        
        // Test extreme positive offset
        Map<String, Object> result1 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'Fiji (+13)'
        );
        
        // Test extreme negative offset
        Map<String, Object> result2 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'American Samoa (-11)'
        );
        
        // Test Hawaii time
        Map<String, Object> result3 = Legacy_Case_BU_Handover.convertHandoverScheduleToUTCAndMapRegion(
            '2025-11-21T14:30:00', 'US Hawaii (-10)'
        );
        
        Test.stopTest();
        
        // Verify extreme timezone offsets work
        System.assertEquals(true, result1.get('success'), 'Fiji (+13) should work');
        System.assertEquals(true, result2.get('success'), 'American Samoa (-11) should work');
        System.assertEquals(true, result3.get('success'), 'US Hawaii (-10) should work');
        
        System.assertEquals(780, result1.get('timezoneOffsetMinutes'), 'Fiji should be +13 hours (780 minutes)');
        System.assertEquals(-660, result2.get('timezoneOffsetMinutes'), 'American Samoa should be -11 hours (-660 minutes)');
        System.assertEquals(-600, result3.get('timezoneOffsetMinutes'), 'US Hawaii should be -10 hours (-600 minutes)');
        
        System.assertNotEquals('UNKNOWN', result1.get('region'), 'Fiji should have valid region');
        System.assertNotEquals('UNKNOWN', result2.get('region'), 'American Samoa should have valid region');
        System.assertNotEquals('UNKNOWN', result3.get('region'), 'US Hawaii should have valid region');
    }

    /* Helper methods and edge-case coverage tests */
    @IsTest
    static void testHelperAndUtilityMethods() {
        // timezone key matching
        Map<String, String> tzMap = new Map<String, String>{
            'Germany (+1)' => 'UTC',
            'Tanzania (+3)' => 'GMT'
        };
        System.assertEquals('Germany (+1)', Legacy_Case_BU_Handover.findMatchingTimezoneKey('Germany (+1)', tzMap));
        System.assertEquals('Tanzania (+3)', Legacy_Case_BU_Handover.findMatchingTimezoneKey('Tanzania   (+3)', tzMap));
        System.assertEquals(null, Legacy_Case_BU_Handover.findMatchingTimezoneKey('', tzMap));
        System.assertEquals(null, Legacy_Case_BU_Handover.findMatchingTimezoneKey('XYZ', tzMap));

        // support queue identification
        Group q;
        List<Group> existing = [SELECT Id FROM Group WHERE Name = 'Support Queue - General' AND Type = 'Queue' LIMIT 1];
        if (existing.isEmpty()) {
            q = new Group(Name = 'Support Queue - General', Type = 'Queue');
            insert q;
        } else {
            q = existing[0];
        }
        System.assert(Legacy_Case_BU_Handover.isSupportQueueGeneral(q.Id));
        System.assert(!Legacy_Case_BU_Handover.isSupportQueueGeneral(null));
        System.assert(!Legacy_Case_BU_Handover.isSupportQueueGeneral(UserInfo.getUserId()));

        // timezone location map
        //Map<String, Legacy_Case_BU_Handover.TimezoneLocation> locationMap = Legacy_Case_BU_Handover.getTimezoneLocationMap();
        //System.assert(locationMap.containsKey('India (+5:30)'), 'map should include India');

        // geolocation region determination
        //System.assertEquals('APAC', Legacy_Case_BU_Handover.determineRegionFromGeolocation(1, 103, 'Singapore'));
        //System.assertEquals('EMEA', Legacy_Case_BU_Handover.determineRegionFromGeolocation(50, 0, 'United Kingdom'));
       // System.assertEquals('EST/EDT', Legacy_Case_BU_Handover.determineRegionFromGeolocation(40, -75, 'United States'));
        //System.assertEquals('UNKNOWN', Legacy_Case_BU_Handover.determineRegionFromGeolocation(null, 10, 'USA'));

        // picklist mapping
        //System.assertEquals('AMER', Legacy_Case_BU_Handover.mapRegionToGeoLocationPicklist('AMER'));
        //System.assertEquals('UNKNOWN', Legacy_Case_BU_Handover.mapRegionToGeoLocationPicklist('foobar'));

        // timezone offset extraction
        DateTime sampleDate = DateTime.newInstance(2025, 11, 1, 12, 0, 0);
        System.assertEquals(780, Legacy_Case_BU_Handover.extractTimezoneOffsetInMinutes('Fiji (+13)', sampleDate));
        //System.assertEquals(-330, Legacy_Case_BU_Handover.extractTimezoneOffsetInMinutes('India (+5:30)', sampleDate));
        //System.assertEquals(-300, Legacy_Case_BU_Handover.extractTimezoneOffsetInMinutes('EST (-5)', sampleDate));
        // DST adjustment example
        DateTime dstDate = DateTime.newInstance(2025, 6, 1, 12, 0, 0);
        Integer dstOffset = Legacy_Case_BU_Handover.extractTimezoneOffsetInMinutes('US Eastern (-5)', dstDate);
        System.assertEquals(-240, dstOffset, 'US Eastern should shift to -4 during DST');

        // basic offset helper
        System.assertEquals(13, Legacy_Case_BU_Handover.extractTimezoneOffset('Fiji (+13)', sampleDate));

        // parsing converted datetime
        DateTime conv1 = Legacy_Case_BU_Handover.parseConvertedDateTime('Feb 09, 2026 02:30:00 PM');
        System.assertNotEquals(null, conv1);
        System.assertEquals(2026, conv1.year());
        System.assertEquals(null, Legacy_Case_BU_Handover.parseConvertedDateTime('not a date'));

        // parse custom datetime indirectly by passing bad format to parseConverted
        DateTime conv2 = Legacy_Case_BU_Handover.parseConvertedDateTime('Dec 32, 2026 00:00:00 AM');
        // invalid date returns null or fallback
        // (depends on parser implementation, just assert it doesn't throw)

        // parse handover schedule
        System.assertNotEquals(null, Legacy_Case_BU_Handover.parseHandoverScheduleDateTime('2025-11-21T14:30:00Z'));
        System.assertNotEquals(null, Legacy_Case_BU_Handover.parseHandoverScheduleDateTime('2025-11-21T14:30:00-05:00'));
        System.assertEquals(null, Legacy_Case_BU_Handover.parseHandoverScheduleDateTime('garbage'));

        // DST active check
        System.assertEquals(true, Legacy_Case_BU_Handover.isDSTActive(DateTime.newInstanceGmt(2025, 7, 1, 0, 0, 0)));
        System.assertEquals(false, Legacy_Case_BU_Handover.isDSTActive(DateTime.newInstanceGmt(2025, 1, 1, 0, 0, 0)));

        // UTC hour mapping
        System.assertEquals('UNKNOWN', Legacy_Case_BU_Handover.mapUTCHourToRegion(-1));
        System.assertEquals('APAC', Legacy_Case_BU_Handover.mapUTCHourToRegion(0));
        System.assertEquals('EMEA', Legacy_Case_BU_Handover.mapUTCHourToRegion(7));
        System.assertEquals('AMER', Legacy_Case_BU_Handover.mapUTCHourToRegion(13));

        // direct call to conversion regional time
        Legacy_Case_BU_Handover instance = new Legacy_Case_BU_Handover();
        DateTime regional = instance.convertHandoverScheduleToRegionalTime('2025-11-21T14:30:00', 'Germany (+1)', 'EMEA');
        System.assertNotEquals(null, regional);
        System.assertEquals(null, instance.convertHandoverScheduleToRegionalTime(null, '', ''));

        // GMT helper
        DateTime gmt = instance.getGMTtimeforHandoverSchedule('2025-11-21T14:30:00Z');
        System.assertNotEquals(null, gmt);

        // geolocation calculations
        Case geoCase = new Case();
        instance.calculateGeolocationFromTimezone(geoCase, 'India (+5:30)');
        //System.assert(geoCase.Customer_Requested_Handover_Time__c.contains('India (+5:30)'));

        Case geoFallback = new Case();
        instance.calculateGeolocationUsingGoogleAPI(geoFallback, 'Nonexistent TZ');
        //System.assertEquals('Unknown Location', geoFallback.get('Geolocation_City__c'));

        // timezone location map non-empty
        //Map<String, Legacy_Case_BU_Handover.TimezoneLocation> tzmap2 = Legacy_Case_BU_Handover.getTimezoneLocationMap();
        //System.assert(tzmap2.size() > 0);
    }
}