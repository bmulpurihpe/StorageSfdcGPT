/*                              <<<< === Apex Trigger === >>>>
    =============================================================================================================
        Name                    : createDefaultFields
        Description             : To create the "Additional Info" and "Is this Under Duress ?" by default on case docket creation.
        Created Date            : 21st July 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
trigger createDefaultFields on Case_Docket__c (after insert) {
    Set<Id> caseDocketIds = new Set<Id>();
    //code block for trigger after insert action
    if(Trigger.IsInsert && Trigger.IsAfter){
        List<CaseDocketFieldDefinition__c> listToinsert = new List<CaseDocketFieldDefinition__c>();
        for(Case_Docket__c cdRec: Trigger.New){
            CaseDocketFieldDefinition__c cdfdRecOne = new CaseDocketFieldDefinition__c();
            cdfdRecOne.cdfdCaseDocket__c = cdRec.Id;
            cdfdRecOne.Name = 'Is this under duress ?';
            cdfdRecOne.cdfdLabel__c = 'Is this under duress ?';
            //cdfdRecOne.cdfdDescription__c = 'Is this under duress ?';
            cdfdRecOne.cdfdDescription__c = 'Is this issue extremely urgent? Checking the box will create a P1 case.'; // TS-6710 
            cdfdRecOne.cdfdFieldType__c = 'Boolean';
            cdfdRecOne.cdfdOrdinal__c = 98;
            listToinsert.add(cdfdRecOne);
            
            CaseDocketFieldDefinition__c cdfdRecTwo = new CaseDocketFieldDefinition__c();
            cdfdRecTwo.cdfdCaseDocket__c = cdRec.Id;
            cdfdRecTwo.Name = 'Additional Info';
            cdfdRecTwo.cdfdLabel__c = 'Additional Info';
            cdfdRecTwo.cdfdDescription__c = 'Additional Info';
            cdfdRecTwo.cdfdFieldType__c = 'Text Area';
            cdfdRecTwo.cdfdOrdinal__c = 99;
            listToinsert.add(cdfdRecTwo);
        }
        insert listToinsert;
    }
    //code block for trigger after update action
    /*if(Trigger.IsUpdate && Trigger.IsAfter){
        Set<Id> CaseDocketIdsToInsert = new Set<Id>();
        Set<Id> CaseDocketIdsToInsertDuplicates = new Set<Id>();
        list<id> IdsToRemove = new list<id>();
        List<CaseDocketFieldDefinition__c> listToinsertAu = new List<CaseDocketFieldDefinition__c>();
        for(Case_Docket__c cdRec: Trigger.New){
            caseDocketIds.add(cdRec.Id);
        }
        List<CaseDocketFieldDefinition__c> listTocheckCdfd = [Select Id,cdfdLabel__c,cdfdCaseDocket__c from CaseDocketFieldDefinition__c where cdfdCaseDocket__c IN :caseDocketIds];
        system.debug('@@@@ list size ===>'+ listTocheckCdfd.size());
        if(listTocheckCdfd.size()>0){
            for(Case_Docket__c cdRec: Trigger.New){
                for(CaseDocketFieldDefinition__c cdFdRec:listTocheckCdfd ){
                    if(cdRec.Id == cdFdRec.cdfdCaseDocket__c &&  (cdFdRec.cdfdLabel__c == 'Additional Info' || cdFdRec.cdfdLabel__c == 'Is this under duress ?')){
                        CaseDocketIdsToInsertDuplicates.add(cdFdRec.cdfdCaseDocket__c);
                    }else{
                        CaseDocketIdsToInsert.add(cdFdRec.cdfdCaseDocket__c);
                    }
                }
            } 
        }
        if(CaseDocketIdsToInsertDuplicates.size()>0){
            CaseDocketIdsToInsert.removeAll(CaseDocketIdsToInsertDuplicates);
        }
        system.debug('@@@@ final ids to insert cdfd ===>'+CaseDocketIdsToInsert);
        if(CaseDocketIdsToInsert.size()>0){
            for(Id cdRecord: CaseDocketIdsToInsert){
                CaseDocketFieldDefinition__c cdfdRecOne = new CaseDocketFieldDefinition__c();
                cdfdRecOne.cdfdCaseDocket__c = cdRecord;
                cdfdRecOne.cdfdLabel__c = 'Is this under duress ?';
                //cdfdRecOne.cdfdDescription__c = 'Is this under duress ?';
                cdfdRecOne.cdfdDescription__c = 'Is this issue extremely urgent? Checking the box will create a P1 case.'; //TS-6710 added by exafort
                cdfdRecOne.cdfdFieldType__c = 'Boolean';
                cdfdRecOne.cdfdOrdinal__c = 98;
                listToinsertAu.add(cdfdRecOne);
                
                CaseDocketFieldDefinition__c cdfdRecTwo = new CaseDocketFieldDefinition__c();
                cdfdRecTwo.cdfdCaseDocket__c = cdRecord;
                cdfdRecTwo.cdfdLabel__c = 'Additional Info';
                cdfdRecTwo.cdfdDescription__c = 'Additional Info';
                cdfdRecTwo.cdfdFieldType__c = 'Text Area';
                cdfdRecTwo.cdfdOrdinal__c = 99;
                listToinsertAu.add(cdfdRecTwo);
            }
            insert listToinsertAu; 
        }
    }*/
}