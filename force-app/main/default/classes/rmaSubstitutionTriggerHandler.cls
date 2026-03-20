public class rmaSubstitutionTriggerHandler extends TriggerHandler {
    
    // ###################################################################################################### assetTriggerHandler (constructor)
    public rmaSubstitutionTriggerHandler() {
    }
    
    // ###################################################################################################### beforeInsert
    public override void beforeInsert() {
        processMain();  
    }
    
    // ###################################################################################################### beforeUpdate
    public override void beforeUpdate() {
        processMain();  
    }
    
    public void processMain()
    {
        Set<string> existingOldValues = new Set<string>();
        Set<ID> currrentIDs = new Set<ID>();
        Map<String,List<RMASubstitution__c>> rmaSubtitutionMap = new  Map<String,List<RMASubstitution__c>>();
        
        for(RMASubstitution__c rmaSubstitutionTrigger:(List<RMASubstitution__c>) Trigger.new)
        {
            existingOldValues.add(rmaSubstitutionTrigger.OldValue__c);
            
            if(rmaSubstitutionTrigger.Id != null)
            {
                currrentIDs.add(rmaSubstitutionTrigger.Id);
            }
            
        }
        
        rmaSubtitutionMap = getRmaSubtitutionMap(existingOldValues,currrentIDs);
        
        for(RMASubstitution__c rmaSubstitutionTrigger:(List<RMASubstitution__c>) Trigger.new)
        {
            
            if((rmaSubstitutionTrigger.NimbleOsVersionFrom__c  == rmaSubstitutionTrigger.NimbleOsVersionTo__c)
               || (rmaSubstitutionTrigger.NimbleOsVersionFrom__c != null && rmaSubstitutionTrigger.NimbleOsVersionTo__c == null))
            {
                rmaSubstitutionTrigger.IncludeToNimbleOsInSubstitution__c = false;
            }
            
            if(rmaSubstitutionTrigger.NimbleOsVersionFrom__c != null || rmaSubstitutionTrigger.NimbleOsVersionTo__c != null)
            {
                Integer currentFromOsMajor=0;
                Integer currentFromOsMinor=0;
                Integer currentFromOsSub1=0;
                Integer currentFromOsSub2=0;
                
                Integer currentToOsMajor;
                Integer currentToOsMinor;
                Integer currentToOsSub1;
                Integer currentToOsSub2;
                
                string oldValue = rmaSubstitutionTrigger.OldValue__c; 
                
                //Pattern osVersionPattern = Pattern.compile('^(\\d*).(\\d*).(\\d*).(\\d*)$');
                Pattern osVersionPattern = Pattern.compile('^(\\d*).(\\d*).(\\d*).(\\d*)(.*?)$');
                
                if(rmaSubstitutionTrigger.NimbleOsVersionFrom__c != null)
                {
                    Matcher osVersionAssetMatcher = osVersionPattern.matcher(rmaSubstitutionTrigger.NimbleOsVersionFrom__c);
                    if (osVersionAssetMatcher.find())
                    {
                        try
                        {
                            currentFromOsMajor = Integer.valueOf(osVersionAssetMatcher.group(1));
                            currentFromOsMinor = Integer.valueOf(osVersionAssetMatcher.group(2));
                            currentFromOsSub1  = Integer.valueOf(osVersionAssetMatcher.group(3));
                            currentFromOsSub2  = Integer.valueOf(osVersionAssetMatcher.group(4));
                            rmaSubstitutionTrigger.NimbleOsVersionFrom__c = currentFromOsMajor + '.' + currentFromOsMinor + '.' + currentFromOsSub1 + '.' + currentFromOsSub2;
                        }
                        catch(Exception ex)
                        {
                            rmaSubstitutionTrigger.NimbleOsVersionFrom__c.addError('Nimble Os Version (From) should follow the format Major.Minor.Sub1.Sub2');
                            return;
                        }
                    }
                    else
                    {
                        rmaSubstitutionTrigger.NimbleOsVersionFrom__c.addError('Nimble Os Version (From) should follow the format Major.Minor.Sub1.Sub2');
                        return;
                    }
                }
                
                
                if(rmaSubstitutionTrigger.NimbleOsVersionTo__c != null)
                {
                    Matcher osVersionAssetMatcher = osVersionPattern.matcher(rmaSubstitutionTrigger.NimbleOsVersionTo__c);
                    if (osVersionAssetMatcher.find())
                    {
                        try
                        {
                           currentToOsMajor = Integer.valueOf(osVersionAssetMatcher.group(1));
                           currentToOsMinor = Integer.valueOf(osVersionAssetMatcher.group(2));
                           currentToOsSub1  = Integer.valueOf(osVersionAssetMatcher.group(3));
                           currentToOsSub2  = Integer.valueOf(osVersionAssetMatcher.group(4));
                           rmaSubstitutionTrigger.NimbleOsVersionTo__c = currentToOsMajor + '.' + currentToOsMinor + '.' + currentToOsSub1 + '.' + currentToOsSub2;
                        }
                        catch(Exception ex)
                        {
                            rmaSubstitutionTrigger.NimbleOsVersionTo__c.addError('Nimble Os Version (To) should follow the format Major.Minor.Sub1.Sub2');
                            return;
                        }
                    }
                    else
                    {
                        rmaSubstitutionTrigger.NimbleOsVersionTo__c.addError('Nimble Os Version (To) should follow the format Major.Minor.Sub1.Sub2');
                        return;
                    }
                }
                
                
                if(rmaSubstitutionTrigger.NimbleOsVersionFrom__c != null && rmaSubstitutionTrigger.NimbleOsVersionTo__c != null)
                {
                    if((currentFromOsMajor > currentToOsMajor) ||
                       (currentFromOsMajor == currentToOsMajor && currentFromOsMinor > currentToOsMinor) || 
                       (currentFromOsMajor == currentToOsMajor && currentFromOsMinor == currentToOsMinor && currentFromOsSub1 > currentToOsSub1) ||
                       (currentFromOsMajor == currentToOsMajor && currentFromOsMinor == currentToOsMinor && currentFromOsSub1 == currentToOsSub1 && currentFromOsSub2 > currentToOsSub2 ))
                    {
                        rmaSubstitutionTrigger.addError('Nimble Os Version (To) cannot be lesser than Nimble Os Version (From)');
                        return;
                    }
                }
                
                if(rmaSubtitutionMap.size() > 0)
                {
                    checkNimbleOsVersion(oldValue,currentFromOsMajor,currentFromOsMinor,currentFromOsSub1,currentFromOsSub2,rmaSubstitutionTrigger,rmaSubtitutionMap);  
                    checkNimbleOsVersion(oldValue,currentToOsMajor,currentToOsMinor,currentToOsSub1,currentToOsSub2,rmaSubstitutionTrigger,rmaSubtitutionMap);     
                }
            }
            else
            {
                rmaSubstitutionTrigger.IncludeToNimbleOsInSubstitution__c = false;
            }
        }
    }
    
    public static void checkNimbleOsVersion(string currentPart,Integer currentOsMajor, Integer currentOsMinor,Integer currentOsSub1,Integer currentOsSub2,RMASubstitution__c rmaSubstitutionTrigger,Map<String,List<RMASubstitution__c>> rmaSubtitutionMap)
    {  

        Pattern osVersionPattern = Pattern.compile('^(\\d*).(\\d*).(\\d*).(\\d*)$');

        system.debug('+++currentOsMajor+++' + currentOsMajor);
        system.debug('+++currentOsMinor+++' + currentOsMinor);
        system.debug('+++currentOsSub1+++' + currentOsSub1);
        system.debug('+++currentOsSub2+++' + currentOsSub2);
        system.debug('+++rmaSubtitutionMap+++' + rmaSubtitutionMap.size());
        
        for(RMASubstitution__c rmaSubstitution:rmaSubtitutionMap.get(currentPart))
        {
              Integer fromOsMajor=0,toOsMajor;
              Integer fromOsMinor=0,toOsMinor;
              Integer fromOsSub1=0,toOsSub1;
              Integer fromOsSub2=0,toOsSub2;
            
            if(rmaSubstitution.IsOsVersionNull__c == false)
            {
                if(rmaSubstitution.NimbleOsVersionFrom__c != null)
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
                    if(currentOsMajor == fromOsMajor && currentOsMinor == fromOsMinor && currentOsSub1 == fromOsSub1 && currentOsSub2 == fromOsSub2)
                    {
                        rmaSubstitutionTrigger.addError('Conflict occured in boundary condition. Please refer all the existing substution values for  ' + rmaSubstitution.OldValue__c);
                        return;
                    }
                }
                else if(rmaSubstitution.NimbleOsVersionTo__c != null)
                {
                    system.debug('+++block 2+++');
                    if(((currentOsMajor > fromOsMajor) ||
                        (currentOsMajor == fromOsMajor && currentOsMinor > fromOsMinor) || 
                        (currentOsMajor == fromOsMajor && currentOsMinor == fromOsMinor && currentOsSub1 > fromOsSub1) ||
                        (currentOsMajor == fromOsMajor && currentOsMinor == fromOsMinor && currentOsSub1 == fromOsSub1 && currentOsSub2 > fromOsSub2 && rmaSubstitutionTrigger.IncludeToNimbleOsInSubstitution__c==false ) ||
                        (currentOsMajor == fromOsMajor && currentOsMinor == fromOsMinor && currentOsSub1 == fromOsSub1 && currentOsSub2 >= fromOsSub2 && rmaSubstitutionTrigger.IncludeToNimbleOsInSubstitution__c==true ))
                       &&
                       
                       ((currentOsMajor < toOsMajor) ||
                        (currentOsMajor == toOsMajor && currentOsMinor < toOsMinor) ||  
                        (currentOsMajor == toOsMajor && currentOsMinor == toOsMinor && currentOsSub1 < toOsSub1) ||
                        (currentOsMajor == toOsMajor && currentOsMinor == toOsMinor && currentOsSub1 == toOsSub1 && currentOsSub2 < toOsSub2 && rmaSubstitution.IncludeToNimbleOsInSubstitution__c==false) || 
                        (currentOsMajor == toOsMajor && currentOsMinor == toOsMinor && currentOsSub1 == toOsSub1 && currentOsSub2 <= toOsSub2 && rmaSubstitution.IncludeToNimbleOsInSubstitution__c==true))) 
                        
                    {
                       rmaSubstitutionTrigger.addError('Conflict occured in boundary condition. Please refer all the existing substution values for  ' + rmaSubstitution.OldValue__c);
                       return;
                    }
                }
                else if(rmaSubstitution.NimbleOsVersionFrom__c != null)
                {
                    system.debug('+++block 3+++');
                    if((currentOsMajor > fromOsMajor) ||
                       (currentOsMajor == fromOsMajor && currentOsMinor > fromOsMinor) || 
                       (currentOsMajor == fromOsMajor && currentOsMinor == fromOsMinor && currentOsSub1 > fromOsSub1) ||
                       (currentOsMajor == fromOsMajor && currentOsMinor == fromOsMinor && currentOsSub1 == fromOsSub1 && currentOsSub2 >= fromOsSub2 ))
                    {
                        rmaSubstitutionTrigger.addError('Conflict occured in boundary condition. Please refer all the existing substution values for  ' + rmaSubstitution.OldValue__c);
                       return;
                    }
                }
            }
        }
        
    }

    public Map<String,List<RMASubstitution__c>>  getRmaSubtitutionMap(set<string> existingOldValues,set<Id> currrentIDs)
    {
        Map<String,List<RMASubstitution__c>> rmaSubtitutionMap = new  Map<String,List<RMASubstitution__c>>();
        for(RMASubstitution__c  rmaSubtitution: [Select OldValue__c,IsOsVersionNull__c,NimbleOsVersionTo__c,NimbleOsVersionFrom__c,NewValue__c,IncludeToNimbleOsInSubstitution__c,BoundaryFormula__c from RMASubstitution__c where OldValue__c  IN: existingOldValues and Id not in:currrentIDs and IsOsVersionNull__c=false])
        {
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
        
        return rmaSubtitutionMap;
    }
    
    
    
    
}