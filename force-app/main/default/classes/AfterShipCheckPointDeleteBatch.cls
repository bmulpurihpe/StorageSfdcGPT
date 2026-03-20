/*                              <<<< === Batch Apex === >>>>
    =============================================================================================================
        Name                    : AfterShipCheckPointDeleteBatch
        Description             : To delete ahead of last n days aftership checkpoint info 
        Created Date            : 28/05/2015
        Author                  : KomathiPriya
        Version                 : 1.0
        Modification History    : Initial Version 
    ==============================================================================================================
*/

global class AfterShipCheckPointDeleteBatch implements Database.Batchable<sObject> {
    
    // Used to query the AfterShip Tracking records, which are ahead of last n days, and send to Execute method
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        System.debug('@@ Entered in to Start methods ');
        AfterShipSettings__c objAS = AfterShipSettings__c.getInstance(); 
        integer days = (integer)objAS.DaystoDeletetheAfterShipLogs__c;
        system.debug('@@ days ' + days);
        DateTime deleteDate = system.now().addDays(-days);
        return Database.getQueryLocator([SELECT Id,CreatedDate FROM AfterShipCheckPoint__c where CreatedDate <= :deleteDate]);
        
    }
    
    // Used to delete the fetched logs    
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
         
         system.debug('@@ scope ' + scope); 
         //delete the AfterShipCheckPoint__c values for the past DaystoDeletetheAfterShipLogs__c days as per custom settings AfterShipSettings__c           
         delete scope;
    }   
    
    global void finish(Database.BatchableContext BC) {
        System.debug('@@ Entered in to Finish methods @@');
        //AfterShipCheckPointforRMADeleteBatch BatchASCPforRMA = new AfterShipCheckPointforRMADeleteBatch();
        //database.executebatch(BatchASCPforRMA,100);
    }
    
 }