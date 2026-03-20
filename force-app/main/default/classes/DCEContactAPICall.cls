public class DCEContactAPICall {
    
    @future (callout=true)
    public static void requestDCEContactInfo( set<Id> conIdS) {
        String accesstoken ;
        String accesstoken1;
        String requestBodyJson;
        
        list<String> listemails=new List<String>();
        List<contact> updateconlist=new List<contact>();
        
        List<Contact> newList=[select id,DCE_Onboarded__c,Federation_ID__c,email,name from contact where ID IN:conIdS];
        if(!newList.isempty()){
            For(Contact con:newList){
                listemails.add(con.email);
            }
            Map<String, Object> requestBody = new Map<String, Object> {'emails' => listemails};
                requestBodyJson = JSON.serialize(requestBody);
                system.debug(' *** line 18 requestbodyjson ' + requestBodyJson);            
            // calling DCE Identity API
            try{
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                request.setEndpoint(DCEAPIInoformation.DCE_Identity_API__c);
                request.setHeader('Content-Type','application/json'); 
                Blob headerValue = Blob.valueOf(DCEAPIInoformation.Username__c + ':' + DCEAPIInoformation.Password__c);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);           
                request.setHeader('Authorization', authorizationHeader); 
                request.setMethod('POST');
                request.setCompressed(true);            
                System.debug('request-' + request);
                
                response = http.send(request);
                System.debug('Response-' + response);
                if (response.getStatusCode() == 200) {
                    System.debug('Response-' + response);
                    System.debug('Response-' + response.getBody());
                    map<string,Object> resultMap = (map<string,Object>)JSON.deserializeUntyped(response.getBody());
                    accesstoken = (String)resultMap.get('access_token');
                    JSONParser parser = JSON.createParser(response.getBody());
                } 
            }
            catch(System.CalloutException e){
                System.debug('Error-' + e.getMessage());   
            }
            
            // calling Salesforce API
            String EndpointUrl=DCEAPIInoformation.Salesforce_API__c+accesstoken+'&grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer';
            Httprequest req1 = new HttpRequest();  
            req1.setEndpoint(EndpointUrl);  
            req1.setMethod('POST'); 
            req1.setHeader('Content-Type','application/json');   
            
            Http http1 = new Http();
            HttpResponse res1 = http1.send(req1);                  
            map<string,Object> resultMap1 = (map<string,Object>)JSON.deserializeUntyped(res1.getBody());
            accesstoken1 = (String)resultMap1.get('access_token');
            
            // calling ContactSearch API
            String authorizationHeader = 'Bearer ' +accesstoken1;
            Httprequest req2 = new HttpRequest();  
            req2.setEndpoint(DCEAPIInoformation.Contact_API__c); 
            req2.setHeader('Content-Type','application/json');       
            req2.setHeader('Authorization', authorizationHeader); 
            req2.setHeader('callersource', 'Nimble'); 
            req2.setHeader('Trackingid', '1234567890123456'); 
            req2.setHeader('getmockdata', 'false');
            req2.setBody(requestBodyJson); 
            req2.setCompressed(true);
            req2.setMethod('POST');
            
            
            Http http2 = new Http();
            HttpResponse res2 = http2.send(req2);  
            map<string,Object> resultMap2 = (map<string,Object>)JSON.deserializeUntyped(res2.getBody());       
            Map<String, Object> recordsMap = (Map<String, Object>) resultMap2.get('records');
            System.debug('resultMap2======'+resultMap2);
            System.debug('recordsMap======'+recordsMap);
            for (Contact con : newList) {
                if (recordsMap.containsKey(con.Email)) {
                    Map<String, Object> recMap = (Map<String, Object>) recordsMap.get(con.Email);
                    if (recMap.get('federationIdentifier') != null) {
                        con.Federation_ID__c = (String) recMap.get('federationIdentifier');
                    }
                    if (recMap.get('isOnboarded') != null) {
                        con.DCE_Onboarded__c = (Boolean) recMap.get('isOnboarded');
                    }
                }
                updateconlist.add(con);
            }
            if(!updateconlist.isempty()){
                update updateconlist;
            }
        }
    }
    public static DCE_API_Information__mdt DCEAPIInoformation{
        get{
            if(DCEAPIInoformation==null)
                DCEAPIInoformation =[select id,QualifiedApiName,
                                     DeveloperName,
                                     Contact_API__c,
                                     DCE_Identity_API__c,
                                     Salesforce_API__c,
                                     Password__c,
                                     Username__c
                                     from DCE_API_Information__mdt
                                     where QualifiedApiName='Default' ];
            return DCEAPIInoformation;
        }
        private set;
    }
}