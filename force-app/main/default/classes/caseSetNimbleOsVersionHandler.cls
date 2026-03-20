public class caseSetNimbleOsVersionHandler extends TriggerHandler {
    public override void beforeInsert() {
        
        for (Case caseTrigger : (List<Case>) trigger.new)
        {
            if(caseTrigger.Nimble_Version__c == null)
            {
                if(caseTrigger.caseAssetNimbleOSVersion__c != null)
                {
                    setNimbleOsVersion(caseTrigger,caseTrigger.caseAssetNimbleOSVersion__c);
                }
                else
                {
                    caseTrigger.Nimble_Version__c = 'Unknown';
                }
            }
            else if(caseTrigger.Nimble_Version__c != null)
            {
                setNimbleOsVersion(caseTrigger,caseTrigger.Nimble_Version__c);
            }
            // Added by exafort for TS-9315
            if(caseTrigger.caseAssetNimbleOSVersion__c != null){
                caseTrigger.Nimble_OS_Version_At_Case_Open__c = getNimbleOsVersion(caseTrigger.caseAssetNimbleOSVersion__c);
            }
            // End of TS-9315
            
        } 
        
    }
    
    public override void beforeUpdate(){
    
        Map<Id,Case> oldAssetMap = (Map<Id,Case>)  trigger.oldMap;
        
        for (Case caseTrigger : (List<Case>)  trigger.new)
        {
            Case oldCase = oldAssetMap.get(caseTrigger.Id);
       
            if(caseTrigger.Nimble_Version__c == null && oldCase.Nimble_Version__c == 'Unknown' && caseTrigger.caseAssetNimbleOSVersion__c ==null)
            {
                //1
                caseTrigger.Nimble_Version__c = 'Unknown';
            }
            else if(caseTrigger.Nimble_Version__c == null && oldCase.Nimble_Version__c == 'Unknown' && caseTrigger.caseAssetNimbleOSVersion__c !=null)
            {
                //2
                setNimbleOsVersion(caseTrigger,caseTrigger.caseAssetNimbleOSVersion__c);
            }
            
            
            else if(caseTrigger.Nimble_Version__c != null && caseTrigger.Nimble_Version__c != 'Unknown' && !UserInfo.getUserName().containsIgnoreCase('supportforce'))
            {
                //3
                setNimbleOsVersion(caseTrigger,caseTrigger.Nimble_Version__c);
            }
            
            
            else if(caseTrigger.Nimble_Version__c == 'Unknown' && oldCase.Nimble_Version__c != 'Unknown' && !UserInfo.getUserName().containsIgnoreCase('supportforce'))
            {
                //4
                caseTrigger.Nimble_Version__c = oldCase.Nimble_Version__c;
            }
            else if(caseTrigger.Nimble_Version__c != null && caseTrigger.Nimble_Version__c != 'Unknown' && oldCase.Nimble_Version__c == 'Unknown' && UserInfo.getUserName().containsIgnoreCase('supportforce'))
            {
                //5
                 setNimbleOsVersion(caseTrigger,caseTrigger.Nimble_Version__c);
            }
            else if(caseTrigger.Nimble_Version__c != null && caseTrigger.Nimble_Version__c != 'Unknown' && oldCase.Nimble_Version__c != 'Unknown'  && UserInfo.getUserName().containsIgnoreCase('supportforce'))
            {
                //6
                 caseTrigger.Nimble_Version__c = oldCase.Nimble_Version__c;
            }
            else
            {
                //7
                caseTrigger.Nimble_Version__c = oldCase.Nimble_Version__c;
            }
            
            // Added by exafort for TS-9315
            if(caseTrigger.AssetId != oldCase.AssetId){
                if(caseTrigger.caseAssetNimbleOSVersion__c == null){
                    caseTrigger.Nimble_OS_Version_At_Case_Open__c = null;
                }
                else{
                    caseTrigger.Nimble_OS_Version_At_Case_Open__c = getNimbleOsVersion(caseTrigger.caseAssetNimbleOSVersion__c);
                }
            }
            // End of TS-9315
        }
        
    }
    
    public void setNimbleOsVersion(Case caseTrigger,string NimbleOsVersion)
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
                caseTrigger.Nimble_Version__c = assetOsMajor + '.' + assetOsMinor + '.' + assetOsSub1 + '.' + assetOsSub2;
            }
            catch(Exception e)
            {
                caseTrigger.Nimble_Version__c = NimbleOsVersion;
            }
        }

    }
    
    /*
     * Added by Exafort for SFDC-649
	 * Extracts and normalizes the Nimble OS version from the given string
     * Trims the input and removes anything after the first space.
     * Uses regex to capture at least 3 version components, with an optional 4th
     * Example:
        "3.2.0 154"         - "3.2.0"
        "5.0.10.0-742719"   - "5.0.10.0"
        "10.4.5.9"          - "10.4.5.9"
        "3.1.4"             - "3.1.4"
      */

    public String getNimbleOsVersion(String NimbleOsVersion) {
        
        if (String.isBlank(NimbleOsVersion)) {
            return null;
        }
        
        //	Trim and cut off anything after a space
        NimbleOsVersion = NimbleOsVersion.trim().split('\\s+')[0];
        
        //	Regex: at least 3 groups, optional 4th
        Pattern osPattern = Pattern.compile('^(\\d+)\\.(\\d+)\\.(\\d+)(?:\\.(\\d+))?');
        Matcher osVersionMatcher = osPattern.matcher(NimbleOsVersion);
        
        if (osVersionMatcher.find()) {
            try {
                String major = osVersionMatcher.group(1);
                String minor = osVersionMatcher.group(2);
                String sub1  = osVersionMatcher.group(3);
                String sub2  = osVersionMatcher.group(4);
                
                if (sub2 != null) {
                    return major + '.' + minor + '.' + sub1 + '.' + sub2;
                } else {
                    return major + '.' + minor + '.' + sub1;
                }
            } catch (Exception e) {
                return null;
            }
        }
        return null;
    }
    
}