/*                              <<<< === Batch Apex === >>>>
    =============================================================================================================
        Name                    : AfterShipTrackingBatch
        Description             : To insert the RMA outgoing shipment details in AfterShip.com's Tracking and AfterShipTracking__c
        Created Date            : 19/05/2015
        Author                  : Komathipriya
        Version                 : 1.0
        Modification History    : Initial Version 
    ==============================================================================================================
*/
global class AfterShipTrackingBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts,Database.Stateful
{
    global string query;
    global string strTrackingNumber,strCourier,strOrderID,strCustomerName,strEmail;
    global Set<String> setTrackingNumber = new Set<String>();
    global Set<String> setErrorTrackingNumber = new Set<String>();
    AfterShipTracking__c objAfterShipTracking = new AfterShipTracking__c();
    global string TrackingStatus;
    global  Map<string,ID> mapAllTrackingDetails = new Map<string,ID>();
    global  Map<string,string> mapTrackingCreatedTime = new Map<string,string>();
    global  Map<string,string> mapAllTrackingIDs = new Map<string,string>(); 
    global string strTrackingCreatedTime = string.valueof(system.now());
    global List<string> lstAfterShipCarrier = new List<string>(); 
    
    public static string TestResponse{
    get{
        
        return TestResponse;
    }
    set{
        System.assert(Test.isRunningTest(),'This property may only be set in tests');
        TestResponse = value;
        }
    }
    global AfterShipTrackingBatch()
    {
        system.debug(' @@ YESTERDAY' +  Date.Today().addDays(-1));
        DateTime currTime = System.now();
        DateTime Before = currTime.addDays(-1);
        string blank = '';
        //get the Tracking number with Track Status in a SET
        for(AfterShipTracking__c Track : [Select astTrackingNumber__c from AfterShipTracking__c Where astTrackingCreatedinAfterShip__c = TRUE])
           setTrackingNumber.add(Track.astTrackingNumber__c);
        
        for(AfterShipTracking__c Track : [Select astTrackingNumber__c,astTrackingErrorMessage__c  from AfterShipTracking__c Where astTrackingErrorMessage__c != null and astTrackingCreatedinAfterShip__c = FALSE])
           setErrorTrackingNumber.add(Track.astTrackingNumber__c);
           
        //get the AfterShipTracking ID for each tracking number
        for(AfterShipTracking__c Track:[select ID,astTrackingNumber__c,astTrackingStatus__c from AfterShipTracking__c])
        {
           mapAllTrackingDetails.put(Track.astTrackingNumber__c,Track.ID);            
        }
        system.debug(' @@ setTrackingNumber' + setTrackingNumber);
        
        //taking the List of AfterShip Courier from the custom settings.
         
         List<AfterShipCarrierList__c> lstASC = AfterShipCarrierList__c.getall().values();
         for(AfterShipCarrierList__c objASCL : lstASC)
         {
             lstAfterShipCarrier.add(objASCL.Carrier__c.toLowerCase());
         }
         system.debug('@@ setTrackingNumber  ' + setTrackingNumber + '@@ setErrorTrackingNumber ' + setErrorTrackingNumber);


    }
    global database.querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([select ID,Name,rmaOutgoingShipmentTrackingNumber__c,rmaOutShipProviderOrderNumber__c,rmaOutgoingShipmentCarrier__c,rmaShipmentPhone__c,rmaShipmentEmail__c,CreatedDate,rmaShipmentCountry__c,rmaShipmentAttn__c  from RMAv2__c where rmaOutgoingShipmentTrackingNumber__c != '' and rmaOutgoingShipmentTrackingNumber__c NOT IN :setTrackingNumber and rmaOutgoingShipmentTrackingNumber__c NOT IN :setErrorTrackingNumber and rmaOutgoingShipmentCarrier__c IN :lstAfterShipCarrier and rmaOutgoingShipmentAfterShipStatus__c = '' and lastmodifieddate = LAST_N_DAYS:3]);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        system.debug('@@ scope' + scope);
        List<AfterShipTracking__c> lstAfterShipTracking = new List<AfterShipTracking__c>();
        for(sObject s:scope)
        {
            RMAv2__c objRMA = (RMAv2__c)s;
            if(!mapAllTrackingDetails.containsKey(objRMA.rmaOutgoingShipmentTrackingNumber__c))
            {
                //To insert in the AfterShipTracking object
                objAfterShipTracking = new AfterShipTracking__c();
                objAfterShipTracking.astTrackingNumber__c = objRMA.rmaOutgoingShipmentTrackingNumber__c;
                objAfterShipTracking.astCarrier__c = objRMA.rmaOutgoingShipmentCarrier__c;
                objAfterShipTracking.astOrderId__c = objRMA.Name;
                objAfterShipTracking.astTrackingCreatedTime__c = strTrackingCreatedTime;
                if(objAfterShipTracking != null)            
                    lstAfterShipTracking.add(objAfterShipTracking);
            }
         }
         system.debug('@@ lstAfterShipTracking ' + lstAfterShipTracking);
         if(lstAfterShipTracking.size() > 0)
            insert(lstAfterShipTracking);
         
         for(AfterShipTracking__c Track:[select ID,astTrackingNumber__c,astTrackingCreatedTime__c from AfterShipTracking__c])
         {
           mapAllTrackingIDs.put(Track.astTrackingNumber__c,Track.ID);
           mapTrackingCreatedTime.put(Track.astTrackingNumber__c,Track.astTrackingCreatedTime__c);  
          
         }
         
         
         system.debug('@@ mapTrackingCreatedTime ' + mapTrackingCreatedTime);
         
         for(sObject s:scope)
         {       
            RMAv2__c objRMA = (RMAv2__c)s;
            strTrackingNumber = objRMA.rmaOutgoingShipmentTrackingNumber__c;
            if(objRMA.rmaOutgoingShipmentCarrier__c != null)
                strCourier = objRMA.rmaOutgoingShipmentCarrier__c.toLowerCase();
            strOrderID = objRMA.Name;//rmaOutShipProviderOrderNumber__c;
            strCustomerName = objRMA.rmaShipmentAttn__c;
            strEmail = objRMA.rmaShipmentEmail__c;
            //call the API call out to insert RMA data in AfterShip.com
            system.debug('@@ mapTrackingCreatedTime.get(strTrackingNumber) '+ mapTrackingCreatedTime.get(strTrackingNumber));
            insertTrackinginAfterShip(strTrackingNumber,strCourier,strOrderID,strCustomerName,mapTrackingCreatedTime.get(strTrackingNumber),mapAllTrackingIDs.get(strTrackingNumber));
            
            
            //get the Tracking number with Track Status in a SET
          for(AfterShipTracking__c Track : [Select astTrackingNumber__c from AfterShipTracking__c Where astTrackingCreatedinAfterShip__c = TRUE])
           setTrackingNumber.add(Track.astTrackingNumber__c);
        
          for(AfterShipTracking__c Track : [Select astTrackingNumber__c,astTrackingErrorMessage__c  from AfterShipTracking__c Where astTrackingErrorMessage__c != null and astTrackingCreatedinAfterShip__c = FALSE])
           setErrorTrackingNumber.add(Track.astTrackingNumber__c);
            system.debug('@@ aftercreate setTrackingNumber  ' + setTrackingNumber + '@@ setErrorTrackingNumber ' + setErrorTrackingNumber);
                                 
         }
               
    }
    global void finish(Database.BatchableContext BC)
    {
        system.debug('@@ In Finish Mtd  TrackingStatus ' + TrackingStatus );
    }

    
   //to call the after ship api use web service method and insert the tracking records
    
     public static void insertTrackinginAfterShip(string TrackingNumber,string Courier,string OrderID,string CustomerName,string TrackingCreatedTime,string TrackID) {
     
        string aftershipErrorString = '';
        string ErrorMsg;
        HttpRequest request = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        //taking the End point URL and API key from the custom settings.
        AfterShipSettings__c objAS = AfterShipSettings__c.getInstance(); 
        string EndPointURL = (string)objAS.AfterShipEndPointURL__c;
        string APIKey = (string)objAS.AfterShipAPIKey__c;
        system.debug('@@ EndPointURL'+ EndPointURL + '@@ API ' + APIKey);
        //End point for AfterShip.com Tracking. It is documented at https://www.aftership.com/docs/api/4
        request.setEndpoint(EndPointURL);
        //API key for the AfterShip.com. Can get it from https://www.aftership.com/apps/api
        request.setHeader('aftership-api-key', APIKey);
        request.setHeader('Content-Type', 'application/json');
        //JSON formate for the aftership tracking
        string TrackingJSON = '{"tracking": {"slug": "'+Courier+'","tracking_number": "'+TrackingNumber+'","order_id": "'+OrderID+'","custom_fields": {"tracking_created_time": "'+TrackingCreatedTime+'"},"customer_name":"'+CustomerName+'"}}';
        request.setBody(TrackingJSON);
        request.setMethod('POST');
        request.setCompressed(true); // otherwise we hit a limit of 32000
        system.debug('@@ Req.setBody '+TrackingJSON );
        
        try 
        {
            system.debug('@@ Req '+ request );
            system.debug('@@ TestResponse '+TestResponse );
            string resStatus = null;
            if (!Test.isRunningTest())
            {
                res = http.send(request );
                resStatus = res.getStatus();
                aftershipErrorString = res.getBody();
                
            }
            else
            {
                if(TestResponse != '')
                {
                    aftershipErrorString = TestResponse;
                }
                else
                {
                    resStatus = 'Created';
                }
            }
            System.debug('@@ aftershipErrorString from res: '+ aftershipErrorString);
            //TrackingStatus  = TrackingStatus  + 'Status for '+ TrackingNumber + ' is '+ res.Status;
            //return res.Status;
            System.debug('@@ res.getStatus() ' + res.getStatus());
        
            if(resStatus == 'Created')
            {
                AfterShipTracking__c asTrackingRecord = new AfterShipTracking__c();
                asTrackingRecord.ID = TrackID;
                asTrackingRecord.astTrackingCreatedinAfterShip__c = TRUE;
                Update(asTrackingRecord);
                system.debug('@@ tracking created ');
                
                
            }
            else
            {
                system.debug('@@ inside else block of the res.getStatus() == Created @@');
                AfterShipTracking__c asTrackingRecord = new AfterShipTracking__c();
                asTrackingRecord.ID = TrackID;
                asTrackingRecord.astTrackingCreatedinAfterShip__c = FALSE;
                aftershipErrorString = '[' + aftershipErrorString + ']';
                system.debug('@@ aftershipErrorString '+  aftershipErrorString );
                JSONParser parser = JSON.createParser(aftershipErrorString);  
                while (parser.nextToken() != null)  
                {  
                    
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY)  
                    {  
                        
                        while (parser.nextToken() !=  JSONToken.END_ARRAY)  
                        {  
                            
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT)  
                            {  
                                
                                while (parser.nextToken() !=  JSONToken.END_OBJECT)  
                                {  
                                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText().tolowercase() == 'message'))  
                                    {  
                                        parser.nextToken(); 
                                        ErrorMsg  = parser.getText(); 
                                        system.debug('## Parse textstr Error ' + parser.getText());
                                    }
                                }
                                
                            }
                        }
                    }
                }
                                        
             asTrackingRecord.astTrackingErrorMessage__c = ErrorMsg;                          
             Update(asTrackingRecord);       
                              
            }
            
        } 
        catch(System.CalloutException e) 
        {
            //return 'Failed';
            System.debug('@@Callout error: '+ e);
            System.debug('@@res ' + res.toString());
        }
     
     }
     
}