global class abCountryTranslationsBatch implements Database.Batchable<sObject>{
    
   global final String Query;
   //Query all the Address Book Country
   global abCountryTranslationsBatch(){
               Query='SELECT Id,abCountry__c from AddressBook__c';
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
       //Start Method to Execute the query
       return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
       //Loop Through all the incoming records
       //
       
       List<AddressBook__c> lstUpdateAbEntries = new List<AddressBook__c>();
                           
       for(sObject s : scope){
            AddressBook__c ab = (AddressBook__c)s;
               if(ab.abCountry__c != null)
            {
                   if(countryTranslationList__c.getInstance(ab.abCountry__c) != null)
                  {
                      ab.abCountry__c = countryTranslationList__c.getInstance(ab.abCountry__c).ctlTranslationName__c;
                      lstUpdateAbEntries.add(ab);
                  } 
                }    
        }
                           
        update lstUpdateAbEntries; 
   }

   global void finish(Database.BatchableContext BC){

   }

}