/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        March 23, 2016
Purpose             :        Handler class for OpportunityProductTrigger
                            

**************************************************************************************************************************************/

public class OpportunityProductTriggerHandler extends TriggerHandler {

    //declaring variables. collections

    Map<id, OpportunityLineItem> oldOLImap;
    Map<id, OpportunityLineItem> newOLImap;
    
    OpportunityProductTriggerHelper helperClass = new OpportunityProductTriggerHelper();

    //constructor
    public OpportunityProductTriggerHandler(Map<Id, OpportunityLineItem> oldOLImap, Map<Id, OpportunityLineItem> newOLImap) {
        this.oldOLImap = oldOLImap;
        this.newOLImap = newOLImap;
        System.debug('### 1');
    }

    protected override void beforeInsert(){}
    
    protected override void beforeUpdate(){}
    
    protected override void afterInsert(){
        System.debug('### 2.1 after Insert');
        helperClass.updateOpportunityDealType(oldOLImap, newOLImap, true);
    }
    
    protected override void afterUpdate(){
        System.debug('### 2.2 after update');
        //Commented on: April 39, 2016 
        //Reason: CR was created. New logic: this field will be updated via data warehouse
        //helperClass.updateOpportunityDealType(oldOLImap, newOLImap, true);
    }

    protected override void afterDelete(){
        System.debug('### 2.3 after delete');
        //Reason: CR was created. New logic: this field will be updated via data warehouse
        //helperClass.updateOpportunityDealType(oldOLImap, newOLImap, false);
    }

}