public with sharing class rmav2ExtensionsWithSharingDetailV2 {
    
    private ApexPages.StandardController controller {get; set;}
    private RMAV2__c rma {get;set;}
    public boolean hideOnSiteSections{get;set;}
    public boolean hideReturnSections{get;set;}
    public boolean gateKeeper{get;set;}
    
    public static Map<string, SR_Meta_Data__c> srMetaDataMap;
    
    // Added by Exafort for TS-10419
    public Boolean chinaGlobalAccount {get;set;}
    public Boolean assetSlaisNotOnsite {get;set;}
    
    // Added by Exafort for TS-10592
    public string NSBusinessAdminSupportProfileId{get;set;}
    
    // Added by Exafort for SFDC-471
    public List<SelectOption> cancellationPicklistOptions{get;set;}
    
    public rmav2ExtensionsWithSharingDetailV2(ApexPages.StandardController controller) {
        
        // Added by Exafort for TS-10419
        chinaGlobalAccount = false;
        assetSlaisNotOnsite = True;
        
        srMetaDataMap = new Map<string, SR_Meta_Data__c>();
        this.controller = controller;
        // load the current record
        rma = (RMAV2__c)controller.getRecord();
        
        // Added by Exafort for TS-10419
        // Field rmaDiskShelfAsset__r.Install_Country__c,rmaDiskShelfAsset__r.Dual_Support_Providers__c Added by Exafort for SFDC-626
        List<RMAv2__c> rmaRecord = new List<RMAv2__c>([Select id,name,rmaCaseNumber__r.Account.Global_Account__c,rmaShipmentCountry__c,
                                                       rmaCaseNumber__r.Account.Support_Provider__r.Name,rmaAssetSla__c,rmaOutgoingShipmentDepot__c,
                                                       rmaDiskShelfAsset__r.Install_Country__c,rmaDiskShelfAsset__r.Dual_Support_Providers__c,China_Global_Account_RMA__c
                                                       from RMAv2__c where Id=:rma.Id Limit 1]);
        // Check if its a China Global Account RMA
        // If Condition updated by Exafort for SFDC-627
        if(rmaRecord[0].China_Global_Account_RMA__c == True){
            chinaGlobalAccount = true;
        }
        if(rmaRecord[0].rmaAssetSla__c != null && rmaRecord[0].rmaAssetSla__c.contains('Onsite')){
            assetSlaisNotOnsite = false;
        }
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
        
        hidePageSections();
        gateKeeperSettings();
        
        // Added by Exafort for TS-10592
        setNSBusinessAdminSupportProfileId();
        
    }
    
    
    public void gateKeeperSettings()
    {
        settingsForRmaSystem__c rmaSetting = settingsForRmaSystem__c.getInstance();
        gateKeeper = rmaSetting.settingPreventSavingRmaAsOpen10__c;
    }
    //Added by vishnu for getting the SR Metadata details - on 1st Feb 2019 TS-5318 5258
    public static void getSrMetaDataMap()
    {    
        for(SR_Meta_Data__c srMetaData:[Select Id,srPartShipSLAOverride__c,srAutoOFA__c,srAutoEFA__c,srShipOnly__c,srPart__c,srType__c,srDescription__c,srShippingProvider__c from SR_Meta_Data__c])
        {
            srMetaDataMap.put(srMetaData.srPart__c, srMetaData);
            //srMetaDataMapById.put(srMetaData.Id, srMetaData);
        } 
    }
    
    public void hidePageSections()
    {
        //Commented by exafort(vishnu) on 21st Jan 2018 for hiding Onsite information for SLA Override to NBD(TS-5318 and TS-5258).
        /*if(rma.rmaAssetSLA__c.contains('Onsite')  || rma.rmaShowOnSiteSectionsAlways__c == true)
        hideOnSiteSections = false;
        else
        hideOnSiteSections = true;*/
        system.debug('rmaTriggerHandler.isOnsiteSLA(rma) : ' + rmaTriggerHandler.isOnsiteSLA(rma));
        //Added by vishnu for getting the SR Metadata details - on 1st Feb 2019 TS-5318 TS-5258
        getSrMetaDataMap();
        SR_Meta_Data__c srMetaData = srMetaDataMap.get(rma.rmaFailedPart__c);

        if(rma.rmaAssetSLA__c != null)
        {
            //Added by exafort(vishnu) on 21st Jan 2018 for hiding Onsite information for ssdwearlevelhigh(TS-5258) and SLA Override to NBD(tS-5318).
            // rmaTriggerHandler.isOnsiteSLA(rma) Added by Exafort for TS-10107
            if( rma.rmaUplift__c == 'Premium Onsite' || rmaTriggerHandler.isOnsiteSLA(rma)) { //TS-6667 rmaUplift__c  Added by Exafort on August 19 2020
                system.debug('### rma.rmaAssetSLA__c ===>'+rma.rmaAssetSLA__c);
                if(srMetaData != null && srMetaData.srPartShipSLAOverride__c == 'NBD & Onsite Override') {                 
                    system.debug('### ===>1');
                     hideOnSiteSections = true;                     
                }
                // rmaTriggerHandler.isOnsiteSLA(rma) Added by Exafort for TS-10107
                else if(rma.rmaShowOnSiteSectionsAlways__c == true ||  rma.rmaUplift__c == 'Premium Onsite' || rmaTriggerHandler.isOnsiteSLA(rma)
                        || rma.PachinkoCaseType__c == 'ssdwearlevelhigh'){ //TS-6667 rmaUplift__c added  Added by Exafort on August 19 2020
                        
                        system.debug('### ===>2');
                        hideOnSiteSections = false;    
                }
                else{ 
                      system.debug('### ===>3');
                      hideOnSiteSections = false;
                      
                } 
            }
            else{hideOnSiteSections = true;}      
        }      
        else
        {
            //hideOnSiteSections = false; 
        }
		//Added by vishnu for getting the SR Metadata details - on 1st Feb 2019 TS-5318 5258 -END
        
        if((rma.rmaAssetNrdIsInEffect__c == 'Yes' || rma.rmaPartIsAShipOnlyPart__c == 'Yes') && rma.rmaShowReturnSectionsAlways__c != true){
            hideReturnSections = true;
        }
        else{
            hideReturnSections = false;   
        }
        
    }
    
    public Boolean getRenderEFAPriority()
    {
        if(rma.rmaFaRequired__c == 'Engineering FA')
            return true;
        else
            return false;
    }
    
    
    public PageReference deleteRMA() {
        
        String keyPrefix='';
        
        try {
            if(rma.rmaOutgoingShipmentStatus__c != null && !rma.rmaOutgoingShipmentStatus__c.contains('DRAFT-10')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'RMA Cannot be Deleted - Only RMAs with status DRAFT-10 is allowed to delete'));
                return null;
            }
            else{
                Schema.DescribeSObjectResult r = RMAv2__c.sObjectType.getDescribe();
                keyPrefix = r.getKeyPrefix();
                
                RMAv2__c rmaDelete = [SELECT Id From RMAv2__c where Id =: rma.Id];
                delete rmaDelete;
                return new PageReference('/'+keyPrefix+'/o');
            }
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        
    }
    
    public Boolean getDraftShipmentStatus(){
        
        if(rma.rmaOutgoingShipmentStatus__c != null && ((rma.rmaOutgoingShipmentStatus__c.startsWith('DRAFT-10')) && (gateKeeper == true && rma.rmaGateKeeperStatus__c == 'Manual')))
            return true;
        else if(rma.rmaOutgoingShipmentStatus__c != null && rma.rmaOutgoingShipmentStatus__c.startsWith('DRAFT-10'))
            return false;
        else
            return true;
        
    }
    
    public string getSubmitRMALabel(){
        
        if(rma.rmaOutgoingShipmentStatus__c != null && ((rma.rmaOutgoingShipmentStatus__c.startsWith('DRAFT-10')) && (gateKeeper == true && (rma.rmaGateKeeperStatus__c == 'Manual' || rma.rmaGateKeeperStatus__c == null))))
            return 'Submit RMA in Downtime';
        else
            return 'Submit RMA';  
    }
    
    
    
    public Boolean getOpenShipmentStatus(){
        // rma.rmaOutgoingShipmentStatus__c.startsWith('SUBMITTED-CGA:') Added by Exafort for SFDC-471
        if(rma.rmaOutgoingShipmentStatus__c != null && (rma.rmaOutgoingShipmentStatus__c.startsWith('OPEN') || rma.rmaOutgoingShipmentStatus__c.startsWith('SUBMITTED-CGA:')))
            return false;
        else
            return true;
        
    }
    
    
    public PageReference submitRMA() {
        
        try {
            gateKeeperSettings();
            
            if(rma.rmaOutgoingShipmentStatus__c != null && rma.rmaOutgoingShipmentStatus__c.contains('DRAFT-10'))
            {
                settingsForRmaSystem__c rmaSetting = settingsForRmaSystem__c.getInstance();
                boolean gateKeeper= rmaSetting.settingPreventSavingRmaAsOpen10__c;
                
                if(gateKeeper == false)
                {
                    rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
                    rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
                    rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
                    rma.rmaGateKeeperStatus__c = 'Automatic';
                    /*Assigning Server values to Depot related fields which are updated from Future call*/
                    List<RMAv2__c> rmaQuery = [Select rmaOutgoingShipmentOrderDepot__c, rmaNearbyDepot__c,rmaOutgoingShipmentOrderProvider__c,rmaOutgoingShipmentOrder4HrDepotFound__c from RMAv2__c where Id =: rma.Id];
                    for(RMAv2__c rmaLoop : rmaQuery){
                        if(rmaLoop.rmaOutgoingShipmentOrderDepot__c != null){
                            rma.rmaOutgoingShipmentOrderDepot__c = rmaLoop.rmaOutgoingShipmentOrderDepot__c;
                        }
                        if(rmaLoop.rmaOutgoingShipmentOrderProvider__c != null){
                            rma.rmaOutgoingShipmentOrderProvider__c = rmaLoop.rmaOutgoingShipmentOrderProvider__c;
                        }
                        if(rmaLoop.rmaOutgoingShipmentOrder4HrDepotFound__c != null){
                            rma.rmaOutgoingShipmentOrder4HrDepotFound__c = rmaLoop.rmaOutgoingShipmentOrder4HrDepotFound__c;
                        }
                    }
                }
                else
                {
                    rma.rmaGateKeeperStatus__c= 'Manual';
                }
            }
            
            /*****START - Delivery Scheduling Mechanism Validations on SUBMIT *******/
            DateTime shipmentLocationValidated;
            Date shipmentLocationValidatedDate;
            Integer monthsDifference;
            DateTime deliveryDateTime;
            
            RMAv2__c rmaFromDb = [Select rmaDeliveryDate__c, rmaDeliveryTimes__c from RMAv2__c where Id =: rma.Id];
            system.debug('v### delivery date from db==>'+rmaFromDb.rmaDeliveryDate__c);
            system.debug('v### delivery times from db==>'+rmaFromDb.rmaDeliveryTimes__c);
            if(rmaFromDb.rmaDeliveryDate__c != null)
                rma.rmaDeliveryDate__c = rmaFromDb.rmaDeliveryDate__c;
            if(rmaFromDb.rmaDeliveryTimes__c != null)
                rma.rmaDeliveryTimes__c = rmaFromDb.rmaDeliveryTimes__c;
            
            //Added by vishnu on 14th march for RMA delivery Schedule Mechanism--START
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
            //-END
            //Commented by vishnu to debug the rma scheduling.-12th march 2019
            /*if((rma.rmaDeliveryDate__c != null) && (rma.rmaDeliveryTimes__c !=null || rma.rmaDeliveryTimes__c != '')){
                
                DateTime newDateTime = DateTime.newInstance(rma.rmaDeliveryDate__c.year(), rma.rmaDeliveryDate__c.month(),  rma.rmaDeliveryDate__c.day(), Integer.valueOf(rma.rmaDeliveryTimes__c.substring(0, 2)), Integer.valueOf(rma.rmaDeliveryTimes__c.substring(3, 5)) ,0);
                System.debug('v### value assigning to DateTime Field ===>'+newDateTime);
                //rma.rmaDeliveryDateTime__c = newDateTime;
                deliveryDateTime = rma.rmaDeliveryDateTime__c;
            }
            else {
                rma.rmaDeliveryDateTime__c = null;
            }*/
            //Commented by vishnu to debug the rma scheduling.-12th march 2019
            if((rma.rmaDeliveryDate__c != null) && (rma.rmaDeliveryTimes__c == null || rma.rmaDeliveryTimes__c == '' || rma.rmaDeliveryTimes__c == '--None--')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Delivery Date and Time must be in Date and Time format. Please enter Time'));
                return null;
            }
            
            DateTime assetLocalDate = Date.today();
            
            if(rma.rmaDeliveryDate__c != null && rma.rmaAssetLocalDateTime__c != null){
                 /* commented by Exafort on 10/7/2020 for  TS-6996
                //11/08/2017 02:00 PM
                string dateFormat = rma.rmaAssetLocalDateTime__c.substringBefore(' ');
                dateFormat = dateFormat.substringAfterLast('/');
                //DateTime newDateTime = DateTime.newInstance(2017, Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringBefore('/')),  Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween('/', '/')), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(' ', ':')), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(':', ' ')) ,0);
                DateTime newDateTime = DateTime.newInstance(Integer.valueOf(dateFormat), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringBefore('/')),  Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween('/', '/')), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(' ', ':')), Integer.valueOf(rma.rmaAssetLocalDateTime__c.substringbetween(':', ' ')) ,0);
                
                assetLocalDate = newDateTime; */
                
                 //Added by exafort on 10/7/2020 TS-6996 START 
                string dateFormat = rma.rmaAssetLocalDateTime__c.substringBefore(' ');
                system.debug('v### date Format ### ==>'+dateFormat);
                dateFormat = dateFormat.substringAfterLast('/');
                system.debug('v### formatted date Format ### ==>'+dateFormat);
                string timeFormat = rma.rmaAssetLocalDateTime__c.substringAfter(' ');
                system.debug('v### time Format ### ==>'+timeFormat);                 
                
                string AssetLocalTime24HourFormate;
                integer AssetLocalTime24HourFormateSim;
                //timeFormat = 12:30 AM ----- OR ----- 10:00 PM
                if(timeFormat != null && timeFormat.contains('PM')){
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
                assetLocalDate = newDateTime;
                
                ////Added by exafort on 10/7/2020 END 
                
            } 
            
            Date getAssetLocalDate;
            if(rma.rmaDeliveryDate__c != null && assetLocalDate != null){
                getAssetLocalDate = Date.newInstance(assetLocalDate.year(), assetLocalDate.month(), assetLocalDate.day());            
            }
            
            if(rma.rmaDeliveryDate__c != null && getAssetLocalDate != null){
                if(rma.rmaDeliveryDate__c < getAssetLocalDate){
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
            /******END*******************/            
            controller.save();
            //Added by Exafort for TS-10512
            // It will reset the controller record with the database value if controller.save() fails 
            controller.reset();
            //End of TS-10512
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        return null;
    }
    
    public PageReference cancelRMA() {
        try {
            //Added by Exafort for TS-10460
            rma = (RMAV2__c)controller.getRecord();
            
            rma.rmaAllowOrderCancel__c= true;
            rma.rmaOutgoingShipmentStatus__c = 'CANCELED-10: Canceled';
            /*Added on 17th Nov 2016 by Azarudeen - START - Improving RMA Cancellation Workflow*/
            rma.rmaReturnShipmentStatus__c = 'CANCELED-10: Canceled';
            rma.rmaRetShip2Status__c = 'CANCELED-10: Canceled';
            rma.rmaOnsiteTechStatus__c = 'CANCELED-10: Canceled';
            /*END - - Improving RMA Cancellation Workflow */
            
            //Added by Exafort for TS-10460
            rma.rmaFireOnsiteValidations__c = False;
            controller.save();
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        return null;
    }
    
    
    public PageReference cloneRMA() {
        
        Savepoint sp = Database.setSavepoint();
        RMAV2__c newRma;
        RMAV2__c oldRma;
        
        try {
            
            oldRma = [Select 
                      //General Information Section
                      rmaType__c,
                      rmaStatus__c,                         
                      //rmaFaRequired__c,
                      //rmaEFAPriority__c,
                      rmaCaseNumber__c,   
                      //rmaCustomerFARequired__c,
                      rmaCaseNimbleVersion__c,
                      rmaRCACompleted__c,
                      //rmaReturnTo__c,
                      rmaExcludeFromOpsMetrics__c,
                      //rmaWarrantyEntitlement__c, 
                      
                      //Part Selection Section (WHAT)                   
                      //rmaLabArray__c,
                      //rmaComponent__c,
                      //rmaNimbleOsVersion__c,
                      //rmaModel__c,
                      //rmaPart__c,
                      //rmaQuantity__c,
                      //rmaManufacturer__c,
                      //rmaDiskShelfAsset__c,
                      //rmaHddSsdSerialNumber__c,
                      //rmaConfigurationDetails__c,
                      
                      rmaDiskShelfAsset__c,
                      rmaComponent__c,
                      rmaComponentV2__c,
                      rmaSrFlatList__c,
                      rmaSelection__c,
                      rmaPart__c,
                      rmaPartNumber__c,
                      
                      
                      //RMA Reason Section (WHY)
                      //rmaReason__c,
                      //rmaGeneralFailureDetails__c,
                      //rmaDetailedReason__c,
                      
                      //Address Selection Section (WHERE)
                      rmaAddressBook__c,
                      rmaAddOverriddenAddressToAddressBook__c,
                      rmaOverrideShipmentAccountName__c,
                      rmaOverrideShipmentStreet1__c,
                      rmaOverrideShipmentStreet2__c,
                      rmaOverrideShipmentCity__c,
                      rmaOverrideShipmentState__c,
                      rmaOverrideShipmentPostalCode__c,
                      rmaOverrideShipmentCountry__c,
                      rmaOverrideShipmentAttn__c,
                      rmaOverrideShipmentPhone__c,
                      rmaOverrideShipmentEmail__c,
                      
                      //SLA/Uplift Selection Section (WHEN)
                      //rmaAssetSLA__c,
                      //rmaShipmentSLA__c,
                      rmaUplift__c, // Added by Exafort for TS-10349
                      rmaDeliveryDateTime__c, // Added by Exafort for TS-10349
                      rmaMissedSLA__c,
                      rmaUpliftApprovedBy__c,
                      rmaMissedSLAReason__c,
                      
                      //SHI Section
                      rmaTransmitRmaShisWithOrder__c,
                      rmaSHI__c,
                      
                      //Onsite Service Info Section
                      rmaOnsiteTechStatus__c, // Added by Exafort for TS-10349
                      rmaOnsiteTechDateTimeOrderConfirmed__c,
                      rmaOnsiteTechDateTimeArrivalEta__c,
                      rmaOnsiteTechOrderNumber__c,
                      rmaOnsiteTechDateTimeArrivalActual__c,
                      rmaOnsiteTechName__c,
                      rmaOnsiteTechDateTimeReleased__c,
                      
                      
                      //Onsite Service - Codes/Notes
                      rmaOverrideOnsiteSchedulingCode__c,
                      rmaOverrideOnsiteSchedulingNotes__c,
                      rmaOverrideOnsitePartHandoverCode__c,
                      rmaOverrideOnsitePartHandoverNotes__c,
                      rmaOverrideOnsiteCheckInCode__c,
                      rmaOverrideOnsiteCheckInNotes__c,
                      rmaOverrideOnsitePartDispositionCode__c,
                      rmaOverrideOnsitePartDispositionNotes__c,
                      
                      //Onsite Service - FE Arrival Address
                      rmaOverrideOnsiteArrivalStreet1__c,
                      rmaOverrideOnsiteArrivalStreet2__c,
                      rmaOverrideOnsiteArrivalCity__c,
                      rmaOverrideOnsiteArrivalState__c,
                      rmaOverrideOnsiteArrivalPostalCode__c,
                      rmaOverrideOnsiteArrivalCountry__c,
                      
                      //Onsite Service - Array Location
                      rmaOverrideAssetLocBuilding__c,
                      rmaOverrideAssetLocFloor__c,
                      rmaOverrideAssetLocDatacenter__c,
                      rmaOverrideAssetLocAreaOrGrid__c,
                      rmaOverrideAssetLocRow__c,
                      rmaOverrideAssetLocRack__c,
                      rmaOverrideAssetLocPositionInRack__c,
                      
                      //Onsite Service - Component Slots
                      rmaOnsiteControllerExpanderSlot__c,
                      rmaOnsiteHddSsdSlot__c, 
                      rmaOnsitePowerSupplySlot__c,
                      rmaOnsiteNicCardSlot__c,
                      
                      rmaOutgoingShipmentStatus__c,
                      rmaReturnShipmentStatus__c,
                      rmaShowOnSiteSectionsAlways__c ,
                      rmaShowReturnSectionsAlways__c,
                      
                      
                      //Expected Delayed RMA Returns
                      //rmaEFASource__c,
                      rmaExpectedActualNewPartInstallation__c,
                      rmareasonfordelayedinstallation__c,
                      rmaReasonforDelayedinstallationofPart__c
                      
                      
                      from RMAV2__c where Id = :rma.id];
            
            newRma = oldRma.clone(false);
            
            // Added by Exafort for TS-10349
            if(oldRma.rmaOnsiteTechStatus__c != null){
                newRma.rmaOnsiteTechStatus__c = 'DRAFT-10: Waiting to order';
            }
            // End of TS-10349
            
            newRma.rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order';
            newRma.rmaReturnShipmentStatus__c ='DRAFT-10: Waiting to order';
            newRma.rmaRetShip2Status__c='DRAFT-10: Waiting to order';
            newRma.rmaGateKeeperStatus__c = null;
            insert newRma;
        }
        catch (Exception e){
            // roll everything back in case of errors
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        
        return new PageReference('/apex/RMAv2NewPageV2?id='+newRma.id);
    }
    
    public string getShipmentLabelDetails()
    {
        string ShipmentLabel = rma.rmaShipmentAccountName__c + '\n';
        
        ShipmentLabel += 'Attn: ' + rma.rmaShipmentAttn__c + '\n';
        ShipmentLabel += rma.rmaShipmentStreet1__c + '\n';
        
        if(rma.rmaShipmentStreet2__c != null)
            ShipmentLabel += rma.rmaShipmentStreet2__c + '\n';
        
        ShipmentLabel += rma.rmaShipmentCity__c + ', ' +  rma.rmaShipmentState__c + ' ' + rma.rmaShipmentPostalCode__c + '\n';
        ShipmentLabel += rma.rmaShipmentCountry__c + '\n\n';
        ShipmentLabel += 'Contact Phone : ' + rma.rmaShipmentPhone__c + '\n';
        ShipmentLabel += 'Contact Email : ' + rma.rmaShipmentEmail__c;
        
        return ShipmentLabel;
    }
    
    // Method to fetch History
    public list < cHistories > getHistories() {
        list < cHistories > list_ch = new list < cHistories > ();
        // Loop through all field history records
        //Replace Merchandise__History with RMAv2__History
        for(RMAv2__History fh: [select ParentId, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedById, CreatedBy.Name
                                From RMAv2__History where ParentId = : rma.id order by CreatedDate desc
                               ]) {
                                   // Create a new wrapper object
                                   cHistories ch = new cHistories();
                                   ch.theDate = String.valueOf(fh.createddate);
                                   ch.who = fh.createdby.name;
                                   if(String.valueOf(fh.Field) == 'created') { // on Creation
                                       ch.action = 'Created.';
                                   } else if(fh.OldValue != null && fh.NewValue == null) { // when deleting a value from a field
                                       try {
                                           ch.action = 'Deleted ' + Date.valueOf(fh.OldValue)
                                               .format() + ' in <b>' + String.valueOf(fh.Field) + '</b>.';
                                       } catch(Exception e) {
                                           ch.action = 'Deleted ' + String.valueOf(fh.OldValue) + ' in <b>' + String.valueOf(fh.Field) + '</b>.';
                                       }
                                   } else {
                                       String fromText = '';
                                       if(fh.OldValue != null) {
                                           try {
                                               fromText = ' from ' + Date.valueOf(fh.OldValue)
                                                   .format();
                                           } catch(Exception e) {
                                               fromText = ' from ' + String.valueOf(fh.OldValue);
                                           }
                                       }
                                       String toText = '';
                                       try {
                                           toText = ' from ' + Date.valueOf(fh.NewValue)
                                               .format();
                                       } catch(Exception e) {
                                           toText = '' + String.valueOf(fh.NewValue);
                                       }
                                       ch.action = 'Changed <b>' + String.valueOf(fh.Field) + '</b>' + fromText + ' to <b>' + toText + '</b>.';
                                   }
                                   list_ch.add(ch);
                               }
        return list_ch;
    }
    
    
    public class cHistories {
        // Class properties
        public String theDate {
            get;
            set;
        }
        public String who {
            get;
            set;
        }
        public String action {
            get;
            set;
        }
    }

    // Added by Exafort for TS-10592
    /*
		Sets NSBusinessAdminSupportProfileId by querying profile object
	*/    
    Public void setNSBusinessAdminSupportProfileId() {
        NSBusinessAdminSupportProfileId = rmav2ExtensionsWithSharingNewV2.getSupportProfileIdForNSBusinessAdmin();
    }
    //	End of TS-10592
    
    // Added by Exafort for SFDC-600
    public String getDepotLabel() {
        if (rma.rmaOutgoingShipmentDepot__c != null) {
            List<Depot__c> depots = [SELECT Name, depotLocationDescription__c,Depot_Location_Info__c FROM Depot__c WHERE Depot_Location_Info__c = :rma.rmaOutgoingShipmentDepot__c LIMIT 1];
            if (!depots.isEmpty()) {
                Depot__c depot = depots[0];
                return depot.Name + ' - ' + depot.depotLocationDescription__c;
            }
            return '';
        }
        return '';
    }
    // End of SFDC-600
    
}