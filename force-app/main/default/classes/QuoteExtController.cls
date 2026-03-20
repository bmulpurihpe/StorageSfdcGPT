public with sharing class QuoteExtController {
    private Id quoteId;
    public SBAA__Approval__c[] approvals {get; set;}
    
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }

    @RemoteAction
    public static PageReference onSubmit(id quoteId) {
        System.debug('=== Entered OnSubmit method in controller for quote ID:: '+ quoteId);
        if (quoteId != null) {
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
        }
             
        return new PageReference('/' + quoteId);
    }
    
    public PageReference onRecall() {
        if (quoteId != null) {
            System.debug('==== Checkpoint 1:: Quote Id is: '+ quoteId);
  
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);           
        }
        return new PageReference('/' + quoteId);
    }
    
    
    public PageReference onPreview() {
        if (quoteId != null) {
            approvals = SBAA.ApprovalAPI.preview(quoteId, SBAA__Approval__c.Quote__c);
        }
        return null;
    }
}