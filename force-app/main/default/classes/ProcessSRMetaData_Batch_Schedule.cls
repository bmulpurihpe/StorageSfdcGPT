/* Purpose: Schedular class to process the components to 
 * 			create/update srmetadata
 * Change Log: Created by Pradeep Aitha
 */ 
public class ProcessSRMetaData_Batch_Schedule implements Schedulable
{
     public void execute(SchedulableContext SC) {
      ProcessSRMetaData_Batch srb = new ProcessSRMetaData_Batch();
      Database.executeBatch(srb);
   }

}