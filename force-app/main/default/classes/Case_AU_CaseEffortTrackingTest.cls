/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 09-16-2025
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   09-16-2025   Nagalaxmi Telkar   Initial Version
**/
@isTest
public class Case_AU_CaseEffortTrackingTest {
    @testSetup
    static void setup() {
        // Create Account and Contact
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id);
        insert con;
    }

    @isTest
    static void testNegativeOrZeroTimeSpent() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Array Case' LIMIT 1];
        Case c = new Case(Status = 'New', Origin = 'Web', Priority = 'P1', Subject = 'Test', RecordTypeId = rt.Id);
        insert c;
        c.Current_comment_time_spent__c = 0;
        Test.startTest();
        try {
            update c;
            System.assert(false, 'Should have thrown an error for zero time spent');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('You cannot enter Zero or a Negative Value'));
        }
        Test.stopTest();
    }

    @isTest
    static void testPositiveTimeWithActivity() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Array Case' LIMIT 1];
        Case c = new Case(Status = 'New', Origin = 'Web', Priority = 'P1', Subject = 'Test', RecordTypeId = rt.Id);
        insert c;
        c.Current_comment_time_spent__c = 10;
        c.Current_comment_activity__c = 'General Case Work';
        Test.startTest();
        update c;
        Test.stopTest();
        // No error expected
    }

    @isTest
    static void testPositiveTimeWithoutActivity() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Array Case' LIMIT 1];
        Case c = new Case(Status = 'New', Origin = 'Web', Priority = 'P1', Subject = 'Test', RecordTypeId = rt.Id);
        insert c;
        c.Current_comment_time_spent__c = 5;
        c.Current_comment_activity__c = null;
        Test.startTest();
        update c;
        Test.stopTest();
        // No error expected
    }

    @isTest
    static void testOwnerChange() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Array Case' LIMIT 1];
        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Case c = new Case(Status = 'New', Origin = 'Web', Priority = 'P1', Subject = 'Test', RecordTypeId = rt.Id);
        insert c;
        Id oldOwner = c.OwnerId;
        c.OwnerId = u.Id;
        c.Current_comment_time_spent__c = 10;
        c.Current_comment_activity__c = 'General Case Work';
        Test.startTest();
        update c;
        Test.stopTest();
        // No error expected
    }
}