/*
* Created by Exafort for the JIRA TS-10419 & TS-10486
* This is the controller of VF Page "rmaPDFGeneratorPage"
* Logic - When the RMA is Submitted add attachment to the related RMA and send email to the related case contact
* Test Class - rmaPDFGeneratorControllerTest
*/ 

public class RmaPDFGeneratorController {
    // Variable to hold the RMA record
    public RMAv2__c rmaRecord {get; set;}
    
    // Constructor to initialize the controller
    public RmaPDFGeneratorController(){
        Id RMAid = ApexPages.currentPage().getParameters().get('id');
        rmaRecord = [SELECT Id, Name, rmaCaseNumber__c,rmaCaseNumber__r.casenumber,rmaDiskShelfAsset__c,rmaDetailedReason__c,rmaCaseNumber__r.Priority,
                     rmaAssetSla__c, rmaQuantity__c, rmaShipmentPhone__c, rmaShipmentEmail__c,rmaDiskShelfAsset__r.Asset_Product_Code__c,rmaDiskShelfAsset__r.name,
                     rmaFailedPart__c,rmaDateTimeOpened__c,rmaSubstitutionPart__c,rmaCaseNumber__r.contact.name,rmaShipmentAddressDetail__c,
                     rmaCaseNumber__r.contact.phone,rmaCaseNumber__r.contact.email,rmaCaseNumber__r.Account.name,rmaAssetNrdIsInEffect__c,CE_to_bring_RMA_part__c,
                     rmaDiskShelfAsset__r.HPE_Serial_Number__c,rmaComponentV2__r.componentType__c,Full_Shipment_Address__c,
                     rmaEstimated_Delivery_Date_Time__c,rmaOnsite_Task__c,rmaShipmentAccountName__c,rmaShipmentAttn__c,rmaGeneralFailureDetails__c,rmaOnsite_Fault_Location__c,
                     rmaCaseNumber__r.Asset.Asset_Product_Code__c,rmaCaseNumber__r.Asset.HPE_Serial_Number__c, rmaCaseNumber__r.Asset.name
                     FROM RMAv2__c
                     WHERE Id = :RMAid
                     LIMIT 1];
    }
    
    public List<String> getRmaOnsiteTaskLines() {
        List<String> lines = new List<String>();
        if (rmaRecord.rmaOnsite_Task__c != null) {
            // Split by newline characters and add lines to the list, including empty ones
            lines.addAll(rmaRecord.rmaOnsite_Task__c.split('(\r\n|\r|\n)'));
        }
        return lines;
    }
    
    public List<String> getRmaFaultLines() {
        List<String> Faultlines = new List<String>();
        if (rmaRecord.rmaOnsite_Fault_Location__c != null) {
            // Split by newline characters and add lines to the list, including empty ones
            Faultlines.addAll(rmaRecord.rmaOnsite_Fault_Location__c.split('(\r\n|\r|\n)'));
        }
        return Faultlines;
    }
    
    // Added by Exafort for SFDC-627
    public String getAssetProductCode() {
        if(rmaRecord.rmaDiskShelfAsset__c != null && rmaRecord.rmaDiskShelfAsset__r.Asset_Product_Code__c != null) {
            return rmaRecord.rmaDiskShelfAsset__r.Asset_Product_Code__c;
        } else if(rmaRecord.rmaCaseNumber__c != null && rmaRecord.rmaCaseNumber__r.Asset.Asset_Product_Code__c != null) {
            return rmaRecord.rmaCaseNumber__r.Asset.Asset_Product_Code__c;
        } else {
            return ''; 
        }
    }
    
    public String getSerialNumber() {
        if (rmaRecord.rmaDiskShelfAsset__c != null && rmaRecord.rmaDiskShelfAsset__r.HPE_Serial_Number__c != null) {
            return rmaRecord.rmaDiskShelfAsset__r.HPE_Serial_Number__c;
        } else if(rmaRecord.rmaCaseNumber__c != null && rmaRecord.rmaCaseNumber__r.Asset.HPE_Serial_Number__c != null){
            return rmaRecord.rmaCaseNumber__r.Asset.HPE_Serial_Number__c;
        } else {
            return ''; 
        }
    }
    
    public String getDiskShelfAssetName() {
        if (rmaRecord.rmaDiskShelfAsset__c != null && rmaRecord.rmaDiskShelfAsset__r.name != null) {
            return rmaRecord.rmaDiskShelfAsset__r.name;
        } else if(rmaRecord.rmaCaseNumber__c != null && rmaRecord.rmaCaseNumber__r.Asset.name != null) {
            return rmaRecord.rmaCaseNumber__r.Asset.name;
        } else {
            return ''; 
        }
    }
    
    // End of SFDC-627
    
    
    // Method to be executed asynchronously for processing RMA records
    @future(callout=true)
    public static void processIds(List<Id> idList){
        
        List<Attachment> lstAttachmentRma = new List<Attachment>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        //Added by Exafort for SFDC-467
        List<rmav2__c> rmaUpdateList = new List<rmav2__c>();
        List<rmav2__c> rmaErrorList = new List<rmav2__c>();
        try{
            Map<id,RMAv2__c> rmaV2RecordList = new Map<id,RMAv2__c>([Select id,name,rmaCaseNumber__r.contact.email,lastmodifiedby.name,rmaOnsite_Task__c,
                                                                     rmaCaseNumber__r.casenumber,rmaCaseNumber__r.Account.name,rmaDiskShelfAsset__r.HPE_Serial_Number__c,
                                                                     rmaCaseNumber__r.owner.email,rmaCaseNumber__r.Asset.HPE_Serial_Number__c
                                                                     from RMAv2__c where id =: idList]);
            OrgWideEmailAddress owe = [select Id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Support Case'];
            
            // Process the RMA's that are submitted.
            for(Id rmaId: idList){
                PageReference page = new PageReference('/apex/rmaPDFGeneratorPage?id=' + rmaId);
                string rmaName = rmaV2RecordList.get(rmaId).name;
                string contactEmail = rmaV2RecordList.get(rmaId).rmaCaseNumber__r.contact.email;
                string rmaRecordId =  rmaV2RecordList.get(rmaId).Id;
                string rmaCaseNumber = rmaV2RecordList.get(rmaId).rmaCaseNumber__r.casenumber;
                string rmaAssetSN = rmaV2RecordList.get(rmaId).rmaDiskShelfAsset__r.HPE_Serial_Number__c;
                Id caseId = rmaV2RecordList.get(rmaId).rmaCaseNumber__c;
                
                string ownerEmail = rmaV2RecordList.get(rmaId).rmaCaseNumber__r.owner.email;
                system.debug('ownerEmail : ' + ownerEmail);
                
                // Added by exafort for SFDC-627
                if(rmaAssetSN == null){
                    rmaAssetSN = rmaV2RecordList.get(rmaId).rmaCaseNumber__r.Asset.HPE_Serial_Number__c;
                }
                // End of SFDC-627
                
                Blob pdf;
                String name = '';
                String descr = 'RMA PDF';
                //pdf = page.getContentAsPDF();
                
                if (Test.isRunningTest()){
                    pdf = Blob.valueOf('Mock PDF Content'); // Mock PDF Blob for testing
                }else{
                    pdf = page.getContentAsPDF();
                }
                
                // Add Attachment on the RMA
                Attachment att = new Attachment();
                att.Body = pdf;
                att.Name = rmaName + '.pdf';
                att.IsPrivate = false;
                att.ParentId = rmaId;
                att.Description = descr;
                lstAttachmentRma.add(att);
                
                string toEmailAddress = System.Label.China_Storage_Support_Email_Address;
                //String toEmailAddress = UserInfo.getUserEmail();
                
                // Send email
                if(toEmailAddress != null){
                    rmaPDFGeneratorControllerSendEmailCheck.runOnce();
                    EmailTemplate template = [SELECT Id, Name, Body FROM EmailTemplate WHERE Name = 'RMA China Global Account Email Alert' LIMIT 1];
                    Id templateId = template.Id;
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, null, rmaRecordId);
                    email.setWhatId(caseId);
                    email.setOrgWideEmailAddressId(owe.id);
                    email.setSubject('RMA/Work Order Request (' + rmaCaseNumber + ' - ' + rmaAssetSN + ' - ' + rmaName + ') – Nimble H3C [Onsite]');
                    email.setSaveAsActivity(true);
                    email.setToAddresses(new String[]{toEmailAddress});
                    
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName(rmaName + '.pdf');
                    attachment.setBody(pdf);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment}); 
                    
                    emails.add(email);
                    // Added by Exafort for SFDC-467
                    markRMAStatusAsSubmitted(rmaId, rmaUpdateList);
                }
            }
            
            // Send email
            if(emails.size() > 0){
                Messaging.sendEmail(emails);
            }
            
            // Insert Attachment to the RMA
            if(lstAttachmentRma.size() > 0 ){
                insert lstAttachmentRma;
            }
            
            // Added by Exafort for SFDC-467
            if(rmaUpdateList.size() > 0){
                update rmaUpdateList;
            }
            // End of SFDC-467
        }catch (Exception e) {
            for (Id rmaId : idList) {
                rmaErrorList.add(new RMAv2__c(Id = rmaId, RMA_Processing_Error__c = 'RMA PDF Generation Error : ' + e.getMessage()));
            }
        }
        
        if (!rmaErrorList.isEmpty()) {
            update rmaErrorList;
        }
    }
    
    // Added by Exafort for SFDC-467
    private static void markRMAStatusAsSubmitted(id rmaId, List<rmav2__c> rmaUpdateList){
        rmav2__c rmaUpdate = new rmav2__c();
        rmaUpdate.Id = rmaId;
        rmaUpdate.rmaOutgoingShipmentStatus__c = 'SUBMITTED-CGA: China GA RMA Submitted';
        rmaUpdateList.add(rmaUpdate);
    }
    // End of SFDC-467
}