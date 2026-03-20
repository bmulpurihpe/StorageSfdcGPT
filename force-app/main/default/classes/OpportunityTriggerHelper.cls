//*****************************************************************************************************
// Name         : OpportunityTriggerHelper
// Created by   : Sharath
// Description  : This class is used for 
//                1.Update of # of Channel Regs Generated on Call Blitz Object.
//                
//******************************************************************************************************

public class OpportunityTriggerHelper {
    
    public static void rollUpChannelsCallBlitz(List<Opportunity> opptyRecords , Map<Id,Opportunity> opptyMap) {
        
        //These variables are used for updating Call Blitz
        Set<Id> relatedids = new Set<Id>();
        Map<Id,Double> idVsValuesToUpdate = new Map<Id,Double>();
        List<Call_Blitz__c> callBlitzToUpdate = new List<Call_Blitz__c>();

        
        //Iterate over the first parameter opptyRecords (Trigger.new/Trigger.old) 
        //Store all callBlitz record Ids related to Opportunity.
        for(Opportunity opp : opptyRecords) {
            if(opp.Call_Blitz__c != null){
                relatedids.add(opp.Call_Blitz__c);
                if(opptyMap != null) {
                   if(opp.Call_Blitz__c != opptyMap.get(opp.Id).Call_Blitz__c) {
                      relatedids.add(opptyMap.get(opp.Id).Call_Blitz__c);
                   }
                }
            }
        }  
        system.debug( ' *** size of relatedids ' + relatedids.size());
        if(relatedids.size() > 0){
            //Aggregate query is used to fetch count of opptys
            //associated to each Call Blitz in a map idVsValuesToUpdate
            for(AggregateResult opty : [SELECT Call_Blitz__c,Count(Id)
                                        FROM Opportunity WHERE Call_Blitz__c IN : relatedids
                                        GROUP BY Call_Blitz__c]) {
                idVsValuesToUpdate.put((Id)opty.get('Call_Blitz__c'),(Double)opty.get('expr0'));            
            }
            
            
            //Logic to update of_Channel_Regs_Generated__c values appropriately
            // based on idVsValuesToUpdate Map and put null/zero if none of the related
            // Call Blitz records exist
            for(Call_Blitz__c cblitz : [SELECT Id,of_Channel_Regs_Generated__c 
                                        FROM Call_Blitz__c where Id IN : relatedids]) {
                if(idVsValuesToUpdate.ContainsKey(cblitz.Id)) {                
                    cblitz.of_Channel_Regs_Generated__c = idVsValuesToUpdate.get(cblitz.Id);
                }
                else {
                    cblitz.of_Channel_Regs_Generated__c = null;
                }
                callBlitzToUpdate.add(cblitz);
            }
        
        }
        // These variables are used to ids of Successful records and error messages
        Set<Id> successCallBlitzIds  = new Set<Id>();
        Set<String> errorCallBlitz   = new Set<String>();
        
        if(callBlitzToUpdate.size() > 0) {
              Database.saveResult[] saveResultCallBlitz  = Database.update(callBlitzToUpdate,false);
              
              for(Database.saveResult sr : saveResultCallBlitz) {
                    if(sr.isSuccess()){
                            successCallBlitzIds.add(sr.getId());
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            errorCallBlitz.add(err.getMessage());
                        } 
                    }
              }
       }
       
       
       // Iteration of optyRecords is done once again to make sure multiple errors 
       // are shown in case if multiple errors are thrown 
       if(errorCallBlitz.size() > 0 ){
           for(Opportunity opp : opptyRecords) {
                  if(!successCallBlitzIds.contains(opp.Call_Blitz__c)){
                      for(String err: errorCallBlitz) {
                          opp.addError(err);
                      }          
                  }
             }
        }   
        
    }
}