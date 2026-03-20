/*==========================================>
* visualforce page : EACCheckrecusrive
* Author: Exafort(Vishnu)
* Date:  10/17/2018 
* */
public class EACCheckrecusrive {
    public static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}