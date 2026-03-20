/*                              <<<< === Apex Class to handle trigger recursive occurrence=== >>>>
    =============================================================================================================
        Name                    : NEC_CheckRecusrive
        Description             : Apex Class to handle NEC_DefinitionSortOrder_Update trigger recursive occurrence
        Created Date            : 11th april 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
public class NEC_CheckRecusrive {
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