public class assetTriggerSetFieldsHandler {
    //Added by exafort for TS-9266
    public string assetOsMajorLongLenFinal;
    public string assetOsMinorLongFinal;
    public string assetOsSub1LongFinal;
    public string assetOsSub2LongFinal;
    public string nimbleVersionLongTemp;
    public long nimbleVersionLongIntVal; 
    //Added end
    public assetTriggerSetFieldsHandler() {
    }
    
    public List<Asset> setNimbleOsVersion(List<Asset> assets)
    {
        //Pattern osVersionPattern = Pattern.compile('^(\\d*).(\\d*).(\\d*).(\\d*)(.*?)$');
        //Pattern osVersionPattern = Pattern.compile('^(\\d+)\\.(\\d+)\\.(\\d+)(?:[\\.\\-\\s]?(\\d+))?.*$');
         /*
     	  * Added by Exafort for SFDC-649
     	  * Updated osVersionPattern to support versions as below
     	  * Example:
     	  		"3.2.0"
				"5.0.10.0"
          */
        Pattern osVersionPattern = Pattern.compile('^(\\d+)\\.(\\d+)\\.(\\d+)(?:[\\.\\s\\-]+(\\d+))?');

        for (Asset triggerAsset : assets){
            
            if(triggerAsset.Nimble_Version__c != null)
            {
                Matcher osVersionAssetMatcher = osVersionPattern.matcher(triggerAsset.Nimble_Version__c);        
                if (osVersionAssetMatcher.find())
                {
                    try
                    {
                        Integer assetOsMajor = Integer.valueOf(osVersionAssetMatcher.group(1));
                        Integer assetOsMinor = Integer.valueOf(osVersionAssetMatcher.group(2));
                        Integer assetOsSub1  = Integer.valueOf(osVersionAssetMatcher.group(3));
                        Integer assetOsSub2  = 	(osVersionAssetMatcher.group(4) != null)
                            					? Integer.valueOf(osVersionAssetMatcher.group(4))
                            					: 0;
                        
                        triggerAsset.assetNimbleOsVersion__c = 	 assetOsSub2 == 0 ?
                           										 assetOsMajor + '.' + assetOsMinor + '.' + assetOsSub1 :
                       											 assetOsMajor + '.' + assetOsMinor + '.' + assetOsSub1 + '.' + assetOsSub2;
                        
                        //Integer assetOsMajor = Integer.valueOf(osVersionAssetMatcher.group(1));
                        //Integer assetOsMinor = Integer.valueOf(osVersionAssetMatcher.group(2));
                        //Integer assetOsSub1  = Integer.valueOf(osVersionAssetMatcher.group(3));
                        //Integer assetOsSub2  = Integer.valueOf(osVersionAssetMatcher.group(4));
                        //triggerAsset.assetNimbleOsVersion__c = assetOsMajor + '.' + assetOsMinor + '.' + assetOsSub1 + '.' + assetOsSub2;
                        //Added by exafort for TS-9266
                        try{
                            string longOsVersion = getLongOsVersion(assetOsMajor, assetOsMinor, assetOsSub1, assetOsSub2);
                            system.debug('setting to Nimble_Version_Long__c = ' + longOsVersion);
                            triggerAsset.Nimble_Version_Long__c = long.valueOf(longOsVersion);
                        }catch(Exception ex){
                            system.debug('Failure while calculating Nimble_Version_Long__c ' + ex.getMessage());
                            triggerAsset.Nimble_Version_Long__c = null;
                        }
                    }
                    catch(Exception ex)
                    {
                        system.debug('Failure while calculating assetNimbleOsVersion__c ' + ex.getMessage() + ' ' + ex.getStackTraceString());
                        triggerAsset.assetNimbleOsVersion__c = null;
                        triggerAsset.Nimble_Version_Long__c = null;                        
                    }
                } 
            }
            else
            {
                triggerAsset.assetNimbleOsVersion__c = null;
                triggerAsset.Nimble_Version_Long__c = null;                
            }
        }
        return assets;
    }
    //Added by exafort for TS-9266
    private static string getLongOsVersion(integer assetOsMajor, integer assetOsMinor, integer assetOsSub1, integer assetOsSub2){
        if(!isAcceptableVersion(assetOsMajor) || !isAcceptableVersion(assetOsMinor) || !isAcceptableVersion(assetOsSub1) || !isAcceptableVersion(assetOsSub2)){
            system.debug('Not a valid version combo');
            return null;
        }
        string longOsVersion = assetOsMajor +  getLongOsVersion(assetOsMinor, 4) + getLongOsVersion(assetOsSub1, 4) + getLongOsVersion(assetOsSub2, 4);		
        return longOsVersion;
    }
    //Added by exafort for TS-9266
    private static boolean isAcceptableVersion(integer version){
        return (version <= 9999 && version >= 0);
    }
    //Added by exafort for TS-9266
    private static string getLongOsVersion(integer version, integer fitToLength){
        string longOsVersion = null;
        if (version != null){
            longOsVersion = String.valueOf(version).leftPad(fitToLength, '0');
        }
        return longOsVersion;
    }
}