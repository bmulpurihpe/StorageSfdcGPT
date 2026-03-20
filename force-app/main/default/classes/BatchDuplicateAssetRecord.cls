//*****************************************************************************************************
// Name         : BatchDuplicateAssetRecord
// Created by   : Sharath
// Description  : This class is used for 
//                
//******************************************************************************************************
public class BatchDuplicateAssetRecord {

    BatchDuplicateAssetRecordHandler dupHandler = new BatchDuplicateAssetRecordHandler();
}
/*
global class BatchDuplicateAssetRecord implements Database.Batchable<sObject> , Schedulable 
   {   
        global string query; 
        
        global Database.QueryLocator start(Database.BatchableContext BC)
        {    
          if(String.isBlank(query)) {              
               query = ' Select id,name,account__c,Asset_Currency__c,Asset_Name__c,Contact__c,assetNrdEndDate__c,assetNrdStartDate__c, '+
                       ' Opportunity__c,Order_Type__c,Product__c,Purchase_Date__c,Sales_Order__r.Ship_To_Contact_Email__c,Sales_Order_Line__c, '+
                       ' Sales_Order_Line_ID__c, Shelf_Pack_1__c,Shelf_Pack_2__c,Shelf_Pack_3__c,Shelf_Pack_4__c,Shelf_Pack_5__c,Shelf_Pack_6__c, '+
                       ' Expansion_Shelf_Base__c,Array_Cache__c,Array_Capacity__c,Array_Controller__c,Array_Networking__c,Serial_Number__c, '+
                       ' Shipping_Date__c,SLA__c,Status__c,Support_End_Date__c,Support_Start_Date__c from Duplicate_Asset__c '+
                       ' where LastModifiedDate > TODAY ORDER BY LastModifiedDate DESC ';
          } 
          return Database.getQueryLocator(query);
        }
        global void execute(Database.BatchableContext BC, List<Duplicate_Asset__c> scope)
        {
                //BatchDuplicateAssetRecordHandler.invokeDuplicateAssetHandler(scope);        
        }   
        
        global void finish(Database.BatchableContext BC)
        {
            
        }
        
        global void execute(SchedulableContext sc) {
            BatchDuplicateAssetRecord bcDupAssets = new BatchDuplicateAssetRecord(); 
            database.executebatch(bcDupAssets,5);
        }
   
    }
    */