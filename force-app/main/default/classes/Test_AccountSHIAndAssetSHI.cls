@isTest(seeAllData=true)
public class Test_AccountSHIAndAssetSHI {
    static testMethod void TestAccountSHIAndAssetSHI()
    {
        Account          account;
        Contact          contact;
        Asset            asset;
        // Create test account
        account = new Account(Name = 'TEST-ACCOUNT',accountShi__c ='<br><br>', accountRmaShi__c ='<br><br>');
        insert account;
        // Create test contact
        contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',AccountId = account.Id);
        insert contact;
        //creating new asset
        asset = new Asset(Name = 'TEST-ASSET', AccountId = account.Id, ContactId = contact.Id, assetShi__c ='<br><br>', assetRmaShi__c ='<br><br>');
        insert asset;
    }
}