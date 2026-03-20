trigger rmaUpdateDepotTrigger on RMAv2__c (before insert, before update, after insert, after update) {
    //Mapping Nearby Depot With RMA
    list<RMAv2__c> rmalist = new list<RMAv2__c>();
    String Objectapi = 'RMAv2__c';
    String address = '';
    String rmaId = '';
    
    //Map of RMA Id, RMA Address
    map<id, string> rmaMap = new map<id,string>();
    map<id, string> rmaMapwithoutStreet = new map<id,string>();
    map<id, string> rmaMapwithCity = new map<id,string>();
    // Added by Exafort for TS-5631, map holds the RMAv2 id and RMAv2 shipmentCountry
    map<id, string> rmaMapwithCountry = new map<id,string>();
    
    set<ID> rmaCaseId = new set<ID>();
    for(RMAv2__c rmarec : Trigger.new){
      
        if(rmarec.rmaCaseNumber__c != null){
            rmaCaseId.add(rmarec.rmaCaseNumber__c);
        }
    }
    
    //Contact.Email field Added by exafort 9/28/2020 TS-7448 
    Map<Id, Case> caseMap = new Map<Id, Case>([Select id, CaseNumber, Account.Name, Account.Support_Provider__r.Name,Contact.Email from Case where ID =: rmaCaseId]);
    List<string> surveykeyCollection = new List<string>();//TS-7450
    Map<Id, list<string>> surveyCollection = new Map<Id, list<string>>();//TS-7450
    
    List<EmailTemplate> RMA_surveyEmailTemplate = rmaTriggerHandler.getEmailTemplate(); // Added by Exafort for TS-9109
    
    //Trigger block for After Update
    if(Trigger.IsUpdate && Trigger.IsAfter){
        for(RMAv2__c rmarec : Trigger.new){
            RMAv2__c rmaoldrec = Trigger.oldMap.get(rmarec.Id);
            boolean isAccountH3C = false;
            if(caseMap.get(rmarec.rmaCaseNumber__c).Account.Support_Provider__c != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Support_Provider__r.Name.contains('H3C')){
                isAccountH3C = true;
            }
            //Consider rma that are in Draft status and change in address   
            // caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null Added by Exafort
            //	If condition updated by Exafort to support 2HR SLA
            if( (rmarec.rmaAssetSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('Scheduled') || rmarec.rmaAssetSla__c.contains('2') || rmarec.rmaShipmentSla__c.contains('2'))
               && (rmarec.rmaStatus__c == 'Draft') 
               && (rmarec.rmaUplift__c != rmaoldrec.rmaUplift__c || rmaoldrec.rmaAddressBook__c != rmarec.rmaAddressBook__c
                   || rmaoldrec.rmaOverrideShipmentCity__c != rmarec.rmaOverrideShipmentCity__c
                   || rmaoldrec.rmaOverrideShipmentState__c != rmarec.rmaOverrideShipmentState__c 
                   || rmaoldrec.rmaOverrideShipmentCountry__c != rmarec.rmaOverrideShipmentCountry__c)
               //|| rmaoldrec.rmaOverrideShipmentPostalCode__c != rmarec.rmaOverrideShipmentPostalCode__c
               && rmarec.rmaOverrideShipmentCountry__c != 'South Korea' && rmarec.rmaDontCalculateDepot__c == false && caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null && !caseMap.get(rmarec.rmaCaseNumber__c).Account.Name.contains('H3C') && isAccountH3C == false )//rmarec.rmaIsNBDOverriden__c== false && rmarec.rmaShipmentSla__c != 'NBD'
            {
                address = '';
                address += rmarec.rmaShipmentStreet1__c;
                address += rmarec.rmaShipmentStreet2__c;
                address += rmarec.rmaShipmentAddressDetail__c;
                rmaId = rmarec.Id;
                rmaMap.put(rmaId, address);
                rmaMapwithoutStreet.put(rmaId, rmarec.rmaShipmentAddressDetail__c);
                rmaMapwithCity.put(rmaId, rmarec.rmaShipmentAddresswithCity__c);
                // Added by Exafort for TS-5631
                rmaMapwithCountry.put(rmaId, rmarec.rmaShipmentCountry__c);
            } 
            
            system.debug('rmarec.rmaOnsiteTechStatus__c ' + rmarec.rmaOnsiteTechStatus__c);
            system.debug('rmaoldrec.rmaOnsiteTechStatus__c ' + rmaoldrec.rmaOnsiteTechStatus__c);
             //TS-7450 START Added by exafort on 10/12/2020 
            if((rmarec.rmaOnsiteTechStatus__c == 'CLOSED-10: Released from site') && 
               (rmarec.rmaAssetSla__c == '4-Hour Onsite' || rmarec.rmaAssetSla__c == 'NBD Onsite')){
                   if(rmaoldrec.rmaOnsiteTechStatus__c != rmarec.rmaOnsiteTechStatus__c) {
                       surveykeyCollection.add(RMA_surveyEmailTemplate[0].Id);
                       surveykeyCollection.add(rmarec.CaseAccountId__c);
                       surveykeyCollection.add(rmarec.CaseContactId__c);
                       surveykeyCollection.add(rmarec.rmaAssetId__c);                      
                       surveyCollection.put(rmarec.Id,surveykeyCollection);  
                   }
               }
             //TS-7450 END   
        }
        //TS-7450 START Added by exafort on 10/12/2020 
        if(surveyCollection.size() > 0 && SurveyTracking.isAvoidRecursive){             
            SurveyTracking.createSurveyTrackingRecord('RMA',surveyCollection);
             SurveyTracking.isAvoidRecursive = false;
        }
         //TS-7450 END  
    }    
    
    //Trigger block for After Insert
    if(Trigger.IsInsert && Trigger.IsAfter){
        for (RMAv2__c rmarec : Trigger.new){
            boolean isAccountH3C = false;
            if(caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Support_Provider__c != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Support_Provider__r.Name.contains('H3C')){
                isAccountH3C = true;
            }
            system.debug('After insert trigger called on rmaupdateDepotTrigger');
            // caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null Added by Exafort
            //	If condition updated by Exafort to support 2HR SLA
            if(
                (rmarec.rmaAssetSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('Scheduled') || rmarec.rmaAssetSla__c.contains('2') || rmarec.rmaShipmentSla__c.contains('2'))
                && rmarec.rmaOverrideShipmentCountry__c != 'South Korea' && rmarec.rmaShipmentCountry__c != 'South Korea'  && rmarec.rmaDontCalculateDepot__c == false &&
                (
                    //	Added by Exafort for TS-10557
                    //	Account is not available, so assume it is not H3C
                    (caseMap.get(rmarec.rmaCaseNumber__c).Account == null) ||
                    //	If Account is available, make sure it is not H3C
                    (caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null && 
                     !caseMap.get(rmarec.rmaCaseNumber__c).Account.Name.contains('H3C') && isAccountH3C == false)
                )
              ){
                   
                   address = '';
                   address += rmarec.rmaShipmentStreet1__c;
                   address += rmarec.rmaShipmentStreet2__c;
                   address += rmarec.rmaShipmentAddressDetail__c;
                   rmaId = rmarec.Id;
                   rmaMap.put(rmaId, address);
                   rmaMapwithoutStreet.put(rmaId, rmarec.rmaShipmentAddressDetail__c);
                   rmaMapwithCity.put(rmaId, rmarec.rmaShipmentAddresswithCity__c);
                   // Added by Exafort for TS-5631
                   rmaMapwithCountry.put(rmaId, rmarec.rmaShipmentCountry__c);
                   
               }
        }
    }
    /*** START - Added by Azar ***/
    /*** Date - 28th FEB 2017 IST ***/
    /*** PURPOSE - If RMA Address Book Country is South Korea without Overridden Country, then map the Depot listed in AddressBook if available***/
    if(Trigger.isInsert && Trigger.isBefore || Trigger.isUpdate && Trigger.isBefore){
        try{
            set<Id> abSetOfID = new set<Id>();
            set<ID> rmaAssetID = new set<ID>();            
            
            for(RMAv2__c rmarec : Trigger.new){
                
                rmarec.Contact_Email__c = caseMap.get(rmarec.rmaCaseNumber__c).Contact.Email;//Added by exafort 9/28/2020 TS-7448 
                
                /* Added on 5th March 2018
* By - Exafort(Azar)
* Purpose - The below condition and depot assignment is for H3C related RMAs
* */ 
                
                // caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null Added by Exafort
                if((caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name.contains('H3C')) || 
                   (caseMap.get(rmarec.rmaCaseNumber__c).Account.Support_Provider__c != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Support_Provider__r.Name.contains('H3C'))){
                    rmarec.rmaOutgoingShipmentOrderDepot__c = 'Unknown';
                    rmarec.rmaOutgoingShipmentOrderProvider__c = 'Unknown';
                }
                boolean isAccountH3C = false;
                if(caseMap.get(rmarec.rmaCaseNumber__c).Account.Support_Provider__c != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Support_Provider__r.Name.contains('H3C')){
                    isAccountH3C = true;
                }
                // caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null Added by Exafort
                //	If condition updated by Exafort to support 2HR SLA
                if((rmarec.rmaAssetSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('Scheduled') || rmarec.rmaAssetSla__c.contains('2') || rmarec.rmaShipmentSla__c.contains('2')) 
                   && rmarec.rmaShipmentCountry__c == 'South Korea' && rmarec.rmaOverrideShipmentCountry__c == null&& rmarec.rmaOverrideShipmentStreet1__c == null&& 
                   rmarec.rmaOverrideShipmentStreet2__c == null&& rmarec.rmaOverrideShipmentCity__c == null && rmarec.rmaOverrideShipmentPostalCode__c == null && 
                   rmarec.rmaDontCalculateDepot__c == false && caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null && 
                   !caseMap.get(rmarec.rmaCaseNumber__c).Account.Name.contains('H3C') && isAccountH3C == false){//&& rmarec.rmaShipmentSla__c != 'NBD'
                       if(rmarec.rmaAddressBook__c != null){
                           abSetOfID.add(rmarec.rmaAddressBook__c);
                       }
                   }
                // caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null Added by Exafort
                //	If condition updated by Exafort to support 2HR SLA
                else if((rmarec.rmaAssetSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('Scheduled') || rmarec.rmaAssetSla__c.contains('2') || rmarec.rmaShipmentSla__c.contains('2')) && 
                        (rmarec.rmaOverrideShipmentCountry__c != null || rmarec.rmaOverrideShipmentStreet1__c != null || rmarec.rmaOverrideShipmentStreet2__c != null || rmarec.rmaOverrideShipmentCity__c != null || rmarec.rmaOverrideShipmentPostalCode__c != null) && 
                        caseMap.get(rmarec.rmaCaseNumber__c).Account != null && caseMap.get(rmarec.rmaCaseNumber__c).Account.Name != null && !caseMap.get(rmarec.rmaCaseNumber__c).Account.Name.contains('H3C') && isAccountH3C == false ){ //&& rmarec.rmaShipmentSla__c != 'NBD'
                    if(rmarec.rmaDiskShelfAsset__c != null){
                        rmaAssetID.add(rmarec.rmaDiskShelfAsset__c);
                    }
                }
            }
            List<AddressBook__c> abList = [Select id, ab4HourDepot__c, ab4HourDepot__r.Name, ab4HourDepot__r.depotProvider__c from AddressBook__c where ID IN : abSetOfID];
            List<Asset> rmaAsset = [Select id, assetShipmentAddressDepot__c from Asset Where ID IN : rmaAssetID];
            set<string> assetShipmentDepot = new set<string>();
            for(Asset asset : rmaAsset){
                if(asset.assetShipmentAddressDepot__c != null){
                    assetShipmentDepot.add(asset.assetShipmentAddressDepot__c);
                }
            }
            List<Depot__c> depotWithShipmentAddress = [select id, Name, depotProvider__c from depot__c where Name IN : assetShipmentDepot];
            for(RMAv2__c rmarec : Trigger.new){
                for(AddressBook__c ab : abList){
                    if(rmarec.rmaOverrideShipmentCountry__c == null && rmarec.rmaOverrideShipmentStreet1__c == null&& rmarec.rmaOverrideShipmentStreet2__c == null&& rmarec.rmaOverrideShipmentCity__c == null && rmarec.rmaOverrideShipmentPostalCode__c == null){
                        //Added rmarec.rmaShipmentSla__c != 'NBD' for restricting the 4 hout depot update when the SLA is overriden to NBD.TS-5318
                        //	If condition updated by Exafort to support 2HR SLA
                        if((rmarec.rmaAssetSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('Scheduled') || rmarec.rmaAssetSla__c.contains('2') || rmarec.rmaShipmentSla__c.contains('2')) && rmarec.rmaShipmentCountry__c == 'South Korea' && rmarec.rmaDontCalculateDepot__c == false && rmarec.rmaShipmentSla__c != 'NBD'){
                            if(ab.ab4HourDepot__c != null){
                                if(Trigger.isInsert){
                                    rmarec.rmaNearbyDepot__c = ab.ab4HourDepot__c;
                                    rmarec.rmaOutgoingShipmentOrderDepot__c = ab.ab4HourDepot__r.Name;
                                    rmarec.rmaOutgoingShipmentOrderProvider__c = ab.ab4HourDepot__r.depotProvider__c;
                                }
                                if(Trigger.isUpdate){
                                    if(rmarec.rmaOutgoingShipmentOrderDepot__c == null){
                                        rmarec.rmaNearbyDepot__c = ab.ab4HourDepot__c;
                                        rmarec.rmaOutgoingShipmentOrderDepot__c = ab.ab4HourDepot__r.Name;
                                        rmarec.rmaOutgoingShipmentOrderProvider__c = ab.ab4HourDepot__r.depotProvider__c;
                                    }
                                }
                            }
                        }
                    }
                }
                for(Depot__c depot : depotWithShipmentAddress){
                    if(rmarec.rmaOverrideShipmentCountry__c != null || rmarec.rmaOverrideShipmentStreet1__c != null || rmarec.rmaOverrideShipmentStreet2__c != null || rmarec.rmaOverrideShipmentCity__c != null || rmarec.rmaOverrideShipmentPostalCode__c != null){
                        //Added rmarec.rmaShipmentSla__c != 'NBD' for restricting the 4 hout depot update when the SLA is overriden to NBD.TS-5318
                        //	If condition updated by Exafort to support 2HR SLA
                        if((rmarec.rmaAssetSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('4') || rmarec.rmaShipmentSla__c.contains('Scheduled') || rmarec.rmaAssetSla__c.contains('2') || rmarec.rmaShipmentSla__c.contains('2')) && (rmarec.rmaShipmentCountry__c == 'South Korea' || rmarec.rmaOverrideShipmentCountry__c == 'South Korea') && rmarec.rmaDontCalculateDepot__c == false && rmarec.rmaShipmentSla__c != 'NBD'){
                            if(Trigger.isInsert){
                                rmarec.rmaNearbyDepot__c = depot.id;
                                rmarec.rmaOutgoingShipmentOrderDepot__c = depot.Name;
                                rmarec.rmaOutgoingShipmentOrderProvider__c = depot.depotProvider__c;
                            }
                            if(Trigger.isUpdate){
                                if(rmarec.rmaOutgoingShipmentOrderDepot__c == null){
                                    rmarec.rmaNearbyDepot__c = depot.id;
                                    rmarec.rmaOutgoingShipmentOrderDepot__c = depot.Name;
                                    rmarec.rmaOutgoingShipmentOrderProvider__c = depot.depotProvider__c;
                                }
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            system.debug('@@@ Exception Caught in Before Insert Event of rmaUpdateDepotTrigger Apex Trigger @@@ '+e.getMessage());
        }
        
    }
    /*** END - Added by Azar ***/
    
    if(!rmaMap.isEmpty()){
        //Passing the map of RMA id and address, Object api('RMA'), map of RMA id and address without street, map of RMA id and address with city and country
        if(System.IsBatch() == false && System.isFuture() == false){
            // Added new parameter "rmaMapwithCountry" by exafort for TS-5631 to check for isDepotAndShipToWithinUSAorFullyForeign //
            Geolocationaddress.geocodeAddressFuture(rmaMap, Objectapi, rmaMapwithoutStreet, rmaMapwithCity,rmaMapwithCountry);
        }
    }    
}