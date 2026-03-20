/*                              <<<< === Apex Trigger === >>>>
=============================================================================================================
Name                    : NEC_DefinitionSortOrder_Update ,Test class - NEC_DefinitionSortOrder_Update_Test
Description             : Contains the logic to reorder the NEC records.
Created Date            : 11th april 2019
Author                  : Vishnu R
Version                 : 1.0
Modification History    : Initial Version
==============================================================================================================
*/
trigger NEC_DefinitionSortOrder_Update on NEC_Definition__c (after update) {
    if(NEC_CheckRecusrive.runOnce()){
        if(Trigger.IsAfter && Trigger.IsUpdate){
            system.debug('### Inside After update');
            set<Id> IDtoRemove = new set<Id>();
            Integer roundedOffSortValue = 0;
            Boolean eligibleFieldsChanged = false;  //TS-7838
            Map<Id,NEC_Definition__c> DefinitionsWithSortOrder = new Map<Id,NEC_Definition__c>();
            List<NEC_Definition__c> NECDefForUpdate = new List<NEC_Definition__c>();
            for(NEC_Definition__c NECdef:Trigger.new){ 
                //Added by Guru Dev(Exafort) for TS-7838 on 12/13
                NEC_Definition__c NECDefinitionOldMap = Trigger.oldMap.get(NECdef.Id);
                If(NECDefinitionOldMap.necDefaultValue__c != NECdef.necDefaultValue__c ||
                   NECDefinitionOldMap.necDescription__c != NECdef.necDescription__c ||
                   NECDefinitionOldMap.necDocumentationURL__c != NECdef.necDocumentationURL__c ||
                   NECDefinitionOldMap.necFieldTypePicklistItems__c != NECdef.necFieldTypePicklistItems__c ||
                   NECDefinitionOldMap.necGroup__c != NECdef.necGroup__c ||
                   NECDefinitionOldMap.necLabel__c	!= NECdef.necLabel__c ||
                   NECDefinitionOldMap.necSortOrder__c	!= NECdef.necSortOrder__c ||
                   NECDefinitionOldMap.necFieldType__c	!= NECdef.necFieldType__c){
                       eligibleFieldsChanged = True;
                   }
                //Added End
                IDtoRemove.add(NECdef.Id);
                roundedOffSortValue = Integer.valueOf(NECdef.necSortOrder__c);
                
            }
            //Added by Guru Dev(Exafort) for TS-7838 on 12/13 - New If condition
            if(eligibleFieldsChanged){
                system.debug('Trigger is entering sort order update');
                List<NEC_Definition__c> EACDefinitionAllRecords = [Select Id,Name,necGroup__c,necSortOrder__c,necFieldType__c,necFieldTypePicklistItems__c from NEC_Definition__c ORDER BY necSortOrder__c];
                for(NEC_Definition__c eacrec:EACDefinitionAllRecords){
                    DefinitionsWithSortOrder.put(eacrec.Id,eacrec);
                }
                for (Id key: DefinitionsWithSortOrder.keySet()) {
                    System.debug(LoggingLevel.DEBUG, 'key: ' + key + '====> value: ' + DefinitionsWithSortOrder.get(key));
                }
                integer count = 0;
                for(NEC_Definition__c NECDefinition:DefinitionsWithSortOrder.values()){
                    system.debug('### EACDefinition id=====>'+NECDefinition.Name);
                    system.debug('### Sort order old value======>'+NECDefinition.necSortOrder__c );
                    count = count +10;
                    NECDefinition.necSortOrder__c = count;
                    system.debug('### Sort order assignment======>'+NECDefinition.necSortOrder__c );
                    NECDefForUpdate.add(NECDefinition);
                }
                system.debug('### list values for update ======>'+NECDefForUpdate);
                if(!NECDefForUpdate.isEmpty())
                    update NECDefForUpdate;
            }
        }
    }
}