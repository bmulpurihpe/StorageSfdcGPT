public with sharing class TrainingTask 
{
    public String RecordId { get; private set; }
    public String Subject { get; private set; }
    public String Description { get; private set; }
    public String Status { get; private set; }
    public Boolean IsClosed { get; private set; }
    public String Filter { get; private set; }
    public String ActivityDate { get; private set; }
    public Boolean IsDue { get; private set; }
    public String Tab { get; private set; }
    public String Category { get; private set; }
    public String AttachmentName { get; private set; }
    public String AttachmentURL { get; private set; }
    public String SeatTime { get; private set; }

    public TrainingTask(String recordId, 
                        String subject, 
                        String des, 
                        String status, 
                        Boolean isClosed, 
                        String filter, 
                        String activityDate, 
                        Boolean isDue, 
                        String tab, 
                        String category, 
                        String attachmentName, 
                        String attachmentURL,
                        String seatTime)
    {
        this.RecordId = recordId;
        this.Subject = subject;
        this.Description = des;
        this.Status = status;
        this.IsClosed = isClosed;
        this.Filter = filter;
        this.ActivityDate = activityDate;
        this.IsDue = isDue;
        this.Tab = tab;
        this.Category = category;
        this.AttachmentName = attachmentName;
        this.AttachmentURL = attachmentURL;
        this.SeatTime = seatTime;
    }
}