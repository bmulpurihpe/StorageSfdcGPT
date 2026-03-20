@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global static boolean isDone = false;
    
    public static Boolean isSandbox()
    {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    global HTTPResponse respond(HTTPRequest req) 
    {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        
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
           // res.setBody('{\"Message\":{\"TransactionName\":\"PROBLEM RESOLUTION\",\"RemoteAgentName\":\"Test_RemoteAgentName\",\"SERVICE_INCIDENT\":{\"RequesterID\":\"TC1469595635\",\"SOLUTION\":{\"Title\":\"Void\",\"Abstract\":\"Testing Resolution\",\"REFERENCE\":{\"EXPRESSION\":{\"STATEMENT\":[{\"StatementRole\":\"DESCRIPTION\",\"StatementText\":\"Problem Resolution - SolutionDesciptionStatement\"}]}}},\"ACTIVITY\":[{\"ActionLog\":\"Problem Resolution\",\"LocalDate\":\"2016-01-11 16:44:47,2016-01-11 17:44:47\",\"ParameterList\":\"Solution:Create\"}]},\"eCPControl\":{\"ECPVersion\":\"1.0\"}}}');
           res.setBody('{"Acknowledge":"false","TransactionName":"PROBLEM RESOLUTION","TransactionAgentKey":"hAI1miq7GaeMiGSK59En","RemoteAgentName":"SFDC_Train_REST_P030","RemoteAgentType":"HPE","MessageID":"3569800","SERVICE_INCIDENT":{"RequesterID":"GSM-0084","CurrentState":"CLOSED PENDING CONFIRMATION","Comment":"Service Request Comment from TestCustomer GUI","ProviderID":"5320867835","SOLUTION":{"REFERENCE":{"EXPRESSION":{"STATEMENT":[{"StatementRole":"DESCRIPTION","StatementText":"[Onsite Repair][Onsite Repair][Onsite][Closing Task 5320867835-532 Replaced 2 hard drives Rebuilding complete Issue resolved]Closing Task 5320867835-532 Replaced 2 hard drives Rebuilding complete Issue resolvedClosing Task 5320867835-531"},{"StatementRole":"TITLE","StatementText":"Onsite Repair"}]}}},"Activity":[{"ActionLog":"Problem Resolution","LocalDate":"2020-01-16 17:50:12,2020-01-16 17:50:12","ParameterList":"ServiceIncidentExt:Create;SISExtensions:Mapped:Solution:Create","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_eCPExtControl_TransactionType":"4","eCPExtMessage_ExtServiceIncident_Repair_RepairClass":"CO","eCPExtMessage_ExtServiceIncident_Repair_RepairClassText":"Rpr,Compt,Parts Repl","eCPExtMessage_ExtServiceIncident_Repair_DelayCode":"0","eCPExtMessage_ExtServiceIncident_Repair_DelayCodeText":"Response Met","eCPExtMessage_ExtServiceIncident_Repair_ServiceStartDateTime":"2020-01-16 17:30:47","eCPExtMessage_ExtServiceIncident_Repair_SystemFixedTime":"2020-01-16 17:46:01","eCPExtMessage_ExtServiceIncident_Repair_ServiceEndDateTime":"2020-01-16 17:46:01","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_InstalledPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_InstalledSerialNumber":"ABC","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_InstalledPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_RemovedPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_RemovedSerialNumber":"DEF","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART_RemovedPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_InstalledPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_InstalledSerialNumber":"CVB","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_InstalledPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedSerialNumber":"RFG","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART1_RemovedPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledSerialNumber":"SKJ","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_InstalledPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_RemovedPartNumber":"504334-001","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_RemovedSerialNumber":"DSF","eCPExtMessage_ExtServiceIncident_Repair_REPAIRPART2_RemovedPartDescription":"SPS-DRV,HD,146GB,15K 2.5 DP HP SAS","eCPExtMessage_ExtServiceIncident_Repair_RepairDuration":"20:30","eCPExtMessage_ExtServiceIncident_Repair_TravelDuration":"2:30"}}]},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}');
        }  
        
        else if(req.getMethod() == 'GET' && isDone == False){
            res.setBody('{"Acknowledge":"false","TransactionName":"PROVIDE PROBLEM INFORMATION","TransactionAgentKey":"hAI1miq7GaeMiGSK59En","RemoteAgentName":"SFDC_Train_REST_P030","RemoteAgentType":"HPE","MessageID":"3568563","SERVICE_INCIDENT":{"RequesterID":"GSM-0059","ResponseTime":"2019-12-13 04:42:43,2019-12-13 04:42:43","CurrentState":"OPEN PROVIDER","ProviderID":"5320867835","ProviderPriority":"MEDIUM","Activity":[{"ActionLog":"Status changed to : Partner Accept Status Notes:ADDING This note - for reference - Example [2019-12-18 18:43:50 UTC].","LocalDate":"2019-12-18 18:44:30,2019-12-18 18:44:30","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_eCPExtControl_TransactionType":"6","eCPExtMessage_TRANSACTION_TransactionType":"6","eCPExtMessage_EXT_SERVICE_INCIDENT_ProviderTaskID":"5320867416-531","eCPExtMessage_EXT_SERVICE_INCIDENT_ExtendedEvent":"1"}}]},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}');
            isDone = True;
        }     
        res.setStatusCode(200);
        return res;
    }
    
    
}