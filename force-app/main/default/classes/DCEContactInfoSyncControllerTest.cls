@isTest
public class DCEContactInfoSyncControllerTest {
    
   /* @testSetup
    static void setupTestData() {
        Account acct = TestDataFactory.createAccount('Test Account', true, true);
        Contact con = TestDataFactory.createContact(acct, 'John', 'Doe', 'john.doe@example.com');
    }*/
    @isTest
    static void testContactCreationAndUpdate(){
        Field_Changed_Contact__c setting = new Field_Changed_Contact__c();
        setting.Name = 'Email';
        insert setting;

        Contact contact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'venkat@ns.com');
        insert contact;

        
        Contact oldContact = [SELECT Id, Email FROM Contact WHERE Id = :contact.Id];

        contact.Email = 'venkat@new.com';
        update contact;

        Contact updatedContact = [SELECT Id, Email, Contact_Information_Last_Updated__c, LastModifiedDate FROM Contact WHERE Id = :contact.Id];

        List<Contact> newList = new List<Contact>{ updatedContact };
        Map<Id, Contact> oldMap = new Map<Id, Contact>{ oldContact.Id => oldContact };

        Test.startTest();
        DCEContactInfoSyncController.contactInfoLastUpdateSync(newList, oldMap);
        Test.stopTest();
        
    }
   
    
}