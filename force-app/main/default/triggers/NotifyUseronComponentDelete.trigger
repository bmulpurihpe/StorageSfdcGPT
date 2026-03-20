trigger NotifyUseronComponentDelete on Component__c (before Delete) {
    
    Set<ID> compID = new Set<ID>();
    Set<ID> rmaID = new Set<ID>();
    Map<ID,List<RMAv2__c>> mapRMAComponent = new Map<ID,List<RMAv2__c>>();
    Map<ID,Component__c> mapComponent = new Map<ID,Component__c>();
    List<Nimble_Automation_Logs__c> NALogstoInsert= new List<Nimble_Automation_Logs__c>();
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    for (Component__c comp : Trigger.old) {
        compID.add(comp.ID);
        mapComponent.put(comp.ID,comp);
    }
    
    for(RMAv2__c rma : [Select ID,Name,rmaComponentV2__c, rmaComponentV2__r.Name, rmaCaseNumber__c FROM rmav2__c where rmaComponentV2__c in :compID]){
        rmaID.add(rma.ID);
        if(mapRMAComponent.containsKey(rma.rmaComponentV2__c))
            mapRMAComponent.get(rma.rmaComponentV2__c).add(rma);
        else
            mapRMAComponent.put(rma.rmaComponentV2__c,new List<RMAv2__c>{rma});
    }
    system.debug('## compID'+compID); 
    system.debug('## map RMA' +mapRMAComponent);
    if(!mapRMAComponent.isEmpty())
    {
        for(ID comp : compID){
            List<RMAv2__c> relatedRMAs = new List<RMAv2__c>();
            String allRmas = '';
            if(mapRMAComponent.containsKey(comp))
                relatedRMAs= mapRMAComponent.get(comp);
            
            for (RMAv2__c rma : relatedRMAs){
                allRmas += rma.Name + '<br/>';
                // insert the deleted Component details in Nimble_Automation_Logs__c and relate with RMA
                Nimble_Automation_Logs__c NALlogs = new Nimble_Automation_Logs__c();
                NALlogs.NALCase_Number__c = rma.rmaCaseNumber__c;
                NALlogs.NALRMA_Number__c = rma.Id;
                NALlogs.NALlevel__c = 'INFO';
                NALlogs.NALkey__c= 'IsComponentDeleted';
                NALlogs.NALvalue__c = mapComponent.get(comp).Name+'|'+mapComponent.get(comp).componentComponentSN__c+'|'+mapComponent.get(comp).componentServicePartNumber__c;
                NALlogs.NALproccess__c = 'NotifyUseronComponentDelete';
                NALogstoInsert.add(NALlogs);
            }
            system.debug('## NALogstoInsert'+NALogstoInsert);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            system.debug('## getEmailAddresses' + getEmailAddresses());
            if(!getEmailAddresses().isEmpty())
            {
                email.setToAddresses(getEmailAddresses());
                //email.setToAddresses(new String[] {'komathipriya@exafort.com'});
            }
            else
                email.setToAddresses(new String[] {'pradeep.aitha@hpe.com','gabriel.millerd@hpe.com','marie.cardona@hpe.com'});
            
            //email.setToAddresses(new String[] {'komathipriya@exafort.com'});
            email.setSubject('Deleted Component Alert');
            email.setHtmlBody('Hello, <br/><br/> This message is to alert you that the Component named '
                              + relatedRMAs[0].rmaComponentV2__r.Name + ' has been deleted.<br/>' +
                              'Related with below RMAs <br/>' + allRmas);
            system.debug('# Email Body'+email);
            emails.add(email);
        }
    }
    
    
    Messaging.sendEmail(emails);
    if(!NALogstoInsert.Isempty())
    {
        insert NALogstoInsert;
    }
    
    public List<String> getEmailAddresses() {
    List<String> mailToAddresses = new List<String>();
    List<User> users = [SELECT Email FROM User WHERE Id IN (
                          SELECT UserOrGroupId
                          FROM GroupMember
                          WHERE Group.Name = 'Notify User on Component Delete'
                        )];

    for(User u : users)
        mailToAddresses.add(u.email);

    return mailToAddresses;
}
}