/****************************************************************************************************************************
Created By      : Sudhir N
Created Date    : 1/7/2017
Purpose         : NCV Trigger frame work

****************************************************************************************************************************/


public class NCVTriggerHandler extends TriggerHandler {

     //declaring variables. collections

 
    list<Nimble_Cloud_Volume__c> newOLImap = new list<Nimble_Cloud_Volume__c>();
    
    // NCVTriggerHelper helperClass = new NCVTriggerHelper();

    //constructor  // list of new values and old values 
    public NCVTriggerHandler(list<Nimble_Cloud_Volume__c> NCVlst) {
        this.newOLImap = NCVlst;
    }
       
    //protected override void beforeInsert(){}
    
   // protected override void beforeUpdate(){}
    
    protected override void afterInsert(){
     system.debug('After Insert'); 
     NCVTriggerHelper.updateNCT(newOLImap);      
    }
    
    protected override void afterUpdate(){
     system.debug('After Update'); 
     NCVTriggerHelper.updateNCT(newOLImap);  
    }

    //protected override void afterDelete(){}
    
    
  
    
    
}