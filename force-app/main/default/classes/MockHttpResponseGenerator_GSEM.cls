@isTest
global class MockHttpResponseGenerator_GSEM implements HttpCalloutMock {
    
    // Implement this interface method
    public static boolean isDone = false;
    
    static final Integer TEXT_AREA_MAX      = 255;
    static final Integer LONG_TEXT_AREA_MAX = 32768;
    static final String  FILLER_TEXT        = 'FILLER TEXT - ';
    
    public static final String UNDER_FIELD_MAX_SIZE = 'UNDER MAX FIELD SIZE';
    public static final String EQUAL_FIELD_MAX_SIZE = 'EQUAL MAX FIELD SIZE';
    public static final String OVER_FIELD_MAX_SIZE  = 'OVER MAX FIELD SIZE';
    public static final Integer DELTA = 3;
    
    //static String FIELD_SIZE_QUALIFIER = '';

    static String sourceField           = '';
    static String comment               = '';  // <= 32768
    static String actionLog             = '';  // <= 32768
    static String resolutionDescription = '';  // <= 32768
    static String resolutionText        = '';  // <= 255
    static String parameterList         = '';  // <= 255
    
    
    public static String commentSizeQualifier               = UNDER_FIELD_MAX_SIZE;
    public static String actionLogSizeQualifier             = UNDER_FIELD_MAX_SIZE;
    public static String resolutionDescriptionSizeQualifier = UNDER_FIELD_MAX_SIZE;
    public static String resolutionTextSizeQualifier        = UNDER_FIELD_MAX_SIZE;
    public static String parameterListSizeQualifier         = UNDER_FIELD_MAX_SIZE;
    
    public static void setAllFieldsToUnderSized(){
        
        commentSizeQualifier               = UNDER_FIELD_MAX_SIZE;
        actionLogSizeQualifier             = UNDER_FIELD_MAX_SIZE;
        resolutionDescriptionSizeQualifier = UNDER_FIELD_MAX_SIZE;
        resolutionTextSizeQualifier        = UNDER_FIELD_MAX_SIZE;
        parameterListSizeQualifier         = UNDER_FIELD_MAX_SIZE;     
    }
    
    public static void setAllFieldsToMaxSized(){
        
        commentSizeQualifier               = EQUAL_FIELD_MAX_SIZE;
        actionLogSizeQualifier             = EQUAL_FIELD_MAX_SIZE;
        resolutionDescriptionSizeQualifier = EQUAL_FIELD_MAX_SIZE;
        resolutionTextSizeQualifier        = EQUAL_FIELD_MAX_SIZE;
        parameterListSizeQualifier         = EQUAL_FIELD_MAX_SIZE; 
    }
    
    public static void setAllFieldsToOverSized(){
        
        commentSizeQualifier               = OVER_FIELD_MAX_SIZE;
        actionLogSizeQualifier             = OVER_FIELD_MAX_SIZE;
        resolutionDescriptionSizeQualifier = OVER_FIELD_MAX_SIZE;
        resolutionTextSizeQualifier        = OVER_FIELD_MAX_SIZE;
        parameterListSizeQualifier         = OVER_FIELD_MAX_SIZE;   
    }
    
    
    public void populateSourceField(){
        
        // populate the Long Text Area fields
        for(Integer fieldSize = 0; fieldSize < LONG_TEXT_AREA_MAX; fieldSize = sourceField.length()){

            sourceField += FILLER_TEXT;            
        }
        
        system.debug('sourceField(' + sourceField.length()+')');
        
    }
    
    public void populateTestFields(){
                
        populateSourceField();
        
        populateCommentField();
        populateActionLogField();
        populateResolutionDescriptionField();
        populateResolutionTextField();
        populateParameterListField();
  
    }
    
    public void populateCommentField(){
        
        if(commentSizeQualifier == UNDER_FIELD_MAX_SIZE){
                comment = sourceField.abbreviate(LONG_TEXT_AREA_MAX - DELTA);            
        }
        else if(commentSizeQualifier == EQUAL_FIELD_MAX_SIZE){
                comment = sourceField.abbreviate(LONG_TEXT_AREA_MAX);            
        }
        else if(commentSizeQualifier == OVER_FIELD_MAX_SIZE){
                comment = sourceField.abbreviate(LONG_TEXT_AREA_MAX + DELTA);            
        }
        
        
        system.debug('Comment                ('+comment.length()+'):                 ' + comment);
 
    }
    
    public void populateActionLogField(){
        
        if(actionLogSizeQualifier == UNDER_FIELD_MAX_SIZE){
            actionLog = sourceField.abbreviate(LONG_TEXT_AREA_MAX - DELTA);            
        }
        else if(actionLogSizeQualifier == EQUAL_FIELD_MAX_SIZE){
            actionLog = sourceField.abbreviate(LONG_TEXT_AREA_MAX);            
        }
        else if(actionLogSizeQualifier == OVER_FIELD_MAX_SIZE){
            actionLog = sourceField.abbreviate(LONG_TEXT_AREA_MAX + DELTA);            
        }
        
        system.debug('Action Log             ('+actionLog.length()+'):' + actionLog);
    }
    public void populateResolutionDescriptionField(){
        
        if(resolutionDescriptionSizeQualifier == UNDER_FIELD_MAX_SIZE){
            resolutionDescription = sourceField.abbreviate(LONG_TEXT_AREA_MAX - DELTA);            
        }
        else if(resolutionDescriptionSizeQualifier == EQUAL_FIELD_MAX_SIZE){
            resolutionDescription = sourceField.abbreviate(LONG_TEXT_AREA_MAX);            
        }
        else if(resolutionDescriptionSizeQualifier == OVER_FIELD_MAX_SIZE){
            resolutionDescription = sourceField.abbreviate(LONG_TEXT_AREA_MAX + DELTA);            
        }
        
        system.debug('Resolution Description ('+resolutionDescription.length()+'):' + resolutionDescription);

    }
    public void populateResolutionTextField(){
        
        if(resolutionTextSizeQualifier == UNDER_FIELD_MAX_SIZE){
            resolutionText = sourceField.abbreviate(TEXT_AREA_MAX - DELTA);            
        }
        else if(resolutionTextSizeQualifier == EQUAL_FIELD_MAX_SIZE){
            resolutionText = sourceField.abbreviate(TEXT_AREA_MAX);            
        }
        else if(resolutionTextSizeQualifier == OVER_FIELD_MAX_SIZE){
            resolutionText = sourceField.abbreviate(TEXT_AREA_MAX + DELTA);            
        }

        system.debug('Resolution Text        ('+resolutionText.length()+'):' + resolutionText);

    }
    public void populateParameterListField(){
        
        if(parameterListSizeQualifier == UNDER_FIELD_MAX_SIZE){
            parameterList = sourceField.abbreviate(TEXT_AREA_MAX - DELTA);            
        }
        else if(parameterListSizeQualifier == EQUAL_FIELD_MAX_SIZE){
            parameterList = sourceField.abbreviate(TEXT_AREA_MAX);            
        }
        else if(parameterListSizeQualifier == OVER_FIELD_MAX_SIZE){
            parameterList = sourceField.abbreviate(TEXT_AREA_MAX + DELTA);            
        }

        system.debug('Parameter List         ('+parameterList.length()+'):' + parameterList);
    }
    
    
    public static Boolean isSandbox()
    {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    
    global HTTPResponse respond(HTTPRequest req) 
    {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        // populate fields based upon configurations set in test classes
        // otherwise use default values
        populateTestFields();
        
        system.debug('isDone: ' + isDone);
        
        if(!isSandbox())
        {
            // we are running in Production
            System.assertEquals('https://api-csc-sgw.ext.hpe.com/gw/hpit/gsd/gsemapi/redfish/v1/message', req.getEndpoint());
            
        }
        else
        {
            System.assertEquals('https://api-csc-stg-sgw.ext.hpe.com/gw/hpit/gsd/gsemapi.trn/redfish/v1/message', req.getEndpoint());
            
        }   
                
       // System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if(req.getMethod() == 'POST'){
            
            res.setBody('{"TransactionName": "SERVICE REQUEST","eCPControl": {"ECPVersion": "1.0","TransactionStatusCode": "0","TransactionStatus": "Success","ObjectBuilderID": "HPE GSEMCLOUD R1" }}');
        
        }
        else if(req.getMethod() == 'GET' && isDone == true){
            
            system.debug('isDone: ' + isDone);
            
            // res.setBody('{\"Message\":{\"TransactionName\":\"PROBLEM RESOLUTION\",\"RemoteAgentName\":\"Test_RemoteAgentName\",\"SERVICE_INCIDENT\":{\"RequesterID\":\"TC1469595635\",\"SOLUTION\":{\"Title\":\"Void\",\"Abstract\":\"Testing Resolution\",\"REFERENCE\":{\"EXPRESSION\":{\"STATEMENT\":[{\"StatementRole\":\"DESCRIPTION\",\"StatementText\":\"Problem Resolution - SolutionDesciptionStatement\"}]}}},\"ACTIVITY\":[{\"ActionLog\":\"Problem Resolution\",\"LocalDate\":\"2016-01-11 16:44:47,2016-01-11 17:44:47\",\"ParameterList\":\"Solution:Create\"}]},\"eCPControl\":{\"ECPVersion\":\"1.0\"}}}');
            // working --> res.setBody('{"Acknowledge":"false","TransactionName":"PROBLEM RESOLUTION","TransactionAgentKey":"hAI1miq7GaeMiGSK59En","RemoteAgentName":"SFDC_Train_REST_P030","RemoteAgentType":"HPE","MessageID":"3569800","SERVICE_INCIDENT":{"RequesterID":"GSM-0084","CurrentState":"CLOSED PENDING CONFIRMATION","Comment":"Service Request Comment from TestCustomer GUI","ProviderID":"5320867835","SOLUTION":{"REFERENCE":{"EXPRESSION":{"STATEMENT":[{"StatementRole":"DESCRIPTION","StatementText":"[Onsite Repair][Onsite Repair][Onsite][Closing Task 5320867835-532 Replaced 2 hard drives Rebuilding complete Issue resolved]Closing Task 5320867835-532 Replaced 2 hard drives Rebuilding complete Issue resolvedClosing Task 5320867835-531"},{"StatementRole":"TITLE","StatementText":"Onsite Repair"}]}}},"Activity":[{"ActionLog":"Problem Resolution","LocalDate":"2020-01-16 17:50:12,2020-01-16 17:50:12","ParameterList":"ServiceIncidentExt:Create;SISExtensions:Mapped:Solution:Create","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_eCPExtControl_TransactionType":"4","eCPExtMessage_ExtServiceIncident_Repair_RepairClass":"CO","eCPExtMessage_ExtServiceIncident_Repair_RepairClassText":"Rpr,Compt,Parts Repl","eCPExtMessage_ExtServiceIncident_Repair_DelayCode":"0","eCPExtMessage_ExtServiceIncident_Repair_DelayCodeText":"Response Met","eCPExtMessage_ExtServiceIncident_Repair_ServiceStartDateTime":"2020-01-16 17:30:47","eCPExtMessage_ExtServiceIncident_Repair_SystemFixedTime":"2020-01-16 17:46:01","eCPExtMessage_ExtServiceIncident_Repair_ServiceEndDateTime":"2020-01-16 17:46:01","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_InstalledPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_InstalledSerialNumber":"ABC","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_InstalledPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_RemovedPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_RemovedSerialNumber":"DEF","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_RemovedPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_InstalledPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_InstalledSerialNumber":"CVB","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_InstalledPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedSerialNumber":"RFG","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledSerialNumber":"SKJ","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_RemovedPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_RemovedSerialNumber":"DSF","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_RemovedPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_RepairDuration":"20:30","eCPExtMessage_ExtServiceIncident_Repair_TravelDuration":"2:30"}}]},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}');
            res.setBody('{"Acknowledge":"false","TransactionName":"PROBLEM RESOLUTION","TransactionAgentKey":"hAI1miq7GaeMiGSK59En","RemoteAgentName":"SFDC_Train_REST_P030","RemoteAgentType":"HPE","MessageID":"3569800","SERVICE_INCIDENT":{"RequesterID":"GSM-0084","CurrentState":"CLOSED PENDING CONFIRMATION","Comment":"'+comment+'","ProviderID":"5320867835","SOLUTION":{"REFERENCE":{"EXPRESSION":{"STATEMENT":[{"StatementRole":"DESCRIPTION","StatementText":"'+resolutionDescription+'"},{"StatementRole":"TITLE","StatementText":"'+resolutionText+'"}]}}},"Activity":[{"ActionLog":"'+actionLog+'","LocalDate":"2020-01-16 17:50:12,2020-01-16 17:50:12","ParameterList":"'+parameterList+'","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_eCPExtControl_TransactionType":"4","eCPExtMessage_ExtServiceIncident_Repair_RepairClass":"CO","eCPExtMessage_ExtServiceIncident_Repair_RepairClassText":"Rpr,Compt,Parts Repl","eCPExtMessage_ExtServiceIncident_Repair_DelayCode":"0","eCPExtMessage_ExtServiceIncident_Repair_DelayCodeText":"Response Met","eCPExtMessage_ExtServiceIncident_Repair_ServiceStartDateTime":"2020-01-16 17:30:47","eCPExtMessage_ExtServiceIncident_Repair_SystemFixedTime":"2020-01-16 17:46:01","eCPExtMessage_ExtServiceIncident_Repair_ServiceEndDateTime":"2020-01-16 17:46:01","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_InstalledPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_InstalledSerialNumber":"ABC","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_InstalledPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_RemovedPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_RemovedSerialNumber":"DEF","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_RemovedPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_InstalledPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_InstalledSerialNumber":"CVB","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_InstalledPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedSerialNumber":"RFG","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledSerialNumber":"SKJ","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_RemovedPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_RemovedSerialNumber":"DSF","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_RemovedPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_RepairDuration":"20:30","eCPExtMessage_ExtServiceIncident_Repair_TravelDuration":"2:30"}}]},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}');

            system.debug('PROBLEM RESOLUTION BODY: ' + res.getBody());
            system.debug('Comment                ('+comment.length()+'):                 ' + comment);            
            system.debug('Action Log             ('+actionLog.length()+'):' + actionLog);
            system.debug('Resolution Description ('+resolutionDescription.length()+'):' + resolutionDescription);
            system.debug('Resolution Text        ('+resolutionText.length()+'):' + resolutionText);
            system.debug('Parameter List         ('+parameterList.length()+'):' + parameterList);
            
        }  
        else if(req.getMethod() == 'GET' && isDone == false){
            
            system.debug('isDone: ' + isDone);
            
            // working --> res.setBody('{"Acknowledge":"false","TransactionName":"PROVIDE PROBLEM INFORMATION","TransactionAgentKey":"hAI1miq7GaeMiGSK59En","RemoteAgentName":"SFDC_Train_REST_P030","RemoteAgentType":"HPE","MessageID":"3568563","SERVICE_INCIDENT":{"RequesterID":"GSM-0059","ResponseTime":"2019-12-13 04:42:43,2019-12-13 04:42:43","CurrentState":"OPEN PROVIDER","ProviderID":"5320867835","ProviderPriority":"MEDIUM","Activity":[{"ActionLog":"Status changed to : Partner Accept Status Notes:ADDING This note - for reference - Example [2019-12-18 18:43:50 UTC].","LocalDate":"2019-12-18 18:44:30,2019-12-18 18:44:30","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_eCPExtControl_TransactionType":"6","eCPExtMessage_TRANSACTION_TransactionType":"6","eCPExtMessage_EXT_SERVICE_INCIDENT_ProviderTaskID":"5320867416-531","eCPExtMessage_EXT_SERVICE_INCIDENT_ExtendedEvent":"1"}}]},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}');
            res.setBody('{"Acknowledge":"false","TransactionName":"PROVIDE PROBLEM INFORMATION","TransactionAgentKey":"hAI1miq7GaeMiGSK59En","RemoteAgentName":"SFDC_Train_REST_P030","RemoteAgentType":"HPE","MessageID":"3568563","SERVICE_INCIDENT":{"RequesterID":"GSM-0059","ResponseTime":"2019-12-13 04:42:43,2019-12-13 04:42:43","CurrentState":"OPEN PROVIDER","ProviderID":"5320867835","ProviderPriority":"MEDIUM","Activity":[{"ActionLog":"'+actionLog+'","LocalDate":"2019-12-18 18:44:30,2019-12-18 18:44:30","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_eCPExtControl_TransactionType":"6","eCPExtMessage_TRANSACTION_TransactionType":"6","eCPExtMessage_EXT_SERVICE_INCIDENT_ProviderTaskID":"5320867416-531","eCPExtMessage_EXT_SERVICE_INCIDENT_ExtendedEvent":"1"}}]},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}');
            isDone = True;
            
            system.debug('PROVIDE PROBLEM INFORMATION body: ' + res.getBody());
            system.debug('Action Log:              ' + actionLog);

        }     
        
        res.setStatusCode(200);
        return res;
        
    }
    
    
}