public class p2nToGSEM{
    
    // determine if this is production or sandbox
    public static GSEM_Information__mdt gsemInfo;    
    
    public static Boolean isSandbox()
    {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    //public static GSEM_Information__mdt gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_Sandbox');

    //@future(callout=true)
    public static Raw_GSEM_Message__c entitleCaseCreation(string providerID){
        //public static Raw_GSEM_Message__c entitleCaseCreation(string providerID, Id gsemId){
        
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_Sandbox');
            
        }   
        
        String nimbleAgentName = gsemInfo.RemoteAgentName__c;
        
        System.debug('gsemInfo:  ' + gsemInfo);
        //String jsonreq = GenerateJSON.jsonEntitlementGenerator (providerID, gsemId);  
        String jsonreq = GenerateJSON.jsonEntitlementGenerator (providerID);  
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setHeader('AgentName',gsemInfo.RemoteAgentName__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);        
        req.setMethod('POST'); 
        req.setBody(jsonreq);
        

        Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();

        // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
        rawGSEM.GSEM_Flow_Type__c = 'GSEM OEM Provider Flow (Pointnext Originated)'; 
        rawGSEM.Message_Direction__c = 'Outbound';
        rawGSEM.JSON_Request__c = req.getBody();
        rawGSEM.GSEM_Transaction_Type__c = 'ENTITLEMENT';
        //rawGSEM.GSEM_Record__c = gsemId;
        rawGSEM.GSEM_Message_Id__c = 'N/A';
        rawGSEM.GSEM_Ack_DML_Error__c = 'N/A';
        rawGSEM.HTTP_Method__c = req.getMethod();
        
        
        
      
       
        try {
            res = http.send(req);
            System.debug(' *** '+res.toString());
            System.debug('STATUS:'+res.getStatus()); System.debug('STATUS_CODE:'+res.getStatusCode()); 
            
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug('Callout error: '+ e.getLineNumber());
            System.debug('Callout error: '+ e.getCause());
            System.debug('Callout error: '+ e.getStackTraceString());

            System.debug(res.toString());
            
            
            // Send the error notification email 
            //sendErrorNotification(e, gsemId);
            sendErrorNotification(e);
        }
        finally{
            rawGSEM.HTTP_Status__c = res.getStatus();
            rawGSEM.HTTP_Status_Code__c = res.getStatusCode();
            rawGSEM.JSON_Response__c = res.getBody();
            
            
            if(String.isBlank(rawGSEM.JSON_Response__c)){
                rawGSEM.JSON_Response__c = 'No JSON content in HTTP \'POST\' Response Method Body';
            }
            
            // extract the transaction status from the json response
            String jsonRsp = rawGSEM.JSON_Response__c;
            String refStr  = 'TransactionStatus":"';
            Integer len    = refStr.length();
            Integer strtIdx  = jsonRsp.indexOf(refStr);
            strtIdx = strtIdx + len;
           
            // find the next double quote " character
            Integer endIdx = jsonRsp.indexOf('"', strtIdx);
            
            // set the length of the field being extracted
            len = endIdx - strtIdx;

            rawGSEM.GSEM_Engine_Transaction_Status__c = jsonRsp.mid(strtIdx, len) ;
   
            //insert rawGSEM; 
            if(rawGSEM.GSEM_Engine_Transaction_Status__c.containsIgnoreCase('Success')){
                rawGSEM.GSEM_Call_Status__c = 'ENTITLED';
            }
            else{
                rawGSEM.GSEM_Call_Status__c = 'NOT ENTITLED';
            }
                
            
        }
       
        
        return rawGSEM;
    }
    
   // @future(callout=true)
    public static Raw_GSEM_Message__c acceptproblemCase(string requesterID, string caseNumber, string phoneNumber,Id gsemId){
        
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_Sandbox');
            
        }   
        
        String nimbleAgentName = gsemInfo.RemoteAgentName__c;
    
        //String jsonreq = GenerateJSON.jsonAcceptProblemGenerator(requesterID, caseNumber, phoneNumber, gsemId);  
        String jsonreq = GenerateJSON.jsonAcceptProblemGenerator(requesterID, caseNumber, phoneNumber);  
        
        system.debug(' **** jsonREQ formed ' + jsonreq);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setHeader('AgentName',gsemInfo.RemoteAgentName__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);        
        req.setMethod('POST'); 
        req.setBody(jsonreq);
        
        Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();

        // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
        rawGSEM.GSEM_Flow_Type__c        = 'GSEM OEM Provider Flow (Pointnext Originated)'; 
        rawGSEM.Message_Direction__c     = 'Outbound';
        rawGSEM.GSEM_Transaction_Type__c = 'ACCEPT PROBLEM';
        rawGSEM.JSON_Request__c          = req.getBody();
        rawGSEM.GSEM_Record__c = gsemId;
        rawGSEM.GSEM_Message_Id__c = 'N/A';
        rawGSEM.GSEM_Ack_DML_Error__c = 'N/A';
        rawGSEM.HTTP_Method__c = req.getMethod();
        
        
        
  
        
        try {
            res = http.send(req);
            System.debug(' *** '+res.toString());
            System.debug('STATUS:'+res.getStatus()); System.debug('STATUS_CODE:'+res.getStatusCode()); 
            
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug('Callout error: '+ e.getLineNumber());
            System.debug('Callout error: '+ e.getCause());
            System.debug('Callout error: '+ e.getStackTraceString());
            System.debug(res.toString());
            
            // Send the error notification email 
            //sendErrorNotification(e, gsemId);
            sendErrorNotification(e);
        }
        finally{
            rawGSEM.HTTP_Status__c = res.getStatus();
            rawGSEM.HTTP_Status_Code__c = res.getStatusCode();
            rawGSEM.JSON_Response__c = res.getBody();
            if(String.isBlank(rawGSEM.JSON_Response__c)){
                rawGSEM.JSON_Response__c = 'No JSON content in HTTP \'POST\' Response Method Body';
            }
            
            // extract the transaction status from the json response
            String jsonRsp = rawGSEM.JSON_Response__c;
            String refStr  = 'TransactionStatus":"';
            Integer len    = refStr.length();
            Integer strtIdx  = jsonRsp.indexOf(refStr);
            strtIdx = strtIdx + len;
           
            // find the next double quote " character
            Integer endIdx = jsonRsp.indexOf('"', strtIdx);
            
            // set the length of the field being extracted
            len = endIdx - strtIdx;

            rawGSEM.GSEM_Engine_Transaction_Status__c = jsonRsp.mid(strtIdx, len) ;
   
            //insert rawGSEM; 
            
            if(rawGSEM.GSEM_Engine_Transaction_Status__c.containsIgnoreCase('Success')){
                rawGSEM.GSEM_Call_Status__c = 'OPEN PROVIDER';
            }
            else{
                rawGSEM.GSEM_Call_Status__c = 'PROBLEM SUBMITTED';
            }
            
        }
        
        return rawGSEM;
    }
    
    @future(callout=true)
    public static void sendPPI (Id gsemId, string nimbleId, string pointnextID, string caseComment, String currCallStatus, String gsemFlowType){
        system.debug(' ***  sendPPI Called');
        
        if(!isSandbox())
        {
            if(gsemFlowType.contains('OEM')){
                
                // we are running in Production
                gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_PROD');
            }
            else{
                
                gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_PROD');
            }
            
            
        }
        else
        {
            if(gsemFlowType.contains('OEM')){
                
                gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_Sandbox');
            }
            else{
                
                gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_Sandbox');
            }
            
        }   
        
        
        String nimbleAgentName = gsemInfo.Nimble_Agent_Name__c;

        //String jsonreq = GenerateJSON.jsonPPIGenerator(requesterID, caseNum, caseComment, gsemId);  
        String jsonreq = GenerateJSON.jsonPPIGenerator(nimbleId, pointnextID, caseComment, gsemFlowType);  
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setHeader('AgentName',gsemInfo.RemoteAgentName__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);        
        req.setMethod('POST'); 
        req.setBody(jsonreq);
        
        Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();

        // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
        rawGSEM.GSEM_Flow_Type__c        = gsemFlowType; 
        rawGSEM.Message_Direction__c     = 'Outbound';
        rawGSEM.GSEM_Transaction_Type__c = 'PROVIDE PROBLEM INFORMATION';
        rawGSEM.JSON_Request__c          = req.getBody();
        rawGSEM.GSEM_Record__c           = gsemId;
        rawGSEM.GSEM_Message_Id__c = 'N/A';
        rawGSEM.GSEM_Ack_DML_Error__c = 'N/A';
        rawGSEM.HTTP_Method__c = req.getMethod();
        
        System.debug('PPI JSON Request Body:  ' + req.getBody());
        
        // create GSEM Comment record
        GSEM_Comment__c gc = new GSEM_Comment__c();
        gc.Direction__c = 'Outbound Comment';
        gc.Action_Log__c = caseComment;
        //gc.Comment__c = g.Comment__c;
        gc.GSEM_Record__c = gsemId;
        
        if(currCallStatus != 'CLOSED' && currCallStatus != 'CLOSED PENDING CONFIRMATION' ){
            
            
            try {
                res = http.send(req);
                System.debug(' *** '+res.toString());
                System.debug('STATUS:'+res.getStatus()); System.debug('STATUS_CODE:'+res.getStatusCode()); 
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug('Callout error: '+ e.getLineNumber());
                System.debug('Callout error: '+ e.getCause());
                System.debug('Callout error: '+ e.getStackTraceString());
                System.debug(res.toString());
                
                rawGSEM.Callout_Exception_Message__c = e.getMessage();
                //rawGSEM.Callout_Exception_Cause__c   = (String) e.getCause();
                rawGSEM.Callout_Exception_Line_Number__c = String.valueOf(e.getLineNumber());
                rawGSEM.Callout_Exception_Stack_Trace__c = e.getStackTraceString();
                
                
                // Send the error notification email 
                //sendErrorNotification(e, gsemId);
                sendErrorNotification(e);
            }
            finally{
                
                rawGSEM.JSON_Response__c = res.getBody();
                
                if(rawGSEM.JSON_Response__c != null){
                    
                    rawGSEM.HTTP_Status_Code__c = res.getStatusCode();
                    rawGSEM.HTTP_Status__c = res.getStatus();
                    
                    
                    if(String.isBlank(rawGSEM.JSON_Response__c)){
                        rawGSEM.JSON_Response__c = 'No JSON content in HTTP \'POST\' Response Method Body';
                    }
                    
                    // extract the transaction status from the json response
                    String jsonRsp = rawGSEM.JSON_Response__c;
                    String refStr  = 'TransactionStatus":"';
                    Integer len    = refStr.length();
                    Integer strtIdx  = jsonRsp.indexOf(refStr);
                    strtIdx = strtIdx + len;
                    
                    // find the next double quote " character
                    Integer endIdx = jsonRsp.indexOf('"', strtIdx);
                    
                    // set the length of the field being extracted
                    len = endIdx - strtIdx;
                    
                    rawGSEM.GSEM_Engine_Transaction_Status__c = jsonRsp.mid(strtIdx, len) ;
                    
                    if(rawGSEM.GSEM_Engine_Transaction_Status__c == 'Invalid context'){
                        
                        // extract the transaction status from the json response
                        jsonRsp = rawGSEM.JSON_Response__c;
                        refStr  = 'Message":"';
                        len    = refStr.length();
                        strtIdx  = jsonRsp.indexOf(refStr);
                        strtIdx = strtIdx + len;
                        
                        // find the next double quote " character
                        endIdx = jsonRsp.indexOf('"', strtIdx);
                        
                        // set the length of the field being extracted
                        len = endIdx - strtIdx;
                        
                        rawGSEM.GSEM_Error_Message__c = jsonRsp.mid(strtIdx, len) ;
                    }
                    
                    insert rawGSEM; 
                    
                    gc.Raw_GSEM_Message__c = rawGSEM.Id;
                    
                    insert gc;
                    
                    rawGSEM.Related_GSEM_Comment__c = gc.Id;
                    
                    if(rawGSEM.GSEM_Engine_Transaction_Status__c.containsIgnoreCase('Success')){
                        rawGSEM.GSEM_Call_Status__c = 'OPEN REQUESTER';
                    }
                    else{
                        // keep previous state
                        rawGSEM.GSEM_Call_Status__c = currCallStatus;
                    }
                    
                    update rawGSEM;
                    
                    
                    
                }
                else{ // JSON response is empty, probably no response from far end and subsequent callout exception
                    
                    rawGSEM.GSEM_Engine_Transaction_Status__c = 'NO RESPONSE TO MESSAGE';
                    rawGSEM.GSEM_Call_Status__c = currCallStatus;
                    
                    insert rawGSEM;
                    
                }
                
            }
        }
        else{
            rawGSEM.GSEM_Engine_Transaction_Status__c = 'MESSAGE NOT SENT - REMOTE CASE IS CLOSED';
            insert rawGSEM;
        }

        return;
    }
    
    public static Id sendClosePPI (string caseNum, string requesterID, string caseComment, Id gsemId, String currCallStatus){
        system.debug(' ***  sendClosePPI Called');
        
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_Sandbox');
            
        }   
        
        GSEM__c gsem = [select id, name, GSEM_Flow_Type__c from GSEM__c where Id =: gsemId];
        
        String nimbleAgentName = gsemInfo.RemoteAgentName__c;

        //String jsonreq = GenerateJSON.jsonPPIGenerator(requesterID, caseNum, caseComment, gsemId);  
        String jsonreq = GenerateJSON.jsonPPIGenerator(caseNum, requesterID, caseComment, gsem.GSEM_Flow_Type__c );  
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setHeader('AgentName',gsemInfo.RemoteAgentName__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);        
        req.setMethod('POST'); 
        req.setBody(jsonreq);
        
        Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();

        // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
        rawGSEM.GSEM_Flow_Type__c        = 'GSEM OEM Provider Flow (Pointnext Originated)'; 
        rawGSEM.Message_Direction__c     = 'Outbound';
        rawGSEM.GSEM_Transaction_Type__c = 'PROVIDE PROBLEM INFORMATION';
        rawGSEM.JSON_Request__c          = req.getBody();
        rawGSEM.GSEM_Record__c = gsemId;
        rawGSEM.GSEM_Message_Id__c = 'N/A';
        rawGSEM.GSEM_Ack_DML_Error__c = 'N/A';
        rawGSEM.HTTP_Method__c = req.getMethod();
        
        
                
        try {
            res = http.send(req);
            System.debug(' *** '+res.toString());
            System.debug('STATUS:'+res.getStatus()); 
            System.debug('STATUS_CODE:'+res.getStatusCode()); 
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug('Callout error: '+ e.getLineNumber());
            System.debug('Callout error: '+ e.getCause());
            System.debug('Callout error: '+ e.getStackTraceString());

            System.debug(res.toString());
            
            
            // Send the error notification email 
            //sendErrorNotification(e, gsemId);
            sendErrorNotification(e);
        }
        finally{
            rawGSEM.HTTP_Status__c = res.getStatus();
            rawGSEM.HTTP_Status_Code__c = res.getStatusCode();
            rawGSEM.JSON_Response__c = res.getBody();
            
            if(String.isBlank(rawGSEM.JSON_Response__c)){
                rawGSEM.JSON_Response__c = 'No JSON content in HTTP \'POST\' Response Method Body';
            }
            
            // extract the transaction status from the json response
            String jsonRsp = rawGSEM.JSON_Response__c;
            String refStr  = 'TransactionStatus":"';
            Integer len    = refStr.length();
            Integer strtIdx  = jsonRsp.indexOf(refStr);
            strtIdx = strtIdx + len;
           
            // find the next double quote " character
            Integer endIdx = jsonRsp.indexOf('"', strtIdx);
            
            // set the length of the field being extracted
            len = endIdx - strtIdx;

            rawGSEM.GSEM_Engine_Transaction_Status__c = jsonRsp.mid(strtIdx, len) ;
   
            
            
            if(rawGSEM.GSEM_Engine_Transaction_Status__c.containsIgnoreCase('Success')){
                rawGSEM.GSEM_Call_Status__c = 'CLOSED';
            }
            else{
                // keep previous state
                rawGSEM.GSEM_Call_Status__c = currCallStatus;
            }
            
            insert rawGSEM; 
            
        }
        
        return rawGSEM.id;
        
    }
    
    //private static void sendErrorNotification(System.CalloutException exceptionString, Id gsemId)
    private static void sendErrorNotification(System.CalloutException exceptionString)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>(); 
        List<String> ccAddresses = new List<String>(); 
        
        // Add test email addresses
        toAddresses.add('nimble-support-sfdc@hpe.com');
        //toAddresses.add('yesha.benegal@hpe.com');
        
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('donotreply@salesforce.com');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('GSEM Automation');
        
        // Set to True if you want to BCC yourself on the email.
        //mail.setBccSender(false);
        
        //List<GSEM__c> gsemLst = [select Id, Name, Case_Owner_Email__c from GSEM__c where Id =: gsemId];
        List<GSEM__c> gsemLst = null;
      
        if(gsemLst != null){
            
            
            // Specify the subject line for your email address.
            mail.setSubject('GSEM Transfer Failure:  ' + gsemLst[0].Name);
            
            //mail.setHtmlBody('<h3 style="color:blue;">REMINDER</h3> CHECK-IN for Executive Escalation: <a href="https://nimblestorage--stage.my.salesforce.com/a2y80000000mG46AAE">ESC-99999</a> is due in ~'+ (execEscRecord.Hours_Until_Next_Escalation_Check_In__c * 60) + ' minutes');
            
            mail.setHtmlBody('<h3 style="color:red;">ERROR</h3> GSEM Callout Error: '+ exceptionString + ' <a href="https://nimblestorage.my.salesforce.com/'+gsemLst[0].Id+'">'+ gsemLst[0].Name +'</a>');
            
            if(gsemLst[0].Case_Owner_Email__c != null)
            {
                System.debug('gsem.Case_Owner_Email__c: ' + gsemLst[0].Case_Owner_Email__c);
                toAddresses.add(gsemLst[0].Case_Owner_Email__c);
            }
            
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            
            
            System.debug('toAddresses: ' + toAddresses);
            System.debug('ccAddresses: ' + ccAddresses);
            System.debug('mail.getToAddresses(): ' + mail.getToAddresses());
            
            if(mail.getToAddresses().size() > 0)
            {
                try
                {
                    // Send the email you have created.
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
                }
                catch(DmlException e)
                {
                    System.debug('ERROR Sending GSEM HTTP Error Email: ' + e); 
                    System.debug('GSEM Record associated with GSEM HTTP Error: ' + gsemLst[0]);
                }
                
            }
            else
            {
                System.debug('NOT Sending GSEM Transfer Failure Email - EMPTY ToAddresses(): ' + mail.getToAddresses());
            }
            
            return;
    	}
    }
}