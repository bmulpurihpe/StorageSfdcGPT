global class srMetaDataPopulationBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    
    global Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByGuidMapCache = new Map<String,ArenaPLMItemObjectWrapper.Results>(); 
    global Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByNumberMapCache = new Map<String,ArenaPLMItemObjectWrapper.Results>();
    global final String Query;
    global Integer batchProcessedCount = 0;
    global String batchArenaSessionId;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,srPart__c,srType__c from SR_Meta_Data__c');
    }
    
    global void execute(Database.BatchableContext BC, List<SR_Meta_Data__c>  srMetaDataRecord)
    {
        Map<string,SR_Meta_Data__c> existingSrMetaData = new Map<string,SR_Meta_Data__c>();
        
        List<Asset> assetErrorRecord = new List<Asset>();
        
        for(SR_Meta_Data__c srMetaData : srMetaDataRecord)
        {
            existingSrMetaData.put(srMetaData.srPart__c,srMetaData);
        }
        
        ArenaPLMCallouts arenaCallouts = new ArenaPLMCallouts(batchProcessedCount,arenaItemByGuidMapCache,arenaItemByNumberMapCache,batchArenaSessionId, assetErrorRecord);
        arenaItemByGuidMapCache = arenaCallouts.getArenaItemsByGuidMap();
        arenaItemByNumberMapCache = arenaCallouts.getArenaItemsByNumberMap();
        batchArenaSessionId = arenaCallouts.getArenaSessionId();
        
        System.debug('+++++++ arenaItemByGuidMapCache.size()+++++++++' + arenaItemByGuidMapCache.size());
        System.debug('+++++++ arenaItemByNumberMapCache.size()+++++++++' + arenaItemByNumberMapCache.size());
        
        List<SR_Meta_Data__c> lstMetaData = new List<SR_Meta_Data__c>();
        for(String key : arenaItemByNumberMapCache.keySet())
        {
            if(key != null)
            {
                SR_Meta_Data__c srMetaData;
                if(existingSrMetaData.containsKey(key))
                {
                    srMetaData = new SR_Meta_Data__c(Id=existingSrMetaData.get(key).Id);
                }
                else
                {
                    srMetaData = new SR_Meta_Data__c();
                }
                
                
                srMetaData.srDescription__c = arenaItemByNumberMapCache.get(key).name;
                
                system.debug('+++++++++++++ Key +++++++++++++++' + Key);
                
                if(Key.StartsWith('SR-'))
                {
                    srMetaData.srPart__c = Key;
                    Key = Key.toUpperCase();
                    if(Key.contains('-CHASSIS-') || Key.contains('-CHA-'))
                        srMetaData.srType__c = 'Chassis';
                    else if(Key.contains('-CONT-'))
                        srMetaData.srType__c = 'Controller';
                    else if(Key.contains('-CABLE-'))
                        srMetaData.srType__c = 'CABLE';
                    else if(Key.contains('-PWR-'))
                        srMetaData.srType__c = 'PWR(power supply)';
                    else if(Key.contains('-SSD-'))
                        srMetaData.srType__c = 'SSD';
                    else if(Key.contains('-HDD-'))
                        srMetaData.srType__c = 'HDD';
                    else if(Key.contains('-USB') || Key.contains('-USB-') )
                        srMetaData.srType__c = 'USB';
                    else if(Key.contains('-PCI-'))
                        srMetaData.srType__c = 'NIC_CARD';
                    else if(Key.contains('-NIC-'))
                        srMetaData.srType__c = 'NIC';
                    else if(Key.contains('-KIT-'))
                        srMetaData.srType__c = 'SPARES(spare parts kit)';
                    else if(Key.contains('-PCORD-'))
                        srMetaData.srType__c = 'CORD';
                    else if(Key.contains('-BEZEL-'))
                        srMetaData.srType__c = 'BEZEL';
                    else if(Key.contains('-NVRAM-'))
                        srMetaData.srType__c = 'NVRAM';
                    
                    else if(Key.contains('-SASCABLE-'))
                        srMetaData.srType__c = 'CABLE';
                    
                    
                    
                    lstMetaData.add(srMetaData);  
                }
            }
            
        }
        
        Database.upsert(lstMetaData,false);
        
    }   
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    
    
}