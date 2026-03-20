public class CaseChangeOwnerOnVirtualQueueController {
    
    public Case cas{get;set;}
    public list<string> selectedRecIds = new list<string>();
    public boolean notificationEmail{get;set;}
    
    // Constructor
    public CaseChangeOwnerOnVirtualQueueController(){
        
        cas = new Case();
        //  String recIds = ApexPages.currentPage().getParameters().get('selectedRecId');
        string recIdsTrimmed = '';
        
        Cookie recId = ApexPages.currentPage().getCookies().get('recIds');
        system.debug('recId==>'+recId.getValue());
        String recIds = recId.getValue(); 
        
        if (recIds != null) {
            recIdsTrimmed = EncodingUtil.urlDecode(recIds, 'UTF-8');
            string removeColan= recIdsTrimmed.remove('"');
            string removeLeftSquare = removeColan.remove('[');
            string removeRightSquare = removeLeftSquare.remove(']');
            
            for(string eachValFromURL:removeRightSquare.split(',')){
                if(!selectedRecIds.contains(eachValFromURL)){
                    selectedRecIds.add(eachValFromURL.trim());
                }
            }
        }
    }
    // Case Owner updation and Send email to case owner.
    public PageReference updateCaseOwner() {
        try{
            list <id> caseIds = new list <id>(); 
            List<Case> caseUpdateList = new List<Case>();
            for(Case c : [SELECT Id,Owner.Email,OwnerId FROM Case WHERE Id =: selectedRecIds ]){
                caseIds.add(c.id);
                c.OwnerId = cas.OwnerId;
                caseUpdateList.add(c);
            }
            system.debug('caseUpdateList : ' + caseUpdateList);
            update caseUpdateList;
            string caseOwnerId = cas.OwnerId;
            boolean userId = caseOwnerId.startsWith('005');
            
            if(notificationEmail){
                
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> ();
                
                // Dummy contact need to use on target value for case or custom objects email template reference.
                Contact con = [select id from contact limit 1];
                
                EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                               from EmailTemplate 
                                               where name = 'Case Alert - Case Assigned to New Owner'];
                
                OrgWideEmailAddress owe = [select Id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'DoNotReply'];
                system.debug('userId : '+userId);
                if(userId){
                    for(Case cas : [Select id,Owner.Email from Case where id in:caseIds]){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(emailTemplate.id);
                        mail.setWhatId(cas.id);
                        mail.setTargetObjectId(con.id);
                        mail.setSaveAsActivity(false);
                        mail.setOrgWideEmailAddressId(owe.id);
                        mail.setToAddresses(new List<String>{cas.Owner.Email});
                        mail.setTreatTargetObjectAsRecipient(false);
                        messages.add(mail);
                    }
                }
                else{
                    List<String> emailAddresses = new List<String>();
                    
                    // Query GroupMembers to get UserIds of members in the Queue
                    List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: caseOwnerId];
                    
                    // Prepare a set of User IDs
                    Set<Id> userIds = new Set<Id>();
                    for (GroupMember member : groupMembers) {
                        userIds.add(member.UserOrGroupId);
                    }
                    
                    // Query Users to get email addresses
                    List<User> users = [SELECT Id, Email FROM User WHERE Id IN :userIds];
                    
                    // Populate the list of email addresses
                    for (User user : users) {
                        emailAddresses.add(user.Email);
                    }
                    for(Case cas : [Select id,Owner.Email from Case where id in:caseIds]){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(emailTemplate.id);
                        mail.setWhatId(cas.id);
                        mail.setTargetObjectId(con.id);
                        mail.setSaveAsActivity(false);
                        mail.setOrgWideEmailAddressId(owe.id);
                        mail.setToAddresses(emailAddresses);
                        mail.setTreatTargetObjectAsRecipient(false);
                        messages.add(mail);
                    }
                    
                }
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
            // String previousPageUrl = ApexPages.currentPage().getPreviousPageUrl();
            // 
            PageReference virtualQueuePage = Page.VirtualQueue;
            virtualQueuePage.setRedirect(true);
            return virtualQueuePage;
        }
        catch (Exception ex) {
            system.debug('Error updating record: ' + ex.getMessage());
        } 
        return null;
    }
}