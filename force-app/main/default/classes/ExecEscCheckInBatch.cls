global class ExecEscCheckInBatch implements Database.Batchable <SObject>
{
    // query all of the Open Executive Escalations that are within one half hour (30 minutes) of Next Check-In Time
    String query='SELECT Id, Name, Hours_Until_Next_Escalation_Check_In__c, Escalation_Closure_Status__c, caseEscalationTypeDefinition__c, Escalation_Check_In_Status__c, Case_Owner__c, Case_Owner__r.Email, caseEscalationCase__c,Current_Escalation_Owner__c, Current_Escalation_Owner__r.Email, Escalation_Check_In_Cadence__c, Static_Escalation_Owner__c, Static_Escalation_Owner__r.Email, Static_Escalation_Owner_Override__c, Static_Escalation_Owner_Override__r.Email, Next_Escalation_Check_In__c, Escalation_PSM__c, Escalation_PSM__r.Email FROM caseEscalation__c WHERE Escalation_Closure_Status__c=\'Open\' AND Hours_Until_Next_Escalation_Check_In__c <= 0.5 AND caseEscalationTypeDefinition__r.Name=\'Executive Escalation\'';
    
    
    
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('query:  '+ query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<caseEscalation__c> execEscList)
    {
        Messaging.Email[] emailList = new Messaging.Email[0];
        
        for(caseEscalation__c currExecEsc : execEscList)
        {
            System.debug(currExecEsc.Name + ' - Hours_Until_Next_Escalation_Check_In__c: '+ currExecEsc.Hours_Until_Next_Escalation_Check_In__c);
            
            if(currExecEsc.Hours_Until_Next_Escalation_Check_In__c <= 0.5)
            {
                if(currExecEsc.Hours_Until_Next_Escalation_Check_In__c >= 0.0)
                    System.debug('Sending Reminder Notification for ' + currExecEsc.Name);
                else
                    System.debug('Sending Overdue Notification for ' + currExecEsc.Name);
                
                Messaging.SingleEmailMessage newEmail = prepareReminderNotifications(currExecEsc);
                
                if(newEmail != null)
                {
                    emailList.add(newEmail);
                }
                
            }
            
        }
        
        if(emailList.size() > 0)
        {
            try
            {
                // Send the email you have created.
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailList });  
                Messaging.sendEmail(emailList, false);
            }
            catch(DmlException e)
            {
                System.debug('ERROR Sending Email(s): ' + e); 
            }
            
        }
        else
        {
            System.debug('*** NO EMAILS TO SEND AT THIS TIME ***');
        }
        
        
    }
    
    public void finish(Database.BatchableContext BC)
    {   
        if(!Test.isRunningTest())
        {
            ExecEscCheckInBatch nextExecEscBatch = new ExecEscCheckInBatch();
            System.scheduleBatch(nextExecEscBatch, 'Executive Escalation Check-In Monitoring', Integer.valueOf(System.Label.Exec_Esc_Batch_Delay_in_Minutes));
        }
    
    }
    
    public Messaging.SingleEmailMessage prepareReminderNotifications(caseEscalation__c execEscRecord)
    {
               
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage returnMail = null;
        
        //List <Messaging.SingleEmailMessage> mailList = new Messaging.SingleEmailMessage();

        List<String> toAddresses = new List<String>(); 
        List<String> ccAddresses = new List<String>(); 
  
        // Add test email addresses
        //toAddresses.add('lawrence.wasser@hpe.com');
        //ccAddresses.add('lawrence.j.wasser@gmail.com');
       
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('donotreply@salesforce.com');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('ExecEsc Automation');
     
        // Set to True if you want to BCC yourself on the email.
        //mail.setBccSender(false);
        //
        
        Integer days = (Integer) (execEscRecord.Hours_Until_Next_Escalation_Check_In__c / 24);
        Integer hours = (Integer) (execEscRecord.Hours_Until_Next_Escalation_Check_In__c - (days * 24));
        Integer minutes = (Integer) ((execEscRecord.Hours_Until_Next_Escalation_Check_In__c - (days * 24)- hours) * 60); 
        
        if(execEscRecord.Hours_Until_Next_Escalation_Check_In__c < 0)
        {
            days *= -1;
            hours *= -1;
            minutes *= -1;
        }

        system.debug('execEscRecord.Hours_Until_Next_Escalation_Check_In__c: '+ execEscRecord.Hours_Until_Next_Escalation_Check_In__c);
        System.debug('days: ' + days);
        System.debug('hrs: ' + hours);
        System.debug('mins: ' + minutes);

        if(execEscRecord.Hours_Until_Next_Escalation_Check_In__c > 0)
        {            
            // Specify the subject line for your email address.
            mail.setSubject('CHECK-IN REMINDER for Exec Esc: ' + execEscRecord.Name);
            
            //mail.setHtmlBody('<h3 style="color:blue;">REMINDER</h3> CHECK-IN for Executive Escalation: <a href="https://nimblestorage--stage.my.salesforce.com/a2y80000000mG46AAE">ESC-99999</a> is due in ~'+ (execEscRecord.Hours_Until_Next_Escalation_Check_In__c * 60) + ' minutes');
   
            mail.setHtmlBody('<h3 style="color:red;">REMINDER</h3> CHECK-IN for Executive Escalation: <a href="https://nimblestorage.my.salesforce.com/'+execEscRecord.Id+'">'+ execEscRecord.Name +'</a> is due in:   <span style="color:blue;">'+ days+'</span> days  <span style="color:blue;">' + hours + '</span> hrs  <span style="color:blue;">' + minutes + '</span> mins');

            /*if(execEscRecord.Case_Owner__c != null)
            {
                System.debug('execEscRecord.Case_Owner__c: ' + execEscRecord.Case_Owner__c);
                toAddresses.add(execEscRecord.Case_Owner__r.Email);
            } */
           
            if(execEscRecord.Current_Escalation_Owner__c != null)
            {
                System.debug('execEscRecord.Current_Escalation_Owner__c: ' + execEscRecord.Current_Escalation_Owner__c);
                toAddresses.add(execEscRecord.Current_Escalation_Owner__r.Email);
            }
            
            if((execEscRecord.Static_Escalation_Owner__c != null) && (execEscRecord.Static_Escalation_Owner__c != execEscRecord.Current_Escalation_Owner__c))
            {
                System.debug('execEscRecord.Static_Escalation_Owner__c: ' + execEscRecord.Static_Escalation_Owner__c); 
                toAddresses.add(execEscRecord.Static_Escalation_Owner__r.Email);
            }
            
            if(execEscRecord.Static_Escalation_Owner_Override__c != null)
            {
                System.debug('execEscRecord.Static_Escalation_Owner_Override__c: ' + execEscRecord.Static_Escalation_Owner_Override__c);
                toAddresses.add(execEscRecord.Static_Escalation_Owner_Override__r.Email);
            }
            
            if((execEscRecord.Escalation_PSM__c != null) && (execEscRecord.Escalation_PSM__c != execEscRecord.Static_Escalation_Owner__c))
            {     
                System.debug('execEscRecord.Escalation_PSM__c: ' + execEscRecord.Escalation_PSM__c);  
                toAddresses.add(execEscRecord.Escalation_PSM__r.Email);
            }
            
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);

        }
        else
        {
            System.debug('DUMPING execEscRecord:  ' + execEscRecord);
            // Specify the subject line for your email address.
            mail.setSubject('CHECK-IN OVERDUE for Exec Esc: ' + execEscRecord.Name);

            mail.setHtmlBody('<h3 style="color:red;">OVERDUE</h3> CHECK-IN for Executive Escalation: <a href="https://nimblestorage.my.salesforce.com/'+execEscRecord.Id+'">'+ execEscRecord.Name +'</a> is overdue by:   <span style="color:red;">'+ days+'</span> days  <span style="color:red;">' + hours + '</span> hrs  <span style="color:red;">' + minutes + '</span> mins');

            /* if(execEscRecord.Case_Owner__c != null)
            {
                System.debug('execEscRecord.Case_Owner__c: ' + execEscRecord.Case_Owner__c);
                toAddresses.add(execEscRecord.Case_Owner__r.Email);
            } */
           
            if(execEscRecord.Current_Escalation_Owner__c != null)
            {
                System.debug('execEscRecord.Current_Escalation_Owner__c: ' + execEscRecord.Current_Escalation_Owner__c);
                toAddresses.add(execEscRecord.Current_Escalation_Owner__r.Email);
            }
            
            if(execEscRecord.Static_Escalation_Owner__c != null)
            {
                System.debug('execEscRecord.Static_Escalation_Owner__c: ' + execEscRecord.Static_Escalation_Owner__c); 
                toAddresses.add(execEscRecord.Static_Escalation_Owner__r.Email);
            }
            
            if(execEscRecord.Static_Escalation_Owner_Override__c != null)
            {
                System.debug('execEscRecord.Static_Escalation_Owner_Override__c: ' + execEscRecord.Static_Escalation_Owner_Override__c);
                toAddresses.add(execEscRecord.Static_Escalation_Owner_Override__r.Email);
            }
            
            if(execEscRecord.Escalation_PSM__c != null)
            {     
                System.debug('execEscRecord.Escalation_PSM__c: ' + execEscRecord.Escalation_PSM__c);  
                toAddresses.add(execEscRecord.Escalation_PSM__r.Email);
            }
            
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            
            System.debug('toAddresses: ' + toAddresses);
            System.debug('ccAddresses: ' + ccAddresses);

        }
        
        if(mail.getToAddresses().size() > 0)
        {
            returnMail = mail;
            System.debug('mail.getToAddresses(): ' + mail.getToAddresses());
        }
        else
        {
            returnMail = null;
            System.debug('NOT Sending Email - EMPTY ToAddresses(): ' + mail.getToAddresses());
        }
  
        return returnMail;
    }
}