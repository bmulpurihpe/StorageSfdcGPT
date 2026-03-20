@IsTest
public class ProcessBuilderQuickExitTest {
    
    @IsTest
    public static void testQuickExit() {
        // Test the QuickExit method
        Test.startTest();
        ProcessBuilderQuickExit.QuickExit();
        Test.stopTest();
        
        // Since the method doesn't do anything, we just verify it executes without exception
        // The fact that we reach this point means the method executed successfully
        System.assert(true, 'QuickExit method executed successfully');
    }
    
    @IsTest
    public static void testQuickExitMultipleCalls() {
        // Test multiple calls to ensure consistency
        Test.startTest();
        ProcessBuilderQuickExit.QuickExit();
        ProcessBuilderQuickExit.QuickExit();
        ProcessBuilderQuickExit.QuickExit();
        Test.stopTest();
        
        // Verify multiple calls work without issues
        System.assert(true, 'Multiple QuickExit calls executed successfully');
    }
}