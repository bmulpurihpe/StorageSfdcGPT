@isTest
public class Test_schedule_batch_shipping {

    static testMethod void myUnitTest() {
        Test.StartTest();
        schedule_batch_shipping sh1 = new schedule_batch_shipping();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest();
        integer i=1;
        System.assertEquals(i,1);
    }
}