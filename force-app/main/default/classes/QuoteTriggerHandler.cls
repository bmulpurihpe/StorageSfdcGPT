public class QuoteTriggerHandler {
    
    public static Boolean isExecuted = false;
    
    public static void calculateQuoteRollupToOpportunity(List<SBQQ__Quote__c> quoteRecords, Map<Id, SBQQ__Quote__c> oldQuoteMap, System.TriggerOperation triggerOperation){
        
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunityToUpdate = new List<Opportunity>();
        
        Switch on triggerOperation{
            when AFTER_UPDATE{
                for(SBQQ__Quote__c quote : quoteRecords){
                    
                    if(String.isNotBlank(quote.SBQQ__Opportunity2__c) ){
                        opportunityIds.add(quote.SBQQ__Opportunity2__c);
                    }
                    
                    if(String.isNotBlank(oldQuoteMap.get(quote.Id).SBQQ__Opportunity2__c) ){
                        opportunityIds.add(oldQuoteMap.get(quote.Id).SBQQ__Opportunity2__c);
                    }
                }
            }
            when else{
                for(SBQQ__Quote__c quote : quoteRecords){
                
                    opportunityIds.add(quote.SBQQ__Opportunity2__c);
                }
            }
        }
        
        if(!opportunityIds.isEmpty()){
            
            opportunityToUpdate = [Select Id, of_Indirect_Quotes__c, of_Quotes__c, Quote_Count__c, ( Select Id, Quote_Source__c from SBQQ__Quotes2__r ) from Opportunity where Id IN: opportunityIds ];
            
            for(Opportunity opp : opportunityToUpdate){
            
                Integer indirectQuotesCount = 0;
                for(SBQQ__Quote__c quote : opp.SBQQ__Quotes2__r){
                    if(quote.Quote_Source__c == 'Indirect'){
                        indirectQuotesCount++;
                    }
                }
                opp.of_Indirect_Quotes__c = indirectQuotesCount;
                opp.of_Quotes__c = opp.SBQQ__Quotes2__r.isEmpty() ? 0 : opp.SBQQ__Quotes2__r.size();
                opp.Quote_Count__c = opp.SBQQ__Quotes2__r.isEmpty() ? 0 : opp.SBQQ__Quotes2__r.size();
            }
            
            if(!opportunityToUpdate.isEmpty()){
                //try{
                    update opportunityToUpdate;
                //} catch(exception ex){
                    
                //
            }
            
        }
    } 
}