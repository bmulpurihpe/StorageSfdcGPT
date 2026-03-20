public with sharing class TaskTemplate 
{
    public String RecordId { get; set; }
    public String Category { get; set; }
    public String Description { get; set; }
    public String Division { get; set; }
    public Boolean ForAllDivisions { get; set; }
    public String EffectiveDate { get; set; }
    public String Subject { get; set; }
    public String Tab { get; set; }
    public Boolean ExistingUsersWillReceiveThisTask { get; set; }
    public String SeatTime { get; set; }
    public Decimal SortOrder { get; set; }
    public List<CustomAttachment> Attachments { get; set; }

    public TaskTemplate() {}
    public TaskTemplate(String recordId, 
                        String category, 
                        String des, 
                        String division, 
                        Boolean forAllDivisions, 
                        String effectiveDate, 
                        String subject, 
                        String tab, 
                        Boolean applyToExistingUser, 
                        String seatTime,
                        Decimal sortOrder,
                        List<CustomAttachment> attachments)
    {
        this.RecordId = recordId;
        this.Category = category;
        this.Description = des;
        this.Division = division;
        this.ForAllDivisions = forAllDivisions;
        this.EffectiveDate = effectiveDate;
        this.Subject = subject;
        this.Tab = tab;
        this.ExistingUsersWillReceiveThisTask = applyToExistingUser;
        this.SeatTime = seatTime;
        this.SortOrder = sortOrder;
        this.Attachments = attachments;
    }    
}