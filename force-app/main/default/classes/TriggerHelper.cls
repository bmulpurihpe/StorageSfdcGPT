/**
 * Class Name: TriggerHelper
 * Created By: Jana Reddy
 * Created Date: 11/6/2023 
 *
 * Description:
 * This Salesforce Apex class is a helper class that provides methods to manage the execution state of contact triggers.
 * It includes methods for checking if a contact trigger is currently executing and for setting the trigger execution state.
 * 
 * Usage:
 * - Use this class to control the execution state of contact triggers to prevent recursion and manage trigger execution flow.
 */
public class TriggerHelper {
    private static Boolean isContactTriggerExecuting = false;

    /**
     * @return Boolean indicating if the contact trigger is executing.
     */
    public static Boolean isExecutingContactTrigger() {
        return isContactTriggerExecuting;
    }

    /**
     * @param isExecuting Boolean value to set the trigger execution state.
     */
    public static void setContactTriggerFlag(Boolean isExecuting) {
        isContactTriggerExecuting = isExecuting;
    }
}