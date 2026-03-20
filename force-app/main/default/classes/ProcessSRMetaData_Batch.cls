/* Purpose: A batch class to process the components and populate the 
 *          SR metadata with model numbers
 * Change Log: Created by Pradeep Aitha
 */ 
global class ProcessSRMetaData_Batch implements Database.Batchable<sObject>{
    
     global Database.QueryLocator start(Database.BatchableContext BC)
     {
         //Query all the existing components with model numbers and Service part numbers
         String query = 'select Id, componentDiskModel__c, componentServicePartNumber__c from Component__c where componentServicePartNumber__c != null and componentDiskModel__c != null';
         return Database.getQueryLocator(query);
     }
     global void execute(Database.BatchableContext BC, List<sObject> scope)
     {
         
         //Comp records with Model Numbers and SR part Numbers
         List<Component__c> compRecords = scope;       
         Map<String,Set<String>> srToModelMap = new Map<String,Set<String>>();
         Map<String,SR_Meta_Data__c> objsToUpdate = new Map<String,SR_Meta_Data__c>();
         //List<SR_Meta_Data__c> metaList = [select Id, srPart__c, srModelNumbers__c from SR_Meta_Data__c where srPart__c != null and srModelNumbers__c != null];
         List<SR_Meta_Data__c> metaList = [select Id, srPart__c, srModelNumbers__c from SR_Meta_Data__c where srPart__c != null];
         Map<String,String> partToModelMap = new Map<String,String>();
         for(SR_Meta_Data__c sr : metaList)
         {
             // sr.srModelNumbers__c != null Added by Exafort for SFDC-508
             if(sr.srModelNumbers__c != null){
                 partToModelMap.put(sr.srPart__c,sr.srModelNumbers__c);
             }
         }
       
         for(Component__c c : compRecords)
         {
             String mNum  = partToModelMap.get(c.componentServicePartNumber__c);
             if(mNum == null)
                  mNum = '';
             if(c.componentDiskModel__c != null && !mNum.contains(c.componentDiskModel__c))
             {
                 Set<String> models = srToModelMap.get(c.componentServicePartNumber__c);
                 if(models == null)
                    models = new Set<String>();
                models.add(c.componentDiskModel__c);
                 //map with service part number to model
                srToModelMap.put(c.componentServicePartNumber__c,models);                  
             }
             
           
         }
         for(String srNum : srToModelMap.keySet())
         {
             SR_Meta_Data__c sr = objsToUpdate.get(srNum);
             if(sr == null)
             {
                 sr = new SR_Meta_Data__c();
                 Set<String> models = srToModelMap.get(srNum);
                 String temp;
                 if(partToModelMap.get(srNum) != null)
                     temp = partToModelMap.get(srNum);
                 else
                     temp = '';
                 for(String m : models)
                 {
                     if(temp == '')
                         temp = m;
                     else
                        temp = temp + ',' + m;
                 }               
                 sr.srModelNumbers__c = temp;
                 sr.srPart__c = srNum;
                 objsToUpdate.put(srNum,sr);
             }
         }
         upsert objsToUpdate.values() srPart__c;
         
     }
     global void finish(Database.BatchableContext BC)
     {
       //Batch finished
     }

}