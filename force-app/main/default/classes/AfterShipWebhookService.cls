@RestResource(urlMapping='/AfterShipWebhookService')
global with sharing class AfterShipWebhookService {
    
    @HttpPost
    global static void doPost() {
    
        ////////////////////////////////////
        string strTrackingNumber,strSignedBy,strLastUpdateTime,strStatus,strTrackingStatus,strShipmentType,strShipWeight,strShipWeightlb;
        string strTrackingCreatedTime = '';
        Set<string> setTrackingNumber = new Set<string>();
        Map<string,string> mapTrackingStatus = new Map<string,string>();
        List<AfterShipTracking__c> lstUpdateTracking = new List<AfterShipTracking__c>();
        
        //assign the values for the AfterShipCheckPoint
        AfterShipCheckPoint__c objAfterShipCheckPoint = new AfterShipCheckPoint__c();
        List<AfterShipCheckPoint__c> lstAfterShipCheckPoint = new List<AfterShipCheckPoint__c>();
        // take all the Track details for the AfterShipTracking__c for all tracking status
        Map<string,ID> mapAllTrackingDetails = new Map<string,ID>();
        Map<string,string> mapTrackCreatedTime = new Map<string,string>();
        AfterShipTracking__c objAST = new AfterShipTracking__c();
        ///////////////////////////////////
        
        //get the AfterShipTracking ID for each tracking number
        for(AfterShipTracking__c Track:[select ID,astTrackingCreatedTime__c,astOrderId__c,astTrackingNumber__c,astTrackingStatus__c from AfterShipTracking__c where astTrackingStatus__c !='Delivered'])
        {
           mapAllTrackingDetails.put(Track.astTrackingNumber__c,Track.ID);            
           mapTrackCreatedTime.put(Track.astTrackingNumber__c,Track.astOrderId__c);
        }
             
        RestRequest req = RestContext.request;
        if(req.requestbody != null)
        {
            string aftershipJson = req.requestbody.tostring();
            System.debug('@@ body before ' + aftershipJson );
            // concating [ and ] bracket to the result to get the correct formate to get the values in salesforce
            aftershipJson = '[' + aftershipJson + ']';
            aftershipJson = aftershipJson.replace('"custom_fields":{},','');
            System.debug('@@ body ' + aftershipJson );
            
            
           
            JSONParser parser = JSON.createParser(aftershipJson); 
             
            while (parser.nextToken() != null)  
            {  
                System.debug('## inside while parser.nextToken() != null'); 
                if (parser.getCurrentToken() == JSONToken.START_ARRAY)  
                {  
                    
                    System.debug('## inside if parser.getCurrentToken() == JSONToken.START_ARRAY'); 
                    while (parser.nextToken() !=  JSONToken.END_ARRAY)  
                    {  
                        
                        if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText().tolowercase() == 'signed_by'))  
                        {  
                                    parser.nextToken(); 
                                    strSignedBy = parser.getText();
                                    
                                    system.debug('## Parse text Signed By in2nd loop ' + parser.getText() + 'strSignedBy ' + strSignedBy );
                                } 
                                
                                
                                
                                
                        System.debug('## inside while parser.nextToken() !=  JSONToken.END_ARRAY'); 
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT)  
                        {  
                            System.debug('## inside if parser.getCurrentToken() == JSONToken.START_OBJECT'); 
                            while (parser.nextToken() !=  JSONToken.END_OBJECT)  
                            {  
                                    System.debug('## inside while parser.nextToken() !=  JSONToken.END_OBJECT');
                                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME))  
                                    {
                                        system.debug(' && (parser.getText().tolowercase() ' + parser.getText());
                                    } 
                                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText().tolowercase() == 'tracking_created_time'))  
                                    {  
                                        parser.nextToken(); 
                                        strTrackingCreatedTime = parser.getText();                                    
                                        system.debug('## Parse textstr TrackingCreatedTime ' + parser.getText());
                                    }                             
                                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText().tolowercase() == 'tracking_number'))  
                                    {  
                                        parser.nextToken(); 
                                        strTrackingNumber = parser.getText();
                                        objAST.astTrackingNumber__c = parser.getText();
                                        setTrackingNumber.add(parser.getText());    
                                        system.debug('## Parse text tracking no ' + parser.getText());
                                    } 
                                    
                                    
                                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText().tolowercase() == 'country_iso3'))  
                                    {  
                                        parser.nextToken(); 
                                        if(parser.getText() == 'null')
                                            objAfterShipCheckPoint.ascpCountry__c = '';
                                        else
                                            objAfterShipCheckPoint.ascpCountry__c = parser.getText();      
                                        system.debug('## Parse text country' + parser.getText());
                                    } 
                                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText().tolowercase() == 'state'))  
                                    {  
                                        parser.nextToken();
                                        if(parser.getText() == 'null') 
                                            objAfterShipCheckPoint.ascpState__c = '';    
                                        else
                                            objAfterShipCheckPoint.ascpState__c = parser.getText();    
                                        system.debug('## Parse text state' + parser.getText());
                                    } 
                                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText().tolowercase() == 'message'))  
                                    {  
                                        parser.nextToken(); 
                                        objAfterShipCheckPoint.ascpMessage__c = parser.getText();    
                                        system.debug('## Parse text message' + parser.getText());
                                    } 
                                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText().tolowercase() == 'tag'))  
                                    {  
                                        parser.nextToken();
                                        objAfterShipCheckPoint.ascpTrackingStatus__c = parser.getText();
                                        strStatus = parser.getText();
                                         //get the latest tracking status to update in the AfterShipTracking object
                                        mapTrackingStatus.put(strTrackingNumber,parser.getText());
                                        strTrackingStatus = parser.getText();    
                                        system.debug('## Parse text tag ' + parser.getText());
                                    } 
                                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText().tolowercase() == 'checkpoint_time'))  
                                    {  
                                        parser.nextToken(); 
                                        objAfterShipCheckPoint.ascpCheckPointTime__c = parser.getText().replace('T',' ');  
                                        strLastUpdateTime =  parser.getText().replace('T',' ');     
                                        system.debug('## Parse text message' + parser.getText());
                                    } 
                                    
                                   
                                 
                               System.debug('## END of while parser.nextToken() !=  JSONToken.END_OBJECT');
                                   
                            } 
                            
                            System.debug('## END if parser.getCurrentToken() == JSONToken.START_OBJECT');
                                             
                        }
                        
                        System.debug('## END of while parser.nextToken() !=  JSONToken.END_ARRAY');
                        
                        system.debug('## check point object added in list objAfterShipCheckPoint' + objAfterShipCheckPoint);
                        if(objAfterShipCheckPoint != null && objAfterShipCheckPoint.ascpMessage__c != null)
                        {
                            objAfterShipCheckPoint.ascpTrackingCreatedTime__c = strTrackingCreatedTime;
                            objAfterShipCheckPoint.ascpTrackingNumber__c = strTrackingNumber;
                            lstAfterShipCheckPoint.add(objAfterShipCheckPoint);
                            objAfterShipCheckPoint  = new AfterShipCheckPoint__c();
                            system.debug('## new object for check point');
                        }
                           
                          
                    } 
                    
                    System.debug('## END if parser.getCurrentToken() == JSONToken.START_ARRAY');
                    
                }
                
               System.debug('## END of while parser.nextToken() != null');
                
            }
        }    
        system.debug('@@ lstAfterShipCheckPoint ## ' + lstAfterShipCheckPoint + '@@ Size () :  ' +lstAfterShipCheckPoint.size());
        
        if(lstAfterShipCheckPoint.size() > 0){
            insert(lstAfterShipCheckPoint);
        }

        // Update the AfterShipTracking with the latest status
        system.debug('@@ lstUpdateTracking ' + objAST);
        system.debug('@@ mapTrackingStatus ' +mapTrackingStatus);
        objAST.ID = mapAllTrackingDetails.get(strTrackingNumber);
        objAST.astAfterShipLastUpdate__c = strLastUpdateTime;
        objAST.astTrackingStatus__c = mapTrackingStatus.get(strTrackingNumber);
        objAST.astSignedBy__c = strSignedBy;
        lstUpdateTracking.add(objAST);
                
        system.debug('@@ lstUpdateTracking ' + lstUpdateTracking);
        if(lstUpdateTracking.size() > 0 && objAST.ID != null)
        {
            system.debug('@@ lstUpdateTracking ' + lstUpdateTracking ); 
            update(lstUpdateTracking);
        }
        
                
    }
}