public class ArenaPLMCallouts {
    
    public static String baseUrl = 'https://api.arenasolutions.com/v1'; // Base URL of the Arena 
    public static String sessionId{get;set;} // Arena PLM access_token is for use the subsequenet request
    public static string arenaPLMLoginInstance = 'Arena PLM Login'; //Custom Setting Instance in SFDC for Arena PLM login 
    public static Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByGuidMap = new Map<String,ArenaPLMItemObjectWrapper.Results>(); //Map stores the Arena PLM Item Guid as Key and its respective values
    public static Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByNumberMap = new Map<String,ArenaPLMItemObjectWrapper.Results>(); //Map stores the Arena PLM Number as Key and its respective values
    public static boolean arenaServerError = false;
    public static string arenaServerErrorMsg;
    //###################################################################################################### arenaPLMCallouts
    public  ArenaPLMCallouts(Integer batchProcessedCount,Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByGuidMapCache , Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByNumberMapCache,string batchSessionId, List<Asset> assetErrorResponse){
        
        Integer queryOffset = 0;
        
        if((batchProcessedCount == 0) ||(math.mod(batchProcessedCount,5)) == 0 || batchSessionId == null)
        {
            arenaLogin(assetErrorResponse);
            batchSessionId = sessionId;
        }
        
        if((arenaItemByGuidMapCache.size() == 0 || arenaItemByNumberMapCache.size() == 0) && batchSessionId != null)
        {
            getAllArenaItem(queryOffset, assetErrorResponse);
            arenaItemByGuidMapCache = getArenaItemsByGuidMap();
            arenaItemByNumberMapCache = getArenaItemsByNumberMap();  
        }
        else
        {
            setArenaPLMInstanceVariables(arenaItemByGuidMapCache,arenaItemByNumberMapCache,batchSessionId);
        }
    }
    
    //###################################################################################################### LoginArenaPLMWrapper
    public class LoginArenaPLMWrapper{
        public string arenasessionId;
        public string workspaceId;
        public string workspaceName;
    }
    
    //###################################################################################################### arenaLogin
    public void arenaLogin(List<Asset> assetErrorResponse)
    {
        if(ArenaPLM__c.getInstance(ArenaPLMLoginInstance) != null)
        {
            
            //Make a Call to Arena API to Login and it returns "Access Token"
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            string responseHandler;
            
            //Arena Login Credentials
            string username = ArenaPLM__c.getInstance(ArenaPLMLoginInstance).UserName__c;
            string password = ArenaPLM__c.getInstance(ArenaPLMLoginInstance).Password__c;
            
            System.debug('+++++++++username+++++++++++' + username);
            System.debug('+++++++++password+++++++++++' + password);
            
            
            request.setHeader('Content-Type', 'application/json;');
            request.setEndpoint(baseUrl + '/login');
            request.setMethod('POST');
            String requestBody = '{"email":"'+username+'", "password":"'+password+'"}';
            request.setBody(requestBody);
            
            response = http.send(request);
            if(response.getStatusCode() == 200)
            {
                responseHandler = response.getBody();
                LoginArenaPLMWrapper loginObject = (LoginArenaPLMWrapper)JSON.deserialize(responseHandler,LoginArenaPLMWrapper.class);
                sessionId = loginObject.arenaSessionId; 
                System.debug('+++++++++Arena Logic Successfull - Session Id+++++++++++' + sessionId);
            }
            else{
                arenaServerError = true;
                if(assetErrorResponse.size() > 0){
                    for(Asset assetRec : assetErrorResponse){
                        assetRec.assetComponentProcessedMessage__c = response.toString();
                        arenaServerErrorMsg = assetRec.assetComponentProcessedMessage__c;
                    }
                }
                
            }
           
        }
        else
        {
            System.debug('+++++++++ Error: Login details does not exist in Custom Settings +++++++++');
        }       
    }
    
    
    private HttpResponse httpGetMethodCallouts(string url)
    {
       
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        
        request.setHeader('Content-Type', 'application/json;');
        //Use the session Id which is received from Arena Login
        if(sessionid != null){
            request.setHeader('arena_session_id',sessionid);
        }        
        request.setMethod('GET');
        //Search Arena PLM by the respective REST url
        request.setEndpoint(url);
        
        try{
            response = http.send(request);
            return response;
        }
        catch(System.CalloutException e){
            system.debug('This is catch block');
            system.debug('httpcalloutmethod -----> catch block'+e.getMessage());
            return null;
        }
    
    }
    
    
    //###################################################################################################### getAllArenaItem
    public void getAllArenaItem(Integer queryOffset, List<Asset> assetErrorResponse)
    {
        List<Asset> assetErrorUpdate = new List<Asset>();
        Integer queryLimit = 400;
        HttpResponse response = new HttpResponse();
        try{
            response = httpGetMethodCallouts(baseUrl + '/items?limit='+QueryLimit+'&offset='+queryOffset);
            
            if(response.getStatusCode() == 200)
            {
                string jsonResult = response.getBody();
                //Number is the resevered keywork in SFDC, to over come the limination, number is replaced to number__x
                jsonResult = jsonResult.replace('"number":', '"number_x":');
                
                ArenaPLMItemObjectWrapper arenaPLMItemObject = ArenaPLMItemObjectWrapper.parse(jsonResult); 
                List<ArenaPLMItemObjectWrapper.Results> arenaPLMItemResults   = arenaPLMItemObject.results;
                if(ArenaPLMItemResults.size() > 0)
                {
                    for(ArenaPLMItemObjectWrapper.Results Item:arenaPLMItemResults)
                    {
                        arenaItemByGuidMap.put(Item.guid,Item);
                        
                        if(Item.number_x != null)
                        {
                            if(Item.number_x.contains('PBOM-'))
                            {
                                arenaItemByNumberMap.put(Item.number_x.ToUpperCase(),Item);
                            }
                            else
                            {
                                arenaItemByNumberMap.put(Item.number_x,Item);
                            }
                        }
                        
                    }
                    
                    if(arenaPLMItemObject.count != 0)
                    {
                        queryOffset = queryOffset + queryLimit;
                        getAllArenaItem(queryOffset, assetErrorResponse);
                    }
                }
            }else{
                arenaServerError = true;
                if(assetErrorResponse.size() > 0){
                    for(Asset assetRec : assetErrorResponse){
                        assetRec.assetComponentProcessedMessage__c = response.tostring();
                        arenaServerErrorMsg = assetRec.assetComponentProcessedMessage__c;
                    }
                }
            }
        }
        catch(Exception e){
            if(assetErrorResponse.size() > 0){
                for(Asset assetRec : assetErrorResponse){
                    assetRec.assetComponentProcessedMessage__c = response.tostring();
                    arenaServerErrorMsg = assetRec.assetComponentProcessedMessage__c;
                }
            }
        }
        
        System.debug('++++++++++arenaItemGuidMapCache++++++++++++++' + arenaItemByGuidMap.size());
        System.debug('++++++++++arenaItemNumberMapCache++++++++++++++' + arenaItemByNumberMap.size());
    }
    
    //###################################################################################################### getArenaItemsByGuidMap
    public Map<String,ArenaPLMItemObjectWrapper.Results>  getArenaItemsByGuidMap()
    {
        return arenaItemByGuidMap;
    }
    
    //###################################################################################################### getArenaItemsByNumberMap
    public Map<String,ArenaPLMItemObjectWrapper.Results> getArenaItemsByNumberMap()
    {
        return arenaItemByNumberMap;
    }
    
    //###################################################################################################### getArenaItemsByNumberMap
    public String getArenaSessionId()
    {
        return sessionId;
    }
    
    //###################################################################################################### setArenaItemsMapCaches
    public void setArenaPLMInstanceVariables(Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByGuidMapCache,Map<String,ArenaPLMItemObjectWrapper.Results> arenaItemByNumberMapCache,string batchLoginSessionId)    {
        arenaItemByGuidMap = arenaItemByGuidMapCache;
        arenaItemByNumberMap = arenaItemByNumberMapCache;
        sessionId =batchLoginSessionId;
    }
    
    //###################################################################################################### getArenaBOMofItemMap
    public Map<String,List<ArenaItemWrapper>> getArenaBomOfItemsByItemNumber(Set<String> arenaItemNumbersToProcess,Map<String,List<ArenaItemWrapper>> arenaItemOfBomMapCache,set<String> assetLowerSerialItems, List<Asset> assetErrorResponse)
    {
        for(string itemNumberToProcess : arenaItemNumbersToProcess)
        {
            if(itemNumberToProcess != null)
                itemNumberToProcess = itemNumberToProcess.toUpperCase();
            
            System.debug('++++++++++itemNumber++++++++++++++' + itemNumberToProcess);
            if(!arenaItemOfBomMapCache.containsKey(itemNumberToProcess))
            {
                ArenaPLMItemObjectWrapper.Results  arenaPLMItemObjectResults = arenaItemByNumberMap.get(itemNumberToProcess);
                
                if(arenaPLMItemObjectResults != null)
                {
                    string itemGuid = arenaPLMItemObjectResults.guid;
                    System.debug('++++++++++itemGuid++++++++++++++' + itemGuid);
                    
                    Map<String,List<ArenaItemWrapper>> processItemOfBomMap  =  getBOMOfItemsFromArena(itemGuid, itemNumberToProcess,assetLowerSerialItems, assetErrorResponse);
                    
                    if(processItemOfBomMap.size() > 0)
                        arenaItemOfBomMapCache.putAll(processItemOfBomMap);
                }
            }
        }
        System.debug('++++++++++arenaItemOfBomMapCache++++++++++++++' + arenaItemOfBomMapCache);
        return arenaItemOfBomMapCache;
    }
    
    //###################################################################################################### getBOMOfItemsFromArena
    public Map<String,List<ArenaItemWrapper>> getBOMOfItemsFromArena(string itemGuid,string ItemNumber,set<String> assetLowerSerialItems, List<Asset> assetErrorResponse){
        
        Map<String,List<ArenaItemWrapper>> arenaItemOfBomMap = new Map<String,List<ArenaItemWrapper>>(); //arenaItemOfBomMapCache consist of one Item and its BOM Items (Child Items Information)
        List<ArenaItemWrapper> arenaItemOfBomList = new List<ArenaItemWrapper>(); // Child Item List from BOM
        
        //Query the BOM object in Arena PLM using the Item Guid to receive the BOM information of the Item
        //For example for an Item - there can be 1 or more BOM Items (Child Items)
        HttpResponse response = new HttpResponse();
        response = httpGetMethodCallouts(baseUrl + '/items/'+ itemGuid + '/bom');
        
        
        if(response.getStatusCode() == 200)
        {
            ArenaPLMBOMObjectWrapper ArenaPLMBOMObject = ArenaPLMBOMObjectWrapper.parse(response.getBody()); 
            List<ArenaPLMBOMObjectWrapper.Results> ArenaPLMBOMResults   = ArenaPLMBOMObject.results;
            System.debug('++++++++++++ArenaPLMBOMResults++++++++++++' + ArenaPLMBOMResults);
            
            if(ArenaPLMBOMResults.size() > 0)
            {
                //Loop through all BOM Items (to get the GUID of the Child Items)
                for(ArenaPLMBOMObjectWrapper.Results BomRecord: ArenaPLMBOMResults){
                    
                    System.debug('++++++++++++ Child Item guid ++++++++++++' + BomRecord.Item.guid);
                    
                    ArenaPLMItemObjectWrapper.Results  arenaPLMItemObjectResults = arenaItemByGuidMap.get(BomRecord.Item.guid);
                    
                    if(arenaPLMItemObjectResults != null)
                    {
                    //Child Item must be picked only the lifecycle Phase is in "In Production"
                    if(arenaPLMItemObjectResults.lifecyclePhase.name == 'In Production' || assetLowerSerialItems.contains(arenaPLMItemObjectResults.number_x))
                    {
                        ArenaItemWrapper  arenaItemOfBom = new ArenaItemWrapper(arenaPLMItemObjectResults.number_x,BomRecord.Quantity,arenaPLMItemObjectResults.lifecyclePhase.name);
                        arenaItemOfBomList.add(arenaItemOfBom);
                    }
                    }
                    
                }  
            }
            arenaItemOfBomMap.put(itemNumber,arenaItemOfBomList);
        }
        else
        {
            arenaItemOfBomMap.put(itemNumber,null);
            arenaServerError = true;
            if(assetErrorResponse.size() > 0){
                for(Asset assetRec : assetErrorResponse){
                    assetRec.assetComponentProcessedMessage__c = response.toString();
                    arenaServerErrorMsg = assetRec.assetComponentProcessedMessage__c;
                }
            }
        }
        
        
        return arenaItemOfBomMap;
    }   
    
    //###################################################################################################### getBOMOfItemFromArena
    public Map<String,String> getWhereUsedItemFromArena(string itemNumber, List<Asset> assetErrorResponse){
        
        //Query the Where Used object in Arena PLM using the Item Guid to receive the information of the Item
        HttpResponse response = new HttpResponse();
        Map<String,String> arenaWhereUsedItem = new Map<String,String>();
        
        ArenaPLMItemObjectWrapper.Results  arenaPLMItemObjectResult = arenaItemByNumberMap.get(itemNumber);
        
        if(arenaPLMItemObjectResult == null)
        {
            arenaWhereUsedItem.put(itemNumber, 'Does not Exist');
            return arenaWhereUsedItem;
        }
        
        string itemGuid = arenaPLMItemObjectResult.guid;
        
        response = httpGetMethodCallouts(baseUrl + '/items/'+ itemGuid + '/whereused');
        
            if(response.getStatusCode() == 200)
            {
                ArenaPLMWhereUsedObjectWrapper arenaPLMWhereUsedObject = ArenaPLMWhereUsedObjectWrapper.parse(response.getBody()); 
                List<arenaPLMWhereUsedObjectWrapper.Results> ArenaPLMWhereUsedResults   = arenaPLMWhereUsedObject.results;
                
                if(ArenaPLMWhereUsedResults.size() > 0)
                {
                    Integer noOfRecordsReturned = arenaPLMWhereUsedObject.count;
                    
                    System.debug('++++++++++++ No Of Records Returned for where Used object ++++++++++++' + noOfRecordsReturned);
                    
                    //Loop through all BOM Items (to get the GUID of the Child Items)
                    for(arenaPLMWhereUsedObjectWrapper.Results whereUsedRecord: ArenaPLMWhereUsedResults){
                        
                        //System.debug('++++++++++++ whereUsedRecord Child Item guid ++++++++++++' + whereUsedRecord.Item.guid);
                        
                        ArenaPLMItemObjectWrapper.Results  arenaPLMItemObjectResults = arenaItemByGuidMap.get(whereUsedRecord.Item.guid);
                        
                        //System.debug('++++++++++++ arenaPLMItemObjectResults ++++++++++++' + arenaPLMItemObjectResults);
                        
                        if(arenaPLMItemObjectResults != null)
                        {
                            //Child Item must be picked only the lifecycle Phase is in "In Production"
                            if(arenaPLMItemObjectResults.number_x.contains('SR-') && arenaPLMItemObjectResults.lifecyclePhase.name == 'In Production')
                            {
                                arenaWhereUsedItem.put(itemNumber,arenaPLMItemObjectResults.number_x);
                                break;
                            }
                        }
                        
                    }
                }
                
                if(arenaWhereUsedItem.size() == 0)
              {
                   arenaWhereUsedItem.put(itemNumber, 'Does not Exist');
              }
            }
        else{
            arenaServerError = true;
            if(assetErrorResponse.size() > 0){
                for(Asset assetRec : assetErrorResponse){
                    assetRec.assetComponentProcessedMessage__c = response.toString();
                    arenaServerErrorMsg = assetRec.assetComponentProcessedMessage__c;
                }
            }
        }


        return arenaWhereUsedItem;
    } 
    
    public Class ArenaItemWrapper{
        public string arenaChildItemNumber;
        public double arenaQuantity;
        public string arenaLifeCyclePhase;
        
        public ArenaItemWrapper(string childItemNumber,double quantity,string lifeCyclePhase)
        {
            arenaChildItemNumber = childItemNumber;
            arenaQuantity = quantity;
            arenaLifeCyclePhase=lifeCyclePhase;
        }
    }
}