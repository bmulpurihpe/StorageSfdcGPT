/*
Purpose: This class is implemented when case comment records are inserted and updated. It is triggered when a case comment is published for a Case that has DCE sync flag to true.
Created by: Jana
*/
public class DCESyncCaseCommentController { 
    
    public static void caseCommentInsertDceSync(List<CaseComment> newList){
        set<Id> caseCommentIds=new set<Id>();
        List<CaseComment> caseCommentList=new List<CaseComment>();
        For(CaseComment casecomrec: newList){
            if(casecomrec.IsPublished == true ){
                caseCommentIds.add(casecomrec.id);
            }
        }
        caseCommentList=[SELECT Id,CreatedDate,Parent.Contact.DCE_Onboarded__c,ParentId,Parent.DCE_Sync__c,Parent.Subject,Parent.Description,CommentBody,IsPublished,CreatedById FROM CaseComment where ID IN:caseCommentIds AND Parent.DCE_Sync__c=True ]; 
        if(!caseCommentList.isEmpty()){
            createDceSyncUpdateAndInsertCaseComment(caseCommentList); 
        }
    }
    public static void caseCommentUpdateDceSync(List<CaseComment> newList, Map<Id,CaseComment> oldMap){
        set<Id> caseCommentIds=new set<Id>();
        List<CaseComment> caseCommentList=new List<CaseComment>();
        For(CaseComment casecomrec: newList){
            if(casecomrec.IsPublished == true && casecomrec.IsPublished!=oldMap.get(casecomrec.id).IsPublished){
                caseCommentIds.add(casecomrec.id);
            }
        }
        caseCommentList=[SELECT Id,CreatedDate,Parent.Contact.DCE_Onboarded__c,ParentId,Parent.DCE_Sync__c,Parent.Subject,Parent.Description,CommentBody,IsPublished,CreatedById FROM CaseComment where ID IN:caseCommentIds AND Parent.DCE_Sync__c =True ]; 
        if(!caseCommentList.isEmpty()){
            createDceSyncUpdateAndInsertCaseComment(caseCommentList); 
        }
    }
    Public Static void createDceSyncUpdateAndInsertCaseComment(List<CaseComment > caseCommlist){  
        Id caseCommentRecordTypeID = Schema.SObjectType.DCE_Case_Sync__c.getRecordTypeInfosByName().get('CaseComments').getRecordTypeId();
        List<DCE_Case_Sync__c> createDCEList=new List<DCE_Case_Sync__c>();
        for(CaseComment casecom:caseCommlist){
            IF(casecom.IsPublished==true){
                DCE_Case_Sync__c CommentDCE=new DCE_Case_Sync__c(); 
                CommentDCE.Case__c =casecom.ParentId;
                CommentDCE.RecordTypeId=caseCommentRecordTypeID;
                CommentDCE.CaseComment_ID__c=casecom.id;
                CommentDCE.DCE_Sync__c='Create Pending';               
                CommentDCE.Subject__c=casecom.Parent.Subject;
                system.debug(' *** line 43 ' + CommentDCE.Subject__c); 
                CommentDCE.Description__c=casecom.Parent.Description;
                // Start ESS-106322 Added Jana
                CommentDCE.createdBy_FederationId__c=DCEAPIInoformation.createdbyfederationID__c;
                // End ESS-106322  
                system.debug(' *** line 49 ' + CommentDCE.Description__c);
                Integer maxSize = 3000;
                String Comments=casecom.CommentBody;
                if(Comments.length() > maxSize ){
                    Comments = Comments.substring(0, maxSize);
                }
                CommentDCE.Comments__c=Comments;                
                system.debug(' *** line 54 ' + CommentDCE.Comments__c);
                CommentDCE.commentCreatedAt__c=casecom.CreatedDate;
                
                createDCEList.add(CommentDCE);
            }
        } 
        If(!createDCEList.isEmpty()){
            Insert createDCEList;
        }
    }
       // Start ESS-106322 Added Jana
     public static DCE_API_Information__mdt DCEAPIInoformation{
        get{
            if(DCEAPIInoformation==null)
                DCEAPIInoformation =[select id,QualifiedApiName,
                                     DeveloperName,
                                     Contact_API__c,
                                     DCE_Identity_API__c,
                                     createdbyfederationID__c,
                                     Salesforce_API__c,
                                     dummyAssetId__c,
                                     Password__c,
                                     Username__c
                                     from DCE_API_Information__mdt
                                     where QualifiedApiName='Default' ];
            return DCEAPIInoformation;
        }
        private set;
    }
     // End ESS-106322  
     //Start ESS-106914--Jana Added method
      public static void insertCaseCommentsAndUpdateCaseDetails(List<CaseComment> newList) {
        String DCEIntAPIUser = Label.DCEIntegration_APIUser;
        List<Case> caseToUpdate = new List<Case>();
        system.debug('==========newList======'+newList);
        Set<Id> parentIds = new Set<Id>();
        for (CaseComment newComment : newList) {
            if (newComment.ParentId != null && newComment.CreatedById == DCEIntAPIUser) {
                parentIds.add(newComment.ParentId);
            }
        }
        system.debug('==========parentIds======'+parentIds);
        if (!parentIds.isEmpty()) {
            List<Case> parentCaseList = [SELECT Id,ownerId,caseAttnReq__c, Status FROM Case WHERE Id IN :parentIds];
            for (Case casrec : parentCaseList) {
                casrec.caseAttnReq__c = true;
                if(casrec.Status == 'Handover'&& casrec.ownerId == CaseUtility.SUPPORT_QUEUE_GENERAL_ID){
                    casrec.status = 'Handover';
                    System.debug('Only DCE needs handover set to handover instead of open');
                }else
                    casrec.Status = 'Open';
                caseToUpdate.add(casrec);
            }
        }
        system.debug('==========caseToUpdate======'+caseToUpdate);
        if (!caseToUpdate.isEmpty()) {
            update caseToUpdate;
        }
    }
}