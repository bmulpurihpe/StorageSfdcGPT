/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : Nagalaxmi Telkar 
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-27-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger EmailCaseCommentsToOwner on CaseComment (after insert) {
public with sharing class Legacy_CaseComment_AI_EmalCasComenToOwnr implements TriggerAction.AfterInsert{
    public void afterInsert(List<CaseComment> newList){
    //Added by Vishnu on 19th Jun 20, to run the trigger based on the custom setting value.
    Boolean runTheTrigger = ActivateTrigger__c.getInstance().EmailCaseCommentsToOwnerTrigger__c;
    
    if (runTheTrigger)
    {
        string user = UserInfo.getUserId();
        User u = [SELECT Email, Name, ContactId from User where Id = :user];
        boolean isPortalUser = false;
        
        if (u.ContactId != null || user == System.Label.DCEIntegration_APIUser) 
        { 
            isPortalUser = true; 
        }
        //  if(u.Email == 'dbocskai@nimblestorage.com') { //sandbox
        
        if(u.Email == 'supportforce@nimblestorage.com' || isPortalUser == true) {  //production
            CaseComment[] comments = newList;
            
            for(CaseComment cc : comments) {
                CaseCommentMailerToOwnerUtils.sendMail(comments, u.Name, isPortalUser);
            }
        }
    }
}
}