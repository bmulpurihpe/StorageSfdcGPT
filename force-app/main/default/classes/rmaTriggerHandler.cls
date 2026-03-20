/* Run the following test classes to get the minimum code coverage for this "rmaTriggerHanlder".
* rmaTriggerTestV2
* rmaTriggerSetFaTest
* rmaTriggerUtilitiesTest
* rmaTriggerComponentTestv1
* rmaSubstitutionTriggerTest  
* rmaTriggerSLADateTimeTestv1
* rmaTriggerGoodPostalCodeTests
* rmaTriggerUpliftnLogisticsTest
* rmaTriggerSrPartMinReqOsVersion
* rmaAfterUpdateAddNotesInCaseTestv1
* rmaTriggerAssignHddAndSsdPartNumbers
* rmatriggerhandlerTest1
* rmatriggerhandlerTest2
* rmatriggerhandlerTest3
* */
public class rmaTriggerHandler extends TriggerHandler {
    
    //Following Map and Set are used to store all the data needed, before processing the bulk RMA data
    private static Map<String, String> mapPartNumbers;
    private static Map<String, depotMapNbdNd__c> depotMapNbdNd;
    private static Map<String, depotMap4Hour__c> depotMap4Hour;
    private static Map<Id, Asset> assetMap;
    private static Map<Id, Case> caseMap;
    private static Map<Id, Account> accountMap;
    private static Set<Id> rmaAssetToUseIds;
    private static Set<Id> rmaComponentToUseIds; //added by Exafort
    private static Set<Id> rmaAccountToUseIds;
    private static Map<String, List<PostalCode__c>> postalCodeMap;
    private static Map<Id, Component__c> componentMap;
    private static Map<Id,List<Component__c>> componentMapByAssetId;
    private static Map<string, SR_Meta_Data__c> srMetaDataMap;
    private static Map<string, SR_Meta_Data__c> srMetaDataMapById;
    private static Map<string, EOAPart__c> EOAMap;
    private static Map<Id,RMAv2__c> rmaMap;
    private static Map<String,AddressBook__c> mapExistingAbRecords; 
    private static Map<String,Asset> assetsChassisCloneMap = new Map<String,Asset>();
    private static Map<string,Component__c> upsertComponentMap = new Map<string,Component__c>();
    private static Map<String,List<RMASubstitution__c>> rmaSubtitutionMap;
    private static List<Asset> processingAsset = new List<Asset>();
    private static string srMetaDataShippingProvider;
    public static string rmaDayofweek;//isRunningTest
    private static Profile tsrProfileId; // Added by exafort for TS-9109
    private static List<EmailTemplate> rmaEmailTemplate; // Added by exafort for TS-9109
    private static Map<id,String> caseIdWithSupportProfile = new Map<id,String>(); //Added By Exafort for SFDC-309
    private static Map<id,String> caseIdWithAssetSLA = new Map<id,String>(); //Added By Exafort for SFDC-556
    
    //Constructor(called only when class is initialized)
    public rmaTriggerHandler() {
        
        mapPartNumbers = new Map<string,string>();
        depotMapNbdNd = new Map<String, depotMapNbdNd__c>();
        depotMap4Hour = new Map<String, depotMap4Hour__c>();
        assetMap = new Map<Id, Asset>();
        caseMap = new Map<Id, Case>();
        accountMap = new Map<Id, Account>();
        rmaAssetToUseIds = new Set<Id>();
        rmaAccountToUseIds = new Set<Id>();
        postalCodeMap = new Map<String, List<PostalCode__c>>();
        componentMap = new Map<Id, Component__c>();
        componentMapByAssetId = new Map<Id,List<Component__c>>();
        srMetaDataMap = new Map<string, SR_Meta_Data__c>();
        srMetaDataMapById = new Map<string, SR_Meta_Data__c>();
        EOAMap= new Map<string, EOAPart__c>();
        rmaMap = new Map<Id,RMAv2__c>();
        mapExistingAbRecords = new Map<String,AddressBook__c>();
        rmaSubtitutionMap = new  Map<String,List<RMASubstitution__c>>(); 
        srMetaDataShippingProvider='';
        
    }
    
    public static void bulkQueries()
    {
        //This Map consist of the PartNumber of HDD and SSD Assignments 
        getHddSsdPartNumberAssignment();
        
        //This Map consists of the Postal Code data
        getPostalCodeMap();
        
        //This Set Used to the collect all the Countries in the incoming records
        Set<String> sSoqlCountries = new Set<String>();
        
        //This Set Used to the collect all the States in the incoming records
        Set<String> sSoqlStates = new Set<String>(); 
        
        //This Set Used to the collect all the TempKeyPatterns in the incoming records(used in 4 hour logic)
        Set<String> sTemp4HourKeyPatterns = new Set<String>();
        
        //This Set Used to the collect all the rmaCaseNumber in the incoming records(used in Onsite Compiled Notes etc.,)
        Set<Id> rmaCaseIds = new Set<Id>();
        
        Set<Id> rmaComponentIds = new Set<Id>();
        
        Set<string> rmaAssetSerialNumber = new Set<string>();
        
        //Added By Exafort for SFDC-309
        Set<Id> allRmaCaseIds = new Set<Id>();
        
        //Added By Exafort For SFDC-309
        Set<string> rmaSupportProfileSet = new set<string>();
        
        
        //Ensure the Trigger is Before 
        if(Trigger.isBefore) 
        {
            //Looping through the incoming RMA Records 
            //Storing the required SET Values respectively(These SET used in bulk soql Query Processing)
            
            for(RMAv2__c rmas:(List<RMAv2__c>) Trigger.new)
            {
                //Check the current RMA record Postal code is Valid. If valid collect the Value in respective SET else Skip
                //rmaVerifyCountryAndPostalCode method needed to called here bzoc postal code format is required for quering 4HourDepot
                //Example if postal code is "22222-2222", the rmaVerifyCountryAndPostalCode method return "22222"(used for getting 4HourDepot Record)
                
                //Added by Exafort for SFDC-309
                allRmaCaseIds.add(rmas.rmaCaseNumber__c); 
                
                // Added by Exafort for SFDC-2094
                if(rmas.rmaPartNumber__c != null && rmas.rmaOutgoingShipmentStatus__c == 'DRAFT-10: Waiting to order'){
                   rmas.rmaFulfilledPartNumber__c = rmas.rmaPartNumber__c;
                }
                // End of SFDC-2094
                
                String soqlPostalCode = rmaVerifyCountryAndPostalCode(rmas); 
                if(soqlPostalCode != '')
                {
                    string soqlCountry = rmas.rmaShipmentCountry__c;
                    soqlCountry = soqlCountry.replaceAll(' \\([A-Z]{2}\\)$', '');
                    sSoqlCountries.add(soqlCountry);
                    sSoqlStates.add(rmas.rmaShipmentState__c);                  
                    sTemp4HourKeyPatterns.add('\\_\\_' + soqlCountry + '\\_\\_' + soqlPostalCode + '\\_\\_%');//Set Forms SOQL like statement with bulk records
                    rmaAssetToUseIds.add(rmas.rmaDiskShelfAsset__c);
                    rmaCaseIds.add(rmas.rmaCaseNumber__c);
                    rmaComponentIds.add(rmas.rmaComponentV2__c);
                    
                    if(rmas.rmaAssetId__c != null)
                    {
                        rmaAssetSerialNumber.add(rmas.rmaAssetId__c);
                    }
                    
                    //On the following condition  Asset needs to clone if the part is Chassis and store the result in assetsChassisCloneMap(utilized from assetsChassisCloneMap later).
                    if(rmas.rmaOutgoingShipmentStatus__c != null)
                    {
                        if(rmas.rmaOutgoingShipmentPartSn__c !=null && rmas.rmaPartNumber__c != null && rmas.rmaOutgoingShipmentAfterShipStatus__c != null && rmas.rmaIsComponentCreated__c == false && 
                           (rmas.rmaSelection__c == 'Component' || rmas.rmaSelection__c == 'Flat List')  && rmas.rmaPartNumber__c.startsWith('SR-') &&
                           rmas.rmaPartNumber__c.toUpperCase().contains('CHASSIS') && rmas.rmaOutgoingShipmentAfterShipStatus__c == 'picked up')
                        {
                            Asset clonedAsset = rmaCloneAssetForChassis(rmas.rmaAssetId__c,rmas.rmaOutgoingShipmentPartSn__c, rmas);
                            assetsChassisCloneMap.put(rmas.Name,clonedAsset);
                            
                        }
                    }
                }
                else
                {
                    return;
                }
                
            }
            
        }
        
        //Using Collected SET values - quering the following object used in RMA process and store the result data in the respective map's
        //The collected Map value are used in processing bulk records one by one
        getDepotMapNbdNd(sSoqlCountries,sSoqlStates); 
        
        getDepotMap4Hour(sTemp4HourKeyPatterns);   
        getCaseMap(rmaCaseIds);
        getAssetMap(); 
        getAccountMap();
        getComponentMap(rmaComponentIds);
        getSrMetaDataMap();
        getEOAMap();
        getComponentMapByAssetId(rmaAssetSerialNumber);
        
        //Added By Exafort For SFDC-309
        for(Case allCases:[Select id,Support_Profile__c,Asset.SLA__c from Case where id=:allRmaCaseIds]){
            if(allCases.Support_Profile__c != null){
                rmaSupportProfileSet.add(allCases.Support_Profile__c); 
            }
            string supportProfile = allCases.Support_Profile__c == null ? 'Legacy Nimble' : allCases.Support_Profile__c;
            caseIdWithSupportProfile.put(allCases.id,supportProfile);
            //Added By exafort for SFDC-556
            caseIdWithAssetSLA.put(allCases.id,allCases.Asset.SLA__c);
        }
        
        if(rmaSupportProfileSet.size() == 0){
            rmaSupportProfileSet.add('Legacy Nimble');  
        }
        getRmaSubtitutionMap(rmaSupportProfileSet);
        //End Of SFDC-309
        
        scheduleSSDWear();
        
        //Cloned Asset are insert (Id's is genereted in assetsChassisCloneMap after insert)
        
        upsert assetsChassisCloneMap.values();
        
        if(processingAsset.size() > 0){
            update processingAsset;
        }

    }
    
    public override void beforeInsert() {
         set<id> caseIds = new set<id>();
        //Process all the Assignments and SOQL Queries prior execution of bulk RMA data 
        //and store it in the respective map's and set's
        bulkQueries();
        for (SObject so : Trigger.new)
        {              
            RMAv2__c rmaToProcess = (RMAv2__c)so;
            rmaMain(rmaToProcess);
             caseIds.add(rmaToProcess.rmaCaseNumber__c);
        }
        //Added by exafort(vishnu) to default service parts to NBD Delivery SLA TS-5318 on 18th Jan 2019
        rmaOverrideSLA();
        checkSrPartMinOsVersion();//Added by vishnu for TS-6426 on 16th Apr 2020.
        
        //Added by exafort TS-10174 start
        //Update the RMA's order Type field to "Ship Only" when RMA.rmaCaseNumber__c.Asset.CDMR is True.
        Map<id,String> caseWithOrderType = new Map<id,String>(); 
        caseWithOrderType = getCaseIdWithOrderType(caseIds);
        if(caseWithOrderType != Null){
            for (SObject so : Trigger.new)
            {              
                RMAv2__c rmaToProcess = (RMAv2__c)so;
                if(caseWithOrderType.containsKey(rmaToProcess.rmaCaseNumber__c)){
                    rmaToProcess.rmaOrderType__c=caseWithOrderType.get(rmaToProcess.rmaCaseNumber__c);  
                }
            }
        }
        // End of TS-10174
        
    }
    
    public override void beforeUpdate() {
        
        
        //Process all the Assignments and SOQL Queries prior execution of bulk RMA data 
        //and store it in the respective map's and set's
        bulkQueries();
        rmaOutgShipOrderDepotUpdate();
        set<id> caseIds = new set<id>();
        for (SObject so : Trigger.new)
        {              
            RMAv2__c rmaToProcess = (RMAv2__c)so;
            caseIds.add(rmaToProcess.rmaCaseNumber__c);
            rmaMain(rmaToProcess);
            //Added by Exafort(Guru Dev) for TS-9175
            RMAv2__c oldRMAv2 = (RMAv2__c)Trigger.OldMap.get(rmaToProcess.Id);//To get the old values to exceute only on RMA submission
            if(rmaToProcess != null && rmaToProcess.rmaDateTimeOpened__c != oldRMAv2.rmaDateTimeOpened__c && !rmaToProcess.returnPartUnderWarranty__c &&
               rmaToProcess.rmaStatus__c == 'Open'&& rmaToProcess.rmaComponentV2__c != null){
                   Component__c compRec = componentMap.get(rmaToProcess.rmaComponentV2__c);//getting the component records based on rma.component
                   if(compRec != null && compRec.warrantyEndDate__c > rmaToProcess.rmaDateTimeOpened__c){
                       rmaToProcess.returnPartUnderWarranty__c = True;//updating return part under warranty
                   }
               }//Added end
            
            // Added by exafort for TS-10419
            system.debug('Date/Time Opened : ' + rmaToProcess.rmaDateTimeOpened__c);
            system.debug('Asset SLA : ' + rmaToProcess.rmaAssetSla__c);
            DateTime deliveryDateTime;
            DateTime rmaOpenedDateTime;
            if(rmaToProcess.rmaAssetSla__c != null && rmaToProcess.rmaDateTimeOpened__c != null){
                rmaOpenedDateTime = rmaToProcess.rmaDateTimeOpened__c.addHours(8); // Adding +8 hours to covert the DateTime to China Time Zone
                // rmaToProcess.rmaDeliveryDateTime__c != null Added by Exafort
                if(rmaToProcess.rmaUplift__c == 'Scheduled' && rmaToProcess.rmaDeliveryDateTime__c != null){
                    deliveryDateTime = rmaToProcess.rmaDeliveryDateTime__c.addHours(8);
                }
                else if(rmaToProcess.rmaAssetSla__c.contains('NBD') && rmaToProcess.rmaUplift__c != 'Yes: Uplift to 4-Hour'){
                    String dayOfWeek = rmaOpenedDateTime.format('EEEE','GMT');
                    if(dayOfWeek == 'Friday'){
                        DateTime updatedDateTime = rmaOpenedDateTime.addDays(3);
                        deliveryDateTime = updatedDateTime;
                    }
                    else if(dayOfWeek == 'Saturday'){
                        DateTime updatedDateTime = rmaOpenedDateTime.addDays(2);
                        deliveryDateTime = updatedDateTime;
                    }
                    else{
                        DateTime updatedDateTime = rmaOpenedDateTime.addDays(1);
                        deliveryDateTime = updatedDateTime;
                    }
                }
                else if(rmaToProcess.rmaAssetSla__c.contains('4-Hour') || rmaToProcess.rmaUplift__c == 'Yes: Uplift to 4-Hour'){
                    deliveryDateTime = rmaOpenedDateTime.addHours(4);
                }
                else{
                    deliveryDateTime = null;
                }
            }
            
            if(deliveryDateTime != null){
                String formattedDeliveryDateTime;
                String month = deliveryDateTime.format('MM', 'GMT');
                String day = deliveryDateTime.format('dd', 'GMT'); // 27
                String deliveryTime = deliveryDateTime.format('HH:mm:ss', 'GMT'); // 09:29:11
                String year = deliveryDateTime.format('yyyy', 'GMT'); // 2024
                system.debug('day : ' + deliveryDateTime.format('dd', 'GMT'));
                system.debug('day : ' + deliveryDateTime.format('dd'));
                if(rmaToProcess.rmaAssetSla__c.contains('4-Hour') || rmaToProcess.rmaUplift__c == 'Scheduled' || (rmaToProcess.rmaUplift__c == 'Yes: Uplift to 4-Hour' && rmaToProcess.rmaAssetSla__c.contains('NBD'))){
                    formattedDeliveryDateTime = year + '-' + month + '-' + day + ', ' + deliveryTime + ' China Std Time ';
                }
                else if(rmaToProcess.rmaAssetSla__c.contains('NBD')){
                    formattedDeliveryDateTime = year + '-' + month + '-' + day + ', ' + '08:00 to 18:00' + ' China Std Time ';
                }
                else{
                    formattedDeliveryDateTime = null;
                }
                System.debug('formattedDeliveryDateTime : ' + formattedDeliveryDateTime);
                rmaToProcess.rmaEstimated_Delivery_Date_Time__c = formattedDeliveryDateTime;
            }
            // End of TS-10419
            
        }
        //Added by exafort(vishnu) to default service parts to NBD Delivery SLA TS-5318 on 18th Jan 2019
        rmaOverrideSLA();
        checkSrPartMinOsVersion(); //Added by vishnu for TS-6426 on 16th Apr 2020.  
        
        //Added by exafort TS-10174 start 
        //Update the RMA's order Type field to "Ship Only" when RMA.rmaCaseNumber__c.Asset.CDMR is True.
        Map<id,String> caseWithOrderType = new Map<id,String>(); 
        caseWithOrderType = getCaseIdWithOrderType(caseIds);
        if(caseWithOrderType != Null){
            for (SObject so : Trigger.new)
            {              
                RMAv2__c rmaToProcess = (RMAv2__c)so;
                if(caseWithOrderType.containsKey(rmaToProcess.rmaCaseNumber__c)){
                    rmaToProcess.rmaOrderType__c=caseWithOrderType.get(rmaToProcess.rmaCaseNumber__c);  
                }
            }
        }
        // End of TS-10174
    }
    
    //Added by exafort TS-10174 start
    public static Map<id,string> getCaseIdWithOrderType(set<id> caseIds){
        Map<id,String> caseWithOrderType = new Map<id,String>(); 
         for(Case cas: [select id,AssetId,Asset.CDMRisActive__c,Asset.CDMR_Start_Date__c,Asset.CDMR_End_Date__c from Case where id=: caseIds]){
            if(cas.AssetId != null && cas.Asset.CDMRisActive__c == True){                
                string orderType = 'Ship Only';
                if(orderType != null){
                    caseWithOrderType.put(cas.Id,orderType);
                }
            }
        }
        return caseWithOrderType;
    }
   // end of Ts-10174
   
    public override void afterUpdate() {
        //Insert entries to the address book if does not exit, after Updating RMA records(bulk)
        if(rmaStatusInformationsPreventRecursive.runOnce() && CountRMAStatusInforPreventRecursive.runOnce()){
            rmaAfterUpdateMain();
            rmaAfterUpdateAddNotesInCase();
        }
    }
    
    public override void beforeDelete(){
        dontAllowOpenRMAToDelete();
    }
    
    //Bulk - HDD and SSD Part Assignment
    public static void getHddSsdPartNumberAssignment()
    {
        
        mapPartNumbers = new Map<String, String>
        {'HDD_210_Before'    => '1TB SATA HDD [SR-HDD-1TB]',
            'HDD_210_After'     => '1TB SAS HDD [SR-HDD-1TB-SAS]',
            'HDD_H25_Before'    => '1TB SAS HDD [SR-HDD-H25]',
            'HDD_H25_After'     => '1TB SAS HDD [SR-HDD-1TB-SAS]',
            'HDD_240_Before'    => '2TB SATA HDD [SR-HDD-2TB]',
            'HDD_240_After'     => '2TB SAS HDD [SR-HDD-2TB-SAS]',
            'HDD_H45_Before'    => '2TB SAS HDD [SR-HDD-H45]',
            'HDD_H45_After'     => '2TB SAS HDD [SR-HDD-2TB-SAS]',
            'HDD_260_Before'    => '3TB SAS HDD [SR-HDD-3TB]',
            'HDD_260_After'     => '3TB SAS HDD [SR-HDD-3TB-SAS]',
            'HDD_H65_Before'    => '3TB SAS HDD [SR-HDD-3TB]',
            'HDD_H65_After'     => '3TB SAS HDD [SR-HDD-3TB-SAS]',
            'HDD_H85_Before'    => '4TB SAS HDD [SR-HDD-4TB-SAS]',
            'HDD_H85_After'     => '4TB SAS HDD [SR-HDD-4TB-SAS]',
            'HDD_H90T_Before'   => '6TB SAS HDD [SR-HDD-6TB-SAS]',
            'HDD_H90T_After'    => '6TB SAS HDD [SR-HDD-6TB-SAS]',
            'HDD_12T_Before'    => '1TB SAS HDD [SR-HDD-1TB-SAS]',
            'HDD_12T_After'     => '1TB SAS HDD [SR-HDD-1TB-SAS]',
            'HDD_24T_Before'    => '2TB SAS HDD [SR-HDD-2TB-SAS]',
            'HDD_24T_After'     => '2TB SAS HDD [SR-HDD-2TB-SAS]',
            'HDD_36T_Before'    => '3TB SAS HDD [SR-HDD-3TB-SAS]',
            'HDD_36T_After'     => '3TB SAS HDD [SR-HDD-3TB-SAS]',
            'HDD_48T_Before'    => '4TB SAS HDD [SR-HDD-4TB-SAS]',
            'HDD_48T_After'     => '4TB SAS HDD [SR-HDD-4TB-SAS]',
            'HDD_72T_Before'    => '6TB SAS HDD [SR-HDD-6TB-SAS]',
            'HDD_72T_After'     => '6TB SAS HDD [SR-HDD-6TB-SAS]',
            'SSD_210-X2_Before' => '80GB SATA SSD [SR-SSD-80GB]',
            'SSD_210-X2_After'  => '80GB SATA SSD [SR-SSD-3500-80GB]',
            'SSD_210-X4_Before' => '160GB SATA SSD [SR-SSD-160GB]',
            'SSD_210-X4_After'  => '160GB SATA SSD [SR-SSD-3500-160GB]',
            'SSD_H25_Before'    => '160GB SATA SSD [SR-SSD-160GB]',
            'SSD_H25_After'     => '160GB SATA SSD [SR-SSD-3500-160GB]',
            'SSD_220-X4_Before' => '300GB SATA SSD [SR-SSD-300GB]',
            'SSD_220-X4_After'  => '300GB SATA SSD [SR-SSD-3500-300GB]',
            'SSD_H45_Before'    => '300GB SATA SSD [SR-SSD-300GB]',
            'SSD_H45_After'     => '300GB SATA SSD [SR-SSD-3500-300GB]',
            'SSD_220-X8_Before' => '600GB SATA SSD [SR-SSD-600GB]',
            'SSD_220-X8_After'  => '600GB SATA SSD [SR-SSD-3500-600GB]',
            'SSD_H65_Before'    => '600GB SATA SSD [SR-SSD-600GB]',
            'SSD_H65_After'     => '600GB SATA SSD [SR-SSD-3500-600GB]',
            'SSD_H85_Before'    => '1600GB SATA SSD [SR-SSD-1600GB]',
            'SSD_H85_After'     => '1600GB SATA SSD [SR-SSD-1600GB]',
            'SSD_H90T_Before'   => '1920GB SATA SSD [SR-SSD-1920GB]',
            'SSD_H90T_After'    => '1920GB SATA SSD [SR-SSD-1920GB]',
            'SSD_320F_Before'   => '80GB SATA SSD [SR-SSD-3500-80GB]',
            'SSD_320F_After'    => '80GB SATA SSD [SR-SSD-3500-80GB]',
            'SSD_640F_Before'   => '160GB SATA SSD [SR-SSD-3500-160GB]',
            'SSD_640F_After'    => '160GB SATA SSD [SR-SSD-3500-160GB]',
            'SSD_1200F_Before'  => '300GB SATA SSD [SR-SSD-3500-300GB]',
            'SSD_1200F_After'   => '300GB SATA SSD [SR-SSD-3500-300GB]',
            'SSD_2400F_Before'  => '600GB SATA SSD [SR-SSD-3500-600GB]',
            'SSD_2400F_After'   => '600GB SATA SSD [SR-SSD-3500-600GB]',
            'SSD_3200F_Before'  => '800GB SATA SSD [SR-SSD-3500-800GB]',
            'SSD_3200F_After'   => '800GB SATA SSD [SR-SSD-3500-800GB]',
            'SSD_6400F_Before'  => '1600GB SATA SSD [SR-SSD-1600GB]',
            'SSD_6400F_After'   => '1600GB SATA SSD [SR-SSD-1600GB]',
            'SSD_3200FS_Before' => '800GB SAS SSD [SR-SSD-800GB-SAS]',
            'SSD_3200FS_After'  => '800GB SAS SSD [SR-SSD-800GB-SAS]',
            'SSD_6400FS_Before' => '1600GB SAS SSD [SR-SSD-1600GB-SAS]',
            'SSD_6400FS_After'  => '1600GB SAS SSD [SR-SSD-1600GB-SAS]',
            'SSD_300GB_Before'  => '300GB SATA SSD [SR-SSD-3500-300GB]',
            'SSD_300GB_After'   => '300GB SATA SSD [SR-SSD-3500-300GB]',
            'SSD_600GB_Before'  => '600GB SATA SSD [SR-SSD-3500-600GB]',
            'SSD_600GB_After'   => '600GB SATA SSD [SR-SSD-3500-600GB]',
            'SSD_800GB_Before'  => '800GB SATA SSD [SR-SSD-3500-800GB]',
            'SSD_800GB_After'   => '800GB SATA SSD [SR-SSD-3500-800GB]',
            'SSD_1600GB_Before' => '1600GB SATA SSD [SR-SSD-1600GB]',
            'SSD_1600GB_After'  => '1600GB SATA SSD [SR-SSD-1600GB]'};
                
                }
    
    //Bulk - Quering NBDND object with the collected set values
    public static void getDepotMapNbdNd(Set<String> sSoqlCountries,Set<String> sSoqlStates)
    {
        //'N/A' is a default value
        sSoqlStates.add('N/A');
        
        for(depotMapNbdNd__c dptMapNbdNd:[SELECT depotMapNbdNd_NbdDepot__r.Name,
                                          depotMapNbdNd_NbdDepot__r.depotProvider__c,
                                          depotMapNbdNd_NdDepot__r.Name,
                                          depotMapNbdNd_NdDepot__r.depotProvider__c,depotMapNbdNdCountry__c,depotMapNbdNdState__c,Provider__c 
                                          FROM   depotMapNbdNd__c
                                          WHERE  depotMapNbdNdCountry__c In :sSoqlCountries and
                                          depotMapNbdNdState__c  In  :sSoqlStates])
        {
            //Added By exafort for SFDC-556            
            //	String mapKey = '__' + dptMapNbdNd.depotMapNbdNdCountry__c + '__' + dptMapNbdNd.depotMapNbdNdState__c + '__';
			String mapKey = getNbdDepotMapKey (dptMapNbdNd.depotMapNbdNdCountry__c , dptMapNbdNd.depotMapNbdNdState__c, dptMapNbdNd.Provider__c);
            //End of SFDC-556

			if (!depotMapNbdNd.containsKey(mapKey))
            {
				depotMapNbdNd.put(mapKey, dptMapNbdNd);
            }            
            system.debug('depotMapNbdNd :' + depotMapNbdNd);
        }
        
    }
    
    //Bulk - Quering 4Hour object with the collected set values
    public static void getDepotMap4Hour(Set<String> sTemp4HourKeyPatterns)
    {
        for(depotMap4Hour__c dptMap4Hour: [SELECT   depotMap4Hour_4HourDepot__r.Name,
                                           depotMap4Hour_4HourDepot__r.depotProvider__c,
                                           depotMap4HourMiles__c,depotMap4HourKey__c,depotMap4HourCountry__c,depotMap4HourPostalCode__c
                                           FROM     depotMap4Hour__c
                                           WHERE    depotMap4HourKey__c LIKE :sTemp4HourKeyPatterns and
                                           depotMap4Hour_4HourDepot__r.depotStockedFor4Hour__c = 'Yes'
                                           ORDER BY depotMap4HourDriveTime__c ASC NULLS LAST])
        {
            
            String mapKey = '__' +dptMap4Hour.depotMap4HourCountry__c + '__' + dptMap4Hour.depotMap4HourPostalCode__c + '__';
            
            if (!depotMap4Hour.containsKey(mapKey))             
                depotMap4Hour.put(mapKey, dptMap4Hour);
            
        }
    }
    
    //Bulk - Quering Case object with the collected set values
    public static void getCaseMap(Set<Id> rmaCaseNumber)
    {   
        
        for(Case cse:[SELECT Id, AssetId,AccountId,Asset.Account.Id,Asset.Account.accountRmaShi__c,Asset.assetRmaShi__c,Asset.Account.Name, Asset.Account.Support_Provider__r.Name from Case where Id In :rmaCaseNumber])
        {
            
            caseMap.put(cse.Id, cse);
            rmaAssetToUseIds.add(cse.AssetId);
            rmaAccountToUseIds.add(cse.AccountId);
        }
        
    }
    
    //Bulk - Quering Asset object with the collected set values
    public static void getAssetMap()
    {
        for(Asset assets:[SELECT Id,
                          Name,
                          Account.Id,
                          Install_Street1__c,
                          Install_Street2__c,
                          Install_City__c,
                          Install_State_Province__c,
                          Install_Zip_Code__c,
                          Install_Country__c,
                          assetLocBuilding__c,
                          assetLocFloor__c,
                          assetLocDatacenter__c,
                          assetLocAreaOrGrid__c,
                          assetLocRow__c,
                          assetLocRack__c,
                          assetLocPositionInRack__c,
                          assetOnsiteArrivalStreet1__c,
                          assetOnsiteArrivalStreet2__c,
                          assetOnsiteArrivalCity__c,
                          assetOnsiteArrivalState__c,
                          assetOnsiteArrivalPostalCode__c,
                          assetOnsiteArrivalCountry__c,
                          assetOnsiteSchedulingCode__c,
                          assetOnsiteSchedulingNotes__c,
                          assetOnsitePartHandoverCode__c,
                          assetOnsitePartHandoverNotes__c,
                          assetOnsiteCheckInCode__c,
                          assetOnsiteCheckInNotes__c,
                          assetOnsitePartDispositionCode__c,
                          assetOnsitePartDispositionNotes__c,
                          assetRmaShi__c,
                          Account.accountRmaShi__c,
                          Account.Name,
                          Account.Support_Provider__r.Name,
                          assetPartShipAddressBook__c
                          from   Asset
                          where  Id In :rmaAssetToUseIds])
        {
            assetMap.put(assets.Id, assets);
        }
        
    }
    
    //Bulk - Quering Account object with the collected set values
    public static void getAccountMap()
    {
        for(Account acc:[SELECT Id, accountRmaShi__c from Account where Id In :rmaAccountToUseIds])
        {
            accountMap.put(acc.Id, acc);
        } 
    }
    
    //Bulk - Quering PostalCode object
    public static void getPostalCodeMap()
    {
        List<PostalCode__c> pc = [SELECT Id, pcErrorMessage__c,pcCountry__c,pcFormatInRegex__c,pcDummyPostalCode__c from PostalCode__c order by pcCountry__c];
        for(Integer i=0; i< pc.size(); i++)
        {
            List<PostalCode__c> lstCurrentPc = new List<PostalCode__c>();
            lstCurrentPc.add(pc[i]);
            
            //United kingdom has 2 format, so storing the country "United Kingdom" as key and the values for the key would be 2 values for United kingdom Record.
            //Example: Key - United Kingdom
            //Value - List of 2 United Kingdom Records
            //
            //For Rest of the country:
            //Example: Key - United States
            //Value - List of 1 United State Record
            if(postalCodeMap.containsKey(pc[i].pcCountry__c))
            {
                List<PostalCode__c> lstExistingPc = postalCodeMap.get(pc[i].pcCountry__c);
                lstExistingPc.add(pc[i]);
                postalCodeMap.put(pc[i].pcCountry__c,lstExistingPc);
            }
            else
            {
                postalCodeMap.put(pc[i].pcCountry__c,lstCurrentPc);               
            }
        }
    }
    
    //Bulk - Quering Component object with the collected set values
    public static void getComponentMap(Set<Id> rmaComponentIds)
    {
        //Added warrantyEndDate__c field in the below query for TS-9175
        for(Component__c com:[SELECT Id,componentState__c,Sub_State__c,componentAccountId__c,componentAsset__c,componentAssetParentName__c,componentAssetProductName__c,ComponentCreatedFromInformation__c,componentLocation__c,componentStatus__c,componentServicePartNumber__c,componentAssetName__c,componentComponentSN__c,componentType__c,warrantyEndDate__c FROM Component__c where Id IN:rmaComponentIds])
        {
            componentMap.put(com.Id, com);
        } 
    }
    
    //Bulk - Quering Component object with the collected assetName
    public static void getComponentMapByAssetId(Set<String> assetIds)
    {
        for(Component__c component: [Select Id,componentAccountId__c,componentState__c,Sub_State__c,componentAsset__c,componentTransaction__c,componentLocation__c,componentAssetStatus__c,componentServicePartNumber__c,componentAssetName__c,componentComponentSN__c,componentType__c,componentItem__c,ComponentCreatedFromInformation__c from Component__c where componentAsset__c IN: assetIds])
        {
            List<Component__c> lstCurrentComponent = new List<Component__c>();
            lstCurrentComponent.add(component);
            
            if(componentMapByAssetId.containsKey(component.componentAsset__c))
            {
                List<Component__c> lstExistingComponent = componentMapByAssetId.get(component.componentAsset__c);
                lstExistingComponent.add(component);
                componentMapByAssetId.put(component.componentAsset__c,lstExistingComponent);
            }
            else
            {
                componentMapByAssetId.put(component.componentAsset__c,lstCurrentComponent);               
            }
            
        }
    }
    
    //Added Auto OFA field in the SR Metadata Query-By Exafort(vishnu)
    //Added srPartShipSLAOverride__c field in the SR Metadata Query - By Exafort(vishnu) to default service parts to NBD Delivery SLA TS-5318 
    //Added srMinimumVersionRequired__c,srNimbleOSversionExceptions__c field in the Query - By Vishnu for TS-6426
    //Bulk - Quering srMetaData object with the collected set values
    public static void getSrMetaDataMap()
    {
        if(srMetaDataMap.size() == 0 &&  srMetaDataMapById.size() == 0){ // added by Exafort for TS-9109
            system.debug('Entered into the SR Meta Data query');
            for(SR_Meta_Data__c srMetaData:[Select Id,srMinimumVersionRequired__c,srNimbleOSversionExceptions__c,srPartShipSLAOverride__c,srAutoOFA__c,srAutoEFA__c,srShipOnly__c,srPart__c,srType__c,srDescription__c,srShippingProvider__c from SR_Meta_Data__c])
            {
                // toLowerCase() Added by Exafort for SFDC-1260
                if(srMetaData.srPart__c != null){
                    srMetaDataMap.put(srMetaData.srPart__c.toLowerCase(), srMetaData);
                }
                srMetaDataMapById.put(srMetaData.Id, srMetaData);
                
            }
        }
    }
    
    // Added by exafort for TS-9109
    public static Profile getTsrProfileId(){
        system.debug('in getTsrProfileId method --> tsrProfileId = ' + tsrProfileId);
        if (tsrProfileId != null){
            return tsrProfileId;            
        }
        tsrProfileId = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)'];
        return tsrProfileId;
        
    }
    
    
    public static List<EmailTemplate> getEmailTemplate(){
        if (rmaEmailTemplate != null){
            return rmaEmailTemplate;    
        }
        rmaEmailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Survey: RMA Closed'];
        return rmaEmailTemplate;
    }
    // End of TS-9109
    
    //Bulk - Quering EOA object with the collected set values
    public static void getEOAMap()
    {
        for(EOAPart__c EOA:[Select eoaPartName__c,eoaSuggestedFullSystemReplacement__c from EOAPart__c where eoaActive__c=true])
        {
            EOAMap.put(EOA.EOAPartName__c, EOA);
        }
    }
    
    public static void getRmaSubtitutionMap(set<String> rmaSupportProfileSet)
    {
        // Old Logic SFDC-309
        //  for(RMASubstitution__c  rmaSubtitution: [Select OldValue__c,IsOsVersionNull__c,NimbleOsVersionTo__c,NimbleOsVersionFrom__c,NewValue__c,
        //                                          IncludeToNimbleOsInSubstitution__c,BoundaryFormula__c from RMASubstitution__c])
        
        //Added By Exafort For SFDC_309
        String query = 'Select OldValue__c,IsOsVersionNull__c,NimbleOsVersionTo__c,NimbleOsVersionFrom__c,NewValue__c,'+
            'IncludeToNimbleOsInSubstitution__c,BoundaryFormula__c,Support_Profile__c from RMASubstitution__c Where ';
        
        List<String> includesConditions = new List<String>();
        
        // Dynamically build the WHERE clause with multiple INCLUDES conditions
        for (String value : rmaSupportProfileSet) {
            includesConditions.add('Support_Profile__c INCLUDES (\'' + value + '\')');
        }   
        query += String.join(includesConditions, ' OR ');
        
        //End of SFDC-309
        
        for(RMASubstitution__c  rmaSubtitution: Database.query(query)){
            List<RMASubstitution__c> lstCurrentSubstitution = new List<RMASubstitution__c>();
            lstCurrentSubstitution.add(rmaSubtitution);
            
            if(rmaSubtitutionMap.containsKey(rmaSubtitution.OldValue__c))
            {
                List<RMASubstitution__c> lstExistingSubstitution = rmaSubtitutionMap.get(rmaSubtitution.OldValue__c);
                lstExistingSubstitution.add(rmaSubtitution);
                rmaSubtitutionMap.put(rmaSubtitution.OldValue__c,lstExistingSubstitution);
            }
            else
            {
                rmaSubtitutionMap.put(rmaSubtitution.OldValue__c,lstCurrentSubstitution);               
            } 
        }
        
    }
    
    public static string checkNimbleOsVersion(string currentPart,RMAv2__c rmaToProcess)
    { 
        Boolean validOS = false;
        
        // Added by Exafort for TS-8079
        string compModel, rmaSubstitutedModel, commaSeperatedModel;
        Boolean matchModel = false;
        id ComponentRecord = rmaToProcess.rmaComponentV2__c;
        List<Component__c> Comp = [SELECT Id,Name,componentDiskModel__c  from Component__c WHERE id =: ComponentRecord];
        if(Comp.size() > 0 ){
            for(Component__c component : Comp){
                compModel = component.componentDiskModel__c;
            }
        }        
        
        // Added by exafort for SFDC-309
        string caseSupportProfile = caseIdWithSupportProfile.get(rmaToProcess.rmaCaseNumber__c); 
        System.debug('caseSupportProfile :'+caseSupportProfile);
        String rmaSupportProfile =   caseSupportProfile == null || caseSupportProfile != ''  ? 'Legacy Nimble' : caseSupportProfile ;
        List<RMASubstitution__c> rmaSubstitue = [SELECT Id,Name,OldValue__c,Model_Numbers__c  from RMASubstitution__c WHERE OldValue__c =: currentPart and Support_Profile__c Includes (:rmaSupportProfile)];
        //End of SFDC-309
        
        if(rmaSubstitue.size() > 0 ){
            for(RMASubstitution__c rmaSub : rmaSubstitue){
                rmaSubstitutedModel = rmaSub.Model_Numbers__c;
            }
        }
        system.debug('RMA Substitution Model Number ' + rmaSubstitutedModel);
        if(rmaSubstitutedModel != null){
            List<String> SepeartebyComma = rmaSubstitutedModel.split(',');
            for(String SubstitutionModel : SepeartebyComma){
                commaSeperatedModel = SubstitutionModel;
                if(commaSeperatedModel == compModel){
                    matchModel = True;
                    system.debug('Model Match found' + matchModel);
                }
            }
        }
        system.debug('Outside the for loop' + matchModel);
        // End of TS-8079
        
        //Added by Exafort for TS-8266 
        //if(rmaToProcess.rmaNimbleOSVersionForSubstitution__c != null)
        //compModel == null Added by exafort for TS-8079
        system.debug('compModel ++++ --> ' + compModel);
        if(rmaToProcess.rmaCaseNimbleVersion__c != null && (compModel == null || rmaSubstitutedModel == null))           
        {
            system.debug('Enter into the RMA Substitutaion process');
            system.debug('Nimble OS version from case ' + rmaToProcess.rmaCaseNimbleVersion__c);
            system.debug('+++currentPart+++' + currentPart);
            system.debug('+++rmaAssetNimbleOSVersion__c+++' + rmaToProcess.rmaNimbleOSVersionForSubstitution__c);
            
            Integer assetOsMajor;
            Integer assetOsMinor;
            Integer assetOsSub1;
            Integer assetOsSub2;
            
            
            Pattern osVersionPattern = Pattern.compile('^(\\d*).(\\d*).(\\d*).(\\d*)(.*?)$');
            //Added by Exafort for TS-8266
            //Matcher osVersionAssetMatcher = osVersionPattern.matcher(rmaToProcess.rmaNimbleOSVersionForSubstitution__c);
            Matcher osVersionAssetMatcher = osVersionPattern.matcher(rmaToProcess.rmaCaseNimbleVersion__c);
            if (osVersionAssetMatcher.find())
            {
                try
                {
                    assetOsMajor = Integer.valueOf(osVersionAssetMatcher.group(1));
                    assetOsMinor = Integer.valueOf(osVersionAssetMatcher.group(2));
                    assetOsSub1  = Integer.valueOf(osVersionAssetMatcher.group(3));
                    assetOsSub2  = Integer.valueOf(osVersionAssetMatcher.group(4));
                    validOS = true;
                }
                catch(Exception ex)
                {
                    validOS = false;
                }
            }
            
            if(validOS == true)
            {   
                system.debug('+++assetOsMajor+++' + assetOsMajor);
                system.debug('+++assetOsMinor+++' + assetOsMinor);
                system.debug('+++assetOsSub1+++' + assetOsSub1);
                system.debug('+++assetOsSub1+++' + assetOsSub2);
                
                system.debug('+++rmaSubtitutionMap+++' + rmaSubtitutionMap.size());
                
                for(RMASubstitution__c rmaSubstitution:rmaSubtitutionMap.get(currentPart))
                {
                   //Added By Exafort for SFDC-309
                   if(rmaSubstitution.Support_Profile__c.Contains(caseIdWithSupportProfile.get(rmaToProcess.rmaCaseNumber__c))){ 
                    
                    Integer fromOsMajor=0,toOsMajor;
                    Integer fromOsMinor=0,toOsMinor;
                    Integer fromOsSub1=0,toOsSub1;
                    Integer fromOsSub2=0,toOsSub2;
                    
                    if(rmaSubstitution.IsOsVersionNull__c == false)
                    {
                        Integer existingNimbleOsVersionFrom = 0;
                        Integer existingNimbleOsVersionTo = 0;
                        
                        if(rmaSubstitution.NimbleOsVersionFrom__c != null  && rmaSubstitution.NimbleOsVersionFrom__c !='Unknown')
                        {
                            Matcher osVersionFromMatcher = osVersionPattern.matcher(rmaSubstitution.NimbleOsVersionFrom__c);
                            if (osVersionFromMatcher.find())
                            {
                                fromOsMajor = Integer.valueOf(osVersionFromMatcher.group(1));
                                fromOsMinor = Integer.valueOf(osVersionFromMatcher.group(2));
                                fromOsSub1  = Integer.valueOf(osVersionFromMatcher.group(3));
                                fromOsSub2  = Integer.valueOf(osVersionFromMatcher.group(4));
                                
                                system.debug('+++fromOsMajor+++' + fromOsMajor);
                                system.debug('+++fromOsMinor+++' + fromOsMinor);
                                system.debug('+++fromOsSub1+++' + fromOsSub1);
                                system.debug('+++fromOsSub2+++' + fromOsSub2);
                            }
                        }
                        else
                        {
                            fromOsMajor=0;
                            fromOsMinor=0;
                            fromOsSub1=0;
                            fromOsSub2=0; 
                            
                            system.debug('+++fromOsMajor+++' + fromOsMajor);
                            system.debug('+++fromOsMinor+++' + fromOsMinor);
                            system.debug('+++fromOsSub1+++' + fromOsSub1);
                            system.debug('+++fromOsSub2+++' + fromOsSub2);
                        }
                        
                        if(rmaSubstitution.NimbleOsVersionTo__c != null)
                        {
                            Matcher osVersionToMatcher = osVersionPattern.matcher(rmaSubstitution.NimbleOsVersionTo__c);
                            if (osVersionToMatcher.find())
                            {
                                toOsMajor = Integer.valueOf(osVersionToMatcher.group(1));
                                toOsMinor = Integer.valueOf(osVersionToMatcher.group(2));
                                toOsSub1  = Integer.valueOf(osVersionToMatcher.group(3));
                                toOsSub2  = Integer.valueOf(osVersionToMatcher.group(4));
                                
                                system.debug('+++toOsMajor+++' + toOsMajor);
                                system.debug('+++toOsMinor+++' + toOsMinor);
                                system.debug('+++toOsSub1+++' + toOsSub1);
                                system.debug('+++toOsSub2+++' + toOsSub2);
                            }
                        }
                        
                        if(rmaSubstitution.NimbleOsVersionFrom__c == rmaSubstitution.NimbleOsVersionTo__c)
                        {
                            system.debug('+++block 1+++');
                            if((assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 == fromOsSub1 && assetOsSub2 == fromOsSub2))
                            {
                                currentPart = rmaSubstitution.NewValue__c;
                                break;
                            }
                        }
                        else if(rmaSubstitution.NimbleOsVersionTo__c != null)
                        {
                            system.debug('+++block 2+++');
                            if((((assetOsMajor > fromOsMajor) ||
                                 (assetOsMajor == fromOsMajor && assetOsMinor > fromOsMinor) || 
                                 (assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 > fromOsSub1) ||
                                 (assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 == fromOsSub1 && assetOsSub2 >= fromOsSub2 ))
                                
                                &&
                                
                                ((assetOsMajor < toOsMajor) ||
                                 (assetOsMajor == toOsMajor && assetOsMinor < toOsMinor) ||  
                                 (assetOsMajor == toOsMajor && assetOsMinor == toOsMinor && assetOsSub1 < toOsSub1) ||
                                 (assetOsMajor == toOsMajor && assetOsMinor == toOsMinor && assetOsSub1 == toOsSub1 && assetOsSub2 < toOsSub2 && rmaSubstitution.IncludeToNimbleOsInSubstitution__c==false) || 
                                 (assetOsMajor == toOsMajor && assetOsMinor == toOsMinor && assetOsSub1 == toOsSub1 && assetOsSub2 <= toOsSub2 && rmaSubstitution.IncludeToNimbleOsInSubstitution__c==true)))) 
                                
                            {
                                currentPart = rmaSubstitution.NewValue__c;
                                break;
                            }
                        }
                        else if(rmaSubstitution.NimbleOsVersionFrom__c != null)
                        {
                            system.debug('+++block 3+++');
                            if(((assetOsMajor > fromOsMajor) ||
                                (assetOsMajor == fromOsMajor && assetOsMinor > fromOsMinor) || 
                                (assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 > fromOsSub1) ||
                                (assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 == fromOsSub1 && assetOsSub2 >= fromOsSub2 )) )
                            {
                                currentPart = rmaSubstitution.NewValue__c;
                                break;
                            }
                        }
                    }
                    else if(rmaSubstitution.IsOsVersionNull__c == true && rmaSubstitutedModel == null){
                        system.debug('Entered into the balnk boundary condition and blank model');
                        currentPart = rmaSubstitution.NewValue__c;
                        break;
                    }
                    
                    
                }
            }
            }
        }
        // Added by exafort for TS-8079
        else if(rmaToProcess.rmaCaseNimbleVersion__c != null && matchModel == True){
            system.debug('Enter into the New RMA Substitutaion process to map based on Version and Model Number');
            Integer assetOsMajor;
            Integer assetOsMinor;
            Integer assetOsSub1;
            Integer assetOsSub2;
            Pattern osVersionPattern = Pattern.compile('^(\\d*).(\\d*).(\\d*).(\\d*)(.*?)$');
            Matcher osVersionAssetMatcher = osVersionPattern.matcher(rmaToProcess.rmaCaseNimbleVersion__c);
            if (osVersionAssetMatcher.find())
            {
                try
                {
                    assetOsMajor = Integer.valueOf(osVersionAssetMatcher.group(1));
                    assetOsMinor = Integer.valueOf(osVersionAssetMatcher.group(2));
                    assetOsSub1  = Integer.valueOf(osVersionAssetMatcher.group(3));
                    assetOsSub2  = Integer.valueOf(osVersionAssetMatcher.group(4));
                    validOS = true;
                }
                catch(Exception ex)
                {
                    validOS = false;
                }
            }
            
            if(validOS == true)
            {
                for(RMASubstitution__c rmaSubstitution:rmaSubtitutionMap.get(currentPart))
                {
                    //Added by Exafort for SFDC-309
                    if(rmaSubstitution.Support_Profile__c.Contains(caseIdWithSupportProfile.get(rmaToProcess.rmaCaseNumber__c))){
                    Integer fromOsMajor=0,toOsMajor;
                    Integer fromOsMinor=0,toOsMinor;
                    Integer fromOsSub1=0,toOsSub1;
                    Integer fromOsSub2=0,toOsSub2;
                    
                    if(rmaSubstitution.IsOsVersionNull__c == false)
                    {
                        Integer existingNimbleOsVersionFrom = 0;
                        Integer existingNimbleOsVersionTo = 0;
                        
                        if(rmaSubstitution.NimbleOsVersionFrom__c != null  && rmaSubstitution.NimbleOsVersionFrom__c !='Unknown')
                        {
                            Matcher osVersionFromMatcher = osVersionPattern.matcher(rmaSubstitution.NimbleOsVersionFrom__c);
                            if (osVersionFromMatcher.find())
                            {
                                fromOsMajor = Integer.valueOf(osVersionFromMatcher.group(1));
                                fromOsMinor = Integer.valueOf(osVersionFromMatcher.group(2));
                                fromOsSub1  = Integer.valueOf(osVersionFromMatcher.group(3));
                                fromOsSub2  = Integer.valueOf(osVersionFromMatcher.group(4));
                            }
                        }
                        else
                        {
                            fromOsMajor=0;
                            fromOsMinor=0;
                            fromOsSub1=0;
                            fromOsSub2=0;
                        }
                        system.debug('rmaSubstitution.NimbleOsVersionTo__c ++ --> ' + rmaSubstitution.id);
                        system.debug('rmaSubstitution.NimbleOsVersionTo__c ++ --> ' + rmaSubstitution.NimbleOsVersionTo__c);
                        if(rmaSubstitution.NimbleOsVersionTo__c != null)
                        {
                            Matcher osVersionToMatcher = osVersionPattern.matcher(rmaSubstitution.NimbleOsVersionTo__c);
                            if (osVersionToMatcher.find())
                            {
                                toOsMajor = Integer.valueOf(osVersionToMatcher.group(1));
                                toOsMinor = Integer.valueOf(osVersionToMatcher.group(2));
                                toOsSub1  = Integer.valueOf(osVersionToMatcher.group(3));
                                toOsSub2  = Integer.valueOf(osVersionToMatcher.group(4));
                            }
                        }
                        
                        if(rmaSubstitution.NimbleOsVersionFrom__c == rmaSubstitution.NimbleOsVersionTo__c)
                        {
                            system.debug('+++New block 1+++');
                            if((assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 == fromOsSub1 && assetOsSub2 == fromOsSub2) && matchModel == True)
                            {
                                currentPart = rmaSubstitution.NewValue__c;
                                break;
                            }
                        }
                        else if(rmaSubstitution.NimbleOsVersionTo__c != null)
                        {
                            system.debug('+++New block 2+++');
                            if((((assetOsMajor > fromOsMajor) ||
                                 (assetOsMajor == fromOsMajor && assetOsMinor > fromOsMinor) || 
                                 (assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 > fromOsSub1) ||
                                 (assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 == fromOsSub1 && assetOsSub2 >= fromOsSub2 ))
                                
                                &&
                                
                                ((assetOsMajor < toOsMajor) ||
                                 (assetOsMajor == toOsMajor && assetOsMinor < toOsMinor) ||  
                                 (assetOsMajor == toOsMajor && assetOsMinor == toOsMinor && assetOsSub1 < toOsSub1) ||
                                 (assetOsMajor == toOsMajor && assetOsMinor == toOsMinor && assetOsSub1 == toOsSub1 && assetOsSub2 < toOsSub2 && rmaSubstitution.IncludeToNimbleOsInSubstitution__c==false) || 
                                 (assetOsMajor == toOsMajor && assetOsMinor == toOsMinor && assetOsSub1 == toOsSub1 && assetOsSub2 <= toOsSub2 && rmaSubstitution.IncludeToNimbleOsInSubstitution__c==true)))
                               && matchModel == True) 
                                
                            {
                                currentPart = rmaSubstitution.NewValue__c;
                                system.debug('currentPart ++ --> ' + currentPart);
                                break;
                            }
                        }
                        else if(rmaSubstitution.NimbleOsVersionFrom__c != null)
                        {
                            system.debug('+++block 3+++');
                            if(((assetOsMajor > fromOsMajor) ||
                                (assetOsMajor == fromOsMajor && assetOsMinor > fromOsMinor) || 
                                (assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 > fromOsSub1) ||
                                (assetOsMajor == fromOsMajor && assetOsMinor == fromOsMinor && assetOsSub1 == fromOsSub1 && assetOsSub2 >= fromOsSub2 )) 
                               && matchModel == True)
                            {
                                currentPart = rmaSubstitution.NewValue__c;
                                break;
                            }
                        }
                        
                    }
                    else if((rmaSubstitution.IsOsVersionNull__c == True && matchModel == True)){
                        system.debug('Entered to find only the match model');
                        currentPart = rmaSubstitution.NewValue__c;
                        break;
                    }
                }
            }
            }
            
            
        }
        // End of TS-8079
        else
        {
            for(RMASubstitution__c rmaSubstitution:rmaSubtitutionMap.get(currentPart))
            {
                //Added By Exafort for SFDC-309
                if(rmaSubstitution.Support_Profile__c.Contains(caseIdWithSupportProfile.get(rmaToProcess.rmaCaseNumber__c))){
                    if(rmaSubstitution.IsOsVersionNull__c == true)
                    {
                        system.debug('Entered into the null value');
                        currentPart = rmaSubstitution.NewValue__c;
                        break;
                    }
                }
            }
        }
        
        return currentPart;
    }
    
    //Added by vishnu for TS-6426 on 16th Apr 2020.
    public static void checkSrPartMinOsVersion()
    { 
        try{
            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
                for(RMAv2__c rmaToProcess : (List<RMAv2__c>) Trigger.new){
                    if(rmaToProcess.rmaOutgoingShipmentStatus__c.contains('DRAFT-10') && rmaToProcess.rmaPartNumber__c != null ){
                        system.debug('### INSIDE BEFORE INSERT @@@@');
                        system.debug('### rma part number ===>'+rmaToProcess.rmaPartNumber__c);
                        // toLowerCase() Added by Exafort for SFDC-1260
                        SR_Meta_Data__c srMetaDataRec;
                        if(srMetaDataMap.size() > 0 && rmaToProcess.rmaPartNumber__c != null){
                            srMetaDataRec = srMetaDataMap.get(rmaToProcess.rmaPartNumber__c.toLowerCase());
                        }
                        system.debug('####srMetaDataRec Value @@@@'+srMetaDataRec);
                        if(srMetaDataRec != null && srMetaDataRec.srMinimumVersionRequired__c != null){
                            Boolean ShowErr = checkAssetSrPartMinOsVersion(rmaToProcess,srMetaDataRec);
                            system.debug('Value in showError ===>'+ ShowErr);
                            if(ShowErr == true && rmaToProcess.rmaByPassSRPartMinOSvalidation__c == false){
                                rmaToProcess.addError('<b> DO NOT SHIP THIS PART..! </b>'
                                                      +'</br> The part selected is not compatible with this version of Nimble OS reported by the array and case.'
                                                      +'</br> Select a different part to fulfill the RMA request.'
                                                      //+'</br> <b>Nimble OS version details:</b>'
                                                      //+'</br> 1.<b> Asset Nimble OS version : </b>' + rmaToProcess.rmaAssetNimbleVersion__c
                                                      //+'</br> 2.<b> Case Nimble OS version : </b>' + rmaToProcess.rmaCaseNimbleVersion__c
                                                      //+'</br> 3.<b> Minimum Required Version for the selected part : </b>' + srMetaDataRec.srMinimumVersionRequired__c
                                                      //+'</br> 4.<b> Other Invalid Versions : </b>' + srMetaDataRec.srNimbleOSversionExceptions__c
                                                     );
                            }
                        }
                    }
                    //	Added by Exafort for SFDC-1685
                    //	Check if SLA is NBD OR override scheduling code contains NEXT-BUSINESS-DAY-10
                    //	If condition updated by Exafort for SFDC-2307
                    if (((rmaToProcess.Shipment_SLA_Internal__c == 'NBD' ||
                         (rmaToProcess.rmaOverrideOnsiteSchedulingCode__c != null && rmaToProcess.rmaOverrideOnsiteSchedulingCode__c.contains('NEXT-BUSINESS-DAY-10')))
                        && String.isBlank(rmaToProcess.rmaOnsiteSla__c)) || (rmaToProcess.Disk_Shelf_Asset_SLA__c != null && rmaToProcess.Disk_Shelf_Asset_SLA__c == 'Premium Onsite')
                       ) {
                           rmaToProcess.Shipment_SLA_for_Flash__c = 'NBD';
                       } else if (!String.isBlank(rmaToProcess.rmaOnsiteSla__c)) {
                           //        If onsite SLA is provided, use it
                           rmaToProcess.Shipment_SLA_for_Flash__c = rmaToProcess.rmaOnsiteSla__c;
                       } else {
                           rmaToProcess.Shipment_SLA_for_Flash__c = rmaToProcess.Shipment_SLA_Internal__c;
                       }
                    //	End of SFDC-1685
                }
            }
        }
        catch(Exception e){
            system.debug('Caught Error in checkSrPartMinOsVersion method : '+e);
        } 
    }
    //Added by vishnu for TS-6426 on 16th Apr 2020.
    public static boolean checkAssetSrPartMinOsVersion(RMAv2__c rmaToProcess,SR_Meta_Data__c srMetaData)
    {
        Integer SrMajorEx,SrMajorEx0,SrMajorEx1;
        Integer SrMinorEx,SrMinorEx0,SrMinorEx1;
        Integer SrOsSub1Ex,SrOsSub1Ex0,SrOsSub1Ex1;
        Integer SrOsSub2Ex,SrOsSub2Ex0,SrOsSub2Ex1;
        Integer SrMajor,caseOsMajorForSr,assetOsMajorForSr;
        Integer SrMinor,caseOsMinorForSr,assetOsMinorForSr;
        Integer SrOsSub1,caseOsSub1ForSr,assetOsSub1ForSr;
        Integer SrOsSub2,caseOsSub2ForSr,assetOsSub2ForSr;
        Boolean showError,showcaseError,showAssetError,isExcOSValid = false;
        
        system.debug('### Parameters passed ===>'+srMetaData);
        system.debug('### Selected Asset in the RMA ===>'+rmaToProcess.rmaDiskShelfAsset__c);
        system.debug('### OS version from the Asset formula===>'+rmaToProcess.rmaAssetNimbleVersion__c);
        Pattern osVersionPattern = Pattern.compile('^(\\d*).(\\d*).(\\d*).(\\d*)(.*?)$');
        
        //Code block to get the minimum OS version from the SR metadata.
        Matcher osVersionMatcherForSrMetadata = osVersionPattern.matcher(srMetaData.srMinimumVersionRequired__c);
        if (osVersionMatcherForSrMetadata.find())
        {
            system.debug('### Debugging  721===>');
            SrMajor = Integer.valueOf(osVersionMatcherForSrMetadata.group(1));
            SrMinor = Integer.valueOf(osVersionMatcherForSrMetadata.group(2));
            SrOsSub1 = Integer.valueOf(osVersionMatcherForSrMetadata.group(3));
            SrOsSub2 = Integer.valueOf(osVersionMatcherForSrMetadata.group(4));
        }
        //Code block to get the case OS version to validate against the minimum OS version for the SR part.
        if(rmaToProcess.rmaCaseNimbleVersion__c != null){
            Matcher osVersionMatcherCase = osVersionPattern.matcher(rmaToProcess.rmaCaseNimbleVersion__c);
            if (osVersionMatcherCase.find())
            {
                caseOsMajorForSr = Integer.valueOf(osVersionMatcherCase.group(1));
                caseOsMinorForSr = Integer.valueOf(osVersionMatcherCase.group(2));
                caseOsSub1ForSr  = Integer.valueOf(osVersionMatcherCase.group(3));
                caseOsSub2ForSr = Integer.valueOf(osVersionMatcherCase.group(4));
            }
        }else{
            system.debug('### Case Nimble OS version is null <===');
        }
        //Code block to get the asset OS version to validate against the minimum OS version for the SR part.
        if(rmaToProcess.rmaAssetNimbleVersion__c != null){
            Matcher osVersionMatcherAsset = osVersionPattern.matcher(rmaToProcess.rmaAssetNimbleVersion__c);
            if (osVersionMatcherAsset.find())
            {
                assetOsMajorForSr = Integer.valueOf(osVersionMatcherAsset.group(1));
                assetOsMinorForSr = Integer.valueOf(osVersionMatcherAsset.group(2));
                assetOsSub1ForSr  = Integer.valueOf(osVersionMatcherAsset.group(3));
                assetOsSub2ForSr = Integer.valueOf(osVersionMatcherAsset.group(4));
            }
        }else{
            system.debug('### Asset Nimble OS version is null <===');
        }
        
        //Code block for validating exceptions
        if(srMetaData.srNimbleOSversionExceptions__c != null){
            if(srMetaData.srNimbleOSversionExceptions__c.contains(',')){
                
            }else if(srMetaData.srNimbleOSversionExceptions__c.contains('-')){
                List<String> splitted_Array = srMetaData.srNimbleOSversionExceptions__c.split('-');
                if(splitted_Array.size() == 2){
                    //From version
                    Matcher versionMatcherForOsExc0 = osVersionPattern.matcher(splitted_Array[0].trim());
                    if (versionMatcherForOsExc0.find())
                    {
                        SrMajorEx0 = Integer.valueOf(versionMatcherForOsExc0.group(1));
                        SrMinorEx0 = Integer.valueOf(versionMatcherForOsExc0.group(2));
                        SrOsSub1Ex0 = Integer.valueOf(versionMatcherForOsExc0.group(3));
                        SrOsSub2Ex0 = Integer.valueOf(versionMatcherForOsExc0.group(4));
                    }
                    //To version
                    Matcher versionMatcherForOsExc1 = osVersionPattern.matcher(splitted_Array[1].trim());
                    if (versionMatcherForOsExc1.find())
                    {
                        system.debug('### Debugging  721===>');
                        SrMajorEx1 = Integer.valueOf(versionMatcherForOsExc1.group(1));
                        SrMinorEx1 = Integer.valueOf(versionMatcherForOsExc1.group(2));
                        SrOsSub1Ex1 = Integer.valueOf(versionMatcherForOsExc1.group(3));
                        SrOsSub2Ex1 = Integer.valueOf(versionMatcherForOsExc1.group(4));
                    }
                    //validating OS versions against the OS versin exceptions
                    if(  ((assetOsMajorForSr >= SrMajorEx0 && assetOsMajorForSr <= SrMajorEx1)
                          &&   (assetOsMinorForSr >= SrMinorEx0 && assetOsMinorForSr <= SrMinorEx1) 
                          &&   (assetOsSub1ForSr >= SrOsSub1Ex0 && assetOsSub1ForSr <= SrOsSub1Ex1) 
                          &&   (assetOsSub2ForSr >= SrOsSub2Ex0 && assetOsSub2ForSr <= SrOsSub2Ex1))
                       || ((caseOsMajorForSr >= SrMajorEx0 && caseOsMajorForSr <= SrMajorEx1)
                           &&   (caseOsMinorForSr >= SrMinorEx0 && caseOsMinorForSr <= SrMinorEx1) 
                           &&   (caseOsSub1ForSr >= SrOsSub1Ex0 && caseOsSub1ForSr <= SrOsSub1Ex1) 
                           &&   (caseOsSub2ForSr >= SrOsSub2Ex0 && caseOsSub2ForSr <= SrOsSub2Ex1)))
                    {
                        isExcOSValid = true;
                        system.debug('### Debugging  763===>'+isExcOSValid);
                    }else{
                        isExcOSValid = false;
                        system.debug('### Debugging  766===>'+isExcOSValid);
                    }
                }
            }else{
                Matcher versionMatcherForOsExc = osVersionPattern.matcher(srMetaData.srNimbleOSversionExceptions__c);
                if (versionMatcherForOsExc.find())
                {
                    SrMajorEx = Integer.valueOf(versionMatcherForOsExc.group(1));
                    SrMinorEx = Integer.valueOf(versionMatcherForOsExc.group(2));
                    SrOsSub1Ex = Integer.valueOf(versionMatcherForOsExc.group(3));
                    SrOsSub2Ex = Integer.valueOf(versionMatcherForOsExc.group(4));
                }
                if((assetOsMajorForSr == SrMajorEx || caseOsMajorForSr == SrMajorEx)
                   &&   (assetOsMinorForSr == SrMinorEx || caseOsMinorForSr == SrMinorEx) 
                   &&   (assetOsSub1ForSr == SrOsSub1Ex || caseOsSub1ForSr == SrOsSub1Ex) 
                   &&   (assetOsSub2ForSr == SrOsSub2Ex || caseOsSub2ForSr == SrOsSub2Ex))
                {
                    isExcOSValid = true;
                    system.debug('### Debugging  763===>'+isExcOSValid);
                }else{
                    isExcOSValid = false;
                    system.debug('### Debugging  766===>'+isExcOSValid);
                }
            }
        }
        
        //checking the OS version major and minor- For Asset
        if((assetOsMajorForSr > SrMajor) 
           || (assetOsMajorForSr == SrMajor && assetOsMinorForSr > SrMinor) 
           || (assetOsMajorForSr == SrMajor && assetOsMinorForSr == SrMinor && assetOsSub1ForSr > SrOsSub1) 
           || (assetOsMajorForSr == SrMajor && assetOsMinorForSr == SrMinor && assetOsSub1ForSr == SrOsSub1 && assetOsSub2ForSr >= SrOsSub2 ))
        {
            showAssetError = false;
            system.debug('### Debugging  763===>'+showAssetError);
        }else{
            showAssetError = true;
            system.debug('### Debugging  766===>'+showAssetError);
        }
        //checking the OS version major and minor- For Case
        if((caseOsMajorForSr > SrMajor) 
           || (caseOsMajorForSr == SrMajor && caseOsMinorForSr > SrMinor) 
           || (caseOsMajorForSr == SrMajor && caseOsMinorForSr == SrMinor && caseOsSub1ForSr > SrOsSub1) 
           || (caseOsMajorForSr == SrMajor && caseOsMinorForSr == SrMinor && caseOsSub1ForSr == SrOsSub1 && caseOsSub2ForSr >= SrOsSub2 ))
        {
            showcaseError = false;
            system.debug('### Debugging  775===>'+showcaseError);
        }else{
            showcaseError = true;
            system.debug('### Debugging  778===>'+showcaseError);
        }
        
        //Returning the final value to show the validation in RMA.
        if(showAssetError == true || showcaseError == true || isExcOSValid == true){
            showError = true;
            system.debug('### Debugging  784===>'+showError);
        }else{
            showError = false;
            system.debug('### Debugging  787===>'+showError);
        }
        system.debug('### Debugging  789===>'+showError);
        return showError;
    }
    
    //All the incoming RMA Records are processed here one by one
    //While processing the current RMA Records looks for the collected MAP whenever required - eliminating SOQL Query
    public static void rmaMain(RMAv2__c rmaToProcess)
    {
        String soqlPostalCode = rmaVerifyCountryAndPostalCode(rmaToProcess);
        //	Added by Exafort for SFDC-2143
        if(rmaToProcess.rmaSelection__c == 'Component' && rmaToProcess.rmaFailedPart__c == null && !Test.isRunningTest() && !CaseUtility.isNimbleSupportUser() && !CaseUtility.isSupportAutomationUser()){
            rmaToProcess.addError('Please select a Component that has a Service Part Number from "Component View", or use "Flat List View" to select a SR Part');
        }
        //	End of SFDC-2143
        
        if(soqlPostalCode != '')
        {
            rmaSetAutomationFields(rmaToProcess);
            rmaSetFa(rmaToProcess);
            rmaSetStatusAndTimestamps(rmaToProcess);
            rmaSetSLADueDateTimeValue(rmaToProcess);
            
            //rmaModel_c field ensure the navigation to new logic or old logic
            if(rmaToProcess.rmaModel__c != null)
            {
                rmaAssignHddAndSsdPartNumbers(rmaToProcess);
            }
            else
            {
                
                String processedStatus = rmaAssignPartNumberBasedOnSelection(rmaToProcess);
                
                if(processedStatus == 'Failed')
                    return;
                
                //Insert or Update component based on component Flow
                upsertComponentRecords();
                
                //When RMA moves from Draft, for every Flat List selection new component has to be created and assiged to apporiate field(rmaComponentV2__c) in RMA
                if(rmaToProcess.rmaComponentV2__c == null && rmaToProcess.rmaStatus__c == 'Open' && rmaToProcess.rmaSelection__c =='Flat List' && rmaToProcess.rmaPartNumber__c.startsWith('SR-'))
                {
                    if(upsertComponentMap.get(rmaToProcess.Name) != null){
                        component__c newComponent = upsertComponentMap.get(rmaToProcess.Name);
                        rmaToProcess.rmaComponentV2__c = newComponent.Id;
                    }
                }
                
            }
            
            
            rmaAssignProviderAndDepot(rmaToProcess,soqlPostalCode);
            rmaSetOutgoingShipmentTimeStamps(rmaToProcess);
            rmaSetReturnShipmentTimestamps(rmaToProcess);
            rmaPopulateOnsiteCompiledNotes(rmaToProcess);
            
            rmaPopulateDeliveryInstructions(rmaToProcess);
        }
        else
        {
            return;
        }
        //Added by exafort for TS-8266
        system.debug('Entered to find the Outgoing Shipment Status '+rmaToProcess.rmaOutgoingShipmentStatus__c);
        if(rmaToProcess.rmaOutgoingShipmentStatus__c != null && rmaToProcess.rmaOutgoingShipmentStatus__c == 'DRAFT-10: Waiting to order'){
            system.debug('Entered into line 918');
            //rmaToProcess.rmaNimbleOSVersionatSubmission__c = rmaToProcess.rmaCaseNimbleVersion__c;
            rmaToProcess.rmaNimbleOSVersionForSubstitution__c = rmaToProcess.rmaCaseNimbleVersion__c;
        }
        //Added By exafort for the ticket TS-10234
            if(rmaToProcess.rmaSelection__c == 'Component' && 
               rmaToProcess.Flat_List_Type__c != null){                 
                   rmaToProcess.Flat_List_Type__c = null;                  
               } 
         //End of TS-10234 
         
        // Added by Exafort for TS-10033 
        // For 10234 included the condition rmaToProcess.rmaSelection__c == 'Flat List'
        // createdDateTime Added by Exafort for TS-10310 below logic implemented on Oct 2023.
        // To prevent this error on multiple records, Hardcoded the createdDate condition for those that were created before the logic was implemented
        Datetime createdDateTime = Datetime.newInstance(2023, 10, 01, 0, 0, 0);
        if((rmaToProcess.Flat_List_Type__c == 'Based On Head and All Related Assets' || rmaToProcess.Flat_List_Type__c == 'Unfiltered')
           && rmaToProcess.rmaDiskShelfAsset__c != null && rmaToProcess.rmaSelection__c == 'Flat List' && rmaToProcess.CreatedDate >= createdDateTime){
               rmaToProcess.addError('Provide "Disk Shelf Asset" only when "Specified Asset Only" option is selected');
           }    
        // End of TS-10033  
    }
    
    public static void upsertComponentRecords()
    {
        //A Component can be linked to 2 RMA's. In this case, eliminate the same component getting updated twice (caused List exception)
        List<component__c> upsertComponentList = new List<component__c>();
        Set<Id> setComponentIds = new Set<Id>();
        for(Component__c comp: upsertComponentMap.values())
        {
            if(comp.Id == null)
            {
                upsertComponentList.add(comp);
            }
            else if(!setComponentIds.contains(comp.Id))
            {
                setComponentIds.add(comp.Id);
                upsertComponentList.add(comp);
            }
        }
        upsert upsertComponentList;
    }
    
    public static string EOAPartSubstitution(string currentPart, RMAv2__c rmaToProcess)
    {
        
        EOAPart__c EOAPart = (EOAMap.containsKey(currentPart)?EOAMap.get(currentPart):null); //komathi priya on Nov 29 2019 for TS-5413
        
        if(EOAPart != null)
        {
            currentPart = EOAPart.eoaSuggestedFullSystemReplacement__c;
        }
        if(rmaSubtitutionMap.containsKey(currentPart))
        {
            currentPart = checkNimbleOsVersion(currentPart,rmaToProcess);
        }
        
        return currentPart;
    }
    
    public static void determinePartsFromFlash(string rmaPart,RMAv2__c rmaToProcess,SR_Meta_Data__c srMetaData)
    {
        rmaToProcess.rmaPart__c = '(' + rmaPart + ')';
        rmaToProcess.rmaPartNumber__c =  rmaPart;
        
        if(srMetaData != null)
        {
            if(srMetaData.srShippingProvider__c == 'Flash')
            {
                rmaToProcess.rmaPart__c = '[' + rmaPart + ']';
                rmaToProcess.rmaPartNumber__c =  rmaPart;
            }
        }
        
    }
    
    public static void assignComponentFlag(SR_Meta_Data__c srMetaData,RMAv2__c rmaToProcess)
    {
        rmaToProcess.rmaComponentIsAutoEFA__c = false;
        rmaToProcess.rmaComponentIsAShipOnlyPart__c = false;
        //****Added by Exafort(vishnu) on 20th august for Auto OFA feature****//
        rmaToProcess.rmaComponentIsAutoOFA__c = false;
        
        //Order Type should be 'Ship Only' if RMA Part Shipping Provider is 'Shipping and Receiving'
        /* if(srMetaData != null && srMetaData.srShippingProvider__c == 'Shipping and Receiving' && rmaToProcess.rmaType__c != 'Ship Only'){
rmaToProcess.rmaType__c = 'Ship Only';
}*/
        if(srMetaData != null && srMetaData.srShippingProvider__c == 'Shipping and Receiving'){
            srMetaDataShippingProvider = 'Shipping and Receiving';
            rmaToProcess.rmaSRShippingProvider__c = 'Shipping and Receiving';
            //rmaToProcess.rmaSLAHelper__c = 'Ship Only';
        }
        
        
        if(srMetaData != null)
        {
            if(srMetaData.srAutoEFA__c == true)
            {
                rmaToProcess.rmaComponentIsAutoEFA__c = true;
            }
            //****Added by Exafort(vishnu) on 20th august for Auto OFA feature****- Start//
            if(srMetaData.srAutoOFA__c == true)
            {
                rmaToProcess.rmaComponentIsAutoOFA__c = true;
            }
            //**** END ****//
            if(srMetaData.srShipOnly__c == true)
            {
                rmaToProcess.rmaComponentIsAShipOnlyPart__c = true;
            }
            //Added by Exafort(vishnu) on 1st FEB 2019 for overriding the order type from ship only.-TS-5318
            if(srMetaData.srPartShipSLAOverride__c != null)
            {
                rmaToProcess.rmaIsSrPartNBDOverridden__c = true;
            }
        }
    }
    
    public static string rmaAssignPartNumberBasedOnSelection(RMAv2__c rmaToProcess)
    {
        String processedStatus = 'Success';
        string rmaPart; // TS-7109
        if(rmaToProcess != null && rmaToProcess.rmaSelection__c != null)
        {
            if(rmaToProcess.rmaSelection__c == 'Component' || rmaToProcess.rmaSelection__c == 'Spares or Upgrades' )
            {          
                Component__c component = rmaToProcess.rmaComponentV2__c != null && componentMap.containsKey(rmaToProcess.rmaComponentV2__c) ? componentMap.get(rmaToProcess.rmaComponentV2__c) : null;
                if (component != null) // TS-7109
                    rmaPart = EOAPartSubstitution(component.componentServicePartNumber__c,rmaToProcess);  
                rmaToProcess.rmaComponent__c =  component != null ? component.componentType__c : null;
                // toLowerCase() Added by Exafort for SFDC-1260
                SR_Meta_Data__c srMetaData; 
                if(rmaPart != null){
                    srMetaData = srMetaDataMap.containsKey(rmaPart.toLowerCase()) ? srMetaDataMap.get(rmaPart.toLowerCase()) : null;  
                }
                determinePartsFromFlash(rmaPart,rmaToProcess,srMetaData);
                assignComponentFlag(srMetaData,rmaToProcess);
                if (rmaPart != null) //TS-7109
                    if(rmaPart != component.componentServicePartNumber__c)
                {
                    rmaToProcess.rmaSubstitutionPart__c = component.componentServicePartNumber__c + ' <'  + rmaPart + '>';
                }
                else
                {
                    rmaToProcess.rmaSubstitutionPart__c = component.componentServicePartNumber__c;
                }
                
                Asset rmaAsset = assetMap.get(rmaToProcess.rmaDiskShelfAsset__c);
                
                // added by Exfort for TS-7109
                if (rmaAsset != null){
                    rmaComponentDataFlowForParts(component,rmaToProcess,rmaAsset.Account.Id,rmaAsset.Id);
                }                
            }
            
            else if(rmaToProcess.rmaSelection__c =='Flat List')
            {
                if(rmaToProcess.rmaSrFlatList__c != null)
                {
                    SR_Meta_Data__c srMetaData = srMetaDataMapById.get(rmaToProcess.rmaSrFlatList__c); 
                    rmaToProcess.rmaComponent__c =  srMetaData.srType__c;
                    rmaPart = EOAPartSubstitution(srMetaData.srPart__c, rmaToProcess);
                    determinePartsFromFlash(rmaPart,rmaToProcess,srMetaData);
                    assignComponentFlag(srMetaData,rmaToProcess);
                    
                    if(rmaPart != srMetaData.srPart__c)
                    {
                        rmaToProcess.rmaSubstitutionPart__c = srMetaData.srPart__c + ' <'  + rmaPart + '>';
                    }
                    else
                    {
                        rmaToProcess.rmaSubstitutionPart__c = srMetaData.srPart__c;
                    }
                    
                    //Flat List can be DiskShelf or Case Based Asset, new component show be created based on the selection
                    string rmaAssetId = null;
                    string rmaAccountId = null;
                    if(rmaToProcess.rmaDiskShelfAsset__c == null)
                    {
                        Case caseAsset = caseMap.get(rmaToProcess.rmaCaseNumber__c);
                        rmaAssetId = caseAsset.AssetId;
                        rmaAccountId = caseAsset.Asset.Account.Id;
                    }
                    else
                    {
                        Asset rmaAsset = assetMap.get(rmaToProcess.rmaDiskShelfAsset__c);
                        rmaAssetId = rmaAsset.Id;
                        rmaAccountId =  rmaAsset.Account.Id;
                    }
                    
                    //create a new component for Flat List when RMA status move out of Draft
                    Component__c component = null;
                    if(rmaToProcess.rmaStatus__c == 'Draft')
                    {
                        rmaToProcess.rmaComponentV2__c = null;
                    }
                    else if(rmaToProcess.rmaComponentV2__c == null && rmaToProcess.rmaStatus__c == 'Open')
                    {
                        component = new Component__c();
                        component.componentCreatedFromInformation__c = 'Added from ' + rmaToProcess.Name + ' for Flat List';
                        component.componentAccountId__c = rmaAccountId;
                        component.componentAsset__c = rmaAssetId;
                        component.componentServicePartNumber__c = rmaPart;
                        component.componentType__c = srMetaData.srType__c;
                        component.componentDescription__c = srMetaData.srDescription__c;
                        component.componentState__c ='Shipped';
                        component.Sub_State__c = 'Unknown';
                    }
                    else if(rmaToProcess.rmaStatus__c != null)
                    {
                        //Once the rma moved out of Draft -> new component is created and assigned to rmaComponentV2__c
                        component = componentMap.get(rmaToProcess.rmaComponentV2__c);
                    }
                    else
                    {
                        rmaToProcess.rmaComponentV2__c = null;
                    }
                    
                    system.debug('Component Parameter ++++++>'+component);
                    system.debug('rmaToProcess Parameter ++++++>'+rmaToProcess);
                    system.debug('rmaAccountId Parameter ++++++>'+rmaAccountId);
                    system.debug('rmaAssetId Parameter ++++++>'+rmaAssetId);
                    rmaComponentDataFlowForParts(component,rmaToProcess,rmaAccountId,rmaAssetId);
                }
                else
                {
                    rmaToProcess.addError('Choose SR Part from Flat List. If "Specified Asset Only" option is selected, please provide a value for "Disk Shelf Asset"');
                    processedStatus = 'Failed';
                }
            }
            else if(rmaToProcess.rmaSelection__c =='Asset') 
            {
                rmaPart = EOAPartSubstitution(rmaToProcess.rmaAssetProductCode__c, rmaToProcess);
                rmaToProcess.rmaPart__c = 'SYS: (' + rmaPart + ')';
                rmaToProcess.rmaPartNumber__c =  rmaPart;
                rmaToProcess.rmaComponent__c =  'SYS (complete system)';
                rmaToProcess.rmaComponentV2__c =  null;
                
                
                if(rmaPart != rmaToProcess.rmaAssetProductCode__c)
                {
                    rmaToProcess.rmaSubstitutionPart__c = rmaToProcess.rmaAssetProductCode__c + ' <'  + rmaPart + '>';
                }
                else
                {
                    rmaToProcess.rmaSubstitutionPart__c = rmaToProcess.rmaAssetProductCode__c;
                }
                
                rmaComponentDataFlowForFullAssetRMA(rmaToProcess);
            }
            else
            {
                rmaToProcess.rmaPart__c = null;
                rmaToProcess.rmaPartNumber__c =  null;
                rmaToProcess.rmaComponent__c =  null;
                rmaToProcess.rmaComponentV2__c =  null;
            }
        }
        else
        {
            rmaToProcess.addError('Choose Asset (Full RMA) or Component for RMA');
            processedStatus = 'Failed';
        }
        
        return processedStatus;
    }
    
    public static void rmaComponentDataFlowForParts(Component__c component,RMAv2__c rmaToProcess,string rmaAccountId,string rmaAssetId)
    {
        
        if(rmaToProcess.rmaPartNumber__c != null && rmaToProcess.rmaPartNumber__c.startsWith('SR-'))
        {
            // rmaToProcess.rmaOutgoingShipmentStatus__c != null Added by Exafort for TS-10344
            if(rmaToProcess.rmaOutgoingShipmentStatus__c != null && rmaToProcess.rmaStatus__c == 'Open' && !rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('CLOSED-10: Delivered') && !rmaToProcess.rmaRetShip2Status__c.startsWith('CLOSED-10: Delivered'))
            {
                if(component.componentState__c == null)
                    component.componentState__c = '';
                
                if(component.componentState__c == 'Shipped' && component.Sub_State__c == 'RMA in Progress' && rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('OPEN-10'))
                {
                    component.componentException__c ='RMA is already created for a given component';
                }  
                else if(!component.componentState__c.startsWith('Shipped'))
                {
                    component.componentException__c ='RMA initiated on component not shipped to the customer';
                }
                else if(component.componentAccountId__c != rmaAccountId)
                {
                    component.componentException__c = 'RMA initiated for component not belonging to the account identified on the RMA';
                }
                
                component.componentState__c ='Shipped';
                component.Sub_State__c = 'RMA in Progress';
                
                upsertComponentMap.put(rmaToProcess.Name,component);
                
            }
            
            // rmaToProcess.rmaOutgoingShipmentStatus__c != null Added by Exafort for TS-10344
            if(rmaToProcess.rmaOutgoingShipmentStatus__c != null && rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('CLOSED-10: Delivered')  && rmaToProcess.rmaIsComponentCreated__c == false && !rmaToProcess.rmaPartNumber__c.toUpperCase().contains('CHASSIS'))
            {
                rmaToProcess.rmaIsComponentCreated__c = true;
                
                // toLowerCase() Added by Exafort for SFDC-1260
                SR_Meta_Data__c srMetaData;
                if(srMetaDataMap.size() > 0 && rmaToProcess.rmaFulfilledPartNumber__c != null){
                    srMetaData = srMetaDataMap.get(rmaToProcess.rmaFulfilledPartNumber__c.toLowerCase());
                }
                system.debug('srMetaData : ' + srMetaData);
                
                component__c newRMAcomponent = new component__c();
                newRMAcomponent.componentAccountId__c = rmaAccountId;
                
                if(rmaToProcess.rmaSelection__c != 'Spares or Upgrades')
                {
                    newRMAcomponent.componentAsset__c = rmaAssetId;
                }
                
                newRMAcomponent.ComponentCreatedFromInformation__c = 'Added from ' + rmaToProcess.Name + ' for FulFilledPart';
                newRMAcomponent.componentState__c ='Shipped';
                newRMAcomponent.Sub_State__c = 'Unknown';
                newRMAcomponent.componentComponentSN__c = rmaToProcess.rmaOutgoingShipmentPartSn__c;
                newRMAcomponent.componentServicePartNumber__c = rmaToProcess.rmaFulfilledPartNumber__c;
                
                if(srMetaData != null)
                {
                    newRMAcomponent.SR_MetaData__c = srMetaData.Id;
                    newRMAcomponent.componentType__c = srMetaData.srType__c;
                    newRMAcomponent.componentDescription__c = srMetaData.srDescription__c;
                }
                
                /*if(rmaToProcess.rmaPartNumber__c.toUpperCase().contains('CHASSIS') && rmaToProcess.rmaOutgoingShipmentPartSn__c !=null && rmaToProcess.rmaSelection__c != 'Spares or Upgrades')
{
Asset assetNew = assetsChassisCloneMap.get(rmaToProcess.Name);
newRMAcomponent.componentAsset__c = assetNew.Id;

if(componentMapByAssetId.containsKey(rmaToProcess.rmaAssetId__c))
{
for(Component__c arrayComponent : componentMapByAssetId.get(rmaToProcess.rmaAssetId__c))
{
if(arrayComponent.Id != component.Id)
{
arrayComponent.ComponentCreatedFromInformation__c = 'Top Level Array changed from ' + arrayComponent.componentAssetName__c;
arrayComponent.componentAsset__c = assetNew.Id;
arrayComponent.componentState__c ='Shipped';
arrayComponent.Sub_State__c = 'Unknown';
upsertComponentMap.put(arrayComponent.Id,arrayComponent);
}
else
{
arrayComponent.ComponentCreatedFromInformation__c = 'Unchanged Top Level Array'; 
}
}
}
}*/
                
                upsertComponentMap.put(rmaToProcess.Name + ' NewComponent',newRMAcomponent);
                
                if(rmaToProcess.rmaRetShip2Status__c.startsWith('N/A-10: No part to ship for this RMA Type'))
                {
                    component.componentAccountId__c = null;
                    component.componentState__c ='Disposed';
                    component.ComponentCreatedFromInformation__c = null;
                    component.Sub_State__c = null;
                    upsertComponentMap.put(rmaToProcess.Name,component);
                    
                }
                
            }
            if(rmaToProcess.rmaPartNumber__c.toUpperCase().contains('CHASSIS') && rmaToProcess.rmaOutgoingShipmentAfterShipStatus__c == 'picked up' && rmaToProcess.rmaIsComponentCreated__c == false){
                rmaToProcess.rmaIsComponentCreated__c = true;
                
                // toLowerCase() Added by Exafort for SFDC-1260
                SR_Meta_Data__c srMetaData;
                if(srMetaDataMap.size() > 0 && rmaToProcess.rmaFulfilledPartNumber__c != null){
                    srMetaData = srMetaDataMap.get(rmaToProcess.rmaFulfilledPartNumber__c.toLowerCase());
                }
                
                component__c newRMAcomponent = new component__c();
                newRMAcomponent.componentAccountId__c = rmaAccountId;
                
                if(rmaToProcess.rmaSelection__c != 'Spares or Upgrades')
                {
                    newRMAcomponent.componentAsset__c = rmaAssetId;
                }
                
                newRMAcomponent.ComponentCreatedFromInformation__c = 'Added from ' + rmaToProcess.Name + ' for FulFilledPart';
                newRMAcomponent.componentState__c ='Shipped';
                newRMAcomponent.Sub_State__c = 'Unknown';
                newRMAcomponent.componentComponentSN__c = rmaToProcess.rmaOutgoingShipmentPartSn__c;
                newRMAcomponent.componentServicePartNumber__c = rmaToProcess.rmaFulfilledPartNumber__c;
                
                if(srMetaData != null)
                {
                    newRMAcomponent.SR_MetaData__c = srMetaData.Id;
                    newRMAcomponent.componentType__c = srMetaData.srType__c;
                    newRMAcomponent.componentDescription__c = srMetaData.srDescription__c;
                }
                
                if(rmaToProcess.rmaPartNumber__c.toUpperCase().contains('CHASSIS') && rmaToProcess.rmaOutgoingShipmentPartSn__c !=null && rmaToProcess.rmaSelection__c != 'Spares or Upgrades' && rmaToProcess.rmaOutgoingShipmentAfterShipStatus__c == 'picked up'){
                    
                    Asset assetNew = assetsChassisCloneMap.get(rmaToProcess.Name);
                    newRMAcomponent.componentAsset__c = assetNew.Id;
                    
                    if(componentMapByAssetId.containsKey(rmaToProcess.rmaAssetId__c))
                    {
                        for(Component__c arrayComponent : componentMapByAssetId.get(rmaToProcess.rmaAssetId__c))
                        {
                            if(arrayComponent.Id != component.Id)
                            {
                                arrayComponent.ComponentCreatedFromInformation__c = 'Top Level Array changed from ' + arrayComponent.componentAssetName__c;
                                arrayComponent.componentAsset__c = assetNew.Id;
                                arrayComponent.componentState__c ='Shipped';
                                arrayComponent.Sub_State__c = 'Unknown';
                                upsertComponentMap.put(arrayComponent.Id,arrayComponent);
                            }
                            else
                            {
                                arrayComponent.ComponentCreatedFromInformation__c = 'Unchanged Top Level Array'; 
                            }
                        }
                    }
                    
                    upsertComponentMap.put(rmaToProcess.Name + ' NewComponent',newRMAcomponent);
                }
            }
            
            
            if(rmaToProcess.rmaRetShip2Status__c != null && rmaToProcess.rmaRetShip2Status__c.startsWith('CLOSED-10: Delivered'))
            {
                component.componentAccountId__c = null;
                if(rmaToProcess.rmaCustomerFaRequired__c == true)
                {
                    component.componentState__c ='Returned for FA';
                    component.Sub_State__c = null;
                    component.ComponentCreatedFromInformation__c = null;
                }
                else
                {
                    component.componentState__c ='Returned';
                    component.Sub_State__c = null;
                    component.ComponentCreatedFromInformation__c = null;
                }
                upsertComponentMap.put(rmaToProcess.Name,component);
            }
            
            if(rmaToProcess.rmaStatus__c == 'Canceled' && rmaToProcess.rmaIsComponentStatusReset__c == false)
            {
                rmaToProcess.rmaIsComponentStatusReset__c = true;
                component.componentState__c ='Shipment';
                component.Sub_State__c = 'Unknown';
                component.ComponentCreatedFromInformation__c = null;
                upsertComponentMap.put(rmaToProcess.Name,component);
            }
            
            
        }
    }
    
    public static void rmaComponentDataFlowForFullAssetRMA(RMAv2__c rmaToProcess)
    {
        if(rmaToProcess.rmaRetShip2Status__c == 'CLOSED-10: Delivered')
        {
            if(componentMapByAssetId.containsKey(rmaToProcess.rmaAssetId__c))
            {
                system.debug('++++++ Record In ++++++' + componentMapByAssetId.size());
                for(Component__c arrayComponent : componentMapByAssetId.get(rmaToProcess.rmaAssetId__c))
                {
                    arrayComponent.componentState__c ='Returned';
                    arrayComponent.Sub_State__c = null;
                    arrayComponent.ComponentCreatedFromInformation__c = null;
                    upsertComponentMap.put(arrayComponent.Id,arrayComponent);
                }
            }
        }
    }
    
    public static Asset rmaCloneAssetForChassis(Id AssetId,string rmaOutgoingShipmentPartSn,  RMAv2__c rmaTogo)
    {
        string oldAssetSN;
        String soql = UtilsGetAllFieldsFromAnObject.getCreatableFieldsSOQL('asset','id=\''+AssetId+'\'');
        system.debug('soql ++ --> ' + soql);
        Asset assetOld = (Asset)Database.query(soql);
        //Clear ASUP Fields
        //assetOld.lastAsupUrl__c = null;
        assetOld.Autosupport_Last_Received__c = null;
        assetOld.Nimble_Version__c = null;
        assetOld.System_Name__c = null;
        assetOld.Mgmt_IP__c = null;
        assetOld.Unused_Res_GB__c = null;
        assetOld.Free_Space_GB__c = null;
        assetOld.System_Capacity_GB__c = null;
        //assetOld.System_Capacity_Percentage__c = null;
        assetOld.Volume_Usage_MB__c = null;
        assetOld.Primary_Comp__c = null;
        assetOld.Snapshot_Usage_MB__c = null;
        assetOld.Backup_Dedup__c = null;
        assetOld.InstallDate = null;
        assetOld.assetReplaceArray__c = assetOld.Name;
        assetOld.lastAsupDirAccountName__c = null;
        assetOld.lastAsupDirTimestamp__c = null;
        assetOld.lastAsupDirArraySn__c= null;
        
        
        oldAssetSN = assetOld.Name;
        assetOld.Name = rmaOutgoingShipmentPartSn;
        
        DateTime outshipDateTime;
        Date outshipDateTimeShipped;
        if(rmaTogo.rmaOutShipDateTimeShipped__c != null){
            outshipDateTime = rmaTogo.rmaOutShipDateTimeShipped__c;
            outshipDateTimeShipped = Date.newInstance(outshipDateTime.year(), outshipDateTime.month(), outshipDateTime.day());
        }
        else{
            outshipDateTimeShipped = null;
        }
        
        assetOld.Ship_Date__c = outshipDateTimeShipped;
        assetOld.Description = '['+rmaOutgoingShipmentPartSn+'] shipped to replace [' +oldAssetSN+'] under ['+rmaTogo.Name+']';
        assetOld.SerialNumber = rmaOutgoingShipmentPartSn;
        //assetOld.InstallDate = null;
        //assetOld.lastAsupDirAccountName__c = null;
        //assetOld.lastAsupDirTimestamp__c = null;
        /*assetOld.Autosupport_Last_Received__c = null;
assetOld.System_Capacity_GB__c = null;
assetOld.Nimble_Version__c = null;
assetOld.Free_Space_GB__c = null;
assetOld.System_Name__c = null;
assetOld.Volume_Usage_MB__c = null;
assetOld.Mgmt_IP__c = null;
assetOld.Primary_Comp__c = null;
assetOld.Unused_Res_GB__c = null;
assetOld.Snapshot_Usage_MB__c = null;
assetOld.Backup_Dedup__c = null;
assetOld.lastAsupDirArraySn__c= null;*/
        
        Asset assetNew = assetOld.clone(false, true);
        
        Asset processingAssetQuery = (Asset)Database.query(soql);
        processingAssetQuery.Description = '['+rmaOutgoingShipmentPartSn+'] shipped to replace [' +oldAssetSN+'] under ['+rmaTogo.Name+']';
        
        processingAsset.add(processingAssetQuery);
        
        return assetNew;
    }
    
    public static void rmaSetAutomationFields(RMAv2__c rmaToProcess)
    {
        
        //Set Status Fields
        if(rmaToProcess.rmaStatus__c == null && rmaToProcess.rmaOutgoingShipmentStatus__c == null)
        {
            rmaToProcess.rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order';
        }
        
        if(rmaToProcess.rmaStatus__c == null && rmaToProcess.rmaReturnShipmentStatus__c == null)
        {
            rmaToProcess.rmaReturnShipmentStatus__c = 'DRAFT-10: Waiting to order';
        }
        
        if(rmaToProcess.rmaStatus__c == null && rmaToProcess.rmaRetShip2Status__c == null)
        {
            rmaToProcess.rmaRetShip2Status__c = 'DRAFT-10: Waiting to order';   
        }
        
        if(rmaToProcess.rmaStatus__c == null && rmaToProcess.rmashi__c== null && rmaToProcess.rmaTransmitRmaShisWithOrder__c==null)
        {
            
            string accountRmaShi = null;
            string assetRmaShi = null;
            if(rmaToProcess.rmaDiskShelfAsset__c == null)
            {
                Case caseAsset = caseMap.get(rmaToProcess.rmaCaseNumber__c);
                if(caseAsset != null){ // added by exafort for TS-7109
                    accountRmaShi = caseAsset.Asset.Account.accountRmaShi__c;
                    assetRmaShi = caseAsset.Asset.assetRmaShi__c;   
                }
            }
            else
            {
                Asset rmaAsset = assetMap.get(rmaToProcess.rmaDiskShelfAsset__c);
                accountRmaShi = rmaAsset.Account.accountRmaShi__c;
                assetRmaShi =  rmaAsset.assetRmaShi__c;
            }
            
            
            //Set RMA SHI Fields
            if(accountRmaShi != null && assetRmaShi  !=null)
            {
                rmaToProcess.rmashi__c =  accountRmaShi+ '\n\r' + assetRmaShi + '\n\r' ;
                rmaToProcess.rmaTransmitRmaShisWithOrder__c = 'Account RMA SHI;Asset RMA SHI;RMA SHI';
            }
            else if(accountRmaShi!=null)
            {
                rmaToProcess.rmashi__c = accountRmaShi + '\n\r';
                rmaToProcess.rmaTransmitRmaShisWithOrder__c = 'Account RMA SHI';
            }
            else if(assetRmaShi != null)
            {
                rmaToProcess.rmashi__c =  assetRmaShi + '\n\r';
                rmaToProcess.rmaTransmitRmaShisWithOrder__c = 'Asset RMA SHI';
            }
            else
            {
                rmaToProcess.rmashi__c = null;
                rmaToProcess.rmaTransmitRmaShisWithOrder__c = 'No SHI';
            }
        }
        
    }
    
    public static string rmaVerifyCountryAndPostalCode(RMAv2__c rmaToProcess)
    {
        // #############################################
        // BEGIN LOGIC TO VERIFY COUNTRY AND POSTAL CODE
        // #############################################
        
        // Throw error if Address Book is null/blank
        // 
        if (rmaToProcess.rmaAddressBook__c == null && rmaToProcess.rmaShipmentAddressSelector__c == null)
        {rmaToProcess.rmaAddressBook__c.addError('You must enter a value');
         return '';
        }
        
        if(rmaToProcess.rmaOverrideShipmentStreet1__c == null &&  rmaToProcess.rmaOverrideShipmentStreet2__c == null &&  rmaToProcess.rmaOverrideShipmentCity__c == null &&  rmaToProcess.rmaOverrideShipmentState__c == null && rmaToProcess.rmaOverrideShipmentCountry__c == null &&  rmaToProcess.rmaOverrideShipmentPostalCode__c == null && rmaToProcess.rmaAddOverriddenAddressToAddressBook__c == true)
        {
            rmaToProcess.rmaAddOverriddenAddressToAddressBook__c = false;
        }
        
        // Throw error if Shipment Country is null/blank
        // 
        if (rmaToProcess.rmaShipmentCountry__c == null)
        {rmaToProcess.rmaShipmentCountry__c.addError('Based on your address selections, the "Shipment Country" will be blank.  This field cannot be blank.  Override it if needed to provide a valid value.');
         system.debug('DEBUG: Found null Shipment Country');
         return '';
        }
        
        // Remove any two-letter country codes at the end of the Shipment Country
        
        String soqlCountry = rmaToProcess.rmaShipmentCountry__c;
        soqlCountry = soqlCountry.replaceAll(' \\([A-Z]{2}\\)$', '');
        
        //Lookup to NBD/ND Depot - State
        String soqlState = rmaToProcess.rmaShipmentState__c;
        
        
        // Throw error if Shipment Postal Code is null/blank
        // Added by Exafort for TS-7109
        String loggedUserName = UserInfo.getName();
        system.debug('loggedUserName +++++++++++++ ' + loggedUserName);
        String loggedUserId = UserInfo.getUserId();
        system.debug('loggedUserId +++++++++++++ ' + loggedUserId);
        
       /*if(loggedUserId != '00580000003xTOlAAM'){
            if (rmaToProcess.rmaShipmentPostalCode__c == null)
            {rmaToProcess.rmaShipmentPostalCode__c.addError('Based on your address selections, the "Shipment Postal Code" will be blank.  This field cannot be blank.  Override it if needed to provide a valid value.');
             return '';
            }
        }  */  
             
        //Added by exafort for the ticket TS-10235 restrict the validation for automation users
        if((!UserInfo.getUserName().contains(System.Label.Bypass_RMA_Validation_for_this_User)) && (!UserInfo.getUserName().contains(System.Label.Bypass_RMA_Validation_for_User_Order_Admin)) &&
           (!UserInfo.getUserName().contains(System.Label.Bypass_RMA_Validation_for_User_SourceSupport_Montas)) && (!UserInfo.getUserName().contains(System.Label.Bypass_RMA_Validation_for_Informatica_SFDC_User)))
        {
            if (rmaToProcess.rmaShipmentPostalCode__c == null)
            {rmaToProcess.rmaShipmentPostalCode__c.addError('Based on your address selections, the "Shipment Postal Code" will be blank.  This field cannot be blank.  Override it if needed to provide a valid value.');
             return '';
            }
        }          
        //End of TS-10235
        
        // Convert the Shipment Postal Code to all uppercase
        
        String soqlPostalCode = rmaToProcess.rmaShipmentPostalCode__c;
        // soqlPostalCode        = soqlPostalCode.deleteWhiteSpace();   // NOTE: Removed so UK format requirements could be enforced
        if(soqlPostalCode != null) // Added by exafort for TS-7109
            soqlPostalCode        = soqlPostalCode.toUpperCase();
        
        // Prepare postal code patterns for known countries in which there are 4-hour depots
        // United Kingdom postal code formats were obtained from the following two web pages:
        //   Wikipedia page:      http://en.wikipedia.org/wiki/Postcodes_in_the_United_Kingdom
        //   UK standard BS7666:  http://webarchive.nationalarchives.gov.uk/20101126012154/http://www.cabinetoffice.gov.uk/govtalk/schemasstandards/e-gif/datastandards/address/postcode.aspx
        
        // Ireland does not currently use country-wide postal codes, but will be rolling them out in 2015 per the following article:
        // http://www.irishtimes.com/news/ireland/irish-news/every-address-to-have-postcode-by-2015-1.1553971
        //
        // They plan on adopting the format "A99 A9AA" where the first three characters indicate a geographic area.  Based on
        // how Flash has sometimes used only part of a postal code in other countries, I'm guessing they will only use
        // the first three characters to do mappings for Ireland.  If this changes, Ireland's pattern and mappings will need to change.
        //
        // Because Ireland has not yet rolled out country-wide postal codes, the Ireland specific code (later in this trigger) manually
        // sets the SOQL postal code to "A99 A9AA", which is a valid format.  The "A99" part will be stripped out for searching
        // the mappings.  A dummy 4-hour mapping was built for Ireland + A99, and this is the one the trigger will find for 4-hour
        // Ireland RMAs.  Once Ireland rolls out its real postal codes, and we receive valid mappings from Flash for Ireland, the
        // real mappings should be loaded, the code that sets SOQL postal code to "A99 A9AA" should be removed, and the dummy
        // mapping for Ireland + A99 should be deleted.
        
        // United Arab Emirates does not have a postal code system, so we use a dummy postal code of "AAA" for it.
        
        //Check the incoming Country exist in Postal Code map 
        //
        if (postalCodeMap.containsKey(soqlCountry)) 
        {
            Matcher matcherPostalCode;
            
            //Based on the key(incoming country) get the list of values from Postal Code map
            List<PostalCode__c> lstPcRecord = postalCodeMap.get(soqlCountry);
            
            if(lstPcRecord.size() > 0)
            {
                //Ispassed boolean value - determine the the country has a valid Postal Code or not
                Boolean Ispassed = false;
                String errorPostalCodeMsg = '';
                //Loop through the lst record returned from postal code map
                //United kingdom records iterates 2 times
                //Rest of the country iterate 1 time in the following loop
                for(Integer i=0; i<lstPcRecord.size();i++)
                {
                    if(lstPcRecord[i].pcDummyPostalCode__c != null)
                        soqlPostalCode = lstPcRecord[i].pcDummyPostalCode__c;
                    if(loggedUserId != '00580000003xTOlAAM'){ // Added by Exafort for TS-7109
                        errorPostalCodeMsg = lstPcRecord[i].pcErrorMessage__c;
                    }
                    
                    //system.debug('loggedUserId +++++++++++++ 123' + loggedUserName);
                    system.debug('soqlPostalCode +++++++++++++++++ ' + soqlPostalCode);
                    system.debug('lstPcRecord[i].pcDummyPostalCode__c +++++++++++++++++ ' + lstPcRecord[i].pcDummyPostalCode__c);
                    system.debug('Country +++++++++++++++++ ' + lstPcRecord[i].pcCountry__c);
                    system.debug('errorPostalCodeMsg +++++++++++++++++ ' + errorPostalCodeMsg);
                    
                    Pattern patternPostalCode  = Pattern.compile(lstPcRecord[i].pcFormatInRegex__c);
                    if(patternPostalCode != null && soqlPostalCode != null) // Added by Exfort for TS-7109
                        matcherPostalCode = patternPostalCode.matcher(soqlPostalCode);
                    if (matcherPostalCode != null) // Added by Exfort for TS-7109
                        if (matcherPostalCode.matches())
                    {
                        soqlPostalCode = matcherPostalCode.group(1);
                        Ispassed = true;
                        break;
                    }
                }
                //When the country has a invalid Postal Code throws an error
                if(Ispassed == false)
                {
               /*    //Added By vishnu for TS-8554
                    if(!UserInfo.getUserName().containsIgnoreCase('cokeva')){
                        rmaToProcess.rmaShipmentPostalCode__c.addError(errorPostalCodeMsg);
                    }   
                    // End of TS-8554   */ 
                    
                    //Added new coditions by exafort for the ticket TS-10235 restrict the validation for automation users
                    if((!UserInfo.getUserName().containsIgnoreCase('cokeva')) &&
                       (!UserInfo.getUserName().contains(System.Label.Bypass_RMA_Validation_for_this_User)) && (!UserInfo.getUserName().contains(System.Label.Bypass_RMA_Validation_for_User_Order_Admin)) &&
                       (!UserInfo.getUserName().contains(System.Label.Bypass_RMA_Validation_for_User_SourceSupport_Montas)) && (!UserInfo.getUserName().contains(System.Label.Bypass_RMA_Validation_for_Informatica_SFDC_User))){
                           rmaToProcess.rmaShipmentPostalCode__c.addError(errorPostalCodeMsg);
                           
                       }    
                    // End of TS-10235 restrict the error message for automation users
                    return ''; 
                }
            }
        }
        
        return soqlPostalCode;
        
        // ###########################################
        // END LOGIC TO VERIFY COUNTRY AND POSTAL CODE
        // ###########################################
    }
    
    public static void rmaAssignHddAndSsdPartNumbers(RMAv2__c rmaToProcess)
    {
        // #################################################
        // BEGIN LOGIC TO DETERMINE HDD AND SSD PART NUMBERS
        // #################################################
        
        // Below is the map of possible keys to values.  The key is composite, and
        // consists of the following items.  Items are separated by underscores.
        //
        //   1. Component.  This is either 'HDD' or 'SSD'.
        //   2. Model.  This is a substring within the model values for the Component
        //      which is enough to uniquely identify exactly which Model
        //      value was selected.  Note this substring does not mean the
        //      key/value entry applies only to that model, but rather it applies
        //      to all models that use the same type of HDD or SSD.  The substring
        //      just has to be unique enough to identify which picklist Model
        //      value was selected.
        //   3. Serial number cutoff position.  This is either 'Before' or 'After'.
        //
        // The value is the text value, including SR part number, that will be
        // put into the Part field for that combination.
        
        
        String mapKeyComponent = '';
        String mapKeyModel     = '';
        
        if (rmaToProcess.rmaComponent__c.contains('HDD'))
        {mapKeyComponent = 'HDD';
         
         if (rmaToProcess.rmaModel__c.contains('210'))
         {mapKeyModel = '210';
         }
         else if (rmaToProcess.rmaModel__c.contains('H25'))
         {mapKeyModel = 'H25';
         }
         else if (rmaToProcess.rmaModel__c.contains('240'))
         {mapKeyModel = '240';
         }
         else if (rmaToProcess.rmaModel__c.contains('H45'))
         {mapKeyModel = 'H45';
         }
         else if (rmaToProcess.rmaModel__c.contains('260'))
         {mapKeyModel = '260';
         }
         else if (rmaToProcess.rmaModel__c.contains('H65'))
         {mapKeyModel = 'H65';
         }
         else if (rmaToProcess.rmaModel__c.contains('H85'))
         {mapKeyModel = 'H85';
         }
         else if (rmaToProcess.rmaModel__c.contains('H90T'))
         {mapKeyModel = 'H90T';
         }
         else if (rmaToProcess.rmaModel__c.contains('12T'))
         {mapKeyModel = '12T';
         }
         else if (rmaToProcess.rmaModel__c.contains('24T'))
         {mapKeyModel = '24T';
         }
         else if (rmaToProcess.rmaModel__c.contains('36T'))
         {mapKeyModel = '36T';
         }
         else if (rmaToProcess.rmaModel__c.contains('48T'))
         {mapKeyModel = '48T';
         }
         else if (rmaToProcess.rmaModel__c.contains('72T'))
         {mapKeyModel = '72T';
         }
        }
        
        if (rmaToProcess.rmaComponent__c.contains('SSD'))
        {mapKeyComponent = 'SSD';
         
         if (rmaToProcess.rmaModel__c.contains('210-X2'))
         {mapKeyModel = '210-X2';
         }
         else if (rmaToProcess.rmaModel__c.contains('210-X4'))
         {mapKeyModel = '210-X4';
         }
         else if (rmaToProcess.rmaModel__c.contains('H25'))
         {mapKeyModel = 'H25';
         }
         else if (rmaToProcess.rmaModel__c.contains('220-X4'))
         {mapKeyModel = '220-X4';
         }
         else if (rmaToProcess.rmaModel__c.contains('H45'))
         {mapKeyModel = 'H45';
         }
         else if (rmaToProcess.rmaModel__c.contains('220-X8'))
         {mapKeyModel = '220-X8';
         }
         else if (rmaToProcess.rmaModel__c.contains('H65'))
         {mapKeyModel = 'H65';
         }
         else if (rmaToProcess.rmaModel__c.contains('H85'))
         {mapKeyModel = 'H85';
         }
         else if (rmaToProcess.rmaModel__c.contains('H90T'))
         {mapKeyModel = 'H90T';
         }
         else if (rmaToProcess.rmaModel__c.contains('320F'))
         {mapKeyModel = '320F';
         }
         else if (rmaToProcess.rmaModel__c.contains('640F'))
         {mapKeyModel = '640F';
         }
         else if (rmaToProcess.rmaModel__c.contains('1200F'))
         {mapKeyModel = '1200F';
         }
         else if (rmaToProcess.rmaModel__c.contains('2400F'))
         {mapKeyModel = '2400F';
         }
         else if (rmaToProcess.rmaModel__c.contains('3200FS'))
         {mapKeyModel = '3200FS';
         }
         else if (rmaToProcess.rmaModel__c.contains('6400FS'))
         {mapKeyModel = '6400FS';
         }
         else if (rmaToProcess.rmaModel__c.contains('3200F'))
         {mapKeyModel = '3200F';
         }
         else if (rmaToProcess.rmaModel__c.contains('6400F'))
         {mapKeyModel = '6400F';
         }
         else if (rmaToProcess.rmaModel__c.contains('300GB'))
         {mapKeyModel = '300GB';
         }
         else if (rmaToProcess.rmaModel__c.contains('1600GB'))
         {mapKeyModel = '1600GB';
         }
         else if (rmaToProcess.rmaModel__c.contains('800GB'))
         {mapKeyModel = '800GB';
         }
         else if (rmaToProcess.rmaModel__c.contains('600GB'))
         {mapKeyModel = '600GB';
         }
        } 
        
        // Set the map key for whether the asset serial number
        // is before or after the cutoff
        
        Integer rmaAssetSnNumberOnly        = 1;
        String  mapKeyCutoffPosition        = 'Before';
        Pattern patternRmaAssetSnNumberOnly = Pattern.compile('.*?([0-9]{6})');
        Matcher matcherRmaAssetSnNumberOnly;
        
        // The rmaAssetSerialNumber__c field is a formula field that contains the serial
        // number of the Asset the RMA is for.  This can be either the Asset on the Case
        // (if the RMA is for a head unit), or the Disk Shelf Asset on the RMA itself
        // (if the RMA is for a disk shelf).
        
        matcherRmaAssetSnNumberOnly = patternRmaAssetSnNumberOnly.matcher(rmaToProcess.rmaAssetSerialNumber__c);
        
        if (matcherRmaAssetSnNumberOnly.matches())
        {rmaAssetSnNumberOnly = integer.valueof(matcherRmaAssetSnNumberOnly.group(1));
        }
        
        if (rmaAssetSnNumberOnly >= 105000)
        {mapKeyCutoffPosition = 'After';
        }
        else
        {mapKeyCutoffPosition = 'Before';
        }
        
        // Determine the part number for HDD and SSD components
        
        String mapKey = '';
        
        if ((mapKeyComponent == 'HDD') || (mapKeyComponent == 'SSD'))
        {mapKey = mapKeyComponent + '_' + mapKeyModel + '_' + mapKeyCutoffPosition;
         
         rmaToProcess.rmaPart__c = mapPartNumbers.get(mapKey);
        }
        
        // Set the order's Part Number.  This is just the part number only,
        // extracted from the other verbiage.
        
        String partNumberSubstring;
        
        partNumberSubstring = rmaToProcess.rmaPart__c.substringAfterLast('[');
        partNumberSubstring = partNumberSubstring.substringBeforeLast(']');
        
        if (partNumberSubstring.length() == 0)
        {partNumberSubstring = rmaToProcess.rmaPart__c.substringAfterLast('(');
         partNumberSubstring = partNumberSubstring.substringBeforeLast(')');
        }
        
        rmaToProcess.rmaPartNumber__c = partNumberSubstring;
        
        // ###############################################
        // END LOGIC TO DETERMINE HDD AND SSD PART NUMBERS
        // ###############################################
        
        
        
    }
    
    public static void rmaAssignProviderAndDepot(RMAv2__c rmaToProcess,String soqlPostalCode)
    {
        // ###########################################
        // BEGIN LOGIC TO DETERMINE PROVIDER AND DEPOT
        // ###########################################
        
        //Added by vishnu on 1st Feb 2019 for TS-5318 TS-5258
        String PartShipSLAValueForDepotCal;
        getSrMetaDataMap();
        // toLowerCase() Added by Exafort for SFDC-1260
        SR_Meta_Data__c SrMetaDataRec;
        if(rmaToProcess.rmaFailedPart__c != null && srMetaDataMap.size() > 0){
            SrMetaDataRec = srMetaDataMap.get(rmaToProcess.rmaFailedPart__c.toLowerCase());
        }
        system.debug('SrMetaDataRec --> ' + SrMetaDataRec);
        if(SrMetaDataRec != null){
            PartShipSLAValueForDepotCal =  SrMetaDataRec.srPartShipSLAOverride__c;           
        }else{
            System.debug('### srMetaDataMap is Null - rmaAssignProviderAndDepot method');
        }
        system.debug('### Part Ship SLA Value for Depot calcuation===>'+PartShipSLAValueForDepotCal);
        
        
        String soqlCountry = rmaToProcess.rmaShipmentCountry__c;
        soqlCountry = soqlCountry.replaceAll(' \\([A-Z]{2}\\)$', '');
        String soqlState = rmaToProcess.rmaShipmentState__c;
        //	Added by exafort for SFDC-556
        string assetSLA = caseIdWithAssetSLA.get(rmaToProcess.rmaCaseNumber__c);
        
        //	String NbdNdMapKey = '__' + soqlCountry + '__' + soqlState + '__';
        String NbdNdMapKey = getNbdDepotMapKey (soqlCountry, soqlState, null, assetSLA);
        
        //Logic to check the current State is available in depot          
        if(!depotMapNbdNd.containsKey(NbdNdMapKey))
        {
            //State depot not available - set the default state as 'N/A'
            //NbdNdMapKey = '__' + soqlCountry + '__N/A__';
            NbdNdMapKey = getNbdDepotMapKey (soqlCountry, null, null, assetSLA);
        }

		//	Special logic for Japan because there are multiple providers
        /* if(soqlCountry.toLowerCase() == 'japan'){
            if(assetSLA.contains('TSC:')){
                //	NbdNdMapKey = '__' + soqlCountry + '__' + 'N/A' + '__' + 'TSC' + '__';
                NbdNdMapKey = getNbdDepotMapKey (soqlCountry, null, 'TSC');
            }
            else{
                //	NbdNdMapKey = '__' + soqlCountry + '__' + 'N/A' + '__' + 'Flash' + '__';
                NbdNdMapKey = getNbdDepotMapKey (soqlCountry, null, 'Flash');
            }
        } */
        System.debug('NbdNdMapKey :' + NbdNdMapKey);
        //End of SFDC-556
        
        //system.debug('### Part Ship SLA Override Value ==>'+srMetaDataMap.get(rmaToProcess.rmaFailedPart__c).srPartShipSLAOverride__c);
        //Added by exafort(vishnu) to default service parts to NBD Delivery SLA TS-5318
        //Assigning NBD depot if the part SLA is overriden to NBD.
        if (depotMapNbdNd.containsKey(NbdNdMapKey) && PartShipSLAValueForDepotCal != null)
            //&& srMetaDataMap.get(rmaToProcess.rmaFailedPart__c).srPartShipSLAOverride__c != null)
            //&& rmaToProcess.rmaIsNBDOverriden__c ==  true && rmaToProcess.rmaShipmentSla__c == 'NBD'  
            //&& srMetaDataMap.get(rmaToProcess.rmaPartNumber__c).srPartShipSLAOverride__c != null
        {
            System.debug('##### ===> Inside NBD calculation');
            depotMapNbdNd__c mapNbdNd = depotMapNbdNd.get(NbdNdMapKey);
            rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = mapNbdNd.depotMapNbdNd_NdDepot__r.depotProvider__c;
            rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = mapNbdNd.depotMapNbdNd_NdDepot__r.Name;
            rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'N/A';
        }
        
        if (rmaToProcess.rmaType__c == 'Advance replacement'  && (rmaToProcess.rmaPart__c.contains('[SR') || rmaToProcess.rmaPart__c == '(null)' || rmaToProcess.rmaPart__c == '(No SR Part)') && rmaToProcess.PachinkoCaseType__c != 'ssdwearlevelhigh' && srMetaDataShippingProvider != 'Shipping and Receiving')
        {// Old logic prior to onsite service changes
            //  if (rmaToProcess.rmaShipmentSla__c.contains('4-Hour'))
            
            // New logic for onsite service changes
            //Commented Depot Distance Miles for Nearby Depot Calculation based update on rma4HourDepotDistanceMiles__c field Added on 21st Oct 2016
            //rmaToProcess.rma4HourDepotDistanceMiles__c = null;
            if (rmaToProcess.rmaAssetSla__c.contains('4-Hour') || rmaToProcess.rmaUplift__c.contains('4-Hour') || rmaToProcess.rmaUplift__c.contains('Scheduled') || rmaToProcess.rmaAssetSla__c.contains('2') || rmaToProcess.rmaUplift__c.contains('2'))
            {
                /**
* No need for these calculations as they are done as part of Geocode project
* */
                /*                String tempKeyPattern = '__' + soqlCountry + '__' + soqlPostalCode + '__';

System.debug('tempKeyPattern = ' + tempKeyPattern);
if (depotMap4Hour.containsKey(tempKeyPattern))
{
//Commented below lines to update from Near by Depot Calculation - Added on 21st Oct 2016
depotMap4Hour__c map4Hour = depotMap4Hour.get(tempKeyPattern);  
rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = map4Hour.depotMap4Hour_4HourDepot__r.depotProvider__c;
rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = map4Hour.depotMap4Hour_4HourDepot__r.Name;
rmaToProcess.rma4HourDepotDistanceMiles__c            = map4Hour.depotMap4HourMiles__c;
rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'Yes';
}
else
{
System.debug('In NBD and ready to update the fields');
if (depotMapNbdNd.containsKey(NbdNdMapKey))
{
depotMapNbdNd__c mapNbdNd = depotMapNbdNd.get(NbdNdMapKey);
rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = mapNbdNd.depotMapNbdNd_NdDepot__r.depotProvider__c;
rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = mapNbdNd.depotMapNbdNd_NdDepot__r.Name;
rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'No';
}
else
{rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = 'Unknown';
rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = 'Unknown';
rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'Unknown';
}
}
*/
            }
            else if((assetMap.get(rmaToProcess.rmaDiskShelfAsset__c) != null && assetMap.get(rmaToProcess.rmaDiskShelfAsset__c).AccountId != null && assetMap.get(rmaToProcess.rmaDiskShelfAsset__c).Account.Name.Contains('H3C')) 
                    || (assetMap.get(rmaToProcess.rmaDiskShelfAsset__c) != null && assetMap.get(rmaToProcess.rmaDiskShelfAsset__c).AccountId != null && assetMap.get(rmaToProcess.rmaDiskShelfAsset__c).Account.Support_Provider__c != null && assetMap.get(rmaToProcess.rmaDiskShelfAsset__c).Account.Support_Provider__r.Name.Contains('H3C'))
                    || ((rmaToProcess.rmaCaseNumber__c != null && componentMap.containsKey(rmaToProcess.rmaCaseNumber__c ) ? caseMap.get(rmaToProcess.rmaCaseNumber__c).AssetId : null) != null && (rmaToProcess.rmaCaseNumber__c != null && componentMap.containsKey(rmaToProcess.rmaCaseNumber__c) ? caseMap.get(rmaToProcess.rmaCaseNumber__c).Asset.AccountId : null) != null && (rmaToProcess.rmaCaseNumber__c != null && componentMap.containsKey(rmaToProcess.rmaCaseNumber__c) ? caseMap.get(rmaToProcess.rmaCaseNumber__c).Asset.Account.Name : null) != null && (rmaToProcess.rmaCaseNumber__c != null && componentMap.containsKey(rmaToProcess.rmaCaseNumber__c) ? caseMap.get(rmaToProcess.rmaCaseNumber__c).Asset.Account.Name.Contains('H3C') : false))
                    || ((rmaToProcess.rmaCaseNumber__c != null && componentMap.containsKey(rmaToProcess.rmaCaseNumber__c ) ? caseMap.get(rmaToProcess.rmaCaseNumber__c).AssetId : null) != null && (rmaToProcess.rmaCaseNumber__c != null && componentMap.containsKey(rmaToProcess.rmaCaseNumber__c) ? caseMap.get(rmaToProcess.rmaCaseNumber__c).Asset.AccountId : null) != null && (rmaToProcess.rmaCaseNumber__c != null && componentMap.containsKey(rmaToProcess.rmaCaseNumber__c) ? caseMap.get(rmaToProcess.rmaCaseNumber__c).Asset.Account.Support_Provider__c : null) != null && (rmaToProcess.rmaCaseNumber__c != null && componentMap.containsKey(rmaToProcess.rmaCaseNumber__c) ? caseMap.get(rmaToProcess.rmaCaseNumber__c).Asset.Account.Support_Provider__r.Name.Contains('H3C') : false))){
                        
                        rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = 'Unknown';
                        rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = 'Unknown';
                        rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'Unknown';
                    }
            
            else
            {
                if (depotMapNbdNd.containsKey(NbdNdMapKey) && rmaToProcess.rmaShipmentSla__c == 'Next Day')
                {
                    depotMapNbdNd__c mapNbdNd = depotMapNbdNd.get(NbdNdMapKey);
                    rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = mapNbdNd.depotMapNbdNd_NdDepot__r.depotProvider__c;
                    rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = mapNbdNd.depotMapNbdNd_NdDepot__r.Name;
                    rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'N/A';
                }
                else if (depotMapNbdNd.containsKey(NbdNdMapKey))
                {
                    depotMapNbdNd__c mapNbdNd = depotMapNbdNd.get(NbdNdMapKey);   
                    rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = mapNbdNd.depotMapNbdNd_NbdDepot__r.depotProvider__c;
                    rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = mapNbdNd.depotMapNbdNd_NbdDepot__r.Name;
                    rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'N/A';
                }
                
                else
                {rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = 'Unknown';
                 rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = 'Unknown';
                 rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'Unknown';
                }
            }
            
        }
        //If rma Type 'Ship Only' then provider should be 'Shipping and Receiving'
        //Added on 20th July 2017 by exafort
        //rmaToProcess.rmaType__c == 'Ship Only'
        else if(rmaToProcess.rmaType__c == 'Advance replacement' && rmaToProcess.PachinkoCaseType__c != 'ssdwearlevelhigh' && srMetaDataShippingProvider == 'Shipping and Receiving'){
            rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = 'Shipping and Receiving';
            rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = 'SRV-NIMBLE';
            rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'N/A';
        }
        /*
* START - Set Order Provider and Order Depot for Full System RMA.
* */
        else if(rmaToProcess.rmaType__c == 'Advance replacement' && rmaToProcess.rmaFullAssetRMA__c == true){
            rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = 'HPE Order Management';
            rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = 'Shipped from Manufacturing';
            rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'N/A';
        }
        //Added on 18th Jan 2019 by exafort(vishnu) to default service parts to NBD Delivery SLA TS-5258
        else if(depotMapNbdNd.containsKey(NbdNdMapKey) && rmaToProcess.rmaType__c == 'Advance replacement' && rmaToProcess.PachinkoCaseType__c == 'ssdwearlevelhigh'){            
            depotMapNbdNd__c mapNbdNd = depotMapNbdNd.get(NbdNdMapKey);
            rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = mapNbdNd.depotMapNbdNd_NdDepot__r.depotProvider__c;
            rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = mapNbdNd.depotMapNbdNd_NdDepot__r.Name;
            rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'N/A';
        }
        else
        {
            system.debug('### Inside final else condition');
            rmaToProcess.rmaOutgoingShipmentOrderProvider__c      = 'Nimble';
            rmaToProcess.rmaOutgoingShipmentOrderDepot__c         = 'SRV-NIMBLE';
            rmaToProcess.rmaOutgoingShipmentOrder4HrDepotFound__c = 'N/A';
        }
        
        // #########################################
        // END LOGIC TO DETERMINE PROVIDER AND DEPOT
        // #########################################
        
    }
    
    public static void rmaSetStatusAndTimestamps(RMAv2__c rmaToProcess)
    {
        // ############################################
        // BEGIN LOGIC TO SET RMA STATUS AND TIMESTAMPS
        // ############################################

        // See if RMA Status should be Draft
        if (rmaToProcess.rmaOutgoingShipmentStatus__c != null &&(rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('DRAFT') ||
                                                                 (rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('N/A') && rmaToProcess.rmaReturnShipmentStatus__c.startsWith('DRAFT'))))
        {rmaToProcess.rmaStatus__c = 'Draft';
        }
        
        // See if RMA Status should be Open
        // rmaToProcess.rmaOutgoingShipmentStatus__c != 'CLOSED-10: Delivered') added by Exafort for SFDC-513
        else if ((rmaToProcess.rmaOutgoingShipmentStatus__c != null && rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('OPEN')                                             ||
                 rmaToProcess.rmaReturnShipmentStatus__c.startsWith('OPEN')                                               ||
                 (rmaToProcess.rmaRetShip2Status__c   != null && rmaToProcess.rmaRetShip2Status__c.startsWith('OPEN'))    ||
                 (rmaToProcess.rmaOnsiteTechStatus__c != null && rmaToProcess.rmaOnsiteTechStatus__c.startsWith('OPEN'))) && rmaToProcess.rmaOutgoingShipmentStatus__c != 'CLOSED-10: Delivered')
        {rmaToProcess.rmaStatus__c = 'Open';
         if (rmaToProcess.rmaDateTimeOpened__c == null)
         {rmaToProcess.rmaDateTimeOpened__c = System.now();
          string rmaRawOffset;
          string rmaDstOffset;
          if(rmaToProcess.rmaTimeZoneActualOffset__c != null && rmaToProcess.rmaTimeZoneDSTOffset__c != null && rmaToProcess.rmaDateTimeOpened__c != null){
              rmaRawOffset = rmaToProcess.rmaTimeZoneActualOffset__c.deleteWhitespace();
              rmaRawOffset = rmaRawOffset.substringBefore('(');
              rmaDstOffset = rmaToProcess.rmaTimeZoneDSTOffset__c.deleteWhitespace();
              rmaDstOffset = rmaDstOffset.substringBefore('(');
              if(rmaRawOffset != null && rmaDstOffset != null){
                  DateTime rmaUTCDate = rmaToProcess.rmaDateTimeOpened__c.addSeconds((integer.valueOf(rmaRawOffset) + integer.valueOf(rmaDstOffset)));
                  if(rmaUTCDate != null){
                      rmaToProcess.rmaDateTimeOpenedLocalTime__c = string.valueOf(DateTime.newInstance(rmaUTCDate.yearGmt(), rmaUTCDate.monthGmt(), rmaUTCDate.dayGmt(), rmaUTCDate.hourGmt(), rmaUTCDate.minuteGmt(), rmaUTCDate.secondGmt()).format('MM/dd/YYYY hh:mm a'));
                  }
              }
          }
         }
        }
        
        // See if RMA Status should be Closed
        else if ((rmaToProcess.rmaOutgoingShipmentStatus__c != null && ((rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('CLOSED') || rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('N/A'))                                       &&
                                                                       (rmaToProcess.rmaReturnShipmentStatus__c.startsWith('CLOSED')   || rmaToProcess.rmaReturnShipmentStatus__c.startsWith('N/A'))                                         &&
                                                                       (rmaToProcess.rmaRetShip2Status__c   != null && (rmaToProcess.rmaRetShip2Status__c.startsWith('CLOSED')   || rmaToProcess.rmaRetShip2Status__c.startsWith('N/A')))    &&
                                                                       (rmaToProcess.rmaOnsiteTechStatus__c != null && (rmaToProcess.rmaOnsiteTechStatus__c.startsWith('CLOSED') || rmaToProcess.rmaOnsiteTechStatus__c.startsWith('N/A')))))
                ||
                 // Added by Exafort for SFDC-513
                (rmaToProcess.rmaOutgoingShipmentStatus__c != null && rmaToProcess.China_Global_Account_RMA__c == True && rmaToProcess.rmaOutgoingShipmentStatus__c == 'CLOSED-10: Delivered'))
        {rmaToProcess.rmaStatus__c = 'Closed';
         if (rmaToProcess.rmaDateTimeClosed__c == null)
         {rmaToProcess.rmaDateTimeClosed__c = System.now();
         }
        }
        
        // See if RMA Status should be Canceled
        else if (rmaToProcess.rmaOutgoingShipmentStatus__c != null && ((rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('CLOSED') || rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('CANCELED') || rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('N/A'))                                 &&
                                                                       (rmaToProcess.rmaReturnShipmentStatus__c.startsWith('CLOSED')   || rmaToProcess.rmaReturnShipmentStatus__c.startsWith('CANCELED')   || rmaToProcess.rmaReturnShipmentStatus__c.startsWith('N/A'))                                   &&
                                                                       (rmaToProcess.rmaRetShip2Status__c   != null && (rmaToProcess.rmaRetShip2Status__c.startsWith('CLOSED')   || rmaToProcess.rmaRetShip2Status__c.startsWith('CANCELED')   || rmaToProcess.rmaRetShip2Status__c.startsWith('N/A')))    &&
                                                                       (rmaToProcess.rmaOnsiteTechStatus__c != null && (rmaToProcess.rmaOnsiteTechStatus__c.startsWith('CLOSED') || rmaToProcess.rmaOnsiteTechStatus__c.startsWith('CANCELED') || rmaToProcess.rmaOnsiteTechStatus__c.startsWith('N/A')))))
        {rmaToProcess.rmaStatus__c = 'Canceled';
         if (rmaToProcess.rmaDateTimeCanceled__c == null)
         {rmaToProcess.rmaDateTimeCanceled__c = System.now();
         }
        }
        
        // Set RMA Status to Open as a default if none of the above logic was invoked
        else
        {rmaToProcess.rmaStatus__c = 'Open';
         if (rmaToProcess.rmaDateTimeOpened__c == null)
         {rmaToProcess.rmaDateTimeOpened__c = System.now();
          string rmaRawOffset;
          string rmaDstOffset;
          if(rmaToProcess.rmaTimeZoneActualOffset__c != null && rmaToProcess.rmaTimeZoneDSTOffset__c != null && rmaToProcess.rmaDateTimeOpened__c != null){
              rmaRawOffset = rmaToProcess.rmaTimeZoneActualOffset__c.deleteWhitespace();
              rmaRawOffset = rmaRawOffset.substringBefore('(');
              rmaDstOffset = rmaToProcess.rmaTimeZoneDSTOffset__c.deleteWhitespace();
              rmaDstOffset = rmaDstOffset.substringBefore('(');
              
              if(rmaRawOffset != null && rmaDstOffset != null){
                  DateTime rmaUTCDate = rmaToProcess.rmaDateTimeOpened__c.addSeconds((integer.valueOf(rmaRawOffset) + integer.valueOf(rmaDstOffset)));
                  if(rmaUTCDate != null){
                      rmaToProcess.rmaDateTimeOpenedLocalTime__c = string.valueOf(DateTime.newInstance(rmaUTCDate.yearGmt(), rmaUTCDate.monthGmt(), rmaUTCDate.dayGmt(), rmaUTCDate.hourGmt(), rmaUTCDate.minuteGmt(), rmaUTCDate.secondGmt()).format('MM/dd/YYYY hh:mm a'));
                  }
              }
          }
         }
        }
        
        // ##########################################
        // END LOGIC TO SET RMA STATUS AND TIMESTAMPS
        // ##########################################
        
    }
    
    public static void rmaSetSLADueDateTimeValue(RMAv2__c rmaToProcess)
    {
        // ####################################################################################################################
        // Start LOGIC TO SET RMA SLA Due Date Time Value Calculations - Added on 14th November by Azarudeen
        // ####################################################################################################################
        try{
            if(rmaToProcess.rmaOutgoingShipmentStatus__c.contains('OPEN-10')){
                
                Set<String> middleEastCountries = new Set<String>{'Turkey', 'Israel', 'Iran', 'Saudi Arabia','United Arab Emirates','Iraq','Yemen','Qatar','Jordan','Kuwait','Oman','Bahrain','Tunisia','Cyprus'}; //Where Friday and saturday is weekend
                    
                    if(rmaToProcess.rmaUplift__c.contains('4') || rmaToProcess.rmaShipmentSla__c.contains('4')){
                        if(rmaToProcess.rmaDateTimeOpened__c != null){
                            //rmaToProcess.rmaSLADueDateTime__c = string.valueOf(rmaToProcess.rmaDateTimeOpened__c.addHours(4).format('MM-dd-yyyy HH:mm:ss'));
                            
                            string rmaRawOffset;
                            string rmaDstOffset;
                            if(rmaToProcess.rmaTimeZoneActualOffset__c != null && rmaToProcess.rmaTimeZoneDSTOffset__c != null && rmaToProcess.rmaDateTimeOpened__c != null){
                                rmaRawOffset = rmaToProcess.rmaTimeZoneActualOffset__c.deleteWhitespace();
                                rmaRawOffset = rmaRawOffset.substringBefore('(');
                                rmaDstOffset = rmaToProcess.rmaTimeZoneDSTOffset__c.deleteWhitespace();
                                rmaDstOffset = rmaDstOffset.substringBefore('(');
                                
                                DateTime rmaUTCDate = rmaToProcess.rmaDateTimeOpened__c.addSeconds((integer.valueOf(rmaRawOffset) + integer.valueOf(rmaDstOffset)));
                                rmaUTCDate = rmaUTCDate.addHours(4);
                                if(rmaUTCDate != null){
                                    rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(rmaUTCDate.yearGmt(), rmaUTCDate.monthGmt(), rmaUTCDate.dayGmt(), rmaUTCDate.hourGmt(), rmaUTCDate.minuteGmt(), rmaUTCDate.secondGmt()).format('MM-dd-yyyy HH:mm:ss'));
                                }
                            }
                            string year;
                            integer rmaRawOffsetConverted;
                            integer rmaDstOffsetConverted;
                            if(rmaToProcess.rmaTimeZoneActualOffset__c != null && rmaToProcess.rmaTimeZoneDSTOffset__c != null){
                                rmaRawOffset = rmaToProcess.rmaTimeZoneActualOffset__c.deleteWhitespace();
                                rmaRawOffset = rmaRawOffset.substringBefore('(');
                                rmaDstOffset = rmaToProcess.rmaTimeZoneDSTOffset__c.deleteWhitespace();
                                rmaDstOffset = rmaDstOffset.substringBefore('(');
                            }
                            if(rmaRawOffset != null){
                                rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                            }
                            if(rmaDstOffset != null){
                                rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                            }
                            //Ex SLA Due Date = 02-02-2017 03:29:51
                            
                            
                            system.debug('@@@ SLA DUE Date @@@ '+rmaToProcess.rmaSLADueDateTime__c);
                            if(rmaRawOffsetConverted != null && rmaDstOffsetConverted != null && rmaToProcess.rmaSLADueDateTime__c != null){
                                year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')),integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween(' ', ':')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween(':', ':')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringAfterLast(':'))).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                            }
                            //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = rmaToProcess.rmaSLADueDateTime__c;
                        }
                    }
                
                if(rmaToProcess.rmaUplift__c == 'Scheduled' && rmaToProcess.rmaDeliveryDateTime__c != null){
                    if(rmaToProcess.rmaRequestedDeliveryDateTime__c != null){
                        rmaToProcess.rmaSLADueDateTime__c = rmaToProcess.rmaRequestedDeliveryDateTime__c;
                        //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = rmaToProcess.rmaSLADueDateTime__c;
                        string year;
                        integer rmaRawOffsetConverted;
                        integer rmaDstOffsetConverted;
                        string rmaRawOffset;
                        string rmaDstOffset;
                        if(rmaToProcess.rmaTimeZoneActualOffset__c != null && rmaToProcess.rmaTimeZoneDSTOffset__c != null){
                            rmaRawOffset = rmaToProcess.rmaTimeZoneActualOffset__c.deleteWhitespace();
                            rmaRawOffset = rmaRawOffset.substringBefore('(');
                            rmaDstOffset = rmaToProcess.rmaTimeZoneDSTOffset__c.deleteWhitespace();
                            rmaDstOffset = rmaDstOffset.substringBefore('(');
                        }
                        if(rmaRawOffset != null){
                            rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                        }
                        if(rmaDstOffset != null){
                            rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                        }
                        //Ex SLA Due Date = 01-31-2017 10:00:00
                        
                        
                        system.debug('@@@ SLA DUE Date @@@ '+rmaToProcess.rmaSLADueDateTime__c);
                        if(rmaRawOffsetConverted != null && rmaDstOffsetConverted != null && rmaToProcess.rmaSLADueDateTime__c != null){
                            year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                            rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')),integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween(' ', ':')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween(':', ':')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringAfterLast(':'))).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                        }
                    }
                }
                if(rmaToProcess.rmaUplift__c.contains('Next Day') || rmaToProcess.rmaShipmentSla__c.contains('NBD')){
                    // getAssetLocalTimeAtSubmit(rma.rmaLatitude__c, rma.rmaLongitude__c);
                    DateTime currentDate = System.now();
                    string rmaRawOffset;
                    string rmaDstOffset;
                    if(rmaToProcess.rmaTimeZoneActualOffset__c != null && rmaToProcess.rmaTimeZoneDSTOffset__c != null){
                        rmaRawOffset = rmaToProcess.rmaTimeZoneActualOffset__c.deleteWhitespace();
                        rmaRawOffset = rmaRawOffset.substringBefore('(');
                        rmaDstOffset = rmaToProcess.rmaTimeZoneDSTOffset__c.deleteWhitespace();
                        rmaDstOffset = rmaDstOffset.substringBefore('(');
                        
                        DateTime assetUTCDate = currentDate.addSeconds((integer.valueOf(rmaRawOffset) + integer.valueOf(rmaDstOffset)));
                        
                        system.debug('Asset Date And Time  : '+assetUTCDate);
                        system.debug('Asset Date And Time Hour : '+assetUTCDate.hour());
                        system.debug('Asset Date And Time Hour in GMT : '+assetUTCDate.hourGmt());
                        system.debug('RMA Date and Time value '+rmaToProcess.rmaDateTimeOpened__c);
                        
                        String dayOfWeek=assetUTCDate.formatGmt('EEEE');
                        
                        System.debug('Day : ' + dayOfWeek);
                        if(Test.isRunningTest()){dayOfWeek = rmaDayofweek;}
                        string year;
                        integer rmaRawOffsetConverted;
                        integer rmaDstOffsetConverted;
                        if(assetUTCDate.hourGmt() < 16){
                            if(dayOfWeek == 'Monday' || dayOfWeek == 'Tuesday' || dayOfWeek == 'Wednesday' || dayOfWeek == 'Thursday' ){
                                //rmaToProcess.rmaSLADueDateTime__c = DateTime.newInstance(rmaToProcess.rmaDateTimeOpened__c.year(), rmaToProcess.rmaDateTimeOpened__c.month(), rmaToProcess.rmaDateTimeOpened__c.day(), 17, 0, 0);
                                system.debug('Asset UTCDate  '+assetUTCDate);
                                DateTime addDays = assetUTCDate.addDays(1);
                                system.debug('Asset UTCDate adding 1 days '+addDays);
                                
                                rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                if(rmaRawOffset != null){
                                    rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                }
                                if(rmaDstOffset != null){
                                    rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                }
                                rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                
                                system.debug('SLA Date Time if hour lesser than 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                System.debug('Shipment country: ' + rmaToProcess.rmaOverrideShipmentCountry__c);
                                System.debug('Day of the week value : ' + dayOfWeek);
                                if(dayOfWeek == 'Thursday' && middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                    system.debug('Asset UTCDate  '+assetUTCDate);
                                    DateTime addDays1 = assetUTCDate.addDays(3);
                                    system.debug('Asset UTCDate adding 3 days '+addDays1);
                                    rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays1.yearGmt(), addDays1.monthGmt(), addDays1.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                    //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                    system.debug('SLA Date Time if hour lesser than 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                    year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                    //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                    if(rmaRawOffset != null){
                                        rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                    }
                                    if(rmaDstOffset != null){
                                        rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                    }
                                    rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                }
                            }
                            else{
                                if(dayOfWeek == 'Friday' && !middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                    system.debug('assetUTCDate ---> '+assetUTCDate);
                                    DateTime addDays = assetUTCDate.addDays(3);
                                    system.debug('assetUTCDate after adding 3 days  ---> '+addDays);
                                    rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                    //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                    //rmaToProcess.rmaSLADueDateTime__c = string.valueOf(addDays.monthGmt())+'-'+string.valueOf(addDays.dayGmt())+'-'+string.valueOf(addDays.yearGmt())+' 17:00:00';
                                    system.debug('SLA Date Time if hour lesser than 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                    year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                    //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                    if(rmaRawOffset != null){
                                        rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                    }
                                    if(rmaDstOffset != null){
                                        rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                    }
                                    rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                }
                                if(dayOfWeek == 'Friday' && middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                    system.debug('assetUTCDate ---> '+assetUTCDate);
                                    DateTime addDays = assetUTCDate.addDays(2);
                                    system.debug('assetUTCDate after adding 2 days  ---> '+addDays);
                                    rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                    //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                    //rmaToProcess.rmaSLADueDateTime__c = string.valueOf(addDays.monthGmt())+'-'+string.valueOf(addDays.dayGmt())+'-'+string.valueOf(addDays.yearGmt())+' 17:00:00';
                                    system.debug('SLA Date Time if hour lesser than 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                    year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                    //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                    if(rmaRawOffset != null){
                                        rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                    }
                                    if(rmaDstOffset != null){
                                        rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                    }
                                    rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                }
                                if(dayOfWeek == 'Saturday' && !middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                    DateTime addDays = assetUTCDate.addDays(2);
                                    rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                    //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                    year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                    //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                    if(rmaRawOffset != null){
                                        rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                    }
                                    if(rmaDstOffset != null){
                                        rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                    }
                                    rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                }
                                if(dayOfWeek == 'Saturday' && middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                    DateTime addDays = assetUTCDate.addDays(1);
                                    rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                    //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                    year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                    //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                    if(rmaRawOffset != null){
                                        rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                    }
                                    if(rmaDstOffset != null){
                                        rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                    }
                                    rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                }
                                else if(dayOfWeek == 'Sunday'){
                                    DateTime addDays = assetUTCDate.addDays(1);
                                    rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                    //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                    year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                    //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                    if(rmaRawOffset != null){
                                        rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                    }
                                    if(rmaDstOffset != null){
                                        rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                    }
                                    rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                }
                            }
                        }
                        
                        else if(assetUTCDate.hourGmt() >= 16){
                            if(dayOfWeek == 'Monday' || dayOfWeek == 'Tuesday' || dayOfWeek == 'Wednesday'){
                                DateTime addDays = assetUTCDate.addDays(2);
                                system.debug('Added 2 days from DateTime Opnened '+addDays);
                                rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                //12-22-2016 17:00:00
                                //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.newInstanceGMT(2017, 1, 4, 17, 0, 0);
                                system.debug('SLA Date Time if hour greater than or equal 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                if(rmaRawOffset != null){
                                    rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                }
                                if(rmaDstOffset != null){
                                    rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                }
                                rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                
                                if(dayOfWeek == 'Wednesday' && middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                    DateTime addDays1 = assetUTCDate.addDays(4);
                                    system.debug('Added 2 days from DateTime Opnened '+addDays);
                                    rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays1.yearGmt(), addDays1.monthGmt(), addDays1.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                    //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                    system.debug('SLA Date Time if hour greater than or equal 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                    year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                    //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                    if(rmaRawOffset != null){
                                        rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                    }
                                    if(rmaDstOffset != null){
                                        rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                    }
                                    rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                }
                            }
                            else if(dayOfWeek == 'Thursday' && !middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                DateTime addDays = assetUTCDate.addDays(4);
                                system.debug('Added 2 days from DateTime Opnened '+addDays);
                                rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                if(rmaRawOffset != null){
                                    rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                }
                                if(rmaDstOffset != null){
                                    rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                }
                                rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                                
                                system.debug('SLA Date Time if hour greater than or equal 16 '+rmaToProcess.rmaSLADueDateTime__c);
                            }
                            else if(dayOfWeek == 'Thursday' && middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                DateTime addDays = assetUTCDate.addDays(3);
                                system.debug('Added 3 days from DateTime Opnened '+addDays);
                                rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                system.debug('SLA Date Time if hour greater than or equal 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                if(rmaRawOffset != null){
                                    rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                }
                                if(rmaDstOffset != null){
                                    rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                }
                                rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                            }
                            else if(dayOfWeek == 'Friday' && !middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                DateTime addDays = assetUTCDate.addDays(3);
                                system.debug('Added 3 days from DateTime Opnened '+addDays);
                                rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                system.debug('SLA Date Time if hour greater than or equal 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                if(rmaRawOffset != null){
                                    rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                }
                                if(rmaDstOffset != null){
                                    rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                }
                                rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                            }
                            else if(dayOfWeek == 'Friday' && middleEastCountries.contains(rmaToProcess.rmaOverrideShipmentCountry__c)){
                                DateTime addDays = assetUTCDate.addDays(2);
                                system.debug('Added 2 days from DateTime Opnened '+addDays);
                                rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                system.debug('SLA Date Time if hour greater than or equal 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                if(rmaRawOffset != null){
                                    rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                }
                                if(rmaDstOffset != null){
                                    rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                }
                                rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                            }
                            else if(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday'){
                                DateTime addDays = assetUTCDate.addDays(2);
                                system.debug('Added 2 days from DateTime Opnened '+addDays);
                                rmaToProcess.rmaSLADueDateTime__c = string.valueOf(DateTime.newInstance(addDays.yearGmt(), addDays.monthGmt(), addDays.dayGmt(), 17, 0, 0).format('MM-dd-yyyy HH:mm:ss'));
                                //rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = DateTime.parse(rmaToProcess.rmaSLADueDateTime__c);
                                system.debug('SLA Date Time if hour greater than or equal 16 '+rmaToProcess.rmaSLADueDateTime__c);
                                year = rmaToProcess.rmaSLADueDateTime__c.substringAfterLast('-');
                                //convert current rawOffset and DstOffset to negative/postive to get the GMT of current location to add it below. Ex: India GMT is +5:30 hours. Then convert to -5:30 hours
                                if(rmaRawOffset != null){
                                    rmaRawOffsetConverted = integer.valueOf(rmaRawOffset) * -1;
                                }
                                if(rmaDstOffset != null){
                                    rmaDstOffsetConverted = integer.valueOf(rmaDstOffset) * -1;
                                }
                                rmaToProcess.caseSLADueDateTimeInUserLocalTime__c = string.valueOf(DateTime.newInstanceGmt(integer.valueOf(year.substringBefore(' ')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBefore('-')), integer.valueOf(rmaToProcess.rmaSLADueDateTime__c.substringBetween('-', '-')), 17,0,0).addSeconds(rmaRawOffsetConverted + rmaDstOffsetConverted).format('MM-dd-yyyy HH:mm:ss'));
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            system.debug('@@@ Caught Exception @@@: '+e.getMessage());
        }
        
        // #############################################################################################################
        // END LOGIC TO SET RMA SLA Due Date Time Value Calculations - Added on 14th November by Azarudeen
        // #############################################################################################################
    }
    
    public static void rmaSetOutgoingShipmentTimeStamps(RMAv2__c rmaToProcess)
    {
        // ###############################################
        // BEGIN LOGIC TO SET OUTGOING SHIPMENT TIMESTAMPS
        // ###############################################
        
        // rmaToProcess.rmaOutgoingShipmentStatus__c != null Added by Exafort for TS-10344
        if (rmaToProcess.rmaOutgoingShipmentStatus__c != null && rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('OPEN') &&
            rmaToProcess.rmaOutgoingShipmentDateTimeOpened__c == null)
        {rmaToProcess.rmaOutgoingShipmentDateTimeOpened__c = System.now();
        }
        else if (rmaToProcess.rmaOutgoingShipmentStatus__c != null && rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('CLOSED') &&
                 rmaToProcess.rmaOutgoingShipmentDateTimeClosed__c == null)
        {rmaToProcess.rmaOutgoingShipmentDateTimeClosed__c = System.now();
        }
        else if (rmaToProcess.rmaOutgoingShipmentStatus__c != null && rmaToProcess.rmaOutgoingShipmentStatus__c.startsWith('CANCELED') &&
                 rmaToProcess.rmaOutgoingShipmentDateTimeCanceled__c == null)
        {rmaToProcess.rmaOutgoingShipmentDateTimeCanceled__c = System.now();
        }
        
        // #############################################
        // END LOGIC TO SET OUTGOING SHIPMENT TIMESTAMPS
        // #############################################
    }
    
    public static void rmaSetReturnShipmentTimestamps(RMAv2__c rmaToProcess)
    {
        // #############################################
        // BEGIN LOGIC TO SET RETURN SHIPMENT TIMESTAMPS
        // #############################################
        
        if (rmaToProcess.rmaReturnShipmentStatus__c.startsWith('OPEN') &&
            rmaToProcess.rmaReturnShipmentDateTimeOpened__c == null)
        {rmaToProcess.rmaReturnShipmentDateTimeOpened__c = System.now();
        }
        else if (rmaToProcess.rmaReturnShipmentStatus__c.startsWith('CLOSED') &&
                 rmaToProcess.rmaReturnShipmentDateTimeClosed__c == null)
        {rmaToProcess.rmaReturnShipmentDateTimeClosed__c = System.now();
        }
        else if (rmaToProcess.rmaReturnShipmentStatus__c.startsWith('CANCELED') &&
                 rmaToProcess.rmaReturnShipmentDateTimeCanceled__c == null)
        {rmaToProcess.rmaReturnShipmentDateTimeCanceled__c = System.now();
        }
        
        // ###########################################
        // END LOGIC TO SET RETURN SHIPMENT TIMESTAMPS
        // ###########################################
    }
    
    public static void rmaPopulateOnsiteCompiledNotes(RMAv2__c rmaToProcess)
    {
        // #############################################
        // BEGIN LOGIC TO POPULATE ONSITE COMPILED NOTES
        // #############################################
        
        rmaToProcess.rmaOnsiteCompiledNotes__c = null;
        Case caseRecord = null;
        
        //if (rmaToProcess.rmaType__c == 'Advance replacement' && rmaToProcess.rmaAssetSla__c.contains('Onsite'))
        // isOnsiteSLA(rmaToProcess) Added by Exafort for TS-10107
        system.debug('BOOLEAN RETURN : ' + isOnsiteSLA(rmaToProcess));
        if (rmaToProcess.rmaType__c == 'Advance replacement' && isOnsiteSLA(rmaToProcess))
        {// Load asset data, depending on whether the RMA is for a head shelf or disk shelf
            Id rmaAssetToUseKey;
            
            if (rmaToProcess.rmaDiskShelfAsset__c <> null)
            {
                rmaAssetToUseKey = rmaToProcess.rmaDiskShelfAsset__c;
            }
            else
            {
                if (caseMap.containsKey(rmaToProcess.rmaCaseNumber__c))
                    caseRecord = caseMap.get(rmaToProcess.rmaCaseNumber__c);  
                
                if (caseRecord.AssetId <> null)
                {rmaAssetToUseKey = caseRecord.AssetId;
                }
                else
                {rmaToProcess.addError('Could not find Asset data (Disk Shelf Asset on RMA, nor Asset on Case).  Cannot save RMA without valid Asset.');
                 return;
                }
            }
            
            Asset assetRecord = assetMap.get(rmaAssetToUseKey);  
            
            rmaToProcess.rmaOnsiteCompiledNotes__c =
                'ONSITE SERVICE ORDER DATA\n\n' +
                '*** COMMAND CENTER INSTRUCTIONS ***\n\n' +
                'Scheduling Code: ' + rmaToProcess.rmaOnsiteSchedulingCode__c + '\n' +
                'Scheduling Notes: ' + rmaToProcess.rmaOnsiteSchedulingNotes__c + '\n\n' +
                '*** PART COURIER INSTRUCTIONS ***\n\n' +
                'Shipment Address:\n' +
                rmaToProcess.rmaShipmentStreet1__c + '\n' +
                rmaToProcess.rmaShipmentStreet2__c + '\n' +
                rmaToProcess.rmaShipmentCity__c + ', ' +
                rmaToProcess.rmaShipmentState__c + ' ' +
                rmaToProcess.rmaShipmentPostalCode__c + ' ' +
                rmaToProcess.rmaShipmentCountry__c + '\n' +
                'Attn: ' + rmaToProcess.rmaShipmentAttn__c + '\n' +
                'Phone: ' + rmaToProcess.rmaShipmentPhone__c + '\n' +
                'Email: ' + rmaToProcess.rmaShipmentEmail__c + '\n\n' +
                'Part Handover Code: ' + rmaToProcess.rmaOnsitePartHandoverCode__c + '\n' +
                'Part Handover Notes: ' + rmaToProcess.rmaOnsitePartHandoverNotes__c + '\n\n' +
                '*** FE INSTRUCTIONS ***\n\n' +
                'FE Arrival Address:\n' +
                rmaToProcess.rmaOnsiteArrivalStreet1__c + '\n' +
                rmaToProcess.rmaOnsiteArrivalStreet2__c + '\n' +
                rmaToProcess.rmaOnsiteArrivalCity__c + ', ' +
                rmaToProcess.rmaOnsiteArrivalState__c + ' ' +
                rmaToProcess.rmaOnsiteArrivalPostalCode__c + ' ' +
                rmaToProcess.rmaOnsiteArrivalCountry__c + '\n\n' +
                'FE Check-In Code: ' + rmaToProcess.rmaOnsiteCheckInCode__c + '\n' +
                'FE Check-In Notes: ' + rmaToProcess.rmaOnsiteCheckInNotes__c + '\n\n' +
                'Refer to the PART COURIER INSTRUCTIONS, above, to determine where the part courier left the part, and go pick it up.\n\n' +
                'Asset Install Address:\n' +
                assetRecord.Install_Street1__c + '\n' +
                assetRecord.Install_Street2__c + '\n' +
                assetRecord.Install_City__c + ', ' +
                assetRecord.Install_State_Province__c + ' ' +
                assetRecord.Install_Zip_Code__c + ' ' +
                assetRecord.Install_Country__c + '\n\n' +
                'Asset Specific Location (these fields are optional, and may not be populated):\n' +
                'Building: ' + rmaToProcess.rmaAssetLocBuilding__c + '\n' +
                'Floor: ' + rmaToProcess.rmaAssetLocFloor__c + '\n' +
                'Datacenter: ' + rmaToProcess.rmaAssetLocDatacenter__c + '\n' +
                'Area/Grid: ' + rmaToProcess.rmaAssetLocAreaOrGrid__c + '\n' +
                'Row: ' + rmaToProcess.rmaAssetLocRow__c + '\n' +
                'Rack: ' + rmaToProcess.rmaAssetLocRack__c + '\n' +
                'Position In Rack: ' + rmaToProcess.rmaAssetLocPositionInRack__c + '\n' +
                'Asset Serial Number: ' + assetRecord.Name + '\n\n' +
                'Slot Information (for components that are slot-specific):\n' +
                'Controller/Expander: ' + rmaToProcess.rmaOnsiteControllerExpanderSlot__c + '\n' +
                'HDD/SSD: ' + rmaToProcess.rmaOnsiteHddSsdSlot__c + '\n' +
                'Power Supply: ' + rmaToProcess.rmaOnsitePowerSupplySlot__c + '\n' +
                'NIC Card:' + rmaToProcess.rmaOnsiteNicCardSlot__c + '\n\n' +
                'Part Disposition Code: ' + rmaToProcess.rmaOnsitePartDispositionCode__c + '\n' +
                'Part Disposition Notes: ' + rmaToProcess.rmaOnsitePartDispositionNotes__c + '\n\n' +
                '(end of ONSITE SERVICE ORDER DATA)';
        }
        
        // ###########################################
        // END LOGIC TO POPULATE ONSITE COMPILED NOTES
        // ###########################################
        
    }
    
    public static void rmaPopulateDeliveryInstructions(RMAv2__c rmaToProcess)
    {
        // #############################################
        // BEGIN LOGIC TO POPULATE DELIVERY INSTRUCTIONS
        // #############################################
        
        String tmpRmaDeliveryInstructions;
        
        rmaToProcess.rmaDeliveryInstructions__c = '';
        
        Case caseRecord = null;
        Account accountRecord = null;
        Asset assetRecord = null;
        
        if (rmaToProcess.rmaType__c == 'Advance replacement' && rmaToProcess.rmaTransmitRmaShisWithOrder__c != null)
        {String[] rmaTransmitRmaShisWithOrderValues = rmaToProcess.rmaTransmitRmaShisWithOrder__c.split(';');
         
         // Loop through each value in the multi-select picklist
         for (String rmaTransmitRmaShisWithOrderValue : rmaTransmitRmaShisWithOrderValues)
         {System.debug('DEBUG rmaTransmitRmaShisWithOrderValue = ' + rmaTransmitRmaShisWithOrderValue);
          
          // Add Account RMA SHI (if selected)
          if (rmaTransmitRmaShisWithOrderValue == 'Account RMA SHI')
          {
              if (caseMap.containsKey(rmaToProcess.rmaCaseNumber__c))
                  caseRecord = caseMap.get(rmaToProcess.rmaCaseNumber__c);  
              
              if (caseRecord.AccountId == null)
              {rmaToProcess.addError('RMA Case has no Account.  Cannot save RMA without valid Account on the Case.');
               return;
              }
              
              if (accountMap.containsKey(caseRecord.AccountId))
                  accountRecord = accountMap.get(caseRecord.AccountId); 
              
              if (accountRecord.accountRmaShi__c != null)
              {tmpRmaDeliveryInstructions              = rmaToProcess.rmaDeliveryInstructions__c + 'Account RMA SHI:\n' + accountRecord.accountRmaShi__c + '\n\n';
               rmaToProcess.rmaDeliveryInstructions__c = tmpRmaDeliveryInstructions.left(2000);
              }
          }
          
          // Add Asset RMA SHI (if selected)
          else if (rmaTransmitRmaShisWithOrderValue == 'Asset RMA SHI')
          {
              if (rmaToProcess.rmaDiskShelfAsset__c == null)
              {
                  if (caseMap.containsKey(rmaToProcess.rmaCaseNumber__c))
                      caseRecord = caseMap.get(rmaToProcess.rmaCaseNumber__c); 
                  
                  if (caseRecord.AssetId == null)
                  {rmaToProcess.addError('RMA Case has no Asset.  Cannot save RMA without valid Asset on the Case.');
                   return;
                  }
                  if (assetMap.containsKey(caseRecord.AssetId))   
                      assetRecord = assetMap.get(caseRecord.AssetId); 
              }
              else
              {
                  if (assetMap.containsKey(rmaToProcess.rmaDiskShelfAsset__c))
                      assetRecord = assetMap.get(rmaToProcess.rmaDiskShelfAsset__c);
              }
              
              if (assetRecord.assetRmaShi__c != null)
              {tmpRmaDeliveryInstructions              = rmaToProcess.rmaDeliveryInstructions__c + 'Asset RMA SHI:\n' + assetRecord.assetRmaShi__c + '\n\n';
               rmaToProcess.rmaDeliveryInstructions__c = tmpRmaDeliveryInstructions.left(2000);
              }
          }
          
          // Add RMA SHI (if selected)
          else if (rmaTransmitRmaShisWithOrderValue == 'RMA SHI')
          {tmpRmaDeliveryInstructions              = rmaToProcess.rmaDeliveryInstructions__c + 'RMA SHI:\n' + rmaToProcess.rmaShi__c + '\n\n';
           rmaToProcess.rmaDeliveryInstructions__c = tmpRmaDeliveryInstructions.left(2000);
          }
          
         }
        }
        
        // ###########################################
        // END LOGIC TO POPULATE DELIVERY INSTRUCTIONS
        // ###########################################
        
    }
    
    public static void rmaSetFa(RMAv2__c rmaToProcess)
    {
        // ##################################################
        // BEGIN LOGIC TO SET FA (FAILURE ANALYSIS) VARIABLES
        // ##################################################
        
        String newFaLogicHistory;
        String PartShipSLAValue;
        //Added by vishnu on 1st Feb 2019 for TS-5318 TS-5258 -Start
        getSrMetaDataMap();
        // toLowerCase() Added by Exafort for SFDC-1260
        SR_Meta_Data__c SrMetaDataRec;
        if(rmaToProcess.rmaFailedPart__c != null && srMetaDataMap.size() > 0){
            SrMetaDataRec = srMetaDataMap.get(rmaToProcess.rmaFailedPart__c.toLowerCase());
        }
        system.debug('SrMetaDataRec --> ' + SrMetaDataRec);
        if(SrMetaDataRec != null){
            PartShipSLAValue =  SrMetaDataRec.srPartShipSLAOverride__c;           
        }
        system.debug('### Part Ship SLA Value'+PartShipSLAValue);
        //Added by vishnu on 1st Feb 2019 for TS-5318 TS-5258 -start-END
        System.debug('DEBUG: ****************************************');
        System.debug('DEBUG: Timestamp                           = ' + System.now());
        System.debug('DEBUG: User ID                             = ' + UserInfo.getUserId());
        System.debug('DEBUG: User Name                           = ' + UserInfo.getName());
        System.debug('DEBUG: INPUTS:');
        System.debug('DEBUG: rmaType__c                          = ' + rmaToProcess.rmaType__c);
        System.debug('DEBUG: rmaAssetNrdIsInEffect__c            = ' + rmaToProcess.rmaAssetNrdIsInEffect__c);
        System.debug('DEBUG: rmaPartIsAShipOnlyPart__c           = ' + rmaToProcess.rmaPartIsAShipOnlyPart__c);
        System.debug('DEBUG: rmaAssetSla__c                      = ' + rmaToProcess.rmaAssetSla__c);
        System.debug('DEBUG: rmaCaseIsEngOrExecEscalated__c      = ' + rmaToProcess.rmaCaseIsEngOrExecEscalated__c);
        System.debug('DEBUG: rmaComponent__c                     = ' + rmaToProcess.rmaComponent__c);
        System.debug('DEBUG: rmaPartFailedWithinOpsTimePeriod__c = ' + rmaToProcess.rmaPartFailedWithinOpsTimePeriod__c);
        System.debug('DEBUG: rmaFaRequired__c                    = ' + rmaToProcess.rmaFaRequired__c);
        System.debug('DEBUG: rmaOutgoingShipmentStatus__c        = ' + rmaToProcess.rmaOutgoingShipmentStatus__c);
        System.debug('DEBUG: rmaReturnShipmentStatus__c          = ' + rmaToProcess.rmaReturnShipmentStatus__c);
        System.debug('DEBUG: rmaRetShip2Status__c                = ' + rmaToProcess.rmaRetShip2Status__c);
        System.debug('DEBUG: rmaCustomerFaRequired__c            = ' + rmaToProcess.rmaCustomerFaRequired__c);
        System.debug('DEBUG: LOGIC DECISIONS:');
        
        newFaLogicHistory = rmaToProcess.rmaFaLogicHistory__c +
            '\n****************************************\n' +
            'Timestamp                           = ' + System.now() + '\n' +
            'User ID                             = ' + UserInfo.getUserId() + '\n' +
            'User Name                           = ' + UserInfo.getName() + '\n' +
            'INPUTS:\n' +
            'rmaType__c                          = ' + rmaToProcess.rmaType__c + '\n' +
            'rmaAssetNrdIsInEffect__c            = ' + rmaToProcess.rmaAssetNrdIsInEffect__c + '\n' +
            'rmaPartIsAShipOnlyPart__c           = ' + rmaToProcess.rmaPartIsAShipOnlyPart__c + '\n' +
            'rmaAssetSla__c                      = ' + rmaToProcess.rmaAssetSla__c + '\n' +
            'rmaCaseIsEngOrExecEscalated__c      = ' + rmaToProcess.rmaCaseIsEngOrExecEscalated__c + '\n' +
            'rmaComponent__c                     = ' + rmaToProcess.rmaComponent__c + '\n' +
            'rmaPartFailedWithinOpsTimePeriod__c = ' + rmaToProcess.rmaPartFailedWithinOpsTimePeriod__c + '\n' +
            'rmaFaRequired__c                    = ' + rmaToProcess.rmaFaRequired__c + '\n' +
            'rmaOutgoingShipmentStatus__c        = ' + rmaToProcess.rmaOutgoingShipmentStatus__c + '\n' +
            'rmaReturnShipmentStatus__c          = ' + rmaToProcess.rmaReturnShipmentStatus__c + '\n' +
            'rmaRetShip2Status__c                = ' + rmaToProcess.rmaRetShip2Status__c + '\n' +
            'rmaCustomerFaRequired__c            = ' + rmaToProcess.rmaCustomerFaRequired__c + '\n' +
            'LOGIC DECISIONS:\n';
        
        // Type = "System/part return"
        if (rmaToProcess.rmaType__c == 'System/part return')
        {System.debug('DEBUG: HERE 0100 - Type = "System/part return"');
         newFaLogicHistory += 'HERE 0100 - Type = "System/part return"\n';
         
         rmaToProcess.rmaOrderType__c          = 'System/part return';
         rmaToProcess.rmaFaRequired__c         = 'No FA Required';
         rmaToProcess.rmaEFAPriority__c = null;
         rmaToProcess.rmaCustomerFaRequired__c = false;
        }
        
        // Asset NRD is in Effect
        else if (rmaToProcess.rmaAssetNrdIsInEffect__c == 'Yes')
        {System.debug('DEBUG: HERE 0200 - Asset NRD is in Effect');
         newFaLogicHistory += 'HERE 0200 - Asset NRD is in Effect\n';
         // isOnsiteSLA(rmaToProcess) Added by Exafort for TS-10107
         //if (rmaToProcess.rmaAssetSla__c.contains('Onsite'))
         if(isOnsiteSLA(rmaToProcess))
         {
             //rmaToProcess.rmaOrderType__c = 'Ship Only w/ Tech';
             if(rmaToProcess.rmaOnsiteTechStatus__c == 'N/A-10: No onsite for this RMA Type'){//Added by exafort on 05/14 for TS-8227
                 rmaToProcess.rmaOrderType__c = 'Ship Only';   
             }
             else{
                 rmaToProcess.rmaOrderType__c = 'Ship only w Tech';
             }
             
         }
         //Added end
         else
         {rmaToProcess.rmaOrderType__c = 'Ship Only';
         }
         
         rmaToProcess.rmaFaRequired__c           = 'No FA Required';
         rmaToProcess.rmaEFAPriority__c = null;
         rmaToProcess.rmaReturnShipmentStatus__c = 'N/A-10: No part to ship for this RMA Type';
         rmaToProcess.rmaRetShip2Status__c       = 'N/A-10: No part to ship for this RMA Type';
         rmaToProcess.rmaCustomerFaRequired__c   = false;
        }
        // Exafort(vishnu) on 21st august 2018- added the rmaToProcess.rmaComponentIsAutoOFA__c != true for Auto OFA Logic
        // Part is a Ship Only Part
        // Added by Exafort(vishnu) on 1st FEB 2019 - added the conditon "rmaToProcess.rmaIsSrPartNBDOverridden__c != true"
        else if (rmaToProcess.rmaPartIsAShipOnlyPart__c == 'Yes' && rmaToProcess.rmaComponentIsAutoOFA__c != true )//&& rmaToProcess.rmaIsSrPartNBDOverridden__c != true
        {System.debug('DEBUG: HERE 0300 - Part is a Ship Only Part');
         newFaLogicHistory += 'HERE 0300 - Part is a Ship Only Part\n';
         // isOnsiteSLA(rmaToProcess) Added by Exafort for TS-10107
         //if (rmaToProcess.rmaAssetSla__c.contains('Onsite') && rmaToProcess.rmaIsSrPartNBDOverridden__c != true)
         if (isOnsiteSLA(rmaToProcess) && rmaToProcess.rmaIsSrPartNBDOverridden__c != true)
         {
             // rmaToProcess.rmaOrderType__c = 'Ship Only w/ Tech';
             if(rmaToProcess.rmaOnsiteTechStatus__c == 'N/A-10: No onsite for this RMA Type'){//Added by exafort on 05/14 for TS-8227
                 rmaToProcess.rmaOrderType__c = 'Ship Only';
             }
             else{
                 rmaToProcess.rmaOrderType__c = 'Ship only w Tech';
             }
         }
         //Added end
         else
         {rmaToProcess.rmaOrderType__c = 'Ship Only';
         }
         /*If CFA is checked it should not ovverride the FA Required field - changed on 25th April 2016*/
         if(rmaToProcess.rmaCustomerFaRequired__c   == true){
             rmaToProcess.rmaFaRequired__c           = 'Operations FA';
             rmaToProcess.rmaCustomerFaRequired__c   = true;
         }
         else{
             //Commneted By Exafort(vishnu) on 22nd August 2018 for TS-4048 Unable to assign FA for ship only parts
             //rmaToProcess.rmaFaRequired__c           = 'No FA Required';
             rmaToProcess.rmaCustomerFaRequired__c   = false;
         }
         //rmaToProcess.rmaFaRequired__c           = 'No FA Required';
         rmaToProcess.rmaEFAPriority__c = null;
         rmaToProcess.rmaReturnShipmentStatus__c = 'N/A-10: No part to ship for this RMA Type';
         rmaToProcess.rmaRetShip2Status__c       = 'N/A-10: No part to ship for this RMA Type';
         //rmaToProcess.rmaCustomerFaRequired__c   = false;
        }
        
        // Case is Engineering or Executive Escalated
        // NOTE: Per Alexander Pham's flowchart, marking
        //       the FA Required field as "Engineering FA" is
        //       no longer required just because the case is
        //       escalated.  Commented this out.
        //else if (rmaToProcess.rmaCaseIsEngOrExecEscalated__c)
        //  {System.debug('DEBUG: HERE 0400 - Case is Engineering or Executive Escalated');
        //   newFaLogicHistory += 'HERE 0400 - Case is Engineering or Executive Escalated\n';
        //
        //   if (rmaToProcess.rmaAssetSla__c.contains('Onsite'))
        //     {rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ FA w/ Tech';
        //     }
        //   else
        //     {rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ Failure Analysis';
        //     }
        //
        //   rmaToProcess.rmaFaRequired__c = 'Engineering FA';
        //  }
        
        
        // Component = "SSD"
        else if (rmaToProcess.rmaComponentIsAutoEFA__c == true)
        {System.debug('DEBUG: HERE 0400 - Component ="' + rmaToProcess.rmaComponent__c);
         newFaLogicHistory += 'HERE 0400 - Component = "' + rmaToProcess.rmaComponent__c + '"\n';
         
         //TS-6667 added rmaUplift__c  Added by Exafort on August 19 2020
         // isOnsiteSLA(rmaToProcess) Added by Exafort for TS-10107
         //if (rmaToProcess.rmaAssetSla__c.contains('Onsite') || rmaToProcess.rmaUplift__c == 'Premium Onsite')
         if (isOnsiteSLA(rmaToProcess) || rmaToProcess.rmaUplift__c == 'Premium Onsite')
         {
             // rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ FA w/ Tech'; 
             if(rmaToProcess.rmaOnsiteTechStatus__c == 'N/A-10: No onsite for this RMA Type'){//Added by exafort on 05/14 for TS-8227
                 // Added by Exafort for TS-9447
                 //rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ FA';
                 rmaToProcess.rmaOrderType__c = 'Advance Replacement w Failure Analysis';
                 // Added end
             }
             else{
                 rmaToProcess.rmaOrderType__c = 'Advance Replacement w FA w Tech';
             }
             
         }
         //Added end
         else
         {
             rmaToProcess.rmaOrderType__c = 'Advance Replacement w Failure Analysis';
         }
         if(rmaToProcess.rmaAutoEFAoverride__c == false){
             rmaToProcess.rmaFaRequired__c = 'Engineering FA';
             if(rmaToProcess.rmaCustomerFaRequired__c == true){
                 rmaToProcess.rmaCustomerFaRequired__c = true;
             }
             else{
                 rmaToProcess.rmaCustomerFaRequired__c = false;
             }
         }
         
         /*CFA is checked it should not ovverride the FA Required field - changed on 25th April 2016*/
         if(rmaToProcess.rmaCustomerFaRequired__c == true && rmaToProcess.rmaFaRequired__c == 'Engineering FA'){
             rmaToProcess.rmaFaRequired__c = 'Engineering FA';
             rmaToProcess.rmaCustomerFaRequired__c = true;
         }
         else{
             rmaToProcess.rmaCustomerFaRequired__c = false;
         }
         
         
         if(rmaToProcess.rmaEFAPriority__c == null)
             rmaToProcess.rmaEFAPriority__c = 'P3';
         
        }
        
        //************************************************************
        //Added by exafort vishnu for Auto OFA logic-start
        //************************************************************
        else if (rmaToProcess.rmaComponentIsAutoOFA__c == true){
            System.debug('DEBUG: HERE 0500 - Component ="' + rmaToProcess.rmaComponent__c);
            newFaLogicHistory += 'HERE 0500 - Component = "' + rmaToProcess.rmaComponent__c + '"\n';
            
            rmaToProcess.rmaFaRequired__c = 'Operations FA';
            rmaToProcess.rmaOrderType__c = 'Advance Replacement w Defective Return';
            
        }
        //************************************************************
        //Auto OFA logic -END
        //************************************************************
        
        // Part Failed within Ops Time Period
        //   and
        // FA Required is not "Engineering FA"
        else if (rmaToProcess.rmaPartFailedWithinOpsTimePeriod__c == 'Yes' &&
                 rmaToProcess.rmaFaRequired__c != 'Engineering FA')
        {System.debug('DEBUG: HERE 0600 - Part Failed within Ops Time Period and FA Required is not "Engineering FA"');
         newFaLogicHistory += 'HERE 0600 - Part Failed within Ops Time Period and FA Required is not "Engineering FA"\n';
         
         //TS-6667 added rmaUplift__c Added by Exafort on August 19 2020
         // isOnsiteSLA(rmaToProcess) Added by Exafort for TS-10107
         //if (rmaToProcess.rmaAssetSla__c.contains('Onsite') || rmaToProcess.rmaUplift__c == 'Premium Onsite')
         if (isOnsiteSLA(rmaToProcess) || rmaToProcess.rmaUplift__c == 'Premium Onsite')
         {
             //rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ FA w/ Tech';
             if(rmaToProcess.rmaOnsiteTechStatus__c  == 'N/A-10: No onsite for this RMA Type'){//Added by exafort on 05/14 for TS-8227
                 // Added by Exafort for TS-9447
                 //rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ FA';
                 rmaToProcess.rmaOrderType__c = 'Advance Replacement w Failure Analysis';
                 // Added End
                 
             }
             else{
                 rmaToProcess.rmaOrderType__c = 'Advance Replacement w FA w Tech';
             }
             
         }
         //Added end
         else
         {
             rmaToProcess.rmaOrderType__c = 'Advance Replacement w Failure Analysis';
         }
         
         rmaToProcess.rmaFaRequired__c = 'Operations FA';
         rmaToProcess.rmaEFAPriority__c = null;
        }
        
        // FA Required = "Engineering FA" or "Operations FA"
        else if (rmaToProcess.rmaFaRequired__c == 'Engineering FA' ||
                 rmaToProcess.rmaFaRequired__c == 'Operations FA')
        {System.debug('DEBUG: HERE 0700 - FA Required = "Engineering FA" or "Operations FA"');
         newFaLogicHistory += 'HERE 0700 - FA Required = "Engineering FA" or "Operations FA"\n';
         
         //TS-6667 added rmaUplift__c  Added by Exafort on August 19 2020
         // isOnsiteSLA(rmaToProcess) Added by Exafort for TS-10107
         //if (rmaToProcess.rmaAssetSla__c.contains('Onsite') || rmaToProcess.rmaUplift__c == 'Premium Onsite')
         if (isOnsiteSLA(rmaToProcess) || rmaToProcess.rmaUplift__c == 'Premium Onsite')    
         {
             //rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ FA w/ Tech';
             if(rmaToProcess.rmaOnsiteTechStatus__c == 'N/A-10: No onsite for this RMA Type'){//Added by exafort on 05/14 for TS-8227
                 // Added by Exafort for TS-9447
                 //rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ FA';
                 rmaToProcess.rmaOrderType__c = 'Advance Replacement w Failure Analysis';
                 // Added end
             }
             
             else{
                 rmaToProcess.rmaOrderType__c = 'Advance Replacement w FA w Tech';
             }
         }
         //Added end
         else
         {
             rmaToProcess.rmaOrderType__c = 'Advance Replacement w Failure Analysis';
         }
        }
        
        //system.debug('### part ship SLA Override value =>'+srMetaDataMap.get(rmaToProcess.rmaPartNumber__c).srPartShipSLAOverride__c);
        // Asset SLA contains "Onsite"
        // Added "PartShipSLAValue" as a condition to override order type to "Advance Replacement w/ Defective Return"
        //TS-6667 added rmaUplift__c  Added by Exafort on August 19 2020
        //else if ((rmaToProcess.rmaAssetSla__c.contains('Onsite') || rmaToProcess.rmaUplift__c == 'Premium Onsite') 
        //         && (PartShipSLAValue == null && rmaToProcess.PachinkoCaseType__c != 'ssdwearlevelhigh')
        // isOnsiteSLA(rmaToProcess) Added by Exafort for TS-10107
        else if ((isOnsiteSLA(rmaToProcess) || rmaToProcess.rmaUplift__c == 'Premium Onsite') 
                 && (PartShipSLAValue == null && rmaToProcess.PachinkoCaseType__c != 'ssdwearlevelhigh')
                ) //PartShipSLAValue != 'NBD & Onsite Override'
            //(PartShipSLAValue == 'NBD & Onsite Retain' && rmaToProcess.PachinkoCaseType__c == 'ssdwearlevelhigh')
        {
            System.debug('DEBUG: HERE 0900 - Asset SLA contains "Onsite"');
            newFaLogicHistory += 'HERE 0900 - Asset SLA contains "Onsite"\n';
            //rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ Def Rtrn w/ Tech';
            //Added by exafort on 05/14 for TS-8227
            if(rmaToProcess.rmaOnsiteTechStatus__c == 'N/A-10: No onsite for this RMA Type'){
                // Added by Exafort for TS-9447
                //rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ Def Rtrn'; 
                rmaToProcess.rmaOrderType__c = 'Advance Replacement w Defective Return';
                // Added end
            }
            else{
                
                rmaToProcess.rmaOrderType__c = 'Advance Replacement w Def Rtrn w Tech';
            }
            
            
        }
        
        //TS-6667 - added the else if to update the order type.  Added by Exafort on August 19 2020
        //Asset SLA contains "Onsite" and "PartShipSLAValue" as NBD & Onsite Retain
        // isOnsiteSLA(rmaToProcess) Added by Exafort for TS-10107
        //else if((rmaToProcess.rmaAssetSla__c.contains('Onsite') || rmaToProcess.rmaUplift__c == 'Premium Onsite') && (PartShipSLAValue != null && PartShipSLAValue.contains('NBD')))
        else if((isOnsiteSLA(rmaToProcess) || rmaToProcess.rmaUplift__c == 'Premium Onsite') && (PartShipSLAValue != null && PartShipSLAValue.contains('NBD')))
        {
            //rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ Def Rtrn w/ Tech';
            //Added by exafort on 05/14 for TS-8227
            if(rmaToProcess.rmaOnsiteTechStatus__c == 'N/A-10: No onsite for this RMA Type'){ 
                // Added by Exafort for TS-9447
                //rmaToProcess.rmaOrderType__c = 'Advance Replacement w/ Def Rtrn';
                rmaToProcess.rmaOrderType__c = 'Advance Replacement w Defective Return';
                // Added end
            }
            else{
                rmaToProcess.rmaOrderType__c = 'Advance Replacement w Def Rtrn w Tech';
            } 
        }
        
        // Asset SLA does not contain "Onsite"
        // This section is the last block of logic, and will
        // catch all RMAs that didn't match earlier logic.
        else
        {System.debug('DEBUG: HERE 1000 - Asset SLA does not contain "Onsite"');
         newFaLogicHistory += 'HERE 1000 - Asset SLA does not contain "Onsite"\n';        

         rmaToProcess.rmaOrderType__c = 'Advance Replacement w Defective Return';
        }
        
        System.debug('DEBUG: OUTPUTS:');
        System.debug('DEBUG: rmaOrderType__c              = ' + rmaToProcess.rmaOrderType__c);
        System.debug('DEBUG: rmaFaRequired__c             = ' + rmaToProcess.rmaFaRequired__c);
        System.debug('DEBUG: rmaOutgoingShipmentStatus__c = ' + rmaToProcess.rmaOutgoingShipmentStatus__c);
        System.debug('DEBUG: rmaReturnShipmentStatus__c   = ' + rmaToProcess.rmaReturnShipmentStatus__c);
        System.debug('DEBUG: rmaRetShip2Status__c         = ' + rmaToProcess.rmaRetShip2Status__c);
        System.debug('DEBUG: rmaCustomerFaRequired__c     = ' + rmaToProcess.rmaCustomerFaRequired__c);
        
        if(rmaToProcess.rmaReason__c == 'DOA' && rmaToProcess.rmaFaRequired__c != 'Engineering FA'){
            rmaToProcess.rmaFaRequired__c = 'Operations FA';
        }
        
        /*
* START - set order type to Advance Replacement w/ Failure Analysis for full system RMAs.
* Added on 17th Aug 2017
* By - Exafort(Azar)
* */
        if(rmaToProcess.rmaFullAssetRMA__c == true){
            rmaToProcess.rmaOrderType__c = 'Advance Replacement w Failure Analysis';
        }
        //rmaToProcess.rmaType__c == 'Ship Only'
        //Added By Exafort(vishnu)
        //*Added the condition of Auto OFA = false .
        //Removed the below condition on 31st Jan 2019 to restrict the overriding of order type to "Ship Only"
        //Condition:-->(rmaToProcess.PachinkoCaseType__c != null && rmaToProcess.PachinkoCaseType__c != 'ssdwearlevelhigh') || 
        
        if(((srMetaDataShippingProvider == 'Shipping and Receiving')) && rmaToProcess.rmaComponentIsAutoOFA__c != true){
            //if((rmaToProcess.PachinkoCaseType__c != null && rmaToProcess.PachinkoCaseType__c == 'ssdwearlevelhigh') || (srMetaDataShippingProvider == 'Shipping and Receiving')){
            rmaToProcess.rmaOrderType__c = 'Ship Only';
            rmaToProcess.rmaSLAHelper__c = 'Ship Only';
        }
        //Added by Exafort(Guru Dev) for TS-9193
        // isOnsiteSLA(rmaToProcess) Added by Exafort for TS-10107
        //if(rmaToProcess.rmaAssetSla__c.contains('Onsite') && rmaToProcess.rmaOrderType__c == 'Ship Only w/ Tech' &&
        if(isOnsiteSLA(rmaToProcess) && rmaToProcess.rmaOrderType__c == 'Ship only w Tech' &&
           rmaToProcess.rmaOverrideOnsitePartDispositionCode__c == null){
               rmaToProcess.rmaOverrideOnsitePartDispositionCode__c = 'LEAVE-PART-10: FE must leave old part at site';
           }
        //Added End
        newFaLogicHistory += 'OUTPUTS:\n' +
            'rmaOrderType__c              = ' + rmaToProcess.rmaOrderType__c + '\n' +
            'rmaFaRequired__c             = ' + rmaToProcess.rmaFaRequired__c + '\n' +
            'rmaOutgoingShipmentStatus__c = ' + rmaToProcess.rmaOutgoingShipmentStatus__c + '\n' +
            'rmaReturnShipmentStatus__c   = ' + rmaToProcess.rmaReturnShipmentStatus__c + '\n' +
            'rmaRetShip2Status__c         = ' + rmaToProcess.rmaRetShip2Status__c + '\n' +
            'rmaCustomerFaRequired__c     = ' + rmaToProcess.rmaCustomerFaRequired__c;
        
        rmaToProcess.rmaFaLogicHistory__c = newFaLogicHistory.right(131072);
        
        // ################################################
        // END LOGIC TO SET FA (FAILURE ANALYSIS) VARIABLES
        // ################################################
    }
    
    /*
     * Added by Exafort for TS-10550
     * Returns uniquekey representing address used in RMA
     */
    private static string getAddressKey(RMAv2__c rmaToProcess, Map<Id,RMAv2__c> rmaMap){
        string addressKey = '';
        if (rmaToProcess == null || rmaMap == null){
            return '';
        }
        
		RMAv2__c rmaRecord = rmaMap.get(rmaToProcess.Id);
        
        addressKey = (rmaToProcess.rmaDiskShelfAsset__c != null ? rmaRecord.rmaDiskShelfAsset__r.Account.Id : rmaRecord.rmaCaseNumber__r.Asset.Account.Id);
        
        addressKey += '_' + (rmaToProcess.rmaShipmentStreet1__c == null  ? '' : rmaToProcess.rmaShipmentStreet1__c);
        addressKey += '_' + (rmaToProcess.rmaShipmentStreet2__c == null ? '' : rmaToProcess.rmaShipmentStreet2__c);
        addressKey += '_' + (rmaToProcess.rmaShipmentCity__c == null ? '' : rmaToProcess.rmaShipmentCity__c);
        addressKey += '_' + (rmaToProcess.rmaShipmentState__c == null ? '' : rmaToProcess.rmaShipmentState__c);
        addressKey += '_' + (rmaToProcess.rmaShipmentCountry__c == null ? '' : rmaToProcess.rmaShipmentCountry__c);
        addressKey += '_' + (rmaToProcess.rmaShipmentPostalCode__c == null ? '' :  rmaToProcess.rmaShipmentPostalCode__c);
        return addressKey;
    }
    // End of TS-10550
    
    public static void rmaCheckExistingRecordsInAb()
    {
        rmaMap = new Map<Id,RMAv2__c>([SELECT rmaDiskShelfAsset__c,rmaDiskShelfAsset__r.Id,rmaDiskShelfAsset__r.Account.Id,
                                       rmaDiskShelfAsset__r.Account.Name, rmaCaseNumber__c,rmaCaseNumber__r.Asset.Account.Id,
                                       rmaCaseNumber__r.Asset.Account.Name, rmaCaseNumber__r.Asset.Account.Support_Provider__r.Name,
                                       rmaCaseNumber__r.casenumber,rmaDiskShelfAsset__r.HPE_Serial_Number__c,rmaCaseNumber__r.E2CP__Case_Thread_Id__c
                                       from RMAv2__c where Id In :Trigger.newMap.keySet()]);
        
        Set<String> sAddressKeys = new Set<String>();
        
        // Added by Exafort for SFDC-471
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress owe = [select Id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Support Case'];
        // End of SFDC-471
        
        for(RMAv2__c rmaToProcess : (List<RMAv2__c>) Trigger.new){
            
            RMAv2__c rmaRecord = rmaMap.get(rmaToProcess.Id);
            
            String addressKey = '';
            
            if(rmaToProcess.rmaAddOverriddenAddressToAddressBook__c == true)
            {
			/* if(rmaToProcess.rmaDiskShelfAsset__c != null)
                    addressKey = rmaRecord.rmaDiskShelfAsset__r.Account.Id;
                else
                    addressKey = rmaRecord.rmaCaseNumber__r.Asset.Account.Id;
                
                addressKey += + '_' + rmaToProcess.rmaShipmentStreet1__c;
                
                if(rmaToProcess.rmaShipmentStreet2__c == null)
                    addressKey += + '_';
                else
                    addressKey += + '_' + rmaToProcess.rmaShipmentStreet2__c;
                
                
                addressKey += + '_' + rmaToProcess.rmaShipmentCity__c;
                addressKey += + '_' + rmaToProcess.rmaShipmentState__c;
                addressKey += + '_' + rmaToProcess.rmaShipmentCountry__c;
                addressKey += + '_' + rmaToProcess.rmaShipmentPostalCode__c;
				*/
                
                // Added by Exafort for TS-10550
                addressKey = getAddressKey(rmaToProcess, rmaMap);
                system.debug('Adding Addresskey = ' + addressKey);

                sAddressKeys.add(addressKey);
            }
            
            // Added by Exafort for SFDC-471
            // Send email to the China Storage Support if an China GA RMA is cancelled
            // String toEmailAddress = UserInfo.getUserEmail();
            string toEmailAddress = System.Label.China_Storage_Support_Email_Address;
            if(toEmailAddress != null){
                RMAv2__c rmaoldrec = (RMAv2__c)Trigger.oldMap.get(rmaToProcess.Id);
                
                // Condition checks if its an China GA RMA and its Outgoing Shipment Status is Cancelled
                // If condition updated by Exafort for SFDC-899
                if(rmaoldrec.rmaOutgoingShipmentStatus__c != rmaToProcess.rmaOutgoingShipmentStatus__c && rmaToProcess.China_Global_Account_RMA__c == True &&
                   rmaToProcess.rmaOutgoingShipmentStatus__c == 'CANCELED-10: Canceled' && rmaToProcess.rmaShipmentCountry__c == 'China'){
                       Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                       email.setToAddresses(new String[]{toEmailAddress});
                       email.setHtmlBody('Hello GRS Team, <br/><br/> Do note that ' + rmaToProcess.Name + ' has been cancelled, please ignore the request. <br/><br/> HPE Storage Support <br/>' +
                                         'Technical support phone numbers: <a href="https://www.hpe.com/psnow/doc/A00050207ENW">https://www.hpe.com/psnow/doc/A00050207ENW</a><br/><br/>' +
                                         '***********************************************************************************<br/>' +
                                         'CASE REFERENCE NUMBER REQUIRED - DO NOT MODIFY<br/>' +
                                         rmaMap.get(rmaToProcess.Id).rmaCaseNumber__r.E2CP__Case_Thread_Id__c + '<br/>' +
                                         '***********************************************************************************');
                       email.setWhatId(rmaToProcess.rmaCaseNumber__c);
                       email.setOrgWideEmailAddressId(owe.id);
                       email.setSubject('RMA/Work Order Cancellation (' + rmaMap.get(rmaToProcess.Id).rmaCaseNumber__r.casenumber + ' - ' + rmaMap.get(rmaToProcess.Id).rmaDiskShelfAsset__r.HPE_Serial_Number__c + ' - ' + rmaToProcess.name + ') – Nimble H3C [Onsite]');
                       emails.add(email);
                   }
            }
            // End of SFDC-471
        }
        
        
        //Check the address already exist in AddressBook
        for (AddressBook__c abs : [SELECT Id, abUniqueField__c,abDescription__c FROM AddressBook__c WHERE abUniqueField__c IN :sAddressKeys]) {
            mapExistingAbRecords.put(abs.abUniqueField__c.toUpperCase(),abs);
        }
        
        // Added by Exafort for SFDC-471
        // Send email
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
        // End of SFDC-471
    }
    
    public static void rmaAfterUpdateMain()
    {
        rmaCheckExistingRecordsInAb();
        
        List<AddressBook__c> newAddressBookEntries = new List<AddressBook__c>();
        Map<Id,Asset> asstMap = new Map<Id,Asset>();
        String addressKey = '';                   
        for(RMAv2__c rmaToProcess : (List<RMAv2__c>) Trigger.new){
            
            RMAv2__c rmaRecord = rmaMap.get(rmaToProcess.Id);
            
            if(rmaToProcess.rmaAddOverriddenAddressToAddressBook__c == true)
            {
				/*              
				if(rmaToProcess.rmaDiskShelfAsset__c != null)
                    addressKey = rmaRecord.rmaDiskShelfAsset__r.Account.Id;
                else
                    addressKey = rmaRecord.rmaCaseNumber__r.Asset.Account.Id;
                
                addressKey += + '_' + rmaToProcess.rmaShipmentStreet1__c;
                
                if(rmaToProcess.rmaShipmentStreet2__c == null)
                    addressKey += + '_';
                else
                    addressKey += + '_' + rmaToProcess.rmaShipmentStreet2__c;
                
                addressKey += + '_' + rmaToProcess.rmaShipmentCity__c;
                addressKey += + '_' + rmaToProcess.rmaShipmentState__c;
                addressKey += + '_' + rmaToProcess.rmaShipmentCountry__c;
                addressKey += + '_' + rmaToProcess.rmaShipmentPostalCode__c;
				*/
                
                // Added by Exafort for TS-10550
                addressKey = getAddressKey(rmaToProcess, rmaMap);
                system.debug('Searching for addresskey ' + addressKey.toUpperCase());
                
                if(!mapExistingAbRecords.containsKey(addressKey.toUpperCase()))
                {
                    AddressBook__c newAddressBookEntry = new AddressBook__c();                 
                    if(rmaToProcess.rmaDiskShelfAsset__c != null)
                        newAddressBookEntry.abAccount__c       = rmaRecord.rmaDiskShelfAsset__r.Account.Id;
                    else
                        newAddressBookEntry.abAccount__c       = rmaRecord.rmaCaseNumber__r.Asset.Account.Id;
                    
                    newAddressBookEntry.abStreet1__c       = rmaToProcess.rmaShipmentStreet1__c; 
                    newAddressBookEntry.abStreet2__c       = rmaToProcess.rmaShipmentStreet2__c;
                    newAddressBookEntry.abCity__c          = rmaToProcess.rmaShipmentCity__c;
                    newAddressBookEntry.abStateProvince__c = rmaToProcess.rmaShipmentState__c;
                    newAddressBookEntry.abCountry__c       = rmaToProcess.rmaShipmentCountry__c;
                    newAddressBookEntry.abPostalCode__c    = rmaToProcess.rmaShipmentPostalCode__c;
                    newAddressBookEntry.abDescription__c   = 'From ' + rmaToProcess.Name;
                    newAddressBookEntries.add(newAddressBookEntry);
                }
                
            }
            else
            {
                
                //if(rmaToProcess.rmaShipmentLocationValidated__c != null && rmaToProcess.rmaOutgoingShipmentStatus__c.contains('CLOSED-10: Delivered'))
                // rmaToProcess.rmaOutgoingShipmentStatus__c != null Added by Exafort for TS-10344
                if(rmaToProcess.rmaShipmentLocationValidated__c != null && rmaToProcess.rmaOverrideShipmentStreet1__c == null &&  rmaToProcess.rmaOverrideShipmentStreet2__c == null 
                   &&  rmaToProcess.rmaOverrideShipmentCity__c == null &&  rmaToProcess.rmaOverrideShipmentState__c == null && rmaToProcess.rmaOverrideShipmentCountry__c == null 
                   &&  rmaToProcess.rmaOverrideShipmentPostalCode__c == null
                   && rmaToProcess.rmaOutgoingShipmentStatus__c != null
                   && rmaToProcess.rmaOutgoingShipmentStatus__c.contains('CLOSED-10: Delivered')
                  )
                {                 
                    Integer lastValidationDateInDays= Integer.valueOf(rmaToProcess.rmaShipmentLocationValidated__c.Date().daysBetween(rmaToProcess.CreatedDate.Date()));
                    
                    if(lastValidationDateInDays>0 && lastValidationDateInDays<=180)
                    {
                        ID AssetId;
                        if(rmaToProcess.rmaDiskShelfAsset__c != null)
                            AssetId = rmaRecord.rmaDiskShelfAsset__r.Id;
                        else
                            AssetId = rmaRecord.rmaCaseNumber__r.Asset.Id;
                        
                        Asset assetToUpdate = asstMap.get(AssetId);
                        if(assetToUpdate == null)
                            assetToUpdate = new Asset(Id = AssetId);
                        assetToUpdate.assetPartShipLastValidatedDatetime__c = Datetime.now();
                        assetToUpdate.assetPartShipLastValidatedByInfo__c = 'From ' + rmaToProcess.Name;
                        asstMap.put(AssetId,assetToUpdate);
                    }
                }
            }
        }
        
        insert newAddressBookEntries;
        update asstMap.values();
    }
    
    public static void rmaOutgShipOrderDepotUpdate()
    {
        try{
            if(Trigger.isBefore && Trigger.isUpdate){
                List<RMAv2__c> rmaUpdate = new List<RMAv2__c>();
                for(RMAv2__c rmaToProcess : (List<RMAv2__c>) Trigger.new){
                    if(assetPreventRecursive.runOnce() && CountAssetPreventRecursive.runOnce())  //prevent Recursive 
                    {
                        RMAv2__c oldRMA = (RMAv2__c)Trigger.OldMap.get(rmaToProcess.Id);
                        if(rmaToProcess.rmaDontCalculateDepot__c == true && rmaToProcess.rmaOutgoingShipmentOrderDepot__c != oldRMA.rmaOutgoingShipmentOrderDepot__c && rmaToProcess.rmaOutgoingShipmentOrderDepot__c != null && rmaToProcess.rmaOutgoingShipmentOrderDepot__c != ''){
                            rmaToProcess.rmaOutgoingShipmentOrderDepot__c = rmaToProcess.rmaOutgoingShipmentOrderDepot__c;
                            rmaUpdate.add(rmaToProcess);
                        }
                        if(rmaToProcess.rmaDontCalculateDepot__c == true && rmaToProcess.rmaOutgoingShipmentOrderProvider__c != oldRMA.rmaOutgoingShipmentOrderDepot__c && rmaToProcess.rmaOutgoingShipmentOrderProvider__c != null && rmaToProcess.rmaOutgoingShipmentOrderProvider__c != ''){
                            rmaToProcess.rmaOutgoingShipmentOrderProvider__c = rmaToProcess.rmaOutgoingShipmentOrderProvider__c;
                            rmaUpdate.add(rmaToProcess);
                        }
                    }
                }
            }
        }
        catch(Exception e){
            system.debug('Caught Error : '+e.getMessage());
        }
        
    }
    
    //Added by exafort(vishnu) for rma SLA NBD override TS-5318 TS-5258 on 18th Jan 2019
    public static void rmaOverrideSLA()
    {
        try{
            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
                for(RMAv2__c rmaToProcess : (List<RMAv2__c>) Trigger.new){
                    if(rmaToProcess.rmaOutgoingShipmentStatus__c.contains('DRAFT-10') ){
                        if(rmaToProcess.rmaPartNumber__c != null){
                            system.debug('INSIDE BEFORE INSERT @@@@');
                            system.debug('### rma part number ===>'+rmaToProcess.rmaPartNumber__c);
                            // toLowerCase() Added by Exafort for SFDC-1260
                            SR_Meta_Data__c srMetaDataRec;
                            if(srMetaDataMap.size() > 0 && rmaToProcess.rmaPartNumber__c != null){
                                srMetaDataRec = srMetaDataMap.get(rmaToProcess.rmaPartNumber__c.toLowerCase());
                            }
                            system.debug('####srMetaDataRec Value @@@@'+srMetaDataRec);
                            if(srMetaDataRec != null && (rmaToProcess.PachinkoCaseType__c == 'ssdwearlevelhigh' || 
                                                         (srMetaDataRec.srPartShipSLAOverride__c == 'NBD & Onsite Override' || srMetaDataRec.srPartShipSLAOverride__c == 'NBD & Onsite Retain'))){
                                                             rmaToProcess.rmaIsNBDOverriden__c = true;
                                                             if(srMetaDataRec.srPartShipSLAOverride__c == 'NBD & Onsite Retain' ){ 
                                                                 rmaToProcess.rmaIsNBDOnsiteRetain__c = true;
                                                                 //rmaToProcess.rmaFireOnsiteValidations__c = true;
                                                             }
                                                             system.debug('INSIDE BEFORE INSERT @@@@');
                                                         }
                            System.debug('#### RMA Contains Onsite ==>'+rmaToProcess.rmaAssetSla__c.contains('Onsite'));
                            System.debug('#### Part Ship SLA Override Value ==>'+srMetaDataRec.srPartShipSLAOverride__c);
                            System.debug('#### Pachinko Case Type ==>'+rmaToProcess.PachinkoCaseType__c);
                            // rmaToProcess.rmaAssetSla__c.contains('2HR') Added by Exafort for TS-10107
                            if(rmaToProcess.rmaAssetSla__c.contains('Onsite') || rmaToProcess.rmaAssetSla__c.contains('2HR')){
                                //TS-6667 START Added by Exafort on August 19 2020
                                if(rmaToProcess.rmaUplift__c == 'Premium Onsite'){
                                    rmaToProcess.rmaFireOnsiteValidations__c = true;
                                }
                                //TS-6667 END Added by Exafort on August 19 2020                               
                                else if(srMetaDataRec.srPartShipSLAOverride__c == 'NBD & Onsite Override'){
                                    rmaToProcess.rmaFireOnsiteValidations__c = false;
                                }
                                else if(srMetaDataRec.srPartShipSLAOverride__c == 'NBD & Onsite Retain' || srMetaDataRec.srPartShipSLAOverride__c == null || rmaToProcess.PachinkoCaseType__c == 'ssdwearlevelhigh' ){
                                    rmaToProcess.rmaFireOnsiteValidations__c = true;
                                }
                                /*else{
rmaToProcess.rmaFireOnsiteValidations__c = true;
}*/
                            }else{
                                rmaToProcess.rmaFireOnsiteValidations__c = false;
                            }

                        }
                    } 
                }
            }
        }
        catch(Exception e){
            system.debug('Caught Error : '+e.getMessage());
        }  
    }
    
    public static void rmaAfterUpdateAddNotesInCase()
    {
        // ####################################################################################################################
        // Start LOGIC TO insert Public Notes in  - Added on 17th Dec 2016 by Azarudeen
        // ####################################################################################################################
        try{
            List<CaseComment> rmaShippedComment = new List<CaseComment>();
            List<CaseComment> rmaTrackingNoUpdateComment = new List<CaseComment>();
            List<CaseComment> rmaETAUpdateComment = new List<CaseComment>();
            List<CaseComment> rmaPartDeliveredComment = new List<CaseComment>();
            List<CaseComment> rmaDeliveryExceptionComment = new List<CaseComment>();
            List<CaseComment> rmaSLAOverrideComment = new List<CaseComment>();
            set<Id> rmaCase = new set<Id>();
            List<Id> RMASLAoverrideUpdateList = new List<Id>();
            List<Id> RMAPartDeliveredUpdateList = new List<Id>();
            List<Id> lstIds = new List<Id>();

            for(RMAv2__c rmaToProcess : (List<RMAv2__c>) Trigger.new){
                if(rmaToProcess.rmaCaseNumber__c != null){
                    rmaCase.add(rmaToProcess.rmaCaseNumber__c);
                }
                
                // Added by Exafort for TS-10419
                RMAv2__c rmaoldrec = (RMAv2__c)Trigger.oldMap.get(rmaToProcess.Id);
                if(rmaToProcess.rmaOutgoingShipmentStatus__c == 'OPEN-10: Ordered, waiting for confirmation' && rmaToProcess.rmaStatus__c == 'Open' &&
                   rmaoldrec.rmaOutgoingShipmentStatus__c != rmaToProcess.rmaOutgoingShipmentStatus__c && rmaToProcess.China_Global_Account_RMA__c == True){
                    lstIds.add(rmaToProcess.Id);
                }
                // End of TS-10419
                
            }
            
            // Added by Exafort for TS-10419
            if(lstIds.size() > 0){
                RmaPDFGeneratorController.processIds(lstIds); 
            }
            // End of TS-10419
            
            List<Case> rmaCases = [select id,CaseNumber, Account.Name  from Case Where Id =: rmaCase];
            for(Case casefromRMA : rmaCases){
                for(RMAv2__c rmaToProcess : (List<RMAv2__c>) Trigger.new){
                    RMAv2__c rmaoldrec = (RMAv2__c)Trigger.oldMap.get(rmaToProcess.Id);
                    if(casefromRMA.Id == rmaToProcess.rmaCaseNumber__c){
                        string trackingURLLink='';
                        if(rmaToProcess.rmaOutgoingShipmentTrackingUrl__c != null){
                            trackingURLLink = rmaToProcess.rmaOutgoingShipmentTrackingUrl__c;
                            trackingURLLink = trackingURLLink.remove('_HL_ENCODED_');
                            trackingURLLink = trackingURLLink.substringBefore('_');
                        }
                        string trackingNumber;
                        string rmaOutShipDateTimeShipped;
                        string rmaOutShipDateTimeEta;
                        string rmaOutgoingShipmentDateDelivered;
                        string noteFor4HrTrackingNumber='';
                        
                        if(rmaToProcess.rmaOutgoingShipmentTrackingNumber__c != null){
                            trackingNumber = rmaToProcess.rmaOutgoingShipmentTrackingNumber__c;
                        }
                        else{
                            trackingNumber = '';
                        }
                        if(rmaToProcess.rmaShipmentSla__c.contains('4')){
                            noteFor4HrTrackingNumber = '\n Note: 4 hr deliveries will not have a tracking number available as these are shipped via courier.';
                        }
                        
                        
                        if(rmaToProcess.rmaOutShipDateTimeShipped__c != null){
                            rmaOutShipDateTimeShipped = rmaToProcess.rmaOutShipDateTimeShipped__c.format();
                        }
                        else{
                            rmaOutShipDateTimeShipped = '';
                        }
                        
                        if(rmaToProcess.rmaOutShipDateTimeEta__c != null){
                            rmaOutShipDateTimeEta = rmaToProcess.rmaOutShipDateTimeEta__c.format();
                        }
                        else{
                            rmaOutShipDateTimeEta = '';
                        }
                        string rmaOutgoingShipmentPartSn = '';
                        if(rmaToProcess.rmaOutgoingShipmentPartSn__c != null){
                            rmaOutgoingShipmentPartSn = rmaToProcess.rmaOutgoingShipmentPartSn__c;
                        }
                        else if(rmaToProcess.rmaOutgoingShipmentPartSn__c == null){
                            if(rmaToProcess.rmaComponentSN__c != null){
                                rmaOutgoingShipmentPartSn = rmaToProcess.rmaComponentSN__c;
                            }
                        }
                        if(rmaToProcess.rmaOutShipDateTimeDelivered__c != null){
                            rmaOutgoingShipmentDateDelivered = rmaToProcess.rmaOutShipDateTimeDelivered__c.format();
                        }
                        else{
                            rmaOutgoingShipmentDateDelivered = '';
                        }
                        if(!rmaoldrec.rmaOutgoingShipmentStatus__c.contains('OPEN-30') &&  rmaToProcess.rmaOutgoingShipmentStatus__c.contains('OPEN-30')){
                            CaseComment addComment = new CaseComment();
                            addComment.ParentId = casefromRMA.id;
                            addComment.IsPublished = False;
                            addComment.CommentBody = ' \n\n RMA Status Update: Shipped \n\n Record: '+rmaToProcess.Name+
                                '\n Status: Shipped \n Case Number: '+
                                casefromRMA.CaseNumber+'\n Shipment Account: '+
                                casefromRMA.Account.Name+'\n Part: '+
                                rmaToProcess.rmaPart__c+'\n Shipment Carrier: '+
                                rmaToProcess.rmaOutgoingShipmentCarrier__c+
                                '\n Shipment Tracking Number: '+
                                trackingNumber+'\n Shipping URL: '+
                                trackingURLLink+ noteFor4HrTrackingNumber +'\n Order Shipment Date/Time: '+
                                rmaOutShipDateTimeShipped+'\n Order Shipment ETA: '+
                                rmaOutShipDateTimeEta+'\n Shipment SLA: '+
                                rmaToProcess.rmaShipmentSla__c+'\n Part Serial Number: '+rmaOutgoingShipmentPartSn;
                            rmaShippedComment.add(addComment);
                        }
                        if(rmaoldrec.rmaOutgoingShipmentStatus__c.contains('OPEN-30') && rmaoldrec.rmaOutgoingShipmentTrackingNumber__c !=  rmaToProcess.rmaOutgoingShipmentTrackingNumber__c  &&  rmaToProcess.rmaOutgoingShipmentTrackingNumber__c != null){
                            CaseComment addComment = new CaseComment();
                            addComment.ParentId = casefromRMA.id;
                            addComment.IsPublished = False;
                            addComment.CommentBody = ' \n\n RMA Status Update: Tracking Number Changed \n\n Record: '+rmaToProcess.Name+
                                '\n Status: Shipped(Tracking Number Changed) \n Case Number: '+
                                casefromRMA.CaseNumber+'\n Shipment Account: '+
                                casefromRMA.Account.Name+'\n Part: '+
                                rmaToProcess.rmaPart__c+'\n Shipment Carrier: '+
                                rmaToProcess.rmaOutgoingShipmentCarrier__c+
                                '\n Shipment Tracking Number: '+
                                trackingNumber+'\n Shipping URL: '+
                                trackingURLLink+'\n Order Shipment Date/Time: '+
                                rmaOutShipDateTimeShipped+'\n Order Shipment ETA: '+
                                rmaOutShipDateTimeEta+'\n Shipment SLA: '+
                                rmaToProcess.rmaShipmentSla__c+'\n Part Serial Number: '+rmaOutgoingShipmentPartSn;
                            rmaTrackingNoUpdateComment.add(addComment);
                        }
                        if(rmaoldrec.rmaOutShipDateTimeEta__c != null && rmaoldrec.rmaOutShipDateTimeEta__c != rmaToProcess.rmaOutShipDateTimeEta__c){
                            CaseComment addComment = new CaseComment();
                            addComment.ParentId = casefromRMA.id;
                            addComment.IsPublished = False;
                            
                            addComment.CommentBody = ' \n\n RMA Status Update: Shipped (ETA Change) \n\n Record: '+rmaToProcess.Name+
                                '\n Status: Shipped (ETA Change) \n Case Number: '+
                                casefromRMA.CaseNumber+'\n Shipment Account: '+
                                casefromRMA.Account.Name+'\n Part: '+
                                rmaToProcess.rmaPart__c+'\n Shipment Carrier: '+
                                rmaToProcess.rmaOutgoingShipmentCarrier__c+
                                '\n Shipment Tracking Number: '+
                                trackingNumber+'\n Shipping URL: '+
                                trackingURLLink+'\n Order Shipment Date/Time: '+
                                rmaOutShipDateTimeShipped+'\n Order Shipment ETA: '+
                                rmaOutShipDateTimeEta+'\n Shipment SLA: '+
                                rmaToProcess.rmaShipmentSla__c+'\n Part Serial Number: '+rmaOutgoingShipmentPartSn;
                            rmaETAUpdateComment.add(addComment);
                        }
                        if(NimbleAutomationLogs.checkRMAPartDeliveredCommentStatus(rmaToProcess) == 'False' && rmaToProcess.rmaOutgoingShipmentAfterShipStatus__c == 'Delivered' && rmaToProcess.rmaOutgoingShipmentStatus__c.contains('Delivered')){
                            CaseComment addComment = new CaseComment();
                            addComment.ParentId = casefromRMA.id;
                            addComment.IsPublished = False;
                            addComment.CommentBody = ' \n\n RMA Status Update: Delivered \n\n Record: '+rmaToProcess.Name+
                                '\n Status: Delivered \n Case Number: '+
                                casefromRMA.CaseNumber+'\n Shipment Account: '+
                                casefromRMA.Account.Name+'\n Part: '+
                                rmaToProcess.rmaPart__c+'\n Shipment Signed For By: '+
                                rmaToProcess.OutgoingShipmentAfterShipSignedBy__c+
                                '\n Order Delivered Date/Time: '+
                                rmaOutgoingShipmentDateDelivered+'\n Shipment SLA: '+
                                rmaToProcess.rmaShipmentSla__c+'\n Part Serial Number: '+rmaOutgoingShipmentPartSn;
                            rmaPartDeliveredComment.add(addComment);
                            //updateComponentInstalledNotesInRMA(rmaToProcess);
                            RMAPartDeliveredUpdateList.add(rmaToProcess.Id);
                        }
                        if(rmaoldrec.rmaOutgoingShipmentAfterShipStatus__c != 'Exception' && rmaToProcess.rmaOutgoingShipmentAfterShipStatus__c == 'Exception'){
                            CaseComment addComment = new CaseComment();
                            addComment.ParentId = casefromRMA.id;
                            addComment.IsPublished = False;
                            addComment.CommentBody = ' \n\n RMA Status Update: Delivery Exception \n\n Record: '+rmaToProcess.Name+
                                '\n Status: Delivery exception - Customer not available or business closed \n Case Number: '+
                                casefromRMA.CaseNumber+'\n Shipment Account: '+
                                casefromRMA.Account.Name+'\n Part: '+
                                rmaToProcess.rmaPart__c+'\n Shipment Signed For By: '+
                                rmaToProcess.OutgoingShipmentAfterShipSignedBy__c+
                                '\n Order Delivered Date/Time: '+
                                rmaOutgoingShipmentDateDelivered+'\n Shipment SLA: '+
                                rmaToProcess.rmaShipmentSla__c+'\n Part Serial Number: '+rmaOutgoingShipmentPartSn;
                            rmaDeliveryExceptionComment.add(addComment);
                        }
                        //Added by exafort(vishnu) to default service parts to NBD Delivery SLA TS-5318 on 18th Jan 2019
                        if(NimbleAutomationLogs.checkRMAPartDeliveredCommentStatus(rmaToProcess) == 'False' && rmaToProcess.rmaIsNBDOverriden__c){
                            CaseComment addComment = new CaseComment();
                            addComment.ParentId = casefromRMA.id;
                            addComment.IsPublished = False;
                            addComment.CommentBody = 'RMA SLA field override for '+rmaToProcess.Name+'\nField:Required Shipment SLA value changed from '+rmaToProcess.rmaAssetSla__c+' to NBD,see http://kcs.nimblestorage.com/doc/3713';
                            rmaSLAOverrideComment.add(addComment);
                            RMASLAoverrideUpdateList.add(rmaToProcess.Id);
                        }
                    }
                }  
            }
            if(rmaShippedComment.size() > 0){
                insert rmaShippedComment;
            } 
            if(rmaTrackingNoUpdateComment.size() > 0){
                insert rmaTrackingNoUpdateComment;
            }
            if(rmaETAUpdateComment.size() > 0){
                insert rmaETAUpdateComment;
            }
            if(rmaPartDeliveredComment.size() > 0){
                insert rmaPartDeliveredComment;
                NimbleAutomationLogs.InsertLogForPartDelivery(RMAPartDeliveredUpdateList);
                //updateComponentInstalledNotesInRMA(RMAPartDeliveredUpdateList);
            }
            if(rmaDeliveryExceptionComment.size() > 0){
                insert rmaDeliveryExceptionComment;
            }
            //Added by exafort(vishnu) to default service parts to NBD Delivery SLA TS-5318 on 18th Jan 2019
            if(rmaSLAOverrideComment.size() > 0){
                insert rmaSLAOverrideComment;
                NimbleAutomationLogs.InsertLogForSLAOverride(RMASLAoverrideUpdateList);
            }
        }
        catch(Exception e){
            System.debug('Exception occured in rmaAfterUpdateAddNotesInCase method of rmaTriggerHandler '+e.getMessage());
        }
        
        // #############################################################################################################
        // END LOGIC TO insert Public Notes in  - Added on 17th Dec 2016 by Azarudeen
        // #############################################################################################################
    }
    
    public void dontAllowOpenRMAToDelete()
    {
        if(trigger.isDelete && trigger.isBefore){
            for(RMAv2__c rmaToProcess : (List<RMAv2__c>)Trigger.old){
                if(rmaToProcess.rmaStatus__c != 'Draft'){
                    rmaToProcess.addError('RMA Cannot be Deleted - Only RMAs with status DRAFT-10 is allowed to delete');
                }
            } 
        }
    }
    /*START - SSD Scheduling - schedule to 14 days from Creation Date
* Date - 17th July 2017
* By - Exafort
* */
    public static void scheduleSSDWear()
    {
        for(RMAv2__c rmaToProcess : (List<RMAv2__c>)Trigger.new){
            if(rmaToProcess.PachinkoCaseType__c == 'ssdwearlevelhigh' && rmaToProcess.rmaDeliveryDateTime__c == null){
                rmaToProcess.rmaDeliveryDateTime__c = System.now().addDays(14);
                rmaToProcess.rmaRequestedDeliveryDateTime__c = string.valueOf(rmaToProcess.rmaDeliveryDateTime__c);
                rmaToProcess.rmaExcludeFromOpsMetrics__c = true;
            }
        }
    }
    
    
    
    // Added by Exafort for TS-10107
    public static boolean isOnsiteSLA(RMAv2__c rmaToProcess){
        system.debug('Entered into the onsite method to return true or false');
		return isOnsiteSLA(rmaToProcess.rmaAssetSla__c, rmaToProcess.rmaUplift__c);     
    }
    // End of TS-10107
    
    // Added by Exafort for TS-10543
    public static boolean isOnsiteSLA(string assetSla, string rmaUpliftSla){
        return (isOnsiteSLA(assetSla) || isOnsiteSLA(rmaUpliftSla));
    }
    
    public static boolean isOnsiteSLA(string sla){
        boolean returnValue = false;
        if (sla != null && (sla.contains('Onsite') || sla.contains('2HR') || 
                            sla.contains('6 Hr CTR') || sla.contains('Critical 2 Hour'))
           )
        {
            returnValue = true;
        }        
		system.debug('isOnsiteSLA returning ' + returnValue);
        return returnValue;
    }
    // End of TS-10543

    /*
     * 	Returns mapkey to help store/retrieve depots in Map for NBD
	*/
    public static string getNbdDepotMapKey(string country, string state, string provider){
		return getNbdDepotMapKey(country, state, provider, null);
    }
    
    public static string getNbdDepotMapKey(string country, string state, string provider, string assetSla){
		string mapKey = '__';
        string providerOverride = provider;
        
        //	For Japan, if Asset SLA has TSC, provider should be TSC. This is a special scenario
        if (country != null && country.toLowerCase().equals('japan') && assetSla != null && assetSla.contains('TSC:')){
            providerOverride = 'TSC';
        }
        
        //	default value for state is 'N/A' and Provider is 'Flash'
        return '__' 
            + (country != null ? country : '')  + '__'
            + (state != null ? state : 'N/A') + '__'
            + (providerOverride != null ? providerOverride : 'Flash') + '__';
    }
}