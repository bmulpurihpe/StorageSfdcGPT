public with sharing class TaskTemplateController 
{
    public TrainingMessage__c Message { get; set; }
    public TaskTemplate__c Template { get; set; }
    public Attachment TaskAttachment { get; set; }

    public TaskTemplateController()
    {
        TaskAttachment = new Attachment();
    }

    public String DivisionOptions
    {
        get
        {
            JSONGenerator gen = JSON.createGenerator(false);     
            gen.writeStartArray();
            Schema.DescribeFieldResult result = TaskTemplate__c.Division__c.getDescribe();
            for(Schema.PicklistEntry entry : result.getPicklistValues())        
            {
                gen.writeStartObject();
                gen.writeStringField('Value', entry.getValue());
                gen.writeStringField('Label', entry.getLabel());
                gen.writeEndObject();
            }      
            gen.writeStartObject();
            gen.writeStringField('Value', 'All');
            gen.writeStringField('Label', 'All Tasks');
            gen.writeEndObject();
            gen.writeEndArray();            
            return gen.getAsString();
        }
    }
    public String Messages
    {
        get
        {            
            List<TrainingMessage> messages = new List<TrainingMessage>();
            String expiryDate;
            for(TrainingMessage__c msg : [select Id, Message__c, ExpiryDate__c, Division__c, ForAllDivisions__c 
                                          from TrainingMessage__c order by Division__c, ExpiryDate__c])
            {
                expiryDate = msg.ExpiryDate__c == null ? '' : msg.ExpiryDate__c.format();
                messages.add(new TrainingMessage(msg.Id, msg.Message__c, expiryDate, msg.Division__c, msg.ForAllDivisions__c));
            }            
            return JSON.serialize(messages);
        }
    }

    public String TaskTemplates
    {
        get
        {
            List<TaskTemplate> templates = new List<TaskTemplate>();
            String effectiveDate;
            for(TaskTemplate__c template : [select Id, Category__c, Description__c, Division__c, 
                                                ForAllDivisions__c, Effective_Date__c, Subject__c, Tab__c,
                                                ExistingUsersWillReceiveThisTask__c, Sort__c, SeatTime__c,
                                                (select Id, Name from Attachments order by CreatedDate desc) 
                                            from TaskTemplate__c
                                            order by Tab__c, Sort__c NULLS FIRST, Category__c, Division__c])
            {
                List<CustomAttachment> attachments = new List<CustomAttachment>();
                for(Attachment att : template.Attachments)
                {
                    attachments.add(new CustomAttachment(att.Id, att.Name));
                }
                effectiveDate = template.Effective_Date__c == null ? '' : template.Effective_Date__c.format();                
                templates.add(new TaskTemplate(template.Id,
                                               template.Category__c,
                                               template.Description__c,
                                               template.Division__c,
                                               template.ForAllDivisions__c,
                                               effectiveDate,
                                               template.Subject__c,
                                               template.Tab__c,
                                               template.ExistingUsersWillReceiveThisTask__c,
                                               template.SeatTime__c,
                                               template.Sort__c,
                                               attachments));
            }
            return JSON.serialize(templates);
        }
    }

    @RemoteAction
    public static String saveMessage(TrainingMessage message)
    {
        TrainingMessage__c messageRecord = new TrainingMessage__c();
        messageRecord.Division__c = message.Division;
        messageRecord.ForAllDivisions__c = message.ForAllDivisions;
        messageRecord.Message__c = message.Message;
        messageRecord.ExpiryDate__c = Date.parse(message.ExpiryDate);
        if(String.isNotBlank(message.RecordId))
        {
            messageRecord.Id = message.RecordId;
        }
        upsert messageRecord;
        return messageRecord.Id;
    }    


    @RemoteAction
    public static String saveTemplate(TaskTemplate template)
    {        
        TaskTemplate__c templateRecord = new TaskTemplate__c();
        templateRecord.Division__c = template.Division;
        templaterecord.ForAllDivisions__c  = template.ForAllDivisions;
        templateRecord.Subject__c = template.Subject;
        templateRecord.Description__c = template.Description;
        templateRecord.Category__c = template.Category;
        templateRecord.Tab__c = template.Tab;
        templateRecord.Effective_Date__c = Date.parse(template.EffectiveDate);
        templaterecord.SeatTime__c = template.SeatTime;
        templateRecord.ExistingUsersWillReceiveThisTask__c = template.ExistingUsersWillReceiveThisTask;
        if(String.isNotBlank(template.RecordId))
        {
            templateRecord.Id = template.RecordId;
        }
        upsert templateRecord;
        return templateRecord.Id;
    }

    @RemoteAction
    public static String uploadFile(String parentId, String fileName, String body, String attachmentId)
    {
        Attachment attachment = getAttachment(attachmentId);
        if(attachment.Id == null)
        {
            attachment.Body = EncodingUtil.base64Decode(body);
            attachment.ParentId = parentId;
            attachment.Name = fileName;
        }
        else
        {
            String newBody = EncodingUtil.base64Encode(attachment.Body) + body;
            attachment.Body = EncodingUtil.base64Decode(newBody);
        }

        upsert attachment;
        return attachment.Id;
    }

    private static Attachment getAttachment(String attachmentId)
    {
        Attachment attachment = new Attachment();
        if(attachmentId != '')
        {
            List<Attachment> attachments = [select Id, Name, ParentId, Body from Attachment where Id = :attachmentId];
            if(attachments.size() > 0)
            {
                attachment = attachments[0];
            }
        }
        return attachment;
    }

    @RemoteAction
    public static void deleteRecord(String recordId)
    {
        Database.delete(recordId);
    }

    // Change the order of task template
    @RemoteAction
    public static void changeSortOrder(String templateId, Decimal sortOrder)
    {
        TaskTemplate__c template = [select Sort__c from TaskTemplate__c where Id = :templateId];
        template.Sort__c = sortOrder;
        update template;
    }
}