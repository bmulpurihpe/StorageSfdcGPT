/*                              <<<< === Apex Batch Class for Sobject Records Mass Delete === >>>>
    =============================================================================================================
        Name                    : MassRecordsDeleteBatch
        Description             : To delete sObject records which are provided to the class by a string query.
        Created Date            : 3rd April 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
global class MassRecordsDeleteBatch implements Database.Batchable<sObject>{
    
    global String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }  
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
        DataBase.emptyRecycleBin(scope);
    }
    
    global void finish(Database.BatchableContext BC){
    } 
}