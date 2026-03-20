trigger QuoteTrigger on SBQQ__Quote__c (after insert, after update, after delete, after undelete) {

/***************************************************************************************************************
    Created By         : Srujan
    Created Date       : 05-22-2020
    Functionality      : This Trigger on Quote Object to calculate no of indirect Quotes for Opportunity.
   
    ***************************************************************************************************************/
    
    if(!QuoteTriggerHandler.isExecuted){
        QuoteTriggerHandler.isExecuted = true;
        Switch on Trigger.OperationType{
            when AFTER_INSERT{
                QuoteTriggerHandler.calculateQuoteRollupToOpportunity(Trigger.new, NULL, Trigger.OperationType);
            }
            when AFTER_UPDATE{
                QuoteTriggerHandler.calculateQuoteRollupToOpportunity(Trigger.new, Trigger.oldMap, Trigger.OperationType);
            }
            when AFTER_DELETE{
                QuoteTriggerHandler.calculateQuoteRollupToOpportunity(Trigger.old, NULL, Trigger.OperationType);
            }
            when AFTER_UNDELETE{
                QuoteTriggerHandler.calculateQuoteRollupToOpportunity(Trigger.new, NULL, Trigger.OperationType);
            }
        }
    }
}