/*                              <<<< === Batch Apex === >>>>
    =============================================================================================================
        Name                    : AfterShipTrackingDeleteBatch
        Description             : To delete ahead of last n days aftership tracking info 
        Created Date            : 28/05/2015
        Author                  : KomathiPriya
        Version                 : 1.0
        Modification History    : Initial Version 
    ==============================================================================================================
*/

global class AfterShipTrackingDeleteBatch implements Database.Batchable<sObject>,Schedulable {
    
    // Used to query the AfterShip Tracking records, which are ahead of last n days, and send to Execute method
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        System.debug('@@ Entered in to Start methods ');
        AfterShipSettings__c objAS = AfterShipSettings__c.getInstance(); 
        integer days = (integer)objAS.DaystoDeletetheAfterShipLogs__c;
        system.debug('@@ days ' + days);
        DateTime deleteDate = system.now().addDays(-days);
        return Database.getQueryLocator([SELECT Id,CreatedDate FROM AfterShipTracking__c where CreatedDate <= :deleteDate]);
        
    }
    
    // Used to delete the fetched logs    
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
         
         system.debug('@@ scope ' + scope); 
         //delete the AfterShipTracking__c values for the past DaystoDeletetheAfterShipLogs__c days as per custom settings AfterShipSettings__c      
         delete scope;
    }   
    
    global void finish(Database.BatchableContext BC) {
        System.debug('@@ Entered in to Finish methods @@');
        AfterShipCheckPointDeleteBatch BatchASCP = new AfterShipCheckPointDeleteBatch();
        database.executebatch(BatchASCP,100);
        
    }
    
    // This methos is used to execute the batch class    
    global void execute(SchedulableContext sc) {
        AfterShipTrackingDeleteBatch BatchAST = new AfterShipTrackingDeleteBatch();
        database.executebatch(BatchAST,100);
    }
}