trigger EmailCaseComments on CaseComment (after insert) {
    //Added by Vishnu on 25th Aug 20, to run the trigger based on the custom setting value.
    Boolean runTheCaseCommentTrigger = ActivateTrigger__c.getInstance().EmailCaseCommentsTrigger__c;
    
    if (runTheCaseCommentTrigger)
    {
        string user = UserInfo.getUserId();
        User u = [SELECT Email, Name, ContactId from User where Id = :user];
        boolean isPortalUser = false;
        
        if (u.ContactId != null) { isPortalUser = true; }
        
        //if (u.Email == 'dbocskai@nimblestorage.com') { //sandbox
        if (u.Email == 'supportforce@nimblestorage.com' || isPortalUser == true) {  //production
            CaseComment[] comments = Trigger.new;
            CaseUtility.VALIDATE_OWNER_TRIGGER = false;
            CaseUtility.CASETRIGGER_FLAG = false;
            
            for(CaseComment cc : comments) {
                
                if (cc.IsPublished == true) {
                    //string templateId = '00X80000001RZpEEAW'; //sandbox
                    //string templateId = 'XXXXXXXXXXXXXXXXXX'; //test
                    
                    string templateId = '00X80000001v7FDEAY'; //production
                    CaseCommentMailerUtils.sendMail(comments, templateId, isPortalUser);
                }
            }
        }
    }
}