public with sharing class rmav2ExtensionsWithSharingNewV2 {
    
    public String geocodingKey {get;set;}
    //General Variables
    public RMAv2__c rma{get;set;}
    private ApexPages.StandardController controller;
    private integer totalRecs = 0;
    private integer OffsetSize = 0;
    private integer LimitSize= 50;
    
    //Component Section Variables
    public transient Map<String,Map<String,List<List<Component__c>>>> assetOuterMap {get;set;} 
    //TS-6880 modified the assetOuterMap to hold List<List<Comp> to fix the Collection size exceeds maximum size issue.
    //public transient Map<String,Map<String,List<Component__c>>> assetOuterMap {get;set;}
    public transient  Map<String,String> assetIdbyKey {get;set;}
    public transient Map<String,String> parentAssetMap{get;set;}
    public transient  Map<String,String> assetProductNameMap{get;set;}
    public string currrentAccountName{get;set;}
    public string linkedAssetId{get;set;}
    public string linkedCaseAssetName{get;set;}
    public string linkedDiskAssetName{get;set;}
    // Added by exafort for TS-9340
    public string linkedAssetType{get;set;}
    public string linkedCaseAssetType{get;set;}
    public string flatListSelection{get;set;}
    public string linkedAssetName{get;set;}
    // Added end
    
    public string assetToExpand{get;set;}
    public Boolean checkedBox{get;set;}
    public String partScreenSelection { get; set; }    
    public string selectedAssetForRMA{get;set;}
    public string selectedComponentForRMA{get;set;}
    
    //SR Meta Data Section Variables
    public transient Map<string, SR_Meta_Data__c> srMetaDataMap {get;set;}
    public transient Map<string, SR_Meta_Data__c> srMetaDataMapByName {get;set;}
    
    //Shipment Label Detail Section Variables
    public string shpAccountName{get;set;}
    public string shpLabelAssetContact{get;set;}
    public string shpLabelStreet1{get;set;}
    public string shpLabelStreet2{get;set;}
    public string shpLabelCity{get;set;}
    public string shpLabelState{get;set;}
    public string shpLabelPostalCode{get;set;}
    public string shpLabelCountry{get;set;}
    public string shpLabelContactPhone{get;set;}
    public string shpLabelContactEmail{get;set;}
    
    //Address Validation Variables
    public DateTime shpLocationValidationOn{get;set;}
    public ID addressBookId = null;
    public ID addressBookLinkedId = null;
    public string strShipmentLocationValidatedOn{get;set;}
    
    //Show or Hide Section Variables
    public boolean alwaysShownOnSiteSection{get;set;}
    public boolean alwaysShownReturnSection{get;set;}
    public boolean shownEFAPriority{get;set;}
    public boolean shownDeliveryDateAndTime{get;set;}
    public boolean hideOnSiteSections{get;set;}  
    public boolean hideReturnSections{get;set;}  
    public boolean assetNrdIsInEffect{get;set;}
    
    //RMA SHI Section variables
    public List<String> checkboxTransmitRMASelections{get;set;}
    public string strAccountRMASHIText{get;set;}
    public string strAssetRMASHIText{get;set;} 
    
    public string ComponentAccountId{get;set;}
    public string ComponentAccountName{get;set;}
    
    //Esclation
    public string escalationType{get;set;}
    public string selectedSrPart{get;set;}
    
    public string efaSourceValue{get;set;}
    
    public boolean shipOnlyPart{get;set;}
    
    public boolean autoEFAPart{get;set;}
    public string nimbleOsVersion{get;set;}
    public boolean rmaCancelationReasonShowOrHide{get;set;}
    
    //Added by exafort(vishnu) on 21st Jan 2018 TS-5318
    public string rmaPartForOnsiteValidation;
    public string casePachinkoType;
    public string casePachinkoTypeForRMANew;
    public String AssetSLA;
    public string OnsiteValueForSLANBD;
    //Added by exafort TS-9679
    public Map<string,string> reasonWithToolTipMap{get;set;}    
    //Added by exafort for 10402
    public String onsitePartHandoverCode{get;set;}
    public String onsiteSchedulingCode{get;set;}
    public String onsiteSchedulingNotes{get;set;}
    public String onsitePartHandoverNotes{get;set;}
    public String onsiteCheckInCode{get;set;}
    public String onsiteCheckInNotes{get;set;}
    public String onsitePartDispositionCode{get;set;}
    public String onsitePartDispositionNotes{get;set;}
    //End of TS-10402
    
    // Added by Exafort for TS-10419
    public Boolean chinaGlobalAccount {get;set;}
    public Boolean assetSlaisNotOnsite {get;set;}
    
    // Added by Exafort for TS-10592
    public string NSBusinessAdminSupportProfileId{get;set;}

    // Added by Exafort for SFDC-471
    public List<SelectOption> cancellationPicklistOptions{get;set;}
    
    // Added by Exafort for SFDC-627
    public Id caseNumber { get; set; }
    public String rmaCaseNumber;
    public Id assetId;
    
    // Added by Exafort for SFDC-600
    public List<SelectOption> depotOptions { get; set; }
    public String selectedDepot { get; set; }
    public String rmaOutgoingShipmentDepot { get; set; }
    
    //###################################################################################################### rmav2ExtensionsWithSharingNewV2
    public rmav2ExtensionsWithSharingNewV2(ApexPages.StandardController controller) {
        
        // Added by Exafort for TS-10419
        chinaGlobalAccount = false;
        assetSlaisNotOnsite = True;
        
        // Added by Exafort for SFDC-600
        depotOptions = new List<SelectOption>();
        //fetchDepotOptions();
        
        onsiteServiceFieldReset();//Added by exafort for TS-10402 
        
        //Added by exafort TS-9679
        reasonWithToolTipMap = new map<string,string>(); 
        list<RMA_Reason_ToolTip__mdt> allReason = [Select id,label,Tool_Tips__c,Reason__c from RMA_Reason_ToolTip__mdt];
        for(RMA_Reason_ToolTip__mdt reasonsval : allReason){
            reasonWithToolTipMap.put(reasonsval.Reason__c,reasonsval.Tool_Tips__c);
        } 
        
        checkboxTransmitRMASelections= new List<string>();   
        this.controller = controller;
        checkedBox = true;
        //capture the Google Map key from custom setting
        geocodingKey = X4HourDepotCalculationSetting__c.getInstance().GoogleServerKey__c;
        
        rma=(RMAv2__c) controller.getRecord();
        fetchDepotOptions();
        if (rma.Id == null)
            rmaNewRecord();
        else
            rmaEditRecord();
        // Added by Exafort for TS-10419
        /*if(rma.rmaAddressBook__c != null && rma.rmaCaseNumber__c != null){
            AddressBook__c addressBook = [select Id,abCountry__c from AddressBook__c Where id =:rma.rmaAddressBook__c];
            chinaGlobalAccount = isGlobalChinaH3cCase(rma.rmaCaseNumber__c,addressBook.abCountry__c);  
        }*/
        // End of TS-10419
         
        
        // Added by Exafort for SFDC-471
        cancellationPicklistOptions = new List<SelectOption>();
        cancellationPicklistOptions.add(new SelectOption('', '--None--'));
        if(chinaGlobalAccount == True || rma.China_Global_Account_RMA__c == True){
            cancellationPicklistOptions.add(new SelectOption('Shipment Address Incorrect', 'Shipment Address Incorrect'));
            cancellationPicklistOptions.add(new SelectOption('Issue resolved by Engineering/Customer/Support', 'Issue resolved by Engineering/Customer/Support'));
            cancellationPicklistOptions.add(new SelectOption('Account/Asset/RMA SHI miscommunication', 'Account/Asset/RMA SHI miscommunication'));
            cancellationPicklistOptions.add(new SelectOption('Wrong part selected', 'Wrong part selected'));
        }
        else{
            cancellationPicklistOptions.add(new SelectOption('Shipment Address Incorrect', 'Shipment Address Incorrect'));
            cancellationPicklistOptions.add(new SelectOption('Updated Shipment Address ', 'Updated Shipment Address '));
            cancellationPicklistOptions.add(new SelectOption('Issue Resolved by Engineering ', 'Issue Resolved by Engineering '));
            cancellationPicklistOptions.add(new SelectOption('RMA SHI miscommunicated ', 'RMA SHI miscommunicated '));
            cancellationPicklistOptions.add(new SelectOption('Asset SHI unclear', 'Asset SHI unclear'));
            cancellationPicklistOptions.add(new SelectOption('Customer Environment Noted After RMA created', 'Customer Environment Noted After RMA created'));
            cancellationPicklistOptions.add(new SelectOption('Customer provided a different location based on SLA & hours', 'Customer provided a different location based on SLA & hours'));
            cancellationPicklistOptions.add(new SelectOption('Out of Stock - part will ship from HQ', 'Out of Stock - part will ship from HQ'));
            cancellationPicklistOptions.add(new SelectOption('Wrong Part Shipped', 'Wrong Part Shipped'));
            cancellationPicklistOptions.add(new SelectOption('Wrong Part Selected', 'Wrong Part Selected'));
            cancellationPicklistOptions.add(new SelectOption('Ops request - Acct team to submit SO', 'Ops request - Acct team to submit SO'));
            cancellationPicklistOptions.add(new SelectOption('Ops Part Change - cancel and Update to new part', 'Ops Part Change - cancel and Update to new part'));
        }
        // End of SFDC-471
        
        // Added by Exafort for TS-10592
        setNSBusinessAdminSupportProfileId();
        
        // Added by Exafort for SFDC-627
        // If condition added by exafort for SFDC-844
        if (rma.Id == null){
            flatListSelection = 'Based On Head and All Related Assets';
        }
        rmaCaseNumber = rma.rmaCaseNumber__c;
        
        // Added by Exafort for TS-10970
        String casePachinkoTypes = rma.rmaCaseNumber__r.casePachinkoCaseType__c;
        system.debug('casePachinkoTypes : ' + casePachinkoTypes );
        if (casePachinkoType == 'ssdwearlevelhigh') {
            rma.rmaOnsiteTechStatus__c = 'N/A-10: No onsite for this RMA Type';
        }
        // End of TS-10970
    }
    
    //Added by exafort for 10402
    public void onsiteServiceFieldReset(){
        onsitePartHandoverCode = '';
        onsiteSchedulingNotes = '';
        onsiteSchedulingCode = '';
        onsitePartHandoverNotes = '';
        onsiteCheckInCode = '';
        onsiteCheckInNotes = '';
        onsitePartDispositionCode = '';
        onsitePartDispositionNotes = '';
    }
    //End of TS-10402
    
    //###################################################################################################### rmaEditRecord
    public void rmaEditRecord()
    {
        // rmaCaseNumber__r.Account.Global_Account__c,rmaCaseNumber__r.Account.Support_Provider__r.Name new field added to query by Exafort for TS-10419 
        // Added rmaDiskShelfAsset__r.Asset_Type__c,rmaCaseNumber__r.Asset.Asset_Type__c,Flat_List_Type__c in the below SOQL query by Exafort for TS-9340
        List<RMAv2__c> rmaRecord = new List<RMAv2__c>([Select rmaEFASource__c,rmaCaseNumber__r.casePachinkoCaseType__c,rmaPartNumber__c,
                                                       rmaCaseNumber__r.caseEscalationType__c,rmaCaseNumber__r.Asset.Account.Name,rmaCaseNumber__r.Asset.Name,
                                                       rmaComponentV2__c,rmaSelection__c,rmaDiskShelfAsset__r.Account.Id,rmaDiskShelfAsset__r.Account.Name,
                                                       rmaDiskShelfAsset__r.Name,rmaCaseNumber__r.Asset.assetSameDayPartDeliveryPreference__c,
                                                       rmaDiskShelfAsset__r.assetSameDayPartDeliveryPreference__c,rmaTransmitRmaShisWithOrder__c,
                                                       rmaCaseNumber__r.Asset.assetRmaShi__c,rmaDiskShelfAsset__r.assetRmaShi__c,
                                                       rmaCaseNumber__r.Asset.Account.accountRmaShi__c,rmaDiskShelfAsset__r.Account.accountRmaShi__c,
                                                       rmaShipmentLocationValidated__c,rmaComponent__c,rmaCaseNumber__r.Asset.assetNrdStartDate__c,
                                                       rmaCaseNumber__r.Asset.assetNrdEndDate__c,rmaCaseNumber__r.Asset.Id,rmaCaseNumber__r.Asset.SLA__c, 
                                                       rmaCaseNumber__r.Asset.assetPartShipAddressBook__c,rmaDiskShelfAsset__r.assetPartShipAddressBook__c,
                                                       rmaCaseNumber__r.Asset.assetPartShipLastValidatedDatetime__c,
                                                       rmaDiskShelfAsset__r.assetPartShipLastValidatedDatetime__c,rmaDiskShelfAsset__c,
                                                       rmaDiskShelfAsset__r.assetNrdStartDate__c,rmaDiskShelfAsset__r.assetNrdEndDate__c,rmaDiskShelfAsset__r.SLA__c,
                                                       rmaCaseNumber__r.Asset.Contact.FirstName,rmaCaseNumber__r.Asset.Contact.LastName,
                                                       rmaCaseNumber__r.Asset.Contact.Phone,rmaCaseNumber__r.Asset.Contact.Email,rmaDiskShelfAsset__r.Contact.FirstName,
                                                       rmaDiskShelfAsset__r.Contact.LastName,rmaDiskShelfAsset__r.Contact.Phone,rmaDiskShelfAsset__r.Contact.Email,
                                                       rmaAddressBook__r.abAccount__r.Name,rmaAddressBook__r.abStreet1__c, rmaAddressBook__r.abStreet2__c, 
                                                       rmaAddressBook__r.abCity__c, rmaAddressBook__r.abStateProvince__c, rmaAddressBook__r.abPostalCode__c,
                                                       rmaAddressBook__r.abCountry__c,rmaShipmentStreet2__c,rmaShipmentCountry__c , rmaAssetLocalDateTime__c, 
                                                       rmaDeliveryDate__c, rmaDeliveryTimes__c , rmaAssetSameDayPartDeliveryPreference__c , rmaDeliveryDateTime__c , 
                                                       Asset_Date_and_Time__c , rmaFailedPart__c ,rmaRequestedDeliveryDateTime__c,rmaDiskShelfAsset__r.Asset_Type__c,
                                                       rmaCaseNumber__r.Asset.Asset_Type__c,Flat_List_Type__c,rmaOverrideOnsitePartHandoverCode__c,rmaDiskShelfAsset__r.assetOnsitePartHandoverCode__c,
                                                       rmaDiskShelfAsset__r.assetOnsiteSchedulingNotes__c,rmaDiskShelfAsset__r.assetOnsiteSchedulingCode__c,rmaDiskShelfAsset__r.assetOnsitePartHandoverNotes__c,
                                                       rmaDiskShelfAsset__r.assetOnsiteCheckInCode__c,rmaDiskShelfAsset__r.assetOnsiteCheckInNotes__c,rmaDiskShelfAsset__r.assetOnsitePartDispositionCode__c,
                                                       rmaDiskShelfAsset__r.assetOnsitePartDispositionNotes__c,
                                                       rmaCaseNumber__r.Asset.assetOnsitePartHandoverCode__c,rmaOverrideOnsiteSchedulingNotes__c,rmaOverrideOnsiteSchedulingCode__c,
                                                       rmaOverrideOnsitePartHandoverNotes__c,rmaOverrideOnsiteCheckInCode__c,rmaOverrideOnsiteCheckInNotes__c,rmaOverrideOnsitePartDispositionCode__c,
                                                       rmaOverrideOnsitePartDispositionNotes__c,rmaCaseNumber__r.Asset.assetOnsiteSchedulingNotes__c,rmaCaseNumber__r.Asset.assetOnsiteSchedulingCode__c,
                                                       rmaCaseNumber__r.Asset.assetOnsitePartHandoverNotes__c,rmaCaseNumber__r.Asset.assetOnsiteCheckInCode__c,rmaCaseNumber__r.Asset.assetOnsiteCheckInNotes__c,
                                                       rmaCaseNumber__r.Asset.assetOnsitePartDispositionCode__c,rmaCaseNumber__r.Asset.assetOnsitePartDispositionNotes__c,
                                                       rmaCaseNumber__r.Account.Global_Account__c,rmaCaseNumber__r.Account.Support_Provider__r.Name,rmaAssetSla__c,
                                                       rmaDiskShelfAsset__r.Install_Country__c,rmaDiskShelfAsset__r.Dual_Support_Providers__c,
                                                       rmaDiskShelfAsset__r.Parent_Asset__r.Dual_Support_Providers__c
                                                       from RMAv2__c where Id=:rma.Id Limit 1]);
        // Added by Exafort for TS-10419
        // If Condition updated by Exafort for SFDC-626
        //	rmaDiskShelfAsset__r.Parent_Asset__r.Dual_Support_Providers__c If condition updated by Exafort for SFDC-1999
        if((rmaRecord[0].rmaDiskShelfAsset__r.Install_Country__c  == 'China' || rmaRecord[0].rmaShipmentCountry__c == 'China') && 
           (rmaRecord[0].rmaDiskShelfAsset__r.Dual_Support_Providers__c == True || rmaRecord[0].rmaDiskShelfAsset__r.Parent_Asset__r.Dual_Support_Providers__c == True)){
               chinaGlobalAccount = true;
           }
        if(rmaRecord[0].rmaAssetSla__c != null && rmaRecord[0].rmaAssetSla__c.contains('Onsite')){
            assetSlaisNotOnsite = false;
        }
        // End of TS-10419
        
        //Added by exafort for TS-10402
        if(rmaRecord[0].rmaDiskShelfAsset__c != null){  
            if(isAssetOnsite(rmaRecord[0].rmaDiskShelfAsset__r.SLA__c)){
                
            onsitePartHandoverCode = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsitePartHandoverCode__c,rmaRecord[0].rmaDiskShelfAsset__r.assetOnsitePartHandoverCode__c);
            onsiteSchedulingNotes = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsiteSchedulingNotes__c,rmaRecord[0].rmaDiskShelfAsset__r.assetOnsiteSchedulingNotes__c);
            onsiteSchedulingCode =  onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsiteSchedulingCode__c,rmaRecord[0].rmaDiskShelfAsset__r.assetOnsiteSchedulingCode__c);
            onsitePartHandoverNotes = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsitePartHandoverNotes__c,rmaRecord[0].rmaDiskShelfAsset__r.assetOnsitePartHandoverNotes__c);
            onsiteCheckInCode = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsiteCheckInCode__c,rmaRecord[0].rmaDiskShelfAsset__r.assetOnsiteCheckInCode__c);
           onsiteCheckInNotes = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsiteCheckInNotes__c,rmaRecord[0].rmaDiskShelfAsset__r.assetOnsiteCheckInNotes__c);
            onsitePartDispositionCode = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsitePartDispositionCode__c,rmaRecord[0].rmaDiskShelfAsset__r.assetOnsitePartDispositionCode__c);
            onsitePartDispositionNotes = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsitePartDispositionNotes__c,rmaRecord[0].rmaDiskShelfAsset__r.assetOnsitePartDispositionNotes__c);
            }
        }
        else{
             if(isAssetOnsite(rmaRecord[0].rmaCaseNumber__r.Asset.SLA__c)){
                
            onsitePartHandoverCode = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsitePartHandoverCode__c,rmaRecord[0].rmaCaseNumber__r.Asset.assetOnsitePartHandoverCode__c);
            onsiteSchedulingNotes = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsiteSchedulingNotes__c,rmaRecord[0].rmaCaseNumber__r.Asset.assetOnsiteSchedulingNotes__c);
            onsiteSchedulingCode = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsiteSchedulingCode__c,rmaRecord[0].rmaCaseNumber__r.Asset.assetOnsiteSchedulingCode__c);
            onsitePartHandoverNotes = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsitePartHandoverNotes__c,rmaRecord[0].rmaCaseNumber__r.Asset.assetOnsitePartHandoverNotes__c);
            onsiteCheckInCode = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsiteCheckInCode__c,rmaRecord[0].rmaCaseNumber__r.Asset.assetOnsiteCheckInCode__c);
            onsiteCheckInNotes = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsiteCheckInNotes__c,rmaRecord[0].rmaCaseNumber__r.Asset.assetOnsiteCheckInNotes__c);
            onsitePartDispositionCode = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsitePartDispositionCode__c,rmaRecord[0].rmaCaseNumber__r.Asset.assetOnsitePartDispositionCode__c);
            onsitePartDispositionNotes = onsiteServiceValueGenereator(rmaRecord[0].rmaOverrideOnsitePartDispositionNotes__c,rmaRecord[0].rmaCaseNumber__r.Asset.assetOnsitePartDispositionNotes__c);
             }    
        }  
        //End of TS-10402
        
        //Added by exafort(vishnu) on 21st Jan 2018 TS-5318 get failed Part and pachinko case type to use in checkAssetSLA method -START
        system.debug('### rma Failed part ==>'+rmaRecord[0].rmaFailedPart__c);
        system.debug('### rma part ==>'+rmaRecord[0].rmaPartNumber__c);
        system.debug('### Pachinko Case Type ==>'+rmaRecord[0].rmaCaseNumber__r.casePachinkoCaseType__c);
        system.debug('#### rma selection ==>'+rmaRecord[0].rmaSelection__c);
        if(rmaRecord[0].rmaFailedPart__c != null){
            rmaPartForOnsiteValidation = rmaRecord[0].rmaFailedPart__c;
        }else if(rmaRecord[0].rmaPartNumber__c != null){
            rmaPartForOnsiteValidation = rmaRecord[0].rmaPartNumber__c;
        }
        casePachinkoType = rmaRecord[0].rmaCaseNumber__r.casePachinkoCaseType__c;
        //Added by exafort(vishnu) on 21st Jan 2018 TS-5318-END
        
        rma.rmaDiskShelfAsset__c = rmaRecord[0].rmaDiskShelfAsset__c;
        rma.rmaSelection__c = rmaRecord[0].rmaSelection__c;
        partScreenSelection = 'Component View';
        
        if(rmaRecord.size() == 0)
            return;
        
        if(rmaRecord[0].rmaDiskShelfAsset__c != null)
        {
            shpLabelAssetContact = 'Attn: ' + ((rmaRecord[0].rmaDiskShelfAsset__r.Contact.FirstName!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.Contact.FirstName + ' ' : '') + ((rmaRecord[0].rmaDiskShelfAsset__r.Contact.LastName!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.Contact.LastName: '');
            shpLabelContactPhone = 'Contact Phone: ' + ((rmaRecord[0].rmaDiskShelfAsset__r.Contact.Phone!=null) ?  rmaRecord[0].rmaDiskShelfAsset__r.Contact.Phone: '');
            shpLabelContactEmail = 'Contact Email: ' + ((rmaRecord[0].rmaDiskShelfAsset__r.Contact.Email!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.Contact.Email: '');
            shpLocationValidationOn = (rmaRecord[0].rmaDiskShelfAsset__r.assetPartShipLastValidatedDatetime__c!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.assetPartShipLastValidatedDatetime__c: null;
            addressBookLinkedId = (rmaRecord[0].rmaDiskShelfAsset__r.assetPartShipAddressBook__c);
            
            strAccountRMASHIText = (rmaRecord[0].rmaDiskShelfAsset__r.Account.accountRmaShi__c!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.Account.accountRmaShi__c: '';
            strAssetRMASHIText = (rmaRecord[0].rmaDiskShelfAsset__r.assetRmaShi__c!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.assetRmaShi__c: '';
            // Added by Exafort for TS-9340
            linkedAssetType = rmaRecord[0].rmaDiskShelfAsset__r.Asset_Type__c;
            linkedAssetName = rmaRecord[0].rmaDiskShelfAsset__r.name;
            // Added end
            checkAssetSLA(rmaRecord[0].rmaDiskShelfAsset__r.SLA__c);
            /* if(rmaRecord[0].rmaDiskShelfAsset__r.SLA__c != null){
rma.rmaUplift__c = rmaRecord[0].rmaDiskShelfAsset__r.SLA__c;
}*/
            
            checkNrdInEffect(rmaRecord[0].rmaDiskShelfAsset__r.assetNrdEndDate__c);
            
            //checkComponentType(rmaRecord[0].rmaComponent__c);
            assetToExpand = rmaRecord[0].rmaDiskShelfAsset__r.Name;
            
            if(rmaRecord[0].rmaSelection__c == 'Asset')
            {
                selectedAssetForRMA = rmaRecord[0].rmaDiskShelfAsset__r.Name;
            }
            else if(rmaRecord[0].rmaSelection__c == 'Component')
            {
                selectedComponentForRMA = rmaRecord[0].rmaComponentV2__c;
            }
            else if(rmaRecord[0].rmaSelection__c == 'Spares or Upgrades')
            {
                selectedComponentForRMA = rmaRecord[0].rmaComponentV2__c;
                assetToExpand = rmaRecord[0].rmaSelection__c;
            }
            else if(rmaRecord[0].rmaSelection__c == 'Flat List')
            {
                partScreenSelection = 'Flat List View';
                // Added by Exafort for TS-9340
                if(rmaRecord[0].Flat_List_Type__c != null){
                    flatListSelection = rmaRecord[0].Flat_List_Type__c;
                }
                else{
                    flatListSelection = 'Unfiltered';  
                }
                // Added end
            }
            
            
        }
        else
        {
            shpLabelAssetContact = 'Attn: ' + ((rmaRecord[0].rmaCaseNumber__r.Asset.Contact.FirstName!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.Contact.FirstName+ ' ' : '') +  ((rmaRecord[0].rmaCaseNumber__r.Asset.Contact.LastName!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.Contact.LastName: '');
            shpLabelContactPhone = 'Contact Phone: ' + ((rmaRecord[0].rmaCaseNumber__r.Asset.Contact.Phone!=null) ?  rmaRecord[0].rmaCaseNumber__r.Asset.Contact.Phone: '');
            shpLabelContactEmail = 'Contact Email: ' + ((rmaRecord[0].rmaCaseNumber__r.Asset.Contact.Email!=null) ?  rmaRecord[0].rmaCaseNumber__r.Asset.Contact.Email: '');
            shpLocationValidationOn = (rmaRecord[0].rmaCaseNumber__r.Asset.assetPartShipLastValidatedDatetime__c!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.assetPartShipLastValidatedDatetime__c: null;
            addressBookLinkedId = (rmaRecord[0].rmaCaseNumber__r.Asset.assetPartShipAddressBook__c);
            
            strAccountRMASHIText = (rmaRecord[0].rmaCaseNumber__r.Asset.Account.accountRmaShi__c!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.Account.accountRmaShi__c: '';
            strAssetRMASHIText = (rmaRecord[0].rmaCaseNumber__r.Asset.assetRmaShi__c!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.assetRmaShi__c: ''; 
            // Added by Exafort for TS-9340
            linkedCaseAssetType = rmaRecord[0].rmaCaseNumber__r.Asset.Asset_Type__c;
            linkedAssetName = rmaRecord[0].rmaCaseNumber__r.Asset.name;
            // Added end
            checkAssetSLA(rmaRecord[0].rmaCaseNumber__r.Asset.SLA__c);
            /*if(rmaRecord[0].rmaCaseNumber__r.Asset.SLA__c != null){
rma.rmaUplift__c = rmaRecord[0].rmaCaseNumber__r.Asset.SLA__c;
}*/
            checkNrdInEffect(rmaRecord[0].rmaCaseNumber__r.Asset.assetNrdEndDate__c);
            
            //checkComponentType(rmaRecord[0].rmaComponent__c);
            
            assetToExpand = rmaRecord[0].rmaCaseNumber__r.Asset.Name;
            
            if(rmaRecord[0].rmaSelection__c == 'Flat List')
            {
                partScreenSelection = 'Flat List View';
                // Added by Exafort for TS-9340
                if(rmaRecord[0].Flat_List_Type__c != null){
                    flatListSelection = rmaRecord[0].Flat_List_Type__c;
                }
                else{
                    flatListSelection = 'Unfiltered'; 
                }
                // Added end
                
            }
            
            
        }
        
        shpAccountName = (rmaRecord[0].rmaAddressBook__r.abAccount__r.Name!=null) ? rmaRecord[0].rmaAddressBook__r.abAccount__r.Name: '';
        shpLabelStreet1 = (rmaRecord[0].rmaAddressBook__r.abStreet1__c!=null) ? rmaRecord[0].rmaAddressBook__r.abStreet1__c: '';
        shpLabelStreet2 =  (rmaRecord[0].rmaAddressBook__r.abStreet2__c!=null) ? rmaRecord[0].rmaAddressBook__r.abStreet2__c: '';
        shpLabelCountry =  (rmaRecord[0].rmaAddressBook__r.abCountry__c!=null) ? rmaRecord[0].rmaAddressBook__r.abCountry__c: '';
        shpLabelCity = (rmaRecord[0].rmaAddressBook__r.abCity__c!=null) ? rmaRecord[0].rmaAddressBook__r.abCity__c + ', ': '';
        shpLabelState = (rmaRecord[0].rmaAddressBook__r.abStateProvince__c!=null) ? rmaRecord[0].rmaAddressBook__r.abStateProvince__c: '';
        shpLabelPostalCode=(rmaRecord[0].rmaAddressBook__r.abPostalCode__c!=null) ? rmaRecord[0].rmaAddressBook__r.abPostalCode__c: '';
        addressBookId = rmaRecord[0].rmaAddressBook__c;
        
        alwaysShownOnSiteSection = rma.rmaShowOnSiteSectionsAlways__c;
        alwaysShownReturnSection = rma.rmaShowReturnSectionsAlways__c;
        efaSourceValue = rma.rmaEFASource__c;
        
        strShipmentLocationValidatedOn  = (rmaRecord[0].rmaShipmentLocationValidated__c !=null) ? (rmaRecord[0].rmaShipmentLocationValidated__c).format() : null;
        assignRMASHI(rmaRecord[0].rmaTransmitRmaShisWithOrder__c);
        displayEFAPriority();
        
        //componentLoad(rmaRecord[0].rmaCaseNumber__r.Asset.Account.Id,rmaRecord[0].rmaCaseNumber__r.Asset.Account.Name);
        linkedAssetId = rmaRecord[0].rmaCaseNumber__r.Asset.Id;
        
        
        ComponentAccountId=rmaRecord[0].rmaCaseNumber__r.Asset.Account.Id;
        ComponentAccountName=rmaRecord[0].rmaCaseNumber__r.Asset.Account.Name;
        
        escalationType = rmaRecord[0].rmaCaseNumber__r.caseEscalationType__c;
        selectedSrPart = rmaRecord[0].rmaPartNumber__c;
        
        linkedDiskAssetName = rmaRecord[0].rmaDiskShelfAsset__r.Name;
        linkedCaseAssetName = rmaRecord[0].rmaCaseNumber__r.Asset.Name;
        
        checkComponentType(rmaRecord[0].rmaComponent__c);
    }
    
    //###################################################################################################### assignRMASHI
    public void assignRMASHI(String rmaTransmitRmaShisWithOrder)
    {
        String[] strSHISplit = new String[]{};
            if(String.isNotBlank(rmaTransmitRmaShisWithOrder)) 
            strSHISplit = rmaTransmitRmaShisWithOrder.split(';');
        
        for(String strSHI :strSHISplit)
        {
            checkboxTransmitRMASelections.add(strSHI);
        }
        
    }
    
    //Added by exafort for 10402
    public static string onsiteServiceValueGenereator(String OverrideValue,String assetOnsiteField){
        string fieldReturn = '';
        if(OverrideValue != null){
            fieldReturn = OverrideValue;
        }
        else{
            fieldReturn = assetOnsiteField;
        }
        return fieldReturn;
    }
    
    public static boolean isAssetOnsite(string SLA){
        Boolean isOnsite = false;
        if(SLA != null && SLA.contains('Onsite')){
            isOnsite = true;  
        }
        return isOnsite;
    }
    //End of TS-10402
    
    
    //###################################################################################################### rmaNewRecord
    public void rmaNewRecord()
    {  
        partScreenSelection = 'Component View';

        
        if(rma.rmaDiskShelfAsset__c != null)
        {
            // Added Asset_Type__c field in the below SOQL Query for TS-9340 By Exafort
            List<Asset> assets = new List<Asset>([Select Account.Name,Name,assetSameDayPartDeliveryPreference__c,assetRmaShi__c,Account.accountRmaShi__c,
                                                  assetNrdEndDate__c,SLA__c,assetPartShipAddressBook__r.ID,assetPartShipAddressBook__r.abAccount__r.Name,
                                                  assetPartShipAddressBook__r.abStreet1__c,assetPartShipAddressBook__r.abStreet2__c,assetPartShipAddressBook__r.abCity__c,
                                                  assetPartShipAddressBook__r.abPostalCode__c,assetPartShipAddressBook__r.abCountry__c,assetOnsitePartHandoverCode__c,
                                                  assetOnsiteSchedulingNotes__c,assetOnsiteSchedulingCode__c,assetOnsitePartHandoverNotes__c,assetOnsiteCheckInCode__c,
                                                  assetOnsiteCheckInNotes__c,assetOnsitePartDispositionCode__c,assetOnsitePartDispositionNotes__c,
                                                  assetPartShipAddressBook__r.abStateProvince__c,Account.ID, assetPartShipAddressBook__c,assetPartShipLastValidatedDatetime__c,
                                                  Contact.FirstName,Contact.LastName,Contact.Phone,Contact.Email,Asset_Type__c from Asset where Id=:rma.rmaDiskShelfAsset__c Limit 1]);
            
            if(assets.size() == 0)
                return;
            
           //Added by exafort for 10402 
            if(isAssetOnsite(assets[0].SLA__c)){
            onsitePartHandoverCode = (assets[0].assetOnsitePartHandoverCode__c != null) ? assets[0].assetOnsitePartHandoverCode__c : '';
            onsiteSchedulingNotes = (assets[0].assetOnsiteSchedulingNotes__c != null) ? assets[0].assetOnsiteSchedulingNotes__c : '';
            onsiteSchedulingCode = (assets[0].assetOnsiteSchedulingCode__c != null) ? assets[0].assetOnsiteSchedulingCode__c : '';
            onsitePartHandoverNotes = (assets[0].assetOnsitePartHandoverNotes__c != null) ? assets[0].assetOnsitePartHandoverNotes__c : '';
            onsiteCheckInCode = (assets[0].assetOnsiteCheckInCode__c != null) ? assets[0].assetOnsiteCheckInCode__c : '';
            onsiteCheckInNotes = (assets[0].assetOnsiteCheckInNotes__c != null) ? assets[0].assetOnsiteCheckInNotes__c : '';
            onsitePartDispositionCode = (assets[0].assetOnsitePartDispositionCode__c != null) ? assets[0].assetOnsitePartDispositionCode__c : '';
            onsitePartDispositionNotes = (assets[0].assetOnsitePartDispositionNotes__c != null) ? assets[0].assetOnsitePartDispositionNotes__c : ''; 
            }
            //End of TS-10402
            
            addressBookId = assets[0].assetPartShipAddressBook__c;
            addressBookLinkedId =  assets[0].assetPartShipAddressBook__c;
            
            
            rma.rmaAddressBook__c = (assets[0].assetPartShipAddressBook__r.ID!=null) ? assets[0].assetPartShipAddressBook__r.ID : null;          
            shpAccountName = (assets[0].assetPartShipAddressBook__r.abAccount__r.Name!=null) ? assets[0].assetPartShipAddressBook__r.abAccount__r.Name: '';
            shpLabelAssetContact = 'Attn: ' + ((assets[0].Contact.FirstName!=null) ? assets[0].Contact.FirstName+ ' ' : '') +  ((assets[0].Contact.LastName!=null) ? assets[0].Contact.LastName: '');
            shpLabelStreet1 =  (assets[0].assetPartShipAddressBook__r.abStreet1__c!=null) ? assets[0].assetPartShipAddressBook__r.abStreet1__c: '';
            shpLabelStreet2 =  (assets[0].assetPartShipAddressBook__r.abStreet2__c!=null) ? assets[0].assetPartShipAddressBook__r.abStreet2__c: '';
            shpLabelCountry =  (assets[0].assetPartShipAddressBook__r.abCountry__c!=null) ? assets[0].assetPartShipAddressBook__r.abCountry__c: '';
            shpLabelContactPhone = 'Contact Phone: ' + ((assets[0].Contact.Phone!=null) ? assets[0].Contact.Phone: '');
            shpLabelContactEmail = 'Contact Email: ' + ((assets[0].Contact.Email!=null) ?  assets[0].Contact.Email: '');
            shpLabelCity =(assets[0].assetPartShipAddressBook__r.abCity__c!=null) ? assets[0].assetPartShipAddressBook__r.abCity__c + ', ':'';
            shpLabelState =(assets[0].assetPartShipAddressBook__r.abStateProvince__c!=null) ? assets[0].assetPartShipAddressBook__r.abStateProvince__c: '';
            shpLabelPostalCode=(assets[0].assetPartShipAddressBook__r.abPostalCode__c!=null) ? assets[0].assetPartShipAddressBook__r.abPostalCode__c: '';
            
            strShipmentLocationValidatedOn = (assets[0].assetPartShipLastValidatedDatetime__c !=null) ? (assets[0].assetPartShipLastValidatedDatetime__c).format() : null;
            shpLocationValidationOn = (assets[0].assetPartShipLastValidatedDatetime__c!=null) ? assets[0].assetPartShipLastValidatedDatetime__c : null;
            
            strAccountRMASHIText = (assets[0].Account.accountRmaShi__c!=null) ? assets[0].Account.accountRmaShi__c: '';
            strAssetRMASHIText = (assets[0].assetRmaShi__c!=null) ? assets[0].assetRmaShi__c: '';
            //Added by vishnu for TS-5318 on 21st Jan 2019
            AssetSLA = assets[0].SLA__c;
            //
            checkAssetSLA(assets[0].SLA__c);
            if(assets[0].SLA__c != null){
                if(assets[0].SLA__c.contains('Critical') && (rma.rmaCaseNumber__r.Priority == 'P1' || rma.rmaCaseNumber__r.Priority == 'P2')) {
                    rma.rmaUplift__c = 'Critical 2 Hour';
                } else {
                    rma.rmaUplift__c = assets[0].SLA__c;
                }
            }
            checkNrdInEffect(assets[0].assetNrdEndDate__c);
            generatedRmaShiText(strAccountRMASHIText,strAssetRMASHIText);
            assignOnsiteTechStatus(assets[0].SLA__c);
            
            assetToExpand = assets[0].Name;
            // Added By Exafort for TS-9340 
            linkedAssetType = assets[0].Asset_Type__c;
            linkedAssetName = assets[0].Name;
            // Added end
            
            
            
            checkComponentType(rma.rmaComponent__c);
            automateEFASource();
            
            // Added by Exafort for TS-10419
            // If Condition updated by Exafort for SFDC-1080
            if(assets[0].SLA__c != null && (assets[0].SLA__c.contains('Onsite') || assets[0].SLA__c == '6 Hr CTR')){
                assetSlaisNotOnsite = False;
            }
            // End of TS-10419
            
        }
        else if(rma.rmaCaseNumber__c != null)
        {
            // Added Asset.Asset_Type__c in the below query by Exafort for TS-9340
            List<Case> cases = new List<Case>([Select Nimble_Version__c,casePachinkoCaseType__c,caseEscalationType__c,Asset.Id,Asset.Name,
                                               Asset.Account.Name,Asset.assetSameDayPartDeliveryPreference__c,Asset.assetRmaShi__c,Asset.Account.accountRmaShi__c,
                                               Asset.assetNrdEndDate__c,Asset.SLA__c,Asset.assetPartShipAddressBook__r.ID,Asset.assetPartShipAddressBook__r.abAccount__r.Name,
                                               Asset.assetPartShipAddressBook__r.abStreet1__c,Asset.assetPartShipAddressBook__r.abStreet2__c,Asset.assetOnsitePartHandoverCode__c,
                                               Asset.assetPartShipAddressBook__r.abCity__c,Asset.assetPartShipAddressBook__r.abPostalCode__c,
                                               Asset.assetPartShipAddressBook__r.abCountry__c,Asset.assetPartShipAddressBook__r.abStateProvince__c,Asset.Account.ID, 
                                               Asset.assetPartShipAddressBook__c,Asset.assetPartShipLastValidatedDatetime__c,Asset.Contact.FirstName,Asset.Contact.LastName,                                               
                                               Asset.assetOnsiteSchedulingNotes__c,Asset.assetOnsiteSchedulingCode__c,Asset.assetOnsitePartHandoverNotes__c,Asset.assetOnsiteCheckInCode__c,
                                               Asset.assetOnsiteCheckInNotes__c,Asset.assetOnsitePartDispositionCode__c,Asset.assetOnsitePartDispositionNotes__c,                                               
                                               Asset.Contact.Phone,Asset.Contact.Email,Asset.Asset_Type__c, Priority from Case where Id=:rma.rmaCaseNumber__c Limit 1]); 
            
            if(cases.size() == 0)
                return;
            
            //Added by exafort for 10402
            if(isAssetOnsite(cases[0].Asset.SLA__c)){
            onsitePartHandoverCode = (cases[0].Asset.assetOnsitePartHandoverCode__c != null) ? cases[0].Asset.assetOnsitePartHandoverCode__c : '';
            onsiteSchedulingNotes = (cases[0].Asset.assetOnsiteSchedulingNotes__c != null) ? cases[0].Asset.assetOnsiteSchedulingNotes__c : '';
            onsiteSchedulingCode = (cases[0].Asset.assetOnsiteSchedulingCode__c != null) ? cases[0].Asset.assetOnsiteSchedulingCode__c : '';
            onsitePartHandoverNotes = (cases[0].Asset.assetOnsitePartHandoverNotes__c != null) ? cases[0].Asset.assetOnsitePartHandoverNotes__c : '';
            onsiteCheckInCode = (cases[0].Asset.assetOnsiteCheckInCode__c != null) ? cases[0].Asset.assetOnsiteCheckInCode__c : '';
            onsiteCheckInNotes = (cases[0].Asset.assetOnsiteCheckInNotes__c != null) ? cases[0].Asset.assetOnsiteCheckInNotes__c : '';
            onsitePartDispositionCode = (cases[0].Asset.assetOnsitePartDispositionCode__c != null) ? cases[0].Asset.assetOnsitePartDispositionCode__c : '';
            onsitePartDispositionNotes = (cases[0].Asset.assetOnsitePartDispositionNotes__c != null) ? cases[0].Asset.assetOnsitePartDispositionNotes__c : '';
            
            }    
            //End of TS-10402
            
            addressBookId = cases[0].Asset.assetPartShipAddressBook__c;
            addressBookLinkedId =  cases[0].Asset.assetPartShipAddressBook__c;
            
            
            rma.rmaAddressBook__c =  cases[0].Asset.assetPartShipAddressBook__r.ID;  
            
            shpAccountName = (cases[0].Asset.assetPartShipAddressBook__r.abAccount__r.Name!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abAccount__r.Name: '';
            shpLabelAssetContact ='Attn: ' +  ((cases[0].Asset.Contact.FirstName!=null) ? cases[0].Asset.Contact.FirstName + ' ' : '') + ((cases[0].Asset.Contact.LastName!=null) ? cases[0].Asset.Contact.LastName: '');
            shpLabelStreet1 =  (cases[0].Asset.assetPartShipAddressBook__r.abStreet1__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abStreet1__c: '';
            shpLabelStreet2 =  (cases[0].Asset.assetPartShipAddressBook__r.abStreet2__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abStreet2__c: '';
            shpLabelCountry =  (cases[0].Asset.assetPartShipAddressBook__r.abCountry__c!=null) ?cases[0].Asset.assetPartShipAddressBook__r.abCountry__c: '';
            shpLabelContactPhone = 'Contact Phone: ' +  ((cases[0].Asset.Contact.Phone!=null) ?  cases[0].Asset.Contact.Phone: '');
            shpLabelContactEmail = 'Contact Email: ' +  ((cases[0].Asset.Contact.Email!=null) ?  cases[0].Asset.Contact.Email: '');
            shpLabelCity =(cases[0].Asset.assetPartShipAddressBook__r.abCity__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abCity__c + ', ':'';
            shpLabelState =(cases[0].Asset.assetPartShipAddressBook__r.abStateProvince__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abStateProvince__c: '';
            shpLabelPostalCode=(cases[0].Asset.assetPartShipAddressBook__r.abPostalCode__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abPostalCode__c: '';
            
            strShipmentLocationValidatedOn = (cases[0].Asset.assetPartShipLastValidatedDatetime__c !=null) ? (cases[0].Asset.assetPartShipLastValidatedDatetime__c).format() : null; 
            shpLocationValidationOn = (cases[0].Asset.assetPartShipLastValidatedDatetime__c!=null) ? cases[0].Asset.assetPartShipLastValidatedDatetime__c : null;
            
            strAccountRMASHIText = (cases[0].Asset.Account.accountRmaShi__c!=null) ? cases[0].Asset.Account.accountRmaShi__c: '';
            strAssetRMASHIText = (cases[0].Asset.assetRmaShi__c!=null) ? cases[0].Asset.assetRmaShi__c: '';
            //Added by vishnu for TS-5318 on 21st Jan 2019
            casePachinkoTypeForRMANew = cases[0].casePachinkoCaseType__c;
            AssetSLA = cases[0].Asset.SLA__c;
            //
            checkAssetSLA(cases[0].Asset.SLA__c);
            if(cases[0].Asset.SLA__c != null){
                if(cases[0].Asset.SLA__c.contains('Critical') && (cases[0].Priority == 'P1' || cases[0].Priority == 'P2')) {
                    rma.rmaUplift__c = 'Critical 2 Hour';
                } else {
                    rma.rmaUplift__c = cases[0].Asset.SLA__c;
                }
            }
            checkNrdInEffect(cases[0].Asset.assetNrdEndDate__c);
            generatedRmaShiText(strAccountRMASHIText,strAssetRMASHIText);
            assignOnsiteTechStatus(cases[0].Asset.SLA__c);
            
            //componentLoad(cases[0].Asset.Account.Id,cases[0].Asset.Account.Name);
            linkedAssetId = cases[0].Asset.Id;
            linkedCaseAssetName = cases[0].Asset.Name;
            
            assetToExpand = cases[0].Asset.Name;            
            checkComponentType(rma.rmaComponent__c);
            
            ComponentAccountId=cases[0].Asset.Account.Id;
            ComponentAccountName=cases[0].Asset.Account.Name;
            escalationType = cases[0].caseEscalationType__c;
            // Added by Exafort for TS-9340
            linkedCaseAssetType = cases[0].Asset.Asset_Type__c;
            linkedAssetName = cases[0].Asset.Name;
            // Added end
            automateEFASource();
            nimbleOsVersion = cases[0].Nimble_Version__c;
            // Added by Exafort for TS-10419
            // // If Condition updated by Exafort for SFDC-1080
            if(cases[0].Asset.SLA__c != null && (cases[0].Asset.SLA__c.contains('Onsite') || cases[0].Asset.SLA__c == '6 Hr CTR')){
                assetSlaisNotOnsite = False;
            }
            // End of TS-10419
        }
        
        
        if(rma.rmaSelection__c == 'Flat List')
        {
            partScreenSelection = 'Flat List View';
            // Added by Exafort for TS-9340
            if(flatListSelection != null){
                flatListSelection = flatListSelection;
            }
            else{
                flatListSelection = 'Based On Head and All Related Assets';
            }
            // Added end 
        }
    }
    
    //###################################################################################################### checkEscalationType
    public void automateEFASource()
    {
        rma.rmaEFASource__c = efaSourceValue;
        
        
        if(selectedSrPart != null)
        {
            getSrMetaDataOptions();
            if(srMetaDataMapByName.containsKey(selectedSrPart))
            {
                Boolean autoEFA = srMetaDataMapByName.get(selectedSrPart).srAutoEFA__c;
                
                if(autoEFA == true)
                {
                    rma.rmaEFASource__c = 'Auto-EFA';
                }
            }
        }
        
        if(escalationType != null)
        {
            if(escalationType.contains('Engineering Escalation'))
            {
                rma.rmaEFASource__c='ENG Escalation';
            }
        }       
        
    }
    
    //###################################################################################################### assetOnChange
    public void assetOnChange()
    { 
        // Added by Exafort for SFDC-627
        assetId = rma.rmaDiskShelfAsset__c;
        if (assetId != null) {
            checkForChinaGaRma(assetId);
        }
        onsiteServiceFieldReset(); // Added by Exafort for TS-10402
        
        // Added by Exafort for TS-9340
        if(rma.rmaDiskShelfAsset__c == null){
            linkedAssetType = null;
        }
        // Added End
        clearAddressFields();
        rmaNewRecord();
    }
    
    //###################################################################################################### assetOnChange
    public void caseOnChange()
    { 
        onsiteServiceFieldReset(); // Added by Exafort for TS-10402
        
        // Added by Exafort for TS-9340
        rma.rmaDiskShelfAsset__c = null;
        linkedCaseAssetType = null;
        linkedAssetType = null;
        // Added end
        
        clearAddressFields();
        rmaNewRecord();
        rma.rmaNimbleOSVersionForSubstitution__c = setNimbleOsVersion(nimbleOsVersion);
    }
    
    // Added by Exafort for TS-10419
    /*public void overrideCountryOnChange()
    {
        string rmaCountry = rma.rmaOverrideShipmentCountry__c != null ? rma.rmaOverrideShipmentCountry__c :rma.rmaShipmentCountry__c;
        if(rma.rmaCaseNumber__c != null){
            chinaGlobalAccount = isGlobalChinaH3cCase(rma.rmaCaseNumber__c,rmaCountry);    
        }
    }
    public Boolean isGlobalChinaH3cCase(id caseId,String rmaCountry){
        Boolean isValidGlobalChinaH3cCase  = false;
        Case cas =[Select id,Account.Global_Account__c,Account.Support_Provider__r.Name from Case Where id =:caseId];
        if(rmaCountry == 'China' && cas.Account.Support_Provider__r.Name != 'H3C Service Provider'){
               isValidGlobalChinaH3cCase = true;                  
           }
        return isValidGlobalChinaH3cCase;
    }*/
    // End of TS-10419
    
    //###################################################################################################### displayEFAPriority
    public void displayEFAPriority()
    {
        if(rma.rmaFaRequired__c == 'Engineering FA' &&  rma.rmaEFAPriority__c== null)
        {
            shownEFAPriority = true;
            rma.rmaEFAPriority__c= 'P2';
        }
        else if(rma.rmaFaRequired__c == 'Engineering FA')
        {
            shownEFAPriority = true;
        }
        else
        {
            shownEFAPriority = false;
        }
    }
    
    //###################################################################################################### faRequiredOnChange
    public void faRequiredOnChange()
    {
        
        string rmaFaRequired = Apexpages.currentPage().getParameters().get('rmaFaRequired');
        
        if(rmaFaRequired == 'Engineering FA')
        {
            shownEFAPriority = true;
            rma.rmaEFAPriority__c = 'P2';
        }
        else
        {
            shownEFAPriority = false;
            rma.rmaEFAPriority__c = null;
        }
    }
    
    //###################################################################################################### CFAOnChange
    Public void CFAOnChange(){     
        
        if( rma.rmaCustomerFaRequired__c == true){          
            rma.rmaFaRequired__c = 'Operations FA';                         
        } 
        else{
            if(rma.rmaEFAPriority__c != null){
                rma.rmaFaRequired__c = 'Engineering FA';
            }
            else{
                rma.rmaFaRequired__c = 'No FA Required';
                shownEFAPriority = false;
            }            
        }
    }
    
    //###################################################################################################### addressBookOnChange
    public void addressBookOnChange()
    {
        clearAddressFields();
        
        if(rma.rmaAddressBook__c == null)
        {
            shpAccountName='';
            shpLabelStreet1 =  '';
            shpLabelStreet2 = '';
            shpLabelCountry =  '';
            shpLabelCity = '';
            shpLabelState = '';
            shpLabelPostalCode='';
        }
        else if(addressBookLinkedId == rma.rmaAddressBook__c)
        {
            if(shpLocationValidationOn != null)
                strShipmentLocationValidatedOn = shpLocationValidationOn.format();
            else
                strShipmentLocationValidatedOn = null;
        }
        
        populateAddressFields();
        
        // Added by Exafort for TS-10419
        /*if(rma.rmaAddressBook__c != null && rma.rmaCaseNumber__c != null){
            AddressBook__c addressBook = [select Id,abCountry__c from AddressBook__c Where id =:rma.rmaAddressBook__c];
            chinaGlobalAccount = isGlobalChinaH3cCase(rma.rmaCaseNumber__c,addressBook.abCountry__c);  
        }*/
        // End of TS-10419
        
    }
    
    //###################################################################################################### showOnSiteSectionOnChange
    public void showOnSiteSectionOnChange()
    {
        
        if(rma.rmaShowOnSiteSectionsAlways__c == true)
            alwaysShownOnSiteSection = true;
        else
            alwaysShownOnSiteSection = false;
    }
    
    //###################################################################################################### showRMACancellationReason
    //Added On 21st Nov 2016 By Azarudeen. To show/hide Cancellation Reason if outgoing shipment status is Canceled
    public void showRMACancellationReason(){
        
        string ougoingshipmentstatus = Apexpages.currentPage().getParameters().get('rmaOutgoingShipmentStatusParam');
        
        if(ougoingshipmentstatus.Contains('Canceled'))
        {
            rmaCancelationReasonShowOrHide = true;
        }
        else
        {
            rmaCancelationReasonShowOrHide = false;
        }
    }
    //###################################################################################################### showReturnSectionOnChange
    public void showReturnSectionOnChange()
    {
        
        if(rma.rmaShowReturnSectionsAlways__c == true)
            alwaysShownReturnSection = true;
        else
            alwaysShownReturnSection = false;
    }
    
    //###################################################################################################### checkAssetSLA
    public void checkAssetSLA(String assetSLA)
    {            
        /*if(assetSLA != null){
hideOnSiteSections = true;
if(assetSLA.contains('Onsite'))
{
hideOnSiteSections = false;
}
}*/
        system.debug('==>checkAssetSLA method calling');
        if(assetSLA != null)
        {
            system.debug('### RMA part ==>'+rmaPartForOnsiteValidation);
            string partShipSlaValue;
            if(rmaPartForOnsiteValidation != null)
            {
                getSrMetaDataOptions();
                if(Test.isRunningTest()){
                    partShipSlaValue = 'SR-USB';
                }else{
                    //Added the null check to avoid the Null pointer Exception TS-5744 by vishnu on 12th April 2019
                    if(srMetaDataMapByName.get(rmaPartForOnsiteValidation) != null){
                        partShipSlaValue = srMetaDataMapByName.get(rmaPartForOnsiteValidation).srPartShipSLAOverride__c;  
                    }
                    
                }
                //uncomment these lines in sandbox for debugging.
                /*system.debug('### partShipSlaValue ==>'+partShipSlaValue);
system.debug('### casePachinkoType ==>'+casePachinkoType);*/
                //if(assetSLA.contains('Onsite')){
                    /*if(partShipSlaValue == 'NBD & Onsite Override' && casePachinkoType != 'ssdwearlevelhigh'){
alwaysShownOnSiteSection = false;
hideOnSiteSections = true ;
}
else{*/
                if(rmaTriggerHandler.isOnsiteSLA(assetSLA)){
                    //TS-6667 START  Added by Exafort on August 19 2020
                    if(rma.rmaUplift__c !=null && rma.rmaUplift__c == 'Premium Onsite'){
                        alwaysShownOnSiteSection = true; 
                    }
                    //TS-6667 END  Added by Exafort on August 19 2020
                    // If condition updated by Exafort for TS-10970
                    else if(partShipSlaValue == 'NBD & Onsite Override'){// || casePachinkoType == 'ssdwearlevelhigh'){
                        alwaysShownOnSiteSection = false;
                        hideOnSiteSections = true ;
                    }
                    else if(partShipSlaValue == 'NBD & Onsite Retain' || casePachinkoType != 'ssdwearlevelhigh' 
                            || (partShipSlaValue == '' && casePachinkoType != 'ssdwearlevelhigh')){
                                alwaysShownOnSiteSection = true; 
                            }
                    //}
                }
                //Added by exafort(vishnu) on 2nd April 2019 for hiding onsite sections for non-onsite customers TS-5520.
                else{
                    hideOnSiteSections = true ;
                }
            }else{
                System.debug('### RMA partnumber is Null ###');
            }
        }
    }
    
    //###################################################################################################### checkComponentType
    public void checkComponentType(String component)
    {
        
        hideReturnSections = false;
        shipOnlyPart = false;
        
        if(selectedSrPart != null)
        {
            getSrMetaDataOptions();
            if(srMetaDataMapByName.containsKey(selectedSrPart))
            { 
                shipOnlyPart = srMetaDataMapByName.get(selectedSrPart).srShipOnly__c;
            }
        }
        
        if(component != null)
        {
            if(((component == 'HDD' || component== 'SSD') && (assetNrdIsInEffect == true)) || (shipOnlyPart==true))
            {
                hideReturnSections = true;
            }
        }
    }
    
    //###################################################################################################### assignOnsiteTechStatus
    public void assignOnsiteTechStatus(String assetSLA)
    {
        if(assetSLA != null)
        {
            if(assetSLA == 'Premium' || assetSLA.contains('4 Hour') || assetSLA.contains('H3C'))
            {
                //rma.rmaOnsiteTechStatus__c = 'N/A-10: No onsite for this RMA Type';
                //Added for TS-8227 By exafort on 05/11
                rma.rmaOnsiteTechStatus__c = 'None';
            }
            else
            {
                rma.rmaOnsiteTechStatus__c = 'None';
            }
        }
    }
    
    //###################################################################################################### checkNrdInEffect
    public void checkNrdInEffect(DateTime assetNrdEndDate)
    { 
        
        assetNrdIsInEffect = false;           
        if(rma.rmaOutgoingShipmentDateTimeOpened__c == null)
        {
            if(DateTime.Now() <= assetNrdEndDate)
                assetNrdIsInEffect = true; 
        }
        else
        {
            if(rma.rmaOutgoingShipmentDateTimeOpened__c <= assetNrdEndDate)
                assetNrdIsInEffect = true;
        }
        
    }
    
    //###################################################################################################### populateAddressFields
    public void populateAddressFields()
    {
        List<AddressBook__c> ab = new List<AddressBook__c>([SELECT Id,abAccount__r.Name,abAddressLine__c, abStreet1__c, abStreet2__c, abCity__c, abStateProvince__c, abPostalCode__c, abCountry__c FROM AddressBook__c where ID=:rma.rmaAddressBook__c Limit 1]); 
        if(ab.size()== 0)
        {
            return;
        }
        
        shpAccountName = (ab[0].abAccount__r.Name!=null) ? ab[0].abAccount__r.Name: '';  
        shpLabelStreet1 =  (ab[0].abStreet1__c!=null) ? ab[0].abStreet1__c: '';
        shpLabelStreet2 =  (ab[0].abStreet2__c!=null) ? ab[0].abStreet2__c: '';
        shpLabelCountry =  (ab[0].abCountry__c!=null) ? ab[0].abCountry__c: '';
        shpLabelCity =(ab[0].abCity__c!=null) ? ab[0].abCity__c + ', ': '';
        shpLabelState =(ab[0].abStateProvince__c!=null) ? ab[0].abStateProvince__c: '';
        shpLabelPostalCode=(ab[0].abPostalCode__c!=null) ? ab[0].abPostalCode__c: '';
    }
    
    //###################################################################################################### getAddressOptions
    public List<SelectOption> getAddressOptions()
    {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('', '- None -'));
        
        String AccountID= null;
        
        
        if(rma.rmaDiskShelfAsset__c != null)
        {
            List<Asset> asset = new List<Asset>([Select ID,Account.Id from Asset where Id=: rma.rmaDiskShelfAsset__c Limit 1]);
            AccountID = asset[0].Account.Id;
        }
        else if(rma.rmaCaseNumber__c != null)
        {
            List<Case> cases = new List<Case>([Select ID,Asset.Account.Id from Case where Id=: rma.rmaCaseNumber__c Limit 1]);
            AccountID = cases[0].Asset.Account.Id;
        }
        
        if(AccountID == null)
            return options;
        
        // Limit 999 Added by Exafort for TS-10550
        for (AddressBook__c ab:[SELECT Name,abAccount__r.Name,abAddressLine__c,abDescription__c FROM AddressBook__c where abAccount__c =: AccountID  or ID=:addressBookId order by Name desc Limit 999])
        { 
            if(ab.abAddressLine__c != null)
                options.add(new selectOption(ab.Id, ab.abAccount__r.Name + ' - ' + ab.abDescription__c + ' - ' +ab.abAddressLine__c)); 
            else
                options.add(new selectOption(ab.Id, ab.abAccount__r.Name + ' - ' + ab.abDescription__c)); 
        }
        
        return options; 
    }
    
    //###################################################################################################### saveRMA
    public PageReference saveRMA() {
        
        try {
            
            if(rma.rmashi__c != null)
            {
                String SHIValues='';
                for(String SHIs : checkboxTransmitRMASelections)
                {
                    SHIValues = SHIValues + SHIs + ';';
                }
                
                rma.rmaTransmitRmaShisWithOrder__c = SHIValues + 'RMA SHI';
            }
            else
            {
                rma.rmaTransmitRmaShisWithOrder__c = 'No SHI';
            }
            
            /*START -  Delivery Scheduling Mechanism Validation */
            
            //Validate only if the RMA is in draft status
            if(rma.rmaStatus__c == 'Draft' || rma.rmaStatus__c == '' || rma.rmaStatus__c == null){
                DateTime shipmentLocationValidated;
                Date shipmentLocationValidatedDate;
                Integer monthsDifference;
                DateTime deliveryDateTime;
                
                system.debug('### Delivery Date ### '+rma.rmaDeliveryDate__c);
                system.debug('### Delivery Time ### '+rma.rmaDeliveryTimes__c);
                system.debug('### Delivery Time rmaSLADueDateTime__c ### '+rma.rmaSLADueDateTime__c);
                
                /*  if(rma.rmaSLADueDateTime__c != ''){
integer rmaRawOffsetConverted;
integer rmaDstOffsetConverted;
string rmaRawOffset;
string rmaDstOffset;
if(rma.rmaTimeZoneActualOffset__c != null && rma.rmaTimeZoneDSTOffset__c != null){
rmaRawOffset = rma.rmaTimeZoneActualOffset__c.deleteWhitespace();
rmaRawOffset = rmaRawOffset.substringBefore('(');
rmaDstOffset = rma.rmaTimeZoneDSTOffset__c.deleteWhitespace();
rmaDstOffset = rmaDstOffset.substringBefore('(');
}
if(rmaRawOffset != null){
rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
}
if(rmaDstOffset != null){
rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
}
string year = rma.rmaSLADueDateTime__c.substringAfterLast('-');
rma.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')),integer.valueOf(rma.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rma.rmaSLADueDateTime__c.substringBetween('-', '-')), integer.valueOf(rma.rmaSLADueDateTime__c.substringBetween(' ', ':')), integer.valueOf(rma.rmaSLADueDateTime__c.substringBetween(':', ':')), integer.valueOf(rma.rmaSLADueDateTime__c.substringAfterLast(':'))).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
}
*/
                /**** form the DateTime from Delivery Date and Delivery Time fields ****/
                if((rma.rmaDeliveryDate__c != null) && (rma.rmaDeliveryTimes__c !=null || rma.rmaDeliveryTimes__c != '')){
                    string deliveryTime24HourFormate = '';
                    integer deliveryHourSim;
                    integer deliveryMinSim;
                    if(rma.rmaDeliveryTimes__c != null && rma.rmaDeliveryTimes__c.contains('PM')){
                        deliveryHourSim = integer.valueOf(rma.rmaDeliveryTimes__c.substringBefore(':'));
                        if(rma.rmaDeliveryTimes__c.substringBefore(':') == '12'){
                            deliveryHourSim = deliveryHourSim;
                        }else{
                            deliveryHourSim = deliveryHourSim + 12;   
                        }
                        deliveryMinSim = integer.valueOf(rma.rmaDeliveryTimes__c.substringBetween(':', ' '));
                    }
                    if(rma.rmaDeliveryTimes__c.contains('AM') && rma.rmaDeliveryTimes__c.substringBefore(':') == '12'){
                        deliveryHourSim = 00;
                    }
                    
                    /**** form the new instance of DateTime from the DeliveryDate and DeliveryTime fields ****/
                    DateTime newDateTime;
                    //If time is in PM, then use previously formed integer variables to assign hour and minute
                    if(deliveryHourSim != null && deliveryMinSim != null){
                        system.debug('### delivery hour and minute is not null ###');
                        //Get the actual datetime using GMT method(without adding UTC hours)
                        newDateTime = DateTime.newInstance(rma.rmaDeliveryDate__c.year(), rma.rmaDeliveryDate__c.month(),  rma.rmaDeliveryDate__c.day(), deliveryHourSim, deliveryMinSim ,0);    
                        
                    }
                    //Else, assign Hour and minute directly from the DeliveryTime
                    else{
                        if(rma.rmaDeliveryTimes__c.contains('AM') && rma.rmaDeliveryTimes__c.substringBefore(':') == '12'){
                            system.debug('### delivery hour and minute is null and Time is 12.00 AM ###');
                            //get the actual datetime using GMT method(without adding UTC hours)
                            newDateTime = DateTime.newInstance(rma.rmaDeliveryDate__c.year(), rma.rmaDeliveryDate__c.month(),  rma.rmaDeliveryDate__c.day(), 0, Integer.valueOf(rma.rmaDeliveryTimes__c.substring(3, 5)) ,0);        
                        }
                        /*else if(rma.rmaDeliveryTimes__c.contains('PM') && rma.rmaDeliveryTimes__c.substringBefore(':') == '12'){
system.debug('### delivery hour and minute is null and Time is 12.00 PM ###');
//get the actual datetime using GMT method(without adding UTC hours)
newDateTime = DateTime.newInstance(rma.rmaDeliveryDate__c.year(), rma.rmaDeliveryDate__c.month(),  rma.rmaDeliveryDate__c.day(), Integer.valueOf(rma.rmaDeliveryTimes__c.substring(0, 2)), Integer.valueOf(rma.rmaDeliveryTimes__c.substring(3, 5)) ,0);        
}*/
                        else{
                            system.debug('### delivery hour and minute is null ###');
                            //get the actual datetime using GMT method(without adding UTC hours)
                            newDateTime = DateTime.newInstance(rma.rmaDeliveryDate__c.year(), rma.rmaDeliveryDate__c.month(),  rma.rmaDeliveryDate__c.day(), Integer.valueOf(rma.rmaDeliveryTimes__c.substring(0, 2)), Integer.valueOf(rma.rmaDeliveryTimes__c.substring(3, 5)) ,0);        
                        }
                        
                    }
                    system.debug('### newDateTime ### '+newDateTime);
                    rma.rmaDeliveryDateTime__c = newDateTime;
                    deliveryDateTime = rma.rmaDeliveryDateTime__c;
                }
                else {
                    rma.rmaDeliveryDateTime__c = null;
                }
                
                system.debug('### RMA Delivery DateTime ### '+rma.rmaDeliveryDateTime__c);
                
                system.debug('### RMA Delivery DateTime assigned variable value ###'+deliveryDateTime);
                
                //Throw error if Delivery Date is selected and Time is not selected
                if((rma.rmaDeliveryDate__c != null) && (rma.rmaDeliveryTimes__c == null || rma.rmaDeliveryTimes__c == '' || rma.rmaDeliveryTimes__c == '--None--')){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Delivery Date and Time must be in Date and Time format. Please enter Time'));
                    return null;
                }
                
                /*** Get the Asset Local Date and Time in a DateTime formate to compare with Delivery Date Time and validate the scheduling ***/
                
                DateTime assetLocalDate = Date.today();
                //DateTime assetLocalDate;
                //system.debug('### Asset Local DateTime ### '+rma.rmaAssetLocalDateTime__c);
                //rma.rmaAssetLocalDateTime__c = '1/11/2018 11:00 AM';
                system.debug('### Asset Local DateTime ### '+rma.rmaAssetLocalDateTime__c);
                system.debug('v### RMA Delivery Date ### ==>'+rma.rmaDeliveryDate__c);
                if(rma.rmaDeliveryDate__c != null && rma.rmaAssetLocalDateTime__c != null){
                    //11/08/2017 02:00 PM
                    //1/11/2018 06:00 PM
                    //rma.rmaAssetLocalDateTime__c = 1/11/2018 12:30 AM
                    //1/29/2018 12:30 AM
                    string dateFormat = rma.rmaAssetLocalDateTime__c.substringBefore(' ');
                    system.debug('v### date Format ### ==>'+dateFormat);
                    dateFormat = dateFormat.substringAfterLast('/');
                    system.debug('v### formatted date Format ### ==>'+dateFormat);
                    string timeFormat = rma.rmaAssetLocalDateTime__c.substringAfter(' ');
                    system.debug('v### time Format ### ==>'+timeFormat);
                    /*integer getHour = 0;
if(timeFormat.contains('AM') && (timeFormat.contains('12') || timeFormat.contains('01'))){
if(timeFormat.contains('01')){
getHour = 01;
}
else if(timeFormat.contains('12')){
getHour = 00;
}

}
else{
getHour = Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(' ', ':'));
}*/
                    
                    string AssetLocalTime24HourFormate;
                    integer AssetLocalTime24HourFormateSim;
                    //added by Exafort on TS-4203
                    //To validate the time of timeFormat.contains('12:00 PM') || timeFormat.contains('12:30 PM')
                    if(timeFormat.contains('12:00 PM') || timeFormat.contains('12:30 PM')){
                        AssetLocalTime24HourFormateSim = 12;
                        system.debug('Entered into if condition' + AssetLocalTime24HourFormateSim);
                    }
                    //end
                    //if(timeFormat != null && timeFormat.contains('PM') ){
                    else if(timeFormat != null && timeFormat.contains('PM') ){
                        AssetLocalTime24HourFormateSim = integer.valueOf(timeFormat.substringBefore(':'));
                        system.debug('v### AssetLocalTime24HourFormateSim ### ==>'+AssetLocalTime24HourFormateSim);
                        AssetLocalTime24HourFormateSim = AssetLocalTime24HourFormateSim + 12;
                        system.debug('v### AssetLocalTime24HourFormateSim ### ==>'+AssetLocalTime24HourFormateSim);
                    }
                    else if(timeFormat != null && timeFormat.contains('12') && timeFormat.contains('AM')){
                        //AssetLocalTime24HourFormate = '00';
                        AssetLocalTime24HourFormateSim = 00;
                        system.debug('v### AssetLocalTime24HourFormateSim ### ==>'+AssetLocalTime24HourFormateSim);
                    }
                    
                    integer getAssetLocalHour;
                    integer getAssetMin;
                    if(integer.valueOf(timeFormat.substringBetween(':', ' ')) != null){
                        getAssetMin = integer.valueOf(timeFormat.substringBetween(':', ' '));
                        system.debug('v### getAssetMin ### ==>'+getAssetMin);
                    }
                    
                    if(AssetLocalTime24HourFormateSim != null){
                        getAssetLocalHour = AssetLocalTime24HourFormateSim;
                        system.debug('v### getAssetLocalHour ### ==>'+getAssetLocalHour);
                    }
                    
                    DateTime newDateTime = system.today();
                    if(getAssetLocalHour != null && getAssetMin != null){                        
                        newDateTime = DateTime.newInstance(Integer.valueOf(dateFormat), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringBefore('/')),  Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween('/', '/')), getAssetLocalHour, getAssetMin ,0);
                    }
                    else{
                        newDateTime = DateTime.newInstance(Integer.valueOf(dateFormat), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringBefore('/')),  Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween('/', '/')), integer.valueOf(timeFormat.substringBefore(':')), Integer.valueOf(timeFormat.substringbetween(':', ' ')) ,0);
                    }
                    
                    system.debug('v### newDateTime ### ==>'+newDateTime);
                    //system.debug('### getHour ### '+getHour);
                    //DateTime newDateTime = DateTime.newInstance(2017, Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringBefore('/')),  Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween('/', '/')), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(' ', ':')), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(':', ' ')) ,0);
                    //DateTime newDateTime = DateTime.newInstance(Integer.valueOf(dateFormat), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringBefore('/')),  Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween('/', '/')), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(' ', ':')), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(':', ' ')) ,0);
                    //DateTime newDateTime = DateTime.newInstanceGMT(Integer.valueOf(dateFormat), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringBefore('/')),  Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween('/', '/')), getHour, Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(':', ' ')) ,0);
                    
                    
                    assetLocalDate = newDateTime;
                } 
                
                system.debug('### Asset Local date ### '+assetLocalDate);
                
                Date getAssetLocalDate;
                if(rma.rmaDeliveryDate__c != null && assetLocalDate != null){
                    getAssetLocalDate = Date.newInstance(assetLocalDate.year(), assetLocalDate.month(), assetLocalDate.day());            
                }
                system.debug('getAssetLocalDate '+ getAssetLocalDate);
                system.debug('rmaDeliveryDate__c '+ rma.rmaDeliveryDate__c);
                if(rma.rmaDeliveryDate__c != null && getAssetLocalDate != null){
                    if(rma.rmaDeliveryDate__c < getAssetLocalDate){
                        
                        system.debug('Entered');
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Delivery Date should be future date or Current date from Asset Local Date and Time (with nearest half time)'));
                        return null;
                    }
                }
                if(rma.rmaDeliveryDate__c != null && getAssetLocalDate != null && deliveryDateTime.getTime() != null && assetLocalDate.getTime() != null){
                    if((rma.rmaDeliveryDate__c == getAssetLocalDate) && (deliveryDateTime.getTime() < assetLocalDate.getTime())){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Delivery Time should not be past time from Asset Local Date and Time (with nearest half time)'));
                        return null;
                    }
                }
                if(rma.rmaDeliveryDate__c != null && getAssetLocalDate != null){
                    if(rma.rmaDeliveryDate__c >= getAssetLocalDate){
                        if(assetLocalDate.getTime() != null && deliveryDateTime.getTime() != null){
                            integer getTime = integer.valueOf(assetLocalDate.getTime() - deliveryDateTime.getTime());                
                            if(getTime < 0){
                                getTime = getTime * (-1);
                            }
                            integer finalTime = getTime/(1000*60*60);
                            if(finalTime < 4){
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Delivery Time Should not be within 4 hours from Asset Local Date and Time (rounded up to closest 30 min interval)'));
                                return null;
                            }
                        }
                        
                    }
                }
                
                Date actualDate;
                String convertedDate;
                String actualTime;
                if(rma.rmaDeliveryDate__c != null){
                    actualDate = rma.rmaDeliveryDate__c;
                    convertedDate = DateTime.newInstance(actualDate.year(),actualDate.month(),actualDate.day()).format('MM-dd-yyyy');
                }
                if(rma.rmaDeliveryTimes__c != null){
                    actualTime = rma.rmaDeliveryTimes__c;
                }
                system.debug('v### actualDate ### ==>'+actualDate);
                system.debug('v### convertedDate ### ==>'+convertedDate);
                system.debug('v### actualTime ### ==>'+actualTime);
                string trimAMPM;
                if(actualTime != null){
                    if(actualTime == '01:00 PM'){
                        trimAMPM = '13:00';
                    }
                    else if(actualTime == '01:30 PM'){
                        trimAMPM = '13:30';
                    }
                    else if(actualTime == '02:00 PM'){
                        trimAMPM = '14:00';
                    }
                    else if(actualTime == '02:30 PM'){
                        trimAMPM = '14:30';
                    }
                    else if(actualTime == '03:00 PM'){
                        trimAMPM = '15:00';
                    }
                    else if(actualTime == '03:30 PM'){
                        trimAMPM = '15:30';
                    }
                    else if(actualTime == '04:00 PM'){
                        trimAMPM = '16:00';
                    }
                    else if(actualTime == '04:30 PM'){
                        trimAMPM = '16:30';
                    }
                    else if(actualTime == '05:00 PM'){
                        trimAMPM = '17:00';
                    }
                    else if(actualTime == '05:30 PM'){
                        trimAMPM = '17:30';
                    }
                    else if(actualTime == '06:00 PM'){
                        trimAMPM = '18:00';
                    }
                    else if(actualTime == '06:30 PM'){
                        trimAMPM = '18:30';
                    }
                    else if(actualTime == '07:00 PM'){
                        trimAMPM = '19:00';
                    }
                    else if(actualTime == '07:30 PM'){
                        trimAMPM = '19:30';
                    }
                    else if(actualTime == '08:00 PM'){
                        trimAMPM = '20:00';
                    }
                    else if(actualTime == '08:30 PM'){
                        trimAMPM = '20:30';
                    }
                    else if(actualTime == '09:00 PM'){
                        trimAMPM = '21:00';
                    }
                    else if(actualTime == '09:30 PM'){
                        trimAMPM = '21:30';
                    }
                    else if(actualTime == '10:00 PM'){
                        trimAMPM = '22:00';
                    }
                    else if(actualTime == '10:30 PM'){
                        trimAMPM = '22:30';
                    }
                    else if(actualTime == '11:00 PM'){
                        trimAMPM = '23:00';
                    }
                    else if(actualTime == '11:30 PM'){
                        trimAMPM = '23:30';
                    }//commneted by vishnu for RMA scheduling
                    /*else if(actualTime == '12:00 AM'){
trimAMPM = '24:00';
}*/
                    else if(actualTime == '12:00 AM'){
                        trimAMPM = '00:00';
                    }
                    else if(actualTime == '12:30 AM'){
                        trimAMPM = '00:30';
                    }
                    else{
                        if(rma.rmaDeliveryTimes__c != null){
                            trimAMPM = rma.rmaDeliveryTimes__c;
                            trimAMPM = trimAMPM.substring(0,trimAMPM.length()-3);
                        }
                        
                    }
                }
                
                
                system.debug('v### trimAMPM ### ==>'+trimAMPM);
                system.debug('v### convertedDate ### ==>'+convertedDate);
                if(convertedDate !=null && trimAMPM != null){
                    rma.rmaRequestedDeliveryDateTime__c = convertedDate+' '+trimAMPM+':00';
                }
                else{
                    rma.rmaRequestedDeliveryDateTime__c = null;
                }
            }
            
            
            /*END - Delivery Scheduling Mechanism */
            
            if(hideOnSiteSections == true && rma.rmaShowOnSiteSectionsAlways__c != true)
                clearOnsiteSectionsFields(); 
            
            if(hideReturnSections == true && rma.rmaShowReturnSectionsAlways__c != true)
                clearReturnSectionFields();
            
            
            if(rma.rmaFaRequired__c == 'Engineering FA' && rma.rmaEFASource__c == null)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'EFA Source cannot be blank if EFA Priority is \'Engineering FA\''));
                return null;
            }
            // Fa Required should not be No FA Required if CFA is selected - change made on 4th May 2016
            if(rma.rmaCustomerFaRequired__c == true && rma.rmaFaRequired__c == 'No FA Required'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'FA Required cannot be set to \'No FA Required\' if Customer FA Required is selected'));
                return null; 
            }
            if(shipOnlyPart == true)
            {
                rma.rmaComponentIsAShipOnlyPart__c = true;
            }
            else
            {
                rma.rmaComponentIsAShipOnlyPart__c = false;
            }
            
            if(autoEFAPart == true)
            {
                rma.rmaComponentIsAutoEFA__c= true;
            }
            else
            {
                rma.rmaComponentIsAutoEFA__c = false;
            }
            
            if(rma.rmaEFASource__c == 'Auto-EFA')
            {
                getSrMetaDataOptions();
                if(srMetaDataMapByName.containsKey(selectedSrPart))
                {
                    if(srMetaDataMapByName.get(selectedSrPart).srAutoEFA__c == false)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'EFA Source cannot be set to Auto-EFA since selected part is not Auto-EFA\'d'));
                        return null;
                    }
                }
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'EFA Source cannot be set to Auto-EFA since selected part is not Auto-EFA\'d'));
                    return null;
                }
            }
            if(selectedSrPart != null){
                rma.rmaFailedPart__c = selectedSrPart;
            }
            
            upsert rma;
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/apex/RMAv2DetailPageV2?id='+rma.id);
    }
    
    //###################################################################################################### clearAddressFields
    public void clearAddressFields()
    {
        rma.rmaOverrideShipmentAccountName__c = null;
        rma.rmaOverrideShipmentStreet1__c = null;
        rma.rmaOverrideShipmentStreet2__c = null;
        rma.rmaOverrideShipmentCity__c = null;
        rma.rmaOverrideShipmentState__c = null;
        rma.rmaOverrideShipmentPostalCode__c = null;
        rma.rmaOverrideShipmentCountry__c = null;
        rma.rmaOverrideShipmentAttn__c = null;
        rma.rmaOverrideShipmentPhone__c = null;
        rma.rmaOverrideShipmentEmail__c = null;
        //rma.rmaAddressBook__c = null;
        strShipmentLocationValidatedOn =null;
        rma.rmaAddOverriddenAddressToAddressBook__c=null;
        
        //Added by exafort for TS-10402
        rma.rmaOverrideOnsitePartHandoverCode__c = null;
        rma.rmaOverrideOnsiteSchedulingCode__c = null;
        rma.rmaOverrideOnsiteSchedulingNotes__c = null;
        rma.rmaOverrideOnsitePartHandoverNotes__c = null;
        rma.rmaOverrideOnsiteCheckInCode__c = null;
        rma.rmaOverrideOnsiteCheckInNotes__c = null;
        rma.rmaOverrideOnsitePartDispositionCode__c = null;
        rma.rmaOverrideOnsitePartDispositionNotes__c = null;
        //End of TS-10402
    }
    
    //###################################################################################################### clearOnsiteSectionsFields
    public void clearOnsiteSectionsFields()
    {
        //Onsite Service Info Section
        //rma.rmaOnsiteTechStatus__c = null;
        rma.rmaOnsiteTechDateTimeOrderConfirmed__c = null;
        rma.rmaOnsiteTechDateTimeArrivalEta__c = null;
        rma.rmaOnsiteTechOrderNumber__c = null;
        rma.rmaOnsiteTechDateTimeArrivalActual__c = null;
        rma.rmaOnsiteTechName__c = null;
        rma.rmaOnsiteTechDateTimeReleased__c = null;
        
        
        //Onsite Service - Codes/Notes
        rma.rmaOverrideOnsiteSchedulingCode__c = null;
        rma.rmaOverrideOnsiteSchedulingNotes__c = null;
        rma.rmaOverrideOnsitePartHandoverCode__c = null;
        rma.rmaOverrideOnsitePartHandoverNotes__c = null;
        rma.rmaOverrideOnsiteCheckInCode__c = null;
        rma.rmaOverrideOnsiteCheckInNotes__c = null;
        rma.rmaOverrideOnsitePartDispositionCode__c = null;
        rma.rmaOverrideOnsitePartDispositionNotes__c = null;
        
        //Onsite Service - FE Arrival Address
        rma.rmaOverrideOnsiteArrivalStreet1__c = null;
        rma.rmaOverrideOnsiteArrivalStreet2__c = null;
        rma.rmaOverrideOnsiteArrivalCity__c = null;
        rma.rmaOverrideOnsiteArrivalState__c = null;
        rma.rmaOverrideOnsiteArrivalPostalCode__c = null;
        rma.rmaOverrideOnsiteArrivalCountry__c = null;
        
        //Onsite Service - Array Location
        rma.rmaOverrideAssetLocBuilding__c = null;
        rma.rmaOverrideAssetLocFloor__c = null;
        rma.rmaOverrideAssetLocDatacenter__c = null;
        rma.rmaOverrideAssetLocAreaOrGrid__c = null;
        rma.rmaOverrideAssetLocRow__c = null;
        rma.rmaOverrideAssetLocRack__c = null;
        rma.rmaOverrideAssetLocPositionInRack__c = null;
        
        //Onsite Service - Component Slots
        rma.rmaOnsiteControllerExpanderSlot__c = null;
        rma.rmaOnsiteHddSsdSlot__c = null;
        rma.rmaOnsitePowerSupplySlot__c = null;
        rma.rmaOnsiteNicCardSlot__c = null;
    }
    
    //###################################################################################################### clearReturnSectionFields
    public void clearReturnSectionFields()
    {
        rma.rmaRetShipProviderOrderNumber__c=null;
        rma.rmaReturnShipmentCarrier__c= null;
        rma.rmaReturnShipmentTrackingNumber__c=null;
        rma.rmaReturnShipmentNotes__c=null;
        rma.rmaRetShipDateTimeDelivered__c=null;
        rma.rmaRetShipSignedForBy__c=null;
        
        //rma.rmaRetShip2Status__c=null;
        rma.rmaRetShip2Carrier__c=null;
        rma.rmaRetShip2TrackingNumber__c=null;
        rma.rmaRetShip2DateTimeShipped__c=null;
        rma.rmaRetShip2DateTimeEta__c=null;
        rma.rmaRetShip2DateTimeDelivered__c=null;
        rma.rmaRetShip2SignedForBy__c=null;
    }
    
    //###################################################################################################### getTransmitRMASHICheckboxes
    public list<selectOption> getTransmitRMASHICheckboxes(){
        List<SelectOption> transmitRMASHIOptions = new list<selectOption>();
        transmitRMASHIOptions.add(new selectOption('Account RMA SHI','Account RMA SHI'));
        transmitRMASHIOptions.add(new selectOption('Asset RMA SHI','Asset RMA SHI'));
        return transmitRMASHIOptions ;
    }
    
    //###################################################################################################### generatedRmaShiText
    public void generatedRmaShiText(string strAccountRMASHIText,string strAssetRMASHIText)
    {
        checkboxTransmitRMASelections = new List<string>();
        
        if(strAccountRMASHIText !='' && strAssetRMASHIText  !='')
        {
            rma.rmashi__c =  strAccountRMASHIText + '\n\r' + strAssetRMASHIText + '\n\r' ;
            checkboxTransmitRMASelections.add('Account RMA SHI');
            checkboxTransmitRMASelections.add('Asset RMA SHI');
        }
        else if(strAccountRMASHIText !='')
        {
            rma.rmashi__c =  strAccountRMASHIText + '\n\r';
            checkboxTransmitRMASelections.add('Account RMA SHI');
        }
        
        else if(strAssetRMASHIText  != '')
        {
            rma.rmashi__c =  strAssetRMASHIText + '\n\r';
            checkboxTransmitRMASelections.add('Asset RMA SHI');
        }
        else
        {
            rma.rmashi__c = null;
        }
        
        
    }
    
    //###################################################################################################### componentLoad
    public List<String> getassetOuterMap1()
    {
        Map<String,String> assetParentMap = new Map<String,String>();
        assetOuterMap = new Map<String,Map<string,List<List<Component__c>>>>(); //TS-6880 updated declaration 
        
        if(ComponentAccountId != null)
        {
            currrentAccountName = ComponentAccountName+ ' ' + 'Assets';
            getSrMetaDataOptions();
            
            assetIdbyKey = new Map<String,String>();
            
            parentAssetMap = new Map<String,String>();
            assetProductNameMap = new Map<String,String>();
            
            
            //List<component__c> componentList = [SELECT Id,componentDescription__c,componentAsset__c,componentAssetParentName__c,componentAssetProductName__c,componentLocation__c,componentStatus__c,componentServicePartNumber__c,componentAssetName__c,componentComponentSN__c,componentType__c FROM Component__c where componentAccountId__c=:accountId order by componentAsset__c];
            
            //Map<id,Component__c> componentMap = new Map<id,Component__c>([SELECT Id,componentDiskShelfSlot__c,ComponentDiskLocationForRMA__c,componentDescription__c,componentAsset__c,componentAssetParentName__c,componentAssetProductName__c,componentLocation__c,componentStatus__c,componentServicePartNumber__c,componentAssetName__c,componentAssetStatus__c,componentComponentSN__c,componentType__c FROM Component__c where componentAccountId__c=:ComponentAccountId  AND componentAssetStatus__c='Shipped' AND (componentAsset__c=:rma.rmaAssetId__c OR componentAsset__r.Parent_Asset__c=:rma.Name) order by componentAsset__c]);
            
            // TS-8525 - Response size exceeded 15MB organization limit error when creating RMA added by Larry Wasser 
            // New version of query to find only the components associated with the asset/parent asset related to the case from which this RMA is being created
            Map<id,Component__c> componentMap = new Map<id,Component__c>([SELECT Id,componentDiskShelfSlot__c,ComponentDiskLocationForRMA__c,componentDescription__c,componentAsset__c,componentAssetParentName__c,componentAssetProductName__c,componentLocation__c,componentStatus__c,componentServicePartNumber__c,componentAssetName__c,componentAssetStatus__c,componentComponentSN__c,componentType__c FROM Component__c where componentAccountId__c=:ComponentAccountId  AND componentAssetStatus__c='Shipped' AND (componentAsset__r.Name=:linkedCaseAssetName OR componentAssetParentName__c=:linkedCaseAssetName) order by componentAsset__c]);
            
            List<Component__c> componentList = componentMap.values();
            
            
            for(component__c component:componentList)
            {
                
                string key = component.componentAssetName__c;
                // Added by Exafort for TS-9230
                Boolean isInProd = True;
                if(srMetaDataMapByName.containsKey(component.componentServicePartNumber__c))
                {
                    /** When component matching SR Metadata.IsInProd == false need to avoid that component on loading in RMA page
// In existing we load all the components, don't check for SR MetaData
*/
                    if(srMetaDataMapByName.get(component.componentServicePartNumber__c) != null && 
                       srMetaDataMapByName.get(component.componentServicePartNumber__c).Is_In_Prod__c == false){
                           isInProd = false; 
                       }
                    
                    component.componentDescription__c = (srMetaDataMapByName.get(component.componentServicePartNumber__c).srDescription__c) + ' ' + ((srMetaDataMapByName.get(component.componentServicePartNumber__c).srExtendedDescription__c!=null) ? + '\n' +srMetaDataMapByName.get(component.componentServicePartNumber__c).srExtendedDescription__c: '');
                }
                // Will process only the component's matching SR MetaData.IsInProd = True and component with no SR MetaData
                if(isInProd){
                    
                    
                    if(key == null)
                    {
                        key = 'Spares or Upgrades';
                        assetIdbyKey.put(key,'');
                    }
                    else
                    {
                        assetIdbyKey.put(key,component.componentAsset__c);
                        
                        if(component.componentAssetParentName__c != null)
                        {
                            assetParentMap.put(key,component.componentAssetParentName__c);
                        }
                    }
                    
                    
                    if(component.componentAssetParentName__c != null)
                    {
                        parentAssetMap.put(key,'Parent Asset:' + component.componentAssetParentName__c);
                    }
                    else
                    {
                        parentAssetMap.put(key,'E');
                    }
                    
                    if(component.componentAssetProductName__c != null)
                    {
                        assetProductNameMap.put(key, '[' + component.componentAssetProductName__c + ']');
                    }
                    else
                    {
                        assetProductNameMap.put(key,'E');
                    }
                    
                    List<List<Component__c>> lstAllComponent = new List<List<Component__c>>();
                    List<Component__c> lstCurrentComponent = new List<Component__c>();
                    lstCurrentComponent.add(component);
                    
                    if(assetOuterMap.containsKey(key))
                    {
                        Map<String,List<List<Component__c>>> mapExistingComponent = assetOuterMap.get(key); //TS-6880
                        
                        if(mapExistingComponent.containsKey(component.componentType__c))
                        {
                            //List<component__c> lstExistingComponent = mapExistingComponent.get(component.componentType__c);
                            lstAllComponent = mapExistingComponent.get(component.componentType__c); //TS-6880
                            if(lstAllComponent.size() > 0)
                            {
                                List<component__c> lstExistingComponent = lstAllComponent[lstAllComponent.size() - 1];
                                if(lstExistingComponent.size() == 1000)
                                {
                                    lstExistingComponent = new List<component__c>();
                                    lstExistingComponent.add(component);
                                    lstAllComponent.add(lstExistingComponent);
                                    
                                }
                                else
                                {
                                    lstExistingComponent.add(component);
                                    lstAllComponent.remove(lstAllComponent.size() - 1);
                                    lstAllComponent.add(lstExistingComponent);
                                }
                            }
                            
                            mapExistingComponent.put(component.componentType__c,lstAllComponent);
                            assetOuterMap.put(key,mapExistingComponent);
                        }
                        else
                        {
                            lstAllComponent.add(lstCurrentComponent);//TS-6880
                            mapExistingComponent.put(component.componentType__c,lstAllComponent);
                            assetOuterMap.put(key,mapExistingComponent);
                        }
                    }
                    else
                    {
                        Map<String,List<List<Component__c>>> componentInnerMap = new Map<String,List<List<Component__c>>>();
                        lstAllComponent.add(lstCurrentComponent);//TS-6880
                        componentInnerMap.put(component.componentType__c,lstAllComponent);
                        assetOuterMap.put(key,componentInnerMap);
                    }
                }
            }
        }
        
        
        List<String> ordered_keys = performSorting(assetOuterMap,assetParentMap);
        
        return ordered_keys;
        
    }
    
    public List<String> performSorting(Map<String,Map<string,List<List<Component__c>>>> assetOuterMap,Map<String,String> assetParentMap)//TS-6880
    {
        
        Set<String> addedKeys = new Set<String>();
        List<String> ordered_keys = new List<String>();
        List<string> sortedList = new List<string>();
        
        if(rma.rmaSelection__c == 'Spares or Upgrades')
        {
            if(assetOuterMap.containsKey('Spares or Upgrades'))
            {
                ordered_keys.add('Spares or Upgrades');
                addedKeys.add('Spares or Upgrades');
            }
        }
        
        
        if(linkedCaseAssetName != linkedDiskAssetName)
        {
            
            if(assetOuterMap.containsKey(linkedDiskAssetName))
            {
                ordered_keys.add(linkedDiskAssetName);
                addedKeys.add(linkedDiskAssetName);
            }
        }
        
        //Case Asset
        if(assetOuterMap.containsKey(linkedCaseAssetName))
        {
            ordered_keys.add(linkedCaseAssetName);
            addedKeys.add(linkedCaseAssetName);
        }
        
        //Case Disk Shelf
        for(string key:assetOuterMap.keySet())
        {
            if(!addedKeys.contains(key))
            {
                if(assetParentMap.containsKey(key))
                {
                    if(assetParentMap.get(key) == linkedCaseAssetName)
                    {
                        ordered_keys.add(Key);
                        addedKeys.add(Key);
                    }
                    else
                    {
                        sortedList.add(Key);
                        addedKeys.add(Key);
                    }
                }
                else
                {
                    sortedList.add(Key);
                    addedKeys.add(Key);
                }
            }
        }
        
        sortedList.Sort();
        ordered_keys.addAll(sortedList);
        
        totalRecs = ordered_keys.size();
        
        List<string> resultList = new List<string>();
        if(ordered_keys.size() > 0)
        {
            
            Integer EndValue = null;
            
            
            if((OffsetSize + LimitSize) > totalRecs )
            {
                EndValue = totalRecs;
            }
            else
            {
                EndValue = OffsetSize + LimitSize;
            }
            
            
            for(integer start = OffsetSize ; start < EndValue; ++start)
            {
                resultList.add(ordered_keys[start]);
            } 
            
        }
        
        return resultList;
        
    }
    
    //###################################################################################################### checkboxOnChange
    public void checkboxOnChange()
    {
        string identity = Apexpages.currentPage().getParameters().get('identity');
        string identityValue = Apexpages.currentPage().getParameters().get('identityValue');
        string assetToProcess = Apexpages.currentPage().getParameters().get('assetToProcess');
        string isSelected= Apexpages.currentPage().getParameters().get('isSelected');
        string componentType = Apexpages.currentPage().getParameters().get('componentType');
        selectedSrPart =  Apexpages.currentPage().getParameters().get('srPart');
        
        
        if(isSelected != 'false')
        {
            if(identity == 'Asset')
            {
                rma.rmaDiskShelfAsset__c = assetIdbyKey.get(assetToProcess);
                checkForChinaGaRma(assetIdbyKey.get(assetToProcess)); // Added by Exafort for SFDC-626
                rma.rmaSelection__c = identity;
                rma.rmaComponent__c = 'SYS (complete system)';
                //assetToExpand = assetToProcess;
            }
            else if(identity == 'Component')
            {
                rma.rmaComponentV2__c = identityValue;
                rma.rmaDiskShelfAsset__c = assetIdbyKey.get(assetToProcess); 
                checkForChinaGaRma(assetIdbyKey.get(assetToProcess)); // Added by Exafort for SFDC-626
                rma.rmaSelection__c = identity;
                rma.rmaComponent__c = componentType;
                //assetToExpand = assetToProcess;
            }
            else if(identity == 'Spares or Upgrades')
            {
                rma.rmaComponentV2__c = identityValue;
                rma.rmaDiskShelfAsset__c = linkedAssetId;
                rma.rmaSelection__c = identity;
                rma.rmaComponent__c = componentType;
                //assetToExpand = 'Spares or Upgrades';
            }
        }
        else
        {
            rma.rmaDiskShelfAsset__c = null;
            rma.rmaComponentV2__c = null;
            rma.rmaSelection__c = null;
            rma.rmaComponent__c = null;
        }
        
        clearAddressFields();
        rmaNewRecord();
        system.debug('selectedSrPart =====>'+selectedSrPart);
        //Added by exafort(vishnu) on 21st Jan 2018 for hiding Onsite information and SLA Override to NBD(TS-5318)
        //Added a null check for selectedSrPart to fix the issue for Full RMA TS-5744 on 12th april 2019 by vishnu.
        if( selectedSrPart != '') 
        {
            OnsiteValueForNBD(selectedSrPart);
        }
    }
   
    
    //###################################################################################################### onPartSelectionViewChange
    public void onPartSelectionViewChange(){ 
        if(partScreenSelection == 'Flat List View')
        {
            rma.rmaSelection__c = 'Flat List'; 
            rma.rmaDiskShelfAsset__c = null;
            rma.rmaComponentV2__c = null;
            rma.rmaComponent__c = null;
            rma.rmaSrFlatList__c = null;
        }
        else
        {
            rma.rmaDiskShelfAsset__c = null;
            rma.rmaComponentV2__c = null;
            rma.rmaSelection__c = null;
            rma.rmaComponent__c = null;
            rma.rmaSrFlatList__c = null;
            selectedAssetForRMA = null;
            selectedComponentForRMA = null;
        } 
        
        clearAddressFields();
        rmaNewRecord();
        
        // Added by Exafort for SFDC-627
        flatListSelection = 'Based On Head and All Related Assets';
        handleRadioChange();
        
    }
    //###################################################################################################### OnsiteValueForNBD
    //Added by exafort(vishnu) on 21st Jan 2018 for hiding Onsite information and SLA Override to NBD(TS-5318)
    public void OnsiteValueForNBD(String SRPart){
        //Commented by vishnu on 12th April 2019 to fix TS-5744.uncomment these lines in sandbox for debugging.
        /*system.debug('### Asset SLA ==>'+AssetSLA);
system.debug('### Selected Part from the RMA ==>'+SRPart);
system.debug('### part ship override SLA Value ==>'+srMetaDataMapByName.get(SRPart).srPartShipSLAOverride__c);
system.debug('### Pachinko Case Type ==>'+rma.PachinkoCaseType__c);
system.debug('### Pachinko Case Type variable ==>'+casePachinkoTypeForRMANew);*/
        if(srMetaDataMapByName.get(SRPart) != null){
            OnsiteValueForSLANBD = srMetaDataMapByName.get(SRPart).srPartShipSLAOverride__c;
        }
//        if(AssetSLA !='' && AssetSLA.Contains('Onsite')){
        if(rmaTriggerHandler.isOnsiteSLA(assetSLA)){
            //TS-6667 START  Added by Exafort on August 19 2020
            if(rma.rmaUplift__c != null && rma.rmaUplift__c == 'Premium Onsite'){
                alwaysShownOnSiteSection = true; 
            }
            //TS-6667 END  Added by Exafort on August 19 2020           
            else if(OnsiteValueForSLANBD != null && OnsiteValueForSLANBD == 'NBD & Onsite Override'){ //|| casePachinkoTypeForRMANew == 'ssdwearlevelhigh')
                System.debug('### 1');
                alwaysShownOnSiteSection = false;
                hideOnSiteSections = true;
            }
            else{
                System.debug('### 2');
                alwaysShownOnSiteSection = true;
            }
        }else{
            System.debug('### 3');
            alwaysShownOnSiteSection = false;
            hideOnSiteSections = true;
        }
    }
    //###################################################################################################### getSrMetaDataOptions
    public List<SelectOption> getSrMetaDataOptions()
    {
        
        srMetaDataMap = new Map<string, SR_Meta_Data__c>();
        srMetaDataMapByName = new Map<string, SR_Meta_Data__c>();
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('', '- None -'));
        
        // Added by Exafort for TS-9340 to get the related child assets
        set<string> relatedAssetTypes = new set<string>();
        system.debug('linkedAssetName = '+ linkedAssetName);
        if(rma.rmaCaseNumber__c != null && linkedAssetName != null && flatListSelection == 'Based On Head and All Related Assets'){
            for(Asset relatedAssets : [select id, name, Parent_Asset__c, Asset_Type__c from asset where (Parent_Asset__r.name =: linkedAssetName)]){
                relatedAssetTypes.add(relatedAssets.Asset_Type__c.toUpperCase()); 
            }
            system.debug('relatedAssetTypes ='+ relatedAssetTypes);
        }
        // Added end
        
        //Added srPartShipSLAOverride__c by exafort(vishnu) on 21st Jan 2018 for hiding Onsite information for ssdwearlevelhigh(TS-5258) and SLA Override to NBD(tS-5318).
        // Added Is_In_Prod__c field in the below query and Is_In_Prod__c == true for TS-9230 By Exafort
        
        /** Changes for TS-9340 By Exafort
* Updated below soql query where condition to filter the SR MetaData records
* "srmetadataIsValid__c = true and Is_In_Prod__c = true"
**/
        
        for (SR_Meta_Data__c sr:[SELECT Id,srPartShipSLAOverride__c,srPart__c,srType__c,srShipOnly__c,srShippingProvider__c,srAutoEFA__c,srDescription__c,
                                 srmetadataIsValid__c,srExtendedDescription__c,Is_In_Prod__c,srAssetType__c  
                                 from SR_Meta_Data__c 
                                 where srmetadataIsValid__c = true and 
                                 Is_In_Prod__c = true  order by srPart__c])
            
        {
            /** Changes for TS-9340 By Exafort
* On Flat List View introduced three radio buttons "Based On Head and All Related Assets", "Specified Asset Only", "Unfiltered"
* Based on radio button selection SR MetaData records on SR Flat List is displayed in VF page
* UnFiltered - All the eligible records from the above SOQL Query
* Based On Head and All Related Assets - From all the eligible records filtered based
*              						  on "rmaCaseNumber__c.Asset.AssetType" and all child assets.assetType with "SRMetaData.srAssetType__c"
* Specified Asset Only - From all the eligible records filtered based on "rmaDiskShelfAsset__c.assetType with " "SRMetaData.srAssetType__c"
**/
            
            
            if(flatListSelection == 'Unfiltered')
            {
                if(rma.Flat_List_Type__c != 'Unfiltered'){
                    rma.Flat_List_Type__c = 'Unfiltered';
                }
                // New method for adding SR MetaData records to SR Flat List Options
                addPartToSRflatList(sr,options);
                
            }
            else if(flatListSelection == 'Specified Asset Only' && rma.rmaDiskShelfAsset__c != null && sr.srAssetType__c != null)
            {
                string [] srAssetTypeSplit = sr.srAssetType__c.split(',');
                system.debug('srAssetTypeSplit = '+ srAssetTypeSplit);
                Boolean specifiedAssetTypeFound = false;
                for(string srAssetType : srAssetTypeSplit){
                    string trimmedSrAssetType = srAssetType.trim();
                    if(linkedAssetType != null && trimmedSrAssetType.equalsIgnoreCase(linkedAssetType)){
                        specifiedAssetTypeFound = True;
                        system.debug('srAssetType = '+ srAssetType);
                    }
                }
                // New method for mapping SR Flat List Options
                if(specifiedAssetTypeFound){
                    if(rma.Flat_List_Type__c != 'Specified Asset Only'){
                        rma.Flat_List_Type__c = 'Specified Asset Only';	
                    }
                    addPartToSRflatList(sr,options); 
                }
                
            }
            
            else if(flatListSelection == 'Based On Head and All Related Assets' && rma.rmaCaseNumber__c != null && sr.srAssetType__c != null)
            {
                string [] srAssetTypeSplit = sr.srAssetType__c.split(',');
                system.debug('srAssetTypeSplit = '+ srAssetTypeSplit);
                Boolean basedOnAssetTypeFound = false;
                for(string srAssetType : srAssetTypeSplit){
                    string trimmedSrAssetType = srAssetType.trim();
                    if((linkedCaseAssetType != null && trimmedSrAssetType.equalsIgnoreCase(linkedCaseAssetType)) || 
                       (relatedAssetTypes != null && relatedAssetTypes.Contains(trimmedSrAssetType.toUpperCase())))
                    {
                        basedOnAssetTypeFound = True;
                        system.debug('srAssetType = '+ srAssetType);
                    }
                }
                // New method for mapping SR Flat List Options
                if(basedOnAssetTypeFound){
                    if(rma.Flat_List_Type__c != 'Based On Head and All Related Assets'){
                        rma.Flat_List_Type__c = 'Based On Head and All Related Assets';	
                    }
                    addPartToSRflatList(sr,options); 
                }
                
            }
            //system.debug('options size = '+ options.size());
            // Changes end
            srMetaDataMap.put(sr.Id,sr);
            srMetaDataMapByName.put(sr.srPart__c,sr);
        }
        return options; 
    }
    //###################################################################################################### srFlatListOptionsMapping
    /*
* Changes for TS-9340 By Exafort
* New method for adding SR MetaData records to SR Flat List Options
* This method is called from "getSrMetaDataOptions" method
**/
    public void addPartToSRflatList(SR_Meta_Data__c srMetaData, List<selectOption> options){
        
        if(srMetaData.srDescription__c != null && srMetaData.srExtendedDescription__c == null)
        {
            options.add(new selectOption(srMetaData.Id,srMetaData.srPart__c  + ' : ' + srMetaData.srDescription__c)); 
        }
        else if(srMetaData.srDescription__c != null && srMetaData.srExtendedDescription__c != null)
        {
            options.add(new selectOption(srMetaData.Id,srMetaData.srPart__c  + ' : ' + srMetaData.srDescription__c + ' : ' + srMetaData.srExtendedDescription__c)); 
        }
        else
        {
            options.add(new selectOption(srMetaData.Id,srMetaData.srPart__c)); 
        }
    }
    
    //###################################################################################################### srFlatListOnChange
    public void srFlatListOnChange()
    {
        if(rma.rmaSrFlatList__c != null)
        {
            rma.rmaComponent__c = srMetaDataMap.get(rma.rmaSrFlatList__c).srType__c;
            selectedSrPart = srMetaDataMap.get(rma.rmaSrFlatList__c).srPart__c;
            rmaNewRecord();
            //Added by exafort(vishnu) on 23rd Jan 2018 for hiding Onsite information and SLA Override to NBD(tS-5318)
            OnsiteValueForNBD(selectedSrPart);
        }
        
    }
    
    //###################################################################################################### onEFASourceChange
    public void onEFASourceChange()
    {
        efaSourceValue= rma.rmaEFASource__c;
    }
    
    
    public void FirstPage()
    {
        OffsetSize = 0;
    }
    
    public void previous()
    {
        OffsetSize = OffsetSize - LimitSize;
    }
    
    public void next()
    {
        OffsetSize = OffsetSize + LimitSize;
        onPartSelectionViewChange();
    }
    
    public void LastPage()
    {
        OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
        onPartSelectionViewChange();
    }
    
    public boolean getprev()
    {
        if(OffsetSize == 0)
            return true;
        else
            return false;
    }
    
    public boolean getnxt()
    {
        if((OffsetSize + LimitSize) > totalRecs)
            return true;
        else
            return false;
    }
    
    public string getPageDetails()
    {
        
        Integer pageSize = OffsetSize + LimitSize;
        Integer showingAsset = pageSize -LimitSize;
        if(totalRecs <= 0)
        {
            return 'Showing 0 out of 0 Assets';
        }
        else
        {
            if(pageSize  < totalRecs)
            {
                if(showingAsset == 0)
                {
                    showingAsset = 1;
                }
                return 'Showing ' + showingAsset  + '-'  + pageSize  + ' out of ' + totalRecs + ' Assets';
            }
            else
            {
                if(showingAsset == 0)
                {
                    showingAsset = 1;
                }
                return 'Showing ' + showingAsset  + '-'  + totalRecs + ' out of ' + totalRecs + ' Assets';
            }
        }
        
    }
    public string setNimbleOsVersion(string NimbleOsVersion)
    {
        
        Pattern osPatter = Pattern.compile('^(\\d*).(\\d*).(\\d*).(\\d*)(.*?)$');
        Matcher osVersionMatcher = osPatter.matcher(NimbleOsVersion);
        if (osVersionMatcher.find())
        {
            try
            {
                Integer assetOsMajor = Integer.valueOf(osVersionMatcher.group(1));
                Integer assetOsMinor = Integer.valueOf(osVersionMatcher.group(2));
                Integer assetOsSub1  = Integer.valueOf(osVersionMatcher.group(3));
                Integer assetOsSub2  = Integer.valueOf(osVersionMatcher.group(4));
                NimbleOsVersion = assetOsMajor + '.' + assetOsMinor + '.' + assetOsSub1 + '.' + assetOsSub2;
            }
            catch(Exception e)
            {
                //osVersion = NimbleOsVersion;
            }
        }
        
        return NimbleOsVersion;
        
    }
    
    
    /*                
*  TS-7467 July 13, 2020  --- START --- 
*  Enhance RMAV2 Edit page to support Google API Application Restrictions
*  Belowed Methods are helps to find out the Asset local Date and Time 
*/    
    public  double assetLatitude{get;set;}
    public  double assetLongitude{get;set;}
    public  integer assetrawOffset{get;set;}
    public  integer assetdstOffset{get;set;}
    public String timeZoneName {get;set;}
    public String assettimeStamp {get;set;}
    public String assetCountry {get;set;}
    
    public void calculateGeolocationBasedOnCountry(){
        JSONParser responseParser = Geolocationaddress.callGeolocationApi(assetCountry);   
        string status = Geolocationaddress.statusFromJson(responseParser);
        if(status == 'ok'){
            responseParser = Geolocationaddress.callGeolocationApi(assetCountry);
            while(responseParser.nextToken() != null) {
                assetLatitude = null;
                assetLongitude = null;
                if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'location')) {
                    responseParser.nextToken();
                    while(responseParser.nextToken() != JSONToken.END_OBJECT) {
                        String locationText = responseParser.getText();
                        responseParser.nextToken();
                        if (locationText == 'lat')   
                            assetLatitude = responseParser.getDoubleValue();
                        else if (locationText == 'lng')
                            assetLongitude = responseParser.getDoubleValue();                           
                    }
                }
                //	When first one is found break
                if (assetLatitude != null && assetLongitude != null){
                    break;
                }
            }
        }
        
    }         
    public void calculateAssetTimeZone(){
        system.Debug('calculateAssetTimeZone' + assetLatitude +' '+ assetLongitude);
        if(assetLatitude !=null && assetLongitude !=null){                                     
            JSONParser jsonString = Geolocationaddress.callGeolocationTimeZoneApi(assetLatitude,assetLongitude,assettimeStamp);                         
            string status = Geolocationaddress.statusFromJson(jsonString);
            if(status == 'ok'){
                jsonString = Geolocationaddress.callGeolocationTimeZoneApi(assetLatitude,assetLongitude,assettimeStamp);  
                while(jsonString.nextToken() != null) {                        
                    if (jsonString.getCurrentToken() == JSONToken.FIELD_NAME) {
                        String locationText = jsonString.getText();
                        jsonString.nextToken();                         
                        if(locationText == 'dstOffset'){assetdstOffset = jsonString.getIntegerValue();}                                                   
                        if(locationText == 'rawOffset'){assetrawOffset = jsonString.getIntegerValue();}                            
                        if(locationText == 'timeZoneName'){timeZoneName = jsonString.getText();}                            
                    }                
                } 
            }            
        }        
    }
    
    /*  TS-7467 July 13, 2020  --- END  --- */
    
    //Added by exafort TS-9679
    public String getstringReasonWithToolTipMap(){
        return JSON.serialize(reasonWithToolTipMap);
    }
    
    // Added by Exafort for TS-10592
	/*
		Returns Id for the the Profile "NS-BusinessAdmin Support"
	 */
    public static string getSupportProfileIdForNSBusinessAdmin(){
        // Query to get the NS-BusinessAdmin Support profile ID
        List<Profile> profileList = [SELECT Id FROM Profile WHERE Name = 'NS-BusinessAdmin Support' LIMIT 1];
        
        if (profileList != null && !profileList.isEmpty()) {
			return profileList[0].Id;
        }
        return null;
    }
    
    /*
		Sets NSBusinessAdminSupportProfileId by querying profile object
	*/
    Public void setNSBusinessAdminSupportProfileId() {
        NSBusinessAdminSupportProfileId = getSupportProfileIdForNSBusinessAdmin();
    }
    //	End of TS-10592
    
    // Added by exafort for SFDC-626
    public void checkForChinaGaRma(id assetId){
        system.debug('Entered into China GA RMA');
        //	Parent_Asset__r.Dual_Support_Providers__c If condition updated by Exafort for SFDC-1999
        Asset selectedComponentAsset = [select id,Install_Country__c,Dual_Support_Providers__c,Parent_Asset__r.Dual_Support_Providers__c from Asset Where id =: assetId];
        if((selectedComponentAsset.Install_Country__c == 'China' || rma.rmaShipmentCountry__c == 'China') && 
           (selectedComponentAsset.Dual_Support_Providers__c == true || selectedComponentAsset.Parent_Asset__r.Dual_Support_Providers__c == True)){
            chinaGlobalAccount = true;
        } else {
            chinaGlobalAccount = False;
        }
    }
    // End of SFDC-626
   
    // Added by Exafort for SFDC-627
    public void handleRadioChange() {
        
        chinaGlobalAccount = false;
        if(flatListSelection == 'Based On Head and All Related Assets' || flatListSelection == 'Unfiltered') {
            system.debug('Based On Head and All Related Assets, Unfiltered');
            if(rmaCaseNumber!= null){
                //	Parent_Asset__r.Dual_Support_Providers__c If condition updated by Exafort for SFDC-1999
                List<case> caseRecords = [SELECT id,Asset.Install_Country__c,Asset.Dual_Support_Providers__c,asset.Parent_Asset__r.Dual_Support_Providers__c FROM case WHERE Id = :rmaCaseNumber LIMIT 1];
                if(caseRecords[0].Asset.Install_Country__c == 'China' && 
                   (caseRecords[0].Asset.Dual_Support_Providers__c == true || caseRecords[0].asset.Parent_Asset__r.Dual_Support_Providers__c == True)){
                    chinaGlobalAccount = True;
                }
            }
            
        } else if(flatListSelection == 'Specified Asset Only') {
            chinaGlobalAccount = false;
        } 
    }
    // End of SFDC-627
    
    // Added by Exafort for SFDC-600
    
    /*
     * This returns list of depots available for rmaOutgoingShipmentDepot__c field. This list's format is formed dynamically based on the data value in rmaOutgoingShipmentDepot__c.
     * It could be either
     * 		depotName + '-' + depotLocationDescription 
	 * 		OR
	 * 		depotLocationDescription
     * 
	*/     
    public void fetchDepotOptions() {
        depotOptions.add(new SelectOption('', '--None--'));
        //	Added by Exafort for SFDC-2342
        String outgoingDepot = rma.rmaOutgoingShipmentDepot__c;
        Boolean useLocationLabel = false;
//        Boolean useNameLocationLabel = false;
        
        List<Depot__c> activeDepots = [SELECT Id, Name, depotLocationDescription__c FROM Depot__c WHERE depotIsActive__c = true order by Name ASC];
        
        //	Go through list of depots and find the pattern to list the depots in based on the rmaOutgoingShipmentDepot__c field data
        for (Depot__c depot : activeDepots) {
            String locationLabel = depot.depotLocationDescription__c;
            String nameLocationLabel = depot.Name + ' - ' + depot.depotLocationDescription__c;
            
            //	Check if the field Outgoing Shipment Depot is null
            if (String.isBlank(outgoingDepot)) {
                useLocationLabel = true;
                break;
            }
            //	Check existing value on Outgoing Shipment Depot match with depot's Location Description
            else if (outgoingDepot == locationLabel) {
                useLocationLabel = true;
                break;
            }
            //	Check existing value on Outgoing Shipment Depot match with depot Name + Location Description
/*            else if (outgoingDepot == nameLocationLabel) {
                useNameLocationLabel = true;
                break; 
            }
*/
        }
        //	If both options stayed as false, use Name + Location combination
        /*	if (!useLocationLabel && !useNameLocationLabel) {
            useNameLocationLabel = true;
        }*/
        
        for (Depot__c depot : activeDepots) {
            String locationLabel = depot.depotLocationDescription__c;
            String nameLocationLabel = depot.Name + ' - ' + depot.depotLocationDescription__c;
            
            //	Forms Outgoing Shipment Depot field value 
            if (useLocationLabel) {
                depotOptions.add(new SelectOption(locationLabel, locationLabel));
            } else {
                depotOptions.add(new SelectOption(nameLocationLabel, nameLocationLabel));
            }
        }
    }

    // End of SFDC-600
    
    //	Added by Exafort for SFDC-2280
    //	Controls the RMA’s Onsite Status picklist values based on the RMA’s status
    public List<SelectOption> getOnsiteTechStatusOptions() {
        
        List<SelectOption> options = new List<SelectOption>();
        String rmaStatus = rma.rmaStatus__c;
        
        if (rmaStatus == 'Draft' || rmaStatus == null) {
            options.add(new SelectOption('', '--None--'));
            options.add(new SelectOption('DRAFT-10: Waiting to order', 'DRAFT-10: Waiting to order'));
            options.add(new SelectOption('N/A-10: No onsite for this RMA Type', 'N/A-10: No onsite for this RMA Type'));
        }
        else if (rmaStatus != 'Draft') {
            options.add(new SelectOption('DRAFT-10: Waiting to order', 'DRAFT-10: Waiting to order'));
            options.add(new SelectOption('OPEN-10: Ordered, waiting for confirmation', 'OPEN-10: Ordered, waiting for confirmation'));
            options.add(new SelectOption('OPEN-20: Order confirmed, waiting for tech assignment', 'OPEN-20: Order confirmed, waiting for tech assignment'));
            options.add(new SelectOption('OPEN-30: Tech assigned, waiting for release from site', 'OPEN-30: Tech assigned, waiting for release from site'));
            options.add(new SelectOption('CLOSED-10: Released from site', 'CLOSED-10: Released from site'));
            options.add(new SelectOption('CANCELED-10: Canceled', 'CANCELED-10: Canceled'));
            options.add(new SelectOption('Dispatch Completed', 'Dispatch Completed'));
            options.add(new SelectOption('Dispatch Record Created', 'Dispatch Record Created'));
            options.add(new SelectOption('N/A-10: No onsite for this RMA Type', 'N/A-10: No onsite for this RMA Type'));
            options.add(new SelectOption('Pre-Game Comp', 'Pre-Game Comp'));
            options.add(new SelectOption('Pre-Game Completed', 'Pre-Game Completed'));
            options.add(new SelectOption('Pre-Game Started', 'Pre-Game Started'));
        }
        return options;
    }
    //	End of SFDC-2280
	
    //	Added by Exafort for SFDC-2420
    public List<SelectOption> getOverrideSchedulingOptions() {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        system.debug('AssetSLA : ' + AssetSLA);
        system.debug('RMA Created Date : ' + rma.CreatedDate);        
        
        Date cutoffDate = Date.newInstance(2026, 3, 5);
        //	If the RMA created date is within March 3 display the existing picklist value
        if (rma.CreatedDate != null && rma.CreatedDate.date() <= cutoffDate) {
            
            options.add(new SelectOption(
                'WITHIN-4-HOURS-10: Schedule within the next 4 hours',
                'WITHIN-4-HOURS-10: Schedule within the next 4 hours'));
            
            options.add(new SelectOption(
                'SCHEDULED-10: Schedule according to the Scheduling Notes',
                'SCHEDULED-10: Schedule according to the Scheduling Notes'));
            
            options.add(new SelectOption(
                'NEXT-BUSINESS-DAY-10: Schedule within the Next Business Day',
                'NEXT-BUSINESS-DAY-10: Schedule within the Next Business Day'));
            
            return options;
        }
        String overrideCode = rma.rmaOverrideOnsiteSchedulingCode__c;
        Boolean isExistingScheduled = overrideCode != null && overrideCode.startsWith('SCHEDULED-10');
        Boolean isExisting4Hour = overrideCode != null && overrideCode.startsWith('WITHIN-4-HOURS-10');
        Boolean isExistingNBD = overrideCode != null && overrideCode.startsWith('NEXT-BUSINESS-DAY-10');
        Boolean isNBD = (AssetSLA != null && AssetSLA == 'Premium Onsite') || (rma.rmaAssetSla__c != null && rma.rmaAssetSla__c.contains('NBD'));
        Boolean isNonNBD = (AssetSLA != null && AssetSLA != 'Premium Onsite') || (rma.rmaAssetSla__c != null && !rma.rmaAssetSla__c.contains('NBD'));
        
        // NON-NBD options
        if (isNonNBD || isExisting4Hour ) {
            
            options.add(new SelectOption(
                'WITHIN-4-HOURS-10: Schedule within the next 4 hours',
                'WITHIN-4-HOURS-10: Schedule within the next 4 hours'));
            
            options.add(new SelectOption(
                'SCHEDULED-10: Schedule according to the Scheduling Notes',
                'SCHEDULED-10: Schedule according to the Scheduling Notes'));
        }
        
        
        // NBD options
        if (isNBD || isExistingNBD ) {
            
            options.add(new SelectOption(
                'SCHEDULED-10: Schedule at or after the NBD ETA',
                'SCHEDULED-10: Schedule at or after the NBD ETA'));
            
            options.add(new SelectOption(
                'NEXT-BUSINESS-DAY-10: Schedule as Next Business Day',
                'NEXT-BUSINESS-DAY-10: Schedule as Next Business Day'));
        }
        
        return options;
    }
    //	End of SFDC-2420
    
}