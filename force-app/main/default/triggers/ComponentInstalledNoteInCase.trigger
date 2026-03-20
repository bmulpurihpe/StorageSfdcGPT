trigger ComponentInstalledNoteInCase on Component__c (after update,before insert, before update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        new ComponentInstalledNoteInCaseHandler().run();
    }
    //Added by Exafort (Guru Dev) for TS-9261 to map SR MetaData when Component Service Part Number exists
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        try
        {
            set<id> compId = new set<id>();
            Map<string, SR_Meta_Data__c> srMetaDataMap = new Map<string, SR_Meta_Data__c>();
            for(Component__c compRec : Trigger.new){
                if(compRec.componentServicePartNumber__c != null){//To get the Component ids only when Service Part Number exists
                    compId.add(compRec.Id);
                }
            }
            if(compId.size() > 0 && srMetaDataMap.size() == 0){
                for(SR_Meta_Data__c srMetaData:[select Id,Name,srPart__c From SR_Meta_Data__c]){//quering SR MetaData
                    srMetaDataMap.put(srMetaData.srPart__c, srMetaData);
                }
            }
            if(Trigger.isInsert){
                for(Component__c compRec : Trigger.new){
                    if(compRec.SR_MetaData__c == null && compRec.componentServicePartNumber__c != null){
                        SR_Meta_Data__c SRMetaDataRec = srMetaDataMap.get(compRec.componentServicePartNumber__c);
                        if(SRMetaDataRec != null){
                            compRec.SR_MetaData__c = SRMetaDataRec.id;//Mapping SR MetaData using the Service Part Number
                        }
                    }
                }
            }
            if(Trigger.isUpdate){
                for(Component__c compRec : Trigger.new){
                    Component__c oldCompServicePartNo = Trigger.oldMap.get(compRec.id);
                    if(compRec.componentServicePartNumber__c != null && (oldCompServicePartNo.componentServicePartNumber__c != compRec.componentServicePartNumber__c || compRec.SR_MetaData__c == null)){
                        SR_Meta_Data__c SRMetaDataRec = srMetaDataMap.get(compRec.componentServicePartNumber__c);
                        if(SRMetaDataRec != null){
                            compRec.SR_MetaData__c = SRMetaDataRec.id;//Mapping SR MetaData using the Service Part Number
                        }
                    }else if(compRec.componentServicePartNumber__c != null && oldCompServicePartNo.componentServicePartNumber__c != compRec.componentServicePartNumber__c && compRec.SR_MetaData__c != null){
                        SR_Meta_Data__c SRMetaRec = srMetaDataMap.get(compRec.componentServicePartNumber__c);
                        if(SRMetaRec != null){
                            compRec.SR_MetaData__c = SRMetaRec.id;//Mapping SR MetaData using the Service Part Number
                        }
                    }else{
                        if(compRec.componentServicePartNumber__c == null){
                            compRec.SR_MetaData__c = null;
                        }
                    }
                }                
            }
        }catch(Exception e){
            system.debug('Error on Component Insert/Update'+e.getMessage());
        } 
    }
    //Added End
}