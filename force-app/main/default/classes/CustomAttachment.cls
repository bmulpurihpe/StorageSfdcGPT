public with sharing class CustomAttachment 
{
	public String RecordId { get; set; }
    public String RecordName { get; set; }
    //public String ParentId { get; set; }

    public CustomAttachment(String recordId, String recordName)
    {
        this.RecordId = recordId;
        this.RecordName = recordName;
    }
}