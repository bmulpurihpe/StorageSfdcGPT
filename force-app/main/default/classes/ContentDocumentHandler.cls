public class ContentDocumentHandler {
    public static void handleContentDocumentLinks(List<ContentDocumentLink> contentDocumentLinks) {
        System.debug('=======calling handler class method============');
        List<File_Event__e> fileEventList = new List<File_Event__e>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink contentDocLink : contentDocumentLinks) {
            contentDocumentIds.add(contentDocLink.ContentDocumentId);
            if (contentDocLink.LinkedEntityId.getSObjectType() == Case.SObjectType) {
                caseIds.add(contentDocLink.LinkedEntityId);
                System.debug('=======caseIds============' + caseIds);
            }
        }
        System.debug('=======contentDocumentIds============' +contentDocumentIds);
        // Retrieve the related ContentDocument records
        Map<Id, ContentDocument> contentDocumentsMap = new Map<Id, ContentDocument>([SELECT Id, LatestPublishedVersionId, ContentSize,
                                                                                     Title, LatestPublishedVersion.Checksum, LatestPublishedVersion.PathOnClient
                                                                                     FROM ContentDocument WHERE Id IN :contentDocumentIds]);
        System.debug('=======contentDocumentsMap============' +contentDocumentsMap);
        // Retrieve the related Cases with dcesync flag true
        Map<Id, Case> casesMap = new Map<Id, Case>([
            SELECT Id, DCE_Sync__c
            FROM Case
            WHERE Id IN :caseIds AND DCE_Sync__c = true
        ]);
        // Iterate over each ContentDocumentLink record that was inserted
        for (ContentDocumentLink contentDocLink : contentDocumentLinks) {
            if (contentDocumentsMap.containsKey(contentDocLink.ContentDocumentId)) {
                ContentDocument contentDoc = contentDocumentsMap.get(contentDocLink.ContentDocumentId);
                if (contentDocLink.LinkedEntityId.getSObjectType() == Case.SObjectType) {
                    caseIds.add(contentDocLink.LinkedEntityId);
                    System.debug('=======casesMap============' +casesMap);
                    // Check if the Case has dcesync flag true before adding to fileEventList
                    if (casesMap.containsKey(contentDocLink.LinkedEntityId)) {
                         System.debug('=======inside map============');
                        File_Event__e fileEvent = new File_Event__e();
                        fileEvent.Case_Id__c = contentDocLink.LinkedEntityId;
                        fileEvent.Content_Document_Id__c = contentDoc.Id;
                        fileEvent.Content_Version_Id__c = contentDoc.LatestPublishedVersionId;
                        fileEvent.File_Size__c = contentDoc.ContentSize;
                        fileEvent.Title__c = contentDoc.Title;
                        fileEvent.Checksum__c = contentDoc.LatestPublishedVersion.Checksum;
                        fileEvent.File_Name__c = contentDoc.LatestPublishedVersion.PathOnClient;
                        
                        fileEventList.add(fileEvent);
                    }
                }
            }
        }
        System.debug('=======fileEventList============' +fileEventList);
        if (!fileEventList.isEmpty()) {
            List<Database.SaveResult> saveResults = EventBus.publish(fileEventList);
            for (Database.SaveResult saveResult : saveResults) {
                if (saveResult.isSuccess()) {
                    System.debug('Event published successfully.');
                } else {
                    System.debug('Failed to publish event: ' + saveResult.getErrors());
                }
            }
        }
    }
}