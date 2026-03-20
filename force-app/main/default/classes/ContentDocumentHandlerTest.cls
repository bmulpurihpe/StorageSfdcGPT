@isTest
public class ContentDocumentHandlerTest {
  @isTest
    static void testCreateCaseFilepayloadblank() {
        Case caseRec = new Case();
        caseRec.Subject = 'Test Subject';
        caseRec.Description = 'Test Description';
        caseRec.Severity__c = 'P4';
        caseRec.DCE_Sync__c=true;
        Insert caseRec;
         List<ContentDocumentLink> contentDocumentLinks =new List<ContentDocumentLink>();
        ContentVersion testContentVersion = new ContentVersion();
        testContentVersion.Title = 'Test Content';
        testContentVersion.PathOnClient = 'test.txt';
        testContentVersion.VersionData = Blob.valueOf('Test content');
        insert testContentVersion;
        ContentDocumentLink testContentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = caseRec.Id
        );
        contentDocumentLinks.add(testContentLink);
        Insert contentDocumentLinks;
      
        Test.startTest();
        ContentDocumentHandler.handleContentDocumentLinks(contentDocumentLinks);
        Test.stopTest();
       
    }
}