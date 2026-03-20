public with sharing class TrainingMessage 
{
    public String RecordId { get; set; }
    public String Message { get; set; }
    public String ExpiryDate { get; set; }
    public String Division { get; set; }
    public Boolean ForAllDivisions { get; set; }

    public TrainingMessage(){}
    public TrainingMessage(String recordId, String message, String expiryDate, String division, Boolean forAllDivisions)
    {
        this.RecordId = recordId;
        this.Message = message;
        this.ExpiryDate = expiryDate;
        this.Division = division;
        this.ForAllDivisions = forAllDivisions;
    }
}