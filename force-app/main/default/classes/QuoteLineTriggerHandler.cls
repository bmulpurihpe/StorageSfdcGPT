/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        April 30, 2016
Purpose             :        Handler class for QuoteLineTrigger
                            1) QuoteLineBeforeCustom
                            

**************************************************************************************************************************************/

public class QuoteLineTriggerHandler extends TriggerHandler {

    //declaring variables/collections

    Map<id, SBQQ__QuoteLine__c> oldQLImap;
    List<SBQQ__QuoteLine__c> qliList;
    
    QuoteLineTriggerHelper helperClass = new QuoteLineTriggerHelper();

    //constructor
    public QuoteLineTriggerHandler(Map<Id, SBQQ__QuoteLine__c> oldQLImap, List<SBQQ__QuoteLine__c> qliList) {
        System.debug('QuoteLine => QuoteLineTriggerHandler :: Entered');
        this.oldQLImap = oldQLImap;
        this.qliList = qliList;
    }
    /*
    protected override void beforeInsert(){
        System.debug('QuoteLine => QuoteLineTriggerHandler :: Entered => beforeInsert Method ');
        helperClass.restructureFormulaFields(qliList);
    }
    
    protected override void beforeUpdate(){
        System.debug('QuoteLine => QuoteLineTriggerHandler :: Entered => beforeUpdate Method ');
        helperClass.restructureFormulaFields(qliList);
    }
    
    protected override void afterInsert(){}

    protected override void afterUpdate(){}

    protected override void afterDelete(){}
    */
}