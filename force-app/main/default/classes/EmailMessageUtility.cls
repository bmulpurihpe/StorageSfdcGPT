public class EmailMessageUtility {
    private static boolean run = true;
    //This Method is used in Legacy_EmailMessage_AI_OpenCase class for recursion stop.
    public static boolean runOnce(){
        
        if(run){
            run = false;
            return true;
        }else{
            return run;
        }
    }
}