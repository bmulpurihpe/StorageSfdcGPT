public class ScheduledExecEscCheckInBatch implements Schedulable{

    public void execute(SchedulableContext sc)
    {
        ExecEscCheckInBatch execEscBatch = new ExecEscCheckInBatch();
        
        Database.executebatch(execEscBatch);
    }
}