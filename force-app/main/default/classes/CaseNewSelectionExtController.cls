/* Purpose: Extension controller for CaseNewSelectionPage to redirect 
* either to ncv or array case page based on record type selection
* Change Log: changed on 30th August 2019 By Vishnu For TS-5907
*/
public class CaseNewSelectionExtController {
    
    String acctId, contId, asstId, acctname, contname, asstname;    
    User userDetails = new User();
    Profile profileDetails = new Profile();
    public CaseNewSelectionExtController(ApexPages.StandardController controller) {
        system.debug('## ApexPages.currentPage().getParameters()' + ApexPages.currentPage().getParameters());
        acctId = ApexPages.currentPage().getParameters().get('def_account_id');//ApexPages.currentPage().getParameters().get('acctid');//Komathi - To fix new case issue for the QH Account  
        //contId = ApexPages.currentPage().getParameters().get('contid');
        //asstId = ApexPages.currentPage().getParameters().get('asstid');
        
        //Added by Exafort for TS-8754
        contId = ApexPages.currentPage().getParameters().get('def_contact_id');
        asstId = ApexPages.currentPage().getParameters().get('def_asset_id');
        system.debug('acctId ++ '+ acctId);
        system.debug('contId ++ '+ contId);
        system.debug('asstId ++ '+ asstId);
        
        //acctname = ApexPages.currentPage().getParameters().get('acctname');
        //contname = ApexPages.currentPage().getParameters().get('contname');
        //asstname = ApexPages.currentPage().getParameters().get('asstname');
        
        // Added by Exafort for TS-8754
        if(acctId != null && acctId.length() > 10){
            Account getAccount = [Select Name from Account where ID=:acctId];
            acctname = getAccount.Name;
        }
        if(contId != null && contId.length() > 10){
            Contact getContact = [Select Name from Contact where Id = :contId];
            contname = getContact.Name;
        }
        if(asstId != null && asstId.length() > 10){
            Asset getAsset = [Select Name from Asset where Id = :asstId];
            asstname = getAsset.Name;
        }
        system.debug('acctname ++ '+ acctname);
        system.debug('contname ++ '+ contname);
        system.debug('asstname ++ '+ asstname);
        
        if(acctId == null)
            acctId = '';
        if(contId == null)
            contId = '';
        if(asstId == null)
            asstId = '';
        if(acctname == null)
            acctname = '';
        if(contname == null)
            contname = '';
        if(asstname == null)
            asstname = '';
        system.debug('### Account Name in constructor ### '+acctname);
        //Constructor
    }
    
    public pagereference Redirect()
    {
        User userDetails = [Select Id, Name, ProfileId from User where Id =: UserInfo.getUserId()];
        Profile profileDetails = [Select Id, Name from Profile where Id =: userDetails.ProfileId];
        String retURl = '%2F500';
        if(acctId != '')
            retURl = '%2F' + acctId;
        if(asstId != '')
            retURl = '%2F' + asstId;
        else if(contId != '')
            retURl = '%2F' + contId;
        
        /* FOR NCV CASE */
        //if(ApexPages.currentPage().getParameters().get('RecordType') == '01234000000BnF9')

        //	Added By exafort For SFDC-1594
        //	Get the current 'RecordType' URL parameter (if any)
        String rtParam = ApexPages.currentPage().getParameters().get('RecordType');
        If(String.isBlank(rtParam)){
            //	Retrieve all record type infos for the object
            List<Schema.RecordTypeInfo> rtInfos = Schema.SObjectType.Case.getRecordTypeInfos();
            
            //	Collect only the available record types for the current user (excluding Master if desired)
            List<Schema.RecordTypeInfo> availableRTs = new List<Schema.RecordTypeInfo>();
            for (Schema.RecordTypeInfo rti : rtInfos) {
                if (rti.isAvailable() && !rti.isMaster()) {  // isAvailable() checks profile-based access
                    availableRTs.add(rti);
                }
            }
            
            //	If exactly one available record type, override/set the 'RecordType' param to its ID
            if (availableRTs.size() == 1 && profileDetails.Name != 'Support Provider H3C') {
                ApexPages.currentPage().getParameters().put('RecordType', availableRTs[0].getRecordTypeId());
            }
        }
        
        if(ApexPages.currentPage().getParameters().get('RecordType') != null && 
           Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(ApexPages.currentPage().getParameters().get('RecordType')).getName() == 'NCV Case')
        {  
            //Pagereference pageref = new Pagereference('/500/e?RecordType=01234000000BnF9&retURL=' + retURl +'&ent=Case&def_account_id='+acctId+'&def_contact_id='+contId+'&def_asset_id='+asstId);
            //pageRef.getParameters().put('nooverride', '0');
            //pageref.setredirect(true);
            //return pageref;
            if(acctId != null && acctId.length() > 10){
                Account getAccount = [Select Name from Account where ID=:acctId];
                acctname = getAccount.Name;
            }
            if(contId != null && contId.length() > 10){
                Contact getContact = [Select Name from Contact where ID=:contId];
                contname = getContact.Name;
            }    
            
            Pagereference pageref = new Pagereference('/apex/caseNewOrEditPage?retURL=' + retURl +'&acctId=' + acctname + '&contId=' + contname + '&asstId=' + asstname+'&RecordType=01234000000BnF9&sfdc.override=1');
            pageref.setredirect(true);
            return pageref;
        }
        /* FOR ARRAY CASE */
        //else if(ApexPages.currentPage().getParameters().get('RecordType') == '01234000000BnF4')
        else if(ApexPages.currentPage().getParameters().get('RecordType') != null && 
                Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(ApexPages.currentPage().getParameters().get('RecordType')).getName() == 'Array Case')
        {
            //Pagereference pageref = new Pagereference('/apex/CaseNewPage?retURL=' + retURl + '&acctId=' + acctname + '&contId=' + contname + '&asstId=' + asstname);
            //Pagereference pageref = new Pagereference('/apex/caseNewOrEditPage?retURL=%2F500%2Fo&RecordType=01234000000BnF4&ent=Case&sfdc.override=1');
            Pagereference pageref = new Pagereference('/apex/caseNewOrEditPage?retURL=' + retURl +'&accountId=' + acctId + '&acctId=' + acctname + '&contId=' + contname +'&assetId='+ asstId +'&asstId=' + asstname+'&RecordType=01234000000BnF4&sfdc.override=1');
            //Komathi - Added accountId param to fix new case issue for QH Account Oct 11 2019
            
            //Commented by vishnu to fix the URL redirection in lightning on 5th Nov 2020
            //Pagereference pageref = new Pagereference('/apex/caseNewOrEditPage?retURL=' + retURl + '&acctId=' + acctname + '&contId=' + contname +'&asstId=' + asstname+'&RecordType=01234000000BnF4&sfdc.override=1');
            //Pagereference pageref = new Pagereference('/apex/caseNewOrEditPage?retURL=' + retURl + '&acctId=' + acctname + '&contId=' + contname + '&asstId=' + asstname+'&RecordType='+ApexPages.currentPage().getParameters().get('RecordType')+'&sfdc.override=1');
            pageref.setredirect(true);
            return pageref;
        }
        //Added by Exafort on Feb 26 2021 - TS-7979
        else if(ApexPages.currentPage().getParameters().get('RecordType') != null && 
                Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(ApexPages.currentPage().getParameters().get('RecordType')).getName() == 'SSaaS')
        {                        
            Pagereference pageref = new Pagereference('/apex/caseNewOrEditPage?retURL=' + retURl +'&accountId=' + acctId + '&acctId=' + acctname + '&contId=' + contname +'&assetId='+ asstId +'&asstId=' + asstname+'&RecordType='+ApexPages.currentPage().getParameters().get('RecordType')+'&sfdc.override=1');
            pageref.setredirect(true);
            return pageref;
        }
        // End
        /*FOR InfoSight Portal case*/
        //Added for TS-6416 by Exafort
        else if(ApexPages.currentPage().getParameters().get('RecordType') != null && 
                Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(ApexPages.currentPage().getParameters().get('RecordType')).getName() == 'InfoSight Portal')
        {
            System.debug('Inside infosight condition <=====');
            Pagereference pageref = new Pagereference('/apex/infoSightCaseNewOrEditPage?retURL=' + retURl + '&acctId=' + acctname + '&contId=' + contname + '&asstId=' + asstname+'&RecordType='+ApexPages.currentPage().getParameters().get('RecordType')+'&sfdc.override=1');
            pageref.setredirect(true);
            return pageref;
        }
        //Added by Subhash - to show the Case Detail Page for H3C Support Provider users - Start
        //Added by vishnu on 18th June 2019 to handle the page redirection for the new Ops case record type and infosight portal case TS-5907.
        //else if(profileDetails.Name == 'Support Provider H3C' || Test.isRunningTest() || ApexPages.currentPage().getParameters().get('RecordType') != '01234000000BnF4' || ApexPages.currentPage().getParameters().get('RecordType') != '01234000000BnF9'){
        else if(profileDetails.Name == 'Support Provider H3C' || Test.isRunningTest() || 
                (ApexPages.currentPage().getParameters().get('RecordType') != null &&  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(ApexPages.currentPage().getParameters().get('RecordType')).getName() != 'Array Case') || 
                (ApexPages.currentPage().getParameters().get('RecordType') != null &&  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(ApexPages.currentPage().getParameters().get('RecordType')).getName() != 'NCV Case') ||
                (ApexPages.currentPage().getParameters().get('RecordType') != null &&  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(ApexPages.currentPage().getParameters().get('RecordType')).getName() != 'InfoSight Portal')){
                    Map<String, String> mapParameters;
                    Pagereference pageref;
                    String uiThemeDisplayed = UserInfo.getUIThemeDisplayed();
                    if(uiThemeDisplayed=='Theme2' || uiThemeDisplayed=='Theme3'){  // Classic Theme Value
                        pageref = new Pagereference('/500/e');
                        mapParameters = ApexPages.currentPage().getParameters();
                        for (String parameterName:mapParameters.keySet()){
                            if (parameterName <> 'save_new'){
                                pageref.getParameters().put(parameterName, mapParameters.get(parameterName));
                            }
                        }
                        pageRef.getParameters().put('nooverride', '0');
                        pageRef.setRedirect(true);
                        //return pageref;
                    }
                    System.debug('Inside final condition <=======');
                    if(uiThemeDisplayed=='Theme4d'){  // Lightning Theme Value   
                        System.debug('Inside final if condition <=======');
                        //pageref = new Pagereference('/?retURL=' + retURl +'&RecordType='+ApexPages.currentPage().getParameters().get('RecordType')+'&sfdc.override=0');
                        pageref = new Pagereference('/apex/caseNewOrEditPage?retURL=' + retURl +'&RecordType='+ApexPages.currentPage().getParameters().get('RecordType')+'&sfdc.override=1');
                        pageRef.setRedirect(true);
                        //return pageref;
                        
                    }
                    return pageref;
                }
        //Added by Subhash - to show the Case Detail Page for H3C Support Provider users - End
        else
            return null;
    }
}