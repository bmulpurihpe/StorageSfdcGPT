@isTest
global class MockHttpOEMResponseGenerator implements HttpCalloutMock {
    
    // Implement this interface method
    global static boolean isDoneSR = false;
    global static boolean isDonePS = false;
    global static boolean isDonePPI = false;
    global static boolean isDonePPIDupe = false;
    global static boolean isDoneRC = false;
    
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://api-csc-sgw.ext.hpe.com/gw/hpit/gsd/gsemapi/redfish/v1/message', req.getEndpoint());
       // System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if(req.getMethod() == 'GET' && isDoneSR == False){
            res.setBody('{"Acknowledge":"false","TransactionName":"SERVICE REQUEST","TransactionAgentKey":"GuuQnxHWnxHWnxHWnxHW","RemoteAgentName":"SFDC_Train_REST_R029","RemoteAgentType":"HPE","MessageID":"3772616","SERVICE_INCIDENT":{"RequesterID":"5320904567","RequesterSeverity":"MAJOR","CurrentState":"NOT ENTITLED","SERVICE_REQUESTER":{"ORGANIZATION":{"OrganizationName":"Government Of The Province Of Alberta","ADDRESS":{"AddressType":"PRIMARY","GeoAddress1":"9 Quarry Hts SE","GeoAddress2":"","City":"CALGARY","Region":"ALBERTA","PostalCode":"T2C 5H7","TimeZone":"(GMT-06:00) Mountain Daylight Time (America/Denver)","Country":"CA"}},"PERSON":{"FirstName":"Dan","LastName":"Carreiro","ContactType":"LG=French (Canadian)","ADDRESS":{"LOCATION":[{"ID":"6138351544","Type":"PRIMARY_VOICE"},{"Type":"ALTERNATE_VOICE"},{"ID":"DCE","Type":"FAX"},{"ID":"navandan@gmail.com.train","Type":"EMAIL"}]}}},"AGREEMENT":{"ContractID":"NONE","AgreementType":"LN=2021-04-06 15:32:19;DT=2021-04-06 15:27:08;PN=P18229-B21;SN=CZ293507KN;LG=French (Canadian)"},"Activity":[{"ActionLog":"Service_Incident Submission","LocalDate":"2021-04-06 15:32:19,2021-04-06 15:32:19","ParameterList":"Service_Incident:Create","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerFirstName":"Daniel","eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerLastName":"Carreiro","eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerEmail":"dcarreiro@hpe.com","eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerPhoneNumber":"+1 613 2879319"}}]},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}');
            isDoneSR = True;
        }
        else if(req.getMethod() == 'GET' && isDonePS == false){
           // res.setBody('{\"Message\":{\"TransactionName\":\"PROBLEM RESOLUTION\",\"RemoteAgentName\":\"Test_RemoteAgentName\",\"SERVICE_INCIDENT\":{\"RequesterID\":\"TC1469595635\",\"SOLUTION\":{\"Title\":\"Void\",\"Abstract\":\"Testing Resolution\",\"REFERENCE\":{\"EXPRESSION\":{\"STATEMENT\":[{\"StatementRole\":\"DESCRIPTION\",\"StatementText\":\"Problem Resolution - SolutionDesciptionStatement\"}]}}},\"ACTIVITY\":[{\"ActionLog\":\"Problem Resolution\",\"LocalDate\":\"2016-01-11 16:44:47,2016-01-11 17:44:47\",\"ParameterList\":\"Solution:Create\"}]},\"eCPControl\":{\"ECPVersion\":\"1.0\"}}}');
           res.setBody('{"Acknowledge":"false","TransactionName":"PROBLEM SUBMITTAL","TransactionAgentKey":"GuuQnxHWnxHWnxHWnxHW","RemoteAgentName":"SFDC_Train_REST_R029","RemoteAgentType":"HPE","MessageID":"3779149","SERVICE_INCIDENT":{"RequesterID":"5320904567","RequesterSeverity":"MAJOR","ResponseTime":"2021-04-06 15:32:19,2021-04-06 15:32:19","CurrentState":"PROBLEM SUBMITTED","Entitled":"YES","SERVICE_REQUESTER":{"ORGANIZATION":{"OrganizationName":"Government Of The Province Of Alberta","ADDRESS":{"AddressType":"PRIMARY","GeoAddress1":"9 Quarry Hts SE","GeoAddress2":"","City":"CALGARY","Region":"ALBERTA","PostalCode":"T2C 5H7","TimeZone":"(GMT-06:00) Mountain Daylight Time (America/Denver)","Country":"CA"}},"PERSON":{"FirstName":"Dan","LastName":"Carreiro","ContactType":"LG=French (Canadian)","ADDRESS":{"LOCATION":[{"ID":"6138351544","Type":"PRIMARY_VOICE"},{"Type":"ALTERNATE_VOICE"},{"ID":"6138351544","Type":"FAX"},{"ID":"navandan@gmail.com.train","Type":"EMAIL"}]}}},"AGREEMENT":{"ContractID":"NONE","AgreementType":"LN=2021-04-06 15:32:19;DT=2021-04-06 15:27:08;PN=P18229-B21;SN=CZ293507KN;LG=French (Canadian)"},"PROBLEM":{"EXPRESSION":{"Relation":"AND","STATEMENT":[{"StatementRole":"DESCRIPTION","StatementText":"Environment: TEST Case Issue: TEST CASE "},{"StatementRole":"TITLE","StatementText":"Test Case for Nimble OEM Flow 1"}]}},"Activity":[{"ActionLog":"Service_Incident Submission","LocalDate":"2021-04-06 15:32:19,2021-04-06 15:32:19","ParameterList":"Service_Incident:Create","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerFirstName":"Daniel","eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerLastName":"Carreiro","eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerEmail":"dcarreiro@hpe.com","eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerPhoneNumber":"+1 613 2879319"}},{"ActionLog":"Entitlement","LocalDate":"2021-05-12 12:56:46,2021-05-12 19:56:46","ParameterList":"Service_Incident:Update"},{"ActionLog":"Service_Incident ProblemSubmittal","LocalDate":"2021-05-12 20:04:32,2021-05-12 20:04:32","ParameterList":"Service_Incident:Update"}]},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}');
           isDonePS = True;
        }          
        else if(req.getMethod() == 'GET' && isDonePPI == false){
            res.setBody('{"Message":{"TransactionName":"PROVIDE PROBLEM INFORMATION","RemoteAgentName":"SFDC_Train_REST_R029","MessageID":"3772600","StopOnConversion":"false","SERVICE_INCIDENT":{"RequesterID":"5320904567","RequesterSeverity":"CRITICAL","ResponseTime":"2021-05-17 09:55:01,2021-05-17 16:55:01","Comment":"Test PPI","ACTIVITY":[{"ActionLog":"PPI","LocalDate":"2021-05-17 09:55:01,2021-05-17 16:55:01","ParameterList":"ServiceIncidentExt:Create;SISExtensions:Mapped","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_eCPExtControl_TransactionType":"6","eCPExtMessage_ExtServiceIncident_WorkflowStatus":"Partner Accept","eCPExtMessage_TRANSACTION_TransactionType":"6"}},{"ActionLog":"Partner Accepted - Workflow Status Changed Internal Notes Field","LocalDate":"2021-05-17 09:55:01,2021-05-17 16:55:01","ProviderID":"05761906","ParameterList":"Activity:Log;Distribution:Private"}],"PROBLEM":{"EXPRESSION":{"Relation":"AND","STATEMENT":[{"StatementRole":"TITLE","StatementText":"PPI"},{"StatementRole":"DESCRIPTION","StatementText":"comment"}]}}},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}}');
            isDonePPI = true;
        }  
        else if(req.getMethod() == 'GET' && isDonePPIDupe == false){
            res.setBody('{"Message":{"TransactionName":"PROVIDE PROBLEM INFORMATION","RemoteAgentName":"SFDC_Train_REST_R029","MessageID":"3772600","StopOnConversion":"false","SERVICE_INCIDENT":{"RequesterID":"5320904567","RequesterSeverity":"CRITICAL","ResponseTime":"2021-05-17 09:55:01,2021-05-17 16:55:01","Comment":"Test PPI","ACTIVITY":[{"ActionLog":"PPI","LocalDate":"2021-05-17 09:55:01,2021-05-17 16:55:01","ParameterList":"ServiceIncidentExt:Create;SISExtensions:Mapped","NameValuePairList":{"eCPExtMessage_eCPExtControl_Version":"1.0","eCPExtMessage_eCPExtControl_Name":"SDK Extension","eCPExtMessage_eCPExtControl_TransactionType":"6","eCPExtMessage_ExtServiceIncident_WorkflowStatus":"Partner Accept","eCPExtMessage_TRANSACTION_TransactionType":"6"}},{"ActionLog":"Partner Accepted - Workflow Status Changed Internal Notes Field","LocalDate":"2021-05-17 09:55:01,2021-05-17 16:55:01","ProviderID":"05761906","ParameterList":"Activity:Log;Distribution:Private"}],"PROBLEM":{"EXPRESSION":{"Relation":"AND","STATEMENT":[{"StatementRole":"TITLE","StatementText":"PPI"},{"StatementRole":"DESCRIPTION","StatementText":"comment"}]}}},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}}');
            
        } 
        else if(req.getMethod() == 'GET' && isDoneRC == false){
            res.setBody('{"Acknowledge":"false","TransactionName":"REQUEST CLOSURE","TransactionAgentKey":"GuuQnxHWnxHWnxHWnxHW","RemoteAgentName":"SFDC_Train_REST_R029","RemoteAgentType":"HPE","MessageID":"3984080","SERVICE_INCIDENT":{"RequesterID":"5320935018","CurrentState":"CLOSED","Comment":"Resolution text","ProviderID":"05761906","Activity":[{"ActionLog":"Request Closure","LocalDate":"2023-06-13 14:04:47,2023-06-13 14:04:47"}]},"eCPControl":{"ECPVersion":"1.0","TransactionStatusCode":"0","TransactionStatus":"Success","ObjectBuilderID":"HPE GSEMCLOUD R1"}}');
            
        } 
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
    
    
}