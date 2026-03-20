public class assetPreventRecursiveV1 {
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