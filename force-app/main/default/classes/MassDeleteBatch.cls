/*                              <<<< === Apex Batch Class for Sobject Records Mass Delete === >>>>
    =============================================================================================================
        Name                    : MassDeleteBatch
        Description             : To delete sObject records which are provided to the class by a string query with the object name.
        Created Date            : 3rd April 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
global class MassDeleteBatch implements Database.Batchable<sObject>{
    
    global String queryString;
    global String objectString;
    
    
    global MassDeleteBatch(String objectString){
        queryString = constructQuery(objectString);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    global String constructQuery(String objectString){
        
        queryString = 'SELECT Id FROM '+objectString+ ' where createddate < LAST_MONTH';
        return queryString;
    }
}