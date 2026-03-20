trigger NMBL_OPP_ProcessTrigger on Opportunity (before insert,before update,after insert,after update) {

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-11-2015
    Functionality      : This Trigger on Sales Order contains below mentioned functionality 
    
    1. on insert/update of sales order status to 'Approved by OA' a new WorkOrder will be created.          
    ***************************************************************************************************************/
    List<Opportunity> oppList = new List<Opportunity>();
    if(Trigger.isAfter){
        for(Opportunity op : Trigger.new){
            if(Trigger.IsInsert || (Trigger.IsUpdate && Trigger.oldMap.get(op.Id).StageName != op.StageName)){
                    oppList.add(op);
            }   
        }             
    }
    // Added by Srujan on 04/16/2019
   
    If(Trigger.Isbefore){
    Id NCVRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Nimble Cloud Volume (NCV)').getRecordTypeId(); // Addedby Srujan on 07/29/2019
        Set<String> hpeOpp = new Set<String>();                                                                                        // Addedby Srujan on 07/29/2019
           for(Opportunity opp : Trigger.new){
           If(opp.RecordTypeId != NCVRecordTypeId){
             if(Trigger.IsInsert ||  (Trigger.IsUpdate && ((Trigger.oldMap.get(opp.Id).HPE_Opportunity_ID__c != opp.HPE_Opportunity_ID__c && opp.HPE_Opportunity_ID__c != null)
                                 ||(Trigger.oldMap.get(opp.Id).Amount != opp.Amount  )))) {
              //System.debug('opp.Amount====================='+opp.Amount);  
               //System.debug('opp.HPE_Opportunity_ID__c====================='+opp.HPE_Opportunity_ID__c);                 
             If((opp.Amount == null || opp.Amount == 0.00 ) && (opp.HPE_Opportunity_ID__c!=null && opp.HPE_Opportunity_ID__c =='OPE-0000000000')){
                 break;
             } 
             else if(opp.HPE_Opportunity_ID__c!=null ){
            
                hpeOpp.add(opp.HPE_Opportunity_ID__c);
                }
            }
            } 
            }
        If(!hpeOpp.isEmpty()){
            List<Opportunity> listOfOppties= [select id,HPE_Opportunity_ID__c from opportunity where HPE_Opportunity_ID__c != null and HPE_Opportunity_ID__c IN:hpeOpp];
            Map<String,Id> mapOfOppties= new Map<String,Id> ();
            if(listOfOppties.size()>1){
            for(Opportunity op:listOfOppties){
                mapOfOppties.put(op.HPE_Opportunity_ID__c,op.id);
            }
            
            for(Opportunity opps:Trigger.new){
                
                if(mapOfOppties.get(opps.HPE_Opportunity_ID__c)!=null){
                    opps.addError('Duplicate HPE Opportunity');
                }
            }
            }
        }
    }
    
     // Added by Srujan on 04/16/2019 -End
    
    if(oppList.size() > 0)
       OpportunityProcessClass.InsertWorkOrder(oppList);
  
}