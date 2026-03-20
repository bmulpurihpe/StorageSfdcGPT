/*
 *  Queueable Apex class to perform actions On Contact And Lead asynchronously
 */ 
public class VTaskTriggerQueueable implements Queueable{
    private list<Task> taskList;
    private map<id,Task> taskMap;
	private boolean isDelete = false;
    
    // Contructor call,Parameter Variables gets initialized
    public VTaskTriggerQueueable(List<Task> queuedTaskList, Map<id,Task> queuedTaskMap, boolean isInDeleteTrigger){
        this.taskList = queuedTaskList;
        this.taskMap = queuedTaskMap;
        this.isDelete = isInDeleteTrigger;
    }
    // Executes the logic asynchronously.
    public void execute(System.QueueableContext qc) {  
        try{
            activityCountOnContactAndLead.calculateTaskActivityCounters(taskList, taskMap);
        }catch(Exception e){
            //	If an exception occurs again, execute the same method once again.
            activityCountOnContactAndLead.calculateTaskActivityCounters(taskList, taskMap);
        }
        //	If it is not delete, call populateLeadStatusandInfo 
        if(this.isDelete == false){
			activityCountOnContactAndLead.populateLeadStatusandInfo(taskList, taskMap);
        }
    } 
}