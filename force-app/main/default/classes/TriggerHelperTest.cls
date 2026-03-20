/**
 * Test Class Name: TriggerHelperTest
 * Created By: Jana Reddy
 * Created Date: 11/6/2023 
 *
 * Description:
 * This Salesforce Apex test class is designed to test the functionality of the TriggerHelper class.
 * It verifies the behavior of the isExecutingContactTrigger and setContactTriggerFlag methods.
 * 
 * Usage:
 * - Use this test class to validate the functionality of the TriggerHelper class.
 */
@isTest
private class TriggerHelperTest {
    @isTest
    static void testIsExecutingContactTrigger() {
        System.assertEquals(false, TriggerHelper.isExecutingContactTrigger());
        TriggerHelper.setContactTriggerFlag(true);
        System.assertEquals(true, TriggerHelper.isExecutingContactTrigger());
    }

    @isTest
    static void testSetContactTriggerFlag() {
        TriggerHelper.setContactTriggerFlag(true);
        System.assertEquals(true, TriggerHelper.isExecutingContactTrigger());
        TriggerHelper.setContactTriggerFlag(false);
        System.assertEquals(false, TriggerHelper.isExecutingContactTrigger());
    }
}