trigger PublishContentToAnotherLibrary on ContentDocumentLink (After insert) {
    if(UserInfo.getUserId() != Label.DCEFileSync_APIUser) {
        ContentDocumentHandler.handleContentDocumentLinks(Trigger.new);
    }
    if(CountAssetPreventRecursive.runOnce()){
        for (ContentDocumentLink cdl : trigger.new) {
            String docId = cdl.ContentDocumentId;
           // if(CDLHelper.flag)
              // CDLHelper.shareWithLibrary(docId);                  // To attach the file to the case
        }
        
    }
    
}