@isTest(SeeALLData=True)
private class DceSyncCaseCommenetControllerTest {
    static testMethod void testDceSyncCaseCommentInsert() {
        Case testCase = new Case(Subject = 'Test Case', Description = 'Test Description', DCE_Sync__c=true );
        insert testCase;        
        CaseComment testComment = new CaseComment(ParentId = testCase.Id, CommentBody = 'Test Comment',IsPublished = true );
        insert testComment;
        
        Test.startTest();
        DceSyncCaseCommenetController.caseCommentInsertDceSync(new List<CaseComment>{testComment});
        DCE_Case_Sync__c testDceSync = new DCE_Case_Sync__c(
            Case__c = testCase.Id,
            RecordTypeId = Schema.SObjectType.DCE_Case_Sync__c.getRecordTypeInfosByName().get('CaseComments').getRecordTypeId(),
            CaseComment_ID__c = testComment.Id,
            DCE_Sync__c = 'Create Pending',
            Subject__c = JSON.serialize(testComment.Parent.Subject),
            Description__c = JSON.serialize(testComment.Parent.Description),
            Comments__c = JSON.serialize(testComment.CommentBody),
            commentCreatedAt__c = testComment.CreatedDate
        );
        insert testDceSync;
        
        Test.stopTest();
        DCE_Case_Sync__c createdDceSync = [SELECT Id,DCE_Sync__c FROM DCE_Case_Sync__c WHERE id = :testDceSync.Id];
        System.assertEquals('Create Pending', createdDceSync.DCE_Sync__c);
    }
    
    static testMethod void testDceSyncCaseCommentUpdate() {
        Case testCase = new Case(Subject = 'Test Case', Description = 'Test Description',DCE_Sync__c=true);
        insert testCase;
        
        CaseComment testComment = new CaseComment(ParentId = testCase.Id,CommentBody = 'Test Comment', IsPublished = false );
        insert testComment;
        Map<Id,CaseComment> oldmap=new Map<Id,CaseComment>();
        oldmap.put(testComment.id,testComment);
        CaseComment  casecom=[SELECT Id,CreatedDate,Parent.Contact.DCE_Onboarded__c,ParentId,Parent.DCE_Sync__c,Parent.Subject,Parent.Description,CommentBody,IsPublished,CreatedById FROM CaseComment where ID =:testComment.id ]; 
        Test.startTest();
        casecom.IsPublished=true;
        Casecom.CommentBody =Casecom.CommentBody +'Test';
        update casecom;
        DceSyncCaseCommenetController.caseCommentUpdateDceSync(new List<CaseComment>{casecom}, oldmap);
        DceSyncCaseCommenetController.createDceSyncUpdateAndInsertCaseComment(new List<CaseComment>{casecom});
        DCE_Case_Sync__c testDceSync = new DCE_Case_Sync__c(
            Case__c = testCase.Id,
            RecordTypeId = Schema.SObjectType.DCE_Case_Sync__c.getRecordTypeInfosByName().get('CaseComments').getRecordTypeId(),
            CaseComment_ID__c = testComment.Id,
            DCE_Sync__c = 'Create Pending',
            Subject__c = JSON.serialize(testComment.Parent.Subject),
            Description__c = JSON.serialize(testComment.Parent.Description),
            Comments__c = JSON.serialize(testComment.CommentBody),
            commentCreatedAt__c = testComment.CreatedDate
        );
        insert testDceSync;
        Test.stopTest();
    }
}