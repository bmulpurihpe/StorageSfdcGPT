@isTest(seeAllData = true)
public class PublishContentToAnotherLibraryTest {
    
    static testMethod void publishContentToAnotherLib(){
        
        
        CountAssetPreventRecursive.run = true;
        string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        //Insert contentdocument data
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;  
		cv.Expiration_Date__c = system.today().addDays(15);        
        insert cv;        
    }
}