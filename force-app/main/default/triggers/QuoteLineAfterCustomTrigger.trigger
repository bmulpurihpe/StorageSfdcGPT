trigger QuoteLineAfterCustomTrigger on SBQQ__QuoteLine__c (after insert,after update) {
 if(recursviveClass.recursiveTestCls){
  List<SBQQ__QuoteLine__c> parentChild  =[select id,Default_Factory__c,(select id,Default_Factory__c from SBQQ__Quote_Lines__r) from SBQQ__QuoteLine__c where id in:Trigger.New];
 
    List<SBQQ__QuoteLine__c> toUpdateRequiredBy=new List<SBQQ__QuoteLine__c>();
    
    for (SBQQ__QuoteLine__c line : parentChild) {
        List<SBQQ__QuoteLine__c> childToUpdate=line.SBQQ__Quote_Lines__r;
        for(SBQQ__QuoteLine__c childObj :childToUpdate){
        
        if(!String.isBlank(line.Default_Factory__c)){
        childObj.Default_Factory__c=line.Default_Factory__c;
        
        toUpdateRequiredBy.add(childObj);
        
        }
        
        }
      
    
    }
    update toUpdateRequiredBy;
    }
}