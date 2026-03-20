/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 08-01-2022
 * @last modified by  : Nagalaxmi Telkar 
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   08-01-2022   Nagalaxmi Telkar   Initial Version
**/
public class CaseManagerPageController {
    private ApexPages.StandardController controller;
    public Case thisCase{get;set;}
    public String caseNumber{get;set;}
    public String recordId ;
   
    public CaseManagerPageController (ApexPages.StandardController controller) {
        this.controller = controller;
        thisCase = (Case) controller.getRecord(); 
        recordId = String.valueOf(thisCase.Id);
        
        caseNumber = [SELECT CaseNumber FROM Case WHERE Id =:thisCase.Id LIMIT 1 ].CaseNumber;
    }
    
    public String getRecordId(){
        return recordId ;
    }
    
    public PageReference getRecordPage(){
         return new PageReference('/' + recordId);
    }

    public Boolean getShowCollaborationLinks() {
        Id currentUserProfileId = UserInfo.getProfileId();
        String profileName = [Select Id, Name from Profile Where Id =: currentUserProfileId].Name;
        String profilesToRestrictStr = Label.CaseManagerLinkRestriction;
        List<String> profilesToRestrictList = profilesToRestrictStr.split(',');
        if(profilesToRestrictList.contains(profileName)) {
            return false;
        }
        return true;
    }
}