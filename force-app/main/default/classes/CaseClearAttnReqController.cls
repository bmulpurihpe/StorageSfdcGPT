/*
 * Added By Exafort for TS-9315
 * Test Class - CaseClearAttnReqControllerTest
*/
public class CaseClearAttnReqController {
    public string caseCommentBody{get;set;}
    public boolean caseCommentIsPublished{get;set;} 
    public boolean caseCommentIsNotified{get;set;}
    public boolean saveButtonDisable{get;set;}
    public CaseComment caseCommentValues;
    public Case cas{get;set;}
    
    public CaseClearAttnReqController(ApexPages.StandardController controller) {
        saveButtonDisable = false;
        id casId = ApexPages.CurrentPage().getparameters().get('id');
        cas = [Select CaseNumber,Subject,Description,Current_comment_time_spent__c,ownerId,caseAttnReq__c,Status,owner.name,owner.email,
               account.name,asset.SerialNumber,asset.System_Name__c,caseNimbleGroupName__c,priority,Category__c,Origin
               from Case where id =: casId];
        if(cas.caseAttnReq__c == false){
            saveButtonDisable = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Attn Req field does not need to be cleared at this time'));
        }
    }
    
    public PageReference caseClearAttnReq(){
        Id loginUserId = UserInfo.getUserId();
        if(loginUserId == cas.OwnerId && cas.caseAttnReq__c == true){
            PageReference casePage = new PageReference('/'+cas.id);
            casePage.setRedirect(true);
            cas.caseAttnReq__c = false;
            system.debug('status -->  '  + cas.Status);
            update cas;
            return casePage; 
        }
        return null; 
    }
    
    public pageReference saveCaseComment(){
        string convertedComment = caseCommentBody.replaceAll( '\\s+', '');
        system.debug('convertedComment --> ' + convertedComment);
        // Case Comment field should not be null, if null throws error message
        if(convertedComment == null || convertedComment == ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Comment field should not be Null');
            ApexPages.addMessage(msg);
            return null;
        }
        
        // Send email to the case owner when the Attn req flag is cleared
        // Added by Exafort for TS-9980
        
        // Added by Exafort for TS-10117 [isCurrentCaseOwnerUser if condition]
        // Send email only if the owner is user
        if (isCurrentCaseOwnerUser()){
        	sendEmail();    
        }
        
        
        // Insert new comment on the case
        CaseComment caseCommentInsert = new CaseComment();
        system.debug('caseCommentBody --> ' + caseCommentBody);
        caseCommentInsert.CommentBody = caseCommentBody;
        caseCommentInsert.IsPublished = caseCommentIsPublished;
        caseCommentInsert.IsNotificationSelected = caseCommentIsNotified;
        caseCommentInsert.ParentId = cas.id;
        // Added by Exafort for TS-9980
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if(caseCommentIsNotified == TRUE){
            dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
            dmlOpts.EmailHeader.triggerOtherEmail = true;
            dmlOpts.EmailHeader.triggerUserEmail = true;
        }
        database.insert(caseCommentInsert, dmlOpts); 
        // End of TS-9980
        
        case caseUpdate = [Select id,caseAttnReq__c,Current_comment_time_spent__c,status from case where id =: cas.id limit 1];
        
        // Set the "Attn Req" field to false
        if(caseUpdate.caseAttnReq__c){
            caseUpdate.caseAttnReq__c = False;
        }
        
        caseUpdate.Status = cas.Status;
        caseUpdate.Current_comment_time_spent__c = cas.Current_comment_time_spent__c;
        system.debug('status -->  '  + cas.Status);
        update caseUpdate;
        PageReference result = new PageReference('/' + cas.id);
        result.setRedirect(true); 
        return result;
    }
    
    // Added by Exafort for TS-9980
    public void sendEmail(){
        system.debug('Entered to send email');
        // Get the from email Id from the OrgWideEmailAddress
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@nimblestorage.com'];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Get case owner email id
        String ownerEmail = cas.owner.email;
        String[] toAddresses = new String[] {ownerEmail};
            
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
        
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('donotreply@nimblestorage.com');
        mail.setUseSignature(false);
        mail.setSubject('Nimble Case #'+Cas.CaseNumber+ ' Updated: '+Cas.Subject);
        
        mail.setHtmlBody('A new comment has been added to case #' + cas.CaseNumber +' </b> with Nimble Storage. Information about the new comment is listed below.<p>'+
                         'Case Comment: <p/>'+
                         + caseCommentBody + '<p/>');
        
                         /*'Account Name: '+cas.account.name + '<br/>'+
                         'Array SN: '+cas.asset.SerialNumber + '<br/>'+
                         'Array Name: '+cas.asset.System_Name__c + '<br/>'+
                         'Nimble Group Name: '+cas.caseNimbleGroupName__c + '<br/>'+
                         'Case Number: '+cas.CaseNumber + '<br/>'+
                         'Case Priority: '+cas.Priority + '<br/>'+
                         'Case Category: '+cas.Category__c + '<br/>'+
                         'Case Origin: '+cas.Origin + '<br/>'+
                         'Case Owner: '+cas.owner.name + '<p/>'+
                         'Case Subject: '+cas.Subject + '<br/>'+
                         
                         '*********************************************************************************** <br/>'+
                         'CASE REFERENCE NUMBER REQUIRED - DO NOT MODIFY <br/>' +
                         '***********************************************************************************'*/
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    // End of TS-9980
    
    // Added by Exafort for TS-10117 
    boolean isCurrentCaseOwnerUser(){
        Id caseOwnerId = cas.ownerId;
        system.debug('caseOwnerId.getsobjecttype() : ' + caseOwnerId.getsobjecttype());
        if (caseOwnerId != null &&  caseOwnerId.getsobjecttype() == User.getSObjectType()){
            return true;            
        }
        return false;
    }
    // End of TS-10117
}