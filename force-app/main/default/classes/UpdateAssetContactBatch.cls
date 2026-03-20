/**
* Class Name: UpdateAssetContactBatch
* Created By: Jana Reddy
* Created Date:  10/9/2023
*
* Description:
* This Salesforce Apex class is used to batch process Asset records and update the ContactId field.
* It checks for Asset records without a ContactId, but with valid End Customer Ship-to Contact information.
* If a matching Contact is found, it updates the ContactId on the Asset. Otherwise, it creates a new Contact.
* 
* Usage:
* - Use this class to batch process Asset records for Contact updates based on criteria.
*/
global class UpdateAssetContactBatch implements Database.Batchable<SObject> {
    private static Map<String, Id> hpeOppIdToAccountIdMap = new Map<String, Id>();
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id, ContactId,HPE_Opportunity_ID__c, Asset_Stage__r.HPE_Opportunity_ID__c, Asset_Stage__r.End_Customer_Ship_to_Contact_Email__c, Asset_Stage__r.End_Customer_Ship_to_Contact_Name__c FROM Asset 
            WHERE  ContactId = NULL AND Asset_Stage__r.End_Customer_Ship_to_Contact_Email__c != NULL AND Asset_Stage__r.End_Customer_Ship_to_Contact_Name__c != NULL ORDER BY CreatedDate DESC limit 50]); 
    }
    global void execute(Database.BatchableContext context, List<Asset> scope) {
        List<Asset> updateAssetList = new List<Asset>();
        Map<String, Asset> emailToAssetMap = new Map<String, Asset>();
        Map<String, Id> emailToContactIdMap = new Map<String, Id>();
        Set<String> hpeOppIds = new Set<String>();
        for (Asset asset : scope) {
            if (asset.Asset_Stage__r.End_Customer_Ship_to_Contact_Email__c != null) {              
                emailToAssetMap.put(asset.Asset_Stage__r.End_Customer_Ship_to_Contact_Email__c, asset);
                If(asset.HPE_Opportunity_ID__c!=null){
                    hpeOppIds.add(asset.HPE_Opportunity_ID__c);
                }
            }
        }
        if (!hpeOppIds.isEmpty()) {
            populateHpeOppIdToAccountIdMap(hpeOppIds);
        }
        // Query existing contacts with these email addresses
        List<Contact> existingContacts = [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :emailToAssetMap.keySet() ];
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Contact contact : existingContacts) {
            emailToContactIdMap.put(contact.Email, contact.Id);
            // Update the contact's AccountId if it's missing and we have a matching HPE Opportunity ID
            if (contact.AccountId == null && emailToAssetMap.containskey(contact.Email)) {
                   system.debug('==========existingContacts======'+emailToAssetMap.get(contact.Email).HPE_Opportunity_ID__c);
                String hpeOppId = emailToAssetMap.get(contact.Email).HPE_Opportunity_ID__c;
                if (hpeOppId != null && hpeOppIdToAccountIdMap.containsKey(hpeOppId)) {
                    contact.AccountId = hpeOppIdToAccountIdMap.get(hpeOppId);
                    contactsToUpdate.add(contact);
                }
            }
        }
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        system.debug('==========emailToContactIdMap======'+emailToContactIdMap);
        for (Asset asset : scope) {
            String email = asset.Asset_Stage__r.End_Customer_Ship_to_Contact_Email__c;
            if (emailToContactIdMap.containsKey(email)) {
                asset.ContactId = emailToContactIdMap.get(email);
            } else {
                String accountId = hpeOppIdToAccountIdMap.get(asset.Asset_Stage__r.HPE_Opportunity_ID__c);
                if (accountId != null) {
                    Contact newContact = createNewContact(accountId, asset.Asset_Stage__r.End_Customer_Ship_to_Contact_Name__c, email);
                    system.debug('==========ContactId======'+newContact);
                    if (newContact != null) {
                        asset.ContactId = newContact.Id;
                        emailToContactIdMap.put(email, newContact.Id);           
                    }
                }
            }
            updateAssetList.add(asset);
        }
        if (!updateAssetList.isEmpty()) {
            update updateAssetList;
            system.debug('==========updateAssetList======'+updateAssetList); 
        }
    }    
    global void finish(Database.BatchableContext context) {
    } 
    private void populateHpeOppIdToAccountIdMap(Set<String> hpeOppIds) {
        if (!hpeOppIds.isEmpty()) {
            try {
                List<Opportunity> oppList = [
                    SELECT Id, AccountId, HPE_Opportunity_ID__c 
                    FROM Opportunity 
                    WHERE HPE_Opportunity_ID__c IN :hpeOppIds  
                ];
                
                for (Opportunity opp : oppList) {
                    // Additional null checks
                    if (opp.HPE_Opportunity_ID__c != null && opp.AccountId != null) {
                        hpeOppIdToAccountIdMap.put(opp.HPE_Opportunity_ID__c, opp.AccountId);
                    } else {
                        System.debug('Null values encountered in Opportunity: ' + opp);
                    }
                }
            } catch (Exception e) {
                System.debug('Exception in populateHpeOppIdToAccountIdMap: ' + e.getMessage());
                throw e;
            }
        }
    }
    
    private static Contact createNewContact(String Accountid, String Name, String Email) {
        Contact con = new Contact();  
        TriggerHelper.setContactTriggerFlag(true);
        if (Name != null && Name.contains(' ')) {
            List<String> nameParts = name.split(' ');
            con.LastName = nameParts.remove(0);
            con.FirstName = String.join(nameParts, ' ');
        } else {
            con.LastName = Name;
        }
        con.AccountId = Accountid;
        con.Email = Email;
        try {
            insert con;
        } catch (DmlException e) {
        }
        return con;
    }
}