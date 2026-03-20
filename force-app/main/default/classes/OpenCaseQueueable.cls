/*
 *  Queueable Apex class to "update First Customer Contact" on case object asynchronously
 */ 
public class OpenCaseQueueable implements Queueable{
    private EmailMessage[] emailMessages;
    private DateTime currentDateTime;
    
    // Contructor call,Parameter Variables gets initialized
    public OpenCaseQueueable(EmailMessage[] emailMessages,DateTime invokedDateTime) {
        this.emailMessages = emailMessages;
        this.currentDateTime = invokedDateTime;
    }
    
    // Executes the logic asynchronously
    public void execute(System.QueueableContext qc) {
        System.debug('currentDateTime = '+currentDateTime);
        List<case> updateFirstCustomerContact = new List<case>();
        List<string> emailIds = new List<string>();
        Set<string> userEmailname = new Set<string>();
        list<id> parentIds = new list<id>();
        // Added by Exafort for SFDC-1696
        // To check the outgoing Email is Welcome Email or actual reply to the Case.
        Map<id,EmailMessage> mapEmailMessage = new Map<id,EmailMessage>(); 
        Set<String> newCaseEmailTemplate = new Set<String>();
        for (Case_PSM_Alerts__mdt alert : [SELECT Id,DeveloperName,Body_Template_Id__c,ArcusTemplate__c FROM Case_PSM_Alerts__mdt  where DeveloperName ='PSM_New_Case_Notification']) {
            if(alert.Body_Template_Id__c != null)
                newCaseEmailTemplate.add(alert.Body_Template_Id__c);
            if(alert.ArcusTemplate__c != null)
                newCaseEmailTemplate.add(alert.ArcusTemplate__c);
        }
        Set<String> emailSubject = new Set<String>();
        for(EmailTemplate emailTemp : [SELECT Id, Subject FROM EmailTemplate WHERE Id in :newCaseEmailTemplate]){
            emailSubject.add(emailTemp.Subject);
        }
        //END	SFDC-1696
        system.debug('emailSubject --> ##' + emailSubject);
        // Get the sent emails parent id and from address
        for (EmailMessage emailMessageToProcess : emailMessages){
            emailIds.add(emailMessageToProcess.FromAddress);
            parentIds.add(emailMessageToProcess.ParentId);
            mapEmailMessage.put(emailMessageToProcess.ParentId,emailMessageToProcess);
            system.debug('emailIds --> ' + emailIds);
        }
        
        // Get if the email is sent from a user
        for (User userToProcess : [select id,name,Email from user where Email =: emailIds]){
            userEmailname.add(userToProcess.email);
            system.debug('userEmailname --> ' + userEmailname);
        }
        // Added by Exafort for SFDC-1696
        // This logic is to check if the From address is not an Email addres of any exsting user but its part of the OrgWideEmailAddress
        if(userEmailname.isEmpty() || emailIds.size() != userEmailname.size()){
            for (OrgWideEmailAddress emailToProcess : [SELECT Address FROM OrgWideEmailAddress where Address =: emailIds]){             
                userEmailname.add(emailToProcess.Address);
                system.debug('SFDC-1696 userEmailname --> ' + userEmailname);
            }
        }
        //End	SFDC-1696
        List<id> parentIdUpdateList = new List<id>(); 
        for (EmailMessage emailMessageToProcess : emailMessages){            
            // Condition to check that the parent id is not null AND the Email is sent by a user
            if(emailMessageToProcess.ParentId != null && emailMessageToProcess.ParentId.getsobjecttype() == Case.sObjectType && 
               userEmailname.contains(emailMessageToProcess.FromAddress)){
                   parentIdUpdateList.add(emailMessageToProcess.ParentId);
               }            
        }
        
        if(parentIdUpdateList.size() > 0){
            for(Case acase: [Select Id,Subject,CaseNumber,First_Customer_Contact__c,CreatedDate FROM Case Where Id =: parentIdUpdateList and First_Customer_Contact__c = null and caseAttnReq__c != True]){ 
                //SFDC-1696 - Check for the Welcome Email Template Subject and bypass the First_Customer_Contact__c update
                boolean isFirstCustomerContactUpdate = True; 
                for(string templateSubject: emailSubject){                    
                    if (String.isNotBlank(templateSubject)) {
                        String expectedSubject = templateSubject.replace('{!Case.CaseNumber}', acase.CaseNumber);
                        expectedSubject = expectedSubject.replace('{!Case.Subject}', acase.Subject);
                        system.debug('## 1696 expectedSubject ' + expectedSubject);
                        system.debug('## 1696 mapEmailMessage Subject ' + mapEmailMessage.get(acase.Id).Subject);
                        if(mapEmailMessage.containsKey(acase.Id) && mapEmailMessage.get(acase.Id).Subject == expectedSubject)
                            isFirstCustomerContactUpdate = False;
                    }
                }
                if (isFirstCustomerContactUpdate == True) {  
                    acase.First_Customer_Contact__c = currentDateTime;
                    updateFirstCustomerContact.add(acase);
                }
            }
        }
        
        // Update case first customer contact field
        if (updateFirstCustomerContact.size() > 0){
            system.debug('First Customer contact updated');
            update updateFirstCustomerContact; 
        }
    }    
}