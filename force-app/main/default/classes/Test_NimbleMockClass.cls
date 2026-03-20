@isTest
public class Test_NimbleMockClass {

	static testMethod void nmtest1() {
		Test.startTest(); 
        NimbleMockClass n1= new NimbleMockClass();
        n1.NSMethod();
        Test.stopTest(); 
	}

}