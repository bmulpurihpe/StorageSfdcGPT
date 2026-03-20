/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 06-07-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   06-07-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger OpenCase on EmailMessage (after insert,before insert){
public with sharing class Legacy_EmailMessage_AI_OpenCase implements TriggerAction.AfterInsert{
    public void afterInsert(List<EmailMessage> newList){
    EmailMessage[] emailMessages = newList;
    // String emailLoop1 = System.Label.EmailLoopProtection ;
    //String emailLoop2 = System.Label.EmailLoopProtection2;
    //system.debug(emailLoop1);
    /** Added by Exafort(vishnu) 
*  Purpose - To restrict case comments with subject  Delivery delayed: 
*  */
    
    //if (Trigger.isAfter && Trigger.isInsert){
        new EmailMessageHandler().reopenCase(emailMessages);
        
        // Added by Exafort for TS-10320
        List<EmailMessage> emailList = new List<EmailMessage>();
        
        for(EmailMessage emailToProcess : newList){
            system.debug('Inspecting email = ' + emailToProcess.Id + ', CreatedById = ' + emailToProcess.CreatedById);
            
            /*  
                Only outgoing emails should be considered
                Update "First_Customer_Contact__c" field only it is not Automation users "Support Automation / Nimble Support"
                OpenCaseQueueable class need not be excuted for the automation users                
            */           
            if(emailToProcess.Incoming == false){
                if(!(emailToProcess.CreatedById == Id.valueOf(CaseUtility.SUPPORT_AUTOMATION_USER_ID) || emailToProcess.CreatedById == Id.valueOf(CaseUtility.NIMBLE_SUPPORT_USER_ID))){
                    system.debug('Adding email ' + emailToProcess.Id + ' as a candidate for updating the First Customer contact');
                    emailList.add(emailToProcess);
                }
            }
        }
        
        if(emailList.size() > 0){
            //  Call Handler
            //new EmailMessageHandler().updateFirstCustomerContactOnCase(emailList);
            //  rmaPDFGeneratorControllerSendEmailCheck.runOnce() added by Exafort for TS-10419
            if(rmaPDFGeneratorControllerSendEmailCheck.runOnce()){
                if(EmailMessageUtility.runOnce()){
                    new EmailMessageHandler().updateFirstCustomerContactOnCase(emailList);
                }
            }
        }
        // End of TS-10320        
    }
}