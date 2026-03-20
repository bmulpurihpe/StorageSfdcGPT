/*Change log: added a group dimension to the user context as it is not communicated out of the box.
*/
@isTest
Public class CustomContextHIPTest{
    // NOTE: Divided this test class up into separate test methods because
    //       everything in one method was overriding SOQL governor limits.
    
    static testMethod void test_01()
    { 
        CustomContextHIP context = new CustomContextHIP();
        
        test.startTest();
        Map<String, Object> data = new Map<String, Object>();
        Map<String, Object> result = context.getCustomContext(data);
        System.assert(result.containsKey('groupName'));
        test.stopTest();
    } 
}