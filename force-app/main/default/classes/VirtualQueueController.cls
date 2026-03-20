/*                             <<<< === VirtualQueuePageController Apex class === >>>>
=====================================================================================================================================
Name                    : VirtualQueuePageController(Support Product Area)
Description             : Logic to display list of cases based on user familar support profiles with cases in support queue general
Created Date            : 04/06/2023
Author                  : Guru Dev(Exafort)
Version                 : 1.0
Modification History    : Initial Version - This apex class is referred in "VirtualQueue"
=====================================================================================================================================
*/
public class VirtualQueueController {
   // public Boolean AlletraMPFile{get;set;}
   // public Boolean AlletraMPBlock{get;set;}
   // public Boolean LegacyNimble{get;set;}
   // public Boolean AlletraMPObject{get;set;}
   // public Boolean backupAndRecovery{get;set;}
    public list<Case> caseList{get;set;}
    public list<string> supportProfileList{get;set;}
    public String selectedRecordIds { get; set; }
    public List<String> selectedRecordIdsList { get; set; }
    public Integer offset { get; set; }
    public Integer pageSize { get; set; }
    public integer caseTotalSize;
    private string SUPPORT_QUEUE_GENERAL = '00G80000001ucU1';
    private String sortDirection = 'ASC';
    private String sortExp = 'CaseNumber';
    
    public Map<String, Boolean> selectedSupportProfiles { get; set; }
    public List<String> globalSupportProfileList { get; set; }
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    
    
    // Constructor
    public VirtualQueueController(){
        system.debug('Virtual queue Controller');
        sortDirection ='ASC';
        List<String> CurrentUserSupportProfiles =  New List<String>();
        Id userId = UserInfo.getUserId();
        list<CntrbnMdl_TSE__c> CntrbnMdlTSE = [Select id,Support_Profile__c from CntrbnMdl_TSE__c where Employee_Name__c =: userId limit 1];
        if(CntrbnMdlTSE.size() > 0 &&  CntrbnMdlTSE[0].Support_Profile__c != null){
            CurrentUserSupportProfiles = CntrbnMdlTSE[0].Support_Profile__c.split(';'); // CurrentUserSupportProfiles.
        }
        supportProfileList = New list<string>();
       /* for(String supportProfile : familiarSupportProfiles){
            
            string trimmedSupprortProfile = supportProfile.trim();
            supportProfileList.add(trimmedSupprortProfile);
            
            switch on trimmedSupprortProfile{
                when 'Alletra MP File' {
                    AlletraMPFile = true;
                }
                when 'Alletra MP Block' {
                    AlletraMPBlock = true;
                }
                when 'Legacy Nimble' {
                    LegacyNimble = true;
                }
                when 'Alletra MP Object' {
                    AlletraMPObject = true;
                }
                when 'Backup & Recovery' {
                    backupAndRecovery = true;
                }
            }
        }  */
        
        
        globalSupportProfileList = new List<String>();//globalSupportProfileList
        
        Schema.DescribeFieldResult fieldResult = CntrbnMdl_TSE__c.Support_Profile__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        List<String> picklistValueStrings = new List<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
            picklistValueStrings.add(entry.getLabel());
        }
        
        globalSupportProfileList = picklistValueStrings;
        
        // Initialize the map of selected values
        selectedSupportProfiles = new Map<String, Boolean>();
        for (String option : globalSupportProfileList) {
            selectedSupportProfiles.put(option, false);
        }
        
        for(string ctrbnMdlTSESupportProfile : CurrentUserSupportProfiles){
            string trimmedSupprortProfile = ctrbnMdlTSESupportProfile.trim();
            supportProfileList.add(trimmedSupprortProfile);
            if(selectedSupportProfiles.containsKey(ctrbnMdlTSESupportProfile)){
               selectedSupportProfiles.put(ctrbnMdlTSESupportProfile,true); //selectedSupportProfiles
            }  
        }
        
        system.debug('supportProfileList:   '+supportProfileList);
        // For Pagination
        offset = 0;
        pageSize = 50;
        
        //Query the cases records based on TSE-Support profile
        displayCases();
    }
    
    
    /* 
checkBoxOnChange This method used when user change the Support profile filter from UI, 
Currently Support profile filter section is hidden 
*/
    public void checkBoxOnChange(){
        
        supportProfileList =  New list<string>();
        system.debug('supportProfileList = '+ supportProfileList);
        
       /* if(AlletraMPFile == true)
            supportProfileList.add('Alletra MP File');  
        
        if(AlletraMPBlock == true)
            supportProfileList.add('Alletra MP Block');
        
        if(LegacyNimble == true)
            supportProfileList.add('Legacy Nimble');
        
        if(AlletraMPObject == true)
            supportProfileList.add('Alletra MP Object');
        
        if(backupAndRecovery == true)
            supportProfileList.add('Backup & Recovery'); */
        
        for(string supportProfiles : selectedSupportProfiles.keySet()){
            Boolean isTrue = selectedSupportProfiles.get(supportProfiles);
            if(isTrue){
                supportProfileList.add(supportProfiles);
            }
            
        }
        
        //displayCases();  
        firstPage();     
    }
    
    
    /* Next Methods Used for pagination */
    public void next() {
        offset += pageSize;
        displayCases();
        
    }
    
    /* Display 50 Records on each page */
    public void firstPage(){
        offset = 0;
        pageSize = 50;
        displayCases();
    }
    
    /* Used to display previous page */
    public void previous() {
        offset -= pageSize;
        displayCases();
    }
    
    /* To disable preview button when user is on first page */
    public boolean getprev()
    {
        if(offset == 0)
            return true;
        else
            return false;
    }
    
    /* To disable next button when user is on last page */
    public boolean getnxt()
    {
        if((offset + pageSize) >= caseTotalSize)
            return true;
        else
            return false;
    }
    
    /*	Moves directly to last page in Pagination */
    public void LastPage()
    {
        offset = caseTotalSize - math.mod(caseTotalSize,pageSize);
        displayCases();
    }
    
    /* Display the number of records from total count */
    public string getPageDetails()
    {
        
        Integer pageSizes = offset + pageSize;
        system.debug('pageSizes :'+ pageSizes);
        Integer showingAsset = pageSizes -pageSize;
        if(caseTotalSize <= 0)
        {
            return 'Showing 0 out of 0 Cases';
        }
        else
        {
            if(pageSizes  < caseTotalSize)
            {
                if(showingAsset == 0)
                {
                    showingAsset = 1;
                }
                if(showingAsset != 1){
                    showingAsset = showingAsset+1;
                }
                system.debug('pageSizes : '+pageSizes);
                return 'Showing ' + showingAsset  + '-'  + pageSizes  + ' out of ' + caseTotalSize + ' Cases';
            }
            else
            {
                if(showingAsset == 0)
                {
                    showingAsset = 1;
                }
                if(showingAsset != 1){
                    showingAsset = showingAsset+1;
                }
                return 'Showing ' + showingAsset  + '-'  + caseTotalSize + ' out of ' + caseTotalSize + ' Cases';
            }
        }
        
    }
    
    /*	Query the case records based on TSE-Support profile	*/ 
    public void displayCases(){		
        //	Query based on User's support profile
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        system.debug('sortFullExp :'+sortFullExp);
        /*
        caseList = [Select
                    id,CaseNumber,Account.Name,Support_Profile__c,Contact.Name,Case_Handling__c,Priority,Asset.Name,AssetId,Subject,CreatedDate,
                    Status,caseAccountCritical__c,caseIsAssetSla4Hour__c,US_Support__c,caseSLAExpiryMinutes__c
                    from
                    case 
                    where 
                    OwnerId =: SUPPORT_QUEUE_GENERAL AND 
                    (Support_Profile__c =: supportProfileList OR Support_Profile__c = null) AND
                    IsClosed = false and (not subject like '%SCARECROW HAWK%') AND
                    subject != 'Returned mail: see transcript for details' AND
                    subject != 'Warning: could not send message for past 4 hours'
                    order by CaseNumber ASC LIMIT :pageSize OFFSET :offset];  
        sortDirection = 'ASC'; */
        string setNullvalue = sortDirection=='ASC'?'FIRST':'LAST';
        //	Added by Exafort for SFDC-1096 Start
        string supportprofileFilter = VirtualQueueController.getSupportProfileQueryString(supportProfileList);
        system.debug('supportProfileList :'+supportProfileList);
        //Added by Exafort for SFDC-872
        caseList = Database.query('Select ' +
                                  'id,CaseNumber,Account.Name,Support_Profile__c,Contact.Name,Case_Handling__c,Priority,Asset.Name,AssetId,Subject,CreatedDate,' +
                                  'Status,caseAccountCritical__c,caseIsAssetSla4Hour__c,US_Support__c,caseSLAExpiryMinutes__c ' +
                                  'from ' + 
                                  'case ' + 
                                  'where ' + 
                                  'OwnerId =: SUPPORT_QUEUE_GENERAL AND (not Case_Handling__c like \'%PCAI%\') AND ' +
                                  //	Added by Exafort for SFDC-1096
                                  '('+ supportprofileFilter + ') AND '+
                                  // '(Support_Profile__c =: supportProfileList OR Support_Profile__c = null) AND ' +
                                  'IsClosed = false and (not subject like \'%SCARECROW HAWK%\') AND ' +
                                  'subject != \'Returned mail: see transcript for details\' AND ' +
                                  'subject != \'Warning: could not send message for past 4 hours\' ' + 
                                  'order by ' + sortFullExp + ' NULLS ' + setNullvalue +' LIMIT :pageSize OFFSET :offset');
        
        if(offset == 0 && caseList!= null && caseList.size() < pageSize){
            // No need to issue query to find out the count because the list returned is less the page size
            caseTotalSize = caseList.size();
            system.debug('No need to query to get case list size');
        }else{
            // Need to issue SOQL to find the size
            system.debug('Issuing another SOQL to get case list size');
            //	Query to get the count of the total record value in pagination
            //Added by Exafort for SFDC-872
            //	Added by Exafort for SFDC-1096
            caseTotalSize = Database.countQuery('Select ' +
                                                'count() ' +
                                                'from ' + 
                                                'case ' + 
                                                'where ' + 
                                                'OwnerId =: SUPPORT_QUEUE_GENERAL AND (not Case_Handling__c like \'%PCAI%\') AND ' +
                                                '('+ supportprofileFilter + ') AND '+
                                                'IsClosed = false and (not subject like \'%SCARECROW HAWK%\') AND ' +
                                                'subject != \'Returned mail: see transcript for details\' AND ' +
                                                'subject != \'Warning: could not send message for past 4 hours\' ');  
        }
    }
    
    /* Method executes in clicking Accept button. Assigns the case owner as the login user */
    public void changeOwner(){
        system.debug('selectedRecordIds:'+selectedRecordIds);
        List<case> updateList = New List<case>();
        selectedRecordIdsList = selectedRecordIds.split(',');
        
        //	Get the list of case with FOR UPDATE to help lock the record
        caseList = [Select id,CaseNumber,Account.Name,Support_Profile__c,Contact.Name,Case_Handling__c,Priority,Asset.Name,AssetId,Subject,
                    CreatedDate,Status,caseAccountCritical__c,caseIsAssetSla4Hour__c,US_Support__c from case 
                    where id in: selectedRecordIdsList FOR UPDATE];
        
        for(case cas : caseList){
            cas.ownerid = UserInfo.getUserId();
            cas.Last_Accepted_By__c = UserInfo.getName();
            updateList.add(cas);
        }        
        if(updateList.size() > 0){
            system.debug('Updating owner for :' + updateList);
            update updateList;
        }
        checkBoxOnChange();
    }
    
    /* Passing the Selected record id's to "CaseChangeOwnerOnVirtualQueue" vf page */
    public PageReference changeOwnerRedirect(){
        system.debug('Selected record ids : '+selectedRecordIds);
        Cookie c = new Cookie('recIds', selectedRecordIds, null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{c});
        PageReference pageRef = Page.CaseChangeOwnerOnVirtualQueue;
        return pageRef;
        
    }
    
    /* Passing the Selected record id's to "CaseStatusChangeOnVirtualQueue" vf page */
    public PageReference changeStatusRedirect(){
        system.debug('Selected record ids : '+selectedRecordIds);
        Cookie c = new Cookie('recIds', selectedRecordIds, null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{c});
        PageReference pageRef = Page.CaseStatusChangeOnVirtualQueue;
        return pageRef;
        
    }
    //	Added by Exafort for SFDC-1096 Start
    /*	This method provides profile based conditions */
    public Static string getSupportProfileQueryString(list<string> supportProfileList){
        string supportprofileFilter = '';
        system.debug('supportProfileList :'+supportProfileList);
        if(supportProfileList != null){
            for(string supportProfile : supportProfileList){
                if(supportProfile == 'Alletra MP Block'){
                    supportprofileFilter = supportprofileFilter + '((Support_Profile__c LIKE \'%Alletra MP Block%\') AND (NOT Case_Handling__c LIKE \'%dHCI%\')) OR ';
                }
                else{
                    supportprofileFilter = supportprofileFilter + '(Support_Profile__c LIKE \'%' + supportProfile + '%\') OR ' ;
                }
            }
        }
        
        supportprofileFilter = supportprofileFilter + '(Support_Profile__c = null)';
        return supportprofileFilter;
    }
    //	End of SFDC-1096
}