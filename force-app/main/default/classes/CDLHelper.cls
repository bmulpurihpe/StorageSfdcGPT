public class CDLHelper {

public static boolean flag=true;

     /**
      * Helper method to publish ContentDocument into another Library.
      */
    public static void shareWithLibrary(String docId) {   
        CollaborationGroup getGroupID = [Select Id, Name from CollaborationGroup where Name = 'File Object - Group' limit 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        //we can assign only chatter group id to linkedentityId. For ex: testing chatter group -  0F9340000000Nic
        //cdl.LinkedEntityId = Id.valueOf('00G3F000000FzYE'); // workspaceId where user wants to publish the file.
        cdl.LinkedEntityId = getGroupID.Id;
        cdl.ShareType = 'V'; 
        insert(cdl);
    }

}