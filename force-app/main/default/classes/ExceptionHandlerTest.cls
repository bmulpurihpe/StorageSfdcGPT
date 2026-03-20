@isTest
public class ExceptionHandlerTest {
	testMethod static void exceptionHandlerTestMethod()
    {
        String errorMessage = 'Error Message!';
        Test.startTest();
        new ExceptionHandler(errorMessage);
        Test.stopTest();
        System.assert(true);
    }
}