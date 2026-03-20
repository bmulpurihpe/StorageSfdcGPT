/**
 * @description       : CaseUtility - Utility class for case trigger
 * @author            : 
 * @group             : NimbleSupport
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Modifications Log
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ver   Date         Author             Modification        JIRA                     Description 
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * 1.0    4/21/2015                      Initial Version                       
       Utility class for case trigger
 * 2.0    12/2/2020   Exafort            2.0              TS-7728/TS-5295            Avoid the recursive SOQL -
 * 3.0    05/06/2021  Exafort            3.0              TS-5295
 * 4.0    12/22/2020  Exafort            4.0              TS-7728/TS-5295            Avoid the recursive SOQL -  
 * 5.0    7/27/2022   Nagalaxmi Telkar   5.0              TS-8865                    Successive updates to case tatsa dont not update peak mapping code  : 
                                                                                     Added validation code(different code to run when test is running, needed for coverage)                                                                      
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
**/
public class CaseUtility
{
    public static String REC_STATUS_COMPLETE = 'Complete';
    public static String NIMBLE_SUPPORT_USER_ID = '00580000003xTOlAAM';
    public static String SUPPORT_QUEUE_GENERAL_ID = '00G80000001ucU1EAI';
    public static String SUPPORT_QUEUE_AUTOMATIC_ID = '00G34000003rkEyEAI';
    public static String SUPPORT_AUTOMATION_USER_ID = '0052H00000Dz0AbQAJ';
    
    public static Boolean VALIDATE_OWNER_TRIGGER = true;
    public static Boolean CASETRIGGER_FLAG = true;
    //Added by exafort on May 06 2021 for TS-5295 START
    public static Boolean restrictBugListBinding = false;
    public static list<Bug__c> bugListDetails = new list<Bug__c>();
    public static set<Id> caseRecordIds = new set<Id>();
    public static Set<String> orgWideEmailFromAddresses = new Set<String>();
    // Map of Org Wide Email Address Id's by it's Address
    public static Map<String, String> orgWideEmailAddressIdsFromAddress = new Map<String, String>();
    
    public static List<String> pachinkoCodes = new List<String>();
    // END
  
    //public static list<Account> accountList = new list<Account>();
    public static Boolean isCommentInsert = false; // Added for Exafort SFDC-1988
    public static Boolean isEmailIncoming = false; // Added for Exafort SFDC-1988
    public static String SUPPORT_PROVIDER_PROFILE_ID = '00e800000018tEuAAI'; // Added for Exafort SFDC-1988
    public static String SUPPORT_PROVIDER_H3C_PROFILE_ID = '00e340000018xBfAAI'; // Added for Exafort SFDC-1988
    //Added by Exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728- TS-5295 - START
    public static list<Category_Notes__c> catnotesList;
    public static  Map<Id,Case> caseMap;
    //Added by Exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728-TS-5295 - END
    Public static Map<string,Case_Docket__c> caseDocketRecMap = new Map<string,Case_Docket__c>();//Added by exafort for TS-8404 and TS-8401 on 05/Aug 2021
      
    
    /*
     * Create outstanding recomendation on case insert with pachinko case type and exceeds a threshold limit
     * Input: list of cases which has pachinko case type populated, set of packinko type values
     */
    public static void createOutStandingRecomendationOnCaseInsert(List<Case> caseList, Set<String> pachinkoCaseTypes)
    {
        set<Id> assetIds = new set<Id> ();
        set<Id> acctIds = new set<Id> ();
        set<Id> caseIds = new set<Id>();
        //Query the case velocity object 
        list<pachinko_case_type__c> pachinkoCaseTypeList = [select id, Monthly_Threshold__c,Recommendation_Text__c, Pachinko_Case_Type__c,Threshold_Applies_To__c from pachinko_case_type__c Where pachinko_case_type__c IN: pachinkoCaseTypes and Enabled__c = true] ;
        Decimal months;
        Integer imonths;
        //get the custom setting for number of months 
        Threshold_limit__c t1 = Threshold_limit__c.getValues('limit');
        if(t1 != null) // check for null, if custom setting has record or not
        {
            months = t1.Number_of_Months__c;
            imonths = months.intValue();
        }
        Datetime StartDate = System.now().addMonths(-imonths);// System.now is used get the date and time in GMT timezone, so that the query results the correct records
        Datetime endDate = System.now();
        Map<String,pachinko_case_type__c> pachinkoCaseTypeMap = new Map<String,pachinko_case_type__c> ();
        for(pachinko_case_type__c pCaseType : pachinkoCaseTypeList)
        {
            pachinkoCaseTypeMap.put(pCaseType.Pachinko_Case_Type__c, pCaseType);
        }
        set<String> pachinkoCaseTypesForAcct = new set<String> ();
        set<String> pachinkoCaseTypesForAsst = new set<String> ();
        for(Case c : caseList)
        {
        // separate the account ids and asset ids
            caseIds.add(c.Id);
            pachinko_case_type__c pc =  pachinkoCaseTypeMap.get(c.casePachinkoCaseType__c);
            if(pc != null && pc.Threshold_Applies_To__c == 'Account')
            {
                acctIds.add(c.AccountId);
                pachinkoCaseTypesForAcct.add(c.casePachinkoCaseType__c);
            }
            else if(pc != null && pc.Threshold_Applies_To__c == 'Array')
            {
                assetIds.add(c.assetId);
                pachinkoCaseTypesForAsst.add(c.casePachinkoCaseType__c);
            }
        }   
        
        List<Outstanding_Recommendation__c> outRecsForAsset = new List<Outstanding_Recommendation__c>();
        List<Outstanding_Recommendation__c> outRecsForAccount = new List<Outstanding_Recommendation__c>();
        Map<String,Outstanding_Recommendation__c> recMapToInsert = new Map<String,Outstanding_Recommendation__c>();
        // TS-8865 : Successive updates to case tatsa dont not update peak mapping code:Added validation code(different code to run when test is running, needed for coverage) 
        if(!test.isRunningTest())
            outRecsForAsset = [select Id, CreatedDate, Status__c, Asset__c, Case_Velocity_Type__c from Outstanding_Recommendation__c where Asset__c in :assetIds and Case_Velocity_Type__c in :pachinkoCaseTypesForAsst];
        else
            outRecsForAsset = [select Id, CreatedDate, Status__c, Asset__c, Case_Velocity_Type__c from Outstanding_Recommendation__c where Asset__c in :assetIds];
        
        if(!test.isRunningTest())
           outRecsForAccount = [select Id, CreatedDate, Status__c, Account__c, Case_Velocity_Type__c from Outstanding_Recommendation__c where Account__c in :acctIds and Case_Velocity_Type__c in :pachinkoCaseTypesForAcct];
        else
            outRecsForAccount = [select Id, CreatedDate, Status__c, Account__c, Case_Velocity_Type__c from Outstanding_Recommendation__c where Account__c in :acctIds];
         
        Map<String,List<Outstanding_Recommendation__c>> recMapExisting = new Map<String,List<Outstanding_Recommendation__c>>();
        Map<String,Outstanding_Recommendation__c> recMapExistingLatest = new Map<String,Outstanding_Recommendation__c>();
        for(Outstanding_Recommendation__c orec : outRecsForAsset)
        {
            String key = orec.Asset__c + ':' + orec.Case_Velocity_Type__c;
            List<Outstanding_Recommendation__c> outRecs = recMapExisting.get(key);
            if(outRecs == null)
            {
                outRecs = new List<Outstanding_Recommendation__c>();                                
            }
            outRecs.add(orec);
            recMapExisting.put(key,outRecs);
                
        }
        for(Outstanding_Recommendation__c orec : outRecsForAccount)
        {
            String key = orec.Account__c + ':' + orec.Case_Velocity_Type__c;
            List<Outstanding_Recommendation__c> outRecs = recMapExisting.get(key);
            if(outRecs == null)
            {
                outRecs = new List<Outstanding_Recommendation__c>();                                
            }
            outRecs.add(orec);
            recMapExisting.put(key,outRecs);
                
        }
        for(String key : recMapExisting.keySet())
        {
            List<Outstanding_Recommendation__c> outRecs = recMapExisting.get(key);
            Outstanding_Recommendation__c outRec = outRecs.get(0);
            Datetime createdDate = outRec.createdDate;
            for(Integer i = 1; i < outRecs.size(); i++)
            {
                if(outRecs.get(i).CreatedDate > createdDate)
                {
                    outRec = outRecs.get(i);
                    createdDate = outRec.createdDate;
                }
            }
            recMapExistingLatest.put(key,outRec);           
        }
        //Use group by with assetId, pachinkotype and accountId, pachinkotype
        List<Case> CaseResultsForAsset = [Select AssetId, casePachinkoCaseType__c, CreatedDate FROM Case Where AssetId in: assetIds and casePachinkoCaseType__c in :pachinkoCaseTypesForAsst and CreatedDate >= :StartDate and CreatedDate <= :Enddate];
        List<Case> CaseResultsForAccount = [Select AccountId, casePachinkoCaseType__c, CreatedDate FROM Case Where AccountId in: acctIds and casePachinkoCaseType__c in :pachinkoCaseTypesForAcct and CreatedDate >= :StartDate and CreatedDate <= :Enddate];       
        
        Map<String,Integer> caseCountMap = new Map<String, Integer>();
        for(Case c : CaseResultsForAsset)
        {           
            Id asstId = c.AssetId;
            String pType = c.casePachinkoCaseType__c;
            //Key is the combination of asstId:pachinkotype
            String key = asstId + ':' + pType;
            Outstanding_Recommendation__c oRec1 = recMapExistingLatest.get(key);
            Integer count = caseCountMap.get(key);
          
            if(oRec1 != null && oRec1.Status__c == REC_STATUS_COMPLETE)
            {
                
                if(c.CreatedDate > oRec1.CreatedDate)
                {                   
                    if(count != null)
                        count = count + 1;  
                    else
                        count = 1;
                }               
            }
            else
            {                
                if(count != null)
                    count = count + 1;  
                else
                    count = 1;
            }
            caseCountMap.put(key,count);
        }
        
       
        for(Case c : CaseResultsForAccount)
        {
            Id actId = c.AccountId;
            String pType = c.casePachinkoCaseType__c;
            //Key is the combination of acctId:pachinkotype
            String key = actId + ':' + pType;
            Outstanding_Recommendation__c oRec1 = recMapExistingLatest.get(key);
            Integer count = caseCountMap.get(key);
           
            if(oRec1 != null && oRec1.Status__c == REC_STATUS_COMPLETE)
            {                
                if(c.CreatedDate > oRec1.CreatedDate)
                {                   
                    if(count != null)
                        count = count + 1;  
                    else
                        count = 1;
                }               
            }
            else
            {
                if(count != null)
                    count = count + 1;  
                else
                    count = 1;
            }
            caseCountMap.put(key,count);
        }       
        for(Case cas : caseList)
        {
            pachinko_case_type__c pCaseType = pachinkoCaseTypeMap.get(cas.casePachinkoCaseType__c);
            if(pCaseType != null){        
                Decimal Threshold =  pCaseType.Monthly_Threshold__c;
                Integer iThreshold = Threshold.intValue();
                String key;
                if(pCaseType.Threshold_Applies_To__c == 'Array')
                    key = cas.AssetId + ':' + cas.casePachinkoCaseType__c;
                else if(pCaseType.Threshold_Applies_To__c == 'Account')
                    key = cas.AccountId + ':' + cas.casePachinkoCaseType__c;
                Integer count = caseCountMap.get(key);                
                if(count>=Threshold)
                {                    
                    Outstanding_Recommendation__c oRec = recMapToInsert.get(key);
                    if(oRec == null)
                    {
                        Outstanding_Recommendation__c oRec1 = recMapExistingLatest.get(key);                        
                        if(oRec1 == null || oRec1.Status__c == REC_STATUS_COMPLETE)
                        {
                            oRec = new Outstanding_Recommendation__c();
                            oRec.Recommended_Action__c = pCaseType.Recommendation_Text__c;
                            oRec.Account__c= cas.AccountId;
                            oRec.Asset__c=cas.AssetId;
                            oRec.case__c = cas.Id;
                            oRec.Case_Velocity__c = pCaseType.Id;
                            oRec.Case_Velocity_Type__c = pCaseType.Pachinko_Case_Type__c;
                            recMapToInsert.put(key,oRec);//add to map
                        }
                        
                    }
                } 
            }
         } 
                if(recMapToInsert.size() > 0)
                    insert recMapToInsert.values(); //insert the map values, outstanding recs
    }
    /* validate the outstanding recomendation on case close by nimblesupport 
     * whether the case velocity has Leave Case Open = true
     * Input: List of closed cases by nimble support user
    */
    public static void validateRecommendationOnCaseClose(List<Case> closedCases)
    {
        Set<Id> caseIds = new Set<Id>();
        for(Case c : closedCases)
        {
            caseIds.add(c.Id);            
        }
        Map<Id,Case> caseMap = new Map<Id,Case>([select Id, (select Id,Status__c,Case_Velocity__r.Leave_Case_Open__c from Outstanding_Recommendations__r order by createddate desc limit 1) from Case where Id in:caseIds]);
        
        for(Case c : closedCases)
        {
            Case c1 = caseMap.get(c.Id);
            List<Outstanding_Recommendation__c> outRecs = c1.Outstanding_Recommendations__r;
            if(outRecs.size() > 0)
            {
                Outstanding_Recommendation__c outRec = outRecs.get(0);
                if(outRec.Status__c != REC_STATUS_COMPLETE && outRec.Case_Velocity__r.Leave_Case_Open__c)
                {
                    c.addError('Pachinko Ignore : Leave Case Open True for Case Velocity');
                }
            }
        }
    }
    
    //  Added by exafort for TS-10444 && 10445
    /*
     * This returns set of account ids in Management_Escalation__c records with Severity__c = 'Code Red' and Status__c != 'Closed'
     */
    public static set<id> getManagementEscalationWithAccountsInCodeRedSeverity(set<id> accoutIds){
        set<id> accountWithSeverityCodeRed = new set<id>();
        for(Management_Escalation__c eachCustomerCareEscalation : [Select id,Account__c,Severity__c from Management_Escalation__c where Account__c =:accoutIds and Status__c != 'Closed' and Severity__c = 'Red']){
            accountWithSeverityCodeRed.add(eachCustomerCareEscalation.Account__c);
        }
        if(accountWithSeverityCodeRed.size() > 0){
            return accountWithSeverityCodeRed;
        }
        return null;
    }
    
    public static void populateEscalationAndPeakArea(List<Case> caseList)
    {
        
        //	Added by exafort for SFDC-1387
        // Collect unique tech/sub-tech values
        Set<String> techAreas = new Set<String>();
        Set<String> subTechAreas = new Set<String>();
        
        for (Case c : caseList) {
            if (String.isNotBlank(c.Technology_Area__c) && String.isNotBlank(c.Sub_Technology_Area__c)) {
                techAreas.add(c.Technology_Area__c);
                subTechAreas.add(c.Sub_Technology_Area__c);
            }
        }
        
        // Query mappings and child records
        List<TechnicalSubArea_Mappings__c> allMappings = [
            SELECT Id, Technical_Area__c, Technical_SubArea__c, Case_Types__c,
            Escalation_Rotation__c, Peak_Area__c, CreatedDate,
            Default_Peak__c, Default_Escalation_Rotation__c, Support_Profile__c,
            (SELECT Id, TechnicalSubArea_Mapping__c, Support_Profile__c,
             Engineering_Escalation_Mapping__r.Rot_Code__c,
             Engineering_Escalation_Mapping__r.IsActive__c
             FROM TA_TSA_Engineering_Escalation__r
             ORDER BY LastModifiedDate DESC)
            FROM TechnicalSubArea_Mappings__c
            WHERE Technical_Area__c IN :techAreas
            AND Technical_SubArea__c IN :subTechAreas
            AND IsDeleted__c = FALSE
            ORDER BY LastModifiedDate DESC
        ];
        
        // Build map of child escalations
        Map<Id, List<TA_TSA_Engineering_Escalation__c>> tsaToEscalationsMap = new Map<Id, List<TA_TSA_Engineering_Escalation__c>>();
        for (TechnicalSubArea_Mappings__c mapping : allMappings) {
            List<TA_TSA_Engineering_Escalation__c> validEscalations = new List<TA_TSA_Engineering_Escalation__c>();
            for (TA_TSA_Engineering_Escalation__c esc : mapping.TA_TSA_Engineering_Escalation__r) {
                if (esc.Engineering_Escalation_Mapping__r != null &&
                    esc.Engineering_Escalation_Mapping__r.IsActive__c == true) {
                        validEscalations.add(esc);
                    }
            }
            if (!validEscalations.isEmpty()) {
                tsaToEscalationsMap.put(mapping.Id, validEscalations);
            }
        }
        
        // Main case loop
        for (Case c : caseList) {
            c.Escalation_Rotation__c = null;
            c.Peak_Area__c = null;
            
            String caseTypeName = '';
            if (c.RecordTypeId != null && Schema.SObjectType.Case.getRecordTypeInfosById().containsKey(c.RecordTypeId)) {
                caseTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getName();
            }
            
            String supportProfile = String.isNotBlank(c.Support_Profile__c) ? c.Support_Profile__c : 'Legacy Nimble';
            
            if (String.isNotBlank(c.Technology_Area__c) && String.isNotBlank(c.Sub_Technology_Area__c)) {
                // Set Peak Area
                for (TechnicalSubArea_Mappings__c mapping : allMappings) {
                    if (mapping.Technical_Area__c == c.Technology_Area__c &&
                        mapping.Technical_SubArea__c == c.Sub_Technology_Area__c &&
                        String.isNotBlank(mapping.Support_Profile__c) &&
                        mapping.Support_Profile__c.split(';').contains(supportProfile.trim()) &&
                        String.isNotBlank(mapping.Case_Types__c) &&
                        mapping.Case_Types__c.split(';').contains(caseTypeName)){  
                            
                            c.Peak_Area__c = String.isNotBlank(mapping.Peak_Area__c) ? mapping.Peak_Area__c : mapping.Default_Peak__c;
                            break;
                        }
                }
                
                // Try to get Escalation Rotation from TA/TSA Escalation child
                Boolean foundEscalation = false;
                for (TechnicalSubArea_Mappings__c mapping : allMappings) {
                    if (tsaToEscalationsMap.containsKey(mapping.Id)) {
                        for (TA_TSA_Engineering_Escalation__c esc : tsaToEscalationsMap.get(mapping.Id)) {
                            if (String.isNotBlank(esc.Support_Profile__c) &&
                                esc.Support_Profile__c.split(';').contains(supportProfile.trim()) &&
                                esc.Engineering_Escalation_Mapping__r != null &&
                                String.isNotBlank(esc.Engineering_Escalation_Mapping__r.Rot_Code__c)) {
                                    
                                    c.Escalation_Rotation__c = esc.Engineering_Escalation_Mapping__r.Rot_Code__c;
                                    foundEscalation = true;
                                    break;
                                }
                        }
                    }
                    if (foundEscalation) break;
                }
                
                // Fallback to direct mapping if no escalation found
                if (!foundEscalation) {
                    for (TechnicalSubArea_Mappings__c mapping : allMappings) {
                        if (mapping.Technical_Area__c == c.Technology_Area__c &&
                            mapping.Technical_SubArea__c == c.Sub_Technology_Area__c &&
                            String.isNotBlank(mapping.Support_Profile__c) &&
                            mapping.Support_Profile__c.split(';').contains(supportProfile.trim()) &&
                            String.isNotBlank(mapping.Case_Types__c) &&
                            mapping.Case_Types__c.split(';').contains(caseTypeName)) {
                                
                                c.Escalation_Rotation__c = String.isNotBlank(mapping.Escalation_Rotation__c) ? mapping.Escalation_Rotation__c : mapping.Default_Escalation_Rotation__c;
                                break;
                            }
                    }
                }                
            } //	End of SFDC-1387
            else if(c.caseCatImpactToCustomer__c != null){
                Map<String, CustomerImpactMapping__c> cIMMap = new Map<String,CustomerImpactMapping__c>();
                List<CustomerImpactMapping__c> cIMapList = [select id,Customer_Impact__c,Esc_Rotation__c,PEAK_Area__c from CustomerImpactMapping__c ];
                for (CustomerImpactMapping__c cIM : cIMapList ){
                    String key  = cIM.Customer_Impact__c;
                    if(key != null)
                    {
                        key = key.trim().tolowercase().replace('\u2014', '-'); // replace spaces and  Em Dash(long dash)
                        cIMMap.put(key,cIM); 
                    }              
                } 
                String caseType = caseTypeName;   
                String key = c.caseCatImpactToCustomer__c + caseType;                   
                key = key.trim().tolowercase().replace('\u2014', '-'); // replace spaces and  Em Dash(long dash)
                
                if(cIMMap.get(Key) != null)
                {                    
                    c.Escalation_Rotation__c = cIMMap.get(key).Esc_Rotation__c ;
                    c.Peak_Area__c = cIMMap.get(key).Peak_Area__c;
                }
                else
                {                    
                    c.Escalation_Rotation__c = null;
                    c.Peak_Area__c = null;
                }
            }
        }
    }

    public static void populateDifficultyRating(List<Case> caseList)
    {
        //Commenting the below codes. The object CntrbnMdl_Difficulty__c is deprecated and Difficulty Rating field is moved to TechnicalAreaSub Mappings object.
        //Modified By Exafort(Azar)
        //Date: 3rd Oct 2017
        /*Map<String, CntrbnMdl_Difficulty__c> ctrMap = new Map<String,CntrbnMdl_Difficulty__c>(); 
        List<CntrbnMdl_Difficulty__c> cdList = [select id,Difficulty_Rating__c,Sub_Technical_Area__c,Technical_Area__c from CntrbnMdl_Difficulty__c where Sub_Technical_Area__c != null and Technical_Area__c != null];
  
        for (CntrbnMdl_Difficulty__c cd : cdList ){        
            String key = cd.Technical_Area__c+cd.Sub_Technical_Area__c;
            if(key != null)
            {
                key = key.trim().tolowercase().replace('\u2014', '-'); // replace spaces and  Em Dash(long dash) 
                ctrMap.put(key, cd);  
            }
        } */
        Map<String, TechnicalSubArea_Mappings__c> ctrMap = new Map<String,TechnicalSubArea_Mappings__c>(); 
        List<TechnicalSubArea_Mappings__c> cdList = [select id,Difficulty_Rating__c,Technical_SubArea__c,Technical_Area__c from TechnicalSubArea_Mappings__c where Technical_SubArea__c != null and Technical_Area__c != null];
        for (TechnicalSubArea_Mappings__c cd : cdList ){        
            String key = cd.Technical_Area__c+cd.Technical_SubArea__c;
            if(key != null)
            {
                key = key.trim().tolowercase().replace('\u2014', '-'); // replace spaces and  Em Dash(long dash) 
                ctrMap.put(key, cd);  
            }
        } 
        
        for(Case c : caseList) {
            String key = c.Technology_Area__c+c.Sub_Technology_Area__c;
            if(key != null)
            {
                key = key.trim().tolowercase().replace('\u2014', '-'); // replace spaces and  Em Dash(long dash) 
                if(ctrMap.containsKey(key)){
                    c.Case_Difficulty_Rating__c = ctrMap.get(key).Difficulty_Rating__c;                            
                }
                else
                {
                     c.Case_Difficulty_Rating__c = null;                     
                }
            }
        }
    }
    
     
    // Added by Exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295  START
    // Variable is used in caseTriggerSetOwnerEmail trigger
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    // Added by Exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295 START
    
      public static boolean isStandardUser(){         
        string userType = UserInfo.getUserType();   
        return (userType == 'Standard');
    }
    // Added by Exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728  STOP
    /*
    public static boolean isPortalUser(){
        string user = UserInfo.getUserId();
        User u = [SELECT Email, Name, ContactId from User where Id = :user];
        boolean isPortalUser = false;
        
        if (u.ContactId != null) 
        { 
            isPortalUser = true; 
        }
        return isPortalUser;
        
    }*/
    
    // Added by Exafort on 22 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295  START
    // Variable is used in caseTrigger
    public static boolean GSEMrun = true;
    public static boolean GSEMrunOnce(){
        if(GSEMrun){
            GSEMrun=false;
            return true;
        }else{
            return GSEMrun;
        }
    }
    
    public static Boolean runningInASandbox {
        get {
            //check if boolean has been set yet
            if (runningInASandbox == null) {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            //Return value
            return runningInASandbox;
        }
        set;
    }
    //Added by Exafort on 22 dec 2020 for avoid the recursive SOQL - TS-7728 - TS-5295 STOP
    
    public static void addToMapOfOrgWideEmailAddress(String requestAddress){
        orgWideEmailFromAddresses.add(requestAddress); 
        // If we have org wide emails to query
        if (!orgWideEmailFromAddresses.isEmpty()) {
            System.debug('### orgWideEmailAddresses >>> '+orgWideEmailFromAddresses);
            // For each org wide email address we find
            for (OrgWideEmailAddress orgWideEmail : [SELECT Id, Address From OrgWideEmailAddress WHERE Address IN: orgWideEmailFromAddresses]) {
                // Add a mapping to it's address
                orgWideEmailAddressIdsFromAddress.put(orgWideEmail.Address, orgWideEmail.Id);
            }
            System.debug('### orgWideEmailAddressIdsByAddress >>> '+orgWideEmailAddressIdsFromAddress);
        }
    }
    
    private static boolean caseUpdateRun = true;
    public static boolean caseUpdateRunOnce(){
        if(caseUpdateRun){
            caseUpdateRun=false;
            return true;
        }else{
            return caseUpdateRun;
        }
    }
    
    public static void createCaseEffortTrackingRecord(Case cse){
        list<Case_Effort_Tracking__c> commentTrackingCollection = new list<Case_Effort_Tracking__c>();                       
        System.debug('CreateCaseEffortTrackingRecord 1 : '+CaseCommentTimeTrackingVariable.caseCommentSpentTime +':'+CaseCommentTimeTrackingVariable.caseCommentActivity);        
        if(CaseCommentTimeTrackingVariable.caseCommentSpentTime !=null && CaseCommentTimeTrackingVariable.caseCommentActivity !=null){          
            Case_Effort_Tracking__c commentTracking = new Case_Effort_Tracking__c();
            System.debug('CreateCaseEffortTrackingRecord 2');
            commentTracking.CaseId__c = cse.Id;
            if(cse.Owner.Type == 'Queue')
                commentTracking.Effort_Queue__c = cse.Owner.Name;
            else
                commentTracking.Effort_Owner__c = cse.Owner.Id;
            System.debug('CreateCaseEffortTrackingRecord 3 : '+cse.Estimated_Effort__c+': css.Case_Effort_Summary_Total__c : ' +cse.Case_Effort_Summary_Total__c);
            if(cse.Estimated_Effort__c != null && cse.Estimated_Effort__c != 'none' && cse.Estimated_Effort__c != 'N/A' && cse.Case_Effort_Summary_Total__c == 0){
                String formattedStr = cse.Estimated_Effort__c;
                String[] strArr = formattedStr.split(' ');
                if(strArr.size() == 1){
                    if(strArr[0].isNumeric())
                        commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]); 
                    else{
                        String numberOnly = strArr[0].replaceAll('[^0-9]', '');
                        commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(numberOnly);
                    }
                }else if(strArr.size() == 2){
                    if(formattedStr.contains('minutes') || formattedStr.contains('min'))
                        commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]);
                    else if(formattedStr.contains('hour') || formattedStr.contains('hours') || formattedStr.contains('hr'))
                        commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]) * 60;
                    else if(formattedStr.contains('day'))
                        commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]) * 24 * 60;
                    else if(formattedStr.equals('one hour'))
                        commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(strArr[0]) * 60;
                    
                }else if(strArr.size() == 4){
                    String numberOnly = formattedStr.replaceAll('[^0-9]', '');
                    if(formattedStr.contains('min'))
                        commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(numberOnly);
                    else if(formattedStr.contains('hour'))
                        commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(numberOnly) * 60;
                    else if(formattedStr.contains('day'))
                        commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime + Decimal.ValueOf(numberOnly) * 24 * 60;
                }
            }else
                commentTracking.Effort_Amount__c = CaseCommentTimeTrackingVariable.caseCommentSpentTime;                            
            commentTracking.Effort_Origin__c = 'Case';
            commentTracking.Effort_Timestamp__c = Datetime.now();
            commentTracking.Effort_Type__c = CaseCommentTimeTrackingVariable.caseCommentActivity;
            commentTracking.Effort_User__c = UserInfo.getUserId();                   
            commentTrackingCollection.add(commentTracking);
        }                                                                            
    
        if(commentTrackingCollection.size() > 0){
            upsert commentTrackingCollection;//this is an after udate event
            case caseToUpdate = [select id, Case_Effort_Summary_Total__c,caseClosureEstimatedEffort__c from case where Id = :cse.Id];
            caseToUpdate.caseClosureEstimatedEffort__c = String.valueOf(caseToUpdate.Case_Effort_Summary_Total__c);
            caseToUpdate.Current_comment_time_spent__c = null;
            caseToUpdate.Current_comment_activity__c = null;
            update caseToUpdate;
            System.debug('Upsert and Update completed!!');
        }
    }
    
    
    //	Added By Exafort for TS-10444 & TS-10445
    //  This method is used to retrieve email addresses from the case to send emails upon creation or update of a Case with Severity Red Account. 
    public static List<String> getEmailToAddressFromCaseOfAccountRed(Case cas) {
        String toEmailAddress = '';
        
        if (cas.Owner.Type == 'User' && String.isNotBlank(cas.Owner.Email)) {
            toEmailAddress += cas.Owner.Email + ',';
        }
        if (cas.Account != null && cas.Account.Primary_PSM__r != null && String.isNotBlank(cas.Account.Primary_PSM__r.Email)) {
            toEmailAddress += cas.Account.Primary_PSM__r.Email + ',';
        }
        if (cas.Account != null && cas.Account.Secondary_PSM__r != null && String.isNotBlank(cas.Account.Secondary_PSM__r.Email)) {
            toEmailAddress += cas.Account.Secondary_PSM__r.Email + ',';
        }
        
        //Added By Exafort for SFDC-1552.
        //For sandbox, the value 'invalid' will be appended to the email address defined in the custom label.
        string technicalSupportManagerDL = (CaseUtility.runningInASandbox ? getValidEmailAddresses(System.Label.Technical_Support_Manager_DL) + '.invalid' : getValidEmailAddresses(System.Label.Technical_Support_Manager_DL));       
        if (String.isNotBlank(technicalSupportManagerDL)) {
            toEmailAddress += technicalSupportManagerDL + ',';
        } 
        //	Added By exafort for SFDC-1552
        //	As part of SFDC-1552, implemented new logic to handle invalid email addresses through the custom label.
        string escalationManagerDL = (CaseUtility.runningInASandbox ? getValidEmailAddresses(System.Label.Escalation_Manager_DL) + '.invalid' : getValidEmailAddresses(System.Label.Escalation_Manager_DL));
        if (String.isNotBlank(escalationManagerDL)) {
            toEmailAddress += escalationManagerDL + ',';
        }
        
        
        // Remove last comma if present
        if (toEmailAddress.endsWith(',')) {
            toEmailAddress = toEmailAddress.substring(0, toEmailAddress.length() - 1);
        }
        
        // Convert to List and handle empty case
        return String.isNotBlank(toEmailAddress) ? toEmailAddress.split(',') : new List<String>();
    }
   //End of TS-10444 & TS-10445
   
    //	Added By exafort for SFDC-1552
    //	As part of SFDC-1552, implemented new logic to handle invalid email addresses through the custom label.
    public static String getValidEmailAddresses(String inputEmails) {
        List<String> emails = inputEmails.split(',');
        List<String> validEmails = new List<String>();
        
        for (String email : emails) {
            email = email.trim(); // Remove leading/trailing spaces
            if (isValidEmail(email)) {
                validEmails.add(email);
            }
        }
        
        return String.join(validEmails, ',');
    }
    
    public static Boolean isValidEmail(String email) {
        String emailRegex = '(?i)^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher matcher = emailPattern.matcher(email);
        return matcher.matches();
    }
    //End of SFDC-1552
    
      //	Added by Exafort for SFDC-1664
      //	This method set the Timer Expiry Date based on the Status and Sub status
    public Static DateTime applyTimerDuration(Case cas, String selectedStatus, String selectedSubStatus, Boolean selectedX3Strike) {
        DateTime timerExpiryDateVar;
        DateTime timerExpiryDateVarSave;
        
        List<Case_Sub_Status_Mapping__c> mappingList;
        if (String.isNotBlank(selectedSubStatus)) {
            
            mappingList = [
                SELECT Default_Timer_in_Minutes__c
                FROM Case_Sub_Status_Mapping__c
                WHERE Status__c = :selectedStatus AND Sub_Status__c = :selectedSubStatus
                LIMIT 1 ];
        } else {
            mappingList = [
                SELECT Default_Timer_in_Minutes__c
                FROM Case_Sub_Status_Mapping__c
                WHERE Status__c = :selectedStatus
                LIMIT 1 ];
        }
        System.Debug('The Record type'+Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(cas.RecordTypeId).getName());
        
        
        if (!mappingList.isEmpty() && mappingList[0].Default_Timer_in_Minutes__c != null) {
            if (selectedSubStatus != null && (selectedStatus != 'Waiting on Customer' || (selectedStatus == 'Waiting on Customer' && selectedX3Strike && (cas == null || cas.Id != null)))){
                DateTime gmtNow = System.now(); 
                TimeZone userTimeZone = UserInfo.getTimeZone(); 
                Integer offsetInMinutes = userTimeZone.getOffset(gmtNow) / 60000; 
                DateTime userTime = gmtNow.addMinutes(offsetInMinutes); 
                timerExpiryDateVar = userTime.addMinutes((Integer)mappingList[0].Default_Timer_in_Minutes__c);
                timerExpiryDateVarSave = System.Now().addMinutes((Integer)mappingList[0].Default_Timer_in_Minutes__c);
                cas.Timer_Expiry_Date__c = timerExpiryDateVarSave;
                cas.Timer_Expiry_Date_Change_for_Scheduled__c = timerExpiryDateVarSave;
                cas.Timer_Expiry_Override_Date__c = null;
            }
            else{
                resetTimerFields(cas);
                
            }
        } else {
            // Optionally handle no mapping found
            resetTimerFields(cas);
        }
        return timerExpiryDateVar;
    }
    
    private static void resetTimerFields(Case cas){
        cas.Timer_Expiry_Date__c = null;
        cas.Timer_Expiry_Date_Change_for_Scheduled__c = null;
        cas.Timer_Expiry_Override_Date__c = null;
        cas.Timer_Expiry_Date_Overridden__c =False;
    }
    // End  for SFDC-1664
   
    /*
     * 	Checks if the provided email is in OrgWideEmailAddress list, returns true if found else Returns false;
	*/
    public static boolean isOrgwideEmailAddress(string emailAddress){
        List<OrgWideEmailAddress> owaList = [SELECT Id, Address From OrgWideEmailAddress WHERE Address = :emailAddress];
        if(owaList != null && owaList.size() > 0){
            return true;
        }
        return false;
    }

    public static List<String> getPachinkoCodeListFromCustomSettings(){
        List<String> codeList = new List<String>();
        Map<String, PachinkoCaseTypes__c> csMap = PachinkoCaseTypes__c.getAll();
        for (PachinkoCaseTypes__c cs : csMap.values()) {
            codeList.add(cs.Code__c);
        }
        return codeList;
    }
    
    public static boolean isNimbleSupportUser(){
        return (NIMBLE_SUPPORT_USER_ID == UserInfo.getUserId());
    }
    
    public static boolean isSupportAutomationUser(){
        return (SUPPORT_AUTOMATION_USER_ID == UserInfo.getUserId());
    }
    // Added for Exafort SFDC-1988
    public static Boolean isSupportProviderProfileUser() {
        return (SUPPORT_PROVIDER_PROFILE_ID == UserInfo.getProfileId());
    }
    public static Boolean isSupportProviderH3CProfileUser() {
        return (SUPPORT_PROVIDER_H3C_PROFILE_ID == UserInfo.getProfileId());
    }
    // End of Exafort SFDC-1988
}