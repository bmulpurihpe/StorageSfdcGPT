/**
 * Created: 25-Jul-13
 */
global with sharing class SPIFFClaim {
    
    private final static String STATUS_DRID_NOT_FOUND = 'DRID not found';
    private final static String STATUS_UNCONVERTED_LEAD_NO_OPP = 'Unconverted Lead (no Oppty)';
    private final static String STATUS_CONVERTED_LEAD_NO_OPP = 'Converted Lead (no Oppty)';
    private final static String STATUS_RESOLVED = 'Resolved';
    private final static String DUPLICATE_INFO_SAME_DRID_SUBMITTED = 'Same DRID Submitted';
    private final static String DUPLICATE_INFO_SAME_DRID_FOUND = 'Same DRID Found';
    private final static String DUPLICATE_INFO_NA = 'N/A';
    private final static String CLAIM_STATUS_PENDING = 'Pending';
    private final static String ERR_NOT_FOUND_RECORDTYPE = 'SPIFF Claim Record Type not found. Please verify its spelling on the SPIFF Reference record.';
    private static Boolean updatedClaim = false;
    
    private static Boolean isExecuteFromClaimTrigger = false;

    private static List<SPIFF_Claim__c> lstPrimaryClaim2Update = new List<SPIFF_Claim__c>();
    
    /**
     * Whenever Opportunity is updated all related claims should be updated
     * Call from trigger UpdateOpportunitySPIFF_Claim on event after update
     */
    public static void updateSPIFFClaim(List<Opportunity> lopp){
        if(updatedClaim) return;
        /*HCS 07.10.2013
          it works only for SPIFF Claim records that have the Claim_Processed__c field = FALSE.
        */
        List<SPIFF_Claim__c> lc = [ Select SPIFF_Reference__c, SPIFF_Program_Name__c, RecordTypeId, CurrencyIsoCode, Claim_Status__c, Opportunity_Updated__c, Manual_Update__c,
                                    Deal_Registration_ID_webform__c, Internal_Status__c, Opportunity__c, Reseller_Account__c, Update_SPIFF_Claim__c, 
                                    Lead_ID__c, Lead_Name__c, Lead_Company__c, Lead_Status__c, CH_Reg_Submit_Date__c, Duplicate_Info__c,Primary__c
                                    From SPIFF_Claim__c Where Opportunity__c IN: lopp and Claim_Processed__c = false ORDER BY CreatedDate];
        updateSPIFFClaim(lc);

        for(SPIFF_Claim__c claim : lc){
            claim.Opportunity_Updated__c = true;
        }
        update lc;
        //To enable history shown
        for(SPIFF_Claim__c claim : lc){
            claim.Opportunity_Updated__c = false;
        }
        update lc;
        //updatedClaim = true;


        updatePrimaryClaim();

    }
    
    /**
     * Whenever SPIFF Reference is updated all related claims should be updated
     * Call from trigger UpdateSPFRefSPIFF_Claim on event after update
     */
    public static void updateSPIFFClaim(List<SPFRef__c> lref){
        if(updatedClaim) return;
        
         /*HCS 07.10.2013
          it works only for SPIFF Claim records that have the Claim_Processed__c field = FALSE.
        */
        List<SPIFF_Claim__c> lc = [ Select SPIFF_Reference__c, SPIFF_Program_Name__c, RecordTypeId, CurrencyIsoCode, Claim_Status__c, Reference_Updated__c, Manual_Update__c,
                                    Deal_Registration_ID_webform__c, Internal_Status__c, Opportunity__c, Reseller_Account__c, Update_SPIFF_Claim__c,
                                    Lead_ID__c, Lead_Name__c, Lead_Company__c, Lead_Status__c, CH_Reg_Submit_Date__c, Duplicate_Info__c,Primary__c
                                    From SPIFF_Claim__c Where SPIFF_Reference__c IN: lref and Claim_Processed__c = false ORDER BY CreatedDate];
        
        updateSPIFFClaim(lc);
        
        for(SPIFF_Claim__c claim : lc){
            claim.Reference_Updated__c = true;
        }
        update lc;
        //To enable history shown
        for(SPIFF_Claim__c claim : lc){
            claim.Reference_Updated__c = false;
        }
        update lc;

        updatePrimaryClaim();

        //updatedClaim = true;
    
       
    }
    
    /**
     * The button for forcing the Apex functionality to run any time after the SPIFF Claim was created.
     * Button UpdateSPIFF_Claim on SPIFF_Claim__c details page layout
     */
    /*
    ** Modified : only process for Claim that is not Primary
    ** Modified date : 24 Feb 2016
    ** @author :    Mony
    */
    webservice static String manualUpdateSPIFF_Claim(String claimId){

        List<SPIFF_Claim__c> lc = [ Select SPIFF_Reference__c,SPIFF_Program_Name__c, RecordTypeId, CurrencyIsoCode, Claim_Status__c, Update_SPIFF_Claim__c,
                        Deal_Registration_ID_webform__c, Internal_Status__c, Opportunity__c, Reseller_Account__c, Manual_Update__c,
                        Lead_ID__c, Lead_Name__c, Lead_Company__c, Lead_Status__c, CH_Reg_Submit_Date__c, Duplicate_Info__c,Primary__c
                        From SPIFF_Claim__c Where Id =: claimId];
        try{
            updateSPIFFClaim(lc);
            update lc;
        }catch(Exception ex){
            return ex.getMessage();
        }

        updatePrimaryClaim();

        return '';
    }
    
    /**
     * Execute when Update_SPIFF_Claim__c = true & Manual_Update__c = true
     * Call from trigger UpdateSPIFF_Claim on event before insert
     */
    public static void updateSPIFFClaimByFieldCheck(List<SPIFF_Claim__c> lstClaim){
    	List<SPIFF_Claim__c> lstToUpdate = new List<SPIFF_Claim__c>();
        for(SPIFF_Claim__c claim : lstClaim){
        	if(claim.Manual_Update__c && claim.Update_SPIFF_Claim__c) lstToUpdate.add(claim);
        }
        updateSPIFFClaim(lstToUpdate);
        //Reset require update
        for(SPIFF_Claim__c c : lstToUpdate){
        	c.Manual_Update__c = false;
        	c.Update_SPIFF_Claim__c = false;
        }
    }
    
    /**
     * Execute all funtionalities 1,2,3,4,5,6
     * Call from trigger UpdateSPIFF_Claim on event before insert
     */
    public static void updateSPIFFClaim(List<SPIFF_Claim__c> lstClaim){
        
        if(updatedClaim && !Test.isRunningTest()) return;
        
        //#1
        lookupSPIFF_Reference(lstClaim);
        //#2,3,4
        updateClaimByDRID(lstClaim);
        
        //#5 
        updateDuplicateInfo(lstClaim);    

        //#6
        setClaimStatusPending(lstClaim);

        updatedClaim = true;

        if(isExecuteFromClaimTrigger) updatePrimaryClaim();
    }
    
    /**
     * 1.Lookup the SPIFF Reference record linked to the SPIFF Claim record(Part of 1)
     * Call from trigger CheckClaimRecordType on event before insert, before update
     */
    public static void doCheckClaimRecordType(List<SPFRef__c> lstRef){
        Set<String> sRecType = new Set<String>();
        for(SPFRef__c ref : lstRef)
            sRecType.add(notNullString(ref.SPIFF_Claim_Record_Type__c));
        Map<String, String> mRecordTypeId = new Map<String, String>();
        for(RecordType rt : [Select Name, Id From RecordType Where SObjectType = 'SPIFF_Claim__c' And Name IN: sRecType]) 
            mRecordTypeId.put(rt.Name, rt.Id);
        for(SPFRef__c ref : lstRef){
            if(ref.SPIFF_Claim_Record_Type__c == null) continue;
            String recordType = mRecordTypeId.get(notNullString(ref.SPIFF_Claim_Record_Type__c));
            if(recordType == null) ref.SPIFF_Claim_Record_Type__c.addError(ERR_NOT_FOUND_RECORDTYPE);
        }
    }
    
    /**
     * 1.Lookup the SPIFF Reference record linked to the SPIFF Claim record and set the following fields on the SPIFF Claim record, 
     * with the values found in the SPIFF Reference 
     */
    private static void lookupSPIFF_Reference(List<SPIFF_Claim__c> lstClaim){

        System.debug('=====lookupSPIFF_Reference() PROCESS');
        Set<String> setRef = new Set<String>();
        for(SPIFF_Claim__c claim : lstClaim){
            if(claim.SPIFF_Reference__c == null) continue;
            setRef.add(claim.SPIFF_Reference__c);
        }
        // Query References and RecordTypes
        Set<String> sRecType = new Set<String>();
        Map<String, String> mRecordTypeId = new Map<String, String>();
        Map<Id, SPFRef__c> mRef = new Map<Id,SPFRef__c>([Select Id, SPIFF_Claim_Record_Type__c, CurrencyIsoCode From SPFRef__c Where Id IN: setRef]);
        for(SPFRef__c ref : mRef.values()) 
            sRecType.add(notNullString(ref.SPIFF_Claim_Record_Type__c));
        for(RecordType rt : [Select Name, Id From RecordType Where SObjectType = 'SPIFF_Claim__c' And Name IN: sRecType]) 
            mRecordTypeId.put(rt.Name, rt.Id);
        
        //Populate Fields CurrencyIsoCode, RecordType
        for(SPIFF_Claim__c claim : lstClaim){
            if(claim.SPIFF_Reference__c == null) continue;
            SPFRef__c ref = mRef.get(claim.SPIFF_Reference__c);
            if(ref == null) continue;
            String recordType = mRecordTypeId.get(notNullString(ref.SPIFF_Claim_Record_Type__c));
            if(recordType == null){
                claim.RecordTypeId.addError(ERR_NOT_FOUND_RECORDTYPE);
                continue;
            }
            claim.CurrencyIsoCode = ref.CurrencyIsoCode;
            claim.RecordTypeId = recordType;
           
        }

        System.debug('=====lookupSPIFF_Reference() FINISHED');
    } 
    
    /**
     * 2. Lookup the Deal Registration ID (webform): 
     * It is expected to be the Lead ID of a Lead that was previously converted to an Opportunity. 
     * 3. Set the Opportunity lookup field & Reseller_Account__c on the SPIFF Claim record with the record ID found (if found)
     * Also: 4
     */
    private static void updateClaimByDRID(List<SPIFF_Claim__c> lstClaim){

        System.debug('=====updateClaimByDRID() PROCESS');

        Set<String> sDRID = new Set<String>();
        for(SPIFF_Claim__c claim : lstClaim){
            try{
                Id validId = claim.Deal_Registration_ID_webform__c;
                if(validId != null) sDRID.add(validId);
            }catch(Exception e){
                //Invalid data input
            }
        }
        Map<String, Lead> mLead = new Map<String, Lead>();
        for(Lead ld : [Select Id, Status, Name, IsConverted, ConvertedOpportunityId, Company, CH_Registration_Submission_Date__c From Lead Where Id IN: sDRID]){
            mLead.put(idTo15Chars(ld.Id), ld);
        }

        Set<String> sOppId = new Set<String>();
        for(SPIFF_Claim__c claim : lstClaim){
            // Update the Internal Status field on the SPIFF Claim record according to the following criteria
            Lead lead = mLead.get(notNullString(claim.Deal_Registration_ID_webform__c));
            // No Lead with this DRID (Lead ID) was found
            if(lead == null) claim.Internal_Status__c = STATUS_DRID_NOT_FOUND;
            // Unconverted Lead found (no Opportunity)
            else if(!lead.isConverted) claim.Internal_Status__c = STATUS_UNCONVERTED_LEAD_NO_OPP;
            // Converted Lead found (no Opportunity)
            else if(lead.isConverted && lead.ConvertedOpportunityId == null) claim.Internal_Status__c = STATUS_CONVERTED_LEAD_NO_OPP;
            // Converted Lead found (and Opportunity found)
            else if(lead.isConverted && lead.ConvertedOpportunityId != null) claim.Internal_Status__c = STATUS_RESOLVED;
            
            // Set the Opportunity
            if(lead != null && lead.ConvertedOpportunityId != null) sOppId.add(lead.ConvertedOpportunityId);
            
            // Lookup the converted Lead by its ID 
            if(lead != null) setClaimWithConvertedLeadInfo(claim, lead);
            
        }
        
        // Set the Opportunity lookup field and Reseller Account
        Map<String, Opportunity> mOpp = new Map<String, Opportunity>([Select Id, Reseller_Account__c From Opportunity Where Id IN: sOppId]);
        for(SPIFF_Claim__c claim : lstClaim){
            Lead lead = mLead.get(notNullString(claim.Deal_Registration_ID_webform__c));
            if(lead != null && lead.ConvertedOpportunityId != null){
                claim.Opportunity__c = lead.ConvertedOpportunityId;
                claim.Reseller_Account__c = mOpp.get(lead.ConvertedOpportunityId).Reseller_Account__c;
            }
        }

        System.debug('=====updateClaimByDRID() FINISHED');
    }
    
    /**
     * 4. Lookup the converted Lead by its ID, query information from the converted Lead and write this information onto the SPIFF Claim record
     * Call from method updateClaimByDRID
     */
    private static void setClaimWithConvertedLeadInfo(SPIFF_Claim__c claim, Lead lead){
        claim.Lead_ID__c = idTo15Chars(lead.Id);
        claim.Lead_Name__c = lead.Name;
        claim.Lead_Company__c = lead.Company;
        claim.Lead_Status__c = lead.Status;
        claim.CH_Reg_Submit_Date__c = lead.CH_Registration_Submission_Date__c;
    }
    
    /**
     * 5. Update the Duplicate Info field of the SPIFF Claim record according to the following criteria: 
     * SPIFF Claim record with DRID submitted exists
     * SPIFF Claim record with DRID found exists
     */
     
     /**
      * Modified Date : 24-Feb-16
      * Modified By : Mony
      *	Description : For New Duplicate Functionality which controll by Custom Setting that act as Switch ON/OFF
      *  - if CustomSetting is unchecked (OFF) , Old functionality will apply 
      *    When Claim #2 is created and identified as a duplicate, set the “Primary” checkbox on Claim #1 to be TRUE for have field DRID the same.
      *  - if CustomSetting is checked (ON) , New functionality will apply 
      *    When Claim #2 is created and identified as a duplicate, set the “Primary” checkbox on Claim #1 to be TRUE for have field SPIFF Program Name  and DRID the same.	 
      */

    private static void updateDuplicateInfo(List<SPIFF_Claim__c> lstClaim){

        System.debug('=====updateDuplicateInfo() PROCESS');
    	
        //For reference variable purpose
        Map<Id,SPIFF_Claim__c> mapClaim = new Map<Id,SPIFF_Claim__c>();

        // 1) add code Manage of Custom Setting for Control of Updating Field Duplicate_Info__c
    	SPIFFClaimSetting__c settings = SPIFFClaimSetting__c.getInstance('Duplicates Checked Mode');
  		Boolean checkNameMode = (settings != null)?settings.SPIFF_Program_Name_Mode__c:false;
    	
        // Only claim with DRID are taken in account
        Set<String> setDRID_Lead = new Set<String>();
        List<SPIFF_Claim__c> lstClaimWithoutId = new List<SPIFF_Claim__c>();

        for (SPIFF_Claim__c claim : lstClaim) {
            
            //Store Claim without ID in case this method call from SPIFF CLAIM Befor Trigger which we cannot query from system
            if (claim.Id == NULL) lstClaimWithoutId.add(claim);       

            // Check Duplicate DRID or Lead 
            if (claim.Deal_Registration_ID_webform__c != null) setDRID_Lead.add(claim.Deal_Registration_ID_webform__c);
            if (claim.Lead_ID__c != null) setDRID_Lead.add(claim.Lead_ID__c);
            
            // Check Duplicate SPIFF Program Name only when checkNameMode is ON (TRUE)
            if(checkNameMode && claim.SPIFF_Program_Name__c != null) setDRID_Lead.add(claim.SPIFF_Program_Name__c);  
        }

        System.debug('>>>>setDRID_Lead: ' + setDRID_Lead);

        if(lstClaimWithoutId.size()>0) isExecuteFromClaimTrigger = true;
        else
            mapClaim = new Map<Id,SPIFF_Claim__c>(lstClaim); 
        
        System.debug('>>>>mapClaim: ' + mapClaim);

        List<SPIFF_Claim__c> allClaim = new List<SPIFF_Claim__c>();
        
        if(checkNameMode)
            allClaim.addAll([Select Lead_ID__c, Deal_Registration_ID_webform__c, SPIFF_Program_Name__c,CreatedDate,Primary__c,Duplicate_Info__c From SPIFF_Claim__c Where (ID NOT IN: lstClaim OR ID IN: lstClaim) And (Deal_Registration_ID_webform__c IN: setDRID_Lead OR Lead_ID__c IN: setDRID_Lead) AND SPIFF_Program_Name__c IN: setDRID_Lead order by CreatedDate,Name]);
        else
            allClaim.addAll([Select Lead_ID__c, Deal_Registration_ID_webform__c, SPIFF_Program_Name__c,CreatedDate,Primary__c,Duplicate_Info__c From SPIFF_Claim__c Where (ID NOT IN: lstClaim OR ID IN: lstClaim) And (Deal_Registration_ID_webform__c IN: setDRID_Lead OR Lead_ID__c IN: setDRID_Lead OR SPIFF_Program_Name__c IN: setDRID_Lead) order by CreatedDate,Name]);
        
        allClaim.addAll(lstClaimWithoutId);

        Map<String, list<SPIFF_Claim__c>> mapClaim2Process = new Map<String, list<SPIFF_Claim__c>>();
        for(SPIFF_Claim__c claim : allClaim){

            //CheckNameMode = TRUE => Check Duplicated SPIFF-Programm & DRID
            if(checkNameMode){

                if(claim.Deal_Registration_ID_webform__c != null && claim.SPIFF_Program_Name__c != null){

                    //Key : SPIFF-Program Name $ DRID    
                    String duplicateKey = claim.SPIFF_Program_Name__c + '#' + claim.Deal_Registration_ID_webform__c;

                    if(mapClaim2Process.get(duplicateKey) == null) mapClaim2Process.put(duplicateKey, new List<SPIFF_Claim__c>());
                    mapClaim2Process.get(duplicateKey).add(claim);
                }        

            }

            //CheckNameMode = FALSE => Check Duplicated DRID/LEAD
            else{
                //Check Duplicated DRID
                if(claim.Deal_Registration_ID_webform__c != null){

                    //Key : DRID
                    if(mapClaim2Process.get(claim.Deal_Registration_ID_webform__c) == null) mapClaim2Process.put(claim.Deal_Registration_ID_webform__c, new List<SPIFF_Claim__c>());
                    mapClaim2Process.get(claim.Deal_Registration_ID_webform__c).add(claim);
                }
                //Check Duplicated Lead
                if(claim.Lead_ID__c != null){
                    
                    //Key : Lead
                    if(mapClaim2Process.get(claim.Lead_ID__c) == null) mapClaim2Process.put(claim.Lead_ID__c, new List<SPIFF_Claim__c>());
                    mapClaim2Process.get(claim.Lead_ID__c).add(claim);
                }
            }
            
        }

        for(String key : mapClaim2Process.keySet()){
            System.debug('>>>> ' + key);
            for(integer i=0; i<mapClaim2Process.get(key).size(); i++){
                System.debug('>>>>>>>> ' + mapClaim2Process.get(key).get(i).Id + ', ' + mapClaim2Process.get(key).get(i).Primary__c);
            }
        }

        Set<String> keyPrimaryClaims = new Set<String>();
        //Process through all claims records which pass via Parameters
        for(SPIFF_Claim__c claim : lstClaim){
           
            //claim.Duplicate_Info__c = DUPLICATE_INFO_NA;
            //claim.Primary__c = false;

            String duplicateKey = (checkNameMode)?claim.SPIFF_Program_Name__c + '#' + ((claim.Deal_Registration_ID_webform__c!=null)?claim.Deal_Registration_ID_webform__c:claim.Lead_ID__c):((claim.Deal_Registration_ID_webform__c!=null)?claim.Deal_Registration_ID_webform__c:claim.Lead_ID__c);
            System.debug('>>>>duplicateKey: ' + duplicateKey);

            if(mapClaim2Process.get(duplicateKey) != null && mapClaim2Process.get(duplicateKey).size() > 1){

                //When Switch is ON Mark as Duplicate on Claim that the same SPIFF-Program and DRID [New Functionality]
                if(checkNameMode){

                    if(claim.Id == NULL || !(claim.Id == mapClaim2Process.get(duplicateKey).get(0).Id)){
                        claim.Duplicate_Info__c = DUPLICATE_INFO_SAME_DRID_SUBMITTED;
                        claim.Primary__c = false;
                    }
                    
                    keyPrimaryClaims.add(duplicateKey);

                }
                //When Switch is OFF Mark as Duplicate on Claim that the same DRID/LEAD (in case DRID is NULL) [Old Functionality]
                else{

                    if(claim.Deal_Registration_ID_webform__c != null){
                        claim.Duplicate_Info__c = DUPLICATE_INFO_SAME_DRID_SUBMITTED;
                        claim.Primary__c = false;
                        keyPrimaryClaims.add(duplicateKey);
                    }
                    else if(claim.Lead_ID__c != null){

                        claim.Duplicate_Info__c = DUPLICATE_INFO_SAME_DRID_FOUND;

                    }                        
                }

            }else{
                claim.Duplicate_Info__c = DUPLICATE_INFO_NA;
                claim.Primary__c = false;
            }

        }
        
        System.debug('>>>>keyPrimaryClaims: ' + keyPrimaryClaims);

        //Update the earliest Claims to Primary, in case there are duplication for Both Old and New Functionality
       for(String key : keyPrimaryClaims){
			
            if(mapClaim2Process.get(key)!= null) {
            //if(mapClaim2Process.get(key)!= null && (!mapClaim2Process.get(key).get(0).Primary__c || mapClaim2Process.get(key).get(0).Duplicate_Info__c != DUPLICATE_INFO_NA)) {
                
                SPIFF_Claim__c cl = mapClaim2Process.get(key).get(0);
                
                if(cl.Id != null && mapClaim.get(cl.Id) != null){
                    
                    mapClaim.get(cl.Id).Duplicate_Info__c = (mapClaim.get(cl.Id).Duplicate_Info__c != DUPLICATE_INFO_NA)?DUPLICATE_INFO_NA:mapClaim.get(cl.Id).Duplicate_Info__c;
                    mapClaim.get(cl.Id).Primary__c = (!mapClaim.get(cl.Id).Primary__c)?true:mapClaim.get(cl.Id).Primary__c;        
                    continue;
                }                    
                
                cl.Duplicate_Info__c = (cl.Duplicate_Info__c != DUPLICATE_INFO_NA)?DUPLICATE_INFO_NA:cl.Duplicate_Info__c;
                cl.Primary__c = (!cl.Primary__c)?true:cl.Primary__c;
                if(cl.Id != null) lstPrimaryClaim2Update.add(cl);
                
            }        
        }

        System.debug('=====updateDuplicateInfo() FINISHED');
    }
     
    /**
     * 6. Set the SPIFF Claim Status field to “Pending”.
     * Call from method updateClaimByDRID
     */
    private static void setClaimStatusPending(List<SPIFF_Claim__c> lstClaim){
        
        System.debug('=====setClaimStatusPending() PROCESS');
        
        for(SPIFF_Claim__c claim : lstClaim){
            System.debug('>>>>claim status: ' + claim.Claim_Status__c + ', ' + claim.Duplicate_Info__c );
            if(claim.Duplicate_Info__c == DUPLICATE_INFO_NA) claim.Claim_Status__c = CLAIM_STATUS_PENDING;
        }

        System.debug('=====setClaimStatusPending() FINISHED');
    }
  
     
    /**
     * Small method replace null to empty string
     */
    private static String notNullString(String val){
        return val == null ? '' : val;
    }
    
    /**
     * Convert Id 18 to 15 chars
     */
    public static String idTo15Chars(String val){
        if(val != null && val.length() > 15) return val.substring(0,15);
        return val;
    }
    
    private static void updatePrimaryClaim(){

        System.debug('=====PROCESS updatePrimaryClaim()');
        System.debug('lstPrimaryClaim2Update: ' + lstPrimaryClaim2Update);
        
        update lstPrimaryClaim2Update;
        lstPrimaryClaim2Update.clear();
    }
    
}