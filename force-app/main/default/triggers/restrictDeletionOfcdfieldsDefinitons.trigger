/*                              <<<< === Apex Trigger === >>>>
    =============================================================================================================
        Name                    : restrictDeletionOfcdfieldsDefinitons
        Description             : To restrict the deletion of "Additional Info" and "Is this Under Duress ?" from case docket field definition.
        Created Date            : 21st July 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
trigger restrictDeletionOfcdfieldsDefinitons on CaseDocketFieldDefinition__c (before delete,before update) {
    if(System.Trigger.IsDelete)
    { 
        for (CaseDocketFieldDefinition__c cdFdRec : Trigger.old) 
        {
            if (cdFdRec.cdfdLabel__c == 'Additional Info' || cdFdRec.cdfdLabel__c == 'Is this under duress ?')
            { 
                cdFdRec.addError('You cannot delete this field Definition.Please contact your Salesforce Administrator for assistance.');
            }
            if(cdFdRec.cdfdRequired__c == true)
            {
                cdFdRec.addError('Required field defintions cannot be deleted.Please contact your Salesforce Administrator for assistance.');
            }
        } 
    }
}