//******************************************************************************************************//
//  Version      Date           Author      Comments                                                   //
//  0.1          2014-07-02     Sravan      Contribution data creator batch schedular class            //
//******************************************************************************************************//
global class CntrbnMdl_TSECreatorSchedular implements Schedulable
{   
    global void execute(SchedulableContext sc)
    {
        CntrbnMdl_TSECreator TSE = new CntrbnMdl_TSECreator();
        if(Test.isRunningTest())
            ID batchprocessid = Database.executeBatch(TSE);
        else            
        	ID batchprocessid1 = Database.executeBatch(TSE,1);
    }
}