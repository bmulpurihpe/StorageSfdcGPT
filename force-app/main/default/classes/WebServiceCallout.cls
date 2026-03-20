public class WebServiceCallout {
    
    // determine if this is production or sandbox
    public static GSEM_Information__mdt gsemInfo;    
    static final Integer TEXT_AREA_MAX         = 255;
    static final Integer LONG_TEXT_AREA_MAX    = 32768;
    static final Integer MAX_COMMENT_BODY_SIZE = 4000;
    static final String  FIELD_TRUNCATION_INDICATOR = '......TRUNCATED';
    
    
    
    public static Boolean isSandbox()
    {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    @future(callout=true)
    public static void sendNotification(Id gsemId)
    {
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_Sandbox');
            
        }   
        
        String nimbleAgentName = gsemInfo.Nimble_Agent_Name__c;
        
        System.debug('gsemInfo:  ' + gsemInfo);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);
        
        req.setMethod('POST');
        DateTime dt = system.today();
        Datetime GMTDate = Datetime.newInstanceGmt(
            dt.year(),
            dt.month(),
            dt.day(),
            dt.hour(),
            dt.minute(),
            dt.second());
        string dt2 = string.valueOf(GMTDate) +',' + string.valueOf(dt);
        List<GSEM__C> gLst = [SELECT Id, Name, Case_Owner_Email__c, Company_Name__c,Organization_Name__c,Address_1__c,Address_2__c,City__c,Contract_Id__c,
                              State__c,Zipcode__c,Country__c, Time_Zone__c,ContactFirstName__c, Contact_Last_Name__c,Problem_Title__c,Problem_Description__c,
                              Severity_Level__c,Resolution_Code_Text__c,CSR_Part_Description__c, Consumed_Part_Description__c,Cust_ticket__c, Contact_Title__c,
                              Queue__c, Contact_Email__c, Contact_Fax__c, Serial_Number__c, Product_Number__c, Contact_Phone__c, System_Serial_No__c, 
                              Nimble_Agent_Name__c, Pointnext_Severity_Level__c                           
                              FROM GSEM__c where id =: gsemId];
        
        
        string CNId='';
        if(gLst[0].Contract_Id__c != null){
            CNId = gLst[0].Contract_Id__c;
        }
        string pNID='';
        
        
        String cleanedProblemTitle = '';
        String cleanedProblemDescription = '';
        
        if(gLst[0].Problem_Title__c != null)
        {
            cleanedProblemTitle = gLst[0].Problem_Title__c;
            
            // escape JSON special characters to prevent the GSEM engine from experiencing problems 
            // with either the initial JSON processing or later XML processing
            cleanedProblemTitle = cleanedProblemTitle.replace('"', '\\"');
            
            System.debug('cleanedProblemTitle after escaping double Quotes:  ' + cleanedProblemTitle);
        }
        
        if(gLst[0].Problem_Description__c != null)
        {
            cleanedProblemDescription = gLst[0].Problem_Description__c;
            
            if(gLst[0].Case_Owner_Email__c != null)
            {
                cleanedProblemDescription = '*** Nimble Case Owner Email:  '+ gLst[0].Case_Owner_Email__c+' ***\n' + cleanedProblemDescription;
            } 
            
            // escape JSON special characters to prevent the GSEM engine from experiencing problems 
            // with either the initial JSON processing or later XML processing
            //cleanedProblemDescription = cleanedProblemDescription.replace('\t', '\\t');
            cleanedProblemDescription = cleanedProblemDescription.replace('"' , '\\"');
            //cleanedProblemDescription = cleanedProblemDescription.replace('\n', '\\n');
            //cleanedProblemDescription = cleanedProblemDescription.replace('\t', '\\t');
            
            System.debug('cleanedProblemDescription after escaping double Quotes:  ' + cleanedProblemDescription);
        }
        
        // 
        // TS-9759 - GSEM: Company Name not mapping to Web Company in Pointnext SFDC
        // 
        // Overriding the Organization Name field to hold the same value as Company Name
        // Due to the fact that Organization Name is mapped to the Web Company field on the Pointnext Case
        // This is a work-around for the GSEM field mapping not matching the GSEM Elevation Flow documentation
        gLst[0].Organization_Name__c       = gLst[0].Company_Name__c;
        gLst[0].Nimble_Agent_Name__c       = nimbleAgentName;
        glst[0].GSEM_Flow_Type__c          = 'GSEM Requester Flow (Nimble Originated)';
        gLst[0].Requester_Id__c            = gLst[0].Name;
        glst[0].Requested_Date_Time__c     = System.now();
        glst[0].Send_Service_Request__c    = false;
        glst[0].Service_Request_Sent__c    = true;
        //glst[0].
        
        
        
        // 
        // transition to using JSON Generator  ****************
        // 
        
        string t3 = ('{"Message": {"TransactionName": "SERVICE REQUEST","RemoteAgentName": "'+gsemInfo.RemoteAgentName__c+'","StopOnConversion": "false","RemoteAgentType": "HPE","eCPControl": {"ECPVersion": "1.0"},"SERVICE_INCIDENT": {"RequesterID":"'+ gLst[0].Name+'","RequesterSeverity": "'+gLst[0].Severity_Level__c+'","ResponseTime": "'+ 
                     dt2 +'","Comment":"","SERVICE_REQUESTER": {"ORGANIZATION": {"Business": "'+gLst[0].Company_Name__c+'","OrganizationName":"'+gLst[0].Organization_Name__c +'","ADDRESS": {"AddressType": "PRIMARY","GeoAddress1": "'
                     +gLst[0].Address_1__c+','+ gLst[0].Address_2__c+'","City": "'+gLst[0].City__c+'","Region": "'+gLst[0].State__c+'","PostalCode": "'+gLst[0].Zipcode__c+'","TimeZone": "'+gLst[0].Time_Zone__c+'","Country": "'+gLst[0].Country__c
                     +'","LOCATION": [{"ID": "'+gLst[0].Contact_Phone__c+'","Type": "PRIMARY_VOICE"},{"ID": "DUMMY ALTERNATE VOICE NUMBER","Type": "ALTERNATE_VOICE"},{"ID": "'+gLst[0].Contact_Fax__c+'","Type": "FAX"},{"ID": "'+gLst[0].Contact_Email__c+'","Type": "EMAIL"},{"ID": "http://www.dummyurl.com","Type": "URL"}]}},"PERSON": {"FirstName": "'
                     + gLst[0].ContactFirstName__c+'","LastName": "'+gLst[0].Contact_Last_Name__c+'","Salutation": "","Title": "'+ gLst[0].Contact_Title__c+'","ContactType": "LG=ENG","CommunicationMode": "PRIMARY_VOICE","ADDRESS": {"AddressType": "PRIMARY","GeoAddress1": "'
                     +gLst[0].Address_1__c+'","City": "'+gLst[0].City__c+'","Region": "'+gLst[0].State__c+'","PostalCode": "'+ gLst[0].Zipcode__c+'","TimeZone": "'+gLst[0].Time_Zone__c+'","Country": "'+gLst[0].Country__c
                     +'","LOCATION": [{"ID": "'+gLst[0].Contact_Phone__c+'","Type": "PRIMARY_VOICE"},{"ID": "DUMMY ALTERNATE VOICE NUMBER","Type": "ALTERNATE_VOICE"},{"ID": "DUMMY FAX NUMBER","Type": "FAX"},{"ID": "'+gLst[0].Contact_Email__c+'","Type": "EMAIL"},{"ID": "http://www.dummyurl.com","Type": "URL"}]}}},"AGREEMENT": {"ContractID":"CN='
                     +CNId+'","AgreementType": "SN='+gLst[0].System_Serial_No__c +' ;PN='+pNID+';LN='+gLst[0].Cust_ticket__c+';RI='+gLst[0].Queue__c+'"},"ACTIVITY": [{"ActionLog": "ActionLog is not applicable to Service Request","LocalDate": "'
                     +dt2+'","ParameterList": "No Parameter List"}],"PROBLEM": {"EXPRESSION": {"Relation": "AND","STATEMENT": [{"StatementRole": "TITLE","StatementText": "'+cleanedProblemTitle+'"},{"StatementRole": "DESCRIPTION","StatementText": "'+ cleanedProblemDescription +'"}]}}}}}');
        
        
        //String escapedT3 = JSON.serialize(t3);
        List<String> gsemMessageContents = t3.split(',');
        
        for(Integer index = 0; index < gsemMessageContents.size(); index++)
        {
            System.debug(gsemMessageContents[index]);
            
        }
        
        req.setBody(t3);
        
        // this record will be created immediately to hold the unparsed JSON in the event of a parsing error or Ack Message creation preventing a record update
        // it will be deleted later following successful parsing and Acknowledge Message creation
        Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();
        
        
        // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
        rawGSEM.GSEM_Flow_Type__c = 'GSEM Requester Flow (Nimble Originated)'; 
        rawGSEM.Message_Direction__c = 'Outbound';
        rawGSEM.JSON_Request__c = req.getBody();
        rawGSEM.GSEM_Transaction_Type__c = 'SERVICE REQUEST';
        rawGSEM.GSEM_Record__c = gsemId;
        rawGSEM.GSEM_Message_Id__c = 'N/A';
        rawGSEM.GSEM_Ack_DML_Error__c = 'N/A';
        rawGSEM.HTTP_Method__c = req.getMethod();
        rawGSEM.GSEM_Record__c = gLst[0].Id;
        
        
        
        
        system.debug(' ***** ' + t3);
        // req.setBody('Id='+EncodingUtil.urlEncode(Id, 'UTF-8')+'&Email='+EncodingUtil.urlEncode(Email, 'UTF-8')+'&First_Name='+EncodingUtil.urlEncode(First_Name, 'UTF-8')+'&Last_Name='+EncodingUtil.urlEncode(Last_Name, 'UTF-8')+'&Title='+EncodingUtil.urlEncode(Title, 'UTF-8'));
        req.setCompressed(true); // otherwise we hit a limit of 32000
        
        Boolean isCalloutException = false;
        System.CalloutException coException = null;
        
        try {
            
            res = http.send(req);
            System.debug(' *** '+res.toString());
            System.debug('res.getBody():   ' + res.getBody());
            System.debug('STATUS:'+res.getStatus()); System.debug('STATUS_CODE:'+res.getStatusCode()); 
            
        } catch(System.CalloutException e) {
            
            System.debug('Callout error: '+ e);            
            System.debug('Callout error: '+ e.getLineNumber());
            System.debug('Callout error: '+ e.getCause());
            System.debug('Callout error: '+ e.getStackTraceString());
            System.debug(res.toString());
            
            isCalloutException = true;
            coException = e;
        }
        finally{
            
            rawGSEM.HTTP_Status__c = res.getStatus();
            rawGSEM.HTTP_Status_Code__c = res.getStatusCode();
            rawGSEM.JSON_Response__c = res.getBody();
            
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
            
            rawGSEM.GSEM_Engine_Transaction_Status__c = jsonRsp.mid(strtIdx, len);
            
            if(rawGSEM.GSEM_Engine_Transaction_Status__c == 'Success'){
                glst[0].Current_GSEM_State__c = 'PROBLEM SUBMITTED';
                rawGSEM.GSEM_Call_Status__c = 'PROBLEM SUBMITTED';
            }
            else{
                glst[0].Current_GSEM_State__c = 'SERVICE REQUEST SEND FAILURE';
                rawGSEM.GSEM_Call_Status__c = 'SERVICE REQUEST SEND FAILURE';
            }
            
            if(rawGSEM.JSON_Response__c.length() > LONG_TEXT_AREA_MAX){
                rawGSEM.JSON_Response__c = rawGSEM.JSON_Response__c.abbreviate(LONG_TEXT_AREA_MAX-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
            }
            
            insert rawGSEM; 
            update gLst[0];
            
            if(isCalloutException && coException != null){
                
                sendErrorNotification(coException, gLst[0], rawGSEM.Id);
            }
            
            
        }
    }
    
    @future(callout=true)
    public static void getNotification()
    {
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_Sandbox');
            
        }   
        
        
        
        CaseComment closureCaseComment;
        CaseComment newCaseComment;
        String nimbleAgentName = gsemInfo.Nimble_Agent_Name__c;
        List<GSEM__c> allOpenGSEM;
        List<Acknowledge_Message__c> openGSEMAckList = new List<Acknowledge_Message__c>();
        List<Acknowledge_Message__c> ackList = new List<Acknowledge_Message__c>();
        GSEM__c realGSEM;
        
        System.debug('gsemInfo:  ' + gsemInfo);
        
        HttpRequest req = new HttpRequest();
        HttpResponse response = new HttpResponse();
        //HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setHeader('AgentName',gsemInfo.RemoteAgentName__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);
        req.setMethod('GET');
        req.setTimeout(20000);
        
        // this record will be created immediately to hold the unparsed JSON in the event of a parsing error or Ack Message creation preventing a record update
        // it will be deleted later following successful parsing and Acknowledge Message creation
        Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();
        
        
        // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
        rawGSEM.GSEM_Flow_Type__c = 'GSEM Requester Flow (Nimble Originated)'; 
        rawGSEM.Message_Direction__c = 'Inbound';
        rawGSEM.JSON_Request__c = req.getBody();
        rawGSEM.HTTP_Method__c = req.getMethod();
        
        if(String.isBlank(rawGSEM.JSON_Request__c)){
            rawGSEM.JSON_Request__c = 'No JSON content in HTTP \'GET\' Method Body';
        }
        
        Boolean isCalloutException = false;
        System.CalloutException coException = null;
        
        try {
            response = http.send(req);
            System.debug(' *** '+response.toString());
            System.debug('res.getBody():   ' + response.getBody());
            System.debug('STATUS:'+response.getStatus()); System.debug('STATUS_CODE:'+response.getStatusCode()); 
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(response.toString());
            System.debug('Callout error: '+ e.getLineNumber());
            System.debug('Callout error: '+ e.getCause());
            System.debug('Callout error: '+ e.getStackTraceString());
            
            isCalloutException = true;
            coException = e;
            
            // Send the error notification email 
            //sendErrorNotification(e, new GSEM__c(), );
        }
        finally{
            rawGSEM.HTTP_Status__c = response.getStatus();
            rawGSEM.HTTP_Status_Code__c = response.getStatusCode();
            rawGSEM.JSON_Response__c = response.getBody();
            
            if(!isCalloutException){
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
                
                // insert rawGSEM; 
            }
            
            if(isCalloutException && coException != null){
                
                sendErrorNotification(coException, new GSEM__c(), rawGSEM.Id);
            }
            
        }
        
        Datetime currentTime = System.now();
        
        //response = http.send(req);
        system.debug('get response *** ' + response.getBody());
        JSONParser parser = JSON.createParser(response.getBody());
        system.debug(' *** line 45 parser ' + parser);
        
        
        
        // check to see if this if this is real transaction and not just a placeholder
        // letting us know that that there is "No Message"
        Boolean realGSEMTxn = rawGSEM.JSON_Response__c.contains('"TransactionStatus":"Success"');
        
        
        
        
        
        //JSON2APEX a = (JSON2Apex) System.JSON.deserialize(response.getBody(), JSON2Apex.class);
        //string s = json.serialize(a);
        //system.debug(' *** line 49 ' + s);
        // GSEM__c g = [select Id from GSEM__c where Name = a.SERVICE_INCIDENT.RequesterID];
        string Id1 ;
        string requesterId;
        string i2;
        string i3;
        string i4;
        string s2;
        string tnName;
        string prResolutionDescription;
        string prResolutionTitle;
        boolean isClosingCase = false;
        //Type resultType = Type.forName('JSON2APEX');
        // JSON2APEX readValueAsResults = (JSON2APEX )JSON.createParser(response.getBody()).readValueAs(resultType);
        // System.debug('==========> createParser().readValueAs() results = ' +      readValueAsResults);
        
        GSEM__c g = new GSEM__c();
        //g.Current_GSEM_Message_Id__c = rawGSEM.GSEM_Message_Id__c;
        g.GSEM_Flow_Type__c = 'GSEM Requester Flow (Nimble Originated)'; 
        
        Acknowledge_Message__c am = new Acknowledge_Message__c();
        
        // capture raw json from the message
        am.jsonReceived__c = response.getBody();
        am.Raw_GSEM_Message__c = rawGSEM.Id;
        
        
        
        Onsite_Task__c otask = new Onsite_Task__c();
        
        // capture the case where there isn't a message id 
        // so the queue BACKLOG indicator can be cleared in the GSEM record
        //g.Current_GSEM_Message_Id__c = 'No Message';
        
        System.JSONToken nextToken;
        Boolean moreToProcess = true;
        
        //while (parser.nextToken() != null) {
        while(moreToProcess){
            try{
                nextToken = parser.nextToken();
                
                // exit while loop if message parsing is complete
                if(nextToken == null){
                    System.debug('Message parsing complete -- nextToken == null');
                    moreToProcess = false;
                    break;
                }
            }
            catch(Exception e){
                
                // exit if unexpected exception
                // typically due to unexpected character ('<' (code 60)) resulting from GSEM system error
                // which returns HTML instead of JSON
                System.debug('Message parsing exception: '+ e);
                System.debug('Message parsing exception: '+ e.getLineNumber());
                System.debug('Message parsing exception: '+ e.getCause());
                System.debug('Message parsing exception: '+ e.getStackTraceString());
                
                moreToProcess = false;
                break;
            }
            system.debug(' *** line 57 ' + parser.getCurrentToken());
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String currentPropertyName = parser.getText();
                if(currentPropertyName == 'RequesterID'){
                    parser.nextvalue();
                    requesterId =  parser.getText();
                    am.Requester_Id__c = requesterId;
                    g.pn2nRequesterID__c = requesterId;
                    System.debug('requesterId: '+ requesterId);
                    
                }
                // 
                // *** THIS IS MISLEADING -- THE FIELD ON THE POINTNEXT CASE IS SEVERITY ***
                // 
                else if(currentPropertyName == 'ProviderPriority'){
                    parser.nextvalue();
                    am.Provider_Severity__c = parser.getText();
                    g.Pointnext_Severity_Level__c = parser.getText();
                    g.Provider_Severity_Level__c = parser.getText();
                }
                else if(currentPropertyName == 'ProviderID'){
                    parser.nextvalue();
                    am.ProviderID__c = parser.getText();
                    g.Provider_ID__c = parser.getText();
                    g.Pointnext_Case__c = g.Provider_ID__c;
                    otask.Product_Number__c = parser.getText();
                }
                else if(currentPropertyName == 'CurrentState'){
                    parser.nextvalue();
                    am.Current_State__c = parser.getText();
                    g.Current_GSEM_State__c = parser.getText();
                    rawGSEM.GSEM_Call_Status__c = parser.getText();
                }
                else if(currentPropertyName == 'MessageID'){
                    parser.nextvalue();
                    am.MessageID__c = parser.getText();
                    // extract the most recent message id to use in determining
                    // whether the GSEM Requester Queue is backlogged
                    rawGSEM.GSEM_Message_Id__c = am.MessageID__c;
                    //g.Previous_GSEM_Message_Id__c = g.Current_GSEM_Message_Id__c;
                    g.Current_GSEM_Message_Id__c = am.MessageID__c;
                    i2 = parser.getText();
                }
                else if(currentPropertyName == 'TransactionName'){
                    parser.nextvalue();
                    am.TransactionName__c = parser.getText();
                    otask.Action_Type__c = parser.getText();
                    tnName = parser.getText();
                    
                }
                else if(currentPropertyName == 'TransactionAgentKey'){
                    parser.nextvalue();
                    am.TransactionAgentKey__c = parser.getText();                    
                }
                else if(currentPropertyName == 'RemoteAgentName'){
                    parser.nextvalue();
                    am.RemoteAgentName__c = parser.getText();
                    g.Remote_Agent_Name__c = parser.getText();
                }
                else if(currentPropertyName == 'RemoteAgentType'){
                    parser.nextvalue();
                    am.RemoteAgentType__c = parser.getText();
                }
                else if(currentPropertyName == 'ResponseTime'){
                    parser.nextvalue();
                    am.ResponseTime__c = parser.getText();
                    
                }
                else if(currentPropertyName == 'TransactionStatus'){
                    parser.nextvalue();
                    am.TransactionStatus__c = parser.getText();
                }
                else if(currentPropertyName == 'TransactionStatusCode'){
                    parser.nextvalue();
                    am.TransactionStatusCode__c = parser.getText();
                }
                else if(currentPropertyName == 'ObjectBuilderID'){
                    parser.nextvalue();
                    am.ObjectBuilderId__c = parser.getText();
                }
                else if(currentPropertyName == 'ECPVersion'){
                    parser.nextvalue();
                    am.ECPVersion__c = parser.getText();
                }
                else if(currentPropertyName == 'Comment'){
                    parser.nextvalue();
                    am.Comment__c = parser.getText().abbreviate(LONG_TEXT_AREA_MAX);   
                    g.Comment__c = am.Comment__c;
                }
                else if(currentPropertyName == 'ParameterList'){
                    parser.nextvalue();
                    am.Parameter_List__c = parser.getText().abbreviate(TEXT_AREA_MAX);   
                    //g.Comment__c = am.Comment__c;
                }
                else if(currentPropertyName == 'ActionLog'){
                    parser.nextvalue();
                    //am.Comment__c = parser.getText();
                    //g.Comment_from_PN__c = parser.getText();
                    s2 = parser.getText();                    
                    s2 = s2.replaceAll('\\s+',' ');
                    s2 = s2.abbreviate(LONG_TEXT_AREA_MAX);
                    // trim to avoid attempting to write more characters than the field can hold
                    am.Action_Log__c = s2;
                    g.ActionLog__c = s2;
                    //g.Comment_from_PN__c = s2; 
                    //am.Comment__c = s2;
                }
                else if(currentPropertyName == 'eCPExtMessage_EXT_SERVICE_INCIDENT_ProviderTaskID'){
                    parser.nextvalue();
                    otask.TASK_ID_WES__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_RepairDuration'){
                    parser.nextvalue();
                    try{
                        g.Repair_Hours__c = parser.getTimeValue();
                    }
                    catch(Exception e){
                        system.debug('Rx Field format ERROR - g.Repair_Hours__c:  ' + e.getMessage());   
                    }
                    
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_ServiceStartDateTime'){
                    parser.nextvalue();
                    g.Service_Start_date_time__c = DateTime.valueOf(parser.getText());
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_SystemFixedTime'){
                    parser.nextvalue();
                    g.System_Fixed_Date_time__c = DateTime.valueOf(parser.getText());
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_ServiceEndDateTime'){
                    parser.nextvalue();
                    g.Service_End_Date_time__c = DateTime.valueOf(parser.getText());
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledPartNumber' ){
                    parser.nextvalue();
                    g.Consumed_Part__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledPartDescription'){
                    parser.nextvalue();
                    g.Consumed_Part_Description__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledSerialNumber'){
                    parser.nextvalue();
                    g.Consumered_Part_Serial_Number__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedPartDescription'){
                    parser.nextvalue();
                    g.Removed_Part_Description__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedSerialNumber'){
                    parser.nextvalue();
                    g.Removed_Serial_Number__c  = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedPartNumber' ){
                    parser.nextvalue();
                    g.Removed_Part_Number__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_RepairClass'){
                    parser.nextvalue();
                    g.Repair_Class_Code__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_RepairClassText'){
                    parser.nextvalue();
                    g.Repair_Class_Text__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_DelayCode'){
                    parser.nextvalue();
                    g.Delay_Code__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_ExtServiceIncident_Repair_DelayCodeText' ){
                    parser.nextvalue();
                    g.Delay_Code_Text__c = parser.getText();
                }
                else if(currentPropertyName == 'StatementRole'){
                    parser.nextvalue();
                    if(parser.getText() == 'DESCRIPTION'){                    
                        parser.nextvalue();
                        prResolutionDescription = parser.getText().abbreviate(LONG_TEXT_AREA_MAX);
                        g.Resolution_Summary__c = prResolutionDescription;
                        
                    } else if (parser.getText() == 'TITLE'){  
                        parser.nextvalue();
                        prResolutionTitle = parser.getText().abbreviate(TEXT_AREA_MAX);
                    }
                }
            }
        } // end while
        
        System.debug('Message parsing complete -- nextToken == null');
        
        if(am.MessageID__c == null || am.MessageID__c == '')
        {
            system.debug('am.MessageID__c:  ' + am.MessageID__c);
            g.Current_GSEM_Message_Id__c = 'No Message';
            rawGSEM.GSEM_Message_Id__c = 'No Message';
        }
        
        
        
        
        
        //
        // transaction-specific processing below
        // 
        
        Boolean isDuplicateMessage = false;
        if(realGSEMTxn){
            
            GSEM_Comment__c gc = new GSEM_Comment__c();
            
            List<GSEM__c> lstGSEM =  new List<GSEM__c>();
            if(!Test.isRunningTest()){
                lstGSEM = [select id,Provider_ID__c,Provider_Priority__c,Product_Number__c,System_Serial_No__c, Comment_from_PN__c,GSEM__c,Delay_Code_Text__c ,Delay_Code__c ,Remote_Agent_Name__c,
                           Repair_Class_Text__c,Repair_Class_Code__c, Removed_Part_Number__c,Removed_Serial_Number__c, Removed_Part_Description__c,Consumered_Part_Serial_Number__c, Consumed_Part_Description__c,
                           Consumed_Part__c,Service_End_Date_time__c, System_Fixed_Date_time__c, Service_Start_date_time__c, Repair_Hours__c, Resolution_Code_Text__c,Resolution_Summary__c,
                           Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, SBU_Case_Priority__c, Requester_Priority__c
                           from GSEM__c where Name =: requesterId];
            }
            if(Test.isRunningTest()){
                lstGSEM = [select id,Provider_ID__c,Provider_Priority__c,Product_Number__c,System_Serial_No__c, Comment_from_PN__c,GSEM__c,Delay_Code_Text__c ,Delay_Code__c ,Remote_Agent_Name__c,
                           Repair_Class_Text__c,Repair_Class_Code__c, Removed_Part_Number__c,Removed_Serial_Number__c, Removed_Part_Description__c,Consumered_Part_Serial_Number__c, Consumed_Part_Description__c,
                           Consumed_Part__c,Service_End_Date_time__c, System_Fixed_Date_time__c, Service_Start_date_time__c, Repair_Hours__c, Resolution_Code_Text__c,Resolution_Summary__c,
                           Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, SBU_Case_Priority__c, Requester_Priority__c
                           from GSEM__c limit 1];
            }     
            //Integer index = allOpenGSEM.indexOf(lstGSEM[0]);
            
            //if(index != -1){
            //    allOpenGSEM.remove(index);
            //}
            //
            if(lstGSEM.size() > 0 && (lstGSEM[0].Current_GSEM_Message_Id__c != 'No Message')){
                realGSEM = lstGSEM[0];
                
                
                
                // process this message ONLY if we have not already received this message
                if(lstGSEM[0].Current_GSEM_Message_Id__c == g.Current_GSEM_Message_Id__c &&
                   (lstGSEM[0].Current_GSEM_Message_Id__c != 'No Message'  || lstGSEM[0].Current_GSEM_Message_Id__c != null)){
                       
                       isDuplicateMessage = true;
                       lstGSEM[0].Time_of_Last_Incoming_GSEM_Message_Dupe__c = currentTime;
                       lstGSEM[0].Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                       update lstGSEM[0];
                   }
                else{
                    
                    
                    
                    // capture transaction name for raw GSEM
                    rawGSEM.GSEM_Transaction_Type__c = tnName;
                    // pull the case priority
                    am.Requester_Priority__c = lstGSEM[0].SBU_Case_Priority__c;
                    
                    if(tnName == 'ACCEPT PROBLEM'){
                        rawGSEM.GSEM_Call_Status__c = 'PROBLEM ACCEPTED';    
                    }
                    else if(tnName == 'PROVIDE PROBLEM INFORMATION'){
                        rawGSEM.GSEM_Call_Status__c = 'OPEN REQUESTER';
                    }            
                    else if(tnName == 'PROBLEM RESOLUTION'){
                        rawGSEM.GSEM_Call_Status__c = 'CLOSED PENDING CONFIRMATION';   
                        isClosingCase = true;
                    }
                    
                    
                    
                    Raw_GSEM_Message__c rawOutboundMsg;
                    
                    if(lstGSEM.size() > 0) {
                        for(GSEM__c G1 : lstGSEM){
                            G1.Provider_ID__c = g.Provider_ID__c ;
                            G1.Provider_Priority__c = g.Provider_Priority__c ;
                            G1.Remote_Agent_Name__c = g.Remote_Agent_Name__c;
                            
                            // capture the message ids to check for GSEM Queue backlog
                            G1.Previous_GSEM_Message_Id__c = G1.Current_GSEM_Message_Id__c;
                            G1.Current_GSEM_Message_Id__c = g.Current_GSEM_Message_Id__c;
                            G1.pn2nRequesterID__c = g.pn2nRequesterID__c;
                            
                            //
                            // Comment handling below
                            // 
                            if(g.ActionLog__c != null && g.ActionLog__c != 'ACCEPT PROBLEM'){
                                String s;
                                if(G1.Comment_from_PN__c != null){
                                    s = G1.Comment_from_PN__c = g.ActionLog__c + '\n' + system.now() + '\n' + G1.Comment_from_PN__c;                                    
                                }
                                else{
                                    s = G1.Comment_from_PN__c =  g.ActionLog__c + '\n' + system.now();
                                }
                                // trim to avoid trying to write more characters than the max size of the field
                                if(s.length() > LONG_TEXT_AREA_MAX){
                                    s = s.abbreviate(LONG_TEXT_AREA_MAX-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
                                }
                                G1.Comment_from_PN__c = s;
                            }
                            
                            
                            
                            
                            if(isClosingCase == true){
                                G1.Repair_Hours__c = g.Repair_Hours__c;
                                G1.Service_Start_date_time__c = g.Service_Start_date_time__c;
                                G1.System_Fixed_Date_time__c = g.System_Fixed_Date_time__c;
                                G1.Service_End_Date_time__c = g.Service_End_Date_time__c;
                                G1.Consumed_Part__c = g.Consumed_Part__c;
                                G1.Consumed_Part_Description__c = g.Consumed_Part_Description__c;
                                G1.Consumered_Part_Serial_Number__c = g.Consumered_Part_Serial_Number__c;
                                G1.Removed_Part_Description__c = g.Removed_Part_Description__c;
                                G1.Removed_Serial_Number__c = g.Removed_Serial_Number__c;
                                G1.Removed_Part_Number__c = g.Removed_Part_Number__c;
                                G1.Repair_Class_Code__c = g.Repair_Class_Code__c;
                                G1.Repair_Class_Text__c  = g.Repair_Class_Text__c ;
                                G1.Delay_Code__c = g.Delay_Code__c;                
                                G1.Delay_Code_Text__c = g.Delay_Code_Text__c;
                                G1.Resolution_Code_Text__c = prResolutionTitle;  
                                G1.Time_of_Resolution__c = currentTime;
                                
                                //String[] bodyList = prResolutionDescription.split('\\['); 
                                //prResolutionDescription.replaceAll('\\]\\[', '\\]\\n\\[');
                                System.debug('prResolutionDescription - before split:  ' + prResolutionDescription);
                                
                                G1.Resolution_Summary__c = prResolutionDescription;
                                
                                am.SOLUTION_TITLE__c = prResolutionTitle;
                                am.SOLUTION_DESCRIPTION__c = prResolutionDescription;
                                //System.debug('bodyList:  ' + bodyList);
                                
                                //integer count = 0; 
                                
                                /*for(String str : bodyList){
//system.debug('------>'+s); 
if(count == 1){
G1.Resolution_Code_Text__c = prResolutionTitle;                        
}
if(count>3){
G1.Resolution_Summary__c = G1.Resolution_Summary__c + str.removeEnd(']');
}
count++;
}*/
                                
                                // since we received a PROBLEM RESOLUTION message
                                // we should confirm that the GSEM record will be closed
                                
                                rawOutboundMsg = sendConfirmCloseNotification(G1.Id);
                                
                                G1.Current_GSEM_State__c = rawOutboundMsg.GSEM_Call_Status__c;
                                
                                String commentBodyString;
                                
                                commentBodyString = '\nCase Transfer complete. Pointnext case will be closed.\n\n' +
                                    'No further communication will be accepted by PN for this case.\n\n' +
                                    'Resolution Summary:\n' + 
                                    g.Resolution_Summary__c;
                                
                                if(commentBodyString.length() > MAX_COMMENT_BODY_SIZE){
                                    commentBodyString = commentBodyString.abbreviate(MAX_COMMENT_BODY_SIZE-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
                                }
                                
                                gc.Complete_Case_Comment__c = commentBodyString;
                                
                                
                                // g.Resolution_Summary__c = 'Case Transfer complete. Pointnext case will be closed.\n\n' +
                                //                  '      Resolution Summary:  ' + g.Resolution_Summary__c /*+ '\n' +
                                //                'Resolution Description:  ' + prResolutionDescription + '\n\n' +
                                //              '             ActionLog:  ' + g.ActionLog__c*/;
                                
                                
                                //G1.Resolution_Code_Text__c = 
                                //G1.Resolution_Summary__c = 
                                //still pending resolution type
                            } // end if closing = true
                        } // end while loop
                        
                        system.debug('rawGSEM.JSON_Response__c.length(): ' + rawGSEM.JSON_Response__c.length());
                        
                        if(rawGSEM.JSON_Response__c.length() > LONG_TEXT_AREA_MAX){
                            rawGSEM.JSON_Response__c = rawGSEM.JSON_Response__c.abbreviate(LONG_TEXT_AREA_MAX-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
                        }
                        
                        system.debug('rawGSEM.JSON_Response__c.length(): ' + rawGSEM.JSON_Response__c.length());
                        
                        insert rawGSEM;
                        
                        am.Raw_GSEM_Message__c = rawGSEM.Id;
                        
                        // create GSEM Comment record
                        //gc.Complete_Case_Comment__c = 'Case Transfer complete. Pointnext case will be closed.\n\n' +
                        //                         '      Resolution Summary:  ' + g.Resolution_Summary__c;
                        gc.Direction__c = 'Inbound Comment';
                        gc.Action_Log__c = am.Action_Log__c;
                        gc.Comment__c = g.Comment__c;
                        gc.Parameter_List__c = am.Parameter_List__c;
                        gc.GSEM_Record__c = lstGSEM[0].id;
                        gc.Raw_GSEM_Message__c = rawGSEM.Id;
                        
                        insert gc;
                        
                        gc = [select Id, Complete_Case_Comment__c, Action_Log__c from GSEM_Comment__c where Id =:gc.Id];
                        
                        am.GSEM__c = lstGSEM[0].id;
                        
                        // link to parent GSEM record
                        rawGSEM.GSEM_Record__c = lstGSEM[0].id;  
                        
                        
                        // get the most recent Acknowledge Message to update the ACK Status
                        List<Acknowledge_Message__c> priorAckMsg = [SELECT Id, Name, Acknowledgement_Status__c 
                                                                    FROM Acknowledge_Message__c 
                                                                    WHERE GSEM__c =: lstGSEM[0].Id 
                                                                    ORDER BY CreatedDate DESC NULLS LAST
                                                                    LIMIT 1];
                        
                        if(priorAckMsg.size() > 0){
                            
                            //index = openGSEMAckList.indexOf(priorAckMsg[0]);
                            //openGSEMAckList.remove(index);
                            
                            // update GSEM record regardless of whether case is being closed
                            // so the current and previous message ids will be updated
                            if(lstGSEM[0].Current_GSEM_Message_Id__c != lstGSEM[0].Previous_GSEM_Message_Id__c  &&
                               (lstGSEM[0].Previous_GSEM_Message_Id__c != null || lstGSEM[0].Previous_GSEM_Message_Id__c != 'No Message')){
                                   // assumption is that either the ACK has been received 
                                   // OR there has been a 'Manual Acknowledgement' through the GSEM Dev Console
                                   priorAckMsg[0].Acknowledgement_Status__c = 'ACK RECEIVED';
                               }
                            else if(lstGSEM[0].Current_GSEM_Message_Id__c == lstGSEM[0].Previous_GSEM_Message_Id__c  &&
                                    (lstGSEM[0].Previous_GSEM_Message_Id__c != null || lstGSEM[0].Previous_GSEM_Message_Id__c != 'No Message')){
                                        priorAckMsg[0].Acknowledgement_Status__c = 'ACK NOT RECEIVED';
                                    }
                            update priorAckMsg;
                            update lstGSEM;
                        }
                    }
                    
                    Boolean amInsertSucceeded = true;
                    
                    system.debug('am.jsonReceived__c.length():  ' + am.jsonReceived__c.length());
                    if(am.jsonReceived__c.length() > LONG_TEXT_AREA_MAX){
                        
                        am.jsonReceived__c = am.jsonReceived__c.abbreviate(LONG_TEXT_AREA_MAX-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
                    }
                    
                    
                    system.debug('am.jsonReceived__c.length():  ' + am.jsonReceived__c.length());
                    
                    
                    try{
                        
                        insert am; 
                    }
                    catch(Exception e){
                        
                        system.debug('Insert Failure:  ' + e.getMessage());
                        amInsertSucceeded = false;
                        // capture DML error to indicate failure to create Acknowledge Message
                        rawGSEM.GSEM_Ack_DML_Error__c = e.getMessage();
                        
                    }
                    finally{
                        
                        if(amInsertSucceeded){
                            
                            rawGSEM.GSEM_Ack_DML_Error__c = 'No Error';
                            rawGSEM.GSEM_Acknowledge_Message__c = am.Id;
                        }
                        
                        rawGSEM.Related_GSEM_Comment__c = gc.Id;
                        
                        
                        system.debug('rawGSEM.JSON_Response__c.length():  ' + rawGSEM.JSON_Response__c.length());
                        
                        if(rawGSEM.JSON_Response__c.length() > LONG_TEXT_AREA_MAX){
                            rawGSEM.JSON_Response__c = rawGSEM.JSON_Response__c.abbreviate(LONG_TEXT_AREA_MAX-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
                        }
                        
                        system.debug('rawGSEM.JSON_Response__c.length():  ' + rawGSEM.JSON_Response__c.length());
                                                
                        update rawGSEM;
                        
                        
                    } // end of finally
                    
                    
                    
                    
                    system.debug(' *** Case ID ' +  lstGSEM[0].GSEM__c);    
                    system.debug(' *** GSEM record ID ' +  lstGSEM[0].id);
                    system.debug(' *** isClosingCase ' + isClosingCase);
                    
                    If(isClosingCase == false && (lstGSEM[0].Current_GSEM_Message_Id__c != 'No Message')){
                        
                        otask.Case__c = lstGSEM[0].GSEM__c;
                        otask.GSEM__c = lstGSEM[0].id ; 
                        
                        Set<string> taskID = new set<String>();  
                        
                        List<Onsite_Task__c> existingLst = [select Id, Action_Type__c, Product_Description__c,Product_Number__c,Problem_Description__c,
                                                            Serial_Number__c, Comment__c,Comment_PN__c,TASK_ID_WES__c,Scheduling_Status__c,ResponseTime__c from Onsite_Task__c where GSEM__c =: lstGSEM[0].id  ];
                        
                        for(Onsite_Task__c ot1 : existingLst){
                            if(ot1.TASK_ID_WES__c != null && !taskID.contains(ot1.TASK_ID_WES__c)){
                                taskID.add(ot1.TASK_ID_WES__c);
                            }
                        }
                        
                        string t1 = otask.TASK_ID_WES__c;
                        string t2 = s2.substringBefore('for task');
                        string t4 = s2.substringAfter('\nStatus Notes:');
                        string t5 = s2.substringbetween ('than','UTC');
                        
                        // t2 maps to Onsite_Task__c.Action_Type__c 
                        // Onsite_Task__c.Action_Type__c data type is: Long Text Area(2500)
                        if(t2.length() > 2500){
                            t2 = t2.abbreviate(2500);
                        }
                        if(t5 != null && t5!= ''){
                            otask.ResponseTime__c = t5 + 'UTC)';
                            if(otask.ResponseTime__c.length() > TEXT_AREA_MAX){
                                otask.ResponseTime__c = otask.ResponseTime__c.abbreviate(TEXT_AREA_MAX);
                            }
                        }
                        List<Onsite_Task_Status__mdt> otskmdt = [select Id, label from Onsite_Task_Status__mdt];
                        string nstr ;
                        for(Onsite_Task_Status__mdt  o: otskmdt){
                            if(s2.contains(o.label)){
                                nstr = o.label;
                            }
                        }
                        
                        system.debug(' line 224 *** ' + t1 + ' ,' + t2 + ' ,'+ t4);
                        system.debug(' *** line 225 ' + nstr);
                        system.debug(' line 226 t4 is ' + t4);
                        system.debug(' line 226 t5 is ' + t5);
                        system.debug(' *** size of existingLst ' + existingLst.size());
                        
                        if(existingLst.size() > 0){
                            boolean nOtask = false;
                            for(Onsite_Task__c ot : existingLst){
                                system.debug( ' ***  ot wes id ' + ot.TASK_ID_WES__c );
                                system.debug(' *** otask wes id ' + otask.TASK_ID_WES__c);
                                if(ot.TASK_ID_WES__c == otask.TASK_ID_WES__c){
                                    ot.Action_Type__c = t2;
                                    //if(t4 != null && t4 != '' && t4 != '.'){
                                    ot.Comment_PN__c = ot.Comment_PN__c + '\n' + s2 + system.now() ;
                                    //}
                                    if(nstr != null && nstr != ''){
                                        ot.Scheduling_Status__c = nstr;
                                    }
                                    ot.ResponseTime__c = otask.ResponseTime__c ;
                                    
                                    system.debug(' *** line 237  existingLst ' + existingLst ); 
                                    nOtask = true;
                                    update ot;
                                }
                            }
                            
                            if(nOtask == false){
                                
                                otask.Action_Type__c = t2;
                                if(t4 != null && t4 != '' && t4 != '.'){
                                    otask.Comment_PN__c = t4 + system.now(); 
                                }
                                if(nstr != null && nstr != ''){
                                    otask.Scheduling_Status__c = nstr;
                                }    
                                t2 = t2.trim();
                                if(t2 != 'ACCEPT PROBLEM' && otask.TASK_ID_WES__c != null){
                                    insert otask;
                                    system.debug( ' *** onsite task inserted ' + otask);
                                }
                                
                            }
                        }
                        else if(existingLst.size() == 0 &&  otask.TASK_ID_WES__c != null ){
                            system.debug( ' ***  am provider ID ' + am.ProviderID__c );
                            system.debug(' *** otask wes id ' + otask.TASK_ID_WES__c);
                            
                            otask.Action_Type__c = t2;
                            if(t4 != null && t4 != '' && t4 != '.'){
                                otask.Comment_PN__c = t4 + system.now(); 
                            }
                            if(nstr != null && nstr != ''){
                                otask.Scheduling_Status__c = nstr;
                            }    
                            t2 = t2.trim();
                            if(t2 != 'ACCEPT PROBLEM'){
                                insert otask;
                                system.debug( ' onsite task inserted ' + otask);
                            }
                            
                        }
                        else if(otask.TASK_ID_WES__c == null){
                            //if(t2 != 'ACCEPT PROBLEM'){
                            update lstGSEM;
                            system.debug( ' *** update GSEM ' + lstGSEM);
                            //}
                        }
                        
                    }// if transaction Name is not Problem Resolution            
                    
                    
                    
                    system.debug(' **** ' + am);            
                    
                    if(rawOutboundMsg != null){
                        insert rawOutboundMsg;
                    }
                    
                    // truncate string for populating comment body which only holds 4000 chars
                    String commentBodyString;
                    
                    if(isClosingCase == true){
                        //update lstGSEM;
                        system.debug( ' closing case ' );
                        commentBodyString = gc.Complete_Case_Comment__c;
                        if(commentBodyString.length() > MAX_COMMENT_BODY_SIZE){
                            commentBodyString = commentBodyString.abbreviate(MAX_COMMENT_BODY_SIZE-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
                        }
                        closureCaseComment = new CaseComment(ParentId = lstGSEM[0].GSEM__c, CommentBody = commentBodyString);
                        //insert cscm;
                    }
                    else{
                        commentBodyString = '\n' + gc.Action_Log__c;
                        
                        if(commentBodyString.length() > MAX_COMMENT_BODY_SIZE){
                            commentBodyString = commentBodyString.abbreviate(MAX_COMMENT_BODY_SIZE-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
                        }
                        
                        newCaseComment = new CaseComment(ParentId = lstGSEM[0].GSEM__c, CommentBody = commentBodyString);
                    }
                }
            } // end of duplicate check/processing
        } // end of realGSEMTxn
        
        
        
        Boolean processAll;
        
        if(realGSEM == null){
            processAll = true;
        }
        else{
            processAll = false;
        }
        
        if(!isCalloutException){
            
            // update all open GSEM records on the GSEM Requester Flow so that the GSEM Queue Health is updated properly
            allOpenGSEM = [select id, RecordType.Name, Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, Confirm_Close__c, GSEM_Queue_Status__c,
                           (SELECT Id, Name, Acknowledgement_Status__c 
                            FROM Acknowledge_Messages__r                                                   
                            ORDER BY CreatedDate DESC NULLS LAST
                            LIMIT 1)
                           from GSEM__c 
                           where RecordType.Name = 'Nimble to PN' AND Confirm_Close__c = 'OPEN'
                           ORDER BY CreatedDate DESC NULLS LAST];
            if(realGSEM != null){
                
                Integer index = allOpenGSEM.indexOf(realGSEM);
                
                System.debug('indexOf(realGSEM): ' + index);
                
                if(index != -1){
                    allOpenGSEM.remove(index);
                }
            }
            
            
            // obtain the message id to determine if the GSEM Queue is unblocked
            rawGSEM.GSEM_Message_Id__c = 'No Message'; 
            
            /*if(isDuplicateMessage){
// do nothing
}
else{*/
            for(GSEM__c gIter : allOpenGSEM){
                
                if(processAll){
                    gIter.Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    //gIter.Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    //gIter.Previous_GSEM_Message_Id__c = gIter.Current_GSEM_Message_Id__c;
                    //gIter.Current_GSEM_Message_Id__c  = rawGSEM.GSEM_Message_Id__c;
                    
                    System.debug('gIter.Acknowledge_Messages__r.size():  ' + gIter.Acknowledge_Messages__r.size());
                    System.debug('gIter.Acknowledge_Messages__r:  ' + gIter.Acknowledge_Messages__r);
                    
                    if(gIter.Acknowledge_Messages__r.size() > 0){
                        
                        System.debug('THERE ARE ACK MESSAGES FOR THIS GSEM RECORD');
                        
                        System.debug('gIter.Acknowledge_Messages__r[0].Id:  ' + gIter.Acknowledge_Messages__r[0].Id);
                        System.debug('gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c:  ' + gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c);
                        System.debug('gIter.Acknowledge_Messages__r[0].Name:  ' + gIter.Acknowledge_Messages__r[0].Name);
                        
                        
                        System.debug('   gIter.Id: ' + gIter.Id);
                        if(realGSEM != null){
                            System.debug('realGSEM.Id: ' + realGSEM.Id);
                        }
                        
                        
                        if(gIter.Acknowledge_Messages__r[0].Id != null && 
                           gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c != null){
                               
                               if(gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c != 'ACK RECEIVED'){
                                   
                                   
                                   if( (gIter.Current_GSEM_Message_Id__c != gIter.Previous_GSEM_Message_Id__c  && 
                                        (gIter.Previous_GSEM_Message_Id__c != 'No Message' || gIter.Previous_GSEM_Message_Id__c != null)
                                       )
                                     )
                                       
                                   {
                                       System.debug('THE REQUIREMENTS HAVE BEEN MET: ACK RECEIVED');
                                       // update GSEM record regardless of whether case is being closed
                                       // so the current and previous message ids will be updated
                                       
                                       // assumption is that either the ACK has been received 
                                       // OR there has been a 'Manual Acknowledgement' through the GSEM Dev Console
                                       gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c = 'ACK RECEIVED';
                                       
                                       // add this ack message record to the set for update
                                       ackList.add(gIter.Acknowledge_Messages__r[0]);
                                   }
                                   else if((gIter.Current_GSEM_Message_Id__c == gIter.Previous_GSEM_Message_Id__c)  &&
                                           (gIter.Previous_GSEM_Message_Id__c != 'No Message' || gIter.Previous_GSEM_Message_Id__c != null)){
                                               
                                               System.debug('THE REQUIREMENTS HAVE NOT BEEN MET: ACK NOT RECEIVED');
                                               gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c = 'ACK NOT RECEIVED';
                                               
                                               // add this ack message record to the set for update
                                               ackList.add(gIter.Acknowledge_Messages__r[0]);
                                           }
                               }
                           }
                        
                    }
                    
                }
               /* else if(gIter.Id == realGSEM.Id){
                    
                    System.debug('SKIPPING REAL GSEM: ' + realGSEM);
                    continue;                      
                }*/
                else{                     
                    gIter.Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    //gIter.Previous_GSEM_Message_Id__c = gIter.Current_GSEM_Message_Id__c;
                    //gIter.Current_GSEM_Message_Id__c  = rawGSEM.GSEM_Message_Id__c;
                    
                    System.debug('gIter.Acknowledge_Messages__r.size():  ' + gIter.Acknowledge_Messages__r.size());
                    System.debug('gIter.Acknowledge_Messages__r:  ' + gIter.Acknowledge_Messages__r);
                    
                    if(gIter.Acknowledge_Messages__r.size() > 0){
                        
                        System.debug('THERE ARE ACK MESSAGES FOR THIS GSEM RECORD');
                        
                        System.debug('gIter.Acknowledge_Messages__r[0].Id:  ' + gIter.Acknowledge_Messages__r[0].Id);
                        System.debug('gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c:  ' + gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c);
                        System.debug('gIter.Acknowledge_Messages__r[0].Name:  ' + gIter.Acknowledge_Messages__r[0].Name);
                        
                        
                        System.debug('   gIter.Id: ' + gIter.Id);
                        if(realGSEM != null){
                            System.debug('realGSEM.Id: ' + realGSEM.Id);
                        }
                        
                        
                        if(gIter.Acknowledge_Messages__r[0].Id != null && 
                           gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c != null){
                               
                               if(gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c != 'ACK RECEIVED'){
                                   
                                   
                                   if( (gIter.Current_GSEM_Message_Id__c != gIter.Previous_GSEM_Message_Id__c  && 
                                        (gIter.Previous_GSEM_Message_Id__c != 'No Message' || gIter.Previous_GSEM_Message_Id__c != null)
                                       )
                                     )
                                       
                                   {
                                       System.debug('THE REQUIREMENTS HAVE BEEN MET: ACK RECEIVED');
                                       // update GSEM record regardless of whether case is being closed
                                       // so the current and previous message ids will be updated
                                       
                                       // assumption is that either the ACK has been received 
                                       // OR there has been a 'Manual Acknowledgement' through the GSEM Dev Console
                                       gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c = 'ACK RECEIVED';
                                       
                                       // add this ack message record to the set for update
                                       ackList.add(gIter.Acknowledge_Messages__r[0]);
                                   }
                                   else if((gIter.Current_GSEM_Message_Id__c == gIter.Previous_GSEM_Message_Id__c)  &&
                                           (gIter.Previous_GSEM_Message_Id__c != 'No Message' || gIter.Previous_GSEM_Message_Id__c != null)){
                                               
                                               System.debug('THE REQUIREMENTS HAVE NOT BEEN MET: ACK NOT RECEIVED');
                                               gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c = 'ACK NOT RECEIVED';
                                               
                                               // add this ack message record to the set for update
                                               ackList.add(gIter.Acknowledge_Messages__r[0]);
                                           }
                               }
                           }
                        
                    }
                    
                }
            }

            
            // 
            // this should probably be replaced with a real batch job
            // but, there are likely only 2 or 3 DML calls for now
            // 
            
            System.debug('allOpenGSEM.size():  ' + allOpenGSEM.size());
            
            if(allOpenGSEM.size() > 0){
                
                Integer maxDMLRecordsPerBatch = 200;                
                Integer batchesNeeded = allOpenGSEM.size()/maxDMLRecordsPerBatch;
                Integer additionalRecordsRemaining = Math.mod(allOpenGSEM.size(), maxDMLRecordsPerBatch);
                
                System.debug('             batchesNeeded:  ' + batchesNeeded);
                System.debug('additionalRecordsRemaining:  ' + additionalRecordsRemaining);
                
                if(additionalRecordsRemaining > 0){
                    batchesNeeded++;
                }
                
                System.debug('             batchesNeeded:  ' + batchesNeeded);
                
                
                List<GSEM__c> batch = new List<GSEM__c>();
                
                for(Integer bc = 0; bc < batchesNeeded; bc++){
                    
                    System.debug('batch count:  ' + bc);
                    
                    for(Integer i = 0;  i < maxDMLRecordsPerBatch; i++ ){
                        if(bc == batchesNeeded-1 && i == additionalRecordsRemaining-1){
                            break;
                        }
                        System.debug('allOpenGSEM[' + ((bc * maxDMLRecordsPerBatch) + i) + ']');
                        batch.add(allOPenGSEM[(bc * maxDMLRecordsPerBatch) + i]);
                    }
                    
                    System.debug('Updating current batch:  ' + batch.size() + ' records in this batch');
                    update batch;
                    
                    batch.clear();
                }
            }
            if(ackList.size() > 0){                
                update ackList;
            }
            if(newCaseComment != null){
                insert newCaseComment;
            }
            if(closureCaseComment != null){
                insert closureCaseComment;
            }
            
        }
        /*if(!isCalloutException){


system.debug('isCalloutException should be false - isCalloutException: ' + isCalloutException);            
// create the record now in case uncaught parsing exceptions prevent saving later
//insert rawGSEM;
//}
//else{
// our HTTP REQ 'GET' message out to GSEM was somehow invalid (e.g malformed JSON, duplicate, sent message at inappropriate state of gsem call)
// this message does NOT contain a real message  with a real message id


system.debug('realGSEMTxn should be false: ' + realGSEMTxn);


// obtain the message id to determine if the GSEM Queue is unblocked
//rawGSEM.GSEM_Message_Id__c = 'No Message';
system.debug('Incoming Message Id: ' + rawGSEM.GSEM_Message_Id__c);

// update all open GSEM records on the GSEM Requester Flow so that the GSEM Queue Health is updated properly
allOpenGSEM = [select id, RecordType.Name, Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, Confirm_Close__c, GSEM_Queue_Status__c /*,
(SELECT Id, Name, Acknowledgement_Status__c 
FROM Acknowledge_Messages__r                                                   
ORDER BY CreatedDate DESC NULLS LAST
LIMIT 1) */
        //   from GSEM__c 
        //   where RecordType.Name = 'Nimble to PN' AND Confirm_Close__c = 'OPEN'];
        
        // remove real message from allOpenGSEM since it has already been processed
        /*Integer index = allOpenGSEM.indexOf(realGSEM);

if(index != -1){
allOpenGSEM.remove(index);
} */
        
        /*  System.debug('realGSEM: ' + realGSEM);
for(GSEM__c gIter : allOpenGSEM){

gIter.Time_of_Last_GSEM_Queue_Polling__c = currentTime;

}
if(allOpenGSEM.size() > 0){

update allOpenGSEM;
}/*

/*if(openGSEMAckList.size() > 0){
update openGSEMAckList;
}*/
    } 
    
    // 
    // THIS METHOD IS NOT CURRENTLY USED
    // THIS METHOD CREATES MAL-FORMED JSON
    // THE METHOD FOR THE OEM PROVIDER FLOW IS BEING UTILIZED FOR BOTH DIRECTIONS UNTIL GSEM REDESIGN
    // 
    @future(callout=true)
    public static void sendPPINotification(Id gsemId)
    {
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_Sandbox');
            
        }   
        
        String nimbleAgentName = gsemInfo.RemoteAgentName__c;
        
        System.debug('gsemInfo:  ' + gsemInfo);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setHeader('AgentName',gsemInfo.RemoteAgentName__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);
        req.setMethod('POST');
        DateTime dt = system.today();
        Datetime GMTDate = Datetime.newInstanceGmt(
            dt.year(),
            dt.month(),
            dt.day(),
            dt.hour(),
            dt.minute(),
            dt.second());
        string dt2 = string.valueOf(GMTDate) +',' + string.valueOf(dt);
        List<GSEM__C> gLst = [SELECT Id, Name, Company_Name__c,Address_1__c,Address_2__c,City__c,Contract_Id__c,State__c,Zipcode__c,Country__c, ContactFirstName__c, 
                              Contact_Last_Name__c,Problem_Title__c,Resolution_Code_Text__c,CSR_Part_Description__c,Consumed_Part_Description__c,Cust_ticket__c,
                              Comment__c, Contact_Email__c, Contact_Fax__c, Serial_Number__c, Product_Number__c, Contact_Phone__c, System_Serial_No__c, sendPPI__c,
                              Current_GSEM_State__c, Severity_Level__c
                              FROM GSEM__c where id =: gsemId];
        
        // working string  string t = ('{"Message": {"TransactionName": "SERVICE REQUEST","RemoteAgentName": "'+gsemInfo.RemoteAgentName__c+'","StopOnConversion": "false","RemoteAgentType": "HPE","eCPControl": {"ECPVersion": "1.0"},"SERVICE_INCIDENT": {"RequesterID": "R_2019_841539223","RequesterSeverity": "Critical","ResponseTime": "2019-09-04 15:37:05,2019-09-04 22:37:05","SERVICE_REQUESTER": {"ORGANIZATION": {"Business": "Computer manufacturer","OrganizationName": "Huf Huelsbeck Fuerst GmbH","ADDRESS": {"AddressType": "PRIMARY","GeoAddress1": "307 E City road","City": "Indianapolis","Region": "IN","PostalCode": "46285","TimeZone": "EST","Country": "US","LOCATION": [{"ID": "11111111","Type": "PRIMARY_VOICE"},{"ID": "+31 6 123456789","Type": "ALTERNATE_VOICE"},{"ID": "+31 12345 6789","Type": "FAX"},{"ID": "Eric.Sonneveld@digital.com","Type": "EMAIL"},{"ID": "http://www.digital.com","Type": "URL"}]}},"PERSON": {"FirstName": "Eric","LastName": "Benegal","Salutation": "Mr. ","Title": "Title","ContactType": "LG=ENG","CommunicationMode": "PRIMARY_VOICE","ADDRESS": {"AddressType": "PRIMARY","GeoAddress1": "307 E City Road","City": "Indianapolis","Region": "IN","PostalCode": "46285","TimeZone": "EST","Country": "US","LOCATION": [{"ID": "898989889","Type": "PRIMARY_VOICE"},{"ID": "+31 6 123456789","Type": "ALTERNATE_VOICE"},{"ID": "+31 (0)30 222 5000","Type": "FAX"},{"ID": "Eric.Sonneveld@HP.com","Type": "EMAIL"},{"ID": "http://www.hp.com","Type": "URL"}]}}},"AGREEMENT": {"ContractID": "ABC-7878","AgreementType": "SN=NSN:WFMPNLIST ;PN=WFMPNLIST;RI=USA_OR Eli Lilly"},"ACTIVITY": [{"ActionLog": "Service_Incident Submission","LocalDate": "2019-09-04 15:37:05,2019-09-04 22:37:05","ParameterList": "Service_Incident:Create"}],"PROBLEM": {"EXPRESSION": {"Relation": "AND","STATEMENT": [{"StatementRole": "DESCRIPTION","StatementText": "test problem"},{"StatementRole": "TITLE","StatementText": "test problem"}]}}}}}');     
        
        if(gLst[0].Current_GSEM_State__c != 'CLOSED' && gLst[0].Current_GSEM_State__c != 'CLOSED PENDING CONFIRMATION' ){
            
            
            
            
            //not working string t2= ('{"Message": {"TransactionName": "SERVICE REQUEST","RemoteAgentName": "'+gsemInfo.RemoteAgentName__c+'","StopOnConversion": "false","RemoteAgentType": "HPE","eCPControl": {"ECPVersion": "1.0"},"SERVICE_INCIDENT": {"RequesterID": "GSM-0006", "RequesterSeverity": "Critical","ResponseTime": "2019-09-25 10:00:00,2019-09-25 17:00:00","SERVICE_REQUESTER": {"ORGANIZATION": {"Business": "BTS USA","OrganizationName": "BTS USA","ADDRESS": {"AddressType": "4","GeoAddress1": "Rehav-Am Zeevi","City"  "Richardson","Region": "TX","PostalCode": "75080","TimeZone": "PST","Country": "US","LOCATION": [{"ID": "1.0","TYPE": "PRIMARY_VOICE"}, {"ID": "1.0","TYPE": "ALTERNATE_VOICE"}, {"ID": "1.0","TYPE": "FAX"}, {"ID": "1.0","TYPE": "EMAIL"}, {"ID": "1.0","TYPE": "URL"}]}},"PERSON": {"FirstName": "NOC","LastName": "Team","Salutation": "1.0","Title": "Standby Controller Not Available Alert","ContactType": "1.0","CommunicationMode": "FAX","ADDRESS": {"AddressType": "4","GeoAddress1": "Rehav-Am Zeevi","City": "Richardson","Region": "TX","PostalCode": "75080","TimeZone": "PST","Country": "US","LOCATION": [ {"ID": "1.0","TYPE": "RIMARY_VOICE"}, {"ID": "1.0","TYPE": "ALTERNATE_VOICE"}, {"ID": "1.0","TYPE": "FAX"}, {"ID": "1.0","TYPE": "EMAIL"}, {"ID": "1.0","TYPE": "URL"}]}}},"AGREEMENT": {"ContractID": "1","AgreementType": "SN=NSN:WFMPNLIST ;PN=WFMPNLIST;RI=USA_OR Eli Lilly"},"ACTIVITY": [ {"ActionLog": "Service_Incident Submission","LocalDate": "2019-09-04 15:37:05,2019-09-04 22:37:05","ParameterList": "Service_Incident:Create"}],"PROBLEM": {"EXPRESSION": {"Relation": "AND","STATEMENT": [ {"StatementRole": "DESCRIPTION","StatementText": "TEst GSM-009"}, {"StatementRole": "TITLE","StatementText": "Snapshot or Backup Problem"}]}}}}}');
            //string t3 = ('{"Message": {"TransactionName": "PROVIDE PROBLEM INFORMATION","RemoteAgentName": "'+gsemInfo.RemoteAgentName__c+'","StopOnConversion": "False","SERVICE_INCIDENT": {"RequesterID": "'+gLst[0].Name+'","RequesterSeverity": "CRITICAL","ResponseTime": "'+dt2+'","Comment": "'+gLst[0].Comment__c+'","SERVICE_REQUESTER": {"PERSON": {"FirstName": "'+gLst[0].ContactFirstName__c+'","LastName": "'+gLst[0].Contact_Last_Name__c+'","Salutation": "Mr.","Title": "'+gLst[0].Problem_Title__c+'","ContactType": "LG=ENG","CommunicationMode": "PRIMARY_VOICE","ADDRESS": {"AddressType": "PRIMARY","LOCATION": [{"ID": "'+gLst[0].Contact_Phone__c+'","Type": "PRIMARY_VOICE"}]}}},"AGREEMENT": {"ContractID": "CN='+gLst[0].Contract_Id__c+'","AgreementType": "SN='+gLst[0].System_Serial_No__c+' ;PN='+gLst[0].Product_Number__c+';LN='+gLst[0].Cust_ticket__c+'"},"ACTIVITY": [{"ActionLog": "Provide Problem Information","LocalDate": "'+dt2+'","ParameterList": "Problem:Add","NameValuePairList": {}}],"PROBLEM": {"EXPRESSION": {"Relation": "AND","STATEMENT": [{"StatementRole": "TITLE","StatementText": "'+gLst[0].Consumed_Part_Description__c+'"},{"StatementRole": "DESCRIPTION","StatementText": "'+gLst[0].CSR_Part_Description__c+'"}]}}},"eCPControl": {"ECPVersion": "1.0"}}}');
            //string t3 = ('{"Message":{"TransactionName": "PROVIDE PROBLEM INFORMATION","RemoteAgentName": "'+gsemInfo.RemoteAgentName__c+'","SERVICE_INCIDENT": {"RequesterID": "'+gLst[0].Name+'","RequesterSeverity": "CRITICAL","ResponseTime": "'+dt2+'","Comment": "'+gLst[0].Comment__c+'","ACTIVITY": [{"ActionLog": "'+gLst[0].Comment__c+'","LocalDate": "'+dt2+'","ParameterList": "Problem:Add"}]},"eCPControl": {"ECPVersion": "1.0"}  }}');
            string t3 = ('{"Message":{"TransactionName":"PROVIDE PROBLEM INFORMATION","RemoteAgentName":"'+gsemInfo.RemoteAgentName__c+'","StopOnConversion":"false","SERVICE_INCIDENT":{"RequesterID":"'+gLst[0].Name+'","RequesterSeverity":"'+gLst[0].Severity_Level__c+'","ResponseTime":"'+dt2+'","Comment":"","ACTIVITY":[{"ActionLog":"'+gLst[0].Comment__c+'","LocalDate":"'+dt2+'","ParameterList":"Problem:Add"}]},"eCPControl":{"ECPVersion":"1.0"}}}');
            
            req.setBody(t3);
            system.debug(' ***** ' + t3);
            // req.setBody('Id='+EncodingUtil.urlEncode(Id, 'UTF-8')+'&Email='+EncodingUtil.urlEncode(Email, 'UTF-8')+'&First_Name='+EncodingUtil.urlEncode(First_Name, 'UTF-8')+'&Last_Name='+EncodingUtil.urlEncode(Last_Name, 'UTF-8')+'&Title='+EncodingUtil.urlEncode(Title, 'UTF-8'));
            //req.setCompressed(true); // otherwise we hit a limit of 32000
            
            // this record will be created immediately to hold the unparsed JSON in the event of a parsing error or Ack Message creation preventing a record update
            // it will be deleted later following successful parsing and Acknowledge Message creation
            Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();
            
            // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
            String newLineC = '\n';
            String newLineReplacement = ' ';
            rawGSEM.GSEM_Flow_Type__c = 'GSEM Requester Flow (Nimble Originated)'; 
            rawGSEM.Message_Direction__c = 'Outbound';
            rawGSEM.JSON_Request__c = req.getBody().stripHtmlTags();
            rawGSEM.JSON_Request__c.replaceAll(newLineReplacement,newLineC);
            rawGSEM.GSEM_Transaction_Type__c = 'PROVIDE PROBLEM INFORMATION';
            rawGSEM.GSEM_Record__c = gsemId;  // not sure if this won't be null
            rawGSEM.GSEM_Message_Id__c = 'N/A';
            rawGSEM.GSEM_Ack_DML_Error__c = 'N/A';
            rawGSEM.HTTP_Method__c = req.getMethod();
            
            Boolean isCalloutException = false;
            System.CalloutException coException = null;
            
            try {
                res = http.send(req);
                System.debug(' *** '+res.toString());
                System.debug('STATUS:'+res.getStatus()); System.debug('STATUS_CODE:'+res.getStatusCode()); 
                gLst[0].sendPPI__c = false;
                update gLst[0];
            } 
            catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug('Callout error: '+ e.getLineNumber());
                System.debug('Callout error: '+ e.getCause());
                System.debug('Callout error: '+ e.getStackTraceString());
                
                System.debug(res.toString());
                
                isCalloutException = true;
                coException = e;
                
                // Send the error notification email 
                //sendErrorNotification(e, gLst[0]);
            }
            finally{
                rawGSEM.HTTP_Status__c = res.getStatus();
                rawGSEM.HTTP_Status_Code__c = res.getStatusCode();
                rawGSEM.JSON_Response__c = res.getBody();
                
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
                
                rawGSEM.GSEM_Engine_Transaction_Status__c = jsonRsp.mid(strtIdx, len);
                
                if(rawGSEM.GSEM_Engine_Transaction_Status__c == 'Success'){
                    gLst[0].Current_GSEM_State__c = 'OPEN PROVIDER';
                    rawGSEM.GSEM_Call_Status__c = 'OPEN PROVIDER';
                }
                else{
                    rawGSEM.GSEM_Call_Status__c = gLst[0].Current_GSEM_State__c;
                }
                
                if(rawGSEM.JSON_Response__c.length() > LONG_TEXT_AREA_MAX){
                    rawGSEM.JSON_Response__c = rawGSEM.JSON_Response__c.abbreviate(LONG_TEXT_AREA_MAX-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
                }
                
                insert rawGSEM; 
                
                if(isCalloutException && coException != null){
                    
                    sendErrorNotification(coException, gLst[0], rawGSEM.Id);
                }
            }
            
            
            
        }
        else{
            
            gLst[0].sendPPI__c = false;
        }
        
    }
    
    
    @future(callout=true)
    public static void sendPPINotificationOTask(Id oId)
    {
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_Sandbox');
            
        }   
        
        String nimbleAgentName = gsemInfo.RemoteAgentName__c;
        
        System.debug('gsemInfo:  ' + gsemInfo);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);
        req.setMethod('POST');
        DateTime dt = system.today();
        Datetime GMTDate = Datetime.newInstanceGmt(
            dt.year(),
            dt.month(),
            dt.day(),
            dt.hour(),
            dt.minute(),
            dt.second());
        string dt2 = string.valueOf(GMTDate) +',' + string.valueOf(dt);
        List<Onsite_Task__c> oTask = [select Id, GSEM__C,Comment__c,Send_PPI__c from Onsite_Task__c where id =: oId];
        List<GSEM__C> gLst = [SELECT Id, Name, Company_Name__c,Address_1__c,Address_2__c,City__c,Contract_Id__c,State__c,Zipcode__c,Country__c, 
                              ContactFirstName__c, Contact_Last_Name__c,Problem_Title__c,Resolution_Code_Text__c,CSR_Part_Description__c,
                              Consumed_Part_Description__c,Cust_ticket__c,Comment__c, Contact_Email__c, Contact_Fax__c, Serial_Number__c, 
                              Product_Number__c, Contact_Phone__c, System_Serial_No__c, Current_GSEM_State__c
                              FROM GSEM__c where id =: oTask[0].GSEM__C];
        
        string t3 = ('{"Message":{"TransactionName":"PROVIDE PROBLEM INFORMATION","RemoteAgentName":"'+gsemInfo.RemoteAgentName__c+'","StopOnConversion":"false","SERVICE_INCIDENT":{"RequesterID":"'+gLst[0].Name+'","RequesterSeverity":"CRITICAL","ResponseTime":"'+dt2+'","Comment":"","ACTIVITY":[{"ActionLog":"'+oTask[0].Comment__c+'","LocalDate":"'+dt2+'","ParameterList":"Problem:Add"}]},"eCPControl":{"ECPVersion":"1.0"}}}');
        
        req.setBody(t3);
        system.debug(' ***** ' + t3);
        // req.setBody('Id='+EncodingUtil.urlEncode(Id, 'UTF-8')+'&Email='+EncodingUtil.urlEncode(Email, 'UTF-8')+'&First_Name='+EncodingUtil.urlEncode(First_Name, 'UTF-8')+'&Last_Name='+EncodingUtil.urlEncode(Last_Name, 'UTF-8')+'&Title='+EncodingUtil.urlEncode(Title, 'UTF-8'));
        req.setCompressed(true); // otherwise we hit a limit of 32000
        
        // this record will be created immediately to hold the unparsed JSON in the event of a parsing error or Ack Message creation preventing a record update
        // it will be deleted later following successful parsing and Acknowledge Message creation
        Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();
        
        
        // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
        rawGSEM.GSEM_Flow_Type__c = 'GSEM Requester Flow (Nimble Originated)'; 
        rawGSEM.Message_Direction__c = 'Outbound';
        rawGSEM.JSON_Request__c = req.getBody();
        rawGSEM.GSEM_Transaction_Type__c = 'PROVIDE PROBLEM INFORMATION';
        rawGSEM.GSEM_Record__c = gLst[0].Id;  // not sure if this won't be null
        rawGSEM.GSEM_Message_Id__c = 'N/A';
        rawGSEM.GSEM_Ack_DML_Error__c = 'N/A';
        rawGSEM.HTTP_Method__c = req.getMethod();
        
        Boolean isCalloutException = false;
        System.CalloutException coException = null;
        
        try {
            res = http.send(req);
            System.debug(' *** '+res.toString());
            System.debug('STATUS:'+res.getStatus()); System.debug('STATUS_CODE:'+res.getStatusCode()); 
            oTask[0].Send_PPI__c = false;
            update oTask[0];
        } 
        catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug('Callout error: '+ e.getLineNumber());
            System.debug('Callout error: '+ e.getCause());
            System.debug('Callout error: '+ e.getStackTraceString());
            
            System.debug(res.toString());
            
            // Send the error notification email 
            //sendErrorNotification(e, gLst[0]);
        }
        finally{
            rawGSEM.HTTP_Status__c = res.getStatus();
            rawGSEM.HTTP_Status_Code__c = res.getStatusCode();
            rawGSEM.JSON_Response__c = res.getBody();
            
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
            
            if(rawGSEM.GSEM_Engine_Transaction_Status__c == 'Success'){
                gLst[0].Current_GSEM_State__c = 'OPEN PROVIDER';
                rawGSEM.GSEM_Call_Status__c = 'OPEN PROVIDER';
            }
            else{
                rawGSEM.GSEM_Call_Status__c = gLst[0].Current_GSEM_State__c;
            }
            
            if(rawGSEM.JSON_Response__c.length() > LONG_TEXT_AREA_MAX){
                rawGSEM.JSON_Response__c = rawGSEM.JSON_Response__c.abbreviate(LONG_TEXT_AREA_MAX-FIELD_TRUNCATION_INDICATOR.length()) + FIELD_TRUNCATION_INDICATOR;
            }
            
            insert rawGSEM; 
            
            if(isCalloutException && coException != null){
                
                sendErrorNotification(coException, gLst[0], rawGSEM.Id);
            }
            
        }
        
        
    }
    
    //@future(callout=true)
    public static Raw_GSEM_Message__c sendConfirmCloseNotification(Id gsemId)
    {
        system.debug('gsemId: ' + gsemId);
        
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_Sandbox');
            
        }   
        
        String nimbleAgentName = gsemInfo.RemoteAgentName__c;
        
        System.debug('gsemInfo:  ' + gsemInfo);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);
        req.setMethod('POST');
        
        DateTime dt = system.today();
        Datetime GMTDate = Datetime.newInstanceGmt(
            dt.year(),
            dt.month(),
            dt.day(),
            dt.hour(),
            dt.minute(),
            dt.second());
        string dt2 = string.valueOf(GMTDate) +',' + string.valueOf(dt);
        
        List<GSEM__c> gsmLst = [select Id, name, Nimble_Agent_Name__c, Current_GSEM_State__c from GSEM__c where Id =: gsemId];
        system.debug('gsmLst: ' + gsmLst);
        
        string reqStr = ('{"Message": {"TransactionName": "CONFIRM CLOSE","RemoteAgentName": "'+gsemInfo.RemoteAgentName__c+'", "SERVICE_INCIDENT": { "RequesterID": "'+gsmLst[0].Name+'", "Comment": "SBU Confirming Closure of '+gsmLst[0].Name+'", "ACTIVITY": [{"ActionLog": "Confirm Close","LocalDate": "'+dt2+'","ParameterList": "Service_Incident:Update"}]},"eCPControl": {"ECPVersion": "1.0"}}}');
        req.setBody(reqStr);
        system.debug(' confirm close string request : ' + reqStr );
        
        req.setCompressed(true); // otherwise we hit a limit of 32000
        
        // this record will be created immediately to hold the unparsed JSON in the event of a parsing error or Ack Message creation preventing a record update
        // it will be deleted later following successful parsing and Acknowledge Message creation
        Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();
        
        // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
        rawGSEM.GSEM_Flow_Type__c = 'GSEM Requester Flow (Nimble Originated)'; 
        rawGSEM.Message_Direction__c = 'Outbound';
        rawGSEM.JSON_Request__c = req.getBody();
        rawGSEM.GSEM_Transaction_Type__c = 'CONFIRM CLOSE';
        rawGSEM.GSEM_Record__c = gsemId;  // not sure if this won't be null
        rawGSEM.GSEM_Message_Id__c = 'N/A';
        rawGSEM.GSEM_Ack_DML_Error__c = 'N/A';
        rawGSEM.HTTP_Method__c = req.getMethod();
        
        Boolean isCalloutException = false;
        System.CalloutException coException = null;
        
        try{
            res = http.send(req);
            System.debug(' *** '+res.toString());
            System.debug('STATUS:'+res.getStatus()); System.debug('STATUS_CODE:'+res.getStatusCode()); 
        } 
        catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug('Callout error: '+ e.getLineNumber());
            System.debug('Callout error: '+ e.getCause());
            System.debug('Callout error: '+ e.getStackTraceString());
            
            rawGSEM.Callout_Exception_Message__c = e.getMessage();
            //rawGSEM.Callout_Exception_Cause__c   = (String) e.getCause();
            rawGSEM.Callout_Exception_Line_Number__c = String.valueOf(e.getLineNumber());
            rawGSEM.Callout_Exception_Stack_Trace__c = e.getStackTraceString();
           
            
            System.debug(res.toString());
            
            // Send the error notification email 
            //sendErrorNotification(e, gsmLst[0]);
        }
        finally{
            
            rawGSEM.JSON_Response__c = res.getBody();
            
            if(rawGSEM.JSON_Response__c != null){
                
                rawGSEM.HTTP_Status__c = res.getStatus();
                rawGSEM.HTTP_Status_Code__c = res.getStatusCode();
            
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
                
                rawGSEM.GSEM_Engine_Transaction_Status__c = jsonRsp.mid(strtIdx, len);
                
                if(rawGSEM.GSEM_Engine_Transaction_Status__c == 'Success'){
                    //gsmLst[0].Current_GSEM_State__c = 'CLOSED';
                    rawGSEM.GSEM_Call_Status__c = 'CLOSED';
                }
                else{
                    //gsmLst[0].Current_GSEM_State__c = 'CLOSED PENDING CONFIRMATION';
                    rawGSEM.GSEM_Call_Status__c = 'CLOSED PENDING CONFIRMATION';
                }
                
                //insert rawGSEM; 
                
                //gsmLst[0].Nimble_Agent_Name__c = nimbleAgentName;
                //update gsmLst[0];
                
                if(isCalloutException && coException != null){
                    
                    sendErrorNotification(coException, gsmLst[0], rawGSEM.Id);
                }
                
            }
            else{ // JSON response is empty, probably no response from far end and subsequent callout exception
                
                rawGSEM.GSEM_Engine_Transaction_Status__c = 'NO RESPONSE TO CONFIRM CLOSE MESSAGE';
                rawGSEM.GSEM_Call_Status__c = 'CLOSED';
            
            }
        }
        
        return rawGSEM;
        
    }
    
    private static void sendErrorNotification(System.CalloutException exceptionString, GSEM__c gsem, Id rawGSEMId)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>(); 
        List<String> ccAddresses = new List<String>(); 
        
        // Add test email addresses
        toAddresses.add('lawrence.wasser@hpe.com');
        toAddresses.add('yesha.benegal@hpe.com');
        
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('donotreply@salesforce.com');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('GSEM Automation');
        
        // Set to True if you want to BCC yourself on the email.
        //mail.setBccSender(false);
        
        List<Raw_GSEM_Message__c> lstRawGSEM = new List<Raw_GSEM_Message__c>();
        
        lstRawGSEM = [select id, name, GSEM_Transaction_Type__c from Raw_GSEM_Message__c where Id =: rawGSEMId];
        
        if(lstRawGSEM != null){
            
            mail.setHtmlBody('<h3 style="color:red;">ERROR</h3> GSEM Callout Error: '+ exceptionString + 
                             ' <a href="https://nimblestorage.my.salesforce.com/'+ lstRawGSEM[0].Id+'">'+ lstRawGSEM[0].Name +'</a>' +
                             '\n  Line Number: '   + exceptionString.getLineNumber() +
                             '\n        Cause: '   + exceptionString.getCause() +
                             '\n  Stack Trace: '   + exceptionString.getStackTraceString() +
                             '\n\nJSON Response: ' + exceptionString.getLineNumber() );
        }
        
        else{
            mail.setHtmlBody('<h3 style="color:red;">ERROR</h3> GSEM Callout Error: '+ exceptionString +
                             '\n  Line Number: '   + exceptionString.getLineNumber() +
                             '\n        Cause: '   + exceptionString.getCause() +
                             '\n  Stack Trace: '   + exceptionString.getStackTraceString() +
                             '\n\nJSON Response: ' + exceptionString.getLineNumber() );
        }    
        
        if(gsem.Id == null){
            
            // Specify the subject line for your email address.
            mail.setSubject('GSEM Requestor Queue Write Failure at: ' + System.now());
        }
        else{
            
            // Specify the subject line for your email address.
            mail.setSubject('GSEM Requestor Queue Read/Write Failure:  ' + gsem.Name);            
        }
        
        if(gsem.Case_Owner_Email__c != null)
        {
            System.debug('gsem.Case_Owner_Email__c: ' + gsem.Case_Owner_Email__c);
            toAddresses.add(gsem.Case_Owner_Email__c);
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
                System.debug('GSEM Record associated with GSEM HTTP Error: ' + gsem);
            }
            
        }
        else
        {
            System.debug('NOT Sending GSEM Transfer Failure Email - EMPTY ToAddresses(): ' + mail.getToAddresses());
        }
        
        return;
    }
    
    @InvocableMethod (label = 'Resend GSEM to PN')
    
    public static List<String> reSendServiceRequest(List<Id> gsemIds){
        
        List<String> resultStrings = new List<String>();
            
        try{
            sendNotification(gsemIds[0]);
        }
        catch(System.CalloutException coExc){
            
        }
        finally{
            
            
        }
        
        return resultStrings;
        
    }
}