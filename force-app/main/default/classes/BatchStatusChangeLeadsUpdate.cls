//*****************************************************************************************************
// Name         : BatchStatusChangeLeadsUpdate
// Created by   : Sharath
// Description  : This class is used for 
//                1.Update of Status Change Date field on Leads
//                2. Use Query parameter to update selective set of records as required .
//******************************************************************************************************
global class BatchStatusChangeLeadsUpdate implements Database.Batchable<sObject> , Schedulable 
   {   
        global string query; 
        
        global Database.QueryLocator start(Database.BatchableContext BC)
        {    
          if(String.isBlank(query)) {              
               query = ' SELECT id, Status_Change_Date__c, LastModifiedDate FROM Lead '+
                       ' where status in (\'Nurture\',\'Working\',\'Open\',\'Disqualified\')  '+
                       ' and Status_Change_Date__c = null ORDER BY LastModifiedDate DESC ';
          }
          return Database.getQueryLocator(query);
        }
        
        global void execute(Database.BatchableContext BC, List<Lead> scope)
        {
            for(lead ld: scope)
            { 
                DateTime dT = ld.LastModifiedDate; 
                ld.Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day()); 
            }
            
            Update scope;
        }   
        
        global void finish(Database.BatchableContext BC)
        {
            
        }
        
        global void execute(SchedulableContext sc) {
            BatchStatusChangeLeadsUpdate bcLeads = new BatchStatusChangeLeadsUpdate(); 
            database.executebatch(bcLeads,2000);
        }
    }