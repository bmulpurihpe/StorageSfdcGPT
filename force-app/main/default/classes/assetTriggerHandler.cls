public class assetTriggerHandler extends TriggerHandler {
    
    private static Map<Id, AddressBook__c> addressBooks;
    private static List<AddressBook__c>    newAddressBooks;
    
    // ###################################################################################################### assetTriggerHandler (constructor)
    public assetTriggerHandler() {
    }
    
    // ###################################################################################################### beforeInsert
    public override void beforeInsert() {
        translateAssetInstallCountry();
        setInsertedAssetAddressBook();
    }
    
    // ###################################################################################################### beforeUpdate
    public override void beforeUpdate() {
        translateAssetInstallCountry();
        setUpdatedAssetLastValidatedFields();
        setUpdatedAssetAddressBook();
        setUpdatedAssetSameDayPartDeliveryPreference();
    }
    
    // ###################################################################################################### afterInsert
    public override void afterInsert() {
    }
    
    // ###################################################################################################### afterUpdate
    public override void afterUpdate() {
    }
    
    // ###################################################################################################### translateAssetInstallCountry
    public void translateAssetInstallCountry()
    {
        for (Asset assetToProcess : (List<Asset>) Trigger.new) {
            
            if(assetToProcess.Install_Country__c != null)
            {
                if(countryTranslationList__c.getInstance(assetToProcess.Install_Country__c) != null)
                {
                    assetToProcess.Install_Country__c = countryTranslationList__c.getInstance(assetToProcess.Install_Country__c).ctlTranslationName__c;
                }
            }
            system.debug('### Asset Last Validated Logic History ### '+assetToProcess.assetLastValidatedLogicHistory__c);
        }
    }
    
    // ###################################################################################################### setUpdatedAssetSameDayPartDeliveryPreference
    public static void setUpdatedAssetSameDayPartDeliveryPreference() {
        Asset oldAsset;
        
        for (Asset assetToProcess : (List<Asset>) Trigger.new) {
            oldAsset = (Asset) Trigger.oldMap.get(assetToProcess.Id);
            
            // System.debug('DEBUG: (setUpdatedAssetSameDayPartDeliveryPreference) oldAsset.SLA__c = ' + oldAsset.SLA__c);
            // System.debug('DEBUG: (setUpdatedAssetSameDayPartDeliveryPreference) assetToProcess.SLA__c = ' + assetToProcess.SLA__c);
            
            if (oldAsset.SLA__c == null                                                                                ||
                assetToProcess.SLA__c == null                                                                          ||
                (oldAsset.SLA__c.containsIgnoreCase('4 Hour')  && !assetToProcess.SLA__c.containsIgnoreCase('4 Hour')) ||
                (!oldAsset.SLA__c.containsIgnoreCase('4 Hour') && assetToProcess.SLA__c.containsIgnoreCase('4 Hour'))) {
                    // System.debug('DEBUG: (setUpdatedAssetSameDayPartDeliveryPreference) DIFFERENT - clear fields');
                    assetToProcess.assetSameDayPartDeliveryPreference__c = null;
                }
            else {
                // System.debug('DEBUG: (setUpdatedAssetSameDayPartDeliveryPreference) SAME - do not clear fields');
            }
        }
    }
    
    // ###################################################################################################### setInsertedAssetAddressBook
    public static void setInsertedAssetAddressBook() {
         try {//8413
            Boolean abInsertedcheck = false; //flag check for new AB insert
        // System.debug('DEBUG: (setInsertedAssetAddressBook) Entered.');
        
        // If the user is supportforce, do nothing with the Assets in this trigger.
        if (UserInfo.getUserName().containsIgnoreCase('supportforce')) {
            System.debug('DEBUG: (setInsertedAssetAddressBook) User is supportforce; returning');
            return;
        }
        
        // Populate the Address Book entries used by the Accounts of the Assets being inserted in this trigger.
        populateAddressBooks();
        // System.debug('DEBUG: (setInsertedAssetAddressBook) addressBooks.size() = ' + addressBooks.size());
        
        // Create Address Book entries that may not already exist.
        newAddressBooks = new List<AddressBook__c>();
        
        for (Asset assetToProcess : (List<Asset>) Trigger.new) {
            
            // If Street1, City, or Country is null, do nothing with this Asset.
            if (assetToProcess.Install_Street1__c == null ||
                assetToProcess.Install_City__c    == null ||
                assetToProcess.Install_Country__c == null) {
                    continue;
                }
            
            // If Address Book entry doesn't exist, create it.
            if (getAddressBookIdForAssetInstallAddress(assetToProcess)     == null  &&
                newAddressBookExistsForAssetInstallAddress(assetToProcess) == false &&
                  assetToProcess.assetPartShipAddressBook__c == null) {////Added by Exafort(Guru Dev) for TS-8494 on 12/04/22
                    createNewAddressBookForAssetInstallAddress(assetToProcess);
                }
            system.debug('### Asset Last Validated Logic History In setInsertedAssetAddressBook method1 ### '+assetToProcess.assetLastValidatedLogicHistory__c);
        }
        
        // Insert any new Address Book entries that were created.
        // System.debug('DEBUG: (setInsertedAssetAddressBook) newAddressBooks.size() = ' + newAddressBooks.size());
        // System.debug('DEBUG: (setInsertedAssetAddressBook) About to insert newAddressBooks');
        if (newAddressBooks.size() > 0) {
            // insert newAddressBooks;
            Database.insert(newAddressBooks, false);
             abInsertedcheck = True;//TS-8413
        }
        
        // Re-populate the Address Book entries.  This will contain the original list, plus any new ones that were created.
        if(abInsertedcheck){//TS-8413 to avoid calling populateAddressBooks method without creating new AB
        populateAddressBooks();
        }
        // System.debug('DEBUG: (setInsertedAssetAddressBook) addressBooks.size() = ' + addressBooks.size());
        
        // Set the Address Book lookup on Assets being inserted by this trigger.
        for (Asset assetToProcess : (List<Asset>) Trigger.new) {
            
            // If Street1, City, or Country is null, do nothing with this Asset.
            if (assetToProcess.Install_Street1__c == null ||
                assetToProcess.Install_City__c    == null ||
                assetToProcess.Install_Country__c == null) {
                    continue;
                }
            
            // Set the Asset Address Book lookup to the Address Book entry.
            assetToProcess.assetPartShipAddressBook__c = getAddressBookIdForAssetInstallAddress(assetToProcess);
            // System.debug('DEBUG: (setInsertedAssetAddressBook) assetToProcess.assetPartShipAddressBook__c set to: ' + assetToProcess.assetPartShipAddressBook__c);
            system.debug('### Asset Last Validated Logic History In setInsertedAssetAddressBook method ### '+assetToProcess.assetLastValidatedLogicHistory__c);
        }
    }
            catch(Exception e) {//TS-8413
            System.debug('An exception occurred in asset insert trigger: ' + e.getMessage());
        }
    }
    // ###################################################################################################### setUpdatedAssetAddressBook
    public static void setUpdatedAssetAddressBook() {
        //Added for TS-8413 by Exafort(Guru Dev) to restrict recursive calling
        if(RecursiveCheck.runOnce){
            RecursiveCheck.runOnce = false;
            try {//TS-8413
                Boolean abInserted = false; //flag check for new AB insert
                //Added End
        Asset oldAsset;
        
        // System.debug('DEBUG: (setUpdatedAssetAddressBook) Entered.');
        
        // If the user is supportforce, do nothing with the Assets in this trigger.
        if (UserInfo.getUserName().containsIgnoreCase('supportforce')) {
            System.debug('DEBUG: (setUpdatedAssetAddressBook) User is supportforce; returning');
            return;
        }
        // Populate the Address Book entries used by the Accounts of the Assets being updated in this trigger.
        populateAddressBooks();
        // System.debug('DEBUG: (setUpdatedAssetAddressBook) addressBooks.size() = ' + addressBooks.size());
        
        // Create Address Book entries that may not already exist.
        newAddressBooks = new List<AddressBook__c>();
        
        for (Asset assetToProcess : (List<Asset>) Trigger.new) {
            
            // Populate the Asset's old (previous) data
            oldAsset = (Asset) Trigger.oldMap.get(assetToProcess.Id);
            
            // If none of the Asset Install Address fields changed, do nothing with this Asset.
            if (oldAsset.Install_Street1__c        == assetToProcess.Install_Street1__c        &&
                oldAsset.Install_Street2__c        == assetToProcess.Install_Street2__c        &&
                oldAsset.Install_City__c           == assetToProcess.Install_City__c           &&
                oldAsset.Install_State_Province__c == assetToProcess.Install_State_Province__c &&
                oldAsset.Install_Zip_Code__c       == assetToProcess.Install_Zip_Code__c       &&
                oldAsset.Install_Country__c        == assetToProcess.Install_Country__c        &&
                assetToProcess.assetPartShipAddressBook__c != null) {//TS-8413 for psab null and install address not null
                    continue;
                }
            
            // If Street 1, City, or Country is null, do nothing with this Asset.
            if (assetToProcess.Install_Street1__c == null ||
                assetToProcess.Install_City__c    == null ||
                assetToProcess.Install_Country__c == null) {
                    continue;
                }
            
            // If Address Book entry doesn't exist, create it.
            if (getAddressBookIdForAssetInstallAddress(assetToProcess)     == null  &&
                newAddressBookExistsForAssetInstallAddress(assetToProcess) == false &&
                assetToProcess.assetPartShipAddressBook__c == null){///Added by Exafort(Guru Dev) for TS-8494 on 12/04/22
                    createNewAddressBookForAssetInstallAddress(assetToProcess);
                }
        }
        
        // Insert any new Address Book entries that were created.
        // System.debug('DEBUG: (setUpdatedAssetAddressBook) newAddressBooks.size() = ' + newAddressBooks.size());
        // System.debug('DEBUG: (setUpdatedAssetAddressBook) About to insert newAddressBooks');
        if (newAddressBooks.size() > 0) {
            // insert newAddressBooks;
            Database.insert(newAddressBooks, false);
            abInserted = True;//TS-8413
        }
        
        // Re-populate the Address Book entries.  This will contain the original list, plus any new ones that were created.
         if(abInserted){//TS-8413 to avoid calling populateAddressBooks method without creating new AB
        populateAddressBooks();
         }
        // System.debug('DEBUG: (setUpdatedAssetAddressBook) addressBooks.size() = ' + addressBooks.size());
        
        // Set the Address Book lookup on Assets being updated by this trigger.
        for (Asset assetToProcess : (List<Asset>) Trigger.new) {
            
            // Populate the Asset's old (previous) data
            oldAsset = (Asset) Trigger.oldMap.get(assetToProcess.Id);
            
            // If none of the Asset Install Address fields changed, do nothing with this Asset.
            if (oldAsset.Install_Street1__c        == assetToProcess.Install_Street1__c        &&
                oldAsset.Install_Street2__c        == assetToProcess.Install_Street2__c        &&
                oldAsset.Install_City__c           == assetToProcess.Install_City__c           &&
                oldAsset.Install_State_Province__c == assetToProcess.Install_State_Province__c &&
                oldAsset.Install_Zip_Code__c       == assetToProcess.Install_Zip_Code__c       &&
                oldAsset.Install_Country__c        == assetToProcess.Install_Country__c        &&
                assetToProcess.assetPartShipAddressBook__c != null) {//TS-8413 for psab null and install address not null
                    continue;
                }
            
            // If Street1, City, or Country is null, clear the Validated Date and Validated By-Info fields, and continue to the next Asset.
            if (assetToProcess.Install_Street1__c == null ||
                assetToProcess.Install_City__c    == null ||
                assetToProcess.Install_Country__c == null) {
                    continue;
                }
            
            // If the Asset Address Book lookup is null, set it to the Address Book entry of the install address.
            if (assetToProcess.assetPartShipAddressBook__c == null) {
                assetToProcess.assetPartShipAddressBook__c = getAddressBookIdForAssetInstallAddress(assetToProcess);
                // System.debug('DEBUG: (setInsertedAssetAddressBook) assetToProcess.assetPartShipAddressBook__c was null; set to: ' + assetToProcess.assetPartShipAddressBook__c);
            }
            else {
                // System.debug('DEBUG: (setInsertedAssetAddressBook) assetToProcess.assetPartShipAddressBook__c was not null; did not change');
            }
        }
            }
            catch(Exception e) {//TS-8413
                System.debug('An exception occurred in asset update trigger: ' + e.getMessage());}
    }
        }
    // ###################################################################################################### populateAddressBooks
    public static void populateAddressBooks() {
        // Gather all the Address Book entries needed for this trigger's Asset records
        Set<Id> assetAccountIds = new Set<Id>();
        
        for (Asset assetToProcess : (List<Asset>) Trigger.new) {
            
            assetAccountIds.add(assetToProcess.AccountId);
        }
        system.debug('%%% assetAccountIds'+assetAccountIds.size() + assetAccountIds);
        system.debug('%%% addressBooks'+addressBooks);
        
        addressBooks = new Map<Id, AddressBook__c>([SELECT Id,
                                                    abAccount__c,
                                                    abStreet1__c,
                                                    abStreet2__c,
                                                    abCity__c,
                                                    abStateProvince__c,
                                                    abPostalCode__c,
                                                    abCountry__c
                                                    FROM   AddressBook__c
                                                    WHERE  abAccount__c IN :assetAccountIds and abAccount__c != null]);// limit: assetAccountIds.size()])- 
        //removed limit from where condition to pick all the AB under the asset.account
        
        system.debug('%%% addressBooks'+addressBooks.size());
    }
    
    // ###################################################################################################### getAddressBookIdForAssetInstallAddress
    public static Id getAddressBookIdForAssetInstallAddress(Asset assetToProcess) {
        
        
        System.debug('DEBUG: (getAddressBookIdForAssetInstallAddress) get the address:');
        System.debug('DEBUG:   abAccount__c       = ' + assetToProcess.accountId);
        System.debug('DEBUG:   abStreet1__c       = ' + assetToProcess.Install_Street1__c);
        System.debug('DEBUG:   abStreet2__c       = ' + assetToProcess.Install_Street2__c);
        System.debug('DEBUG:   abCity__c          = ' + assetToProcess.Install_City__c);
        System.debug('DEBUG:   abStateProvince__c = ' + assetToProcess.Install_State_Province__c);
        System.debug('DEBUG:   abPostalCode__c    = ' + assetToProcess.Install_Zip_Code__c);
        System.debug('DEBUG:   abCountry__c       = ' + assetToProcess.Install_Country__c);
        
        
        for (AddressBook__c addressBook : addressBooks.values()) {
            if (addressBook.abAccount__c       == assetToProcess.accountId                 &&
                addressBook.abStreet1__c       == assetToProcess.Install_Street1__c        &&
                addressBook.abStreet2__c       == assetToProcess.Install_Street2__c        &&
                addressBook.abCity__c          == assetToProcess.Install_City__c           &&
                addressBook.abStateProvince__c == assetToProcess.Install_State_Province__c &&
                addressBook.abPostalCode__c    == assetToProcess.Install_Zip_Code__c       &&
                addressBook.abCountry__c       == assetToProcess.Install_Country__c) {
                    
                    return(addressBook.id);
                }
        }
        return(null);
    }
    
    // ###################################################################################################### newAddressBookExistsForAssetInstallAddress
    public static Boolean newAddressBookExistsForAssetInstallAddress(Asset assetToProcess) {
        for (AddressBook__c addressBook : newAddressBooks) {
            if (addressBook.abAccount__c       == assetToProcess.accountId                 &&
                addressBook.abStreet1__c       == assetToProcess.Install_Street1__c        &&
                addressBook.abStreet2__c       == assetToProcess.Install_Street2__c        &&
                addressBook.abCity__c          == assetToProcess.Install_City__c           &&
                addressBook.abStateProvince__c == assetToProcess.Install_State_Province__c &&
                addressBook.abPostalCode__c    == assetToProcess.Install_Zip_Code__c       &&
                addressBook.abCountry__c       == assetToProcess.Install_Country__c) {
                    
                    return(true);
                }
        }
        return(false);
    }
    
    // ###################################################################################################### createNewAddressBookForAssetInstallAddress
    public static void createNewAddressBookForAssetInstallAddress(Asset assetToProcess) {
        System.debug('DEBUG: (createNewAddressBookForAssetInstallAddress) Creating new entry with:');
        System.debug('DEBUG:   abAccount__c       = ' + assetToProcess.accountId);
        System.debug('DEBUG:   abStreet1__c       = ' + assetToProcess.Install_Street1__c);
        System.debug('DEBUG:   abStreet2__c       = ' + assetToProcess.Install_Street2__c);
        System.debug('DEBUG:   abCity__c          = ' + assetToProcess.Install_City__c);
        System.debug('DEBUG:   abStateProvince__c = ' + assetToProcess.Install_State_Province__c);
        System.debug('DEBUG:   abPostalCode__c    = ' + assetToProcess.Install_Zip_Code__c);
        System.debug('DEBUG:   abCountry__c       = ' + assetToProcess.Install_Country__c);
        System.debug('DEBUG:   abDescription__c   = ' + assetToProcess.Name + ' install address');
        
        newAddressBooks.add(new AddressBook__c(abAccount__c       = assetToProcess.accountId,
                                               abStreet1__c       = assetToProcess.Install_Street1__c,
                                               abStreet2__c       = assetToProcess.Install_Street2__c,
                                               abCity__c          = assetToProcess.Install_City__c,
                                               abStateProvince__c = assetToProcess.Install_State_Province__c,
                                               abPostalCode__c    = assetToProcess.Install_Zip_Code__c,
                                               abCountry__c       = assetToProcess.Install_Country__c,
                                               abDescription__c   = assetToProcess.Name + ' install address'));
    }
    
    // ###################################################################################################### setUpdatedAssetLastValidatedFields
    public static void setUpdatedAssetLastValidatedFields() {
        String newLastValidatedLogicHistory;
        
        for (Asset assetToProcess : (List<Asset>) Trigger.new) {
            Asset oldAsset = (Asset) Trigger.oldMap.get(assetToProcess.id);
            
            /* System.debug('DEBUG: ****************************************');
System.debug('Entered evaluatePartShipLastValidatedFields');
System.debug('Timestamp                                     = ' + System.now());
System.debug('User ID                                       = ' + UserInfo.getUserId());
System.debug('User Name                                     = ' + UserInfo.getUserName());
System.debug('INPUTS:');
System.debug('old Install_Street1__c                        = ' + oldAsset.Install_Street1__c);
System.debug('old Install_Street2__c                        = ' + oldAsset.Install_Street2__c);
System.debug('old Install_City__c                           = ' + oldAsset.Install_City__c);
System.debug('old Install_State_Province__c                 = ' + oldAsset.Install_State_Province__c);
System.debug('old Install_Zip_Code__c                       = ' + oldAsset.Install_Zip_Code__c);
System.debug('old Install_Country__c                        = ' + oldAsset.Install_Country__c);
System.debug('old assetPartShipLastValidatedDatetime__c     = ' + oldAsset.assetPartShipLastValidatedDatetime__c);
System.debug('old assetPartShipLastValidatedByInfo__c       = ' + oldAsset.assetPartShipLastValidatedByInfo__c);
System.debug('new Install_Street1__c                        = ' + assetToProcess.Install_Street1__c);
System.debug('new Install_Street2__c                        = ' + assetToProcess.Install_Street2__c);
System.debug('new Install_City__c                           = ' + assetToProcess.Install_City__c);
System.debug('new Install_State_Province__c                 = ' + assetToProcess.Install_State_Province__c);
System.debug('new Install_Zip_Code__c                       = ' + assetToProcess.Install_Zip_Code__c);
System.debug('new Install_Country__c                        = ' + assetToProcess.Install_Country__c);
System.debug('new assetPartShipLastValidatedDatetime__c     = ' + assetToProcess.assetPartShipLastValidatedDatetime__c);
System.debug('new assetPartShipLastValidatedByInfo__c       = ' + assetToProcess.assetPartShipLastValidatedByInfo__c);
System.debug('LOGIC DECISIONS:'); */
            
            /*  newLastValidatedLogicHistory = assetToProcess.assetLastValidatedLogicHistory__c +
'Timestamp                                     = ' + System.now() + '\n' +
'User ID                                       = ' + UserInfo.getUserId() + '\n' +
'User Name                                     = ' + UserInfo.getUserName() + '\n' +
'INPUTS:\n' +
'old Install_Street1__c                        = ' + oldAsset.Install_Street1__c + '\n' +
'old Install_Street2__c                        = ' + oldAsset.Install_Street2__c + '\n' +
'old Install_City__c                           = ' + oldAsset.Install_City__c + '\n' +
'old Install_State_Province__c                 = ' + oldAsset.Install_State_Province__c + '\n' +
'old Install_Zip_Code__c                       = ' + oldAsset.Install_Zip_Code__c + '\n' +
'old Install_Country__c                        = ' + oldAsset.Install_Country__c + '\n' +
'old assetPartShipLastValidatedDatetime__c     = ' + oldAsset.assetPartShipLastValidatedDatetime__c + '\n' +
'old assetPartShipLastValidatedByInfo__c       = ' + oldAsset.assetPartShipLastValidatedByInfo__c + '\n' +
'new Install_Street1__c                        = ' + assetToProcess.Install_Street1__c + '\n' +
'new Install_Street2__c                        = ' + assetToProcess.Install_Street2__c + '\n' +
'new Install_City__c                           = ' + assetToProcess.Install_City__c + '\n' +
'new Install_State_Province__c                 = ' + assetToProcess.Install_State_Province__c + '\n' +
'new Install_Zip_Code__c                       = ' + assetToProcess.Install_Zip_Code__c + '\n' +
'new Install_Country__c                        = ' + assetToProcess.Install_Country__c + '\n' +
'new assetPartShipLastValidatedDatetime__c     = ' + assetToProcess.assetPartShipLastValidatedDatetime__c + '\n' +
'new assetPartShipLastValidatedByInfo__c       = ' + assetToProcess.assetPartShipLastValidatedByInfo__c + '\n' +
'LOGIC DECISIONS:\n';*/
            
            if (UserInfo.getUserName().containsIgnoreCase('supportforce')) {
                // System.debug('HERE 0100 - User is supportforce; Ignore address change');
                newLastValidatedLogicHistory += 'HERE 0100 - User is supportforce; Ignore address change\n';
            }
            else {
                // System.debug('HERE 0200 - User is not supportforce; Do not ignore address change');
                newLastValidatedLogicHistory += 'HERE 0200 - User is not supportforce; Do not ignore address change\n';
                
                if (oldAsset.Install_Street1__c        != assetToProcess.Install_Street1__c        ||
                    oldAsset.Install_Street2__c        != assetToProcess.Install_Street2__c        ||
                    oldAsset.Install_City__c           != assetToProcess.Install_City__c           ||
                    oldAsset.Install_State_Province__c != assetToProcess.Install_State_Province__c ||
                    oldAsset.Install_Zip_Code__c       != assetToProcess.Install_Zip_Code__c       ||
                    oldAsset.Install_Country__c        != assetToProcess.Install_Country__c) {
                        
                        // System.debug('HERE 0300 - Address is different; clear Last Validated fields');
                        // Commented by Exafort for SFDC-783
                        // newLastValidatedLogicHistory += 'HERE 0300 - Address is different; clear Last Validated fields\n';
                        
                        // assetToProcess.assetPartShipLastValidatedDatetime__c = null;
                        // assetToProcess.assetPartShipLastValidatedByInfo__c   = null;
                    }
                else {
                    // System.debug('HERE 0400 - Address is not different; do not clear Last Validated fields');
                    newLastValidatedLogicHistory += 'HERE 0400 - Address is not different; do not clear Last Validated fields\n';
                }
            }
            
            /* System.debug('OUTPUTS:');
System.debug('old Install_Street1__c                        = ' + oldAsset.Install_Street1__c);
System.debug('old Install_Street2__c                        = ' + oldAsset.Install_Street2__c);
System.debug('old Install_City__c                           = ' + oldAsset.Install_City__c);
System.debug('old Install_State_Province__c                 = ' + oldAsset.Install_State_Province__c);
System.debug('old Install_Zip_Code__c                       = ' + oldAsset.Install_Zip_Code__c);
System.debug('old Install_Country__c                        = ' + oldAsset.Install_Country__c);
System.debug('old assetPartShipLastValidatedDatetime__c     = ' + oldAsset.assetPartShipLastValidatedDatetime__c);
System.debug('old assetPartShipLastValidatedByInfo__c       = ' + oldAsset.assetPartShipLastValidatedByInfo__c);
System.debug('new Install_Street1__c                        = ' + assetToProcess.Install_Street1__c);
System.debug('new Install_Street2__c                        = ' + assetToProcess.Install_Street2__c);
System.debug('new Install_City__c                           = ' + assetToProcess.Install_City__c);
System.debug('new Install_State_Province__c                 = ' + assetToProcess.Install_State_Province__c);
System.debug('new Install_Zip_Code__c                       = ' + assetToProcess.Install_Zip_Code__c);
System.debug('new Install_Country__c                        = ' + assetToProcess.Install_Country__c);
System.debug('new assetPartShipLastValidatedDatetime__c     = ' + assetToProcess.assetPartShipLastValidatedDatetime__c);
System.debug('new assetPartShipLastValidatedByInfo__c       = ' + assetToProcess.assetPartShipLastValidatedByInfo__c); */
            
            newLastValidatedLogicHistory = 'OUTPUTS:\n' +
                'old Install_Street1__c                        = ' + oldAsset.Install_Street1__c + '\n' +
                'old Install_Street2__c                        = ' + oldAsset.Install_Street2__c + '\n' +
                'old Install_City__c                           = ' + oldAsset.Install_City__c + '\n' +
                'old Install_State_Province__c                 = ' + oldAsset.Install_State_Province__c + '\n' +
                'old Install_Zip_Code__c                       = ' + oldAsset.Install_Zip_Code__c + '\n' +
                'old Install_Country__c                        = ' + oldAsset.Install_Country__c + '\n' +
                'old assetPartShipLastValidatedDatetime__c     = ' + oldAsset.assetPartShipLastValidatedDatetime__c + '\n' +
                'old assetPartShipLastValidatedByInfo__c       = ' + oldAsset.assetPartShipLastValidatedByInfo__c + '\n';
            
            assetToProcess.assetLastValidatedLogicHistory__c = newLastValidatedLogicHistory.right(131072);
        }
    }
    
    //ESS-25920--code start
    //yesha benegal
    @future
    public static void createAssetStageRecords(Set<Id> astId){
    
    List<Asset> newAsset = [select Id,HPE_Serial_Number__c,HPE_Support_SKU__c,Dynamic_SKU__c,Support_End_Date__c,Support_Start_Date_Asset__c,Install_City__c,Install_Country__c,Install_State_Province__c,Install_Street1__c,
                               Install_Street2__c, Install_Zip_Code__c,Ship_Date__c,SerialNumber,Asset_Stage__c,Asset_Product_Family__c,HPE_Opportunity_ID__c,  
                               Order_Type__c, Status, HPE_Order_Number__c, HPE_Quote_Number__c, dhci__c, HPE_Service_Agreement_ID__c, PurchaseDate, Product2.HPE_SKU__c from Asset where Id in: astId];
                               
        List<Asset_Stage__c> astStgLst = new List<Asset_Stage__c>();
        Set<string> existingSN = new Set<String>();
        system.debug(' *** isHPE' + AssetHPSyncTrgCls.isHPE);
       // if(AssetHPSyncTrgCls.isHPE == False){
            for(Asset a : newAsset){
                if(a.Asset_Stage__c == null && a.Asset_Product_Family__c != 'Virtual Array' ){ //&&  a.HPE_Opportunity_ID__c == null && AssetHPSyncTrgCls.isHPE == false){ // a.CreatedById == '005800000040ACd'
                    Asset_Stage__c aStg = new Asset_Stage__c();
                    aStg.Asset__c    = a.Id;
                    aStg.Legacy_Asset__c = true;
                    aStg.HPE_Serial_Number__c = a.HPE_Serial_Number__c;            
                    aStg.SLA_Support_Level__c = a.HPE_Support_SKU__c;
                    aStg.Dynamic_SKU__c = a.Dynamic_SKU__c;
                    Date DefaultEndDate = Date.newInstance(2099, 12, 31);
                    aStg.HPE_Product_SKU__c = a.Product2.HPE_SKU__c;
                    /*** CR#2881  code begins if asset has default date avoid adding it to asset stage*/
                    if(a.Support_End_Date__c != DefaultEndDate){
                        aStg.Support_End_Date__c = a.Support_End_Date__c;
                    }
                    /** end code **/
                    aStg.Support_Start_Date__c = a.Support_Start_Date_Asset__c;
                    aStg.Install_Address_City__c = a.Install_City__c;
                    aStg.Install_Address_Country__c = a.Install_Country__c;
                    aStg.Install_Address_State__c = a.Install_State_Province__c;
                    aStg.Install_Address_Street1__c = a.Install_Street1__c;
                    aStg.Install_Address_Street2__c = a.Install_Street2__c;
                    aStg.Install_Zip_Code__c = a.Install_Zip_Code__c;
                    aStg.Order_Ship_Date__c = a.Ship_Date__c;
                    aStg.Order_Status__c = a.Status;
                    aStg.Order_Type__c = a.Order_Type__c;
                    aStg.HPE_Order_Number__c = a.HPE_Order_Number__c;
                    aStg.HPE_Opportunity_ID__c = a.HPE_Opportunity_ID__c;
                    aStg.HPE_Quote_Number__c = a.HPE_Quote_Number__c;
                    aStg.dhci__c = a.dhci__c;
                    aStg.Purchase_Date_HPE_Receive_Date__c = a.PurchaseDate;
                    aStg.HPE_Service_Agreement_ID__c = a.HPE_Service_Agreement_ID__c;
                    if(a.SerialNumber != null){
                        string srn = a.SerialNumber;
                        //srn.remove('-');
                        //srn = srn + 'NIM';
                        aStg.Nimble_Serial_Number__c = srn;    
                        if(!existingSN.contains(srn)){
                            existingSN.add(srn);
                        }
                    }
                    
                    astStgLst.add(aStg);                
                }    
            }
            system.debug(' **** size of astStgLst ' + astStgLst.size());
            List<Asset_Stage__c> insertLst = new List<Asset_Stage__c>();
            insertLst = astStgLst;
            List<Asset_Stage__c> lstAstStg = [select Id, Nimble_Serial_Number__c from Asset_stage__c where Nimble_Serial_Number__c in: existingSN];
            system.debug(' **** size of lstAstStg' + lstAstStg.size());
            if(lstAstStg.size() > 0){
                for(integer i=0; i<lstAstStg.size(); i++){
                    for(integer j=0; j<astStgLst.size(); j++){
                        
                        if(lstAstStg[i].Nimble_Serial_Number__c == astStgLst[j].Nimble_Serial_Number__c){
                            astStgLst.remove(j);
                        }
                    }
                }
            }
            
            system.debug(' **** size of astStgLst ' + astStgLst.size());
            if(astStgLst.size() > 0){
                insert astStgLst;
            }
            
            Asset_nRec_FutureClass.nRecFutureMethod(astId);
            // CR#2886 -- Added by Srujan on 05/21/2020
            
            List<Asset> assets = new List<Asset>();
            for(Asset_Stage__c assetStage : astStgLst){
              
                Asset ast = new Asset();
                ast.Id = assetStage.Asset__c;
                ast.Asset_Stage__c = assetStage.Id;
                assets.add(ast);
            }
            
            if(!assets.isEmpty()){
               update assets;
            }
            // CR#2886  ---End
       // }
    }
     //ESS-25920--code end
     
     
   @future
   public static void createNECRecord(Set<Id> astId){
   
       Asset_nRec_FutureClass.nRecFutureMethod(astId);
   }

}