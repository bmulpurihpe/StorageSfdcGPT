@RestResource(urlMapping = '/dcefilesync/*')
global with sharing class DCECaseFileSyncRestController {
    @HttpPost
    global static Map<String, String> createCaseFile(String nimbleCaseId, String versionId) {
        Map<String, String> responseMap = new Map<String, String>();
        RestRequest req = RestContext.request;
        String debugId = req.headers.get('debugId');
        if (debugId != null) {
            system.debug('**********nimbleCaseId***********'+nimbleCaseId);
            system.debug('**********versionId***********'+versionId);
            if (String.isBlank(nimbleCaseId) || String.isBlank(versionId)) {
                responseMap.put('httpStatusCode', '400');
                responseMap.put('ErrorMessage', 'nimbleCaseId/versionId is either Null or Empty');
            } else {
                try{
                    List<Case> caseList = [SELECT Id, CaseNumber, AccountId, Status FROM Case WHERE Id = :nimbleCaseId LIMIT 1]; 
                    if (!caseList.isEmpty()) {
                        List<ContentVersion> conVerList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :versionId];                
                        if (conVerList.isEmpty()) {
                            responseMap.put('httpStatusCode', '400');
                            responseMap.put('ErrorMessage', 'Content Version id is Invalid');  
                        } else {
                            Id conDocument = conVerList[0].ContentDocumentId;
                            List<ContentDocumentLink> existingDoclink = [ SELECT Id FROM ContentDocumentLink 
                                                                         WHERE ContentDocumentId = :conDocument  LIMIT 1 ];
                            if (!existingDoclink.isEmpty()) {
                                ContentDocumentLink cDocLink = new ContentDocumentLink();
                                cDocLink.ContentDocumentId = conDocument;
                                cDocLink.LinkedEntityId = caseList[0].Id;
                                cDocLink.Visibility = 'AllUsers'; 
                                Insert cDocLink; 
                                responseMap.put('contentDocumentLinkId', cDocLink.Id);
                                responseMap.put('ContentDocumentId', conDocument);
                                responseMap.put('caseID', cDocLink.LinkedEntityId);
                                responseMap.put('httpStatusCode', '200');
                                responseMap.put('message', 'Linked Document to corresponding case'); 
                            } else {
                                responseMap.put('httpStatusCode', '400');
                                responseMap.put('ErrorMessage', 'Content Version Document id is Invalid');                  
                            }
                        }
                    } else {
                        responseMap.put('httpStatusCode', '400');
                        responseMap.put('ErrorMessage', 'nimbleCaseId could not be found / nimbleCaseId is Invalid');              
                    }
                }
                catch(exception e){
                    responseMap.put('debugId', debugId);
                    responseMap.put('httpStatusCode', '400');
                    responseMap.put('message', 'Request is not in the proper format');
                    responseMap.put('errorCode', 'BAD_REQUEST');
                    RestContext.response.statusCode = 400;  
                }
            }
        } else {
            responseMap.put('httpStatusCode', '400');
            responseMap.put('message', 'Header Missing'); 
        }
        return responseMap;
    }
}