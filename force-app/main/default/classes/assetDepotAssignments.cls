public class assetDepotAssignments {
    
    private static Map<String, depotMapNbdNd__c> depotMapNbdNd = new Map<String, depotMapNbdNd__c>();
    private static Map<String, depotMap4Hour__c> depotMap4Hour = new Map<String, depotMap4Hour__c>();
    private static Map<String, List<PostalCode__c>> postalCodeMap = new Map<String, List<PostalCode__c>>();
    private static List<Asset> assetRecords;
    //TS-6902
    //public static List<String> koreaCountryList = new List<String>{'South Korea','Korea','south korea','korea','SOUTH KOREA','KOREA','KOREA, REPUBLIC OF','Korea, Republic Of','korea, republic of'}; 
    public static List<depot__c> koreanActiveDepot = new List<depot__c>();
    public static List<String> koreaCountryList = new List<String>();
    
    public assetDepotAssignments(List<Asset> assetRecordsToProcess)
    {
        assetRecords = assetRecordsToProcess;
    }
    //TS-6902
    public Boolean checkInstallCountry(String assetIstallCountry){
        for(CountryAliases__mdt countryNameMdt: [Select Id,MasterLabel from CountryAliases__mdt]){
            koreaCountryList.add(countryNameMdt.MasterLabel);
        }
        
        if(!koreaCountryList.isEmpty()){
            if(koreaCountryList.contains(assetIstallCountry)){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    //TS-6902
    public void getActiveKoreanDepot(){   
        for(CountryAliases__mdt countryNameMdt: [Select Id,MasterLabel from CountryAliases__mdt]){
            koreaCountryList.add(countryNameMdt.MasterLabel);
        }
        if(!koreaCountryList.isEmpty()){
            koreanActiveDepot = [Select Id,Name,depotCountry__c,depotIsactive__c From depot__c 
                                 where depotCountry__c IN : koreaCountryList AND depotIsactive__c = true]; 
        }
    }
    
    //Bulk - Quering NBDND object with the collected set values
    private void getDepotMapNbdNd(Set<String> sSoqlCountries,Set<String> sSoqlStates)
    {
        //'N/A' is a default value
        sSoqlStates.add('N/A');
        
        for(depotMapNbdNd__c dptMapNbdNd:[SELECT depotMapNbdNd_NbdDepot__r.Name,
                                          depotMapNbdNd_NbdDepot__r.depotProvider__c,
                                          depotMapNbdNd_NdDepot__r.Name,
                                          depotMapNbdNd_NdDepot__r.depotProvider__c,depotMapNbdNdCountry__c,depotMapNbdNdState__c 
                                          FROM   depotMapNbdNd__c
                                          WHERE  depotMapNbdNdCountry__c In :sSoqlCountries and
                                          depotMapNbdNdState__c  In  :sSoqlStates])
        {
            String mapKey = '__' + dptMapNbdNd.depotMapNbdNdCountry__c + '__' + dptMapNbdNd.depotMapNbdNdState__c + '__';
            
            if (!depotMapNbdNd.containsKey(mapKey))             
                depotMapNbdNd.put(mapKey, dptMapNbdNd);
        }
        
    }
    
    //Bulk - Quering 4Hour object with the collected set values
    private void getDepotMap4Hour(Set<String> sTemp4HourKeyPatterns)
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
    
    //Bulk - Quering PostalCode object
    private void getPostalCodeMap()
    {
        List<PostalCode__c> pc = [SELECT Id, pcErrorMessage__c,pcCountry__c,pcFormatInRegex__c,pcDummyPostalCode__c from PostalCode__c order by pcCountry__c];
        for(Integer i=0; i< pc.size(); i++)
        {
            List<PostalCode__c> lstCurrentPc = new List<PostalCode__c>();
            lstCurrentPc.add(pc[i]);
            
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
    
    private string getTrimmedPostalCode(string soqlCountry,string soqlState,string soqlPostalCode)
    {
        
        if(soqlPostalCode != null)
            soqlPostalCode        = soqlPostalCode.toUpperCase();
        else
            return soqlPostalCode;
        
        
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
                    
                    errorPostalCodeMsg = lstPcRecord[i].pcErrorMessage__c;
                    
                    Pattern patternPostalCode  = Pattern.compile(lstPcRecord[i].pcFormatInRegex__c);
                    matcherPostalCode = patternPostalCode.matcher(soqlPostalCode);
                    if (matcherPostalCode.matches())
                    {
                        soqlPostalCode = matcherPostalCode.group(1);
                        Ispassed = true;
                        break;
                    }
                }
                if(Ispassed == false)
                {
                    return soqlPostalCode; 
                }
            }
        }
        
        return soqlPostalCode;
        
    }
    
    public void assetDepotMain()
    {
        Set<String> sSoqlCountries = new Set<String>();
        Set<String> sSoqlStates = new Set<String>();
        Set<String> sTemp4HourKeyPatterns = new Set<String>();
        
        getPostalCodeMap();
        
        for (Asset assetToProcess : assetRecords) {
            
            if(assetToProcess.Install_Country__c != null)
            {
                String soqlCountry = assetToProcess.Install_Country__c;
                if(countryTranslationList__c.getInstance(assetToProcess.Install_Country__c) != null)
                {
                    soqlCountry = countryTranslationList__c.getInstance(assetToProcess.Install_Country__c).ctlTranslationName__c;
                }
                
                String soqlPostalCode = getTrimmedPostalCode(soqlCountry,assetToProcess.Install_State_Province__c,assetToProcess.Install_Zip_Code__c); 
                sSoqlCountries.add(soqlCountry);
                sSoqlStates.add(assetToProcess.Install_State_Province__c);                  
                sTemp4HourKeyPatterns.add('\\_\\_' + soqlCountry + '\\_\\_' + soqlPostalCode + '\\_\\_%');
            }
            
            if(assetToProcess.assetPartShipAddressBook__c != null)
            {
                if(assetToProcess.assetPartShipAddressBook__r.abCountry__c != null)
                {
                    String soqlCountry = assetToProcess.assetPartShipAddressBook__r.abCountry__c;
                    if(countryTranslationList__c.getInstance(assetToProcess.assetPartShipAddressBook__r.abCountry__c) != null)
                    {
                        soqlCountry = countryTranslationList__c.getInstance(assetToProcess.assetPartShipAddressBook__r.abCountry__c).ctlTranslationName__c;
                    }
                    
                    string soqlPostalCode = getTrimmedPostalCode(soqlCountry,assetToProcess.assetPartShipAddressBook__r.abStateProvince__c,assetToProcess.assetPartShipAddressBook__r.abPostalCode__c); 
                    sSoqlCountries.add(soqlCountry);
                    sSoqlStates.add(assetToProcess.assetPartShipAddressBook__r.abStateProvince__c);                  
                    sTemp4HourKeyPatterns.add('\\_\\_' + soqlCountry + '\\_\\_' + soqlPostalCode + '\\_\\_%');
                }
            }
        }
        
        getDepotMapNbdNd(sSoqlCountries,sSoqlStates);        
        getDepotMap4Hour(sTemp4HourKeyPatterns); 
        getActiveKoreanDepot(); //Added by vishnu for TS-6902
        assetAssignDepot(); 
    }
    
    private void assetAssignDepot()
    {
        List<Asset> updAssetList = new List<Asset>();
        for (Asset assetToProcess : assetRecords) {
            string assetSLA = '';
            if(assetToProcess.SLA__c != null)
                assetSLA = assetToProcess.SLA__c;
            
            if (!assetSLA.contains('4 Hour')){
                if(assetToProcess.Install_Country__c != null)
                {  
                    String soqlCountry = assetToProcess.Install_Country__c;
                    if(countryTranslationList__c.getInstance(assetToProcess.Install_Country__c) != null)
                    {
                        soqlCountry = countryTranslationList__c.getInstance(assetToProcess.Install_Country__c).ctlTranslationName__c;
                    }
                    
                    String soqlPostalCode = getTrimmedPostalCode(soqlCountry,assetToProcess.Install_State_Province__c,assetToProcess.Install_Zip_Code__c); 
                    assetToProcess.assetInstallAddressDepot__c = assetDetermineOrderDepot(assetToProcess,soqlCountry,assetToProcess.Install_State_Province__c,soqlPostalCode);
                }
                else
                {
                    assetToProcess.assetInstallAddressDepot__c = null;
                }
                
                if(assetToProcess.assetPartShipAddressBook__c != null)
                {
                    if(assetToProcess.assetPartShipAddressBook__r.abCountry__c != null)
                    {
                        
                        String soqlCountry = assetToProcess.assetPartShipAddressBook__r.abCountry__c;
                        if(countryTranslationList__c.getInstance(assetToProcess.assetPartShipAddressBook__r.abCountry__c) != null)
                        {
                            soqlCountry = countryTranslationList__c.getInstance(assetToProcess.assetPartShipAddressBook__r.abCountry__c).ctlTranslationName__c;
                        }
                        
                        String soqlPostalCode = getTrimmedPostalCode(soqlCountry,assetToProcess.assetPartShipAddressBook__r.abStateProvince__c,assetToProcess.assetPartShipAddressBook__r.abPostalCode__c); 
                        assetToProcess.assetShipmentAddressDepot__c = assetDetermineOrderDepot(assetToProcess,soqlCountry,assetToProcess.assetPartShipAddressBook__r.abStateProvince__c,soqlPostalCode);
                    }
                    else
                    {
                        assetToProcess.assetShipmentAddressDepot__c = null;
                    }
                }
                else
                {

                    assetToProcess.assetShipmentAddressDepot__c = null;
                }
                
                //updAssetList.add(assetToProcess);  
            } 
            else 
            { 
                //for south korean depot mapping-Added by vishnu on 23rd march 2020 - TS-6902
                //	Added by exafort for TS-10717
                if(assetToProcess.Install_Country__c != null && checkInstallCountry(assetToProcess.Install_Country__c)
                   && (assetToProcess.assetInstallAddressDepot__c == 'unknown' || assetToProcess.assetShipmentAddressDepot__c == 'Unknown'
                       || assetToProcess.assetInstallAddressDepot__c == null || assetToProcess.assetShipmentAddressDepot__c == null)){
                           if(assetToProcess.assetPartShipAddressBook__c != null){
                               //	Based on SLA and Country assetInstallAddressDepot__c and assetShipmentAddressDepot__c will be updated
                               assetToProcess.assetInstallAddressDepot__c = Geolocationaddress.getDepotName(assetToProcess.Install_Country__c, assetToProcess.SLA__c, assetToProcess.assetPartShipAddressBook__r.ab4HourDepot__r.Name, assetToProcess.assetPartShipAddressBook__r.ab4HourDepotTsc__r.Name);
                               assetToProcess.assetShipmentAddressDepot__c = Geolocationaddress.getDepotName(assetToProcess.Install_Country__c, assetToProcess.SLA__c, assetToProcess.assetPartShipAddressBook__r.ab4HourDepot__r.Name, assetToProcess.assetPartShipAddressBook__r.ab4HourDepotTsc__r.Name);
                               assetToProcess.assetNearbyDepot__c = Geolocationaddress.getDepotID(assetToProcess.Install_Country__c, assetToProcess.SLA__c, assetToProcess.assetPartShipAddressBook__r.ab4HourDepot__c, assetToProcess.assetPartShipAddressBook__r.ab4HourDepotTsc__c);
                               //	End of TS-10717
                           }else{
                               if(assetToProcess.assetNearbyDepot__c != null){
                                   assetToProcess.assetInstallAddressDepot__c = assetToProcess.assetNearbyDepot__r.Name;
                                   assetToProcess.assetShipmentAddressDepot__c =  assetToProcess.assetNearbyDepot__r.Name;
                               }
                               else if(!koreanActiveDepot.isEmpty() ){
                                   assetToProcess.assetInstallAddressDepot__c = koreanActiveDepot[0].Name;
                                   assetToProcess.assetShipmentAddressDepot__c = koreanActiveDepot[0].Name;
                               }
                           }
                       }else{
                           //Install country is null
                       }
            }
            updAssetList.add(assetToProcess);
        }
        update updAssetList;
    }
    
    private string assetDetermineOrderDepot(Asset assetToProcess,String soqlCountry,String soqlState,String soqlPostalCode)
    {
        // ###########################################
        // BEGIN LOGIC TO DETERMINE  DEPOT
        // ###########################################
          

        String NbdNdMapKey = '__' + soqlCountry + '__' + soqlState + '__';
        //Logic to check the current State is available in depot
        
        if(!depotMapNbdNd.containsKey(NbdNdMapKey))
        {
            //State depot not available - set the default state as 'N/A'
            NbdNdMapKey = '__' + soqlCountry + '__N/A__';
        }
        
        System.debug('++++++++soqlCountry++++++++' + soqlCountry);
        System.debug('++++++++soqlState++++++++' + soqlState);
        System.debug('++++++++NbdNdMapKey++++++++' + NbdNdMapKey);
        
        string assetSLA = '';
        if(assetToProcess.assetParentSLA__c != null)
            assetSLA = assetToProcess.assetParentSLA__c;
        //
        if (assetSLA.contains('4 Hour') && (assetToProcess.Account.Support_Provider__c != null && !assetToProcess.Account.Support_Provider__r.Name.contains('H3C')) && !assetToProcess.Account.Name.contains('H3C'))
        {String tempKeyPattern = '__' + soqlCountry + '__' + soqlPostalCode + '__';
         
         if (depotMap4Hour.containsKey(tempKeyPattern))
         {
             depotMap4Hour__c map4Hour = depotMap4Hour.get(tempKeyPattern);  
             return map4Hour.depotMap4Hour_4HourDepot__r.Name;
         }
         else
         {
             return 'Unknown';
         }
        }
        else if(assetSLA.contains('H3C') || (assetToProcess.Account.Support_Provider__c != null && assetToProcess.Account.Support_Provider__r.Name.contains('H3C')) || assetToProcess.Account.Name.contains('H3C')){
            return 'Unknown';
        }
        else
        {
            if (depotMapNbdNd.containsKey(NbdNdMapKey))
            {
                depotMapNbdNd__c mapNbdNd = depotMapNbdNd.get(NbdNdMapKey);   
                return mapNbdNd.depotMapNbdNd_NbdDepot__r.Name;
            }
            else
            {
                return 'Unknown';
            }
        }
        // #########################################
        // END LOGIC TO DETERMINE DEPOT
        // #########################################   
    }
}