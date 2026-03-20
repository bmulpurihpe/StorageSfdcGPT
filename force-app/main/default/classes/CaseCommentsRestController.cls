@RestResource(urlMapping='/casecomment/*')
global with Sharing class CaseCommentsRestController {   
    @HttpPost
    global static Map<String, String> createCaseComment() {
        RestRequest req = RestContext.request;
        Map<String, String> responseMap = new Map<String, String>();
        String debugId = req.headers.get('debugId');
        if (debugId != null) {
            CaseCommentRequest cmr = (CaseCommentRequest) JSON.deserialize(req.requestBody.toString(), CaseCommentRequest.class);
            if (cmr != null) {    
                Id CaseNumbercaseId = getCaseId(cmr.caseNumber);
                if(String.isBlank(cmr.caseNumber) ||String.isBlank(cmr.caseId)){
                    responseMap.put('debugId', debugId);
                    responseMap.put('httpStatusCode', '400');
                    responseMap.put('message', 'CaseId and CaseNumber Missing');
                    responseMap.put('errorCode', 'Required fields are missing');
                    RestContext.response.statusCode = 400;
                }
                else{                
                if (cmr.caseCommentBody != null && cmr.caseCommentBody != '') { 
                    try{ 
                        CaseComment newCaseComment = new CaseComment();     
                        if (cmr.caseId != null && cmr.caseId != '') {
                            newCaseComment.ParentId = cmr.caseId;
                        } else {
                            newCaseComment.ParentId = CaseNumbercaseId;
                        }
                        String updatedCommentBody = 'Created by: ' + cmr.createdbyFirstName + ' '+  cmr.createdbyLastName + '\n' + 'Federation ID: ' + cmr.createdbyFederationId + '\n'+ 'CreatedbyEmail: ' + cmr.createdbyEmail + '\n' + 'CreatedDate: ' + cmr.createdDate + '\n' + cmr.caseCommentBody;
                        newCaseComment.CommentBody = updatedCommentBody;
                        insert newCaseComment;
                        responseMap.put('debugId', debugId);
                        responseMap.put('httpStatusCode', '200');
                        responseMap.put('Casecomment', newCaseComment.ParentId);
                        responseMap.put('message', 'Case Comment created');
                    } 
                    catch (exception e) {
                        responseMap.put('debugId', debugId);
                        responseMap.put('httpStatusCode', '400');
                        responseMap.put('errorCode', 'REQUIRED_FIELD_MISSING');
                        responseMap.put('message', 'Missing mandatory fields');
                        RestContext.response.statusCode = 400;
                    }
                } else {
                    responseMap.put('debugId', debugId);
                    responseMap.put('httpStatusCode', '400');
                    responseMap.put('message', 'caseCommentBody is not in the proper format');
                    responseMap.put('errorCode', 'BAD_REQUEST');
                    RestContext.response.statusCode = 400;
                }
            }
        } else {
            responseMap.put('debugId', debugId);
            responseMap.put('httpStatusCode', '400');
            responseMap.put('message', 'Request is not in the proper format');
            responseMap.put('errorCode', 'BAD_REQUEST');
            RestContext.response.statusCode = 400;
        }
    } else {
        responseMap.put('httpStatusCode', '400');
        responseMap.put('message', 'Header Missing');
        responseMap.put('errorCode', 'BAD_REQUEST');
        RestContext.response.statusCode = 400;
    }
    return responseMap;
}

private static Id getCaseId(String caseNumber) {
    List<Case> cases = [SELECT Id FROM Case WHERE CaseNumber = :caseNumber LIMIT 1];
    return (cases != null && !cases.isEmpty()) ? cases[0].Id : null;
}

global class CaseCommentRequest {
    public String debugId;
    public String caseNumber;
    public String caseId;
    public String caseCommentBody;
    public String createdbyFederationId;
    public String createdbyFirstName;
    public String createdbyLastName;
    public String createdbyEmail;
    public String createdDate;
}
}