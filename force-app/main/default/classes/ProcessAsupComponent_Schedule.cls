/* Purpose: Schedular class to process the asup components daily to 
 * 			create/update the components for an asset
 * Change Log: Created by Pradeep Aitha
 */ 
global class ProcessAsupComponent_Schedule implements Schedulable
{	
   public void execute(SchedulableContext SC) {
      ProcessAsupComponent_Batch pb = new ProcessAsupComponent_Batch(false);
      Database.executeBatch(pb);
   }
}