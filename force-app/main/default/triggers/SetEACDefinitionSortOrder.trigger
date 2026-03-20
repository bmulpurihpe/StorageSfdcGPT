/* * * ====================================================>
* Apex trigger: SetEACDefinitionSortOrder
* Author: Exafort(Vishnu)
* Date: 10/25/2018 
* * *
* * * */
trigger SetEACDefinitionSortOrder on Enhanced_Asset_Characteristic_Definition__c (after update) { 
    if(EACCheckrecusrive.runOnce()){
        if(Trigger.IsAfter && Trigger.IsUpdate){
            system.debug('### Inside After update');
            set<Id> IDtoRemove = new set<Id>();
            Integer roundedOffSortValue = 0;
            Map<Id,Enhanced_Asset_Characteristic_Definition__c> DefinitionsWithSortOrder = new Map<Id,Enhanced_Asset_Characteristic_Definition__c>();
            List<Enhanced_Asset_Characteristic_Definition__c> EACDefForUpdate = new List<Enhanced_Asset_Characteristic_Definition__c>();
            for(Enhanced_Asset_Characteristic_Definition__c EACdef:Trigger.new){
                IDtoRemove.add(EACdef.Id);
                roundedOffSortValue = Integer.valueOf(EACdef.Sort_Order__c);
            }
            List<Enhanced_Asset_Characteristic_Definition__c> EACDefinitionAllRecords = [Select Id,Name,Group__c,Sort_Order__c,Field_Type__c,Field_Type_Picklist_Items__c from Enhanced_Asset_Characteristic_Definition__c ORDER BY Sort_Order__c];
            for(Enhanced_Asset_Characteristic_Definition__c eacrec:EACDefinitionAllRecords){
                DefinitionsWithSortOrder.put(eacrec.Id,eacrec);
            }
            for (Id key: DefinitionsWithSortOrder.keySet()) {
                System.debug(LoggingLevel.DEBUG, 'key: ' + key + '====> value: ' + DefinitionsWithSortOrder.get(key));
            }
            integer count = 0;
            for(Enhanced_Asset_Characteristic_Definition__c EACDefinition:DefinitionsWithSortOrder.values()){
                system.debug('### EACDefinition id=====>'+EACDefinition.Name);
                system.debug('### Sort order old value======>'+EACDefinition.Sort_Order__c );
                count = count +10;
                EACDefinition.Sort_Order__c = count;
                system.debug('### Sort order assignment======>'+EACDefinition.Sort_Order__c );
                EACDefForUpdate.add(EACDefinition);
            }
            system.debug('### list values for update ======>'+EACDefForUpdate);
            if(!EACDefForUpdate.isEmpty())
                update EACDefForUpdate;
        }
    }
}